#!/bin/bash
# abqueue2.sh <n>: interleaved final A/B, base package (B) vs new (N): meteor pair (paced) and debris_awake.
H=$(cd "$(dirname "$0")" && pwd); P=/Users/glavin/Development/vibe-land/target/perf-tools/steady; N=${1:-3}
for i in $(seq 1 $N); do
  for b in B N; do SCEN=meteor $H/ab.sh fmeteor-$b $P/lib-$b VIBE_PERF_ALL_TICKS=1 VIBE_PHYSX_PROFILE=1; done
  for b in B N; do SCEN=debris_awake $H/ab.sh fdebris-$b $P/lib-$b VIBE_PERF_FAST_SETUP=1 VIBE_PERF_ALL_TICKS=1 VIBE_PHYSX_PROFILE=1; done
done
$H/outcome.sh 7 8 9 10 11 12 >> $P/outcome.log 2>&1
