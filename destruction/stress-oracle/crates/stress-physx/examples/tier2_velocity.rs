//! Tier 2 as the analysis states it, through PhysX: impacts as velocity conditions
//! (`ImpactModel::VelocityCondition`, momentum exact) and one implicit step per frame,
//! with at most `CORRECTIONS` correction passes. Runs a scene (e.g. one written by
//! `stress-ref`'s `wall_variants`) three ways for `FRAMES` frames of 1/60 s:
//!
//! * `truth`: the standalone reference world, explicit (the oracle);
//! * `px_explicit`: PhysX + the stress solver, impacts as Hertz pulses, explicit solve;
//! * `px_tier2`: PhysX + the stress solver, velocity conditions, implicit solve.
//!
//! and reports the failure: chunks off the anchored body, how many of them move at
//! over half the ram's initial speed (the punched-out plug), and the largest fragment.
//!
//! ```text
//! PHYSX_ROOT=<install> cargo run --release -p stress-physx --example tier2_velocity -- SCENE.json [FRAMES] [CORRECTIONS]
//! ```

use stress_physx::PhysxDestruction;
use stress_ref::api::ImpactModel;
use stress_ref::scene::{Scene, SolveMode};
use stress_ref::solver::ReferenceSolver;
use stress_ref::world::World;

struct Failure {
    detached: usize,
    fast: usize,
    largest: usize,
    broken: usize,
}

fn failure(solver: &ReferenceSolver, ram_speed: f64) -> Failure {
    let mut f = Failure { detached: 0, fast: 0, largest: 0, broken: 0 };
    for c in solver.clusters.iter().filter(|c| !c.anchored) {
        f.detached += c.chunks.len();
        f.largest = f.largest.max(c.chunks.len());
        if c.velocity.norm() > 0.5 * ram_speed {
            f.fast += c.chunks.len();
        }
    }
    f.broken = solver.bonds.iter().flatten().filter(|b| !b.connected()).count();
    f
}

fn print(label: &str, f: &Failure, ram: f64, extra: &str) {
    println!(
        "{label:<12} detached {:>4}  fast {:>4}  largest {:>4}  broken {:>5}  ram {:>7.2} m/s{extra}",
        f.detached, f.fast, f.largest, f.broken, ram
    );
}

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let scene = Scene::load(std::path::Path::new(&args[0])).expect("scene");
    let frames: usize = args.get(1).map(|a| a.parse().expect("frames")).unwrap_or(6);
    let corrections: usize = args.get(2).map(|a| a.parse().expect("corrections")).unwrap_or(1);
    let dt = 1.0 / 60.0;
    let ram0 = scene.impactors[0].velocity;
    let ram_speed = (ram0[0] * ram0[0] + ram0[1] * ram0[1] + ram0[2] * ram0[2]).sqrt();

    let mut truth_scene = scene.clone();
    truth_scene.sim.solve_mode = SolveMode::Explicit;
    truth_scene.sim.frame_dt = dt;
    truth_scene.sim.duration = frames as f64 * dt;
    let mut truth = World::new(&truth_scene);
    for _ in 0..frames {
        truth.step_frame();
    }
    print("truth", &failure(&truth.solver, ram_speed), truth.impactors[0].velocity.norm(), "");

    for (label, model, mode) in [
        ("px_explicit", ImpactModel::Pulse, SolveMode::Explicit),
        ("px_tier2", ImpactModel::VelocityCondition, SolveMode::Implicit),
    ] {
        let mut s = scene.clone();
        s.sim.solve_mode = mode;
        s.sim.frame_dt = dt;
        let mut sim = PhysxDestruction::new(&s).expect("PhysX CPU scene");
        sim.stress.filter.impact_model = model;
        sim.correction_limit = corrections;
        let mut used = 0;
        for _ in 0..frames {
            sim.step(dt);
            used += sim.last_corrections;
        }
        let (_, v) = sim.impactor_state(0);
        print(label, &failure(&sim.stress.solver, ram_speed), v.norm(), &format!("  corrections {used}"));
    }
}
