//! The standalone world on the GPU: stress-ref `World::step_frame` (explicit mode)
//! with the stress solve, scripted loads and probes on the GPU (`GpuSolver`).
//!
//! A stress-ref `World` is kept as the host shell: it supplies the prestressed initial
//! state, the substep schedule (`substep_dt`) and the observation assembly, run on the
//! GPU solver's mirror. Scripted structural events (removals) run the reference's own
//! code on the mirror at the start of the substep they fall in; segments start there and
//! where a blast first acts, so blast faces are cached with that moment's geometry.

use stress_ref::math::Vec3;
use stress_ref::observation::{Observation, ProbeSeries};
use stress_ref::scene::{EventDesc, LoadDesc, ProbeKind, Scene, SectionComponent, SolveMode};
use stress_ref::solver::ReferenceSolver;
use stress_ref::world::World;

use crate::gpu::Gpu;
use crate::loads::WorldLoads;
use crate::solver::GpuSolver;

/// Probe accumulator (world.rs `ProbeAcc`): envelope since the last sample.
#[derive(Clone, Debug, Default)]
struct ProbeAcc {
    series: ProbeSeries,
    lo: f64,
    hi: f64,
}

pub struct GpuWorld {
    pub scene: Scene,
    /// The host shell (its `solver` is a placeholder; the mirror lives in `solver`).
    shell: World,
    pub solver: GpuSolver,
    pub frame: u64,
    events_done: Vec<bool>,
    blasts_active: Vec<bool>,
    probes: Vec<ProbeAcc>,
    next_sample: f64,
    sample_interval: f64,
}

/// Why a scene cannot run on the GPU yet.
pub fn unsupported(scene: &Scene) -> Option<String> {
    if scene.sim.solve_mode != SolveMode::Explicit {
        return Some(format!("solve mode {:?} (only explicit so far)", scene.sim.solve_mode));
    }
    if scene.sim.methods.layer_contact {
        return Some("layer contact (the penalty contact is on the GPU so far)".into());
    }
    if scene.sim.refine_utilization.is_some() {
        return Some("refinement".into());
    }
    None
}

impl GpuWorld {
    pub fn new(gpu: &Gpu, scene: &Scene) -> Result<GpuWorld, String> {
        if let Some(why) = unsupported(scene) {
            return Err(why);
        }
        let mut shell = World::new(scene);
        let mirror = shell.solver.clone();
        let loads = WorldLoads::new(scene, &mirror);
        let solver = GpuSolver::new(gpu, mirror, Some(loads), shell.impactors.clone())?;
        // The shell keeps a light placeholder; the mirror is swapped in when needed.
        shell.solver = ReferenceSolver::new(&Scene { bodies: Vec::new(), ..scene.clone() });
        let mut w = GpuWorld {
            scene: scene.clone(),
            shell,
            solver,
            frame: 0,
            events_done: vec![false; scene.events.len()],
            blasts_active: vec![false; scene.loads.len()],
            probes: vec![ProbeAcc::default(); scene.probes.len()],
            next_sample: 0.0,
            sample_interval: scene.sim.sample_interval.unwrap_or(scene.sim.frame_dt),
        };
        let values: Vec<f64> = (0..scene.probes.len()).map(|p| w.probe_value(p)).collect();
        w.record(w.solver.mirror.time, &values, true);
        Ok(w)
    }

    /// Run `f` with the mirror in the shell `World`.
    fn with_shell<R>(&mut self, f: impl FnOnce(&World) -> R) -> R {
        self.shell.impactors = self.solver.impactors.clone();
        self.shell.contact.dissipated = self.solver.contact_dissipated;
        self.shell.contact.crush = self.solver.crush_energy;
        std::mem::swap(&mut self.shell.solver, &mut self.solver.mirror);
        let r = f(&self.shell);
        std::mem::swap(&mut self.shell.solver, &mut self.solver.mirror);
        r
    }

    /// Apply scripted events due at time `t` (world.rs `process_events`). True if any.
    fn process_events(&mut self, t: f64) -> bool {
        let mut any = false;
        for ei in 0..self.scene.events.len() {
            if self.events_done[ei] {
                continue;
            }
            let m = &mut self.solver.mirror;
            match self.scene.events[ei].clone() {
                EventDesc::RemoveChunks { time, duration, body, chunks } => {
                    if t + 1e-12 < time {
                        continue;
                    }
                    let s = m.structure_index(&body).expect("event body");
                    let sel = select_with_descendants(&chunks, &self.scene, s);
                    m.remove_chunks(s, &sel, duration);
                }
                EventDesc::RemoveSupports { time, duration, body, chunks } => {
                    if t + 1e-12 < time {
                        continue;
                    }
                    let s = m.structure_index(&body).expect("event body");
                    let sel = chunks.select(&self.scene.bodies[s]);
                    m.remove_supports(s, &sel, duration);
                }
            }
            self.events_done[ei] = true;
            any = true;
        }
        any
    }

    /// Whether a blast starts acting at time `t` (its faces are then cached).
    fn blasts_starting(&mut self, t: f64) -> bool {
        let mut any = false;
        for (li, l) in self.scene.loads.iter().enumerate() {
            if let LoadDesc::Blast { time, .. } = l {
                if !self.blasts_active[li] && t + 1e-12 >= *time {
                    self.blasts_active[li] = true;
                    any = true;
                }
            }
        }
        any
    }

    /// Advance one frame (`sim.frame_dt`).
    pub fn step_frame(&mut self, gpu: &Gpu) -> Result<(), String> {
        let dt = self.with_shell(|w| w.substep_dt());
        let n = (self.scene.sim.frame_dt / dt).round().max(1.0) as usize;
        let mut done = 0;
        while done < n {
            let t = self.solver.mirror.time;
            let changed = self.process_events(t);
            let blast = self.blasts_starting(t);
            if changed || blast {
                if let Some(l) = self.solver.loads.as_mut() {
                    l.topology_version += changed as u64;
                }
                if changed {
                    // The removal may have split clusters: the reference re-forms them
                    // inside `remove_chunks`/`remove_supports`.
                }
                self.solver.rebuild(gpu, 0.0)?;
            }
            // The segment runs to the next substep at which an event or blast is due.
            let mut len = 1;
            while done + len < n {
                let tk = t + len as f64 * dt;
                let due = self.scene.events.iter().enumerate().any(|(ei, e)| {
                    !self.events_done[ei]
                        && match e {
                            EventDesc::RemoveChunks { time, .. } | EventDesc::RemoveSupports { time, .. } => tk + 1e-12 >= *time,
                        }
                }) || self.scene.loads.iter().enumerate().any(|(li, l)| matches!(l, LoadDesc::Blast { time, .. } if !self.blasts_active[li] && tk + 1e-12 >= *time));
                if due {
                    break;
                }
                len += 1;
            }
            let start = self.solver.mirror.substeps as usize;
            let values = self.solver.step(gpu, dt, len)?;
            for k in 0..len {
                let t = self.solver.time_after(start + k + 1);
                let row: Vec<f64> = values.iter().map(|v| v[k]).collect();
                self.record(t, &row, false);
            }
            done += len;
        }
        self.frame += 1;
        Ok(())
    }

    /// Run the scene to its duration and return the observation.
    pub fn run(&mut self, gpu: &Gpu) -> Result<Observation, String> {
        let frames = (self.scene.sim.duration / self.scene.sim.frame_dt).round() as u64;
        while self.frame < frames {
            self.step_frame(gpu)?;
        }
        Ok(self.observation())
    }

    /// The observation (world.rs `observation`, on the GPU state), with the GPU's probes.
    pub fn observation(&mut self) -> Observation {
        let mut obs = self.with_shell(|w| w.observation());
        obs.solver = "stress-gpu".into();
        for (p, acc) in self.scene.probes.iter().zip(&self.probes) {
            obs.probes.insert(p.name.clone(), acc.series.clone());
        }
        obs
    }

    /// world.rs `record_probes`.
    fn record(&mut self, t: f64, values: &[f64], force_sample: bool) {
        let sample = force_sample || t + 1e-12 >= self.next_sample;
        for (acc, &v) in self.probes.iter_mut().zip(values) {
            if acc.series.t.is_empty() && !force_sample {
                continue;
            }
            if acc.series.t.is_empty() || force_sample {
                acc.lo = v;
                acc.hi = v;
            } else {
                acc.lo = acc.lo.min(v);
                acc.hi = acc.hi.max(v);
            }
            if sample {
                acc.series.push(t, v, acc.lo, acc.hi);
                acc.lo = v;
                acc.hi = v;
            }
        }
        if sample {
            self.next_sample = t + self.sample_interval;
        }
    }

    /// A probe's value from the mirror (world.rs `probe_value`), for the initial sample.
    fn probe_value(&self, p: usize) -> f64 {
        let m = &self.solver.mirror;
        let initial = &self.solver.loads.as_ref().expect("loads").initial_positions;
        match &self.scene.probes[p].kind {
            ProbeKind::ChunkDisplacement { body, chunk, axis } => {
                let s = m.structure_index(body).expect("probe body");
                if !m.chunks[s][*chunk].active {
                    return f64::NAN;
                }
                (m.chunk_position(s, *chunk) - initial[s][*chunk]).dot(Vec3::from_array(*axis).normalized())
            }
            ProbeKind::ChunkVelocity { body, chunk, axis } => {
                let s = m.structure_index(body).expect("probe body");
                if !m.chunks[s][*chunk].active {
                    return f64::NAN;
                }
                m.chunk_velocity(s, *chunk).0.dot(Vec3::from_array(*axis).normalized())
            }
            ProbeKind::SectionForce { body, point, normal, region, component } => {
                let s = m.structure_index(body).expect("probe body");
                let pt = Vec3::from_array(*point);
                let n = Vec3::from_array(*normal).normalized();
                let st = &m.structures[s];
                let (mut f, mut mo) = (Vec3::ZERO, Vec3::ZERO);
                for b in m.bonds[s].iter().filter(|b| b.alive) {
                    let g = &b.geometry;
                    if region.as_ref().is_some_and(|r| !r.contains(g.centroid)) {
                        continue;
                    }
                    let (sa, sb) = ((st.chunks[g.a].center - pt).dot(n), (st.chunks[g.b].center - pt).dot(n));
                    if sa * sb >= 0.0 {
                        continue;
                    }
                    let (fa, ma, fb, mb) = g.chunk_loads(&b.force);
                    let (fc, mc, xc) = if sa > 0.0 { (fa, ma, st.chunks[g.a].center) } else { (fb, mb, st.chunks[g.b].center) };
                    f += fc;
                    mo += mc + (xc - pt).cross(fc);
                }
                match component {
                    SectionComponent::Normal => -f.dot(n),
                    SectionComponent::Force(a) => f.dot(Vec3::from_array(*a).normalized()),
                    SectionComponent::Moment(a) => mo.dot(Vec3::from_array(*a).normalized()),
                }
            }
            ProbeKind::Reaction { body, chunks, axis } => {
                let s = m.structure_index(body).expect("probe body");
                let a = Vec3::from_array(*axis).normalized();
                chunks.select(&self.scene.bodies[s]).into_iter().map(|c| m.reaction_world(s, c).0.dot(a)).sum()
            }
            ProbeKind::ImpactorVelocity { impactor, axis } => {
                let imp = self.solver.impactors.iter().find(|i| &i.name == impactor).expect("probe impactor");
                imp.velocity.dot(Vec3::from_array(*axis).normalized())
            }
            ProbeKind::ImpactorPosition { impactor, axis } => {
                let imp = self.solver.impactors.iter().find(|i| &i.name == impactor).expect("probe impactor");
                imp.pose.position.dot(Vec3::from_array(*axis).normalized())
            }
        }
    }
}

fn select_with_descendants(sel: &stress_ref::scene::ChunkSelector, scene: &Scene, s: usize) -> Vec<usize> {
    let body = &scene.bodies[s];
    let mut out = sel.select(body);
    let mut i = 0;
    while i < out.len() {
        for (k, c) in body.chunks.iter().enumerate() {
            if c.parent == Some(out[i]) && !out.contains(&k) {
                out.push(k);
            }
        }
        i += 1;
    }
    out
}
