#!/bin/bash
cd /root/workspace/physx-2; V=out/demo-videos-20260918
NOTE1="Stats: physics step time per tick (excludes the renderer; the CUDA renderer shares the GPU). RTX 5060 Ti."
NOTE2="REAL-TIME playback: each frame is held for max(16.7 ms, its physics step time); heavy ticks slow the video as a game would. RTX 5060 Ti; the CUDA renderer shares the GPU."
declare -A T=( [through-wall]="Projectile through a wall: same-tick fracture + correction (1 building)" [building-close]="One building, four 18 t projectiles, close camera" [city256-close]="City 256 buildings (113k chunks, 229k bonds), 256 projectiles, close camera" [city256-mid]="City 256 buildings (113k chunks, 229k bonds), 256 projectiles, quarter view" [city256-overview]="City 256 buildings (113k chunks, 229k bonds), 256 projectiles, overview" [city16-staggered-close]="City 16 buildings, 16 impacts staggered over 4 s, close camera" [city16-staggered-mid]="City 16 buildings, 16 impacts staggered over 4 s, quarter view" [city64-staggered-overview]="City 64 buildings, 64 impacts staggered over 8 s, overview" [city64-staggered-mid]="City 64 buildings, 64 impacts staggered over 8 s, quarter view" [city256-staggered-overview]="City 256 buildings (113k chunks), 256 impacts staggered over 14 s, overview" [city256-staggered-mid]="City 256 buildings (113k chunks), 256 impacts staggered over 14 s, quarter view" )
for n in through-wall building-close city256-close city256-mid city256-overview city16-staggered-close city16-staggered-mid city64-staggered-overview city64-staggered-mid city256-staggered-overview city256-staggered-mid; do
  python3 $V/make-realtime.py $V/$n-raw.mp4 $V/$n/native.frames.csv $V/$n-realtime.mp4 "${T[$n]}" "$NOTE2" 2>&1 | tail -1
  python3 $V/make-overlay.py $V/$n-raw.mp4 $V/$n/native.frames.csv $V/$n.mp4 "${T[$n]}" "$NOTE1" 2>&1 | tail -1
done
ls -la $V/*.mp4 | grep -v raw
echo REGEN_DONE
