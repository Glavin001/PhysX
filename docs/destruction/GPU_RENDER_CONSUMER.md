# Committed GPU rendering and explicit observations

The native demo now renders the committed destruction view through CUDA/OpenGL
interop. PhysX still performs the intact trial, impulse-driven stress/fracture
and at most one internal correction. The renderer neither predicts fracture nor
runs a separate physics simulation.

Immutable chunk visuals are uploaded once. A CUDA kernel resolves authored
chunk → current root → stable motion slot, transforms local geometry, and writes
an OpenGL instance buffer. Removed chunks are hidden. Slot ownership/generations
are validated before reading motion. Ordinary projectile poses are gathered
through Direct GPU API into device memory. They are never downloaded to draw.

The consumer stream waits on the destruction ready event and the projectile
API's completion event. It records its read-completion event for the next scene
advance. CUDA graphics unmap orders OpenGL's use of the instance buffer. Drawing
requires no CPU completion wait or topology/motion observation. GPU validation
errors accumulate until explicit finalization; an invalid frame cannot be erased
by a later successful one. Reconfiguration requires rebuilding the visual asset.

The renderer is a demo consumer of the public device view, not a new SDK graphics
dependency. It supports this demo's boxes and projectiles, not arbitrary cooked
mesh rendering or a production window/input system. Optional EGL support is
selected explicitly; a requested graphics build fails if EGL/OpenGL is missing.
CPU/WASM builds do not compile this CUDA-only demo path.

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4 --gpu-renderer
out/destruction-sdk/reference/native_destruction_demo \
  --grid 8 --waves 4 --seconds 30 --stress-iterations 8192 \
  --preserve-contact-pairs 1 --gpu-island-repair 1 \
  --gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 \
  --record-state 0 --gpu-render 1 --gpu-camera close \
  --gpu-video out/native-gpu-close.mp4 --output out/recordings/native-gpu-close
python3 tools/scripts/annotate-native-gpu-video.py \
  out/recordings/native-gpu-close out/native-gpu-close.mp4 out/native-gpu-close-timing.mp4
```

`--record-state` now defaults to **0**. `--record-state 1` or `--audit-motion 1`
explicitly enables the old CPU pose/topology observer. Its arrays are not
allocated in resident mode. All launch decisions use a GPU clearance query in
both modes: the CPU observes one height value, then submits an authored shot.
The query checks nearby committed chunks and projectiles, including debris after
fracture. This conservative launch protocol is recorded as
`gpu-clear-aerial-ballistic-v3`; historical v2 runs are not identical-input
performance comparisons.

Telemetry still explicitly observes a fixed topology status for counts. The
summary separates those bytes, optional pose/audit bytes, scalar query/final
validation bytes, and exported pixel bytes. Video export reads only rendered
RGB pixels for a software encoder. A run without video export has no pixel
readback; rendering without CPU pose observation remains supported. GPU hardware
encoding can replace pixel export independently of the simulation data flow.

Simulation min/mean/percentiles/max, deadline misses and achieved simulation
speed come from measured simulate/fetch time. Graphics submission/pixel export
host time is reported separately and is not a pure GPU kernel-duration metric.
The annotation tool displays the measurements over exported pixels. Playback
rate does not establish real-time physics or whole-game throughput. Shared-GPU
captures are correctness evidence, not isolated performance qualification.

Tests exercise analytic rotated/offset chunks, sparse/reused slots, removed
chunks, event ordering, invalid-view errors and launch clearance. End-to-end
fixtures run actual native fracture with and without CPU motion observation,
check unchanged launch commands, preserve independent motion/contact audits,
and require zero pose readback in resident mode. The EGL test runs real GPU
draws without video pixel export.

This removes a consumer-side CPU dependency. Native fragment BodySim registration,
CPU collision/interaction metadata, sleep-safe correction, full native CUDA
memory qualification and scene-scale body pool growth remain unfinished. The
standalone consumer memory check does not close the existing conditional-graph
or native correction memory-qualification issues.

## Recorded qualification

The [qualification record](qualification/gpu-render-consumer-20260906.json)
contains hashes, settings and completed-run evidence. All 35 focused native,
topology and reference tests pass; the standalone consumer memory check has
zero errors. The native conditional-graph/correction memory gate remains open.

A 256-building capture completed 1,800 steps / 30 seconds with 113,664 chunks,
229,376 bonds, 1,024 shots, 368 corrected steps and 97,116 peak clusters. It
rendered 1,800 frames with zero consumer pose readback. The explicit scalar
queries/final validation read 4,104 bytes and topology-count diagnostics read
43,200 bytes. Export read 2,799,360,000 RGB pixel bytes for the software encoder.
The engine's separate CPU contact-graph bridge still downloaded 5,612,461,488
bytes. The video labels both facts; zero render-pose readback is not zero engine
readback.

Simulation averaged 183.424 ms (min 1.033, max 1,474.740), about 0.091x real time.
Graphics submission/export averaged 1.309 ms outside that interval. These are
shared-GPU measurements; no speedup or whole-game 60 Hz claim follows. The
[detailed timing report](qualification/gpu-render-consumer-timing-20260906.md)
records nested/parallel host phases and separate CUDA destruction intervals.
