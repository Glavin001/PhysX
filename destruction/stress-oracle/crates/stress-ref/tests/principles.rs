//! Principles any faithful simulation satisfies, whatever its internals. Each test
//! fails for a workaround (a cap, a regularisation, a hand-picked constant) even when
//! every benchmark gate passes, because it checks an invariance or a textbook law
//! rather than a calibrated number:
//!
//! * **Dimensional similarity**: rescaling every unit (lengths x2, times x4, masses
//!   x16, every derived quantity accordingly) rescales every result and changes no
//!   dimensionless one. A constant with physical units hidden in the code (a velocity,
//!   a force, a length), or a formula adding quantities of different units, breaks it.
//!   Powers of two, squares for times and masses, keep the arithmetic and its square
//!   roots exact: the run must be reproduced bit for bit.
//! * **Frame invariance**: a uniform velocity added to everything (Galilean) or a rigid
//!   rotation of the whole scene changes nothing relative.
//! * **Step independence**: results converge as the substep and the frame step shrink;
//!   a bound proportional to `1/dt` does not.
//! * **Resting contact**: a box set down flat stays flat, without rocking, and sinks
//!   only by the elastic compression of the two bodies.
//! * **Coulomb friction**: a block on an incline sticks below the friction angle (no
//!   creep) and slides above it with `g (sin t - mu cos t)`; a sliding block stops after
//!   `v^2 / (2 mu g)`; both independent of the block's mass and of the substep.

mod common;

use stress_ref::builders::*;
use stress_ref::math::{Quat, Vec3};
use stress_ref::scene::*;
use stress_ref::snapshot::{BondStatus, Snapshot};
use stress_ref::world::World;

// ------------------------------------------------------------------ scenes

const G: f64 = 9.81;

/// A free cube resting on the ground under gravity tilted by `slope` (radians) about
/// y: the ground acts as an incline. `mu` is the contact friction, `density` sets the
/// block's mass, `safety` the Courant fraction.
fn incline(slope: f64, mu: f64, density: f64, safety: f64, duration: f64) -> Scene {
    let mut s = new_scene("incline", "free block on an incline (tilted gravity)");
    s.gravity = [G * slope.sin(), 0.0, -G * slope.cos()];
    let mut m = oracle_concrete(None);
    m.density = density;
    m.friction = mu;
    s.materials.insert("block".into(), m.clone());
    s.materials.insert("ground".into(), m);
    let h = 0.1;
    s.bodies.push(body("block", vec![chunk(Vec3::new(0.0, 0.0, h), Vec3::splat(h), "block")], vec![]));
    s.ground = Some(GroundDesc { height: 0.0, friction: mu, material: "ground".into() });
    s.sim.duration = duration;
    s.sim.frame_dt = 1e-3;
    s.sim.courant_safety = safety;
    s.sim.gravity_prestress = false;
    s
}

/// A block sliding on flat ground at `speed` along x.
fn sliding(speed: f64, mu: f64, density: f64, safety: f64, duration: f64) -> Scene {
    let mut s = incline(0.0, mu, density, safety, duration);
    s.name = "sliding".into();
    s.bodies[0].linear_velocity = [speed, 0.0, 0.0];
    s
}

/// A small anchored concrete wall on the ground, struck by a steel box: impact,
/// fracture, crack contact, friction and gravity in one short run.
fn small_impact() -> Scene {
    let mut s = new_scene("small_impact", "anchored wall struck by a steel box");
    s.materials.insert("concrete".into(), oracle_concrete(None));
    s.materials.insert("steel".into(), elastic_steel());
    let mut chunks = grid(Vec3::new(-0.3, 0.0, 0.0), [6, 2, 6], Vec3::splat(0.1), "concrete");
    for c in chunks.iter_mut().take(12) {
        c.support = Support::Fixed;
    }
    let bonds = auto_bonds(&chunks, |_, _| "concrete".into());
    s.bodies.push(body("wall", chunks, bonds));
    s.impactors.push(ImpactorDesc {
        name: "ram".into(),
        shape: ImpactorShape::Box { half_extents: [0.08, 0.08, 0.08] },
        mass: 40.0,
        position: [0.05, -0.081, 0.35],
        orientation: [1.0, 0.0, 0.0, 0.0],
        velocity: [0.0, 12.0, 0.0],
        angular_velocity: [0.0; 3],
        material: "steel".into(),
        crush: None,
    });
    s.ground = Some(GroundDesc { height: 0.0, friction: 0.6, material: "concrete".into() });
    s.sim.duration = 0.02;
    s.sim.frame_dt = 1e-3;
    s
}

/// A free wall in zero gravity struck by a sphere (no ground): the scene for the
/// frame-invariance checks, where nothing may single out an origin, a velocity or an
/// axis.
fn free_impact(fracture: bool) -> Scene {
    let mut s = new_scene("free_impact", "free wall struck by a sphere in zero gravity");
    s.gravity = [0.0; 3];
    s.materials.insert("concrete".into(), oracle_concrete(None));
    s.materials.insert("steel".into(), elastic_steel());
    let chunks = grid(Vec3::new(-0.3, 0.0, -0.3), [6, 2, 6], Vec3::splat(0.1), "concrete");
    let bonds = auto_bonds(&chunks, |_, _| "concrete".into());
    s.bodies.push(body("wall", chunks, bonds));
    s.impactors.push(ImpactorDesc {
        name: "ball".into(),
        shape: ImpactorShape::Sphere { radius: 0.08 },
        mass: 20.0,
        position: [0.05, -0.081, 0.05],
        orientation: [1.0, 0.0, 0.0, 0.0],
        velocity: [0.0, 15.0, 0.0],
        angular_velocity: [0.0; 3],
        material: "steel".into(),
        crush: None,
    });
    s.sim.duration = 0.015;
    s.sim.frame_dt = 1e-3;
    s.sim.fracture = fracture;
    s.sim.gravity_prestress = false;
    s
}

// ------------------------------------------------------------------ helpers

/// Runs `scene` and returns a snapshot after every frame (the first is t = 0).
fn frames(scene: &Scene) -> Vec<Snapshot> {
    let mut w = World::new(scene);
    let mut out = vec![w.snapshot()];
    while w.solver.time < scene.sim.duration - 0.5 * scene.sim.frame_dt {
        w.step_frame();
        out.push(w.snapshot());
    }
    out
}

fn v(a: [f64; 3]) -> Vec3 {
    Vec3::from_array(a)
}

/// The block's centre over time (single-chunk scenes).
fn block_path(scene: &Scene) -> Vec<(f64, Vec3, Vec3)> {
    frames(scene).iter().map(|f| (f.time, v(f.chunks[0].center), v(f.chunks[0].velocity))).collect()
}

/// Broken bonds, as (body, a, b), sorted.
fn broken(s: &Snapshot) -> Vec<(usize, usize, usize)> {
    let mut out: Vec<_> = s.bonds.iter().filter(|b| b.status == BondStatus::Broken).map(|b| (b.body, b.a, b.b)).collect();
    out.sort();
    out
}

/// Units of a rescaling: lengths, times and masses multiplied by `l`, `t`, `m`.
#[derive(Clone, Copy)]
struct Units {
    l: f64,
    t: f64,
    m: f64,
}

impl Units {
    fn vel(self) -> f64 {
        self.l / self.t
    }
    fn acc(self) -> f64 {
        self.l / (self.t * self.t)
    }
    fn force(self) -> f64 {
        self.m * self.acc()
    }
    fn stress(self) -> f64 {
        self.force() / (self.l * self.l)
    }
    fn energy(self) -> f64 {
        self.force() * self.l
    }
}

fn scale3(a: [f64; 3], k: f64) -> [f64; 3] {
    [a[0] * k, a[1] * k, a[2] * k]
}

fn scale_time_fn(f: &TimeFunction, u: Units, value: f64) -> TimeFunction {
    match f {
        TimeFunction::Constant { value: x } => TimeFunction::Constant { value: x * value },
        TimeFunction::Ramp { t0, t1, value: x } => TimeFunction::Ramp { t0: t0 * u.t, t1: t1 * u.t, value: x * value },
        TimeFunction::HalfSine { start, duration, peak } => TimeFunction::HalfSine { start: start * u.t, duration: duration * u.t, peak: peak * value },
        TimeFunction::Friedlander { arrival, peak, duration, decay } => {
            TimeFunction::Friedlander { arrival: arrival * u.t, peak: peak * value, duration: duration * u.t, decay: *decay }
        }
        TimeFunction::Table { points } => TimeFunction::Table { points: points.iter().map(|p| [p[0] * u.t, p[1] * value]).collect() },
    }
}

fn scale_region(r: &Region, u: Units) -> Region {
    Region { min: scale3(r.min, u.l), max: scale3(r.max, u.l) }
}

fn scale_selector(c: &ChunkSelector, u: Units) -> ChunkSelector {
    match c {
        ChunkSelector::Region(r) => ChunkSelector::Region(scale_region(r, u)),
        other => other.clone(),
    }
}

/// The same physical scene in other units: every dimensional quantity is multiplied by
/// its unit's factor, every dimensionless one kept.
fn rescale(s: &Scene, u: Units) -> Scene {
    let mut s = s.clone();
    s.gravity = scale3(s.gravity, u.acc());
    for m in s.materials.values_mut() {
        m.density *= u.m / u.l.powi(3);
        m.youngs_modulus *= u.stress();
        m.tensile_strength *= u.stress();
        m.compressive_strength *= u.stress();
        m.cohesion *= u.stress();
        m.shear_cap = m.shear_cap.map(|x| x * u.stress());
        // Energy per unit area.
        let ga = u.energy() / (u.l * u.l);
        m.fracture_energy.tension *= ga;
        m.fracture_energy.shear *= ga;
        m.fracture_energy.compression *= ga;
        if let Some(d) = &mut m.dif {
            d.reference_rate /= u.t;
            d.transition_rate /= u.t;
        }
        if let Some(f) = &mut m.static_fatigue {
            f.test_time *= u.t;
        }
    }
    for b in &mut s.bodies {
        b.position = scale3(b.position, u.l);
        b.linear_velocity = scale3(b.linear_velocity, u.vel());
        b.angular_velocity = scale3(b.angular_velocity, 1.0 / u.t);
        for c in &mut b.chunks {
            c.center = scale3(c.center, u.l);
            c.half_extents = scale3(c.half_extents, u.l);
            if let Some(h) = &mut c.hull {
                h.iter_mut().for_each(|p| *p = scale3(*p, u.l));
            }
        }
        for bd in &mut b.bonds {
            bd.centroid = scale3(bd.centroid, u.l);
            bd.area *= u.l * u.l;
            bd.width = [bd.width[0] * u.l, bd.width[1] * u.l];
            bd.buckling_length = bd.buckling_length.map(|x| x * u.l);
            if let Some(r) = &mut bd.rebar {
                r.area *= u.l * u.l;
            }
            bd.derived = None;
        }
    }
    for i in &mut s.impactors {
        i.shape = match &i.shape {
            ImpactorShape::Sphere { radius } => ImpactorShape::Sphere { radius: radius * u.l },
            ImpactorShape::Box { half_extents } => ImpactorShape::Box { half_extents: scale3(*half_extents, u.l) },
        };
        i.mass *= u.m;
        i.position = scale3(i.position, u.l);
        i.velocity = scale3(i.velocity, u.vel());
        i.angular_velocity = scale3(i.angular_velocity, 1.0 / u.t);
        if let Some(c) = &mut i.crush {
            c.max_force *= u.force();
            c.energy *= u.energy();
        }
    }
    if let Some(g) = &mut s.ground {
        g.height *= u.l;
    }
    for load in &mut s.loads {
        *load = match load {
            LoadDesc::PointForce { body, chunk, direction, magnitude, point } => LoadDesc::PointForce {
                body: body.clone(),
                chunk: *chunk,
                direction: *direction,
                magnitude: scale_time_fn(magnitude, u, u.force()),
                point: point.map(|p| scale3(p, u.l)),
            },
            LoadDesc::Pressure { body, chunks, face_normal, pressure } => LoadDesc::Pressure {
                body: body.clone(),
                chunks: scale_selector(chunks, u),
                face_normal: *face_normal,
                pressure: scale_time_fn(pressure, u, u.stress()),
            },
            LoadDesc::Blast { .. } => panic!("blast loads follow an empirical, unit-bearing law (Kingery-Bulmash): not rescalable"),
        };
    }
    for e in &mut s.events {
        *e = match e {
            EventDesc::RemoveChunks { time, duration, body, chunks } => {
                EventDesc::RemoveChunks { time: *time * u.t, duration: *duration * u.t, body: body.clone(), chunks: scale_selector(chunks, u) }
            }
            EventDesc::RemoveSupports { time, duration, body, chunks } => {
                EventDesc::RemoveSupports { time: *time * u.t, duration: *duration * u.t, body: body.clone(), chunks: scale_selector(chunks, u) }
            }
        };
    }
    let sim = &mut s.sim;
    sim.duration *= u.t;
    sim.frame_dt *= u.t;
    sim.sample_interval = sim.sample_interval.map(|x| x * u.t);
    sim.max_substep = sim.max_substep.map(|x| x * u.t);
    sim.mass_scaling_dt = sim.mass_scaling_dt.map(|x| x * u.t);
    sim.implicit_dt = sim.implicit_dt.map(|x| x * u.t);
    // Probes and metrics are not compared here.
    s.probes.clear();
    s.metrics.clear();
    s
}

/// Largest deviation, as a fraction of `reference`, of `b` from `a` after mapping `b`
/// back to `a`'s frame (`map`), over every chunk and impactor of every frame; and
/// whether the broken-bond sets agree at every frame.
fn compare_runs(a: &[Snapshot], b: &[Snapshot], map_pos: impl Fn(f64, Vec3) -> Vec3, map_vel: impl Fn(Vec3) -> Vec3, reference: (f64, f64)) -> (f64, f64, Option<f64>) {
    assert_eq!(a.len(), b.len(), "same number of frames");
    let (mut dx, mut dv) = (0.0f64, 0.0f64);
    let mut first_split = None;
    for (fa, fb) in a.iter().zip(b) {
        let key = |s: &Snapshot| {
            let mut m: Vec<_> = s.chunks.iter().map(|c| ((c.body, c.chunk), (v(c.center), v(c.velocity)))).collect();
            m.sort_by_key(|e| e.0);
            m
        };
        let (ka, kb) = (key(fa), key(fb));
        assert_eq!(ka.len(), kb.len(), "same active chunks at t = {}", fa.time);
        for ((ia, (xa, va)), (ib, (xb, vb))) in ka.iter().zip(&kb) {
            assert_eq!(ia, ib);
            dx = dx.max((map_pos(fa.time, *xb) - *xa).norm() / reference.0);
            dv = dv.max((map_vel(*vb) - *va).norm() / reference.1);
        }
        for (ia, ib) in fa.impactors.iter().zip(&fb.impactors) {
            dx = dx.max((map_pos(fa.time, v(ib.center)) - v(ia.center)).norm() / reference.0);
            dv = dv.max((map_vel(v(ib.velocity)) - v(ia.velocity)).norm() / reference.1);
        }
        if first_split.is_none() && broken(fa) != broken(fb) {
            first_split = Some(fa.time);
        }
    }
    (dx, dv, first_split)
}

// ------------------------------------------------------------------ dimensional similarity

/// Rescaling every unit reproduces the run: positions scale by L, velocities by L/T,
/// the same bonds break at the same scaled times. The factors are powers of two (and
/// squares where square roots are taken), so a solver built only from the scene's own
/// quantities with dimensionally consistent formulas reproduces it bit for bit; any
/// constant with physical units in the code shows up as a difference.
#[test]
fn rescaling_every_unit_reproduces_the_run() {
    let u = Units { l: 2.0, t: 4.0, m: 16.0 };
    let cases: Vec<(&str, Scene)> = vec![
        ("impact with fracture, contact and friction", small_impact()),
        ("block sticking on an incline", incline(20f64.to_radians(), 0.5, 2400.0, 0.5, 0.1)),
        ("block sliding to rest", sliding(1.0, 0.5, 2400.0, 0.5, 0.1)),
        ("masonry wall struck by a ball", {
            let mut s = masonry_wall(15.0, "b7");
            s.sim.duration = 0.02;
            s
        }),
        ("frame losing a column", {
            let mut s = frame_column_removal(0.0, "b8");
            s.sim.duration = 0.1;
            s
        }),
    ];
    let mut failures = Vec::new();
    for (label, scene) in &cases {
        let a = frames(scene);
        let b = frames(&rescale(scene, u));
        let size = a[0].chunks.iter().map(|c| v(c.half_extents).norm()).fold(0.0, f64::max).max(1e-3);
        let speed = a.iter().flat_map(|f| f.chunks.iter().map(|c| v(c.velocity).norm())).fold(0.0, f64::max).max(1e-3);
        let (dx, dv, split) = compare_runs(&a, &b, |_, x| x / u.l, |w| w / u.vel(), (size, speed));
        println!("{label}: position {dx:.2e} of a chunk size, velocity {dv:.2e} of the peak speed, broken bonds differ from {split:?}");
        if dx > 0.0 || dv > 0.0 || split.is_some() {
            failures.push(format!("{label}: position {dx:.2e}, velocity {dv:.2e}, broken bonds differ from t = {split:?}"));
        }
    }
    assert!(failures.is_empty(), "results depend on the choice of units (a dimensional constant in the code):\n{}", failures.join("\n"));
}

// ------------------------------------------------------------------ frame invariance

/// The divergence a frame change may cause in a fracturing run: ten times the largest
/// divergence among runs of the original scene whose impact velocity is perturbed by a
/// few units in the last place (in four directions), plus round-off. Fracture is
/// discontinuous in time (a bond reaching its strength near a substep boundary breaks
/// a substep earlier or later), and the overlap of chunks that just split is a
/// difference of nearly equal coordinates, so round-off can grow; a change of frame
/// must be indistinguishable from it.
fn round_off_envelope(scene: &Scene, reference: &[Snapshot]) -> (f64, f64) {
    let (mut ex, mut ev) = (0.0f64, 0.0f64);
    let mut add = |dx: f64, dv: f64| {
        ex = ex.max(dx);
        ev = ev.max(dv);
    };
    // The impact velocity perturbed by a few units in the last place...
    for dir in [Vec3::X, Vec3::Y, Vec3::Z, Vec3::new(1.0, -1.0, 1.0).normalized()] {
        let mut p = scene.clone();
        let vel = v(p.impactors[0].velocity);
        p.impactors[0].velocity = (vel + dir * (4.0 * f64::EPSILON * vel.norm())).to_array();
        let (dx, dv, _) = compare_runs(reference, &frames(&p), |_, x| x, |w| w, (0.05, 15.0));
        add(dx, dv);
    }
    // ...and the whole scene turned by a few units in the last place of an angle, which
    // rounds every coordinate as a finite rotation does.
    for k in [1.0, 4.0, 16.0] {
        let q = Quat::from_axis_angle(Vec3::new(1.0, 2.0, 3.0).normalized(), k * f64::EPSILON);
        let back = q.conjugate();
        let (dx, dv, _) = compare_runs(reference, &frames(&rotated(scene, q)), |_, x| back.rotate(x), |w| back.rotate(w), (0.05, 15.0));
        add(dx, dv);
    }
    (10.0 * ex + 1e-9, 10.0 * ev + 1e-9)
}

/// `scene` turned rigidly by `q` about the origin.
fn rotated(scene: &Scene, q: Quat) -> Scene {
    let mut turned = scene.clone();
    let rot = |a: [f64; 3]| q.rotate(v(a)).to_array();
    for b in &mut turned.bodies {
        b.position = rot(b.position);
        b.orientation = (q * Quat::from_wxyz(b.orientation)).to_wxyz();
        b.linear_velocity = rot(b.linear_velocity);
        b.angular_velocity = rot(b.angular_velocity);
    }
    for i in &mut turned.impactors {
        i.position = rot(i.position);
        i.orientation = (q * Quat::from_wxyz(i.orientation)).to_wxyz();
        i.velocity = rot(i.velocity);
        i.angular_velocity = rot(i.angular_velocity);
    }
    turned
}

/// Checks a frame change: without fracture the motion agrees to round-off; with it the
/// same bonds break by every frame and the motion differs no more than round-off
/// perturbations of the original make it differ.
fn assert_frame_change(label: &str, fracture: bool, original: &Scene, a: &[Snapshot], b: &[Snapshot], dx: f64, dv: f64, split: Option<f64>) {
    assert!(split.is_none(), "{label}: the change of frame changed which bonds break (from t = {split:?})");
    let (lx, lv) = if fracture { round_off_envelope(original, a) } else { (1e-9, 1e-9) };
    println!("{label}: position {dx:.2e} (allowed {lx:.2e}), velocity {dv:.2e} (allowed {lv:.2e}), frames {}", b.len());
    assert!(dx <= lx && dv <= lv, "{label}: the change of frame changed the motion beyond round-off: position {dx:.2e} > {lx:.2e} or velocity {dv:.2e} > {lv:.2e}");
}

/// A uniform velocity added to every body changes nothing relative (no ground, no
/// gravity: nothing singles out a frame).
#[test]
fn a_uniform_velocity_changes_nothing_relative() {
    for fracture in [false, true] {
        let scene = free_impact(fracture);
        let drift = Vec3::new(3.0, -2.0, 1.5);
        let mut moved = scene.clone();
        for b in &mut moved.bodies {
            b.linear_velocity = (v(b.linear_velocity) + drift).to_array();
        }
        for i in &mut moved.impactors {
            i.velocity = (v(i.velocity) + drift).to_array();
        }
        let (a, b) = (frames(&scene), frames(&moved));
        let (dx, dv, split) = compare_runs(&a, &b, |t, x| x - drift * t, |w| w - drift, (0.05, 15.0));
        assert_frame_change(&format!("uniform velocity, fracture {fracture}"), fracture, &scene, &a, &b, dx, dv, split);
    }
}

/// Rotating the whole scene rotates the result (nothing singles out an axis).
#[test]
fn a_rigid_rotation_of_the_scene_rotates_the_result() {
    let q = Quat::from_axis_angle(Vec3::new(1.0, 2.0, 3.0).normalized(), 0.7);
    for fracture in [false, true] {
        let scene = free_impact(fracture);
        let (a, b) = (frames(&scene), frames(&rotated(&scene, q)));
        let back = q.conjugate();
        let (dx, dv, split) = compare_runs(&a, &b, |_, x| back.rotate(x), |w| back.rotate(w), (0.05, 15.0));
        assert_frame_change(&format!("rotation, fracture {fracture}"), fracture, &scene, &a, &b, dx, dv, split);
    }
}

// ------------------------------------------------------------------ resting contact

/// A box set down flat on a flat support stays flat under a small sideways load (gravity
/// tilted 5 degrees, far inside the friction cone): no rocking, no tilt, and it sinks
/// only by the elastic compression of the contact (`m g / k`, `k` from both bodies'
/// moduli and thicknesses, over the whole face). A face supported at one point balances
/// only by symmetry, and sinks by more. Checked on the ground plane and on an anchored
/// chunk.
#[test]
fn a_box_set_down_flat_stays_flat() {
    let mut failures = Vec::new();
    for on_chunk in [false, true] {
        let mut s = incline(5f64.to_radians(), 0.5, 2400.0, 0.5, 0.2);
        let h = 0.1;
        if on_chunk {
            // An anchored slab chunk below the block instead of the ground plane.
            s.ground = None;
            s.bodies[0].chunks[0].center = [0.0, 0.0, 3.0 * h];
            let mut slab = chunk(Vec3::new(0.0, 0.0, h), Vec3::new(4.0 * h, 4.0 * h, h), "ground");
            slab.support = Support::Fixed;
            s.bodies.push(body("slab", vec![slab], vec![]));
        }
        let base = if on_chunk { 2.0 * h } else { 0.0 };
        let mut w = World::new(&s);
        let (mut peak_w, mut tilt, mut sink) = (0.0f64, 0.0f64, 0.0f64);
        while w.solver.time < s.sim.duration - 0.5 * s.sim.frame_dt {
            w.step_frame();
            let cl = &w.solver.clusters[w.solver.chunks[0][0].cluster];
            peak_w = peak_w.max(cl.angular_velocity.norm());
            tilt = tilt.max(cl.rotation().m[2][2].clamp(-1.0, 1.0).acos().to_degrees());
            sink = sink.max(base + h - w.solver.chunk_position(0, 0).z);
        }
        let m = &s.materials["block"];
        let e = m.youngs_modulus / (1.0 - m.poisson_ratio * m.poisson_ratio);
        let k = (2.0 * h).powi(2) / (h / e + h / e);
        let elastic = 2400.0 * (2.0 * h).powi(3) * G / k;
        let label = if on_chunk { "on an anchored chunk" } else { "on the ground" };
        println!("{label}: peak spin {peak_w:.2e} rad/s, tilt {tilt:.3} deg, sink {sink:.2e} m (elastic {elastic:.2e} m)");
        if peak_w > 1e-3 || tilt > 0.01 || sink > 2.0 * elastic {
            failures.push(format!("{label}: rocks at up to {peak_w:.2e} rad/s, tilts {tilt:.3} deg, sinks {sink:.2e} m (elastic {elastic:.2e} m)"));
        }
    }
    assert!(failures.is_empty(), "a box set down flat does not rest flat:\n{}", failures.join("\n"));
}

// ------------------------------------------------------------------ Coulomb friction

/// Displacement along the slope of a block path.
fn along(p: &[(f64, Vec3, Vec3)], k: usize) -> f64 {
    p[k].1.x - p[0].1.x
}

/// Below the friction angle a block sticks: once the contact has settled it does not
/// move (no creep), whatever its mass and the substep. Coulomb friction holds any
/// tangential force up to `mu N` with zero slip; a regularised (viscous) law creeps.
#[test]
fn a_block_below_the_friction_angle_sticks_without_creep() {
    let (mu, slope) = (0.5, 20f64.to_radians()); // tan 20 = 0.36 < 0.5
    let mut failures = Vec::new();
    for density in [24.0, 2400.0, 240_000.0] {
        for safety in [0.5, 0.1] {
            let p = block_path(&incline(slope, mu, density, safety, 0.4));
            let n = p.len() - 1;
            // Creep over the second half, after any contact transient.
            let creep = along(&p, n) - along(&p, n / 2);
            let rate = creep / (p[n].0 - p[n / 2].0);
            println!("density {density}, safety {safety}: slid {creep:.3e} m over the last {:.2} s ({rate:.2e} m/s)", p[n].0 - p[n / 2].0);
            if creep.abs() > 1e-7 {
                failures.push(format!("density {density} kg/m3, safety {safety}: creeps {rate:.2e} m/s below the friction angle"));
            }
        }
    }
    assert!(failures.is_empty(), "a sticking block creeps:\n{}", failures.join("\n"));
}

/// Above the friction angle a block slides with `a = g (sin t - mu cos t)`, whatever
/// its mass and the substep.
#[test]
fn a_block_above_the_friction_angle_slides_at_the_coulomb_acceleration() {
    let (mu, slope) = (0.3, 30f64.to_radians());
    let expected = G * (slope.sin() - mu * slope.cos());
    let mut failures = Vec::new();
    for density in [24.0, 2400.0, 240_000.0] {
        for safety in [0.5, 0.1] {
            let p = block_path(&incline(slope, mu, density, safety, 0.3));
            // Acceleration from the velocity change over the run, after 50 ms.
            let (k0, k1) = (50, p.len() - 1);
            let a = (p[k1].2.x - p[k0].2.x) / (p[k1].0 - p[k0].0);
            let err = (a - expected).abs() / expected;
            println!("density {density}, safety {safety}: a = {a:.4} m/s2 (Coulomb {expected:.4}), {:.2}%", 100.0 * err);
            if err > 0.01 {
                failures.push(format!("density {density} kg/m3, safety {safety}: a = {a:.4} vs {expected:.4} m/s2 ({:.1}%)", 100.0 * err));
            }
        }
    }
    assert!(failures.is_empty(), "sliding acceleration is not Coulomb's:\n{}", failures.join("\n"));
}

/// A block sliding on flat ground stops after `v^2 / (2 mu g)` in `v / (mu g)` and then
/// stays put, whatever its mass and the substep.
#[test]
fn a_sliding_block_stops_after_the_coulomb_distance() {
    let (mu, speed) = (0.5, 1.0);
    let (distance, time) = (speed * speed / (2.0 * mu * G), speed / (mu * G));
    let mut failures = Vec::new();
    for density in [24.0, 2400.0, 240_000.0] {
        for safety in [0.5, 0.1] {
            let p = block_path(&sliding(speed, mu, density, safety, 0.4));
            let n = p.len() - 1;
            let travelled = along(&p, n);
            let stop = p.iter().find(|e| e.2.x.abs() < 1e-3 * speed).map_or(f64::INFINITY, |e| e.0);
            let creep = along(&p, n) - along(&p, n - 100);
            println!("density {density}, safety {safety}: {travelled:.4} m (Coulomb {distance:.4}), stopped at {stop:.3} s ({time:.3}), last 0.1 s {creep:.2e} m");
            if (travelled - distance).abs() > 0.01 * distance || (stop - time).abs() > 0.01 + 0.02 * time || creep.abs() > 1e-7 {
                failures.push(format!(
                    "density {density} kg/m3, safety {safety}: slid {travelled:.4} m (Coulomb {distance:.4}), stopped at {stop:.3} s ({time:.3}), creeps {creep:.2e} m afterwards"
                ));
            }
        }
    }
    assert!(failures.is_empty(), "sliding to rest is not Coulomb's:\n{}", failures.join("\n"));
}

// ------------------------------------------------------------------ step independence

/// Without fracture, an impact converges as the substep shrinks: the ram's rebound
/// velocity changes less between the two finest substeps than between the two
/// coarsest (first-order or better). With fracture, crack contact and friction, the
/// outcome at the default substep and frame agrees with the finest within the
/// refinement study's 10% (fracture is discontinuous in time, so not monotonically).
#[test]
fn an_impact_converges_as_the_substep_and_the_frame_step_shrink() {
    let outcome = |fracture: bool, safety: f64, frame_dt: f64| {
        let mut s = small_impact();
        s.sim.fracture = fracture;
        s.sim.courant_safety = safety;
        s.sim.frame_dt = frame_dt;
        let f = frames(&s);
        let last = f.last().unwrap();
        (broken(last).len() as f64, v(last.impactors[0].velocity).y)
    };
    let elastic: Vec<f64> = [0.5, 0.25, 0.125].iter().map(|&k| outcome(false, k, 1e-3).1).collect();
    println!("elastic ram speed at safety 0.5, 0.25, 0.125: {elastic:?}");
    assert!((elastic[2] - elastic[1]).abs() <= (elastic[1] - elastic[0]).abs(), "elastic rebound does not converge with the substep: {elastic:?}");
    let runs: Vec<((f64, f64), (f64, f64))> =
        [(0.5, 1e-3), (0.25, 1e-3), (0.125, 1e-3), (0.5, 2.5e-4)].iter().map(|&(s, f)| ((s, f), outcome(true, s, f))).collect();
    for ((s, f), (b, vy)) in &runs {
        println!("fracture, safety {s}, frame {f}: {b} broken bonds, ram {vy:.4} m/s");
    }
    let ((b0, v0), (b2, v2), (bf, vf)) = (runs[0].1, runs[2].1, runs[3].1);
    assert!(common::rel(v0, v2) < 0.10 && common::rel(b0.max(1.0), b2.max(1.0)) < 0.10, "default substep differs from the finest: ram {v0} vs {v2}, bonds {b0} vs {b2}");
    assert!(common::rel(v0, vf) < 0.10 && common::rel(b0.max(1.0), bf.max(1.0)) < 0.10, "frame step changes the outcome: ram {v0} vs {vf}, bonds {b0} vs {bf}");
}
