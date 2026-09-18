#!/bin/bash
cd /root/workspace/physx-2; V=out/demo-videos-20260918; DEMO=out/destruction-sdk/reference/native_destruction_demo
COMMON="--launch-seconds 0 --stress-iterations 8192 --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 --frame-strength 40 --record-state 0 --audit-motion 0 --trace-motion 0 --standard-scene 1 --sleeping 1 --gpu-render 0 --grid 1 --shot-path aerial --geometry building --workload bombardment --waves 4 --projectile-mass 18000 --material-strength 100 --seconds 4 --audit-penetration 1"
cmake --build out/destruction-sdk --target native_destruction_demo -j 16 > $V/build4.log 2>&1 || { echo "demo build failed"; grep -E "error" $V/build4.log | head -5; exit 1; }; echo "demo build ok"
pen() { name=$1; shift; rm -rf $V/pen-$name; env LD_LIBRARY_PATH=$PWD/physx/bin/linux.x86_64/release "$@" $DEMO $COMMON --preserve-contact-pairs ${PRESERVE:-1} --output $V/pen-$name > $V/pen-$name.log 2>&1; echo "$name exit $? :: $(grep '\[penetration\] summary' $V/pen-$name.log)"; grep '\[penetration\] step' $V/pen-$name.log | head -4 | cut -c1-140; }
pen default
pen sleep0 PHYSX_DESTRUCTION_DEVICE_SLEEP=0
PRESERVE=0 pen preserve0
pen readiness-verdict PHYSX_DESTRUCTION_DEVICE_SLEEP=0 PHYSX_DESTRUCTION_ACCEPT_SYNC=1
echo PEN_DONE
cmake --build out/sdk-release -j 32 > $V/build5-rel.log 2>&1 || { echo "sdk-release build failed"; grep -E "error:" $V/build5-rel.log | head -5; exit 1; }
cmake --build out/destruction-sdk -j 32 > $V/build5.log 2>&1 || { echo "sdk build failed"; exit 1; }; echo "limit build ok"
for so in libPhysXDestructionGpuRuntime_64.so libPhysXGpuActivity_64.so; do cp physx/bin/linux.x86_64/release/$so out/direct-factor-feasibility-20260915/artifacts/; cp physx/bin/linux.x86_64/release/$so out/direct-ab-arms/B/; done
rm -rf $V/tower-limit; BLAST_GPU_NATIVE_DIRECT_DIAG=1 LD_LIBRARY_PATH=$PWD/physx/bin/linux.x86_64/release $DEMO --launch-seconds 0 --stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 --frame-strength 40 --record-state 0 --audit-motion 0 --trace-motion 0 --standard-scene 1 --sleeping 1 --gpu-render 0 --grid 1 --shot-path aerial --geometry tower64 --workload bombardment --waves 2 --projectile-mass 18000 --material-strength 8 --impact-target 0,6,0 --seconds 8 --output $V/tower-limit > $V/tower-limit.log 2>&1; echo "tower-limit exit $?"
grep "native direct patterns\|native direct woodbury" $V/tower-limit.log | head -2 | cut -c1-220
python3 -c "
import csv;rows=list(csv.DictReader(open('$V/tower-limit/native.frames.csv')));ms=[float(r['physics_step_ms']) for r in rows];print('tower ticks',len(rows),'mean %.2f'%(sum(ms)/len(ms)),'late(last 120) %.2f'%(sum(ms[-120:])/120),'max %.1f'%max(ms))"
grep "native direct:" $V/tower-limit.log | tail -1 | cut -c1-200
echo LIMIT_DONE
