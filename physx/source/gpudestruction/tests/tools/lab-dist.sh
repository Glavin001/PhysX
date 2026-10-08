#!/bin/bash
# lab-dist.sh TOOL DIR [OUT.jsonl] [ENV...]: the explicit step on every capture of a lab run (DIR: e.g.
# vibe-land target/impact-capture/all/cannonball-framed-house-r1), one process each, in capture order;
# per evaluation its time, window, launches and each patch's size, substeps and break times (JSON
# lines), then the distribution (lab-dist.py). Shared GPU unless EXCL=1.
. "$(dirname "$0")/env.sh"
T=$1; D=$2; O=${3:-$OUT/lab-dist.jsonl}; shift 3 2>/dev/null || shift $#
if [ "${EXCL:-0}" = 1 ]; then pre=(env); else pre=(env VIBE_GPU_SHARED=1); fi
: > "$O"
for f in $(ls "$D"/impact-*.impc | sort -t- -k2 -n); do
  "${pre[@]}" "$G" lab-dist env CUMETAL_USE_METAL_DEVICE_ADDRESSES=1 IMPACT_QUIET=1 IMPACT_METHOD=2 IMPACT_ROUTE=1 IMPACT_BOUND_IMPACTOR=1 \
    IMPACT_STEP_LOG=1 IMPACT_EXPLICIT_TIMES=1 "$@" "$T" "$f" 2>&1 | python3 "$TOOLS_DIR/lab-dist.py" parse "$(basename "$f")" >> "$O"
done
python3 "$TOOLS_DIR/lab-dist.py" summary "$O"
