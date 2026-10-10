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
//! damping; the substep is a safety fraction of the smallest per-chunk damped
//! central-difference limit, from Gershgorin bounds on each chunk's stiffness and
//! dashpot rows. Settled clusters may instead be solved quasi-statically
//! (`statics.rs`) and idle clusters sleep (`SolveMode::Adaptive`).
//!
//! **Fracture.** Bonds are evaluated every substep (`joint.rs`). When a bond stops
//! connecting its chunks, the cluster's connectivity is recomputed and it splits into
//! child clusters that inherit each chunk's exact velocity (`v + w x r` of the parent
//! plus the hidden deformation velocity), conserving linear and angular momentum.

use crate::bond::{BondGeometry, BondStiffness, Local6};
use crate::joint::{fatigue_factor, FailureMode, JointModel, JointResponse, JointState, JointStrength, RebarParams, StressMeasures};
use crate::math::{Mat3, Pose, Quat, Vec3};
use crate::scene::{Features, Scene, SolveMode, Support};
use crate::structure::{BondData, Structure};

/// Solver settings (from the scene's `sim` block).
/// Residual static-fatigue strength factor at which a bond "creaks" ([`SolverEvent::Creaked`]).
pub const CREAK_STRENGTH: f64 = 0.99;

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
    pub features: Features,
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
            features: scene.sim.features,
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
    /// Rigid motion owned by an external engine this frame (see `engine.rs`): the
    /// solver neither integrates it nor folds hidden motion into it.
    pub driven: bool,
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
    /// Multiplier on the chunk's deformation inertia (selective mass scaling; 1 = none).
    pub inertia_scale: f64,
    /// `SolveMode::Implicit` only: hidden accelerations of the last implicit step, and
    /// the hidden state at its end (the next step starts from it; between steps `u`,
    /// `th`, `v`, `w` hold the predictor, see `implicit.rs`).
    pub a: Vec3,
    pub alpha: Vec3,
    pub step_start: [Vec3; 4],
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
    /// Static fatigue cost a bond its first percent of strength ([`CREAK_STRENGTH`]):
    /// the onset of measurable strength loss, heard as creaking (acoustic emission).
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
    /// Stored energy released beyond the softening law by bonds snapping within one
    /// substep (time-discretisation; shrinks with the substep).
    pub softening_overshoot: f64,
    /// Energy stored in bonds between chunks that a split separates; the pieces keep
    /// their overlap instead of being pushed apart (see `contact.rs`).
    pub split_release: f64,
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
    /// Resize (zeroed) only if the solver's chunk counts differ; keeps the values otherwise.
    pub fn ensure_shape(&mut self, solver: &ReferenceSolver) {
        let same = self.force.len() == solver.structures.len()
            && self.force.iter().zip(&solver.structures).all(|(f, s)| f.len() == s.chunks.len());
        if !same {
            self.resize(solver);
        }
    }
    pub fn clear(&mut self) {
        self.force.iter_mut().flatten().for_each(|f| *f = Vec3::ZERO);
        self.torque.iter_mut().flatten().for_each(|f| *f = Vec3::ZERO);
    }
    /// `self += other * k`.
    pub fn add_scaled(&mut self, other: &ChunkLoads, k: f64) {
        for (a, b) in self.force.iter_mut().flatten().zip(other.force.iter().flatten()) {
            *a += *b * k;
        }
        for (a, b) in self.torque.iter_mut().flatten().zip(other.torque.iter().flatten()) {
            *a += *b * k;
        }
    }
    pub fn scale(&mut self, k: f64) {
        self.force.iter_mut().flatten().for_each(|f| *f *= k);
        self.torque.iter_mut().flatten().for_each(|f| *f *= k);
    }
    /// Add a world force applied at world point `at` on a chunk centred at `center`.
    pub fn add_at(&mut self, structure: usize, chunk: usize, force: Vec3, at: Vec3, center: Vec3) {
        self.force[structure][chunk] += force;
        self.torque[structure][chunk] += (at - center).cross(force);
    }
}

#[derive(Clone)]
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
    /// Largest bond failure index seen so far (meaningful with fracture disabled too).
    pub max_utilization: f64,
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
            max_utilization: 0.0,
            structures,
        };
        for si in 0..solver.structures.len() {
            let s = &solver.structures[si];
            let chunks: Vec<ChunkState> = s
                .chunks
                .iter()
                .map(|c| ChunkState { active: c.level == 0, inertia_scale: 1.0, ..Default::default() })
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
            driven: false,
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

    /// Gershgorin row sums of a cluster's bond matrix for one per-bond coefficient set
    /// (`coeffs` gives the 6 local components: shear t1, shear t2, axial, bending t1,
    /// bending t2, torsion): per chunk, the 3 translational then 3 rotational rows.
    fn gershgorin_rows(&self, ci: usize, coeffs: impl Fn(&RtBond) -> [f64; 6]) -> Vec<[f64; 6]> {
        let cl = &self.clusters[ci];
        let s = cl.structure;
        let mut row = vec![[0.0f64; 6]; self.structures[s].chunks.len()];
        for &bi in &cl.bonds {
            let b = &self.bonds[s][bi];
            let g = &b.geometry;
            let ks = coeffs(b);
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
        row
    }

    /// Full stiffness of a bond's 6 components (concrete plus rebar).
    fn bond_stiffness6(b: &RtBond) -> [f64; 6] {
        let mut k = b.stiffness.as_local();
        if let Some(r) = &b.rebar {
            k.lin.z += r.k_axial;
            k.lin.x += r.k_dowel;
            k.lin.y += r.k_dowel;
        }
        [k.lin.x, k.lin.y, k.lin.z, k.ang.x, k.ang.y, k.ang.z]
    }

    /// Gershgorin bound on each chunk's squared natural frequency (rad^2/s^2) in a
    /// cluster, with every bond at full stiffness (damage only lowers it) and the
    /// chunk's (possibly scaled) deformation inertia. Returns `(chunk, omega^2)`.
    pub fn chunk_frequencies(&self, ci: usize) -> Vec<(usize, f64)> {
        let row = self.gershgorin_rows(ci, Self::bond_stiffness6);
        let st = &self.structures[self.clusters[ci].structure];
        let s = self.clusters[ci].structure;
        self.clusters[ci]
            .chunks
            .iter()
            .map(|&c| {
                let ch = &st.chunks[c];
                let mu = self.chunks[s][c].inertia_scale;
                let i_min = smallest_principal_moment(&ch.inertia);
                let w2 = (0..3).map(|d| (row[c][d] / ch.mass).max(row[c][3 + d] / i_min)).fold(0.0, f64::max);
                (c, w2 / mu)
            })
            .collect()
    }

    /// Stable central-difference substep of each chunk of a cluster (before the safety
    /// factor), `2/w (sqrt(1 + zeta^2) - zeta)` for every translational and rotational
    /// row, with `w` and `zeta` from that row's own stiffness and dashpot sums
    /// (Gershgorin). Each bond's dashpot is proportional to its own stiffness at its own
    /// frequency, so a soft bond adds little damping: pairing one bond's damping ratio
    /// with another chunk's frequency would overstate the damping.
    pub fn chunk_stable_dts(&self, ci: usize) -> Vec<(usize, f64)> {
        let k = self.gershgorin_rows(ci, Self::bond_stiffness6);
        let c = self.gershgorin_rows(ci, |b| [b.damping.lin.x, b.damping.lin.y, b.damping.lin.z, b.damping.ang.x, b.damping.ang.y, b.damping.ang.z]);
        let s = self.clusters[ci].structure;
        self.clusters[ci]
            .chunks
            .iter()
            .map(|&ch| {
                let data = &self.structures[s].chunks[ch];
                let mu = self.chunks[s][ch].inertia_scale;
                let i_min = smallest_principal_moment(&data.inertia);
                let dt = (0..6)
                    .filter(|&d| k[ch][d] > 0.0)
                    .map(|d| {
                        let m = mu * if d < 3 { data.mass } else { i_min };
                        let w = (k[ch][d] / m).sqrt();
                        let zeta = c[ch][d] / (2.0 * m * w);
                        2.0 / w * ((1.0 + zeta * zeta).sqrt() - zeta)
                    })
                    .fold(f64::INFINITY, f64::min);
                (ch, dt)
            })
            .collect()
    }

    /// Selective mass scaling (explicit solve): give every chunk whose own stable
    /// substep is below `target_dt` just enough extra *deformation* inertia to reach it
    /// (`mu = (target / dt_chunk)^2`), as explicit FE codes do instead of softening the
    /// material. Stiffness, strengths, loads and rigid-body masses stay physical; only
    /// the response of the smallest chunks to fast loading is slowed. Returns the added
    /// mass as a fraction of the total.
    pub fn apply_mass_scaling(&mut self, target_dt: f64) -> f64 {
        let safety = self.config.courant_safety;
        let mut added = 0.0;
        let mut total = 0.0;
        for ci in 0..self.clusters.len() {
            let s = self.clusters[ci].structure;
            for (c, w2) in self.chunk_frequencies(ci) {
                let dt_chunk = if w2 > 0.0 { 2.0 * safety / w2.sqrt() } else { f64::INFINITY };
                let state = &mut self.chunks[s][c];
                state.inertia_scale *= (target_dt / dt_chunk).powi(2).max(1.0);
                let m = self.structures[s].chunks[c].mass;
                added += (state.inertia_scale - 1.0) * m;
                total += m;
            }
        }
        if total > 0.0 {
            added / total
        } else {
            0.0
        }
    }

    /// Largest stable explicit substep over all active clusters (with damping and safety).
    pub fn stable_dt(&self) -> f64 {
        let mut dt = f64::INFINITY;
        for ci in 0..self.clusters.len() {
            // Only clusters integrated explicitly limit the step (adaptive: the active ones).
            let settled = self.config.mode == SolveMode::Adaptive && self.clusters[ci].activity != Activity::Active;
            if self.clusters[ci].bonds.is_empty() || settled {
                continue;
            }
            dt = self.chunk_stable_dts(ci).iter().map(|&(_, d)| d).fold(dt, f64::min);
        }
        dt * self.config.courant_safety
    }

    // ------------------------------------------------------------------ substep

    /// Advance every cluster by one explicit substep under the given external loads.
    pub fn substep(&mut self, dt: f64, loads: &ChunkLoads) {
        let t_mid = self.time + dt;
        // Clusters integrated explicitly this substep. Their bond responses and chunk
        // loads depend only on the state at the start of the substep, so all of them
        // (across every cluster) are evaluated in parallel; the results are then applied
        // cluster by cluster in index order, bond by bond, exactly as a sequential sweep
        // would (bit-identical for any thread count).
        let explicit: Vec<usize> = (0..self.clusters.len()).filter(|&ci| self.integrates_explicitly(ci)).collect();
        let accel = crate::par::map(&explicit, |&ci| self.rigid_acceleration(ci, loads));
        let fracture = self.config.fracture;
        let bond_jobs: Vec<(usize, usize)> = explicit
            .iter()
            .flat_map(|&ci| {
                let cl = &self.clusters[ci];
                cl.bonds.iter().map(move |&bi| (cl.structure, bi))
            })
            .collect();
        let mut responses = crate::par::map(&bond_jobs, |&(s, bi)| self.bond_response(s, bi, dt, fracture)).into_iter();
        for &ci in &explicit {
            self.apply_bond_responses(ci, &mut responses, t_mid);
        }
        let chunk_jobs: Vec<(usize, usize)> =
            explicit.iter().enumerate().flat_map(|(k, &ci)| self.clusters[ci].chunks.iter().map(move |&c| (k, c))).collect();
        let mut frame_loads = crate::par::map(&chunk_jobs, |&(k, c)| {
            let (a, alpha) = accel[k];
            self.frame_loads(explicit[k], c, loads, a, alpha, t_mid)
        })
        .into_iter();
        let mut next = explicit.iter().zip(&accel).peekable();
        for ci in 0..self.clusters.len() {
            match next.peek() {
                Some(&(&e, &(a, alpha))) if e == ci => {
                    next.next();
                    self.integrate_cluster(ci, dt, loads, a, alpha, &mut frame_loads);
                }
                _ => {
                    if self.config.mode == SolveMode::Implicit {
                        self.implicit_predict(ci, dt, loads, t_mid);
                    }
                    self.advance_rigid_only(ci, dt, loads);
                }
            }
        }
        self.time += dt;
        self.substeps += 1;
        if !self.pending_split.is_empty() {
            self.process_splits();
        }
    }

    /// Whether cluster `ci` takes explicit substeps (the others are quasi-static,
    /// implicit or settled and only move rigidly here).
    fn integrates_explicitly(&self, ci: usize) -> bool {
        match self.config.mode {
            SolveMode::Explicit => true,
            SolveMode::QuasiStatic | SolveMode::Implicit => false,
            SolveMode::Adaptive => self.clusters[ci].activity == Activity::Active,
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
        let mut f_world = loads.force[s][c] + self.config.gravity * ch.mass;
        let mut t_world = loads.torque[s][c];
        if self.config.features.rigid_motion_loads {
            f_world -= (a + alpha.cross(r_world) + w.cross(w.cross(r_world))) * ch.mass;
            t_world -= iw * alpha + w.cross(iw * w);
        }
        let mut f = cl.pose.inverse_transform_vector(f_world);
        let mut m = cl.pose.inverse_transform_vector(t_world);
        if self.config.features.rigid_motion_loads {
            // Coupling of the hidden velocities with the frame rotation (body frame):
            // Coriolis force on the chunk and the gyroscopic cross terms of its spin.
            let wb = cl.pose.inverse_transform_vector(w);
            let st = &self.chunks[s][c];
            f -= wb.cross(st.v) * (2.0 * ch.mass);
            m -= wb.cross(ch.inertia * st.w) + st.w.cross(ch.inertia * wb) + st.w.cross(ch.inertia * st.w);
        }
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
    pub(crate) fn net_load(&self, ci: usize, loads: &ChunkLoads) -> (Vec3, Vec3) {
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

    /// Symplectic rigid update. The angular part integrates angular momentum (exactly
    /// conserved when the net torque vanishes) and recovers the angular velocity from
    /// the rotated inertia.
    fn integrate_rigid(&mut self, ci: usize, dt: f64, a: Vec3, alpha: Vec3) {
        if !self.config.integrate_rigid || self.clusters[ci].anchored || self.clusters[ci].driven {
            return;
        }
        let cl = &mut self.clusters[ci];
        let com_world = cl.com_world();
        let iw = cl.world_inertia();
        // alpha = Iw^-1 (tau - w x Iw w)  =>  dL/dt = tau = Iw alpha + w x Iw w.
        let torque = iw * alpha + cl.angular_velocity.cross(iw * cl.angular_velocity);
        let l = iw * cl.angular_velocity + torque * dt;
        cl.velocity += a * dt;
        let new_com = com_world + cl.velocity * dt;
        // Rotate with the momentum-consistent angular velocity, then refresh it.
        let w_mid = iw.inverse().expect("invertible") * l;
        cl.pose.rotation = cl.pose.rotation.integrate(w_mid, dt);
        cl.pose.position = new_com - cl.pose.rotation.rotate(cl.com);
        cl.angular_velocity = cl.world_inertia().inverse().expect("invertible") * l;
    }

    /// Rigid update only (no deformation), e.g. between implicit steps.
    pub(crate) fn advance_rigid(&mut self, ci: usize, dt: f64, loads: &ChunkLoads) {
        self.advance_rigid_only(ci, dt, loads);
    }

    /// An impulse `impulse` (world, N s) at world point `point` on chunk `c`, as an
    /// instantaneous change of the chunk's velocity: the velocity condition of an impact
    /// with inertia in the stress solve. Under an engine (`integrate_rigid` off) the
    /// engine has already given the cluster its rigid share, so the chunk's hidden
    /// velocity takes the change and the floating frame removes the rigid share again.
    /// In implicit mode the next step starts from the kicked velocity.
    pub fn apply_chunk_impulse(&mut self, s: usize, c: usize, impulse: Vec3, point: Vec3) {
        let ci = self.chunks[s][c].cluster;
        let pose = self.clusters[ci].pose;
        let ch = &self.structures[s].chunks[c];
        if ch.support != Support::None {
            return;
        }
        let x = self.chunk_position(s, c);
        let st = &mut self.chunks[s][c];
        let dv = pose.inverse_transform_vector(impulse) * (1.0 / (ch.mass * st.inertia_scale));
        let dw = ch.inv_inertia * pose.inverse_transform_vector((point - x).cross(impulse)) * (1.0 / st.inertia_scale);
        st.v += dv;
        st.w += dw;
        st.step_start[2] += dv;
        st.step_start[3] += dw;
    }

    fn advance_rigid_only(&mut self, ci: usize, dt: f64, loads: &ChunkLoads) {
        let (a, alpha) = self.rigid_acceleration(ci, loads);
        self.integrate_rigid(ci, dt, a, alpha);
    }

    /// Response of bond `bi` of structure `s` to the current chunk displacements, with
    /// its dashpot force (from the lagged velocities) and the energy that dissipates.
    fn bond_response(&self, s: usize, bi: usize, dt: f64, fracture: bool) -> (JointResponse, Local6, f64) {
        let b = &self.bonds[s][bi];
        let (sa, sb) = (self.chunks[s][b.geometry.a], self.chunks[s][b.geometry.b]);
        let d = b.geometry.kinematics(sa.u, sa.th, sb.u, sb.th);
        let rate = b.geometry.kinematics(sa.v, sa.w, sb.v, sb.w);
        let resp = b.model().evaluate(&b.joint, &d, dt, fracture);
        let factors = b.model().secant_factors(&resp.state, &d);
        let q_damp = rate.mul_elem(&b.damping).mul_elem(&factors);
        let q = resp.force.add(&q_damp);
        let damped = q_damp.dot(&rate) * dt;
        (resp, q, damped)
    }

    /// Commit the bond responses of cluster `ci` (taken in bond order from `responses`):
    /// joint states, internal chunk forces, energies and events.
    fn apply_bond_responses(&mut self, ci: usize, responses: &mut impl Iterator<Item = (JointResponse, Local6, f64)>, t: f64) {
        let s = self.clusters[ci].structure;
        for &c in &self.clusters[ci].chunks {
            self.f_int[s][c] = (Vec3::ZERO, Vec3::ZERO);
        }
        let mut dissipated = 0.0;
        let mut damped = 0.0;
        for k in 0..self.clusters[ci].bonds.len() {
            let bi = self.clusters[ci].bonds[k];
            let (resp, q, bond_damped) = responses.next().expect("one response per bond");
            let (ga, gb) = {
                let g = &self.bonds[s][bi].geometry;
                (g.a, g.b)
            };
            damped += bond_damped;
            dissipated += resp.dissipated;
            self.energy.softening_overshoot += resp.overshoot;
            self.max_utilization = self.max_utilization.max(resp.state.utilization);
            let (fa, ma, fb, mb) = self.bonds[s][bi].geometry.chunk_loads(&q);
            let bm = &mut self.bonds[s][bi];
            let previous = std::mem::replace(&mut bm.joint, resp.state);
            bm.force = q;
            bm.measures = resp.measures;
            bm.stored = resp.stored;
            self.f_int[s][ga].0 += fa;
            self.f_int[s][ga].1 += ma;
            self.f_int[s][gb].0 += fb;
            self.f_int[s][gb].1 += mb;
            if self.record_bond_events(ci, bi, &previous, resp.disconnected, t) && !self.pending_split.contains(&ci) {
                self.pending_split.push(ci);
            }
        }
        self.energy.bond_dissipation += dissipated;
        self.energy.damping_dissipation += damped;
    }

    /// Central-difference update of cluster `ci`'s chunk deformation (velocities at half
    /// steps) under the internal forces and its chunk loads (taken in chunk order from
    /// `frame_loads`), then its rigid motion.
    fn integrate_cluster(&mut self, ci: usize, dt: f64, loads: &ChunkLoads, a: Vec3, alpha: Vec3, frame_loads: &mut impl Iterator<Item = (Vec3, Vec3)>) {
        let s = self.clusters[ci].structure;
        let (pose, cv, cw, com) = {
            let cl = &self.clusters[ci];
            (cl.pose, cl.velocity, cl.angular_velocity, cl.com)
        };
        let mut work = 0.0;
        for k in 0..self.clusters[ci].chunks.len() {
            let c = self.clusters[ci].chunks[k];
            let (f_ext, m_ext) = frame_loads.next().expect("one load per chunk");
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
                    st.w += ch.inv_inertia * (m_ext + mi) * (dt / st.inertia_scale);
                    st.th += st.w * dt;
                }
                Support::None => {
                    st.v += (f_ext + fi) * (dt / (ch.mass * st.inertia_scale));
                    st.w += ch.inv_inertia * (m_ext + mi) * (dt / st.inertia_scale);
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

    /// Emit the events of bond `bi` (in cluster `ci`) changing from `previous` to its
    /// current state at time `t`: first damage (`Cracked`), first percent of strength
    /// lost to static fatigue (`Creaked`), disconnection (`Broken`). Returns whether the
    /// bond disconnected (the cluster must then be split).
    pub(crate) fn record_bond_events(&mut self, ci: usize, bi: usize, previous: &JointState, disconnected: bool, t: f64) -> bool {
        let s = self.clusters[ci].structure;
        let b = &self.bonds[s][bi];
        let pose = self.clusters[ci].pose;
        let position = pose.transform_point(b.geometry.centroid).to_array();
        if !previous.is_damaged() && b.joint.is_damaged() {
            let mode = b.joint.mode;
            self.events.push(SolverEvent::Cracked { time: t, structure: s, bond: bi, mode, position });
        }
        let b = &self.bonds[s][bi];
        if fatigue_factor(&b.strength, previous) > CREAK_STRENGTH && fatigue_factor(&b.strength, &b.joint) <= CREAK_STRENGTH {
            self.events.push(SolverEvent::Creaked { time: t, structure: s, bond: bi, position });
        }
        let b = &self.bonds[s][bi];
        if disconnected {
            self.events.push(SolverEvent::Broken {
                time: t,
                structure: s,
                bond: bi,
                mode: b.joint.mode,
                position,
                normal: pose.transform_vector(b.geometry.normal).to_array(),
                dissipated: b.joint.dissipated,
            });
        }
        disconnected
    }

    /// Disconnect the given bonds now (a fracture verdict decided elsewhere, e.g. by a
    /// trial evaluation of the same tick) and split the clusters they held together.
    /// The energy the bonds store is booked as `split_release`; each bond gets a
    /// `Broken` event. Children inherit the exact momentum of their chunks.
    pub fn break_bonds(&mut self, bonds: &[(usize, usize)]) {
        let mut clusters = Vec::new();
        for &(s, bi) in bonds {
            if !self.bonds[s][bi].connected() {
                continue;
            }
            let previous = self.bonds[s][bi].joint.clone();
            let b = &mut self.bonds[s][bi];
            b.joint.damage = 1.0;
            b.joint.rebar_broken = true;
            let ci = self.chunks[s][b.geometry.a].cluster;
            self.record_bond_events(ci, bi, &previous, true, self.time);
            if !clusters.contains(&ci) {
                clusters.push(ci);
            }
        }
        // Highest index first: splitting swap-removes the parent.
        clusters.sort_unstable();
        for &ci in clusters.iter().rev() {
            self.split_cluster(ci);
        }
    }

    /// Keep the floating frame on the cluster (a mean-axis frame): fold the best-fit
    /// rigid translation and rotation of the hidden displacements into the cluster pose,
    /// and the net linear and angular momentum of the hidden velocities into its rigid
    /// velocity. Chunk positions are unchanged to second order in the (tiny, per-substep)
    /// correction and chunk velocities exactly, so total momentum is conserved.
    ///
    /// Without this the small-rotation bond model sees a growing rigid rotation of the
    /// hidden field whose bond forces do not turn with it, which is unstable in a
    /// spinning body. Moving only the velocities (not the rotation) is inconsistent too:
    /// the hidden field then integrates the opposite rotation. Under an engine (which owns
    /// rigid motion) the hidden rigid motion is removed instead.
    pub(crate) fn remove_rigid_drift(&mut self, ci: usize) {
        let cl = &self.clusters[ci];
        let s = cl.structure;
        let st = &self.structures[s];
        // Deformation-inertia weights (true masses unless mass scaling is on): the
        // frame follows the hidden field's momentum under the inertia that integrates it.
        let weight = |c: usize| self.chunks[s][c].inertia_scale;
        let scaled = cl.chunks.iter().any(|&c| weight(c) != 1.0);
        let (mass, com, inertia) = if scaled {
            let mass: f64 = cl.chunks.iter().map(|&c| st.chunks[c].mass * weight(c)).sum();
            let com = cl.chunks.iter().map(|&c| st.chunks[c].center * (st.chunks[c].mass * weight(c))).fold(Vec3::ZERO, |a, b| a + b)
                / mass;
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
        let inv_i = inertia.inverse().expect("invertible");
        let (mut tu, mut pv) = (Vec3::ZERO, Vec3::ZERO);
        for &c in &cl.chunks {
            let m = st.chunks[c].mass * weight(c);
            tu += self.chunks[s][c].u * m;
            pv += self.chunks[s][c].v * m;
        }
        let (t, dv) = (tu / mass, pv / mass);
        let (mut lu, mut lv) = (Vec3::ZERO, Vec3::ZERO);
        for &c in &cl.chunks {
            let ch = &st.chunks[c];
            let cs = &self.chunks[s][c];
            let r = ch.center - com;
            let k = weight(c);
            lu += (r.cross(cs.u - t) * ch.mass + ch.inertia * cs.th) * k;
            lv += (r.cross(cs.v - dv) * ch.mass + ch.inertia * cs.w) * k;
        }
        let (phi, dw) = (inv_i * lu, inv_i * lv);
        let chunks = cl.chunks.clone();
        let true_com = cl.com;
        for c in chunks {
            let r = st.chunks[c].center - com;
            let cs = &mut self.chunks[s][c];
            cs.u -= t + phi.cross(r);
            cs.th -= phi;
            cs.v -= dv + dw.cross(r);
            cs.w -= dw;
        }
        if self.config.integrate_rigid && !self.clusters[ci].driven {
            let cl = &mut self.clusters[ci];
            let rot = cl.pose.rotation;
            cl.pose.position += rot.rotate(t - phi.cross(com));
            cl.pose.rotation = (rot * Quat::from_axis_angle(phi, phi.norm())).normalized();
            // The removed velocity field `dv + dw x (x - com)` evaluated at the true com.
            cl.velocity += rot.rotate(dv + dw.cross(true_com - com));
            cl.angular_velocity += rot.rotate(dw);
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
                self.energy.split_release += self.bonds[s][bi].stored;
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

    /// Number of bonds broken by fracture (bonds of removed chunks do not count).
    pub fn broken_bond_count(&self) -> usize {
        self.bonds.iter().flatten().filter(|b| !b.joint.connected(b.rebar.is_some())).count()
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
