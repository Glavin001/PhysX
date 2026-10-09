use stress_ref::builders::*;
use stress_ref::world::World;
#[test]
fn dbg() {
    let name = std::env::var("DBG_SCENE").unwrap_or("b9_panel_high".into());
    let frames: usize = std::env::var("DBG_FRAMES").ok().and_then(|v| v.parse().ok()).unwrap_or(60);
    let s = catalog().into_iter().find(|s| s.name == name).unwrap().with_override("sim.solve_mode", "implicit").unwrap();
    let mut w = World::new(&s);
    let t0 = std::time::Instant::now();
    let mut worst: f64 = 0.0; let mut unconv = 0;
    for f in 0..frames {
        w.step_frame();
        let r = w.implicit_report;
        worst = worst.max(r.residual); if !r.converged { unconv += 1; }
        let vrig = w.solver.clusters.iter().map(|c| c.velocity.norm()).fold(0.0, f64::max);
        println!("frame {f} clusters {} broken {} rigid v {:.3e} newton {} cg {} res {:.2e}", w.solver.clusters.len(), w.solver.broken_bond_count(), vrig, r.newton_iterations, r.cg_iterations, r.residual);
    }
    println!("worst {worst:.3e} unconverged {unconv}/{frames} wall {:.1}s", t0.elapsed().as_secs_f64());
}
