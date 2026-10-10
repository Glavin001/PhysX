//! The GPU stress solver with the full model: explicit substeps of every cluster with
//! the joint law, fracture, rigid motion, drift removal, scripted and replacement loads,
//! probes (`shaders/stress_island.slang`), and penalty contacts with impactors and the
//! ground (`shaders/contact.slang`).
//!
//! Islands that touch nothing this segment run all their substeps in one dispatch; the
//! others (and impactors) advance in lockstep through a per-substep contact pipeline.
//!
//! A `ReferenceSolver` is kept as the host mirror of topology and history. Rare
//! operations run the reference's own code on it after the GPU state is downloaded:
//! when a bond disconnects, its island stops after that substep, and the host splits the
//! cluster with `ReferenceSolver::split_cluster` (as the reference does at the end of
//! that substep), re-uploads, and lets the children finish the parent's remaining
//! substeps.

use std::collections::HashMap;

use stress_ref::bond::Local6;
use stress_ref::math::{Mat3, Quat, Vec3};
use stress_ref::scene::{ImpactorShape, Scene, Support};
use stress_ref::solver::{ReferenceSolver, SolverEvent};
use stress_ref::world::Impactor;

use crate::contacts::{modulus, plan, PairKey, PairState, Plan, NAN_STATE};
use crate::gpu::{Binding, Gpu, Kernel};
use crate::joint::{bond_law, from_gpu_state, mode_of, to_gpu_state, GpuJointBond, GpuJointMaterial, GpuJointState, MaterialTable};
use crate::loads::{Function, LoadTerm, ProbeItem, Target, WorldLoads};
use crate::shaders;

const MAX_MATERIALS: usize = 64;
const ISLAND_ANCHORED: u32 = 1;
const ISLAND_DRIVEN: u32 = 2;
const ISLAND_CONTACT: u32 = 4;
const ISLAND_HALTED: u32 = 1;
const STOP_NOW: u32 = 1;

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
struct Params {
    gravity: [f32; 4],
    dt: f32,
    fracture: u32,
    rigid_motion_loads: u32,
    step_start: u32,
    t_hi: f32,
    t_lo: f32,
    probe_base: u32,
    probe_stride: u32,
    max_steps: u32,
    contact_mode: u32,
    contact_base: u32,
    halt_index: u32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
struct ContactParams {
    gravity: [f32; 4],
    dt: f32,
    zeta: f32,
    pair_friction: f32,
    halt_index: u32,
    ground_hi: f32,
    ground_lo: f32,
    ground_friction: f32,
    ground_modulus: f32,
    has_ground: u32,
    pair_count: u32,
    impactor_count: u32,
    chunk_count: u32,
    loads_base: u32,
    ledger_base: u32,
    step_start: u32,
    record_stride: u32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
struct BondStatic {
    t1: [f32; 4],
    t2: [f32; 4],
    normal: [f32; 4],
    ra: [f32; 4],
    rb: [f32; 4],
    centroid: [f32; 4],
    c_lin: [f32; 4],
    c_ang: [f32; 4],
    law: GpuJointBond,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
pub struct BondDyn {
    pub js: GpuJointState,
    pub force_lin: [f32; 4],
    pub force_ang: [f32; 4],
    pub sums: [f32; 4],
    pub comps: [f32; 4],
    pub events: [u32; 4],
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
struct ChunkStatic {
    center: [f32; 4],
    inertia: [[f32; 4]; 3],
    inv: [[f32; 4]; 3],
    scale: [f32; 4],
    info: [u32; 4],
    load_range: [u32; 4],
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
struct ContactChunk {
    half: [f32; 4],
    rot: [[f32; 4]; 3],
    mat: [f32; 4],
    start_hi: [f32; 4],
    start_lo: [f32; 4],
    info: [u32; 4],
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
struct GpuImpactor {
    position: [f32; 4],
    position_err: [f32; 4],
    velocity: [f32; 4],
    velocity_err: [f32; 4],
    angular_velocity: [f32; 4],
    rotation: [f32; 4],
    inertia: [[f32; 4]; 3],
    inv: [[f32; 4]; 3],
    shape: [f32; 4],
    half: [f32; 4],
    mat: [f32; 4],
    crush: [f32; 4],
    load_force: [f32; 4],
    load_torque: [f32; 4],
    ledger: [f32; 4],
    cand: [u32; 4],
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
pub struct Island {
    pub range: [u32; 4],
    pub info: [u32; 4],
    pub com: [f32; 4],
    pub inertia: [[f32; 4]; 3],
    pub inv: [[f32; 4]; 3],
    pub wcom: [f32; 4],
    pub winv: [[f32; 4]; 3],
    pub rotation: [f32; 4],
    pub position: [f32; 4],
    pub position_err: [f32; 4],
    pub velocity: [f32; 4],
    pub velocity_err: [f32; 4],
    pub angular_velocity: [f32; 4],
    pub done: [u32; 4],
    pub probes: [u32; 4],
    pub energy: [f32; 4],
}

fn v4(v: Vec3, w: f64) -> [f32; 4] {
    [v.x as f32, v.y as f32, v.z as f32, w as f32]
}

fn rows(m: &Mat3) -> [[f32; 4]; 3] {
    std::array::from_fn(|r| [m.m[r][0] as f32, m.m[r][1] as f32, m.m[r][2] as f32, 0.0])
}

/// A value as an f32 plus the f32 rounding error of that value.
fn split1(x: f64) -> (f32, f32) {
    let hi = x as f32;
    (hi, (x - hi as f64) as f32)
}

/// A vector as an f32 value plus the f32 rounding error of that value.
fn split(v: Vec3) -> ([f32; 4], [f32; 4]) {
    let hi = v4(v, 0.0);
    let lo = v4(v - Vec3::new(hi[0] as f64, hi[1] as f64, hi[2] as f64), 0.0);
    (hi, lo)
}

fn joined(hi: [f32; 4], lo: [f32; 4]) -> Vec3 {
    Vec3::new(hi[0] as f64 + lo[0] as f64, hi[1] as f64 + lo[1] as f64, hi[2] as f64 + lo[2] as f64)
}

fn vec3(a: [f32; 4]) -> Vec3 {
    Vec3::new(a[0] as f64, a[1] as f64, a[2] as f64)
}

fn damping_ratio(restitution: f64) -> f64 {
    let l = restitution.max(1e-6).ln();
    -l / (std::f64::consts::PI.powi(2) + l * l).sqrt()
}

/// The GPU form of a load term (5 float4) and its table data.
fn pack_term(t: &LoadTerm, chunk: u32, data: &mut Vec<[f32; 4]>, data_base: u32) -> [[f32; 4]; 5] {
    let (fn_kind, origin, p, offset): (u32, f64, [f32; 4], u32) = match &t.function {
        Function::Constant(_) => (0, 0.0, [0.0; 4], 0),
        Function::Ramp { t0, t1, value } => (1, *t0, [(t1 - t0) as f32, *value as f32, 0.0, 0.0], 0),
        Function::HalfSine { start, duration, peak } => (2, *start, [*duration as f32, *peak as f32, 0.0, 0.0], 0),
        Function::Friedlander { arrival, peak, duration, decay } => (3, *arrival, [*peak as f32, *duration as f32, *decay as f32, 0.0], 0),
        Function::Table(points) => {
            let origin = points.first().map(|p| p[0]).unwrap_or(0.0);
            let offset = data_base + data.len() as u32;
            for p in points {
                data.push([(p[0] - origin) as f32, p[1] as f32, 0.0, 0.0]);
            }
            if points.is_empty() {
                data.push([0.0; 4]);
            }
            (4, origin, [f32::from_bits(points.len().max(1) as u32), 0.0, 0.0, 0.0], offset)
        }
        Function::Blast(fb) => (5, fb.arrival, [fb.duration as f32, fb.decay as f32, fb.peak as f32, fb.stagnation as f32], 0),
        Function::Replacement { start, duration } => (6, *start, [*duration as f32, 0.0, 0.0, 0.0], 0),
    };
    let (o_hi, o_lo) = split1(origin);
    let constant = match &t.function {
        Function::Constant(v) => *v as f32,
        _ => 0.0,
    };
    let clearing = match &t.function {
        Function::Blast(fb) => fb.clearing_time as f32,
        _ => 0.0,
    };
    [
        [f32::from_bits(chunk), f32::from_bits(t.kind), f32::from_bits(fn_kind), f32::from_bits(offset)],
        v4(t.dir, t.area),
        v4(t.arm, 0.0),
        [o_hi, o_lo, constant, clearing],
        p,
    ]
}

struct Kernels {
    island: Kernel,
    pairs: Kernel,
    impactors: Kernel,
    gather: Kernel,
    integrate: Kernel,
}

const CONTACT_BINDINGS: [Binding; 9] = [
    Binding::Uniform,
    Binding::Storage,
    Binding::Storage,
    Binding::Storage,
    Binding::StorageRw,
    Binding::Storage,
    Binding::StorageRw,
    Binding::StorageRw,
    Binding::StorageRw,
];

struct Buffers {
    /// Island dispatch params: segment mode (contact_mode 0) and per-substep mode (1).
    params_segment: wgpu::Buffer,
    params_contact: wgpu::Buffer,
    contact_params: wgpu::Buffer,
    contact_params_host: ContactParams,
    state: wgpu::Buffer,
    bond_dyn: wgpu::Buffer,
    scratch: wgpu::Buffer,
    islands: wgpu::Buffer,
    impactors: wgpu::Buffer,
    contact_state: wgpu::Buffer,
    contact_out: wgpu::Buffer,
    bind_segment: wgpu::BindGroup,
    bind_contact: wgpu::BindGroup,
    bind_contact_kernels: wgpu::BindGroup,
    probe_base: u32,
    probe_stride: u32,
    contact_base: u32,
    ledger_base: u32,
}

/// Where each GPU chunk and bond lives in the mirror, the probe items by slot, the
/// contact plan.
struct Layout {
    chunks: Vec<(usize, usize)>,
    bonds: Vec<(usize, usize)>,
    islands: Vec<Island>,
    items: Vec<ProbeItem>,
    plan: Plan,
    gpu_impactors: Vec<GpuImpactor>,
}

pub struct GpuSolver {
    /// The host mirror: topology and history, current after `download`.
    pub mirror: ReferenceSolver,
    /// The scene's loads and probes (none: gravity only, no probes).
    pub loads: Option<WorldLoads>,
    /// Impactors (host mirror) and contact energies.
    pub impactors: Vec<Impactor>,
    pub contact_dissipated: f64,
    pub crush_energy: f64,
    /// Pre-existing overlap of the pairs in contact (world.rs `pair_offsets`).
    pair_memory: HashMap<PairKey, PairState>,
    kernels: Kernels,
    layout: Layout,
    buffers: Buffers,
    /// Time after each absolute substep (index: substep count since the start).
    step_times: Vec<f64>,
    /// GPU submissions, host splits and contact re-plans so far.
    pub dispatches: u64,
    pub host_splits: u64,
    pub replans: u64,
}

impl GpuSolver {
    pub fn new(gpu: &Gpu, mirror: ReferenceSolver, loads: Option<WorldLoads>, impactors: Vec<Impactor>) -> Result<GpuSolver, String> {
        let kernels = Kernels {
            island: gpu.compute(
                &shaders::STRESS_ISLAND,
                "island_frame",
                &[
                    Binding::Uniform,
                    Binding::Uniform,
                    Binding::Storage,
                    Binding::Storage,
                    Binding::Storage,
                    Binding::StorageRw,
                    Binding::StorageRw,
                    Binding::StorageRw,
                    Binding::StorageRw,
                    Binding::Storage,
                    Binding::Storage,
                ],
            ),
            pairs: gpu.compute(&shaders::CONTACT, "contact_pairs", &CONTACT_BINDINGS),
            impactors: gpu.compute(&shaders::CONTACT, "contact_impactors", &CONTACT_BINDINGS),
            gather: gpu.compute(&shaders::CONTACT, "contact_gather", &CONTACT_BINDINGS),
            integrate: gpu.compute(&shaders::CONTACT, "impactor_integrate", &CONTACT_BINDINGS),
        };
        let step_times = vec![mirror.time];
        let mut loads = loads;
        let pair_memory = HashMap::new();
        let (layout, buffers) = Self::build(gpu, &kernels, &mirror, loads.as_mut(), &impactors, &pair_memory, 4, 0.0)?;
        Ok(GpuSolver {
            mirror,
            loads,
            impactors,
            contact_dissipated: 0.0,
            crush_energy: 0.0,
            pair_memory,
            kernels,
            layout,
            buffers,
            step_times,
            dispatches: 0,
            host_splits: 0,
            replans: 0,
        })
    }

    /// Rebuild every buffer from the mirror (after the host changed topology or loads),
    /// planning contacts for the next `horizon` seconds.
    pub fn rebuild(&mut self, gpu: &Gpu, horizon: f64) -> Result<(), String> {
        let stride = self.buffers.probe_stride;
        let (layout, buffers) = Self::build(gpu, &self.kernels, &self.mirror, self.loads.as_mut(), &self.impactors, &self.pair_memory, stride, horizon)?;
        self.layout = layout;
        self.buffers = buffers;
        Ok(())
    }

    fn scene(&self) -> Option<&Scene> {
        self.loads.as_ref().map(|l| &l.scene)
    }

    /// Every buffer from the mirror's current state.
    #[allow(clippy::too_many_arguments)]
    fn build(
        gpu: &Gpu,
        kernels: &Kernels,
        m: &ReferenceSolver,
        loads: Option<&mut WorldLoads>,
        impactors: &[Impactor],
        pair_memory: &HashMap<PairKey, PairState>,
        probe_stride: u32,
        horizon: f64,
    ) -> Result<(Layout, Buffers), String> {
        if m.config.mode != stress_ref::scene::SolveMode::Explicit {
            return Err("only the explicit solve mode is on the GPU so far".into());
        }
        let scene = loads.as_ref().map(|l| l.scene.clone());
        let (terms, items) = match loads {
            Some(l) => (l.terms(m, m.time), l.probe_items(m)),
            None => (Vec::new(), Vec::new()),
        };
        let mut chunk_index: Vec<Vec<u32>> = m.structures.iter().map(|st| vec![u32::MAX; st.chunks.len()]).collect();
        let mut chunks = Vec::new();
        let mut chunk_static = Vec::new();
        let mut state = Vec::new();
        let mut islands = Vec::new();
        for (ci, cl) in m.clusters.iter().enumerate() {
            let s = cl.structure;
            let st = &m.structures[s];
            let begin = chunks.len() as u32;
            for &c in &cl.chunks {
                let data = &st.chunks[c];
                let cs = &m.chunks[s][c];
                chunk_index[s][c] = chunks.len() as u32;
                chunks.push((s, c));
                let mu = cs.inertia_scale;
                chunk_static.push(ChunkStatic {
                    center: v4(data.center, data.mass),
                    inertia: rows(&data.inertia),
                    inv: rows(&data.inv_inertia),
                    scale: [mu as f32, (1.0 / (data.mass * mu)) as f32, (1.0 / mu) as f32, 0.0],
                    info: [
                        match data.support {
                            Support::None => 0,
                            Support::Fixed => 1,
                            Support::Pinned => 2,
                        },
                        ci as u32,
                        s as u32,
                        c as u32,
                    ],
                    load_range: [0; 4],
                });
                let r = cs.reaction.0;
                state.extend([v4(cs.u, 0.0), v4(cs.th, r.x), v4(cs.v, r.y), v4(cs.w, r.z)]);
            }
            // Drift-removal weights (solver.rs `remove_rigid_drift`).
            let weight = |c: usize| m.chunks[s][c].inertia_scale;
            let scaled = cl.chunks.iter().any(|&c| weight(c) != 1.0);
            let (wmass, wcom, winertia) = if scaled {
                let mass: f64 = cl.chunks.iter().map(|&c| st.chunks[c].mass * weight(c)).sum();
                let com = cl.chunks.iter().map(|&c| st.chunks[c].center * (st.chunks[c].mass * weight(c))).fold(Vec3::ZERO, |a, b| a + b) / mass;
                let mut inertia = Mat3::ZERO;
                for &c in &cl.chunks {
                    let ch = &st.chunks[c];
                    let r = ch.center - com;
                    inertia += (ch.inertia + (Mat3::IDENTITY * r.norm2() - Mat3::outer(r, r)) * ch.mass) * weight(c);
                }
                (mass, com, inertia)
            } else {
                (cl.mass, cl.com, cl.inertia)
            };
            let flags = if cl.anchored { ISLAND_ANCHORED } else { 0 } | if cl.driven { ISLAND_DRIVEN } else { 0 };
            let (position, position_err) = split(cl.pose.position);
            let (velocity, velocity_err) = split(cl.velocity);
            let q = cl.pose.rotation;
            let inv = cl.inertia.inverse().unwrap_or(Mat3::ZERO);
            let winv = winertia.inverse().unwrap_or(Mat3::ZERO);
            islands.push(Island {
                range: [begin, chunks.len() as u32, 0, 0],
                info: [flags, 0, 0, m.substeps as u32],
                com: v4(cl.com, cl.mass),
                inertia: rows(&cl.inertia),
                inv: rows(&inv),
                wcom: v4(wcom, wmass),
                winv: rows(&winv),
                rotation: [q.x as f32, q.y as f32, q.z as f32, q.w as f32],
                position,
                position_err,
                velocity,
                velocity_err,
                angular_velocity: v4(cl.angular_velocity, 0.0),
                ..Default::default()
            });
        }
        let mut table = MaterialTable::default();
        let mut bonds = Vec::new();
        let mut bond_index: HashMap<(usize, usize), u32> = HashMap::new();
        let mut bond_static = Vec::new();
        let mut bond_dyn = Vec::new();
        let mut incident = vec![Vec::new(); chunks.len()];
        for (ci, cl) in m.clusters.iter().enumerate() {
            let s = cl.structure;
            islands[ci].range[2] = bonds.len() as u32;
            for &bi in &cl.bonds {
                let b = &m.bonds[s][bi];
                let g = &b.geometry;
                let material = table.index(&b.strength);
                let mut law = bond_law(g, &b.stiffness, &b.strength, b.rebar.as_ref(), b.weibull, material);
                let (a, bb) = (chunk_index[s][g.a], chunk_index[s][g.b]);
                law.ids = [material, a, bb, ci as u32];
                let i = bonds.len() as u32;
                incident[a as usize].push(2 * i);
                incident[bb as usize].push(2 * i + 1);
                bond_index.insert((s, bi), i);
                bonds.push((s, bi));
                bond_static.push(BondStatic {
                    t1: v4(g.t1, 0.0),
                    t2: v4(g.t2, 0.0),
                    normal: v4(g.normal, 0.0),
                    ra: v4(g.ra, 0.0),
                    rb: v4(g.rb, 0.0),
                    centroid: v4(g.centroid, 0.0),
                    c_lin: v4(b.damping.lin, 0.0),
                    c_ang: v4(b.damping.ang, 0.0),
                    law,
                });
                bond_dyn.push(BondDyn {
                    js: to_gpu_state(&b.joint),
                    force_lin: v4(b.force.lin, b.stored),
                    force_ang: v4(b.force.ang, b.joint.utilization),
                    ..Default::default()
                });
            }
            islands[ci].range[3] = bonds.len() as u32;
        }
        if table.materials.len() > MAX_MATERIALS {
            return Err(format!("{} joint materials (the GPU table holds {MAX_MATERIALS})", table.materials.len()));
        }
        // CSR incidence: offsets (into this buffer) then entries, in bond order.
        let n = chunks.len();
        let mut csr = vec![0u32; n + 1];
        let mut entries = Vec::new();
        for (c, inc) in incident.iter().enumerate() {
            csr[c] = (n + 1 + entries.len()) as u32;
            entries.extend_from_slice(inc);
        }
        csr[n] = (n + 1 + entries.len()) as u32;
        csr.extend(entries);

        // Load terms by GPU chunk (stable: the reference's order within a chunk), then
        // table data, then probe items grouped by island.
        let mut by_chunk: Vec<Vec<&LoadTerm>> = vec![Vec::new(); n];
        for t in &terms {
            let k = chunk_index[t.structure][t.chunk];
            if k != u32::MAX {
                by_chunk[k as usize].push(t);
            }
        }
        let term_count: usize = by_chunk.iter().map(|v| v.len()).sum();
        let data_base = (5 * term_count) as u32;
        let mut data = Vec::new();
        let mut packed: Vec<[f32; 4]> = Vec::with_capacity(5 * term_count);
        for (k, list) in by_chunk.iter().enumerate() {
            let begin = (packed.len() / 5) as u32;
            for t in list {
                packed.extend(pack_term(t, k as u32, &mut data, data_base));
            }
            chunk_static[k].load_range = [begin, (packed.len() / 5) as u32, 0, 0];
        }
        packed.extend(data);
        let item_island = |it: &ProbeItem| -> Option<(u32, u32)> {
            match it.target {
                Target::Chunk(s, c) => {
                    let k = chunk_index[s][c];
                    (k != u32::MAX).then(|| (chunk_static[k as usize].info[1], k))
                }
                Target::Bond(s, b) => bond_index.get(&(s, b)).map(|&i| (bond_static[i as usize].law.ids[3], i)),
            }
        };
        let mut placed: Vec<(u32, u32, ProbeItem)> = items.into_iter().filter_map(|it| item_island(&it).map(|(isl, idx)| (isl, idx, it))).collect();
        placed.sort_by_key(|p| p.0);
        let mut layout_items = Vec::new();
        let items_base = packed.len() as u32;
        let mut cursor = 0;
        for (ci, island) in islands.iter_mut().enumerate() {
            let begin = items_base + 4 * layout_items.len() as u32;
            while cursor < placed.len() && placed[cursor].0 == ci as u32 {
                let (_, idx, it) = &placed[cursor];
                let slot = layout_items.len() as u32;
                packed.push([f32::from_bits(it.kind), f32::from_bits(*idx), f32::from_bits(it.side), f32::from_bits(slot)]);
                packed.push(v4(it.a, 0.0));
                let (hi, lo) = split(it.x0);
                packed.push(if it.kind == crate::loads::PROBE_SECTION_BOND { v4(it.b, 0.0) } else { hi });
                packed.push(lo);
                layout_items.push(it.clone());
                cursor += 1;
            }
            island.probes = [begin, items_base + 4 * layout_items.len() as u32, 0, 0];
        }
        if packed.is_empty() {
            packed.push([0.0; 4]);
        }

        // ---------------------------------------------------------------- contacts
        let plan = match &scene {
            Some(scene) if horizon > 0.0 && (m.clusters.len() > 1 || !impactors.is_empty() || scene.ground.is_some()) => plan(scene, m, impactors, &chunks, horizon),
            _ => Plan { contact_clusters: vec![false; m.clusters.len()], budget: vec![0.0; n], ..Default::default() },
        };
        // With any contact or impactor, every island advances in lockstep through the
        // per-substep pipeline (a split then stops all of them at the same substep); only
        // the planned chunks receive contact loads.
        let pipeline = !impactors.is_empty() || plan.contact_clusters.iter().any(|&c| c);
        if pipeline {
            for island in islands.iter_mut() {
                island.info[0] |= ISLAND_CONTACT;
            }
        }
        // Output slots: 2 per pair (side a, side b), 1 per impactor candidate.
        let pair_slots = 2 * plan.pairs.len();
        let imp_slots: usize = plan.impactor_chunks.iter().map(|l| l.len()).sum();
        let slots = pair_slots + imp_slots;
        let ledger_base = (2 * slots) as u32;
        let contact_base = ledger_base + (plan.pairs.len() + n) as u32;
        // Static: pair candidates, impactor candidate entries, chunk contribution lists.
        let mut cstatic: Vec<[u32; 4]> = Vec::new();
        for (i, (_, a, b, m_red, mu)) in plan.pairs.iter().enumerate() {
            cstatic.push([*a, *b, (2 * i) as u32, i as u32]);
            cstatic.push([(*m_red as f32).to_bits(), (*mu as f32).to_bits(), 0, 0]);
        }
        // Contributions per chunk in the reference's order: impactors, ground, pairs.
        let mut contributions: Vec<Vec<[u32; 4]>> = vec![Vec::new(); n];
        let mut imp_ranges = Vec::new();
        let mut slot = pair_slots as u32;
        for list in &plan.impactor_chunks {
            let begin = cstatic.len() as u32;
            for &k in list {
                cstatic.push([k, slot, 0, 0]);
                contributions[k as usize].push([0, slot, 0, 0]);
                slot += 1;
            }
            imp_ranges.push([begin, cstatic.len() as u32]);
        }
        for &k in &plan.ground {
            contributions[k as usize].push([1, 0, 0, 0]);
        }
        for (i, (_, a, b, _, _)) in plan.pairs.iter().enumerate() {
            contributions[*a as usize].push([0, (2 * i) as u32, 0, 0]);
            contributions[*b as usize].push([0, (2 * i + 1) as u32, 0, 0]);
        }
        let mut contact_chunks = vec![ContactChunk::default(); n];
        for (k, &(s, c)) in chunks.iter().enumerate() {
            let ci = m.chunks[s][c].cluster;
            let data = &m.structures[s].chunks[c];
            let begin = cstatic.len() as u32;
            cstatic.extend(contributions[k].iter().copied());
            let (e, mu) = match &scene {
                Some(scene) => (modulus(scene, &data.material), scene.material(&data.material).friction),
                None => (1.0, 0.0),
            };
            let (start_hi, start_lo) = split(m.chunk_position(s, c));
            let flags = if plan.contact_clusters[ci] { 1 } else { 0 };
            contact_chunks[k] = ContactChunk {
                half: v4(data.half_extents, data.half_extents.norm()),
                rot: rows(&data.rotation),
                mat: [e as f32, mu as f32, data.mass as f32, 0.0],
                start_hi: [start_hi[0], start_hi[1], start_hi[2], plan.budget[k] as f32],
                start_lo,
                info: [begin, cstatic.len() as u32, flags, 0],
            };
        }
        if cstatic.is_empty() {
            cstatic.push([0; 4]);
        }
        let mut cstate: Vec<[f32; 4]> = Vec::with_capacity(28 * plan.pairs.len());
        for (key, ..) in &plan.pairs {
            match pair_memory.get(key) {
                Some(st) => cstate.extend_from_slice(st),
                None => cstate.extend(std::iter::repeat(NAN_STATE).take(28)),
            }
        }
        if cstate.is_empty() {
            cstate.push(NAN_STATE);
        }
        let gpu_impactors: Vec<GpuImpactor> = impactors
            .iter()
            .enumerate()
            .map(|(ii, imp)| {
                let (position, position_err) = split(imp.pose.position);
                let (velocity, velocity_err) = split(imp.velocity);
                let q = imp.pose.rotation;
                let (shape, half) = match imp.shape {
                    ImpactorShape::Sphere { radius } => ([0.0, radius as f32, 0.0, 0.0], Vec3::splat(radius)),
                    ImpactorShape::Box { half_extents } => ([1.0, 0.0, 0.0, 0.0], Vec3::from_array(half_extents)),
                };
                let e = scene.as_ref().map(|s| {
                    let mm = &imp.material;
                    mm.youngs_modulus * s.sim.stiffness_scale / (1.0 - mm.poisson_ratio * mm.poisson_ratio)
                });
                let (max_force, energy) = imp.crush.unwrap_or((0.0, 0.0));
                GpuImpactor {
                    position,
                    position_err,
                    velocity,
                    velocity_err,
                    angular_velocity: v4(imp.angular_velocity, 0.0),
                    rotation: [q.x as f32, q.y as f32, q.z as f32, q.w as f32],
                    inertia: rows(&imp.inertia),
                    inv: rows(&imp.inertia.inverse().unwrap_or(Mat3::ZERO)),
                    shape,
                    half: v4(half, half.norm()),
                    mat: [e.unwrap_or(1.0) as f32, imp.material.friction as f32, imp.mass as f32, 0.0],
                    crush: [max_force as f32, energy as f32, imp.crush_used as f32, imp.crush_depth as f32],
                    cand: [imp_ranges.get(ii).map_or(0, |r| r[0]), imp_ranges.get(ii).map_or(0, |r| r[1]), imp.driven as u32, m.substeps as u32],
                    ..Default::default()
                }
            })
            .collect();
        // The sentinel island (batch control) after the islands.
        let halt_index = islands.len() as u32;
        let mut islands_gpu = islands.clone();
        islands_gpu.push(Island::default());

        let mut materials = vec![GpuJointMaterial::default(); MAX_MATERIALS];
        materials[..table.materials.len()].copy_from_slice(&table.materials);
        let probe_base = (3 * bonds.len()) as u32;
        let scratch_len = 3 * bonds.len() + (layout_items.len() * probe_stride as usize).div_ceil(4) + 1;
        // Chunk contact loads, then the impactor records (2 per impactor and substep).
        let contact_out_len = contact_base as usize + 2 * n + 2 * impactors.len() * probe_stride as usize + 1;

        let (gravity, ground) = (m.config.gravity, scene.as_ref().and_then(|s| s.ground.clone()));
        let (g_hi, g_lo) = split1(ground.as_ref().map_or(0.0, |g| g.height));
        let contact_params = ContactParams {
            gravity: v4(gravity, 0.0),
            dt: 0.0,
            zeta: scene.as_ref().map_or(0.0, |s| damping_ratio(s.sim.contact_restitution)) as f32,
            pair_friction: scene.as_ref().and_then(|s| s.sim.contact_friction).map_or(-1.0, |f| f as f32),
            halt_index,
            ground_hi: g_hi,
            ground_lo: g_lo,
            ground_friction: ground.as_ref().map_or(0.0, |g| scene.as_ref().unwrap().sim.contact_friction.unwrap_or(g.friction)) as f32,
            ground_modulus: ground.as_ref().map_or(1.0, |g| modulus(scene.as_ref().unwrap(), &g.material)) as f32,
            has_ground: ground.is_some() as u32,
            pair_count: plan.pairs.len() as u32,
            impactor_count: impactors.len() as u32,
            chunk_count: n as u32,
            loads_base: contact_base,
            ledger_base,
            step_start: 0,
            record_stride: probe_stride,
        };

        let params_segment = gpu.uniform("params segment", &Params::default());
        let params_contact = gpu.uniform("params contact", &Params::default());
        let contact_params_host = contact_params;
        let contact_params = gpu.uniform("contact params", &contact_params);
        let materials = gpu.uniform_slice("materials", &materials);
        let bonds_buf = gpu.storage("bond static", &bond_static);
        let chunks_buf = gpu.storage("chunk static", &chunk_static);
        let csr = gpu.storage("csr", &csr);
        let state = gpu.storage("state", &state);
        let bond_dyn_buf = gpu.storage("bond dyn", &bond_dyn);
        let scratch = gpu.storage("scratch", &vec![[0f32; 4]; scratch_len]);
        let islands_buf = gpu.storage("islands", &islands_gpu);
        let loads_buf = gpu.storage("loads", &packed);
        let contact_chunks_buf = gpu.storage("contact chunks", &contact_chunks);
        let cstatic_buf = gpu.storage("contact static", &cstatic);
        let cstate_buf = gpu.storage("contact state", &cstate);
        let impactors_buf = gpu.storage("impactors", &if gpu_impactors.is_empty() { vec![GpuImpactor::default()] } else { gpu_impactors.clone() });
        let contact_out = gpu.storage("contact out", &vec![[0f32; 4]; contact_out_len]);
        let island_buffers = |params: &wgpu::Buffer| {
            gpu.bind(&kernels.island.group, &[params, &materials, &bonds_buf, &chunks_buf, &csr, &state, &bond_dyn_buf, &scratch, &islands_buf, &loads_buf, &contact_out])
        };
        let bind_segment = island_buffers(&params_segment);
        let bind_contact = island_buffers(&params_contact);
        let bind_contact_kernels =
            gpu.bind(&kernels.pairs.group, &[&contact_params, &chunks_buf, &contact_chunks_buf, &state, &islands_buf, &cstatic_buf, &cstate_buf, &impactors_buf, &contact_out]);
        Ok((
            Layout { chunks, bonds, islands, items: layout_items, plan, gpu_impactors },
            Buffers {
                params_segment,
                params_contact,
                contact_params,
                contact_params_host,
                state,
                bond_dyn: bond_dyn_buf,
                scratch,
                islands: islands_buf,
                impactors: impactors_buf,
                contact_state: cstate_buf,
                contact_out,
                bind_segment,
                bind_contact,
                bind_contact_kernels,
                probe_base,
                probe_stride,
                contact_base,
                ledger_base,
            },
        ))
    }

    fn contacts_possible(&self) -> bool {
        self.mirror.clusters.len() > 1 || !self.impactors.is_empty() || self.scene().is_some_and(|s| s.ground.is_some())
    }

    /// Advance every cluster by `substeps` explicit substeps of `dt` (splits and
    /// contacts included). Returns each probe's value after every substep (NaN where it
    /// has no item).
    pub fn step(&mut self, gpu: &Gpu, dt: f64, substeps: usize) -> Result<Vec<Vec<f64>>, String> {
        let stride = (substeps as u32).div_ceil(4) * 4;
        let horizon = dt * substeps as f64;
        if stride > self.buffers.probe_stride || self.contacts_possible() {
            let stride = stride.max(self.buffers.probe_stride);
            let (layout, buffers) = Self::build(gpu, &self.kernels, &self.mirror, self.loads.as_mut(), &self.impactors, &self.pair_memory, stride, horizon)?;
            self.layout = layout;
            self.buffers = buffers;
        }
        let start = self.mirror.substeps as usize;
        while self.step_times.len() <= start + substeps {
            let t = *self.step_times.last().unwrap() + dt;
            self.step_times.push(t);
        }
        let (t_hi, t_lo) = split1(self.step_times[start]);
        let (gravity, fracture, rml) = (self.mirror.config.gravity, self.mirror.config.fracture, self.mirror.config.features.rigid_motion_loads);
        let island_params = |b: &Buffers, halt_index: u32, contact: bool| Params {
            gravity: v4(gravity, 0.0),
            dt: dt as f32,
            fracture: fracture as u32,
            rigid_motion_loads: rml as u32,
            step_start: start as u32,
            t_hi,
            t_lo,
            probe_base: b.probe_base,
            probe_stride: b.probe_stride,
            max_steps: if contact { 1 } else { u32::MAX },
            contact_mode: contact as u32,
            contact_base: b.contact_base,
            halt_index,
        };
        // Probe values per item (by identity) and substep.
        let mut values: HashMap<(usize, u32, Target, u32), Vec<f64>> = HashMap::new();
        let mut remaining: HashMap<u64, usize> = self.mirror.clusters.iter().map(|c| (c.id, substeps)).collect();
        // Substeps the contact pipeline (impactors) still has to run.
        let mut pipeline_left = substeps;
        // Impactor velocity and position after every substep (for the impactor probes).
        let mut impactor_records = vec![vec![(Vec3::splat(f64::NAN), Vec3::splat(f64::NAN)); substeps]; self.impactors.len()];
        loop {
            let halt_index = self.layout.islands.len() as u32;
            let mut any = false;
            let mut contact_left = 0usize;
            for (ci, isl) in self.layout.islands.iter_mut().enumerate() {
                let left = remaining[&self.mirror.clusters[ci].id];
                isl.info[1] = left as u32;
                isl.info[2] = 0;
                isl.info[3] = (start + substeps - left) as u32;
                any |= left > 0;
                if isl.info[0] & ISLAND_CONTACT != 0 {
                    contact_left = contact_left.max(left);
                }
            }
            let pipeline = !self.impactors.is_empty() || contact_left > 0;
            let pipeline_steps = if !self.impactors.is_empty() { pipeline_left.max(contact_left) } else { contact_left };
            if !any && pipeline_steps == 0 {
                break;
            }
            let mut islands_gpu = self.layout.islands.clone();
            islands_gpu.push(Island::default());
            gpu.queue.write_buffer(&self.buffers.islands, 0, bytemuck::cast_slice(&islands_gpu));
            if !self.layout.gpu_impactors.is_empty() {
                // Impactors count their integrated substeps from where the pipeline is.
                let at = (start + substeps - pipeline_left) as u32;
                let mut imps: Vec<GpuImpactor> = gpu.read(&self.buffers.impactors);
                imps.iter_mut().for_each(|g| g.cand[3] = at);
                gpu.queue.write_buffer(&self.buffers.impactors, 0, bytemuck::cast_slice(&imps));
            }
            gpu.queue.write_buffer(&self.buffers.params_segment, 0, bytemuck::bytes_of(&island_params(&self.buffers, halt_index, false)));
            gpu.queue.write_buffer(&self.buffers.params_contact, 0, bytemuck::bytes_of(&island_params(&self.buffers, halt_index, true)));
            let mut cp = self.buffers.contact_params_host;
            cp.dt = dt as f32;
            cp.step_start = start as u32;
            gpu.queue.write_buffer(&self.buffers.contact_params, 0, bytemuck::bytes_of(&cp));
            let mut encoder = gpu.device.create_command_encoder(&Default::default());
            {
                let mut pass = encoder.begin_compute_pass(&Default::default());
                let islands_n = self.layout.islands.len() as u32;
                // Islands that touch nothing: every substep in one dispatch.
                pass.set_pipeline(&self.kernels.island.pipeline);
                pass.set_bind_group(0, &self.buffers.bind_segment, &[]);
                pass.dispatch_workgroups(islands_n.max(1), 1, 1);
                // Contact islands and impactors: the per-substep pipeline.
                if pipeline {
                    let n = self.layout.chunks.len();
                    let groups = |count: usize| (count as u32).div_ceil(64).max(1);
                    for _ in 0..pipeline_steps {
                        pass.set_bind_group(0, &self.buffers.bind_contact_kernels, &[]);
                        pass.set_pipeline(&self.kernels.pairs.pipeline);
                        pass.dispatch_workgroups(groups(self.layout.plan.pairs.len()), 1, 1);
                        pass.set_pipeline(&self.kernels.impactors.pipeline);
                        pass.dispatch_workgroups(groups(self.impactors.len()), 1, 1);
                        pass.set_pipeline(&self.kernels.gather.pipeline);
                        pass.dispatch_workgroups(groups(n), 1, 1);
                        pass.set_pipeline(&self.kernels.island.pipeline);
                        pass.set_bind_group(0, &self.buffers.bind_contact, &[]);
                        pass.dispatch_workgroups(islands_n.max(1), 1, 1);
                        pass.set_bind_group(0, &self.buffers.bind_contact_kernels, &[]);
                        pass.set_pipeline(&self.kernels.integrate.pipeline);
                        pass.dispatch_workgroups(groups(self.impactors.len()), 1, 1);
                    }
                }
            }
            gpu.queue.submit([encoder.finish()]);
            self.dispatches += 1;
            let mut islands: Vec<Island> = gpu.read(&self.buffers.islands);
            let sentinel = islands.pop().unwrap_or_default();
            // Probe outputs of the substeps each island ran.
            if !self.layout.items.is_empty() {
                let scratch: Vec<[f32; 4]> = gpu.read(&self.buffers.scratch);
                let flat: &[f32] = bytemuck::cast_slice(&scratch[self.buffers.probe_base as usize..]);
                for (ci, isl) in islands.iter().enumerate() {
                    let before = self.layout.islands[ci].info[3] as usize;
                    let (first, last) = (before - start, isl.info[3] as usize - start);
                    let island = &self.layout.islands[ci];
                    for at in (island.probes[0]..island.probes[1]).step_by(4) {
                        let slot = ((at - self.layout.islands[0].probes[0]) / 4) as usize;
                        let item = &self.layout.items[slot];
                        let row = values.entry(item.key()).or_insert_with(|| vec![f64::NAN; substeps]);
                        for k in first..last {
                            row[k] = flat[slot * self.buffers.probe_stride as usize + k] as f64;
                        }
                    }
                }
            }
            if !self.impactors.is_empty() {
                // Impactor records of the substeps the pipeline ran.
                let out: Vec<[f32; 4]> = gpu.read(&self.buffers.contact_out);
                let base = self.buffers.contact_base as usize + 2 * self.layout.chunks.len();
                let stride = self.buffers.contact_params_host.record_stride as usize;
                let first = substeps - pipeline_left;
                for (ii, rec) in impactor_records.iter_mut().enumerate() {
                    for k in first..substeps {
                        let at = base + 2 * (ii * stride + k);
                        if at + 1 < out.len() {
                            rec[k] = (vec3(out[at]), vec3(out[at + 1]));
                        }
                    }
                }
                let imps: Vec<GpuImpactor> = gpu.read(&self.buffers.impactors);
                let done = imps[0].cand[3] as usize - (start + substeps - pipeline_left);
                pipeline_left -= done;
            }
            let halted: Vec<usize> = (0..islands.len()).filter(|&i| islands[i].info[2] & ISLAND_HALTED != 0).collect();
            for (ci, isl) in islands.iter().enumerate() {
                let id = self.mirror.clusters[ci].id;
                *remaining.get_mut(&id).unwrap() = isl.info[1] as usize;
            }
            self.layout.islands = islands;
            let replan = sentinel.info[2] & STOP_NOW != 0;
            if halted.is_empty() && !replan {
                // Everything ran to the end of the step.
                break;
            }
            // Split the halted clusters on the host mirror, at the time they reached;
            // re-plan contacts from the state reached.
            self.download(gpu);
            let mut pending: Vec<usize> = halted;
            pending.sort_unstable();
            for &ci in pending.iter().rev() {
                let id = self.mirror.clusters[ci].id;
                let left = remaining[&id];
                let done = substeps - left;
                self.mirror.time = self.step_times[start + done];
                let before = self.mirror.clusters.len();
                self.mirror.split_cluster(ci);
                self.host_splits += 1;
                for c in &self.mirror.clusters[before.saturating_sub(1)..] {
                    remaining.entry(c.id).or_insert(left);
                }
            }
            if !pending.is_empty() {
                if let Some(l) = self.loads.as_mut() {
                    l.topology_version += 1;
                }
            }
            if replan {
                self.replans += 1;
            }
            self.mirror.time = self.step_times[start];
            let left_now = remaining.values().copied().max().unwrap_or(0).max(pipeline_left);
            let (layout, buffers) = Self::build(gpu, &self.kernels, &self.mirror, self.loads.as_mut(), &self.impactors, &self.pair_memory, self.buffers.probe_stride, dt * left_now as f64)?;
            self.layout = layout;
            self.buffers = buffers;
        }
        self.download(gpu);
        self.mirror.time = self.step_times[start + substeps];
        self.mirror.substeps = (start + substeps) as u64;
        // Each probe's value: the sum of its items (NaN without any); impactor probes from
        // the impactor records.
        let probes = self.loads.as_ref().map(|l| l.scene.probes.len()).unwrap_or(0);
        let mut out = vec![vec![f64::NAN; substeps]; probes];
        if let Some(l) = self.loads.as_ref() {
            for (p, probe) in l.scene.probes.iter().enumerate() {
                let (name, axis, velocity) = match &probe.kind {
                    stress_ref::scene::ProbeKind::ImpactorVelocity { impactor, axis } => (impactor, axis, true),
                    stress_ref::scene::ProbeKind::ImpactorPosition { impactor, axis } => (impactor, axis, false),
                    _ => continue,
                };
                let Some(ii) = self.impactors.iter().position(|i| &i.name == name) else { continue };
                let a = Vec3::from_array(*axis).normalized();
                for k in 0..substeps {
                    let (v, x) = impactor_records[ii][k];
                    out[p][k] = if velocity { v.dot(a) } else { x.dot(a) };
                }
            }
        }
        let mut seen = vec![vec![false; substeps]; probes];
        for (key, row) in &values {
            for k in 0..substeps {
                if row[k].is_nan() {
                    continue;
                }
                if !seen[key.0][k] {
                    out[key.0][k] = 0.0;
                    seen[key.0][k] = true;
                }
                out[key.0][k] += row[k];
            }
        }
        Ok(out)
    }

    /// Copy the GPU state into the mirror: hidden state, reactions, bond history and
    /// forces, cluster motion, energies (accumulated since the last download), events,
    /// impactors and the contacts' overlap memory.
    pub fn download(&mut self, gpu: &Gpu) {
        let state: Vec<[f32; 4]> = gpu.read(&self.buffers.state);
        let bond_dyn: Vec<BondDyn> = gpu.read(&self.buffers.bond_dyn);
        let mut islands: Vec<Island> = gpu.read(&self.buffers.islands);
        let sentinel = islands.pop().unwrap_or_default();
        let m = &mut self.mirror;
        for (k, &(s, c)) in self.layout.chunks.iter().enumerate() {
            let cs = &mut m.chunks[s][c];
            cs.u = vec3(state[4 * k]);
            cs.th = vec3(state[4 * k + 1]);
            cs.v = vec3(state[4 * k + 2]);
            cs.w = vec3(state[4 * k + 3]);
            if m.structures[s].chunks[c].support != Support::None {
                cs.reaction = (Vec3::new(state[4 * k + 1][3] as f64, state[4 * k + 2][3] as f64, state[4 * k + 3][3] as f64), Vec3::ZERO);
            }
        }
        for (ci, isl) in islands.iter_mut().enumerate() {
            m.energy.external_work += isl.energy[0] as f64 + isl.energy[1] as f64;
            isl.energy = [0.0; 4];
            let cl = &mut m.clusters[ci];
            if !cl.anchored {
                let q = isl.rotation;
                cl.pose.rotation = Quat { x: q[0] as f64, y: q[1] as f64, z: q[2] as f64, w: q[3] as f64 }.normalized();
                cl.pose.position = joined(isl.position, isl.position_err);
                cl.velocity = joined(isl.velocity, isl.velocity_err);
                cl.angular_velocity = vec3(isl.angular_velocity);
            }
        }
        let mut with_sentinel = islands.clone();
        with_sentinel.push(sentinel);
        gpu.queue.write_buffer(&self.buffers.islands, 0, bytemuck::cast_slice(&with_sentinel));
        self.layout.islands = islands;
        // Impactors and contact energies.
        if !self.impactors.is_empty() {
            let mut imps: Vec<GpuImpactor> = gpu.read(&self.buffers.impactors);
            for (imp, g) in self.impactors.iter_mut().zip(imps.iter_mut()) {
                imp.pose.position = joined(g.position, g.position_err);
                let q = g.rotation;
                imp.pose.rotation = Quat { x: q[0] as f64, y: q[1] as f64, z: q[2] as f64, w: q[3] as f64 }.normalized();
                imp.velocity = joined(g.velocity, g.velocity_err);
                imp.angular_velocity = vec3(g.angular_velocity);
                imp.crush_used = g.crush[2] as f64;
                imp.crush_depth = g.crush[3] as f64;
                self.contact_dissipated += g.ledger[0] as f64 + g.ledger[1] as f64;
                self.crush_energy += g.ledger[2] as f64 + g.ledger[3] as f64;
                g.ledger = [0.0; 4];
            }
            gpu.queue.write_buffer(&self.buffers.impactors, 0, bytemuck::cast_slice(&imps));
        }
        let plan = &self.layout.plan;
        if !plan.pairs.is_empty() || !plan.ground.is_empty() {
            let mut out: Vec<[f32; 4]> = gpu.read(&self.buffers.contact_out);
            let lb = self.buffers.ledger_base as usize;
            for i in 0..plan.pairs.len() + self.layout.chunks.len() {
                let l = &mut out[lb + i];
                self.contact_dissipated += l[1] as f64 + l[2] as f64;
                l[1] = 0.0;
                l[2] = 0.0;
            }
            gpu.queue.write_buffer(&self.buffers.contact_out, 0, bytemuck::cast_slice(&out));
            if !plan.pairs.is_empty() {
                let cstate: Vec<[f32; 4]> = gpu.read(&self.buffers.contact_state);
                for (i, (key, ..)) in plan.pairs.iter().enumerate() {
                    let st: PairState = std::array::from_fn(|e| cstate[28 * i + e]);
                    if st.iter().all(|e| e[0].is_nan()) {
                        self.pair_memory.remove(key);
                    } else {
                        self.pair_memory.insert(*key, st);
                    }
                }
            }
        }
        // Events in the reference's order: by substep, then cluster, then bond.
        let mut events: Vec<(u32, usize, usize, u8, SolverEvent)> = Vec::new();
        let mut cleared = Vec::new();
        let (mut dissipated, mut overshoot, mut damped) = (0.0, 0.0, 0.0);
        for (k, &(s, bi)) in self.layout.bonds.iter().enumerate() {
            let bd = &bond_dyn[k];
            let b = &mut m.bonds[s][bi];
            let previous = b.joint.clone();
            b.joint = from_gpu_state(&bd.js, &previous);
            b.force = Local6 { lin: vec3(bd.force_lin), ang: vec3(bd.force_ang) };
            b.stored = bd.force_lin[3] as f64;
            m.max_utilization = m.max_utilization.max(bd.force_ang[3] as f64);
            dissipated += bd.sums[0] as f64 + bd.comps[0] as f64;
            overshoot += bd.sums[1] as f64 + bd.comps[1] as f64;
            damped += bd.sums[2] as f64 + bd.comps[2] as f64;
            let ci = m.chunks[s][b.geometry.a].cluster;
            let pose = m.clusters[ci].pose;
            let position = pose.transform_point(b.geometry.centroid).to_array();
            let time = |step: u32| self.step_times[step as usize];
            if bd.events[0] != 0 {
                let mode = mode_of(bd.events[3]);
                events.push((bd.events[0], ci, k, 0, SolverEvent::Cracked { time: time(bd.events[0]), structure: s, bond: bi, mode, position }));
            }
            if bd.events[1] != 0 {
                events.push((bd.events[1], ci, k, 1, SolverEvent::Creaked { time: time(bd.events[1]), structure: s, bond: bi, position }));
            }
            if bd.events[2] != 0 {
                let b = &m.bonds[s][bi];
                events.push((
                    bd.events[2],
                    ci,
                    k,
                    2,
                    SolverEvent::Broken {
                        time: time(bd.events[2]),
                        structure: s,
                        bond: bi,
                        mode: b.joint.mode,
                        position,
                        normal: pose.transform_vector(b.geometry.normal).to_array(),
                        dissipated: b.joint.dissipated,
                    },
                ));
            }
            if bd.events != [0; 4] || bd.sums != [0.0; 4] {
                cleared.push(k);
            }
        }
        events.sort_by_key(|e| (e.0, e.1, e.2, e.3));
        m.events.extend(events.into_iter().map(|e| e.4));
        m.energy.bond_dissipation += dissipated;
        m.energy.softening_overshoot += overshoot;
        m.energy.damping_dissipation += damped;
        // Reset the per-download accumulators and events on the GPU.
        if !cleared.is_empty() {
            let mut reset = bond_dyn;
            for &k in &cleared {
                reset[k].sums = [0.0; 4];
                reset[k].comps = [0.0; 4];
                reset[k].events = [0; 4];
            }
            gpu.queue.write_buffer(&self.buffers.bond_dyn, 0, bytemuck::cast_slice(&reset));
        }
        let _ = &self.layout.gpu_impactors;
    }

    /// GPU order of chunks (structure, chunk).
    pub fn chunk_order(&self) -> &[(usize, usize)] {
        &self.layout.chunks
    }

    pub fn island_count(&self) -> usize {
        self.layout.islands.len()
    }

    /// Time after `n` substeps since the start.
    pub fn time_after(&self, n: usize) -> f64 {
        self.step_times[n]
    }
}
