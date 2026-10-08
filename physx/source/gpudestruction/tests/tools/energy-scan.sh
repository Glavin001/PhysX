#!/bin/bash
# energy-scan.sh DIR: the explicit step's energy books on every capture of DIR (one process each, shared GPU).
. "$(dirname "$0")/env.sh"
for f in $(ls "$1"/impact-*.impc | sort -t- -k2 -n); do
  VIBE_GPU_SHARED=1 "$G" energy-scan env CUMETAL_USE_METAL_DEVICE_ADDRESSES=1 IMPACT_QUIET=1 IMPACT_ROUTE=0 IMPACT_STEP_LOG=1 IMPACT_ENERGY_CHECK=1 "$OUT/impact_capture_replay" "$f" 2>&1 \
    | grep -E "explicit patch|energy deficit: [1-9]" | grep -v "broke 0," | sed "s|^|$(basename "$f") |"
done
