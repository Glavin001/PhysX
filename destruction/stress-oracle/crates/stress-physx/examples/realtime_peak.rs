//! Real-time peak of the GPU stress solver coupled to PhysX with GPU dynamics (CUDA, or
//! CuMetal on macOS), end to end: complete frames of `GpuWorld::with_engine` (impact
//! islands, engine step, GPU substeps, verification, write-back), in three regimes:
//!   house idle   house-1story, fresh and intact, nothing touching it
//!   wall ram     a 200 kg ram at 40 m/s through a free concrete wall
//!   house ram    house-1story struck by a 400 kg box at 12 m/s
//! all in the adaptive mode (sleeping), at the certified true step, the contact step at
//! safety 0.35 and the stress step at 0.5 (`sim.stress_courant_safety`): the GPU's
//! outcomes are the same from 0.125 to 0.5 for either (tests
//! `gpu_stress_safety_convergence`, `gpu_contact_safety_convergence`), the established
//! methods (penalty contact, as on the GPU).
//!
//! Prints each regime's frames and `PEAK_MS <ms>`: the worst complete frame of any
//! regime, first frames included, the minimum over `--repeats` runs (default 1; the GPU
//! is shared), over `--seconds` of simulated time (default 0.25: the impacts and the
//! start of the collapse; 0.5 for a full qualification run).
//!
//! `--guard`: also checks each regime's outcome (ram speed, fragments, broken bonds)
//! against the reference world coupled to PhysX CPU at its converged contact step (safety
//! 0.25: the reference's global contact bound does not resolve a fracturing impact at
//! 0.5, REALTIME_ROADMAP A11), cached in `target/realtime-ref`: within twice the
//! reference's own spread (its half step and a 1e-4 change of the ram's speed), or the
//! GPU gate's floor for counts (10 %, at least one). Exits 1 if any regime fails.
//!
//!   PHYSX_ROOT=<GPU SDK> cargo run --release -p stress-physx --features gpu --example realtime_peak -- [--guard] [--repeats N] [--seconds S]

use std::time::Instant;

use stress_gpu::gpu::Gpu;
use stress_gpu::world::GpuWorld;
use stress_physx::PhysxEngine;
use stress_ref::math::Vec3;
use stress_ref::observation::Observation;
use stress_ref::scene::{Methods, Scene, SolveMode};
use stress_ref::world::World;

/// The converged real-time step and the GPU's methods, sleeping on, `seconds` long.
fn configure(mut s: Scene, seconds: f64) -> Scene {
    s.sim.methods = Methods::established();
    s.sim.methods.true_step = true;
    s.sim.courant_safety = 0.35;
    s.sim.stress_courant_safety = Some(0.5);
    s.sim.solve_mode = SolveMode::Adaptive;
    s.sim.duration = seconds;
    s
}

fn wall_ram() -> Scene {
    use stress_ref::builders::*;
    use stress_ref::scene::*;
    let mut s = new_scene("wall_ram", "free concrete wall hit by a steel ram");
    s.gravity = [0.0; 3];
    s.materials.insert("concrete".into(), oracle_concrete(None));
    s.materials.insert("steel".into(), elastic_steel());
    let chunks = grid(Vec3::new(-0.5, 0.0, -0.1), [10, 2, 11], Vec3::splat(0.1), "concrete");
    let bonds = auto_bonds(&chunks, |_, _| "concrete".into());
    s.bodies.push(body("wall", chunks, bonds));
    s.impactors.push(ImpactorDesc {
        name: "ram".into(),
        shape: ImpactorShape::Box { half_extents: [0.1, 0.1, 0.1] },
        mass: 200.0,
        position: [0.0, -0.15, 0.5],
        orientation: [1.0, 0.0, 0.0, 0.0],
        velocity: [0.0, 40.0, 0.0],
        angular_velocity: [0.0; 3],
        material: "steel".into(),
        crush: None,
    });
    s
}

fn house() -> Scene {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../../blast/blast-stress-demo-rs/assets/scenes/house-1story.json");
    stress_ref::scene_pack::import(&path, "house-1story", "structure").expect("house-1story pack")
}

fn regimes(seconds: f64) -> Vec<(&'static str, Scene)> {
    let mut idle = configure(house(), seconds);
    idle.name = "house_idle".into();
    let mut house_ram = configure(stress_gpu::scenes::rammed(house()), seconds);
    house_ram.name = "house_ram".into();
    vec![("house idle", idle), ("wall ram", configure(wall_ram(), seconds)), ("house ram", house_ram)]
}

/// One regime on the GPU with PhysX GPU: frame times (ms) and the outcome.
fn run_gpu(gpu: &Gpu, scene: &Scene) -> (Vec<f64>, Outcome) {
    let engine = PhysxEngine::boxed_gpu(Vec3::from_array(scene.gravity)).expect("a PhysX GPU scene (build with PHYSX_ROOT at a GPU SDK)");
    let mut w = GpuWorld::with_engine(gpu, scene, engine).expect("GPU coupled world");
    let frames = (scene.sim.duration / scene.sim.frame_dt).round() as usize;
    let mut times = Vec::with_capacity(frames);
    for _ in 0..frames {
        let t = Instant::now();
        w.step_frame(gpu).expect("frame");
        times.push(t.elapsed().as_secs_f64() * 1e3);
    }
    w.solver.sync(gpu);
    let o = w.observation();
    let ram = w.solver.impactors.first().map_or(0.0, |i| i.velocity.norm());
    (times, Outcome::of(&o, ram))
}

#[derive(Clone, Copy, Debug, serde::Serialize, serde::Deserialize)]
struct Outcome {
    ram: f64,
    fragments: f64,
    broken: f64,
}

impl Outcome {
    fn of(o: &Observation, ram: f64) -> Outcome {
        Outcome { ram, fragments: o.values["fragments"], broken: o.values["broken_bonds"] }
    }
}

/// The reference coupled to PhysX CPU at the scene's step, and its spread (half step,
/// the ram 1e-4 faster), cached by the scene and stress-ref's sources.
#[derive(serde::Serialize, serde::Deserialize)]
struct Reference {
    at: Outcome,
    spread: Outcome,
}

fn reference(scene: &Scene) -> Reference {
    // The reference at its converged contact step.
    let mut scene = scene.clone();
    scene.sim.courant_safety = 0.25;
    let scene = &scene;
    let key = serde_json::to_string(scene).expect("scene json");
    let path = stress_gpu::gate::cached_path(&format!("realtime-ref-{}", scene.name), &key);
    if let Some(r) = std::fs::read_to_string(&path).ok().and_then(|t| serde_json::from_str(&t).ok()) {
        return r;
    }
    let run = |s: &Scene| {
        let mut w = World::with_engine(s, PhysxEngine::boxed(Vec3::from_array(s.gravity)).expect("PhysX CPU"));
        let o = w.run();
        Outcome::of(&o, w.impactors.first().map_or(0.0, |i| i.velocity.norm()))
    };
    let at = run(scene);
    let mut half = scene.clone();
    half.sim.scale_safety(0.5);
    let mut faster = scene.clone();
    for imp in &mut faster.impactors {
        imp.velocity = imp.velocity.map(|v| v * (1.0 + 1e-4));
    }
    let others = [run(&half), run(&faster)];
    let dev = |f: fn(&Outcome) -> f64| others.iter().map(|o| (f(o) - f(&at)).abs()).fold(0.0, f64::max);
    let r = Reference { at, spread: Outcome { ram: dev(|o| o.ram), fragments: dev(|o| o.fragments), broken: dev(|o| o.broken) } };
    std::fs::create_dir_all(path.parent().unwrap()).ok();
    std::fs::write(&path, serde_json::to_string(&r).unwrap()).expect("cache");
    r
}

/// Twice the reference's spread; counts at least the GPU gate's floor (10 %, one).
fn within(gpu: &Outcome, r: &Reference) -> Result<(), String> {
    let ram_tol = 2.0 * r.spread.ram;
    let count_tol = |v: f64, s: f64| (2.0 * s).max(0.1 * v).max(1.0);
    let mut errs = Vec::new();
    if (gpu.ram - r.at.ram).abs() > ram_tol.max(1e-3 * r.at.ram) {
        errs.push(format!("ram {:.3} vs {:.3} (tolerance {:.3})", gpu.ram, r.at.ram, ram_tol.max(1e-3 * r.at.ram)));
    }
    if (gpu.fragments - r.at.fragments).abs() > count_tol(r.at.fragments, r.spread.fragments) {
        errs.push(format!("fragments {} vs {} (tolerance {})", gpu.fragments, r.at.fragments, count_tol(r.at.fragments, r.spread.fragments)));
    }
    if (gpu.broken - r.at.broken).abs() > count_tol(r.at.broken, r.spread.broken) {
        errs.push(format!("broken bonds {} vs {} (tolerance {})", gpu.broken, r.at.broken, count_tol(r.at.broken, r.spread.broken)));
    }
    if errs.is_empty() {
        Ok(())
    } else {
        Err(errs.join("; "))
    }
}

fn main() {
    let mut guard = false;
    let mut repeats = 1usize;
    let mut seconds = 0.25f64;
    let mut args = std::env::args().skip(1);
    while let Some(a) = args.next() {
        match a.as_str() {
            "--guard" => guard = true,
            "--repeats" => repeats = args.next().and_then(|v| v.parse().ok()).expect("--repeats N"),
            "--seconds" => seconds = args.next().and_then(|v| v.parse().ok()).expect("--seconds S"),
            other => panic!("unknown argument {other}"),
        }
    }
    let gpu = Gpu::new().expect("GPU");
    let mut peak = 0.0f64;
    let mut failed = false;
    for (label, scene) in regimes(seconds) {
        let mut best: Option<(Vec<f64>, Outcome)> = None;
        for _ in 0..repeats.max(1) {
            let (times, outcome) = run_gpu(&gpu, &scene);
            let worst = times.iter().copied().fold(0.0, f64::max);
            if best.as_ref().is_none_or(|b| worst < b.0.iter().copied().fold(0.0, f64::max)) {
                best = Some((times, outcome));
            }
        }
        let (times, outcome) = best.unwrap();
        let worst = times.iter().copied().fold(0.0, f64::max);
        let mut sorted = times[1..].to_vec();
        sorted.sort_by(f64::total_cmp);
        println!(
            "{label:<11} first {:7.1} ms  median {:7.1} ms  worst {:7.1} ms  | ram {:.2} m/s, {} fragments, {} broken bonds",
            times[0],
            sorted[sorted.len() / 2],
            worst,
            outcome.ram,
            outcome.fragments,
            outcome.broken
        );
        peak = peak.max(worst);
        if guard {
            let r = reference(&scene);
            match within(&outcome, &r) {
                Ok(()) => println!("  guard: ok against the reference (ram {:.2}, {} fragments, {} broken; spread {:.3}, {}, {})", r.at.ram, r.at.fragments, r.at.broken, r.spread.ram, r.spread.fragments, r.spread.broken),
                Err(e) => {
                    println!("  guard: FAIL {e}");
                    failed = true;
                }
            }
        }
    }
    println!("PEAK_MS {peak:.1}");
    if failed {
        std::process::exit(1);
    }
}
