#!/usr/bin/env python3
"""Read native wall/Metal compile traces; emit wall-time attribution JSON to stdout.

No GPU work is performed. Compilation overlap is a UNION of observed Metal API
intervals, clipped to each phase; subtracting it does not isolate GPU or CPU physics.
Requires same-process steady_clock markers with compile_trace=1 to establish
coverage. Missing clocks, interrupted spans, or disabled tracing remain unknown.
"""
import argparse
import json
import math
from pathlib import Path
import statistics

METAL = {"metal_new_library_with_source", "metal_new_library_with_data",
         "metal_new_function", "metal_new_compute_pipeline"}
PHASES = {"setup", "physics_step", "observation", "teardown"}


def union(intervals):
    result = []
    for start, end in sorted(intervals):
        if result and start <= result[-1][1]:
            result[-1] = (result[-1][0], max(end, result[-1][1]))
        else:
            result.append((start, end))
    return result


def length(intervals):
    return sum(end - start for start, end in union(intervals))


def distribution(values):
    if not values:
        return {"count": 0, "min_ms": None, "median_ms": None,
                "p95_ms": None, "max_ms": None, "total_ms": 0}
    values = sorted(values)
    return {"count": len(values), "min_ms": values[0],
            "median_ms": statistics.median(values),
            "p95_ms": values[math.ceil(.95 * len(values)) - 1],
            "max_ms": values[-1], "total_ms": sum(values)}


def analyze(text):
    issues, phases, compiles = [], [], []
    opened, seen, bad_pids = {}, set(), set()
    global_bad = False
    for line_number, line in enumerate(text.splitlines(), 1):
        if not line.startswith(("NATIVE_WALL_TIMING ", "CUMETAL_COMPILE ")):
            continue
        kind = line.split()[0]
        record, pid = {}, None
        try:
            fields = [part.split("=", 1) for part in line.split()[1:]]
            if any(len(field) != 2 for field in fields):
                raise ValueError("malformed fields")
            record = dict(fields)
            if len(record) != len(fields):
                raise ValueError("duplicate fields")
            pid = int(record["pid"])
            if pid <= 0:
                raise ValueError("invalid pid")
            stage = record["stage"]
            # Compiler-only spans are not Metal API compilation/loading work.
            if kind == "CUMETAL_COMPILE" and stage not in METAL:
                continue
            if kind == "NATIVE_WALL_TIMING" and stage not in PHASES:
                raise ValueError("unknown phase")
            event = record["event"]
            if event not in ("begin", "end"):
                raise ValueError("unknown event")
            if record.get("clock") != "steady_clock":
                raise ValueError("missing/unsupported clock evidence")
            when = int(record["monotonic_ns"])
            if when < 0:
                raise ValueError("negative monotonic timestamp")
            if kind == "CUMETAL_COMPILE":
                ident = int(record["span"])
                if ident <= 0:
                    raise ValueError("invalid span")
                key = (kind, pid, ident)
            else:
                frame = int(record.get("frame", "-1"))
                if stage in ("physics_step", "observation") and frame < 0:
                    raise ValueError("missing frame")
                key = (kind, pid, stage, frame)
            if event == "begin":
                if key in seen:
                    raise ValueError("duplicate span/phase")
                seen.add(key)
                opened[key] = (when, record)
            else:
                if key not in opened:
                    raise ValueError("end without begin")
                start, first = opened.pop(key)
                if stage != first["stage"] or when < start:
                    raise ValueError("mismatched or reversed span")
                if kind == "CUMETAL_COMPILE":
                    compiles.append((pid, start, when))
                else:
                    covered = first.get("compile_trace") == "1" and record.get("compile_trace") == "1"
                    phases.append({"pid": pid, "stage": stage, "frame": key[-1],
                                   "begin_ns": start, "end_ns": when, "covered": covered})
                    if not covered:
                        issues.append(f"pid {pid} {stage} frame {key[-1]}: compilation tracing not proven enabled")
        except (KeyError, ValueError) as error:
            issues.append(f"line {line_number}: {error}")
            if pid is None:
                global_bad = True
            else:
                bad_pids.add(pid)
    for key in opened:
        issues.append(f"unclosed trace: {key}")
        bad_pids.add(key[1])
    if not phases:
        issues.append("no complete phase intervals")
    # A single instrumented process cannot execute two phase scopes concurrently.
    # Reject overlap instead of double-counting setup/steps/observations.
    for pid in {p["pid"] for p in phases}:
        ordered = sorted((p["begin_ns"], p["end_ns"]) for p in phases if p["pid"] == pid)
        if length(ordered) != sum(end - start for start, end in ordered):
            issues.append(f"pid {pid}: overlapping phase intervals")
            bad_pids.add(pid)
    output = []
    for phase in sorted(phases, key=lambda p: (p["pid"], p["begin_ns"])):
        pid, start, end = phase["pid"], phase["begin_ns"], phase["end_ns"]
        known = phase.pop("covered") and pid not in bad_pids and not global_bad
        overlap = length((max(start, a), min(end, b)) for p, a, b in compiles
                         if p == pid and a < end and b > start) if known else None
        phase.update(wall_ms=(end - start) / 1e6,
                     metal_compile_overlap_ms=None if overlap is None else overlap / 1e6,
                     noncompile_wall_ms=None if overlap is None else (end - start - overlap) / 1e6,
                     compilation_free=None if overlap is None else overlap == 0)
        output.append(phase)
    steps = [p for p in output if p["stage"] == "physics_step"]
    totals = {}
    for stage in sorted(PHASES):
        rows = [p for p in output if p["stage"] == stage]
        known = bool(rows) and all(p["metal_compile_overlap_ms"] is not None for p in rows)
        totals[stage] = {"count": len(rows), "wall_ms": sum(p["wall_ms"] for p in rows),
                         "metal_compile_overlap_ms": sum(p["metal_compile_overlap_ms"] for p in rows) if known else None,
                         "noncompile_wall_ms": sum(p["noncompile_wall_ms"] for p in rows) if known else None}
    return {"schema": "physx.native-wall-timing", "version": 1,
            "status": "complete" if not issues else "incomplete", "issues": issues,
            "interpretation": "Observed host wall time, not GPU kernel performance. Metal API intervals include compilation/loading/pipeline creation. Their union is clipped to phases. Subtraction does not isolate CPU or GPU physics; asynchronous work may overlap. No steps or warm spikes are discarded.",
            "phases": output, "stage_totals": totals,
            "physics_step_wall": distribution([p["wall_ms"] for p in steps]),
            "compilation_free_physics_step_wall": distribution([p["wall_ms"] for p in steps if p["compilation_free"] is True]),
            "physics_steps_with_unknown_compile_coverage": sum(p["compilation_free"] is None for p in steps)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("logs", nargs="+", type=Path)
    args = parser.parse_args()
    result = analyze("\n".join(path.read_text() for path in args.logs))
    print(json.dumps(result, indent=2))
    return 0 if result["status"] == "complete" else 2


if __name__ == "__main__":
    raise SystemExit(main())
