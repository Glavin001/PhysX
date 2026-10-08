#!/bin/bash
# bridge.sh <lib B|N>: vibe-land bridge suites (plus ignored ground_contact, stack_settling,
# gpu_load, heightfield_edge) against a package's dylibs, one GPU-locked job per suite.
P=/Users/glavin/Development/vibe-land/target/perf-tools/steady; L=$P/lib-$1; OUT=$P/bridge-$1; mkdir -p $OUT
cd /Users/glavin/Development/vibe-land/.claude/worktrees/steady
export CARGO_TARGET_DIR=$P/cargo2 PHYSX_DESTRUCTION_SDK=/Users/glavin/Development/PhysX/.claude/worktrees/steady-base PHYSX_ROOT=/Users/glavin/Development/PhysX/.claude/worktrees/steady-base/out/install/macos-cumetal/release
G=/Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh
$G steady-bridge-$1 env DYLD_LIBRARY_PATH=$L CUMETAL_CACHE_DIR=$P/cumetal-cache cargo test --release -p vibe-land-physx-bridge --features native-destruction -- --test-threads=1 > $OUT/all.log 2>&1
echo "all: $(grep -E '^test result' $OUT/all.log | awk '{p+=$4; f+=$6} END {print p" passed "f" failed"}')"
for t in ground_contact stack_settling gpu_load heightfield_edge; do
  $G steady-bridge-$1-$t env DYLD_LIBRARY_PATH=$L CUMETAL_CACHE_DIR=$P/cumetal-cache cargo test --release -p vibe-land-physx-bridge --features native-destruction --test $t -- --include-ignored --test-threads=1 > $OUT/$t.log 2>&1
  echo "$t: $(grep -E '^test result' $OUT/$t.log | tr '\n' ' ')"
done
