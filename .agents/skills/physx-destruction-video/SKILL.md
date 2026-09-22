---
name: physx-destruction-video
description: Record the current native PhysX GPU destruction demo as 1080p/60 H.264. Use when asked for a destruction video, MP4, demo capture, GPU-rendered clip, cluster-colored playback, or annotated native bombardment recording. Do not use for performance qualification.
---

# PhysX destruction video

Record committed native GPU destruction. The renderer follows GPU cluster and
projectile poses. It does not script fracture. 60 fps playback is not a
real-time or 8 ms claim. Performance campaigns stay in
[physx-destruction-performance](../physx-destruction-performance/SKILL.md).

This is a repository-local skill. Run commands from the repository root.

## Do not use

- `tools/scripts/record-destruction-demo.py` and [DEMO.md](../../../docs/destruction/DEMO.md) — old CPU-orchestrated reference
- `demos/blast-stress-demo/recorder` offline replay unless the user asks to re-render an existing `--record-state 1` capture
- `--standard-scene 1` with `--gpu-connectivity-owner 1`
- `--audit-motion`, `--profile-phases`, `--profile-gpu`, CUPTI, or `--record-state 1` on a hero capture
- Material, mass, iteration, or correction changes to make the clip look real-time

## Machine

Linux, RTX 4090 / sm_89, CUDA >= 12.8, `ffmpeg`, `ffprobe`, `nvidia-smi`. One GPU
job at a time. Do not stop other developers' processes. macOS cannot produce
this video.

## Build

Incremental if `out/destruction-sdk` already has the GPU renderer:

```sh
cmake --build out/sdk-release --target PhysX PhysXGpu PhysXDestructionGpuRuntime -j4
cmake --build out/destruction-sdk --target native_destruction_demo -j3
```

Otherwise:

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4 --cuda-architectures 89 --gpu-renderer
```

Binary: `out/destruction-sdk/reference/native_destruction_demo`. Output
directories must not already exist.

## Flagship capture

256 buildings, 113,664 chunks, 229,376 bonds, four-wave bombardment, 30 s / 1,800
steps, one correction max. Two cameras are two physics runs; label them as such.

**Close (hero):**

```sh
STAMP=$(date +%Y%m%d)
OUT=out/recordings/native-gpu-256-close-$STAMP
out/destruction-sdk/reference/native_destruction_demo \
  --grid 16 --waves 4 --seconds 30 --stress-iterations 8192 \
  --preserve-contact-pairs 1 \
  --gpu-island-repair 1 \
  --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 \
  --gpu-connectivity-owner 1 \
  --color-by-cluster 1 \
  --record-state 0 --gpu-render 1 --gpu-camera close --record-fps 60 \
  --gpu-video $OUT-raw.mp4 --output $OUT
python3 tools/scripts/annotate-native-cluster-video.py \
  $OUT $OUT-raw.mp4 $OUT-captioned.mp4
```

**Overview:** same flags with `--gpu-camera overview`, a new `--output` /
`--gpu-video`, and `annotate-native-gpu-video.py` instead of the cluster annotator.

If 256-building encode is too heavy, use `--grid 8` (64 buildings) with the same
flags and say so in the deliverable.

`--gpu-camera` is `close`, `overview`, `diagnostic`, or `penetration`. Connectivity
owner requires the island-repair and three pre-solve flags together.

## Accept the result

`native.summary.json` `status` must be `completed`. Frame count must match
`seconds * record_fps` (1,800 at 30 s / 60 fps). Decode the finished H.264:

```sh
ffmpeg -hide_banner -loglevel error -i $OUT-captioned.mp4 -f null -
```

## Deliver

- Captioned MP4(s) plus the capture directory (`native.summary.json`,
  `native.frames.csv`, hashes)
- `git rev-parse HEAD`, GPU name from `nvidia-smi`, grid/camera, and that this is
  a shared-GPU visual, not isolated timing
- Chunk/bond/shot counts from the summary; do not invent real-time from playback

## Docs

- [GPU render consumer](../../../docs/destruction/GPU_RENDER_CONSUMER.md)
- [Bombardment recording](../../../docs/destruction/NATIVE_BOMBARDMENT_RECORDING.md)
- [Connectivity owner](../../../docs/destruction/GPU_CONNECTIVITY_OWNERSHIP.md)
- [Cluster colors](../../../qualification/cluster-colored-demo-20260906.md)
