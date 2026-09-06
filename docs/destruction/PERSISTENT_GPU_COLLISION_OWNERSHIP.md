# Persistent collision ownership inside PhysX

This document records the original transfer boundary. Native GPU allocation,
body initialization and [collision binding preparation](NATIVE_GPU_COLLISION_PREPARATION.md)
now precede it; application inside the correction transaction remains unfinished.

PhysX now has an internal operation that transfers an exclusive shape between
existing rigid bodies without destroying its `ShapeSim`, cooked geometry
registration, transform/contact index or shape reference. GPU broadphase,
narrowphase, shape motion bindings and CPU actor/query membership follow the new
owner. This removes a required obstacle to first-class chunk splitting.

This is an intermediate implementation. The native material task does **not**
yet call this boundary, allocate the new rigid bodies, or rewind/resimulate the
interaction. Membership-changing native verdicts still return error bit 8. The
new tests exercise actual PhysX GPU collisions through the internal ownership
boundary, not a completed native destruction simulation.

## Ownership transaction

`NpShapeManager::rebindShape` is private SDK implementation, not a new public
simulation API. Its current inputs are existing actors and an explicit local
shape pose. It runs between scene advances, while API writes are allowed. It
performs no fracture prediction, mass fitting or stress calculation.

The operation:

1. Validates the actors, shape and supported scene configuration before changing
   ownership, and prepares the target CPU membership slot.
2. Requests broadphase overlap refresh under the target's collision group while
   retaining the existing bounds/transform index.
3. Releases incompatible contact interactions and their constraint/cache state.
4. Rebinds narrowphase instance-to-body and instance-to-actor maps, retaining the
   registered geometry. The existing reverse rigid-to-shape indexing is rebuilt
   by the normal GPU pipeline.
5. Transfers the persistent simulation element between actor membership tables,
   changes its local pose, and queues its GPU shape motion binding.
6. Updates the CPU shape owner and scene-query membership without public
   detach/attach or actor-reference changes.

Repeated updates to the same shape before an upload are deduplicated. Each GPU
shape slot receives one final write, avoiding concurrent writes from duplicate
queued entries. Removal can follow a queued transfer and release geometry before
upload: a removed entry now writes an inactive record without dereferencing the
released shape core.

Current supported configurations use GPU rigid dynamics and GPU broadphase,
exclusive box/sphere/capsule or GPU-compatible convex shapes, and existing
`PxRigidDynamic` actors (including a kinematic source/target). Shared shapes,
triggers, aggregates, pruning structures and query compounds are rejected by the
internal operation. In particular, a scene with any active aggregate is rejected:
its persistent aggregate-pair cache requires a separate invalidation path. A
rejected configuration retains actor/shape membership. These restrictions are
remaining implementation work, not filtering away physical interactions.

## Detecting contacts when geometry has not moved

The GPU sweep-and-prune broadphase normally discovers new overlaps from endpoint
movement or newly inserted volumes. Changing the motion owner alone can make two
already-overlapping chunks eligible to collide, without moving an endpoint.

A persistent refresh mask now marks those existing endpoints for the same
spatial overlap discovery used by insertion. Existing sorted endpoints and
bounds storage are reused; no new element IDs are allocated. Incremental
found/lost reporting skips refreshed volumes because their former interactions
have already been invalidated, avoiding duplicate reports. New overlaps are
filtered with current body ownership. Refresh flags clear after that pass.

Explicit `resetFiltering` also uses this path where supported. CPU broadphase
and aggregate scenes retain their existing reset implementation. No fracture
policy or ordinary collision settings were changed.

The refresh work remains GPU collision work, with CPU submission of its mask at
this intermediate boundary. Changed shapes still trigger ordinary PhysX index
maintenance. Further work must feed GPU topology transactions into these
bindings, batch the remaining CPU compatibility updates, and qualify scheduling
and memory growth at large scene sizes.

## Overflow and failure publication

A refresh cannot accept a partial set of newly eligible overlaps. Broadphase
found/lost capacity exhaustion during refresh now aborts that step explicitly.
It reports the required pair capacity and enters the existing CUDA abort state;
this version requires scene/context recovery rather than growing and retrying
in place. Automatic growth/retry remains unfinished.

Testing also exposed a pre-existing result-fetching issue: a CUDA abort could
return from `fetchResults` before setting `errorState`, and split fetching could
report success without valid contact output. GPU failures now return false with
the hardware error code; split fetching returns false with empty contact output.
A repeated fetch of the failed scene retains an explicit error. Ordinary
successful scene advancement is unchanged.

## Verification

The ownership fixture uses actual GPU contact-stream observations and explicit
GPU motion observations. Ordinary CPU callbacks and stale actor getters are not
used as evidence of Direct GPU solver behavior. Committed motion is published to
the CPU query mirror through the existing observation API.

Coverage includes:

- Two overlapping chunks initially share one kinematic owner and produce no
  self-contact. Transferring one shape produces a contact pair immediately,
  with the same contact IDs, the new actor/node identity and actual dynamic
  depenetration. The prescribed source stays fixed.
- Rotated assets and an offset/rotated body COM exercise shape-to-actor and
  body-to-actor transforms; queries identify the new owner after observation.
- Returning the shape invalidates the former inter-body contact. Repeated
  transfers before a single upload use the final owner, preserving reference
  counts and IDs.
- Repeated filtering refresh, aggregate-configuration rejection and removal of
  all user/actor shape references before upload exercise storage lifetime.
- A scene with capacity for four found pairs requires 36 after splitting two
  overlapping groups. Both normal and split result fetching report failure,
  expose no accepted trial output, and retain the failure on retry.

The full native suite passes **44/49 tests**, with the same five known failures
unchanged. All three new ownership/overflow tests pass. Compute Sanitizer reports
zero errors for the normal, overflow and split-overflow cases. Installed full SDK
and native-only consumers pass on CPU and GPU.

Exact build, regression, sanitizer and installed-consumer results are recorded in
`qualification/persistent-gpu-collision-ownership-20260905.json`. These are shared
GPU correctness checks. They do not establish 100k-chunk collision throughput or
60 Hz performance.

## Next integration work

Native destruction must allocate solver bodies for GPU candidate clusters and
supply their full mass/COM/inertia and inherited motion, then invoke ownership
changes at an internal task barrier. GPU topology remains authoritative; CPU
objects represent compatible bookkeeping and committed observations.

The scene transaction must then checkpoint and restore every affected ordinary
body/joint, rebuild eligible contacts, and run the configured **one physics
resimulation** before publishing accepted state. GPU batch ownership updates,
aggregate support, lifecycle handles, crushing geometry/energy, selective
correction and large-scene qualification remain open. This boundary alone does
not satisfy the full destruction-engine objective.
