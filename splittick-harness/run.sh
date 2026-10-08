#!/bin/bash
# run.sh <variant> <tag> [ENV=VAL...]: one meteor perf_bench run of a frozen variant, under the GPU lock,
# into runs/<variant>.<tag>.<n>. Mode by env: TRACE=1 adds CUMETAL_TRACE_SYNC/COMMITS; KERN=1 adds per-kernel GPU trace.
S=/private/tmp/claude-501/splittick
v=$1; tag=$2; shift 2
V=$S/variants/$v
n=$(ls -d $S/runs/$v.$tag.* 2>/dev/null | wc -l | tr -d ' '); n=$((n+1)); out=$S/runs/$v.$tag.$n; mkdir -p $out
EXTRA=()
[ -n "$TRACE" ] && EXTRA+=(CUMETAL_TRACE_SYNC=1 CUMETAL_TRACE_COMMITS=1)
[ -n "$KERN" ] && EXTRA+=(CUMETAL_TRACE_GPU=1 CUMETAL_PROVENANCE=1)
cd $S/vl-src/server
/Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh "splittick-$v-$tag" env VIBE_PHYSICS_BACKEND=physx_gpu \
  DYLD_LIBRARY_PATH=$V/lib CUMETAL_CACHE_DIR=$S/cumetal-cache \
  VIBE_PERF_SCENARIOS=${SCEN:-meteor} VIBE_PERF_ALL_TICKS=1 VIBE_PERF_PACE=${PACE:-1} VIBE_PHYSX_PROFILE=1 \
  VIBE_PERF_MARKERS=1 VIBE_PERF_TRACE_DIR=$out "${EXTRA[@]}" "$@" \
  $V/bench perf_bench --ignored --nocapture --test-threads=1 > $out/bench.log 2>&1
echo "$v.$tag.$n rc=$? $(grep -o '"scenario":"[a-z_0-9]*","ticks":[0-9]*,"p50":[0-9.]*,"p90":[0-9.]*,"p99":[0-9.]*,"max":[0-9.]*' $out/bench.log | tr '\n' ' ') $(grep -o '"bonds_broken":[0-9]*' $out/bench.log|tr '\n' ' ')"
