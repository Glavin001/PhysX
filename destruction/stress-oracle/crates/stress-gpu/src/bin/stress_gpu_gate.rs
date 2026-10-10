//! The accuracy gate over every case (`gate::cases`) at full duration, against the
//! cached reference runs (`gate::reference_set`).
//!
//!   stress-gpu-gate --build [--only A,B]   compute the missing reference sets (CPU only)
//!   stress-gpu-gate [--only A,B]           run the GPU world on each cached case and gate it
//!
//! Exits non-zero when a case fails or has no cached reference.

use std::time::Instant;

use stress_gpu::gate::{allowed_error, cases, difference, gate, reference_set};
use stress_gpu::gpu::Gpu;
use stress_gpu::world::{unsupported, GpuWorld};

fn main() {
    let mut build = false;
    let mut only: Option<Vec<String>> = None;
    let mut args = std::env::args().skip(1);
    while let Some(a) = args.next() {
        match a.as_str() {
            "--build" => build = true,
            "--only" => only = args.next().map(|v| v.split(',').map(str::to_string).collect()),
            other => panic!("unknown argument {other}"),
        }
    }
    let selected: Vec<_> = cases().into_iter().filter(|c| only.as_ref().is_none_or(|o| o.iter().any(|p| c.name.starts_with(p.as_str())))).collect();
    if build {
        let t = Instant::now();
        for (i, c) in selected.iter().enumerate() {
            let t_case = Instant::now();
            let hit = reference_set(&c.scene, false).is_some();
            if !hit {
                reference_set(&c.scene, true);
            }
            eprintln!("[{}/{}] {:<36} {}", i + 1, selected.len(), c.name, if hit { "cached".to_string() } else { format!("computed in {:.1} s", t_case.elapsed().as_secs_f64()) });
        }
        eprintln!("reference sets ready in {:.1} s", t.elapsed().as_secs_f64());
        return;
    }
    let gpu = Gpu::new().expect("GPU");
    println!("| case | duration | gpu error | allowed | broken ref/gpu | fragments ref/gpu | gpu s | ref s | result |");
    println!("|---|---|---|---|---|---|---|---|---|");
    let mut failed = 0;
    for c in &selected {
        let Some(refs) = reference_set(&c.scene, false) else {
            println!("| {} | {:.2} s | - | - | - | - | - | - | NO REFERENCE (run --build) |", c.name, c.scene.sim.duration);
            failed += 1;
            continue;
        };
        if let Some(why) = unsupported(&c.scene) {
            println!("| {} | {:.2} s | - | - | - | - | - | - | unsupported: {why} |", c.name, c.scene.sim.duration);
            continue;
        }
        let t = Instant::now();
        let ours = match GpuWorld::new(&gpu, &c.scene).and_then(|mut w| w.run(&gpu)) {
            Ok(o) => o,
            Err(e) => {
                println!("| {} | {:.2} s | - | - | - | - | - | - | GPU ERROR: {e} |", c.name, c.scene.sim.duration);
                failed += 1;
                continue;
            }
        };
        let gpu_s = t.elapsed().as_secs_f64();
        let (err, _) = difference(&refs.reference, &ours);
        let allowed = allowed_error(&refs.reference, &refs.half, &refs.spreads);
        let fails = gate(&refs.reference, &ours, &refs.half, &refs.spreads);
        let v = |o: &stress_ref::observation::Observation, k: &str| o.values.get(k).copied().unwrap_or(0.0);
        println!(
            "| {} | {:.2} s | {err:.1e} | {allowed:.1e} | {}/{} | {}/{} | {gpu_s:.1} | {:.1} | {} |",
            c.name,
            c.scene.sim.duration,
            v(&refs.reference, "broken_bonds"),
            v(&ours, "broken_bonds"),
            v(&refs.reference, "fragments"),
            v(&ours, "fragments"),
            refs.reference_seconds,
            if fails.is_empty() { "pass".to_string() } else { format!("FAIL: {}", fails.join("; ")) }
        );
        failed += !fails.is_empty() as usize;
    }
    if failed > 0 {
        eprintln!("{failed} case(s) failed");
        std::process::exit(1);
    }
}
