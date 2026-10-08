#!/bin/bash
# ab.sh <tag> <LIBDIR|-> [ENV=VAL...]: one perf_bench run (scenario $SCEN, default debris_awake)
# under the GPU lock into runs/<tag>.<n>. LIBDIR overrides the package dylibs via DYLD_LIBRARY_PATH.
P=/Users/glavin/Development/vibe-land/target/perf-tools/steady
BIN=${BIN:-$P/cargo2/release/deps/web_fps_server-c88140cb4ccdc8ac}
tag=$1; lib=$2; shift 2
n=$(ls -d $P/runs/$tag.* 2>/dev/null | wc -l | tr -d ' '); n=$((n+1)); out=$P/runs/$tag.$n; mkdir -p $out
EXTRA=(); [ "$lib" != "-" ] && EXTRA+=(DYLD_LIBRARY_PATH=$(cd $lib && pwd))
cd /Users/glavin/Development/vibe-land/.claude/worktrees/steady/server
/Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh "steady-$tag" env VIBE_PHYSICS_BACKEND=physx_gpu CUMETAL_CACHE_DIR=${CACHE:-$P/cumetal-cache} \
  VIBE_PERF_SCENARIOS=${SCEN:-debris_awake} VIBE_PERF_PACE=${PACE:-1} VIBE_PERF_TRACE_DIR=$out "${EXTRA[@]}" "$@" \
  $BIN perf_bench --ignored --nocapture --test-threads=1 > $out/bench.log 2>&1
echo "$tag.$n rc=$? $(grep -o '"scenario":"[a-z_0-9]*","ticks":[0-9]*,"p50":[0-9.]*,"p90":[0-9.]*,"p99":[0-9.]*,"max":[0-9.]*' $out/bench.log | tr '\n' ' ') $(grep -o '"bonds_broken":[0-9]*' $out/bench.log|tr '\n' ' ')"
