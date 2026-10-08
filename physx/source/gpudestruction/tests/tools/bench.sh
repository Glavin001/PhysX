#!/bin/bash
# bench.sh TOOL [RUNS] [ENV...]: the explicit step on the cannonball's first contact (or CAPTURE=...),
# RUNS times in one process; min and median of build, window and the whole evaluation, the first
# run (pipeline build) discarded. Shared GPU unless EXCL=1 (the exclusive lock: brief runs only).
. "$(dirname "$0")/env.sh"
T=$1; runs=${2:-20}; shift 2
C=${CAPTURE:-$F/impact-handoff/cannon-first.impc}
if [ "${EXCL:-0}" = 1 ]; then pre=(env); else pre=(env VIBE_GPU_SHARED=1); fi
"${pre[@]}" "$G" explicit-bench env CUMETAL_USE_METAL_DEVICE_ADDRESSES=1 IMPACT_QUIET=1 IMPACT_METHOD=2 IMPACT_ROUTE=1 IMPACT_BOUND_IMPACTOR=1 IMPACT_STEP_LOG=1 "$@" "$T" "$C" "$runs" 2>&1 | python3 -c "
import sys,re,statistics as st
b=[];w=[];e=[];sub=set()
for l in sys.stdin:
    m=re.search(r'build ([\d.]+) ms, window ([\d.]+) ms',l)
    if m: b.append(float(m.group(1)));w.append(float(m.group(2)))
    m=re.search(r'error \d+; ([\d.]+) ms in',l)
    if m: e.append(float(m.group(1)))
    m=re.search(r'explicit patch (\d+):.* (\d+) substeps of ([\d.]+) us',l)
    if m: sub.add((int(m.group(1)),int(m.group(2)),float(m.group(3))))
b,w,e=b[1:],w[1:],e[1:]
f=lambda x:'min %.2f med %.2f (n %d)'%(min(x),st.median(x),len(x)) if x else '-'
print('build',f(b),'| window',f(w),'| evaluation',f(e))
print('substeps', ' '.join('p%d:%d@%.1fus'%s for s in sorted(sub)))
"
