# Native cluster body reservations

This document records the reservation milestone. Physical initialization is now
implemented separately in [NATIVE_GPU_BODY_INITIALIZATION.md](NATIVE_GPU_BODY_INITIALIZATION.md);
remaining split/correction limitations still apply.

Actual native GPU fracture verdicts now reserve the additional PhysX BodySim and
island-node slots inside scene finalization. This connects GPU candidate topology
to scene-owned allocation. The slots are private, inactive and uncommitted: their
physical GPU state initialization, persistent shape transfer and one internal
resimulation remain unfinished. Native splitting still returns incomplete-step
error 8 and does not commit destruction topology or material state.

## GPU/CPU boundary

The GPU prepares full mass/inertia/COM/motion records as described in
[NATIVE_GPU_CLUSTER_BODIES.md](NATIVE_GPU_CLUSTER_BODIES.md). It also determines
which candidate components retain an existing native body and which require a
new slot. Existing bindings stay on the GPU.

On an ownership-changing verdict, stable GPU compaction selects only new-body
requests. Each request contains five 32-bit fields: component root, source body
index, support flag, allocation flag and candidate slot. Only these records and
small completion/count observations reach the CPU. The CPU does not traverse the
bond graph, scan world actors, or read back contact loads, mass tensors or motion
to allocate a body. Returned native IDs are scattered into candidate order on GPU.
Nonfracturing steps do not compact or read back allocation arrays.

`NpDestructionBodyAllocator` owns real BodySim/node reservations. It uses the
native pools and leaves the application's scene API-write guard enabled. Source
lookup uses the island node type plus the controller's current registration;
the registration check is necessary because island deletion is deferred after
body memory can already be released. Unpublished reservations cannot become
configuration sources. Invalid source configuration leaves the previous graph
and its reservations intact.

A retry retaining component root, source body and support kind reuses the same
reservation. Replacement, graph clearing, reconfiguration and scene teardown
release abandoned slots, including removal before their pending GPU upload.
Private objects are allocated without registering them with public factory
listeners. Cancellation does not emit user deletion events. They are absent from
public scene actor/query lists and have no collision shapes. Raw low-level body
storage statistics can include these reserved slots; they are not accepted
physical cluster counts.

Storage grows with actual new candidate clusters. There are no independently
simulated chunk bodies allocated for intact connectivity. This is not yet the
complete scene-wide grow/retry policy for all possible CPU/GPU memory failures.

## Device view and acceptance

`PxDestructionScene` version 6 adds `trialBodyIndices` and `bodyAllocation`.
`bodyAllocation.valid` describes a complete reservation map in candidate cluster
order, with `count`, `reserved` and `generation`. The preparation status also
reports the GPU-produced `allocationRequests` count. The enclosing ready event
orders both GPU compaction and returned-ID publication.

Reservation validity does not mean those indices are ready for physical reads
through `PxDirectGPUAPI`. Fresh slots have allocation placeholders, not the
GPU-prepared mass/COM/motion state. The correction initialization stage must
populate that state before activating or publishing a body. No shape ownership,
ordinary actor/joint state, or destruction material state commits in this phase.
Allocator rejection adds stage error 256. Runtime errors still use bit 4.

Ordinary provisional motion is still not rewound after the incomplete split.
The required next transaction work is GPU initialization of reserved/retained
body state, native collision ownership updates, checkpoint restoration and one
internal correction solve, followed by committed-only event/actor publication.

## Qualification

`physx_native_gpu_body_allocation` uses ordinary `PxScene::simulate/fetchResults`;
the test never allocates candidate actors or orchestrates their reservation. It
checks:

- Intact connectivity allocates no child slots.
- Actual native fracture creates additional, inactive BodySim/node reservations.
- Existing owners retain their IDs and uncommitted bodies stay out of actor lists.
- Repeated verdicts reuse IDs; growth to 256 new child slots retains every request.
- Clearing/reconfiguration before upload, subsequent uploads and scene teardown.
- No user deletion events for private reservations.
- Unallocated, unpublished and released source rejection, including deferred
  island deletion.
- Both native sleeping and sleeping-disabled scene configurations.
- One new component among 64 unchanged clusters emits only one CPU allocation
  request and preserves all unchanged device bindings.

Reproduce:

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4
ctest --test-dir out/destruction-sdk --output-on-failure
/usr/local/cuda/bin/compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/destruction-sdk/reference/native_gpu_allocation_test
```

These are correctness/lifecycle checks. No complete native destruction, full-scene
scale, performance or 60 Hz qualification is claimed by this milestone.

Verified: **47/52 native tests pass**, with the same five known failures. Three
GPU memory checks report zero errors; all four installed CPU/GPU consumers pass.
Exact commands, results and source/artifact/log hashes are recorded in
[native-gpu-body-allocation-20260906.json](qualification/native-gpu-body-allocation-20260906.json).
