//! `stress-ref` command line.
//!
//! ```text
//! stress-ref gen-scenes <dir>                       write the scene catalogue (with derived bond data)
//! stress-ref with-seed <scene.json> <seed> <out.json>  same scene, Weibull strengths for another seed
//! stress-ref run <scene.json> [--seed N] [--out obs.json] [--mode explicit|adaptive|quasi_static]
//!                [--stiffness-scale S] [--max-substep DT] [--frame-dt DT]
//! stress-ref compare <scene.json> <ours.json> [<oracle.json> ...] [--json report.json]
//! stress-ref check <scenes-dir> <golden-dir> [--only NAME] [--json report.json]
//! ```
//!
//! `check` runs every scene, compares against analytic expectations and every golden
//! oracle observation in `<golden-dir>/<scene>/*.json`, and exits non-zero on failure.

use std::path::{Path, PathBuf};
use std::process::ExitCode;

use stress_ref::builders;
use stress_ref::metrics::{compare, format_table, Comparison};
use stress_ref::observation::Observation;
use stress_ref::scene::Scene;
use stress_ref::world::World;

fn usage() -> ExitCode {
    eprintln!("usage: stress-ref gen-scenes <dir> | run <scene> [opts] | compare <scene> <ours> [oracles..] | check <scenes> <golden>");
    ExitCode::from(2)
}

fn flag(args: &[String], name: &str) -> Option<String> {
    args.iter().position(|a| a == name).and_then(|i| args.get(i + 1)).cloned()
}

fn positional(args: &[String]) -> Vec<String> {
    let mut out = Vec::new();
    let mut skip = false;
    for a in args {
        if skip {
            skip = false;
            continue;
        }
        if a.starts_with("--") {
            skip = true;
            continue;
        }
        out.push(a.clone());
    }
    out
}

fn apply_overrides(scene: &mut Scene, args: &[String]) -> Result<(), String> {
    if let Some(v) = flag(args, "--seed") {
        scene.sim.seed = v.parse().map_err(|e| format!("--seed: {e}"))?;
    }
    if let Some(v) = flag(args, "--mode") {
        scene.sim.solve_mode = serde_json::from_value(serde_json::Value::String(v)).map_err(|e| format!("--mode: {e}"))?;
    }
    if let Some(v) = flag(args, "--stiffness-scale") {
        scene.sim.stiffness_scale = v.parse().map_err(|e| format!("--stiffness-scale: {e}"))?;
    }
    if let Some(v) = flag(args, "--max-substep") {
        scene.sim.max_substep = Some(v.parse().map_err(|e| format!("--max-substep: {e}"))?);
    }
    if let Some(v) = flag(args, "--frame-dt") {
        scene.sim.frame_dt = v.parse().map_err(|e| format!("--frame-dt: {e}"))?;
    }
    Ok(())
}

fn run_scene(scene: &Scene) -> Observation {
    let start = std::time::Instant::now();
    let mut world = World::new(scene);
    let mut obs = world.run();
    obs.values.insert("wall_seconds".into(), start.elapsed().as_secs_f64());
    obs
}

fn load_goldens(dir: &Path) -> Vec<Observation> {
    let mut out = Vec::new();
    if let Ok(entries) = std::fs::read_dir(dir) {
        let mut paths: Vec<PathBuf> = entries.filter_map(|e| e.ok().map(|e| e.path())).collect();
        paths.sort();
        for p in paths {
            if p.extension().is_some_and(|e| e == "json") && !p.file_name().unwrap().to_string_lossy().starts_with("provenance") {
                match Observation::load(&p) {
                    Ok(o) => out.push(o),
                    Err(e) => eprintln!("warning: {e}"),
                }
            }
        }
    }
    out
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let Some(cmd) = args.first().cloned() else { return usage() };
    let rest = &args[1..];
    let pos = positional(rest);
    let result: Result<bool, String> = (|| match cmd.as_str() {
        "gen-scenes" => {
            let dir = PathBuf::from(pos.first().ok_or("missing <dir>")?);
            std::fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
            for scene in builders::catalog() {
                scene.validate()?;
                let path = dir.join(format!("{}.json", scene.name));
                // Large scenes are written compactly; both forms parse identically.
                let derived = scene.with_derived();
                let chunks: usize = derived.bodies.iter().map(|b| b.chunks.len()).sum();
                let text = if chunks < 300 { derived.to_json_pretty() } else { serde_json::to_string(&derived).unwrap() };
                std::fs::write(&path, text + "\n").map_err(|e| e.to_string())?;
                println!("wrote {}", path.display());
            }
            Ok(true)
        }
        "with-seed" => {
            // Re-derive a scene for another Weibull seed (exporters read derived.weibull).
            let mut scene = Scene::load(Path::new(pos.first().ok_or("missing <scene>")?))?;
            scene.sim.seed = pos.get(1).ok_or("missing <seed>")?.parse().map_err(|e| format!("seed: {e}"))?;
            let out = pos.get(2).ok_or("missing <out>")?;
            std::fs::write(out, serde_json::to_string(&scene.with_derived()).unwrap() + "\n").map_err(|e| e.to_string())?;
            Ok(true)
        }
        "run" => {
            let mut scene = Scene::load(Path::new(pos.first().ok_or("missing <scene>")?))?;
            apply_overrides(&mut scene, rest)?;
            let obs = run_scene(&scene);
            let text = obs.to_json_pretty();
            match flag(rest, "--out") {
                Some(p) => std::fs::write(&p, text + "\n").map_err(|e| e.to_string())?,
                None => println!("{text}"),
            }
            let rows = compare(&scene, &obs, &[]);
            eprint!("{}", format_table(&scene.name, &rows));
            Ok(rows.iter().all(|r| r.pass != Some(false)))
        }
        "compare" => {
            let scene = Scene::load(Path::new(pos.first().ok_or("missing <scene>")?))?;
            let ours = Observation::load(Path::new(pos.get(1).ok_or("missing <ours>")?))?;
            let oracles: Vec<Observation> = pos[2..].iter().map(|p| Observation::load(Path::new(p))).collect::<Result<_, _>>()?;
            let rows = compare(&scene, &ours, &oracles);
            print!("{}", format_table(&scene.name, &rows));
            if let Some(p) = flag(rest, "--json") {
                std::fs::write(p, serde_json::to_string_pretty(&rows).unwrap()).map_err(|e| e.to_string())?;
            }
            Ok(rows.iter().all(|r| r.pass != Some(false)))
        }
        "check" => {
            let scenes = PathBuf::from(pos.first().ok_or("missing <scenes-dir>")?);
            let golden = PathBuf::from(pos.get(1).ok_or("missing <golden-dir>")?);
            let only = flag(rest, "--only");
            let mut paths: Vec<PathBuf> = std::fs::read_dir(&scenes)
                .map_err(|e| format!("{}: {e}", scenes.display()))?
                .filter_map(|e| e.ok().map(|e| e.path()))
                .filter(|p| p.extension().is_some_and(|e| e == "json"))
                .collect();
            paths.sort();
            let mut all: Vec<(String, Vec<Comparison>)> = Vec::new();
            let mut ok = true;
            for p in paths {
                let mut scene = Scene::load(&p)?;
                if only.as_ref().is_some_and(|o| !scene.name.contains(o.as_str())) {
                    continue;
                }
                apply_overrides(&mut scene, rest)?;
                {
                    let obs = run_scene(&scene);
                    let oracles = load_goldens(&golden.join(&scene.name));
                    let rows = compare(&scene, &obs, &oracles);
                    print!("{}", format_table(&scene.name, &rows));
                    ok &= rows.iter().all(|r| r.pass != Some(false));
                    all.push((scene.name.clone(), rows));
                }
            }
            if let Some(p) = flag(rest, "--json") {
                std::fs::write(p, serde_json::to_string_pretty(&all).unwrap()).map_err(|e| e.to_string())?;
            }
            Ok(ok)
        }
        _ => Err(format!("unknown command '{cmd}'")),
    })();
    match result {
        Ok(true) => ExitCode::SUCCESS,
        Ok(false) => {
            eprintln!("some metrics failed");
            ExitCode::FAILURE
        }
        Err(e) => {
            eprintln!("error: {e}");
            ExitCode::from(2)
        }
    }
}
