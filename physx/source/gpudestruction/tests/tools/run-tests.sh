#!/bin/bash
# run-tests.sh: the explicit step's gates and the impact regressions, as ctest registers them,
# on tools built by build-tool.sh (shared GPU). Logs in $OUT/*.log.
. "$(dirname "$0")/env.sh"
T=$OUT
run(){ name=$1; want=$2; shift 2; VIBE_GPU_SHARED=1 "$G" "$name" env CUMETAL_USE_METAL_DEVICE_ADDRESSES=1 "$@" > "$T/$name.log" 2>&1; rc=$?; ok=PASS; if [ "$want" = fail ]; then [ $rc = 1 ] || ok=FAIL; else [ $rc = 0 ] || ok=FAIL; fi; echo "$ok $name (exit $rc): $(grep -E 'against the harness|corrected pass|held over|energy deficit' "$T/$name.log" | tail -1)"; }
run explicit_cannon pass IMPACT_EXPLICIT_DT_US=32 "$T/impact_explicit_replay" "$F/impact-level/cannon-level5.bin" "$F/impact-level/cannon-level5.explicit.txt"
run explicit_energy pass IMPACT_QUIET=1 IMPACT_ENERGY_CHECK=1 "$T/impact_capture_replay" "$F/impact-handoff/cannon-fragments.impc"
[ "${ALL:-0}" = 1 ] || exit 0
for shot in cannon truck; do
  run handoff_$shot pass IMPACT_ROUTE=1 IMPACT_STATIC_ISLAND=1443 "$T/impact_static_handoff" "$F/impact-handoff/$shot-trial.impc" "$F/impact-handoff/$shot-corrected.impc"
  run handoff_${shot}_unrouted fail IMPACT_ROUTE=0 IMPACT_STATIC_ISLAND=1443 "$T/impact_static_handoff" "$F/impact-handoff/$shot-trial.impc" "$F/impact-handoff/$shot-corrected.impc"
done
run held_over_capacity pass IMPACT_QUIET=1 IMPACT_METHOD=2 IMPACT_ROUTE=1 IMPACT_BOUND_IMPACTOR=1 IMPACT_HELD_CHECK=1 "$T/impact_capture_replay" "$F/impact-handoff/cannon-first.impc"
