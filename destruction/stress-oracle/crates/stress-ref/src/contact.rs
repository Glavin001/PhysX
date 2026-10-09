//! Contact geometry for the standalone world: oriented boxes, spheres and the ground.
//!
//! Penalty contact is resolved at the stress substep, so impact forces build up and
//! decay over the physical contact duration set by the contact stiffness and masses;
//! there is no impulse divided by a timestep anywhere.
//!
//! Chunks that were bonded can still overlap slightly when they separate (residual
//! bond deformation and rotation). The world records that initial overlap per sample
//! point at the start of the contact episode and resists only further penetration,
//! so a split never converts it into spurious kinetic energy.
//!
//! Box contact uses sample points: the 8 corners pulled 10% towards the centre plus the
//! 6 face centres. Pulling corners inwards avoids double counting where the corners of
//! aligned, equal chunks meet exactly on an edge.

use crate::math::{Mat3, Vec3};

/// An oriented box in world space.
#[derive(Clone, Copy, Debug)]
pub struct OBox {
    pub center: Vec3,
    pub rotation: Mat3,
    pub half: Vec3,
}

/// A penetrating contact: `normal` points from the first shape towards the second.
#[derive(Clone, Copy, Debug)]
pub struct ContactPoint {
    /// Sample-point index on the first shape (0 for spheres).
    pub index: usize,
    pub point: Vec3,
    pub normal: Vec3,
    pub depth: f64,
}

pub const SAMPLE_POINTS: usize = 14;

impl OBox {
    pub fn bounding_radius(&self) -> f64 {
        self.half.norm()
    }

    pub fn sample_points(&self) -> [Vec3; SAMPLE_POINTS] {
        let mut pts = [Vec3::ZERO; SAMPLE_POINTS];
        let h = self.half * 0.9;
        for (i, p) in pts.iter_mut().take(8).enumerate() {
            let s = Vec3::new(
                if i & 1 == 0 { -h.x } else { h.x },
                if i & 2 == 0 { -h.y } else { h.y },
                if i & 4 == 0 { -h.z } else { h.z },
            );
            *p = self.center + self.rotation * s;
        }
        for axis in 0..3 {
            for (k, sign) in [(0usize, -1.0f64), (1usize, 1.0f64)] {
                let mut v = Vec3::ZERO;
                v[axis] = sign * self.half[axis];
                pts[8 + 2 * axis + k] = self.center + self.rotation * v;
            }
        }
        pts
    }

    /// If `p` is inside, the depth to the nearest face and that face's outward normal.
    pub fn penetration(&self, p: Vec3) -> Option<(f64, Vec3)> {
        let local = self.rotation.transpose() * (p - self.center);
        let mut best = f64::INFINITY;
        let mut axis = 0;
        for k in 0..3 {
            let d = self.half[k] - local[k].abs();
            if d <= 0.0 {
                return None;
            }
            if d < best {
                best = d;
                axis = k;
            }
        }
        let mut n = Vec3::ZERO;
        n[axis] = if local[axis] >= 0.0 { 1.0 } else { -1.0 };
        Some((best, self.rotation * n))
    }

    /// Sample points of `self` inside `other`. Normals point from `other` towards `self`
    /// reversed, i.e. from `self` to `other`'s interior is `-normal`: here `normal` is
    /// `other`'s outward face normal, which pushes `self` out of `other`.
    pub fn points_inside(&self, other: &OBox) -> Vec<ContactPoint> {
        self.sample_points()
            .iter()
            .enumerate()
            .filter_map(|(index, &p)| other.penetration(p).map(|(depth, normal)| ContactPoint { index, point: p, normal, depth }))
            .collect()
    }

    /// Sphere against this box: normal points from the box to the sphere centre.
    pub fn sphere_contact(&self, center: Vec3, radius: f64) -> Option<ContactPoint> {
        let local = self.rotation.transpose() * (center - self.center);
        let q = Vec3::new(
            local.x.clamp(-self.half.x, self.half.x),
            local.y.clamp(-self.half.y, self.half.y),
            local.z.clamp(-self.half.z, self.half.z),
        );
        let d = local - q;
        let dist = d.norm();
        if dist > 1e-12 {
            if dist >= radius {
                return None;
            }
            let n = self.rotation * (d / dist);
            return Some(ContactPoint { index: 0, point: self.center + self.rotation * q, normal: n, depth: radius - dist });
        }
        // Centre inside the box: push out through the nearest face.
        let (inside, n) = self.penetration(center)?;
        Some(ContactPoint { index: 0, point: center - n * (radius.min(inside)), normal: n, depth: radius + inside })
    }

    /// Ray (segment `a + t (b - a)`, `t in [0, 1]`) against the box: entry parameter.
    pub fn segment_hit(&self, a: Vec3, b: Vec3) -> Option<f64> {
        let ro = self.rotation.transpose() * (a - self.center);
        let rd = self.rotation.transpose() * (b - a);
        let mut t0: f64 = 0.0;
        let mut t1: f64 = 1.0;
        for k in 0..3 {
            if rd[k].abs() < 1e-15 {
                if ro[k].abs() > self.half[k] {
                    return None;
                }
            } else {
                let inv = 1.0 / rd[k];
                let (mut ta, mut tb) = ((-self.half[k] - ro[k]) * inv, (self.half[k] - ro[k]) * inv);
                if ta > tb {
                    std::mem::swap(&mut ta, &mut tb);
                }
                t0 = t0.max(ta);
                t1 = t1.min(tb);
                if t0 > t1 {
                    return None;
                }
            }
        }
        Some(t0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn unit_box(c: Vec3) -> OBox {
        OBox { center: c, rotation: Mat3::IDENTITY, half: Vec3::splat(0.5) }
    }

    #[test]
    fn sphere_touching_a_face() {
        let b = unit_box(Vec3::ZERO);
        let c = b.sphere_contact(Vec3::new(0.0, 0.0, 0.9), 0.5).unwrap();
        assert!((c.depth - 0.1).abs() < 1e-12);
        assert!((c.normal - Vec3::Z).norm() < 1e-12);
        assert!(b.sphere_contact(Vec3::new(0.0, 0.0, 1.1), 0.5).is_none());
    }

    #[test]
    fn stacked_boxes_overlap_once_per_point() {
        let a = unit_box(Vec3::new(0.0, 0.0, 0.95));
        let b = unit_box(Vec3::ZERO);
        let pts = a.points_inside(&b);
        // Four shrunk bottom corners and the bottom face centre are inside.
        assert_eq!(pts.len(), 5);
        assert!(pts.iter().all(|p| (p.normal - Vec3::Z).norm() < 1e-12));
    }

    #[test]
    fn segment_hits_box() {
        let b = unit_box(Vec3::ZERO);
        let t = b.segment_hit(Vec3::new(-2.0, 0.0, 0.0), Vec3::new(2.0, 0.0, 0.0)).unwrap();
        assert!((t - 0.375).abs() < 1e-12);
        assert!(b.segment_hit(Vec3::new(-2.0, 1.0, 0.0), Vec3::new(2.0, 1.0, 0.0)).is_none());
    }
}
