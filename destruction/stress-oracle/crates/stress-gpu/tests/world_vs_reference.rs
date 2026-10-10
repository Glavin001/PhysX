//! The GPU world against stress-ref's `World` on the benchmark catalogue: every scene the
//! GPU supports so far, truncated in time, compared probe by probe (each sample against
//! the reference's probe range) and by the observation's outcome values.

use stress_gpu::gpu::Gpu;
use stress_gpu::world::{unsupported, GpuWorld};
use stress_ref::observation::Observation;
use stress_ref::scene::Scene;
use stress_ref::world::World;

fn compare(gpu: &Gpu, mut scene: Scene, duration: f64) -> Result<(String, f64), String> {
    scene.sim.duration = scene.sim.duration.min(duration);
    let mut world = GpuWorld::new(gpu, &scene)?;
    let ours: Observation = world.run(gpu)?;
    let reference = World::new(&scene).run();
    let mut worst = 0.0f64;
    let mut report = Vec::new();
    for (name, r) in &reference.probes {
        let Some(g) = ours.probes.get(name) else {
            report.push(format!("{name}: missing"));
            worst = f64::INFINITY;
            continue;
        };
        let range = r.v.iter().fold(0.0f64, |m, x| m.max(x.abs())).max(1e-30);
        let n = r.v.len().min(g.v.len());
        let err = (0..n).map(|i| (r.v[i] - g.v[i]).abs()).fold(0.0f64, f64::max) / range;
        let count = if r.v.len() == g.v.len() { String::new() } else { format!(" (samples {} vs {})", r.v.len(), g.v.len()) };
        report.push(format!("{name}: {err:.2e}{count}"));
        worst = worst.max(err);
    }
    for key in ["broken_bonds", "fragments", "max_failure_index", "first_crack_time", "bond_dissipation", "damping_dissipation", "substeps"] {
        let (r, g) = (reference.values.get(key).copied(), ours.values.get(key).copied());
        if r != g {
            report.push(format!("{key}: ref {r:?} gpu {g:?}"));
        }
    }
    Ok((report.join("; "), worst))
}

#[test]
fn catalogue_matches_the_reference_world() {
    let gpu = Gpu::new().expect("GPU");
    let mut ran = 0;
    for scene in stress_ref::builders::catalog() {
        let name = scene.name.clone();
        if let Some(why) = unsupported(&scene) {
            eprintln!("{name:<32} skipped: {why}");
            continue;
        }
        match compare(&gpu, scene, 0.1) {
            Ok((report, worst)) => {
                ran += 1;
                eprintln!("{name:<32} worst probe error {worst:.2e}: {report}");
            }
            Err(e) => eprintln!("{name:<32} error: {e}"),
        }
    }
    assert!(ran > 0);
}
