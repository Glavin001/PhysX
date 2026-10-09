//! Convex hull chunks: a scene whose boxes are given as hulls (the same 8 corners) must
//! behave as the box scene. Statics, waves, impact contact and fracture are compared.

mod common;

use stress_ref::builders::catalog;
use stress_ref::observation::Observation;
use stress_ref::scene::Scene;
use stress_ref::showcases;

/// The scene with every chunk replaced by the convex hull of its box corners.
fn as_hulls(scene: &Scene) -> Scene {
    let mut s = scene.clone();
    for body in &mut s.bodies {
        for c in &mut body.chunks {
            let h = c.half_extents;
            c.hull = Some(
                (0..8)
                    .map(|i| [if i & 1 == 0 { -h[0] } else { h[0] }, if i & 2 == 0 { -h[1] } else { h[1] }, if i & 4 == 0 { -h[2] } else { h[2] }])
                    .collect(),
            );
        }
    }
    s.validate().expect("hull scene is valid");
    s
}

fn value(o: &Observation, key: &str) -> f64 {
    o.values[key]
}

fn scene(name: &str) -> Scene {
    catalog().into_iter().chain(showcases::catalog()).find(|s| s.name == name).unwrap_or_else(|| panic!("no scene {name}"))
}

#[test]
fn hull_boxes_match_boxes_in_statics_and_waves() {
    for name in ["b2_cantilever", "b3_bar_wave"] {
        let s = scene(name);
        let (a, b) = (common::run(&s), common::run(&as_hulls(&s)));
        for m in &s.metrics {
            let (x, y) = (
                stress_ref::metrics::evaluate(&s, m, &a).unwrap().as_f64().unwrap(),
                stress_ref::metrics::evaluate(&s, m, &b).unwrap().as_f64().unwrap(),
            );
            println!("{name} {}: box {x} hull {y}", m.name);
            assert!(common::rel(y, x) < 1e-9, "{name} {}: box {x} hull {y}", m.name);
        }
    }
}

/// Contact and fracture: same breach, same fragments and bonds broken within a few,
/// the same car speed lost (the sample points are the same but their order differs, so
/// the force sums round differently and the fracture cascade drifts slightly).
#[test]
fn hull_boxes_match_boxes_under_impact() {
    let s = scene("s_car_brick");
    let (a, b) = (common::run(&s), common::run(&as_hulls(&s)));
    println!(
        "box: broken {} fragments {}; hull: broken {} fragments {}",
        value(&a, "broken_bonds"),
        value(&a, "fragments"),
        value(&b, "broken_bonds"),
        value(&b, "fragments")
    );
    let speed = |o: &Observation| *o.probes["car_velocity"].v.last().unwrap();
    assert!((speed(&a) - speed(&b)).abs() < 0.02 * speed(&a).abs().max(1.0), "car {} vs {}", speed(&a), speed(&b));
    assert!(common::rel(value(&b, "broken_bonds"), value(&a, "broken_bonds")) < 0.1);
    assert!(a.bodies["wall"].iter().any(|c| c.detached) && b.bodies["wall"].iter().any(|c| c.detached));
}

/// The authored assets import with their geometry: hull chunks, supports, bonds with
/// patches recomputed from shared faces, and they stand under their own weight.
#[test]
fn scene_packs_import_and_stand() {
    let dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../../blast/blast-stress-demo-rs/assets/scenes");
    for (file, nodes) in [("rig-portal.json", 18), ("comp-wall-bay.json", 35), ("house-2story.json", 599), ("villa-savoye.json", 1045)] {
        let path = dir.join(file);
        if !path.exists() {
            eprintln!("{} not found; skipping", path.display());
            continue;
        }
        let mut s = stress_ref::scene_pack::import(&path, file, "structure").unwrap();
        let b = &s.bodies[0];
        let hulls = b.chunks.iter().filter(|c| c.hull.is_some()).count();
        let supports = b.chunks.iter().filter(|c| c.support == stress_ref::scene::Support::Fixed).count();
        println!("{file}: {} chunks ({hulls} hulls, {supports} supports), {} bonds; {}; {:?}", b.chunks.len(), b.bonds.len(), s.description, stress_ref::scene_pack::summary(&s));
        assert_eq!(b.chunks.len(), nodes);
        assert!(supports > 0 && !b.bonds.is_empty());
        s.sim.duration = 0.05;
        let o = common::run(&s);
        println!("{file}: broken {} fragments {}", o.values["broken_bonds"], o.values["fragments"]);
        assert_eq!(o.values["broken_bonds"], 0.0, "{file} does not stand");
    }
}
