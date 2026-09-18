# Stable GPU cluster motion slots

The topology runtime now allocates cluster motion slots on CUDA. This is the
first shared-state step toward GPU-owned body/contact lifecycle. It does not
remove the existing native CPU BodySim allocator or claim complete GPU residency.

## Device representation and execution

`PxDestructionScene` version 12 changes topology motion addressing. The device
view exposes `clusterSlots[root]`, `slotRoots[slot]`, `slotGenerations[slot]` and
`slotCapacity`. Resolve a chunk through `chunkCluster[chunk]`, then
`clusterSlots[root]`, then `motions[slot]`. `activeClusters` remains a compact,
stably ordered list of authored roots, not a motion index. Capacity is backed
storage; it does not imply independently active motion for every chunk.

A surviving minimum-authored-ID root retains its slot and generation. A root
that disappears retires its handle. Other roots receive ascending free slots
in ascending authored-root order; reuse increments the slot's 64-bit generation.
Handles are scoped to the owning topology instance and invalidated by release or
reconfiguration. Creation ancestry and a scene-wide asset lifetime remain future
SDK work; these handles must not be treated as global actor IDs.

Parallel classification produces free-slot and allocation-request flags. Two
exclusive scans assign distinct slots without a CPU count readback or contended
linked free list. Existing CUDA motion transfer, candidate rigid-body preparation
and accepted-motion publication now use this representation. No additional
independent simulation or packed-motion mirror is introduced. The offline demo
and diagnostic tests explicitly gather by the mapping when requesting CPU data.

The currently fixed topology capacity equals its authored chunk count, sufficient
for its existing split/removal operations. Future fragment creation and asset
streaming require growable scene pools. This change is not that complete allocator.

## Transactions and lifetimes

Candidate slot maps/generations are computed separately from accepted state.
Rejected, discarded and replaced candidates cannot consume accepted generations.
Commit copies the slot state with the topology and motion under the existing GPU
acceptance predicate. Generation exhaustion or insufficient slots sets slotError;
a transaction propagates error bit 8 and cannot commit. Event-ordered consumers
must finish before the next mutation, as with the existing topology view.

## Verification

- SDK build: `out/gpu-stable-slots-final-build.log`.
- 32 focused native/topology tests: `out/gpu-stable-slots-final-native-tests.log`.
- Additional lifecycle fixture: `out/gpu-stable-slots-lifecycle-tests2.log`.
  Covers retirement before an unchanged component, stable indices, reuse and stale
  generations, discarded candidate isolation, device-only handle resolution, and
  generation-overflow rejection preserving accepted bonds and slot state.
- Existing 100,000-chunk / 200,000-bond transaction, mass/inertia, point-velocity
  continuity and repeated-impact parity checks retain their physical assertions.

This is not full qualification of the original plan. The separate native
allocation sanitizer failure remains open. Native body-slot registration,
contact lifecycle, sleep/correction integration and GPU rendering are next.

The standalone topology memory check reports zero errors in
`out/gpu-stable-slots-final-memcheck.log`. A 64-building, 28,416-chunk / 57,344-bond
audited native bombardment completed 600 steps with all stress solves converged,
zero recorded motion error and zero contact-boundary audit failures:
`out/recordings/native-stable-slots-final-20260906`. This is a correctness capture
on a shared GPU, not a performance qualification.
