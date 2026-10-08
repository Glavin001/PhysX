#!/bin/bash
# citybench.sh <base|final> [label]: city-bench systematic, 1 client capped at 30 fps, against a private package.
arm=$1; O=/Users/glavin/Development/vibe-land/target/perf-tools/steady-tick/cb-$arm
cd /Users/glavin/Development/vibe-land/.claude/worktrees/steady-bench
CITY_BENCH_OUT=$O PHYSX_DESTRUCTION_SDK=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick \
PHYSX_ROOT=/Users/glavin/Development/cuda-metal/out/pkg/steady-$arm CITY_BENCH_CLIENT_QUERY=maxFps=30 \
HTTP_PORT=4551 WT_PORT=4552 CLIENT_PORT=3553 \
  scripts/perf/city-bench.sh --no-build --scenario systematic --label steady-$arm${2:+-$2} > $O/citybench-${2:-run}.log 2>&1
echo "citybench $arm ${2:-} rc=$? $(ls -td $O/runs/* | head -1)"
