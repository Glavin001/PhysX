//! The reference's stable substep against the true stable step (power iteration) on the
//! catalogue and the scene packs: how many substeps per 60 Hz frame each needs.
//!
//!   stress-gpu-steps [pack.json ...]

use stress_gpu::stability::true_stable_dt;
use stress_ref::scene::Scene;
use stress_ref::solver::ReferenceSolver;

fn report(scene: &Scene) {
    let m = ReferenceSolver::new(scene);
    let chunks: usize = m.structures.iter().map(|s| s.chunks.len()).sum();
    let reference = m.stable_dt();
    let t = std::time::Instant::now();
    let truth = true_stable_dt(&m, 400, 0.9);
    let took = t.elapsed().as_secs_f64();
    let per_frame = |dt: f64| (1.0 / 60.0 / dt).ceil();
    println!(
        "{:<30} {:>7} chunks  reference {:>10.3e} s ({:>10.0}/frame)  true {:>10.3e} s ({:>8.0}/frame)  x{:>8.1}  ({took:.2} s)",
        scene.name,
        chunks,
        reference,
        per_frame(reference),
        truth,
        per_frame(truth),
        truth / reference
    );
}

fn main() {
    let packs: Vec<String> = std::env::args().skip(1).collect();
    if packs.is_empty() {
        for scene in stress_ref::builders::catalog().into_iter().chain(stress_ref::showcases::catalog()) {
            report(&scene);
        }
    }
    for path in packs {
        let name = std::path::Path::new(&path).file_stem().unwrap().to_string_lossy().to_string();
        match stress_ref::scene_pack::import(std::path::Path::new(&path), &name, &name) {
            Ok(scene) => report(&scene),
            Err(e) => println!("{name}: {e}"),
        }
    }
}
