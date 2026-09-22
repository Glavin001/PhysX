# Experimental CuMetal motion descriptor root

`PX_CUMETAL_EXPLICIT_MOTION_ROOT` is an opt-in compiler hint, OFF by default and
qualified for the motion-allocation component suite; full scenes remain unqualified. The safe helper exposes `--cumetal-explicit-motion-root`
and records its state/scope in the build manifest. CUDA rejects enabling it. The original CUDA/default
kernel signature and algorithms remain unchanged. It does not enable broad O1
inlining or erase unsupported LLVM freeze instructions.

## Scope and allocation contract

The hint adds one explicit `const NativeMotionAddresses* __restrict__` argument
to the private `allocateNativeMotionRequests` kernel. Its graph construction
passes `NativeMotionAllocation::mAddresses`. The original count and prefix
helpers continue to receive the original view; they read no address descriptor
members. Compaction and final owner assignment use a local view with the explicit
root rebound, and those two helpers are force-inlined to expose its provenance
to the compiler. The same hint
force-inlines `PxContactStreamIterator::nextPatch`; its shared iterator body is
unchanged. Both changes expose private pointer updates, not alternative physics.

The restriction applies only to the descriptor allocation itself. Every nested
body/node/previous/acceleration/scratch pointer keeps its existing aliasing
semantics. There is no assertion that nested pointees are mutually disjoint.

Evidence in `PxgDestructionMotionSlots.cuh`:

- `initialize` obtains `mAddresses` from its own `cudaMalloc(sizeof(*mAddresses))`.
  Offsets, birth transaction and address-error storage use separate allocations.
  View buffers are supplied before this descriptor allocation exists.
- The production caller allocates `mTrialBodyIndices` (the written
  `candidateIndices`) independently in `PxgDestructionRuntime.cu`, along with
  compact requests, returned body indices, trial bodies and the motion pool.
- The descriptor is only written by ordered host-to-device copies in
  `registerAddresses`, `setNodes`, `setStorage` and `setResources`/`setCapacity`.
  Device kernels read its members and may write nested pointees; no device
  kernel writes descriptor bytes.
- Production descriptor refreshes and graph execution use the ordered runtime
  stream. Storage producer events are joined before refresh/consumption.
  Exceptional resource growth is outside graph execution. The descriptor remains
  allocated across graph replay; `clear` destroys graphs before freeing it.
- `addressView()` exposes a const pointer for the node-range clearing kernel,
  which reads it. The production class has no path that returns its allocation
  as writable body/node/scratch storage.

Passing a descriptor allocation that overlaps writable storage, writing its
bytes concurrently, or freeing/rebinding its allocation while the graph is in
flight violates this contract. Const/noalias must not be generalized to arbitrary
caller memory, nested pointees, or values loaded through them.

## Transform articulation descriptor array

The same flag exposes the existing `const PxgArticulation* PX_RESTRICT` local
root in `updateTransformAndBoundArray.cu` as an explicit kernel parameter.
`PxgSimulationCore::update` passes `mArticulationBuffer.getDevicePtr()` only to
`UPDATE_TRANSFORMCACHE_AND_BOUNDARRAY` using a separate `transformParams` array;
later kernels continue using their unchanged original argument array.

`PxgSimulationCore.cpp` creates the articulation pool from the independently
owned `mArticulationBuffer` (`allocateCopyOldDataAsync`), and the simulation
controller descriptor normally points to that same allocation via
`desc.mArticulationPool`. The transform launch joins the solver stream before
reading it. This exposes an existing descriptor restriction across the kernel
ABI; it does not add restrictions to arrays reached through articulation fields.
The transform kernel reads descriptor bytes while writing separate transform,
bounds and nested motion buffers. Allocation/descriptor updates must remain
ordered outside that kernel's execution. Root's isolated run 936 compiled this
shared transform source with the explicit argument; full scene/articulation
numerical qualification is still required.

## Qualification

`motion_slots_test.cu --descriptor-stability` executes the actual captured
allocation graph twice at a 129-request tail. It checks exact owners, physical
body values, node births, and byte-for-byte descriptor immutability during each
launch. Between launches it updates the descriptor to a new node allocation;
the old allocation stays alive and must retain its original birth counters.
This checks that the graph preserves the root address while reading current
nested pointer values. The test is also part of the existing complete motion
slot suite, whose invalid grants, aliases, counts, retries and exactly-once
commit checks remain unchanged.

Required evidence before default enablement: hinted native runtime compilation,
original CUDA build, hinted graph numerical test and existing full motion slot
suite, followed by the native awake scene and integrated correction/publication
checks. Source availability, compile-only success and CPU helper tests do not
establish GPU correctness. No precision, tolerance, correction, warm-start,
convergence or failure-publication policy changes are permitted.

## Compile evidence

Root's serialized run 932 compiled the actual shared `PxgDestructionRuntime.cu`
with the refined hint on compiler 925. This closes the nextPatch and motion
descriptor pointer-proof frontiers without broad inline-500 or freeze erasure.
Native descriptor-stability (949) and the complete motion-slot suite (950)
pass on Apple GPU through 113,664 requests, with no forced per-kernel sync.
These compile production headers into the fixture; they do not execute the
private kernels from object 932. Transform (939) and cloth contact/attachment
(951) compile with matching host signatures both OFF and ON. The later motion
pointer-proof regression is resolved: the actual `PxgDestructionRuntime.cu`
compiles again (961), following passing descriptor pointer-permutation GPU and
compiler checks (959). Soft-body, soft-body GM and particle-controller sources
also compile with matching host OFF/ON signatures (964/966/967).

The complete `updateBodiesAndShapes.cu`, including the staging and existing-tendon
paths below, compiles with host OFF/ON checks (980). Its actual production object
links into the bounds-refresh fixture (981), and all 14 Apple-GPU cases pass
(982): exact transforms/bounds/update flags, zero/single/tail and multi-block work,
queued captured snapshots, guards and isolated invalid-index/capacity/ownership
errors. That fixture executes `refreshReboundShapeBounds`; it does not qualify
articulation tendon updates or a full correction transaction. The complete GPU
module and native scene have not yet linked or run. Evidence numbers refer to
CuMetal's `out/tests/pointer-tuples/command-<number>.log`.

Both CMake paths propagate the same flag to host and device code; configure-time
rejection of CUDA and generated command inspection are CPU checks. None of these
component results establishes scene/SDK acceptance or Linux CUDA qualification.

## CuMetal execution requirements

The CuMetal motion allocator requires an Apple device name, 32-wide warps,
at least 128 threads per block and cooperative launch support. Negative
capability cases are tested. CUDA retains its architecture 8.9 requirement.
CuMetal uses one cooperative block with the existing grid-stride work loops;
the NVIDIA occupancy-based block selection is unchanged. Equations and
tolerances are shared.

The explicit articulation root also reaches the cloth rigid-contact and
attachment preparation kernels through their sole host launch sites. The
shared deformable helpers select that root only for these hinted callers;
other callers retain the original path. This is a compilation dependency of
the GPU module, not qualification of cloth physics.

## New-articulation tendon staging descriptors

The same opt-in flag appends two `const PxgArticulationTendon* PX_RESTRICT`
arguments to `newArticulationsLaunch`, for the new spatial and fixed tendon
staging descriptors. The sole `NEW_ARTICULATIONS` host launch in
`PxgSimulationCore::updateArticulations` supplies
`mNewSpatialTendonsBuffer.getTypedPtr()` and
`mNewFixedTendonsBuffer.getTypedPtr()`. These are the same addresses already
bound to `mNewSpatialTendonPool` and `mNewFixedTendonPool` in the update descriptor.
The original CUDA/default signature and source path remain unchanged.

Allocation evidence in `PxgSimulationCore.cpp`: each staging descriptor buffer
is separately constructed from `allocDesc.deviceAlloc`, separately allocated
when new tendon records exist, and populated with `memcpyHtoDAsync` on `mStream`.
The descriptor binding and `NEW_ARTICULATIONS` dispatch also use that stream.
Attachment/modification data, remap buffers, and persistent articulation storage
are separate allocations. The buffer members stay owned by the simulation core;
there is no other reference to these two buffer members outside that class's
implementation/header. Normal PhysX scene-update ordering must continue to
exclude reallocation or modification while this launch is in flight.

The kernel only reads these staging descriptor bytes, including the byte copies
to persistent tendon storage. Its element pointers still designate writable
outputs, and no mutual disjointness of their pointees is asserted. In particular,
`mArticulationPool` is deliberately **not** declared read-only: this launch copies
new articulation records into that persistent pool. When a tendon count is zero,
the corresponding staging argument is not dereferenced.

This is a source/host ABI and provenance hint, not an articulation numerical
qualification. Host compilation with the flag OFF and ON and actual source-first
translation-unit compilation pass (980). Scene and articulation correctness tests
remain required before claiming that feature works.

## Existing-articulation tendon updates: scheduling tradeoff

With the same hint enabled, `UPDATE_ARTICULATIONS` uses **N ordered launches for
N update records**, rather than one launch with `ceil(N / 8)` blocks. Each launch
still has the original `(32, 8, 1)` block dimensions, but one block and
`nbSimUpdates=1`. Its mapped update pointer addresses exactly one record in the
original mapped array. Absolute link, tendon, and DOF offsets inside that record
are unchanged. All launches stay on `mStream`, without added synchronization.
This extra launch overhead is a deliberate, unmeasured compatibility tradeoff
for an articulation compilation dependency; it is not a performance improvement
or a claim of articulation numerical correctness.

The host appends two explicit restricted const roots from
`mArticulationDataBuffer[updates[i].articulationIndex]`: its persistent
`spatialTendons` and `fixedTendons` buffers. These separately owned allocations
were installed in the corresponding articulation record during creation. The
kernel reads their descriptor bytes only; its nested element destinations remain
writable and unrestricted. The persistent articulation allocation is also still
writable. The two tendon-element loops select these roots under the hint, while
all shared copies, scalar updates, counts, equations, and synchronization remain
shared with the original path. No new storage is allocated for the hint.

Uniqueness evidence: `PxgBodySimManager::updateArticulation` appends only when
`eIN_DIRTY_LIST` is absent, and sets the bit before appending. Its node-to-remap
mapping identifies one persistent articulation. New insertions already carry
the bit and are excluded from this update list. The controller partitions that
list into disjoint task ranges, and each task writes exactly its
`startIndex + i` update record with the original remap index. Thus this scheduling
change serializes independent targets; it does not establish an order for
previously dependent duplicate targets. Scene update APIs retain their existing
no-concurrent-mutation requirement.

All 256 lanes still copy the shared update record and reach the existing block
barrier. Thereafter only warp zero passes `globalWarpIndex < nbSimUpdates`; its
32 lanes execute the unchanged warp-copy loops and warp barriers. A one-record
slice preserves its absolute payload offsets. The kernel never assigns either
tendon descriptor pointer or tendon descriptor fields: persistent articulation
record writes are scalar `data.flags`, `data.confiDirty`, and `data.updateDirty`;
other writes target shared scalar state or separately allocated nested arrays.
`PxgSimulationCore.cpp` allocates each persistent tendon descriptor buffer and
its attachment/modification/coefficient arrays independently, and installs the
latter addresses in the former during creation.

Before hinted update dispatch, missing mapped records or missing per-articulation
storage report an explicit internal error and set abort mode. Mapping and launch
failures are also reported, with record/articulation indices for launch failure;
no failed launch is reported as success. Successful queueing does not imply
successful completion: normal asynchronous error handling remains required.
The CUDA/default branch retains its original signature, launch grouping, and
error behavior. OFF/ON host builds and actual translation-unit compilation pass
(980). Required follow-up numerical qualification includes multiple distinct
updated articulations, tendon and zero-tendon cases, dirty-flag/direct-API
combinations, output/guard checks, and original numerical tolerances before this
path can be called working.
