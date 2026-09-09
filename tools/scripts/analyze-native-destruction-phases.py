#!/usr/bin/env python3
"""Validate and summarize --profile-phases 1 native captures (host wall time)."""
import argparse
import collections
import csv
import gzip
import json
import math
from pathlib import Path
import statistics

PREFIX = "GpuDestruction."
ALWAYS = {"submit", "finishAndReserve", "collisionBindings", "correctionBodies"}
CORRECTION = {"applyBindings", "restoreInstall", "correctedCollisionSolve", "refilter", "acceptCorrection"}
# refilter is nested inside correctedCollisionSolve; never add both to totals.
INDEPENDENT = ALWAYS | (CORRECTION - {"refilter"}) | {"initializeReserved", "publishReservedMetadata", "resetContactCaches", "preparationCompletion"}


def open_capture(path):
    return path.open() if path.exists() else gzip.open(str(path) + ".gz", "rt")


def require(condition, message):
    if not condition:
        raise ValueError(message)


CUDA_STAGES = {"contactLoads", "stress", "materials", "topologyAndCandidates", "commitAndStressTopology"}


CUDA_OPTIONAL_STAGES = {"motionAllocation", "motionAllocationRetry", "allocationAndPreparation", "allocationAndPreparationRetry"}


CUDA_CORRECTION_STAGES = {"rewindState", "installFragments", "installOwners", "finalSplitState", "finalSplitFragments", "finalSplitOwners"}


def cuda_stages(directory, count, passes=None):
    path = directory / "native.phases.csv.device.csv"
    if not path.exists() and not Path(str(path) + ".gz").exists():
        return None  # Legacy host-only captures remain readable.
    values = collections.defaultdict(dict)
    occurrences = collections.Counter()
    passes = passes or [1] * count
    with open_capture(path) as stream:
        for row in csv.DictReader(stream):
            step, name = int(row["step"]), row["phase"]
            require(name.startswith(PREFIX + "cuda."), "unexpected CUDA stage")
            name = name[len(PREFIX + "cuda."):]
            require(name in CUDA_STAGES | CUDA_CORRECTION_STAGES | CUDA_OPTIONAL_STAGES and 0 <= step < count, "invalid CUDA stage or step")
            require(row["accepted_step"] == "1", "CUDA stage from incomplete step")
            occurrences[step, name] += 1
            require(occurrences[step, name] <= (1 if name in CUDA_CORRECTION_STAGES else passes[step]), "duplicate CUDA stage")
            elapsed = float(row["cuda_elapsed_ms"])
            require(math.isfinite(elapsed) and elapsed >= 0, "invalid CUDA elapsed time")
            values[step][name] = values[step].get(name, 0) + elapsed
    require(len(values) == count and all(CUDA_STAGES <= set(values[i]) for i in range(count)),
            "missing CUDA stage measurements")
    require(all(occurrences[i, name] == passes[i] for i in range(count) for name in CUDA_STAGES),
            "missing stress evaluation CUDA measurements")
    device_preparation = any('allocationAndPreparation' in v for v in values.values())
    if device_preparation:
        require(all(occurrences[i, 'allocationAndPreparation'] == passes[i] for i in range(count)),
                'missing device preparation CUDA measurements')
        require(not any(name in v for v in values.values() for name in ('motionAllocation','motionAllocationRetry')),
                'mixed preparation protocols')
    def summarize(samples):
        ordered = sorted(samples)
        return dict(samples=len(samples), min_ms=min(samples), mean_ms=statistics.mean(samples),
                    max_ms=max(samples), p95_ms=ordered[min(len(samples)-1, int(.95*len(samples)))])
    optional = {name: summarize([values[i].get(name, 0) for i in range(count)])
                for name in sorted(CUDA_OPTIONAL_STAGES) if any(name in v for v in values.values())}
    return dict(device_controlled_preparation=device_preparation, optional_phases=optional, scope="Consecutive CUDA event intervals on the destruction stream; includes cross-stream dependencies, "
                      "contention and host submission gaps, not pure kernel execution. Excludes ordinary/corrected rigid solving, "
                      "reservation and acceptance after correction. Optional allocation/retry intervals are reported separately; they are not included in this total. Collected after an existing completion wait, with no added synchronization.",
                phases={name: summarize([values[i][name] for i in range(count)]) for name in sorted(CUDA_STAGES)},
                total=summarize([sum(values[i][name] for name in CUDA_STAGES) for i in range(count)]))


def analyze(directory):
    summary = json.loads((directory / "native.summary.json").read_text())
    with open_capture(directory / "native.frames.csv") as stream:
        frames = list(csv.DictReader(stream))
    with open_capture(directory / "native.phases.csv") as stream:
        phases = list(csv.DictReader(stream))
    require(summary["status"] == "completed", "capture did not complete")
    require(len(frames) == summary["frames"], "frame count mismatch")
    stress_passes = [int(f.get("stress_passes", 1)) for f in frames]
    for i, f in enumerate(frames):
        if "stress_passes" in f:
            require(stress_passes[i] == 1 + int(f["resim_passes"]), "invalid stress evaluation count")
    device = cuda_stages(directory, len(frames), stress_passes)
    required = ({"submit", "finishAndReserve", "preparationCompletion"}
                if device and device['device_controlled_preparation'] else ALWAYS)
    by_step = collections.defaultdict(dict)
    occurrences = collections.Counter()
    for row in phases:
        step = int(row["step"])
        name = row["phase"]
        require(name.startswith(PREFIX), "unexpected phase name")
        name = name[len(PREFIX):]
        require(0 <= step < len(frames), "phase has invalid step")
        require(row["accepted_step"] == "1", "phase belongs to an incomplete step")
        occurrences[step, name] += 1
        limit = 1 if name in {"correctedCollisionSolve", "refilter", "resetContactCaches"} else stress_passes[step]
        require(name.startswith(("task.", "detail.", "trialDetail.", "migrateDetail.")) or occurrences[step, name] <= limit, f"duplicate phase: {step}/{name}")
        elapsed = float(row["host_wall_ms"])
        require(math.isfinite(elapsed) and elapsed >= 0, "invalid phase duration")
        by_step[step][name] = by_step[step].get(name, 0) + elapsed
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
        require(required <= values.keys(), f"missing native phases at step {i}")
        if "finishDetail.waitForGpu" in values:
            require({"finishDetail.reserveBodies"} <= values.keys(), "missing reservation timing")
            require(values["finishDetail.waitForGpu"] + values["finishDetail.reserveBodies"] <= values["finishAndReserve"] + .05,
                    "finish detail exceeds its parent")
            reservation_children = ("requestReadback", "allocateNativeBodies", "uploadBindings", "publishReservation")
            require(sum(values.get("finishDetail." + name, 0) for name in reservation_children)
                    <= values["finishDetail.reserveBodies"] + .05, "reservation details exceed their parent")
        if passes:
            require(CORRECTION <= values.keys(), f"missing correction phases at step {i}")
            require(values["refilter"] <= values["correctedCollisionSolve"], "invalid nested refilter duration")
            corrected.append(values)
        else:
            require(not ((CORRECTION | {"resetContactCaches"}) & values.keys()), f"correction phase on intact step {i}")
        residual = float(frame["physics_step_ms"]) - sum(values.get(name, 0) for name in INDEPENDENT)
        require(residual >= -0.05, "phase total exceeds complete physics step (allowing CSV rounding)")
        residuals.append(max(0, residual))
        for name, value in values.items():
            totals[name].append(value)
    require(len(corrected) == summary["corrections"], "correction count mismatch")
    require(corrected, "capture contains no correction")
    def timing(column):
        values = [float(frame[column]) for frame in frames]
        require(all(math.isfinite(x) and x > 0 for x in values), "invalid step timing")
        ordered = sorted(values)
        mean = statistics.mean(values)
        fixed_ms = 1000.0 * summary["seconds"] / len(frames)
        return {"samples": len(values), "min_ms": min(values), "mean_ms": mean,
                "max_ms": max(values), "p50_ms": statistics.median(values),
                "p95_ms": ordered[min(len(values)-1, int(.95*len(values)))],
                "p99_ms": ordered[min(len(values)-1, int(.99*len(values)))],
                "total_wall_seconds": sum(values)/1000.0,
                "effective_steps_per_second": 1000.0/mean,
                "real_time_factor": fixed_ms/mean,
                "missed_deadlines": sum(x > fixed_ms for x in values),
                "fixed_step_ms": fixed_ms}
    return {
        "status": "validated-native-phase-capture",
        "physics_timing": timing("physics_step_ms"),
        "cuda_stages": device,
        "capture_tick_timing": timing("frame_host_ms"),
        "capture_tick_scope": ("physics, input placement, explicit GPU observations/audit, GPU graphics submission and pixel export; excludes setup and later video annotation"
                               if summary.get("gpu_rendered_frames", 0) else
                               "physics, input placement, explicit GPU observations/audit and recording I/O; excludes setup and offline rendering"),
        "frames": len(frames),
        "corrected_steps": len(corrected),
        "timing_kind": "host wall intervals, including GPU waits; not CUDA kernel timings",
        "profiling_overhead_in_simulation_time": True,
        "nested_phase": "refilter is included in correctedCollisionSolve",
        "task_scope_totals": "task.* sums calls per step across trial/correction; task and detail scopes can overlap and are not additive simulation costs",
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
