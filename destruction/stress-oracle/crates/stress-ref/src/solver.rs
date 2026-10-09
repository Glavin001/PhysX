//! The reference stress solver.
//!
//! **State.** Every structure is a set of chunks connected by bonds. Chunks are
//! grouped into *clusters*: connected components of intact bonds, each one rigid body
//! for the physics engine. Every chunk carries a hidden 6-DOF displacement
//! `(u, theta)` and its rate `(v, w)` in its cluster's body frame (floating frame of
//! reference). Rendering stays rigid; the displacements exist only to compute stress.
//!
//! **Loads.** The chunk loads of a free cluster are the external forces minus the
//! inertial forces of the cluster's rigid motion (linear, angular and centrifugal
//! terms), so the deformation problem is self-equilibrated. Anchored clusters (with
//! supported chunks) live in the static world frame and report support reactions.
//!
//! **Integration.** Explicit central differences with light stiffness-proportional
//! damping; the substep is a safety fraction of the Gershgorin bound on the highest
//! natural frequency. Settled clusters may instead be solved quasi-statically
//! (`statics.rs`) and idle clusters sleep (`SolveMode::Adaptive`).
//!
//! **Fracture.** Bonds are evaluated every substep (`joint.rs`). When a bond stops
//! connecting its chunks, the cluster's connectivity is recomputed and it splits into
//! child clusters that inherit each chunk's exact velocity (`v + w x r` of the parent
//! plus the hidden deformation velocity), conserving linear and angular momentum.

use crate::bond::{BondGeometry, BondStiffness, Local6};
use crate::joint::{FailureMode, JointModel, JointState, JointStrength, RebarParams, StressMeasures};
use crate::math::{Mat3, Pose, Vec3};
use crate::scene::{Scene, SolveMode, Support};
use crate::structure::{BondData, Structure};

/// Solver settings (from the scene's `sim` block).
#[derive(Clone, Debug)]
pub struct SolverConfig {
    pub gravity: Vec3,
    pub fracture: bool,
    pub mode: SolveMode,
    /// Integrate cluster rigid motion here (standalone) instead of taking it from an engine.
    pub integrate_rigid: bool,
    pub courant_safety: f64,
    pub refine_utilization: Option<f64>,
    /// Adaptive mode: time a cluster stays explicit after its last dynamic load.
    pub active_time: f64,
    /// Adaptive mode: relative load change that wakes a settled cluster.
    pub wake_threshold: f64,
}

impl SolverConfig {
    pub fn from_scene(scene: &Scene) -> SolverConfig {
        SolverConfig {
            gravity: Vec3::from_array(scene.gravity),
            fracture: scene.sim.fracture,
            mode: scene.sim.solve_mode,
            integrate_rigid: true,
            courant_safety: scene.sim.courant_safety,
            refine_utilization: scene.sim.refine_utilization,
            active_time: 0.5,
            wake_threshold: 0.02,
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Activity {
    /// Explicit dynamic substeps.
    Active,
    /// Held at quasi-static equilibrium; re-solved when its loads change.
    Settled,
}

/// A rigid cluster of chunks.
#[derive(Clone, Debug)]
pub struct Cluster {
    /// Unique, never reused.
    pub id: u64,
    pub parent: Option<u64>,
    pub structure: usize,
    /// Active chunk indices (into the structure).
    pub chunks: Vec<usize>,
    /// Live runtime bonds with both chunks in this cluster (intact or cracked-contact).
    pub bonds: Vec<usize>,
    /// Holds supported chunks: the frame is the static world frame.
    pub anchored: bool,
    /// Pose of the structure's body frame for this cluster.
    pub pose: Pose,
    /// Centre of mass in the body frame (undeformed).
    pub com: Vec3,
    pub mass: f64,
    /// Inertia about the centre of mass, body frame.
    pub inertia: Mat3,
    /// Velocity of the centre of mass and angular velocity (world).
    pub velocity: Vec3,
    pub angular_velocity: Vec3,
    pub activity: Activity,
    pub active_timer: f64,
    /// External chunk loads at the last quasi-static solve (for change detection).
    pub settled_load_norm: f64,
}

impl Cluster {
    pub fn com_world(&self) -> Vec3 {
        self.pose.transform_point(self.com)
    }
    pub fn rotation(&self) -> Mat3 {
        self.pose.rotation.to_mat3()
    }
    pub fn world_inertia(&self) -> Mat3 {
        let r = self.rotation();
        r * self.inertia * r.transpose()
    }
}

/// Hidden deformation state of a chunk (body frame of its cluster).
#[derive(Clone, Copy, Debug, Default)]
pub struct ChunkState {
    pub u: Vec3,
    pub th: Vec3,
    pub v: Vec3,
    pub w: Vec3,
    /// Represented in the simulation (not removed, and on the current refinement level).
    pub active: bool,
    pub removed: bool,
    /// Index into `ReferenceSolver::clusters` (valid when active).
    pub cluster: usize,
    /// Support reaction (body frame force and moment) at the last substep.
    pub reaction: (Vec3, Vec3),
}

/// A bond as simulated: a static bond, possibly re-attached to coarser chunks.
#[derive(Clone, Debug)]
pub struct RtBond {
    /// Static bond in the structure this was created from.
    pub source: usize,
    pub geometry: BondGeometry,
    pub stiffness: BondStiffness,
    pub strength: JointStrength,
    pub rebar: Option<RebarParams>,
    pub weibull: f64,
    pub damping: Local6,
    pub level: u32,
    pub alive: bool,
    pub joint: JointState,
    /// Last actual generalised force (incl. damping) and effective stress measures.
    pub force: Local6,
    pub measures: StressMeasures,
    pub stored: f64,
}

impl RtBond {
    fn from_static(index: usize, b: &BondData) -> RtBond {
        RtBond {
            source: index,
            geometry: b.geometry.clone(),
            stiffness: b.stiffness,
            strength: b.strength.clone(),
            rebar: b.rebar,
            weibull: b.weibull,
            damping: b.damping,
            level: b.level,
            alive: true,
            joint: JointState::new(),
            force: Local6::ZERO,
            measures: StressMeasures::default(),
            stored: 0.0,
        }
    }

    pub fn model(&self) -> JointModel<'_> {
        JointModel {
            geometry: &self.geometry,
            stiffness: &self.stiffness,
            strength: &self.strength,
            rebar: self.rebar.as_ref(),
            weibull: self.weibull,
        }
    }

    pub fn connected(&self) -> bool {
        self.alive && self.joint.connected(self.rebar.is_some())
    }
}

/// Things that happened, for rendering (crack decals), audio and VFX.
#[derive(Clone, Debug, PartialEq, serde::Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum SolverEvent {
    /// A bond first took damage (crack initiation).
    Cracked { time: f64, structure: usize, bond: usize, mode: Option<FailureMode>, position: [f64; 3] },
    /// Sustained-load damage crossed 10% (audible creak).
    Creaked { time: f64, structure: usize, bond: usize, position: [f64; 3] },
    /// A bond stopped connecting its chunks.
    Broken { time: f64, structure: usize, bond: usize, mode: Option<FailureMode>, position: [f64; 3], normal: [f64; 3], dissipated: f64 },
    Split { time: f64, parent: u64, children: Vec<u64> },
    Refined { time: f64, structure: usize, chunk: usize },
}

/// Cumulative energy terms (J). See `energy_balance` in `world.rs` for the closed form.
#[derive(Clone, Copy, Debug, Default, serde::Serialize)]
pub struct EnergyLedger {
    /// Damage, friction and rebar plasticity in bonds.
    pub bond_dissipation: f64,
    /// Bond dashpots.
    pub damping_dissipation: f64,
    /// Work done on chunks by external (non-gravity) loads.
    pub external_work: f64,
}

/// Force-replacement load of a removed member (alternate-path procedure).
#[derive(Clone, Debug)]
pub struct ReplacementLoad {
    pub structure: usize,
    pub chunk: usize,
    /// Body-frame force and moment at `start`.
    pub force: Vec3,
    pub moment: Vec3,
    pub start: f64,
    pub duration: f64,
}

impl ReplacementLoad {
    pub fn factor(&self, t: f64) -> f64 {
        if self.duration <= 0.0 {
            0.0
        } else {
            (1.0 - (t - self.start) / self.duration).clamp(0.0, 1.0)
        }
    }
}

/// External loads on chunks for one substep (world frame; torque about the chunk centre).
#[derive(Clone, Debug, Default)]
pub struct ChunkLoads {
    pub force: Vec<Vec<Vec3>>,
    pub torque: Vec<Vec<Vec3>>,
}

impl ChunkLoads {
    pub fn new(solver: &ReferenceSolver) -> ChunkLoads {
        let mut l = ChunkLoads::default();
        l.resize(solver);
        l
    }
    pub fn resize(&mut self, solver: &ReferenceSolver) {
        self.force = solver.structures.iter().map(|s| vec![Vec3::ZERO; s.chunks.len()]).collect();
        self.torque = self.force.clone();
    }
    pub fn clear(&mut self) {
        self.force.iter_mut().flatten().for_each(|f| *f = Vec3::ZERO);
        self.torque.iter_mut().flatten().for_each(|f| *f = Vec3::ZERO);
    }
    /// Add a world force applied at world point `at` on a chunk centred at `center`.
    pub fn add_at(&mut self, structure: usize, chunk: usize, force: Vec3, at: Vec3, center: Vec3) {
        self.force[structure][chunk] += force;
        self.torque[structure][chunk] += (at - center).cross(force);
    }
}

pub struct ReferenceSolver {
    pub config: SolverConfig,
    pub structures: Vec<Structure>,
    pub chunks: Vec<Vec<ChunkState>>,
    pub bonds: Vec<Vec<RtBond>>,
    /// Runtime bonds touching each chunk.
    pub chunk_bonds: Vec<Vec<Vec<usize>>>,
    pub clusters: Vec<Cluster>,
    pub time: f64,
    pub energy: EnergyLedger,
    pub events: Vec<SolverEvent>,
    pub replacements: Vec<ReplacementLoad>,
    next_cluster_id: u64,
    /// Scratch: internal forces per chunk.
    f_int: Vec<Vec<(Vec3, Vec3)>>,
    /// Set when a bond disconnects during a substep.
    pending_split: Vec<usize>,
    /// Substep count, for diagnostics.
    pub substeps: u64,
}

impl ReferenceSolver {
    pub fn new(scene: &Scene) -> ReferenceSolver {
        let config = SolverConfig::from_scene(scene);
        let structures: Vec<Structure> = (0..scene.bodies.len()).map(|i| Structure::from_scene(scene, i)).collect();
        let mut solver = ReferenceSolver {
            config,
            chunks: Vec::new(),
            bonds: Vec::new(),
            chunk_bonds: Vec::new(),
            clusters: Vec::new(),
            time: 0.0,
            energy: EnergyLedger::default(),
            events: Vec::new(),
            replacements: Vec::new(),
            next_cluster_id: 0,
            f_int: Vec::new(),
            pending_split: Vec::new(),
            substeps: 0,
            structures,
        };
        for si in 0..solver.structures.len() {
            let s = &solver.structures[si];
            let chunks: Vec<ChunkState> = s
                .chunks
                .iter()
                .map(|c| ChunkState { active: c.level == 0, ..Default::default() })
                .collect();
            let bonds: Vec<RtBond> =
                s.bonds.iter().enumerate().filter(|(_, b)| b.level == 0).map(|(i, b)| RtBond::from_static(i, b)).collect();
            solver.chunks.push(chunks);
            solver.bonds.push(bonds);
            solver.chunk_bonds.push(Vec::new());
            solver.f_int.push(vec![(Vec3::ZERO, Vec3::ZERO); s.chunks.len()]);
            solver.rebuild_adjacency(si);
            let s = &solver.structures[si];
            let pose = Pose::new(s.initial_position, s.initial_rotation);
            let (v, w) = (s.initial_velocity, s.initial_angular_velocity);
            let active: Vec<usize> = (0..s.chunks.len()).filter(|&c| solver.chunks[si][c].active).collect();
            for comp in solver.components(si, &active) {
                solver.add_cluster(si, comp, None, pose, |_| (v, w));
            }
        }
        solver
    }

    pub(crate) fn rebuild_adjacency(&mut self, s: usize) {
        let mut adj = vec![Vec::new(); self.structures[s].chunks.len()];
        for (i, b) in self.bonds[s].iter().enumerate() {
            if b.alive {
                adj[b.geometry.a].push(i);
                adj[b.geometry.b].push(i);
            }
        }
        self.chunk_bonds[s] = adj;
    }

    /// Connected components of `chunks` over connected bonds (deterministic order).
    fn components(&self, s: usize, chunks: &[usize]) -> Vec<Vec<usize>> {
        let n = self.structures[s].chunks.len();
        let mut member = vec![false; n];
        chunks.iter().for_each(|&c| member[c] = true);
        let mut seen = vec![false; n];
        let mut out = Vec::new();
        for &start in chunks {
            if seen[start] {
                continue;
            }
            let mut comp = vec![start];
            seen[start] = true;
            let mut head = 0;
            while head < comp.len() {
                let c = comp[head];
                head += 1;
                for &bi in &self.chunk_bonds[s][c] {
                    let b = &self.bonds[s][bi];
                    if !b.connected() {
                        continue;
                    }
                    let o = if b.geometry.a == c { b.geometry.b } else { b.geometry.a };
                    if member[o] && !seen[o] {
                        seen[o] = true;
                        comp.push(o);
                    }
                }
            }
            comp.sort_unstable();
            out.push(comp);
        }
        out
    }

    /// Create a cluster from chunks; `velocity_of(com_world)` supplies its rigid motion.
    fn add_cluster(
        &mut self,
        s: usize,
        chunks: Vec<usize>,
        parent: Option<u64>,
        pose: Pose,
        velocity_of: impl Fn(Vec3) -> (Vec3, Vec3),
    ) -> usize {
        let st = &self.structures[s];
        let mass: f64 = chunks.iter().map(|&c| st.chunks[c].mass).sum();
        let com = chunks.iter().map(|&c| st.chunks[c].center * st.chunks[c].mass).fold(Vec3::ZERO, |a, b| a + b) / mass;
        let mut inertia = Mat3::ZERO;
        for &c in &chunks {
            let ch = &st.chunks[c];
            let r = ch.center - com;
            inertia += ch.inertia + (Mat3::IDENTITY * r.norm2() - Mat3::outer(r, r)) * ch.mass;
        }
        let anchored = chunks.iter().any(|&c| st.chunks[c].support != Support::None);
        let (velocity, angular_velocity) =
            if anchored { (Vec3::ZERO, Vec3::ZERO) } else { velocity_of(pose.transform_point(com)) };
        let idx = self.clusters.len();
        for &c in &chunks {
            self.chunks[s][c].cluster = idx;
        }
        let set: std::collections::HashSet<usize> = chunks.iter().copied().collect();
        let mut bonds: Vec<usize> = chunks
            .iter()
            .flat_map(|&c| self.chunk_bonds[s][c].iter().copied())
            .filter(|&b| {
                let g = &self.bonds[s][b].geometry;
                set.contains(&g.a) && set.contains(&g.b)
            })
            .collect();
        bonds.sort_unstable();
        bonds.dedup();
        self.clusters.push(Cluster {
            id: self.next_cluster_id,
            parent,
            structure: s,
            chunks,
            bonds,
            anchored,
            pose,
            com,
            mass,
            inertia,
            velocity,
            angular_velocity,
            activity: Activity::Active,
            active_timer: self.config.active_time,
            settled_load_norm: 0.0,
        });
        self.next_cluster_id += 1;
        idx
    }

    /// Recompute a cluster's chunk/bond lists and mass properties after its chunks
    /// changed in place (refinement); its rigid motion is kept.
    pub(crate) fn refresh_cluster_membership(&mut self, ci: usize) {
        let s = self.clusters[ci].structure;
        let chunks: Vec<usize> =
            (0..self.structures[s].chunks.len()).filter(|&c| self.chunks[s][c].active && self.chunks[s][c].cluster == ci).collect();
        let st = &self.structures[s];
        let mass: f64 = chunks.iter().map(|&c| st.chunks[c].mass).sum();
        let com = chunks.iter().map(|&c| st.chunks[c].center * st.chunks[c].mass).fold(Vec3::ZERO, |a, b| a + b) / mass;
        let mut inertia = Mat3::ZERO;
        for &c in &chunks {
            let ch = &st.chunks[c];
            let r = ch.center - com;
            inertia += ch.inertia + (Mat3::IDENTITY * r.norm2() - Mat3::outer(r, r)) * ch.mass;
        }
        let set: std::collections::HashSet<usize> = chunks.iter().copied().collect();
        let mut bonds: Vec<usize> = chunks
            .iter()
            .flat_map(|&c| self.chunk_bonds[s][c].iter().copied())
            .filter(|&b| {
                let g = &self.bonds[s][b].geometry;
                set.contains(&g.a) && set.contains(&g.b)
            })
            .collect();
        bonds.sort_unstable();
        bonds.dedup();
        let cl = &mut self.clusters[ci];
        cl.chunks = chunks;
        cl.bonds = bonds;
        cl.mass = mass;
        cl.com = com;
        cl.inertia = inertia;
    }

    // ------------------------------------------------------------------ kinematics

    /// World position of a chunk centre (including its hidden displacement).
    pub fn chunk_position(&self, s: usize, c: usize) -> Vec3 {
        let cl = &self.clusters[self.chunks[s][c].cluster];
        cl.pose.transform_point(self.structures[s].chunks[c].center + self.chunks[s][c].u)
    }

    /// World velocity and angular velocity of a chunk.
    pub fn chunk_velocity(&self, s: usize, c: usize) -> (Vec3, Vec3) {
        let st = &self.chunks[s][c];
        let cl = &self.clusters[st.cluster];
        let r = cl.pose.transform_vector(self.structures[s].chunks[c].center + st.u - cl.com);
        (
            cl.velocity + cl.angular_velocity.cross(r) + cl.pose.transform_vector(st.v),
            cl.angular_velocity + cl.pose.transform_vector(st.w),
        )
    }

    /// Velocity of a world point rigidly attached to a chunk.
    pub fn point_velocity(&self, s: usize, c: usize, p: Vec3) -> Vec3 {
        let (v, w) = self.chunk_velocity(s, c);
        v + w.cross(p - self.chunk_position(s, c))
    }

    /// Total kinetic energy of all active chunks (world frame).
    pub fn kinetic_energy(&self) -> f64 {
        let mut e = 0.0;
        for (s, st) in self.structures.iter().enumerate() {
            for (c, ch) in st.chunks.iter().enumerate() {
                if !self.chunks[s][c].active {
                    continue;
                }
                let (v, w) = self.chunk_velocity(s, c);
                let cl = &self.clusters[self.chunks[s][c].cluster];
                let r = cl.rotation();
                let iw = r * ch.inertia * r.transpose();
                e += 0.5 * ch.mass * v.norm2() + 0.5 * w.dot(iw * w);
            }
        }
        e
    }

    /// Recoverable elastic energy stored in bonds at the last evaluation.
    pub fn elastic_energy(&self) -> f64 {
        self.bonds.iter().flatten().filter(|b| b.alive).map(|b| b.stored).sum()
    }

    /// Gravitational potential energy `-m g . x` of all active chunks.
    pub fn gravity_potential(&self) -> f64 {
        let g = self.config.gravity;
        let mut e = 0.0;
        for (s, st) in self.structures.iter().enumerate() {
            for (c, ch) in st.chunks.iter().enumerate() {
                if self.chunks[s][c].active {
                    e -= ch.mass * g.dot(self.chunk_position(s, c));
                }
            }
        }
        e
    }

    // ------------------------------------------------------------------ timestep

    /// Gershgorin bound on the highest natural frequency (rad/s) of a cluster's
    /// deformation, with every bond at full stiffness (damage only lowers it).
    pub fn max_frequency(&self, ci: usize) -> f64 {
        let cl = &self.clusters[ci];
        let s = cl.structure;
        let st = &self.structures[s];
        let mut row = vec![[0.0f64; 6]; st.chunks.len()];
        for &bi in &cl.bonds {
            let b = &self.bonds[s][bi];
            let g = &b.geometry;
            let mut k = b.stiffness.as_local();
            if let Some(r) = &b.rebar {
                k.lin.z += r.k_axial;
                k.lin.x += r.k_dowel;
                k.lin.y += r.k_dowel;
            }
            let ks = [k.lin.x, k.lin.y, k.lin.z, k.ang.x, k.ang.y, k.ang.z];
            let axes = [g.t1, g.t2, g.normal];
            for comp in 0..6 {
                let t = axes[comp % 3];
                // 12-vector of this component's kinematic row: [u_a, th_a, u_b, th_b].
                let row_vec: [Vec3; 4] = if comp < 3 {
                    [-t, -(g.ra.cross(t)), t, g.rb.cross(t)]
                } else {
                    [Vec3::ZERO, -t, Vec3::ZERO, t]
                };
                let l1: f64 = row_vec.iter().map(|v| v.x.abs() + v.y.abs() + v.z.abs()).sum();
                for (blk, chunk) in [(0usize, g.a), (2usize, g.b)] {
                    for d in 0..3 {
                        row[chunk][d] += ks[comp] * row_vec[blk][d].abs() * l1;
                        row[chunk][3 + d] += ks[comp] * row_vec[blk + 1][d].abs() * l1;
                    }
                }
            }
        }
        let mut w2: f64 = 0.0;
        for &c in &cl.chunks {
            let ch = &st.chunks[c];
            let i_min = smallest_principal_moment(&ch.inertia);
            for d in 0..3 {
                w2 = w2.max(row[c][d] / ch.mass);
                w2 = w2.max(row[c][3 + d] / i_min);
            }
        }
        w2.sqrt()
    }

    /// Largest stable explicit substep over all active clusters (with damping and safety).
    pub fn stable_dt(&self) -> f64 {
        let mut dt = f64::INFINITY;
        for ci in 0..self.clusters.len() {
            if self.clusters[ci].bonds.is_empty() {
                continue;
            }
            let w = self.max_frequency(ci);
            if w <= 0.0 {
                continue;
            }
            let zeta = self.clusters[ci]
                .bonds
                .iter()
                .map(|&b| {
                    let bd = &self.bonds[self.clusters[ci].structure][b];
                    0.5 * bd.damping.lin.z / bd.stiffness.kn * w
                })
                .fold(0.0f64, f64::max);
            let crit = 2.0 / w * ((1.0 + zeta * zeta).sqrt() - zeta);
            dt = dt.min(crit);
        }
        dt * self.config.courant_safety
    }

    // ------------------------------------------------------------------ substep

    /// Advance every cluster by one explicit substep under the given external loads.
    pub fn substep(&mut self, dt: f64, loads: &ChunkLoads) {
        let t_mid = self.time + dt;
        for ci in 0..self.clusters.len() {
            let explicit = match self.config.mode {
                SolveMode::Explicit => true,
                SolveMode::QuasiStatic => false,
                SolveMode::Adaptive => self.clusters[ci].activity == Activity::Active,
            };
            if explicit {
                self.substep_cluster(ci, dt, loads, t_mid);
            } else {
                self.advance_rigid_only(ci, dt, loads);
            }
        }
        self.time += dt;
        self.substeps += 1;
        if !self.pending_split.is_empty() {
            self.process_splits();
        }
    }

    /// External loads of a chunk in the body frame of its cluster, minus the inertial
    /// loads of the cluster's rigid motion (`a`, `alpha` world).
    pub(crate) fn frame_loads(&self, ci: usize, c: usize, loads: &ChunkLoads, a: Vec3, alpha: Vec3, t: f64) -> (Vec3, Vec3) {
        let cl = &self.clusters[ci];
        let s = cl.structure;
        let ch = &self.structures[s].chunks[c];
        let r_world = cl.pose.transform_vector(ch.center + self.chunks[s][c].u - cl.com);
        let w = cl.angular_velocity;
        let rot = cl.rotation();
        let iw = rot * ch.inertia * rot.transpose();
        let f_world = loads.force[s][c] + self.config.gravity * ch.mass
            - (a + alpha.cross(r_world) + w.cross(w.cross(r_world))) * ch.mass;
        let t_world = loads.torque[s][c] - (iw * alpha + w.cross(iw * w));
        let mut f = cl.pose.inverse_transform_vector(f_world);
        let mut m = cl.pose.inverse_transform_vector(t_world);
        for rl in &self.replacements {
            if rl.structure == s && rl.chunk == c {
                let k = rl.factor(t);
                f += rl.force * k;
                m += rl.moment * k;
            }
        }
        (f, m)
    }

    /// Net external force and torque (about the com) on a cluster, world frame, gravity included.
    fn net_load(&self, ci: usize, loads: &ChunkLoads) -> (Vec3, Vec3) {
        let cl = &self.clusters[ci];
        let s = cl.structure;
        let com = cl.com_world();
        let mut f = Vec3::ZERO;
        let mut t = Vec3::ZERO;
        for &c in &cl.chunks {
            let ch = &self.structures[s].chunks[c];
            let fc = loads.force[s][c] + self.config.gravity * ch.mass;
            let x = cl.pose.transform_point(ch.center + self.chunks[s][c].u);
            f += fc;
            t += (x - com).cross(fc) + loads.torque[s][c];
        }
        for rl in &self.replacements {
            if rl.structure == s && self.chunks[s][rl.chunk].active && self.chunks[s][rl.chunk].cluster == ci {
                let k = rl.factor(self.time);
                let x = cl.pose.transform_point(self.structures[s].chunks[rl.chunk].center);
                let fw = cl.pose.transform_vector(rl.force * k);
                f += fw;
                t += (x - com).cross(fw) + cl.pose.transform_vector(rl.moment * k);
            }
        }
        (f, t)
    }

    /// Rigid acceleration of a free cluster under its net load.
    pub(crate) fn rigid_acceleration(&self, ci: usize, loads: &ChunkLoads) -> (Vec3, Vec3) {
        let cl = &self.clusters[ci];
        if cl.anchored {
            return (Vec3::ZERO, Vec3::ZERO);
        }
        let (f, t) = self.net_load(ci, loads);
        let iw = cl.world_inertia();
        let w = cl.angular_velocity;
        let alpha = iw.inverse().expect("cluster inertia invertible") * (t - w.cross(iw * w));
        (f / cl.mass, alpha)
    }

    fn integrate_rigid(&mut self, ci: usize, dt: f64, a: Vec3, alpha: Vec3) {
        if !self.config.integrate_rigid || self.clusters[ci].anchored {
            return;
        }
        let cl = &mut self.clusters[ci];
        let com_world = cl.com_world();
        cl.velocity += a * dt;
        cl.angular_velocity += alpha * dt;
        let new_com = com_world + cl.velocity * dt;
        cl.pose.rotation = cl.pose.rotation.integrate(cl.angular_velocity, dt);
        cl.pose.position = new_com - cl.pose.rotation.rotate(cl.com);
    }

    fn advance_rigid_only(&mut self, ci: usize, dt: f64, loads: &ChunkLoads) {
        let (a, alpha) = self.rigid_acceleration(ci, loads);
        self.integrate_rigid(ci, dt, a, alpha);
    }

    fn substep_cluster(&mut self, ci: usize, dt: f64, loads: &ChunkLoads, t: f64) {
        let (a, alpha) = self.rigid_acceleration(ci, loads);
        let s = self.clusters[ci].structure;
        // Internal forces from the current displacements (and lagged velocities for damping).
        for &c in &self.clusters[ci].chunks {
            self.f_int[s][c] = (Vec3::ZERO, Vec3::ZERO);
        }
        let fracture = self.config.fracture;
        let bond_ids = self.clusters[ci].bonds.clone();
        let mut dissipated = 0.0;
        let mut damped = 0.0;
        for bi in bond_ids {
            let (ga, gb) = {
                let g = &self.bonds[s][bi].geometry;
                (g.a, g.b)
            };
            let (sa, sb) = (self.chunks[s][ga], self.chunks[s][gb]);
            let b = &self.bonds[s][bi];
            let d = b.geometry.kinematics(sa.u, sa.th, sb.u, sb.th);
            let rate = b.geometry.kinematics(sa.v, sa.w, sb.v, sb.w);
            let resp = b.model().evaluate(&b.joint, &d, dt, fracture);
            let factors = b.model().secant_factors(&resp.state, &d);
            let q_damp = rate.mul_elem(&b.damping).mul_elem(&factors);
            let q = resp.force.add(&q_damp);
            damped += q_damp.dot(&rate) * dt;
            dissipated += resp.dissipated;
            let (fa, ma, fb, mb) = b.geometry.chunk_loads(&q);
            let prev_damage = b.joint.damage + b.joint.crush;
            let prev_sustained = b.joint.sustained;
            let (pos, normal) = (b.geometry.centroid, b.geometry.normal);
            let bm = &mut self.bonds[s][bi];
            bm.joint = resp.state;
            bm.force = q;
            bm.measures = resp.measures;
            bm.stored = resp.stored;
            self.f_int[s][ga].0 += fa;
            self.f_int[s][ga].1 += ma;
            self.f_int[s][gb].0 += fb;
            self.f_int[s][gb].1 += mb;
            if prev_damage == 0.0 && bm.joint.damage + bm.joint.crush > 0.0 {
                let mode = bm.joint.mode;
                let p = self.clusters[ci].pose.transform_point(pos);
                self.events.push(SolverEvent::Cracked { time: t, structure: s, bond: bi, mode, position: p.to_array() });
            }
            let bm = &self.bonds[s][bi];
            if prev_sustained < 0.1 && bm.joint.sustained >= 0.1 {
                let p = self.clusters[ci].pose.transform_point(pos);
                self.events.push(SolverEvent::Creaked { time: t, structure: s, bond: bi, position: p.to_array() });
            }
            if resp.disconnected {
                let cl = &self.clusters[ci];
                self.events.push(SolverEvent::Broken {
                    time: t,
                    structure: s,
                    bond: bi,
                    mode: bm.joint.mode,
                    position: cl.pose.transform_point(pos).to_array(),
                    normal: cl.pose.transform_vector(normal).to_array(),
                    dissipated: bm.joint.dissipated,
                });
                if !self.pending_split.contains(&ci) {
                    self.pending_split.push(ci);
                }
            }
        }
        self.energy.bond_dissipation += dissipated;
        self.energy.damping_dissipation += damped;

        // Update chunk deformation (central difference: v at half steps).
        let chunk_ids = self.clusters[ci].chunks.clone();
        let (pose, cv, cw, com) = {
            let cl = &self.clusters[ci];
            (cl.pose, cl.velocity, cl.angular_velocity, cl.com)
        };
        let mut work = 0.0;
        for c in chunk_ids {
            let (f_ext, m_ext) = self.frame_loads(ci, c, loads, a, alpha, t);
            let (fi, mi) = self.f_int[s][c];
            let ch = &self.structures[s].chunks[c];
            let st = &mut self.chunks[s][c];
            match ch.support {
                Support::Fixed => {
                    st.reaction = (-(f_ext + fi), -(m_ext + mi));
                    st.v = Vec3::ZERO;
                    st.w = Vec3::ZERO;
                }
                Support::Pinned => {
                    st.reaction = (-(f_ext + fi), Vec3::ZERO);
                    st.v = Vec3::ZERO;
                    st.w += ch.inv_inertia * (m_ext + mi) * dt;
                    st.th += st.w * dt;
                }
                Support::None => {
                    st.v += (f_ext + fi) * (dt / ch.mass);
                    st.w += ch.inv_inertia * (m_ext + mi) * dt;
                    st.u += st.v * dt;
                    st.th += st.w * dt;
                }
            }
            // Work of the external (non-gravity) loads at the chunk's world velocity.
            let r = pose.transform_vector(ch.center + st.u - com);
            let v_world = cv + cw.cross(r) + pose.transform_vector(st.v);
            let w_world = cw + pose.transform_vector(st.w);
            work += (loads.force[s][c].dot(v_world) + loads.torque[s][c].dot(w_world)) * dt;
        }
        self.energy.external_work += work;
        self.integrate_rigid(ci, dt, a, alpha);
        if !self.clusters[ci].anchored {
            self.remove_rigid_drift(ci);
        }
    }

    /// Remove any net linear/angular momentum from the deformation velocities of a free
    /// cluster (the floating frame carries all rigid motion); round-off only.
    fn remove_rigid_drift(&mut self, ci: usize) {
        let cl = &self.clusters[ci];
        let s = cl.structure;
        let st = &self.structures[s];
        let mut p = Vec3::ZERO;
        let mut l = Vec3::ZERO;
        for &c in &cl.chunks {
            let ch = &st.chunks[c];
            let cs = &self.chunks[s][c];
            let r = ch.center - cl.com;
            p += cs.v * ch.mass;
            l += r.cross(cs.v) * ch.mass + ch.inertia * cs.w;
        }
        let dv = p / cl.mass;
        let dw = cl.inertia.inverse().expect("invertible") * l;
        // Translational part is exact; the rotational part uses the undeformed inertia.
        let chunks = cl.chunks.clone();
        let com = cl.com;
        for c in chunks {
            let r = st.chunks[c].center - com;
            let cs = &mut self.chunks[s][c];
            cs.v -= dv + dw.cross(r);
            cs.w -= dw;
        }
    }

    // ------------------------------------------------------------------ fracture

    fn process_splits(&mut self) {
        let mut pending = std::mem::take(&mut self.pending_split);
        pending.sort_unstable();
        pending.dedup();
        // Highest index first so swap-removal does not disturb lower pending indices.
        for &ci in pending.iter().rev() {
            self.split_cluster(ci);
        }
    }

    /// Recompute the connectivity of cluster `ci` and split it into children.
    pub fn split_cluster(&mut self, ci: usize) {
        let s = self.clusters[ci].structure;
        let comps = self.components(s, &self.clusters[ci].chunks.clone());
        if comps.len() <= 1 {
            return;
        }
        let parent = self.clusters.swap_remove(ci);
        if ci < self.clusters.len() {
            // Re-point the chunks of the cluster that moved into slot `ci`.
            let moved = self.clusters[ci].clone();
            for &c in &moved.chunks {
                self.chunks[moved.structure][c].cluster = ci;
            }
        }
        // Mass data of the parent's chunks (copied: the loop below mutates `self`).
        let lite: std::collections::HashMap<usize, (Vec3, f64, Mat3)> = parent
            .chunks
            .iter()
            .map(|&c| {
                let ch = &self.structures[s].chunks[c];
                (c, (ch.center, ch.mass, ch.inertia))
            })
            .collect();
        let rot = parent.rotation();
        // Exact world velocity of every chunk before the split.
        let mut vel: std::collections::HashMap<usize, (Vec3, Vec3)> = std::collections::HashMap::new();
        let com_world = parent.com_world();
        for &c in &parent.chunks {
            let cs = &self.chunks[s][c];
            let x = parent.pose.transform_point(lite[&c].0 + cs.u);
            let v = parent.velocity + parent.angular_velocity.cross(x - com_world) + rot * cs.v;
            let w = parent.angular_velocity + rot * cs.w;
            vel.insert(c, (v, w));
        }
        // Bonds crossing between children are handed over to rigid-body contact.
        let mut comp_of = std::collections::HashMap::new();
        for (k, comp) in comps.iter().enumerate() {
            for &c in comp {
                comp_of.insert(c, k);
            }
        }
        for &bi in &parent.bonds {
            let g = &self.bonds[s][bi].geometry;
            if comp_of[&g.a] != comp_of[&g.b] {
                self.bonds[s][bi].alive = false;
            }
        }
        self.rebuild_adjacency(s);
        let mut children = Vec::new();
        for comp in comps {
            // Linear and angular momentum of the child from its chunks' exact velocities.
            let mass: f64 = comp.iter().map(|&c| lite[&c].1).sum();
            let com_local =
                comp.iter().map(|&c| lite[&c].0 * lite[&c].1).fold(Vec3::ZERO, |a, b| a + b) / mass;
            let mut p = Vec3::ZERO;
            let mut l = Vec3::ZERO;
            let mut i_local = Mat3::ZERO;
            for &c in &comp {
                let (center, ch_mass, ch_inertia) = lite[&c];
                let (v, w) = vel[&c];
                let r = parent.pose.transform_vector(center - com_local);
                p += v * ch_mass;
                l += r.cross(v) * ch_mass + rot * ch_inertia * rot.transpose() * w;
                let rl = center - com_local;
                i_local += ch_inertia + (Mat3::IDENTITY * rl.norm2() - Mat3::outer(rl, rl)) * ch_mass;
            }
            let iw = rot * i_local * rot.transpose();
            let (cv, cw) = (p / mass, iw.inverse().expect("invertible") * l);
            let idx = self.add_cluster(s, comp.clone(), Some(parent.id), parent.pose, |_| (cv, cw));
            let child = self.clusters[idx].clone();
            // Hidden velocities: whatever the child's rigid motion does not carry.
            for &c in &comp {
                let (v, w) = vel[&c];
                let r = parent.pose.transform_vector(lite[&c].0 - child.com);
                let cs = &mut self.chunks[s][c];
                cs.v = rot.transpose() * (v - child.velocity - child.angular_velocity.cross(r));
                cs.w = rot.transpose() * (w - child.angular_velocity);
            }
            // Fold the mean hidden translation of a free child into its pose.
            if !child.anchored {
                let mean = comp.iter().map(|&c| self.chunks[s][c].u * lite[&c].1).fold(Vec3::ZERO, |a, b| a + b)
                    / mass;
                for &c in &comp {
                    self.chunks[s][c].u -= mean;
                }
                self.clusters[idx].pose.position += parent.pose.transform_vector(mean);
            }
            children.push(self.clusters[idx].id);
        }
        self.events.push(SolverEvent::Split { time: self.time, parent: parent.id, children });
    }

    // ------------------------------------------------------------------ events

    /// Remove chunks; the forces their bonds exerted on the rest are replaced by
    /// external loads that ramp to zero over `duration` (0 = sudden).
    pub fn remove_chunks(&mut self, s: usize, chunks: &[usize], duration: f64) {
        let removed: std::collections::HashSet<usize> =
            chunks.iter().copied().filter(|&c| self.chunks[s][c].active).collect();
        if removed.is_empty() {
            return;
        }
        for b in self.bonds[s].iter_mut() {
            if !b.alive {
                continue;
            }
            let (a, bb) = (b.geometry.a, b.geometry.b);
            let ra = removed.contains(&a);
            let rb = removed.contains(&bb);
            if !(ra || rb) {
                continue;
            }
            if ra != rb {
                let (fa, ma, fb, mb) = b.geometry.chunk_loads(&b.force);
                let (kept, f, m) = if ra { (bb, fb, mb) } else { (a, fa, ma) };
                self.replacements.push(ReplacementLoad {
                    structure: s,
                    chunk: kept,
                    force: f,
                    moment: m,
                    start: self.time,
                    duration,
                });
            }
            b.alive = false;
        }
        for &c in &removed {
            self.chunks[s][c].active = false;
            self.chunks[s][c].removed = true;
        }
        self.rebuild_adjacency(s);
        self.rebuild_structure_clusters(s);
    }

    /// Remove the supports of chunks, replacing their reactions by ramped loads.
    pub fn remove_supports(&mut self, s: usize, chunks: &[usize], duration: f64) {
        for &c in chunks {
            if self.structures[s].chunks[c].support == Support::None {
                continue;
            }
            let (f, m) = self.chunks[s][c].reaction;
            self.replacements.push(ReplacementLoad { structure: s, chunk: c, force: f, moment: m, start: self.time, duration });
            self.structures[s].chunks[c].support = Support::None;
            self.chunks[s][c].reaction = (Vec3::ZERO, Vec3::ZERO);
        }
        self.rebuild_structure_clusters(s);
    }

    /// Rebuild all clusters of a structure from current connectivity (keeps motion).
    fn rebuild_structure_clusters(&mut self, s: usize) {
        let affected: Vec<usize> = (0..self.clusters.len()).filter(|&i| self.clusters[i].structure == s).collect();
        for &ci in affected.iter().rev() {
            // Drop removed chunks from the cluster, then split/re-anchor by connectivity.
            let keep: Vec<usize> = self.clusters[ci].chunks.iter().copied().filter(|&c| self.chunks[s][c].active).collect();
            if keep.is_empty() {
                self.clusters.swap_remove(ci);
                if ci < self.clusters.len() {
                    let moved = self.clusters[ci].clone();
                    for &c in &moved.chunks {
                        self.chunks[moved.structure][c].cluster = ci;
                    }
                }
                continue;
            }
            let old = self.clusters[ci].clone();
            let pose = old.pose;
            let (v, w, com_w) = (old.velocity, old.angular_velocity, old.com_world());
            let comps = self.components(s, &keep);
            self.clusters.swap_remove(ci);
            if ci < self.clusters.len() {
                let moved = self.clusters[ci].clone();
                for &c in &moved.chunks {
                    self.chunks[moved.structure][c].cluster = ci;
                }
            }
            let mut children = Vec::new();
            for comp in comps {
                let idx = self.add_cluster(s, comp, Some(old.id), pose, |x| (v + w.cross(x - com_w), w));
                children.push(self.clusters[idx].id);
            }
            if children.len() > 1 {
                self.events.push(SolverEvent::Split { time: self.time, parent: old.id, children });
            }
        }
    }

    // ------------------------------------------------------------------ queries

    /// Cluster index of an active chunk.
    pub fn cluster_of(&self, s: usize, c: usize) -> Option<usize> {
        let st = &self.chunks[s][c];
        st.active.then_some(st.cluster)
    }

    pub fn structure_index(&self, name: &str) -> Option<usize> {
        self.structures.iter().position(|s| s.name == name)
    }

    /// Number of bonds (static, level 0) that no longer connect their chunks.
    pub fn broken_bond_count(&self) -> usize {
        self.bonds.iter().flatten().filter(|b| !b.connected()).count()
    }

    /// Support reaction of a chunk in world frame.
    pub fn reaction_world(&self, s: usize, c: usize) -> (Vec3, Vec3) {
        let st = &self.chunks[s][c];
        if !st.active {
            return (Vec3::ZERO, Vec3::ZERO);
        }
        let cl = &self.clusters[st.cluster];
        (cl.pose.transform_vector(st.reaction.0), cl.pose.transform_vector(st.reaction.1))
    }
}

/// Smallest eigenvalue of a symmetric positive 3x3 matrix (closed form).
pub fn smallest_principal_moment(m: &Mat3) -> f64 {
    let a = &m.m;
    let p1 = a[0][1] * a[0][1] + a[0][2] * a[0][2] + a[1][2] * a[1][2];
    if p1 < 1e-30 * (a[0][0].abs() + a[1][1].abs() + a[2][2].abs()).powi(2) {
        return a[0][0].min(a[1][1]).min(a[2][2]);
    }
    let q = m.trace() / 3.0;
    let p2 = (a[0][0] - q).powi(2) + (a[1][1] - q).powi(2) + (a[2][2] - q).powi(2) + 2.0 * p1;
    let p = (p2 / 6.0).sqrt();
    let b = (*m - Mat3::IDENTITY * q) * (1.0 / p);
    let r = (b.det() / 2.0).clamp(-1.0, 1.0);
    let phi = r.acos() / 3.0;
    q + 2.0 * p * (phi + 2.0 * std::f64::consts::PI / 3.0).cos()
}
