# Single-building motion diagnosis — 2026-09-06

The reported circling reproduced with one building and one projectile. The
renderer and collision shape agreed, but both could be displaced from the
fragment's actual physical center of mass. This was a simulation mass-frame
ownership bug, not simply a graphics transform mismatch.

## Cause and change

Native fracture installs mass, principal inertia and body-to-actor COM transforms
on the GPU. Later scheduler metadata uploads (reproduced by `setWakeCounter`)
replaced those fields with CPU reservation placeholders. The upload preserved
actor pose, so the geometric chunk initially stayed in place. Subsequent rotation
then moved its geometry around the incorrectly placed COM. This also corrupted
collision lever arms, effective mass and subsequent physical response.

`nativeCandidateState` now marks destruction-owned mass properties. The direct-GPU
body upload preserves the resident inverse mass, principal inertia and full COM
transform unless an explicit corresponding host setter is present. Ordinary
bodies retain their existing upload path. First uploads initialize reused slots
normally. No mass properties are copied back to the CPU to implement this fix.

The new `--trace-motion 1` diagnostic explicitly observes the CUDA-written GL
instance buffer, physical GPU actor/shape pose, raw native body COM and velocities,
cluster mass, membership and generation. It verifies rendering against physics
and independently verifies the physical COM against accepted topology. These
observations are optional, outside simulation timing, and separately accounted
in `motion_trace_readback_bytes`. They are not part of normal GPU rendering.

## Results

Identical authored input: one 444-chunk building, 896 bonds, one 20,000 kg sphere,
10 seconds, 60 Hz, maximum one correction per step. The projectile starts at
(0, 24, -48), above and outside the building, and follows its authored ballistic
launch toward it. Materials and impulse-driven fracture settings were unchanged.

| Measurement | Before | After |
|---|---:|---:|
| Observed chunk-frames | 266,400 | 266,400 |
| Max rendering/collision-center discrepancy | 0.0080 mm | 0.0051 mm |
| Max single-chunk center / physical COM discrepancy | 12.0623 m | 0.00434 mm |
| Single chunks ever exceeding 1 mm COM discrepancy | 174 | 0 |
| Single-chunk observations exceeding 1 mm | 67,289 | 0 |

All-cluster COM reconciliation in the corrected run had a maximum error of
0.00628 mm. Chunk 160 provides a clear example: before the fix, its visual center
oscillated around its airborne COM with a 4.743 m radius. After the fix, that
chunk instead settled into rubble. The two simulations diverge physically because
the bug affected collision response; this is a fidelity correction, not a
behavior-preserving optimization.

The corrected run used five correction passes across five different steps, never
more than one per step. It ended with 784 broken bonds and 381 clusters. The
unfixed run had two corrected steps, 783 broken bonds and 380 clusters.

Simulation-only timing in the corrected diagnostic recording: average 1.203 ms,
minimum 0.571 ms, maximum 9.824 ms; 0/600 steps exceeded 16.67 ms. Rendering,
observation, tracing and encoding are excluded. This is not isolated performance
qualification, a whole-game timing, or evidence for large-scene throughput.
Earlier dynamic-scene benchmarks need requalification with corrected physics.

## Validation

- The added offset-COM regression fails on the original engine with
  `scheduler upload replaced resident fragment COM with CPU placeholder`.
- It passes with the fix, including a nonidentity principal inertia frame,
  explicit wake-counter upload and checks of mass, inertia and valid rotations.
- 29 targeted native GPU, persistent shape and direct GPU tests pass.
- The native resimulation regression passes CUDA memcheck with zero errors.
- The corrected capture passes all 266,400 exact-render-buffer / physical-shape
  checks and all-cluster COM checks. No tolerances were loosened.
- The annotated video decodes as 600 frames, 960×540, 60 fps, 10 seconds.

This diagnoses and fixes a reproduced cause of the reported motion. It does not
establish that every artifact in the earlier 113,664-chunk video has the same
cause. That older large recording has not been regenerated in this investigation.

## Artifacts and reproduction

Paths below are relative to the repository root:

- Before: `out/single-impact-trace-20260906/` and corresponding `.mp4`.
- Corrected: `out/single-impact-corrected-20260906/` and corresponding `.mp4`.
- Video with measured trails and timing labels:
  `out/single-impact-diagnosis-20260906/single-building-tracked.mp4`.
- COM comparison: `out/single-impact-diagnosis-20260906/motion-diagnosis.png`.
- Spatial trajectories: `out/single-impact-diagnosis-20260906/corrected-trajectories.png`.
- Measurements and input CSV hashes:
  `out/single-impact-diagnosis-20260906/motion-analysis.json`.
- Build/test logs: `out/mass-frame-*.log`.
- Source and binary provenance: `qualification/single-impact-motion-20260906.json`.

Build the SDK with `tools/scripts/build-destruction-sdk.py --gpu-renderer
--gpu-profiler --jobs 4`, then use an unused output destination:

```bash
out/destruction-sdk/reference/native_destruction_demo \
  --output out/single-impact-reproduction \
  --grid 1 --waves 1 --workload single-impact --seconds 10 --launch-seconds 0 \
  --stress-iterations 8192 --preserve-contact-pairs 1 \
  --gpu-island-repair 1 --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 \
  --gpu-pre-solve-support 1 --gpu-connectivity-owner 1 \
  --audit-islands 1 --audit-motion 1 --trace-motion 1 --record-state 1 \
  --gpu-render 1 --gpu-camera diagnostic \
  --gpu-video /root/workspace/physx-2/out/single-impact-reproduction.mp4

python3 tools/scripts/analyze-native-motion.py \
  out/single-impact-trace-20260906 out/single-impact-corrected-20260906 \
  out/single-impact-plots-reproduction \
  --video out/single-impact-corrected-20260906.mp4
```

The plotter requires numpy, matplotlib and Pillow. Its video trails are explicit
screen-space diagnostic annotations over existing GPU-rendered pixels. They have
no depth occlusion and do not alter the underlying physics or rendered geometry.
