//! PhysX CPU as the world's rigid-body engine ([`RigidEngine`]).
//!
//! One PhysX body per world body (cluster or impactor). A cluster body carries one box
//! shape per chunk, so contacts are reported on the chunk they touch. Supported
//! clusters are fixed (kinematic in PhysX); island bodies are made kinematic for the
//! frames the world simulates them and are released with the world's end state.
//!
//! PhysX has no sphere shape in the backend's command set: a sphere impactor is a
//! 42-vertex geodesic hull scaled to the sphere's volume. While it flies, rolls or
//! rests the difference is a few percent of its radius in contact position; its
//! impacts on breakable bodies are island contacts, which the world resolves against
//! the true sphere.

use std::collections::HashMap;

use blast_stress_solver::backend::{
    BodyKind, BodyStateSoa, CommandBuffer, CommandResults, ContactBatch, CreateBody, CreateShape, Phase, PhysicsBackend,
    Pose as PxPose, Quat as PxQuat, ShapeGeom, SnapshotToken,
};
use blast_stress_solver::backends::physx_backend::{PhysXWorld, PxBodyId, PxShapeId};
use blast_stress_solver::types::Vec3 as PxVec3;
use stress_ref::engine::{BodyGeometry, BodyKey, BodyMotion, EngineBody, EngineContact, RigidEngine};
use stress_ref::math::{Pose, Quat, Vec3};

pub(crate) fn pv(v: Vec3) -> PxVec3 {
    PxVec3::new(v.x as f32, v.y as f32, v.z as f32)
}
pub(crate) fn rv(v: PxVec3) -> Vec3 {
    Vec3::new(v.x as f64, v.y as f64, v.z as f64)
}
pub(crate) fn pq(q: Quat) -> PxQuat {
    PxQuat::new(q.x as f32, q.y as f32, q.z as f32, q.w as f32)
}
pub(crate) fn rq(q: PxQuat) -> Quat {
    Quat { w: q.w as f64, x: q.x as f64, y: q.y as f64, z: q.z as f64 }.normalized()
}
fn px_pose(p: Pose) -> PxPose {
    PxPose::new(pv(p.position), pq(p.rotation))
}

/// Half thickness of the ground box (m): thick enough that nothing tunnels through it.
const GROUND_HALF_THICKNESS: f64 = 10.0;
/// Half width of the ground box (m).
const GROUND_HALF_WIDTH: f64 = 1000.0;

/// What a PhysX shape stands for.
#[derive(Clone, Copy, Debug)]
enum Owner {
    Body { key: BodyKey, chunk: Option<(usize, usize)> },
    Ground,
}

/// Shapes of a new body: (local pose, geometry, mass), the chunk each stands for, and
/// the centre of mass in the body frame.
type BodyShapes = (Vec<(Pose, ShapeGeom, f32)>, Vec<Option<(usize, usize)>>, Vec3);

struct Entry {
    id: PxBodyId,
    signature: u64,
    fixed: bool,
    shapes: Vec<PxShapeId>,
    /// Centre of mass in the body frame (from the shapes' masses).
    com: Vec3,
}

pub struct PhysxEngine {
    pub world: PhysXWorld,
    bodies: HashMap<BodyKey, Entry>,
    owners: HashMap<PxShapeId, Owner>,
    contacts: ContactBatch<PxShapeId>,
    /// Bodies currently held kinematic for an island.
    frozen: Vec<BodyKey>,
    /// Motion saved at the start of a frame that may be redone.
    saved: Option<SnapshotToken>,
}

impl PhysxEngine {
    /// A PhysX CPU scene with the given gravity; `None` if PhysX cannot be created.
    pub fn new(gravity: Vec3) -> Option<PhysxEngine> {
        Some(PhysxEngine {
            world: PhysXWorld::new_cpu(pv(gravity), 1)?,
            bodies: HashMap::new(),
            owners: HashMap::new(),
            contacts: ContactBatch::default(),
            frozen: Vec::new(),
            saved: None,
        })
    }

    /// The engine as a boxed [`RigidEngine`] for `World::with_engine`.
    pub fn boxed(gravity: Vec3) -> Option<Box<dyn RigidEngine>> {
        PhysxEngine::new(gravity).map(|e| Box::new(e) as Box<dyn RigidEngine>)
    }

    fn apply(&mut self, phase: Phase, cmd: &CommandBuffer<PxBodyId, PxShapeId>) -> CommandResults<PxBodyId, PxShapeId> {
        let mut out = CommandResults::default();
        self.world.apply(phase, cmd, &mut out).expect("PhysX accepts the command buffer");
        out
    }

    /// Create a body with `shapes` (local pose, geometry, mass) and return it with its
    /// shape ids.
    fn create(&mut self, pose: Pose, kind: BodyKind, ccd: bool, shapes: Vec<(Pose, ShapeGeom, f32)>) -> (PxBodyId, Vec<PxShapeId>) {
        let mut cmd = CommandBuffer::new();
        cmd.create_bodies.push(CreateBody {
            pose: px_pose(pose),
            kind,
            linvel: PxVec3::ZERO,
            angvel: PxVec3::ZERO,
            ccd,
            start_sleeping: false,
        });
        let body = self.apply(Phase::Topology, &cmd).created_bodies[0];
        let mut cmd = CommandBuffer::new();
        for (i, (local, geom, mass)) in shapes.into_iter().enumerate() {
            cmd.create_shapes.push(CreateShape { body, local: px_pose(local), geom, mass, node: i as u32 });
        }
        cmd.recompute_mass.push(body);
        let shapes = self.apply(Phase::Topology, &cmd).created_shapes;
        (body, shapes)
    }

    fn create_body(&mut self, b: &EngineBody) {
        let (shapes, chunks, com): BodyShapes = match &b.geometry {
            BodyGeometry::Boxes(boxes) => {
                let mass: f64 = boxes.iter().map(|s| s.mass).sum();
                let com = boxes.iter().fold(Vec3::ZERO, |a, s| a + s.local.position * s.mass) * (1.0 / mass.max(1e-300));
                (
                    boxes
                        .iter()
                        .map(|s| {
                            let geom = match &s.hull {
                                Some(points) => ShapeGeom::ConvexHull { points: points.iter().map(|p| pv(*p)).collect() },
                                None => ShapeGeom::Cuboid { half_extents: pv(s.half_extents) },
                            };
                            (s.local, geom, s.mass as f32)
                        })
                        .collect(),
                    boxes.iter().map(|s| s.chunk).collect(),
                    com,
                )
            }
            BodyGeometry::Sphere { radius, mass } => {
                let points = sphere_hull(*radius).into_iter().map(pv).collect();
                (vec![(Pose::default(), ShapeGeom::ConvexHull { points }, *mass as f32)], vec![None], Vec3::ZERO)
            }
        };
        let kind = if b.fixed { BodyKind::Fixed } else { BodyKind::Dynamic };
        let (id, shape_ids) = self.create(b.pose, kind, b.ccd, shapes);
        for (s, chunk) in shape_ids.iter().zip(chunks) {
            self.owners.insert(*s, Owner::Body { key: b.key, chunk });
        }
        if !b.fixed {
            // Never asleep: a sleeping body reports no contacts, and a resting body's
            // support reactions are loads the stress solve must keep seeing.
            let mut cmd = CommandBuffer::new();
            cmd.set_velocity.push((id, pv(b.velocity), pv(b.angular_velocity)));
            cmd.set_sleep_thresholds.push((id, 0.0, 0.0));
            self.apply(Phase::Motion, &cmd);
        }
        self.bodies.insert(b.key, Entry { id, signature: b.signature, fixed: b.fixed, shapes: shape_ids, com });
    }

    fn remove_body(&mut self, key: BodyKey) {
        if let Some(e) = self.bodies.remove(&key) {
            for s in &e.shapes {
                self.owners.remove(s);
            }
            let mut cmd = CommandBuffer::new();
            cmd.remove_bodies.push(e.id);
            self.apply(Phase::Retire, &cmd);
        }
        self.frozen.retain(|k| *k != key);
    }

    /// Pose, centre-of-mass velocity and angular velocity of the given bodies.
    fn read(&self, keys: &[BodyKey]) -> Vec<BodyMotion> {
        let ids: Vec<PxBodyId> = keys.iter().map(|k| self.bodies[k].id).collect();
        let mut st = BodyStateSoa::default();
        self.world.read_bodies(&ids, &mut st);
        keys.iter()
            .enumerate()
            .map(|(i, &key)| BodyMotion {
                key,
                pose: Pose::new(rv(st.pose[i].translation), rq(st.pose[i].rotation)),
                velocity: rv(st.linvel[i]),
                angular_velocity: rv(st.angvel[i]),
            })
            .collect()
    }

    /// Total linear momentum of the dynamic bodies.
    pub fn momentum(&self) -> Vec3 {
        let mut ids = Vec::new();
        self.world.for_each_dynamic_body(&mut |b| ids.push(b));
        let mut st = BodyStateSoa::default();
        self.world.read_bodies(&ids, &mut st);
        (0..ids.len()).map(|i| rv(st.linvel[i]) * st.mass[i] as f64).fold(Vec3::ZERO, |a, b| a + b)
    }

    /// Number of PhysX bodies (ground excluded).
    pub fn body_count(&self) -> usize {
        self.bodies.len()
    }
}

impl RigidEngine for PhysxEngine {
    fn name(&self) -> &str {
        "physx-cpu"
    }

    fn add_ground(&mut self, height: f64) {
        let center = Pose::new(Vec3::new(0.0, 0.0, height - GROUND_HALF_THICKNESS), Quat::IDENTITY);
        let half = Vec3::new(GROUND_HALF_WIDTH, GROUND_HALF_WIDTH, GROUND_HALF_THICKNESS);
        let (_, shapes) = self.create(center, BodyKind::Fixed, false, vec![(Pose::default(), ShapeGeom::Cuboid { half_extents: pv(half) }, 0.0)]);
        self.owners.insert(shapes[0], Owner::Ground);
    }

    fn sync_bodies(&mut self, bodies: &[EngineBody]) {
        let wanted: HashMap<BodyKey, &EngineBody> = bodies.iter().map(|b| (b.key, b)).collect();
        let stale: Vec<BodyKey> = self
            .bodies
            .iter()
            .filter(|(k, e)| wanted.get(k).is_none_or(|b| b.signature != e.signature || b.fixed != e.fixed))
            .map(|(k, _)| *k)
            .collect();
        for k in stale {
            self.remove_body(k);
        }
        let mut new: Vec<&EngineBody> = bodies.iter().filter(|b| !self.bodies.contains_key(&b.key)).collect();
        new.sort_by_key(|b| b.key);
        for b in new {
            self.create_body(b);
        }
    }

    fn step(&mut self, dt: f64, frozen: &[BodyKey], impulses: &[(BodyKey, Vec3, Vec3)]) -> Vec<EngineContact> {
        // Hold island bodies still; push the scripted loads' impulses into driven ones.
        let mut cmd = CommandBuffer::new();
        for k in frozen {
            if let Some(e) = self.bodies.get(k) {
                if !e.fixed {
                    cmd.set_body_kind.push((e.id, BodyKind::Kinematic));
                    self.frozen.push(*k);
                }
            }
        }
        for (k, lin, ang) in impulses {
            if let Some(e) = self.bodies.get(k) {
                cmd.apply_impulse.push((e.id, pv(*lin), pv(*ang)));
            }
        }
        self.apply(Phase::Motion, &cmd);

        // Start-of-step motion: the closing speed of a contact is a pre-contact quantity.
        let mut keys: Vec<BodyKey> = self.bodies.keys().copied().collect();
        keys.sort();
        let before: HashMap<BodyKey, (BodyMotion, Vec3)> =
            self.read(&keys).into_iter().map(|m| (m.key, (m, m.pose.transform_point(self.bodies[&m.key].com)))).collect();
        let point_velocity = |owner: Option<Owner>, p: Vec3| match owner {
            Some(Owner::Body { key, .. }) => before.get(&key).map_or(Vec3::ZERO, |(m, com)| m.velocity + m.angular_velocity.cross(p - *com)),
            _ => Vec3::ZERO,
        };

        self.world.step(dt as f32);
        self.world.drain_contacts(&mut self.contacts);

        // PhysX reports the impulse magnitude (as force over the step) and the normal
        // along which shape A is pushed out of shape B.
        let mut out = Vec::new();
        for c in &self.contacts.contacts {
            let n = rv(c.normal);
            let j = c.force as f64 * dt;
            if j <= 0.0 {
                continue;
            }
            let point = rv(c.world_position);
            let a = self.owners.get(&c.shape_a).copied();
            let b = c.shape_b.and_then(|s| self.owners.get(&s).copied());
            for (mine, other, push) in [(a, b, n), (b, a, -n)] {
                let Some(Owner::Body { chunk: Some((structure, chunk)), .. }) = mine else { continue };
                let other_key = match other {
                    Some(Owner::Body { key, .. }) => Some(key),
                    _ => None,
                };
                let closing = (point_velocity(other, point) - point_velocity(mine, point)).dot(push).max(0.0);
                out.push(EngineContact { structure, chunk, point, impulse: push * j, other: other_key, approach_speed: closing });
            }
        }
        out
    }

    fn motion(&self) -> Vec<BodyMotion> {
        let mut keys: Vec<BodyKey> = self.bodies.keys().copied().collect();
        keys.sort();
        self.read(&keys)
    }

    fn set_motion(&mut self, states: &[BodyMotion]) {
        let mut cmd = CommandBuffer::new();
        for s in states {
            let Some(e) = self.bodies.get(&s.key) else { continue };
            if e.fixed {
                continue;
            }
            cmd.set_body_kind.push((e.id, BodyKind::Dynamic));
            cmd.set_pose.push((e.id, px_pose(s.pose)));
            cmd.set_velocity.push((e.id, pv(s.velocity), pv(s.angular_velocity)));
            cmd.wake.push(e.id);
        }
        self.apply(Phase::Motion, &cmd);
        // Any frozen body the world did not hand back (it no longer exists there) is
        // released where it stands; the next sync removes it.
        let released: Vec<BodyKey> = states.iter().map(|s| s.key).collect();
        let mut cmd = CommandBuffer::new();
        for k in self.frozen.drain(..).filter(|k| !released.contains(k)) {
            if let Some(e) = self.bodies.get(&k) {
                cmd.set_body_kind.push((e.id, BodyKind::Dynamic));
            }
        }
        self.apply(Phase::Motion, &cmd);
    }

    fn save(&mut self) {
        self.discard();
        self.saved = Some(self.world.capture_motion(&[]).expect("PhysX motion snapshot"));
    }

    fn restore(&mut self) {
        // Kinematic bodies restore their pose only: release the frozen ones first.
        let mut cmd = CommandBuffer::new();
        for k in self.frozen.drain(..) {
            if let Some(e) = self.bodies.get(&k) {
                cmd.set_body_kind.push((e.id, BodyKind::Dynamic));
            }
        }
        self.apply(Phase::Motion, &cmd);
        if let Some(token) = self.saved.take() {
            self.world.restore_motion(token, &[]).expect("PhysX motion restore");
            self.world.release_snapshot(token);
        }
        self.world.drain_contacts(&mut self.contacts);
    }

    fn discard(&mut self) {
        if let Some(token) = self.saved.take() {
            self.world.release_snapshot(token);
        }
    }
}

/// Vertices of a geodesic sphere (icosahedron subdivided once: 42 vertices, 80 faces)
/// scaled so the hull has the sphere's volume.
fn sphere_hull(radius: f64) -> Vec<Vec3> {
    let t = (1.0 + 5f64.sqrt()) / 2.0;
    let mut v: Vec<Vec3> = [
        (-1.0, t, 0.0),
        (1.0, t, 0.0),
        (-1.0, -t, 0.0),
        (1.0, -t, 0.0),
        (0.0, -1.0, t),
        (0.0, 1.0, t),
        (0.0, -1.0, -t),
        (0.0, 1.0, -t),
        (t, 0.0, -1.0),
        (t, 0.0, 1.0),
        (-t, 0.0, -1.0),
        (-t, 0.0, 1.0),
    ]
    .iter()
    .map(|&(x, y, z)| Vec3::new(x, y, z).normalized())
    .collect();
    let faces: [[usize; 3]; 20] = [
        [0, 11, 5],
        [0, 5, 1],
        [0, 1, 7],
        [0, 7, 10],
        [0, 10, 11],
        [1, 5, 9],
        [5, 11, 4],
        [11, 10, 2],
        [10, 7, 6],
        [7, 1, 8],
        [3, 9, 4],
        [3, 4, 2],
        [3, 2, 6],
        [3, 6, 8],
        [3, 8, 9],
        [4, 9, 5],
        [2, 4, 11],
        [6, 2, 10],
        [8, 6, 7],
        [9, 8, 1],
    ];
    let mut mid: HashMap<(usize, usize), usize> = HashMap::new();
    let mut tris = Vec::new();
    for f in faces {
        let mut m = [0; 3];
        for e in 0..3 {
            let (a, b) = (f[e].min(f[(e + 1) % 3]), f[e].max(f[(e + 1) % 3]));
            m[e] = *mid.entry((a, b)).or_insert_with(|| {
                v.push(((v[a] + v[b]) * 0.5).normalized());
                v.len() - 1
            });
        }
        tris.extend([[f[0], m[0], m[2]], [f[1], m[1], m[0]], [f[2], m[2], m[1]], [m[0], m[1], m[2]]]);
    }
    let volume: f64 = tris.iter().map(|t| v[t[0]].dot(v[t[1]].cross(v[t[2]])).abs() / 6.0).sum();
    let scale = radius * (4.0 / 3.0 * std::f64::consts::PI / volume).cbrt();
    v.into_iter().map(|p| p * scale).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sphere_hull_has_the_sphere_volume() {
        let v = sphere_hull(1.0);
        assert_eq!(v.len(), 42);
        let r: Vec<f64> = v.iter().map(|p| p.norm()).collect();
        assert!(r.iter().all(|&x| (x - r[0]).abs() < 1e-12 && x > 1.0 && x < 1.05), "{r:?}");
    }
}
