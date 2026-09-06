#!/usr/bin/env python3
"""Validate and summarize --profile-phases 1 native captures (host wall time)."""
import argparse
import collections
import csv
import json
import math
from pathlib import Path
import statistics

PREFIX = "GpuDestruction."
ALWAYS = {"submit", "finishAndReserve", "collisionBindings", "correctionBodies"}
CORRECTION = {"applyBindings", "restoreInstall", "correctedCollisionSolve", "refilter", "acceptCorrection"}
# refilter is nested inside correctedCollisionSolve; never add both to totals.
INDEPENDENT = ALWAYS | (CORRECTION - {"refilter"}) | {"initializeReserved"}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def analyze(directory):
    summary = json.loads((directory / "native.summary.json").read_text())
    frames = list(csv.DictReader((directory / "native.frames.csv").open()))
    phases = list(csv.DictReader((directory / "native.phases.csv").open()))
    require(summary["status"] == "completed", "capture did not complete")
    require(len(frames) == summary["frames"], "frame count mismatch")
    by_step = collections.defaultdict(dict)
    for row in phases:
        step = int(row["step"])
        name = row["phase"]
        require(name.startswith(PREFIX), "unexpected phase name")
        name = name[len(PREFIX):]
        require(0 <= step < len(frames), "phase has invalid step")
        require(row["accepted_step"] == "1", "phase belongs to an incomplete step")
        require(name not in by_step[step], f"duplicate phase: {step}/{name}")
        elapsed = float(row["host_wall_ms"])
        require(math.isfinite(elapsed) and elapsed >= 0, "invalid phase duration")
        by_step[step][name] = elapsed
    corrected = []
    totals = collections.defaultdict(list)
    residuals = []
    for i, frame in enumerate(frames):
        require(int(frame["step"]) == i, "frame order mismatch")
        require(int(frame["stress_converged"]) == 1 and int(frame["correction_status"]) == 0,
                f"unconverged or incomplete step {i}")
        passes = int(frame["resim_passes"])
        require(passes in (0, 1), "more than one correction")
        values = by_step[i]
        require(ALWAYS <= values.keys(), f"missing native phases at step {i}")
        if passes:
            require(CORRECTION <= values.keys(), f"missing correction phases at step {i}")
            require(values["refilter"] <= values["correctedCollisionSolve"], "invalid nested refilter duration")
            corrected.append(values)
        else:
            require(not (CORRECTION & values.keys()), f"correction phase on intact step {i}")
        residual = float(frame["physics_step_ms"]) - sum(values.get(name, 0) for name in INDEPENDENT)
        require(residual >= -0.05, "phase total exceeds complete physics step (allowing CSV rounding)")
        residuals.append(max(0, residual))
        for name, value in values.items():
            totals[name].append(value)
    require(len(corrected) == summary["corrections"], "correction count mismatch")
    require(corrected, "capture contains no correction")
    return {
        "status": "validated-native-phase-capture",
        "frames": len(frames),
        "corrected_steps": len(corrected),
        "timing_kind": "host wall intervals, including GPU waits; not CUDA kernel timings",
        "profiling_overhead_in_simulation_time": True,
        "nested_phase": "refilter is included in correctedCollisionSolve",
        "unmeasured_interval": "ordinary trial, checkpoint, remaining PhysX work and callback overhead",
        "phases": {name: {"samples": len(values), "mean_ms": statistics.mean(values),
                          "median_ms": statistics.median(values), "max_ms": max(values)}
                   for name, values in sorted(totals.items())},
        "corrected_step_mean_ms": {name: statistics.mean(v.get(name, 0) for v in corrected)
                                  for name in sorted(INDEPENDENT | {"refilter"})},
        "corrected_pass_excluding_refilter_mean_ms": statistics.mean(
            v["correctedCollisionSolve"] - v["refilter"] for v in corrected),
        "unmeasured_interval_mean_ms": statistics.mean(residuals),
        "isolated_performance_qualification": False,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("capture", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    try:
        text = json.dumps(analyze(args.capture), indent=2) + "\n"
    except (ValueError, KeyError, OSError) as error:
        parser.exit(1, f"Invalid phase capture: {error}\n")
    if args.output:
        args.output.write_text(text)
    else:
        print(text, end="")
