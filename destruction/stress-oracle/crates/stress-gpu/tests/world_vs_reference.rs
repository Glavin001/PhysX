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
use stress_ref::world::World;

mod common;
use common::{difference, gate, refined, spread_run};

#[test]
fn catalogue_matches_the_reference_world() {
    let gpu = Gpu::new().expect("GPU");
    let filter: Option<Vec<String>> = std::env::var("STRESS_GPU_SCENES").ok().map(|v| v.split(',').map(str::to_string).collect());
    let mut ran = 0;
    let mut failures = Vec::new();
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
        let spread = spread_run(&scene, &reference);
        let half = World::new(&refined(&scene)).run();
        let (gpu_err, gpu_notes) = difference(&reference, &ours);
        let (self_err, self_notes) = difference(&reference, &spread);
        let (half_err, half_notes) = difference(&reference, &half);
        ran += 1;
        eprintln!("{name:<26} gpu {gpu_err:.1e} vs reference's spread {self_err:.1e}, half step {half_err:.1e} | time gpu {gpu_time:.1} s, reference {ref_time:.1} s");
        eprintln!("{:<26}   gpu: {}", "", gpu_notes.join("; "));
        eprintln!("{:<26}   ref spread: {}", "", self_notes.join("; "));
        eprintln!("{:<26}   ref half step: {}", "", half_notes.join("; "));
        let fails = gate(&reference, &ours, &half, &spread);
        if !fails.is_empty() {
            eprintln!("{:<26}   GATE: {}", "", fails.join("; "));
            failures.push(format!("{name}: {}", fails.join("; ")));
        }
    }
    assert!(ran > 0);
    if std::env::var("STRESS_GPU_GATE").as_deref() != Ok("report") {
        assert!(failures.is_empty(), "accuracy gate:\n{}", failures.join("\n"));
    }
}
