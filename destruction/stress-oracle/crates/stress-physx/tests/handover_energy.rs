//! The engine handover adds no energy: a chunk resting where the world's penalty contact
//! holds it (its contact samples on the ground: corners pulled 10 % towards the centre,
//! so the true lowest corner sits 10 % of its depth below the ground) is handed to the
//! rigid-body engine for a frame. Nothing does work on it but gravity, so its kinetic
//! plus potential energy must not grow. fractured-bridge (blowup_gpu
//! `bridge_stays_within_its_energy_reference`, frame 223) handed resting debris to PhysX,
//! which pushed out of the ground and out of its neighbours the overlaps the world holds
//! at rest (a 1.6e3 N s depenetration impulse on a 2.8 t chunk); back in the world the
//! ground fired the new overlap as energy (+16 MJ).

use stress_physx::PhysxEngine;
use stress_ref::math::{Quat, Vec3};
use stress_ref::scene::{GroundDesc, Scene, SolveMode};
use stress_ref::world::World;

/// A 1 m concrete cube at `position`, turned by `q`.
fn tilted_cube(position: Vec3, q: Quat) -> Scene {
    use stress_ref::builders::*;
    let mut s = new_scene("handover", "a chunk resting on the ground, handed to the engine");
    s.materials.insert("concrete".into(), oracle_concrete(None));
    s.ground = Some(GroundDesc { height: 0.0, friction: 0.6, material: "concrete".into() });
    let mut c = chunk(Vec3::ZERO, Vec3::splat(0.5), "concrete");
    c.orientation = [1.0, 0.0, 0.0, 0.0];
    let mut b = body("cube", vec![c], Vec::new());
    b.position = position.to_array();
    b.orientation = q.to_wxyz();
    s.bodies.push(b);
    s.sim.methods = stress_ref::scene::Methods::established();
    s.sim.solve_mode = SolveMode::Adaptive;
    s
}

/// The cube rested by the world's own contact model (no engine): dropped from 1 cm and
/// left 2 s to come to rest. Its pose, its true lowest corner's height and the elastic
/// energy its contact stores at rest.
fn rested_by_the_world(q: Quat) -> (Vec3, Quat, f64, f64) {
    let r = q.to_mat3();
    let lowest = (0..8).map(|i| (r * Vec3::new(if i & 1 == 0 { -0.5 } else { 0.5 }, if i & 2 == 0 { -0.5 } else { 0.5 }, if i & 4 == 0 { -0.5 } else { 0.5 })).z).fold(f64::INFINITY, f64::min);
    let mut w = World::new(&tilted_cube(Vec3::new(0.0, 0.0, -lowest + 0.01), q));
    for _ in 0..120 {
        w.step_frame();
    }
    let cl = &w.solver.clusters[0];
    let (x, rot) = (w.solver.chunk_position(0, 0), cl.pose.rotation);
    let rm = rot.to_mat3();
    let corner = (0..8).map(|i| (x + rm * Vec3::new(if i & 1 == 0 { -0.5 } else { 0.5 }, if i & 2 == 0 { -0.5 } else { 0.5 }, if i & 4 == 0 { -0.5 } else { 0.5 })).z).fold(f64::INFINITY, f64::min);
    let stored = w.contact.stored;
    eprintln!("the world rests the cube at {:?} (speed {:.2e} m/s), its lowest corner {corner:.4} m from the ground, its contact storing {stored:.3e} J", x.to_array(), w.solver.chunk_velocity(0, 0).0.norm());
    (x, rot, corner, stored)
}

fn mechanical(w: &World) -> f64 {
    let m = &w.solver;
    let g = m.config.gravity.norm();
    let ch = &m.structures[0].chunks[0];
    let (v, om) = m.chunk_velocity(0, 0);
    let cl = &m.clusters[m.chunks[0][0].cluster];
    let r = cl.rotation() * ch.rotation;
    let iw = r * ch.inertia * r.transpose();
    0.5 * ch.mass * v.norm2() + 0.5 * om.dot(iw * om) + ch.mass * g * m.chunk_position(0, 0).z
}

fn hand_over(engine: Box<dyn stress_ref::engine::RigidEngine>, label: &str) {
    // Dropped on a face 4 degrees off flat: the world rests it where its contact samples
    // hold it (with corners pulled in, rocked onto a pulled-in corner, its true corner
    // below the ground).
    let q = Quat::from_axis_angle(Vec3::new(1.0, 0.0, 0.0), 0.07) * Quat::from_axis_angle(Vec3::new(0.0, 1.0, 0.0), 0.0);
    let (x, rot, _, stored) = rested_by_the_world(q);
    let mut w = World::with_engine(&tilted_cube(x, rot), engine);
    let e0 = mechanical(&w);
    let z0 = w.solver.chunk_position(0, 0).z;
    w.step_frame();
    let e1 = mechanical(&w);
    let z1 = w.solver.chunk_position(0, 0).z;
    let driven = w.solver.clusters[0].driven;
    // A rigid engine takes the chunk without the penalty contact's compression d: lifting
    // it out (m g d) is the only work the handover may do. At rest the contact's force
    // carries the weight, sum k_i d_i = m g, and stores E = sum k_i d_i^2 / 2, so for
    // the equal compressions of a face at rest m g d = 2 E.
    let allowance = 2.0 * stored;
    eprintln!("{label}: driven by the engine {driven}; centre {z0:.5} -> {z1:.5} m; kinetic + potential {e0:.4} -> {e1:.4} J ({:+.3e} J; the compression's lift {allowance:.3e} J)", e1 - e0);
    assert!(e1 - e0 <= allowance, "{label}: the handover added {:.3e} J (the centre rose {:.4} m), more than lifting the chunk out of its contact compression ({allowance:.3e} J)", e1 - e0, z1 - z0);
}

#[test]
fn handover_to_physx_cpu_adds_no_energy() {
    let g = Vec3::new(0.0, 0.0, -9.81);
    let Some(engine) = PhysxEngine::boxed(g) else {
        eprintln!("PhysX CPU unavailable; skipping");
        return;
    };
    hand_over(engine, "PhysX CPU");
}

#[cfg(feature = "gpu")]
#[test]
fn handover_to_physx_gpu_adds_no_energy() {
    let g = Vec3::new(0.0, 0.0, -9.81);
    let Some(engine) = PhysxEngine::boxed_gpu(g) else {
        eprintln!("PhysX GPU unavailable; skipping");
        return;
    };
    hand_over(engine, "PhysX GPU");
}
