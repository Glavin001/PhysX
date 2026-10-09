//! Import of the repository's authored destruction assets ("scene packs", the JSON
//! written by `blast/blast-stress-solver/structures`) as stress-oracle scenes.
//!
//! Geometry and structure come from the asset: chunk shapes (boxes and convex hulls),
//! positions, which chunks are anchored, structural roles and the bond graph. Physics
//! comes from this crate: each asset material is mapped to one of the calibrated
//! materials in `material.rs`. The assets' own stress limits are tuned for gameplay
//! (their "reinforced concrete" breaks in tension at 11.5 MPa, about four times real
//! concrete) and are not used.
//!
//! Conversions:
//! * Packs are Y-up; scenes are Z-up: `(x, y, z) -> (x, -z, y)` (a rotation, so shapes
//!   keep their handedness).
//! * Hull points are given relative to the node centroid; the chunk centre is moved to
//!   the hull's centre of mass (exactly computed) and the points re-centred on it.
//! * A node with zero mass is a support: the chunk is fixed.
//! * Bond patches are recomputed from the touching faces of the two chunks (area,
//!   centroid, principal widths); the asset's centroid, normal and area are the fallback
//!   where no shared face is found within the seam tolerance.

use std::collections::BTreeMap;

use serde_json::Value;

use crate::builders::{body, chunk, new_scene};
use crate::hull::{contact_patch, ConvexHull, MAX_HULL_VERTICES};
use crate::material::Material;
use crate::math::Vec3;
use crate::scene::{BondDesc, ChunkDesc, GroundDesc, Scene, Support};

/// Faces closer than this (m) count as touching: the assets' Voronoi cutter leaves
/// hairline seams between neighbouring cells.
const SEAM: f64 = 5e-3;

/// The calibrated material standing for an asset material, as (chunk, joint) material
/// names: masonry units are joined by mortar.
fn map_material(asset: &str) -> Result<(&'static str, &'static str), String> {
    Ok(match asset {
        // Precast facade panels are concrete too.
        "reinforced-concrete" | "prestressed-concrete" | "concrete-slab" | "footing-anchor" | "facade-panel" => ("concrete", "concrete"),
        "brick" => ("brick", "mortar"),
        "stone" | "white-stone" => ("stone", "mortar"),
        "glass" => ("glass", "glass"),
        // Facade and glazing clips are metal connectors.
        "steel" | "facade-clip" | "glazing-clip" => ("steel", "steel"),
        "wood-frame" => ("timber", "timber"),
        other => return Err(format!("no calibrated material for asset material '{other}'")),
    })
}

fn material_preset(name: &str) -> Material {
    match name {
        "concrete" => Material::concrete(),
        "brick" => Material::brick(),
        "mortar" => Material::mortar(),
        "stone" => Material::stone(),
        "glass" => Material::glass(),
        "steel" => Material::steel(),
        "timber" => Material::timber(),
        _ => unreachable!("mapped names only"),
    }
}

/// Y-up to Z-up.
fn zup(v: &Value) -> Vec3 {
    let f = |k: &str| v[k].as_f64().unwrap_or(0.0);
    Vec3::new(f("x"), -f("z"), f("y"))
}

/// A flat `[x, y, z, x, y, z, ...]` list (or a list of `{x, y, z}`) to Z-up points.
fn points(v: &Value) -> Vec<Vec3> {
    let arr = v.as_array().cloned().unwrap_or_default();
    if arr.first().is_some_and(Value::is_number) {
        arr.chunks(3)
            .map(|c| {
                let g = |i: usize| c[i].as_f64().unwrap_or(0.0);
                Vec3::new(g(0), -g(2), g(1))
            })
            .collect()
    } else {
        arr.iter().map(zup).collect()
    }
}

/// Load the scene pack at `path` as a scene named `name` with one body `body_name`,
/// on a ground at the bottom of its supports.
pub fn import(path: &std::path::Path, name: &str, body_name: &str) -> Result<Scene, String> {
    let text = std::fs::read_to_string(path).map_err(|e| format!("{}: {e}", path.display()))?;
    let json: Value = serde_json::from_str(&text).map_err(|e| format!("{}: {e}", path.display()))?;
    let sc = &json["scenario"];
    let nodes = sc["nodes"].as_array().ok_or("pack has no nodes")?;
    let colliders = sc["nodeColliders"].as_array().ok_or("pack has no nodeColliders")?;
    let library = sc["shapeLibrary"].as_array().cloned().unwrap_or_default();
    // Version-1 packs (the pre-fractured Voronoi walls, bridges, towers) carry no
    // materials: they are concrete.
    let node_materials: Vec<String> = match sc["nodeMaterials"].as_array() {
        Some(a) => a.iter().map(|m| m.as_str().unwrap_or("").to_string()).collect(),
        None => vec!["reinforced-concrete".to_string(); nodes.len()],
    };
    let node_types: Vec<String> = sc["nodeTypes"].as_array().map(|a| a.iter().map(|t| t.as_str().unwrap_or("").to_string()).collect()).unwrap_or_default();
    let pack_materials: Vec<String> = json["defaults"]["solver"]["materials"]
        .as_array()
        .map(|a| a.iter().map(|m| m["name"].as_str().unwrap_or("").to_string()).collect())
        .unwrap_or_default();

    let mut scene = new_scene(name, &format!("Imported from {}", path.file_name().map(|f| f.to_string_lossy().to_string()).unwrap_or_default()));
    let mut chunks: Vec<ChunkDesc> = Vec::with_capacity(nodes.len());
    let mut hulls: Vec<ConvexHull> = Vec::with_capacity(nodes.len());
    for (i, node) in nodes.iter().enumerate() {
        let (mat, _) = map_material(&node_materials[i])?;
        let centroid = zup(&node["centroid"]);
        let collider = &colliders[i];
        let collider = if collider["kind"] == "shape" { &library[collider["shape"].as_u64().ok_or("bad shape index")? as usize] } else { collider };
        let local: Vec<Vec3> = match collider["kind"].as_str() {
            Some("cuboid") => {
                let h = zup(&collider["halfExtents"]).abs();
                (0..8).map(|k| Vec3::new(if k & 1 == 0 { -h.x } else { h.x }, if k & 2 == 0 { -h.y } else { h.y }, if k & 4 == 0 { -h.z } else { h.z })).collect()
            }
            Some("convex_hull") => points(&collider["points"]),
            other => return Err(format!("node {i}: unsupported collider {other:?}")),
        };
        let mut hull = ConvexHull::new(&local).map_err(|e| format!("node {i}: {e}"))?;
        if hull.vertices.len() > MAX_HULL_VERTICES {
            return Err(format!("node {i}: hull has {} vertices", hull.vertices.len()));
        }
        let com = hull.unit_mass().centroid;
        hull = hull.translated(com);
        let half = hull.half_extents() * (1.0 + 1e-9);
        let mut c = chunk(centroid + com, half, mat);
        c.hull = Some(hull.vertices.iter().map(|v| v.to_array()).collect());
        if node["mass"].as_f64().unwrap_or(0.0) <= 0.0 {
            c.support = Support::Fixed;
        }
        if let Some(t) = node_types.get(i).filter(|t| !t.is_empty()) {
            c.groups.push(t.clone());
        }
        scene.materials.entry(mat.to_string()).or_insert_with(|| material_preset(mat));
        chunks.push(c);
        hulls.push(hull);
    }

    let mut bonds = Vec::new();
    let mut fallback = 0usize;
    for b in sc["bonds"].as_array().ok_or("pack has no bonds")? {
        let (a, bb) = (b["node0"].as_u64().ok_or("bad bond")? as usize, b["node1"].as_u64().ok_or("bad bond")? as usize);
        let asset_material = b["m"].as_u64().and_then(|m| pack_materials.get(m as usize)).cloned().unwrap_or_else(|| node_materials[a].clone());
        let (_, joint) = map_material(&asset_material)?;
        scene.materials.entry(joint.to_string()).or_insert_with(|| material_preset(joint));
        // Normal from a to b (the asset's may point either way).
        let mut normal = zup(&b["normal"]).normalized();
        let (ca, cb) = (Vec3::from_array(chunks[a].center), Vec3::from_array(chunks[bb].center));
        if normal.dot(cb - ca) < 0.0 {
            normal = -normal;
        }
        let patch = contact_patch(&hulls[a], ca, &hulls[bb], cb, normal, SEAM);
        let (centroid, area, tangent, width) = match patch {
            Some(p) => (p.centroid, p.area, p.tangent, p.width),
            None => {
                fallback += 1;
                let area = b["area"].as_f64().unwrap_or(0.0);
                (zup(&b["centroid"]), area, normal.any_perpendicular().normalized(), [area.sqrt(); 2])
            }
        };
        if area <= 0.0 {
            continue;
        }
        bonds.push(BondDesc {
            a,
            b: bb,
            centroid: centroid.to_array(),
            normal: normal.to_array(),
            tangent: tangent.to_array(),
            area,
            width,
            material: joint.to_string(),
            rebar: None,
            buckling_length: None,
            level: 0,
            groups: Vec::new(),
            derived: None,
        });
    }
    if fallback > 0 {
        scene.description = format!("{} ({fallback} of {} bond patches from the asset's area, no shared face found)", scene.description, bonds.len());
    }

    let bottom = chunks
        .iter()
        .filter(|c| c.support == Support::Fixed)
        .map(|c| c.center[2] - c.half_extents[2])
        .fold(f64::INFINITY, f64::min);
    let ground = if bottom.is_finite() { bottom } else { chunks.iter().map(|c| c.center[2] - c.half_extents[2]).fold(f64::INFINITY, f64::min) };
    scene.materials.entry("concrete".into()).or_insert_with(Material::concrete);
    scene.ground = Some(GroundDesc { height: ground, friction: 0.6, material: "concrete".into() });
    scene.bodies.push(body(body_name, chunks, bonds));
    scene.validate()?;
    Ok(scene)
}

/// Bonds per asset material pair and chunk counts per calibrated material.
pub fn summary(scene: &Scene) -> BTreeMap<String, usize> {
    let mut out = BTreeMap::new();
    for b in &scene.bodies {
        for c in &b.chunks {
            *out.entry(format!("chunks:{}", c.material)).or_default() += 1;
        }
        for bd in &b.bonds {
            *out.entry(format!("bonds:{}", bd.material)).or_default() += 1;
        }
    }
    out
}
