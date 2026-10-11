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
