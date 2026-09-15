# Accepted destruction state export and restore

## Clarified contract: physical-state save/load

The user's latest clarification supersedes the execution-history requirements
in the historical V19 status below. Save physical state at an accepted tick
boundary and rebuild a valid world without advancing physical time. Exact
continuation of the uninterrupted engine's contact scheduling, pool allocation
or numerical caches is not the feature requirement.

Required persistent state includes rigid body poses, velocities, mass/inertia,
shape geometry and ownership, material/settings, supports, surviving bonds,
bond health and accumulated chunk damage. In the current material law, loads
above elastic limits cause gradual health loss; a combined fatal damage
multiplier breaks the bond immediately. Convergence is a solve result, not
material health. Warm solution guesses, factorizations, settled-input
certificates, temporary buffers and allocator history are rebuildable. Reset
certificates explicitly; the next solve must meet the existing equilibrium
quality in the current tick. Contact/friction cache reconstruction can change
finite-iteration results; validate resting stability and impact quality rather
than assuming those changes are harmless.

Acceptance requires exact physical-state roundtrip before simulation, then
physical quality, convergence, at most one correction and exactly-once stimulus
checks. For repeatability and candidate comparisons, independently restore the
same snapshot with the same cache initialization and stimulus. Uninterrupted
versus restored trajectory differences remain useful diagnostics, not a demand
to serialize arbitrary execution history. Keep continuous trajectory tests for
warm simulation quality and performance. Report restore/setup costs separately
and account for candidate-specific preparation; cold restored ticks are not
interchangeable with warm game ticks.

**Implemented as private runtime V20 / schema7, public API16.** All 28 physical
save/load cases pass, each with two independent restores and ten complete ticks.
See [per-scenario results](../../qualification/optimization-next20-20260910/snapshot-v20-results.md).
GPU memory checking and the surrounding native regression checks are recorded in
[the qualification report](../../qualification/optimization-next20-20260910/snapshot-export-restore.md).
This is physical reconstruction, not exact uninterrupted execution replay.

### Reconstruction bookkeeping

The logical input is `(asset definitions, accepted physical state, next stimulus,
simulation settings)`. Reconstruction has a defined fresh-cache policy. This
defines a reproducible experiment input; it does not promise bitwise GPU
determinism or equality to an uninterrupted finite-iteration solve.

| Record | Required contents |
|---|---|
| Assets | Geometry, authored chunk/bond definitions, material laws and per-chunk mass properties; immutable assets may be referenced by version/hash rather than copied into every snapshot. |
| Bodies and shapes | Stable identities, poses, linear/angular velocities, mass, inertia, COM frame, body flags, sleep/wake state and body parameters; shape local poses, geometry/material references and collision filters. Include the relevant environment and projectiles. |
| Destruction state | Surviving bonds and remaining health, accumulated chunk damage, supports, and current chunk-to-rigid-owner membership. Preserve externally visible identities; allocate new internal GPU slots and rebuild connectivity/derived mass data with consistency checks. |
| Tick inputs | Fixed timestep, gravity, simulation/quality settings, and the next force/impulse/kinematic command batch keyed by stable identity. Export at an accepted boundary before that batch; apply it exactly once after import. |
| Binding/version information | Format and asset versions plus ID references joining chunks, shapes, owners and commands. Runtime pointers, GPU indices, free lists and capacity history are not persistent identities. |

Export must observe completed accepted GPU writes. Read physical values from
their authoritative owner; a stale CPU mirror is not a valid serialization
source. Import recreates objects, resolves IDs, uploads physical state and builds
derived structures without a simulation tick. No solver convergence certificate
survives reconstruction merely because the source previously converged.

PhysX binary collection serialization is an object format, not a minimal
pose/velocity schema: its default serializer writes object data plus extra data,
and mesh extra data can contain cooked acceleration structures. However,
deserialization resets the actor's simulation link (`Sc::ActorCore::mSim`) and
scene membership (`NpBase::mScene`); it is not a checkpoint of the live scene's
contact/solver execution. Reuse this supported object reconstruction mechanism;
do not add live contact allocation history to the destruction section.

`PxDestructionScene::exportState` and `importState` supply the destruction section
missing from ordinary PhysX collections. They are synchronous setup/observation
APIs outside `simulate`/`fetchResults`; rebuild V20 consumers together.

The destruction section stores geometry/materials/settings, accepted bond health
and chunk damage, active connectivity, current chunk/shape/rigid ownership,
accepted motion, logical tick and topology handles. A physical body supplement
reads accepted pose, velocity, COM and mass/inertia from the GPU where necessary.
Logical wake state comes from the ordinary actor API, including a wake caused by
a subsequently cleared force. Kinematic backup mass and motion parameters remain
available when a later fracture produces dynamic pieces.

No stress guesses, response history, convergence certificates, inverse caches,
friction patches, cached world-space shape transforms, CPU sleep filters or
native allocation/scheduling history are serialized. Import recreates ordinary
host bodies and lets normal PhysX insertion/upload construct their GPU state.
Collision/query transforms and stress structures are rebuilt without advancing
physical time. The next tick performs current contact → stress/fracture → at most
one correction → second stress → accepted publication.

Use the existing PhysX binary collection APIs for bodies, shapes, materials and
other supported rigid objects. Scene configuration, callbacks and future game
commands remain application-owned, as with ordinary PhysX collection loading.
Pair the two sections from the **same export**. The destruction format is a
versioned, checksummed native-build format; it is not a cross-version interchange
format or an untrusted PhysX binary loader.

## Export

1. Finish a successful `fetchResults` and join consumers. A newly configured
   pristine destruction state can also be exported before its first stress tick.
2. Export **before** submitting the next force/impulse or kinematic command batch.
   Unconsumed native force accumulators/kinematic targets reject export instead
   of being silently lost. Unconsumed pose/velocity/mass setters also reject export; submit them as the next stimulus after restore.
3. Create a collection using `PxCollectionExt::createCollection(scene)` and call
   `PxSerialization::complete`. The collection now includes accepted private
   fragment owners, discovered through their exclusive published shapes.
4. Assign unique nonzero `PxSerialObjectId`s to every authored destructible shape
   and current owner (assigning IDs to all collection objects is convenient).
   Authored chunk order remains stable inside the destruction section.
5. Call `scene.getDestructionScene()->exportState(destructionStream, collection)`.
   Check its boolean result. Then use `serializeCollectionToBinary` on that same
   collection. Store both sections and the application's scene/command manifest.

## Restore

1. Create a fresh GPU scene with the same settings (ordinary actor API, sleeping,
   gravity, solver/filter configuration, capacities, fixed timestep).
2. Allocate PhysX binary backing storage with `PX_SERIAL_FILE_ALIGN` alignment;
   call `createCollectionFromBinary`, then `scene.addCollection`.
3. Call `scene.getDestructionScene()->importState(destructionInput, collection)`.
   Check its result **before publishing the replacement world**. Shape and body
   IDs are resolved against this scene and remapped to its native GPU indices.
4. Submit the frozen next command batch exactly once and execute the next normal
   `simulate`/`fetchResults`. Import performs no warmup physics tick.
5. Retain binary backing storage for the lifetime required by PhysX serialization.
   Release the scene, imported objects/collection and backing storage in the
   usual PhysX order. Imported actors have ordinary collection ownership;
   fragments subsequently created by destruction remain scene-owned.

Import requires an unconfigured destruction stage. It rejects corrupt/truncated
sections, unsupported versions/flags, missing/duplicate/wrong-scene bindings,
invalid connectivity/handles/material state, and attempts to overwrite a live
stage. Configure validates the active graph instead of pretending broken bonds
are intact. Build a replacement scene transactionally; on failure discard it.
The source world is never modified by export or a failed destination import.

## Scope and benchmark use

This supports the current native rigid destruction contract with full chunk mass
properties and persistent exclusive shapes. Chunk removal/crush-geometry creation
is not supported by current corrected rigid simulation and is explicitly rejected
by snapshots; it is never resurrected. Pending commands are separate stimulus,
not hidden snapshot contents. Existing restrictions on joints/articulations/CCD
and loaded fractured sources remain the engine's existing restrictions.

Both benchmark arms must reconstruct the same physical snapshot with the same
next stimulus and quality settings. The rebuilt-cache first tick and later warm
ticks are different timing scopes: report both honestly. Keep continuous
trajectories to validate warm gameplay performance. This feature does not by
itself migrate or qualify the earlier 24-case performance suite.

The native regression covers flying/sliding/resting bodies, intact/partially
weakened/fractured structures, impact onset, explicit post-restore commands, nine
cold/warm geometries, and a heavily fragmented 444-chunk building. It checks
exact physical destruction re-export before stepping, mass/inertia/COM,
sleep/wake state, every authored shape, damage monotonicity, convergence and
correction caps. Two independent restores must match the existing motion bounds;
free-fall acceleration and exactly-once impulse checks are independent oracles.
Ten continuation ticks are correctness checks, not ten independent benchmarks.
Historical V19 source-versus-restore failures remain unchanged in their reports.

## Build and verify

```bash
.toolchains/build-env/bin/cmake --build out/sdk-release \
  --target PhysX PhysXGpu PhysXDestructionGpuRuntime -j6
.toolchains/build-env/bin/cmake -S destruction -B out/destruction-sdk
.toolchains/build-env/bin/cmake --build out/destruction-sdk \
  --target native_destruction_consumers -j6
.toolchains/build-env/bin/ctest --test-dir out/destruction-sdk \
  -R '^physx_native_destruction_snapshot$' --output-on-failure
```

For immutable raw outputs and GPU/module provenance, use the existing wrapper:

```bash
python3 tools/diagnostics/destruction-snapshot/run-probe.py out/NEW-snapshot-run \
  --binary out/destruction-sdk/reference/native_destruction_snapshot_test \
  --artifacts physx/bin/linux.x86_64/release --require-complete-shapes \
  --allow-existing-graphics --allow-compute-pid 435374
```

The PID allowance describes the recorded shared VM; verify current identities
rather than copying it to a different environment. Optional `--sanitizer memcheck`
(or `initcheck`) and `--watchdog-seconds 600` preserve the same provenance checks.
See the dated [qualification record](../../qualification/optimization-next20-20260910/snapshot-export-restore.md)
for actual passes, failures and remaining qualification limits.

For independent single-tick file replay (no capture history), use the
[replay command](../../tools/diagnostics/destruction-snapshot/README.md). It loads
the paired saved files in a new process and reconstructs once per sample. The
helper's scene configuration matches its fixtures; applications retain ownership
of their own scene settings and command manifests.

## Large native city replay

The saved-state catalog now includes the original native bombardment geometry
at 11,100, 28,416 and 113,664 chunks, sampled through eight phases at each scale.
See the [large scenario report](../../qualification/optimization-next20-20260910/snapshot-large-20260911/README.md)
for current qualification; small-case success alone does not qualify this scale.
The benchmark saves application scene policy in a hashed `.scene` sidecar alongside
the PhysX and destruction streams. It uses ordinary GPU/TGS, sleeping enabled,
fixed 1/60 timestep and the original material/convergence/correction settings.

Fresh scenes exposed a command-history capacity bug: a corrected checkpoint can
contain new fragment body IDs beyond the original epoch's stamp storage. Runtime
preparation now extends the storage, preserving old command stamps and zeroing
only the new suffix. This is reconstructed bookkeeping, not additional saved
execution history. Loaded-source and invalid-history rejection still apply.

File replay retains all independent samples when a comparison fails, then returns
a failing exit code and `passed:false`. This allows measuring variance without
relaxing the exact bond-health/topology gate or hiding failed comparisons. A
missing motion comparison is marked explicitly; its numeric sentinel is -1.

## Reusing snapshot backing storage

Repeated benchmark replay loads the saved files once and reuses an aligned PhysX
object buffer plus bounded pinned allocation capacity through the existing CUDA
context allocator callback. Each sample still reconstructs fresh scene/object
bindings and imports the same physical state. This is not an in-place live-scene
rollback: removing and reinserting existing actors was rejected after physical
property differences and deferred work increased the measured tick.

Destruction import retains one decoded physical payload per calling thread when
the payload is at most64 MiB. A hit requires exact input bytes and valid format
metadata. The decoded representation has no GPU/runtime pointers, contact history,
solver guesses or certificates. Runtime bindings and configuration checks run
again on an independent copy. Entry replacement is transactional. The pinned pool
retains at most8 GiB of unused capacity, matches size/flags, synchronizes before
recycling a lease, and drains before its context is destroyed. These are memory
tradeoffs for replay speed; no state is added to the serialized schema.

Active cluster motion is gathered/scattered in bulk through existing GPU scratch,
so import/export no longer makes one synchronous transfer per cluster. Unused
capacity is not transferred. API16/privateV20/schema7 and quality tolerances stay
unchanged. See the [52-case reset qualification](../../qualification/optimization-next20-20260910/snapshot-reset-20260911/README.md)
and [exact build and replay commands](../../OPTIMIZATION.md). Full-step timing
continues to exclude restore, validation and teardown, each reported separately.
