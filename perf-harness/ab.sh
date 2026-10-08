#!/bin/bash
# ab.sh <tag> <PKG|-> [ENV=VAL...]: one perf_bench run (scenario $SCEN, default city_rubble)
# under the GPU lock into runs/<tag>.<n>. PKG is a package dir under cuda-metal/out/pkg whose
# lib/ overrides the GPU dylibs via DYLD_LIBRARY_PATH ("-" = the binary's rpath, steady-base).
P=/Users/glavin/Development/vibe-land/target/perf-tools/steady-tick
BIN=${BIN:-$P/cargo/release/deps/web_fps_server-c88140cb4ccdc8ac}
tag=$1; pkg=$2; shift 2
n=$(ls -d $P/runs/$tag.* 2>/dev/null | wc -l | tr -d ' '); n=$((n+1)); out=$P/runs/$tag.$n; mkdir -p $out
EXTRA=(); [ "$pkg" != "-" ] && EXTRA+=(DYLD_LIBRARY_PATH=/Users/glavin/Development/cuda-metal/out/pkg/$pkg/lib)
cd /Users/glavin/Development/vibe-land/.claude/worktrees/steady-bench/server
LOCK=(/Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh "steady-tick-$tag"); [ -n "$NOLOCK" ] && LOCK=()
"${LOCK[@]}" env VIBE_PHYSICS_BACKEND=physx_gpu CUMETAL_CACHE_DIR=${CACHE:-$P/cumetal-cache} \
  VIBE_PERF_SCENARIOS=${SCEN:-city_rubble} VIBE_PERF_PACE=${PACE:-1} VIBE_PERF_TRACE_DIR=$out "${EXTRA[@]}" "$@" \
  $BIN perf_bench --ignored --nocapture --test-threads=1 > $out/bench.log 2>&1
rc=$?
echo "$tag.$n rc=$rc $(grep -o '"scenario":"[a-z_0-9]*","ticks":[0-9]*,"p50":[0-9.]*,"p90":[0-9.]*,"p99":[0-9.]*,"max":[0-9.]*' $out/bench.log | tr '\n' ' ') $(grep -o '"bonds_broken":[0-9]*' $out/bench.log|tr '\n' ' ')"
