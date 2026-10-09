//! The scene format (`stress-scene/1`): the single description every solver runs.
//!
//! A scene is plain JSON. The reference solver loads it directly; each external
//! oracle has an exporter that turns the same file into that tool's input deck, so
//! both sides simulate the identical setup. Bond section properties and stiffnesses
//! are written into `derived` by [`Scene::with_derived`] for exporters that need
//! them; the solver recomputes them and ignores the field on load.
//!
//! Conventions: SI units, z-up (default gravity `[0, 0, -9.81]`), quaternions as
//! `[w, x, y, z]`. Chunk and bond geometry is in the owning body's frame.

use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

use crate::material::Material;
use crate::math::{Quat, Vec3};

pub const SCENE_FORMAT: &str = "stress-scene/1";

fn default_gravity() -> [f64; 3] {
    [0.0, 0.0, -9.81]
}
fn identity_quat() -> [f64; 4] {
    [1.0, 0.0, 0.0, 0.0]
}
fn default_true() -> bool {
    true
}

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Scene {
    pub format: String,
    pub name: String,
    #[serde(default)]
    pub description: String,
    /// The validation benchmark this scene belongs to (spec table number), if any.
    #[serde(default)]
    pub benchmark: Option<u32>,
    #[serde(default = "default_gravity")]
    pub gravity: [f64; 3],
    pub materials: BTreeMap<String, Material>,
    pub bodies: Vec<BodyDesc>,
    #[serde(default)]
    pub impactors: Vec<ImpactorDesc>,
    #[serde(default)]
    pub ground: Option<GroundDesc>,
    #[serde(default)]
    pub loads: Vec<LoadDesc>,
    #[serde(default)]
    pub events: Vec<EventDesc>,
    pub sim: SimDesc,
    #[serde(default)]
    pub probes: Vec<ProbeDesc>,
    #[serde(default)]
    pub metrics: Vec<MetricDesc>,
    /// Free-form per-oracle settings (mesh density, element formulation, ...), keyed by oracle name.
    #[serde(default)]
    pub oracle: BTreeMap<String, serde_json::Value>,
}

/// One rigid cluster of chunks: a single rigid body until fracture splits it.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct BodyDesc {
    pub name: String,
    #[serde(default)]
    pub position: [f64; 3],
    #[serde(default = "identity_quat")]
    pub orientation: [f64; 4],
    #[serde(default)]
    pub linear_velocity: [f64; 3],
    #[serde(default)]
    pub angular_velocity: [f64; 3],
    pub chunks: Vec<ChunkDesc>,
    pub bonds: Vec<BondDesc>,
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Support {
    #[default]
    None,
    /// All six degrees of freedom held.
    Fixed,
    /// Translations held, rotations free.
    Pinned,
}

/// A box-shaped chunk.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ChunkDesc {
    pub center: [f64; 3],
    pub half_extents: [f64; 3],
    #[serde(default = "identity_quat")]
    pub orientation: [f64; 4],
    pub material: String,
    #[serde(default)]
    pub support: Support,
    /// Named groups for selection (events, probes, metrics, exporters).
    #[serde(default)]
    pub groups: Vec<String>,
    /// Pre-fracture level: 0 is the coarse structural level.
    #[serde(default)]
    pub level: u32,
    /// The coarser chunk this one refines, for level > 0.
    #[serde(default)]
    pub parent: Option<usize>,
}

/// A bond between two touching chunks of the same body.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct BondDesc {
    pub a: usize,
    pub b: usize,
    /// Centre of the contact patch.
    pub centroid: [f64; 3],
    /// Unit normal of the contact patch, pointing from `a` to `b`.
    pub normal: [f64; 3],
    /// Unit tangent of the patch; `width[0]` is measured along it, `width[1]` along `normal x tangent`.
    pub tangent: [f64; 3],
    pub area: f64,
    pub width: [f64; 2],
    /// Material of the joint (strength, stiffness, fracture energy).
    pub material: String,
    #[serde(default)]
    pub rebar: Option<RebarSpec>,
    /// Effective (Euler) buckling length of the member this bond belongs to; enables the buckling cap.
    #[serde(default)]
    pub buckling_length: Option<f64>,
    #[serde(default)]
    pub level: u32,
    #[serde(default)]
    pub groups: Vec<String>,
    /// Exporter convenience, written by [`Scene::with_derived`]; ignored on load.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub derived: Option<serde_json::Value>,
}

/// Rebar crossing a bond: an elastic-plastic axial tie in parallel with the joint,
/// holding cracked concrete together until it ruptures.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct RebarSpec {
    /// Total steel cross-section crossing the joint (m^2).
    pub area: f64,
    /// Material supplying E, the yield stress (`tensile_strength`) and the rupture
    /// energy (`fracture_energy.tension`, per unit steel area).
    pub material: String,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case", deny_unknown_fields)]
pub enum ImpactorShape {
    Sphere { radius: f64 },
    Box { half_extents: [f64; 3] },
}

/// Crush law of a soft impactor (vehicle front, crate): the impactor's own
/// force-deformation curve, rigid-perfectly plastic. While its crushable energy lasts
/// the impactor deforms (its contact surface recedes) instead of transmitting more than
/// `max_force`; then it bottoms out and contacts with its material stiffness. This is a
/// material law of the impactor acting in its contact with the structure, not a cap on
/// rigid-body contacts in general. For vehicles the plateau force and the crush energy
/// (crush depth = energy / max_force) come from crash-test force-deformation curves;
/// EN 1991-1-7 Annex C idealises the same behaviour as an equivalent elastic stiffness
/// (`F = v sqrt(k m)`), which gives the same impulse with a different pulse shape.
#[derive(Clone, Copy, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct CrushDesc {
    pub max_force: f64,
    pub energy: f64,
}

/// A rigid, unbreakable projectile coupled to the stress solve through contact.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ImpactorDesc {
    pub name: String,
    pub shape: ImpactorShape,
    pub mass: f64,
    pub position: [f64; 3],
    #[serde(default = "identity_quat")]
    pub orientation: [f64; 4],
    pub velocity: [f64; 3],
    #[serde(default)]
    pub angular_velocity: [f64; 3],
    /// Material supplying the contact stiffness and friction.
    pub material: String,
    #[serde(default)]
    pub crush: Option<CrushDesc>,
}

/// Horizontal ground plane `z = height`.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct GroundDesc {
    pub height: f64,
    pub friction: f64,
    pub material: String,
}

/// Scalar function of time.
#[derive(Clone, Debug, Serialize, Deserialize, PartialEq)]
#[serde(tag = "type", rename_all = "snake_case", deny_unknown_fields)]
pub enum TimeFunction {
    Constant { value: f64 },
    /// 0 before `t0`, linear to `value` at `t1`, then held.
    Ramp { t0: f64, t1: f64, value: f64 },
    /// `peak * sin(pi (t - start)/duration)` on `[start, start + duration]`, else 0.
    HalfSine { start: f64, duration: f64, peak: f64 },
    /// Friedlander blast waveform `peak (1 - s) exp(-decay s)`, `s = (t - arrival)/duration`, for `0 <= s <= 1`.
    Friedlander { arrival: f64, peak: f64, duration: f64, decay: f64 },
    /// Piecewise-linear `[t, value]` table, clamped at both ends.
    Table { points: Vec<[f64; 2]> },
}

impl TimeFunction {
    pub fn eval(&self, t: f64) -> f64 {
        match *self {
            TimeFunction::Constant { value } => value,
            TimeFunction::Ramp { t0, t1, value } => {
                if t <= t0 {
                    0.0
                } else if t >= t1 {
                    value
                } else {
                    value * (t - t0) / (t1 - t0)
                }
            }
            TimeFunction::HalfSine { start, duration, peak } => {
                if t < start || t > start + duration {
                    0.0
                } else {
                    peak * (std::f64::consts::PI * (t - start) / duration).sin()
                }
            }
            TimeFunction::Friedlander { arrival, peak, duration, decay } => {
                let s = (t - arrival) / duration;
                if !(0.0..=1.0).contains(&s) {
                    0.0
                } else {
                    peak * (1.0 - s) * (-decay * s).exp()
                }
            }
            TimeFunction::Table { ref points } => {
                if points.is_empty() {
                    return 0.0;
                }
                if t <= points[0][0] {
                    return points[0][1];
                }
                for w in points.windows(2) {
                    if t <= w[1][0] {
                        let f = (t - w[0][0]) / (w[1][0] - w[0][0]).max(1e-300);
                        return w[0][1] + f * (w[1][1] - w[0][1]);
                    }
                }
                points[points.len() - 1][1]
            }
        }
    }
}

/// Axis-aligned box in a body frame.
#[derive(Clone, Copy, Debug, Serialize, Deserialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct Region {
    pub min: [f64; 3],
    pub max: [f64; 3],
}

impl Region {
    pub fn contains(&self, p: Vec3) -> bool {
        (0..3).all(|i| p[i] >= self.min[i] && p[i] <= self.max[i])
    }
}

/// Selects chunks of one body.
#[derive(Clone, Debug, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case", deny_unknown_fields)]
pub enum ChunkSelector {
    All,
    Group(String),
    Indices(Vec<usize>),
    /// Chunks whose centre lies in the region (body frame).
    Region(Region),
}

impl ChunkSelector {
    pub fn matches(&self, index: usize, chunk: &ChunkDesc) -> bool {
        match self {
            ChunkSelector::All => true,
            ChunkSelector::Group(g) => chunk.groups.iter().any(|x| x == g),
            ChunkSelector::Indices(v) => v.contains(&index),
            ChunkSelector::Region(r) => r.contains(Vec3::from_array(chunk.center)),
        }
    }
    pub fn select(&self, body: &BodyDesc) -> Vec<usize> {
        body.chunks.iter().enumerate().filter(|(i, c)| self.matches(*i, c)).map(|(i, _)| i).collect()
    }
}

/// Scripted external loads.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case", deny_unknown_fields)]
pub enum LoadDesc {
    /// Force (world-frame direction, magnitude `magnitude(t)`) on a chunk, applied at
    /// `point` (body frame; default the chunk centre).
    PointForce {
        body: String,
        chunk: usize,
        direction: [f64; 3],
        magnitude: TimeFunction,
        #[serde(default)]
        point: Option<[f64; 3]>,
    },
    /// Uniform pressure on the exposed faces of the selected chunks whose outward
    /// normal (body frame) matches `face_normal`. Positive pressure pushes into the face.
    Pressure { body: String, chunks: ChunkSelector, face_normal: [f64; 3], pressure: TimeFunction },
    /// Free-air spherical charge: empirical pressure-time pulse on every exposed face,
    /// with distance falloff, angle of incidence, shadowing and clearing (venting).
    Blast { position: [f64; 3], tnt_mass: f64, time: f64 },
}

/// Scripted structural changes.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case", deny_unknown_fields)]
pub enum EventDesc {
    /// Remove chunks from a structure (e.g. a column). At `time` the forces their bonds
    /// exert on the rest are replaced by equal external forces, which ramp to zero over
    /// `duration` (0 = sudden removal). The alternate-path procedure of GSA/UFC 4-023-03.
    RemoveChunks { time: f64, duration: f64, body: String, chunks: ChunkSelector },
    /// Remove supports, with the same force-replacement ramp.
    RemoveSupports { time: f64, duration: f64, body: String, chunks: ChunkSelector },
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SolveMode {
    /// Explicit central-difference substeps everywhere, every frame (ground truth).
    #[default]
    Explicit,
    /// Explicit for recently loaded clusters, quasi-static for settled ones, sleep when idle.
    Adaptive,
    /// Quasi-static equilibrium every frame with same-step cascade (no inertia in the stress solve).
    QuasiStatic,
    /// One implicit Newmark (average acceleration) step per frame: inertia and true
    /// stiffness at the frame step; failures cascade over steps (see `implicit.rs`).
    Implicit,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SimDesc {
    pub duration: f64,
    #[serde(default = "default_frame_dt")]
    pub frame_dt: f64,
    /// Multiplier on every Young's and shear modulus (<= 1 lowers the cost of the explicit solve).
    #[serde(default = "default_one")]
    pub stiffness_scale: f64,
    #[serde(default)]
    pub seed: u64,
    #[serde(default)]
    pub solve_mode: SolveMode,
    /// Settle every structure under gravity (static equilibrium) before t = 0.
    #[serde(default = "default_true")]
    pub gravity_prestress: bool,
    /// Fraction of the critical explicit timestep used.
    #[serde(default = "default_courant")]
    pub courant_safety: f64,
    /// Upper bound on the substep (for timestep-convergence studies).
    #[serde(default)]
    pub max_substep: Option<f64>,
    /// Allow damage and fracture (false = linear elastic).
    #[serde(default = "default_true")]
    pub fracture: bool,
    /// Probe sampling interval (defaults to `frame_dt`).
    #[serde(default)]
    pub sample_interval: Option<f64>,
    /// Multi-level pre-fracture: refine a coarse chunk when a bond touching it exceeds
    /// this utilization (None disables refinement; level-0 only).
    #[serde(default)]
    pub refine_utilization: Option<f64>,
    /// Coefficient of restitution of every penalty contact (sets the contact dashpot).
    #[serde(default = "default_restitution")]
    pub contact_restitution: f64,
    /// Contact friction: the smaller of the two materials' `friction`, unless overridden.
    #[serde(default)]
    pub contact_friction: Option<f64>,
    /// Selective mass scaling (explicit solve): chunks whose stable substep is below
    /// this get extra deformation inertia to reach it (an alternative to lowering
    /// `stiffness_scale`; see `ReferenceSolver::apply_mass_scaling`).
    #[serde(default)]
    pub mass_scaling_dt: Option<f64>,
    /// `SolveMode::Implicit`: the implicit step (defaults to `frame_dt`). It must resolve
    /// the periods whose dynamics matter (about 10 steps per period for a few percent).
    #[serde(default)]
    pub implicit_dt: Option<f64>,
    /// Model capabilities (all on by default); switch one off to see what it contributes.
    #[serde(default)]
    pub features: Features,
}

/// Switches for the model's capabilities, all on by default.
///
/// Each switch removes one mechanism and leaves the others unchanged, so running a scene
/// with and without it shows what that mechanism contributes. A switch only disables
/// what the scene's materials provide (e.g. `rate_effects` does nothing for a material
/// without a DIF). Inertia in the stress solve is selected by [`SolveMode`].
#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Features {
    /// Strength rises with loading rate (dynamic increase factor).
    pub rate_effects: bool,
    /// Delayed failure under sustained load (static fatigue).
    pub static_fatigue: bool,
    /// Per-bond Weibull strengths (off: every bond at the mean strength).
    pub weibull: bool,
    /// Fracture-energy softening (off: a bond breaks the instant it reaches its
    /// strength and releases all its stored energy, like a threshold model).
    pub softening: bool,
    /// Cracked joints keep carrying compression and friction through a no-tension
    /// contact patch (off: the cracked share of a joint carries nothing).
    pub crack_contact: bool,
    /// Compressive crushing of bonds (off: unlimited compressive strength, as in an
    /// elastic continuum without a crushing law).
    pub crushing: bool,
    /// Euler buckling cap on bonds of slender members.
    pub buckling: bool,
    /// Rebar crossing bonds.
    pub rebar: bool,
    /// Inertial loads of a cluster's rigid motion on its chunks (linear, angular,
    /// centrifugal, Coriolis); off, chunks feel only applied loads, as if the cluster
    /// were at rest.
    pub rigid_motion_loads: bool,
    /// Blast: faces behind other chunks receive only the diffracted pressure.
    pub blast_shadowing: bool,
    /// Blast: reflected pressure clears from the free edges (and from new holes).
    pub blast_clearing: bool,
    /// Bond dashpots (light stiffness-proportional damping).
    pub damping: bool,
}

impl Default for Features {
    fn default() -> Self {
        Features {
            rate_effects: true,
            static_fatigue: true,
            weibull: true,
            softening: true,
            crack_contact: true,
            crushing: true,
            buckling: true,
            rebar: true,
            rigid_motion_loads: true,
            blast_shadowing: true,
            blast_clearing: true,
            damping: true,
        }
    }
}

impl Features {
    /// Names of every switch, in declaration order.
    pub const NAMES: [&'static str; 12] = [
        "rate_effects",
        "static_fatigue",
        "weibull",
        "softening",
        "crack_contact",
        "crushing",
        "buckling",
        "rebar",
        "rigid_motion_loads",
        "blast_shadowing",
        "blast_clearing",
        "damping",
    ];

    /// Set a switch by name.
    pub fn set(&mut self, name: &str, on: bool) -> Result<(), String> {
        let slot = match name {
            "rate_effects" => &mut self.rate_effects,
            "static_fatigue" => &mut self.static_fatigue,
            "weibull" => &mut self.weibull,
            "softening" => &mut self.softening,
            "crack_contact" => &mut self.crack_contact,
            "crushing" => &mut self.crushing,
            "buckling" => &mut self.buckling,
            "rebar" => &mut self.rebar,
            "rigid_motion_loads" => &mut self.rigid_motion_loads,
            "blast_shadowing" => &mut self.blast_shadowing,
            "blast_clearing" => &mut self.blast_clearing,
            "damping" => &mut self.damping,
            _ => return Err(format!("unknown feature '{name}' (known: {})", Self::NAMES.join(", "))),
        };
        *slot = on;
        Ok(())
    }
}

fn default_restitution() -> f64 {
    0.2
}

fn default_frame_dt() -> f64 {
    1.0 / 60.0
}
fn default_one() -> f64 {
    1.0
}
fn default_courant() -> f64 {
    0.5
}

impl Default for SimDesc {
    fn default() -> Self {
        SimDesc {
            duration: 1.0,
            frame_dt: default_frame_dt(),
            stiffness_scale: 1.0,
            seed: 0,
            solve_mode: SolveMode::Explicit,
            gravity_prestress: true,
            courant_safety: default_courant(),
            max_substep: None,
            fracture: true,
            sample_interval: None,
            refine_utilization: None,
            contact_restitution: default_restitution(),
            contact_friction: None,
            implicit_dt: None,
            mass_scaling_dt: None,
            features: Features::default(),
        }
    }
}

/// Generalised force component across a section.
#[derive(Clone, Debug, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case", deny_unknown_fields)]
pub enum SectionComponent {
    /// Force along the section normal (tension positive).
    Normal,
    /// Force along `axis`.
    Force([f64; 3]),
    /// Moment about `axis` through the section point.
    Moment([f64; 3]),
}

/// A measured quantity, sampled over time. Directions are world-frame unless noted.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case", deny_unknown_fields)]
pub enum ProbeKind {
    /// Displacement of a chunk centre from its initial position, along `axis`.
    ChunkDisplacement { body: String, chunk: usize, axis: [f64; 3] },
    ChunkVelocity { body: String, chunk: usize, axis: [f64; 3] },
    /// Internal force across the plane through `point` with `normal` (body frame),
    /// restricted to bonds whose centroid lies in `region`. Acts on the `+normal` side.
    SectionForce { body: String, point: [f64; 3], normal: [f64; 3], region: Option<Region>, component: SectionComponent },
    /// Sum of the support reactions of the selected chunks, along `axis`.
    Reaction { body: String, chunks: ChunkSelector, axis: [f64; 3] },
    ImpactorVelocity { impactor: String, axis: [f64; 3] },
    ImpactorPosition { impactor: String, axis: [f64; 3] },
}

#[derive(Clone, Debug, Serialize, Deserialize)]
// `flatten` cannot be combined with `deny_unknown_fields`.
pub struct ProbeDesc {
    pub name: String,
    #[serde(flatten)]
    pub kind: ProbeKind,
}

/// How a metric is compared against an oracle.
#[derive(Clone, Copy, Debug, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case", deny_unknown_fields)]
pub enum Tolerance {
    /// `|ours - oracle| <= rel * |oracle|`.
    Relative(f64),
    Absolute(f64),
    /// Booleans and categories must be equal.
    Exact,
    /// Recorded, not gated.
    Report,
}

/// Quantities derived from an observation (probe series plus final chunk states).
/// Computed by the same code for every solver (see `metrics.rs`).
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case", deny_unknown_fields)]
pub enum MetricKind {
    ProbeFinal { probe: String },
    /// Max |value| over the run (the solver tracks it every substep).
    ProbePeak { probe: String },
    /// Largest / smallest value over the run (signed, envelope-aware).
    ProbeMax { probe: String },
    ProbeMin { probe: String },
    /// Max |value| of `probe` over max |value| of `reference`.
    ProbePeakRatioOf { probe: String, reference: String },
    /// `distance / (t_b - t_a)` where `t_x` is the first time |probe x| reaches `threshold`.
    WaveSpeed { probe_a: String, probe_b: String, distance: f64, threshold: f64 },
    /// Max |value| over the run divided by |value| at `reference_time`.
    ProbePeakRatio { probe: String, reference_time: f64 },
    /// Value at a time (linear interpolation of samples).
    ProbeAt { probe: String, time: f64 },
    /// First time |value| reaches `threshold`.
    ProbeArrival { probe: String, threshold: f64 },
    /// Dominant frequency (Hz) of the probe about its mean after `after`, from zero crossings.
    ProbeFrequency { probe: String, after: f64 },
    /// Initial minus final value.
    ProbeDrop { probe: String },
    /// Dynamic amplification `(peak - v(before)) / (v(end) - v(before))` of a load change
    /// at `before`, with the peak taken after `before` (sign-aware).
    DynamicAmplification { probe: String, before: f64 },
    /// Projected area (perpendicular to `axis`) of detached chunks of `body` within `region`.
    DetachedArea { body: String, region: Option<Region>, axis: [f64; 3] },
    DetachedMass { body: String, region: Option<Region> },
    /// Whether any chunk of `body` in `region` detached.
    DetachedAny { body: String, region: Option<Region> },
    /// Mass-weighted mean (or max) speed along `axis` of detached chunks in `region`; 0 if none.
    DetachedSpeed { body: String, region: Option<Region>, axis: [f64; 3], max: bool },
    /// Mass-weighted mean velocity along `axis` of every (non-removed) chunk of `body`
    /// that started in `region`, attached or not.
    RegionSpeed { body: String, region: Region, axis: [f64; 3] },
    /// Whether the chunks that started in `outer` move away from those in `inner` (along
    /// `axis`) faster than `threshold` m/s at the end: a layer separating across a crack
    /// plane, whether or not ligaments elsewhere still connect it (e.g. a spall layer).
    Separating { body: String, outer: Region, inner: Region, axis: [f64; 3], threshold: f64 },
    /// "hole", "push_over" or "intact" (see `metrics::failure_mode`).
    FailureMode { body: String, impact_region: Region },
    /// Boolean flag recorded by the solver (e.g. `collapse`, `any_bond_broken`).
    Flag { flag: String },
    /// Scalar recorded by the solver (e.g. `bond_dissipation`).
    Value { key: String },
}

#[derive(Clone, Debug, Serialize, Deserialize)]
// `flatten` cannot be combined with `deny_unknown_fields`.
pub struct MetricDesc {
    pub name: String,
    #[serde(flatten)]
    pub kind: MetricKind,
    /// Tolerance against the analytic `expected` value (and against oracles unless
    /// `oracle_tolerance` is given).
    pub tolerance: Tolerance,
    /// Tolerance against oracle observations when it differs (another formulation:
    /// a continuum or a different beam theory converges to a slightly different value).
    #[serde(default)]
    pub oracle_tolerance: Option<Tolerance>,
    /// Which oracles this metric is compared against ("analytic" uses `expected`).
    #[serde(default)]
    pub oracles: Vec<String>,
    /// Closed-form expected value, for analytic benchmarks.
    #[serde(default)]
    pub expected: Option<serde_json::Value>,
}

impl MetricDesc {
    pub fn with_oracle_tolerance(mut self, t: Tolerance) -> MetricDesc {
        self.oracle_tolerance = Some(t);
        self
    }

    /// The tolerance against a reference (`"analytic"` or an oracle's name).
    pub fn tolerance_for(&self, source: &str) -> Tolerance {
        if source == "analytic" {
            self.tolerance
        } else {
            self.oracle_tolerance.unwrap_or(self.tolerance)
        }
    }
}

impl Scene {
    pub fn from_json(text: &str) -> Result<Scene, String> {
        let scene: Scene = serde_json::from_str(text).map_err(|e| format!("scene parse error: {e}"))?;
        scene.validate()?;
        Ok(scene)
    }

    pub fn load(path: &std::path::Path) -> Result<Scene, String> {
        let text = std::fs::read_to_string(path).map_err(|e| format!("{}: {e}", path.display()))?;
        Scene::from_json(&text).map_err(|e| format!("{}: {e}", path.display()))
    }

    pub fn to_json_pretty(&self) -> String {
        serde_json::to_string_pretty(self).expect("scene serializes")
    }

    /// The scene with one field replaced: `path` is a dotted path into the scene's JSON
    /// (object keys and array indices, e.g. `sim.stiffness_scale`, `impactors.0.velocity`,
    /// `materials.concrete.tensile_strength`) and `value` is JSON (a bare word that is not
    /// valid JSON is taken as a string, so `sim.solve_mode=adaptive` works).
    pub fn with_override(&self, path: &str, value: &str) -> Result<Scene, String> {
        let mut root = serde_json::to_value(self).map_err(|e| e.to_string())?;
        let new: serde_json::Value =
            serde_json::from_str(value).unwrap_or_else(|_| serde_json::Value::String(value.to_string()));
        let mut node = &mut root;
        for key in path.split('.') {
            node = match node {
                serde_json::Value::Object(map) => map.entry(key.to_string()).or_insert(serde_json::Value::Null),
                serde_json::Value::Array(items) => {
                    let i: usize = key.parse().map_err(|_| format!("'{path}': '{key}' is not an array index"))?;
                    let len = items.len();
                    items.get_mut(i).ok_or_else(|| format!("'{path}': index {i} out of range ({len})"))?
                }
                _ => return Err(format!("'{path}': '{key}' is inside a non-container value")),
            };
        }
        *node = new;
        let scene: Scene = serde_json::from_value(root).map_err(|e| format!("'{path}={value}': {e}"))?;
        scene.validate()?;
        Ok(scene)
    }

    /// The scene with a model feature switched on or off (see [`Features`]).
    pub fn with_feature(&self, name: &str, on: bool) -> Result<Scene, String> {
        let mut scene = self.clone();
        scene.sim.features.set(name, on)?;
        Ok(scene)
    }

    pub fn material(&self, name: &str) -> &Material {
        &self.materials[name]
    }

    pub fn body(&self, name: &str) -> Option<(usize, &BodyDesc)> {
        self.bodies.iter().enumerate().find(|(_, b)| b.name == name)
    }

    pub fn validate(&self) -> Result<(), String> {
        if self.format != SCENE_FORMAT {
            return Err(format!("unsupported scene format '{}', expected '{SCENE_FORMAT}'", self.format));
        }
        for (name, m) in &self.materials {
            m.validate(name)?;
        }
        let known = |m: &str| -> Result<(), String> {
            if self.materials.contains_key(m) {
                Ok(())
            } else {
                Err(format!("unknown material '{m}'"))
            }
        };
        let mut names = std::collections::BTreeSet::new();
        for body in &self.bodies {
            if !names.insert(body.name.clone()) {
                return Err(format!("duplicate body name '{}'", body.name));
            }
            for (i, c) in body.chunks.iter().enumerate() {
                known(&c.material)?;
                if c.half_extents.iter().any(|h| !(*h > 0.0)) {
                    return Err(format!("body '{}' chunk {i}: half extents must be positive", body.name));
                }
                if let Some(p) = c.parent {
                    if p >= body.chunks.len() || body.chunks[p].level + 1 != c.level {
                        return Err(format!("body '{}' chunk {i}: bad parent {p}", body.name));
                    }
                }
            }
            for (i, b) in body.bonds.iter().enumerate() {
                known(&b.material)?;
                if b.a >= body.chunks.len() || b.b >= body.chunks.len() || b.a == b.b {
                    return Err(format!("body '{}' bond {i}: bad chunk indices", body.name));
                }
                if !(b.area > 0.0) || b.width.iter().any(|w| !(*w > 0.0)) {
                    return Err(format!("body '{}' bond {i}: area and width must be positive", body.name));
                }
                let n = Vec3::from_array(b.normal);
                let t = Vec3::from_array(b.tangent);
                if (n.norm() - 1.0).abs() > 1e-6 || (t.norm() - 1.0).abs() > 1e-6 || n.dot(t).abs() > 1e-6 {
                    return Err(format!("body '{}' bond {i}: normal/tangent must be orthonormal", body.name));
                }
                if let Some(r) = &b.rebar {
                    known(&r.material)?;
                }
                let la = body.chunks[b.a].level;
                let lb = body.chunks[b.b].level;
                if la != b.level || lb != b.level {
                    return Err(format!("body '{}' bond {i}: chunks must be on the bond's level", body.name));
                }
            }
        }
        for imp in &self.impactors {
            known(&imp.material)?;
            if !(imp.mass > 0.0) {
                return Err(format!("impactor '{}': mass must be positive", imp.name));
            }
        }
        if let Some(g) = &self.ground {
            known(&g.material)?;
        }
        let body_known = |b: &str| -> Result<(), String> {
            if names.contains(b) {
                Ok(())
            } else {
                Err(format!("unknown body '{b}'"))
            }
        };
        for l in &self.loads {
            match l {
                LoadDesc::PointForce { body, .. } | LoadDesc::Pressure { body, .. } => body_known(body)?,
                LoadDesc::Blast { .. } => {}
            }
        }
        for e in &self.events {
            match e {
                EventDesc::RemoveChunks { body, .. } | EventDesc::RemoveSupports { body, .. } => body_known(body)?,
            }
        }
        let mut probe_names = std::collections::BTreeSet::new();
        for p in &self.probes {
            if !probe_names.insert(p.name.clone()) {
                return Err(format!("duplicate probe '{}'", p.name));
            }
        }
        if !(self.sim.frame_dt > 0.0 && self.sim.duration >= 0.0 && self.sim.stiffness_scale > 0.0) {
            return Err("sim: frame_dt and stiffness_scale must be positive, duration non-negative".into());
        }
        Ok(())
    }

    /// Copy with each bond's `derived` section properties filled in (for exporters).
    pub fn with_derived(&self) -> Scene {
        let mut s = self.clone();
        for (body_index, body) in s.bodies.iter_mut().enumerate() {
            let chunks = body.chunks.clone();
            for (bond_index, bond) in body.bonds.iter_mut().enumerate() {
                let m = &self.materials[&bond.material];
                let g = crate::bond::BondGeometry::from_desc(bond, &chunks);
                let k = crate::bond::BondStiffness::new(&g, m, 1.0);
                let weibull = crate::material::bond_strength_factor(m.weibull_modulus, self.sim.seed, body_index, bond_index);
                bond.derived = Some(serde_json::json!({
                    "length": g.length,
                    "i_t1": g.i_t1, "i_t2": g.i_t2, "torsion_constant": g.torsion_constant,
                    "section_modulus_t1": g.s_t1, "section_modulus_t2": g.s_t2,
                    "torsion_modulus": g.torsion_modulus,
                    "kn": k.kn, "ks": k.ks, "kb_t1": k.kb_t1, "kb_t2": k.kb_t2, "kt": k.kt,
                    "weibull": weibull,
                }));
            }
        }
        s
    }
}

/// Mass and body-frame inertia (about its centre) of a box chunk.
pub fn box_mass_inertia(half_extents: [f64; 3], orientation: [f64; 4], density: f64) -> (f64, crate::math::Mat3) {
    let h = Vec3::from_array(half_extents);
    let mass = density * 8.0 * h.x * h.y * h.z;
    let (a, b, c) = (2.0 * h.x, 2.0 * h.y, 2.0 * h.z);
    let local = Vec3::new(b * b + c * c, a * a + c * c, a * a + b * b) * (mass / 12.0);
    let r = Quat::from_wxyz(orientation).to_mat3();
    (mass, r * crate::math::Mat3::diag(local) * r.transpose())
}

/// Observation summary written by every solver; see `observation.rs`.
pub use crate::observation::Observation;
