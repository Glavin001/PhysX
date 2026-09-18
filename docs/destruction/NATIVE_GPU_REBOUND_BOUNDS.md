# GPU-authoritative bounds for persistent ownership transfers

Persistent shape ownership transfer now refreshes collision transforms and bounds
from the target's actual GPU body state before collision detection. The previous
path called the CPU bounds updater after rebinding. In a Direct GPU scene, CPU
poses can be stale or contain allocation placeholders for private destruction
clusters. Copying those bounds back to the GPU could miss the newly eligible
fragment contact despite correct GPU motion.

A real GPU collision reproducer moved both actors from their original CPU
location to a distant translated/rotated pose using Direct GPU writes only. The
old transfer missed their overlap on the first step. The corrected path finds
the contact, reports the persistent shape IDs and new actor/body ownership,
and solves the separated body's motion. No host pose publication is required
for collision detection.

## Implementation and ordering

The shape manager keeps a persistent pinned queue of affected shape IDs. Repeated
requests collapse to one final owner; removal cancels pending work. Compaction
also removes duplicate IDs after cancellation/requeue or reuse. Capacity grows
rather than truncating requests. Queue allocation failure after refiltering
marks the scene incomplete instead of accepting mismatched collision ownership.

The normal simulation pipeline uploads final shape metadata first. After
narrowphase geometry/index updates and bounds/transform-buffer growth, the
narrowphase stream waits for that upload and launches the bounds refresh. The
kernel reads GPU body-to-world, body-to-actor and persistent shape-to-actor
transforms, then uses PhysX's existing geometry-specific bounds formulas. It
writes only collision transforms and bounds, never rigid motion. The existing
ownership-refilter map already marks these IDs for broadphase rediscovery.
Downstream articulation, broadphase and narrowphase ordering includes the new
work. An empty queue submits no extra kernel or event.

Pinned queue storage survives asynchronous DMA until scene completion. The
device ID buffer persists and grows geometrically. Current GPU pointers are
passed directly to the kernel, avoiding modification of the cached Direct GPU
API descriptor during collision-buffer reallocation. CUDA submission/allocation
failure uses the existing explicit incomplete-step/abort path.

An ordinary newly added body whose first upload is pending still uses its
initial CPU pose. A later transfer to such a body cancels an earlier queued GPU
refresh. Native private cluster slots initialized in GPU storage have already
cleared the first-upload flag, so their authoritative GPU state selects the new
path. Explicit pending host pose commands take precedence over an existing
body's GPU pose until uploaded. Commands issued after a transfer cancel its
pending refresh in the dirty-shape pass. That pass now stages bounds for those
explicit commands through the sparse Direct GPU change tracker; its ordinary
worker previously bypassed tracking. Pending bounds changes are merged even
without a shape-instance change. CPU and non-Direct GPU scenes retain their
existing update behavior.

## Verification

The GPU-only pose fixture covers boxes, spheres, capsules and scaled cooked
convex meshes, each with unrotated and rotated/offset-COM configurations. Two
additional cases transfer again to a fresh, unuploaded target. It checks first
step contact, correct solver ownership, dynamic response, persistent identities,
reference counts, merge filtering, and CPU queries after explicit observation.

Four host-command cases exercise pose changes before and after a transfer,
including rotated/offset COMs. Each also issues a subsequent command without
changing ownership. Contact points must be at the commanded location and the
first-step collision response must move the separated body correctly. The
initial compatibility probe failed before command-aware staging was added;
its result is retained in `out/native-rebound-host-pose-before.log`.

A second fixture grows the refresh batch from one to 257 shapes, repeats each
transfer several times, and adds 1,100 ordinary shapes during the same step to
force collision storage growth. All 257 contact pairs retain the right shape
and body identities. It then removes all queued transfer geometry before upload
and advances successfully. Host motion publication is disabled in that fixture.

The independent SDK build and native regression suite currently pass 53/58
checks, with the same five known failures. All six ownership checks pass,
including the three new bounds cases, and all four installed CPU/GPU consumers
pass. Collision memory checks pass. A repeated native correction-body memory
check has exposed CUDA address failures in the stress path. The independently
rebuilt prior revision `24452e67` reproduces an address failure in the same stress
path under the same memory checker. The current stress runtime binary also
matches the SHA-256 recorded by the previous qualification; the independently
rebuilt copy has its own recorded hash. The standalone rigid-checkpoint memory check passes. Root cause
of the stress failure remains unresolved; full native qualification is incomplete.
Results, source/library hashes and the failed baseline comparison are recorded in
`qualification/native-gpu-rebound-bounds-20260906.json`.

The clean baseline build also exposed a build-script dependency on an old
`PX_OUTPUT_ARCH=x86` cache value. The SDK build entrypoint now supplies it
explicitly, preserving the required `_64` library names. No physics settings
change with this build correction. The pre-fix failure is
retained in `out/native-rebound-bounds-before.log`. Existing assertions and
physical tolerances are unchanged.

## Remaining integration

This fixes the existing internal ownership boundary. Native material-driven
splits still stop explicitly before acceptance. Applying GPU-produced ownership
batches inside the complete correction transaction, restoring island/contact/
constraint state, command assignment, one internal resimulation, and committed
publication remain unfinished. The current queue is submitted from CPU ownership
bookkeeping; it is not the final device-produced topology transaction. Native
private-body transfer/acceptance is not exercised by these collision fixtures.

These are correctness checks, not a 100k-chunk throughput or 60 Hz result.
