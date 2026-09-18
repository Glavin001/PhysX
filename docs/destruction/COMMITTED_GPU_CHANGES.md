# Committed GPU topology publication (API v15)

`PxDestructionDeviceView::committedChanges` exposes an event-ordered CUDA view of
accepted membership changes and newly broken bond indices. It requires rebuilding
all consumers of `PxDestructionDeviceView` against the matching v15 CPU/GPU SDK.
Direct GPU API mode is not required; ordinary sleeping actors and scene queries
remain supported.

After successful `PxScene::fetchResults`, obtain `getDeviceView()`. Its `readyEvent`
orders the change status and rows. Device consumers wait on that event and provide
their completion event through `setConsumerEvent` before the next simulation.
CPU gameplay consumers may explicitly read the small status and its counted rows.
The buffers belong to the scene; clear/reconfiguration invalidates them.

The first accepted frame publishes every chunk and any initially inactive bonds.
Subsequent frames publish only changes, sorted by immutable chunk/bond index.
Every chunk in an affected source cluster appears, including retained members:
keeping the same root does not imply unchanged membership or center of mass.
Rows carry current root, slot and generation. Inactive rows use invalid root/slot.
An explicit full `acceptedTopology` observation is needed if a consumer misses
change frames. Failed steps are never accepted observations.

The existing GPU collision producer already identifies affected source clusters.
Before each accepted topology commit, publication marks those source members and
actual newly inactive bonds. Flags union both fracture evaluations. A conditional
CUDA graph compacts the final flags and resolves final handles once the accepted
frame is ready. Quiet frames publish an empty status and bypass compaction. No CPU
fracture decision, shape lookup or full topology reconstruction enters this stage.
Capacity is bounded by configured immutable chunk/bond counts; allocation failure
or an unsupported selection size fails explicitly. There is no truncated output.

The Vibe-land integration consumes only changed groups, preserves unaffected group
records, and emits the established body/migration/bond wire events. It no longer
reads full membership, slot, generation and health arrays on every fracture tick.
Its stress-island and broken-bond counters also use committed publication instead
of repeated whole-world observations. Ordinary pose/sleep snapshots and CPU actor
compatibility creation are still separate work; this does not claim that the
entire engine lifecycle has moved to CUDA.

Tests cover first/quiet/rejected frames, cycle cuts, two-commit unions, retained
identities, reinitialization and explicit capacity rejection. CUDA memcheck passes.
A separate 256-building audit compares every tick's CPU consumption against full
accepted GPU membership, generations and bond health, outside performance timing.
The frozen penetration signature and eight ordinary sleep/query/reuse tests pass.
See [qualification](../../qualification/vibe-committed-changes-20260908/README.md).
