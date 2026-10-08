#!/bin/bash
H=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick/perf-harness
VIBE_PERF_ALL_TICKS=1 $H/ab.sh base - VIBE_PERF_ALL_TICKS=1
$H/ab.sh sync-base - VIBE_PERF_ALL_TICKS=1 VIBE_PERF_MARKERS=1 CUMETAL_TRACE_SYNC=1 CUMETAL_TRACE_COMMITS=1
$H/ab.sh gpu-base - VIBE_PERF_ALL_TICKS=1 VIBE_PERF_MARKERS=1 CUMETAL_TRACE_GPU=1 CUMETAL_PROVENANCE=1
