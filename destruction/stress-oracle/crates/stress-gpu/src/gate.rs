//! The accuracy gate against stress-ref, with the reference's runs cached on disk.
//!
//! Each case's reference set is the reference run, the run at half the substep and the
//! runs with the inputs perturbed by +-1e-4 (the size of the GPU's f32 drift). The GPU
//! passes where its probes stay within 1e-3 of their range or within twice the
//! reference's own spread, and its broken bonds and fragments within 10% or twice the
//! spread's deviation (`gate`).
//!
//! The reference runs are slow (minutes for the larger scenes, at full duration) and
//! never change unless stress-ref or the scene does, so they are computed once and kept
//! under `target/stress-gate-cache/`, keyed by the scene's JSON, the perturbation and a
//! fingerprint of stress-ref's sources. A GPU check then costs only the GPU runs.

use std::path::{Path, PathBuf};

use stress_ref::math::Vec3;
use stress_ref::observation::Observation;
use stress_ref::scene::{ImpactorDesc, ImpactorShape, ProbeDesc, ProbeKind, Scene, SolveMode};
use stress_ref::world::World;

pub const KEYS: [&str; 6] = ["broken_bonds", "fragments", "max_failure_index", "first_crack_time", "bond_dissipation", "damping_dissipation"];

/// Worst probe error (relative to the reference's probe range) and the outcome values.
pub fn difference(reference: &Observation, other: &Observation) -> (f64, Vec<String>) {
    let mut worst = 0.0f64;
    let mut notes = Vec::new();
    for (name, r) in &reference.probes {
        let Some(g) = other.probes.get(name) else {
            notes.push(format!("{name}: missing"));
            worst = f64::INFINITY;
            continue;
        };
        let range = r.v.iter().filter(|x| x.is_finite()).fold(0.0f64, |m, x| m.max(x.abs())).max(1e-30);
        let n = r.v.len().min(g.v.len());
        let mut err = 0.0f64;
        let mut at = 0;
        for i in 0..n {
            let (a, b) = (r.v[i], g.v[i]);
            let e = if a.is_nan() && b.is_nan() { 0.0 } else if a.is_nan() || b.is_nan() { f64::INFINITY } else { (a - b).abs() / range };
            if e > err {
                err = e;
                at = i;
            }
        }
        if r.v.len() != g.v.len() {
            notes.push(format!("{name}: samples {} vs {}", r.v.len(), g.v.len()));
        }
        let detail = if n > 0 && err > 1e-3 { format!(" at t={:.5} ({:.4e} vs {:.4e}, range {:.3e})", r.t[at], r.v[at], g.v[at], range) } else { String::new() };
        notes.push(format!("{name} {err:.1e}{detail}"));
        worst = worst.max(err);
    }
    for key in KEYS {
        let (a, b) = (reference.values.get(key).copied(), other.values.get(key).copied());
        if a != b {
            let fmt = |x: Option<f64>| x.map_or("-".into(), |v| format!("{v:.6}"));
            notes.push(format!("{key} {}|{}", fmt(a), fmt(b)));
        }
    }
    (worst, notes)
}

/// The scene with its impactor and body velocities and gravity scaled by `1 + eps`.
pub fn perturbed_by(scene: &Scene, eps: f64) -> Scene {
    let mut s = scene.clone();
    let k = 1.0 + eps;
    s.gravity = s.gravity.map(|g| g * k);
    for imp in &mut s.impactors {
        imp.velocity = imp.velocity.map(|v| v * k);
    }
    for b in &mut s.bodies {
        b.linear_velocity = b.linear_velocity.map(|v| v * k);
    }
    s
}

/// The input perturbation of the spread runs (`STRESS_GPU_PERTURB` overrides).
pub fn perturbation() -> f64 {
    std::env::var("STRESS_GPU_PERTURB").ok().and_then(|v| v.parse::<f64>().ok()).unwrap_or(1e-4)
}

/// The reference's sensitivity to its inputs: the runs with its inputs perturbed by
/// +-1e-4. That is the size of the GPU's own perturbation: f32 arithmetic moves even
/// smooth, intact runs by 1e-5 to 5e-4 of their range over thousands of substeps, so
/// wherever the reference separates under a 1e-4 change (fracture cascades, fatigue and
/// settling thresholds), the GPU may separate as far.
pub fn spread_run(scene: &Scene, _reference: &Observation) -> Vec<Observation> {
    let eps = perturbation();
    [eps, -eps].iter().map(|&e| World::new(&perturbed_by(scene, e)).run()).collect()
}

/// The largest of the spread runs' differences from the reference (with its notes).
pub fn spread_difference(reference: &Observation, spreads: &[Observation]) -> (f64, Vec<String>) {
    spreads.iter().map(|o| difference(reference, o)).fold((0.0, Vec::new()), |a, b| if b.0 > a.0 || a.1.is_empty() { b } else { a })
}

/// The scene at half the reference's substep (its Courant safety halved).
pub fn refined(scene: &Scene) -> Scene {
    let mut s = scene.clone();
    s.sim.courant_safety *= 0.5;
    s
}

fn value(o: &Observation, key: &str) -> f64 {
    o.values.get(key).copied().unwrap_or(0.0)
}

/// The accuracy gate (the analysis's G2, judged against the reference's own spread):
/// probes within 1e-3 of their range, or within twice the largest difference of the
/// reference's timestep-halving and input-perturbation runs; broken bonds and fragments
/// within 10% (at least one), or within twice those runs' largest deviation (fracture
/// cascades scatter their counts: b5 v10 adaptive gives 41-50 fragments over input
/// changes of 1e-6 to 2e-4). Returns what fails.
pub fn gate(reference: &Observation, ours: &Observation, half: &Observation, spreads: &[Observation]) -> Vec<String> {
    let mut fails = Vec::new();
    let (gpu_err, _) = difference(reference, ours);
    let allowed = allowed_error(reference, half, spreads);
    if !(gpu_err <= allowed) {
        fails.push(format!("probes {gpu_err:.1e} > {allowed:.1e}"));
    }
    for key in ["broken_bonds", "fragments"] {
        let r = value(reference, key);
        let d = (value(ours, key) - r).abs();
        let deviation = spreads.iter().chain(std::iter::once(half)).map(|o| (value(o, key) - r).abs()).fold(0.0, f64::max);
        let allowed = (0.1 * r).max(1.0).max(2.0 * deviation);
        if d > allowed {
            fails.push(format!("{key} {} vs {r} (allowed {allowed})", value(ours, key)));
        }
    }
    fails
}

/// The probe error the gate allows: twice the reference's own spread, at least 1e-3.
pub fn allowed_error(reference: &Observation, half: &Observation, spreads: &[Observation]) -> f64 {
    let (half_err, _) = difference(reference, half);
    let (spread_err, _) = spread_difference(reference, spreads);
    (2.0 * half_err.max(spread_err)).max(1e-3)
}

// ------------------------------------------------------------------ cases

/// A gate case: a scene at the duration it is judged over.
#[derive(Clone)]
pub struct Case {
    pub name: String,
    pub scene: Scene,
}

/// The bounds of a scene's chunks (world).
pub fn bounds(scene: &Scene) -> (Vec3, Vec3) {
    let mut lo = Vec3::splat(f64::INFINITY);
    let mut hi = Vec3::splat(f64::NEG_INFINITY);
    for c in scene.bodies.iter().flat_map(|b| b.chunks.iter()) {
        let p = Vec3::from_array(c.center);
        lo = lo.component_min(p);
        hi = hi.component_max(p);
    }
    (lo, hi)
}

/// An impactor aimed at the middle of the structure's -x face, from 0.2 m outside it,
/// with probes on its velocity and on a few chunks' displacement.
pub fn with_impactor(mut scene: Scene, shape: ImpactorShape, mass: f64, speed: f64) -> Scene {
    let (lo, hi) = bounds(&scene);
    let mid = (lo + hi) * 0.5;
    let reach = match shape {
        ImpactorShape::Sphere { radius } => radius,
        ImpactorShape::Box { half_extents } => half_extents[0],
    };
    let material = scene.bodies[0].chunks[0].material.clone();
    scene.impactors.push(ImpactorDesc {
        name: "ram".into(),
        shape,
        mass,
        position: [lo.x - 0.2 - reach, mid.y, mid.z],
        orientation: [0.0, 0.0, 0.0, 1.0],
        velocity: [speed, 0.0, 0.0],
        angular_velocity: [0.0; 3],
        material,
        crush: None,
    });
    scene.probes.push(ProbeDesc { name: "ram_velocity".into(), kind: ProbeKind::ImpactorVelocity { impactor: "ram".into(), axis: [1.0, 0.0, 0.0] } });
    with_chunk_probes(scene)
}

/// Displacement probes on the chunks nearest a few points of the structure.
pub fn with_chunk_probes(mut scene: Scene) -> Scene {
    let (lo, hi) = bounds(&scene);
    let body = scene.bodies[0].name.clone();
    for (i, f) in [[0.0, 0.5, 0.5], [0.5, 0.5, 1.0], [1.0, 0.5, 0.5]].iter().enumerate() {
        let target = lo + Vec3::new((hi.x - lo.x) * f[0], (hi.y - lo.y) * f[1], (hi.z - lo.z) * f[2]);
        let nearest = (0..scene.bodies[0].chunks.len())
            .min_by(|&a, &b| {
                let d = |k: usize| (Vec3::from_array(scene.bodies[0].chunks[k].center) - target).norm();
                d(a).total_cmp(&d(b))
            })
            .unwrap();
        for (axis, name) in [([1.0, 0.0, 0.0], "x"), ([0.0, 0.0, 1.0], "z")] {
            scene.probes.push(ProbeDesc { name: format!("chunk{i}_{name}"), kind: ProbeKind::ChunkDisplacement { body: body.clone(), chunk: nearest, axis } });
        }
    }
    scene
}

/// The authored scene packs' directory (sibling asset checkout).
pub fn packs_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../../blast/blast-stress-demo-rs/assets/scenes")
}

/// Every gate case: each catalogue and showcase scene as authored, at its full duration;
/// a set of them in the adaptive and quasi-static modes; the authored packs that stand
/// at rest (villa-savoye is over strength under its own weight as authored), struck.
pub fn cases() -> Vec<Case> {
    let catalogue: Vec<Scene> = stress_ref::builders::catalog().into_iter().chain(stress_ref::showcases::catalog()).collect();
    let mut out: Vec<Case> = catalogue.iter().map(|s| Case { name: s.name.clone(), scene: s.clone() }).collect();
    let modes: [(&str, SolveMode); 8] = [
        ("b2_cantilever", SolveMode::QuasiStatic),
        ("b8_frame_sudden", SolveMode::QuasiStatic),
        ("s_floor_static", SolveMode::QuasiStatic),
        ("b8_frame_sudden", SolveMode::Adaptive),
        ("b9_panel_high", SolveMode::Adaptive),
        ("b5_wall_impact_v10", SolveMode::Adaptive),
        ("s_house_car", SolveMode::Adaptive),
        ("s_overhang_thin", SolveMode::Adaptive),
    ];
    for (name, mode) in modes {
        let mut s = catalogue.iter().find(|s| s.name == name).expect("catalogue scene").clone();
        s.sim.solve_mode = mode;
        out.push(Case { name: format!("{name} ({mode:?})"), scene: s });
    }
    let packs: [(&str, &str, f64); 4] = [("rig-portal", "box", 0.25), ("comp-wall-bay", "sphere", 0.25), ("rig-toppled", "box", 0.25), ("house-1story", "box", 0.1)];
    for (pack, load, duration) in packs {
        let path = packs_dir().join(format!("{pack}.json"));
        let Ok(base) = stress_ref::scene_pack::import(&path, pack, "structure") else { continue };
        let mut scene = match load {
            "box" => with_impactor(base, ImpactorShape::Box { half_extents: [0.15, 0.3, 0.3] }, 400.0, 12.0),
            _ => with_impactor(base, ImpactorShape::Sphere { radius: 0.25 }, 300.0, 15.0),
        };
        scene.sim.duration = duration;
        out.push(Case { name: format!("{pack} ({load})"), scene });
    }
    out
}

// ------------------------------------------------------------------ the cache

/// A case's reference runs.
pub struct ReferenceSet {
    pub reference: Observation,
    pub half: Observation,
    pub spreads: Vec<Observation>,
    /// Host seconds the reference run took (when it was computed).
    pub reference_seconds: f64,
}

#[derive(serde::Serialize, serde::Deserialize)]
struct Stored {
    reference: Observation,
    half: Observation,
    spreads: Vec<Observation>,
    reference_seconds: f64,
}

/// 64-bit FNV-1a (stable across runs and toolchains, unlike `DefaultHasher`).
fn fnv(bytes: &[u8], mut h: u64) -> u64 {
    for &b in bytes {
        h ^= b as u64;
        h = h.wrapping_mul(0x100000001b3);
    }
    h
}

/// A fingerprint of stress-ref's sources: the cache is stale when they change.
fn reference_fingerprint() -> u64 {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../stress-ref");
    let mut files = Vec::new();
    let mut stack = vec![root.join("src"), root.join("Cargo.toml")];
    while let Some(p) = stack.pop() {
        if p.is_dir() {
            for e in std::fs::read_dir(&p).into_iter().flatten().flatten() {
                stack.push(e.path());
            }
        } else {
            files.push(p);
        }
    }
    files.sort();
    let mut h = 0xcbf29ce484222325;
    for f in files {
        h = fnv(f.to_string_lossy().as_bytes(), h);
        h = fnv(&std::fs::read(&f).unwrap_or_default(), h);
    }
    h
}

fn cache_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../../target/stress-gate-cache")
}

fn cache_path(scene: &Scene, fingerprint: u64) -> PathBuf {
    let json = serde_json::to_string(scene).expect("scene json");
    let mut h = fnv(json.as_bytes(), 0xcbf29ce484222325);
    h = fnv(&perturbation().to_bits().to_le_bytes(), h);
    h = fnv(&fingerprint.to_le_bytes(), h);
    cache_dir().join(format!("{}-{h:016x}.json", scene.name))
}

/// The case's reference set from the cache, or computed (its four runs in parallel) and
/// stored. `compute`: false returns None on a miss instead of running the reference.
pub fn reference_set(scene: &Scene, compute: bool) -> Option<ReferenceSet> {
    let path = cache_path(scene, reference_fingerprint());
    if let Ok(text) = std::fs::read_to_string(&path) {
        if let Ok(s) = serde_json::from_str::<Stored>(&text) {
            return Some(ReferenceSet { reference: s.reference, half: s.half, spreads: s.spreads, reference_seconds: s.reference_seconds });
        }
    }
    if !compute {
        return None;
    }
    let eps = perturbation();
    let (reference, half, plus, minus) = std::thread::scope(|sc| {
        let r = sc.spawn(|| {
            let t = std::time::Instant::now();
            let o = World::new(scene).run();
            (o, t.elapsed().as_secs_f64())
        });
        let h = sc.spawn(|| World::new(&refined(scene)).run());
        let p = sc.spawn(|| World::new(&perturbed_by(scene, eps)).run());
        let m = sc.spawn(|| World::new(&perturbed_by(scene, -eps)).run());
        (r.join().unwrap(), h.join().unwrap(), p.join().unwrap(), m.join().unwrap())
    });
    let stored = Stored { reference: reference.0, half, spreads: vec![plus, minus], reference_seconds: reference.1 };
    std::fs::create_dir_all(cache_dir()).ok();
    std::fs::write(&path, serde_json::to_string(&stored).expect("json")).ok();
    Some(ReferenceSet { reference: stored.reference, half: stored.half, spreads: stored.spreads, reference_seconds: stored.reference_seconds })
}
