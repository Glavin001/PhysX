#!/bin/bash
cd /root/workspace/physx-2
V=out/demo-videos-20260918; DEMO=out/destruction-sdk/reference/native_destruction_demo
COMMON="--stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 --projectile-mass 18000 --material-strength 24 --frame-strength 40 --record-state 0 --audit-motion 0 --trace-motion 0 --standard-scene 1 --sleeping 1 --gpu-render 1 --gpu-resolution 1920x1080 --color-by-cluster 1 --waves 1 --workload bombardment --shot-path aerial"
NOTE="Stats: physics step time per tick (excludes the renderer; the CUDA renderer shares the GPU). RTX 5060 Ti."
run() { name=$1; shift; rm -rf $V/$name $V/$name.mp4 $V/$name-raw.mp4; LD_LIBRARY_PATH=$PWD/physx/bin/linux.x86_64/release $DEMO $COMMON "$@" --gpu-video $V/$name-raw.mp4 --output $V/$name > $V/$name.log 2>&1; echo "$name exit $?"; }
run city16-staggered-close    --grid 4  --launch-seconds 4  --seconds 10 --gpu-camera close
run city16-staggered-mid      --grid 4  --launch-seconds 4  --seconds 10 --gpu-camera mid
run city64-staggered-overview --grid 8  --launch-seconds 8  --seconds 12 --gpu-camera overview
run city64-staggered-mid      --grid 8  --launch-seconds 8  --seconds 12 --gpu-camera mid
run city256-staggered-overview --grid 16 --launch-seconds 14 --seconds 20 --gpu-camera overview
run city256-staggered-mid      --grid 16 --launch-seconds 14 --seconds 20 --gpu-camera mid
python3 $V/make-overlay.py $V/city16-staggered-close-raw.mp4 $V/city16-staggered-close/native.frames.csv $V/city16-staggered-close.mp4 "City 16 buildings, 16 impacts staggered over 4 s, close camera" "$NOTE"
python3 $V/make-overlay.py $V/city16-staggered-mid-raw.mp4 $V/city16-staggered-mid/native.frames.csv $V/city16-staggered-mid.mp4 "City 16 buildings, 16 impacts staggered over 4 s, quarter view" "$NOTE"
python3 $V/make-overlay.py $V/city64-staggered-overview-raw.mp4 $V/city64-staggered-overview/native.frames.csv $V/city64-staggered-overview.mp4 "City 64 buildings, 64 impacts staggered over 8 s, overview" "$NOTE"
python3 $V/make-overlay.py $V/city64-staggered-mid-raw.mp4 $V/city64-staggered-mid/native.frames.csv $V/city64-staggered-mid.mp4 "City 64 buildings, 64 impacts staggered over 8 s, quarter view" "$NOTE"
python3 $V/make-overlay.py $V/city256-staggered-overview-raw.mp4 $V/city256-staggered-overview/native.frames.csv $V/city256-staggered-overview.mp4 "City 256 buildings (113k chunks), 256 impacts staggered over 14 s, overview" "$NOTE"
python3 $V/make-overlay.py $V/city256-staggered-mid-raw.mp4 $V/city256-staggered-mid/native.frames.csv $V/city256-staggered-mid.mp4 "City 256 buildings (113k chunks), 256 impacts staggered over 14 s, quarter view" "$NOTE"
ls -la $V/*staggered*.mp4 | grep -v raw
echo STAG_DONE
