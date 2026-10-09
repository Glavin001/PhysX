//! The world with PhysX CPU as its rigid-body engine (`World::with_engine`) against the
//! standalone reference world.

use stress_physx::PhysxEngine;
use stress_ref::engine::{BodyGeometry, BodyKey, BoxShape, EngineBody, RigidEngine};
use stress_ref::math::{Pose, Quat, Vec3};
use stress_ref::scene::Scene;
use stress_ref::world::World;

fn coupled(scene: &Scene) -> Option<World> {
    let engine = PhysxEngine::boxed(Vec3::from_array(scene.gravity))?;
    Some(World::with_engine(scene, engine))
}

/// A box resting on the ground: the contact impulses PhysX reports on its chunk push it
/// up and add up to its weight over a step.
#[test]
fn engine_contact_impulses_carry_the_weight_upwards() {
    let Some(mut e) = PhysxEngine::new(Vec3::new(0.0, 0.0, -9.81)) else {
        eprintln!("PhysX CPU unavailable; skipping");
        return;
    };
    e.add_ground(0.0);
    let mass = 100.0;
    let key = BodyKey::Cluster(1);
    e.sync_bodies(&[EngineBody {
        key,
        signature: 1,
        geometry: BodyGeometry::Boxes(vec![BoxShape {
            local: Pose::default(),
            half_extents: Vec3::splat(0.5),
            mass,
            chunk: Some((0, 7)),
            hull: None,
        }]),
        fixed: false,
        ccd: false,
        pose: Pose::new(Vec3::new(0.0, 0.0, 0.5), Quat::IDENTITY),
        velocity: Vec3::ZERO,
        angular_velocity: Vec3::ZERO,
    }]);
    let dt = 1.0 / 60.0;
    let mut last = Vec::new();
    for _ in 0..60 {
        last = e.step(dt, &[], &[]);
    }
    let total = last.iter().fold(Vec3::ZERO, |a, c| a + c.impulse);
    println!("closing speeds {:?}", last.iter().map(|c| c.approach_speed).collect::<Vec<_>>());
    println!("{} contacts, impulse {total:?}", last.len());
    assert!(last.iter().all(|c| c.structure == 0 && c.chunk == 7 && c.other.is_none()));
    assert!((total.z - mass * 9.81 * dt).abs() < 0.02 * mass * 9.81 * dt, "{total:?}");
    let z = e.motion()[0].pose.position.z;
    assert!((z - 0.5).abs() < 0.01, "rests at {z}");
}

/// A fast ram through a free wall. PhysX alone resolves it against the whole wall
/// (the ram drops to ~11 m/s); with the impact owned by the stress solve, the coupled
/// run matches the reference world: the ram keeps ~35 m/s, the wall breaks into the
/// same fragments, momentum is conserved.
#[test]
fn ram_through_free_wall_matches_the_reference_world() {
    let scene = ram_scene();
    let mut reference = World::new(&scene);
    let ro = reference.run();
    let Some(mut w) = coupled(&scene) else {
        eprintln!("PhysX CPU unavailable; skipping");
        return;
    };
    let p0 = momentum(&w);
    let o = w.run();
    let p1 = momentum(&w);
    let (vr, vp) = (reference.impactors[0].velocity.y, w.impactors[0].velocity.y);
    println!(
        "reference: ram {vr:.2} m/s, {} fragments; physx-coupled: ram {vp:.2} m/s, {} fragments, {} island frames (max {} bodies)",
        ro.values["fragments"], o.values["fragments"], w.island_frames, w.max_island_bodies
    );
    assert!(w.island_frames > 0);
    println!("engine body-frames {}, island body-frames {}", w.engine_body_frames, w.island_body_frames);
    assert!((vp - vr).abs() < 0.05 * vr, "ram {vp} vs {vr}");
    assert!((p1 - p0).norm() < 1e-3 * p0.norm(), "momentum {p1:?} vs {p0:?}");
    let (fr, fp) = (ro.values["fragments"], o.values["fragments"]);
    assert!((fp - fr).abs() <= 0.25 * fr, "fragments {fp} vs {fr}");
}

/// A free (unsupported) column standing on the ground: PhysX carries it, and the
/// ground reaction it reports must reach the stress solve, so the bottom joint carries
/// the weight of the four chunks above it (statics: N = 4 m g), as in the standalone
/// world. Nothing about this scene breaks the rigid assumption, so PhysX integrates
/// the column every frame.
#[test]
fn free_column_on_the_ground_carries_its_weight_through_physx_contacts() {
    use stress_ref::builders::*;
    use stress_ref::scene::*;
    let mut s = new_scene("free_column", "five free chunks standing on the ground");
    s.materials.insert("concrete".into(), oracle_concrete(None));
    let chunks = grid(Vec3::new(-0.1, -0.1, 0.0), [1, 1, 5], Vec3::splat(0.2), "concrete");
    let bonds = auto_bonds(&chunks, |_, _| "concrete".into());
    s.bodies.push(body("column", chunks, bonds));
    s.ground = Some(GroundDesc { height: 0.0, friction: 0.5, material: "concrete".into() });
    s.sim.duration = 1.0;
    let base_force = |w: &mut World| {
        let mut sum = 0.0;
        let mut n = 0;
        while w.solver.time < s.sim.duration {
            w.step_frame();
            if w.solver.time > 0.5 {
                let b = w.solver.bonds[0].iter().find(|b| b.geometry.a.min(b.geometry.b) == 0 && b.geometry.a.max(b.geometry.b) == 1).unwrap();
                sum += b.force.lin.z;
                n += 1;
            }
        }
        sum / n as f64
    };
    let mass = w_mass(&s);
    let expected = -4.0 * mass * 9.81;
    let standalone = base_force(&mut World::new(&s));
    let Some(mut w) = coupled(&s) else {
        eprintln!("PhysX CPU unavailable; skipping");
        return;
    };
    let physx = base_force(&mut w);
    println!(
        "base joint: expected {expected:.1} N, standalone {standalone:.1} N, physx {physx:.1} N; engine body-frames {}, island {}",
        w.engine_body_frames, w.island_body_frames
    );
    assert_eq!(w.island_body_frames, 0);
    assert!(w.engine_body_frames > 0);
    assert!((standalone - expected).abs() < 0.01 * expected.abs(), "standalone {standalone} vs {expected}");
    assert!((physx - expected).abs() < 0.01 * expected.abs(), "physx {physx} vs {expected}");
    let z = w.solver.clusters[0].com_world().z;
    assert!((z - 0.5).abs() < 0.01, "column centre at {z}");
}

/// Mass of one chunk of the scene's first body.
fn w_mass(s: &Scene) -> f64 {
    stress_ref::structure::Structure::from_scene(s, 0).chunks[0].mass
}

/// Linear momentum of every body (hidden deformation carries none: mean-axis frame).
fn momentum(w: &World) -> Vec3 {
    let clusters = w.solver.clusters.iter().filter(|c| !c.anchored).fold(Vec3::ZERO, |a, c| a + c.velocity * c.mass);
    w.impactors.iter().fold(clusters, |a, m| a + m.velocity * m.mass)
}

/// The scene of `physx_integration.rs`: a free 1 x 0.2 x 1.1 m concrete wall, a 200 kg
/// steel ram at 40 m/s, no gravity.
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
    s
}
