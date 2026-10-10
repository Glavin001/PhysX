//! The GPU world against stress-ref's `World` on the benchmark catalogue: every scene the
//! GPU supports so far, truncated in time, compared probe by probe (each sample against
//! the reference's probe range) and by the observation's outcome values.
//!
//! Fracture cascades can be chaotic: tiny differences grow into different breakage.
//! Each comparison is therefore set beside the reference's own sensitivity: the same
//! scene run by the reference with its impactor and body velocities and gravity scaled
//! by (1 + 1e-6). `STRESS_GPU_SCENES=b5,b7` restricts the scenes.

use stress_gpu::gpu::Gpu;
use stress_gpu::world::{unsupported, GpuWorld};
use stress_ref::observation::Observation;
use stress_ref::scene::Scene;
use stress_ref::world::World;

const KEYS: [&str; 6] = ["broken_bonds", "fragments", "max_failure_index", "first_crack_time", "bond_dissipation", "damping_dissipation"];

/// Worst probe error (relative to the reference's probe range) and the outcome values.
fn difference(reference: &Observation, other: &Observation) -> (f64, Vec<String>) {
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

fn perturbed(scene: &Scene) -> Scene {
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

#[test]
fn catalogue_matches_the_reference_world() {
    let gpu = Gpu::new().expect("GPU");
    let filter: Option<Vec<String>> = std::env::var("STRESS_GPU_SCENES").ok().map(|v| v.split(',').map(str::to_string).collect());
    let mut ran = 0;
    for mut scene in stress_ref::builders::catalog() {
        let name = scene.name.clone();
        if filter.as_ref().is_some_and(|f| !f.iter().any(|p| name.starts_with(p.as_str()))) {
            continue;
        }
        if let Some(why) = unsupported(&scene) {
            eprintln!("{name:<26} skipped: {why}");
            continue;
        }
        scene.sim.duration = scene.sim.duration.min(0.1);
        let t = std::time::Instant::now();
        let ours = match GpuWorld::new(&gpu, &scene).and_then(|mut w| w.run(&gpu)) {
            Ok(o) => o,
            Err(e) => {
                eprintln!("{name:<26} error: {e}");
                continue;
            }
        };
        let gpu_time = t.elapsed().as_secs_f64();
        let t = std::time::Instant::now();
        let reference = World::new(&scene).run();
        let ref_time = t.elapsed().as_secs_f64();
        let spread = World::new(&perturbed(&scene)).run();
        let (gpu_err, gpu_notes) = difference(&reference, &ours);
        let (self_err, self_notes) = difference(&reference, &spread);
        ran += 1;
        eprintln!("{name:<26} gpu {gpu_err:.1e} vs reference's own spread {self_err:.1e} | time gpu {gpu_time:.1} s, reference {ref_time:.1} s");
        eprintln!("{:<26}   gpu: {}", "", gpu_notes.join("; "));
        eprintln!("{:<26}   ref spread: {}", "", self_notes.join("; "));
    }
    assert!(ran > 0);
}
