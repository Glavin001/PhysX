# Native GPU cluster body initialization

Native scene finalization now initializes the reserved cluster slots in PhysX's
actual persistent GPU body pool. It consumes the GPU-produced candidate COM,
principal inertia, mass and point-velocity-compatible motion. The CPU receives
only the existing compact allocation requests, native IDs and completion status;
it does not read back or calculate physical body state.

This completes physical initialization of **new private slots**, not native split
acceptance. Retained owners keep their ordinary trial state. Shape transfer,
checkpoint restoration and one internal resimulation remain unfinished. A split
still returns incomplete-step error 8 without committing destruction topology or
material state; ordinary provisional motion is still not rewound.

## Initialization boundary

After candidate preparation and scene-owned allocation complete:

1. Grow the existing GPU body and optional acceleration buffers on the PhysX
   simulation stream, preserving old contents with the normal storage helper.
2. Refresh the Direct GPU actor descriptor after potential relocation.
3. Validate the compact reservation mapping on GPU before any slot writes.
4. Initialize only new private slots, including their solver COM frames, inverse
   mass/inertia, motion and inherited physical settings. Source slots remain
   read-only. Native allocation guarantees private destinations cannot alias any
   public source or another live destination.
5. Reset inherited sleep accumulators and initialize optional previous velocities
   from the new motion, with zero initial observed acceleration. Do not copy trial
   external acceleration accumulators: the future rewind transaction must restore
   and distribute commands exactly once.
6. Publish initialization status with a CUDA event, then consume the corresponding
   pending CPU placeholder uploads. One queue compaction preserves other updates.
   The allocator consumes its initial inactive notification before initialization;
   otherwise fetchResults would interpret it as a sleep transition and zero motion.

Reserved bodies stay inactive, shapeless and absent from public actor/query lists.
They are not frozen approximations of accepted physical bodies. Initialization
retries reuse allocation IDs but refresh physical state from the current verdict.
The CPU cores still contain allocation placeholders and must not be treated as
committed observations or uploaded during subsequent collision transfer.

## Kinematic configuration

PhysX replaces effective damping and speed limits while a body is kinematic and
normally retains its authored dynamic values only in CPU backup storage. Detached
dynamic fragments need those authored values. The ordinary configuration upload
now preserves them in a separate GPU body field, including property edits while
kinematic. Fracture initialization reads that resident field, without host
configuration traversal at the fracture boundary. Supported candidates retain
the effective kinematic settings. Mass/inertia always come from chunk properties.

Existing GPU body field offsets are unchanged. The private GPU body record grows
from 224 to 240 bytes, and the low-level CPU rigid body gains one configuration
vector. These are internal layout changes: rebuild PhysX and its native modules
together. Performance impact has not been qualified. No timestep, solver
iterations, material parameters, force limits or test tolerances were relaxed.

## Device status

`PxDestructionScene` version 7 extends `PxDestructionBodyAllocationStatus` with
`initialized` and `initializationError`. With a valid allocation batch,
`initialized == reserved` and zero initialization error mean new reserved indices
have physical GPU state after the device view's ready event. Retained indices
still contain their unchanged trial-step state. No actor/topology commit is
implied. Initialization error 1 is invalid mapping, 2 is CUDA/storage failure;
either adds native stage error bit 512.

The storage helper retains upstream allocation behavior. This milestone does
not establish recoverability from every CPU/GPU allocation failure or finish the
scene-wide capacity growth/retry policy.

## Verification scope

`physx_native_gpu_body_allocation` covers actual native initialization, 256-child
buffer growth, retry/removal/teardown, supported and dynamic children, inherited
physical settings, post-insertion kinematic configuration edits, and private
actor/event isolation. It runs with sleeping enabled/disabled and acceleration
storage enabled/disabled. Moving fixtures run both TGS and PGS and check actual
GPU COM/inertia/motion, analytic point-velocity continuity, retained parent state,
a GPU-only source parameter and public Direct GPU pose commands after growth.

Reproduce:

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4
ctest --test-dir out/destruction-sdk --output-on-failure
/usr/local/cuda/bin/compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/destruction-sdk/reference/native_gpu_allocation_test
```

Verified: **47/52 native tests pass**, with the same five known failures. Three
GPU memory checks report zero errors; all four installed CPU/GPU consumers pass.
Exact results and hashes are in
[native-gpu-body-initialization-20260906.json](qualification/native-gpu-body-initialization-20260906.json).
These checks do not establish complete native destruction or full-scene 60 Hz
performance.
