//! Testable properties: momentum conserved through fracture, fragments inherit
//! `v + w x r`, no energy gain with dissipation accounted for.

mod common;

use stress_ref::builders::*;
use stress_ref::material::Material;
use stress_ref::math::Vec3;
use stress_ref::scene::*;
use stress_ref::solver::ReferenceSolver;
use stress_ref::world::World;

/// A free (unsupported) concrete wall in zero gravity, hit by a fast steel sphere.
fn free_wall_impact(speed: f64, fracture: bool) -> Scene {
    let mut s = new_scene("free_wall", "free wall hit by a sphere in zero gravity");
    s.gravity = [0.0; 3];
    s.materials.insert("concrete".into(), oracle_concrete(None));
    s.materials.insert("steel".into(), elastic_steel());
    let chunks = grid(Vec3::new(-0.5, 0.0, -0.5), [10, 2, 10], Vec3::splat(0.1), "concrete");
    let bonds = auto_bonds(&chunks, |_, _| "concrete".into());
    let mut b = body("wall", chunks, bonds);
    b.angular_velocity = [0.0, 0.0, 0.5];
    s.bodies.push(b);
    s.impactors.push(ImpactorDesc {
        name: "ball".into(),
        shape: ImpactorShape::Sphere { radius: 0.1 },
        mass: 50.0,
        position: [0.05, -0.101, 0.05],
        orientation: [1.0, 0.0, 0.0, 0.0],
        velocity: [0.0, speed, 0.0],
        angular_velocity: [0.0; 3],
        material: "steel".into(),
        crush: None,
    });
    s.sim.duration = 0.03;
    s.sim.frame_dt = 1e-3;
    s.sim.fracture = fracture;
    s.sim.gravity_prestress = false;
    s
}

/// Total linear and angular momentum (about the origin) of chunks and impactors.
fn momentum(w: &World) -> (Vec3, Vec3) {
    let mut p = Vec3::ZERO;
    let mut l = Vec3::ZERO;
    let sv = &w.solver;
    for (s, st) in sv.structures.iter().enumerate() {
        for (c, ch) in st.chunks.iter().enumerate() {
            if !sv.chunks[s][c].active {
                continue;
            }
            let (v, om) = sv.chunk_velocity(s, c);
            let x = sv.chunk_position(s, c);
            let r = sv.clusters[sv.chunks[s][c].cluster].rotation();
            p += v * ch.mass;
            l += x.cross(v) * ch.mass + (r * ch.inertia * r.transpose()) * om;
        }
    }
    for imp in &w.impactors {
        let r = imp.pose.rotation.to_mat3();
        p += imp.velocity * imp.mass;
        l += imp.pose.position.cross(imp.velocity) * imp.mass + (r * imp.inertia * r.transpose()) * imp.angular_velocity;
    }
    (p, l)
}

/// Linear momentum is conserved to round-off (all forces act in equal and opposite
/// pairs and splits preserve every chunk's velocity). Angular momentum is conserved to
/// the accuracy of the small-strain bond model, whose moments balance about the
/// undeformed chunk centres: the error scales with hidden displacement times bond
/// force, not with the timestep (0.1-0.2% in this 40 m/s impact).
#[test]
fn momentum_is_conserved_through_impact_and_fracture() {
    let scene = free_wall_impact(40.0, true);
    let mut w = World::new(&scene);
    let (p0, l0) = momentum(&w);
    for _ in 0..30 {
        w.step_frame();
        let (p, l) = momentum(&w);
        assert!((p - p0).norm() <= 1e-9 * p0.norm(), "linear momentum drift {:?} vs {:?}", p, p0);
        assert!((l - l0).norm() <= 5e-3 * l0.norm(), "angular momentum drift {:?} vs {:?}", l, l0);
    }
    assert!(w.solver.broken_bond_count() > 0, "the impact should fracture the wall");
    assert!(w.solver.clusters.len() > 1, "the wall should split");
}

#[test]
fn fragments_inherit_parent_rigid_velocity_field() {
    // A spinning, translating free beam whose middle bond is cut: with no hidden
    // deformation, each half must move with v + w x r of the parent.
    let mut s = new_scene("spin", "spinning beam split");
    s.gravity = [0.0; 3];
    s.materials.insert("m".into(), Material::analytic_test());
    let chunks = grid(Vec3::new(-0.4, -0.05, -0.05), [8, 1, 1], Vec3::splat(0.1), "m");
    let bonds = auto_bonds(&chunks, |_, _| "m".into());
    let mut b = body("beam", chunks, bonds);
    b.linear_velocity = [1.0, 2.0, -0.5];
    b.angular_velocity = [0.3, -0.2, 5.0];
    s.bodies.push(b);
    let mut solver = ReferenceSolver::new(&s);
    // Some hidden deformation velocity too, so the split must redistribute it.
    for (i, c) in solver.chunks[0].iter_mut().enumerate() {
        c.v = Vec3::new(0.01 * i as f64, -0.02, 0.005 * (i % 3) as f64);
        c.w = Vec3::new(0.0, 0.1 * i as f64, 0.0);
    }
    let momentum = |sv: &ReferenceSolver| {
        let mut p = Vec3::ZERO;
        let mut l = Vec3::ZERO;
        for (c, ch) in sv.structures[0].chunks.iter().enumerate() {
            let (v, w) = sv.chunk_velocity(0, c);
            let r = sv.clusters[sv.chunks[0][c].cluster].rotation();
            p += v * ch.mass;
            l += sv.chunk_position(0, c).cross(v) * ch.mass + r * ch.inertia * r.transpose() * w;
        }
        (p, l)
    };
    let (p0, l0) = momentum(&solver);
    let mid = solver.bonds[0].iter().position(|b| b.geometry.a == 3 && b.geometry.b == 4).unwrap();
    solver.bonds[0][mid].joint.damage = 1.0;
    solver.split_cluster(0);
    assert_eq!(solver.clusters.len(), 2);
    let (p1, l1) = momentum(&solver);
    assert!((p1 - p0).norm() < 1e-12 * p0.norm() && (l1 - l0).norm() < 1e-12 * l0.norm(), "split changed momentum");

    // Without hidden velocities, each half moves with the parent's rigid field.
    let mut solver = ReferenceSolver::new(&s);
    let parent = solver.clusters[0].clone();
    solver.bonds[0][mid].joint.damage = 1.0;
    solver.split_cluster(0);
    let com_p = parent.com_world();
    for child in &solver.clusters {
        let expected = parent.velocity + parent.angular_velocity.cross(child.com_world() - com_p);
        assert!((child.velocity - expected).norm() < 1e-12, "{:?} vs {:?}", child.velocity, expected);
        assert!((child.angular_velocity - parent.angular_velocity).norm() < 1e-12);
    }
}

#[test]
fn elastic_impact_conserves_energy_up_to_contact_dissipation() {
    let scene = free_wall_impact(5.0, false);
    let mut w = World::new(&scene);
    let e0 = w.mechanical_energy();
    for _ in 0..30 {
        w.step_frame();
        let e = w.mechanical_energy() + w.dissipated_energy();
        assert!((e - e0).abs() <= 0.01 * e0, "energy {e} vs {e0}");
    }
}

/// Mechanical energy plus everything dissipated (fracture energy, friction, dashpots,
/// contact damping, softening overshoot, energy left in bonds a split separates) stays
/// at the initial energy and never exceeds it. The residual (2% at this resolution) is
/// the explicit integration error of 40 m/s penalty contact and shrinks with the substep.
#[test]
fn fracture_never_gains_energy_and_dissipation_is_accounted() {
    let scene = free_wall_impact(40.0, true);
    let mut w = World::new(&scene);
    let e0 = w.mechanical_energy();
    let mut contact = 0.0;
    for _ in 0..30 {
        w.step_frame();
        let e = w.mechanical_energy() + w.dissipated_energy();
        assert!((e - e0).abs() <= 0.05 * e0, "transient imbalance: {e} vs {e0}");
        // The second law for the contacts: what they have taken out of the motion
        // (net of what they store) never falls, else the contact law creates energy.
        assert!(w.contact.dissipated >= contact - 1e-9 * e0, "contacts gave back energy: {} after {contact}", w.contact.dissipated);
        contact = w.contact.dissipated;
    }
    let e = w.mechanical_energy() + w.dissipated_energy();
    assert!(e <= e0 * 1.001, "energy gain: {e} vs {e0}");
    assert!((e - e0).abs() <= 0.025 * e0, "final imbalance: {e} vs {e0}");
    assert!(w.solver.energy.bond_dissipation > 0.0);
}
