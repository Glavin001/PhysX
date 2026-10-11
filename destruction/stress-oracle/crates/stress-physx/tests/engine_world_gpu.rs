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
