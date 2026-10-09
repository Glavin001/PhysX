//! The bond's constitutive law: strength, damage and the cracked-joint contact.
//!
//! **Failure surface** (evaluated on the *effective*, i.e. undamaged, bond forces):
//! * tension cutoff: extreme-fibre stress `N/A + |M1|/S1 + |M2|/S2 <= f_t`;
//! * Mohr-Coulomb shear: `|V|/A + |T|/W <= min(c + mu sigma_c, cap)`, so shear strength
//!   rises with compression `sigma_c = max(0, -N/A)`;
//! * crushing: `-N/A + |M1|/S1 + |M2|/S2 <= f_c`;
//! * buckling cap: `-N <= pi^2 E I_min / L_b^2` for bonds of slender members.
//!
//! Each strength is multiplied by the bond's Weibull factor, the dynamic increase
//! factor of the current strain rate and the residual-strength factor of static
//! fatigue (delayed failure under sustained load, see [`StaticFatigue`]).
//!
//! **Damage** (two scalars): `D` for the tension/shear family, `Dc` for crushing. Each
//! is a function of the history maximum `kappa` of its failure index. With `U0` the
//! energy the bond stores at the onset of failure along the current deformation, the
//! ductility `r = G_f A / U0` fixes the softening so that the energy dissipated by a
//! bond equals `G_f A` whatever the chunk size (resolution independence):
//! * brittle: linear softening, `D = r (kappa - 1) / (kappa (r - 1))`; `r <= 1` snaps
//!   (and every bond snaps with [`Features::softening`] off);
//! * ductile: plateau `D = 1 - 1/kappa` until `kappa = (r + 1)/2`, then snaps.
//!
//! `D` degrades shear, bending, torsion and tensile axial stiffness; compression is
//! degraded only by `Dc` (crack closure). The degraded share `D` of the joint is
//! replaced by a unilateral frictional contact: a no-tension grid of normal springs
//! over the patch (so a cracked joint rocks about its compressed edge and develops
//! arching thrust when restrained), Coulomb sliding (`|V| <= mu N_c`) and torsional
//! friction. A bond
//! with `D = 1` therefore still transmits compression and friction while its chunks
//! remain in one cluster, but it no longer connects them.
//!
//! Rebar acts in parallel: an elastic-plastic axial tie (and dowel) that keeps a
//! cracked bond connected until its plastic work reaches its rupture energy.
//!
//! Dissipation is accounted exactly: a damage increment releases
//! `(psi_elastic - psi_contact) dD`; plastic slips release `force x |slip increment|`.

use serde::{Deserialize, Serialize};

use crate::bond::{BondGeometry, BondStiffness, Local6, Mat6};
use crate::material::{BondKind, DifParams, Material, StaticFatigue};
use crate::scene::Features;
use crate::math::Vec3;

/// The failure mode that governed a damage increment.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum FailureMode {
    Tension,
    Shear,
    Compression,
    Buckling,
}

/// Strength parameters of one bond, resolved from its material and geometry.
#[derive(Clone, Debug)]
pub struct JointStrength {
    pub tensile: f64,
    pub compressive: f64,
    pub cohesion: f64,
    pub friction: f64,
    pub shear_cap: f64,
    pub g_tension: f64,
    pub g_shear: f64,
    pub g_compression: f64,
    pub kind: BondKind,
    /// Euler load of the member (N), if the bond belongs to a slender member.
    pub buckling_load: Option<f64>,
    pub dif: Option<DifParams>,
    pub static_fatigue: Option<StaticFatigue>,
    /// Fracture-energy softening (else bonds snap at their strength).
    pub softening: bool,
    /// The cracked share of the joint acts as a no-tension frictional contact.
    pub crack_contact: bool,
    /// Physical Young's modulus, for converting stress rate to strain rate.
    pub youngs_modulus: f64,
    /// Smoothing time of the strain-rate estimate.
    pub rate_filter_time: f64,
}

impl JointStrength {
    pub fn new(m: &Material, g: &BondGeometry, buckling_length: Option<f64>, stiffness_scale: f64, features: &Features) -> JointStrength {
        let i_min = g.i_t1.min(g.i_t2);
        let wave_speed = (m.youngs_modulus * stiffness_scale / m.density).sqrt();
        JointStrength {
            tensile: m.tensile_strength,
            compressive: m.compressive_strength,
            cohesion: m.cohesion,
            friction: m.friction,
            shear_cap: m.shear_cap.unwrap_or(f64::INFINITY),
            g_tension: m.fracture_energy.tension,
            g_shear: m.fracture_energy.shear,
            g_compression: m.fracture_energy.compression,
            kind: m.kind,
            buckling_load: buckling_length
                .filter(|l| features.buckling && *l > 0.0)
                .map(|l| std::f64::consts::PI.powi(2) * m.youngs_modulus * i_min / (l * l)),
            dif: m.dif.filter(|_| features.rate_effects),
            static_fatigue: m.static_fatigue.filter(|_| features.static_fatigue),
            softening: features.softening,
            crack_contact: features.crack_contact,
            youngs_modulus: m.youngs_modulus,
            rate_filter_time: 2.0 * g.length / wave_speed,
        }
    }
}

/// Rebar crossing a bond.
#[derive(Clone, Copy, Debug)]
pub struct RebarParams {
    pub k_axial: f64,
    pub k_dowel: f64,
    pub yield_force: f64,
    pub dowel_capacity: f64,
    pub rupture_work: f64,
}

impl RebarParams {
    pub fn new(area: f64, steel: &Material, length: f64, stiffness_scale: f64) -> RebarParams {
        let e = steel.youngs_modulus * stiffness_scale;
        let yield_force = steel.tensile_strength * area;
        RebarParams {
            k_axial: e * area / length,
            k_dowel: steel.shear_modulus() * stiffness_scale * area / length,
            yield_force,
            dowel_capacity: 0.5 * yield_force,
            rupture_work: steel.fracture_energy.tension * area,
        }
    }
}

/// History variables of one bond.
#[derive(Clone, Debug, Default, PartialEq, Serialize, Deserialize)]
pub struct JointState {
    /// Tension/shear damage `D`.
    pub damage: f64,
    /// Crushing damage `Dc`.
    pub crush: f64,
    pub kappa: f64,
    pub kappa_c: f64,
    pub ductility: f64,
    pub ductility_c: f64,
    /// Static fatigue: fraction of the sustained-load life consumed (`omega`).
    pub fatigue: f64,
    /// Plastic offsets of the contact part: `lin.x, lin.y` sliding, `ang.x, ang.y`
    /// rocking, `ang.z` twist (`lin.z` unused).
    pub plastic: Local6Ser,
    pub rebar_plastic: f64,
    pub rebar_slip: [f64; 2],
    pub rebar_work: f64,
    pub rebar_broken: bool,
    /// Smoothed equivalent strain rate (1/s) and the stress it is differentiated from.
    pub strain_rate: f64,
    pub governing_stress: f64,
    pub mode: Option<FailureMode>,
    /// Energy dissipated by this bond so far (J): damage, friction, rebar.
    pub dissipated: f64,
    /// Largest effective failure index at the last evaluation (1 = at strength).
    pub utilization: f64,
}

/// Serializable mirror of [`Local6`] (kept separate so the math types stay serde-free).
#[derive(Clone, Copy, Debug, Default, PartialEq, Serialize, Deserialize)]
pub struct Local6Ser {
    pub lin: [f64; 3],
    pub ang: [f64; 3],
}

impl From<Local6Ser> for Local6 {
    fn from(s: Local6Ser) -> Local6 {
        Local6 { lin: Vec3::from_array(s.lin), ang: Vec3::from_array(s.ang) }
    }
}
impl From<Local6> for Local6Ser {
    fn from(l: Local6) -> Local6Ser {
        Local6Ser { lin: l.lin.to_array(), ang: l.ang.to_array() }
    }
}

impl JointState {
    pub fn new() -> JointState {
        JointState { kappa: 0.0, kappa_c: 0.0, ductility: f64::INFINITY, ductility_c: f64::INFINITY, ..Default::default() }
    }

    /// Whether the bond still holds its chunks together (for cluster connectivity).
    pub fn connected(&self, has_rebar: bool) -> bool {
        self.damage < 1.0 || (has_rebar && !self.rebar_broken)
    }

    pub fn is_damaged(&self) -> bool {
        self.damage > 0.0 || self.crush > 0.0
    }
}

/// Stress measures of a generalised bond force.
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct StressMeasures {
    /// Max extreme-fibre tension (Pa, may be negative = no tension anywhere).
    pub tension: f64,
    /// Max shear stress (Pa).
    pub shear: f64,
    /// Average compressive normal stress (Pa, >= 0).
    pub normal_compression: f64,
    /// Max extreme-fibre compression (Pa).
    pub compression: f64,
    /// Axial compressive force (N, >= 0).
    pub compressive_force: f64,
}

pub fn stress_measures(g: &BondGeometry, q: &Local6) -> StressMeasures {
    let axial = q.lin.z / g.area;
    let bending = q.ang.x.abs() / g.s_t1 + q.ang.y.abs() / g.s_t2;
    let shear = (q.lin.x.hypot(q.lin.y)) / g.area + q.ang.z.abs() / g.torsion_modulus;
    StressMeasures {
        tension: axial + bending,
        shear,
        normal_compression: (-axial).max(0.0),
        compression: -axial + bending,
        compressive_force: (-q.lin.z).max(0.0),
    }
}

/// Failure indices (stress over strength) of the effective state.
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct FailureIndices {
    pub tension: f64,
    pub shear: f64,
    pub compression: f64,
    pub buckling: f64,
}

impl FailureIndices {
    pub fn tension_shear(&self) -> (f64, FailureMode) {
        if self.tension >= self.shear {
            (self.tension, FailureMode::Tension)
        } else {
            (self.shear, FailureMode::Shear)
        }
    }
    pub fn compression_family(&self) -> (f64, FailureMode) {
        if self.compression >= self.buckling {
            (self.compression, FailureMode::Compression)
        } else {
            (self.buckling, FailureMode::Buckling)
        }
    }
    pub fn max(&self) -> f64 {
        self.tension.max(self.shear).max(self.compression).max(self.buckling)
    }
}

/// Residual strength factor of static fatigue (1 without it).
pub fn fatigue_factor(s: &JointStrength, st: &JointState) -> f64 {
    s.static_fatigue.map(|f| f.strength_factor(st.fatigue)).unwrap_or(1.0)
}

/// Strength multiplier and resulting indices.
pub fn failure_indices(s: &JointStrength, m: &StressMeasures, multiplier: f64) -> FailureIndices {
    let ft = s.tensile * multiplier;
    let fc = s.compressive * multiplier;
    let tau_max = (s.cohesion * multiplier + s.friction * m.normal_compression).min(s.shear_cap * multiplier);
    FailureIndices {
        tension: (m.tension / ft).max(0.0),
        shear: if tau_max > 0.0 { m.shear / tau_max } else { f64::INFINITY },
        compression: (m.compression / fc).max(0.0),
        buckling: s.buckling_load.map(|p| m.compressive_force / p).unwrap_or(0.0),
    }
}

/// Damage as a function of the history maximum `kappa` of the failure index and the
/// ductility `r` (total fracture energy over the energy stored at onset).
pub fn damage_law(kind: BondKind, kappa: f64, r: f64) -> f64 {
    if kappa <= 1.0 {
        return 0.0;
    }
    match kind {
        BondKind::Brittle => {
            if r <= 1.0 {
                1.0
            } else {
                (r * (kappa - 1.0) / (kappa * (r - 1.0))).min(1.0)
            }
        }
        BondKind::Ductile => {
            let kappa_u = 0.5 * (r + 1.0);
            if kappa >= kappa_u {
                1.0
            } else {
                1.0 - 1.0 / kappa
            }
        }
    }
}

/// Damage after the failure index grows from `kappa_old` to `lambda`, and the energy
/// the softening law releases on the way: `integral U0 kappa^2 dD`, with `U0 = psi /
/// lambda^2` the energy stored at onset along the current deformation. The integrand
/// `kappa^2 D'(kappa)` is constant for both laws (`r/(r-1)` brittle, `1` on the ductile
/// plateau), so the integral is exact whatever the step: a bond that fails completely
/// releases exactly `r U0 = G_f A`. A snap releases the energy still stored at the snap.
pub fn damage_increment(kind: BondKind, kappa_old: f64, lambda: f64, r: f64, d_old: f64, psi: f64) -> (f64, f64) {
    let d_new = damage_law(kind, lambda, r).max(d_old);
    if d_new <= d_old || d_old >= 1.0 {
        return (d_old, 0.0);
    }
    let u0 = psi / (lambda * lambda);
    let k1 = kappa_old.max(1.0);
    match kind {
        BondKind::Brittle if r > 1.0 => (d_new, u0 * r / (r - 1.0) * (lambda.min(r) - k1.min(r)).max(0.0)),
        BondKind::Brittle => (d_new, (1.0 - d_old) * psi),
        BondKind::Ductile => {
            let ku = 0.5 * (r + 1.0);
            let plateau = u0 * (lambda.min(ku) - k1.min(ku)).max(0.0);
            // At the snap the bond still stores (1 - D(ku)) U0 ku^2 = U0 ku.
            let snap = if d_new >= 1.0 { u0 * ku } else { 0.0 };
            (d_new, plateau + snap)
        }
    }
}

/// Everything the constitutive update needs about one bond.
pub struct JointModel<'a> {
    pub geometry: &'a BondGeometry,
    pub stiffness: &'a BondStiffness,
    pub strength: &'a JointStrength,
    pub rebar: Option<&'a RebarParams>,
    /// Weibull strength multiplier of this bond.
    pub weibull: f64,
}

/// Result of one constitutive evaluation.
#[derive(Clone, Debug)]
pub struct JointResponse {
    /// Actual generalised bond force (tension-positive, local).
    pub force: Local6,
    /// Updated history (commit it to advance).
    pub state: JointState,
    /// Energy dissipated by this evaluation (J): the softening law's fracture energy,
    /// friction and rebar plasticity.
    pub dissipated: f64,
    /// Stored energy released beyond the law when a step overshoots the softening
    /// branch (the bond snaps within one step); vanishes as the step shrinks.
    pub overshoot: f64,
    /// Recoverable elastic energy stored after the evaluation (J).
    pub stored: f64,
    /// The bond's connectivity changed from connected to disconnected.
    pub disconnected: bool,
    /// Effective stress measures (for exposure).
    pub measures: StressMeasures,
}

/// Springs per side of the cracked joint's no-tension patch.
pub const CONTACT_SPRINGS: usize = 6;

fn sq(x: f64) -> f64 {
    x * x
}

/// Elastic energy of the components degraded by `D` (shear, bending, torsion, tensile axial).
fn psi_tension_shear(k: &BondStiffness, d: &Local6) -> f64 {
    0.5 * (k.ks * (sq(d.lin.x) + sq(d.lin.y))
        + k.kb_t1 * sq(d.ang.x)
        + k.kb_t2 * sq(d.ang.y)
        + k.kt * sq(d.ang.z)
        + if d.lin.z > 0.0 { k.kn * sq(d.lin.z) } else { 0.0 })
}

/// 1-D return map of an elastic-perfectly-plastic spring: returns (force, plastic increment).
fn return_map(k: f64, total: f64, plastic: f64, cap: f64) -> (f64, f64) {
    let trial = k * (total - plastic);
    if trial.abs() <= cap {
        (trial, 0.0)
    } else {
        let f = cap * trial.signum();
        (f, (trial - f) / k)
    }
}

impl<'a> JointModel<'a> {
    /// Evaluate the bond at generalised displacement `d`.
    ///
    /// `dt > 0` advances the rate-dependent history (strain rate, static fatigue);
    /// `dt = 0` evaluates without it (static iterations). With `fracture = false` the
    /// damage variables are frozen (but contacts and rebar still act).
    pub fn evaluate(&self, state: &JointState, d: &Local6, dt: f64, fracture: bool) -> JointResponse {
        let k = self.stiffness;
        let s = self.strength;
        let g = self.geometry;
        let mut st = state.clone();
        let was_connected = st.connected(self.rebar.is_some());

        // Effective (undamaged) generalised force and its stress measures.
        let q_eff = d.mul_elem(&k.as_local());
        let measures = stress_measures(g, &q_eff);

        // Strain rate from the governing effective stress (loading only).
        let governing = measures.tension.max(measures.shear).max(measures.compression);
        if dt > 0.0 {
            let raw = ((governing - st.governing_stress) / dt).max(0.0) / s.youngs_modulus;
            let a = (dt / s.rate_filter_time).min(1.0);
            st.strain_rate += (raw - st.strain_rate) * a;
            st.governing_stress = governing;
        }
        let dif = s.dif.map(|p| p.factor(st.strain_rate)).unwrap_or(1.0);
        let multiplier = self.weibull * dif * fatigue_factor(s, &st);
        let idx = failure_indices(s, &measures, multiplier);
        st.utilization = idx.max();

        let mut dissipated = 0.0;
        let mut overshoot = 0.0;
        let psi_ts = psi_tension_shear(k, d);
        let psi_c = if d.lin.z < 0.0 { 0.5 * k.kn * sq(d.lin.z) } else { 0.0 };

        // Contact part (the degraded share of the joint), computed with the old damage
        // so the damage increment below sees the contact energy it is replaced by.
        let contact = |st: &mut JointState, commit_dissipation: bool| -> (Local6, f64, f64) {
            if !s.crack_contact {
                return (Local6::default(), 0.0, 0.0);
            }
            // No-tension multi-spring patch (the Applied Element Method's spring grid):
            // each spring carries compression only, so a cracked joint rocks about its
            // compressed edge and develops arching thrust when restrained.
            let n = CONTACT_SPRINGS;
            let ki = k.kn * (1.0 - st.crush) / (n * n) as f64;
            let (mut nc_sum, mut m1, mut m2, mut energy) = (0.0, 0.0, 0.0, 0.0);
            for a in 0..n {
                let s1 = ((a as f64 + 0.5) / n as f64 - 0.5) * g.width[0];
                for b in 0..n {
                    let s2 = ((b as f64 + 0.5) / n as f64 - 0.5) * g.width[1];
                    let di = d.lin.z + d.ang.x * s2 - d.ang.y * s1;
                    if di < 0.0 {
                        let f = ki * di;
                        nc_sum += f;
                        m1 += f * s2;
                        m2 -= f * s1;
                        energy += 0.5 * ki * di * di;
                    }
                }
            }
            let nc = -nc_sum;
            let mut p: Local6 = st.plastic.into();
            let mut q = Local6 { lin: Vec3::new(0.0, 0.0, nc_sum), ang: Vec3::new(m1, m2, 0.0) };
            let mut diss = 0.0;
            // Coulomb sliding (isotropic in the patch plane).
            let slide_cap = s.friction * nc;
            let trial = Vec3::new(k.ks * (d.lin.x - p.lin.x), k.ks * (d.lin.y - p.lin.y), 0.0);
            let tn = trial.norm();
            if tn > slide_cap && tn > 0.0 {
                let dir = trial / tn;
                let dslip = (tn - slide_cap) / k.ks;
                p.lin.x += dir.x * dslip;
                p.lin.y += dir.y * dslip;
                q.lin.x = dir.x * slide_cap;
                q.lin.y = dir.y * slide_cap;
                diss += slide_cap * dslip;
            } else {
                q.lin.x = trial.x;
                q.lin.y = trial.y;
            }
            // Torsional friction.
            let (tq, dpt) = return_map(k.kt, d.ang.z, p.ang.z, s.friction * nc * g.friction_radius);
            diss += tq.abs() * dpt.abs();
            p.ang.z += dpt;
            q.ang.z = tq;
            energy += 0.5 * (sq(q.lin.x) / k.ks + sq(q.lin.y) / k.ks + sq(tq) / k.kt);
            if commit_dissipation {
                st.plastic = p.into();
            }
            (q, energy, diss)
        };

        // Damage evolution.
        if fracture {
            let (lambda_ts, mode_ts) = idx.tension_shear();
            if lambda_ts > st.kappa && lambda_ts > 1.0 && psi_ts > 0.0 {
                let g_f = if mode_ts == FailureMode::Tension { s.g_tension } else { s.g_shear };
                let r = if s.softening { g_f * g.area * lambda_ts * lambda_ts / psi_ts } else { 0.0 };
                st.ductility = r;
                let kind = if s.softening { s.kind } else { BondKind::Brittle };
                let (new_d, released) = damage_increment(kind, st.kappa, lambda_ts, r, st.damage, psi_ts);
                if new_d > st.damage {
                    let mut probe = st.clone();
                    let (_, psi_contact, _) = contact(&mut probe, false);
                    // Pure compression is carried identically by both shares.
                    let excess = (psi_contact - (1.0 - st.crush) * psi_c).max(0.0);
                    let law = (released - excess * (new_d - st.damage)).max(0.0);
                    dissipated += law;
                    overshoot += ((psi_ts - excess) * (new_d - st.damage) - law).max(0.0);
                    st.damage = new_d;
                    st.mode = Some(mode_ts);
                }
            }
            st.kappa = st.kappa.max(lambda_ts);

            // Crushing acts on the stress the joint actually transmits in compression:
            // the axial force is never degraded by D, but once cracked the joint carries
            // bending only through its intact share and the (capped) rocking contact.
            // Using the undamaged bending stiffness here would "crush" any cracked joint
            // that keeps rotating.
            let comp_idx = {
                let mut probe = state.clone();
                let (qc, _, _) = contact(&mut probe, false);
                let d_old = state.damage;
                let q = Local6 {
                    lin: Vec3::new(0.0, 0.0, q_eff.lin.z.min(0.0)),
                    ang: q_eff.ang * (1.0 - d_old) + qc.ang * d_old,
                };
                failure_indices(s, &stress_measures(g, &q), multiplier)
            };
            let (lambda_c, mode_c) = comp_idx.compression_family();
            if lambda_c > st.kappa_c && lambda_c > 1.0 && psi_c > 0.0 {
                let r = if s.softening { s.g_compression * g.area * lambda_c * lambda_c / psi_c } else { 0.0 };
                st.ductility_c = r;
                let kind = if !s.softening {
                    BondKind::Brittle
                } else if mode_c == FailureMode::Buckling {
                    BondKind::Ductile
                } else {
                    s.kind
                };
                let (new_dc, released) = damage_increment(kind, st.kappa_c, lambda_c, r, st.crush, psi_c);
                if new_dc > st.crush {
                    dissipated += released;
                    overshoot += (psi_c * (new_dc - st.crush) - released).max(0.0);
                    st.crush = new_dc;
                    st.mode = Some(mode_c);
                    if st.crush >= 1.0 && st.damage < 1.0 {
                        // A crushed joint is gone: release the rest of its energy too.
                        dissipated += psi_ts * (1.0 - st.damage);
                        st.damage = 1.0;
                    }
                }
            }
            st.kappa_c = st.kappa_c.max(lambda_c);
        }

        // Actual force: intact share + contact share + rebar.
        let dmg = st.damage;
        let (q_contact, psi_contact, diss_contact) = contact(&mut st, true);
        dissipated += dmg * diss_contact;
        let intact_normal = if d.lin.z > 0.0 { k.kn * d.lin.z } else { (1.0 - st.crush) * k.kn * d.lin.z };
        let mut force = Local6 {
            lin: Vec3::new(
                (1.0 - dmg) * q_eff.lin.x + dmg * q_contact.lin.x,
                (1.0 - dmg) * q_eff.lin.y + dmg * q_contact.lin.y,
                (1.0 - dmg) * intact_normal + dmg * q_contact.lin.z,
            ),
            ang: q_eff.ang * (1.0 - dmg) + q_contact.ang * dmg,
        };
        let mut stored = (1.0 - dmg) * (psi_ts + (1.0 - st.crush) * psi_c) + dmg * psi_contact;

        if let Some(rb) = self.rebar {
            if !st.rebar_broken {
                let (n_r, dep) = return_map(rb.k_axial, d.lin.z, st.rebar_plastic, rb.yield_force);
                let (v1, ds1) = return_map(rb.k_dowel, d.lin.x, st.rebar_slip[0], rb.dowel_capacity);
                let (v2, ds2) = return_map(rb.k_dowel, d.lin.y, st.rebar_slip[1], rb.dowel_capacity);
                let work = rb.yield_force * dep.abs() + rb.dowel_capacity * (ds1.abs() + ds2.abs());
                st.rebar_plastic += dep;
                st.rebar_slip[0] += ds1;
                st.rebar_slip[1] += ds2;
                st.rebar_work += work;
                dissipated += work;
                let elastic = 0.5 * (sq(n_r) / rb.k_axial + (sq(v1) + sq(v2)) / rb.k_dowel);
                if fracture && st.rebar_work >= rb.rupture_work {
                    st.rebar_broken = true;
                    dissipated += elastic;
                } else {
                    force.lin = force.lin + Vec3::new(v1, v2, n_r);
                    stored += elastic;
                }
            }
        }

        // Static fatigue consumes life at the actual stress ratio against the static
        // (rate-free, undamaged) strength.
        if fracture && dt > 0.0 {
            if let Some(f) = s.static_fatigue {
                let actual = stress_measures(g, &force);
                let static_idx = failure_indices(s, &actual, self.weibull);
                let ratio = static_idx.tension.max(static_idx.shear).max(static_idx.compression);
                st.fatigue = (st.fatigue + f.life_rate(ratio) * dt).min(1.0);
            }
        }

        st.dissipated += dissipated;
        let disconnected = was_connected && !st.connected(self.rebar.is_some());
        JointResponse { force, state: st, dissipated, overshoot, stored, disconnected, measures }
    }

    /// Tangent stiffness at displacement `d` (history frozen), for the Newton
    /// iterations of the static and implicit solves: the intact share elastic
    /// (compression degraded by crushing); the cracked share as the contact patch's
    /// *active* springs, `sum k_i g_i g_i^T` over the compressed springs with
    /// `g_i = d(spring)/d(lin.z, ang.x, ang.y)`, which couples the normal force with the
    /// rocking moments; sticking friction at the shear/torsion stiffness, sliding
    /// friction with the radial-return tangent `ks (cap/trial) (I - s s^T)`; plus rebar.
    pub fn tangent(&self, state: &JointState, d: &Local6) -> Mat6 {
        let k = self.stiffness;
        let s = self.strength;
        let g = self.geometry;
        let dmg = state.damage;
        let normal_intact = if d.lin.z > 0.0 { k.kn } else { (1.0 - state.crush) * k.kn };
        let intact = Local6 { lin: Vec3::new(k.ks, k.ks, normal_intact), ang: Vec3::new(k.kb_t1, k.kb_t2, k.kt) };
        let mut m = Mat6::diag(&intact.scale(1.0 - dmg));
        if dmg > 0.0 && s.crack_contact {
            let n = CONTACT_SPRINGS;
            let ki = k.kn * (1.0 - state.crush) / (n * n) as f64;
            let mut nc = 0.0;
            for a in 0..n {
                let s1 = ((a as f64 + 0.5) / n as f64 - 0.5) * g.width[0];
                for b in 0..n {
                    let s2 = ((b as f64 + 0.5) / n as f64 - 0.5) * g.width[1];
                    let di = d.lin.z + d.ang.x * s2 - d.ang.y * s1;
                    if di < 0.0 {
                        nc -= ki * di;
                        // Rows/columns 2 (lin.z), 3 (ang.x), 4 (ang.y).
                        let gv = [(2usize, 1.0), (3usize, s2), (4usize, -s1)];
                        for &(i, gi) in &gv {
                            for &(j, gj) in &gv {
                                m.0[i][j] += dmg * ki * gi * gj;
                            }
                        }
                    }
                }
            }
            let p: Local6 = state.plastic.into();
            let trial = Vec3::new(k.ks * (d.lin.x - p.lin.x), k.ks * (d.lin.y - p.lin.y), 0.0);
            let cap = s.friction * nc;
            let tn = trial.norm();
            if nc > 0.0 {
                if tn <= cap || tn == 0.0 {
                    m.0[0][0] += dmg * k.ks;
                    m.0[1][1] += dmg * k.ks;
                } else {
                    let dir = trial / tn;
                    let r = k.ks * cap / tn;
                    let dirs = [dir.x, dir.y];
                    for i in 0..2 {
                        for j in 0..2 {
                            let delta = if i == j { 1.0 } else { 0.0 };
                            m.0[i][j] += dmg * r * (delta - dirs[i] * dirs[j]);
                        }
                    }
                }
                if k.kt * (d.ang.z - p.ang.z).abs() <= cap * g.friction_radius {
                    m.0[5][5] += dmg * k.kt;
                }
            }
        }
        if let Some(rb) = self.rebar {
            if !state.rebar_broken {
                m = m.add_diag(&Local6 { lin: Vec3::new(rb.k_dowel, rb.k_dowel, rb.k_axial), ang: Vec3::ZERO });
            }
        }
        // Keep every component minimally positive (a fully opened, unbonded joint).
        let floor = intact.scale(1e-6);
        m.add_diag(&floor)
    }

    /// Secant stiffness (diagonal): an upper bound of [`tangent`](Self::tangent) for
    /// the contact patch, so a correction with it always descends.
    pub fn secant(&self, state: &JointState, d: &Local6) -> Mat6 {
        Mat6::diag(&self.secant_factors(state, d).mul_elem(&self.stiffness.as_local()))
    }

    /// Per-component secant stiffness factors at the given state (used for the
    /// damping dashpots). Floored to stay positive.
    pub fn secant_factors(&self, state: &JointState, d: &Local6) -> Local6 {
        let dmg = state.damage;
        let compressed = d.lin.z < 0.0;
        let contact = if compressed { dmg } else { 0.0 };
        let ts = (1.0 - dmg + contact).max(1e-6);
        let normal = if compressed { (1.0 - state.crush).max(1e-6) } else { (1.0 - dmg).max(1e-6) };
        let mut f = Local6 { lin: Vec3::new(ts, ts, normal), ang: Vec3::splat(ts) };
        if let Some(rb) = self.rebar {
            if !state.rebar_broken {
                f.lin.z += rb.k_axial / self.stiffness.kn;
                f.lin.x += rb.k_dowel / self.stiffness.ks;
                f.lin.y += rb.k_dowel / self.stiffness.ks;
            }
        }
        f
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn brittle_law_endpoints() {
        assert_eq!(damage_law(BondKind::Brittle, 1.0, 5.0), 0.0);
        assert!((damage_law(BondKind::Brittle, 5.0, 5.0) - 1.0).abs() < 1e-12);
        assert_eq!(damage_law(BondKind::Brittle, 1.0001, 0.5), 1.0);
        // Traction (1 - D) kappa falls linearly from 1 to 0 over [1, r].
        let r = 4.0;
        for kappa in [1.5, 2.0, 3.0] {
            let t = (1.0 - damage_law(BondKind::Brittle, kappa, r)) * kappa;
            assert!((t - (r - kappa) / (r - 1.0)).abs() < 1e-12);
        }
    }

    #[test]
    fn released_energy_is_the_fracture_energy_for_any_step_size() {
        // U0 = 1 J at onset; r = 3 means G_f A = 3 J.
        for kind in [BondKind::Brittle, BondKind::Ductile] {
            for steps in [1usize, 3, 50] {
                let (r, mut d, mut kappa, mut total) = (3.0, 0.0, 1.0, 0.0);
                let end = if kind == BondKind::Brittle { r } else { 0.5 * (r + 1.0) } * 1.0001;
                for i in 1..=steps {
                    let lambda = 1.0 + (end - 1.0) * i as f64 / steps as f64;
                    let (dn, e) = damage_increment(kind, kappa, lambda, r, d, lambda * lambda);
                    d = dn;
                    kappa = lambda;
                    total += e;
                }
                assert_eq!(d, 1.0);
                assert!((total - r).abs() < 1e-3, "{kind:?} steps {steps}: {total}");
            }
        }
    }

    #[test]
    fn ductile_law_holds_a_plateau() {
        for kappa in [1.5, 2.0, 2.4] {
            let t = (1.0 - damage_law(BondKind::Ductile, kappa, 4.0)) * kappa;
            assert!((t - 1.0).abs() < 1e-12);
        }
        assert_eq!(damage_law(BondKind::Ductile, 2.6, 4.0), 1.0);
    }
}
