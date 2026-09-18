# Experimental Direct GPU native sleeping and host observation, PhysX 5.10

`5.10-direct-gpu-sleep.patch` applies to NVIDIA-Omniverse/PhysX commit
`3ca45ad36e9755f7c8c5bea9f7c57d308d9f0c54`. This is an opt-in, rigid-body
prototype with an opt-in host command/observation adapter. It is not a
replacement for full destruction rollback or a fully GPU-owned city pipeline.
The ordinary GPU and stock Direct GPU defaults remain intact.

## Build an isolated SDK

From the dependency repository:

```sh
python3 tools/scripts/build-physx-gpu-activity.py \
  --source /root/PhysX \
  --destination /root/workspace/physx-gpu-activity \
  --cc /usr/bin/clang --cxx /usr/bin/clang++ \
  --cuda /usr/local/cuda-12.8/bin/nvcc
```

The source may also be a Git URL; the default is the official NVIDIA repository.
The recipe checks the exact base and patch, refuses unrelated destination edits,
keeps the source SDK untouched, builds CPU and GPU components together, and emits
`physx/gpu-activity-manifest.json` with artifact hashes. CUDA and a working Linux
C++ toolchain must already be installed. Linux x86-64 is the validated platform.
Use the generated `physx` directory as `PHYSX_ROOT`, and its
`bin/linux.x86_64/release` directory as `PHYSX_LIB_DIR`.

The modified CPU library explicitly loads `libPhysXGpuActivity_64.so`. This name
prevents a stock `libPhysXGpu_64.so` from silently satisfying the experimental
engine's different internal interface. Rebuild every component against this SDK;
do not mix patched and stock CPU libraries. A checked-in source patch is the
reproducibility boundary; generated SDK files do not belong in this repository.

## Ownership and sequencing

1. `ExtStressPhysXGpuActivity::configureScene` enables
   `eENABLE_DIRECT_GPU_API | eENABLE_DIRECT_GPU_SLEEPING` after the caller sets
   GPU dynamics, GPU broadphase and a CUDA context. It returns false on stock
   headers or invalid configuration without changing the descriptor. The SDK
   exposes `PX_DIRECT_GPU_SLEEPING_VERSION == 1` for capability detection.
2. GPU sleep-energy calculations and the native CPU island manager remain the
   authorities for activity. Each solved rigid body exports its existing
   eight-byte wake-counter/flags record at the existing completion fence. Pose
   and velocity readback stays disabled. This is per-active-body metadata,
   not a fully GPU-owned island manager or a transition-only stream.
3. CPU bookkeeping imports only sleeping flag bits. Importing GPU initialization
   flags would allow a later metadata update to overwrite device motion with
   stale CPU values. CPU pose/cache updates and absent Direct GPU scene-query
   freeze arrays are excluded from the re-enabled activity callback path.
4. Actual sleep transitions zero velocities and force/torque accumulators on
   device. PhysX can integrate a body while island deactivation runs in parallel;
   sparse rollback gathers the existing pre-step solver poses on device and
   refreshes GPU shape bounds via the Direct GPU pose setter. Only body indices
   cross H2D. Transition batches complete before fetch returns. Pending explicit
   sleep resets complete before a public wake command or the next simulation.
   Removed bodies are erased before their indices can be reused. A related
   insertion fix invalidates retired CPU body pointers and compacts the pending
   upload queue once per frame. Otherwise a stale queued update can consume a
   replacement body's first-upload flag after the allocator reuses its storage,
   producing NaNs in Direct GPU dynamics.
5. `ExtStressPhysXGpuActivity::write` validates a complete batch before waking
   actors, then writes device values with an optional producer CUDA event.
   Whole-batch validation rejects null, removed, duplicate and kinematic actors.
   Buffers persist between calls. Calls are synchronous, outside simulation, on
   the scene-owning thread. Raw device writes require an explicit `wakeUp()`;
   device values alone cannot activate the native CPU islands.

6. The optional `eENABLE_DIRECT_GPU_HOST_ACCESS` flag additionally requires
   Direct GPU native sleeping and exposes `PX_DIRECT_GPU_HOST_ACCESS_VERSION == 1`.
   Native CPU pose/velocity commands queue only explicitly changed fields for
   the next simulation upload. Native force modes accumulate velocity deltas,
   applied after explicit velocity commands; force/torque clearing is explicit.
   Metadata-only updates preserve device motion. Mixing immediate device writes
   with pending CPU commands does not provide last-call-wins ordering: pending
   CPU commands still execute at the next simulation.
7. `ExtStressPhysXGpuHostMirror::synchronize` explicitly gathers a caller's live
   bodies into persistent pinned/device buffers, then publishes CPU motion
   getters and scene-query poses with one host wait. Publication neither wakes
   bodies nor queues GPU writes. It rejects pending CPU pose/velocity commands
   rather than overwriting them. The owner must call it after fetch, include
   newly sleeping bodies, and observe before pose-dependent CPU work. This
   deliberately reads back selected motion; the initial city reference adapter
   selects every dynamic body and therefore does not retain the prototype's
   readback reduction. It is not a network commit or rollback boundary.
8. Kinematic targets retain native velocity computation and publish final poses
   and GPU bounds before fetch returns. The redundant CPU kinematic bounds task
   is skipped in host-access mode: its stale bounds array otherwise overwrites
   unrelated dynamic GPU bounds and can make nearby bodies miss collisions.

The eight-byte record replaces the ordinary rigid-body pose/velocity portion
of automatic readback (explicit host observation adds its requested motion). Other metadata transfers, topology updates, CPU islands and fences
still exist. Sparse sleep rollback adds transition-only kernels and fences;
steady resting steps have no transition batch. No materials, solver iterations,
sleep thresholds, timestep or fracture thresholds are weakened.

## Correctness and limits

`gpu_activity_test` compares ordinary GPU native sleep against the extension at
identical settings. It covers resting zeros, metadata writes, force/torque and
velocity commands, finite-mass collision wake, support removal, joint wake,
repeated explicit sleep/wake, logical activity checkpoints, producer events,
removed/reinserted bodies, replacement index lifetime and articulation rejection.
Trace gates are 0.1 mm position, 1 mm/s linear velocity, 0.002 rad/s angular
velocity, and quaternion dot at least 0.9999. Exact command/zero-motion checks
also catch deferred resets clobbering later writes. This is not an exhaustive
vehicle, dense-pile or city destruction qualification.

The existing motion checkpoint now captures logical sleeping and wake counters
in this mode. It rejects changed GPU indices and kinematic classification.
Callers must invalidate/recapture around topology changes: public GPU indices
are reusable, and actor pointers are borrowed. Force buffers, sleep-energy
history, contact caches, support topology and fracture generation are not part
of that checkpoint. It does not guarantee deterministic replay across sleep
transitions. Without explicit host access/observation, CPU motion getters and
scene queries remain subject to Direct GPU restrictions. Articulations are
rejected. Host-access fixtures additionally compare native CPU commands, force
modes, query publication, freeze/kinematic targets and dynamic landing beside a
moving kinematic, under both PGS and TGS as applicable. These fixtures do not
qualify full city destruction, vehicles, fallback collision paths or networking.

The contact decoder now retains zero-impulse normal points, separation, normals,
original normal-impulse scalars and stable per-pair point order, alongside
nonzero friction anchors. This preserves support geometry and couples while
allowing consumers to reproduce native body-pair force thresholds. Consumers
must aggregate across compound shapes and the solver's shared static world
body; a per-shape threshold can omit a distributed load. Actor identifiers are
opaque until validated against live shape ownership.
`PxDirectGPUAPI::getShapeContactIndex` exposes the live exclusive shape's
transform-cache identity for this mapping. `PxShape::getGPUIndex()` is a geometry
index from a different allocator; the two can diverge after fracture migration.
Node colliders are now exclusive to their current actor, with an adapter-owned
reference preserving each collider through detach/attach transfers. Both index
spaces are reusable and must not be treated as generation-bearing identities.

## Run the campaign

From the associated game repository, with the GPU idle:

```sh
python3 scripts/gpu-activity-campaign.py \
  --dependency /root/workspace/blast-stress-solver-2 \
  --sdk /root/workspace/physx-gpu-activity/physx \
  --output bench-results/gpu-sleep-run --bodies 4096 --trials 3 --memcheck
```

The runner checks engine hashes, builds the adapters, runs activity/checkpoint/
contact/CUDA stress tests, optionally runs Compute Sanitizer, and validates every
expected sample in a rotated five-mode benchmark. It refuses competing GPU
processes and an existing output directory. It never stops or modifies a live
city deployment. The game report records measured results and production gates.

## Rotation fidelity correction (2026-09-05)

The patch now also corrects speculative CCD's rotational search envelope.
The radius encloses local geometry in the body's mass frame, including offset
compound shapes. It does not combine stale CPU world bounds with GPU-owned
positions. Search inflation is `min(abs(omega)*dt, 2)*radius`: an arc-length
bound for small rotations and the full diameter for larger rotations. Under
the existing velocity prediction, every intermediate rotated point remains
inside this envelope. It does not clamp angular velocity or collision impulses.
Speculative CCD remains an approximate predictive contact method, not an exact
angular time-of-impact solver under arbitrary acceleration.

The host adapter and game bridge set PhysX's supported numerical angular range
instead of the default 100 rad/s ceiling. The shared stress solver's centrifugal
input is outward, so radial bonds carry tension. `velocity_fidelity_test` checks
50 and +/-500 rad/s, analytical tensile stress, fracture momentum and replay in
CPU, ordinary GPU and Direct GPU modes, with speculative CCD enabled. A selected
six-case CTest campaign also covers GPU activity/wake, contact drain and device
checkpoints. This is not full city qualification or a new performance result.

The build recipe pins `_64` output naming explicitly. It preserves the cached
compiler path when a requested command resolves to the same executable, and
rejects an actual compiler change in an existing build. The artifact manifest
lists the exact consumer libraries, including PVDRuntime; unrelated or stale
unsuffixed artifacts are excluded. Use the builder to refresh the manifest after
SDK edits. Do not interpret archive existence alone as proof of a rebuild.
