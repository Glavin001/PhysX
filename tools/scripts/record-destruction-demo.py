#!/usr/bin/env python3
"""Record actual PhysX GPU destruction, preserving commands and validation evidence.

This deliberately identifies the current CPU-orchestrated reference backend.
It is a development demo, not integrated-engine or 60 Hz qualification.
"""
import argparse
import csv
import datetime as dt
import hashlib
import json
import math
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
SCENES = {
    "wall": ("blast/blast-stress-solver/assets/reference/crush-wall.json", 8, 1, 1.4),
    "building": ("blast/blast-stress-solver/assets/reference/reference-building-crush.json", 10, 8, 1),
    "city": ("blast/blast-stress-solver/assets/reference/reference-building-crush.json", 58, 8, 2),
}


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def validate_capture(metadata_path, frames_path):
    data = json.loads(metadata_path.read_text())
    with frames_path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    require(rows, "capture has no physics steps")
    require(data["gpuActive"] and data["physicsMode"] == "gpu", "GPU physics was not active")
    require(data["gpuStressRequested"] and data["gpuStressSolveMilliseconds"] > 0,
            "capture contains no CUDA stress work")
    correction = data["resimulation"]
    require(correction["completeCorrectionRequired"] and correction["incompleteFrames"] == 0,
            "capture contains incomplete correction")
    require(not correction["scoped"] and not correction["quietCaptureSkip"],
            "capture must use full-scene checkpoints and correction")
    require(correction["passesTotal"] > 0, "capture contains no corrected interaction")
    require(data["contactsDropped"] == 0, "capture dropped required contacts")
    require(data["projectileImpactContacts"] > 0 and data["projectileImpactImpulse"] > 0,
            "capture contains no actual projectile impulse")
    require(data["splits"] > 0 and data["destructionMotion"]["movedChunks"] > 0,
            "capture contains no visible fracture motion")
    continuity_passed = (data["maxSplitWorldPositionDrift"] <= 1e-3 and
                         data["maxSplitPointVelocityDrift"] <= 1e-3)
    required = ["step", "simulation_seconds", "frame_host_ms", "gpu_stress_solve_ms",
                "correction_status", "resim_bodies_frozen", "contacts_dropped_total",
                "splits_total", "chunks_crushed_total", "resim_passes"]
    require(all(k in rows[0] for k in required), "required capture diagnostics are missing")
    for i, row in enumerate(rows):
        require(int(row["step"]) == i, "physics step sequence has a gap")
        require(all(math.isfinite(float(value)) for value in row.values()), "non-finite frame diagnostic")
        require(int(row["correction_status"]) == 0, f"incomplete correction at step {i}")
        require(int(row["resim_bodies_frozen"]) == 0, f"artificially frozen body at step {i}")
        require(int(row["contacts_dropped_total"]) == 0, f"contact overflow at step {i}")
        if float(row["simulation_seconds"]) < 2:
            require(int(row["splits_total"]) == 0 and int(row["chunks_crushed_total"]) == 0,
                    "structure changed topology before projectile launch")
    def timing_summary(values):
        values = sorted(values)
        def percentile(p):
            return values[max(0, math.ceil(p * len(values)) - 1)]
        return {"p50": percentile(.5), "p95": percentile(.95), "p99": percentile(.99),
                "worst": values[-1], "total": sum(values),
                "missed16_67ms": sum(t > 1000 / 60 for t in values)}
    if data["tuning"].get("keepProjectiles"):
        active = [int(row["projectiles_active"]) for row in rows]
        require(all(a <= b for a, b in zip(active, active[1:])), "launched projectiles were retired")
        require(active[-1] == data["tuning"]["projectileCount"], "not all projectiles launched")
    phases = ["frame_host_ms", "physics_step_ms", "stress_solve_ms", "gpu_stress_solve_ms",
              "contact_processing_ms", "fracture_topology_ms", "state_export_ms",
              "resim_capture_ms", "resim_restore_ms", "resim_simulate_submit_ms",
              "resim_fetch_results_ms", "resim_tick_ms"]
    return {
        "validationPassed": continuity_passed,
        "validationFailures": [] if continuity_passed else ["split continuity exceeded reference tolerance"],
        "continuity": {"maxPositionDriftMetres": data["maxSplitWorldPositionDrift"],
                       "maxPointVelocityDriftMps": data["maxSplitPointVelocityDrift"],
                       "tolerance": 1e-3},
        "backend": "reference: PhysX GPU + CUDA stress, CPU fracture/replay orchestration",
        "qualification": "development capture only; not an isolated performance campaign",
        "steps": len(rows), "chunks": data["authoredChunkCount"],
        "authoredBonds": data.get("authoredBondCount"),
        "buildings": data["buildingCount"],
        "finalBodies": int(rows[-1]["bodies"]),
        "peakDestructionBodies": max(int(r["bodies"]) for r in rows),
        "peakAwakeDestructionBodies": max(int(r["awake_bodies"]) for r in rows),
        "peakDestructionBodiesAndLaunchedProjectiles": max(int(r["bodies"]) + int(r["projectiles_active"]) for r in rows),
        "projectilesRetainedAtEnd": int(rows[-1]["projectiles_active"]),
        "splits": data["splits"], "crushedChunks": int(rows[-1]["chunks_crushed_total"]),
        "motion": data["destructionMotion"], "tuning": data["tuning"],
        "simulationSeconds": len(rows) / 60,
        "simulationWallSeconds": data["wallSeconds"],
        "processedContacts": int(rows[-1]["contacts_total"]),
        "peakContactsPerStep": max(int(r["contacts_frame"]) for r in rows),
        "stressTransferBytes": {k: sum(int(r[k]) for r in rows)
                                for k in ("gpu_stress_h2d_bytes", "gpu_stress_d2h_bytes")},
        "timingPhasesOverlap": True,
        "phaseMilliseconds": {k: timing_summary([float(r[k]) for r in rows]) for k in phases},
        "projectileImpulseNs": data["projectileImpactImpulse"],
        "correctionPasses": correction["passesTotal"], "incompleteSteps": 0,
        "droppedContacts": 0, "frozenOutsiders": 0,
        "gpuStressMilliseconds": data["gpuStressSolveMilliseconds"],
        "frameHostMilliseconds": timing_summary([float(r["frame_host_ms"]) for r in rows]),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", action="store_true", help="build this checkout's SDK and recorder first")
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--scenes", nargs="+", choices=SCENES, default=["wall", "building"])
    parser.add_argument("--city-grid", type=int, default=12, help="city width in buildings (1..64)")
    parser.add_argument("--city-duration", type=float, default=58, help="bombardment + aftermath, plus 2s settling")
    parser.add_argument("--city-waves", type=int, default=4)
    parser.add_argument("--city-target-stride", type=int, default=1,
                        help="attack every Nth row/column; all city structures remain simulated")
    parser.add_argument("--render-diagnostic-on-failure", action="store_true",
                        help="render complete captures with failed validation, label them, and exit nonzero")
    parser.add_argument("--city-launch-window", type=float, default=48)
    args = parser.parse_args()
    require(args.jobs > 0, "jobs must be positive")
    require(1 <= args.city_grid <= 64 and 1 <= args.city_waves <= 256, "invalid city size/waves")
    require(math.isfinite(args.city_duration) and math.isfinite(args.city_launch_window)
            and 0 <= args.city_launch_window < args.city_duration, "invalid city launch duration")
    require(1 <= args.city_target_stride <= args.city_grid, "invalid target stride")
    require(len(set(args.scenes)) == len(args.scenes), "scene names must be unique")
    for program in ("ffmpeg", "ffprobe", "nvidia-smi"):
        require(shutil.which(program), f"required tool missing: {program}")
    if args.build:
        subprocess.run([sys.executable, str(ROOT / "tools/scripts/build-destruction-sdk.py"),
                        "--jobs", str(args.jobs)], cwd=ROOT, check=True)
        subprocess.run(["cargo", "build", "--release", "--locked", "-j", str(args.jobs)],
                       cwd=ROOT / "demos/blast-stress-demo/recorder", check=True)
    sim = ROOT / "out/destruction-sdk/reference/blast_stress_demo"
    recorder = ROOT / "demos/blast-stress-demo/recorder/target/release/blast-mini-city-recorder"
    for path in (sim, recorder):
        require(path.is_file(), f"missing {path}; run with --build")
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d-%H%M%S")
    output = (args.output_dir or ROOT / "out/recordings" / stamp).resolve()
    output.mkdir(parents=True, exist_ok=False)  # never mix stale and fresh evidence
    manifest = {"status": "running", "startedUtc": stamp,
                "backend": "external-reference", "engineIntegrationComplete": False,
                "rendering": "offline playback of captured simulation at 60 fps",
                "commands": [], "scenes": {}, "inputs": {},
                "revision": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
                "workingTree": subprocess.check_output(["git", "status", "--short"], cwd=ROOT, text=True),
                "workingDiffSha256": hashlib.sha256(subprocess.check_output(
                    ["git", "diff", "HEAD", "--binary"], cwd=ROOT)).hexdigest()}
    manifest_path = output / "manifest.json"
    def save():
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    def run(command, log_name, allow_failure=False):
        command = [str(x) for x in command]
        manifest["commands"].append(command)
        save()
        with (output / log_name).open("w") as log:
            completed = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
        require(allow_failure or completed.returncode == 0, f"command failed; see {output / log_name}")
        return completed.returncode
    try:
        for path in [sim, recorder, Path(__file__).resolve(),
                     *sorted((ROOT / "physx/bin/linux.x86_64/release").glob("*.so"))]:
            manifest["inputs"][str(path.relative_to(ROOT))] = digest(path)
        run(["nvidia-smi", "--query-gpu=name,uuid,driver_version,memory.used,utilization.gpu", "--format=csv"],
            "gpu-before.csv")
        for name in args.scenes:
            relative, duration, mass, speed = SCENES[name]
            scene = ROOT / relative
            pack = json.loads(scene.read_text())
            require(pack["defaults"]["physics"]["contactForceScale"] == 1,
                    "recording requires authored unity contact transfer")
            manifest["inputs"][relative] = digest(scene)
            prefix = output / name
            city = name == "city"
            if city:
                duration = args.city_duration
            extra = (["--projectile-pattern", "overhead", "--keep-projectiles",
                      "--projectile-launch-window", args.city_launch_window,
                      "--projectile-target-stride", args.city_target_stride] if city else [])
            print(f"Simulating {name} with strict GPU/correction checks", flush=True)
            # Sample the shared GPU throughout simulation. Stop only our sampler;
            # never modify other processes to manufacture benchmark isolation.
            gpu_log = (output / f"{name}.gpu.csv").open("w")
            sampler_command = [
                "nvidia-smi", "--query-gpu=timestamp,name,memory.used,utilization.gpu,utilization.memory,power.draw,temperature.gpu",
                "--format=csv,nounits", "--loop-ms=500"]
            manifest["commands"].append(sampler_command)
            save()
            sampler = subprocess.Popen(sampler_command, stdout=gpu_log, stderr=subprocess.STDOUT)
            try:
                native_exit = run([sim, "--scene", scene, "--physics", "gpu", "--require-gpu",
                     "--gpu-stress", "--gpu-stress-min-bonds", "0", "--grid", args.city_grid if city else 1,
                     "--uniform-building-heights", "--duration", duration, "--settle", "2",
                     "--projectile-waves", args.city_waves if city else 1, "--projectile-mass-scale", mass,
                     "--projectile-speed-scale", speed, "--projectile-ttl-scale", "2",
                     "--contact-force-scale", "1", "--resim-passes", "64" if city else "8",
                     "--no-scoped-resim", "--no-quiet-capture-skip", "--require-complete-correction",
                     *extra, "--snapshot-fps", "60", "--state", prefix.with_suffix(".twstate"),
                     "--metadata", prefix.with_suffix(".json"), "--frame-telemetry", prefix.with_suffix(".frames.csv")],
                    f"{name}.simulation.log", allow_failure=args.render_diagnostic_on_failure)
            finally:
                sampler.terminate()
                sampler.wait(timeout=10)
                gpu_log.close()
            report = validate_capture(prefix.with_suffix(".json"), prefix.with_suffix(".frames.csv"))
            require(report["steps"] == math.ceil((duration + 2) * 60), "simulation capture is incomplete")
            report["nativeExitCode"] = native_exit
            if native_exit:
                report["validationPassed"] = False
                report["validationFailures"].append(f"native contract failed (exit {native_exit}); inspect simulation log")
            (output / f"{name}.validation.json").write_text(json.dumps(report, indent=2) + "\n")
            manifest["scenes"][name] = report
            save()
            require(report["validationPassed"] or args.render_diagnostic_on_failure,
                    "; ".join(report["validationFailures"]))
            failure_title = "VALIDATION FAILED | " if not report["validationPassed"] else ""
            print(f"Rendering {name}: actual captured states; validationPassed={report['validationPassed']}", flush=True)
            run([recorder, "render", "--state", prefix.with_suffix(".twstate"),
                 "--frame-telemetry", prefix.with_suffix(".frames.csv"),
                 "--camera", "0", "--compact-hud", "--ground-y", "0",
                 "--camera-margin", "0.08" if city else "0.5",
                 "--title", failure_title + (f"{report['chunks']:,} CHUNKS | {report['authoredBonds']:,} BONDS | "
                             f"{report['tuning']['projectileCount']} SHOTS | PhysX GPU reference"
                             if city else f"{name.upper()} | PhysX GPU + CUDA stress | CPU orchestration (reference)"),
                 "--output", prefix.with_suffix(".mp4")], f"{name}.render.log")
            if city:
                # This is a second view of the same captured world, never a smaller simulation.
                pitch = 18.0  # native demo city spacing
                origin = -(args.city_grid - 1) * pitch * 0.5
                column = (args.city_grid // 2 // args.city_target_stride) * args.city_target_stride
                row = args.city_target_stride if args.city_target_stride < args.city_grid else 0
                run([recorder, "render", "--state", prefix.with_suffix(".twstate"),
                     "--frame-telemetry", prefix.with_suffix(".frames.csv"), "--camera", "0",
                     "--compact-hud", "--ground-y", "0", "--focus-center",
                     origin + column * pitch, "8", origin + row * pitch, "--focus-radius", "30",
                     "--title", failure_title + f"NEIGHBORHOOD VIEW | {report['chunks']:,}-chunk world | PhysX GPU reference",
                     "--output", output / "city-detail.mp4"], "city-detail.render.log")
        # Names above are fixed identifiers; ffmpeg's concat file needs no path escaping.
        concat = output / "clips.txt"
        concat.write_text("".join(f"file '{name}.mp4'\n" for name in args.scenes))
        video = output / "physx-gpu-destruction-demo.mp4"
        run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "concat", "-safe", "1",
             "-i", concat, "-c", "copy", "-movflags", "+faststart", video], "compose.log")
        probe = json.loads(subprocess.check_output([
            "ffprobe", "-v", "error", "-select_streams", "v:0", "-count_frames", "-show_entries",
            "stream=codec_name,width,height,r_frame_rate,nb_read_frames:format=duration", "-of", "json", str(video)]))
        expected_frames = sum(report["steps"] + 1 for report in manifest["scenes"].values())
        stream = probe["streams"][0]
        require(stream["codec_name"] == "h264" and stream["width"] == 1920 and stream["height"] == 1080,
                "encoded video format mismatch")
        require(stream["r_frame_rate"] == "60/1" and int(stream["nb_read_frames"]) == expected_frames,
                "encoded video lost or duplicated frames")
        run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-i", video, "-f", "null", "-"], "decode-check.log")
        run(["nvidia-smi", "--query-gpu=name,uuid,driver_version,memory.used,utilization.gpu", "--format=csv"],
            "gpu-after.csv")
        all_passed = all(r["validationPassed"] for r in manifest["scenes"].values())
        manifest.update(status="complete" if all_passed else "diagnostic-failed-validation", video=str(video), videoProbe=probe,
                        artifacts={p.name: digest(p) for p in sorted(output.iterdir())
                                   if p.is_file() and p != manifest_path})
        save()
        print(video)
        print(f"Evidence: {manifest_path}")
        return 0 if all_passed else 2
    except Exception as error:
        manifest.update(status="failed", error=str(error))
        save()
        raise


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"recording failed: {error}", file=sys.stderr)
        sys.exit(1)
