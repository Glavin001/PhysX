//! Static equilibrium on the GPU (`GpuSolver::equilibrate`) against stress-ref's
//! `equilibrate` in f64: anchored structures under gravity, and a free slab under a
//! point load (inertia relief). The GPU solves in f32 to a relative residual of 1e-5;
//! displacements are compared against their own range, reactions against the weight.

use stress_gpu::gpu::Gpu;
use stress_gpu::scenes;
use stress_gpu::solver::GpuSolver;
use stress_ref::math::Vec3;
use stress_ref::scene::{Scene, Support};
use stress_ref::solver::{ChunkLoads, ReferenceSolver};
use stress_ref::statics::StaticOptions;

fn catalogue(name: &str) -> Scene {
    stress_ref::builders::catalog().into_iter().chain(stress_ref::showcases::catalog()).find(|s| s.name == name).expect("scene")
}

/// Solve every cluster with bonds both ways from the unloaded state; worst displacement
/// error (relative to the largest displacement) and reaction error (relative to the
/// total weight).
fn compare(name: &str, scene: &Scene, loads_of: impl Fn(&ReferenceSolver) -> ChunkLoads) -> (f64, f64) {
    let gpu = Gpu::new().expect("GPU");
    let mut reference = ReferenceSolver::new(scene);
    let loads = loads_of(&reference);
    let mut solver = GpuSolver::new(&gpu, reference.clone(), None, Vec::new()).expect("GPU solver");
    let clusters: Vec<usize> = (0..reference.clusters.len()).filter(|&ci| !reference.clusters[ci].bonds.is_empty()).collect();
    let t = std::time::Instant::now();
    let results = solver.equilibrate(&gpu, &clusters, &loads);
    let gpu_time = t.elapsed().as_secs_f64();
    let t = std::time::Instant::now();
    let mut ref_reports = Vec::new();
    for &ci in &clusters {
        ref_reports.push(reference.equilibrate(ci, &loads, &StaticOptions::default()));
    }
    let ref_time = t.elapsed().as_secs_f64();
    let m = &solver.mirror;
    let (mut scale, mut err) = (0.0f64, 0.0f64);
    let (mut weight, mut rerr) = (0.0f64, 0.0f64);
    for s in 0..reference.structures.len() {
        for c in 0..reference.structures[s].chunks.len() {
            let (a, b) = (&reference.chunks[s][c], &m.chunks[s][c]);
            scale = scale.max(a.u.norm());
            err = err.max((a.u - b.u).norm());
            weight += reference.structures[s].chunks[c].mass * reference.config.gravity.norm();
            rerr += (a.reaction.0 - b.reaction.0).norm();
        }
    }
    let (du, dr) = (err / scale.max(1e-30), rerr / weight.max(1e-30));
    for (k, (g, r)) in results.iter().zip(&ref_reports).enumerate() {
        eprintln!(
            "{name} cluster {}: gpu converged {} residual {:.1e} ({} Newton, {} CG) in {gpu_time:.3} s | reference converged {} residual {:.1e} ({} Newton, {} CG) in {ref_time:.3} s",
            clusters[k], g.converged, g.residual, g.newton_iterations, g.cg_iterations, r.converged, r.residual, r.newton_iterations, r.cg_iterations
        );
    }
    eprintln!("{name}: displacement error {du:.1e} of the largest ({scale:.3e} m); reaction error {dr:.1e} of the weight");
    for (g, r) in results.iter().zip(&ref_reports) {
        assert_eq!(g.converged, r.converged, "{name}: convergence differs");
    }
    (du, dr)
}

#[test]
fn equilibrium_matches_the_reference() {
    let gravity_only = |m: &ReferenceSolver| ChunkLoads::new(m);
    let mut cases: Vec<(&str, Scene)> = vec![
        ("slab 12x6x2", scenes::slab([12, 6, 2])),
        ("slab 40x20x4", scenes::slab([40, 20, 4])),
        ("b2_cantilever", catalogue("b2_cantilever")),
        ("b8_frame_gradual", catalogue("b8_frame_gradual")),
        ("s_floor_static", catalogue("s_floor_static")),
    ];
    for (name, scene) in cases.drain(..) {
        let (du, dr) = compare(name, &scene, gravity_only);
        assert!(du < 1e-3, "{name}: displacement error {du:.1e}");
        assert!(dr < 1e-4, "{name}: reaction error {dr:.1e}");
    }
    // A free slab (no supports) pushed at one corner: inertia relief.
    let mut free = scenes::slab([12, 6, 2]);
    for c in free.bodies[0].chunks.iter_mut() {
        c.support = Support::None;
    }
    let push = |m: &ReferenceSolver| {
        let mut l = ChunkLoads::new(m);
        l.force[0][0] = Vec3::new(0.0, 0.0, 5.0e4);
        l
    };
    let (du, _) = compare("free slab", &free, push);
    assert!(du < 1e-3, "free slab: displacement error {du:.1e}");
}
