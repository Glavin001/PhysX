#!/bin/bash
# wreck-queue.sh <pkg|-> <tagprefix> [modes...]: city_wreck runs: t=timing, s=sync trace, g=gpu trace
H=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick/perf-harness
pkg=$1; pre=$2; shift 2
for m in "$@"; do case $m in
  t) SCEN=city_wreck $H/ab.sh $pre-t $pkg VIBE_PERF_ALL_TICKS=1 ;;
  s) SCEN=city_wreck $H/ab.sh $pre-s $pkg VIBE_PERF_ALL_TICKS=1 VIBE_PERF_MARKERS=1 CUMETAL_TRACE_SYNC=1 CUMETAL_TRACE_COMMITS=1 ;;
  g) SCEN=city_wreck $H/ab.sh $pre-g $pkg VIBE_PERF_ALL_TICKS=1 VIBE_PERF_MARKERS=1 CUMETAL_TRACE_GPU=1 CUMETAL_PROVENANCE=1 ;;
  p) SCEN=city_wreck $H/ab.sh $pre-p $pkg VIBE_PERF_ALL_TICKS=1 VIBE_PHYSX_PROFILE=1 ;;
esac; done
