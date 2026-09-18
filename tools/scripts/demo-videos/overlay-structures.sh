#!/bin/bash
cd /root/workspace/physx-2; V=out/demo-videos-20260918
until grep -q STRUCT_DONE $V/structures.log; do sleep 15; done
NOTE1="Stats: physics step time per tick (excludes the renderer; the CUDA renderer shares the GPU). RTX 5060 Ti."
NOTE2="REAL-TIME playback: each frame is held for max(16.7 ms, its physics step time); heavy ticks slow the video as a game would. RTX 5060 Ti; the CUDA renderer shares the GPU."
declare -A T=( [tower64-collapse]="64-storey tower (2,368 chunks), two 18 t projectiles at the base, material strength 8: topples" [tower64-stands]="64-storey tower (2,368 chunks), two 18 t projectiles at the base, material strength 24: base shattered, tower stands" [bridge64-midspan]="64 m bridge deck supported at both ends, 18 t projectile at mid-span" [cantilever64-tip]="64 m cantilever beam fixed at one end, 18 t projectile near the free tip" [dense12-block]="Solid 12x12x12 block (1,728 chunks), two 18 t projectiles" [chain256-column]="256 m slender column (256 chunks), 18 t projectile near the top" [panel32-plate]="32x32 plate on four corner supports, 18 t projectile at the centre" [building-weak]="Building, four 18 t projectiles, material strength 6 (weak)" [building-strong]="Building, four 18 t projectiles, material strength 100 (strong)" [building-heavy-shot]="Building, four 120 t projectiles, material strength 24" )
cp -r $V/tower-test $V/tower64-stands 2>/dev/null; cp $V/tower-test-raw.mp4 $V/tower64-stands-raw.mp4 2>/dev/null
for n in tower64-collapse tower64-stands bridge64-midspan cantilever64-tip dense12-block chain256-column panel32-plate building-weak building-strong building-heavy-shot; do
  [ -f $V/$n-raw.mp4 ] || { echo "missing $n"; continue; }
  python3 $V/make-realtime.py $V/$n-raw.mp4 $V/$n/native.frames.csv $V/$n-realtime.mp4 "${T[$n]}" "$NOTE2" 2>&1 | tail -1
  python3 $V/make-overlay.py $V/$n-raw.mp4 $V/$n/native.frames.csv $V/$n.mp4 "${T[$n]}" "$NOTE1" 2>&1 | tail -1
done
echo OVERLAY_STRUCT_DONE
