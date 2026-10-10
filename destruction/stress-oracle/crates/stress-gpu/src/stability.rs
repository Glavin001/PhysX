//! The true stable explicit step of a cluster (the colleague's speed-of-light analysis,
//! section 4): the largest eigenvalue of M^-1 K by power iteration (supports treated as
//! free, which only raises it; intact stiffness with rebar; deformation inertia), the
//! damping ratio of that mode (strain-energy-weighted stiffness-proportional dashpots),
//! and the damped central-difference limit `s (2 / w) (sqrt(1 + z^2) - z)`.
//!
//! Damage only removes stiffness, so the bound of an intact cluster holds for it and for
//! every fragment it breaks into (refinement excepted).

use stress_ref::bond::Local6;
use stress_ref::math::Vec3;
use stress_ref::solver::ReferenceSolver;

/// Highest natural frequency (rad/s) and the damping ratio of that mode.
#[derive(Clone, Copy, Debug)]
pub struct TopMode {
    pub omega: f64,
    pub zeta: f64,
}

fn stiffness6(b: &stress_ref::solver::RtBond) -> Local6 {
    let mut k = b.stiffness.as_local();
    if let Some(r) = &b.rebar {
        k.lin.z += r.k_axial;
        k.lin.x += r.k_dowel;
        k.lin.y += r.k_dowel;
    }
    k
}

/// Power iteration on M^-1 K of cluster `ci` (`iters` steps; the estimate converges
/// from below, so callers add a margin).
pub fn top_mode(m: &ReferenceSolver, ci: usize, iters: usize) -> Option<TopMode> {
    let cl = &m.clusters[ci];
    if cl.bonds.is_empty() {
        return None;
    }
    let s = cl.structure;
    let st = &m.structures[s];
    let n = st.chunks.len();
    let mut x: Vec<(Vec3, Vec3)> = vec![(Vec3::ZERO, Vec3::ZERO); n];
    for &c in &cl.chunks {
        let h = (c as f64 * 0.618_033_988_75 + 0.1).fract();
        x[c] = (
            Vec3::new(h - 0.5, (h * 7.0).fract() - 0.5, (h * 13.0).fract() - 0.5),
            Vec3::new((h * 3.0).fract() - 0.5, (h * 5.0).fract() - 0.5, (h * 11.0).fract() - 0.5),
        );
    }
    let mut lambda = 0.0;
    let apply = |x: &[(Vec3, Vec3)]| -> Vec<(Vec3, Vec3)> {
        let mut y = vec![(Vec3::ZERO, Vec3::ZERO); n];
        for &bi in &cl.bonds {
            let b = &m.bonds[s][bi];
            let g = &b.geometry;
            let d = g.kinematics(x[g.a].0, x[g.a].1, x[g.b].0, x[g.b].1);
            let (fa, ma, fb, mb) = g.chunk_loads(&d.mul_elem(&stiffness6(b)));
            y[g.a].0 -= fa;
            y[g.a].1 -= ma;
            y[g.b].0 -= fb;
            y[g.b].1 -= mb;
        }
        y
    };
    // Mass-normalised form M^-1/2 K M^-1/2 (symmetric): iterate on z = M^1/2 x.
    let sqrt_m = |c: usize| (st.chunks[c].mass * m.chunks[s][c].inertia_scale).sqrt();
    let i_scale = |c: usize| m.chunks[s][c].inertia_scale;
    for _ in 0..iters {
        let y = apply(&x);
        let (mut num, mut den) = (0.0, 0.0);
        let mut next = vec![(Vec3::ZERO, Vec3::ZERO); n];
        for &c in &cl.chunks {
            let ch = &st.chunks[c];
            // M^-1 K x.
            let v = y[c].0 * (1.0 / (ch.mass * i_scale(c)));
            let w = (ch.inv_inertia * y[c].1) * (1.0 / i_scale(c));
            next[c] = (v, w);
            // Rayleigh quotient x^T K x / x^T M x.
            num += x[c].0.dot(y[c].0) + x[c].1.dot(y[c].1);
            den += x[c].0.norm2() * ch.mass * i_scale(c) + x[c].1.dot(ch.inertia * x[c].1) * i_scale(c);
        }
        lambda = if den > 0.0 { num / den } else { 0.0 };
        // Normalise in the mass norm.
        let norm: f64 = cl
            .chunks
            .iter()
            .map(|&c| {
                let ch = &st.chunks[c];
                next[c].0.norm2() * ch.mass * i_scale(c) + next[c].1.dot(ch.inertia * next[c].1) * i_scale(c)
            })
            .sum::<f64>()
            .sqrt();
        if norm == 0.0 {
            break;
        }
        for &c in &cl.chunks {
            x[c] = (next[c].0 * (1.0 / norm), next[c].1 * (1.0 / norm));
        }
        let _ = sqrt_m;
    }
    let omega = lambda.max(0.0).sqrt();
    // Damping ratio of the top mode: (w / 2) sum beta_b e_b / sum e_b, beta = c / k.
    let (mut num, mut den) = (0.0, 0.0);
    for &bi in &cl.bonds {
        let b = &m.bonds[s][bi];
        let g = &b.geometry;
        let d = g.kinematics(x[g.a].0, x[g.a].1, x[g.b].0, x[g.b].1);
        let k = stiffness6(b);
        let e = d.dot(&d.mul_elem(&k));
        let c = d.dot(&d.mul_elem(&b.damping));
        num += c;
        den += e;
    }
    let zeta = if den > 0.0 { 0.5 * omega * num / den } else { 0.0 };
    Some(TopMode { omega, zeta })
}

/// The damped central-difference step for a mode, with safety `s`.
pub fn stable_step(mode: TopMode, s: f64) -> f64 {
    let (w, z) = (mode.omega, mode.zeta);
    if w <= 0.0 {
        return f64::INFINITY;
    }
    s * 2.0 / w * ((1.0 + z * z).sqrt() - z)
}

/// The true step over all clusters with bonds (power iteration estimates converge from
/// below: the frequency is raised by 3%).
pub fn true_stable_dt(m: &ReferenceSolver, iters: usize, safety: f64) -> f64 {
    let mut dt = f64::INFINITY;
    for ci in 0..m.clusters.len() {
        if let Some(mut mode) = top_mode(m, ci, iters) {
            mode.omega *= 1.03;
            dt = dt.min(stable_step(mode, safety));
        }
    }
    dt
}

/// The scene with the true stable step: its Courant safety scaled so the reference's
/// stress step equals the power-iteration bound at `safety` (contacts scale with it).
/// Both solvers then run the same substep, so the GPU and the reference stay comparable
/// like for like; the step change itself is measured by `stress-gpu-stepcheck`.
/// Returns the scene and the step ratio (true over the reference's own).
pub fn with_true_step(scene: &stress_ref::scene::Scene, safety: f64) -> (stress_ref::scene::Scene, f64) {
    let m = ReferenceSolver::new(scene);
    let reference = m.stable_dt();
    let truth = true_stable_dt(&m, 1000, safety);
    let mut s = scene.clone();
    if !(truth.is_finite() && reference.is_finite() && reference > 0.0) {
        return (s, 1.0);
    }
    let ratio = (truth / reference).max(1.0);
    s.sim.courant_safety *= ratio;
    (s, ratio)
}
