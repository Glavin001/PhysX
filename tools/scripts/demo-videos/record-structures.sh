#!/bin/bash
# Scenario set on synthetic structures + material/projectile variants. Usage: TOWER_STRENGTH=<n> ./record-structures.sh
cd /root/workspace/physx-2
V=out/demo-videos-20260918; DEMO=out/destruction-sdk/reference/native_destruction_demo
COMMON="--launch-seconds 0 --stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 --frame-strength 40 --record-state 0 --audit-motion 0 --trace-motion 0 --standard-scene 1 --sleeping 1 --gpu-render 1 --gpu-resolution 1920x1080 --color-by-cluster 1 --grid 1 --shot-path aerial"
TS=${TOWER_STRENGTH:-24}
run() { name=$1; shift; rm -rf $V/$name $V/$name-raw.mp4; LD_LIBRARY_PATH=$PWD/physx/bin/linux.x86_64/release $DEMO $COMMON "$@" --gpu-video $V/$name-raw.mp4 --output $V/$name > $V/$name.log 2>&1; echo "$name exit $?"; python3 -c "
import csv,json;rows=list(csv.DictReader(open('$V/$name/native.frames.csv')));d=json.load(open('$V/$name/native.summary.json'));ms=[float(r['physics_step_ms']) for r in rows];print('   bonds',d['broken_bonds'],'awake end',rows[-1]['awake_bodies'],'mean ms %.2f max %.1f'%(sum(ms)/len(ms),max(ms)))"; }
run tower64-collapse      --geometry tower64      --workload bombardment --waves 2 --projectile-mass 18000 --material-strength $TS --impact-target 0,6,0   --gpu-camera structure --seconds 14
run bridge64-midspan      --geometry bridge64     --workload bombardment --waves 1 --projectile-mass 18000 --material-strength 24  --impact-target 0,2,0   --gpu-camera structure --seconds 10
run cantilever64-tip      --geometry cantilever64 --workload bombardment --waves 1 --projectile-mass 18000 --material-strength 24  --impact-target 28,0.5,0 --gpu-camera structure --seconds 10
run dense12-block         --geometry dense12      --workload bombardment --waves 2 --projectile-mass 18000 --material-strength 24  --impact-target 0,6,0   --gpu-camera structure --seconds 10
run chain256-column       --geometry chain256     --workload bombardment --waves 1 --projectile-mass 18000 --material-strength 24  --impact-target 0,200,0 --gpu-camera structure --seconds 14
run panel32-plate         --geometry panel32      --workload bombardment --waves 1 --projectile-mass 18000 --material-strength 24  --impact-target 0,0.5,0 --gpu-camera structure --seconds 10
run building-weak         --geometry building --workload bombardment --waves 4 --projectile-mass 18000  --material-strength 6   --gpu-camera penetration --seconds 8
run building-strong       --geometry building --workload bombardment --waves 4 --projectile-mass 18000  --material-strength 100 --gpu-camera penetration --seconds 8
run building-heavy-shot   --geometry building --workload bombardment --waves 4 --projectile-mass 120000 --material-strength 24  --gpu-camera penetration --seconds 8
echo STRUCT_DONE
