//! Import of Shardwright pre-fractured assets (exported from `.fracphys` as
//! `shardwright-stress/1` JSON: fragments of levels 0..=L with their parents, and the
//! bonds of level L).
//!
//! The level-L fragments become chunks. Shardwright fragments are compounds of up to
//! 16 convex hulls (non-convex chunks), and an oracle chunk holds one convex hull, so
//! each fragment becomes its equivalent-inertia box (`equivalent_box`): the asset's
//! centre of mass, principal axes and principal moments per unit mass. The mass
//! distribution is kept; contact geometry is approximated (compound chunks would make it
//! exact). Each chunk carries its ancestry as groups: `member:<L0 id>` (the authored
//! component), `l1:<id>`, and its role (`column`, `beam`, `slab`, `wall`, ...). Bonds to
//! the world (`b = -1`) make their chunk a support.
//!
//! Bond sections: the asset gives the area and the second moments `i_uu`, `i_vv` in its
//! `(u, v)` frame; the joint takes a rectangle of the same area and the aspect of the
//! patch's oriented extent, along `u` (an approximation of the bending stiffness of a
//! non-rectangular patch). Materials map to the calibrated presets; mortar joints
//! (`composition` kind 1) take mortar; reinforced concrete takes the asset's rebar, or
//! the EN 1992 minimum where the asset has none. The assets' strength scales (Weibull
//! and deliberate weakening of cut interfaces) are not used: strengths are the
//! calibrated materials'.
//!
//! Units SI; the asset's +Y up becomes +Z up.

use serde_json::Value;

use crate::builders::{body, chunk, new_scene};
use crate::material::Material;
use crate::math::Vec3;
use crate::scene::{BondDesc, GroundDesc, RebarSpec, Scene, Support};
use crate::scene_pack::{material_preset, minimum_reinforcement};

const ROLES: [&str; 9] = ["generic", "column", "beam", "slab", "wall", "connection", "cosmetic", "prop", "glazing"];

/// The calibrated (chunk, joint) materials of a Shardwright library material.
fn map_material(name: &str) -> (&'static str, &'static str) {
    match name {
        "brick_clay" | "ceramic" => ("brick", "mortar"),
        "sandstone" => ("stone", "mortar"),
        "pine" => ("timber", "timber"),
        "glass_annealed" | "glass_tempered" => ("glass", "glass"),
        "steel_s355" => ("steel", "steel"),
        // Gypsum board: weak, brittle and light; mortar is the closest preset.
        "drywall" => ("mortar", "mortar"),
        _ => ("concrete", "concrete"),
    }
}

/// Y-up `[x, y, z]` to Z-up.
fn zup(v: &Value) -> Vec3 {
    let f = |i: usize| v[i].as_f64().unwrap_or(0.0);
    Vec3::new(f(0), -f(2), f(1))
}

/// Eigen-decomposition of a symmetric 3 x 3 matrix (cyclic Jacobi): eigenvalues and
/// eigenvectors as columns.
fn sym_eigen(m: [[f64; 3]; 3]) -> ([f64; 3], [[f64; 3]; 3]) {
    let mut a = m;
    let mut v = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]];
    for _ in 0..64 {
        let off = a[0][1].abs() + a[0][2].abs() + a[1][2].abs();
        if off <= 1e-15 * (a[0][0].abs() + a[1][1].abs() + a[2][2].abs()) {
            break;
        }
        for (p, q) in [(0, 1), (0, 2), (1, 2)] {
            if a[p][q] == 0.0 {
                continue;
            }
            let theta = (a[q][q] - a[p][p]) / (2.0 * a[p][q]);
            let t = theta.signum() / (theta.abs() + (theta * theta + 1.0).sqrt());
            let t = if theta == 0.0 { 1.0 } else { t };
            let (c, s) = (1.0 / (t * t + 1.0).sqrt(), t / (t * t + 1.0).sqrt());
            for k in 0..3 {
                let (akp, akq) = (a[k][p], a[k][q]);
                a[k][p] = c * akp - s * akq;
                a[k][q] = s * akp + c * akq;
            }
            for k in 0..3 {
                let (apk, aqk) = (a[p][k], a[q][k]);
                a[p][k] = c * apk - s * aqk;
                a[q][k] = s * apk + c * aqk;
            }
            for k in 0..3 {
                let (vkp, vkq) = (v[k][p], v[k][q]);
                v[k][p] = c * vkp - s * vkq;
                v[k][q] = s * vkp + c * vkq;
            }
        }
    }
    ([a[0][0], a[1][1], a[2][2]], v)
}

/// Quaternion (w, x, y, z) of a proper rotation matrix.
fn quat_wxyz(r: [[f64; 3]; 3]) -> [f64; 4] {
    let tr = r[0][0] + r[1][1] + r[2][2];
    let q = if tr > 0.0 {
        let s = (tr + 1.0).sqrt() * 2.0;
        [0.25 * s, (r[2][1] - r[1][2]) / s, (r[0][2] - r[2][0]) / s, (r[1][0] - r[0][1]) / s]
    } else if r[0][0] > r[1][1] && r[0][0] > r[2][2] {
        let s = (1.0 + r[0][0] - r[1][1] - r[2][2]).sqrt() * 2.0;
        [(r[2][1] - r[1][2]) / s, 0.25 * s, (r[0][1] + r[1][0]) / s, (r[0][2] + r[2][0]) / s]
    } else if r[1][1] > r[2][2] {
        let s = (1.0 + r[1][1] - r[0][0] - r[2][2]).sqrt() * 2.0;
        [(r[0][2] - r[2][0]) / s, (r[0][1] + r[1][0]) / s, 0.25 * s, (r[1][2] + r[2][1]) / s]
    } else {
        let s = (1.0 + r[2][2] - r[0][0] - r[1][1]).sqrt() * 2.0;
        [(r[1][0] - r[0][1]) / s, (r[0][2] + r[2][0]) / s, (r[1][2] + r[2][1]) / s, 0.25 * s]
    };
    let n = q.iter().map(|x| x * x).sum::<f64>().sqrt();
    q.map(|x| x / n)
}

/// A box chunk with the fragment's centre of mass, principal axes and principal moments
/// per unit mass (the uniform box whose inertia ellipsoid is the fragment's: `a^2 =
/// 6 (I2 + I3 - I1) / m`). A compound (multi-hull, non-convex) fragment's mass
/// distribution is kept without a convex hull of it; its mass is then the calibrated
/// density times the box's volume.
fn equivalent_box(f: &Value, mat: &str) -> Result<crate::scene::ChunkDesc, String> {
    let m = f["mass"].as_f64().filter(|m| *m > 0.0).ok_or("no mass")?;
    let i: Vec<f64> = f["inertia"].as_array().ok_or("no inertia")?.iter().map(|v| v.as_f64().unwrap_or(0.0)).collect();
    // Y-up to Z-up: R (x, y, z) = (x, -z, y); I' = R I R^T.
    let r = [[1.0, 0.0, 0.0], [0.0, 0.0, -1.0], [0.0, 1.0, 0.0]];
    let ia: [[f64; 3]; 3] = std::array::from_fn(|p| std::array::from_fn(|q| i[3 * p + q]));
    let iz: [[f64; 3]; 3] = std::array::from_fn(|p| std::array::from_fn(|q| (0..3).map(|a| (0..3).map(|b| r[p][a] * ia[a][b] * r[q][b]).sum::<f64>()).sum()));
    let (l, mut v) = sym_eigen(iz);
    // A proper rotation.
    let det = v[0][0] * (v[1][1] * v[2][2] - v[1][2] * v[2][1]) - v[0][1] * (v[1][0] * v[2][2] - v[1][2] * v[2][0]) + v[0][2] * (v[1][0] * v[2][1] - v[1][1] * v[2][0]);
    if det < 0.0 {
        for row in v.iter_mut() {
            row[2] = -row[2];
        }
    }
    let side = |k: usize| -> f64 {
        let (a, b, c) = (l[k], l[(k + 1) % 3], l[(k + 2) % 3]);
        (6.0 * (b + c - a) / m).max(1e-6 * (a + b + c) / m).sqrt()
    };
    let half = Vec3::new(side(0), side(1), side(2)) * 0.5;
    let mut c = chunk(zup(&f["com"]), half, mat);
    c.orientation = quat_wxyz(v);
    Ok(c)
}

/// Load an exported Shardwright asset as a scene with one body.
pub fn import(path: &std::path::Path, name: &str) -> Result<Scene, String> {
    let text = std::fs::read_to_string(path).map_err(|e| format!("{}: {e}", path.display()))?;
    let json: Value = serde_json::from_str(&text).map_err(|e| format!("{}: {e}", path.display()))?;
    if json["format"] != "shardwright-stress/1" {
        return Err(format!("{}: not a shardwright-stress/1 export", path.display()));
    }
    let level = json["bond_level"].as_u64().ok_or("no bond_level")?;
    let frags = json["fragments"].as_array().ok_or("no fragments")?;
    let by_id: std::collections::HashMap<u64, &Value> = frags.iter().map(|f| (f["id"].as_u64().unwrap(), f)).collect();
    fn ancestor<'a>(by_id: &std::collections::HashMap<u64, &'a Value>, mut f: &'a Value, at: u64) -> Option<u64> {
        while f["level"].as_u64()? > at {
            f = by_id.get(&(f["parent"].as_i64()? as u64))?;
        }
        f["id"].as_u64()
    }
    let mut scene = new_scene(name, &format!("Shardwright asset '{}', level {level}", json["name"].as_str().unwrap_or(name)));
    let mut chunks = Vec::new();
    let mut local = std::collections::HashMap::new();
    for f in frags.iter().filter(|f| f["level"].as_u64() == Some(level)) {
        let (mat, _) = map_material(f["material"].as_str().unwrap_or(""));
        let mut c = equivalent_box(f, mat).map_err(|e| format!("fragment {}: {e}", f["id"]))?;
        let role = ROLES.get(f["role"].as_u64().unwrap_or(0) as usize).copied().unwrap_or("generic");
        c.groups.push(role.to_string());
        if let Some(m) = ancestor(&by_id, f, 0) {
            c.groups.push(format!("member:{m}"));
        }
        if level > 1 {
            if let Some(p) = ancestor(&by_id, f, 1) {
                c.groups.push(format!("l1:{p}"));
            }
        }
        scene.materials.entry(mat.to_string()).or_insert_with(|| material_preset(mat));
        local.insert(f["id"].as_u64().unwrap(), chunks.len());
        chunks.push(c);
    }
    let mut bonds = Vec::new();
    let mut anchors = 0usize;
    for b in json["bonds"].as_array().ok_or("no bonds")? {
        let a = local[&b["a"].as_u64().ok_or("bond a")?];
        let area = b["area"].as_f64().unwrap_or(0.0);
        if b["b"].as_i64() == Some(-1) {
            chunks[a].support = Support::Fixed;
            anchors += 1;
            continue;
        }
        let bb = local[&(b["b"].as_i64().ok_or("bond b")? as u64)];
        let mut normal = zup(&b["normal"]).normalized();
        let (ca, cb) = (Vec3::from_array(chunks[a].center), Vec3::from_array(chunks[bb].center));
        if normal.dot(cb - ca) < 0.0 {
            normal = -normal;
        }
        let eh = [b["extent_half"][0].as_f64().unwrap_or(0.0), b["extent_half"][1].as_f64().unwrap_or(0.0)];
        if !(area > 0.0 && eh[0] > 0.0 && eh[1] > 0.0) {
            continue;
        }
        // The oriented extent scaled to the bond's area (aspect kept).
        let s = (area / (4.0 * eh[0] * eh[1])).sqrt();
        let width = [2.0 * eh[0] * s, 2.0 * eh[1] * s];
        let mortar = b["composition"].as_array().is_some_and(|c| c.iter().any(|k| k[0].as_u64() == Some(1)));
        let chunk_mat = chunks[a].material.clone();
        let joint = if mortar { "mortar" } else { map_material(by_id[&b["a"].as_u64().unwrap()]["material"].as_str().unwrap_or("")).1 };
        scene.materials.entry(joint.to_string()).or_insert_with(|| material_preset(joint));
        let rebar = (chunk_mat == "concrete" && joint == "concrete").then(|| {
            scene.materials.entry("steel".into()).or_insert_with(Material::steel);
            let asset = b["rebar_area"].as_f64().unwrap_or(0.0);
            let area = if asset > 0.0 { asset } else { area * minimum_reinforcement(&Material::concrete(), &Material::steel()) };
            RebarSpec { area, material: "steel".into() }
        });
        bonds.push(BondDesc {
            a,
            b: bb,
            centroid: zup(&b["centroid"]).to_array(),
            normal: normal.to_array(),
            tangent: zup(&b["frame_u"]).to_array(),
            area,
            width,
            material: joint.to_string(),
            rebar,
            buckling_length: None,
            level: 0,
            groups: Vec::new(),
            derived: None,
        });
    }
    scene.description = format!("{} ({} chunks, {} bonds, {anchors} anchors; chunks as equivalent-inertia boxes)", scene.description, chunks.len(), bonds.len());
    scene.materials.entry("concrete".into()).or_insert_with(Material::concrete);
    scene.ground = Some(GroundDesc { height: 0.0, friction: 0.6, material: "concrete".into() });
    scene.bodies.push(body(name, chunks, bonds));
    scene.validate()?;
    Ok(scene)
}
