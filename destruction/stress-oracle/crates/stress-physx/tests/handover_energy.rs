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
    s.sim.methods = if std::env::var("BLOWUP_METHODS").is_ok_and(|v| v == "proven") { stress_ref::scene::Methods::proven() } else { stress_ref::scene::Methods::established() };
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

/// One frame of the engine from the world's state: the change of kinetic plus
/// potential energy and of the centre's height.
fn one_engine_frame(scene: &Scene, engine: Box<dyn stress_ref::engine::RigidEngine>) -> (f64, f64, bool) {
    let mut w = World::with_engine(scene, engine);
    let (e0, z0) = (mechanical(&w), w.solver.chunk_position(0, 0).z);
    w.step_frame();
    let (e1, z1) = (mechanical(&w), w.solver.chunk_position(0, 0).z);
    (e1 - e0, z1 - z0, w.solver.clusters[0].driven)
}

fn hand_over(make: impl Fn() -> Box<dyn stress_ref::engine::RigidEngine>, label: &str) {
    // Dropped on a face 4 degrees off flat: the world rests it where its contact samples
    // hold it (with corners pulled in, rocked onto a pulled-in corner, its true corner
    // below the ground).
    let q = Quat::from_axis_angle(Vec3::new(1.0, 0.0, 0.0), 0.07);
    let (x, rot, _, stored) = rested_by_the_world(q);
    let (gain, rise, driven) = one_engine_frame(&tilted_cube(x, rot), make());
    // The engine's own handling of a body resting exactly on its geometry (flat, the
    // face touching the ground): what its solver does to a body at rest anyway.
    let (own, own_rise, _) = one_engine_frame(&tilted_cube(Vec3::new(x.x, x.y, 0.5), Quat::IDENTITY), make());
    // A rigid engine takes the chunk without the penalty contact's compression d: lifting
    // it out (m g d) is the only work the handover may add to the engine's own. At rest
    // the contact's force carries the weight, sum k_i d_i = m g, and stores
    // E = sum k_i d_i^2 / 2, so for the equal compressions of a face at rest m g d = 2 E.
    // The engine holds poses in f32: the height rounds (by at most eps/2 |z| each time)
    // into and out of the engine, in this handover and in the one at its own rest.
    let scene = tilted_cube(x, rot);
    let mg = stress_ref::solver::ReferenceSolver::new(&scene).structures[0].chunks[0].mass * Vec3::from_array(scene.gravity).norm();
    let rounding = mg * 4.0 * (f32::EPSILON as f64 / 2.0) * x.z.abs().max(0.5);
    let allowance = 2.0 * stored + own.max(0.0) + rounding;
    eprintln!(
        "{label}: driven by the engine {driven}; the centre rose {rise:.3e} m, kinetic + potential {gain:+.3e} J; at its own rest the engine adds {own:+.3e} J (rise {own_rise:.3e} m); the compression's lift {:.3e} J",
        2.0 * stored
    );
    assert!(gain <= allowance, "{label}: the handover added {gain:.3e} J (the centre rose {rise:.4} m), more than the engine adds at its own rest plus lifting the chunk out of its contact compression ({allowance:.3e} J)");
}

#[test]
fn handover_to_physx_cpu_adds_no_energy() {
    let g = Vec3::new(0.0, 0.0, -9.81);
    let Some(engine) = PhysxEngine::boxed(g) else {
        eprintln!("PhysX CPU unavailable; skipping");
        return;
    };
    drop(engine);
    hand_over(|| PhysxEngine::boxed(g).expect("PhysX CPU"), "PhysX CPU");
}

#[cfg(feature = "gpu")]
#[test]
fn handover_to_physx_gpu_adds_no_energy() {
    let g = Vec3::new(0.0, 0.0, -9.81);
    let Some(engine) = PhysxEngine::boxed_gpu(g) else {
        eprintln!("PhysX GPU unavailable; skipping");
        return;
    };
    drop(engine);
    hand_over(|| PhysxEngine::boxed_gpu(g).expect("PhysX GPU"), "PhysX GPU");
}

/// 1 m concrete cubes, one body each, at the given poses.
fn cubes(poses: &[(Vec3, Quat)]) -> Scene {
    use stress_ref::builders::*;
    let mut s = new_scene("handover_pair", "chunks resting on the ground and on each other, handed to the engine");
    s.materials.insert("concrete".into(), oracle_concrete(None));
    s.ground = Some(GroundDesc { height: 0.0, friction: 0.6, material: "concrete".into() });
    for (i, (x, q)) in poses.iter().enumerate() {
        let mut b = body(&format!("cube{i}"), vec![chunk(Vec3::ZERO, Vec3::splat(0.5), "concrete")], Vec::new());
        b.position = x.to_array();
        b.orientation = q.to_wxyz();
        s.bodies.push(b);
    }
    s.sim.methods = if std::env::var("BLOWUP_METHODS").is_ok_and(|v| v == "proven") { stress_ref::scene::Methods::proven() } else { stress_ref::scene::Methods::established() };
    s.sim.solve_mode = SolveMode::Adaptive;
    s
}

/// Kinetic plus potential energy of every chunk.
fn mechanical_all(w: &World) -> f64 {
    let m = &w.solver;
    let g = m.config.gravity.norm();
    let mut e = 0.0;
    for s in 0..m.structures.len() {
        let ch = &m.structures[s].chunks[0];
        let (v, om) = m.chunk_velocity(s, 0);
        let cl = &m.clusters[m.chunks[s][0].cluster];
        let r = cl.rotation() * ch.rotation;
        let iw = r * ch.inertia * r.transpose();
        e += 0.5 * ch.mass * v.norm2() + 0.5 * om.dot(iw * om) + ch.mass * g * m.chunk_position(s, 0).z;
    }
    e
}

/// Two cubes on the ground, the second 2 cm into the first (as chunks of a split can be:
/// the world keeps such an overlap at its birth as an offset, contact.rs), rested by the
/// world for 2 s, then handed to the engine for a frame: the overlap is at rest, so the
/// engine may add no energy beyond lifting both out of their ground compression and its
/// own handling of two cubes resting just touching.
fn hand_over_pair(make: impl Fn() -> Box<dyn stress_ref::engine::RigidEngine>, label: &str) {
    let overlap = 0.02;
    let start = [(Vec3::new(0.0, 0.0, 0.5), Quat::IDENTITY), (Vec3::new(1.0 - overlap, 0.0, 0.5), Quat::IDENTITY)];
    let mut w = World::new(&cubes(&start));
    for _ in 0..120 {
        w.step_frame();
    }
    let rested: Vec<(Vec3, Quat)> = (0..2).map(|s| (w.solver.chunk_position(s, 0), w.solver.clusters[w.solver.chunks[s][0].cluster].pose.rotation)).collect();
    let stored = w.contact.stored;
    let gap = rested[1].0.x - rested[0].0.x - 1.0;
    eprintln!("{label}: the world rests the pair {gap:.4e} m apart (overlapping {:.4} m), its contacts storing {stored:.3e} J", -gap);
    let frame = |poses: &[(Vec3, Quat)]| {
        let mut w = World::with_engine(&cubes(poses), make());
        let e0 = mechanical_all(&w);
        let x0 = w.solver.chunk_position(1, 0).x - w.solver.chunk_position(0, 0).x;
        w.step_frame();
        (mechanical_all(&w) - e0, w.solver.chunk_position(1, 0).x - w.solver.chunk_position(0, 0).x - x0)
    };
    let (gain, spread) = frame(&rested);
    let touching = [(Vec3::new(0.0, 0.0, 0.5), Quat::IDENTITY), (Vec3::new(1.0, 0.0, 0.5), Quat::IDENTITY)];
    let (own, own_spread) = frame(&touching);
    let scene = cubes(&rested);
    let mg = stress_ref::solver::ReferenceSolver::new(&scene).structures[0].chunks[0].mass * Vec3::from_array(scene.gravity).norm();
    let rounding = 2.0 * mg * 4.0 * (f32::EPSILON as f64 / 2.0) * 1.0;
    let allowance = 2.0 * stored + own.max(0.0) + rounding;
    eprintln!("{label}: the engine moved them {spread:+.4e} m apart, kinetic + potential {gain:+.3e} J; just touching: {own_spread:+.3e} m, {own:+.3e} J; allowance {allowance:.3e} J");
    assert!(gain <= allowance, "{label}: handing over the resting overlap added {gain:.3e} J (pushed {spread:.4} m apart), more than {allowance:.3e} J");
}

#[test]
fn pair_handover_to_physx_cpu_adds_no_energy() {
    let g = Vec3::new(0.0, 0.0, -9.81);
    if PhysxEngine::boxed(g).is_none() {
        eprintln!("PhysX CPU unavailable; skipping");
        return;
    }
    hand_over_pair(|| PhysxEngine::boxed(g).expect("PhysX CPU"), "PhysX CPU");
}

#[cfg(feature = "gpu")]
#[test]
fn pair_handover_to_physx_gpu_adds_no_energy() {
    let g = Vec3::new(0.0, 0.0, -9.81);
    if PhysxEngine::boxed_gpu(g).is_none() {
        eprintln!("PhysX GPU unavailable; skipping");
        return;
    }
    hand_over_pair(|| PhysxEngine::boxed_gpu(g).expect("PhysX GPU"), "PhysX GPU");
}
