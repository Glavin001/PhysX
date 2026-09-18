#!/bin/bash
cd /root/workspace/physx-2; V=out/demo-videos-20260918; DEMO=out/destruction-sdk/reference/native_destruction_demo
until grep -q BRIDGE_DONE $V/bridge-retry.log; do sleep 15; done
COMMON="--launch-seconds 0 --stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 --frame-strength 40 --record-state 0 --audit-motion 0 --trace-motion 0 --standard-scene 1 --sleeping 1 --gpu-render 1 --gpu-resolution 1920x1080 --color-by-cluster 1 --grid 1 --shot-path aerial"
NOTE1="Stats: physics step time per tick (excludes the renderer; the CUDA renderer shares the GPU). RTX 5060 Ti."
NOTE2="REAL-TIME playback: each frame is held for max(16.7 ms, its physics step time); heavy ticks slow the video as a game would. RTX 5060 Ti; the CUDA renderer shares the GPU."
n=dense12-block; rm -rf $V/$n $V/$n-raw.mp4 $V/$n.mp4 $V/$n-realtime.mp4
LD_LIBRARY_PATH=$PWD/physx/bin/linux.x86_64/release $DEMO $COMMON --geometry dense12 --workload bombardment --waves 2 --projectile-mass 120000 --material-strength 3 --impact-target 0,6,0 --gpu-camera structure --seconds 10 --gpu-video $V/$n-raw.mp4 --output $V/$n > $V/$n.log 2>&1; echo "$n exit $? $(grep -v 'arrival\|^native' $V/$n.log | tail -1 | cut -c1-100)"
[ -f $V/$n/native.frames.csv ] && { python3 $V/make-realtime.py $V/$n-raw.mp4 $V/$n/native.frames.csv $V/$n-realtime.mp4 "Solid 12x12x12 block (1,728 chunks), two 120 t projectiles, material strength 3" "$NOTE2" 2>&1 | tail -1; python3 $V/make-overlay.py $V/$n-raw.mp4 $V/$n/native.frames.csv $V/$n.mp4 "Solid 12x12x12 block (1,728 chunks), two 120 t projectiles, material strength 3" "$NOTE1" 2>&1 | tail -1; }
echo DENSE_DONE
