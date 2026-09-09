# Persistent contact ownership: implementation boundary

Status: reviewed, **not implemented**. This records the dependency trace for
C1–C6 so the next implementation does not repeat the same discovery or retain
contacts with stale owners. It does not replace the full optimization plan.

## Existing ownership and invalidation

- `ScShapeSimBase.cpp::rebindRigidOwner` already keeps ShapeSim, geometry
  registration, transform-cache IDs and native GPU shape storage. Its
  `NPhaseCore::onVolumeRemoved` call still destroys all old interactions/managers.
- `ScInteraction.h` stores actor references, actor interaction-array indices and
  scene registration. Retention needs mutable owner references plus consistent
  removal/insertion in actor interaction arrays. `ElementSim::rebindActor`
  currently requires the old actor to have no interactions for that element.
- `ScShapeInteraction.cpp::createManager` initializes body/core pointers,
  dynamic/kinematic/response/report flags, dominance, offset slop and the island
  edge. These are motion-dependent; retaining geometry cannot retain them blindly.
- `ScNPhaseCore.cpp::lostTouchReports` handles ActorPair/report ownership and wakes
  the other body on a lost touching/unknown pair. Native non-report pairs often
  have no ActorPair, but reporting/filter callbacks and wake semantics still need
  explicit handling. Shape ordering and kinematic transitions affect filtering.
- `PxsSimpleIslandManager.cpp` has add/remove edge operations, not a verified
  endpoint-rebind transaction. Removal is deferred. A fresh edge needs correct
  speculative/accurate connectivity and retirement of the old partition rows.
- `PxgConstraintPartition.cpp` stores node endpoints and manager indices on
  partition edges; output patch counts and active-edge transitions affect row
  creation. Updating only `PxcNpWorkUnit::mEdgeIndex` leaves stale GPU rows.
- `PxgContactManager.h::PxgContactManagerInput` holds shape and transform-cache
  references, not rigid motion ownership. `PxgContactGraphIdentity` separately
  holds edge index and GPU lifetime generation. Compaction preserves identities.
- `PxgNarrowphaseCore.cpp::refreshContactManagerInternal` removes/re-registers a
  GPU slot; it is not an in-place ownership update. `removeLostPairs` compacts
  both host and device manager arrays. New transaction ordering must account for
  compaction and cancellation/removal, including two endpoints migrating.
- `resetDestructionContactCaches` keeps pair storage but resets all PCM manifolds
  during eligible correction. `PxgSimulationController.cpp` also resets friction
  caches. These resets do not repair owner references or island edges.

## Required transaction, not optional bookkeeping

1. Establish a complete eligibility/invalidation contract for geometric reuse:
   transforms, response/filter state, ordinary/non-rigid participants, reporting,
   supported constraints and ownership generations. If validity is unproved,
   perform the required full collision reconstruction; never omit the pair.
2. Update GPU motion references and contact identity/edge mappings under stream
   dependencies. Invalidate incompatible solver rows, impulses and friction state;
   preserve only geometric data whose validity is established.
3. Preserve or rebuild the contact/constraint dependency graph with new eligible
   fragment pairs and ordinary participants. Stress components are not this graph.
4. Keep CPU compatibility links, counted interactions and query/report owners
   consistent. C1/C2 must ultimately make these accepted publications rather than
   prerequisites for corrected GPU physics. Retaining a manager alone does not
   complete that migration.
5. Verify repeated endpoint changes, removed/recycled slots, compaction, supported
   → dynamic transitions, wake propagation, normal/friction loads, callbacks,
   correction, accepted-only events and ordinary current-tick queries before
   benchmarking the large scene. Do not use one successful GPU-only fixture as
   proof of normal API compatibility.

Current `reserveBodySlots` in `PxgDestructionRuntime.cu` chooses slots on GPU from
CPU-granted indices, then reads compact requests and calls allocator `prepare`.
`NpDestructionBodyAllocator.h` creates BodySim/island metadata on the CPU before
correction. No final GPU allocator/lifecycle completion is claimed.

The standalone L2 chunk lookup experiment was tested and reverted; see
[its evidence](../../qualification/native-chunk-index-20260909/README.md).
It does not address these ownership dependencies. Continue C1–C6 and active
stress work rather than repeating that small table optimization.
