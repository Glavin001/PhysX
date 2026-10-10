//! The GPU stress solver with the full model (`shaders/stress_island.slang`): explicit
//! substeps of every cluster with the joint law, fracture, rigid motion and drift
//! removal on the GPU, one threadgroup per island.
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
use stress_ref::scene::Support;
use stress_ref::solver::{ReferenceSolver, SolverEvent, CREAK_STRENGTH};

use crate::gpu::{Binding, Gpu, Kernel};
use crate::joint::{bond_law, from_gpu_state, mode_of, to_gpu_state, GpuJointBond, GpuJointMaterial, GpuJointState, MaterialTable};
use crate::shaders;

const THREADS: u32 = 256;
const MAX_MATERIALS: usize = 64;
const ISLAND_ANCHORED: u32 = 1;
const ISLAND_DRIVEN: u32 = 2;
const ISLAND_HALTED: u32 = 1;

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, bytemuck::Pod, bytemuck::Zeroable)]
struct Params {
    gravity: [f32; 4],
    dt: f32,
    fracture: u32,
    rigid_motion_loads: u32,
    pad: u32,
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
}

fn v4(v: Vec3, w: f64) -> [f32; 4] {
    [v.x as f32, v.y as f32, v.z as f32, w as f32]
}

fn rows(m: &Mat3) -> [[f32; 4]; 3] {
    std::array::from_fn(|r| [m.m[r][0] as f32, m.m[r][1] as f32, m.m[r][2] as f32, 0.0])
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

struct Buffers {
    params: wgpu::Buffer,
    state: wgpu::Buffer,
    bond_dyn: wgpu::Buffer,
    islands: wgpu::Buffer,
    bind: wgpu::BindGroup,
}

/// Where each GPU chunk and bond lives in the mirror.
struct Layout {
    chunks: Vec<(usize, usize)>,
    bonds: Vec<(usize, usize)>,
    islands: Vec<Island>,
}

pub struct GpuSolver {
    /// The host mirror: topology and history, current after `download`.
    pub mirror: ReferenceSolver,
    kernel: Kernel,
    layout: Layout,
    buffers: Buffers,
    /// Time after each absolute substep (index: substep count since the start).
    step_times: Vec<f64>,
    /// GPU dispatches and host splits so far.
    pub dispatches: u64,
    pub host_splits: u64,
}

impl GpuSolver {
    pub fn new(gpu: &Gpu, mirror: ReferenceSolver) -> Result<GpuSolver, String> {
        let kernel = gpu.compute(
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
            ],
        );
        let step_times = vec![mirror.time];
        let (layout, buffers) = Self::build(gpu, &kernel, &mirror)?;
        Ok(GpuSolver { mirror, kernel, layout, buffers, step_times, dispatches: 0, host_splits: 0 })
    }

    /// Every buffer from the mirror's current state.
    fn build(gpu: &Gpu, kernel: &Kernel, m: &ReferenceSolver) -> Result<(Layout, Buffers), String> {
        if m.config.mode != stress_ref::scene::SolveMode::Explicit {
            return Err("only the explicit solve mode is on the GPU so far".into());
        }
        if !m.replacements.is_empty() {
            return Err("replacement loads are not on the GPU yet".into());
        }
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
                });
                state.extend([v4(cs.u, 0.0), v4(cs.th, 0.0), v4(cs.v, 0.0), v4(cs.w, 0.0)]);
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
                done: [0; 4],
            });
        }
        let mut table = MaterialTable::default();
        let mut bonds = Vec::new();
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
        let mut materials = vec![GpuJointMaterial::default(); MAX_MATERIALS];
        materials[..table.materials.len()].copy_from_slice(&table.materials);

        let params = gpu.uniform("params", &Params::default());
        let materials = gpu.uniform_slice("materials", &materials);
        let bonds_buf = gpu.storage("bond static", &bond_static);
        let chunks_buf = gpu.storage("chunk static", &chunk_static);
        let csr = gpu.storage("csr", &csr);
        let state = gpu.storage("state", &state);
        let bond_dyn_buf = gpu.storage("bond dyn", &bond_dyn);
        let bond_loads = gpu.storage("bond loads", &vec![[0f32; 4]; 3 * bonds.len()]);
        let islands_buf = gpu.storage("islands", &islands);
        let bind = gpu.bind(&kernel.group, &[&params, &materials, &bonds_buf, &chunks_buf, &csr, &state, &bond_dyn_buf, &bond_loads, &islands_buf]);
        Ok((Layout { chunks, bonds, islands }, Buffers { params, state, bond_dyn: bond_dyn_buf, islands: islands_buf, bind }))
    }

    /// Advance every cluster by `substeps` explicit substeps of `dt` (splits included).
    pub fn step(&mut self, gpu: &Gpu, dt: f64, substeps: usize) -> Result<(), String> {
        let m = &self.mirror;
        let params = Params {
            gravity: v4(m.config.gravity, 0.0),
            dt: dt as f32,
            fracture: m.config.fracture as u32,
            rigid_motion_loads: m.config.features.rigid_motion_loads as u32,
            pad: 0,
        };
        gpu.queue.write_buffer(&self.buffers.params, 0, bytemuck::bytes_of(&params));
        let start = self.mirror.substeps as usize;
        while self.step_times.len() <= start + substeps {
            let t = *self.step_times.last().unwrap() + dt;
            self.step_times.push(t);
        }
        // Remaining substeps per cluster id.
        let mut remaining: HashMap<u64, usize> = self.mirror.clusters.iter().map(|c| (c.id, substeps)).collect();
        loop {
            // Each island runs its remaining substeps; it stops early at a disconnection.
            let mut any = false;
            for (ci, isl) in self.layout.islands.iter_mut().enumerate() {
                let left = remaining[&self.mirror.clusters[ci].id];
                isl.info[1] = left as u32;
                isl.info[2] = 0;
                isl.info[3] = (start + substeps - left) as u32;
                any |= left > 0;
            }
            if !any {
                break;
            }
            gpu.queue.write_buffer(&self.buffers.islands, 0, bytemuck::cast_slice(&self.layout.islands));
            let mut encoder = gpu.device.create_command_encoder(&Default::default());
            {
                let mut pass = encoder.begin_compute_pass(&Default::default());
                pass.set_pipeline(&self.kernel.pipeline);
                pass.set_bind_group(0, &self.buffers.bind, &[]);
                pass.dispatch_workgroups(self.layout.islands.len() as u32, 1, 1);
            }
            gpu.queue.submit([encoder.finish()]);
            self.dispatches += 1;
            let islands: Vec<Island> = gpu.read(&self.buffers.islands);
            let halted: Vec<usize> = (0..islands.len()).filter(|&i| islands[i].info[2] & ISLAND_HALTED != 0).collect();
            for (ci, isl) in islands.iter().enumerate() {
                let id = self.mirror.clusters[ci].id;
                *remaining.get_mut(&id).unwrap() -= isl.done[0] as usize;
            }
            self.layout.islands = islands;
            if halted.is_empty() {
                break;
            }
            // Split the halted clusters on the host mirror, at the time they reached.
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
                // Children (appended) inherit the parent's remaining substeps.
                for c in &self.mirror.clusters[before.saturating_sub(1)..] {
                    remaining.entry(c.id).or_insert(left);
                }
            }
            self.mirror.time = self.step_times[start + substeps];
            let (layout, buffers) = Self::build(gpu, &self.kernel, &self.mirror)?;
            self.layout = layout;
            self.buffers = buffers;
            gpu.queue.write_buffer(&self.buffers.params, 0, bytemuck::bytes_of(&params));
        }
        self.download(gpu);
        self.mirror.time = self.step_times[start + substeps];
        self.mirror.substeps = (start + substeps) as u64;
        Ok(())
    }

    /// Copy the GPU state into the mirror: hidden state, bond history and forces,
    /// cluster motion, energies (accumulated since the last download) and events.
    pub fn download(&mut self, gpu: &Gpu) {
        let state: Vec<[f32; 4]> = gpu.read(&self.buffers.state);
        let bond_dyn: Vec<BondDyn> = gpu.read(&self.buffers.bond_dyn);
        let islands: Vec<Island> = gpu.read(&self.buffers.islands);
        let m = &mut self.mirror;
        for (k, &(s, c)) in self.layout.chunks.iter().enumerate() {
            let cs = &mut m.chunks[s][c];
            cs.u = vec3(state[4 * k]);
            cs.th = vec3(state[4 * k + 1]);
            cs.v = vec3(state[4 * k + 2]);
            cs.w = vec3(state[4 * k + 3]);
        }
        for (ci, isl) in islands.iter().enumerate() {
            let cl = &mut m.clusters[ci];
            if !cl.anchored {
                let q = isl.rotation;
                cl.pose.rotation = Quat { x: q[0] as f64, y: q[1] as f64, z: q[2] as f64, w: q[3] as f64 }.normalized();
                cl.pose.position = joined(isl.position, isl.position_err);
                cl.velocity = joined(isl.velocity, isl.velocity_err);
                cl.angular_velocity = vec3(isl.angular_velocity);
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
        let _ = CREAK_STRENGTH;
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
    }

    /// GPU order of chunks (structure, chunk).
    pub fn chunk_order(&self) -> &[(usize, usize)] {
        &self.layout.chunks
    }

    pub fn island_count(&self) -> usize {
        self.layout.islands.len()
    }
}

#[allow(dead_code)]
fn threads() -> u32 {
    THREADS
}
