//! Standalone reference world: runs a scene end to end without an external engine.
//!
//! The world owns the [`ReferenceSolver`] plus the minimum rigid-body machinery the
//! benchmarks need: rigid impactors (optionally crush-capped), a ground plane, penalty
//! contact between chunks of different clusters (debris landing on structures), scripted
//! loads (point forces, face pressures, blasts) and scripted events (member and support
//! removal). Everything advances on the stress substep, so impacts are resolved over
//! their physical contact duration.
//!
//! This is a test harness, not a rigid-body engine: there is no sleeping, no stacking
//! solver and no edge-edge contact. Production runs couple the stress solver to PhysX
//! through `api.rs`.

use std::collections::HashMap;

use crate::api::{hertz_duration, ContactImpulse, ContactLoadFilter};
use crate::blast::FaceBlast;
use crate::engine::{BodyGeometry, BodyKey, BodyMotion, BoxShape, EngineBody, RigidEngine};
use crate::contact::OBox;
use crate::polytope::{ball_cells, field_cells, LayerContact, Owner, Polytope, OWNER_A, OWNER_B};
use crate::material::Material;
use crate::math::{Mat3, Pose, Quat, Vec3};
use crate::observation::{ChunkObservation, Observation, ProbeSeries};
use crate::scene::{
    ChunkSelector, EventDesc, ImpactorShape, LoadDesc, ProbeKind, Scene, SectionComponent, SolveMode, Support,
};
use crate::solver::{Activity, ChunkLoads, ReferenceSolver};
use crate::statics::StaticOptions;

#[path = "world_coupling.rs"]
mod coupling;

/// Friction regularisation speed (m/s): below it friction scales linearly with slip speed.
const FRICTION_REGULARIZATION: f64 = 1e-3;
/// Largest total viscous coefficient (normal dashpot or regularised friction) of one
/// contact set (a chunk against one other body), as a fraction of `m_red / dt`. Its
/// points share it, so a set stays stable however many points engage; a chunk may be
/// in contact with a few sets at once (explicit stability needs `c dt / m < 2`).
const MAX_SET_VISCOSITY: f64 = 1.0;
/// Points over which a face pair spreads its stiffness and viscosity: a set engaging
/// more never exceeds its face-pair values (the stable-substep assumption).
const FACE_PAIR_POINTS: usize = 10;

#[derive(Clone, Debug)]
pub struct Impactor {
    pub name: String,
    pub shape: ImpactorShape,
    pub mass: f64,
    pub inertia: Mat3,
    pub pose: Pose,
    pub velocity: Vec3,
    pub angular_velocity: Vec3,
    pub material: Material,
    pub crush: Option<(f64, f64)>,
    pub crush_used: f64,
    pub crush_depth: f64,
    /// Moved by an external engine this frame (not in an impact island).
    pub driven: bool,
}

impl Impactor {
    fn obox(&self) -> OBox {
        let h = match self.shape {
            ImpactorShape::Box { half_extents } => Vec3::from_array(half_extents),
            ImpactorShape::Sphere { radius } => Vec3::splat(radius),
        };
        OBox { center: self.pose.position, rotation: self.pose.rotation.to_mat3(), half: h, hull: None }
    }
    pub fn kinetic_energy(&self) -> f64 {
        let r = self.pose.rotation.to_mat3();
        let iw = r * self.inertia * r.transpose();
        0.5 * self.mass * self.velocity.norm2() + 0.5 * self.angular_velocity.dot(iw * self.angular_velocity)
    }
}

/// Energy terms of the contacts (J).
#[derive(Clone, Copy, Debug, Default, serde::Serialize)]
pub struct ContactLedger {
    /// Penalty energy currently stored in contacts.
    pub stored: f64,
    /// Dashpot, friction and crush dissipation so far.
    pub dissipated: f64,
    pub crush: f64,
    /// Work done by chunk-pair contact forces on the chunks (diagnostic).
    pub pair_work: f64,
    /// Work done by every contact force on the bodies over the displacement the
    /// integrator applied (force at the start of the substep, velocity at its end):
    /// `-work - stored + received` is the energy the contacts actually took out of the
    /// motion: with `layer_contact`, the dissipation booked.
    pub work: f64,
    /// Energy handed to contacts by the joints of a split (their compression).
    pub received: f64,
    /// With `layer_contact`: the dashpot, friction and crush dissipation by the force
    /// law's own quadrature (first order in the substep; diagnostic).
    pub modelled: f64,
    /// With `layer_contact`, by kind of contact (impactor on chunk, chunk on ground,
    /// impactor on ground, chunk on chunk): a force law that is the gradient of its
    /// stored energy plus its dashpots and friction has `modelled` and the dissipation
    /// from the work converging together with the substep.
    pub kinds: [KindLedger; 4],
}

/// One kind of contact's energy terms (J).
#[derive(Clone, Copy, Debug, Default, serde::Serialize)]
pub struct KindLedger {
    pub stored: f64,
    pub work: f64,
    pub received: f64,
    pub modelled: f64,
}

impl KindLedger {
    /// What these contacts took out of the motion, net of what they store.
    pub fn dissipated(&self) -> f64 {
        -self.work - self.stored + self.received
    }
}

pub const KIND_IMPACTOR: usize = 0;
pub const KIND_GROUND: usize = 1;
pub const KIND_IMPACTOR_GROUND: usize = 2;
pub const KIND_PAIR: usize = 3;

/// A body a contact acts on, for the contact work.
#[derive(Clone, Copy, Debug)]
enum Party {
    Chunk(usize, usize),
    Impactor(usize),
    Ground,
}

/// A contact's load this substep: force and moment on `a` (the opposite on `b`), with
/// the lever arms from each body's centre to the point of action.
#[derive(Clone, Copy, Debug)]
struct Applied {
    kind: usize,
    a: Party,
    ra: Vec3,
    b: Party,
    rb: Vec3,
    force: Vec3,
    moment: Vec3,
}

#[derive(Clone, Debug, Default)]
struct ProbeAcc {
    series: ProbeSeries,
    lo: f64,
    hi: f64,
    last: f64,
}

/// Cached blast loading of the exposed faces (rebuilt when topology changes).
#[derive(Clone, Debug)]
struct BlastCache {
    version: u64,
    faces: Vec<(usize, usize, usize, f64, FaceBlast)>,
}

#[derive(Clone)]
pub struct World {
    pub scene: Scene,
    pub solver: ReferenceSolver,
    pub impactors: Vec<Impactor>,
    pub contact: ContactLedger,
    /// Work done by scripted loads (point forces, pressures, blasts, replacement loads excluded).
    pub frame: u64,
    loads: ChunkLoads,
    frame_loads: ChunkLoads,
    /// Implicit mode: time-integrated loads since the last implicit step, and that time.
    implicit_loads: ChunkLoads,
    implicit_elapsed: f64,
    events_done: Vec<bool>,
    probes: Vec<ProbeAcc>,
    next_sample: f64,
    sample_interval: f64,
    initial_positions: Vec<Vec<Vec3>>,
    /// Exposed area per structure, chunk, face.
    exposure: Vec<Vec<Vec<f64>>>,
    exposure_version: u64,
    topology_version: u64,
    blast_caches: Vec<Option<BlastCache>>,
    contact_dt: f64,
    /// Implicit mode: the last step's solver report and the worst residual so far.
    pub implicit_report: crate::implicit::ImplicitReport,
    pub implicit_worst_residual: f64,
    /// Mass added by selective mass scaling, as a fraction of the total.
    pub added_mass_fraction: f64,
    /// Quasi-static mode: frames in which some cluster had no static equilibrium (a
    /// mechanism); it kept its last equilibrium.
    pub static_unconverged_frames: usize,
    /// Contact force magnitude received by each chunk during the current substep.
    contact_hits: Vec<Vec<f64>>,
    /// Pre-existing overlap per sample point of chunk pairs in contact (NaN = point not
    /// in contact); dropped when the pair separates.
    pair_offsets: std::collections::HashMap<ChunkPair, Vec<(f64, Vec3)>>,
    /// Elastic-layer contact: the friction state (shear-layer slip and twist) of every
    /// contact in touch, carried from substep to substep; dropped when it separates.
    sticks: HashMap<ContactKey, Stick>,
    /// Elastic-layer contacts applied this substep (for the contact work by kind).
    applied: Vec<Applied>,
    /// External rigid-body engine, if the world is coupled to one (`World::with_engine`).
    coupling: Option<Coupling>,
    /// Coupled mode: frames that had an impact island, and the most bodies in islands.
    pub island_frames: u64,
    pub max_island_bodies: usize,
    /// Coupled mode, summed over frames: movable bodies (free clusters, impactors) whose
    /// motion the engine integrated, and those the world simulated in an island.
    pub engine_body_frames: u64,
    pub island_body_frames: u64,
    /// Coupled mode: frames solved again because a body the engine moved fractured.
    pub redone_frames: u64,
}

/// The external engine. A clone of the world is detached from it (the cell clones
/// empty): world snapshots hold everything but the engine, which keeps its own.
struct EngineCell(Option<Box<dyn RigidEngine>>);

impl Clone for EngineCell {
    fn clone(&self) -> EngineCell {
        EngineCell(None)
    }
}

impl std::ops::Deref for EngineCell {
    type Target = dyn RigidEngine;
    fn deref(&self) -> &(dyn RigidEngine + 'static) {
        self.0.as_deref().expect("a world snapshot has no engine")
    }
}

impl std::ops::DerefMut for EngineCell {
    fn deref_mut(&mut self) -> &mut (dyn RigidEngine + 'static) {
        self.0.as_deref_mut().expect("a world snapshot has no engine")
    }
}

/// State of the coupling to an external engine (see `engine.rs`).
#[derive(Clone)]
struct Coupling {
    engine: EngineCell,
    /// Engine contacts on driven clusters, as resting loads and impact pulses.
    filter: ContactLoadFilter,
    /// Engine motion of every body at the start and the end of the current frame.
    start: HashMap<BodyKey, BodyMotion>,
    end: HashMap<BodyKey, BodyMotion>,
}

/// Contact stiffness of two bodies pressed together along `dir`: their half-thicknesses
/// along `dir` in series over the smaller projected face, like a bond between them.
/// Chunks are rigid (all compliance lives in springs), so a softer contact would act
/// as a cushion and cut the stress wave it transmits.
fn contact_stiffness(a: &Material, box_a: &OBox, b: &Material, box_b: &OBox, dir: Vec3, scale: f64) -> f64 {
    let e = |m: &Material| m.youngs_modulus * scale / (1.0 - m.poisson_ratio * m.poisson_ratio);
    let d = dir.normalized();
    let (ha, aa) = half_thickness_and_area(box_a, d);
    let (hb, ab) = half_thickness_and_area(box_b, d);
    aa.min(ab) / (ha / e(a) + hb / e(b))
}

/// Half-thickness of a box along a unit direction and its area projected on the
/// plane perpendicular to it.
fn half_thickness_and_area(b: &OBox, d: Vec3) -> (f64, f64) {
    let mut h = 0.0;
    let mut area = 0.0;
    for k in 0..3 {
        let c = d.dot(b.rotation.col(k)).abs();
        h += c * b.half[k];
        area += c * 4.0 * b.half[(k + 1) % 3] * b.half[(k + 2) % 3];
    }
    (h, area)
}

/// A box's half-thickness along the unit direction `n` for the elastic layer, and its
/// rate of change as the box turns (`dh = g . dtheta`): `sqrt(sum_k (n . e_k)^2 half_k^2)`.
/// Along an axis it is that half-extent (the joint's `L / 2`), and it is smooth in the
/// orientation, unlike the support function `sum_k |n . e_k| half_k`, whose kink at
/// alignment would make the torque of a face-to-face contact jump as it passes through
/// alignment.
fn layer_thickness(b: &OBox, n: Vec3) -> (f64, Vec3) {
    let (mut h2, mut g) = (0.0, Vec3::ZERO);
    for k in 0..3 {
        let axis = b.rotation.col(k);
        let (c, w2) = (axis.dot(n), b.half[k] * b.half[k]);
        h2 += c * c * w2;
        g += axis.cross(n) * (c * w2);
    }
    let h = h2.sqrt();
    (h, if h > 0.0 { g / h } else { Vec3::ZERO })
}

fn damping_ratio(restitution: f64) -> f64 {
    let l = restitution.max(1e-6).ln();
    -l / (std::f64::consts::PI.powi(2) + l * l).sqrt()
}

impl World {
    pub fn new(scene: &Scene) -> World {
        let solver = ReferenceSolver::new(scene);
        let impactors = scene
            .impactors
            .iter()
            .map(|d| {
                let inertia = match d.shape {
                    ImpactorShape::Sphere { radius } => Mat3::IDENTITY * (0.4 * d.mass * radius * radius),
                    ImpactorShape::Box { half_extents } => {
                        let (a, b, c) = (2.0 * half_extents[0], 2.0 * half_extents[1], 2.0 * half_extents[2]);
                        Mat3::diag(Vec3::new(b * b + c * c, a * a + c * c, a * a + b * b) * (d.mass / 12.0))
                    }
                };
                Impactor {
                    name: d.name.clone(),
                    shape: d.shape.clone(),
                    mass: d.mass,
                    inertia,
                    pose: Pose::new(Vec3::from_array(d.position), Quat::from_wxyz(d.orientation)),
                    velocity: Vec3::from_array(d.velocity),
                    angular_velocity: Vec3::from_array(d.angular_velocity),
                    material: scene.material(&d.material).clone(),
                    crush: d.crush.map(|c| (c.max_force, c.energy)),
                    crush_used: 0.0,
                    crush_depth: 0.0,
                    driven: false,
                }
            })
            .collect();
        let loads = ChunkLoads::new(&solver);
        let initial_positions = solver
            .structures
            .iter()
            .map(|s| {
                let pose = Pose::new(s.initial_position, s.initial_rotation);
                s.chunks.iter().map(|c| pose.transform_point(c.center)).collect()
            })
            .collect();
        let contact_hits = solver.structures.iter().map(|s| vec![0.0; s.chunks.len()]).collect();
        let mut w = World {
            frame_loads: loads.clone(),
            implicit_loads: loads.clone(),
            implicit_elapsed: 0.0,
            loads,
            impactors,
            contact: ContactLedger::default(),
            frame: 0,
            events_done: vec![false; scene.events.len()],
            probes: vec![ProbeAcc::default(); scene.probes.len()],
            next_sample: 0.0,
            sample_interval: scene.sim.sample_interval.unwrap_or(scene.sim.frame_dt),
            initial_positions,
            exposure: Vec::new(),
            exposure_version: u64::MAX,
            topology_version: 0,
            blast_caches: vec![None; scene.loads.len()],
            contact_dt: f64::INFINITY,
            added_mass_fraction: 0.0,
            static_unconverged_frames: 0,
            implicit_report: Default::default(),
            implicit_worst_residual: 0.0,
            contact_hits,
            pair_offsets: Default::default(),
            sticks: Default::default(),
            applied: Vec::new(),
            coupling: None,
            island_frames: 0,
            max_island_bodies: 0,
            engine_body_frames: 0,
            island_body_frames: 0,
            redone_frames: 0,
            scene: scene.clone(),
            solver,
        };
        if let Some(target) = scene.sim.mass_scaling_dt {
            w.added_mass_fraction = w.solver.apply_mass_scaling(target);
        }
        w.contact_dt = w.contact_stable_dt();
        w.prestress();
        w.solver.mark_implicit_step_start();
        w.record_probes(true);
        w
    }

    /// Settle supported structures under gravity and the scripted loads at t = 0.
    fn prestress(&mut self) {
        if !self.scene.sim.gravity_prestress {
            return;
        }
        self.loads.clear();
        self.apply_scripted_loads(0.0);
        let opts = StaticOptions::default();
        for ci in 0..self.solver.clusters.len() {
            if self.solver.clusters[ci].anchored && !self.solver.clusters[ci].bonds.is_empty() {
                let r = self.solver.equilibrate(ci, &self.loads, &opts);
                assert!(r.converged, "prestress did not converge (residual {:.3e})", r.residual);
                if self.scene.sim.solve_mode != SolveMode::Explicit {
                    self.solver.clusters[ci].activity = Activity::Settled;
                    self.solver.clusters[ci].settled_load_norm = self.cluster_load_norm(ci);
                }
            }
        }
    }

    // ------------------------------------------------------------------ geometry

    fn chunk_box(&self, s: usize, c: usize) -> OBox {
        let ch = &self.solver.structures[s].chunks[c];
        let st = &self.solver.chunks[s][c];
        let cl = &self.solver.clusters[st.cluster];
        // The hidden rotation turns the box too: contact torques do work on it, so the
        // geometry must follow it for the penalty force to stay conservative.
        let hidden = Quat::from_axis_angle(st.th, st.th.norm()).to_mat3();
        OBox { center: self.solver.chunk_position(s, c), rotation: cl.rotation() * hidden * ch.rotation, half: ch.half_extents, hull: ch.hull.clone() }
    }

    /// `chunk_box`, built once per substep and kept in `cache` (indexed like the active list).
    fn cached_box<'a>(&self, cache: &'a mut [Option<OBox>], k: usize, s: usize, c: usize) -> &'a OBox {
        cache[k].get_or_insert_with(|| self.chunk_box(s, c))
    }

    fn chunk_material(&self, s: usize, c: usize) -> &Material {
        self.scene.material(&self.solver.structures[s].chunks[c].material)
    }

    /// Stable substep for the penalty contacts (stiffest contact on the lightest body).
    fn contact_stable_dt(&self) -> f64 {
        let scale = self.scene.sim.stiffness_scale;
        let stiffest = self.scene.materials.values().max_by(|a, b| a.youngs_modulus.total_cmp(&b.youngs_modulus));
        let Some(stiffest) = stiffest else { return f64::INFINITY };
        let mut w2: f64 = 0.0;
        for (s, st) in self.solver.structures.iter().enumerate() {
            for (c, ch) in st.chunks.iter().enumerate() {
                let b = OBox { center: Vec3::ZERO, rotation: ch.rotation, half: ch.half_extents, hull: ch.hull.clone() };
                let k = (0..3)
                    .map(|axis| contact_stiffness(self.chunk_material(s, c), &b, stiffest, &b, ch.rotation.col(axis), scale))
                    .fold(0.0, f64::max);
                // A face pair engages ~10 sample points of k/10 each (total k); a chunk
                // buried in rubble can touch on all six faces. Contact loads drive the
                // chunk's deformation inertia (scaled under mass scaling).
                w2 = w2.max(6.0 * k / (ch.mass * self.solver.chunks[s][c].inertia_scale));
            }
        }
        for imp in &self.impactors {
            let b = imp.obox();
            let k = (0..3).map(|axis| contact_stiffness(&imp.material, &b, stiffest, &b, b.rotation.col(axis), scale)).fold(0.0, f64::max);
            w2 = w2.max(k / imp.mass);
        }
        if w2 <= 0.0 {
            f64::INFINITY
        } else if self.scene.sim.methods.layer_contact {
            // The contact dashpots are not capped: the step resolves the damped
            // oscillator, `(2 / w) (sqrt(1 + z^2) - z)`, as for the bonds.
            let z = damping_ratio(self.scene.sim.contact_restitution);
            2.0 / w2.sqrt() * ((1.0 + z * z).sqrt() - z) * self.scene.sim.courant_safety
        } else {
            2.0 / w2.sqrt() * self.scene.sim.courant_safety
        }
    }

    /// Contact substep for the coming frame (`sim.methods.frame_contact_step`, with the
    /// elastic-layer contact): a Gershgorin bound over the contacts that can engage
    /// within the frame, from bounding spheres swept by the bodies' speeds (translation
    /// plus rotation at the bounding radius) and gravity over the frame. Each contact
    /// adds to both bodies' rows its normal and two tangential layer stiffnesses at the
    /// largest cross-section either body has (`k'' A`), acting through lever arms up to
    /// the bounding radius; torsion adds `k''_t A R^2`. Infinite when nothing can touch.
    /// A pair that splits within the frame needs nothing here: its contact has the
    /// stiffness of the joint it replaces, already in the stress bound.
    fn frame_contact_dt(&self) -> f64 {
        let scale = self.scene.sim.stiffness_scale;
        let fdt = self.scene.sim.frame_dt;
        let fall = Vec3::from_array(self.scene.gravity).norm() * fdt * fdt;
        let e = |m: &Material| m.youngs_modulus * scale / (1.0 - m.poisson_ratio * m.poisson_ratio);
        let g = |m: &Material| m.shear_modulus() * scale;
        // A body as the bound sees it.
        #[derive(Clone, Copy)]
        struct B {
            center: Vec3,
            radius: f64,
            speed: f64,
            /// sqrt(3) (1/sqrt(m) + R/sqrt(I_min)): the L1 norm of a contact row scaled by
            /// the inverse square roots of the inertias, at most.
            beta: f64,
            rot: f64,
            h: f64,
            area: f64,
            e: f64,
            g: f64,
        }
        let row = |m: f64, i: f64, r: f64| (3f64.sqrt() * (1.0 / m.sqrt() + r / i.sqrt()), 3f64.sqrt() / i.sqrt());
        let mut bodies: Vec<B> = Vec::new();
        let mut chunk_of: Vec<(usize, usize, usize)> = Vec::new(); // (body index, structure, chunk)
        for (si, st) in self.solver.structures.iter().enumerate() {
            for (ci, ch) in st.chunks.iter().enumerate() {
                if !self.solver.chunks[si][ci].active {
                    continue;
                }
                let mu = self.solver.chunks[si][ci].inertia_scale;
                let (v, w) = self.solver.chunk_velocity(si, ci);
                let r = ch.half_extents.norm();
                let h = ch.half_extents;
                let area = match &ch.hull {
                    Some(hull) => 0.5 * hull.faces.iter().map(|f| f.area).sum::<f64>(),
                    None => 4.0 * ((h.x * h.y).powi(2) + (h.y * h.z).powi(2) + (h.z * h.x).powi(2)).sqrt(),
                };
                let mat = self.chunk_material(si, ci);
                let (beta, rot) = row(ch.mass * mu, crate::solver::smallest_principal_moment(&ch.inertia) * mu, r);
                chunk_of.push((bodies.len(), si, ci));
                bodies.push(B { center: self.solver.chunk_position(si, ci), radius: r, speed: v.norm() + w.norm() * r, beta, rot, h: h.min_elem(), area, e: e(mat), g: g(mat) });
            }
        }
        let first_impactor = bodies.len();
        for imp in &self.impactors {
            let (r, h, area) = match imp.shape {
                ImpactorShape::Sphere { radius } => (radius, radius, std::f64::consts::PI * radius * radius),
                ImpactorShape::Box { half_extents } => {
                    let h = Vec3::from_array(half_extents);
                    (h.norm(), h.min_elem(), 4.0 * ((h.x * h.y).powi(2) + (h.y * h.z).powi(2) + (h.z * h.x).powi(2)).sqrt())
                }
            };
            let (beta, rot) = row(imp.mass, crate::solver::smallest_principal_moment(&imp.inertia), r);
            bodies.push(B { center: imp.pose.position, radius: r, speed: imp.velocity.norm() + imp.angular_velocity.norm() * r, beta, rot, h, area, e: e(&imp.material), g: g(&imp.material) });
        }
        let mut w2 = vec![0.0f64; bodies.len()];
        // One contact between bodies a and b (b = None: the ground, which has no rows).
        let add = |w2: &mut Vec<f64>, a: usize, b: Option<usize>, ground: Option<(f64, f64)>| {
            let ba = bodies[a];
            let (bb_beta, bb_rot, h_b, e_b, g_b, area_b) = match b {
                Some(j) => (bodies[j].beta, bodies[j].rot, bodies[j].h, bodies[j].e, bodies[j].g, bodies[j].area),
                None => {
                    let (ge, gg) = ground.expect("ground moduli");
                    (0.0, 0.0, ba.h, ge, gg, f64::INFINITY)
                }
            };
            let area = ba.area.min(area_b);
            let k_n = area / (ba.h / ba.e + h_b / e_b);
            let k_t = area / (ba.h / ba.g + h_b / g_b);
            let radius = b.map_or(ba.radius, |j| ba.radius.max(bodies[j].radius));
            let lin = k_n + 2.0 * k_t;
            let tor = k_t * radius * radius;
            w2[a] += lin * ba.beta * (ba.beta + bb_beta) + tor * ba.rot * (ba.rot + bb_rot);
            if let Some(j) = b {
                w2[j] += lin * bodies[j].beta * (ba.beta + bodies[j].beta) + tor * bodies[j].rot * (ba.rot + bodies[j].rot);
            }
        };
        let near = |a: &B, b: &B| (a.center - b.center).norm() <= a.radius + b.radius + (a.speed + b.speed) * fdt + fall;
        // Ground.
        if let Some(gd) = &self.scene.ground {
            let gm = self.scene.material(&gd.material);
            let moduli = (e(gm), g(gm));
            for &(k, si, ci) in &chunk_of {
                let cl = &self.solver.clusters[self.solver.chunks[si][ci].cluster];
                let b = bodies[k];
                if !cl.anchored && !cl.driven && b.center.z - b.radius - b.speed * fdt - fall <= gd.height {
                    add(&mut w2, k, None, Some(moduli));
                }
            }
            for k in first_impactor..bodies.len() {
                let b = bodies[k];
                if b.center.z - b.radius - b.speed * fdt - fall <= gd.height {
                    add(&mut w2, k, None, Some(moduli));
                }
            }
        }
        // Impactors against chunks.
        for k in first_impactor..bodies.len() {
            for &(j, si, ci) in &chunk_of {
                if !self.solver.clusters[self.solver.chunks[si][ci].cluster].driven && near(&bodies[k], &bodies[j]) {
                    add(&mut w2, j, Some(k), None);
                }
            }
        }
        // Chunks of different clusters.
        for (x, &(ka, sa, ca)) in chunk_of.iter().enumerate() {
            let cla = self.solver.chunks[sa][ca].cluster;
            for &(kb, sb, cb) in &chunk_of[x + 1..] {
                let clb = self.solver.chunks[sb][cb].cluster;
                if cla == clb {
                    continue;
                }
                let (a, b) = (&self.solver.clusters[cla], &self.solver.clusters[clb]);
                if (a.anchored && b.anchored) || a.driven || b.driven || !near(&bodies[ka], &bodies[kb]) {
                    continue;
                }
                add(&mut w2, ka, Some(kb), None);
            }
        }
        let w2_max = w2.iter().copied().fold(0.0, f64::max);
        if w2_max <= 0.0 {
            return f64::INFINITY;
        }
        let z = damping_ratio(self.scene.sim.contact_restitution);
        2.0 / w2_max.sqrt() * ((1.0 + z * z).sqrt() - z) * self.scene.sim.courant_safety
    }

    fn pair_friction(&self, a: &Material, b: &Material) -> f64 {
        self.scene.sim.contact_friction.unwrap_or(a.friction.min(b.friction))
    }

    /// The substep used for the next frame.
    /// Profiling: which limit set this frame's substep (stress, contact, frame or
    /// `max_substep`), recomputed outside the timed stages.
    fn count_step_limit(&self) {
        use crate::profile::{count, Counter};
        let stress = if self.scene.sim.solve_mode == SolveMode::Implicit {
            self.scene.sim.implicit_dt.unwrap_or(f64::INFINITY)
        } else {
            self.solver.stable_dt()
        };
        let candidates = [
            (stress, Counter::StepByStress),
            (self.contact_dt, Counter::StepByContact),
            (self.scene.sim.frame_dt, Counter::StepByFrame),
            (self.scene.sim.max_substep.unwrap_or(f64::INFINITY), Counter::StepByMaxSubstep),
        ];
        let binding = candidates.iter().min_by(|a, b| a.0.total_cmp(&b.0)).expect("four limits");
        count(binding.1, 1);
    }

    pub fn substep_dt(&self) -> f64 {
        // The implicit stress step is unconditionally stable: only contacts limit the substep.
        let stress_dt = if self.scene.sim.solve_mode == SolveMode::Implicit {
            self.scene.sim.implicit_dt.unwrap_or(f64::INFINITY)
        } else {
            self.solver.stable_dt()
        };
        // A chunk with bonds and contacts feels both stiffnesses: with the unit-consistent
        // bound the two limits combine as `1/dt^2 = 1/dt_stress^2 + 1/dt_contact^2`
        // (exact for undamped oscillators sharing a mass); else the smaller is taken.
        let combined = if self.scene.sim.methods.scaled_step_bound {
            1.0 / (stress_dt.powi(-2) + self.contact_dt.powi(-2)).sqrt()
        } else {
            stress_dt.min(self.contact_dt)
        };
        let mut dt = combined.min(self.scene.sim.frame_dt);
        if let Some(m) = self.scene.sim.max_substep {
            dt = dt.min(m);
        }
        let n = (self.scene.sim.frame_dt / dt).ceil().max(1.0);
        self.scene.sim.frame_dt / n
    }

    // ------------------------------------------------------------------ exposure

    fn refresh_exposure(&mut self) {
        if self.exposure_version == self.topology_version {
            return;
        }
        self.exposure = self
            .solver
            .structures
            .iter()
            .enumerate()
            .map(|(s, st)| {
                let mut e: Vec<Vec<f64>> = st.chunks.iter().map(|c| c.faces.iter().map(|f| f.area).collect()).collect();
                for b in self.solver.bonds[s].iter().filter(|b| b.alive) {
                    let sb = &st.bonds[b.source];
                    let (a, bb) = (b.geometry.a, b.geometry.b);
                    // Re-attached bonds keep their static faces' orientation.
                    let fa = face_towards(&st.chunks[a].faces, b.geometry.normal).unwrap_or(sb.face_a);
                    let fb = face_towards(&st.chunks[bb].faces, -b.geometry.normal).unwrap_or(sb.face_b);
                    e[a][fa] -= b.geometry.area;
                    e[bb][fb] -= b.geometry.area;
                }
                for (c, row) in e.iter_mut().enumerate() {
                    if !self.solver.chunks[s][c].active {
                        row.iter_mut().for_each(|v| *v = 0.0);
                    }
                    for v in row.iter_mut() {
                        *v = v.max(0.0);
                    }
                }
                e
            })
            .collect();
        self.exposure_version = self.topology_version;
    }

    /// World centre and outward normal of a chunk face.
    fn face_world(&self, s: usize, c: usize, f: usize) -> (Vec3, Vec3) {
        let ch = &self.solver.structures[s].chunks[c];
        let cl = &self.solver.clusters[self.solver.chunks[s][c].cluster];
        let face = ch.faces[f];
        (cl.pose.transform_point(ch.center + self.solver.chunks[s][c].u + face.offset), cl.pose.transform_vector(face.normal))
    }

    /// Distance from each exposed face to the nearest free edge of its reflecting surface.
    fn clearing_distances(&self, s: usize) -> std::collections::HashMap<(usize, usize), f64> {
        let st = &self.solver.structures[s];
        let exposed = |c: usize, f: usize| self.exposure[s][c][f] > 0.5 * st.chunks[c].faces[f].area;
        // Per exposed face (chunk, face): its in-plane exposed neighbours and their distance.
        type Face = (usize, usize);
        let mut neighbours: std::collections::HashMap<Face, Vec<(Face, f64)>> = Default::default();
        for (c, ch) in st.chunks.iter().enumerate() {
            if !self.solver.chunks[s][c].active {
                continue;
            }
            for f in 0..ch.faces.len() {
                if !exposed(c, f) {
                    continue;
                }
                let n = ch.faces[f].normal;
                let mut list = Vec::new();
                for &bi in &self.solver.chunk_bonds[s][c] {
                    let b = &self.solver.bonds[s][bi];
                    if b.geometry.normal.dot(n).abs() > 0.1 {
                        continue;
                    }
                    let o = if b.geometry.a == c { b.geometry.b } else { b.geometry.a };
                    if let Some(of) = face_towards(&st.chunks[o].faces, n) {
                        if st.chunks[o].faces[of].normal.dot(n) > 0.99 && exposed(o, of) {
                            let d = (st.chunks[o].center + st.chunks[o].faces[of].offset - ch.center - ch.faces[f].offset).norm();
                            list.push(((o, of), d));
                        }
                    }
                }
                neighbours.insert((c, f), list);
            }
        }
        // Multi-source Dijkstra from edge faces (fewer than four in-plane neighbours).
        let mut dist: std::collections::HashMap<(usize, usize), f64> = Default::default();
        let mut heap = std::collections::BinaryHeap::new();
        for (k, list) in &neighbours {
            if list.len() < 4 {
                let half = 0.5 * st.chunks[k.0].faces[k.1].area.sqrt();
                dist.insert(*k, half);
                heap.push(std::cmp::Reverse((OrdF64(half), *k)));
            }
        }
        while let Some(std::cmp::Reverse((OrdF64(d), k))) = heap.pop() {
            if dist.get(&k).is_some_and(|&x| x < d) {
                continue;
            }
            for &(o, w) in &neighbours[&k] {
                let nd = d + w;
                if dist.get(&o).is_none_or(|&x| nd < x) {
                    dist.insert(o, nd);
                    heap.push(std::cmp::Reverse((OrdF64(nd), o)));
                }
            }
        }
        dist
    }

    fn rebuild_blast(&mut self, li: usize, position: Vec3, tnt: f64, time: f64) {
        self.refresh_exposure();
        let mut boxes = Vec::new();
        for (s, st) in self.solver.structures.iter().enumerate() {
            for c in 0..st.chunks.len() {
                if self.solver.chunks[s][c].active {
                    boxes.push((s, c, self.chunk_box(s, c)));
                }
            }
        }
        let mut faces = Vec::new();
        for s in 0..self.solver.structures.len() {
            let clearing = self.clearing_distances(s);
            for c in 0..self.solver.structures[s].chunks.len() {
                if !self.solver.chunks[s][c].active {
                    continue;
                }
                for f in 0..self.exposure[s][c].len() {
                    let area = self.exposure[s][c][f];
                    if area <= 0.0 {
                        continue;
                    }
                    let (x, n) = self.face_world(s, c, f);
                    let to_charge = position - x;
                    let r = to_charge.norm().max(1e-6);
                    let cos_theta = n.dot(to_charge) / r;
                    let start = x + n * 1e-6;
                    let features = &self.scene.sim.features;
                    let shadowed = features.blast_shadowing
                        && cos_theta > 0.0
                        && boxes.iter().any(|(bs, bc, b)| (*bs, *bc) != (s, c) && b.segment_hit(start, position).is_some());
                    // Without clearing the reflected pressure acts for the whole pulse.
                    let s_clear = if features.blast_clearing { clearing.get(&(c, f)).copied().unwrap_or(0.0) } else { f64::INFINITY };
                    faces.push((s, c, f, area, FaceBlast::new(tnt, time, r, cos_theta, shadowed, s_clear)));
                }
            }
        }
        self.blast_caches[li] = Some(BlastCache { version: self.topology_version, faces });
    }

    // ------------------------------------------------------------------ loads

    fn apply_scripted_loads(&mut self, t: f64) {
        for li in 0..self.scene.loads.len() {
            match self.scene.loads[li].clone() {
                LoadDesc::PointForce { body, chunk, direction, magnitude, point } => {
                    let s = self.solver.structure_index(&body).unwrap();
                    if !self.solver.chunks[s][chunk].active {
                        continue;
                    }
                    let f = Vec3::from_array(direction).normalized() * magnitude.eval(t);
                    let center = self.solver.chunk_position(s, chunk);
                    let at = match point {
                        Some(p) => {
                            let cl = &self.solver.clusters[self.solver.chunks[s][chunk].cluster];
                            cl.pose.transform_point(Vec3::from_array(p) + self.solver.chunks[s][chunk].u)
                        }
                        None => center,
                    };
                    self.loads.add_at(s, chunk, f, at, center);
                }
                LoadDesc::Pressure { body, chunks, face_normal, pressure } => {
                    let p = pressure.eval(t);
                    if p == 0.0 {
                        continue;
                    }
                    self.refresh_exposure();
                    let s = self.solver.structure_index(&body).unwrap();
                    let n = Vec3::from_array(face_normal).normalized();
                    let selected = chunks.select(&self.scene.bodies[s]);
                    for c in selected {
                        if !self.solver.chunks[s][c].active {
                            continue;
                        }
                        for f in 0..self.exposure[s][c].len() {
                            let area = self.exposure[s][c][f];
                            if area <= 0.0 || self.solver.structures[s].chunks[c].faces[f].normal.dot(n) < 0.99 {
                                continue;
                            }
                            let (x, nw) = self.face_world(s, c, f);
                            let center = self.solver.chunk_position(s, c);
                            self.loads.add_at(s, c, nw * (-p * area), x, center);
                        }
                    }
                }
                LoadDesc::Blast { position, tnt_mass, time } => {
                    if t < time {
                        continue;
                    }
                    let stale = self.blast_caches[li].as_ref().is_none_or(|b| b.version != self.topology_version);
                    if stale {
                        self.rebuild_blast(li, Vec3::from_array(position), tnt_mass, time);
                    }
                    let faces = self.blast_caches[li].as_ref().unwrap().faces.clone();
                    for (s, c, f, area, fb) in faces {
                        if !self.solver.chunks[s][c].active {
                            continue;
                        }
                        let p = fb.pressure(t);
                        if p == 0.0 {
                            continue;
                        }
                        let (x, nw) = self.face_world(s, c, f);
                        let center = self.solver.chunk_position(s, c);
                        self.loads.add_at(s, c, nw * (-p * area), x, center);
                    }
                }
            }
        }
    }

    /// Penalty contact force between a chunk and another body at one contact point
    /// (`normal` pushes the chunk; returns the force on the chunk), with its energy
    /// booked in the contact ledger.
    #[allow(clippy::too_many_arguments)]
    fn contact_force(
        &mut self,
        k: f64,
        m_red: f64,
        restitution: f64,
        friction: f64,
        depth: f64,
        normal: Vec3,
        rel_velocity: Vec3,
        dt: f64,
        points: usize,
    ) -> Vec3 {
        let (f, stored, dissipated) = penalty_force(k, m_red, restitution, friction, depth, normal, rel_velocity, dt, points);
        self.contact.stored += stored;
        self.contact.dissipated += dissipated;
        f
    }

    fn apply_contacts(&mut self, dt: f64) -> Vec<(Vec3, Vec3)> {
        let scale = self.scene.sim.stiffness_scale;
        let mut imp_loads = vec![(Vec3::ZERO, Vec3::ZERO); self.impactors.len()];
        self.contact.stored = 0.0;
        self.contact_hits.iter_mut().flatten().for_each(|h| *h = 0.0);
        if self.scene.sim.methods.layer_contact {
            return self.apply_layer_contacts(dt);
        }
        let active: Vec<(usize, usize)> = (0..self.solver.structures.len())
            .flat_map(|s| (0..self.solver.structures[s].chunks.len()).map(move |c| (s, c)))
            .filter(|&(s, c)| self.solver.chunks[s][c].active)
            .collect();
        // Bounding spheres for every active chunk; the oriented box only for candidates
        // (building it is the costly part, and most chunks touch nothing).
        let bounds: Vec<(Vec3, f64)> = active
            .iter()
            .map(|&(s, c)| (self.solver.chunk_position(s, c), self.solver.structures[s].chunks[c].half_extents.norm()))
            .collect();
        let mut boxes: Vec<Option<OBox>> = vec![None; active.len()];

        let t_imp = crate::profile::time(crate::profile::Stage::ContactImpactors);
        // Impactors against chunks, with the crush cap applied to the impactor's total force.
        // Only bodies in an impact island take contact here (all of them in the
        // standalone world); an external engine handles the others.
        let in_island = |solver: &ReferenceSolver, s: usize, c: usize| !solver.clusters[solver.chunks[s][c].cluster].driven;
        for ii in 0..self.impactors.len() {
            if self.impactors[ii].driven {
                continue;
            }
            let imp = self.impactors[ii].clone();
            let ib = imp.obox();
            let reach = ib.bounding_radius();
            let mut contacts = Vec::new();
            for (k, &(s, c)) in active.iter().enumerate() {
                let (center, radius) = bounds[k];
                if (center - ib.center).norm() > reach + radius || !in_island(&self.solver, s, c) {
                    continue;
                }
                let b = self.cached_box(&mut boxes, k, s, c);
                let kc = contact_stiffness(&imp.material, &ib, self.chunk_material(s, c), b, b.center - ib.center, scale);
                match imp.shape {
                    ImpactorShape::Sphere { radius } => {
                        if let Some(cp) = b.sphere_contact(imp.pose.position, radius - imp.crush_depth) {
                            // Normal from chunk to impactor: the chunk is pushed along -normal.
                            contacts.push((s, c, kc, cp.point, -cp.normal, cp.depth, 1));
                        }
                    }
                    ImpactorShape::Box { .. } => {
                        let shrunk = OBox { half: ib.half - Vec3::splat(imp.crush_depth).component_min(ib.half * 0.5), ..ib.clone() };
                        let mut points: Vec<(Vec3, Vec3, f64)> = b.points_inside(&shrunk).into_iter().map(|cp| (cp.point, cp.normal, cp.depth)).collect();
                        points.extend(shrunk.points_inside(b).into_iter().map(|cp| (cp.point, -cp.normal, cp.depth)));
                        let n = points.len();
                        for (p, normal, depth) in points {
                            contacts.push((s, c, kc / n.max(FACE_PAIR_POINTS) as f64, p, normal, depth, n));
                        }
                    }
                }
            }
            if contacts.is_empty() {
                continue;
            }
            // Crush cap: limit the total elastic contact force; the excess crushes the impactor.
            let mut crush_factor = 1.0;
            if let Some((max_force, energy)) = imp.crush {
                let total: f64 = contacts.iter().map(|c| c.2 * c.5).sum();
                if imp.crush_used < energy && total > max_force {
                    let ksum: f64 = contacts.iter().map(|c| c.2).sum();
                    let extra = (total - max_force) / ksum;
                    self.impactors[ii].crush_depth += extra;
                    self.impactors[ii].crush_used += max_force * extra;
                    self.contact.crush += max_force * extra;
                    self.contact.dissipated += max_force * extra;
                    crush_factor = max_force / total;
                }
            }
            for (s, c, kc, point, normal, depth, points) in contacts {
                let m = self.solver.structures[s].chunks[c].mass;
                let m_red = m * imp.mass / (m + imp.mass);
                let v_chunk = self.solver.point_velocity(s, c, point);
                let v_imp = imp.velocity + imp.angular_velocity.cross(point - imp.pose.position);
                let f = self.contact_force(
                    kc,
                    m_red,
                    self.scene.sim.contact_restitution,
                    self.pair_friction(&imp.material, self.chunk_material(s, c)),
                    depth * crush_factor,
                    normal,
                    v_chunk - v_imp,
                    dt,
                    points,
                );
                let center = self.solver.chunk_position(s, c);
                self.loads.add_at(s, c, f, point, center);
                self.contact_hits[s][c] += f.norm();
                imp_loads[ii].0 -= f;
                imp_loads[ii].1 -= (point - imp.pose.position).cross(f);
            }
        }

        drop(t_imp);
        let t_ground = crate::profile::time(crate::profile::Stage::ContactGround);
        // Ground.
        if let Some(g) = self.scene.ground.clone() {
            let gm = self.scene.material(&g.material).clone();
            for (k, &(s, c)) in active.iter().enumerate() {
                let (center, radius) = bounds[k];
                if center.z - radius > g.height {
                    continue;
                }
                let cl = &self.solver.clusters[self.solver.chunks[s][c].cluster];
                if cl.anchored || cl.driven {
                    continue;
                }
                let b = self.cached_box(&mut boxes, k, s, c);
                // A face resting flat engages 5 points (4 corners and its centre).
                let kc = contact_stiffness(&gm, b, self.chunk_material(s, c), b, Vec3::Z, scale);
                let m = self.solver.structures[s].chunks[c].mass;
                let below: Vec<Vec3> = b.sample_points().into_iter().filter(|p| p.z < g.height).collect();
                let n = below.len();
                for p in below {
                    let depth = g.height - p.z;
                    let v = self.solver.point_velocity(s, c, p);
                    let mu = self.scene.sim.contact_friction.unwrap_or(g.friction);
                    let f = self.contact_force(kc / n.max(5) as f64, m, self.scene.sim.contact_restitution, mu, depth, Vec3::Z, v, dt, n);
                    let center = self.solver.chunk_position(s, c);
                    self.loads.add_at(s, c, f, p, center);
                }
            }
            for ii in 0..self.impactors.len() {
                if self.impactors[ii].driven {
                    continue;
                }
                let imp = self.impactors[ii].clone();
                let ib = imp.obox();
                let kc = contact_stiffness(&gm, &ib, &imp.material, &ib, Vec3::Z, scale);
                let pts: Vec<Vec3> = match imp.shape {
                    ImpactorShape::Sphere { radius } => vec![imp.pose.position - Vec3::Z * radius],
                    ImpactorShape::Box { .. } => imp.obox().sample_points().to_vec(),
                };
                let kp = kc / pts.len().min(5) as f64;
                let n = pts.iter().filter(|p| p.z < g.height).count();
                for p in pts {
                    let depth = g.height - p.z;
                    if depth <= 0.0 {
                        continue;
                    }
                    let v = imp.velocity + imp.angular_velocity.cross(p - imp.pose.position);
                    let mu = self.scene.sim.contact_friction.unwrap_or(g.friction);
                    let f = self.contact_force(kp, imp.mass, self.scene.sim.contact_restitution, mu, depth, Vec3::Z, v, dt, n);
                    imp_loads[ii].0 += f;
                    imp_loads[ii].1 += (p - imp.pose.position).cross(f);
                }
            }
        }

        drop(t_ground);
        // Chunks of different clusters (debris on structures, fragments on fragments).
        let t_broad = crate::profile::time(crate::profile::Stage::ContactBroadphase);
        let n_clusters = self.solver.clusters.len();
        // Overlap offsets of the pairs in contact last substep; a pair that is not in
        // contact this substep forgets its offsets.
        let mut previous = std::mem::take(&mut self.pair_offsets);
        if n_clusters > 1 {
            let mut cluster_boxes: Vec<(Vec3, Vec3)> = vec![(Vec3::splat(f64::INFINITY), Vec3::splat(f64::NEG_INFINITY)); n_clusters];
            for (k, &(s, c)) in active.iter().enumerate() {
                let ci = self.solver.chunks[s][c].cluster;
                let (center, radius) = bounds[k];
                let r = Vec3::splat(radius);
                cluster_boxes[ci].0 = cluster_boxes[ci].0.component_min(center - r);
                cluster_boxes[ci].1 = cluster_boxes[ci].1.component_max(center + r);
            }
            let mut candidates = Vec::new();
            let mut by_cluster: Vec<Vec<usize>> = vec![Vec::new(); n_clusters];
            for (k, &(s, c)) in active.iter().enumerate() {
                by_cluster[self.solver.chunks[s][c].cluster].push(k);
            }
            for ca in 0..n_clusters {
                for cb in ca + 1..n_clusters {
                    let (a0, a1) = cluster_boxes[ca];
                    let (b0, b1) = cluster_boxes[cb];
                    if (0..3).any(|i| a1[i] < b0[i] || b1[i] < a0[i]) {
                        continue;
                    }
                    if self.solver.clusters[ca].anchored && self.solver.clusters[cb].anchored {
                        continue;
                    }
                    if self.solver.clusters[ca].driven || self.solver.clusters[cb].driven {
                        continue;
                    }
                    for &ka in &by_cluster[ca] {
                        for &kb in &by_cluster[cb] {
                            let ((pa, ra), (pb, rb)) = (bounds[ka], bounds[kb]);
                            if (pa - pb).norm() > ra + rb {
                                continue;
                            }
                            let (sa, chunk_a) = active[ka];
                            let (sb, chunk_b) = active[kb];
                            self.cached_box(&mut boxes, ka, sa, chunk_a);
                            self.cached_box(&mut boxes, kb, sb, chunk_b);
                            let key = (sa, chunk_a, sb, chunk_b);
                            candidates.push((key, ka, kb, previous.remove(&key)));
                        }
                    }
                }
            }
            drop(t_broad);
            crate::profile::count(crate::profile::Counter::PairCandidates, candidates.len() as u64);
            let _t_pairs = crate::profile::time(crate::profile::Stage::ContactPairs);
            // Every pair's contact depends only on the state at the start of the substep:
            // evaluate them in parallel, apply them in pair order (bit-identical).
            let (solver, scene, boxes) = (&self.solver, &self.scene, &boxes);
            let outcomes = crate::par::map_into(candidates, |(key, ka, kb, offsets)| {
                let shape = |k: usize| boxes[k].as_ref().expect("cached above");
                pair_contact(solver, scene, key, offsets, shape(ka), shape(kb), dt)
            });
            for pc in outcomes.into_iter().flatten() {
                crate::profile::count(crate::profile::Counter::PairOverlaps, 1);
                let (sa, ca, sb, cb) = pc.key;
                self.pair_offsets.insert(pc.key, pc.offsets);
                for (p, f, stored, dissipated, work) in pc.points {
                    self.contact.stored += stored;
                    self.contact.dissipated += dissipated;
                    self.contact.pair_work += work;
                    self.loads.add_at(sa, ca, f, p, pc.centers.0);
                    self.loads.add_at(sb, cb, -f, p, pc.centers.1);
                    self.contact_hits[sa][ca] += f.norm();
                    self.contact_hits[sb][cb] += f.norm();
                }
            }
        }
        imp_loads
    }

    /// Elastic-layer contacts (`sim.methods.layer_contact`; see `polytope.rs`):
    /// impactors against chunks, chunks and impactors on the ground, and chunks of
    /// different clusters. Each contact is one overlap: its normal force `k'' V` acts at
    /// the overlap's centroid, with anchored stick-slip friction (`layer_force`).
    fn apply_layer_contacts(&mut self, dt: f64) -> Vec<(Vec3, Vec3)> {
        let scale = self.scene.sim.stiffness_scale;
        let restitution = self.scene.sim.contact_restitution;
        let mut imp_loads = vec![(Vec3::ZERO, Vec3::ZERO); self.impactors.len()];
        let mut previous = std::mem::take(&mut self.sticks);
        self.applied.clear();
        for k in &mut self.contact.kinds {
            k.stored = 0.0;
        }
        let active: Vec<(usize, usize)> = (0..self.solver.structures.len())
            .flat_map(|s| (0..self.solver.structures[s].chunks.len()).map(move |c| (s, c)))
            .filter(|&(s, c)| self.solver.chunks[s][c].active)
            .collect();
        let bounds: Vec<(Vec3, f64)> = active
            .iter()
            .map(|&(s, c)| (self.solver.chunk_position(s, c), self.solver.structures[s].chunks[c].half_extents.norm()))
            .collect();
        let mut boxes: Vec<Option<OBox>> = vec![None; active.len()];
        let in_island = |solver: &ReferenceSolver, s: usize, c: usize| !solver.clusters[solver.chunks[s][c].cluster].driven;

        let t_imp = crate::profile::time(crate::profile::Stage::ContactImpactors);
        // Impactors against chunks; the crush cap limits the impactor's total force.
        for ii in 0..self.impactors.len() {
            if self.impactors[ii].driven {
                continue;
            }
            let imp = self.impactors[ii].clone();
            let ib = imp.obox();
            let reach = ib.bounding_radius();
            // (chunk, the layer between them seen from the chunk)
            let mut contacts: Vec<(usize, usize, PairElastic)> = Vec::new();
            for (k, &(s, c)) in active.iter().enumerate() {
                let (center, radius) = bounds[k];
                if (center - ib.center).norm() > reach + radius || !in_island(&self.solver, s, c) {
                    continue;
                }
                let b = self.cached_box(&mut boxes, k, s, c).clone();
                let chunk_material = self.chunk_material(s, c);
                let pe = match imp.shape {
                    // The ball's overlap with the chunk, exact at faces, edges and corners
                    // (across neighbouring chunks the shares add up to the overlap with
                    // their union), in the chunk's nearest-face cells.
                    ImpactorShape::Sphere { radius } => ball_elastic(&b, chunk_material, imp.pose.position, radius - imp.crush_depth, &imp.material, scale),
                    ImpactorShape::Box { .. } => {
                        let shrunk = OBox { half: ib.half - Vec3::splat(imp.crush_depth).component_min(ib.half * 0.5), ..ib.clone() };
                        if !b.may_overlap(&shrunk) {
                            continue;
                        }
                        pair_elastic(&b, &shrunk, chunk_material, &imp.material, scale, 0.0)
                    }
                };
                if let Some(pe) = pe.filter(|p| p.contact.is_some()) {
                    contacts.push((s, c, pe));
                }
            }
            if contacts.is_empty() {
                continue;
            }
            let mut elastic_scale = 1.0;
            if let Some((max_force, energy)) = imp.crush {
                let total: f64 = contacts.iter().map(|c| c.2.elastic.force).sum();
                if imp.crush_used < energy && total > max_force {
                    let stiffness: f64 = contacts.iter().map(|c| c.2.k_n * c.2.contact.as_ref().map_or(0.0, |l| l.area)).sum();
                    let extra = (total - max_force) / stiffness;
                    self.impactors[ii].crush_depth += extra;
                    self.impactors[ii].crush_used += max_force * extra;
                    self.contact.crush += max_force * extra;
                    self.contact.modelled += max_force * extra;
                    self.contact.kinds[KIND_IMPACTOR].modelled += max_force * extra;
                    elastic_scale = max_force / total;
                }
            }
            let ri = imp.pose.rotation.to_mat3();
            let imp_inertia = ri * imp.inertia * ri.transpose();
            for (s, c, pe) in contacts {
                let lc = pe.contact.expect("filtered above");
                let key = ContactKey::Impactor(ii, s, c);
                let (m, inertia) = self.chunk_mass_inertia(s, c);
                let p = lc.centroid;
                let (v_chunk, w_chunk) = (self.solver.point_velocity(s, c, p), self.solver.chunk_velocity(s, c).1);
                let v_imp = imp.velocity + imp.angular_velocity.cross(p - imp.pose.position);
                let e = pe.elastic;
                let law = LayerLaw {
                    k_n: pe.k_n,
                    k_t: pe.k_t,
                    restitution,
                    friction: self.pair_friction(&imp.material, self.chunk_material(s, c)),
                    m_red: m * imp.mass / (m + imp.mass),
                    i_red: reduced(lc.normal.dot(inertia * lc.normal), lc.normal.dot(imp_inertia * lc.normal)),
                    elastic_scale: 1.0,
                    elastic: Some(Elastic { force: e.force * elastic_scale, moment: e.moment * elastic_scale, stored: e.stored * elastic_scale }),
                };
                let out = layer_force(&law, &lc, v_chunk - v_imp, w_chunk - imp.angular_velocity, previous.remove(&key).unwrap_or_default(), dt);
                let center = self.solver.chunk_position(s, c);
                self.loads.add_at(s, c, out.force, p, center);
                self.loads.torque[s][c] += out.moment;
                self.contact_hits[s][c] += out.force.norm();
                imp_loads[ii].0 -= out.force;
                imp_loads[ii].1 -= (p - imp.pose.position).cross(out.force) + out.moment;
                self.contact.stored += out.stored;
                self.contact.modelled += out.dissipated;
                self.contact.kinds[KIND_IMPACTOR].stored += out.stored;
                self.contact.kinds[KIND_IMPACTOR].modelled += out.dissipated;
                self.applied.push(Applied { kind: KIND_IMPACTOR, a: Party::Chunk(s, c), ra: p - center, b: Party::Impactor(ii), rb: p - imp.pose.position, force: out.force, moment: out.moment });
                self.sticks.insert(key, out.stick);
            }
        }

        drop(t_imp);
        let t_ground = crate::profile::time(crate::profile::Stage::ContactGround);
        // Ground: the half-space below `height`, pressed by chunks and impactors.
        if let Some(g) = self.scene.ground.clone() {
            let gm = self.scene.material(&g.material).clone();
            let mu = self.scene.sim.contact_friction.unwrap_or(g.friction);
            for (k, &(s, c)) in active.iter().enumerate() {
                let (center, radius) = bounds[k];
                if center.z - radius > g.height {
                    continue;
                }
                let cl = &self.solver.clusters[self.solver.chunks[s][c].cluster];
                if cl.anchored || cl.driven {
                    continue;
                }
                let b = self.cached_box(&mut boxes, k, s, c).clone();
                let Some(lc) = LayerContact::with_half_space(&polytope_of(&b, OWNER_A), Vec3::Z, g.height, 0.0).and_then(|o| o.contact) else { continue };
                // The ground's layer is as thick as the chunk's (a mirror image of it); the
                // chunk's thickness along the normal turns with it, which the energy's
                // gradient (`k V depth`, `dk/dh = -k^2 (1/E'_g + 1/E'_c)`) makes a torque.
                let (h, turning) = layer_thickness(&b, Vec3::Z);
                let (k_n, k_t) = layer_moduli(&gm, h, self.chunk_material(s, c), h, scale);
                let e_inv = 1.0 / layer_modulus(&gm, scale) + 1.0 / layer_modulus(self.chunk_material(s, c), scale);
                let (m, inertia) = self.chunk_mass_inertia(s, c);
                let key = ContactKey::Ground(s, c);
                let p = lc.centroid;
                let elastic = Elastic { force: k_n * lc.volume, moment: turning * (k_n * k_n * e_inv * lc.volume * lc.depth), stored: k_n * lc.volume * lc.depth };
                let law = LayerLaw { k_n, k_t, restitution, friction: mu, m_red: m, i_red: lc.normal.dot(inertia * lc.normal), elastic_scale: 1.0, elastic: Some(elastic) };
                let (v, w) = (self.solver.point_velocity(s, c, p), self.solver.chunk_velocity(s, c).1);
                let out = layer_force(&law, &lc, v, w, previous.remove(&key).unwrap_or_default(), dt);
                let center = self.solver.chunk_position(s, c);
                self.loads.add_at(s, c, out.force, p, center);
                self.loads.torque[s][c] += out.moment;
                self.contact.stored += out.stored;
                self.contact.modelled += out.dissipated;
                self.contact.kinds[KIND_GROUND].stored += out.stored;
                self.contact.kinds[KIND_GROUND].modelled += out.dissipated;
                self.applied.push(Applied { kind: KIND_GROUND, a: Party::Chunk(s, c), ra: p - center, b: Party::Ground, rb: Vec3::ZERO, force: out.force, moment: out.moment });
                self.sticks.insert(key, out.stick);
            }
            for ii in 0..self.impactors.len() {
                if self.impactors[ii].driven {
                    continue;
                }
                let imp = self.impactors[ii].clone();
                let ib = imp.obox();
                let (lc, h) = match imp.shape {
                    ImpactorShape::Sphere { radius } => {
                        let Some(cap) = LayerContact::sphere_cap(imp.pose.position, radius, Vec3::Z, g.height - (imp.pose.position.z - radius)) else { continue };
                        (cap, radius)
                    }
                    ImpactorShape::Box { .. } => {
                        if ib.center.z - ib.bounding_radius() > g.height {
                            continue;
                        }
                        let Some(lc) = LayerContact::with_half_space(&polytope_of(&ib, OWNER_A), Vec3::Z, g.height, 0.0).and_then(|o| o.contact) else { continue };
                        (lc, layer_thickness(&ib, Vec3::Z).0)
                    }
                };
                let turning = match imp.shape {
                    ImpactorShape::Sphere { .. } => Vec3::ZERO,
                    ImpactorShape::Box { .. } => layer_thickness(&ib, Vec3::Z).1,
                };
                let (k_n, k_t) = layer_moduli(&gm, h, &imp.material, h, scale);
                let ri = imp.pose.rotation.to_mat3();
                let i_n = lc.normal.dot((ri * imp.inertia * ri.transpose()) * lc.normal);
                let p = lc.centroid;
                let e_inv = 1.0 / layer_modulus(&gm, scale) + 1.0 / layer_modulus(&imp.material, scale);
                let elastic = Elastic { force: k_n * lc.volume, moment: turning * (k_n * k_n * e_inv * lc.volume * lc.depth), stored: k_n * lc.volume * lc.depth };
                let law = LayerLaw { k_n, k_t, restitution, friction: mu, m_red: imp.mass, i_red: i_n, elastic_scale: 1.0, elastic: Some(elastic) };
                let v = imp.velocity + imp.angular_velocity.cross(p - imp.pose.position);
                let key = ContactKey::ImpactorGround(ii);
                let out = layer_force(&law, &lc, v, imp.angular_velocity, previous.remove(&key).unwrap_or_default(), dt);
                imp_loads[ii].0 += out.force;
                imp_loads[ii].1 += (p - imp.pose.position).cross(out.force) + out.moment;
                self.contact.stored += out.stored;
                self.contact.modelled += out.dissipated;
                self.contact.kinds[KIND_IMPACTOR_GROUND].stored += out.stored;
                self.contact.kinds[KIND_IMPACTOR_GROUND].modelled += out.dissipated;
                self.applied.push(Applied { kind: KIND_IMPACTOR_GROUND, a: Party::Impactor(ii), ra: p - imp.pose.position, b: Party::Ground, rb: Vec3::ZERO, force: out.force, moment: out.moment });
                self.sticks.insert(key, out.stick);
            }
        }

        drop(t_ground);
        let t_broad = crate::profile::time(crate::profile::Stage::ContactBroadphase);
        // Chunks of different clusters (debris on structures, fragments on fragments).
        let n_clusters = self.solver.clusters.len();
        if n_clusters > 1 {
            let mut cluster_boxes: Vec<(Vec3, Vec3)> = vec![(Vec3::splat(f64::INFINITY), Vec3::splat(f64::NEG_INFINITY)); n_clusters];
            let mut by_cluster: Vec<Vec<usize>> = vec![Vec::new(); n_clusters];
            for (k, &(s, c)) in active.iter().enumerate() {
                let ci = self.solver.chunks[s][c].cluster;
                let (center, radius) = bounds[k];
                let r = Vec3::splat(radius);
                cluster_boxes[ci].0 = cluster_boxes[ci].0.component_min(center - r);
                cluster_boxes[ci].1 = cluster_boxes[ci].1.component_max(center + r);
                by_cluster[ci].push(k);
            }
            let mut candidates = Vec::new();
            for ca in 0..n_clusters {
                for cb in ca + 1..n_clusters {
                    let ((a0, a1), (b0, b1)) = (cluster_boxes[ca], cluster_boxes[cb]);
                    if (0..3).any(|i| a1[i] < b0[i] || b1[i] < a0[i]) {
                        continue;
                    }
                    let (cla, clb) = (&self.solver.clusters[ca], &self.solver.clusters[cb]);
                    if (cla.anchored && clb.anchored) || cla.driven || clb.driven {
                        continue;
                    }
                    for &ka in &by_cluster[ca] {
                        for &kb in &by_cluster[cb] {
                            let ((pa, ra), (pb, rb)) = (bounds[ka], bounds[kb]);
                            if (pa - pb).norm() > ra + rb {
                                continue;
                            }
                            // Pairs by chunk identity (lower first), not by cluster order,
                            // which a split renumbers: the contact keeps its state.
                            let (ka, kb) = if active[ka] < active[kb] { (ka, kb) } else { (kb, ka) };
                            let ((sa, chunk_a), (sb, chunk_b)) = (active[ka], active[kb]);
                            self.cached_box(&mut boxes, ka, sa, chunk_a);
                            self.cached_box(&mut boxes, kb, sb, chunk_b);
                            let key = ContactKey::Pair(sa, chunk_a, sb, chunk_b);
                            candidates.push((key, ka, kb, previous.remove(&key).unwrap_or_default()));
                        }
                    }
                }
            }
            drop(t_broad);
            crate::profile::count(crate::profile::Counter::PairCandidates, candidates.len() as u64);
            let _t_pairs = crate::profile::time(crate::profile::Stage::ContactPairs);
            // Each pair depends only on the state at the start of the substep: evaluate
            // in parallel, apply in candidate order (bit-identical for any thread count).
            let (solver, scene, boxes) = (&self.solver, &self.scene, &boxes);
            let outcomes = crate::par::map_into_heavy(candidates, |(key, ka, kb, stick)| {
                let _t = crate::profile::time(crate::profile::Stage::PairEval);
                let shape = |k: usize| boxes[k].as_ref().expect("cached above");
                pair_layer_contact(solver, scene, key, stick, shape(ka), shape(kb), dt)
            });
            let _t_apply = crate::profile::time(crate::profile::Stage::PairApply);
            for (key, p, out, work) in outcomes.into_iter().flatten() {
                crate::profile::count(crate::profile::Counter::PairOverlaps, 1);
                let ContactKey::Pair(sa, ca, sb, cb) = key else { unreachable!("pair keys only") };
                let (center_a, center_b) = (self.solver.chunk_position(sa, ca), self.solver.chunk_position(sb, cb));
                self.loads.add_at(sa, ca, out.force, p, center_a);
                self.loads.torque[sa][ca] += out.moment;
                self.loads.add_at(sb, cb, -out.force, p, center_b);
                self.loads.torque[sb][cb] -= out.moment;
                self.contact_hits[sa][ca] += out.force.norm();
                self.contact_hits[sb][cb] += out.force.norm();
                self.contact.stored += out.stored;
                self.contact.modelled += out.dissipated;
                self.contact.pair_work += work;
                self.contact.kinds[KIND_PAIR].stored += out.stored;
                self.contact.kinds[KIND_PAIR].modelled += out.dissipated;
                self.applied.push(Applied { kind: KIND_PAIR, a: Party::Chunk(sa, ca), ra: p - center_a, b: Party::Chunk(sb, cb), rb: p - center_b, force: out.force, moment: out.moment });
                self.sticks.insert(key, out.stick);
            }
        }
        imp_loads
    }

    /// Joints broken by this substep's splits hand their compression over to the
    /// elastic-layer contact of the two chunks: the contact gets the permanent
    /// indentation (crushed material) at which its force equals the joint's compressive
    /// force, raised if needed so it stores no more energy than the joint did; the rest
    /// of the joint's stored energy is booked as released at the split. A joint in
    /// tension leaves no overlap to hand over.
    fn hand_over_split_joints(&mut self) {
        let handovers = std::mem::take(&mut self.solver.handovers);
        let scale = self.scene.sim.stiffness_scale;
        for h in handovers {
            let (s, a, b) = (h.structure, h.a.min(h.b), h.a.max(h.b));
            let (ba, bb) = (self.chunk_box(s, a), self.chunk_box(s, b));
            let material = |c: usize| self.scene.material(&self.solver.structures[s].chunks[c].material);
            let (mat_a, mat_b) = (material(a), material(b));
            let Some(overlap) = (if ba.may_overlap(&bb) { pair_overlap(&ba, &bb) } else { None }) else {
                self.solver.energy.split_release += h.stored;
                continue;
            };
            let at = |indent: f64| pair_elastic_of(&overlap, &ba, &bb, mat_a, mat_b, scale, indent, true);
            let Some(full) = at(0.0).filter(|p| p.elastic.force > 0.0) else {
                self.solver.energy.split_release += h.stored;
                continue;
            };
            // Force and stored energy beyond an indentation (both fall as it deepens).
            let elastic = |i: f64| pair_elastic_of(&overlap, &ba, &bb, mat_a, mat_b, scale, i, false).map_or(Elastic { force: 0.0, moment: Vec3::ZERO, stored: 0.0 }, |p| p.elastic);
            let force = |i: f64| elastic(i).force;
            let energy = |i: f64| elastic(i).stored;
            let bisect = |f: &dyn Fn(f64) -> f64, target: f64| {
                let (mut lo, mut hi) = (0.0, full.max_depth);
                for _ in 0..60 {
                    let mid = 0.5 * (lo + hi);
                    if f(mid) > target {
                        lo = mid;
                    } else {
                        hi = mid;
                    }
                }
                hi
            };
            let mut indent = if full.elastic.force > h.compression { bisect(&force, h.compression) } else { 0.0 };
            if energy(indent) > h.stored {
                indent = bisect(&energy, h.stored);
            }
            let kept = energy(indent);
            // The joint's shear and torsion become the contact's friction (the same
            // stiffness: k''_t A and k''_t J are the joint's G A / L and G J / L), on the
            // pair's first chunk; Coulomb's cap applies at the contact's next step, where
            // any excess slips. Never more energy than the joint stored.
            let mut stick = Stick { indent, ..Default::default() };
            let mut friction = 0.0;
            if let Some(pe) = at(indent) {
                if let Some(lc) = pe.contact {
                    let n = lc.normal;
                    let sign = if h.a <= h.b { 1.0 } else { -1.0 };
                    let (f, m) = (h.force * sign, h.couple * sign);
                    let (k_t, k_r) = (pe.k_t * lc.area, pe.k_t * lc.polar_moment);
                    let shear = f - n * f.dot(n);
                    let torque = m.dot(n);
                    let energy_t = if k_t > 0.0 { 0.5 * shear.dot(shear) / k_t } else { 0.0 };
                    let energy_r = if k_r > 0.0 { 0.5 * torque * torque / k_r } else { 0.0 };
                    let room = (h.stored - kept).max(0.0);
                    let scale = if energy_t + energy_r > room { (room / (energy_t + energy_r)).sqrt() } else { 1.0 };
                    if k_t > 0.0 {
                        stick.shear = shear * scale;
                        stick.k_t = k_t;
                    }
                    if k_r > 0.0 {
                        stick.torque = torque * scale;
                        stick.k_r = k_r;
                    }
                    friction = (energy_t + energy_r) * scale * scale;
                }
            }
            self.solver.energy.split_release += h.stored - kept - friction;
            self.contact.received += kept + friction;
            self.contact.kinds[KIND_PAIR].received += kept + friction;
            self.sticks.insert(ContactKey::Pair(s, a, s, b), stick);
        }
    }

    /// A chunk's mass and its world-frame inertia (about its centre).
    fn chunk_mass_inertia(&self, s: usize, c: usize) -> (f64, Mat3) {
        let ch = &self.solver.structures[s].chunks[c];
        let r = self.solver.clusters[self.solver.chunks[s][c].cluster].rotation();
        (ch.mass, r * ch.inertia * r.transpose())
    }

    // ------------------------------------------------------------------ events

    fn process_events(&mut self, t: f64) {
        for ei in 0..self.scene.events.len() {
            if self.events_done[ei] {
                continue;
            }
            match self.scene.events[ei].clone() {
                EventDesc::RemoveChunks { time, duration, body, chunks } => {
                    if t + 1e-12 < time {
                        continue;
                    }
                    let s = self.solver.structure_index(&body).unwrap();
                    let sel = select_with_descendants(&chunks, &self.scene, s);
                    self.solver.remove_chunks(s, &sel, duration);
                }
                EventDesc::RemoveSupports { time, duration, body, chunks } => {
                    if t + 1e-12 < time {
                        continue;
                    }
                    let s = self.solver.structure_index(&body).unwrap();
                    let sel = chunks.select(&self.scene.bodies[s]);
                    self.solver.remove_supports(s, &sel, duration);
                }
            }
            self.events_done[ei] = true;
            self.topology_version += 1;
            for c in self.solver.clusters.iter_mut() {
                c.activity = Activity::Active;
                c.active_timer = self.solver.config.active_time;
            }
        }
    }

    // ------------------------------------------------------------------ stepping

    fn cluster_load_norm(&self, ci: usize) -> f64 {
        let cl = &self.solver.clusters[ci];
        cl.chunks.iter().map(|&c| self.loads.force[cl.structure][c].norm()).sum()
    }

    fn cluster_weight(&self, ci: usize) -> f64 {
        self.solver.clusters[ci].mass * self.solver.config.gravity.norm()
    }

    /// Advance one frame (`sim.frame_dt`).
    pub fn step_frame(&mut self) {
        if self.scene.sim.methods.frame_contact_step && self.scene.sim.methods.layer_contact {
            self.contact_dt = self.frame_contact_dt();
        }
        if self.coupling.is_some() {
            return self.step_frame_coupled();
        }
        let t_dt = crate::profile::time(crate::profile::Stage::StepDt);
        let dt = self.substep_dt();
        drop(t_dt);
        crate::profile::count(crate::profile::Counter::Frames, 1);
        if crate::profile::enabled() {
            self.count_step_limit();
        }
        let n = (self.scene.sim.frame_dt / dt).round().max(1.0) as usize;
        self.frame_loads.resize(&self.solver);
        let splits_before = self.solver.events.len();
        for i in 0..n {
            self.substep(dt);
            let mut fl = std::mem::take(&mut self.frame_loads);
            fl.add_scaled(&self.loads, 1.0 / n as f64);
            self.frame_loads = fl;
            if self.scene.sim.solve_mode == SolveMode::Implicit {
                self.accumulate_implicit(dt, i + 1 == n);
            }
        }
        self.frame += 1;
        if self.solver.events.len() != splits_before {
            self.topology_version += 1;
        }
        let _t_tail = crate::profile::time(crate::profile::Stage::FrameTail);
        match self.scene.sim.solve_mode {
            SolveMode::Explicit => {}
            SolveMode::QuasiStatic => {
                let opts = StaticOptions { cascade: true, ..Default::default() };
                let fl = self.frame_loads.clone();
                let _t = crate::profile::time(crate::profile::Stage::Statics);
                if !self.solver.solve_static_all(&fl, &opts, self.scene.sim.frame_dt).converged {
                    self.static_unconverged_frames += 1;
                }
                self.topology_version += 1;
            }
            SolveMode::Implicit => {}
            SolveMode::Adaptive => {
                let _t = crate::profile::time(crate::profile::Stage::Settle);
                self.settle_quiet_clusters();
                self.advance_settled_fatigue();
            }
        }
        if let Some(u) = self.scene.sim.refine_utilization {
            let _t = crate::profile::time(crate::profile::Stage::Refine);
            self.refine_where_needed(u);
            self.solver.mark_implicit_step_start();
        }
        self.frame_loads.clear();
    }

    /// Implicit mode: integrate this substep's loads and take an implicit step once
    /// `sim.implicit_dt` (or the frame) has elapsed, with the average loads since the last.
    fn accumulate_implicit(&mut self, dt: f64, frame_end: bool) {
        self.implicit_loads.ensure_shape(&self.solver);
        let mut acc = std::mem::take(&mut self.implicit_loads);
        acc.add_scaled(&self.loads, dt);
        self.implicit_loads = acc;
        self.implicit_elapsed += dt;
        let step = self.scene.sim.implicit_dt.unwrap_or(self.scene.sim.frame_dt);
        if self.implicit_elapsed < step * (1.0 - 1e-9) && !frame_end {
            return;
        }
        let elapsed = self.implicit_elapsed;
        let mut average = std::mem::take(&mut self.implicit_loads);
        average.scale(1.0 / elapsed);
        let events = self.solver.events.len();
        let t_implicit = crate::profile::time(crate::profile::Stage::Implicit);
        self.implicit_report = self.solver.implicit_step_all(&average, elapsed);
        drop(t_implicit);
        self.implicit_worst_residual = self.implicit_worst_residual.max(self.implicit_report.residual);
        if self.solver.events.len() != events {
            self.topology_version += 1;
        }
        average.clear();
        self.implicit_loads = average;
        self.implicit_elapsed = 0.0;
    }

    /// Adaptive mode: clusters whose last dynamic load is older than `active_time` and
    /// whose deformation has calmed down switch to quasi-static equilibrium.
    fn settle_quiet_clusters(&mut self) {
        let fdt = self.scene.sim.frame_dt;
        for ci in 0..self.solver.clusters.len() {
            if self.solver.clusters[ci].activity != Activity::Active {
                continue;
            }
            self.solver.clusters[ci].active_timer -= fdt;
            if self.solver.clusters[ci].active_timer > 0.0 || self.solver.clusters[ci].bonds.is_empty() {
                continue;
            }
            let s = self.solver.clusters[ci].structure;
            let ke: f64 = self.solver.clusters[ci]
                .chunks
                .iter()
                .map(|&c| {
                    let ch = &self.solver.structures[s].chunks[c];
                    let st = &self.solver.chunks[s][c];
                    0.5 * ch.mass * st.v.norm2() + 0.5 * st.w.dot(ch.inertia * st.w)
                })
                .sum();
            let stored: f64 = self.solver.clusters[ci].bonds.iter().map(|&b| self.solver.bonds[s][b].stored).sum();
            if ke > 1e-3 * stored.max(1e-9) {
                continue;
            }
            let opts = StaticOptions { cascade: true, max_cascade: 1, ..Default::default() };
            if !self.solver.equilibrate_or_keep(ci, &self.loads, &opts).converged {
                // No static equilibrium (a mechanism): it stays in the explicit solve.
                self.solver.clusters[ci].active_timer = self.solver.config.active_time;
                continue;
            }
            self.solver.clusters[ci].activity = Activity::Settled;
            self.solver.clusters[ci].settled_load_norm = self.cluster_load_norm(ci);
        }
    }

    /// Static fatigue keeps acting on a settled cluster: once per frame its bonds are
    /// evaluated at the equilibrium displacements with the frame's duration. A bond
    /// that starts to damage wakes the cluster, so the failure itself runs explicitly.
    pub(crate) fn advance_settled_fatigue(&mut self) {
        let fdt = self.scene.sim.frame_dt;
        for ci in (0..self.solver.clusters.len()).rev() {
            let cl = &self.solver.clusters[ci];
            if cl.activity != Activity::Settled || cl.bonds.is_empty() {
                continue;
            }
            let (changed, disconnected) = self.solver.commit_damage(ci, fdt);
            if changed || disconnected {
                self.solver.clusters[ci].activity = Activity::Active;
                self.solver.clusters[ci].active_timer = self.solver.config.active_time;
            }
            if disconnected {
                self.solver.split_cluster(ci);
                self.topology_version += 1;
            }
        }
    }

    /// Wake settled clusters whose external loads changed (impact, blast, debris).
    fn wake_loaded_clusters(&mut self) {
        for ci in 0..self.solver.clusters.len() {
            if self.solver.clusters[ci].activity != Activity::Settled {
                continue;
            }
            let now = self.cluster_load_norm(ci);
            let before = self.solver.clusters[ci].settled_load_norm;
            if (now - before).abs() > self.solver.config.wake_threshold * (self.cluster_weight(ci) + before) {
                self.solver.clusters[ci].activity = Activity::Active;
                self.solver.clusters[ci].active_timer = self.solver.config.active_time;
            }
        }
    }

    fn substep(&mut self, dt: f64) {
        let t = self.solver.time + dt;
        crate::profile::count(crate::profile::Counter::Substeps, 1);
        let t_events = crate::profile::time(crate::profile::Stage::Events);
        self.process_events(self.solver.time);
        drop(t_events);
        let t_loads = crate::profile::time(crate::profile::Stage::ScriptedLoads);
        self.loads.resize(&self.solver);
        self.loads.clear();
        self.apply_scripted_loads(self.solver.time);
        if let Some(c) = &self.coupling {
            c.filter.loads_at(&self.solver, self.solver.time, &mut self.loads);
        }
        drop(t_loads);
        let t_contacts = crate::profile::time(crate::profile::Stage::Contacts);
        let before = (self.loads.force.clone(), self.loads.torque.clone());
        let imp_loads = self.apply_contacts(dt);
        let contact_loads: Vec<(usize, usize, Vec3, Vec3)> = (0..before.0.len())
            .flat_map(|s| (0..before.0[s].len()).map(move |c| (s, c)))
            .map(|(s, c)| (s, c, self.loads.force[s][c] - before.0[s][c], self.loads.torque[s][c] - before.1[s][c]))
            .filter(|l| l.2 != Vec3::ZERO || l.3 != Vec3::ZERO)
            .collect();
        drop(t_contacts);
        if self.scene.sim.solve_mode == SolveMode::Adaptive {
            let _t = crate::profile::time(crate::profile::Stage::Wake);
            self.wake_loaded_clusters();
        }
        let n_events = self.solver.events.len();
        let t_solver = crate::profile::time(crate::profile::Stage::SolverSubstep);
        self.solver.substep(dt, &self.loads);
        drop(t_solver);
        if self.scene.sim.methods.layer_contact {
            let _t = crate::profile::time(crate::profile::Stage::Handover);
            self.hand_over_split_joints();
        }
        if self.solver.events.len() != n_events {
            self.topology_version += 1;
        }
        let t_work = crate::profile::time(crate::profile::Stage::ContactWork);
        for &(s, c, f, tq) in &contact_loads {
            if self.solver.chunks[s][c].active {
                let (v, w) = self.solver.chunk_velocity(s, c);
                self.contact.work += (f.dot(v) + tq.dot(w)) * dt;
            }
        }
        let g = self.solver.config.gravity;
        for (imp, (f, tq)) in self.impactors.iter_mut().zip(imp_loads) {
            if imp.driven {
                continue;
            }
            imp.velocity += (f / imp.mass + g) * dt;
            let r = imp.pose.rotation.to_mat3();
            let l = r * imp.inertia * r.transpose() * imp.angular_velocity + tq * dt;
            let w_mid = (r * imp.inertia * r.transpose()).inverse().unwrap() * l;
            imp.pose.position += imp.velocity * dt;
            imp.pose.rotation = imp.pose.rotation.integrate(w_mid, dt);
            let r = imp.pose.rotation.to_mat3();
            imp.angular_velocity = (r * imp.inertia * r.transpose()).inverse().unwrap() * l;
            self.contact.work += (f.dot(imp.velocity) + tq.dot(imp.angular_velocity)) * dt;
        }
        if self.scene.sim.methods.layer_contact {
            // Exact for the motion the integrator produced: what the contact forces took
            // out of it, less what the contacts still store.
            self.contact.dissipated = -self.contact.work - self.contact.stored + self.contact.received;
            for ap in std::mem::take(&mut self.applied) {
                let power = |party: Party, r: Vec3| match party {
                    Party::Chunk(s, c) if self.solver.chunks[s][c].active => {
                        let (v, w) = self.solver.chunk_velocity(s, c);
                        ap.force.dot(v) + (r.cross(ap.force) + ap.moment).dot(w)
                    }
                    Party::Impactor(i) => {
                        let imp = &self.impactors[i];
                        ap.force.dot(imp.velocity) + (r.cross(ap.force) + ap.moment).dot(imp.angular_velocity)
                    }
                    _ => 0.0,
                };
                self.contact.kinds[ap.kind].work += (power(ap.a, ap.ra) - power(ap.b, ap.rb)) * dt;
            }
        }
        drop(t_work);
        debug_assert!((self.solver.time - t).abs() < 1e-9);
        let _t = crate::profile::time(crate::profile::Stage::Probes);
        self.record_probes(false);
    }

    /// Multi-level pre-fracture: refine coarse chunks near failure or under impact.
    fn refine_where_needed(&mut self, threshold: f64) {
        for s in 0..self.solver.structures.len() {
            let candidates: Vec<usize> = (0..self.solver.structures[s].chunks.len())
                .filter(|&c| {
                    self.solver.chunks[s][c].active
                        && !self.solver.structures[s].chunks[c].children.is_empty()
                        && (self.contact_hits[s][c] > 0.0
                            || self.solver.chunk_bonds[s][c]
                                .iter()
                                .any(|&b| self.solver.bonds[s][b].joint.utilization >= threshold))
                })
                .collect();
            for c in candidates {
                self.solver.refine_chunk(s, c);
                self.topology_version += 1;
            }
        }
    }

    pub fn run(&mut self) -> Observation {
        let frames = (self.scene.sim.duration / self.scene.sim.frame_dt).round() as u64;
        while self.frame < frames {
            self.step_frame();
        }
        self.observation()
    }

    // ------------------------------------------------------------------ probes

    fn probe_value(&self, kind: &ProbeKind) -> f64 {
        match kind {
            ProbeKind::ChunkDisplacement { body, chunk, axis } => {
                let s = self.solver.structure_index(body).unwrap();
                match self.representative(s, *chunk) {
                    Some(c) => {
                        let x = self.solver.chunk_position(s, c)
                            + self.offset_from_representative(s, *chunk, c);
                        (x - self.initial_positions[s][*chunk]).dot(Vec3::from_array(*axis).normalized())
                    }
                    None => f64::NAN,
                }
            }
            ProbeKind::ChunkVelocity { body, chunk, axis } => {
                let s = self.solver.structure_index(body).unwrap();
                match self.representative(s, *chunk) {
                    Some(c) => self.solver.chunk_velocity(s, c).0.dot(Vec3::from_array(*axis).normalized()),
                    None => f64::NAN,
                }
            }
            ProbeKind::SectionForce { body, point, normal, region, component } => {
                let s = self.solver.structure_index(body).unwrap();
                let p = Vec3::from_array(*point);
                let n = Vec3::from_array(*normal).normalized();
                let st = &self.solver.structures[s];
                let mut f = Vec3::ZERO;
                let mut m = Vec3::ZERO;
                for b in self.solver.bonds[s].iter().filter(|b| b.alive) {
                    let g = &b.geometry;
                    if let Some(r) = region {
                        if !r.contains(g.centroid) {
                            continue;
                        }
                    }
                    let side_a = (st.chunks[g.a].center - p).dot(n);
                    let side_b = (st.chunks[g.b].center - p).dot(n);
                    if side_a * side_b >= 0.0 {
                        continue;
                    }
                    let (fa, ma, fb, mb) = g.chunk_loads(&b.force);
                    let (fc, mc, xc) =
                        if side_a > 0.0 { (fa, ma, st.chunks[g.a].center) } else { (fb, mb, st.chunks[g.b].center) };
                    f += fc;
                    m += mc + (xc - p).cross(fc);
                }
                match component {
                    SectionComponent::Normal => -f.dot(n),
                    SectionComponent::Force(a) => f.dot(Vec3::from_array(*a).normalized()),
                    SectionComponent::Moment(a) => m.dot(Vec3::from_array(*a).normalized()),
                }
            }
            ProbeKind::Reaction { body, chunks, axis } => {
                let s = self.solver.structure_index(body).unwrap();
                let a = Vec3::from_array(*axis).normalized();
                chunks
                    .select(&self.scene.bodies[s])
                    .into_iter()
                    .map(|c| self.solver.reaction_world(s, c).0.dot(a))
                    .sum()
            }
            ProbeKind::ImpactorVelocity { impactor, axis } => {
                let imp = self.impactors.iter().find(|i| &i.name == impactor).unwrap();
                imp.velocity.dot(Vec3::from_array(*axis).normalized())
            }
            ProbeKind::ImpactorPosition { impactor, axis } => {
                let imp = self.impactors.iter().find(|i| &i.name == impactor).unwrap();
                imp.pose.position.dot(Vec3::from_array(*axis).normalized())
            }
        }
    }

    fn record_probes(&mut self, force_sample: bool) {
        let t = self.solver.time;
        let values: Vec<f64> = self.scene.probes.iter().map(|p| self.probe_value(&p.kind)).collect();
        let sample = force_sample || t + 1e-12 >= self.next_sample;
        for (acc, v) in self.probes.iter_mut().zip(values) {
            if acc.series.t.is_empty() && !force_sample {
                continue;
            }
            if acc.series.t.is_empty() || force_sample {
                acc.lo = v;
                acc.hi = v;
            } else {
                acc.lo = acc.lo.min(v);
                acc.hi = acc.hi.max(v);
            }
            acc.last = v;
            if sample {
                acc.series.push(t, v, acc.lo, acc.hi);
                acc.lo = v;
                acc.hi = v;
            }
        }
        if sample {
            self.next_sample = t + self.sample_interval;
        }
    }

    // ------------------------------------------------------------------ observation

    /// The active chunk that represents scene chunk `c` (itself, or its active ancestor).
    fn representative(&self, s: usize, c: usize) -> Option<usize> {
        let mut x = c;
        loop {
            if self.solver.chunks[s][x].active {
                return Some(x);
            }
            if self.solver.chunks[s][x].removed {
                return None;
            }
            x = self.solver.structures[s].chunks[x].parent?;
        }
    }

    fn offset_from_representative(&self, s: usize, c: usize, rep: usize) -> Vec3 {
        if c == rep {
            return Vec3::ZERO;
        }
        let st = &self.solver.structures[s];
        let cl = &self.solver.clusters[self.solver.chunks[s][rep].cluster];
        cl.pose.transform_vector(st.chunks[c].center - st.chunks[rep].center)
    }

    /// Active chunks represented by scene chunk `c` (itself, or its active descendants).
    fn descendants(&self, s: usize, c: usize, out: &mut Vec<usize>) {
        if self.solver.chunks[s][c].active {
            out.push(c);
            return;
        }
        for &k in &self.solver.structures[s].chunks[c].children {
            self.descendants(s, k, out);
        }
    }

    pub fn observation(&self) -> Observation {
        let solver = match self.engine_name() {
            Some(engine) => format!("stress-ref+{engine}"),
            None => "stress-ref".to_string(),
        };
        let mut obs = Observation::new(&self.scene.name, &solver, env!("CARGO_PKG_VERSION"), self.scene.sim.seed);
        obs.end_time = self.solver.time;
        if self.coupling.is_some() {
            obs.values.insert("island_frames".into(), self.island_frames as f64);
            obs.values.insert("max_island_bodies".into(), self.max_island_bodies as f64);
            obs.values.insert("engine_body_frames".into(), self.engine_body_frames as f64);
            obs.values.insert("island_body_frames".into(), self.island_body_frames as f64);
            obs.values.insert("redone_frames".into(), self.redone_frames as f64);
        }
        for (p, acc) in self.scene.probes.iter().zip(&self.probes) {
            obs.probes.insert(p.name.clone(), acc.series.clone());
        }
        let mut collapse = false;
        let mut fragments = 0usize;
        for (s, st) in self.solver.structures.iter().enumerate() {
            let has_supports = self.scene.bodies[s].chunks.iter().any(|c| c.support != Support::None);
            // Main piece: anchored clusters, else the heaviest cluster.
            let clusters: Vec<usize> = (0..self.solver.clusters.len()).filter(|&i| self.solver.clusters[i].structure == s).collect();
            fragments += clusters.len();
            let heaviest = clusters
                .iter()
                .copied()
                .max_by(|&a, &b| self.solver.clusters[a].mass.total_cmp(&self.solver.clusters[b].mass));
            let is_main = |ci: usize| {
                if has_supports {
                    self.solver.clusters[ci].anchored
                } else {
                    Some(ci) == heaviest
                }
            };
            let mut list = Vec::with_capacity(st.chunks.len());
            for c in 0..st.chunks.len() {
                let mut reps = Vec::new();
                if self.solver.chunks[s][c].removed && !self.solver.chunks[s][c].active {
                    list.push(ChunkObservation { removed: true, fragment: -1, ..Default::default() });
                    continue;
                }
                match self.representative(s, c) {
                    Some(r) => reps.push(r),
                    None => self.descendants(s, c, &mut reps),
                }
                if reps.is_empty() {
                    list.push(ChunkObservation { removed: true, fragment: -1, ..Default::default() });
                    continue;
                }
                let mut mass = 0.0;
                let mut detached_mass = 0.0;
                let mut v = Vec3::ZERO;
                let mut x = Vec3::ZERO;
                for &r in &reps {
                    let m = st.chunks[r].mass;
                    let ci = self.solver.chunks[s][r].cluster;
                    mass += m;
                    if !is_main(ci) {
                        detached_mass += m;
                    }
                    v += self.solver.chunk_velocity(s, r).0 * m;
                    x += (self.solver.chunk_position(s, r) + self.offset_from_representative(s, c, r)) * m;
                }
                let x = x / mass;
                let detached = detached_mass > 0.5 * mass;
                if detached && has_supports {
                    collapse = true;
                }
                let frag = self.solver.clusters[self.solver.chunks[s][reps[0]].cluster].id as i64;
                list.push(ChunkObservation {
                    detached,
                    removed: false,
                    fragment: frag,
                    velocity: (v / mass).to_array(),
                    displacement: (x - self.initial_positions[s][c]).to_array(),
                });
            }
            obs.bodies.insert(st.name.clone(), list);
        }
        let broken = self.solver.broken_bond_count();
        obs.flags.insert("any_bond_broken".into(), broken > 0);
        // Damage onset anywhere (the criterion an elastic oracle can evaluate).
        let first_crack = self.solver.events.iter().find_map(|e| match e {
            crate::solver::SolverEvent::Cracked { time, .. } => Some(*time),
            _ => None,
        });
        // With fracture disabled, "cracked" means a failure index reached 1 (as an
        // elastic oracle evaluates it).
        let cracked = first_crack.is_some() || (!self.scene.sim.fracture && self.solver.max_utilization >= 1.0);
        obs.flags.insert("any_bond_cracked".into(), cracked);
        obs.values.insert("max_failure_index".into(), self.solver.max_utilization);
        if let Some(t) = first_crack {
            obs.values.insert("first_crack_time".into(), t);
        }
        obs.flags.insert("collapse".into(), collapse);
        obs.values.insert("broken_bonds".into(), broken as f64);
        obs.values.insert("fragments".into(), fragments as f64);
        obs.values.insert("substeps".into(), self.solver.substeps as f64);
        obs.values.insert("bond_dissipation".into(), self.solver.energy.bond_dissipation);
        obs.values.insert("damping_dissipation".into(), self.solver.energy.damping_dissipation);
        obs.values.insert("contact_dissipation".into(), self.contact.dissipated);
        obs.values.insert("softening_overshoot".into(), self.solver.energy.softening_overshoot);
        obs.values.insert("split_release".into(), self.solver.energy.split_release);
        obs.values.insert("crush_energy".into(), self.contact.crush);
        if self.scene.sim.solve_mode == SolveMode::Implicit {
            obs.values.insert("implicit_worst_residual".into(), self.implicit_worst_residual);
        }
        if self.static_unconverged_frames > 0 {
            obs.values.insert("static_unconverged_frames".into(), self.static_unconverged_frames as f64);
        }
        if self.added_mass_fraction > 0.0 {
            obs.values.insert("added_mass_fraction".into(), self.added_mass_fraction);
        }
        obs
    }

    // ------------------------------------------------------------------ energy

    /// Total mechanical energy: kinetic (chunks and impactors) + bond elastic + contact
    /// penalty + gravitational potential (chunks and impactors).
    pub fn mechanical_energy(&self) -> f64 {
        let g = self.solver.config.gravity;
        let imp: f64 = self.impactors.iter().map(|i| i.kinetic_energy() - i.mass * g.dot(i.pose.position)).sum();
        self.solver.kinetic_energy() + self.solver.elastic_energy() + self.contact.stored + self.solver.gravity_potential() + imp
    }

    /// Everything dissipated so far.
    pub fn dissipated_energy(&self) -> f64 {
        let e = &self.solver.energy;
        e.bond_dissipation + e.damping_dissipation + e.softening_overshoot + e.split_release + self.contact.dissipated
    }
}

/// Smallest stiffness scale for which a stress wave still crosses every structure of
/// the scene (its largest extent, at the slowest bar wave speed) within `frames` frames.
/// The real-time compromise: lower E as far as this allows, keep strengths physical.
pub fn min_stiffness_scale(scene: &Scene, frames: f64) -> f64 {
    let mut scale: f64 = 0.0;
    for b in &scene.bodies {
        let (mut lo, mut hi) = (Vec3::splat(f64::INFINITY), Vec3::splat(f64::NEG_INFINITY));
        let mut c_min = f64::INFINITY;
        for c in &b.chunks {
            let x = Vec3::from_array(c.center);
            let h = Vec3::from_array(c.half_extents);
            lo = lo.component_min(x - h);
            hi = hi.component_max(x + h);
            c_min = c_min.min(scene.material(&c.material).bar_wave_speed());
        }
        let extent = (hi - lo).max_elem();
        // Required speed extent / (frames * frame_dt); speed scales with sqrt(scale).
        let needed = extent / (frames * scene.sim.frame_dt);
        scale = scale.max((needed / c_min).powi(2));
    }
    scale.min(1.0)
}

/// Penalty contact force at one point, with the energy it stores and dissipates
/// over `dt`.
#[allow(clippy::too_many_arguments)]
fn penalty_force(
    k: f64,
    m_red: f64,
    restitution: f64,
    friction: f64,
    depth: f64,
    normal: Vec3,
    rel_velocity: Vec3,
    dt: f64,
    points: usize,
) -> (Vec3, f64, f64) {
    // Explicit integration stays stable only while the viscous coefficients acting on a
    // chunk keep `c dt / m` below 2: the `points` of this set share its budget.
    let c_max = MAX_SET_VISCOSITY / points.max(FACE_PAIR_POINTS) as f64 * m_red / dt;
    let c = (2.0 * damping_ratio(restitution) * (k * m_red).sqrt()).min(c_max);
    let vn = rel_velocity.dot(normal);
    let fn_mag = (k * depth - c * vn).max(0.0);
    let vt = rel_velocity - normal * vn;
    let vt_mag = vt.norm();
    // Regularised Coulomb friction: viscous below the sliding speed, with the same cap.
    let ft_mag = (friction * fn_mag).min(c_max.min(friction * fn_mag / FRICTION_REGULARIZATION) * vt_mag);
    let ft = if vt_mag > 0.0 { -vt * (ft_mag / vt_mag) } else { Vec3::ZERO };
    let stored = 0.5 * k * depth * depth;
    // While the dashpot clamps the normal force to zero (fast separation), the
    // penalty spring unloads without doing work: that energy is dissipated too.
    let damping_power = if k * depth - c * vn > 0.0 { c * vn * vn } else { k * depth * vn.max(0.0) };
    let dissipated = (damping_power + ft.norm() * vt_mag) * dt;
    (normal * fn_mag + ft, stored, dissipated)
}

/// A contact of the elastic-layer method, by the bodies it joins.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
enum ContactKey {
    Ground(usize, usize),
    ImpactorGround(usize),
    Impactor(usize, usize, usize),
    Pair(usize, usize, usize, usize),
}

/// Friction state of an elastic-layer contact: the shear layer's elastic force (world
/// vector, in the contact plane) and moment about the normal, updated incrementally
/// (Mindlin-Deresiewicz), with the stiffnesses they were stored at. Where the contact
/// grows, new layer enters unstrained (the force carries over); where it shrinks, the
/// layer leaving takes its share of the force with it (the force scales with the
/// stiffness): the force stays continuous where it should, inside Coulomb's cone, and
/// its stored energy `F^2 / 2k` never grows without work.
#[derive(Clone, Copy, Debug, Default)]
struct Stick {
    shear: Vec3,
    torque: f64,
    k_t: f64,
    k_r: f64,
    /// Permanent indentation of the contact surface (crushed material inherited from
    /// the joint the pair shared): the layer acts only on overlap deeper than this. It
    /// stays while the pair overlaps; a pair that separates forgets it.
    indent: f64,
}

/// Material and inertia data of one elastic-layer contact.
struct LayerLaw {
    /// Normal and shear layer moduli per unit area: `1 / (h_a / E'_a + h_b / E'_b)` and
    /// `1 / (h_a / G_a + h_b / G_b)`.
    k_n: f64,
    k_t: f64,
    restitution: f64,
    friction: f64,
    m_red: f64,
    /// Reduced moment of inertia about the normal (torsional dashpot).
    i_red: f64,
    /// Fraction of the elastic force transmitted (a crush-capped impactor).
    elastic_scale: f64,
    /// The layer's elastic force (along the contact normal), its moment about the
    /// contact point and stored energy, where the contact computes them itself
    /// (`pair_elastic`); else `k_n V` at the overlap centroid.
    elastic: Option<Elastic>,
}

#[derive(Clone, Copy, Debug)]
struct Elastic {
    force: f64,
    moment: Vec3,
    stored: f64,
}

/// Forces of one elastic-layer contact over a substep, on body `a`.
struct LayerOutcome {
    /// Force, acting at the overlap's centroid.
    force: Vec3,
    /// Torsional friction moment (along the normal).
    moment: Vec3,
    stick: Stick,
    stored: f64,
    dissipated: f64,
}

/// The layer moduli per unit area of two half-thicknesses along the normal.
/// The plane-strain modulus `E' = E / (1 - nu^2)` (scaled) of an elastic layer.
fn layer_modulus(m: &Material, scale: f64) -> f64 {
    m.youngs_modulus * scale / (1.0 - m.poisson_ratio * m.poisson_ratio)
}

/// The elastic layer between a chunk (box `b`) and a ball, in the chunk's nearest-face
/// cells (`polytope::ball_cells`): `E = sum_f k''_f int s dV`, `k''_f` from the chunk's
/// half-thickness along face `f`'s normal and the ball's radius (both fixed, so no
/// turning term), its exact gradient the force and moment on the chunk.
fn ball_elastic(b: &OBox, mat_chunk: &Material, center: Vec3, r: f64, mat_ball: &Material, scale: f64) -> Option<PairElastic> {
    let body = polytope_of(b, OWNER_A);
    let cells = ball_cells(&body, center, r);
    if cells.is_empty() {
        return None;
    }
    let (mut force, mut moment, mut stored, mut kv, mut kvc, mut vol, mut ktv) = (Vec3::ZERO, Vec3::ZERO, 0.0, 0.0, Vec3::ZERO, 0.0, 0.0);
    for c in &cells {
        let (k_n, k_t) = layer_moduli(mat_chunk, layer_thickness(b, c.normal).0, mat_ball, r, scale);
        // The chunk's field pushes the ball out; the chunk takes the opposite.
        force -= (c.normal * c.volume + c.interface_force) * k_n;
        moment -= (c.centroid.cross(c.normal) * c.volume + c.interface_moment) * k_n;
        stored += k_n * c.volume * c.depth;
        kv += k_n * c.volume;
        kvc += c.centroid * (k_n * c.volume);
        vol += c.volume;
        ktv += k_t * c.volume;
    }
    let f_el = force.norm();
    if f_el == 0.0 || kv == 0.0 {
        return None;
    }
    let n = force / f_el;
    let point = kvc / kv;
    let geometry = LayerContact::with_ball(&body, center, r)?;
    Some(PairElastic {
        elastic: Elastic { force: f_el, moment: moment - point.cross(force), stored },
        k_n: kv / vol,
        k_t: ktv / vol,
        max_depth: 0.0,
        contact: Some(LayerContact { normal: n, centroid: point, ..geometry }),
    })
}

fn layer_moduli(a: &Material, h_a: f64, b: &Material, h_b: f64, scale: f64) -> (f64, f64) {
    let e = |m: &Material| m.youngs_modulus * scale / (1.0 - m.poisson_ratio * m.poisson_ratio);
    let g = |m: &Material| m.shear_modulus() * scale;
    (1.0 / (h_a / e(a) + h_b / e(b)), 1.0 / (h_a / g(a) + h_b / g(b)))
}

/// `x y / (x + y)`, infinite masses allowed.
fn reduced(x: f64, y: f64) -> f64 {
    if x.is_infinite() {
        y
    } else if y.is_infinite() {
        x
    } else {
        x * y / (x + y)
    }
}

/// The elastic-layer contact law over one substep (`polytope.rs`). Normal: the layer's
/// elastic force `k_n V` at the overlap centroid, minus a dashpot `c v_n` (`c` from the
/// coefficient of restitution and the incremental stiffness `k_n A`), never pulling.
/// Tangential: the shear layer `k_t A` with a dashpot, its elastic slip anchored to the
/// contact and capped by Coulomb's `mu F_n` (return mapping: at the cap the slip is set
/// to what the capped force needs). Torsion: the same with the layer's polar moment and
/// the cap `mu F_n r_mean`. Exact static friction: a stuck contact holds any force inside
/// the cone with no slip rate, independent of the substep.
/// The fraction of a layer force stored at stiffness `before` that stays in the layer at
/// stiffness `now`: all of it where the contact has grown, the remaining layer's share
/// where it has shrunk.
fn shrink(now: f64, before: f64) -> f64 {
    if before > now { now / before } else { 1.0 }
}

fn layer_force(law: &LayerLaw, lc: &LayerContact, v: Vec3, w: Vec3, stick: Stick, dt: f64) -> LayerOutcome {
    let n = lc.normal;
    let zeta = damping_ratio(law.restitution);
    // Normal.
    let k_inc = law.k_n * lc.area;
    let (f_el, m_el, mut stored) = match law.elastic {
        Some(e) => (e.force, e.moment, e.stored),
        None => (law.k_n * lc.volume * law.elastic_scale, Vec3::ZERO, law.k_n * lc.volume * lc.depth * law.elastic_scale),
    };
    let c_n = 2.0 * zeta * (k_inc * law.m_red).sqrt();
    let vn = v.dot(n);
    let trial = f_el - c_n * vn;
    let (f_n, mut dissipated, couple) = if trial > 0.0 {
        (trial, c_n * vn * vn * dt, m_el)
    } else {
        // The dashpot holds the layer at zero force: it unloads without doing work.
        (0.0, f_el * vn.max(0.0) * dt, Vec3::ZERO)
    };
    // Tangential: carry the elastic shear force into the current contact plane (keeping
    // its magnitude), add this substep's elastic increment, then the dashpot; Coulomb's
    // cap by radial return. Stored energy |F|^2 / (2 k) at the current stiffness.
    let k_t = law.k_t * lc.area;
    let c_t = 2.0 * zeta * (k_t * law.m_red).sqrt();
    let vt = v - n * vn;
    let mut shear = stick.shear - n * stick.shear.dot(n);
    let (len0, len1) = (stick.shear.norm(), shear.norm());
    if len1 > 0.0 {
        shear = shear * (len0 / len1 * shrink(k_t, stick.k_t));
    }
    let energy = |f: Vec3| if k_t > 0.0 { 0.5 * f.dot(f) / k_t } else { 0.0 };
    let before = energy(shear);
    if stick.k_t > 0.0 {
        dissipated += 0.5 * stick.shear.dot(stick.shear) / stick.k_t - before;
    }
    shear -= vt * (k_t * dt);
    let mut f_t = shear - vt * c_t;
    let cap = law.friction * f_n;
    if f_n == 0.0 || k_t == 0.0 {
        f_t = Vec3::ZERO;
        shear = Vec3::ZERO;
    } else if f_t.norm() > cap {
        // Sliding: Coulomb's slider in series with the layer (spring and dashpot in
        // parallel) carries the cap, `k e + c de/dt = cap`; the layer's elastic force
        // relaxes towards the cap (backward Euler), continuous with sticking at the
        // threshold and never beyond the larger of the cap and its previous value.
        f_t = f_t * (cap / f_t.norm());
        let carried = shear + vt * (k_t * dt);
        shear = (f_t * k_t + carried * (c_t / dt)) / (k_t + c_t / dt);
    }
    let after = energy(shear);
    dissipated += -f_t.dot(vt) * dt - (after - before);
    stored += after;
    // Torsion about the normal, the same with the layer's polar moment.
    let k_r = law.k_t * lc.polar_moment;
    let c_r = 2.0 * zeta * (k_r * law.i_red).sqrt();
    let spin = w.dot(n);
    let energy_r = |m: f64| if k_r > 0.0 { 0.5 * m * m / k_r } else { 0.0 };
    let carried = stick.torque * shrink(k_r, stick.k_r);
    let before_r = energy_r(carried);
    if stick.k_r > 0.0 {
        dissipated += 0.5 * stick.torque * stick.torque / stick.k_r - before_r;
    }
    let mut torque = carried - k_r * spin * dt;
    let mut m = torque - c_r * spin;
    let cap_r = law.friction * f_n * lc.mean_radius;
    if f_n == 0.0 || k_r == 0.0 {
        m = 0.0;
        torque = 0.0;
    } else if m.abs() > cap_r {
        m = cap_r * m.signum();
        let carried = torque + k_r * spin * dt;
        torque = (m * k_r + carried * (c_r / dt)) / (k_r + c_r / dt);
    }
    let after_r = energy_r(torque);
    dissipated += -m * spin * dt - (after_r - before_r);
    stored += after_r;
    LayerOutcome { force: n * f_n + f_t, moment: n * m + couple, stick: Stick { shear, torque, k_t, k_r, indent: stick.indent }, stored, dissipated }
}

/// The elastic-layer contact of one chunk pair over a substep: the key, the point of
/// action, the outcome on `a` (minus on `b`) and the force's work on the relative motion.
fn pair_layer_contact(solver: &ReferenceSolver, scene: &Scene, key: ContactKey, stick: Stick, ba: &OBox, bb: &OBox, dt: f64) -> Option<(ContactKey, Vec3, LayerOutcome, f64)> {
    let ContactKey::Pair(sa, ca, sb, cb) = key else { return None };
    if !ba.may_overlap(bb) {
        return None;
    }
    let material = |s: usize, c: usize| scene.material(&solver.structures[s].chunks[c].material);
    let pe = pair_elastic(ba, bb, material(sa, ca), material(sb, cb), scene.sim.stiffness_scale, stick.indent)?;
    // The indentation (crushed material) stays while the pair overlaps, and is forgotten
    // when they part (the pair then has no contact state): lowering it while they touch
    // would raise the stored energy without work.
    let Some(lc) = pe.contact else {
        let none = LayerOutcome { force: Vec3::ZERO, moment: Vec3::ZERO, stick: Stick { shear: Vec3::ZERO, torque: 0.0, k_t: 0.0, k_r: 0.0, ..stick }, stored: 0.0, dissipated: 0.0 };
        return Some((key, ba.center, none, 0.0));
    };
    let inertia = |s: usize, c: usize| {
        let r = solver.clusters[solver.chunks[s][c].cluster].rotation();
        lc.normal.dot((r * solver.structures[s].chunks[c].inertia * r.transpose()) * lc.normal)
    };
    let (ma, mb) = (solver.structures[sa].chunks[ca].mass, solver.structures[sb].chunks[cb].mass);
    let law = LayerLaw {
        k_n: pe.k_n,
        k_t: pe.k_t,
        restitution: scene.sim.contact_restitution,
        friction: scene.sim.contact_friction.unwrap_or(material(sa, ca).friction.min(material(sb, cb).friction)),
        m_red: ma * mb / (ma + mb),
        i_red: reduced(inertia(sa, ca), inertia(sb, cb)),
        elastic_scale: 1.0,
        elastic: Some(pe.elastic),
    };
    let p = lc.centroid;
    let _t_law = crate::profile::time(crate::profile::Stage::PairLaw);
    let (va, vb) = (solver.point_velocity(sa, ca, p), solver.point_velocity(sb, cb, p));
    let (wa, wb) = (solver.chunk_velocity(sa, ca).1, solver.chunk_velocity(sb, cb).1);
    let out = layer_force(&law, &lc, va - vb, wa - wb, stick, dt);
    let work = (out.force.dot(va - vb) + out.moment.dot(wa - wb)) * dt;
    Some((key, p, out, work))
}

/// The elastic layer between two chunks `a` and `b` (`polytope::field_cells`): the energy
/// `E = (E_a + E_b) / 2`, each `E_x = sum_f k''_f int s dV` over the overlap's cells
/// nearest the faces `f` of body `x` (its surface receded by `indent`), `k''_f` the
/// series stiffness of the two bodies' half-thicknesses along that face's normal
/// (`layer_thickness`). The
/// elastic force and moment are its exact gradient: per cell `k''_f V_f n_f` at the
/// cell's centroid (pushing the other body out), plus, where neighbouring cells differ
/// in stiffness, the interface integrals of `k'' s`, plus the torque of the stiffness
/// turning with the bodies (`dk''/dh = -k''^2 / E'`). Conservative and
/// continuous, independent of which chunk is `a`, and between two faces `k'' V` at the
/// centroid (the joint's stiffness). The contact normal is the force's direction; the
/// contact point is the stiffness-weighted centroid of the cells, and the area and
/// moments friction uses are the overlap's shadow along the normal.
struct PairElastic {
    elastic: Elastic,
    /// Effective normal and shear moduli per area (stiffness-weighted over the cells).
    k_n: f64,
    k_t: f64,
    max_depth: f64,
    /// The contact seen by friction and the dashpot (`None`: no force).
    contact: Option<LayerContact>,
}

fn pair_elastic(ba: &OBox, bb: &OBox, mat_a: &Material, mat_b: &Material, scale: f64, indent: f64) -> Option<PairElastic> {
    let t_overlap = crate::profile::time(crate::profile::Stage::PairOverlap);
    let overlap = pair_overlap(ba, bb);
    drop(t_overlap);
    let overlap = overlap?;
    pair_elastic_of(&overlap, ba, bb, mat_a, mat_b, scale, indent, true)
}

/// The overlap of two chunks (`None` when they do not overlap).
fn pair_overlap(ba: &OBox, bb: &OBox) -> Option<Polytope> {
    let overlap = polytope_of(ba, OWNER_A).intersect(&polytope_of(bb, OWNER_B));
    (!overlap.is_empty()).then_some(overlap)
}

/// `pair_elastic` on an overlap already computed (it does not depend on the
/// indentation); without `geometry`, only the elastic force and energy (no contact
/// geometry for friction).
#[allow(clippy::too_many_arguments)]
fn pair_elastic_of(overlap: &Polytope, ba: &OBox, bb: &OBox, mat_a: &Material, mat_b: &Material, scale: f64, indent: f64, geometry: bool) -> Option<PairElastic> {
    let (pa, pb) = (polytope_of(ba, OWNER_A), polytope_of(bb, OWNER_B));
    let e = |m: &Material| m.youngs_modulus * scale / (1.0 - m.poisson_ratio * m.poisson_ratio);
    let turning = |b: &OBox, n: Vec3| layer_thickness(b, n).1;
    // Force and moment (about the origin) on `a`, stored energy, weights.
    let (mut force, mut moment, mut stored) = (Vec3::ZERO, Vec3::ZERO, 0.0);
    let (mut kv, mut kvc, mut vol, mut ktv) = (0.0, Vec3::ZERO, 0.0, 0.0);
    let t_cells = crate::profile::time(crate::profile::Stage::PairCells);
    for (field, sign) in [(&pb, 1.0), (&pa, -1.0)] {
        // The other body, whose half-thickness along the field's normals turns with it.
        let (other, e_other) = if sign > 0.0 { (ba, e(mat_a)) } else { (bb, e(mat_b)) };
        for c in field_cells(overlap, field, indent) {
            let (k_n, k_t) = layer_moduli(mat_a, layer_thickness(ba, c.normal).0, mat_b, layer_thickness(bb, c.normal).0, scale);
            let w = 0.5 * k_n;
            let integral = c.volume * c.depth;
            // On the body the field pushes out (`a` for b's field, `b` for a's).
            let f = (c.normal * c.volume + c.interface_force) * w;
            let m = (c.centroid.cross(c.normal) * c.volume + c.interface_moment) * w + turning(other, c.normal) * (0.5 * k_n * k_n / e_other * integral);
            force += f * sign;
            moment += m * sign;
            stored += w * integral;
            kv += w * c.volume;
            kvc += c.centroid * (w * c.volume);
            vol += 0.5 * c.volume;
            ktv += 0.5 * k_t * c.volume;
        }
    }
    drop(t_cells);
    let f_el = force.norm();
    if f_el == 0.0 || kv == 0.0 {
        return Some(PairElastic { elastic: Elastic { force: 0.0, moment: Vec3::ZERO, stored: 0.0 }, k_n: 0.0, k_t: 0.0, max_depth: 0.0, contact: None });
    }
    let _t_geometry = crate::profile::time(crate::profile::Stage::PairGeometry);
    let n = force / f_el;
    let point = kvc / kv;
    let elastic = Elastic { force: f_el, moment: moment - point.cross(force), stored };
    if !geometry {
        return Some(PairElastic { elastic, k_n: kv / vol, k_t: ktv / vol, max_depth: 0.0, contact: None });
    }
    let (lo, hi) = overlap.faces.iter().flat_map(|f| f.vertices.iter()).map(|v| v.dot(n)).fold((f64::INFINITY, f64::NEG_INFINITY), |(lo, hi), x| (lo.min(x), hi.max(x)));
    let geometry = LayerContact::with_normal(overlap, n)?;
    Some(PairElastic { elastic, k_n: kv / vol, k_t: ktv / vol, max_depth: (hi - lo).max(0.0), contact: Some(LayerContact { centroid: point, ..geometry }) })
}

/// A chunk's (or impactor's) shape as a polytope.
fn polytope_of(b: &OBox, owner: Owner) -> Polytope {
    match &b.hull {
        Some(h) => Polytope::hull(h, b.center, b.rotation, owner),
        None => Polytope::cuboid(b.center, b.rotation, b.half, owner),
    }
}

/// The contact of one chunk pair over a substep, computed from the state at its start.
struct PairContact {
    key: ChunkPair,
    /// The pair's per-sample-point overlap offsets after this substep.
    offsets: Vec<(f64, Vec3)>,
    /// Chunk centres of `a` and `b` (world), the moment arms of the forces.
    centers: (Vec3, Vec3),
    /// Per engaged point: position, force on `a` (minus on `b`), energy stored and
    /// dissipated by the penalty contact, and the work of the force on the relative motion.
    points: Vec<(Vec3, Vec3, f64, f64, f64)>,
}

/// Penalty contact between two chunks of different clusters: the sample points of each
/// inside the other push it out along the other's face normal. `offsets` is the pair's
/// memory of pre-existing overlap (see the module docs of `contact.rs`).
fn pair_contact(
    solver: &ReferenceSolver,
    scene: &Scene,
    key: ChunkPair,
    offsets: Option<Vec<(f64, Vec3)>>,
    ba: &OBox,
    bb: &OBox,
    dt: f64,
) -> Option<PairContact> {
    if !ba.may_overlap(bb) {
        return None;
    }
    let (sa, ca, sb, cb) = key;
    let (na, nb) = (ba.sample_count(), bb.sample_count());
    let mut pairs: Vec<(usize, Vec3, Vec3, f64)> = ba.points_inside(bb).into_iter().map(|p| (p.index, p.point, p.normal, p.depth)).collect();
    pairs.extend(bb.points_inside(ba).into_iter().map(|p| (na + p.index, p.point, -p.normal, p.depth)));
    if pairs.is_empty() {
        return None;
    }
    let material = |s: usize, c: usize| scene.material(&solver.structures[s].chunks[c].material);
    let k_pair = contact_stiffness(material(sa, ca), ba, material(sb, cb), bb, bb.center - ba.center, scene.sim.stiffness_scale);
    let (ma, mb) = (solver.structures[sa].chunks[ca].mass, solver.structures[sb].chunks[cb].mass);
    let m_red = ma * mb / (ma + mb);
    let mu = scene.sim.contact_friction.unwrap_or(material(sa, ca).friction.min(material(sb, cb).friction));
    let mut entry = offsets.unwrap_or_else(|| vec![(f64::NAN, Vec3::ZERO); na + nb]);
    let mut inside = vec![false; na + nb];
    let mut effective = Vec::with_capacity(pairs.len());
    for &(i, p, n, depth) in &pairs {
        inside[i] = true;
        // A new contact (or the same point now pushed through a different face): a
        // point born deeper than one substep of approach could carry it was already
        // overlapping (residual deformation of chunks that were one cluster). Keep
        // that overlap as an offset instead of firing it as energy.
        if entry[i].0.is_nan() || entry[i].1.dot(n) < 0.99 {
            let va = solver.point_velocity(sa, ca, p);
            let vb = solver.point_velocity(sb, cb, p);
            let reach = 2.0 * (va - vb).dot(n).abs() * dt + 1e-9;
            entry[i] = (if depth > reach { depth } else { 0.0 }, n);
        }
        // The offset only ratchets down as the overlap relaxes.
        entry[i].0 = entry[i].0.min(depth);
        effective.push((p, n, depth - entry[i].0));
    }
    for (i, e) in entry.iter_mut().enumerate() {
        if !inside[i] {
            e.0 = f64::NAN;
        }
    }
    // A face pair engages ~10 points; deeper overlaps engage more. Never let the
    // pair exceed its face-pair stiffness (the stable-timestep assumption).
    let engaged = effective.iter().filter(|e| e.2 > 0.0).count();
    let k = k_pair / (engaged.max(FACE_PAIR_POINTS) as f64);
    let mut points = Vec::new();
    for (p, n, depth) in effective {
        if depth <= 0.0 {
            continue;
        }
        let va = solver.point_velocity(sa, ca, p);
        let vb = solver.point_velocity(sb, cb, p);
        let (f, stored, dissipated) = penalty_force(k, m_red, scene.sim.contact_restitution, mu, depth, n, va - vb, dt, engaged);
        points.push((p, f, stored, dissipated, f.dot(va - vb) * dt));
    }
    Some(PairContact { key, offsets: entry, centers: (solver.chunk_position(sa, ca), solver.chunk_position(sb, cb)), points })
}

/// The face of a chunk whose outward normal is within ~8 degrees of `dir`.
fn face_towards(faces: &[crate::structure::Face], dir: Vec3) -> Option<usize> {
    let best = (0..faces.len()).max_by(|&i, &j| faces[i].normal.dot(dir).total_cmp(&faces[j].normal.dot(dir)))?;
    (faces[best].normal.dot(dir) > 0.99).then_some(best)
}

fn select_with_descendants(sel: &ChunkSelector, scene: &Scene, s: usize) -> Vec<usize> {
    let body = &scene.bodies[s];
    let mut out = sel.select(body);
    let mut i = 0;
    while i < out.len() {
        for (k, c) in body.chunks.iter().enumerate() {
            if c.parent == Some(out[i]) && !out.contains(&k) {
                out.push(k);
            }
        }
        i += 1;
    }
    out
}

/// Two chunks in contact: (structure, chunk, structure, chunk).
type ChunkPair = (usize, usize, usize, usize);

/// `f64` ordered by `total_cmp`, for the Dijkstra heap.
#[derive(Clone, Copy, Debug)]
struct OrdF64(f64);
impl PartialEq for OrdF64 {
    fn eq(&self, o: &Self) -> bool {
        self.0.total_cmp(&o.0).is_eq()
    }
}
impl Eq for OrdF64 {}
impl PartialOrd for OrdF64 {
    fn partial_cmp(&self, o: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(o))
    }
}
impl Ord for OrdF64 {
    fn cmp(&self, o: &Self) -> std::cmp::Ordering {
        self.0.total_cmp(&o.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::math::Quat;

    fn cube(center: Vec3, rotation: Mat3, half: Vec3) -> OBox {
        OBox { center, rotation, half, hull: None }
    }

    /// A ball's elastic force and moment on a chunk are the gradient of the layer's energy,
    /// at a face, an edge and a corner of a non-cubic chunk (cells of different stiffness).
    #[test]
    fn the_ball_elastic_force_is_the_gradient_of_its_energy() {
        let (m, steel) = (crate::builders::oracle_concrete(None), crate::builders::elastic_steel());
        let half = Vec3::new(0.05, 0.08, 0.03);
        let r = Quat::from_axis_angle(Vec3::new(0.3, 1.0, -0.2).normalized(), 0.4).to_mat3();
        let chunk = cube(Vec3::new(0.01, -0.02, 0.03), r, half);
        let radius = 0.07;
        let at = |local: Vec3| chunk.center + r * local;
        let cases = [
            ("face", at(Vec3::new(0.01, 0.02, half.z + radius - 1e-3))),
            ("edge", at(Vec3::new(0.0, half.y, half.z) + Vec3::new(0.0, 1.0, 1.0).normalized() * (radius - 1e-3))),
            ("corner", at(half + Vec3::new(1.0, 1.0, 1.0).normalized() * (radius - 1e-3))),
            ("deep edge", at(Vec3::new(0.02, half.y, half.z) + Vec3::new(0.0, 1.0, 0.3).normalized() * (radius - 0.02))),
        ];
        for (label, ball) in cases {
            let energy = |b: &OBox| ball_elastic(b, &m, ball, radius, &steel, 1.0).map_or(0.0, |p| p.elastic.stored);
            let pe = ball_elastic(&chunk, &m, ball, radius, &steel, 1.0).expect(label);
            let lc = pe.contact.expect(label);
            let force = lc.normal * pe.elastic.force;
            let torque = (lc.centroid - chunk.center).cross(force) + pe.elastic.moment;
            // (the energy carries ~1e-9 relative round-off from shallow solid angles: a step
            // well above it, well below the 1e-3 overlap; truncation and round-off of the
            // differences both stay under 1e-4)
            let d = 1e-6;
            for k in 0..3 {
                let mut e = Vec3::ZERO;
                e[k] = 1.0;
                let shifted = |s: f64| cube(chunk.center + e * s, chunk.rotation, chunk.half);
                let grad = (energy(&shifted(d)) - energy(&shifted(-d))) / (2.0 * d);
                let turned = |s: f64| cube(chunk.center, Quat::from_axis_angle(e, s).to_mat3() * chunk.rotation, chunk.half);
                let grad_r = (energy(&turned(d)) - energy(&turned(-d))) / (2.0 * d);
                let scale = force.norm();
                assert!((force[k] + grad).abs() < 1e-4 * scale, "{label}: force {k}: {} vs -dE/dx {}", force[k], -grad);
                assert!((torque[k] + grad_r).abs() < 1e-4 * scale * 0.1, "{label}: torque {k}: {} vs -dE/dtheta {}", torque[k], -grad_r);
            }
        }
    }

    /// The same over random relative poses of two cubes just overlapping (a face, an
    /// edge or a corner of either in the other).
    #[test]
    fn the_pair_elastic_force_is_the_gradient_of_its_energy_anywhere() {
        let m = crate::builders::oracle_concrete(None);
        let h = Vec3::splat(0.05);
        let b = cube(Vec3::ZERO, Mat3::IDENTITY, h);
        let mut seed = 0x2545_f491_4f6c_dd1du64;
        let mut rnd = || {
            seed = seed.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
            (seed >> 11) as f64 / (1u64 << 53) as f64 - 0.5
        };
        let mut worst = (0.0, String::new());
        for i in 0..500 {
            let axis = Vec3::new(rnd(), rnd(), rnd()).normalized();
            let r = Quat::from_axis_angle(axis, 2.0 * rnd()).to_mat3();
            let dir = Vec3::new(rnd(), rnd(), rnd()).normalized();
            // Place a so its support towards b's centre just overlaps.
            let mut lo = 0.0;
            let mut hi = 0.3;
            for _ in 0..60 {
                let mid = 0.5 * (lo + hi);
                let a = cube(dir * mid, r, h);
                if pair_elastic(&a, &b, &m, &m, 1.0, 0.0).map_or(false, |p| p.elastic.stored > 0.0) { lo = mid; } else { hi = mid; }
            }
            let depth = 1e-4 * (rnd() + 0.6);
            let a = cube(dir * (lo - depth), r, h);
            let energy = |a: &OBox| pair_elastic(a, &b, &m, &m, 1.0, 0.0).map_or(0.0, |p| p.elastic.stored);
            let Some(pe) = pair_elastic(&a, &b, &m, &m, 1.0, 0.0) else { continue };
            let Some(lc) = pe.contact else { continue };
            let force = lc.normal * pe.elastic.force;
            let torque = (lc.centroid - a.center).cross(force) + pe.elastic.moment;
            let d = 1e-10;
            let mut err: f64 = 0.0;
            for k in 0..3 {
                let mut e = Vec3::ZERO;
                e[k] = 1.0;
                let shifted = |s: f64| cube(a.center + e * s, a.rotation, a.half);
                let grad = (energy(&shifted(d)) - energy(&shifted(-d))) / (2.0 * d);
                let turned = |s: f64| cube(a.center, Quat::from_axis_angle(e, s).to_mat3() * a.rotation, a.half);
                let grad_r = (energy(&turned(d)) - energy(&turned(-d))) / (2.0 * d);
                err = err.max((force[k] + grad).abs() / force.norm()).max((torque[k] + grad_r).abs() / (force.norm() * 0.05));
            }
            if err > worst.0 {
                worst = (err, format!("i {i} err {err:.3e} dir {dir:?} axis {axis:?} F {force:?} T {torque:?} E {:.3e}", energy(&a)));
            }
        }
        assert!(worst.0 < 1e-4, "{}", worst.1);
    }

    /// The pair contact's elastic force and moment are the exact gradient of its stored
    /// energy (finite differences of the energy under translations and rotations of
    /// `a`), in configurations where the overlap reaches faces, edges and corners.
    #[test]
    fn the_pair_elastic_force_is_the_gradient_of_its_energy() {
        let m = crate::builders::oracle_concrete(None);
        let h = Vec3::splat(0.05);
        let tilt = |axis: Vec3, angle: f64| Quat::from_axis_angle(axis.normalized(), angle).to_mat3();
        let b = cube(Vec3::ZERO, Mat3::IDENTITY, h);
        let cases = [
            // Face on face, overhanging an edge.
            ("face overhang", cube(Vec3::new(0.03, 0.01, 0.0999), Mat3::IDENTITY, h)),
            // Tilted: an edge pressed into the face, overhanging.
            ("edge into face", cube(Vec3::new(0.02, -0.01, 0.0995), tilt(Vec3::new(1.0, 0.3, 0.0), 0.02), h)),
            // A corner into a face.
            ("corner into face", {
                // The cube's diagonal (1, 1, 1) turned to point down, a corner 4e-4 deep.
                let d = Vec3::new(1.0, 1.0, 1.0).normalized();
                let axis = d.cross(-Vec3::Z);
                let r = tilt(axis, (-d.z).acos()) * tilt(Vec3::new(0.3, 0.1, 1.0), 0.0);
                let r = tilt(Vec3::new(1.0, 2.0, 0.0), 0.05) * r;
                let low = (0..8).map(|i| {
                    let v = Vec3::new(if i & 1 == 0 { -1.0 } else { 1.0 }, if i & 2 == 0 { -1.0 } else { 1.0 }, if i & 4 == 0 { -1.0 } else { 1.0 });
                    (r * v.mul_elem(h)).z
                }).fold(f64::INFINITY, f64::min);
                cube(Vec3::new(0.01, 0.02, 0.05 - 4e-4 - low), r, h)
            }),
            // Edge against edge.
            ("edge on edge", cube(Vec3::new(0.0995, 0.0, 0.0995), tilt(Vec3::new(0.2, 1.0, 0.1), 0.01), h)),
        ];
        for (label, a) in cases {
            let energy = |a: &OBox| pair_elastic(a, &b, &m, &m, 1.0, 0.0).map_or(0.0, |p| p.elastic.stored);
            let pe = pair_elastic(&a, &b, &m, &m, 1.0, 0.0).expect(label);
            let lc = pe.contact.expect(label);
            let force = lc.normal * pe.elastic.force;
            let torque = (lc.centroid - a.center).cross(force) + pe.elastic.moment;
            let e0 = energy(&a);
            assert!(e0 > 0.0, "{label}");
            let d = 1e-9;
            for k in 0..3 {
                let mut e = Vec3::ZERO;
                e[k] = 1.0;
                let shifted = |s: f64| cube(a.center + e * s, a.rotation, a.half);
                let grad = (energy(&shifted(d)) - energy(&shifted(-d))) / (2.0 * d);
                let turned = |s: f64| cube(a.center, Quat::from_axis_angle(e, s).to_mat3() * a.rotation, a.half);
                let grad_r = (energy(&turned(d)) - energy(&turned(-d))) / (2.0 * d);
                let scale = force.norm();
                assert!((force[k] + grad).abs() < 1e-5 * scale, "{label}: force {k}: {} vs -dE/dx {}", force[k], -grad);
                assert!((torque[k] + grad_r).abs() < 1e-5 * scale * 0.1, "{label}: torque {k}: {} vs -dE/dtheta {}", torque[k], -grad_r);
            }
        }
    }
}
