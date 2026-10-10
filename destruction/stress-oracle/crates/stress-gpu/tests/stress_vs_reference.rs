//! The GPU explicit substep against the f64 reference solver on identical model data,
//! the identical substep and the identical number of substeps.

use stress_gpu::gpu::Gpu;
use stress_gpu::stress::GpuStress;
use stress_ref::builders::{auto_bonds, body, grid, new_scene};
use stress_ref::math::Vec3;
use stress_ref::scene::{Scene, SolveMode, Support};
use stress_ref::solver::{ChunkLoads, ReferenceSolver};

/// A chunked slab (12 x 6 x 2 chunks of 0.2 m) cantilevered from its x = 0 edge,
/// loaded by gravity from rest.
pub fn slab() -> Scene {
    let mut s = new_scene("gpu_slab", "Chunked slab cantilever under suddenly applied gravity.");
    s.materials.insert("concrete".into(), stress_ref::showcases::static_load_concrete());
    let mut chunks = grid(Vec3::new(0.0, 0.0, 0.0), [12, 6, 2], Vec3::splat(0.2), "concrete");
    for c in chunks.iter_mut().filter(|c| c.center[0] < 0.2) {
        c.support = Support::Fixed;
    }
    let bonds = auto_bonds(&chunks, |_, _| "concrete".into());
    s.bodies.push(body("slab", chunks, bonds));
    s
}

fn compare(name: &str, mut scene: Scene, substeps: usize) {
    scene.sim.fracture = false;
    scene.sim.solve_mode = SolveMode::Explicit;
    let mut reference = ReferenceSolver::new(&scene);
    let gpu = Gpu::new().expect("GPU");
    let solver = GpuStress::new(&gpu, &reference).expect("GPU solver");
    let dt = solver.dt as f64;
    let loads = ChunkLoads::new(&reference);
    solver.run(&gpu, substeps);
    for _ in 0..substeps {
        reference.substep(dt, &loads);
    }
    let state = solver.read_state(&gpu);
    let (mut worst_u, mut scale_u, mut worst_th, mut scale_th) = (0f64, 0f64, 0f64, 0f64);
    for (k, &(s, c)) in solver.chunks.iter().enumerate() {
        let st = &reference.chunks[s][c];
        for d in 0..3 {
            let (gu, gt) = (state[4 * k][d] as f64, state[4 * k + 1][d] as f64);
            let (ru, rt) = ([st.u.x, st.u.y, st.u.z][d], [st.th.x, st.th.y, st.th.z][d]);
            worst_u = worst_u.max((gu - ru).abs());
            worst_th = worst_th.max((gt - rt).abs());
            scale_u = scale_u.max(ru.abs());
            scale_th = scale_th.max(rt.abs());
        }
    }
    eprintln!(
        "{name}: {} chunks, {} bonds, dt {:.3e} s x {substeps} = {:.4} s; |u| {scale_u:.3e} m, max err {worst_u:.3e} ({:.2e} rel); |theta| {scale_th:.3e}, max err {worst_th:.3e} ({:.2e} rel)",
        solver.chunks.len(),
        solver.bond_count,
        dt,
        dt * substeps as f64,
        worst_u / scale_u,
        worst_th / scale_th
    );
    assert!(scale_u > 0.0, "{name}: the reference moved");
    // Provisional: to be replaced by a bound derived from the f32 error propagation.
    assert!(worst_u <= 1e-3 * scale_u, "{name}: displacement error {worst_u:e} of {scale_u:e}");
    assert!(worst_th <= 1e-3 * scale_th, "{name}: rotation error {worst_th:e} of {scale_th:e}");
}

#[test]
fn overhang_matches_the_reference() {
    compare("overhang", stress_ref::showcases::overhang(0.5, "overhang"), 4000);
}

#[test]
fn slab_matches_the_reference() {
    compare("slab", slab(), 4000);
}
