//! Diagnostic (`--ignored --nocapture`): the house-1story ram (realtime_peak's "house
//! ram") stepped well past the benchmark's 0.25 s, frame by frame: the fastest cluster
//! and chunk, kinetic energy, substeps, splits and lost chunks.
//!   BLOWUP_FRAMES (default 190), BLOWUP_TRACE_FROM (frame from which
//!   STRESS_GPU_COUPLED_TRACE is set), BLOWUP_ENGINE=cpu (PhysX CPU instead of GPU).
#![cfg(feature = "gpu")]

use stress_gpu::gpu::Gpu;
use stress_gpu::world::GpuWorld;
use stress_physx::PhysxEngine;
use stress_ref::math::Vec3;
use stress_ref::scene::Scene;

fn env_usize(k: &str, d: usize) -> usize {
    std::env::var(k).ok().and_then(|v| v.parse().ok()).unwrap_or(d)
}

pub fn configure(mut s: Scene, seconds: f64) -> Scene {
    s.sim.methods = stress_ref::scene::Methods::established();
    s.sim.methods.true_step = true;
    s.sim.courant_safety = 0.35;
    s.sim.stress_courant_safety = Some(0.5);
    s.sim.solve_mode = stress_ref::scene::SolveMode::Adaptive;
    s.sim.duration = seconds;
    s
}

pub fn house_ram(name: &str) -> Scene {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join(format!("../../../../blast/blast-stress-demo-rs/assets/scenes/{name}.json"));
    stress_gpu::scenes::rammed(stress_ref::scene_pack::import(&path, name, "structure").unwrap())
}

#[path = "common/motion.rs"]
mod motion;
use motion::report;

#[test]
#[ignore]
fn house_ram_long() {
    let name = std::env::var("BLOWUP_SCENE").unwrap_or_else(|_| "house-1story".into());
    let frames = env_usize("BLOWUP_FRAMES", 190);
    let trace_from = env_usize("BLOWUP_TRACE_FROM", usize::MAX);
    let s = configure(house_ram(&name), frames as f64 / 60.0);
    let Ok(gpu) = Gpu::new() else { return };
    let g = Vec3::from_array(s.gravity);
    let engine = if std::env::var("BLOWUP_ENGINE").is_ok_and(|v| v == "cpu") { PhysxEngine::boxed(g) } else { PhysxEngine::boxed_gpu(g) }.expect("PhysX");
    let mut w = GpuWorld::with_engine(&gpu, &s, engine).expect("GPU world");
    let chunks: usize = w.solver.mirror.structures.iter().map(|s| s.chunks.len()).sum();
    let bonds: usize = w.solver.mirror.bonds.iter().map(|b| b.len()).sum();
    eprintln!("{name} rammed: {chunks} chunks, {bonds} bonds");
    let mut first_bad = None;
    for f in 0..frames {
        if f == trace_from {
            std::env::set_var("STRESS_GPU_COUPLED_TRACE", "1");
        }
        let s0 = w.solver.mirror.substeps;
        let splits0 = w.solver.host_splits;
        let replans0 = w.solver.replans;
        let t = std::time::Instant::now();
        w.step_frame(&gpu).expect("frame");
        let ms = t.elapsed().as_secs_f64() * 1e3;
        w.solver.sync(&gpu);
        let m = &w.solver.mirror;
        let (v, line) = report(m, &w.solver.impactors);
        eprintln!(
            "frame {f} t {:.3}: {ms:.0} ms, {} substeps, splits {}, replans {}, {} clusters, {} broken; {line}",
            m.time,
            m.substeps - s0,
            w.solver.host_splits - splits0,
            w.solver.replans - replans0,
            m.clusters.len(),
            m.broken_bond_count()
        );
        if first_bad.is_none() && (v > 200.0 || !v.is_finite()) {
            first_bad = Some(f);
            if std::env::var("BLOWUP_STOP").is_ok() {
                break;
            }
        }
    }
    eprintln!("first frame above 200 m/s: {first_bad:?}");
}

/// Regression (`--ignored --nocapture`, about 3 min): house-1story rammed for 10 s on the
/// GPU world coupled to PhysX GPU at the realtime_peak settings, with the segment
/// horizons fixed (`STRESS_GPU_FIXED_HORIZON=1`) so the run is reproducible (the cost
/// model's horizons follow measured wall-clock costs). Before the GPU statics stopped
/// accepting a diverged settle (world.slang `island_statics`), frame 62's settle of a
/// free fragment returned |u| ~ 1e11 m, |th| ~ 1e12 rad, and its split sent chunks off at
/// ~1e8 m/s.
///
/// Every chunk's speed must stay within what the scene's energy allows: no chunk can
/// carry more kinetic energy than the ram's kinetic energy plus the potential energy of
/// every chunk falling to the ground, `v <= sqrt(2 (E_ram + sum m_i g (z_i - z_ground)) /
/// m_chunk)` (each chunk against its own mass); the ram likewise.
#[test]
#[ignore]
fn house_ram_stays_within_its_energy() {
    std::env::set_var("STRESS_GPU_FIXED_HORIZON", "1");
    let frames = env_usize("BLOWUP_FRAMES", 600);
    let s = configure(house_ram("house-1story"), frames as f64 / 60.0);
    let Ok(gpu) = Gpu::new() else { return };
    let g = Vec3::from_array(s.gravity);
    let Some(engine) = PhysxEngine::boxed_gpu(g) else {
        eprintln!("no PhysX GPU scene; skipping");
        return;
    };
    let mut w = GpuWorld::with_engine(&gpu, &s, engine).expect("GPU world");
    let ground = s.ground.as_ref().expect("house-1story stands on the ground").height;
    let m = &w.solver.mirror;
    let mut energy: f64 = s.impactors.iter().map(|i| 0.5 * i.mass * Vec3::from_array(i.velocity).norm2()).sum();
    let ram_lift: f64 = s.impactors.iter().map(|i| i.mass * g.norm() * (i.position[2] - ground).max(0.0)).sum();
    energy += ram_lift;
    for st in 0..m.structures.len() {
        for c in 0..m.structures[st].chunks.len() {
            energy += m.structures[st].chunks[c].mass * g.norm() * (m.chunk_position(st, c).z - ground).max(0.0);
        }
    }
    eprintln!("energy available: {energy:.4e} J (ram kinetic and potential, chunks' potential above the ground)");
    let mut failure = None;
    let mut worst = (0.0f64, 0usize);
    for f in 0..frames {
        w.step_frame(&gpu).expect("frame");
        w.solver.sync(&gpu);
        let m = &w.solver.mirror;
        for st in 0..m.structures.len() {
            for c in 0..m.structures[st].chunks.len() {
                if !m.chunks[st][c].active {
                    continue;
                }
                let mass = m.structures[st].chunks[c].mass;
                let v = m.chunk_velocity(st, c).0.norm();
                let bound = (2.0 * energy / mass).sqrt();
                if v / bound > worst.0 {
                    worst = (v / bound, f);
                }
                if failure.is_none() && !(v <= bound) {
                    failure = Some(format!(
                        "frame {f} (t {:.3} s): chunk ({st},{c}) of {mass:.1} kg at {v:.3e} m/s, above the energy bound {bound:.2} m/s",
                        m.time
                    ));
                }
            }
        }
        for imp in &w.solver.impactors {
            let bound = (2.0 * energy / imp.mass).sqrt();
            if failure.is_none() && !(imp.velocity.norm() <= bound) {
                failure = Some(format!("frame {f}: ram at {:.3e} m/s, above the energy bound {bound:.2} m/s", imp.velocity.norm()));
            }
        }
        if let Some(why) = &failure {
            let all_u = (0..m.structures.len()).flat_map(|st| (0..m.structures[st].chunks.len()).map(move |c| (st, c))).filter(|&(st, c)| m.chunks[st][c].active);
            let (u, th) = all_u.fold((0.0f64, 0.0f64), |(u, th), (st, c)| (u.max(m.chunks[st][c].u.norm()), th.max(m.chunks[st][c].th.norm())));
            panic!("{why}; hidden max |u| {u:.3e} m, |th| {th:.3e} rad");
        }
    }
    w.solver.sync(&gpu);
    let o = w.observation();
    eprintln!(
        "{frames} frames: worst chunk speed {:.3} of its energy bound (frame {}); {} fragments, {} broken bonds",
        worst.0, worst.1, o.values["fragments"], o.values["broken_bonds"]
    );
}

/// The same scene on the reference world coupled to PhysX CPU (`World::with_engine`),
/// frame by frame (`BLOWUP_FRAMES`, default 192; `BLOWUP_SAFETY` overrides the contact
/// safety 0.35).
#[test]
#[ignore]
fn reference_house_ram_long() {
    let name = std::env::var("BLOWUP_SCENE").unwrap_or_else(|_| "house-1story".into());
    let frames = env_usize("BLOWUP_FRAMES", 192);
    let mut s = configure(house_ram(&name), frames as f64 / 60.0);
    if let Some(c) = std::env::var("BLOWUP_SAFETY").ok().and_then(|v| v.parse().ok()) {
        s.sim.courant_safety = c;
    }
    let mut w = stress_ref::world::World::with_engine(&s, PhysxEngine::boxed(Vec3::from_array(s.gravity)).expect("PhysX CPU"));
    for f in 0..frames {
        let s0 = w.solver.substeps;
        let t = std::time::Instant::now();
        w.step_frame();
        let (_, line) = report(&w.solver, &w.impactors);
        eprintln!(
            "ref frame {f} t {:.3}: {:.0} ms, {} substeps, {} clusters, {} broken; {line}",
            w.solver.time,
            t.elapsed().as_secs_f64() * 1e3,
            w.solver.substeps - s0,
            w.solver.clusters.len(),
            w.solver.broken_bond_count()
        );
    }
}

#[path = "../examples/common/packs.rs"]
mod packs;

/// fractured-bridge as the destruction_video recorder stages it alone (hull colliders
/// reduced to their corners, `packs::pack`), standing under its own weight with its chunks
/// about 20 m from its body origin (the recorder's town places packs by moving chunk
/// centres; the body origin stays at the world origin). No impactor: the recorder's ball
/// arrives at 2 s, after the fault.
fn bridge() -> Scene {
    let p = packs::pack("fractured-bridge");
    let (mut lo, mut hi) = (Vec3::splat(f64::INFINITY), Vec3::splat(f64::NEG_INFINITY));
    for c in &p.bodies[0].chunks {
        lo = lo.component_min(Vec3::from_array(c.center));
        hi = hi.component_max(Vec3::from_array(c.center));
    }
    let offset = Vec3::new(20.0 - 0.5 * (lo.x + hi.x), -0.5 * (lo.y + hi.y), 0.0);
    let mut s = p.clone();
    s.impactors.clear();
    for body in &mut s.bodies {
        for c in &mut body.chunks {
            c.center = (Vec3::from_array(c.center) + offset).to_array();
        }
        for b in &mut body.bonds {
            b.centroid = (Vec3::from_array(b.centroid) + offset).to_array();
        }
    }
    s
}

/// Mechanical energy of the mirror and impactors: every active chunk's kinetic energy
/// (its world velocity and spin: a rigid cluster's by the parallel-axis theorem, plus the
/// hidden deformation's) and potential energy above the ground; and the bonds' stored
/// energy.
fn mechanical(m: &stress_ref::solver::ReferenceSolver, imps: &[stress_ref::world::Impactor], g: f64, ground: f64) -> (f64, f64) {
    let mut e = 0.0;
    for s in 0..m.structures.len() {
        for c in 0..m.structures[s].chunks.len() {
            if !m.chunks[s][c].active {
                continue;
            }
            let ch = &m.structures[s].chunks[c];
            let (v, w) = m.chunk_velocity(s, c);
            let st = &m.chunks[s][c];
            let q = m.clusters[st.cluster].pose.rotation * stress_ref::math::Quat::from_axis_angle(st.th, st.th.norm());
            let r = q.to_mat3() * ch.rotation;
            let iw = r * ch.inertia * r.transpose();
            e += 0.5 * ch.mass * v.norm2() + 0.5 * w.dot(iw * w) + ch.mass * g * (m.chunk_position(s, c).z - ground);
        }
    }
    for imp in imps {
        e += 0.5 * imp.mass * imp.velocity.norm2() + imp.mass * g * (imp.pose.position.z - ground);
    }
    let stored: f64 = m.bonds.iter().flatten().filter(|b| b.alive).map(|b| b.stored).sum();
    (e, stored)
}

/// Nothing does work on the bridge but gravity (in the potential energy); bonds,
/// contacts and the engine only store or dissipate. So the chunks' kinetic plus
/// potential energy can never exceed what the bridge started with: its kinetic and
/// potential energy and the prestress its bonds store. Records the first frame that does.
fn energy_check(f: usize, t: f64, now: f64, start: f64, failure: &mut Option<String>) {
    if failure.is_none() && !(now <= start) {
        *failure = Some(format!("frame {f} (t {t:.3} s): kinetic + potential energy {now:.6e} J above the {start:.6e} J the bridge started with (+{:.3e} J)", now - start));
    }
}

/// Regression (`--ignored --nocapture`; BLOWUP_FRAMES, default 60): fractured-bridge on
/// the GPU world coupled to PhysX GPU at the realtime_peak settings with fixed horizons,
/// within its energy (`energy_check`). While the drift removal's frame fold turned about
/// the body origin, a split child with a 0.09 rad hidden rotation jumped 9.5 cm
/// (1/2 phi^2 x 23.6 m) into its neighbour and the contact fired 2-3 t chunks at
/// 300-450 m/s (frame 49).
#[test]
#[ignore]
fn bridge_stays_within_its_energy_gpu() {
    std::env::set_var("STRESS_GPU_FIXED_HORIZON", "1");
    let frames = env_usize("BLOWUP_FRAMES", 60);
    let s = configure(bridge(), frames as f64 / 60.0);
    let Ok(gpu) = Gpu::new() else { return };
    let g = Vec3::from_array(s.gravity);
    let Some(engine) = PhysxEngine::boxed_gpu(g) else {
        eprintln!("no PhysX GPU scene; skipping");
        return;
    };
    let ground = s.ground.as_ref().expect("ground").height;
    let mut w = GpuWorld::with_engine(&gpu, &s, engine).expect("GPU world");
    w.solver.sync(&gpu);
    let (e0, stored0) = mechanical(&w.solver.mirror, &w.solver.impactors, g.norm(), ground);
    let start = e0 + stored0;
    eprintln!("start: kinetic + potential {e0:.6e} J, bonds' stored {stored0:.3e} J");
    let mut failure = None;
    let mut worst = f64::NEG_INFINITY;
    for f in 0..frames {
        w.step_frame(&gpu).expect("frame");
        w.solver.sync(&gpu);
        let (e, _) = mechanical(&w.solver.mirror, &w.solver.impactors, g.norm(), ground);
        worst = worst.max(e - start);
        energy_check(f, w.solver.mirror.time, e, start, &mut failure);
        if let Some(why) = &failure {
            let (v, line) = report(&w.solver.mirror, &w.solver.impactors);
            panic!("{why}; fastest {v:.3e} m/s: {line}");
        }
    }
    eprintln!("{frames} frames: kinetic + potential at most {worst:.4e} J relative to the start");
}

/// `bridge_stays_within_its_energy_gpu` on the reference world coupled to PhysX CPU
/// (`World::with_engine`, f64), which the same fold sent to 35 m/s at frame 49.
#[test]
#[ignore]
fn bridge_stays_within_its_energy_reference() {
    let frames = env_usize("BLOWUP_FRAMES", 60);
    let s = configure(bridge(), frames as f64 / 60.0);
    let g = Vec3::from_array(s.gravity);
    let ground = s.ground.as_ref().expect("ground").height;
    let mut w = stress_ref::world::World::with_engine(&s, PhysxEngine::boxed(g).expect("PhysX CPU"));
    let (e0, stored0) = mechanical(&w.solver, &w.impactors, g.norm(), ground);
    let start = e0 + stored0;
    eprintln!("start: kinetic + potential {e0:.6e} J, bonds' stored {stored0:.3e} J");
    let mut failure = None;
    let mut worst = f64::NEG_INFINITY;
    for f in 0..frames {
        w.step_frame();
        let (e, _) = mechanical(&w.solver, &w.impactors, g.norm(), ground);
        worst = worst.max(e - start);
        energy_check(f, w.solver.time, e, start, &mut failure);
        if let Some(why) = &failure {
            let (v, line) = report(&w.solver, &w.impactors);
            panic!("{why}; fastest {v:.3e} m/s: {line}");
        }
    }
    eprintln!("{frames} frames: kinetic + potential at most {worst:.4e} J relative to the start");
}
