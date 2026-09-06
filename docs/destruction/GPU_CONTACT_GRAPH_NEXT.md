# GPU contact-graph integration: measured next target

The native destruction path already evaluates chunk/bond stress and structural
connectivity on CUDA. This is distinct from PhysX's contact-island graph.
Retaining unaffected contact managers during correction exposes significant
CPU maintenance of the latter graph in sustained rubble scenes.

The relevant path is `IG::SimpleIslandManager::thirdPassIslandGen()` in
`physx/source/lowlevel/software/src/PxsSimpleIslandManager.cpp`. It schedules
accurate and speculative third-pass tasks. Each removes destroyed edges and
calls `IslandSim::processLostEdges()` in `PxsIslandSim.cpp`, including graph
traversal and island splitting. `IG_LIMIT_DIRTY_NODES` is zero in the current
source, so the conditional deferred-dirty-node limit is disabled. Do not change
that setting to make a benchmark pass.

New `GpuDestruction.task.accurateIslandMaintenance` and
`GpuDestruction.task.speculativeIslandMaintenance` scopes measure these calls.
The phase analyzer aggregates repeated task calls per accepted timestep; both
trial and correction can contribute. Tasks can run concurrently, so adding
these values to each other or to the enclosing simulation time is invalid.
The qualification JSON records the completed diagnostic runs and their scope.

## Integration seam

`PxgContactManagerInput` currently contains shape/transform-cache references,
not island-edge handles. Resident `PxgShapeSim::mBodySimIndex` already resolves
the current motion owner. CPU `PxcNpWorkUnit::mEdgeIndex` identifies the existing
island edge. `PxgContactGraphIdentity` now carries that edge index and a
scene-local 64-bit contact-manager lifetime generation alongside each resident
pair. The companion follows both CPU and GPU removal/compaction, append, buffer
growth, and the merged narrowphase solver buffers. Registration allocates the
generation under the existing lock; edge indices are captured later, after
parallel island insertion has completed. Removed or refiltered managers receive
new generations, including when slots or shape IDs are reused. Generation zero
marks unavailable metadata in the CPU-narrowphase suffix; a future graph consumer
must handle that suffix or explicitly fall back. Generation exhaustion aborts
rather than cycling back into valid identities.

These are private narrowphase buffers, ordered on its input and solver streams;
they are not an externally synchronized public device view. Tests explicitly
wait for both producers before observing them. The companion currently costs
16 bytes per allocated pair on both CPU and GPU, plus existing bucket/merged
buffer duplication. It does not add separately solved chunk motion.

Tests check CPU/GPU edge association, unique lifetimes, unchanged generations
through sparse removal/growth, new generations after reinsertion/refiltering,
mixed rigid geometry buckets, and destruction disable transitions. Native
resimulation tests also verify identities after every accepted trial/correction,
including repeated impacts and both full rebuild and pair-retention paths.
The identity layer does not itself establish body-handle generations or qualify
a performance improvement. Reusing authored bond connectivity as contact
connectivity would be incorrect.

## Resident CUDA contact components

`PxgDestructionContactGraph.cuh` now decodes current motion owners from resident
shape records and contact lifetimes/touch state from the GPU narrowphase arrays.
Monotone atomic union-find with path halving computes minimum-node-ID labels;
a final compression kernel completes both component arrays. There is no fixed
iteration cap or approximate convergence. Speculative components include candidate
pairs; accurate components require touch and enabled response. Static endpoints
and `eHAS_KINEMATIC_ACTOR` pairs do not bridge dynamic groups. This uses actual
PhysX contact flags, not inverse mass as a proxy for kinematic status.

The runtime exposes a private `PxgDestructionContactGraphView` with borrowed
narrowphase/shape buffers, labels, a retirement bitmask, status, a generation and
a CUDA ready event. It regenerates the graph for both trial and corrected
interaction passes, once late contact-manager retirement
has finished. A first implementation captured too early, leaving late-destroyed
CPU interactions in the GPU graph; native resimulation tests caught that error.
The final path uploads the existing retired-index deltas through persistent pinned
staging and masks those rows before accessing geometry or joining nodes. The
underlying narrowphase buckets compact them on the following pass. Duplicate
retirement entries are safe. Decoded retired rows retain their lifetime identity
and an explicit flag, with invalid motion endpoints. Borrowed narrowphase rows
remain unchanged; consumers must honor the retirement mask before reading geometry.

Storage grows geometrically. Allocation/launch failures make the native step
incomplete; absent/unsupported graph input sets explicit graph status bits.
CPU-fallback and buckets beyond the currently supported rigid prefix are counted
as omitted. No consumer may treat an incomplete contact graph as full connectivity.
The node domain is allocated body-index capacity: unused slots and kinematic
endpoints keep singleton labels and require the caller's live dynamic-node
registry for interpretation. Views expire at the next simulation/configuration.

The persistent graph adds one retirement bit per pair, eight bytes per node for
the two label arrays, and device/pinned retirement-index staging. These are
growable capacities, in addition to the previous identity companions. It borrows
the existing contact buffers rather than allocating another 32-byte edge record
per pair. Decoding and union are fused; edge materialization is used only by the
kernel diagnostic test. CPU work here gathers existing retirement deltas and
schedules kernels. A CUDA event makes stress completion/acceptance depend on graph
reads finishing before later ownership changes or narrowphase buffer reuse.

`GpuDestruction.task.contactGraph` measures host enqueue/allocation/wait time,
not total CUDA kernel duration. It can occur twice in a corrected step and can
be nested inside a correction scope. Graph completion is ordered into stress
and acceptance, but the enqueue scope does not measure that full kernel duration;
CUDA event timing is needed before attributing isolated graph performance.

Tests compare shuffled 100,001-node / 201,998-pair graphs against an independent
CPU flood fill, including cycles, split rebuilds, touch/response differences,
common static/kinematic boundaries, retirement and malformed inputs. Native
tests compare GPU partitions with PhysX's actual accurate/speculative islands,
check CPU interaction ownership, and cover shared boundaries, infinite-mass
nonkinematic dynamics, growth/removal, disable transitions and repeated fracture.

## CUDA-driven island repair (opt-in)

`PxDestructionStressDesc::gpuIslandRepair` now lets CUDA components drive
`IslandSim::findRoute` during the third pass. The native demo exposes
`--gpu-island-repair 0|1`; false keeps the original CPU traversal as the reference.
This is an actual connectivity consumer, no longer only a parallel graph check.

For supported awake rigid scenes, `destroyManagers` retires late managers before
preparing the CUDA graph and scheduling third-pass island tasks. The runtime uses
CUB radix sorting of `(component ID, node ID)` keys to produce stable membership
on the GPU, then observes labels and sorted members in persistent pinned memory.
The existing CPU island registry requires this observation: 24 bytes per allocated
node per preparation, plus the 8-byte status. Buffers grow with graph capacity;
there is no per-pair readback or CPU component construction.

Equal labels eliminate the CPU path search. Different labels supply the exact
component's member list to the existing PhysX split machinery, which maintains
node/edge lists, island IDs, static-touch counts and activation bookkeeping.
CPU validation checks member liveness, membership and visited state before any
mutation. A mismatch invalidates the complete borrowed observation for the rest
of that third pass before falling back to CPU traversal. Labels and sorted membership are not an adjacency tree: split nodes'
fast-route hints are invalidated, allowing later CPU traversal to recover actual
paths. Observed pointers are cleared after the one consuming third-pass task.

Sleeping, joints, articulations, CCD/speculative CCD, custom filters/contact
modification and deformables retain the CPU path. Incomplete GPU input also
retains it; device/allocation failure remains an incomplete simulation, not a
permission to omit physical work. The graph is still regenerated at finalization
for the accepted diagnostic view; removing duplicate preparation is a remaining
optimization requiring lifecycle validation.

Native tests now independently flood-fill the inserted CPU edges and compare
both CUDA components and committed island partitions, even when CUDA drives the
latter. Coverage includes connected cycle removal, splits, handle reuse,
GPU-to-CPU switching and resume, invalid observation fallback, sleeping fallback, static/kinematic boundaries,
and repeated corrected impacts. The controlled repeated-impact fixture uses
four GPU-driven splits with zero fallback and preserves the reference's fracture
steps and all 720 trajectory samples within the existing tolerance.

## Remaining integration

The GPU now computes and supplies connectivity for the opt-in supported path.
CPU compatibility-list maintenance, island insertion and solver preparation
remain. This is not an entirely GPU-owned solver-island lifecycle or a proven
end-to-end speedup. The next integration must move those registry operations to
persistent device storage and consume it directly in scheduling, rather than
keeping a host observation in the final architecture.

Sleeping interactions can retain island edges after releasing their active
contact managers. Their connectivity must be represented persistently before
extending this awake-rigid graph to sleeping islands. Joints and other noncontact
edges also need representation before this is a complete solver-island graph.
CPU compatibility registries must reflect the committed result. The original CPU traversal remains selectable as the reference; neither path
constitutes completion of the full GPU island lifecycle.

Required boundaries include ordinary rigid bodies, private destruction clusters,
and prescribed static/kinematic bodies without connecting an entire world
through the ground. Contacts eligible after splitting must enter the graph.
Deleted/reused pair and body handles must not leave stale edges. Correction must
restore or regenerate graph state alongside motion and contact ownership before
publishing one accepted step. Joints and other currently unsupported native
correction state still need their explicit integration and qualification.

Use controlled component partitions, removal/reinsertion, repeated impacts and
position/velocity/impulse checks before replacing CPU traversal. Preserve the
complete correction fallback. Do not infer independent resimulation scheduling
from a contact component alone, or promote this work based only on a graph
kernel benchmark. The final gate is improved complete-scene simulation cost
with the same physical workload and validated fracture/correction behavior.

## Recorded qualification

`qualification/native-contact-components-20260906.json` records the build, 17
focused tests, zero CUDA memcheck errors and the successful 30-second native run
with 113,664 chunks, 229,376 bonds and 1,024 projectiles. All 1,800 steps converged,
used at most one correction, and passed the physical motion audit. Mean simulation
time was 198.84 ms, or 8.38% of real time; this is not a speedup claim.

The compressed 10-second firing schedule exhausted shared GPU memory twice
(steps 222 and 263), with a failed 945,815,552-byte PhysX allocation. Those captures
remain explicitly incomplete. The second sampled total GPU memory near 23.4 GB;
the successful 30-second schedule peaked near 18.3 GB in the same sampling scheme.
These include another process and are not isolated memory or timing measurements.
The final allocator diagnostics now include the requesting source file and line
so subsequent allocation failures can be tied to the responsible buffer.

### GPU-driven repair results

`qualification/native-gpu-island-repair-20260906.json` records the opt-in consumer,
23 passing final tests (including six CPU reference contract/resimulation tests)
and the completed large capture. The 113,664-chunk / 229,376-bond run completed
1,800 steps with at most one correction each, converged stress and zero motion
audit error. Mean physics time was 195.70 ms (8.52% of real time), with a 1,807.10 ms
maximum and 1,696 missed 16.67 ms deadlines. Shared total GPU memory peaked at
19,366 MiB in two-second samples. No real-time qualification or reliable speedup
is established by this single shared-GPU run.

Accurate/speculative CPU island task scopes averaged 23.78/22.80 ms per accepted
step, and GPU preparation's host scope averaged 2.26 ms. These scopes overlap;
do not add them as independent costs. The earlier reference capture averaged
198.84 ms overall. Controlled fixtures preserve their trajectories and fracture
steps; collapse trajectories differ, so repeated matched trials remain required.
The smaller exploratory run was slower with GPU repair (5.48 versus 5.02 ms).

The final combined CUDA memcheck run reported zero errors. An initial combined
run reported an illegal address in stress topology initialization; isolated
reference and GPU-repair fixtures and combined reruns were clean. Its cause is
still unproven and the original failure log remains in the qualification record.
