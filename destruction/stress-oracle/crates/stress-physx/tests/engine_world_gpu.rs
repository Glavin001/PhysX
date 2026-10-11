//! The GPU world coupled to PhysX CPU (`GpuWorld::with_engine`: impact islands simulated
//! by the GPU's own chunk-level contact) against the reference world coupled the same
//! way (`World::with_engine`) and the standalone reference world.
//!
//!   cargo test --release -p stress-physx --features gpu --test engine_world_gpu -- --nocapture
#![cfg(feature = "gpu")]

use stress_gpu::gpu::Gpu;
use stress_gpu::world::GpuWorld;
use stress_physx::PhysxEngine;
use stress_ref::math::Vec3;
use stress_ref::scene::Scene;
use stress_ref::world::World;

/// The free wall and ram of `engine_world.rs` (a 200 kg ram at 40 m/s into a free
/// 528 kg concrete wall), with the methods the GPU implements (penalty contact).
fn ram_scene() -> Scene {
    use stress_ref::builders::*;
    use stress_ref::scene::*;
    let mut s = new_scene("physx_ram_free_wall", "free concrete wall hit by a steel ram");
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
    s.sim.duration = 0.5;
    s.sim.methods = Methods::established();
    s
}

#[test]
fn gpu_ram_through_free_wall_matches_the_coupled_reference() {
    let scene = ram_scene();
    let Ok(gpu) = Gpu::new() else {
        eprintln!("no GPU; skipping");
        return;
    };
    let mut standalone = World::new(&scene);
    let so = standalone.run();
    let Some(engine) = PhysxEngine::boxed(Vec3::from_array(scene.gravity)) else {
        eprintln!("PhysX CPU unavailable; skipping");
        return;
    };
    let mut reference = World::with_engine(&scene, engine);
    let t = std::time::Instant::now();
    let ro = reference.run();
    let ref_secs = t.elapsed().as_secs_f64();
    let engine = PhysxEngine::boxed(Vec3::from_array(scene.gravity)).expect("PhysX");
    let mut w = GpuWorld::with_engine(&gpu, &scene, engine).expect("GPU coupled world");
    let t = std::time::Instant::now();
    let go = w.run(&gpu).expect("run");
    let gpu_secs = t.elapsed().as_secs_f64();
    let ram = |o: &stress_ref::observation::Observation, v: f64| format!("ram {v:.2} m/s, {} fragments, {} broken bonds", o.values["fragments"], o.values["broken_bonds"]);
    println!("standalone reference: {}", ram(&so, standalone.impactors[0].velocity.y));
    println!("reference + PhysX:    {} ({ref_secs:.1} s; island frames {}, redone {})", ram(&ro, reference.impactors[0].velocity.y), ro.values["island_frames"], ro.values["redone_frames"]);
    println!("GPU + PhysX:          {} ({gpu_secs:.1} s; island frames {}, redone {})", ram(&go, w.solver.impactors[0].velocity.y), go.values["island_frames"], go.values["redone_frames"]);
    let (vr, vg) = (reference.impactors[0].velocity.y, w.solver.impactors[0].velocity.y);
    assert!(go.values["island_frames"] > 0.0, "no impact island");
    assert!((vg - vr).abs() < 0.05 * vr, "ram {vg} vs {vr}");
    let (fr, fg) = (ro.values["fragments"], go.values["fragments"]);
    assert!((fg - fr).abs() <= 0.25 * fr.max(4.0), "fragments {fg} vs {fr}");
}

/// Diagnostic (`--ignored --nocapture`, `STRESS_GPU_COUPLED_TRACE=1`): the GPU coupled
/// world alone, frame by frame.
#[test]
#[ignore]
fn gpu_coupled_trace() {
    let scene = ram_scene();
    let Ok(gpu) = Gpu::new() else { return };
    let engine = PhysxEngine::boxed(Vec3::from_array(scene.gravity)).expect("PhysX");
    let mut w = GpuWorld::with_engine(&gpu, &scene, engine).expect("GPU coupled world");
    for _ in 0..6 {
        let t = std::time::Instant::now();
        w.step_frame(&gpu).expect("frame");
        eprintln!("  frame took {:.1} ms; ram {:.2} m/s", t.elapsed().as_secs_f64() * 1e3, w.solver.impactors[0].velocity.y);
    }
}

/// Diagnostic (`--ignored --nocapture`): the ram through the free wall at the true
/// stable step (`stability::with_true_step`, safety 0.9), the reference coupled world and
/// the GPU coupled world both at that step, against the reference coupled world at its
/// own step (the truth); frame times of the GPU world.
#[test]
#[ignore]
fn gpu_coupled_true_step() {
    let scene = ram_scene();
    let (scaled, ratio) = stress_gpu::stability::with_true_step(&scene, 0.9);
    println!("with_true_step: safety x{ratio:.1} (stress and contact steps)");
    // The oracle's certified true step: the stress bound only; contacts keep theirs.
    let mut certified = scene.clone();
    certified.sim.methods.true_step = true;
    // Converged by the reference's refinement (`reference_refinement`): safety 0.25.
    let mut converged = certified.clone();
    converged.sim.courant_safety = 0.25;
    let Ok(gpu) = Gpu::new() else { return };
    let ram = |o: &stress_ref::observation::Observation, v: f64| format!("ram {v:.2} m/s, {} fragments, {} broken bonds", o.values["fragments"], o.values["broken_bonds"]);
    for (label, s) in [("reference step", &scene), ("certified true step, safety 0.25 (converged)", &converged), ("certified true step (stress only)", &certified), ("with_true_step (stress and contact)", &scaled)] {
        let mut reference = World::with_engine(s, PhysxEngine::boxed(Vec3::from_array(s.gravity)).expect("PhysX"));
        let ro = reference.run();
        println!("{label}: reference + PhysX: {}", ram(&ro, reference.impactors[0].velocity.y));
        let mut w = GpuWorld::with_engine(&gpu, s, PhysxEngine::boxed(Vec3::from_array(s.gravity)).expect("PhysX")).expect("GPU world");
        let mut times = Vec::new();
        let frames = (s.sim.duration / s.sim.frame_dt).round() as usize;
        for _ in 0..frames {
            let t = std::time::Instant::now();
            w.step_frame(&gpu).expect("frame");
            times.push(t.elapsed().as_secs_f64() * 1e3);
        }
        w.solver.sync(&gpu);
        let go = w.observation();
        let mut sorted = times[1..].to_vec();
        sorted.sort_by(f64::total_cmp);
        println!(
            "{label}: GPU + PhysX: {}; frames: first {:.1} ms, median {:.1}, worst {:.1}",
            ram(&go, w.solver.impactors[0].velocity.y),
            times[0],
            sorted[sorted.len() / 2],
            sorted[sorted.len() - 1]
        );
    }
}

/// Diagnostic (`--ignored --nocapture`): the standalone reference's own refinement of the
/// ram through the free wall (which step is converged): Courant safety halved, with the
/// established bound and with the certified true step.
#[test]
#[ignore]
fn reference_refinement() {
    let scene = ram_scene();
    for true_step in [false, true] {
        for safety in [0.5, 0.25, 0.125, 0.0625] {
            let mut s = scene.clone();
            s.sim.methods.true_step = true_step;
            s.sim.courant_safety = safety;
            s.sim.duration = 0.1;
            let mut w = World::new(&s);
            let t = std::time::Instant::now();
            let o = w.run();
            println!(
                "true_step {true_step}, safety {safety}: ram {:.2} m/s, {} fragments, {} broken bonds, {} substeps ({:.0} s)",
                w.impactors[0].velocity.y,
                o.values["fragments"],
                o.values["broken_bonds"],
                o.values["substeps"],
                t.elapsed().as_secs_f64()
            );
        }
    }
}
