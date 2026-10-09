//! Engine-facing stress-solver contract, so implementations can be swapped.
//!
//! A rigid-body engine (PhysX) owns cluster motion and contacts. Once per frame it
//! hands the stress solver the clusters' rigid state and the contact impulses their
//! chunks received; the solver returns the fractures to apply (child bodies with
//! their chunk sets and inherited velocities) and per-bond state for rendering, audio
//! and VFX. Applying fractures to the engine is shared code on the engine side.
//!
//! [`StressSolverApi`] is the contract; [`EngineCoupledSolver`] implements it with the
//! reference solver. Contact impulses go through [`ContactLoadFilter`]: a low-pass
//! resting load plus impact pulses spread over a physical impact duration (Hertz, or
//! crush-limited for soft impactors), never `impulse / dt`.

use std::collections::HashMap;

use serde::Serialize;

use crate::joint::FailureMode;
use crate::math::{Pose, Vec3};
use crate::scene::{CrushDesc, Scene};
use crate::solver::{ChunkLoads, ReferenceSolver, SolverEvent};

/// Stable id of a cluster (rigid body) across frames.
pub type ClusterId = u64;

/// One contact impulse delivered to a chunk during the last engine step.
#[derive(Clone, Debug)]
pub struct ContactImpulse {
    pub structure: usize,
    pub chunk: usize,
    /// World contact point.
    pub point: Vec3,
    /// Impulse applied to the chunk's body (N s, world).
    pub impulse: Vec3,
    /// Mass of the other body (infinite for static geometry).
    pub other_mass: f64,
    /// Closing speed along the contact normal before the contact (m/s).
    pub approach_speed: f64,
    /// Young's modulus and size (radius) of the other body, for the Hertz duration.
    pub other_modulus: f64,
    pub other_radius: f64,
    /// Crush model of a soft impactor (vehicle).
    pub crush: Option<CrushDesc>,
}

/// Rigid state of a cluster as integrated by the engine.
#[derive(Clone, Copy, Debug)]
pub struct ClusterMotion {
    pub id: ClusterId,
    pub pose: Pose,
    pub velocity: Vec3,
    pub angular_velocity: Vec3,
}

#[derive(Clone, Debug, Default)]
pub struct FrameInput {
    pub dt: f64,
    pub motion: Vec<ClusterMotion>,
    pub contacts: Vec<ContactImpulse>,
}

/// A new rigid body created by fracture.
#[derive(Clone, Debug, Serialize)]
pub struct ChildBody {
    pub id: ClusterId,
    pub structure: usize,
    pub chunks: Vec<usize>,
    pub anchored: bool,
    pub pose: [f64; 7],
    pub velocity: [f64; 3],
    pub angular_velocity: [f64; 3],
    pub mass: f64,
}

#[derive(Clone, Debug, Serialize)]
pub struct Fracture {
    pub parent: ClusterId,
    pub children: Vec<ChildBody>,
}

#[derive(Clone, Debug, Default)]
pub struct FrameOutput {
    pub fractures: Vec<Fracture>,
    pub events: Vec<SolverEvent>,
}

/// Per-bond state exposed to rendering (crack decals) and other systems.
#[derive(Clone, Debug, Serialize, PartialEq)]
pub struct BondReport {
    pub chunks: (usize, usize),
    pub damage: f64,
    pub crush: f64,
    /// Sustained-load strength loss.
    pub sustained: f64,
    /// Largest stress-over-strength ratio at the last evaluation.
    pub utilization: f64,
    pub mode: Option<FailureMode>,
    pub broken: bool,
    pub tension: f64,
    pub shear: f64,
    pub compression: f64,
}

/// The contract every stress-solver implementation (reference CPU, CUDA) provides.
pub trait StressSolverApi {
    /// Advance one engine frame.
    fn step(&mut self, input: &FrameInput) -> FrameOutput;
    /// Every live cluster with its chunks and rigid state.
    fn clusters(&self) -> Vec<ChildBody>;
    /// State of every bond of a structure (live and broken).
    fn bond_reports(&self, structure: usize) -> Vec<BondReport>;
}

/// Turns per-frame contact impulses into a substep force history.
#[derive(Clone, Debug, Default)]
pub struct ContactLoadFilter {
    /// Time constant of the resting-load low-pass filter (s).
    pub resting_time: f64,
    /// Impulse change (fraction of the resting impulse plus an absolute floor in N s)
    /// above which a contact is treated as an impact.
    pub impact_fraction: f64,
    pub impact_floor: f64,
    resting: HashMap<(usize, usize), (Vec3, Vec3)>,
    pulses: Vec<Pulse>,
}

#[derive(Clone, Debug)]
struct Pulse {
    structure: usize,
    chunk: usize,
    point: Vec3,
    direction: Vec3,
    start: f64,
    /// Plateau force and duration (crush-limited part), then a half-sine of the rest.
    plateau: f64,
    plateau_time: f64,
    peak: f64,
    duration: f64,
}

impl Pulse {
    fn magnitude(&self, t: f64) -> f64 {
        let tau = t - self.start;
        if tau < 0.0 {
            return 0.0;
        }
        if tau < self.plateau_time {
            return self.plateau;
        }
        let s = tau - self.plateau_time;
        if s > self.duration {
            0.0
        } else {
            self.peak * (std::f64::consts::PI * s / self.duration).sin()
        }
    }
    fn end(&self) -> f64 {
        self.start + self.plateau_time + self.duration
    }
}

/// Hertz contact duration of a sphere (reduced mass `m`, radius `r`) on a half-space,
/// effective modulus `e`, approach speed `v`.
pub fn hertz_duration(m: f64, r: f64, e: f64, v: f64) -> f64 {
    let v = v.abs().max(1e-3);
    2.87 * (m * m / (r * e * e * v)).powf(0.2)
}

impl ContactLoadFilter {
    pub fn new() -> ContactLoadFilter {
        ContactLoadFilter { resting_time: 0.1, impact_fraction: 0.5, impact_floor: 0.0, ..Default::default() }
    }

    /// Ingest one frame of impulses starting at time `t0`.
    pub fn ingest(&mut self, solver: &ReferenceSolver, t0: f64, dt: f64, contacts: &[ContactImpulse]) {
        let alpha = dt / (self.resting_time + dt);
        let mut seen = std::collections::HashSet::new();
        for c in contacts {
            let key = (c.structure, c.chunk);
            seen.insert(key);
            let rest = self.resting.entry(key).or_insert((Vec3::ZERO, c.point));
            let resting_impulse = rest.0 * dt;
            let excess = c.impulse - resting_impulse;
            let threshold = self.impact_fraction * resting_impulse.norm() + self.impact_floor;
            if excess.norm() > threshold && c.approach_speed > 0.0 {
                let ch = &solver.structures[c.structure].chunks[c.chunk];
                let m_chunk = ch.mass;
                let m = if c.other_mass.is_finite() { m_chunk * c.other_mass / (m_chunk + c.other_mass) } else { m_chunk };
                let r = c.other_radius.min(ch.volume().cbrt());
                let duration = hertz_duration(m, r, c.other_modulus, c.approach_speed);
                let j = excess.norm();
                let dir = excess / j;
                let (mut plateau, mut plateau_time, mut rest_j) = (0.0, 0.0, j);
                if let Some(cr) = c.crush {
                    // Crushing absorbs up to its energy at the plateau force; the
                    // remaining impulse arrives as a stiff (bottomed-out) pulse.
                    let ke = 0.5 * m * c.approach_speed * c.approach_speed;
                    let e_crush = ke.min(cr.energy);
                    let v1 = (c.approach_speed * c.approach_speed - 2.0 * e_crush / m).max(0.0).sqrt();
                    let jc = (m * (c.approach_speed - v1)).min(j);
                    plateau = cr.max_force;
                    plateau_time = jc / cr.max_force;
                    rest_j = j - jc;
                }
                let peak = std::f64::consts::PI * rest_j / (2.0 * duration);
                self.pulses.push(Pulse {
                    structure: c.structure,
                    chunk: c.chunk,
                    point: c.point,
                    direction: dir,
                    start: t0,
                    plateau,
                    plateau_time,
                    peak,
                    duration,
                });
            } else {
                rest.0 = rest.0 + (c.impulse / dt - rest.0) * alpha;
                rest.1 = c.point;
            }
        }
        for (k, v) in self.resting.iter_mut() {
            if !seen.contains(k) {
                v.0 = v.0 * (1.0 - alpha);
            }
        }
        self.resting.retain(|_, v| v.0.norm() > 0.0);
        self.pulses.retain(|p| p.end() > t0);
    }

    /// Force on every chunk at time `t`.
    pub fn loads_at(&self, solver: &ReferenceSolver, t: f64, loads: &mut ChunkLoads) {
        for (&(s, c), &(f, p)) in &self.resting {
            if solver.chunks[s][c].active {
                loads.add_at(s, c, f, p, solver.chunk_position(s, c));
            }
        }
        for p in &self.pulses {
            if solver.chunks[p.structure][p.chunk].active {
                let f = p.direction * p.magnitude(t);
                loads.add_at(p.structure, p.chunk, f, p.point, solver.chunk_position(p.structure, p.chunk));
            }
        }
    }

    /// Total impulse of all pulses (for momentum checks).
    pub fn pulse_impulse(&self) -> f64 {
        self.pulses.iter().map(|p| p.plateau * p.plateau_time + 2.0 * p.peak * p.duration / std::f64::consts::PI).sum()
    }
}

/// The reference solver driven by an external rigid-body engine.
pub struct EngineCoupledSolver {
    pub solver: ReferenceSolver,
    pub filter: ContactLoadFilter,
    loads: ChunkLoads,
}

impl EngineCoupledSolver {
    pub fn new(scene: &Scene) -> EngineCoupledSolver {
        let mut solver = ReferenceSolver::new(scene);
        solver.config.integrate_rigid = false;
        let loads = ChunkLoads::new(&solver);
        let mut s = EngineCoupledSolver { solver, filter: ContactLoadFilter::new(), loads };
        s.loads.clear();
        s.solver.gravity_prestress();
        s
    }

    fn child_body(&self, ci: usize) -> ChildBody {
        let c = &self.solver.clusters[ci];
        let p = c.pose;
        ChildBody {
            id: c.id,
            structure: c.structure,
            chunks: c.chunks.clone(),
            anchored: c.anchored,
            pose: [p.position.x, p.position.y, p.position.z, p.rotation.w, p.rotation.x, p.rotation.y, p.rotation.z],
            velocity: c.velocity.to_array(),
            angular_velocity: c.angular_velocity.to_array(),
            mass: c.mass,
        }
    }
}

impl StressSolverApi for EngineCoupledSolver {
    fn step(&mut self, input: &FrameInput) -> FrameOutput {
        for m in &input.motion {
            if let Some(c) = self.solver.clusters.iter_mut().find(|c| c.id == m.id) {
                if !c.anchored {
                    c.pose = m.pose;
                    c.velocity = m.velocity;
                    c.angular_velocity = m.angular_velocity;
                }
            }
        }
        let t0 = self.solver.time;
        self.filter.ingest(&self.solver, t0, input.dt, &input.contacts);
        let n_events = self.solver.events.len();
        let dt_sub = self.solver.stable_dt().min(input.dt);
        let n = (input.dt / dt_sub).ceil().max(1.0) as usize;
        let h = input.dt / n as f64;
        for _ in 0..n {
            self.loads.resize(&self.solver);
            self.loads.clear();
            self.filter.loads_at(&self.solver, self.solver.time, &mut self.loads);
            self.solver.substep(h, &self.loads);
        }
        let events: Vec<SolverEvent> = self.solver.events[n_events..].to_vec();
        let mut fractures = Vec::new();
        for e in &events {
            if let SolverEvent::Split { parent, children, .. } = e {
                let kids = children
                    .iter()
                    .filter_map(|id| self.solver.clusters.iter().position(|c| c.id == *id))
                    .map(|ci| self.child_body(ci))
                    .collect();
                fractures.push(Fracture { parent: *parent, children: kids });
            }
        }
        FrameOutput { fractures, events }
    }

    fn clusters(&self) -> Vec<ChildBody> {
        (0..self.solver.clusters.len()).map(|ci| self.child_body(ci)).collect()
    }

    fn bond_reports(&self, structure: usize) -> Vec<BondReport> {
        self.solver.bonds[structure]
            .iter()
            .map(|b| BondReport {
                chunks: (b.geometry.a, b.geometry.b),
                damage: b.joint.damage,
                crush: b.joint.crush,
                sustained: b.joint.sustained,
                utilization: b.joint.utilization,
                mode: b.joint.mode,
                broken: !b.connected(),
                tension: b.measures.tension,
                shear: b.measures.shear,
                compression: b.measures.compression,
            })
            .collect()
    }
}
