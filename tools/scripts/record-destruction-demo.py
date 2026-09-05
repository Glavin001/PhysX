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
    require(data["maxSplitWorldPositionDrift"] <= 1e-3 and
            data["maxSplitPointVelocityDrift"] <= 1e-3, "split continuity exceeded reference tolerance")
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
    times = sorted(float(row["frame_host_ms"]) for row in rows)
    def percentile(p):
        return times[max(0, math.ceil(p * len(times)) - 1)]
    return {
        "backend": "reference: PhysX GPU + CUDA stress, CPU fracture/replay orchestration",
        "qualification": "development capture only; not an isolated performance campaign",
        "steps": len(rows), "chunks": data["authoredChunkCount"],
        "finalBodies": data["bodyCount"], "splits": data["splits"],
        "projectileImpulseNs": data["projectileImpactImpulse"],
        "correctionPasses": correction["passesTotal"], "incompleteSteps": 0,
        "droppedContacts": 0, "frozenOutsiders": 0,
        "gpuStressMilliseconds": data["gpuStressSolveMilliseconds"],
        "frameHostMilliseconds": {"p50": percentile(.5), "p95": percentile(.95),
                                  "p99": percentile(.99), "worst": times[-1],
                                  "missed16_67ms": sum(t > 1000 / 60 for t in times)},
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", action="store_true", help="build this checkout's SDK and recorder first")
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--scenes", nargs="+", choices=SCENES, default=list(SCENES))
    args = parser.parse_args()
    require(args.jobs > 0, "jobs must be positive")
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
    def run(command, log_name):
        command = [str(x) for x in command]
        manifest["commands"].append(command)
        save()
        with (output / log_name).open("w") as log:
            completed = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
        require(completed.returncode == 0, f"command failed; see {output / log_name}")
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
            print(f"Simulating {name} with strict GPU/correction checks", flush=True)
            run([sim, "--scene", scene, "--physics", "gpu", "--require-gpu",
                 "--gpu-stress", "--gpu-stress-min-bonds", "0", "--grid", "1",
                 "--uniform-building-heights", "--duration", duration, "--settle", "2",
                 "--projectile-waves", "1", "--projectile-mass-scale", mass,
                 "--projectile-speed-scale", speed, "--projectile-ttl-scale", "2",
                 "--contact-force-scale", "1", "--resim-passes", "8",
                 "--no-scoped-resim", "--no-quiet-capture-skip", "--require-complete-correction",
                 "--snapshot-fps", "60", "--state", prefix.with_suffix(".twstate"),
                 "--metadata", prefix.with_suffix(".json"), "--frame-telemetry", prefix.with_suffix(".frames.csv")],
                f"{name}.simulation.log")
            report = validate_capture(prefix.with_suffix(".json"), prefix.with_suffix(".frames.csv"))
            (output / f"{name}.validation.json").write_text(json.dumps(report, indent=2) + "\n")
            manifest["scenes"][name] = report
            save()
            print(f"Rendering {name}: actual captured states", flush=True)
            run([recorder, "render", "--state", prefix.with_suffix(".twstate"),
                 "--frame-telemetry", prefix.with_suffix(".frames.csv"),
                 "--camera", "0", "--compact-hud", "--ground-y", "0",
                 "--title", f"{name.upper()} | PhysX GPU + CUDA stress | CPU orchestration (reference)",
                 "--output", prefix.with_suffix(".mp4")], f"{name}.render.log")
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
        manifest.update(status="complete", video=str(video), videoProbe=probe,
                        artifacts={p.name: digest(p) for p in sorted(output.iterdir())
                                   if p.is_file() and p != manifest_path})
        save()
        print(video)
        print(f"Evidence: {manifest_path}")
    except Exception as error:
        manifest.update(status="failed", error=str(error))
        save()
        raise


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"recording failed: {error}", file=sys.stderr)
        sys.exit(1)
