//! Substep throughput of the two kernel shapes on growing scenes:
//!   per-substep  two dispatches per substep (all chunks)
//!   island       one dispatch for all substeps, one threadgroup per island
//!
//!   full         the full model (`GpuSolver`: joint law, rigid motion, drift removal)
//!
//!   stress-gpu-bench [--substeps N] [--full]

use std::time::Instant;

use stress_gpu::gpu::Gpu;
use stress_gpu::scenes;
use stress_gpu::solver::GpuSolver;
use stress_gpu::stress::GpuStress;
use stress_ref::scene::{Scene, SolveMode};
use stress_ref::solver::ReferenceSolver;

fn main() {
    let mut substeps = 2000usize;
    let mut full = false;
    let mut args = std::env::args().skip(1);
    while let Some(a) = args.next() {
        match a.as_str() {
            "--substeps" => substeps = args.next().and_then(|v| v.parse().ok()).expect("--substeps N"),
            "--full" => full = true,
            other => panic!("unknown argument {other}"),
        }
    }
    let gpu = Gpu::new().expect("GPU");
    eprintln!("{} ({:?}), shaders {:?}, {substeps} substeps per run", gpu.adapter_info.name, gpu.adapter_info.backend, gpu.shader_path);
    let cases: Vec<(&str, Scene)> = vec![
        ("slab 12x6x2", scenes::slab([12, 6, 2])),
        ("slab 40x20x4", scenes::slab([40, 20, 4])),
        ("slab 100x50x4", scenes::slab([100, 50, 4])),
        ("town 64 x (12x6x2)", scenes::town(64, [12, 6, 2])),
        ("town 512 x (12x6x2)", scenes::town(512, [12, 6, 2])),
    ];
    if full {
        return full_model(&gpu, cases, substeps);
    }
    println!("{:<22} {:>8} {:>8} {:>8}  {:>12} {:>12}  {:>8}", "scene", "islands", "chunks", "bonds", "per-substep", "island", "speedup");
    for (name, mut scene) in cases {
        scene.sim.fracture = false;
        scene.sim.solve_mode = SolveMode::Explicit;
        let reference = ReferenceSolver::new(&scene);
        let mut solver = GpuStress::new(&gpu, &reference).expect("GPU solver");
        let time = |f: &mut dyn FnMut()| {
            f(); // warm-up
            gpu.device.poll(wgpu::PollType::wait_indefinitely()).unwrap();
            let t = Instant::now();
            f();
            gpu.device.poll(wgpu::PollType::wait_indefinitely()).unwrap();
            t.elapsed().as_secs_f64()
        };
        let per = time(&mut || solver.run(&gpu, substeps));
        let isl = time(&mut || solver.run_islands(&gpu, substeps));
        let rate = |secs: f64| substeps as f64 / secs;
        println!(
            "{:<22} {:>8} {:>8} {:>8}  {:>9.0} /s {:>9.0} /s  {:>7.1}x",
            name,
            solver.islands.len(),
            solver.chunks.len(),
            solver.bond_count,
            rate(per),
            rate(isl),
            per / isl
        );
    }
}

/// The full model on intact scenes (fracture on, nothing breaks): substeps per second and
/// the cost per bond-substep.
fn full_model(gpu: &Gpu, cases: Vec<(&str, Scene)>, substeps: usize) {
    println!("{:<22} {:>8} {:>8} {:>8}  {:>12} {:>14}", "scene", "islands", "chunks", "bonds", "substeps/s", "ns/bond-step");
    for (name, mut scene) in cases {
        scene.sim.solve_mode = SolveMode::Explicit;
        let reference = ReferenceSolver::new(&scene);
        let dt = reference.stable_dt();
        let bonds: usize = reference.clusters.iter().map(|c| c.bonds.len()).sum();
        let chunks: usize = reference.clusters.iter().map(|c| c.chunks.len()).sum();
        let islands = reference.clusters.len();
        let mut solver = GpuSolver::new(gpu, reference, None, Vec::new()).expect("GPU solver");
        solver.step(gpu, dt, substeps).expect("warm-up");
        let t = Instant::now();
        solver.step(gpu, dt, substeps).expect("step");
        let secs = t.elapsed().as_secs_f64();
        println!(
            "{:<22} {:>8} {:>8} {:>8}  {:>9.0} /s {:>14.2}",
            name,
            islands,
            chunks,
            bonds,
            substeps as f64 / secs,
            secs / substeps as f64 / bonds as f64 * 1e9
        );
    }
}
