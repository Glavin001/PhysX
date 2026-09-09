# Review of the unapplied static registration integration

Production source remains on the a6a0562a implementation. Commit 4abf4d8d
contains the isolated prototype and receipts, not an applied runtime change.
No live build/test process was found on this continuation; prior tests completed.
The explicit integration-approval request is still pending.

## Findings

- **Fixed in the review patch:** check the two `maximum-per-body * active-bodies`
  products in 64 bits before passing 32-bit element counts to PGS/TGS allocation
  and batching. Overflow explicitly rejects the step rather than wrapping a
  buffer size. This guard is proposed, not compiled or runtime-qualified.
- **Ordering source confirmed:** ordinary static rigid removals use the stable
  `PxArray::remove` shift, and adds append. The isolated oracle uses those list
  semantics independently of the GPU sort algorithm.
- **Task boundary confirmed by inspection:** special-contact additions are
  collected in the serialized `dopart1` branch of
  `updateIncrementalIslands_Part2_2`. Parallel removal preprocessing records
  special edges for subsequent serialized removal because the existing manager
  is not thread-safe. The patch must keep that producer contract; arbitrary
  concurrent appends to its command array would not be safe.
- **Consumer dependency confirmed by inspection:** `mPrepTask` retains its final
  reference until the end of `updatePostPartitioning`; the proposed registration
  update precedes that release and the allocations that consume its counts.
  Actual integrated execution still needs testing, including abort cleanup.
- **Adoption API confirmed:** `PxArray::reset()` exists and releases the old
  per-body storage. Articulation membership is identified by the existing
  `mNodeToRemapMap`. Mixed-scene adoption and node reuse remain integration gates.

## What this review does not prove

It does not validate the new private ABI, physical trajectories, sleeping,
contact ownership, actor publication, performance, or the device-fault adapter.
The registered geometry/contact-manager lifetime replacement is still separate
unfinished work. Global range rebuilding and a host capacity receipt remain in
this proposal; these costs require explicit measurement and later replacement.

No GPU tests were repeated: this review changes only qualification artifacts,
not the already-tested standalone kernels or executable. The generated patch
passes `git apply --check` and remains unapplied. No deployment/service changes.
