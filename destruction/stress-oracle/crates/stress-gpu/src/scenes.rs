//! Scenes built for the GPU solver's tests and benchmarks (stress-ref scene format).

use stress_ref::builders::{auto_bonds, body, grid, new_scene};
use stress_ref::math::Vec3;
use stress_ref::scene::{BodyDesc, Scene, Support};

/// A chunked slab of `n` chunks of 0.2 m, cantilevered from its x = 0 edge, at `origin`.
pub fn slab_body(name: &str, n: [usize; 3], origin: Vec3) -> BodyDesc {
    let mut chunks = grid(origin, n, Vec3::splat(0.2), "concrete");
    for c in chunks.iter_mut().filter(|c| c.center[0] < origin.x + 0.2) {
        c.support = Support::Fixed;
    }
    let bonds = auto_bonds(&chunks, |_, _| "concrete".into());
    body(name, chunks, bonds)
}

/// One slab cantilever under suddenly applied gravity.
pub fn slab(n: [usize; 3]) -> Scene {
    let mut s = new_scene("gpu_slab", "Chunked slab cantilever under suddenly applied gravity.");
    s.materials.insert("concrete".into(), stress_ref::showcases::static_load_concrete());
    s.bodies.push(slab_body("slab", n, Vec3::ZERO));
    s
}

/// `count` separate slabs on a square grid (one island each): many-island throughput.
pub fn town(count: usize, n: [usize; 3]) -> Scene {
    let mut s = new_scene("gpu_town", "Separate slab cantilevers under suddenly applied gravity.");
    s.materials.insert("concrete".into(), stress_ref::showcases::static_load_concrete());
    let side = (count as f64).sqrt().ceil() as usize;
    let pitch = 0.2 * (n[0].max(n[1]) as f64 + 2.0);
    for i in 0..count {
        let origin = Vec3::new((i % side) as f64 * pitch, (i / side) as f64 * pitch, 0.0);
        s.bodies.push(slab_body(&format!("slab{i}"), n, origin));
    }
    s
}

/// `count` copies of `base`'s structures on a square grid (one or more islands each, as
/// authored): a town of real buildings. Copies stand `gap` metres apart; chunk centres
/// and bond patches are translated (hulls are in the chunk frame), supports and the
/// ground plane kept. Loads, impactors, events, probes and metrics are dropped.
pub fn pack_town(base: &Scene, count: usize, gap: f64) -> Scene {
    let (mut lo, mut hi) = (Vec3::splat(f64::INFINITY), Vec3::splat(f64::NEG_INFINITY));
    for c in base.bodies.iter().flat_map(|b| b.chunks.iter()) {
        let (p, h) = (Vec3::from_array(c.center), Vec3::from_array(c.half_extents));
        lo = lo.component_min(p - h);
        hi = hi.component_max(p + h);
    }
    let side = (count as f64).sqrt().ceil() as usize;
    let pitch = Vec3::new(hi.x - lo.x + gap, hi.y - lo.y + gap, 0.0);
    let mut s = base.clone();
    s.name = format!("{}_town{count}", base.name);
    s.description = format!("{count} copies of {}", base.name);
    s.bodies.clear();
    s.loads.clear();
    s.impactors.clear();
    s.events.clear();
    s.probes.clear();
    s.metrics.clear();
    for i in 0..count {
        let offset = Vec3::new((i % side) as f64 * pitch.x, (i / side) as f64 * pitch.y, 0.0);
        for b in &base.bodies {
            let mut body = b.clone();
            body.name = format!("{}_{i}", b.name);
            for c in &mut body.chunks {
                c.center = (Vec3::from_array(c.center) + offset).to_array();
            }
            for bd in &mut body.bonds {
                bd.centroid = (Vec3::from_array(bd.centroid) + offset).to_array();
            }
            s.bodies.push(body);
        }
    }
    s
}
