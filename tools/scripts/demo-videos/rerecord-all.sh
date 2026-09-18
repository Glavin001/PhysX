#!/bin/bash
# Re-record every video with the collision fix (host refilter default), elevated structures, longer tower.
cd /root/workspace/physx-2; V=out/demo-videos-20260918; DEMO=out/destruction-sdk/reference/native_destruction_demo
until grep -q "FIX_DONE\|build failed" $V/fix.log; do sleep 15; done
grep -q "build failed" $V/fix.log && { echo "fix build failed; not recording"; exit 1; }
BASE="--launch-seconds 0 --stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 --frame-strength 40 --record-state 0 --audit-motion 0 --trace-motion 0 --standard-scene 1 --sleeping 1 --gpu-render 1 --gpu-resolution 1920x1080 --color-by-cluster 1"
CITY="$BASE --projectile-mass 18000 --material-strength 24 --waves 1 --workload bombardment --shot-path aerial"
NOTE1="Stats: physics step time per tick (excludes the renderer; the CUDA renderer shares the GPU). RTX 5060 Ti. Collision fix 2026-09-18."
NOTE2="REAL-TIME playback: each frame is held for max(16.7 ms, its physics step time); heavy ticks slow the video as a game would. RTX 5060 Ti. Collision fix 2026-09-18."
declare -A T
run() { name=$1; title=$2; shift 2; rm -rf $V/$name $V/$name-raw.mp4 $V/$name.mp4 $V/$name-realtime.mp4; LD_LIBRARY_PATH=$PWD/physx/bin/linux.x86_64/release $DEMO "$@" --gpu-video $V/$name-raw.mp4 --output $V/$name > $V/$name.log 2>&1; echo "$name exit $?"; T[$name]="$title"; }
run through-wall "Projectile through a wall: same-tick fracture + correction (1 building)" $BASE --projectile-mass 18000 --material-strength 24 --grid 1 --waves 1 --workload single-impact --shot-path through-wall --gpu-camera penetration --seconds 6
run building-close "One building, four 18 t projectiles, close camera" $BASE --projectile-mass 18000 --material-strength 24 --grid 1 --waves 4 --workload bombardment --shot-path aerial --gpu-camera penetration --seconds 8
run building-strong "Building, four 18 t projectiles, material strength 100 (strong)" $BASE --projectile-mass 18000 --material-strength 100 --grid 1 --waves 4 --workload bombardment --shot-path aerial --gpu-camera penetration --seconds 8
run building-weak "Building, four 18 t projectiles, material strength 6 (weak)" $BASE --projectile-mass 18000 --material-strength 6 --grid 1 --waves 4 --workload bombardment --shot-path aerial --gpu-camera penetration --seconds 8
run building-heavy-shot "Building, four 120 t projectiles, material strength 24" $BASE --projectile-mass 120000 --material-strength 24 --grid 1 --waves 4 --workload bombardment --shot-path aerial --gpu-camera penetration --seconds 8
run city256-close "City 256 buildings (113k chunks, 229k bonds), 256 projectiles, close camera" $CITY --grid 16 --gpu-camera close --seconds 8
run city256-mid "City 256 buildings (113k chunks, 229k bonds), 256 projectiles, quarter view" $CITY --grid 16 --gpu-camera mid --seconds 8
run city256-overview "City 256 buildings (113k chunks, 229k bonds), 256 projectiles, overview" $CITY --grid 16 --gpu-camera overview --seconds 8
run city16-staggered-close "City 16 buildings, 16 impacts staggered over 4 s, close camera" $CITY --grid 4 --launch-seconds 4 --gpu-camera close --seconds 10
run city16-staggered-mid "City 16 buildings, 16 impacts staggered over 4 s, quarter view" $CITY --grid 4 --launch-seconds 4 --gpu-camera mid --seconds 10
run city64-staggered-overview "City 64 buildings, 64 impacts staggered over 8 s, overview" $CITY --grid 8 --launch-seconds 8 --gpu-camera overview --seconds 12
run city64-staggered-mid "City 64 buildings, 64 impacts staggered over 8 s, quarter view" $CITY --grid 8 --launch-seconds 8 --gpu-camera mid --seconds 12
run city256-staggered-overview "City 256 buildings (113k chunks), 256 impacts staggered over 14 s, overview" $CITY --grid 16 --launch-seconds 14 --gpu-camera overview --seconds 20
run city256-staggered-mid "City 256 buildings (113k chunks), 256 impacts staggered over 14 s, quarter view" $CITY --grid 16 --launch-seconds 14 --gpu-camera mid --seconds 20
run tower64-collapse "64-storey tower (2,368 chunks), two 18 t projectiles at the base, material strength 8: topples" $BASE --projectile-mass 18000 --material-strength 8 --grid 1 --waves 2 --workload bombardment --shot-path aerial --geometry tower64 --impact-target 0,6,0 --gpu-camera structure --seconds 24
run tower64-stands "64-storey tower (2,368 chunks), two 18 t projectiles at the base, material strength 24: base shattered, tower stands" $BASE --projectile-mass 18000 --material-strength 24 --grid 1 --waves 2 --workload bombardment --shot-path aerial --geometry tower64 --impact-target 0,6,0 --gpu-camera structure --seconds 12
run bridge64-midspan "64 m bridge deck on end supports, 10 m up, two 120 t projectiles at mid-span, material strength 300" $BASE --projectile-mass 120000 --material-strength 300 --grid 1 --waves 2 --workload bombardment --shot-path aerial --geometry bridge64 --structure-elevation 10 --impact-target 0,2,0 --gpu-camera structure --seconds 10
run cantilever64-tip "64 m cantilever beam fixed at one end, 10 m up, 18 t projectile near the free tip" $BASE --projectile-mass 18000 --material-strength 24 --grid 1 --waves 1 --workload bombardment --shot-path aerial --geometry cantilever64 --structure-elevation 10 --impact-target 28,0.5,0 --gpu-camera structure --seconds 10
run panel32-plate "32x32 plate on four corner supports, 8 m up, 18 t projectile at the centre" $BASE --projectile-mass 18000 --material-strength 24 --grid 1 --waves 1 --workload bombardment --shot-path aerial --geometry panel32 --structure-elevation 8 --impact-target 0,0.5,0 --gpu-camera structure --seconds 10
run dense12-block "Solid 12x12x12 block (1,728 chunks), two 120 t projectiles, material strength 3" $BASE --projectile-mass 120000 --material-strength 3 --grid 1 --waves 2 --workload bombardment --shot-path aerial --geometry dense12 --impact-target 0,6,0 --gpu-camera structure --seconds 10
for n in "${!T[@]}"; do [ -f $V/$n/native.frames.csv ] || { echo "no frames for $n"; continue; }
  python3 $V/make-realtime.py $V/$n-raw.mp4 $V/$n/native.frames.csv $V/$n-realtime.mp4 "${T[$n]}" "$NOTE2" 2>&1 | tail -1
  python3 $V/make-overlay.py $V/$n-raw.mp4 $V/$n/native.frames.csv $V/$n.mp4 "${T[$n]}" "$NOTE1" 2>&1 | tail -1; done
echo RERECORD_DONE
