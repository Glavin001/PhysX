#!/bin/bash
# abqueue.sh <new-lib-name> <n>: interleaved base/new runs of meteor and debris_awake.
H=$(cd "$(dirname "$0")" && pwd); P=/Users/glavin/Development/vibe-land/target/perf-tools/steady
NEW=$1; N=${2:-3}
for i in $(seq 1 $N); do
  for s in meteor debris_awake; do
    SCEN=$s $H/ab.sh $s-A0 $P/lib-base VIBE_PERF_FAST_SETUP=1 VIBE_PERF_ALL_TICKS=1 VIBE_PHYSX_PROFILE=1
    SCEN=$s $H/ab.sh $s-$NEW $P/lib-$NEW VIBE_PERF_FAST_SETUP=1 VIBE_PERF_ALL_TICKS=1 VIBE_PHYSX_PROFILE=1
  done
done
