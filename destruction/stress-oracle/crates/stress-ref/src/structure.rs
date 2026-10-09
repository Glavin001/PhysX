//! Static (per-scene) data of a destructible structure: chunks and bonds with their
//! mass, geometry, stiffness and strength resolved from the scene description.

use crate::bond::{BondGeometry, BondStiffness, Local6};
use crate::joint::{JointStrength, RebarParams};
use crate::material::{bond_strength_factor, Material};
use crate::math::{Mat3, Quat, Vec3};
use crate::scene::{box_mass_inertia, BodyDesc, Scene, Support};

/// One face of a box chunk (body frame).
#[derive(Clone, Copy, Debug)]
pub struct Face {
    /// Outward unit normal.
    pub normal: Vec3,
    /// Face centre relative to the chunk centre.
    pub offset: Vec3,
    pub area: f64,
}

#[derive(Clone, Debug)]
pub struct ChunkData {
    pub center: Vec3,
    pub half_extents: Vec3,
    /// Orientation of the box in the body frame.
    pub rotation: Mat3,
    pub mass: f64,
    /// Inertia about the chunk centre, body frame.
    pub inertia: Mat3,
    pub inv_inertia: Mat3,
    pub material: String,
    pub support: Support,
    pub groups: Vec<String>,
    pub level: u32,
    pub parent: Option<usize>,
    pub children: Vec<usize>,
    pub faces: [Face; 6],
    /// Bond indices touching this chunk.
    pub bonds: Vec<usize>,
}

impl ChunkData {
    pub fn volume(&self) -> f64 {
        8.0 * self.half_extents.x * self.half_extents.y * self.half_extents.z
    }

    /// The eight corners relative to the chunk centre (body frame).
    pub fn corners(&self) -> [Vec3; 8] {
        let h = self.half_extents;
        let mut out = [Vec3::ZERO; 8];
        for (i, c) in out.iter_mut().enumerate() {
            let s = Vec3::new(
                if i & 1 == 0 { -h.x } else { h.x },
                if i & 2 == 0 { -h.y } else { h.y },
                if i & 4 == 0 { -h.z } else { h.z },
            );
            *c = self.rotation * s;
        }
        out
    }
}

#[derive(Clone, Debug)]
pub struct BondData {
    pub geometry: BondGeometry,
    /// Stiffness with the scene's stiffness scale applied.
    pub stiffness: BondStiffness,
    pub strength: JointStrength,
    pub rebar: Option<RebarParams>,
    /// Weibull strength multiplier (1 for deterministic materials).
    pub weibull: f64,
    /// Dashpot coefficients per component (stiffness-proportional, `beta k`).
    pub damping: Local6,
    pub level: u32,
    pub groups: Vec<String>,
    /// Face of chunk `a` (and `b`) the bond covers.
    pub face_a: usize,
    pub face_b: usize,
    /// Joint material, buckling length and rebar, kept to re-derive the bond when it
    /// is re-attached to coarser chunks (multi-level refinement).
    pub material: Material,
    pub buckling_length: Option<f64>,
    pub rebar_spec: Option<(f64, Material)>,
}

/// Stiffness, strength, rebar and dashpots of a bond with the given geometry.
pub fn bond_physics(
    geometry: &BondGeometry,
    material: &Material,
    buckling_length: Option<f64>,
    rebar: Option<&(f64, Material)>,
    stiffness_scale: f64,
    reduced_mass: f64,
) -> (BondStiffness, JointStrength, Option<RebarParams>, Local6) {
    let stiffness = BondStiffness::new(geometry, material, stiffness_scale);
    let strength = JointStrength::new(material, geometry, buckling_length, stiffness_scale);
    let rebar = rebar.map(|(area, steel)| RebarParams::new(*area, steel, geometry.length, stiffness_scale));
    // Stiffness-proportional dashpots: damping ratio `zeta` at the bond's own axial
    // frequency, proportionally less for slower (global) modes.
    let omega = (stiffness.kn / reduced_mass).sqrt();
    let beta = 2.0 * material.damping_ratio / omega;
    (stiffness, strength, rebar, stiffness.as_local().scale(beta))
}

/// Reduced mass of a bond's two chunks (a supported chunk counts as immovable).
pub fn reduced_mass(a: &ChunkData, b: &ChunkData) -> f64 {
    match (a.support, b.support) {
        (Support::None, Support::None) => a.mass * b.mass / (a.mass + b.mass),
        (Support::None, _) => a.mass,
        (_, Support::None) => b.mass,
        _ => a.mass.min(b.mass),
    }
}

#[derive(Clone, Debug)]
pub struct Structure {
    pub name: String,
    pub chunks: Vec<ChunkData>,
    pub bonds: Vec<BondData>,
    pub initial_position: Vec3,
    pub initial_rotation: Quat,
    pub initial_velocity: Vec3,
    pub initial_angular_velocity: Vec3,
    pub stiffness_scale: f64,
}

/// The face of a box whose outward normal is closest to `dir` (body frame).
fn face_index(faces: &[Face; 6], dir: Vec3) -> usize {
    (0..6).max_by(|&i, &j| faces[i].normal.dot(dir).total_cmp(&faces[j].normal.dot(dir))).unwrap()
}

fn faces_of(half: Vec3, rot: Mat3) -> [Face; 6] {
    let mut faces = [Face { normal: Vec3::ZERO, offset: Vec3::ZERO, area: 0.0 }; 6];
    for axis in 0..3 {
        let (a, b) = ((axis + 1) % 3, (axis + 2) % 3);
        let area = 4.0 * half[a] * half[b];
        for (s, sign) in [(0usize, -1.0f64), (1usize, 1.0f64)] {
            let mut n = Vec3::ZERO;
            n[axis] = sign;
            let n = rot * n;
            faces[2 * axis + s] = Face { normal: n, offset: n * half[axis], area };
        }
    }
    faces
}

impl Structure {
    /// Build structure `index` of `scene` with its stiffness scale and Weibull seed.
    pub fn from_scene(scene: &Scene, index: usize) -> Structure {
        let body: &BodyDesc = &scene.bodies[index];
        let scale = scene.sim.stiffness_scale;
        let mut chunks: Vec<ChunkData> = body
            .chunks
            .iter()
            .map(|c| {
                let m = scene.material(&c.material);
                let (mass, inertia) = box_mass_inertia(c.half_extents, c.orientation, m.density);
                let rotation = Quat::from_wxyz(c.orientation).to_mat3();
                let half = Vec3::from_array(c.half_extents);
                ChunkData {
                    center: Vec3::from_array(c.center),
                    half_extents: half,
                    rotation,
                    mass,
                    inertia,
                    inv_inertia: inertia.inverse().expect("chunk inertia is invertible"),
                    material: c.material.clone(),
                    support: c.support,
                    groups: c.groups.clone(),
                    level: c.level,
                    parent: c.parent,
                    children: Vec::new(),
                    faces: faces_of(half, rotation),
                    bonds: Vec::new(),
                }
            })
            .collect();
        for i in 0..chunks.len() {
            if let Some(p) = chunks[i].parent {
                chunks[p].children.push(i);
            }
        }

        let mut bonds = Vec::with_capacity(body.bonds.len());
        for (bi, desc) in body.bonds.iter().enumerate() {
            let m: &Material = scene.material(&desc.material);
            let geometry = BondGeometry::from_desc(desc, &body.chunks);
            let rebar_spec = desc.rebar.as_ref().map(|r| (r.area, scene.material(&r.material).clone()));
            let mred = reduced_mass(&chunks[desc.a], &chunks[desc.b]);
            let (stiffness, strength, rebar, damping) =
                bond_physics(&geometry, m, desc.buckling_length, rebar_spec.as_ref(), scale, mred);
            let weibull = bond_strength_factor(m.weibull_modulus, scene.sim.seed, index, bi);
            let face_a = face_index(&chunks[desc.a].faces, geometry.normal);
            let face_b = face_index(&chunks[desc.b].faces, -geometry.normal);
            chunks[desc.a].bonds.push(bi);
            chunks[desc.b].bonds.push(bi);
            bonds.push(BondData {
                geometry,
                stiffness,
                strength,
                rebar,
                weibull,
                damping,
                level: desc.level,
                groups: desc.groups.clone(),
                face_a,
                face_b,
                material: m.clone(),
                buckling_length: desc.buckling_length,
                rebar_spec,
            });
        }

        Structure {
            name: body.name.clone(),
            chunks,
            bonds,
            initial_position: Vec3::from_array(body.position),
            initial_rotation: Quat::from_wxyz(body.orientation),
            initial_velocity: Vec3::from_array(body.linear_velocity),
            initial_angular_velocity: Vec3::from_array(body.angular_velocity),
            stiffness_scale: scale,
        }
    }

    pub fn bond_other(&self, bond: usize, chunk: usize) -> usize {
        let g = &self.bonds[bond].geometry;
        if g.a == chunk {
            g.b
        } else {
            g.a
        }
    }
}
