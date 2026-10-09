//! Couples the reference stress solver to the PhysX CPU rigid-body engine.
//!
//! PhysX owns rigid motion and contact; the stress solver owns hidden deformation,
//! damage and fracture. Each frame:
//!
//! 1. PhysX steps; the cluster bodies' poses and velocities are read back.
//! 2. Contact forces on chunk shapes become contact impulses for the stress solver
//!    (`api::ContactImpulse`), which spreads impacts over a physical duration.
//! 3. The stress solver advances ([`EngineCoupledSolver`]) and reports fractures; each
//!    parent body is replaced by one PhysX body per child, created with the child's
//!    chunk shapes and the velocities the solver computed (`v + w x r` of the parent
//!    plus the hidden deformation velocity, momentum-exact).
//!
//! **Correction passes.** PhysX resolves a contact against the whole rigid body that
//! carries the struck chunk. If the structure breaks during the contact, that is the
//! wrong body: a ram punching through a wall exchanges momentum with the plug it
//! knocks out, not with the wall. So, as the native pipeline does
//! (`docs/destruction/RESIMULATION.md`, `POST_CORRECTION_FRACTURE.md`), a frame may be
//! re-solved: the motion is checkpointed, PhysX solves the tick (trial) and the stress
//! solver evaluates the trial's actual impulses on a copy of its state; if bonds break
//! and `correction_limit` allows, the motion is restored, the verdict is accepted at
//! the start of the tick (fragments installed with their exact momentum) and the tick
//! is solved again, so the contact now meets the fragment. The last pass's verdict is
//! applied at its final motion without another solve.
//!
//! The engine-side fracture application here is shared by any implementation of
//! [`StressSolverApi`]: swap the solver, keep this adapter.

use std::collections::HashMap;

pub mod engine;
pub use engine::PhysxEngine;
use engine::{pq, pv, rq, rv};

use blast_stress_solver::backend::{
    BodyKind, BodyStateSoa, CommandBuffer, CommandResults, ContactBatch, CreateBody, CreateShape, Phase,
    PhysicsBackend, Pose as PxPose, ShapeGeom,
};
use blast_stress_solver::backends::physx_backend::{PhysXWorld, PxBodyId, PxShapeId};
use blast_stress_solver::types::Vec3 as PxVec3;
use stress_ref::api::{ChildBody, ClusterId, ClusterMotion, ContactImpulse, EngineCoupledSolver, FrameInput, FrameOutput, StressSolverApi};
use stress_ref::solver::SolverEvent;
use stress_ref::math::{Pose, Quat, Vec3};
use stress_ref::scene::{ImpactorShape, Scene};

/// What a PhysX shape stands for.
#[derive(Clone, Copy, Debug)]
enum ShapeOwner {
    Chunk { structure: usize, chunk: usize },
    Impactor { index: usize },
}

/// A rigid impactor body (vehicle, projectile) living only in PhysX.
#[derive(Clone, Debug)]
pub struct ImpactorBody {
    pub name: String,
    pub body: PxBodyId,
    pub mass: f64,
    pub modulus: f64,
    pub radius: f64,
}

pub struct PhysxDestruction {
    pub world: PhysXWorld,
    pub stress: EngineCoupledSolver,
    pub impactors: Vec<ImpactorBody>,
    bodies: HashMap<ClusterId, PxBodyId>,
    owners: HashMap<PxShapeId, ShapeOwner>,
    body_mass: HashMap<PxBodyId, f64>,
    contacts: ContactBatch<PxShapeId>,
    /// Fractures applied so far.
    pub fractures: usize,
    /// Correction passes allowed per frame (the native `internalCorrectionLimit`):
    /// 0 never re-solves; N lets an impact break N failure fronts within one frame.
    /// Off by default: see `tests/physx_integration.rs` for what it does and does not
    /// fix (it cannot shorten a rigid contact, which hands over the whole-body impulse).
    pub correction_limit: usize,
    /// Correction passes used by the last frame.
    pub last_corrections: usize,
    /// Time window of a failure front: the longest wave transit across one chunk.
    pub front_window: f64,
    /// Contact impulses handed to the stress solver in the last frame, and their total.
    pub last_contact_count: usize,
    pub last_contact_impulse: f64,
}

impl PhysxDestruction {
    /// Build the PhysX scene for `scene`: one body per cluster (fixed if anchored) with a
    /// box shape per chunk, plus box impactors. `None` if PhysX cannot be created.
    pub fn new(scene: &Scene) -> Option<PhysxDestruction> {
        let world = PhysXWorld::new_cpu(pv(Vec3::from_array(scene.gravity)), 1)?;
        let stress = EngineCoupledSolver::new(scene);
        let mut s = PhysxDestruction {
            world,
            stress,
            impactors: Vec::new(),
            bodies: HashMap::new(),
            owners: HashMap::new(),
            body_mass: HashMap::new(),
            contacts: ContactBatch::default(),
            fractures: 0,
            correction_limit: 0,
            last_corrections: 0,
            front_window: chunk_transit_time(scene),
            last_contact_count: 0,
            last_contact_impulse: 0.0,
        };
        for child in s.stress.clusters() {
            s.create_cluster_body(&child);
        }
        for (index, d) in scene.impactors.iter().enumerate() {
            let half = match d.shape {
                ImpactorShape::Box { half_extents } => Vec3::from_array(half_extents),
                ImpactorShape::Sphere { radius } => Vec3::splat(radius),
            };
            let body = s.create_body(
                Pose::new(Vec3::from_array(d.position), Quat::from_wxyz(d.orientation)),
                BodyKind::Dynamic,
                Vec3::from_array(d.velocity),
                Vec3::from_array(d.angular_velocity),
                &[(Pose::default(), half, d.mass as f32)],
                // Fast projectiles would tunnel through thin walls in one frame.
                true,
            );
            s.owners.insert(body.1[0], ShapeOwner::Impactor { index });
            s.body_mass.insert(body.0, d.mass);
            let m = scene.material(&d.material);
            s.impactors.push(ImpactorBody {
                name: d.name.clone(),
                body: body.0,
                mass: d.mass,
                modulus: m.youngs_modulus,
                radius: half.min_elem(),
            });
        }
        Some(s)
    }

    /// Create a body with box shapes `(local pose, half extents, mass)`.
    fn create_body(&mut self, pose: Pose, kind: BodyKind, v: Vec3, w: Vec3, boxes: &[(Pose, Vec3, f32)], ccd: bool) -> (PxBodyId, Vec<PxShapeId>) {
        let mut cmd: CommandBuffer<PxBodyId, PxShapeId> = CommandBuffer::new();
        let mut out = CommandResults::default();
        cmd.create_bodies.push(CreateBody {
            pose: PxPose::new(pv(pose.position), pq(pose.rotation)),
            kind,
            linvel: PxVec3::ZERO,
            angvel: PxVec3::ZERO,
            ccd,
            start_sleeping: false,
        });
        self.world.apply(Phase::Topology, &cmd, &mut out).expect("create body");
        let body = out.created_bodies[0];
        let mut cmd: CommandBuffer<PxBodyId, PxShapeId> = CommandBuffer::new();
        let mut out = CommandResults::default();
        for (i, (local, half, mass)) in boxes.iter().enumerate() {
            cmd.create_shapes.push(CreateShape {
                body,
                local: PxPose::new(pv(local.position), pq(local.rotation)),
                geom: ShapeGeom::Cuboid { half_extents: pv(*half) },
                mass: *mass,
                node: i as u32,
            });
        }
        cmd.recompute_mass.push(body);
        self.world.apply(Phase::Topology, &cmd, &mut out).expect("create shapes");
        if kind == BodyKind::Dynamic {
            let mut cmd: CommandBuffer<PxBodyId, PxShapeId> = CommandBuffer::new();
            cmd.set_velocity.push((body, pv(v), pv(w)));
            self.world.apply(Phase::Motion, &cmd, &mut CommandResults::default()).expect("set velocity");
        }
        (body, out.created_shapes)
    }

    fn create_cluster_body(&mut self, child: &ChildBody) {
        let st = &self.stress.solver.structures[child.structure];
        let boxes: Vec<(Pose, Vec3, f32)> = child
            .chunks
            .iter()
            .map(|&c| {
                let ch = &st.chunks[c];
                let rot = rotation_of(&ch.rotation);
                (Pose::new(ch.center, rot), ch.half_extents, ch.mass as f32)
            })
            .collect();
        let pose = Pose::new(
            Vec3::new(child.pose[0], child.pose[1], child.pose[2]),
            Quat { w: child.pose[3], x: child.pose[4], y: child.pose[5], z: child.pose[6] },
        );
        let kind = if child.anchored { BodyKind::Fixed } else { BodyKind::Dynamic };
        let (body, shapes) = self.create_body(
            pose,
            kind,
            Vec3::from_array(child.velocity),
            Vec3::from_array(child.angular_velocity),
            &boxes,
            false,
        );
        for (shape, &chunk) in shapes.iter().zip(&child.chunks) {
            self.owners.insert(*shape, ShapeOwner::Chunk { structure: child.structure, chunk });
        }
        self.bodies.insert(child.id, body);
        self.body_mass.insert(body, if child.anchored { f64::INFINITY } else { child.mass });
    }

    /// Advance one frame of `dt`.
    pub fn step(&mut self, dt: f64) -> FrameOutput {
        let mut checkpoint = (self.correction_limit > 0).then(|| self.world.capture_motion(&[]).expect("motion snapshot"));
        let mut accepted = FrameOutput::default();
        let mut pass = 0;
        loop {
            self.world.step(dt as f32);
            let input = self.frame_input(dt);
            // Evaluate the trial's actual impulses on a copy of the stress state.
            let mut trial = self.stress.clone();
            let out = trial.step(&input);
            let verdict = self.failure_front(&out.events);
            if verdict.is_empty() || pass == self.correction_limit {
                self.stress = trial;
                for f in &out.fractures {
                    self.apply_fracture(f.parent, &f.children);
                }
                accepted.fractures.extend(out.fractures);
                accepted.events.extend(out.events);
                break;
            }
            // Correction: rewind the motion, accept the first failure front at the start
            // of the tick (fragments get their exact start-of-tick momentum), checkpoint
            // the tick again with the fragments, and re-solve.
            let token = checkpoint.take().expect("checkpoint taken when corrections are allowed");
            self.world.restore_motion(token, &[]).expect("restore motion");
            self.world.release_snapshot(token);
            let split = self.stress.accept_verdict(&verdict);
            for f in &split.fractures {
                self.apply_fracture(f.parent, &f.children);
            }
            checkpoint = Some(self.world.capture_motion(&[]).expect("motion snapshot"));
            accepted.fractures.extend(split.fractures);
            accepted.events.extend(split.events);
            pass += 1;
        }
        if let Some(token) = checkpoint {
            self.world.release_snapshot(token);
        }
        self.last_corrections = pass;
        accepted
    }

    /// The bonds of a trial that broke within one chunk wave-transit of the first: the
    /// failure front the trial's impulses are right about. Everything after it was
    /// computed with contacts against bodies that would no longer exist.
    fn failure_front(&self, events: &[SolverEvent]) -> Vec<(usize, usize)> {
        let broken: Vec<(f64, usize, usize)> = events
            .iter()
            .filter_map(|e| match e {
                SolverEvent::Broken { time, structure, bond, .. } => Some((*time, *structure, *bond)),
                _ => None,
            })
            .collect();
        let Some(first) = broken.iter().map(|b| b.0).reduce(f64::min) else { return Vec::new() };
        broken.iter().filter(|b| b.0 <= first + self.front_window).map(|b| (b.1, b.2)).collect()
    }

    /// The engine state after a PhysX step: cluster motion and contact impulses on chunks.
    fn frame_input(&mut self, dt: f64) -> FrameInput {
        // Rigid state of every cluster body, from PhysX.
        let ids: Vec<(ClusterId, PxBodyId)> = self.bodies.iter().map(|(c, b)| (*c, *b)).collect();
        let mut states = BodyStateSoa::default();
        self.world.read_bodies(&ids.iter().map(|x| x.1).collect::<Vec<_>>(), &mut states);
        let motion: Vec<ClusterMotion> = ids
            .iter()
            .enumerate()
            .map(|(i, (id, _))| ClusterMotion {
                id: *id,
                pose: Pose::new(rv(states.pose[i].translation), rq(states.pose[i].rotation)),
                velocity: rv(states.linvel[i]),
                angular_velocity: rv(states.angvel[i]),
            })
            .collect();

        // Contact forces on chunk shapes -> contact impulses.
        self.world.drain_contacts(&mut self.contacts);
        let mut contacts = Vec::new();
        for c in &self.contacts.contacts {
            let n = rv(c.normal);
            let j = c.force as f64 * dt;
            let closing = (-rv(c.relative_velocity).dot(n)).max(0.0);
            let other_of = |shape: Option<PxShapeId>| shape.and_then(|s| self.owners.get(&s).copied());
            for (mine, other, sign) in [(Some(c.shape_a), c.shape_b, -1.0), (c.shape_b, Some(c.shape_a), 1.0)] {
                let Some(ShapeOwner::Chunk { structure, chunk }) = other_of(mine) else { continue };
                let (other_mass, other_modulus, other_radius) = match other_of(other) {
                    Some(ShapeOwner::Impactor { index }) => {
                        let imp = &self.impactors[index];
                        (imp.mass, imp.modulus, imp.radius)
                    }
                    Some(ShapeOwner::Chunk { structure: s2, chunk: c2 }) => {
                        let ch = &self.stress.solver.structures[s2].chunks[c2];
                        (ch.mass, 3e10, ch.half_extents.min_elem())
                    }
                    None => (f64::INFINITY, 3e10, 1.0),
                };
                contacts.push(ContactImpulse {
                    structure,
                    chunk,
                    point: rv(c.world_position),
                    impulse: n * (sign * j),
                    other_mass,
                    approach_speed: closing,
                    other_modulus,
                    other_radius,
                    crush: None,
                });
            }
        }
        self.last_contact_count = contacts.len();
        self.last_contact_impulse = contacts.iter().map(|c| c.impulse.norm()).sum();
        FrameInput { dt, motion, contacts }
    }

    /// Replace the parent body by one body per child.
    fn apply_fracture(&mut self, parent: ClusterId, children: &[ChildBody]) {
        if let Some(body) = self.bodies.remove(&parent) {
            let mut cmd: CommandBuffer<PxBodyId, PxShapeId> = CommandBuffer::new();
            cmd.remove_bodies.push(body);
            self.world.apply(Phase::Retire, &cmd, &mut CommandResults::default()).expect("remove parent");
            self.body_mass.remove(&body);
        }
        for child in children {
            self.create_cluster_body(child);
        }
        self.fractures += 1;
    }

    /// Total linear momentum of every dynamic PhysX body.
    pub fn momentum(&self) -> Vec3 {
        let mut ids = Vec::new();
        self.world.for_each_dynamic_body(&mut |b| ids.push(b));
        let mut states = BodyStateSoa::default();
        self.world.read_bodies(&ids, &mut states);
        (0..ids.len()).map(|i| rv(states.linvel[i]) * states.mass[i] as f64).fold(Vec3::ZERO, |a, b| a + b)
    }

    /// Number of PhysX bodies standing for clusters of the structure.
    pub fn cluster_bodies(&self) -> usize {
        self.bodies.len()
    }

    /// Pose and velocity of an impactor.
    pub fn impactor_state(&self, index: usize) -> (Vec3, Vec3) {
        let mut st = BodyStateSoa::default();
        self.world.read_bodies(&[self.impactors[index].body], &mut st);
        (rv(st.pose[0].translation), rv(st.linvel[0]))
    }
}

/// Longest time a bar wave takes to cross one chunk (along its largest dimension).
fn chunk_transit_time(scene: &Scene) -> f64 {
    let mut t: f64 = 0.0;
    for b in &scene.bodies {
        for c in &b.chunks {
            let m = scene.material(&c.material);
            let speed = (m.youngs_modulus * scene.sim.stiffness_scale / m.density).sqrt();
            let size = 2.0 * c.half_extents.iter().copied().fold(0.0, f64::max);
            t = t.max(size / speed);
        }
    }
    t
}

/// Unit quaternion of an orthonormal rotation matrix.
fn rotation_of(m: &stress_ref::math::Mat3) -> Quat {
    let a = &m.m;
    let tr = m.trace();
    let q = if tr > 0.0 {
        let s = (tr + 1.0).sqrt() * 2.0;
        Quat { w: 0.25 * s, x: (a[2][1] - a[1][2]) / s, y: (a[0][2] - a[2][0]) / s, z: (a[1][0] - a[0][1]) / s }
    } else if a[0][0] > a[1][1] && a[0][0] > a[2][2] {
        let s = (1.0 + a[0][0] - a[1][1] - a[2][2]).sqrt() * 2.0;
        Quat { w: (a[2][1] - a[1][2]) / s, x: 0.25 * s, y: (a[0][1] + a[1][0]) / s, z: (a[0][2] + a[2][0]) / s }
    } else if a[1][1] > a[2][2] {
        let s = (1.0 + a[1][1] - a[0][0] - a[2][2]).sqrt() * 2.0;
        Quat { w: (a[0][2] - a[2][0]) / s, x: (a[0][1] + a[1][0]) / s, y: 0.25 * s, z: (a[1][2] + a[2][1]) / s }
    } else {
        let s = (1.0 + a[2][2] - a[0][0] - a[1][1]).sqrt() * 2.0;
        Quat { w: (a[1][0] - a[0][1]) / s, x: (a[0][2] + a[2][0]) / s, y: (a[1][2] + a[2][1]) / s, z: 0.25 * s }
    };
    q.normalized()
}
