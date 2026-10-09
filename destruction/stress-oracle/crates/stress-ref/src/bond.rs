//! Bond geometry, stiffness and kinematics.
//!
//! A bond is a beam-type joint between two rigid chunks (the rigid-body-spring /
//! Applied-Element family). It sits at the centroid `c` of the contact patch with a
//! local frame `(t1, t2, n)`; `n` points from chunk `a` to chunk `b`. Six springs act
//! there:
//!
//! | component        | stiffness        |
//! |------------------|------------------|
//! | axial (along n)  | `kn = E A / L`   |
//! | shear (t1, t2)   | `ks = G A / L`   |
//! | bending about t1 | `E I_t1 / L`     |
//! | bending about t2 | `E I_t2 / L`     |
//! | torsion about n  | `G J / L`        |
//!
//! `L` is the chunk spacing measured along the normal (centre of `a` to the patch plus
//! the patch to the centre of `b`). `I_t1` is the second moment of the patch for bending
//! about `t1` (stress varies along `t2`). The patch is treated as a `width[0] x width[1]`
//! rectangle (`width[0]` along `t1`).
//!
//! Generalised displacements are the relative motion of `b` with respect to `a` at the
//! patch centroid: `Delta = (u_b + theta_b x r_b) - (u_a + theta_a x r_a)`,
//! `Phi = theta_b - theta_a`, with `r_x = c - x_x`. Generalised forces follow the sign
//! convention "tension positive": the axial force `N > 0` pulls the chunks together.

use crate::material::Material;
use crate::math::{Mat3, Vec3};
use crate::scene::{BondDesc, ChunkDesc};

/// Local components: index 0 = t1, 1 = t2, 2 = n.
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct Local6 {
    /// Translational part (shear t1, shear t2, axial n).
    pub lin: Vec3,
    /// Rotational part (bending about t1, bending about t2, torsion about n).
    pub ang: Vec3,
}

impl Local6 {
    pub const ZERO: Local6 = Local6 { lin: Vec3::ZERO, ang: Vec3::ZERO };
    pub fn dot(&self, o: &Local6) -> f64 {
        self.lin.dot(o.lin) + self.ang.dot(o.ang)
    }
    pub fn scale(&self, s: f64) -> Local6 {
        Local6 { lin: self.lin * s, ang: self.ang * s }
    }
    pub fn add(&self, o: &Local6) -> Local6 {
        Local6 { lin: self.lin + o.lin, ang: self.ang + o.ang }
    }
    pub fn mul_elem(&self, k: &Local6) -> Local6 {
        Local6 { lin: self.lin.mul_elem(k.lin), ang: self.ang.mul_elem(k.ang) }
    }
}

/// Undeformed geometry of a bond, in the body frame.
#[derive(Clone, Debug)]
pub struct BondGeometry {
    pub a: usize,
    pub b: usize,
    pub centroid: Vec3,
    pub normal: Vec3,
    pub t1: Vec3,
    pub t2: Vec3,
    pub area: f64,
    pub width: [f64; 2],
    /// Chunk spacing along the normal.
    pub length: f64,
    /// Patch centroid relative to chunk centres.
    pub ra: Vec3,
    pub rb: Vec3,
    /// Second moment for bending about t1 (`w0 w1^3 / 12`) and about t2 (`w1 w0^3 / 12`).
    pub i_t1: f64,
    pub i_t2: f64,
    /// Saint-Venant torsion constant of the rectangle.
    pub torsion_constant: f64,
    /// Elastic section moduli: extreme-fibre bending stress = M / S.
    pub s_t1: f64,
    pub s_t2: f64,
    /// Torsional section modulus: max shear stress = T / W.
    pub torsion_modulus: f64,
    /// Effective friction radius of the patch (torsional friction lever).
    pub friction_radius: f64,
}

impl BondGeometry {
    pub fn from_desc(desc: &BondDesc, chunks: &[ChunkDesc]) -> BondGeometry {
        let xa = Vec3::from_array(chunks[desc.a].center);
        let xb = Vec3::from_array(chunks[desc.b].center);
        BondGeometry::new(
            desc.a,
            desc.b,
            xa,
            xb,
            Vec3::from_array(desc.centroid),
            Vec3::from_array(desc.normal),
            Vec3::from_array(desc.tangent),
            desc.area,
            desc.width,
        )
    }

    #[allow(clippy::too_many_arguments)]
    pub fn new(
        a: usize,
        b: usize,
        xa: Vec3,
        xb: Vec3,
        centroid: Vec3,
        normal: Vec3,
        tangent: Vec3,
        area: f64,
        width: [f64; 2],
    ) -> BondGeometry {
        let n = normal.normalized();
        let t1 = (tangent - n * tangent.dot(n)).normalized();
        let t2 = n.cross(t1);
        let ra = centroid - xa;
        let rb = centroid - xb;
        let length = (ra.dot(n)).abs() + (rb.dot(n)).abs();
        assert!(length > 0.0, "bond {a}-{b}: zero chunk spacing along the normal");
        let (w0, w1) = (width[0], width[1]);
        let i_t1 = w0 * w1.powi(3) / 12.0;
        let i_t2 = w1 * w0.powi(3) / 12.0;
        let (long, short) = if w0 >= w1 { (w0, w1) } else { (w1, w0) };
        let ratio = short / long;
        let torsion_constant = long * short.powi(3) * (1.0 / 3.0 - 0.21 * ratio * (1.0 - ratio.powi(4) / 12.0));
        let alpha = 1.0 / (3.0 + 1.8 * ratio);
        let torsion_modulus = alpha * long * short * short;
        BondGeometry {
            a,
            b,
            centroid,
            normal: n,
            t1,
            t2,
            area,
            width,
            length,
            ra,
            rb,
            i_t1,
            i_t2,
            torsion_constant,
            s_t1: i_t1 / (0.5 * w1),
            s_t2: i_t2 / (0.5 * w0),
            torsion_modulus,
            friction_radius: (w0 + w1) / 6.0,
        }
    }

    /// Body-frame vector -> local (t1, t2, n) components.
    pub fn to_local(&self, v: Vec3) -> Vec3 {
        Vec3::new(v.dot(self.t1), v.dot(self.t2), v.dot(self.normal))
    }

    /// Local components -> body-frame vector.
    pub fn to_body(&self, l: Vec3) -> Vec3 {
        self.t1 * l.x + self.t2 * l.y + self.normal * l.z
    }

    /// Generalised relative displacement (local) from the chunk DOFs.
    pub fn kinematics(&self, ua: Vec3, tha: Vec3, ub: Vec3, thb: Vec3) -> Local6 {
        let delta = (ub + thb.cross(self.rb)) - (ua + tha.cross(self.ra));
        let phi = thb - tha;
        Local6 { lin: self.to_local(delta), ang: self.to_local(phi) }
    }

    /// Chunk loads produced by local generalised bond forces `q` (tension-positive
    /// convention). Returns `(force_a, moment_a, force_b, moment_b)` in the body
    /// frame; moments are about each chunk's centre. This is the transpose of
    /// [`kinematics`](Self::kinematics), so work and energy are consistent.
    pub fn chunk_loads(&self, q: &Local6) -> (Vec3, Vec3, Vec3, Vec3) {
        let f = self.to_body(q.lin);
        let m = self.to_body(q.ang);
        let fa = f;
        let fb = -f;
        let ma = m + self.ra.cross(fa);
        let mb = -m + self.rb.cross(fb);
        (fa, ma, fb, mb)
    }

    /// The 6x6 coupling block helpers for the static solver: `B_a`, `B_b` such that
    /// `delta = B_b [u_b; th_b] - B_a [u_a; th_a]` (translational part), as 3x3 pieces.
    pub fn skew_ra(&self) -> Mat3 {
        Mat3::skew(self.ra)
    }
    pub fn skew_rb(&self) -> Mat3 {
        Mat3::skew(self.rb)
    }
}

/// Elastic stiffness of the six bond springs (possibly with scaled moduli).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct BondStiffness {
    pub kn: f64,
    pub ks: f64,
    pub kb_t1: f64,
    pub kb_t2: f64,
    pub kt: f64,
}

impl BondStiffness {
    pub fn new(g: &BondGeometry, m: &Material, stiffness_scale: f64) -> BondStiffness {
        let e = m.youngs_modulus * stiffness_scale;
        let gs = m.shear_modulus() * stiffness_scale;
        let l = g.length;
        BondStiffness {
            kn: e * g.area / l,
            ks: gs * g.area / l,
            kb_t1: e * g.i_t1 / l,
            kb_t2: e * g.i_t2 / l,
            kt: gs * g.torsion_constant / l,
        }
    }

    pub fn as_local(&self) -> Local6 {
        Local6 { lin: Vec3::new(self.ks, self.ks, self.kn), ang: Vec3::new(self.kb_t1, self.kb_t2, self.kt) }
    }

    pub fn scaled(&self, s: f64) -> BondStiffness {
        BondStiffness { kn: self.kn * s, ks: self.ks * s, kb_t1: self.kb_t1 * s, kb_t2: self.kb_t2 * s, kt: self.kt * s }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn unit_bond() -> BondGeometry {
        BondGeometry::new(
            0,
            1,
            Vec3::new(0.0, 0.0, 0.0),
            Vec3::new(1.0, 0.0, 0.0),
            Vec3::new(0.5, 0.0, 0.0),
            Vec3::X,
            Vec3::Y,
            0.04,
            [0.2, 0.2],
        )
    }

    #[test]
    fn rigid_motion_produces_no_deformation() {
        let g = unit_bond();
        // A common rigid rotation theta about the origin: u = theta x x.
        let th = Vec3::new(0.01, -0.02, 0.03);
        let xa = Vec3::ZERO;
        let xb = Vec3::new(1.0, 0.0, 0.0);
        let k = g.kinematics(th.cross(xa), th, th.cross(xb), th);
        assert!(k.lin.norm() < 1e-15 && k.ang.norm() < 1e-15);
    }

    #[test]
    fn loads_are_self_equilibrated() {
        let g = BondGeometry::new(
            0,
            1,
            Vec3::new(0.1, 0.2, -0.3),
            Vec3::new(0.9, -0.1, 0.4),
            Vec3::new(0.5, 0.0, 0.0),
            Vec3::new(1.0, 0.2, 0.1).normalized(),
            Vec3::new(1.0, 0.2, 0.1).normalized().any_perpendicular(),
            0.04,
            [0.3, 0.1],
        );
        let q = Local6 { lin: Vec3::new(1.0, -2.0, 3.0), ang: Vec3::new(0.5, 0.25, -0.75) };
        let (fa, ma, fb, mb) = g.chunk_loads(&q);
        let xa = Vec3::new(0.1, 0.2, -0.3);
        let xb = Vec3::new(0.9, -0.1, 0.4);
        assert!((fa + fb).norm() < 1e-14);
        let total_moment = ma + mb + xa.cross(fa) + xb.cross(fb);
        assert!(total_moment.norm() < 1e-13, "{total_moment:?}");
    }

    #[test]
    fn square_torsion_constant_matches_handbook() {
        let g = unit_bond();
        // Square side a: J = 0.1406 a^4, tau_max = T / (0.208 a^3).
        assert!((g.torsion_constant / 0.2f64.powi(4) - 0.1406).abs() < 1e-3);
        assert!((g.torsion_modulus / 0.2f64.powi(3) - 0.208).abs() < 1e-3);
    }
}
