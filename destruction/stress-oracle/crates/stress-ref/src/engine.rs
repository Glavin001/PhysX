//! Coupling the world to an external rigid-body engine (PhysX).
//!
//! A rigid-body engine treats every body as infinitely stiff: a contact instantly
//! involves the whole body's mass, and the body cannot change during the contact. That
//! is right when a contact lasts much longer than a stress wave takes to cross the body
//! and nothing breaks meanwhile — resting, stacking, sliding, slow pushes — and wrong
//! for a fast impact on something that breaks: only the struck region takes part, and
//! it breaks off within the contact. Fed the engine's impulse, the stress solver would
//! see the whole-body collision (a 40 m/s ram into a free wall hands over ~6x the real
//! impulse; see `stress-physx`).
//!
//! So the world partitions each frame:
//!
//! * **Impact islands** (`World::select_islands`): a pair of bodies about to touch is
//!   *owned* by the stress solve when the rigid assumption fails for it — the impact is
//!   shorter than a wave round trip across the struck body, or its predicted peak
//!   contact force exceeds the struck body's weakest bond. Owned pairs, plus every body
//!   whose swept bounds touch them during the frame, form an island. Islands are
//!   simulated by the world itself: chunk-level penalty contact on the stress substep,
//!   rigid motion, fracture during the contact (the validated reference physics). The
//!   engine holds island bodies still (kinematic) for the frame and is then given their
//!   end states. By construction nothing outside an island can touch it during the
//!   frame, so nothing is lost by freezing them.
//! * **Driven bodies** (everything else): the engine integrates them with all their
//!   contacts and with the impulses of the scripted loads (point forces, pressures,
//!   blasts, removal ramps). The stress solve follows their motion and takes their
//!   contact impulses through [`ContactLoadFilter`](crate::api::ContactLoadFilter).
//!
//! The engine is the single owner of a body's rigid motion except for the frames in
//! which that body is in an island; then the world is, and the engine is told.

use crate::math::{Pose, Vec3};

/// A body the engine simulates: a cluster of chunks or an impactor.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum BodyKey {
    /// A cluster, by its unique solver id.
    Cluster(u64),
    /// An impactor, by its index in the scene.
    Impactor(usize),
}

/// One box shape of a body, in the body frame.
#[derive(Clone, Copy, Debug)]
pub struct BoxShape {
    pub local: Pose,
    pub half_extents: Vec3,
    pub mass: f64,
    /// The chunk this shape is (structure, chunk); contacts on it are reported on it.
    pub chunk: Option<(usize, usize)>,
}

#[derive(Clone, Debug)]
pub enum BodyGeometry {
    Boxes(Vec<BoxShape>),
    Sphere { radius: f64, mass: f64 },
}

/// The desired state of one engine body; the engine creates or rebuilds the body when
/// `signature` changes (new chunk set, support state) and otherwise keeps its own
/// motion.
#[derive(Clone, Debug)]
pub struct EngineBody {
    pub key: BodyKey,
    pub signature: u64,
    pub geometry: BodyGeometry,
    /// Fixed in place (a cluster holding supported chunks).
    pub fixed: bool,
    /// Continuous collision detection (fast impactors).
    pub ccd: bool,
    /// Pose of the body frame, and velocity of the centre of mass (world).
    pub pose: Pose,
    pub velocity: Vec3,
    pub angular_velocity: Vec3,
}

/// Rigid state of an engine body: pose of the body frame, velocity of the centre of mass.
#[derive(Clone, Copy, Debug)]
pub struct BodyMotion {
    pub key: BodyKey,
    pub pose: Pose,
    pub velocity: Vec3,
    pub angular_velocity: Vec3,
}

/// A contact impulse the engine delivered to a chunk during its last step.
#[derive(Clone, Copy, Debug)]
pub struct EngineContact {
    pub structure: usize,
    pub chunk: usize,
    pub point: Vec3,
    /// Impulse on the chunk's body (N s, world).
    pub impulse: Vec3,
    /// The other body (None: static geometry such as the ground).
    pub other: Option<BodyKey>,
    /// Closing speed along the normal before the contact (m/s).
    pub approach_speed: f64,
}

/// What the world needs from a rigid-body engine.
pub trait RigidEngine {
    /// Name for reports ("physx-cpu").
    fn name(&self) -> &str;
    /// A static ground plane at height `z`.
    fn add_ground(&mut self, height: f64);
    /// Make the engine's bodies match `bodies` (the complete set): create new ones,
    /// rebuild those whose signature changed (with the given state), remove the rest.
    fn sync_bodies(&mut self, bodies: &[EngineBody]);
    /// Advance by `dt` with `frozen` bodies held still (kinematic, not integrated) and
    /// `impulses` (linear, angular about the centre of mass; world) applied to driven
    /// bodies at the start of the step. Returns the contact impulses on chunks.
    fn step(&mut self, dt: f64, frozen: &[BodyKey], impulses: &[(BodyKey, Vec3, Vec3)]) -> Vec<EngineContact>;
    /// Current motion of every body.
    fn motion(&self) -> Vec<BodyMotion>;
    /// Overwrite the motion of the given (frozen) bodies and release them.
    fn set_motion(&mut self, states: &[BodyMotion]);
}
