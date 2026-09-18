# Native GPU persistent collision binding preparation

The scene's native fracture task now prepares the persistent collision binding
batch after GPU topology evaluation and native cluster body initialization. The
GPU identifies affected source clusters, includes all their bound chunk shapes,
resolves each new motion owner and validates those bindings against PhysX's
resident shape table. No chunk/shape ownership array is read back to the CPU.

This is preparation for the correction transaction. It does not yet apply the
batch, transfer query membership, restore retained bodies, rewind ordinary
participants or run the internal resimulation. Ownership-changing native steps
still report incomplete error 8 and leave accepted destruction material/topology
and persistent shape ownership unchanged. Ordinary trial motion is still not
rewound. Full native split acceptance remains unfinished.

## Work set and persistent storage

The existing GPU topology comparison also marks source clusters whose component
ownership or active chunk membership changes. This is the bond graph's actual
material verdict, not predicted breakage. Only geometry belonging to those source
clusters enters the compact binding batch; unchanged structures are excluded.
Shapes retaining their original owner remain in the affected batch because that
owner's mass/COM and contact constraints can change. Destroyed chunks generate
explicit collision removals.

Candidate cluster roots are mapped to the native body indices allocated by the
scene. The output is stable authored chunk order, compacted on GPU with CUB.
Each 16-byte binding contains chunk ID, persistent shape/contact index, old body
index and candidate body index. A target of `PX_INVALID_U32` means removal.
Geometry, local shape transforms, native shape records, contact identities and
query/actor membership remain intact during preparation. No duplicate geometry
or per-chunk solved motion is allocated by this stage.

Storage is provisioned from the configured chunk/cluster counts and cannot
silently truncate the batch. Current scratch and raw/compact buffers reserve
space for every configured chunk; scene-wide growth/retry remains separate work.
The CPU receives only a 32-byte preparation status and ordinary stage status.

## Validation and ordering

GPU checks cover shape index bounds, current rigid ownership, available candidate
root/body mappings, supported collision geometry and simulation flags. A bad
entry rejects the entire batch. Diagnostic buffers may contain the other valid
entries, but they must not be consumed unless `valid` is nonzero. This stage does
not establish validity for aggregate caches, query compounds, full geometry
lifecycle handles or a later ownership mutation; those transaction gates remain
required before applying edits.

The scene simulation stream waits for candidate construction/body initialization.
It performs validation and stable compaction, then publishes counts and the
result through the destruction view's ready event. A nonfracturing step clears
the preparation status so it cannot expose a previous batch as current.

`PxDestructionScene` version 8 adds `trialCollisionBindings` and
`collisionPreparation`. Preparation errors add stage bit 1024. Detail bits are:

- 1: shape index unavailable/out of range.
- 2: persistent shape no longer belongs to the expected ordinary rigid body.
- 4: candidate component or body mapping invalid.
- 8: unsupported geometry, flags or unavailable native geometry registration.
- 16: CUDA submission/completion failure.

The shape identity lookup `PxDirectGPUAPI::getShapeContactIndex` now works in
initialized Direct GPU scenes even when CPU motion observation is disabled.
It still rejects calls during simulation and nonexclusive/detached/foreign
shapes. Looking up an identity does not read physical state back from the GPU.
Indices can still be recycled; complete generation-bearing lifecycle handles
remain part of the unfinished scene API.

## Qualification scope

`physx_native_gpu_collision_preparation` exercises the native task through
ordinary `simulate/fetchResults`, including:

- Four affected chunk shapes among 64 unchanged structures, with sleeping enabled
  and disabled. Retained shapes are included; quiet structures are excluded.
- A 257-shape split with 256 new native cluster slots, stable ordering and retry
  identity, without truncated bindings.
- Rejection of out-of-range shapes and wrong native source ownership, preserving
  accepted damage and actual GPU shape records, followed by valid recovery.
- Complete collision removal for an actual GPU crushing verdict.
- Clearing stale preparation on a later nonfracturing step.

Reproduce:

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4
ctest --test-dir out/destruction-sdk --output-on-failure
/usr/local/cuda/bin/compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/destruction-sdk/reference/native_gpu_collision_test
```

These correctness checks do not establish complete native collision mutation,
internal resimulation or large-scene 60 Hz performance.

Qualification on the RTX 4090: the independent SDK build and four installed
CPU/GPU consumers pass. The full native suite passes 48/53 tests, with the same
five known failures as the preceding milestone. Memory checks of native
collision preparation, body allocation and material evaluation report zero
errors. Exact commands, source hashes and limitations are recorded in
[the qualification record](qualification/native-gpu-collision-preparation-20260906.json).
