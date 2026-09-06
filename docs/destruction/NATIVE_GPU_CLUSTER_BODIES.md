# Native GPU cluster solver-body preparation

The scene's native fracture task now converts candidate cluster mass and motion
into the principal-axis body state required by PhysX. This calculation runs on
GPU after candidate connectivity/motion generation, before topology acceptance.
It does not allocate native solver-body slots, transfer collision ownership or
perform the internal correction solve. Those remain the next integration work.

## Data and calculation

`PxDestructionScene` version 5 adds `trialBodies` and `bodyPreparation` to the
CUDA-event-ordered device view. The new POD records are in
`PxDestructionTopologyTypes.h`. They contain:

- Stable candidate component root and the source PhysX GPU body index.
- Physical mass, principal moments and solver inverse mass/inertia.
- COM-to-asset and COM-to-world transforms, with the original asset frame retained.
- World angular velocity and linear velocity at the float solver's stored COM.
- Support membership, independently of physical mass.

The GPU diagonalizes each live cluster's full symmetric inertia tensor using
scaled double-precision Jacobi rotations. Principal moments are ordered and the
basis is right-handed. Repeated moments remain physically valid; principal axes
inside their eigenspace are not unique. Identical inputs produce identical
frames in the tested GPU configuration.

The existing graph transaction supplies physical mass, COM, full inertia and
parent-to-child velocity transfer. Preparation converts those results to PhysX's
principal frame. Linear velocity also accounts for the COM displacement from
float storage and normalization of approximately unit GPU quaternion observations.
Without that reconciliation, offset assets could change their rigid point
velocities during body construction.

Supported components retain physical mass and inertia, while their solver
inverse mass and inertia are zero. A massless authored support remains supported;
it is not converted to a freely moving zero-mass body. Unsupported bodies require
positive mass and positive-definite inertia. Invalid, singular dynamic,
nonfinite, nonconverged or unrepresentable states fail explicitly. No inertia
floor, velocity clamp or artificial axis lock is introduced.

## Transaction and lifetime

There is one candidate record per live candidate component, in the same order as
`trialTopology.activeClusters`. Storage reserves chunk capacity; this does not
allocate one independently simulated rigid body per intact chunk.

`bodyPreparation.valid` gates the whole batch; `count` and `generation` identify
its contents. A nonfracturing frame clears validity/count rather than exposing
old records as current. Readers must obey the enclosing ready/consumer events.
The records describe the most recent candidate even if an unchanged-owner cut
commits immediately afterward. They are not committed body handles.

Preparation error bits are: 1 invalid mass, 2 invalid/nonconverged inertia,
4 invalid motion, 8 unrepresentable float body state. Any preparation error adds
bit 128 to the native stage error and prevents topology/material acceptance,
including when other candidate records are valid.

Native splits still report correction-required bit 8. Accepted destruction
material/topology remains unchanged, but ordinary provisional PhysX motion is
not yet rewound. This milestone must not be treated as a completed physics step
when collision ownership changes.

## Verification

`destruction_gpu_body_state` exercises the production GPU preparation routine
with independent analytic tensors and motion calculations:

- 4,096 rotated anisotropic/isotropic tensors, repeated principal moments,
  physical scales from 1e-25 to 1e25 and supported physical mass.
- Full tensor reconstruction, inverse inertia/mass, frame composition and
  point-velocity continuity, including large asset offsets.
- Approximately unit GPU quaternion observations and the resulting COM shift.
- Identical-input frame repeatability, invalid/singular/nonfinite inputs,
  explicit float representability failure and massless supports.

`physx_native_gpu_body_state` obtains candidates from actual native GPU
stress/material/topology evaluation. It verifies full inertia, COM/provenance,
whole-batch rejection without damage commit, and invalidation on a later
nonfracturing step. A test-only observer creates a body from the GPU-generated
records and calls the internal persistent-shape transfer. The real PhysX GPU
force/torque response then matches independent analytic mass/inertia predictions.
This host fixture is qualification scaffolding, not the finished allocator.

The existing rotating native material fixture additionally checks candidate
solver COM velocity, angular velocity and principal moments against its analytic
centrifugal split, retaining all previous momentum/energy assertions.

Reproduce with:

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4
ctest --test-dir out/destruction-sdk --output-on-failure
/usr/local/cuda/bin/compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/destruction-sdk/topology/destruction_body_test
/usr/local/cuda/bin/compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/destruction-sdk/reference/native_gpu_body_test
```

This milestone makes no full-scene scale, performance or 60 Hz claim. Allocation,
GPU body-slot binding, internal shape transfer, ordinary body/joint checkpointing
and one internal resimulation remain unfinished.

Verified: **46/51 native tests pass**, with the same five known failures; all
three GPU memory checks report zero errors and four installed CPU/GPU consumer
runs pass. Exact commands, outcomes and source/library/log hashes are in
[native-gpu-cluster-bodies-20260905.json](qualification/native-gpu-cluster-bodies-20260905.json).

## Native allocation follow-up

The subsequent native stage now reserves private BodySim/node slots automatically
from compact GPU allocation metadata; see
[NATIVE_GPU_BODY_ALLOCATION.md](NATIVE_GPU_BODY_ALLOCATION.md). The physical
GPU-state initialization, collision transfer and one internal resimulation are
still required before those reservations can become accepted cluster bodies.
