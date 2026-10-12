//! Shared diagnostics: one line of a mirror's motion state.
#![allow(dead_code)]

/// One line describing the mirror's motion state.
pub fn report(m: &stress_ref::solver::ReferenceSolver, imps: &[stress_ref::world::Impactor]) -> (f64, String) {
    let (mut vmax, mut vci) = (0.0f64, usize::MAX);
    let (mut wmax, mut wci) = (0.0f64, usize::MAX);
    let mut ke = 0.0;
    for (ci, cl) in m.clusters.iter().enumerate() {
        if cl.anchored {
            continue;
        }
        let v = cl.velocity.norm();
        let w = cl.angular_velocity.norm();
        if !v.is_finite() || v > vmax {
            vmax = v;
            vci = ci;
        }
        if !w.is_finite() || w > wmax {
            wmax = w;
            wci = ci;
        }
        let iw = cl.world_inertia();
        let om = cl.angular_velocity;
        let rot = om.x * (iw.m[0][0] * om.x + iw.m[0][1] * om.y + iw.m[0][2] * om.z) + om.y * (iw.m[1][0] * om.x + iw.m[1][1] * om.y + iw.m[1][2] * om.z) + om.z * (iw.m[2][0] * om.x + iw.m[2][1] * om.y + iw.m[2][2] * om.z);
        ke += 0.5 * cl.mass * cl.velocity.norm2() + 0.5 * rot;
    }
    let imp_ke: f64 = imps.iter().map(|i| 0.5 * i.mass * i.velocity.norm2()).sum();
    let mut lost = 0;
    let mut chunk_vmax = 0.0f64;
    for s in 0..m.structures.len() {
        for c in 0..m.structures[s].chunks.len() {
            if !m.chunks[s][c].active {
                continue;
            }
            let p = m.chunk_position(s, c);
            if p.norm() > 100.0 || p.z < -5.0 || !p.x.is_finite() {
                lost += 1;
            }
            chunk_vmax = chunk_vmax.max(m.chunk_velocity(s, c).0.norm());
        }
    }
    let desc = |ci: usize| {
        if ci == usize::MAX {
            return "-".to_string();
        }
        let cl = &m.clusters[ci];
        let i = cl.inertia;
        format!(
            "cl {ci} (id {}, {} chunks, {} bonds, m {:.3} kg, I diag [{:.2e} {:.2e} {:.2e}], {:?}{}, at {:?})",
            cl.id,
            cl.chunks.len(),
            cl.bonds.len(),
            cl.mass,
            i.m[0][0],
            i.m[1][1],
            i.m[2][2],
            cl.activity,
            if cl.driven { " driven" } else { "" },
            cl.com_world().to_array().map(|x| (x * 100.0).round() / 100.0)
        )
    };
    (
        vmax.max(chunk_vmax),
        format!("vmax {vmax:.3e} [{}]; wmax {wmax:.3e} [{}]; chunk vmax {chunk_vmax:.3e}; KE clusters {ke:.3e} J, impactors {imp_ke:.3e} J; lost {lost}", desc(vci), desc(wci)),
    )
}

