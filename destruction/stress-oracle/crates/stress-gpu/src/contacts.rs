//! Contact planning for a segment (`shaders/world.slang`): candidate chunk pairs,
//! impactor and ground candidates from bounds swept over the segment, the contact data
//! of every chunk, impactors, and the per-pair memory of pre-existing overlap.
//!
//! Candidates are a superset of what the reference tests in any substep of the segment:
//! each chunk gets a travel budget (twice its speed bound over the segment, plus gravity
//! and a margin), pairs within the sum of radii and budgets are candidates, and the GPU
//! stops the batch if a chunk leaves its budget, so the host re-plans from the state
//! then reached. The GPU then applies the reference's own tests to every candidate.

use std::collections::HashMap;

use stress_ref::math::{Mat3, Vec3};
use stress_ref::scene::{ImpactorShape, Scene};
use stress_ref::solver::ReferenceSolver;
use stress_ref::world::Impactor;

/// A chunk pair key as the reference keys `pair_offsets`: (structure, chunk) of the chunk
/// in the lower-index cluster first.
pub type PairKey = (usize, usize, usize, usize);

/// The sample-point offsets of a pair, a's samples then b's (offset, normal; NaN offset:
/// not in contact).
pub type PairState = Vec<[f32; 4]>;

/// Contact sample points of a chunk (contact.rs `sample_count`).
pub fn sample_count(chunk: &stress_ref::structure::ChunkData) -> usize {
    chunk.hull.as_ref().map_or(stress_ref::contact::SAMPLE_POINTS, |h| h.vertices.len() + h.faces.len())
}

pub const NAN_STATE: [f32; 4] = [f32::NAN, 0.0, 0.0, 0.0];

/// The contact plan of a segment.
#[derive(Default)]
pub struct Plan {
    /// Candidate pairs (key, gpu chunk a, gpu chunk b, reduced mass, friction).
    pub pairs: Vec<(PairKey, u32, u32, f64, f64)>,
    /// Per impactor: candidate gpu chunks in the reference's order.
    pub impactor_chunks: Vec<Vec<u32>>,
    /// Gpu chunks that may touch the ground.
    pub ground: Vec<u32>,
    /// Clusters (by index) in the contact pipeline this segment.
    pub contact_clusters: Vec<bool>,
    /// Travel budget per gpu chunk (m).
    pub budget: Vec<f64>,
}

/// Plane-strain modulus (scaled) of a material, as world.rs uses it for contacts.
pub fn modulus(scene: &Scene, material: &str) -> f64 {
    let m = scene.material(material);
    m.youngs_modulus * scene.sim.stiffness_scale / (1.0 - m.poisson_ratio * m.poisson_ratio)
}

/// Candidates for the next `duration` seconds from the mirror's current state.
pub fn plan(scene: &Scene, m: &ReferenceSolver, impactors: &[Impactor], chunk_order: &[(usize, usize)], duration: f64) -> Plan {
    let g = m.config.gravity.norm();
    let n = chunk_order.len();
    let mut gpu_index: HashMap<(usize, usize), u32> = HashMap::new();
    for (k, &sc) in chunk_order.iter().enumerate() {
        gpu_index.insert(sc, k as u32);
    }
    // Bounds and travel budgets of every active chunk.
    let mut pos = vec![Vec3::ZERO; n];
    let mut radius = vec![0.0; n];
    let mut budget = vec![0.0; n];
    for (k, &(s, c)) in chunk_order.iter().enumerate() {
        let r = m.structures[s].chunks[c].half_extents.norm();
        let (v, w) = m.chunk_velocity(s, c);
        let speed = v.norm() + w.norm() * r;
        pos[k] = m.chunk_position(s, c);
        radius[k] = r;
        budget[k] = 2.0 * speed * duration + g * duration * duration + 0.05 * r + 1e-3;
    }
    let mut plan = Plan { contact_clusters: vec![false; m.clusters.len()], budget, ..Default::default() };
    // Chunk pairs of different clusters (world.rs `apply_contacts`, any substep).
    let by_cluster: Vec<Vec<u32>> = m.clusters.iter().map(|cl| cl.chunks.iter().map(|&c| gpu_index[&(cl.structure, c)]).collect()).collect();
    let mut sorted_by_cluster: Vec<Vec<u32>> = by_cluster.clone();
    for (ci, list) in sorted_by_cluster.iter_mut().enumerate() {
        // The reference iterates a cluster's chunks in active order (structure, chunk).
        let s = m.clusters[ci].structure;
        list.sort_by_key(|&k| (s, chunk_order[k as usize].1));
    }
    let mu_of = |s: usize, c: usize| scene.material(&m.structures[s].chunks[c].material).friction;
    for ca in 0..m.clusters.len() {
        for cb in ca + 1..m.clusters.len() {
            let (cla, clb) = (&m.clusters[ca], &m.clusters[cb]);
            if (cla.anchored && clb.anchored) || cla.driven || clb.driven {
                continue;
            }
            for &ka in &sorted_by_cluster[ca] {
                for &kb in &sorted_by_cluster[cb] {
                    let (a, b) = (ka as usize, kb as usize);
                    if (pos[a] - pos[b]).norm() > radius[a] + radius[b] + plan.budget[a] + plan.budget[b] {
                        continue;
                    }
                    let (sa, chunk_a) = chunk_order[a];
                    let (sb, chunk_b) = chunk_order[b];
                    let (ma, mb) = (m.structures[sa].chunks[chunk_a].mass, m.structures[sb].chunks[chunk_b].mass);
                    let mu = scene.sim.contact_friction.unwrap_or(mu_of(sa, chunk_a).min(mu_of(sb, chunk_b)));
                    plan.pairs.push(((sa, chunk_a, sb, chunk_b), ka, kb, ma * mb / (ma + mb), mu));
                    plan.contact_clusters[ca] = true;
                    plan.contact_clusters[cb] = true;
                }
            }
        }
    }
    // Impactors against chunks, in active order.
    let mut active_order: Vec<u32> = (0..n as u32).collect();
    active_order.sort_by_key(|&k| chunk_order[k as usize]);
    for imp in impactors {
        let mut list = Vec::new();
        if !imp.driven {
            let reach = match imp.shape {
                ImpactorShape::Sphere { radius } => radius * 3f64.sqrt(),
                ImpactorShape::Box { half_extents } => Vec3::from_array(half_extents).norm(),
            };
            let imp_budget = 2.0 * (imp.velocity.norm() + imp.angular_velocity.norm() * reach) * duration + g * duration * duration + 1e-3;
            for &k in &active_order {
                let (s, c) = chunk_order[k as usize];
                let ci = m.chunks[s][c].cluster;
                if m.clusters[ci].driven {
                    continue;
                }
                let kk = k as usize;
                if (pos[kk] - imp.pose.position).norm() <= reach + radius[kk] + plan.budget[kk] + imp_budget {
                    list.push(k);
                    plan.contact_clusters[ci] = true;
                }
            }
        }
        plan.impactor_chunks.push(list);
    }
    // Ground.
    if let Some(ground) = &scene.ground {
        for &k in &active_order {
            let (s, c) = chunk_order[k as usize];
            let cl = &m.clusters[m.chunks[s][c].cluster];
            if cl.anchored || cl.driven {
                continue;
            }
            let kk = k as usize;
            if pos[kk].z - radius[kk] - plan.budget[kk] <= ground.height {
                plan.ground.push(k);
                plan.contact_clusters[m.chunks[s][c].cluster] = true;
            }
        }
    }
    plan
}

/// The impactor's inertia and inverse in its body frame.
pub fn impactor_inertia(imp: &Impactor) -> (Mat3, Mat3) {
    (imp.inertia, imp.inertia.inverse().unwrap_or(Mat3::ZERO))
}
