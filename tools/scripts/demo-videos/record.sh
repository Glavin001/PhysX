#!/bin/bash
# Demo videos with perf overlays. Physics timing (physics_step_ms) excludes the renderer's own cost.
cd /root/workspace/physx-2
V=out/demo-videos-20260918; DEMO=out/destruction-sdk/reference/native_destruction_demo
COMMON="--launch-seconds 0 --stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 --projectile-mass 18000 --material-strength 24 --frame-strength 40 --record-state 0 --audit-motion 0 --trace-motion 0 --standard-scene 1 --sleeping 1 --gpu-render 1 --gpu-resolution 1920x1080 --color-by-cluster 1"
cmake --build out/destruction-sdk --target native_destruction_demo -j 16 > $V/build.log 2>&1 || { echo "demo build failed"; grep -E "error" $V/build.log | head -5; exit 1; }
echo "demo build ok"
run() { name=$1; shift; rm -rf $V/$name $V/$name.mp4 $V/$name-raw.mp4; LD_LIBRARY_PATH=$PWD/physx/bin/linux.x86_64/release $DEMO $COMMON "$@" --gpu-video $V/$name-raw.mp4 --output $V/$name > $V/$name.log 2>&1; echo "$name exit $? $(tail -1 $V/$name.log | cut -c1-140)"; }
run through-wall --grid 1 --waves 1 --workload single-impact --shot-path through-wall --gpu-camera penetration --seconds 6
run building-close --grid 1 --waves 4 --workload bombardment --shot-path aerial --gpu-camera close --seconds 8
run city256-close --grid 16 --waves 1 --workload bombardment --shot-path aerial --gpu-camera close --seconds 8
run city256-overview --grid 16 --waves 1 --workload bombardment --shot-path aerial --gpu-camera overview --seconds 8
python3 $V/make-overlay.py $V/through-wall-raw.mp4 $V/through-wall/native.frames.csv $V/through-wall.mp4 "Projectile through a wall: same-tick fracture + correction (1 building)"
python3 $V/make-overlay.py $V/building-close-raw.mp4 $V/building-close/native.frames.csv $V/building-close.mp4 "One building, four 18 t projectiles, close camera"
python3 $V/make-overlay.py $V/city256-close-raw.mp4 $V/city256-close/native.frames.csv $V/city256-close.mp4 "City 256 buildings (113k chunks, 229k bonds), 256 projectiles, close camera"
python3 $V/make-overlay.py $V/city256-overview-raw.mp4 $V/city256-overview/native.frames.csv $V/city256-overview.mp4 "City 256 buildings (113k chunks, 229k bonds), 256 projectiles, overview"
ls -la $V/*.mp4
echo VIDEOS_DONE
