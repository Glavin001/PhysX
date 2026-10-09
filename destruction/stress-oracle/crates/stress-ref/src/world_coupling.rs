//! The world coupled to an external rigid-body engine; see `engine.rs` for the design.

use std::collections::HashMap;
use std::hash::{Hash, Hasher};

use super::*;

/// A body taking part in island selection (or the ground).
struct Part {
    key: Option<BodyKey>,
    /// Bounds swept over the frame.
    lo: Vec3,
    hi: Vec3,
    velocity: Vec3,
    angular_velocity: Vec3,
    /// Largest distance of its surface from the centre of mass (for rotation sweeps).
    reach: f64,
    /// Infinite for supported clusters and the ground.
    mass: f64,
    /// Plane-strain modulus `E / (1 - nu^2)` of its (softest) material, as simulated.
    modulus: f64,
    /// Radius of curvature at a contact (sphere radius, half the smallest box size).
    contact_radius: f64,
    /// Present for clusters with bonds: what makes the rigid assumption fail on them.
    struck: Option<Struck>,
}

/// Properties of a breakable body that decide whether a contact on it may be rigid.
#[derive(Clone, Copy)]
struct Struck {
    /// Time for a bar wave to cross the body and back (s).
    round_trip: f64,
    /// Tensile capacity of its weakest bond (N).
    capacity: f64,
}

/// Whether the rigid-body assumption fails for `a` striking breakable `b`: the impact
/// (Hertz contact time at the closing speed) is shorter than a wave round trip across
/// `b`, so only part of `b` takes part, or its peak force (elastic impulse over a
/// half-sine of that duration) exceeds `b`'s weakest bond, so `b` breaks during the
/// contact. Both follow from the bodies' masses, moduli, sizes and strengths.
fn rigid_assumption_fails(a: &Part, b: &Part) -> bool {
    let Some(struck) = b.struck else { return false };
    let speed = (a.velocity - b.velocity).norm() + a.angular_velocity.norm() * a.reach + b.angular_velocity.norm() * b.reach;
    let m = match (a.mass.is_finite(), b.mass.is_finite()) {
        (true, true) => a.mass * b.mass / (a.mass + b.mass),
        (true, false) => a.mass,
        (false, true) => b.mass,
        (false, false) => return false,
    };
    if speed <= 0.0 {
        return false;
    }
    let modulus = 1.0 / (1.0 / a.modulus + 1.0 / b.modulus);
    let duration = hertz_duration(m, a.contact_radius.min(b.contact_radius), modulus, speed);
    let peak_force = std::f64::consts::PI * (2.0 * m * speed) / (2.0 * duration);
    duration < struck.round_trip || peak_force > struck.capacity
}

fn overlaps(a: &Part, b: &Part) -> bool {
    (0..3).all(|i| a.lo[i] <= b.hi[i] && b.lo[i] <= a.hi[i])
}

fn find(parent: &mut [usize], i: usize) -> usize {
    let mut r = i;
    while parent[r] != r {
        r = parent[r];
    }
    let mut j = i;
    while parent[j] != r {
        let next = parent[j];
        parent[j] = r;
        j = next;
    }
    r
}

fn interpolate(a: &BodyMotion, b: &BodyMotion, s: f64) -> (Pose, Vec3, Vec3) {
    let mut qb = b.pose.rotation;
    let qa = a.pose.rotation;
    if qa.w * qb.w + qa.x * qb.x + qa.y * qb.y + qa.z * qb.z < 0.0 {
        qb = Quat { w: -qb.w, x: -qb.x, y: -qb.y, z: -qb.z };
    }
    let q = Quat {
        w: qa.w + (qb.w - qa.w) * s,
        x: qa.x + (qb.x - qa.x) * s,
        y: qa.y + (qb.y - qa.y) * s,
        z: qa.z + (qb.z - qa.z) * s,
    }
    .normalized();
    let p = a.pose.position + (b.pose.position - a.pose.position) * s;
    (Pose::new(p, q), a.velocity + (b.velocity - a.velocity) * s, a.angular_velocity + (b.angular_velocity - a.angular_velocity) * s)
}

impl World {
    /// The world coupled to an external rigid-body engine, which then owns rigid motion
    /// and contact except in impact islands (see `engine.rs`). Runs the explicit solve.
    pub fn with_engine(scene: &Scene, mut engine: Box<dyn RigidEngine>) -> World {
        assert!(scene.sim.solve_mode == SolveMode::Explicit, "the engine-coupled world runs the explicit solve");
        let mut w = World::new(scene);
        if let Some(g) = &scene.ground {
            engine.add_ground(g.height);
        }
        w.coupling = Some(Coupling { engine, filter: ContactLoadFilter::new(), start: HashMap::new(), end: HashMap::new() });
        w.sync_engine_bodies();
        w
    }

    /// Name of the coupled engine, if any.
    pub fn engine_name(&self) -> Option<&str> {
        self.coupling.as_ref().map(|c| c.engine.name())
    }

    fn impactor_radius(imp: &Impactor) -> f64 {
        match imp.shape {
            ImpactorShape::Sphere { radius } => radius,
            ImpactorShape::Box { half_extents } => half_extents.iter().copied().fold(f64::INFINITY, f64::min),
        }
    }

    /// Every body as the engine should have it: one per cluster (boxes per chunk) and
    /// one per impactor.
    fn engine_bodies(&self) -> Vec<EngineBody> {
        let mut out = Vec::new();
        for cl in &self.solver.clusters {
            let st = &self.solver.structures[cl.structure];
            let mut hasher = std::collections::hash_map::DefaultHasher::new();
            (cl.structure, &cl.chunks, cl.anchored).hash(&mut hasher);
            let shapes = cl
                .chunks
                .iter()
                .map(|&c| {
                    let ch = &st.chunks[c];
                    BoxShape {
                        local: Pose::new(ch.center, rotation_of(&ch.rotation)),
                        half_extents: ch.half_extents,
                        mass: ch.mass,
                        chunk: Some((cl.structure, c)),
                    }
                })
                .collect();
            out.push(EngineBody {
                key: BodyKey::Cluster(cl.id),
                signature: hasher.finish(),
                geometry: BodyGeometry::Boxes(shapes),
                fixed: cl.anchored,
                ccd: false,
                pose: cl.pose,
                velocity: cl.velocity,
                angular_velocity: cl.angular_velocity,
            });
        }
        for (i, imp) in self.impactors.iter().enumerate() {
            let geometry = match imp.shape {
                ImpactorShape::Sphere { radius } => BodyGeometry::Sphere { radius, mass: imp.mass },
                ImpactorShape::Box { half_extents } => BodyGeometry::Boxes(vec![BoxShape {
                    local: Pose::default(),
                    half_extents: Vec3::from_array(half_extents),
                    mass: imp.mass,
                    chunk: None,
                }]),
            };
            out.push(EngineBody {
                key: BodyKey::Impactor(i),
                signature: 0,
                geometry,
                fixed: false,
                ccd: true,
                pose: imp.pose,
                velocity: imp.velocity,
                angular_velocity: imp.angular_velocity,
            });
        }
        out
    }

    fn sync_engine_bodies(&mut self) {
        let bodies = self.engine_bodies();
        self.coupling.as_mut().expect("coupled").engine.sync_bodies(&bodies);
    }

    /// The world's own view of every body's motion.
    fn world_motion(&self) -> HashMap<BodyKey, BodyMotion> {
        let mut m = HashMap::new();
        for cl in &self.solver.clusters {
            let key = BodyKey::Cluster(cl.id);
            m.insert(key, BodyMotion { key, pose: cl.pose, velocity: cl.velocity, angular_velocity: cl.angular_velocity });
        }
        for (i, imp) in self.impactors.iter().enumerate() {
            let key = BodyKey::Impactor(i);
            m.insert(key, BodyMotion { key, pose: imp.pose, velocity: imp.velocity, angular_velocity: imp.angular_velocity });
        }
        m
    }

    /// Mark this frame's impact islands (bodies the world simulates) and the driven
    /// bodies (the engine's). Returns the number of bodies in islands.
    fn select_islands(&mut self, dt: f64) -> usize {
        let scale = self.scene.sim.stiffness_scale;
        let plane_strain = |m: &Material| m.youngs_modulus * scale / (1.0 - m.poisson_ratio * m.poisson_ratio);
        let mut parts: Vec<Part> = Vec::new();
        for ci in 0..self.solver.clusters.len() {
            let cl = &self.solver.clusters[ci];
            let s = cl.structure;
            let com = cl.com_world();
            let (mut lo, mut hi) = (Vec3::splat(f64::INFINITY), Vec3::splat(f64::NEG_INFINITY));
            let (mut reach, mut modulus, mut speed, mut radius): (f64, f64, f64, f64) = (0.0, f64::INFINITY, f64::INFINITY, f64::INFINITY);
            for &c in &cl.chunks {
                let b = self.chunk_box(s, c);
                let r = b.bounding_radius();
                lo = lo.component_min(b.center - Vec3::splat(r));
                hi = hi.component_max(b.center + Vec3::splat(r));
                reach = reach.max((b.center - com).norm() + r);
                let m = self.chunk_material(s, c);
                modulus = modulus.min(plane_strain(m));
                speed = speed.min((m.youngs_modulus * scale / m.density).sqrt());
                radius = radius.min(b.half.min_elem());
            }
            let capacity = cl
                .bonds
                .iter()
                .map(|&bi| {
                    let b = &self.solver.bonds[s][bi];
                    b.strength.tensile * b.geometry.area * b.weibull
                })
                .fold(f64::INFINITY, f64::min);
            let extent = (hi - lo).max_elem();
            let struck = (!cl.bonds.is_empty()).then_some(Struck { round_trip: 2.0 * extent / speed, capacity });
            let sweep = cl.velocity.abs() * dt + Vec3::splat(cl.angular_velocity.norm() * reach * dt);
            parts.push(Part {
                key: Some(BodyKey::Cluster(cl.id)),
                lo: lo - sweep,
                hi: hi + sweep,
                velocity: cl.velocity,
                angular_velocity: cl.angular_velocity,
                reach,
                mass: if cl.anchored { f64::INFINITY } else { cl.mass },
                modulus,
                contact_radius: radius,
                struck,
            });
        }
        for (i, imp) in self.impactors.iter().enumerate() {
            let b = imp.obox();
            let r = b.bounding_radius();
            let sweep = imp.velocity.abs() * dt + Vec3::splat(imp.angular_velocity.norm() * r * dt);
            parts.push(Part {
                key: Some(BodyKey::Impactor(i)),
                lo: b.center - Vec3::splat(r) - sweep,
                hi: b.center + Vec3::splat(r) + sweep,
                velocity: imp.velocity,
                angular_velocity: imp.angular_velocity,
                reach: r,
                mass: imp.mass,
                modulus: plane_strain(&imp.material),
                contact_radius: Self::impactor_radius(imp),
                struck: None,
            });
        }
        if let Some(g) = &self.scene.ground {
            parts.push(Part {
                key: None,
                lo: Vec3::splat(f64::NEG_INFINITY),
                hi: Vec3::new(f64::INFINITY, f64::INFINITY, g.height),
                velocity: Vec3::ZERO,
                angular_velocity: Vec3::ZERO,
                reach: 0.0,
                mass: f64::INFINITY,
                modulus: plane_strain(self.scene.material(&g.material)),
                contact_radius: f64::INFINITY,
                struck: None,
            });
        }

        // Owned pairs seed islands; any overlap of swept bounds joins bodies (the ground
        // and pairs of immovable bodies never do: they cannot exchange motion).
        let n = parts.len();
        let mut parent: Vec<usize> = (0..n).collect();
        let mut seed = vec![false; n];
        for i in 0..n {
            for j in i + 1..n {
                if !overlaps(&parts[i], &parts[j]) {
                    continue;
                }
                let owned = rigid_assumption_fails(&parts[i], &parts[j]) || rigid_assumption_fails(&parts[j], &parts[i]);
                let both_immovable = !parts[i].mass.is_finite() && !parts[j].mass.is_finite();
                if parts[i].key.is_none() || parts[j].key.is_none() {
                    // Against the ground: a breaking landing makes the body an island seed.
                    if owned {
                        seed[if parts[i].key.is_some() { i } else { j }] = true;
                    }
                    continue;
                }
                if both_immovable {
                    continue;
                }
                let (ri, rj) = (find(&mut parent, i), find(&mut parent, j));
                parent[ri] = rj;
                if owned {
                    seed[i] = true;
                    seed[j] = true;
                }
            }
        }
        let mut island_root = vec![false; n];
        for i in 0..n {
            if seed[i] {
                let r = find(&mut parent, i);
                island_root[r] = true;
            }
        }
        let mut count = 0;
        for i in 0..n {
            let in_island = parts[i].key.is_some() && island_root[find(&mut parent, i)];
            match parts[i].key {
                Some(BodyKey::Cluster(id)) => {
                    if let Some(cl) = self.solver.clusters.iter_mut().find(|c| c.id == id) {
                        cl.driven = !in_island;
                    }
                }
                Some(BodyKey::Impactor(k)) => self.impactors[k].driven = !in_island,
                None => {}
            }
            count += usize::from(in_island);
        }
        count
    }

    /// Impulse of the scripted loads (and removal ramps) over the frame on each driven
    /// free cluster, for the engine (gravity excluded: the engine applies it).
    fn scripted_impulses(&mut self, t0: f64, h: f64, n: usize) -> Vec<(BodyKey, Vec3, Vec3)> {
        let free: Vec<usize> =
            (0..self.solver.clusters.len()).filter(|&ci| self.solver.clusters[ci].driven && !self.solver.clusters[ci].anchored).collect();
        if free.is_empty() || (self.scene.loads.is_empty() && self.solver.replacements.is_empty()) {
            return Vec::new();
        }
        let g = self.solver.config.gravity;
        let mut acc = vec![(Vec3::ZERO, Vec3::ZERO); free.len()];
        for k in 0..n {
            self.loads.resize(&self.solver);
            self.loads.clear();
            self.apply_scripted_loads(t0 + (k as f64 + 0.5) * h);
            for (i, &ci) in free.iter().enumerate() {
                let (f, tq) = self.solver.net_load(ci, &self.loads);
                acc[i].0 += (f - g * self.solver.clusters[ci].mass) * h;
                acc[i].1 += tq * h;
            }
        }
        free.iter().zip(acc).map(|(&ci, (j, l))| (BodyKey::Cluster(self.solver.clusters[ci].id), j, l)).collect()
    }

    /// Driven bodies at fraction `s` of the frame, between the engine's start and end.
    fn set_driven_motion(&mut self, s: f64) {
        let c = self.coupling.as_ref().expect("coupled");
        for cl in self.solver.clusters.iter_mut().filter(|c| c.driven && !c.anchored) {
            let key = BodyKey::Cluster(cl.id);
            if let (Some(a), Some(b)) = (c.start.get(&key), c.end.get(&key)) {
                (cl.pose, cl.velocity, cl.angular_velocity) = interpolate(a, b, s);
            }
        }
        for (i, imp) in self.impactors.iter_mut().enumerate().filter(|(_, m)| m.driven) {
            let key = BodyKey::Impactor(i);
            if let (Some(a), Some(b)) = (c.start.get(&key), c.end.get(&key)) {
                (imp.pose, imp.velocity, imp.angular_velocity) = interpolate(a, b, s);
            }
        }
    }

    /// Engine contacts on driven clusters as contact impulses for the load filter.
    fn engine_contacts_to_impulses(&self, contacts: &[crate::engine::EngineContact]) -> Vec<ContactImpulse> {
        let ground_modulus = self.scene.ground.as_ref().map(|g| self.scene.material(&g.material).youngs_modulus).unwrap_or(3e10);
        contacts
            .iter()
            .filter(|c| self.solver.chunks[c.structure][c.chunk].active && self.solver.clusters[self.solver.chunks[c.structure][c.chunk].cluster].driven)
            .map(|c| {
                let (other_mass, other_modulus, other_radius) = match c.other {
                    Some(BodyKey::Impactor(i)) => {
                        let imp = &self.impactors[i];
                        (imp.mass, imp.material.youngs_modulus, Self::impactor_radius(imp))
                    }
                    Some(BodyKey::Cluster(id)) => match self.solver.clusters.iter().find(|cl| cl.id == id) {
                        Some(cl) => {
                            let ch = &self.solver.structures[cl.structure].chunks[cl.chunks[0]];
                            (if cl.anchored { f64::INFINITY } else { cl.mass }, ch.youngs_modulus, ch.half_extents.min_elem())
                        }
                        None => (f64::INFINITY, ground_modulus, 1.0),
                    },
                    None => (f64::INFINITY, ground_modulus, 1.0),
                };
                ContactImpulse {
                    structure: c.structure,
                    chunk: c.chunk,
                    point: c.point,
                    impulse: c.impulse,
                    other_mass,
                    approach_speed: c.approach_speed,
                    other_modulus,
                    other_radius,
                    crush: None,
                }
            })
            .collect()
    }

    /// One frame with the engine: islands, engine step, substeps, write-back, sync.
    pub(super) fn step_frame_coupled(&mut self) {
        let fdt = self.scene.sim.frame_dt;
        let t0 = self.solver.time;
        let island_bodies = self.select_islands(fdt);
        if island_bodies > 0 {
            self.island_frames += 1;
            self.max_island_bodies = self.max_island_bodies.max(island_bodies);
        }
        // Island contacts need the contact-limited substep; otherwise only the stress does.
        let mut dt = if island_bodies > 0 { self.substep_dt() } else { self.solver.stable_dt().min(fdt) };
        if let Some(m) = self.scene.sim.max_substep {
            dt = dt.min(m);
        }
        let n = (fdt / dt).ceil().max(1.0) as usize;
        let h = fdt / n as f64;

        let impulses = self.scripted_impulses(t0, h, n);
        let start = self.world_motion();
        let frozen: Vec<BodyKey> = self
            .solver
            .clusters
            .iter()
            .filter(|c| !c.driven)
            .map(|c| BodyKey::Cluster(c.id))
            .chain(self.impactors.iter().enumerate().filter(|(_, m)| !m.driven).map(|(i, _)| BodyKey::Impactor(i)))
            .collect();
        let coupling = self.coupling.as_mut().expect("coupled");
        let contacts = coupling.engine.step(fdt, &frozen, &impulses);
        let end: HashMap<BodyKey, BodyMotion> = coupling.engine.motion().into_iter().map(|m| (m.key, m)).collect();
        coupling.start = start;
        coupling.end = end;
        let impulses_in = self.engine_contacts_to_impulses(&contacts);
        let coupling = self.coupling.as_mut().expect("coupled");
        coupling.filter.ingest(&self.solver, t0, fdt, &impulses_in);

        self.frame_loads.resize(&self.solver);
        let splits_before = self.solver.events.len();
        for i in 0..n {
            self.set_driven_motion((i + 1) as f64 / n as f64);
            self.substep(h);
            let mut fl = std::mem::take(&mut self.frame_loads);
            fl.add_scaled(&self.loads, 1.0 / n as f64);
            self.frame_loads = fl;
        }
        self.frame += 1;
        if self.solver.events.len() != splits_before {
            self.topology_version += 1;
        }
        if let Some(u) = self.scene.sim.refine_utilization {
            self.refine_where_needed(u);
        }
        self.frame_loads.clear();

        // Island bodies that still exist go back to the engine with the world's state;
        // new fragments are created by the sync with theirs.
        let motion = self.world_motion();
        let back: Vec<BodyMotion> = frozen.iter().filter_map(|k| motion.get(k).copied()).collect();
        self.coupling.as_mut().expect("coupled").engine.set_motion(&back);
        self.sync_engine_bodies();
    }
}

/// Unit quaternion of an orthonormal rotation matrix.
fn rotation_of(m: &Mat3) -> Quat {
    let a = &m.m;
    let tr = m.trace();
    let q = if tr > 0.0 {
        let s = (tr + 1.0).sqrt() * 2.0;
        Quat { w: 0.25 * s, x: (a[2][1] - a[1][2]) / s, y: (a[0][2] - a[2][0]) / s, z: (a[1][0] - a[0][1]) / s }
    } else if a[0][0] > a[1][1] && a[0][0] > a[2][2] {
        let s = (1.0 + a[0][0] - a[1][1] - a[2][2]).sqrt() * 2.0;
        Quat { w: (a[2][1] - a[1][2]) / s, x: 0.25 * s, y: (a[0][1] + a[1][0]) / s, z: (a[0][2] + a[2][0]) / s }
    } else if a[1][1] > a[2][2] {
        let s = (1.0 + a[1][1] - a[0][0] - a[2][2]).sqrt() * 2.0;
        Quat { w: (a[0][2] - a[2][0]) / s, x: (a[0][1] + a[1][0]) / s, y: 0.25 * s, z: (a[1][2] + a[2][1]) / s }
    } else {
        let s = (1.0 + a[2][2] - a[0][0] - a[1][1]).sqrt() * 2.0;
        Quat { w: (a[1][0] - a[0][1]) / s, x: (a[0][2] + a[2][0]) / s, y: (a[1][2] + a[2][1]) / s, z: 0.25 * s }
    };
    q.normalized()
}
