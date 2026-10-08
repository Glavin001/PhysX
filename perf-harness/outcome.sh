#!/bin/bash
# outcome.sh <seeds...>: meteor_seeded fracture outcomes, base (B) and new (N) builds, unpaced.
H=$(cd "$(dirname "$0")" && pwd); P=/Users/glavin/Development/vibe-land/target/perf-tools/steady
for s in "$@"; do for b in B N; do
  SCEN=seeded_meteor PACE=0 $H/ab.sh outcome2-$b-s$s $P/lib-$b VIBE_PERF_METEOR_SEED=$s VIBE_PERF_ALL_TICKS=1 >/dev/null
  echo "$b seed $s $(grep -o 'OUTCOME.*' $P/runs/outcome2-$b-s$s.1/bench.log) $(grep -ci 'stage failed' $P/runs/outcome2-$b-s$s.1/bench.log)"
done; done
