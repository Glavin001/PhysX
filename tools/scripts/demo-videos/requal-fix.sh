#!/bin/bash
# After the re-recordings: native tests, then the continuous 600-tick B-arm run of the collision-fix default.
cd /root/workspace/physx-2; V=out/demo-videos-20260918; D=out/direct-factor-feasibility-20260915
until grep -q "RERECORD_DONE\|not recording" $V/rerecord.log; do sleep 30; done
ctest --test-dir out/destruction-sdk -R "^(physx_native_compound_sleep|physx_native_standard_sleep_boundary|physx_native_standard_gpu_islands|physx_native_standard_wake_boundary|physx_native_standard_late_impact|physx_native_gpu_group_filtering|physx_native_gpu_publication|physx_native_gpu_shape_publication)$" --output-on-failure > $D/fix-ctest.log 2>&1; echo "ctest exit $? $(grep -E 'tests passed' $D/fix-ctest.log)"; grep -E "Failed|\*\*\*" $D/fix-ctest.log | head -5
O=out/direct-continuous-ab-20260918c-B; rm -rf $O; systemctl stop sddm; sleep 5
python3 tools/scripts/run-destruction-ab.py $O --baseline out/direct-ab-arms/B --seconds 10 --trials 2 > $O.log 2>&1; echo "continuous exit $?"
systemctl start sddm
python3 - <<'PY'
import gzip,json,glob
for f in sorted(glob.glob('out/direct-continuous-ab-20260918c-B/*/*/report/report.json.gz')):
    d=json.load(gzip.open(f))
    for i,r in enumerate(d.get('runs',[])):
        m=r.get('metrics',{}); print(f.split('/')[-3],i,{k:m.get(k) for k in ('mean','max','misses_60hz','misses_120hz')})
PY
echo REQUAL_DONE
