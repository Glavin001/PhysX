#!/bin/bash
# bridge.sh <tag>: vibe-land bridge suites (plus ignored stack_settling, gpu_load, heightfield_edge, ground_contact)
# against the private install, from the clean source snapshot, one GPU-locked job per suite.
S=/private/tmp/claude-501/splittick; OUT=$S/logs/bridge-$1; [ -e $OUT ] && { echo "exists"; exit 2; }; mkdir -p $OUT
W=/Users/glavin/Development/PhysX/.claude/worktrees/splittick
cd $S/${VLSRC:-vl-src}
export CARGO_TARGET_DIR=$S/${CARGODIR:-cargo} PHYSX_DESTRUCTION_SDK=$W PHYSX_ROOT=$W/out/install/macos-cumetal/release CUMETAL_CACHE_DIR=$S/cumetal-cache-bridge
G=/Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh
$G splittick-bridge-$1 cargo test --release -p vibe-land-physx-bridge --features native-destruction -- --test-threads=1 > $OUT/all.log 2>&1
echo "all: $(grep -E '^test result' $OUT/all.log | awk '{p+=$4; f+=$6; i+=$8} END {print p" passed "f" failed "i" ignored"}')"
for t in stack_settling gpu_load heightfield_edge ground_contact; do
  $G splittick-bridge-$1-$t cargo test --release -p vibe-land-physx-bridge --features native-destruction --test $t -- --include-ignored --test-threads=1 > $OUT/$t.log 2>&1
  echo "$t: $(grep -E '^test result' $OUT/$t.log | tr '\n' ' ')"
done
