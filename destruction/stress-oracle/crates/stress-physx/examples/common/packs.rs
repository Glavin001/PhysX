//! Scene packs as the GPU world takes them (shared by examples/destruction_video.rs and
//! tests/blowup_gpu.rs): the version-1 Voronoi packs' hull colliders reduced to at most
//! 64 corners (`hull_points_reduced`).
#![allow(dead_code)]

use std::path::{Path, PathBuf};

use stress_ref::math::Vec3;
use stress_ref::scene::Scene;

pub fn assets() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../../blast/blast-stress-demo-rs/assets/scenes")
}

pub fn pack(name: &str) -> Scene {
    let path = assets().join(format!("{name}.json"));
    let path = hull_points_reduced(&path, name);
    stress_ref::scene_pack::import(&path, name, name).unwrap_or_else(|e| panic!("{name}: {e}"))
}

/// The version-1 Voronoi packs (fractured-*) give each convex-hull collider as the
/// points of its render mesh (triangle soup, every corner repeated, up to ~600 distinct
/// points), while a hull chunk takes at most 64 points (`hull::MAX_HULL_VERTICES`, PhysX's
/// cooking limit). Each such collider is replaced by the corners of its convex hull: the
/// points extreme along some direction of a Fibonacci sphere of directions, as many
/// directions as keep 64 or fewer corners. Where a hull has more than 64 corners this is
/// an inscribed hull (a named approximation of the asset's geometry; the volume lost is
/// reported by `volume_check`). Packs with no such collider are read unchanged.
pub fn hull_points_reduced(path: &Path, name: &str) -> PathBuf {
    let text = std::fs::read_to_string(path).expect("pack");
    let mut json: serde_json::Value = serde_json::from_str(&text).expect("pack json");
    let Some(colliders) = json["scenario"]["nodeColliders"].as_array_mut() else { return path.to_path_buf() };
    let too_many = |c: &serde_json::Value| c["kind"] == "convex_hull" && c["points"].as_array().is_some_and(|a| a.len() / 3 > stress_ref::hull::MAX_HULL_VERTICES);
    if !colliders.iter().any(too_many) {
        return path.to_path_buf();
    }
    let mut changed = 0usize;
    let mut reduced = 0usize;
    let mut slivers = 0usize;
    let (mut vol_before, mut vol_after) = (0.0f64, 0.0f64);
    for c in colliders.iter_mut() {
        if c["kind"] != "convex_hull" {
            continue;
        }
        let flat: Vec<f64> = c["points"].as_array().map(|a| a.iter().filter_map(|v| v.as_f64()).collect()).unwrap_or_default();
        // Distinct points (the soup repeats corners; the cutter leaves 0.1 mm jitter).
        let mut pts: Vec<Vec3> = Vec::new();
        for p in flat.chunks(3).map(|p| Vec3::new(p[0], p[1], p[2])) {
            if !pts.iter().any(|q| (*q - p).norm() < 1e-4) {
                pts.push(p);
            }
        }
        let extremes = |n: usize| {
            let golden = std::f64::consts::PI * (3.0 - 5f64.sqrt());
            let mut idx: Vec<usize> = (0..n)
                .map(|i| {
                    let z = 1.0 - 2.0 * (i as f64 + 0.5) / n as f64;
                    let r = (1.0 - z * z).sqrt();
                    let d = Vec3::new(r * (golden * i as f64).cos(), r * (golden * i as f64).sin(), z);
                    (0..pts.len()).max_by(|&a, &b| pts[a].dot(d).total_cmp(&pts[b].dot(d))).unwrap()
                })
                .collect();
            idx.sort();
            idx.dedup();
            idx
        };
        let mut n = 8192;
        let mut keep = extremes(n);
        if keep.len() > stress_ref::hull::MAX_HULL_VERTICES {
            reduced += 1;
        }
        while keep.len() > stress_ref::hull::MAX_HULL_VERTICES {
            n = n * 3 / 4;
            keep = extremes(n);
        }
        // Single-precision corners leave faces only nearly planar, which the solver's
        // exact hull (tolerance 1e-9 of the size) splits into overlapping near-copies.
        // The hull is rebuilt from its face planes instead: planes through three corners
        // with every corner within 0.1 mm inside, moved out to enclose them all, nearly
        // identical planes (1e-4 rad, 0.1 mm) merged, and the corners recomputed as the
        // planes' intersections. The result contains the asset's hull and exceeds it by at
        // most about 0.1 mm.
        let corners: Vec<Vec3> = keep.iter().map(|&i| pts[i]).collect();
        let mut kept = match planar_hull(&corners, 1e-4) {
            Some(v) if v.len() <= stress_ref::hull::MAX_HULL_VERTICES => v,
            _ => corners,
        };
        // The hull must come out the same when rebuilt from its own corners about its
        // centroid (as the importer stores it and the scene check rebuilds it). Corners
        // of nearly coplanar faces (the render mesh is single precision) can make the two
        // differ; while they do, the corner whose removal changes the volume least is
        // dropped (a sliver; counted and reported).
        vol_before += hull_volume(&kept);
        while !rebuilds_alike(&kept) && kept.len() > 4 {
            let full = hull_volume(&kept);
            let drop = (0..kept.len())
                .min_by(|&a, &b| {
                    let without = |k: usize| kept.iter().enumerate().filter(|&(i, _)| i != k).map(|(_, p)| *p).collect::<Vec<_>>();
                    (full - hull_volume(&without(a))).abs().total_cmp(&(full - hull_volume(&without(b))).abs())
                })
                .unwrap();
            kept.remove(drop);
            slivers += 1;
        }
        vol_after += hull_volume(&kept);
        c["points"] = serde_json::Value::Array(kept.iter().flat_map(|p| [p.x, p.y, p.z]).map(serde_json::Value::from).collect());
        changed += 1;
    }
    // Bonds the asset gives with a zero normal: the direction between the two cells'
    // centroids (the importer then finds their shared face from it, or keeps the
    // asset's area and centroid).
    let centroids: Vec<[f64; 3]> =
        json["scenario"]["nodes"].as_array().map(|a| a.iter().map(|n| ["x", "y", "z"].map(|k| n["centroid"][k].as_f64().unwrap_or(0.0))).collect()).unwrap_or_default();
    let mut normals = 0usize;
    if let Some(bonds) = json["scenario"]["bonds"].as_array_mut() {
        for b in bonds {
            let n = ["x", "y", "z"].map(|k| b["normal"][k].as_f64().unwrap_or(0.0));
            if n.iter().map(|v| v * v).sum::<f64>() > 0.25 {
                continue;
            }
            let (a, c) = (b["node0"].as_u64().unwrap() as usize, b["node1"].as_u64().unwrap() as usize);
            let d = Vec3::from_array(centroids[c]) - Vec3::from_array(centroids[a]);
            let d = d.normalized();
            b["normal"] = serde_json::json!({"x": d.x, "y": d.y, "z": d.z});
            normals += 1;
        }
    }
    eprintln!("{name}: {normals} bonds with a zero normal given the direction between their cells' centroids");
    let out = std::env::temp_dir().join(format!("destruction-video-{name}.json"));
    std::fs::write(&out, serde_json::to_string(&json).unwrap()).expect("write reduced pack");
    eprintln!("{name}: {changed} hull colliders given as their corners, {reduced} of them inscribed (more than 64 corners), {slivers} near-coplanar corners dropped (hull volume {vol_before:.3} -> {vol_after:.3} m^3)");
    out
}

/// The corners of the polytope bounded by the face planes of `points` (see
/// `hull_points_reduced`), or `None` if it is degenerate.
pub fn planar_hull(points: &[Vec3], tol: f64) -> Option<Vec<Vec3>> {
    let n = points.len();
    let scale = points.iter().map(|p| p.norm()).fold(0.0, f64::max).max(1e-9);
    let mut planes: Vec<(Vec3, f64)> = Vec::new();
    for i in 0..n {
        for j in i + 1..n {
            for k in j + 1..n {
                let normal = (points[j] - points[i]).cross(points[k] - points[i]);
                if normal.norm() < 1e-10 {
                    continue;
                }
                let mut normal = normal.normalized();
                let mut offset = normal.dot(points[i]);
                let (lo, hi) = points.iter().fold((f64::INFINITY, f64::NEG_INFINITY), |(lo, hi), p| {
                    let d = normal.dot(*p) - offset;
                    (lo.min(d), hi.max(d))
                });
                if hi <= tol {
                    offset += hi;
                } else if lo >= -tol {
                    normal = -normal;
                    offset = -offset - lo;
                } else {
                    continue;
                }
                if !planes.iter().any(|(m, o)| m.dot(normal) > 1.0 - 5e-9 && (o - offset).abs() <= tol) {
                    planes.push((normal, offset));
                }
            }
        }
    }
    let mut corners: Vec<Vec3> = Vec::new();
    let m = planes.len();
    for a in 0..m {
        for b in a + 1..m {
            for c in b + 1..m {
                let (na, nb, nc) = (planes[a].0, planes[b].0, planes[c].0);
                let det = na.dot(nb.cross(nc));
                if det.abs() < 1e-9 {
                    continue;
                }
                let v = (nb.cross(nc) * planes[a].1 + nc.cross(na) * planes[b].1 + na.cross(nb) * planes[c].1) * (1.0 / det);
                if planes.iter().all(|(nn, o)| nn.dot(v) <= o + 1e-9 * scale) && !corners.iter().any(|q| (*q - v).norm() < 1e-6) {
                    corners.push(v);
                }
            }
        }
    }
    (corners.len() >= 4).then_some(corners)
}

pub fn hull_volume(p: &[Vec3]) -> f64 {
    stress_ref::hull::ConvexHull::new(p).map_or(0.0, |h| h.unit_mass().volume)
}

/// The hull of `p`, re-centred on its centroid and rebuilt from its own vertices (as
/// `scene_pack::import` stores a chunk and `Scene::validate` checks it), has its centroid
/// at the centre.
pub fn rebuilds_alike(p: &[Vec3]) -> bool {
    let Ok(h) = stress_ref::hull::ConvexHull::new(p) else { return false };
    let h = h.translated(h.unit_mass().centroid);
    let Ok(again) = stress_ref::hull::ConvexHull::new(&h.vertices) else { return false };
    again.unit_mass().centroid.norm() <= 1e-6 * again.half_extents().norm()
}

