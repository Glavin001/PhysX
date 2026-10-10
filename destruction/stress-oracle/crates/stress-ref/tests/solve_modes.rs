//! The real-time alternatives to the explicit ground truth, measured against it and
//! against closed forms: the implicit Newmark step (inertia and true stiffness at a
//! large step) and selective mass scaling (instead of lowering the modulus).

mod common;

use stress_ref::builders::*;
use stress_ref::metrics::MetricValue;
use stress_ref::scene::*;
use stress_ref::world::World;

/// Damped single-degree-of-freedom response to a suddenly applied (released) load:
/// peak over static `1 + exp(-zeta pi / sqrt(1 - zeta^2))`.
fn damped_amplification(zeta: f64) -> f64 {
    1.0 + (-zeta * std::f64::consts::PI / (1.0 - zeta * zeta).sqrt()).exp()
}

fn amplification(scene: &Scene) -> f64 {
    let obs = common::run(scene);
    match common::metric_value(scene, &obs, "dynamic_amplification") {
        MetricValue::Number(x) => x,
        other => panic!("{other:?}"),
    }
}

/// Sudden support loss with the implicit step: the dynamic amplification converges to
/// the damped closed form as the step resolves the period (T = 0.89 ms here); a step
/// longer than the period misses most of it. The explicit solve is the reference.
#[test]
fn implicit_amplification_converges_as_the_step_resolves_the_period() {
    let sudden = support_loss(0.0, "b4_sudden");
    let exact = damped_amplification(0.02);
    let explicit = amplification(&sudden);
    println!("closed form {exact:.4}, explicit {explicit:.4}");
    assert!(common::rel(explicit, exact) < 0.01);
    let mut errors = Vec::new();
    for step in [1e-3, 2e-4, 5e-5, 2e-5] {
        let mut s = sudden.clone();
        s.sim.solve_mode = SolveMode::Implicit;
        s.sim.implicit_dt = Some(step);
        let a = amplification(&s);
        println!("implicit dt {step:e}: {a:.4}");
        errors.push(common::rel(a, exact));
    }
    assert!(errors[0] > 0.3, "one step per period cannot show the amplification");
    assert!(errors.windows(2).all(|w| w[1] < w[0]), "monotone convergence: {errors:?}");
    assert!(errors[3] < 0.02, "{errors:?}");
}

/// Without damping the implicit (trapezoidal) step neither gains nor loses energy:
/// a released column keeps oscillating between the same extremes.
#[test]
fn implicit_step_conserves_the_energy_of_free_vibration() {
    let mut s = support_loss(0.0, "undamped");
    let rock = s.materials.get_mut("rock").unwrap();
    rock.damping_ratio = 0.0;
    s.sim.solve_mode = SolveMode::Implicit;
    s.sim.implicit_dt = Some(5e-5);
    s.sim.duration = 0.05;
    let obs = common::run(&s);
    let series = &obs.probes["reaction"];
    let late: Vec<f64> = series.t.iter().zip(&series.v).filter(|(t, _)| **t > 0.03).map(|(_, v)| *v).collect();
    let early: Vec<f64> = series.t.iter().zip(&series.v).filter(|(t, _)| **t > 0.01 && **t < 0.02).map(|(_, v)| *v).collect();
    let range = |v: &[f64]| v.iter().copied().fold(f64::NEG_INFINITY, f64::max) - v.iter().copied().fold(f64::INFINITY, f64::min);
    assert!(common::rel(range(&late), range(&early)) < 0.01, "{} vs {}", range(&late), range(&early));
}

/// In the static limit the implicit step is the quasi-static solve: a slowly loaded
/// cantilever reaches the Euler-Bernoulli deflection, and the frame removal matches
/// the explicit solve within the oracle tolerance.
#[test]
fn implicit_step_matches_the_explicit_solve_on_structural_benchmarks() {
    let mut beam = cantilever(20, "c");
    beam.sim.solve_mode = SolveMode::Implicit;
    let obs = common::run(&beam);
    let tip = common::metric_number(&beam, &obs, "tip_deflection");
    let expected = beam.metrics.iter().find(|m| m.name == "tip_deflection").unwrap().expected.clone().unwrap().as_f64().unwrap();
    assert!(common::rel(tip, expected) < 0.01, "{tip} vs {expected}");

    let frame = frame_column_removal_with(0.0, false, "frame_elastic");
    let mut implicit = frame.clone();
    implicit.sim.solve_mode = SolveMode::Implicit;
    let (oe, oi) = (common::run(&frame), common::run(&implicit));
    for m in ["axial_col0_peak", "axial_col2_peak", "beam_moment_peak"] {
        let (e, i) = (common::metric_number(&frame, &oe, m), common::metric_number(&implicit, &oi, m));
        println!("{m}: explicit {e:.4e}, implicit {i:.4e}");
        assert!(common::rel(i, e) < 0.10, "{m}: {i} vs {e}");
    }
}

/// Selective mass scaling raises the stable substep to the target by adding inertia
/// only where needed: statics are untouched, the added mass is reported, and the
/// substep count falls.
#[test]
fn mass_scaling_raises_the_substep_without_touching_statics() {
    let beam = cantilever(40, "c40");
    let w0 = World::new(&beam);
    let dt0 = w0.solver.stable_dt();
    let mut scaled = beam.clone();
    scaled.sim.mass_scaling_dt = Some(4.0 * dt0);
    let w1 = World::new(&scaled);
    let dt1 = w1.solver.stable_dt();
    println!("stable dt {dt0:.3e} -> {dt1:.3e}, added mass {:.1}%", 100.0 * w1.added_mass_fraction);
    // Exactly: the scaling meets its target substep (no allowance).
    assert!(dt1 >= 4.0 * dt0, "{dt1} vs {}", 4.0 * dt0);
    assert!(w1.added_mass_fraction > 0.0);
    let (o0, o1) = (common::run(&beam), common::run(&scaled));
    let tip = |o: &stress_ref::observation::Observation| o.probes["tip"].v[0];
    assert!(common::rel(tip(&o1), tip(&o0)) < 1e-9, "static deflection changed");
    assert_eq!(o1.values["added_mass_fraction"], w1.added_mass_fraction);
    assert!(o1.values["substeps"] < 0.5 * o0.values["substeps"]);
}
