#!/bin/bash
# validate.sh: native_feature_reference_test, then the bridge suites on steady-final.
H=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick/perf-harness; P=/Users/glavin/Development/vibe-land/target/perf-tools/steady-tick
D=/Users/glavin/Development/PhysX/.claude/worktrees/steady-tick/out/build/macos-cumetal/release/sdk/destruction
/Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh steady-tick-nfr bash -c "cd $D/reference && CUMETAL_CACHE_DIR=$P/cumetal-cache ./native_feature_reference_test > $P/nfr-${NFR_TAG:-final}.log 2>&1; echo nfr rc=\$? >> $P/nfr-${NFR_TAG:-final}.log"
tail -3 $P/nfr-${NFR_TAG:-final}.log
$H/bridge.sh ${BRIDGE_PKG:-final}
