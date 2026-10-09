//! Parametric scene construction and the benchmark scene catalogue.
//!
//! The catalogue is the single source of every benchmark scene: `stress-ref
//! gen-scenes` writes it to `scenes/*.json`, the oracle exporters read those files,
//! and the tests rebuild the same scenes in memory.

use std::collections::{BTreeMap, HashMap};

use crate::material::Material;
use crate::math::Vec3;
use crate::scene::*;

pub fn new_scene(name: &str, description: &str) -> Scene {
    Scene {
        format: SCENE_FORMAT.into(),
        name: name.into(),
        description: description.into(),
        benchmark: None,
        gravity: [0.0, 0.0, -9.81],
        materials: BTreeMap::new(),
        bodies: Vec::new(),
        impactors: Vec::new(),
        ground: None,
        loads: Vec::new(),
        events: Vec::new(),
        sim: SimDesc::default(),
        probes: Vec::new(),
        metrics: Vec::new(),
        oracle: BTreeMap::new(),
    }
}

pub fn chunk(center: Vec3, half: Vec3, material: &str) -> ChunkDesc {
    ChunkDesc {
        center: center.to_array(),
        half_extents: half.to_array(),
        orientation: [1.0, 0.0, 0.0, 0.0],
        material: material.into(),
        support: Support::None,
        groups: Vec::new(),
        level: 0,
        parent: None,
    }
}

/// A regular grid of equal boxes; index = `i + nx (j + ny k)`.
pub fn grid(min_corner: Vec3, counts: [usize; 3], size: Vec3, material: &str) -> Vec<ChunkDesc> {
    let mut out = Vec::with_capacity(counts.iter().product());
    for k in 0..counts[2] {
        for j in 0..counts[1] {
            for i in 0..counts[0] {
                let c = min_corner + Vec3::new((i as f64 + 0.5) * size.x, (j as f64 + 0.5) * size.y, (k as f64 + 0.5) * size.z);
                out.push(chunk(c, size * 0.5, material));
            }
        }
    }
    out
}

pub fn grid_index(counts: [usize; 3], i: usize, j: usize, k: usize) -> usize {
    i + counts[0] * (j + counts[1] * k)
}

/// Bonds between every pair of face-touching axis-aligned boxes on the same level.
/// The patch is the overlap rectangle; `joint(a, b)` names the joint material.
pub fn auto_bonds(chunks: &[ChunkDesc], joint: impl Fn(&ChunkDesc, &ChunkDesc) -> String) -> Vec<BondDesc> {
    let max_h = chunks.iter().flat_map(|c| c.half_extents).fold(0.0f64, f64::max);
    // Wider than any centre spacing of touching boxes, so neighbours are at most one cell apart.
    let cell = 2.5 * max_h;
    let key = |p: [f64; 3]| -> (i64, i64, i64) {
        ((p[0] / cell).floor() as i64, (p[1] / cell).floor() as i64, (p[2] / cell).floor() as i64)
    };
    let mut hash: HashMap<(i64, i64, i64), Vec<usize>> = HashMap::new();
    for (i, c) in chunks.iter().enumerate() {
        hash.entry(key(c.center)).or_default().push(i);
    }
    let scale = max_h.max(1e-9);
    let tol = 1e-9 * scale;
    let mut bonds = Vec::new();
    for (i, a) in chunks.iter().enumerate() {
        let (kx, ky, kz) = key(a.center);
        let mut cand = Vec::new();
        for dx in -1..=1 {
            for dy in -1..=1 {
                for dz in -1..=1 {
                    if let Some(v) = hash.get(&(kx + dx, ky + dy, kz + dz)) {
                        cand.extend(v.iter().copied().filter(|&j| j > i));
                    }
                }
            }
        }
        cand.sort_unstable();
        for j in cand {
            let b = &chunks[j];
            if a.level != b.level {
                continue;
            }
            for axis in 0..3 {
                let gap = (b.center[axis] - a.center[axis]).abs() - (a.half_extents[axis] + b.half_extents[axis]);
                if gap.abs() > tol {
                    continue;
                }
                let (o1, o2) = ((axis + 1) % 3, (axis + 2) % 3);
                let lo = |o: usize| (a.center[o] - a.half_extents[o]).max(b.center[o] - b.half_extents[o]);
                let hi = |o: usize| (a.center[o] + a.half_extents[o]).min(b.center[o] + b.half_extents[o]);
                let (w1, w2) = (hi(o1) - lo(o1), hi(o2) - lo(o2));
                if w1 <= tol || w2 <= tol {
                    continue;
                }
                let sign = if b.center[axis] > a.center[axis] { 1.0 } else { -1.0 };
                let mut normal = [0.0; 3];
                normal[axis] = sign;
                let mut tangent = [0.0; 3];
                tangent[o1] = 1.0;
                let mut centroid = [0.0; 3];
                centroid[axis] = a.center[axis] + sign * a.half_extents[axis];
                centroid[o1] = 0.5 * (lo(o1) + hi(o1));
                centroid[o2] = 0.5 * (lo(o2) + hi(o2));
                bonds.push(BondDesc {
                    a: i,
                    b: j,
                    centroid,
                    normal,
                    tangent,
                    area: w1 * w2,
                    width: [w1, w2],
                    material: joint(a, b),
                    rebar: None,
                    buckling_length: None,
                    level: a.level,
                    groups: Vec::new(),
                    derived: None,
                });
            }
        }
    }
    bonds
}

pub fn body(name: &str, chunks: Vec<ChunkDesc>, bonds: Vec<BondDesc>) -> BodyDesc {
    BodyDesc {
        name: name.into(),
        position: [0.0; 3],
        orientation: [1.0, 0.0, 0.0, 0.0],
        linear_velocity: [0.0; 3],
        angular_velocity: [0.0; 3],
        chunks,
        bonds,
    }
}

pub fn probe(name: &str, kind: ProbeKind) -> ProbeDesc {
    ProbeDesc { name: name.into(), kind }
}

pub fn metric(name: &str, kind: MetricKind, tolerance: Tolerance, expected: Option<serde_json::Value>, oracles: &[&str]) -> MetricDesc {
    MetricDesc { name: name.into(), kind, tolerance, oracles: oracles.iter().map(|s| s.to_string()).collect(), expected }
}

fn num(x: f64) -> Option<serde_json::Value> {
    Some(serde_json::json!(x))
}

// ======================================================================== benchmark 1

/// Benchmark 1, tension: two cubes, one held; the other is pulled by a slow force ramp
/// through the bond centroid. Analytic: failure force `f_t A`, dissipated `G_f A`.
pub fn bond_tension() -> Scene {
    let m = Material::analytic_test();
    let h = 0.05;
    let mut s = new_scene("b1_bond_tension", "Single bond pulled in tension to failure (force ramp).");
    s.benchmark = Some(1);
    s.gravity = [0.0; 3];
    let mut chunks = vec![chunk(Vec3::ZERO, Vec3::splat(h), "rock"), chunk(Vec3::new(2.0 * h, 0.0, 0.0), Vec3::splat(h), "rock")];
    chunks[0].support = Support::Fixed;
    let bonds = auto_bonds(&chunks, |_, _| "rock".into());
    let area = 4.0 * h * h;
    s.materials.insert("rock".into(), m.clone());
    s.bodies.push(body("pair", chunks, bonds));
    s.loads.push(LoadDesc::PointForce {
        body: "pair".into(),
        chunk: 1,
        direction: [1.0, 0.0, 0.0],
        magnitude: TimeFunction::Ramp { t0: 0.0, t1: 0.5, value: 2.0 * m.tensile_strength * area },
        point: None,
    });
    s.sim.duration = 0.6;
    s.probes.push(probe(
        "axial",
        ProbeKind::SectionForce { body: "pair".into(), point: [h, 0.0, 0.0], normal: [1.0, 0.0, 0.0], region: None, component: SectionComponent::Normal },
    ));
    s.metrics.push(metric("failure_force", MetricKind::ProbeMax { probe: "axial".into() }, Tolerance::Relative(0.05), num(m.tensile_strength * area), &[]));
    s.metrics.push(metric(
        "dissipated_energy",
        MetricKind::Value { key: "bond_dissipation".into() },
        Tolerance::Relative(0.05),
        num(m.fracture_energy.tension * area),
        &[],
    ));
    s.metrics.push(metric("broke", MetricKind::Flag { flag: "any_bond_broken".into() }, Tolerance::Exact, Some(serde_json::json!(true)), &[]));
    s
}

/// Benchmark 1, shear: compressive preload `sigma_n`, then a shear force ramp through
/// the bond centroid. Analytic Mohr-Coulomb failure force `(c + mu sigma_n) A`.
pub fn bond_shear() -> Scene {
    let m = Material::analytic_test();
    let h = 0.05;
    let area = 4.0 * h * h;
    let sigma_n = 2.0e6;
    let mut s = new_scene("b1_bond_shear", "Single bond under compressive preload, sheared to failure (Mohr-Coulomb).");
    s.benchmark = Some(1);
    s.gravity = [0.0; 3];
    let mut chunks = vec![chunk(Vec3::ZERO, Vec3::splat(h), "rock"), chunk(Vec3::new(2.0 * h, 0.0, 0.0), Vec3::splat(h), "rock")];
    chunks[0].support = Support::Fixed;
    let bonds = auto_bonds(&chunks, |_, _| "rock".into());
    s.materials.insert("rock".into(), m.clone());
    s.bodies.push(body("pair", chunks, bonds));
    s.loads.push(LoadDesc::PointForce {
        body: "pair".into(),
        chunk: 1,
        direction: [-1.0, 0.0, 0.0],
        magnitude: TimeFunction::Constant { value: sigma_n * area },
        point: None,
    });
    let v_fail = (m.cohesion + m.friction * sigma_n) * area;
    s.loads.push(LoadDesc::PointForce {
        body: "pair".into(),
        chunk: 1,
        direction: [0.0, 1.0, 0.0],
        magnitude: TimeFunction::Ramp { t0: 0.0, t1: 0.5, value: 1.6 * v_fail },
        point: Some([h, 0.0, 0.0]),
    });
    s.sim.duration = 0.45;
    s.probes.push(probe(
        "shear",
        ProbeKind::SectionForce {
            body: "pair".into(),
            point: [h, 0.0, 0.0],
            normal: [1.0, 0.0, 0.0],
            region: None,
            component: SectionComponent::Force([0.0, -1.0, 0.0]),
        },
    ));
    s.metrics.push(metric("failure_force", MetricKind::ProbeMax { probe: "shear".into() }, Tolerance::Relative(0.05), num(v_fail), &[]));
    s.metrics.push(metric("broke", MetricKind::Flag { flag: "any_bond_broken".into() }, Tolerance::Exact, Some(serde_json::json!(true)), &[]));
    s
}

// ======================================================================== benchmark 2

/// Cantilever geometry shared by the scene and its analytic expectations.
pub struct Cantilever {
    pub n: usize,
    pub h: f64,
    pub load: f64,
}

impl Cantilever {
    pub fn second_moment(&self) -> f64 {
        self.h.powi(4) / 12.0
    }
    /// Load point distance from the clamp (anchored chunk centre).
    pub fn arm(&self) -> f64 {
        self.n as f64 * self.h
    }
    /// Euler-Bernoulli span for the free vibration: clamp to the free end.
    pub fn span(&self) -> f64 {
        (self.n as f64 + 0.5) * self.h
    }
}

/// Benchmark 2: a chunked cantilever (N chunks plus a clamped root chunk) under a tip
/// load, statically (prestress), then released into free vibration.
pub fn cantilever(n: usize, name: &str) -> Scene {
    let m = Material::analytic_test();
    let cfg = Cantilever { n, h: 0.1 * 20.0 / n as f64, load: 30.0 };
    let h = cfg.h;
    let mut s = new_scene(name, "Chunked cantilever: static tip load, then free vibration (Euler-Bernoulli).");
    s.benchmark = Some(2);
    s.gravity = [0.0; 3];
    s.materials.insert("beam".into(), m.clone());
    let mut chunks = grid(Vec3::new(-0.5 * h, -0.05, -0.05), [n + 1, 1, 1], Vec3::new(h, 0.1, 0.1), "beam");
    chunks[0].support = Support::Fixed;
    // Square section 0.1 x 0.1 regardless of N (the chunk length changes).
    let bonds = auto_bonds(&chunks, |_, _| "beam".into());
    s.bodies.push(body("beam", chunks, bonds));
    let release = 0.05;
    s.loads.push(LoadDesc::PointForce {
        body: "beam".into(),
        chunk: n,
        direction: [0.0, 0.0, -1.0],
        magnitude: TimeFunction::Table { points: vec![[0.0, cfg.load], [release, cfg.load], [release + 1e-9, 0.0]] },
        point: None,
    });
    s.sim.duration = 2.0;
    s.sim.fracture = false;
    s.sim.sample_interval = Some(1e-3);
    s.probes.push(probe("tip", ProbeKind::ChunkDisplacement { body: "beam".into(), chunk: n, axis: [0.0, 0.0, 1.0] }));
    s.probes.push(probe(
        "root_moment",
        ProbeKind::SectionForce {
            body: "beam".into(),
            point: [0.5 * h, 0.0, 0.0],
            normal: [1.0, 0.0, 0.0],
            region: None,
            component: SectionComponent::Moment([0.0, 1.0, 0.0]),
        },
    ));
    let i = 0.1f64.powi(4) / 12.0;
    let e = m.youngs_modulus;
    let a = cfg.arm();
    let tip = -cfg.load * a.powi(3) / (3.0 * e * i);
    let root_moment = -cfg.load * (a - 0.5 * h);
    let area = 0.01;
    let l = cfg.span();
    let f1 = 1.875_104_07f64.powi(2) / (2.0 * std::f64::consts::PI) * (e * i / (m.density * area * l.powi(4))).sqrt();
    s.metrics.push(metric("tip_deflection", MetricKind::ProbeAt { probe: "tip".into(), time: 0.0 }, Tolerance::Relative(0.05), num(tip), &["opensees"]));
    s.metrics.push(metric(
        "root_moment",
        MetricKind::ProbeAt { probe: "root_moment".into(), time: 0.0 },
        Tolerance::Relative(0.05),
        num(root_moment),
        &["opensees"],
    ));
    s.metrics.push(metric(
        "first_frequency",
        MetricKind::ProbeFrequency { probe: "tip".into(), after: release + 0.01 },
        Tolerance::Relative(0.05),
        num(f1),
        &["opensees"],
    ));
    s
}

// ======================================================================== benchmark 3

/// Benchmark 3: a free bar struck by a half-sine force pulse; the compressive wave
/// travels at `sqrt(E_eff / rho)` and reflects from the free end as tension, where the
/// particle velocity doubles.
pub fn bar_wave(stiffness_scale: f64, name: &str) -> Scene {
    let m = Material::analytic_test();
    let n = 100;
    let h = 0.05;
    let area = 0.05 * 0.05;
    let mut s = new_scene(name, "Free bar, half-sine end pulse: wave speed and free-end reflection.");
    s.benchmark = Some(3);
    s.gravity = [0.0; 3];
    s.materials.insert("bar".into(), m.clone());
    let chunks = grid(Vec3::new(0.0, -0.025, -0.025), [n, 1, 1], Vec3::new(h, 0.05, 0.05), "bar");
    let bonds = auto_bonds(&chunks, |_, _| "bar".into());
    s.bodies.push(body("bar", chunks, bonds));
    let c = (m.youngs_modulus * stiffness_scale / m.density).sqrt();
    // Pulse long against the chunk size (low dispersion), short against the bar.
    let duration = 30.0 * h / c;
    let peak_force = 1000.0;
    s.loads.push(LoadDesc::PointForce {
        body: "bar".into(),
        chunk: 0,
        direction: [1.0, 0.0, 0.0],
        magnitude: TimeFunction::HalfSine { start: 0.0, duration, peak: peak_force },
        point: None,
    });
    s.sim.stiffness_scale = stiffness_scale;
    s.sim.fracture = false;
    s.sim.gravity_prestress = false;
    s.sim.frame_dt = duration / 10.0;
    s.sim.sample_interval = Some(duration / 200.0);
    // Long enough for the reflected pulse to pass the middle again.
    s.sim.duration = 2.4 * n as f64 * h / c;
    let v_particle = peak_force / area / (m.density * c);
    for (name, k) in [("v20", 20), ("v50", 50), ("v80", 80), ("v_end", n - 1)] {
        s.probes.push(probe(name, ProbeKind::ChunkVelocity { body: "bar".into(), chunk: k, axis: [1.0, 0.0, 0.0] }));
    }
    s.probes.push(probe(
        "axial_mid",
        ProbeKind::SectionForce { body: "bar".into(), point: [50.0 * h, 0.0, 0.0], normal: [1.0, 0.0, 0.0], region: None, component: SectionComponent::Normal },
    ));
    s.metrics.push(metric(
        "wave_speed",
        MetricKind::WaveSpeed { probe_a: "v20".into(), probe_b: "v80".into(), distance: 60.0 * h, threshold: 0.5 * v_particle },
        Tolerance::Relative(0.05),
        num(c),
        &["opencourant"],
    ));
    s.metrics.push(metric(
        "free_end_velocity_ratio",
        MetricKind::ProbePeakRatioOf { probe: "v_end".into(), reference: "v50".into() },
        Tolerance::Relative(0.05),
        num(2.0),
        &["opencourant"],
    ));
    s.metrics.push(metric(
        "incident_compression",
        MetricKind::ProbeMin { probe: "axial_mid".into() },
        Tolerance::Relative(0.05),
        num(-peak_force),
        &["opencourant"],
    ));
    s.metrics.push(metric(
        "reflected_tension",
        MetricKind::ProbeMax { probe: "axial_mid".into() },
        Tolerance::Relative(0.05),
        num(peak_force),
        &["opencourant"],
    ));
    s
}

// ======================================================================== benchmark 4

/// Benchmark 4: a block held between a lower and an upper support shares its weight
/// equally; the upper support is removed (suddenly or over `duration`). The lower
/// support's reaction jumps to the full weight with a dynamic overshoot: the
/// single-mass-spring solution gives an amplification of 2 for sudden loss.
pub fn support_loss(duration: f64, name: &str) -> Scene {
    let mut m = Material::analytic_test();
    m.damping_ratio = 0.02;
    let h = 0.05;
    let mut s = new_scene(name, "Mass between two supports; one support removed (sudden or gradual).");
    s.benchmark = Some(4);
    s.materials.insert("rock".into(), m);
    let mut chunks = grid(Vec3::new(-h, -h, 0.0), [1, 1, 3], Vec3::splat(2.0 * h), "rock");
    chunks[0].support = Support::Fixed;
    chunks[2].support = Support::Fixed;
    chunks[0].groups.push("lower".into());
    chunks[2].groups.push("upper".into());
    let bonds = auto_bonds(&chunks, |_, _| "rock".into());
    s.bodies.push(body("stack", chunks, bonds));
    let t_remove = 0.01;
    s.events.push(EventDesc::RemoveChunks { time: t_remove, duration, body: "stack".into(), chunks: ChunkSelector::Group("upper".into()) });
    s.sim.fracture = false;
    s.sim.duration = 0.3;
    s.sim.frame_dt = 1e-3;
    s.sim.sample_interval = Some(2e-5);
    s.probes.push(probe("reaction", ProbeKind::Reaction { body: "stack".into(), chunks: ChunkSelector::Group("lower".into()), axis: [0.0, 0.0, 1.0] }));
    let expected = if duration == 0.0 { 2.0 } else { 1.0 };
    s.metrics.push(metric(
        "dynamic_amplification",
        MetricKind::DynamicAmplification { probe: "reaction".into(), before: t_remove - 1e-6 },
        Tolerance::Relative(0.10),
        num(expected),
        &[],
    ));
    s
}

/// Every scene of the catalogue.
pub fn catalog() -> Vec<Scene> {
    vec![
        bond_tension(),
        bond_shear(),
        cantilever(20, "b2_cantilever"),
        cantilever(10, "b2_cantilever_n10"),
        cantilever(40, "b2_cantilever_n40"),
        bar_wave(1.0, "b3_bar_wave"),
        bar_wave(0.01, "b3_bar_wave_scaled"),
        support_loss(0.0, "b4_support_loss_sudden"),
        support_loss(0.1, "b4_support_loss_gradual"),
    ]
}
