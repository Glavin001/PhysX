#!/bin/bash
# citybench.sh <B|N> [label]: vibe-land city-bench systematic (1 client) against the base or new package.
b=$1; L=$([ $b = B ] && echo steady-base || echo steady)
cd /Users/glavin/Development/vibe-land
CITY_BENCH_OUT=/Users/glavin/Development/vibe-land/target/perf-tools/steady/city-bench-$b \
PHYSX_DESTRUCTION_SDK=/Users/glavin/Development/PhysX/.claude/worktrees/$L \
PHYSX_ROOT=/Users/glavin/Development/PhysX/.claude/worktrees/$L/out/install/macos-cumetal/release \
HTTP_PORT=4501 WT_PORT=4502 CLIENT_PORT=3503 \
  scripts/perf/city-bench.sh --no-build --label steady-$b${2:+-$2} > /Users/glavin/Development/vibe-land/target/perf-tools/steady/citybench-$b.log 2>&1
echo "citybench $b rc=$?"
