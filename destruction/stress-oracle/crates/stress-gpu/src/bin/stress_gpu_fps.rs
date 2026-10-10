//! Frame times, frame by frame, for real-time qualification: the GPU world and the f64
//! reference world on the same scenes, in two regimes each:
//!   idle         the intact structure under gravity alone (impactors, loads and events
//!                removed), fresh;
//!   destruction  the scene as authored (impacts, loads, events).
//! Each frame is `sim.frame_dt` (1/60 s). Reported: the first frame (initialisation
//! spike, kept visible), the median and worst of the rest, worst-case FPS, frames over
//! the 8 ms and 16.67 ms budgets, and substeps per frame.
//!
//!   stress-gpu-fps [--frames N] [--config authored|realtime] [--ref-cap SECONDS] [--only NAME]
//!
//! `--config realtime`: the GPU at the true stable step in adaptive mode (sleeping); the
//! reference stays at its own settings (its accuracy baseline).

use std::time::Instant;

use stress_gpu::gpu::Gpu;
use stress_gpu::world::GpuWorld;
use stress_ref::math::Vec3;
use stress_ref::scene::{ImpactorDesc, ImpactorShape, Scene};
use stress_ref::world::World;

struct Frames {
    times: Vec<f64>,
    substeps: Vec<u64>,
    setup: f64,
    chunks: usize,
    bonds: usize,
    broken: usize,
}

fn bounds(scene: &Scene) -> (Vec3, Vec3) {
    let mut lo = Vec3::splat(f64::INFINITY);
    let mut hi = Vec3::splat(f64::NEG_INFINITY);
    for c in scene.bodies.iter().flat_map(|b| b.chunks.iter()) {
        let p = Vec3::from_array(c.center);
        lo = lo.component_min(p);
        hi = hi.component_max(p);
    }
    (lo, hi)
}

/// A 400 kg box rammed at 12 m/s into the middle of the structure's -x face.
fn rammed(mut scene: Scene) -> Scene {
    let (lo, hi) = bounds(&scene);
    let mid = (lo + hi) * 0.5;
    let material = scene.bodies[0].chunks[0].material.clone();
    scene.impactors.push(ImpactorDesc {
        name: "ram".into(),
        shape: ImpactorShape::Box { half_extents: [0.15, 0.3, 0.3] },
        mass: 400.0,
        position: [lo.x - 0.35, mid.y, mid.z],
        orientation: [0.0, 0.0, 0.0, 1.0],
        velocity: [12.0, 0.0, 0.0],
        angular_velocity: [0.0; 3],
        material,
        crush: None,
    });
    scene
}

fn idle(scene: &Scene) -> Scene {
    let mut s = scene.clone();
    s.impactors.clear();
    s.loads.clear();
    s.events.clear();
    // Probes and metrics may name the removed impactors.
    s.probes.clear();
    s.metrics.clear();
    s.name = format!("{} (idle)", s.name);
    s
}

fn counts(m: &stress_ref::solver::ReferenceSolver) -> (usize, usize, usize) {
    let chunks = m.clusters.iter().map(|c| c.chunks.len()).sum();
    let bonds: usize = m.bonds.iter().map(|b| b.len()).sum();
    let broken = m.bonds.iter().flatten().filter(|b| !b.connected()).count();
    (chunks, bonds, broken)
}

fn run_gpu(gpu: &Gpu, scene: &Scene, frames: usize) -> Result<Frames, String> {
    let t = Instant::now();
    let mut world = GpuWorld::new(gpu, scene)?;
    let setup = t.elapsed().as_secs_f64();
    let mut times = Vec::new();
    let mut substeps = Vec::new();
    for _ in 0..frames {
        let before = world.solver.mirror.substeps;
        let t = Instant::now();
        world.step_frame(gpu)?;
        times.push(t.elapsed().as_secs_f64());
        substeps.push(world.solver.mirror.substeps - before);
    }
    world.solver.sync(gpu);
    let (chunks, bonds, broken) = counts(&world.solver.mirror);
    Ok(Frames { times, substeps, setup, chunks, bonds, broken })
}

fn run_ref(scene: &Scene, frames: usize, cap: f64) -> Frames {
    let t = Instant::now();
    let mut world = World::new(scene);
    let setup = t.elapsed().as_secs_f64();
    let mut times = Vec::new();
    let mut substeps = Vec::new();
    let start = Instant::now();
    for _ in 0..frames {
        let before = world.solver.substeps;
        let t = Instant::now();
        world.step_frame();
        times.push(t.elapsed().as_secs_f64());
        substeps.push(world.solver.substeps - before);
        if start.elapsed().as_secs_f64() > cap {
            break;
        }
    }
    let (chunks, bonds, broken) = counts(&world.solver);
    Frames { times, substeps, setup, chunks, bonds, broken }
}

fn report(scene: &str, regime: &str, who: &str, f: &Frames) {
    let first = f.times[0];
    let mut rest: Vec<f64> = f.times[1..].to_vec();
    rest.sort_by(f64::total_cmp);
    let median = rest.get(rest.len() / 2).copied().unwrap_or(first);
    let worst = rest.last().copied().unwrap_or(first);
    let over = |b: f64| f.times[1..].iter().filter(|&&t| t > b).count();
    let max_sub = f.substeps.iter().copied().max().unwrap_or(0);
    let mean_sub = f.substeps.iter().sum::<u64>() as f64 / f.substeps.len() as f64;
    let ms = |s: f64| s * 1e3;
    println!(
        "| {scene} | {regime} | {who} | {} / {} / {} | {:.1} | {:.2} | {:.2} | {:.1} | {} | {} | {:.0} (max {max_sub}) | {:.2} s |",
        f.chunks,
        f.bonds,
        f.broken,
        ms(first),
        ms(median),
        ms(worst),
        1.0 / worst,
        over(1.0 / 120.0),
        over(1.0 / 60.0),
        mean_sub,
        f.setup
    );
}

fn main() {
    let mut frames = 60usize;
    let mut realtime = false;
    let mut cap = 120.0;
    let mut only: Option<String> = None;
    let mut args = std::env::args().skip(1);
    while let Some(a) = args.next() {
        match a.as_str() {
            "--frames" => frames = args.next().and_then(|v| v.parse().ok()).expect("--frames N"),
            "--config" => realtime = args.next().as_deref() == Some("realtime"),
            "--ref-cap" => cap = args.next().and_then(|v| v.parse().ok()).expect("--ref-cap S"),
            "--only" => only = args.next(),
            other => panic!("unknown argument {other}"),
        }
    }
    let catalogue: Vec<Scene> = stress_ref::builders::catalog().into_iter().chain(stress_ref::showcases::catalog()).collect();
    let named = |n: &str| catalogue.iter().find(|s| s.name == n).cloned().unwrap_or_else(|| panic!("no scene {n}"));
    let packs = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../../blast/blast-stress-demo-rs/assets/scenes");
    let pack = |p: &str| stress_ref::scene_pack::import(&packs.join(format!("{p}.json")), p, "structure").expect("pack");
    let scenes: Vec<Scene> = vec![
        named("b5_wall_impact_v10"),
        named("b9_panel_high"),
        named("s_house_car"),
        rammed(pack("house-1story")),
        rammed(pack("villa-savoye")),
    ];
    let gpu = Gpu::new().expect("GPU");
    println!("{} ({:?}); {frames} frames of the scene's frame_dt; config {}", gpu.adapter_info.name, gpu.adapter_info.backend, if realtime { "realtime (GPU: true step, adaptive)" } else { "authored" });
    println!("| scene | regime | solver | chunks / bonds / broken | first frame ms | median ms | worst ms | worst-case FPS | >8 ms | >16.7 ms | substeps/frame | setup |");
    println!("|---|---|---|---|---|---|---|---|---|---|---|---|");
    for scene in scenes {
        if only.as_ref().is_some_and(|o| !scene.name.starts_with(o.as_str())) {
            continue;
        }
        for (regime, s) in [("idle", idle(&scene)), ("destruction", scene.clone())] {
            let mut g = s.clone();
            if realtime {
                g = g.with_override("sim.solve_mode", "\"adaptive\"").expect("mode");
                g = stress_gpu::stability::with_true_step(&g, 0.9).0;
            }
            match run_gpu(&gpu, &g, frames) {
                Ok(f) => report(&scene.name, regime, "GPU", &f),
                Err(e) => println!("| {} | {regime} | GPU | error: {e} |", scene.name),
            }
            report(&scene.name, regime, "stress-ref", &run_ref(&s, frames, cap));
        }
    }
}
