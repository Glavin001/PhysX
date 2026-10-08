#!/bin/bash
# bridge.sh <pkg>: vibe-land bridge suites (plus ignored stack_settling, gpu_load, heightfield_edge)
# against cuda-metal/out/pkg/steady-<pkg>, one GPU-locked job per suite.
P=/Users/glavin/Development/vibe-land/target/perf-tools/steady-tick; OUT=$P/bridge-$1; mkdir -p $OUT
cd /Users/glavin/Development/vibe-land/.claude/worktrees/steady-bench
export CARGO_TARGET_DIR=$P/cargo-bridge PHYSX_DESTRUCTION_SDK=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick PHYSX_ROOT=/Users/glavin/Development/cuda-metal/out/pkg/steady-$1
G=/Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh
$G steady-tick-bridge-$1 env CUMETAL_CACHE_DIR=$P/cumetal-cache cargo test --release -p vibe-land-physx-bridge --features native-destruction -- --test-threads=1 > $OUT/all.log 2>&1
echo "all: $(grep -E '^test result' $OUT/all.log | awk '{p+=$4; f+=$6} END {print p" passed "f" failed"}')"
for t in stack_settling gpu_load heightfield_edge; do
  $G steady-tick-bridge-$1-$t env CUMETAL_CACHE_DIR=$P/cumetal-cache cargo test --release -p vibe-land-physx-bridge --features native-destruction --test $t -- --include-ignored --test-threads=1 > $OUT/$t.log 2>&1
  echo "$t: $(grep -E '^test result' $OUT/$t.log | tr '\n' ' ')"
done
