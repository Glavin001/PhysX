//! Standalone reference world: runs a scene end to end without an external engine.
//!
//! The world owns the [`ReferenceSolver`] plus the minimum rigid-body machinery the
//! benchmarks need: rigid impactors (optionally crush-capped), a ground plane, penalty
//! contact between chunks of different clusters (debris landing on structures), scripted
//! loads (point forces, face pressures, blasts) and scripted events (member and support
//! removal). Everything advances on the stress substep, so impacts are resolved over
//! their physical contact duration.
//!
//! This is a test harness, not a rigid-body engine: there is no sleeping, no stacking
//! solver and no edge-edge contact. Production runs couple the stress solver to PhysX
//! through `api.rs`.

use crate::blast::FaceBlast;
use crate::contact::{OBox, SAMPLE_POINTS};
use crate::material::Material;
use crate::math::{Mat3, Pose, Quat, Vec3};
use crate::observation::{ChunkObservation, Observation, ProbeSeries};
use crate::scene::{
    ChunkSelector, EventDesc, ImpactorShape, LoadDesc, ProbeKind, Scene, SectionComponent, SolveMode, Support,
};
use crate::solver::{Activity, ChunkLoads, ReferenceSolver};
use crate::statics::StaticOptions;

/// Friction regularisation speed (m/s): below it friction scales linearly with slip speed.
const FRICTION_REGULARIZATION: f64 = 1e-3;
/// Largest viscous coefficient of one contact point, as a fraction of `m_red / dt`.
const MAX_POINT_VISCOSITY: f64 = 0.1;

#[derive(Clone, Debug)]
pub struct Impactor {
    pub name: String,
    pub shape: ImpactorShape,
    pub mass: f64,
    pub inertia: Mat3,
    pub pose: Pose,
    pub velocity: Vec3,
    pub angular_velocity: Vec3,
    pub material: Material,
    pub crush: Option<(f64, f64)>,
    pub crush_used: f64,
    pub crush_depth: f64,
}

impl Impactor {
    fn size(&self) -> f64 {
        match self.shape {
            ImpactorShape::Sphere { radius } => radius,
            ImpactorShape::Box { half_extents } => half_extents.iter().copied().fold(f64::INFINITY, f64::min),
        }
    }
    fn obox(&self) -> OBox {
        let h = match self.shape {
            ImpactorShape::Box { half_extents } => Vec3::from_array(half_extents),
            ImpactorShape::Sphere { radius } => Vec3::splat(radius),
        };
        OBox { center: self.pose.position, rotation: self.pose.rotation.to_mat3(), half: h }
    }
    pub fn kinetic_energy(&self) -> f64 {
        let r = self.pose.rotation.to_mat3();
        let iw = r * self.inertia * r.transpose();
        0.5 * self.mass * self.velocity.norm2() + 0.5 * self.angular_velocity.dot(iw * self.angular_velocity)
    }
}

/// Energy terms of the contacts (J).
#[derive(Clone, Copy, Debug, Default, serde::Serialize)]
pub struct ContactLedger {
    /// Penalty energy currently stored in contacts.
    pub stored: f64,
    /// Dashpot, friction and crush dissipation so far.
    pub dissipated: f64,
    pub crush: f64,
    /// Work done by chunk-pair contact forces on the chunks (diagnostic).
    pub pair_work: f64,
}

#[derive(Clone, Debug, Default)]
struct ProbeAcc {
    series: ProbeSeries,
    lo: f64,
    hi: f64,
    last: f64,
}

/// Cached blast loading of the exposed faces (rebuilt when topology changes).
#[derive(Clone, Debug)]
struct BlastCache {
    version: u64,
    faces: Vec<(usize, usize, usize, f64, FaceBlast)>,
}

pub struct World {
    pub scene: Scene,
    pub solver: ReferenceSolver,
    pub impactors: Vec<Impactor>,
    pub contact: ContactLedger,
    /// Work done by scripted loads (point forces, pressures, blasts, replacement loads excluded).
    pub frame: u64,
    loads: ChunkLoads,
    frame_loads: ChunkLoads,
    events_done: Vec<bool>,
    probes: Vec<ProbeAcc>,
    next_sample: f64,
    sample_interval: f64,
    initial_positions: Vec<Vec<Vec3>>,
    /// Exposed area per structure, chunk, face.
    exposure: Vec<Vec<[f64; 6]>>,
    exposure_version: u64,
    topology_version: u64,
    blast_caches: Vec<Option<BlastCache>>,
    contact_dt: f64,
    /// Contact force magnitude received by each chunk during the current substep.
    contact_hits: Vec<Vec<f64>>,
    /// Pre-existing overlap per sample point of chunk pairs in contact (NaN = point not
    /// in contact); dropped when the pair separates.
    pair_offsets: std::collections::HashMap<(usize, usize, usize, usize), [(f64, Vec3); 2 * SAMPLE_POINTS]>,
    pairs_seen: std::collections::HashSet<(usize, usize, usize, usize)>,
}

/// Effective contact modulus of two materials (scaled moduli).
fn contact_modulus(a: &Material, b: &Material, scale: f64) -> f64 {
    let ea = a.youngs_modulus * scale;
    let eb = b.youngs_modulus * scale;
    1.0 / ((1.0 - a.poisson_ratio.powi(2)) / ea + (1.0 - b.poisson_ratio.powi(2)) / eb)
}

fn damping_ratio(restitution: f64) -> f64 {
    let l = restitution.max(1e-6).ln();
    -l / (std::f64::consts::PI.powi(2) + l * l).sqrt()
}

impl World {
    pub fn new(scene: &Scene) -> World {
        let solver = ReferenceSolver::new(scene);
        let impactors = scene
            .impactors
            .iter()
            .map(|d| {
                let inertia = match d.shape {
                    ImpactorShape::Sphere { radius } => Mat3::IDENTITY * (0.4 * d.mass * radius * radius),
                    ImpactorShape::Box { half_extents } => {
                        let (a, b, c) = (2.0 * half_extents[0], 2.0 * half_extents[1], 2.0 * half_extents[2]);
                        Mat3::diag(Vec3::new(b * b + c * c, a * a + c * c, a * a + b * b) * (d.mass / 12.0))
                    }
                };
                Impactor {
                    name: d.name.clone(),
                    shape: d.shape.clone(),
                    mass: d.mass,
                    inertia,
                    pose: Pose::new(Vec3::from_array(d.position), Quat::from_wxyz(d.orientation)),
                    velocity: Vec3::from_array(d.velocity),
                    angular_velocity: Vec3::from_array(d.angular_velocity),
                    material: scene.material(&d.material).clone(),
                    crush: d.crush.map(|c| (c.max_force, c.energy)),
                    crush_used: 0.0,
                    crush_depth: 0.0,
                }
            })
            .collect();
        let loads = ChunkLoads::new(&solver);
        let initial_positions = solver
            .structures
            .iter()
            .map(|s| {
                let pose = Pose::new(s.initial_position, s.initial_rotation);
                s.chunks.iter().map(|c| pose.transform_point(c.center)).collect()
            })
            .collect();
        let contact_hits = solver.structures.iter().map(|s| vec![0.0; s.chunks.len()]).collect();
        let mut w = World {
            frame_loads: loads.clone(),
            loads,
            impactors,
            contact: ContactLedger::default(),
            frame: 0,
            events_done: vec![false; scene.events.len()],
            probes: vec![ProbeAcc::default(); scene.probes.len()],
            next_sample: 0.0,
            sample_interval: scene.sim.sample_interval.unwrap_or(scene.sim.frame_dt),
            initial_positions,
            exposure: Vec::new(),
            exposure_version: u64::MAX,
            topology_version: 0,
            blast_caches: vec![None; scene.loads.len()],
            contact_dt: f64::INFINITY,
            contact_hits,
            pair_offsets: Default::default(),
            pairs_seen: Default::default(),
            scene: scene.clone(),
            solver,
        };
        w.contact_dt = w.contact_stable_dt();
        w.prestress();
        w.record_probes(true);
        w
    }

    /// Settle supported structures under gravity and the scripted loads at t = 0.
    fn prestress(&mut self) {
        if !self.scene.sim.gravity_prestress {
            return;
        }
        self.loads.clear();
        self.apply_scripted_loads(0.0);
        let opts = StaticOptions::default();
        for ci in 0..self.solver.clusters.len() {
            if self.solver.clusters[ci].anchored && !self.solver.clusters[ci].bonds.is_empty() {
                let r = self.solver.equilibrate(ci, &self.loads, &opts);
                assert!(r.converged, "prestress did not converge (residual {:.3e})", r.residual);
                if self.scene.sim.solve_mode != SolveMode::Explicit {
                    self.solver.clusters[ci].activity = Activity::Settled;
                    self.solver.clusters[ci].settled_load_norm = self.cluster_load_norm(ci);
                }
            }
        }
    }

    // ------------------------------------------------------------------ geometry

    fn chunk_box(&self, s: usize, c: usize) -> OBox {
        let ch = &self.solver.structures[s].chunks[c];
        let st = &self.solver.chunks[s][c];
        let cl = &self.solver.clusters[st.cluster];
        // The hidden rotation turns the box too: contact torques do work on it, so the
        // geometry must follow it for the penalty force to stay conservative.
        let hidden = Quat::from_axis_angle(st.th, st.th.norm()).to_mat3();
        OBox { center: self.solver.chunk_position(s, c), rotation: cl.rotation() * hidden * ch.rotation, half: ch.half_extents }
    }

    fn chunk_size(&self, s: usize, c: usize) -> f64 {
        self.solver.structures[s].chunks[c].volume().cbrt()
    }

    fn chunk_material(&self, s: usize, c: usize) -> &Material {
        self.scene.material(&self.solver.structures[s].chunks[c].material)
    }

    /// Stable substep for the penalty contacts (stiffest contact on the lightest body).
    fn contact_stable_dt(&self) -> f64 {
        let scale = self.scene.sim.stiffness_scale;
        let stiffest = self.scene.materials.values().max_by(|a, b| a.youngs_modulus.total_cmp(&b.youngs_modulus));
        let Some(stiffest) = stiffest else { return f64::INFINITY };
        let mut w2: f64 = 0.0;
        for (s, st) in self.solver.structures.iter().enumerate() {
            for (c, ch) in st.chunks.iter().enumerate() {
                let k = contact_modulus(self.chunk_material(s, c), stiffest, scale) * self.chunk_size(s, c);
                // A face pair engages ~10 sample points of k/10 each (total k); a chunk
                // buried in rubble can touch on all six faces.
                w2 = w2.max(6.0 * k / ch.mass);
            }
        }
        for imp in &self.impactors {
            let k = contact_modulus(&imp.material, stiffest, scale) * imp.size();
            w2 = w2.max(k / imp.mass);
        }
        if w2 <= 0.0 {
            f64::INFINITY
        } else {
            2.0 / w2.sqrt() * self.scene.sim.courant_safety
        }
    }

    fn pair_friction(&self, a: &Material, b: &Material) -> f64 {
        self.scene.sim.contact_friction.unwrap_or(a.friction.min(b.friction))
    }

    /// The substep used for the next frame.
    pub fn substep_dt(&self) -> f64 {
        let mut dt = self.solver.stable_dt().min(self.contact_dt).min(self.scene.sim.frame_dt);
        if let Some(m) = self.scene.sim.max_substep {
            dt = dt.min(m);
        }
        let n = (self.scene.sim.frame_dt / dt).ceil().max(1.0);
        self.scene.sim.frame_dt / n
    }

    // ------------------------------------------------------------------ exposure

    fn refresh_exposure(&mut self) {
        if self.exposure_version == self.topology_version {
            return;
        }
        self.exposure = self
            .solver
            .structures
            .iter()
            .enumerate()
            .map(|(s, st)| {
                let mut e: Vec<[f64; 6]> =
                    st.chunks.iter().map(|c| std::array::from_fn(|f| c.faces[f].area)).collect();
                for b in self.solver.bonds[s].iter().filter(|b| b.alive) {
                    let sb = &st.bonds[b.source];
                    let (a, bb) = (b.geometry.a, b.geometry.b);
                    // Re-attached bonds keep their static faces' orientation.
                    let fa = face_towards(&st.chunks[a].faces, b.geometry.normal).unwrap_or(sb.face_a);
                    let fb = face_towards(&st.chunks[bb].faces, -b.geometry.normal).unwrap_or(sb.face_b);
                    e[a][fa] -= b.geometry.area;
                    e[bb][fb] -= b.geometry.area;
                }
                for (c, row) in e.iter_mut().enumerate() {
                    if !self.solver.chunks[s][c].active {
                        *row = [0.0; 6];
                    }
                    for v in row.iter_mut() {
                        *v = v.max(0.0);
                    }
                }
                e
            })
            .collect();
        self.exposure_version = self.topology_version;
    }

    /// World centre and outward normal of a chunk face.
    fn face_world(&self, s: usize, c: usize, f: usize) -> (Vec3, Vec3) {
        let ch = &self.solver.structures[s].chunks[c];
        let cl = &self.solver.clusters[self.solver.chunks[s][c].cluster];
        let face = ch.faces[f];
        (cl.pose.transform_point(ch.center + self.solver.chunks[s][c].u + face.offset), cl.pose.transform_vector(face.normal))
    }

    /// Distance from each exposed face to the nearest free edge of its reflecting surface.
    fn clearing_distances(&self, s: usize) -> std::collections::HashMap<(usize, usize), f64> {
        let st = &self.solver.structures[s];
        let exposed = |c: usize, f: usize| self.exposure[s][c][f] > 0.5 * st.chunks[c].faces[f].area;
        let mut neighbours: std::collections::HashMap<(usize, usize), Vec<((usize, usize), f64)>> = Default::default();
        for (c, ch) in st.chunks.iter().enumerate() {
            if !self.solver.chunks[s][c].active {
                continue;
            }
            for f in 0..6 {
                if !exposed(c, f) {
                    continue;
                }
                let n = ch.faces[f].normal;
                let mut list = Vec::new();
                for &bi in &self.solver.chunk_bonds[s][c] {
                    let b = &self.solver.bonds[s][bi];
                    if b.geometry.normal.dot(n).abs() > 0.1 {
                        continue;
                    }
                    let o = if b.geometry.a == c { b.geometry.b } else { b.geometry.a };
                    if let Some(of) = face_towards(&st.chunks[o].faces, n) {
                        if st.chunks[o].faces[of].normal.dot(n) > 0.99 && exposed(o, of) {
                            let d = (st.chunks[o].center + st.chunks[o].faces[of].offset - ch.center - ch.faces[f].offset).norm();
                            list.push(((o, of), d));
                        }
                    }
                }
                neighbours.insert((c, f), list);
            }
        }
        // Multi-source Dijkstra from edge faces (fewer than four in-plane neighbours).
        let mut dist: std::collections::HashMap<(usize, usize), f64> = Default::default();
        let mut heap = std::collections::BinaryHeap::new();
        for (k, list) in &neighbours {
            if list.len() < 4 {
                let half = 0.5 * st.chunks[k.0].faces[k.1].area.sqrt();
                dist.insert(*k, half);
                heap.push(std::cmp::Reverse((OrdF64(half), *k)));
            }
        }
        while let Some(std::cmp::Reverse((OrdF64(d), k))) = heap.pop() {
            if dist.get(&k).is_some_and(|&x| x < d) {
                continue;
            }
            for &(o, w) in &neighbours[&k] {
                let nd = d + w;
                if dist.get(&o).is_none_or(|&x| nd < x) {
                    dist.insert(o, nd);
                    heap.push(std::cmp::Reverse((OrdF64(nd), o)));
                }
            }
        }
        dist
    }

    fn rebuild_blast(&mut self, li: usize, position: Vec3, tnt: f64, time: f64) {
        self.refresh_exposure();
        let mut boxes = Vec::new();
        for (s, st) in self.solver.structures.iter().enumerate() {
            for c in 0..st.chunks.len() {
                if self.solver.chunks[s][c].active {
                    boxes.push((s, c, self.chunk_box(s, c)));
                }
            }
        }
        let mut faces = Vec::new();
        for s in 0..self.solver.structures.len() {
            let clearing = self.clearing_distances(s);
            for c in 0..self.solver.structures[s].chunks.len() {
                if !self.solver.chunks[s][c].active {
                    continue;
                }
                for f in 0..6 {
                    let area = self.exposure[s][c][f];
                    if area <= 0.0 {
                        continue;
                    }
                    let (x, n) = self.face_world(s, c, f);
                    let to_charge = position - x;
                    let r = to_charge.norm().max(1e-6);
                    let cos_theta = n.dot(to_charge) / r;
                    let start = x + n * 1e-6;
                    let shadowed = cos_theta > 0.0
                        && boxes.iter().any(|(bs, bc, b)| (*bs, *bc) != (s, c) && b.segment_hit(start, position).is_some());
                    let s_clear = clearing.get(&(c, f)).copied().unwrap_or(0.0);
                    faces.push((s, c, f, area, FaceBlast::new(tnt, time, r, cos_theta, shadowed, s_clear)));
                }
            }
        }
        self.blast_caches[li] = Some(BlastCache { version: self.topology_version, faces });
    }

    // ------------------------------------------------------------------ loads

    fn apply_scripted_loads(&mut self, t: f64) {
        for li in 0..self.scene.loads.len() {
            match self.scene.loads[li].clone() {
                LoadDesc::PointForce { body, chunk, direction, magnitude, point } => {
                    let s = self.solver.structure_index(&body).unwrap();
                    if !self.solver.chunks[s][chunk].active {
                        continue;
                    }
                    let f = Vec3::from_array(direction).normalized() * magnitude.eval(t);
                    let center = self.solver.chunk_position(s, chunk);
                    let at = match point {
                        Some(p) => {
                            let cl = &self.solver.clusters[self.solver.chunks[s][chunk].cluster];
                            cl.pose.transform_point(Vec3::from_array(p) + self.solver.chunks[s][chunk].u)
                        }
                        None => center,
                    };
                    self.loads.add_at(s, chunk, f, at, center);
                }
                LoadDesc::Pressure { body, chunks, face_normal, pressure } => {
                    let p = pressure.eval(t);
                    if p == 0.0 {
                        continue;
                    }
                    self.refresh_exposure();
                    let s = self.solver.structure_index(&body).unwrap();
                    let n = Vec3::from_array(face_normal).normalized();
                    let selected = chunks.select(&self.scene.bodies[s]);
                    for c in selected {
                        if !self.solver.chunks[s][c].active {
                            continue;
                        }
                        for f in 0..6 {
                            let area = self.exposure[s][c][f];
                            if area <= 0.0 || self.solver.structures[s].chunks[c].faces[f].normal.dot(n) < 0.99 {
                                continue;
                            }
                            let (x, nw) = self.face_world(s, c, f);
                            let center = self.solver.chunk_position(s, c);
                            self.loads.add_at(s, c, nw * (-p * area), x, center);
                        }
                    }
                }
                LoadDesc::Blast { position, tnt_mass, time } => {
                    if t < time {
                        continue;
                    }
                    let stale = self.blast_caches[li].as_ref().is_none_or(|b| b.version != self.topology_version);
                    if stale {
                        self.rebuild_blast(li, Vec3::from_array(position), tnt_mass, time);
                    }
                    let faces = self.blast_caches[li].as_ref().unwrap().faces.clone();
                    for (s, c, f, area, fb) in faces {
                        if !self.solver.chunks[s][c].active {
                            continue;
                        }
                        let p = fb.pressure(t);
                        if p == 0.0 {
                            continue;
                        }
                        let (x, nw) = self.face_world(s, c, f);
                        let center = self.solver.chunk_position(s, c);
                        self.loads.add_at(s, c, nw * (-p * area), x, center);
                    }
                }
            }
        }
    }

    /// Penalty contact force between a chunk and another body at one contact point.
    /// `normal` pushes the chunk; returns the force on the chunk.
    #[allow(clippy::too_many_arguments)]
    fn contact_force(
        &mut self,
        k: f64,
        m_red: f64,
        restitution: f64,
        friction: f64,
        depth: f64,
        normal: Vec3,
        rel_velocity: Vec3,
        dt: f64,
    ) -> Vec3 {
        // Explicit integration stays stable only while every viscous coefficient acting
        // on a chunk keeps `c dt / m` well below 2; a chunk may touch at ~20 points.
        let c_max = MAX_POINT_VISCOSITY * m_red / dt;
        let c = (2.0 * damping_ratio(restitution) * (k * m_red).sqrt()).min(c_max);
        let vn = rel_velocity.dot(normal);
        let fn_mag = (k * depth - c * vn).max(0.0);
        let vt = rel_velocity - normal * vn;
        let vt_mag = vt.norm();
        // Regularised Coulomb friction: viscous below the sliding speed, with the same cap.
        let ft_mag = (friction * fn_mag).min(c_max.min(friction * fn_mag / FRICTION_REGULARIZATION) * vt_mag);
        let ft = if vt_mag > 0.0 { -vt * (ft_mag / vt_mag) } else { Vec3::ZERO };
        self.contact.stored += 0.5 * k * depth * depth;
        // While the dashpot clamps the normal force to zero (fast separation), the
        // penalty spring unloads without doing work: that energy is dissipated too.
        let damping_power = if k * depth - c * vn > 0.0 { c * vn * vn } else { k * depth * vn.max(0.0) };
        self.contact.dissipated += (damping_power + ft.norm() * vt_mag) * dt;
        normal * fn_mag + ft
    }

    fn apply_contacts(&mut self, dt: f64) -> Vec<(Vec3, Vec3)> {
        let scale = self.scene.sim.stiffness_scale;
        let mut imp_loads = vec![(Vec3::ZERO, Vec3::ZERO); self.impactors.len()];
        self.contact.stored = 0.0;
        self.contact_hits.iter_mut().flatten().for_each(|h| *h = 0.0);
        let active: Vec<(usize, usize)> = (0..self.solver.structures.len())
            .flat_map(|s| (0..self.solver.structures[s].chunks.len()).map(move |c| (s, c)))
            .filter(|&(s, c)| self.solver.chunks[s][c].active)
            .collect();
        let boxes: Vec<OBox> = active.iter().map(|&(s, c)| self.chunk_box(s, c)).collect();

        // Impactors against chunks, with the crush cap applied to the impactor's total force.
        for ii in 0..self.impactors.len() {
            let imp = self.impactors[ii].clone();
            let ib = imp.obox();
            let reach = ib.bounding_radius();
            let mut contacts = Vec::new();
            for (k, &(s, c)) in active.iter().enumerate() {
                let b = &boxes[k];
                if (b.center - ib.center).norm() > reach + b.bounding_radius() {
                    continue;
                }
                let kc = contact_modulus(&imp.material, self.chunk_material(s, c), scale) * imp.size().min(self.chunk_size(s, c));
                match imp.shape {
                    ImpactorShape::Sphere { radius } => {
                        if let Some(cp) = b.sphere_contact(imp.pose.position, radius - imp.crush_depth) {
                            // Normal from chunk to impactor: the chunk is pushed along -normal.
                            contacts.push((s, c, kc, cp.point, -cp.normal, cp.depth));
                        }
                    }
                    ImpactorShape::Box { .. } => {
                        let shrunk = OBox { half: ib.half - Vec3::splat(imp.crush_depth).component_min(ib.half * 0.5), ..ib };
                        for cp in b.points_inside(&shrunk) {
                            contacts.push((s, c, kc / 10.0, cp.point, cp.normal, cp.depth));
                        }
                        for cp in shrunk.points_inside(b) {
                            contacts.push((s, c, kc / 10.0, cp.point, -cp.normal, cp.depth));
                        }
                    }
                }
            }
            if contacts.is_empty() {
                continue;
            }
            // Crush cap: limit the total elastic contact force; the excess crushes the impactor.
            let mut crush_factor = 1.0;
            if let Some((max_force, energy)) = imp.crush {
                let total: f64 = contacts.iter().map(|c| c.2 * c.5).sum();
                if imp.crush_used < energy && total > max_force {
                    let ksum: f64 = contacts.iter().map(|c| c.2).sum();
                    let extra = (total - max_force) / ksum;
                    self.impactors[ii].crush_depth += extra;
                    self.impactors[ii].crush_used += max_force * extra;
                    self.contact.crush += max_force * extra;
                    self.contact.dissipated += max_force * extra;
                    crush_factor = max_force / total;
                }
            }
            for (s, c, kc, point, normal, depth) in contacts {
                let m = self.solver.structures[s].chunks[c].mass;
                let m_red = m * imp.mass / (m + imp.mass);
                let v_chunk = self.solver.point_velocity(s, c, point);
                let v_imp = imp.velocity + imp.angular_velocity.cross(point - imp.pose.position);
                let f = self.contact_force(
                    kc,
                    m_red,
                    self.scene.sim.contact_restitution,
                    self.pair_friction(&imp.material, self.chunk_material(s, c)),
                    depth * crush_factor,
                    normal,
                    v_chunk - v_imp,
                    dt,
                );
                let center = self.solver.chunk_position(s, c);
                self.loads.add_at(s, c, f, point, center);
                self.contact_hits[s][c] += f.norm();
                imp_loads[ii].0 -= f;
                imp_loads[ii].1 -= (point - imp.pose.position).cross(f);
            }
        }

        // Ground.
        if let Some(g) = self.scene.ground.clone() {
            let gm = self.scene.material(&g.material).clone();
            for (k, &(s, c)) in active.iter().enumerate() {
                let b = &boxes[k];
                if b.center.z - b.bounding_radius() > g.height {
                    continue;
                }
                let cl = &self.solver.clusters[self.solver.chunks[s][c].cluster];
                if cl.anchored {
                    continue;
                }
                let kc = contact_modulus(&gm, self.chunk_material(s, c), scale) * self.chunk_size(s, c) / 5.0;
                let m = self.solver.structures[s].chunks[c].mass;
                for p in b.sample_points() {
                    let depth = g.height - p.z;
                    if depth <= 0.0 {
                        continue;
                    }
                    let v = self.solver.point_velocity(s, c, p);
                    let f = self.contact_force(kc, m, self.scene.sim.contact_restitution, self.scene.sim.contact_friction.unwrap_or(g.friction), depth, Vec3::Z, v, dt);
                    let center = self.solver.chunk_position(s, c);
                    self.loads.add_at(s, c, f, p, center);
                }
            }
            for ii in 0..self.impactors.len() {
                let imp = self.impactors[ii].clone();
                let kc = contact_modulus(&gm, &imp.material, scale) * imp.size();
                let pts: Vec<Vec3> = match imp.shape {
                    ImpactorShape::Sphere { radius } => vec![imp.pose.position - Vec3::Z * radius],
                    ImpactorShape::Box { .. } => imp.obox().sample_points().to_vec(),
                };
                let kp = kc / pts.len().min(5) as f64;
                for p in pts {
                    let depth = g.height - p.z;
                    if depth <= 0.0 {
                        continue;
                    }
                    let v = imp.velocity + imp.angular_velocity.cross(p - imp.pose.position);
                    let f = self.contact_force(kp, imp.mass, self.scene.sim.contact_restitution, self.scene.sim.contact_friction.unwrap_or(g.friction), depth, Vec3::Z, v, dt);
                    imp_loads[ii].0 += f;
                    imp_loads[ii].1 += (p - imp.pose.position).cross(f);
                }
            }
        }

        // Chunks of different clusters (debris on structures, fragments on fragments).
        let n_clusters = self.solver.clusters.len();
        self.pairs_seen.clear();
        if n_clusters > 1 {
            let mut cluster_boxes: Vec<(Vec3, Vec3)> = vec![(Vec3::splat(f64::INFINITY), Vec3::splat(f64::NEG_INFINITY)); n_clusters];
            for (k, &(s, c)) in active.iter().enumerate() {
                let ci = self.solver.chunks[s][c].cluster;
                let r = Vec3::splat(boxes[k].bounding_radius());
                cluster_boxes[ci].0 = cluster_boxes[ci].0.component_min(boxes[k].center - r);
                cluster_boxes[ci].1 = cluster_boxes[ci].1.component_max(boxes[k].center + r);
            }
            let mut by_cluster: Vec<Vec<usize>> = vec![Vec::new(); n_clusters];
            for (k, &(s, c)) in active.iter().enumerate() {
                by_cluster[self.solver.chunks[s][c].cluster].push(k);
            }
            for ca in 0..n_clusters {
                for cb in ca + 1..n_clusters {
                    let (a0, a1) = cluster_boxes[ca];
                    let (b0, b1) = cluster_boxes[cb];
                    if (0..3).any(|i| a1[i] < b0[i] || b1[i] < a0[i]) {
                        continue;
                    }
                    if self.solver.clusters[ca].anchored && self.solver.clusters[cb].anchored {
                        continue;
                    }
                    for &ka in &by_cluster[ca] {
                        for &kb in &by_cluster[cb] {
                            let (ba, bb) = (boxes[ka], boxes[kb]);
                            if (ba.center - bb.center).norm() > ba.bounding_radius() + bb.bounding_radius() {
                                continue;
                            }
                            let (sa, chunk_a) = active[ka];
                            let (sb, chunk_b) = active[kb];
                            self.chunk_pair_contact((sa, chunk_a, ba), (sb, chunk_b, bb), dt);
                        }
                    }
                }
            }
        }
        let seen = &self.pairs_seen;
        self.pair_offsets.retain(|k, _| seen.contains(k));
        imp_loads
    }

    fn chunk_pair_contact(&mut self, a: (usize, usize, OBox), b: (usize, usize, OBox), dt: f64) {
        let scale = self.scene.sim.stiffness_scale;
        let (sa, ca, ba) = a;
        let (sb, cb, bb) = b;
        let k_pair = contact_modulus(self.chunk_material(sa, ca), self.chunk_material(sb, cb), scale)
            * self.chunk_size(sa, ca).min(self.chunk_size(sb, cb));
        let (ma, mb) = (self.solver.structures[sa].chunks[ca].mass, self.solver.structures[sb].chunks[cb].mass);
        let m_red = ma * mb / (ma + mb);
        let mu = self.pair_friction(self.chunk_material(sa, ca), self.chunk_material(sb, cb));
        // Points of a inside b push a out along b's face normal, and vice versa.
        let mut pairs: Vec<(usize, Vec3, Vec3, f64)> =
            ba.points_inside(&bb).into_iter().map(|p| (p.index, p.point, p.normal, p.depth)).collect();
        pairs.extend(bb.points_inside(&ba).into_iter().map(|p| (SAMPLE_POINTS + p.index, p.point, -p.normal, p.depth)));
        if pairs.is_empty() {
            return;
        }
        let key = (sa, ca, sb, cb);
        self.pairs_seen.insert(key);
        let entry = self.pair_offsets.entry(key).or_insert([(f64::NAN, Vec3::ZERO); 2 * SAMPLE_POINTS]);
        let mut inside = [false; 2 * SAMPLE_POINTS];
        let mut effective = Vec::with_capacity(pairs.len());
        for &(i, p, n, depth) in &pairs {
            inside[i] = true;
            // A new contact (or the same point now pushed through a different face): a
            // point born deeper than one substep of approach could carry it was already
            // overlapping (residual deformation of chunks that were one cluster). Keep
            // that overlap as an offset instead of firing it as energy.
            if entry[i].0.is_nan() || entry[i].1.dot(n) < 0.99 {
                let va = self.solver.point_velocity(sa, ca, p);
                let vb = self.solver.point_velocity(sb, cb, p);
                let reach = 2.0 * (va - vb).dot(n).abs() * dt + 1e-9;
                entry[i] = (if depth > reach { depth } else { 0.0 }, n);
            }
            // The offset only ratchets down as the overlap relaxes.
            entry[i].0 = entry[i].0.min(depth);
            effective.push((p, n, depth - entry[i].0));
        }
        for (i, e) in entry.iter_mut().enumerate() {
            if !inside[i] {
                e.0 = f64::NAN;
            }
        }
        // A face pair engages ~10 points; deeper overlaps engage more. Never let the
        // pair exceed its face-pair stiffness (the stable-timestep assumption).
        let engaged = effective.iter().filter(|e| e.2 > 0.0).count();
        let k = k_pair / (engaged.max(10) as f64);
        for (p, n, depth) in effective {
            if depth <= 0.0 {
                continue;
            }
            let va = self.solver.point_velocity(sa, ca, p);
            let vb = self.solver.point_velocity(sb, cb, p);
            let f = self.contact_force(k, m_red, self.scene.sim.contact_restitution, mu, depth, n, va - vb, dt);
            self.contact.pair_work += f.dot(va - vb) * dt;
            let xa = self.solver.chunk_position(sa, ca);
            let xb = self.solver.chunk_position(sb, cb);
            self.loads.add_at(sa, ca, f, p, xa);
            self.loads.add_at(sb, cb, -f, p, xb);
            self.contact_hits[sa][ca] += f.norm();
            self.contact_hits[sb][cb] += f.norm();
        }
    }

    // ------------------------------------------------------------------ events

    fn process_events(&mut self, t: f64) {
        for ei in 0..self.scene.events.len() {
            if self.events_done[ei] {
                continue;
            }
            match self.scene.events[ei].clone() {
                EventDesc::RemoveChunks { time, duration, body, chunks } => {
                    if t + 1e-12 < time {
                        continue;
                    }
                    let s = self.solver.structure_index(&body).unwrap();
                    let sel = select_with_descendants(&chunks, &self.scene, s);
                    self.solver.remove_chunks(s, &sel, duration);
                }
                EventDesc::RemoveSupports { time, duration, body, chunks } => {
                    if t + 1e-12 < time {
                        continue;
                    }
                    let s = self.solver.structure_index(&body).unwrap();
                    let sel = chunks.select(&self.scene.bodies[s]);
                    self.solver.remove_supports(s, &sel, duration);
                }
            }
            self.events_done[ei] = true;
            self.topology_version += 1;
            for c in self.solver.clusters.iter_mut() {
                c.activity = Activity::Active;
                c.active_timer = self.solver.config.active_time;
            }
        }
    }

    // ------------------------------------------------------------------ stepping

    fn cluster_load_norm(&self, ci: usize) -> f64 {
        let cl = &self.solver.clusters[ci];
        cl.chunks.iter().map(|&c| self.loads.force[cl.structure][c].norm()).sum()
    }

    fn cluster_weight(&self, ci: usize) -> f64 {
        self.solver.clusters[ci].mass * self.solver.config.gravity.norm()
    }

    /// Advance one frame (`sim.frame_dt`).
    pub fn step_frame(&mut self) {
        let dt = self.substep_dt();
        let n = (self.scene.sim.frame_dt / dt).round().max(1.0) as usize;
        self.frame_loads.resize(&self.solver);
        let splits_before = self.solver.events.len();
        for _ in 0..n {
            self.substep(dt);
            let mut fl = std::mem::take(&mut self.frame_loads);
            for s in 0..fl.force.len() {
                for c in 0..fl.force[s].len() {
                    fl.force[s][c] += self.loads.force[s][c] * (1.0 / n as f64);
                    fl.torque[s][c] += self.loads.torque[s][c] * (1.0 / n as f64);
                }
            }
            self.frame_loads = fl;
        }
        self.frame += 1;
        if self.solver.events.len() != splits_before {
            self.topology_version += 1;
        }
        match self.scene.sim.solve_mode {
            SolveMode::Explicit => {}
            SolveMode::QuasiStatic => {
                let opts = StaticOptions { cascade: true, ..Default::default() };
                let fl = self.frame_loads.clone();
                self.solver.solve_static_all(&fl, &opts, self.scene.sim.frame_dt);
                self.topology_version += 1;
            }
            SolveMode::Adaptive => self.settle_quiet_clusters(),
        }
        if let Some(u) = self.scene.sim.refine_utilization {
            self.refine_where_needed(u);
        }
        self.frame_loads.clear();
    }

    /// Adaptive mode: clusters whose last dynamic load is older than `active_time` and
    /// whose deformation has calmed down switch to quasi-static equilibrium.
    fn settle_quiet_clusters(&mut self) {
        let fdt = self.scene.sim.frame_dt;
        for ci in 0..self.solver.clusters.len() {
            if self.solver.clusters[ci].activity != Activity::Active {
                continue;
            }
            self.solver.clusters[ci].active_timer -= fdt;
            if self.solver.clusters[ci].active_timer > 0.0 || self.solver.clusters[ci].bonds.is_empty() {
                continue;
            }
            let s = self.solver.clusters[ci].structure;
            let ke: f64 = self.solver.clusters[ci]
                .chunks
                .iter()
                .map(|&c| {
                    let ch = &self.solver.structures[s].chunks[c];
                    let st = &self.solver.chunks[s][c];
                    0.5 * ch.mass * st.v.norm2() + 0.5 * st.w.dot(ch.inertia * st.w)
                })
                .sum();
            let stored: f64 = self.solver.clusters[ci].bonds.iter().map(|&b| self.solver.bonds[s][b].stored).sum();
            if ke > 1e-3 * stored.max(1e-9) {
                continue;
            }
            let opts = StaticOptions { cascade: true, max_cascade: 1, ..Default::default() };
            self.solver.equilibrate(ci, &self.loads, &opts);
            self.solver.clusters[ci].activity = Activity::Settled;
            self.solver.clusters[ci].settled_load_norm = self.cluster_load_norm(ci);
        }
    }

    /// Wake settled clusters whose external loads changed (impact, blast, debris).
    fn wake_loaded_clusters(&mut self) {
        for ci in 0..self.solver.clusters.len() {
            if self.solver.clusters[ci].activity != Activity::Settled {
                continue;
            }
            let now = self.cluster_load_norm(ci);
            let before = self.solver.clusters[ci].settled_load_norm;
            if (now - before).abs() > self.solver.config.wake_threshold * (self.cluster_weight(ci) + before) {
                self.solver.clusters[ci].activity = Activity::Active;
                self.solver.clusters[ci].active_timer = self.solver.config.active_time;
            }
        }
    }

    fn substep(&mut self, dt: f64) {
        let t = self.solver.time + dt;
        self.process_events(self.solver.time);
        self.loads.resize(&self.solver);
        self.loads.clear();
        self.apply_scripted_loads(self.solver.time);
        let imp_loads = self.apply_contacts(dt);
        if self.scene.sim.solve_mode == SolveMode::Adaptive {
            self.wake_loaded_clusters();
        }
        let n_events = self.solver.events.len();
        self.solver.substep(dt, &self.loads);
        if self.solver.events.len() != n_events {
            self.topology_version += 1;
        }
        let g = self.solver.config.gravity;
        for (imp, (f, tq)) in self.impactors.iter_mut().zip(imp_loads) {
            imp.velocity += (f / imp.mass + g) * dt;
            let r = imp.pose.rotation.to_mat3();
            let l = r * imp.inertia * r.transpose() * imp.angular_velocity + tq * dt;
            let w_mid = (r * imp.inertia * r.transpose()).inverse().unwrap() * l;
            imp.pose.position += imp.velocity * dt;
            imp.pose.rotation = imp.pose.rotation.integrate(w_mid, dt);
            let r = imp.pose.rotation.to_mat3();
            imp.angular_velocity = (r * imp.inertia * r.transpose()).inverse().unwrap() * l;
        }
        debug_assert!((self.solver.time - t).abs() < 1e-9);
        self.record_probes(false);
    }

    /// Multi-level pre-fracture: refine coarse chunks near failure or under impact.
    fn refine_where_needed(&mut self, threshold: f64) {
        for s in 0..self.solver.structures.len() {
            let candidates: Vec<usize> = (0..self.solver.structures[s].chunks.len())
                .filter(|&c| {
                    self.solver.chunks[s][c].active
                        && !self.solver.structures[s].chunks[c].children.is_empty()
                        && (self.contact_hits[s][c] > 0.0
                            || self.solver.chunk_bonds[s][c]
                                .iter()
                                .any(|&b| self.solver.bonds[s][b].joint.utilization >= threshold))
                })
                .collect();
            for c in candidates {
                self.solver.refine_chunk(s, c);
                self.topology_version += 1;
            }
        }
    }

    pub fn run(&mut self) -> Observation {
        let frames = (self.scene.sim.duration / self.scene.sim.frame_dt).round() as u64;
        while self.frame < frames {
            self.step_frame();
        }
        self.observation()
    }

    // ------------------------------------------------------------------ probes

    fn probe_value(&self, kind: &ProbeKind) -> f64 {
        match kind {
            ProbeKind::ChunkDisplacement { body, chunk, axis } => {
                let s = self.solver.structure_index(body).unwrap();
                match self.representative(s, *chunk) {
                    Some(c) => {
                        let x = self.solver.chunk_position(s, c)
                            + self.offset_from_representative(s, *chunk, c);
                        (x - self.initial_positions[s][*chunk]).dot(Vec3::from_array(*axis).normalized())
                    }
                    None => f64::NAN,
                }
            }
            ProbeKind::ChunkVelocity { body, chunk, axis } => {
                let s = self.solver.structure_index(body).unwrap();
                match self.representative(s, *chunk) {
                    Some(c) => self.solver.chunk_velocity(s, c).0.dot(Vec3::from_array(*axis).normalized()),
                    None => f64::NAN,
                }
            }
            ProbeKind::SectionForce { body, point, normal, region, component } => {
                let s = self.solver.structure_index(body).unwrap();
                let p = Vec3::from_array(*point);
                let n = Vec3::from_array(*normal).normalized();
                let st = &self.solver.structures[s];
                let mut f = Vec3::ZERO;
                let mut m = Vec3::ZERO;
                for b in self.solver.bonds[s].iter().filter(|b| b.alive) {
                    let g = &b.geometry;
                    if let Some(r) = region {
                        if !r.contains(g.centroid) {
                            continue;
                        }
                    }
                    let side_a = (st.chunks[g.a].center - p).dot(n);
                    let side_b = (st.chunks[g.b].center - p).dot(n);
                    if side_a * side_b >= 0.0 {
                        continue;
                    }
                    let (fa, ma, fb, mb) = g.chunk_loads(&b.force);
                    let (fc, mc, xc) =
                        if side_a > 0.0 { (fa, ma, st.chunks[g.a].center) } else { (fb, mb, st.chunks[g.b].center) };
                    f += fc;
                    m += mc + (xc - p).cross(fc);
                }
                match component {
                    SectionComponent::Normal => -f.dot(n),
                    SectionComponent::Force(a) => f.dot(Vec3::from_array(*a).normalized()),
                    SectionComponent::Moment(a) => m.dot(Vec3::from_array(*a).normalized()),
                }
            }
            ProbeKind::Reaction { body, chunks, axis } => {
                let s = self.solver.structure_index(body).unwrap();
                let a = Vec3::from_array(*axis).normalized();
                chunks
                    .select(&self.scene.bodies[s])
                    .into_iter()
                    .map(|c| self.solver.reaction_world(s, c).0.dot(a))
                    .sum()
            }
            ProbeKind::ImpactorVelocity { impactor, axis } => {
                let imp = self.impactors.iter().find(|i| &i.name == impactor).unwrap();
                imp.velocity.dot(Vec3::from_array(*axis).normalized())
            }
            ProbeKind::ImpactorPosition { impactor, axis } => {
                let imp = self.impactors.iter().find(|i| &i.name == impactor).unwrap();
                imp.pose.position.dot(Vec3::from_array(*axis).normalized())
            }
        }
    }

    fn record_probes(&mut self, force_sample: bool) {
        let t = self.solver.time;
        let values: Vec<f64> = self.scene.probes.iter().map(|p| self.probe_value(&p.kind)).collect();
        let sample = force_sample || t + 1e-12 >= self.next_sample;
        for (acc, v) in self.probes.iter_mut().zip(values) {
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
            acc.last = v;
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

    // ------------------------------------------------------------------ observation

    /// The active chunk that represents scene chunk `c` (itself, or its active ancestor).
    fn representative(&self, s: usize, c: usize) -> Option<usize> {
        let mut x = c;
        loop {
            if self.solver.chunks[s][x].active {
                return Some(x);
            }
            if self.solver.chunks[s][x].removed {
                return None;
            }
            x = self.solver.structures[s].chunks[x].parent?;
        }
    }

    fn offset_from_representative(&self, s: usize, c: usize, rep: usize) -> Vec3 {
        if c == rep {
            return Vec3::ZERO;
        }
        let st = &self.solver.structures[s];
        let cl = &self.solver.clusters[self.solver.chunks[s][rep].cluster];
        cl.pose.transform_vector(st.chunks[c].center - st.chunks[rep].center)
    }

    /// Active chunks represented by scene chunk `c` (itself, or its active descendants).
    fn descendants(&self, s: usize, c: usize, out: &mut Vec<usize>) {
        if self.solver.chunks[s][c].active {
            out.push(c);
            return;
        }
        for &k in &self.solver.structures[s].chunks[c].children {
            self.descendants(s, k, out);
        }
    }

    pub fn observation(&self) -> Observation {
        let mut obs = Observation::new(&self.scene.name, "stress-ref", env!("CARGO_PKG_VERSION"), self.scene.sim.seed);
        obs.end_time = self.solver.time;
        for (p, acc) in self.scene.probes.iter().zip(&self.probes) {
            obs.probes.insert(p.name.clone(), acc.series.clone());
        }
        let mut collapse = false;
        let mut fragments = 0usize;
        for (s, st) in self.solver.structures.iter().enumerate() {
            let has_supports = self.scene.bodies[s].chunks.iter().any(|c| c.support != Support::None);
            // Main piece: anchored clusters, else the heaviest cluster.
            let clusters: Vec<usize> = (0..self.solver.clusters.len()).filter(|&i| self.solver.clusters[i].structure == s).collect();
            fragments += clusters.len();
            let heaviest = clusters
                .iter()
                .copied()
                .max_by(|&a, &b| self.solver.clusters[a].mass.total_cmp(&self.solver.clusters[b].mass));
            let is_main = |ci: usize| {
                if has_supports {
                    self.solver.clusters[ci].anchored
                } else {
                    Some(ci) == heaviest
                }
            };
            let mut list = Vec::with_capacity(st.chunks.len());
            for c in 0..st.chunks.len() {
                let mut reps = Vec::new();
                if self.solver.chunks[s][c].removed && !self.solver.chunks[s][c].active {
                    list.push(ChunkObservation { removed: true, fragment: -1, ..Default::default() });
                    continue;
                }
                match self.representative(s, c) {
                    Some(r) => reps.push(r),
                    None => self.descendants(s, c, &mut reps),
                }
                if reps.is_empty() {
                    list.push(ChunkObservation { removed: true, fragment: -1, ..Default::default() });
                    continue;
                }
                let mut mass = 0.0;
                let mut detached_mass = 0.0;
                let mut v = Vec3::ZERO;
                let mut x = Vec3::ZERO;
                for &r in &reps {
                    let m = st.chunks[r].mass;
                    let ci = self.solver.chunks[s][r].cluster;
                    mass += m;
                    if !is_main(ci) {
                        detached_mass += m;
                    }
                    v += self.solver.chunk_velocity(s, r).0 * m;
                    x += (self.solver.chunk_position(s, r) + self.offset_from_representative(s, c, r)) * m;
                }
                let x = if reps.len() == 1 { x / mass } else { x / mass };
                let detached = detached_mass > 0.5 * mass;
                if detached && has_supports {
                    collapse = true;
                }
                let frag = self.solver.clusters[self.solver.chunks[s][reps[0]].cluster].id as i64;
                list.push(ChunkObservation {
                    detached,
                    removed: false,
                    fragment: frag,
                    velocity: (v / mass).to_array(),
                    displacement: (x - self.initial_positions[s][c]).to_array(),
                });
            }
            obs.bodies.insert(st.name.clone(), list);
        }
        let broken = self.solver.broken_bond_count();
        obs.flags.insert("any_bond_broken".into(), broken > 0);
        // Damage onset anywhere (the criterion an elastic oracle can evaluate).
        let first_crack = self.solver.events.iter().find_map(|e| match e {
            crate::solver::SolverEvent::Cracked { time, .. } => Some(*time),
            _ => None,
        });
        // With fracture disabled, "cracked" means a failure index reached 1 (as an
        // elastic oracle evaluates it).
        let cracked = first_crack.is_some() || (!self.scene.sim.fracture && self.solver.max_utilization >= 1.0);
        obs.flags.insert("any_bond_cracked".into(), cracked);
        obs.values.insert("max_failure_index".into(), self.solver.max_utilization);
        if let Some(t) = first_crack {
            obs.values.insert("first_crack_time".into(), t);
        }
        obs.flags.insert("collapse".into(), collapse);
        obs.values.insert("broken_bonds".into(), broken as f64);
        obs.values.insert("fragments".into(), fragments as f64);
        obs.values.insert("substeps".into(), self.solver.substeps as f64);
        obs.values.insert("bond_dissipation".into(), self.solver.energy.bond_dissipation);
        obs.values.insert("damping_dissipation".into(), self.solver.energy.damping_dissipation);
        obs.values.insert("contact_dissipation".into(), self.contact.dissipated);
        obs.values.insert("softening_overshoot".into(), self.solver.energy.softening_overshoot);
        obs.values.insert("split_release".into(), self.solver.energy.split_release);
        obs.values.insert("crush_energy".into(), self.contact.crush);
        obs
    }

    // ------------------------------------------------------------------ energy

    /// Total mechanical energy: kinetic (chunks and impactors) + bond elastic + contact
    /// penalty + gravitational potential (chunks and impactors).
    pub fn mechanical_energy(&self) -> f64 {
        let g = self.solver.config.gravity;
        let imp: f64 = self.impactors.iter().map(|i| i.kinetic_energy() - i.mass * g.dot(i.pose.position)).sum();
        self.solver.kinetic_energy() + self.solver.elastic_energy() + self.contact.stored + self.solver.gravity_potential() + imp
    }

    /// Everything dissipated so far.
    pub fn dissipated_energy(&self) -> f64 {
        let e = &self.solver.energy;
        e.bond_dissipation + e.damping_dissipation + e.softening_overshoot + e.split_release + self.contact.dissipated
    }
}

/// Smallest stiffness scale for which a stress wave still crosses every structure of
/// the scene (its largest extent, at the slowest bar wave speed) within `frames` frames.
/// The real-time compromise: lower E as far as this allows, keep strengths physical.
pub fn min_stiffness_scale(scene: &Scene, frames: f64) -> f64 {
    let mut scale: f64 = 0.0;
    for b in &scene.bodies {
        let (mut lo, mut hi) = (Vec3::splat(f64::INFINITY), Vec3::splat(f64::NEG_INFINITY));
        let mut c_min = f64::INFINITY;
        for c in &b.chunks {
            let x = Vec3::from_array(c.center);
            let h = Vec3::from_array(c.half_extents);
            lo = lo.component_min(x - h);
            hi = hi.component_max(x + h);
            c_min = c_min.min(scene.material(&c.material).bar_wave_speed());
        }
        let extent = (hi - lo).max_elem();
        // Required speed extent / (frames * frame_dt); speed scales with sqrt(scale).
        let needed = extent / (frames * scene.sim.frame_dt);
        scale = scale.max((needed / c_min).powi(2));
    }
    scale.min(1.0)
}

/// The face of a box whose outward normal is within ~8 degrees of `dir`.
fn face_towards(faces: &[crate::structure::Face; 6], dir: Vec3) -> Option<usize> {
    let best = (0..6).max_by(|&i, &j| faces[i].normal.dot(dir).total_cmp(&faces[j].normal.dot(dir)))?;
    (faces[best].normal.dot(dir) > 0.99).then_some(best)
}

fn select_with_descendants(sel: &ChunkSelector, scene: &Scene, s: usize) -> Vec<usize> {
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

#[derive(Clone, Copy, Debug, PartialEq, PartialOrd)]
struct OrdF64(f64);
impl Eq for OrdF64 {}
impl Ord for OrdF64 {
    fn cmp(&self, o: &Self) -> std::cmp::Ordering {
        self.0.total_cmp(&o.0)
    }
}
