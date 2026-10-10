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
    let mut s = scene.clone();
    let k = 1.0 + std::env::var("STRESS_GPU_PERTURB").ok().and_then(|v| v.parse::<f64>().ok()).unwrap_or(1e-6);
    s.gravity = s.gravity.map(|g| g * k);
    for imp in &mut s.impactors {
        imp.velocity = imp.velocity.map(|v| v * k);
    }
    for b in &mut s.bodies {
        b.linear_velocity = b.linear_velocity.map(|v| v * k);
    }
    s
}
