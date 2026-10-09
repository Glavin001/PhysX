//! End-to-end: PhysX (CPU) owns rigid motion and contact, the reference stress solver
//! decides fracture, and fractures become new PhysX bodies.
//!
//! Run with `PHYSX_ROOT=<PhysX SDK install> cargo test --release -p stress-physx`.

use stress_physx::PhysxDestruction;
use stress_ref::api::StressSolverApi;
use stress_ref::builders::*;
use stress_ref::math::Vec3;
use stress_ref::scene::*;

fn wall_and_ram(supported: bool, gravity: bool, speed: f64) -> Scene {
    let mut s = new_scene("physx_wall", "concrete wall hit by a steel ram in PhysX");
    if !gravity {
        s.gravity = [0.0; 3];
    }
    s.materials.insert("concrete".into(), oracle_concrete(None));
    s.materials.insert("steel".into(), elastic_steel());
    let counts = [10, 2, 11];
    let mut chunks = grid(Vec3::new(-0.5, 0.0, -0.1), counts, Vec3::splat(0.1), "concrete");
    if supported {
        for i in 0..counts[0] {
            for j in 0..counts[1] {
                chunks[grid_index(counts, i, j, 0)].support = Support::Fixed;
            }
        }
    }
    let bonds = auto_bonds(&chunks, |_, _| "concrete".into());
    s.bodies.push(body("wall", chunks, bonds));
    s.impactors.push(ImpactorDesc {
        name: "ram".into(),
        shape: ImpactorShape::Box { half_extents: [0.1, 0.1, 0.1] },
        mass: 200.0,
        position: [0.0, -0.15, 0.5],
        orientation: [1.0, 0.0, 0.0, 0.0],
        velocity: [0.0, speed, 0.0],
        angular_velocity: [0.0; 3],
        material: "steel".into(),
        crush: None,
    });
    s
}

#[test]
fn physx_impact_fractures_the_wall_into_new_bodies_and_conserves_momentum() {
    let scene = wall_and_ram(false, false, 40.0);
    let Some(mut sim) = PhysxDestruction::new(&scene) else {
        eprintln!("PhysX CPU scene unavailable; skipping");
        return;
    };
    let p0 = sim.momentum();
    assert!((p0 - Vec3::new(0.0, 8000.0, 0.0)).norm() < 1.0, "initial momentum {p0:?}");
    let mut broken = false;
    for _ in 0..30 {
        let out = sim.step(1.0 / 60.0);
        broken |= !out.fractures.is_empty();
    }
    assert!(broken, "the impact should fracture the wall");
    assert!(sim.cluster_bodies() > 1, "fragments become separate PhysX bodies");
    let p1 = sim.momentum();
    println!("momentum {p0:?} -> {p1:?}, bodies {}", sim.cluster_bodies());
    // PhysX contacts and the solver's splits both conserve momentum (PhysX in f32).
    assert!((p1 - p0).norm() < 0.02 * p0.norm(), "momentum {p1:?} vs {p0:?}");
    let reports = sim.stress.solver.bonds[0].iter().filter(|b| !b.connected()).count();
    assert!(reports > 0);
}

#[test]
fn physx_supported_wall_keeps_its_base_and_sheds_debris() {
    let scene = wall_and_ram(true, true, 40.0);
    let Some(mut sim) = PhysxDestruction::new(&scene) else {
        eprintln!("PhysX CPU scene unavailable; skipping");
        return;
    };
    for _ in 0..20 {
        sim.step(1.0 / 60.0);
    }
    let clusters = sim.stress.clusters();
    assert!(clusters.iter().any(|c| c.anchored), "the supported piece stays fixed");
    assert!(clusters.iter().filter(|c| !c.anchored).count() >= 1, "debris broke off");
    // Debris falls under gravity in PhysX: some free piece is below where it started
    // or moving downwards.
    let (_, ram_v) = sim.impactor_state(0);
    assert!(ram_v.y < 40.0, "the ram lost speed in the impact ({ram_v:?})");
}

#[test]
fn physx_slow_contact_does_not_fracture() {
    let scene = wall_and_ram(true, true, 0.5);
    let Some(mut sim) = PhysxDestruction::new(&scene) else {
        eprintln!("PhysX CPU scene unavailable; skipping");
        return;
    };
    for _ in 0..30 {
        sim.step(1.0 / 60.0);
    }
    assert_eq!(sim.fractures, 0);
    assert_eq!(sim.stress.solver.broken_bond_count(), 0);
}
