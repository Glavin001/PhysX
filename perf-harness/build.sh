#!/bin/bash
# build.sh gpu|sdk <logname>: the shared helper's stages for this worktree with the
# promoted package's flags. sdk (install + pipeline warm) runs under the GPU lock.
set -o pipefail
W=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick
export STEADY_CUMETAL_ROOT=/Users/glavin/Development/cuda-metal/.claude/worktrees/steady-tick
FLAGS=(--preset macos-cumetal --cumetal-root $STEADY_CUMETAL_ROOT --cumetal-rigid-demo --cumetal-block-voted-traps
  --cumetal-explicit-aggregate-root --cumetal-explicit-hierarchy-root --cumetal-explicit-motion-root
  --cumetal-pack-bond-stress-scalars --cumetal-particle-inline-threshold 500 --cumetal-softbody-inline-threshold 500
  --generator 'Unix Makefiles' --jobs ${JOBS:-10})
P=/Users/glavin/Development/vibe-land/target/perf-tools/steady-tick
LOG=$P/build-$2.log
[ -e $LOG ] && { echo "log exists: $LOG"; exit 2; }
cd $W
if [ "$1" = gpu ]; then
  python3 -B tools/scripts/build-destruction-sdk.py --stage gpu "${FLAGS[@]}" "${@:3}" > $LOG 2>&1
else
  /Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh steady-tick-install python3 -B tools/scripts/build-destruction-sdk.py --stage sdk --install "${FLAGS[@]}" > $LOG 2>&1
fi
rc=$?; echo "build $1 rc=$rc"; tail -3 $LOG | cut -c1-200; exit $rc
