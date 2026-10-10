//! Comparison of observations, shared by the world tests.

use stress_ref::observation::Observation;
use stress_ref::scene::Scene;

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

pub fn perturbed(scene: &Scene) -> Scene {
    perturbed_by(scene, std::env::var("STRESS_GPU_PERTURB").ok().and_then(|v| v.parse::<f64>().ok()).unwrap_or(1e-4))
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

/// The reference's sensitivity to its inputs: the run with its inputs perturbed by
/// 1e-4 (`STRESS_GPU_PERTURB` overrides). That is the size of the GPU's own perturbation:
/// f32 arithmetic moves even smooth, intact runs by 1e-5 to 5e-4 of their range over
/// thousands of substeps (the cantilevers, the bar wave), so wherever the reference
/// separates under a 1e-4 change (fracture cascades, fatigue and settling thresholds),
/// the GPU may separate as far.
pub fn spread_run(scene: &Scene, _reference: &Observation) -> Observation {
    stress_ref::world::World::new(&perturbed(scene)).run()
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
/// probes within 1e-3 of their range, or within twice the larger of the reference's
/// timestep-halving and input-perturbation spreads; broken bonds and fragments within
/// 10% (at least one), or within those spreads. Returns what fails.
pub fn gate(reference: &Observation, ours: &Observation, half: &Observation, spread: &Observation) -> Vec<String> {
    let mut fails = Vec::new();
    let (gpu_err, _) = difference(reference, ours);
    let (half_err, _) = difference(reference, half);
    let (spread_err, _) = difference(reference, spread);
    let allowed = (2.0 * half_err.max(spread_err)).max(1e-3);
    if !(gpu_err <= allowed) {
        fails.push(format!("probes {gpu_err:.1e} > {allowed:.1e}"));
    }
    for key in ["broken_bonds", "fragments"] {
        let r = value(reference, key);
        let d = (value(ours, key) - r).abs();
        let allowed = (0.1 * r).max(1.0).max((value(half, key) - r).abs()).max((value(spread, key) - r).abs());
        if d > allowed {
            fails.push(format!("{key} {} vs {r} (allowed {allowed})", value(ours, key)));
        }
    }
    fails
}
