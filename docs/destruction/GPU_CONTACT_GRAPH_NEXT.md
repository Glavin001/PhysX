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
CUB radix sorting of `(component ID, node ID)` keys followed by a CUDA kernel that
produces component heads and node successors in stable node-ID order. The
registry observes labels and these member links in persistent pinned memory.
Component lookup is direct; CPU binary searches are removed. The two link arrays
reuse the consumed input-key buffer, preserving the 8-byte-per-node membership
allocation and transfer size.
The existing CPU island registry observes only graphs with pending connectivity
changes: 12 bytes per allocated node for each requested graph, plus one 8-byte
status per observation. With both graphs clean, no sort or readback is performed.
Pending destroyed edges count as changes before third-pass removal marks their
nodes dirty. Buffers grow with graph capacity; there is no per-pair readback or
CPU component construction.

Equal labels eliminate the CPU path search. Different labels supply the exact
component's member list to the existing PhysX split machinery, which maintains
node/edge lists, island IDs, static-touch counts and activation bookkeeping.
CPU validation checks member liveness, membership, strict ascending order and visited state before any
mutation. A mismatch invalidates the complete borrowed observation for the rest
of that third pass before falling back to CPU traversal. Labels and ordered membership are not an adjacency tree: split nodes'
fast-route hints are invalidated, allowing later CPU traversal to recover actual
paths. Observed pointers are cleared after the one consuming third-pass task.

Sleeping, joints, articulations, CCD/speculative CCD, custom filters/contact
modification and deformables retain the CPU path. Incomplete GPU input also
retains it; device/allocation failure remains an incomplete simulation, not a
permission to omit physical work. Finalization reuses the graph prepared for the
same narrowphase pass when its lifetime generation, per-bucket pair counts and
retirement counts and the retained-edge lifecycle revision remain valid. A new narrowphase result, pair append/compaction,
correction cache reset, runtime reconfiguration or changed retirement set
invalidates reuse. Retirement lists are append-only between compactions; sorting
them does not change the represented retirement set. The existing ready event
and graph-to-stress dependency remain in force when a build is reused. Trial and
corrected passes always receive distinct graphs; this does not reuse across
simulation steps.

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

### Graph reuse and selective observation

The native demo now emits `native.graph-diagnostics.json` with graph build/reuse
counts, host observation/sort counts, graph-only device-to-host bytes, GPU-driven
connectedness answers/splits and registry mismatch fallbacks. These are scoped
counters, not total engine transfer metrics. They are read after the timed loop.

The repeated-impact fixture requires exactly 62 graph builds for 60 steps and
two corrections, and 62 same-pass reuses when GPU island repair is enabled.
Independent CPU edge flood fills, fracture decisions and trajectory tolerances
remain unchanged. A quiet registry fixture requires zero sort/readback, while
explicit one-graph observations check that the other graph is not returned or
transferred. Late manager retirement and runtime reconfiguration reject the
old reuse receipt. The 100,001-node / 201,998-pair CUDA test also compares the
production member-link kernel against independent CPU grouping, including the
reused key-buffer layout; malformed cyclic host membership triggers CPU fallback.

`GpuDestruction.task.{accurate,speculative}Island.*` scopes now distinguish
connection removal, edge-list removal, path/split work, destroyed edge/node
cleanup, deactivation and dirty-list reset. These are nested inside the existing
island-maintenance scopes and must not be added again to complete-step time.
They will identify the remaining CPU registry work to move into device storage.
Sleeping behavior has not been changed by this optimization.

### Retained contact edges and independent boundary auditing

A pre-mutation audit exposed a missing input in the active-manager-only graph.
At step 82 of the 64-building capture, native speculative connectivity contained
830 dynamic-to-dynamic contact edges without a narrowphase contact manager, in
addition to 838 edges represented by active pairs. This occurs during fragment
creation even with sleeping disabled. The GPU graph reported singleton fragments
where native edges connected them. Merely disabling sleeping did not establish
complete graph coverage. Failed captures remain under
`out/recordings/native-boundary-audit-{gpu,detail,pairs,edges}-20260906`.

`SimpleIslandManager` now tracks retained contact edges in a bitmap maintained by
contact registration, manager creation/release, edge removal and handle reuse.
Parallel registration uses atomic bit operations. Graph construction enumerates
this bitmap, excluding removed/uninserted entries, and transfers their current
endpoints and accurate/speculative state to persistent, growable CUDA storage.
The CUDA union kernel combines these edges with resident narrowphase pairs before
compression and deterministic member generation. Static/kinematic boundaries do
not bridge groups; invalid endpoints and unsupported edge kinds report explicit
graph errors. These records belong to the published graph generation; raw native
indices are not independently persistent public handles.

The initial bridge added one host bit per allocated native edge and uploaded a
16-byte retained-edge snapshot per graph build. The persistent lifecycle update
below replaces that snapshot implementation. CPU compatibility registries and
direct solver consumption still need their remaining integration. Lifecycle revisions invalidate
same-pass graph reuse on manager transitions, contact state changes or kinematic
changes, even if narrowphase pair/retirement counts did not change.

`--audit-islands 1` enables an expensive independent CPU flood fill from native
inserted edges before GPU components can change island membership. It checks
labels and complete ordered member chains, including incorrect equal labels.
Failure clears the borrowed graph, records a sticky diagnostic and rejects the
capture after fetch. It does not qualify a failed step or silently replace a
failed audited run with CPU success. The option defaults off; enabling it adds
CPU work inside measured simulation time. `native.graph-diagnostics.json`
records audit failures and graph transfer counts separately.

The real-fracture regression requires retained edges, at least one correction,
zero boundary mismatches and zero motion-audit error. Existing repeated-impact
parity tests now run the boundary audit as well, keeping all prior tolerances.
Kernel tests separately cover retained touching/no-touch edges, disabled response,
static/kinematic boundaries and removal on the next graph build.

The first fixed 64-building run completed 600 steps with 1,234 boundary audits,
zero mismatches/fallbacks and at most one correction per step. It uploaded 45,874
retained-edge records across graph builds (733,984 bytes), with a peak snapshot
of 3,836 retained edges. These are diagnostic shared-GPU results, not speedup or
60 Hz qualification.

An earlier `native-member-links-gpu-20260906` run exited with SIGSEGV after the
last flushed accepted step 209. Five debugger and five crash-trace retries
completed, and a partial CPU AddressSanitizer run wrote a 600-step completion
manifest without an invalid-access report. No crash stack was captured. The
retained-edge omission is now reproducible and fixed, but its causal relation to
that original segfault has not been established. Preserve that failure as open;
clean retries alone do not prove a fix. The prior CUDA stress-initialization
sanitizer observation is also distinct and remains documented above.

`qualification/native-retained-contact-20260906.json` records final source hashes,
24 passing focused tests, the audited 64-building run and all unresolved failures.
The graph-kernel and native island-repair CUDA memory checks reported zero errors.
The real-fracture asynchronous sanitizer run failed at step 1, and an ordinary
asynchronous retry failed at step 150, both with error 700 reported at
`Runtime::finish()`'s completion wait and no device fault location. CPU-reference
repair, `CUDA_LAUNCH_BLOCKING=1`, and `BLAST_GPU_GRAPH_UPDATE=0` comparisons each
completed with zero sanitizer errors. This narrows the next investigation but
establishes neither a CUDA graph-update bug nor a fix. Default optimization
settings have not been changed to hide the failure. Broader qualification remains
open. Old partial-ASan binaries predate the changed native class layout and must
not be run against the current GPU libraries without rebuilding.

### Conditional-graph diagnostic isolation

A standalone arithmetic graph now reproduces an instrumented error 700 at its
first launch without PhysX/Blast, stream capture, graph allocation nodes or any
graph update. Its plain-graph control passes memcheck; all three modes produce
500 correct results without instrumentation. IF and WHILE fail with the isolated
CUDA 13.2 sanitizer, while WHILE fails and IF passes with the installed CUDA 12.8
sanitizer. Both errors occur before graph update or destruction. This is stronger
evidence against an update-specific explanation, but it does not identify the
cause or prove that the native solver failure has the same cause. Production
conditional-loop/update settings remain unchanged; native memory qualification
is still open.

`tools/diagnostics/cuda-conditional-graph/` contains the dependency-free source
and reproducible command runner. `qualification/cuda-conditional-graph-diagnostic-20260906.json`
records both tool versions, exact source hash, exit codes and logs. The diagnostic
returns failure for instrumented errors and is not treated as a green engine test.

The CPU boundary audit now has separate
`task.{accurate,speculative}Island.boundaryAudit` profiling scopes. These are
nested inside island maintenance, not additional simulation costs. With auditing
disabled they measure only the no-op call and scope overhead. They distinguish
validation cost from compatibility-registry maintenance in diagnostic runs;
subtracting overlapping host scopes does not establish unaudited throughput.

### Full-size retained-edge regression

The fixed path completed 30 seconds / 1,800 steps with 256 buildings, 113,664
chunks, 229,376 bonds and 1,024 projectiles. All stress solves converged, all 4,202
independent boundary audits passed, and motion-audit error and registry fallback
counts were zero. The 384 corrected steps used at most one resimulation each.
It performed 2,184 graph builds and 2,184 same-pass reuses; 85,214 retained-edge
records were uploaded (1,363,424 bytes).

The existing CPU registry bridge observed 5,659,647,152 bytes of graph data. This
is scoped graph readback, not total engine transfers. Mean physics time was
244.89 ms (6.81% of real time), maximum 1,703.71 ms, with 1,702 missed 16.67 ms
deadlines. The independent CPU audit is included, the GPU was shared, and state
recording was disabled. This is a scale correctness result, not a comparison
against the earlier unaudited video or a real-time qualification. The run used
revision e408107e before the new boundary-audit timing scopes; do not attribute
those new scopes to this capture.

`qualification/native-retained-contact-large-20260906.json` records source/library
provenance, every artifact hash, counters, timings and remaining limitations.
The next production integration remains direct device island-registry maintenance
and solver consumption, replacing the compatibility observation bridge rather
than treating observed CUDA components as the final GPU-owned lifecycle.

The profiling change rebuilt successfully and passed the same 24 focused native,
GPU-graph and CPU-reference tests. A separate 240-step / 7,104-chunk fracture run
exercised both boundary-audit scopes on every step, checked that each remained
within its parent maintenance interval, and completed with zero boundary or
motion-audit failures. Its exact results and build hashes are recorded in
`qualification/native-island-audit-scopes-20260906.json`. No physics settings or
assertion tolerances changed.

## Persistent retained-contact lifecycle on CUDA

Retained contact records now live in native-edge-indexed device slots between
graph builds. A device bitmap identifies active slots. CUDA applies ordered
insert/update/remove transactions, maintains live/peak counts, and consumes the
active slots when computing accurate and speculative connectivity. It no longer
requires the CPU to enumerate and upload every retained edge on each graph build.

Native registration, manager release/recreation, touch changes and destruction
mark an atomic changed-edge bitmap. Endpoint type changes coalesce a refresh of
retained candidates once at the publication boundary. Commands have unique,
sorted native edge indices and represent final state at that boundary. Edges
awaiting insertion stay dirty for a later transaction. A new or reconfigured
runtime imports the current set once; subsequent publications acknowledge the
change bitmap only after successful submission. A publication receipt masks out
coalesced removals for edges that were never device-resident. It tracks submitted
membership, not components or another physics simulation. Same-pass reuse retains the
existing native lifecycle revision check. CPU work here is command staging from
the existing native lifecycle; edge state application, live membership and
connectivity reside on CUDA.

Private slot indices are scoped by the published graph generation, including
removal/reuse and reconfiguration. They are not independent public lifetime
handles. The graph's active mask must be tested before reading any slot, and
`retainedSlotCount` describes the index domain, not live count. Producer-stream
ordering and the graph-ready event protect commands, slots and the consuming
stress/acceptance path. Slot growth preserves prior records/mask; allocation
failure rejects the step. Invalid command framing is rejected on the host before
acknowledging the change log. CUDA also validates the entire batch before any
slot mutation; malformed/duplicate/out-of-range batches report explicit errors.

Memory tradeoff: this first persistent registry allocates 16 bytes per reserved
native edge slot plus one device bit per slot, including inactive holes. Three host
bitmaps track retained/changed edges and acknowledged publication membership. Command staging uses 16 bytes per reserved
delta on the host and device, and three device words track counts/validation.
It replaces the smaller dense snapshot with stable addressable storage; this is
not a claimed memory reduction. `retained_slot_capacity` makes the cost visible.
Paged storage is a future optimization if measured native edge capacity warrants
it; allocation failure must never truncate the registry.

Diagnostics distinguish upsert records (`retained_edges_uploaded`), all commands
including removals (`retained_delta_updates`), command H2D bytes, slot capacity
and exact peak live edges. Explicit counter queries read eight diagnostic bytes;
these are excluded from the simulation graph D2H counter, as its scope states.
There is no per-step live-count readback. The existing CPU component observation
bridge remains and must still be replaced by native GPU registry/solver consumers.

### Solver integration ordering

`PxgGpuContext::updatePostPartitioning()` stages island IDs/static-touch metadata
for the CUDA solver before releasing the lost-contact tasks.
`Sc::Scene::destroyManagers()` currently builds the accurate retained-edge graph
after those tasks retire managers. Therefore, directly feeding this later graph
to the earlier solver would change the phase of connectivity/static-boundary
state used for integration. The next device registry work must preserve those
phase boundaries, not wire a later snapshot into an earlier consumer or assume
GPU solver islands already provide independent resimulation scheduling.

### Persistent lifecycle qualification

`qualification/native-retained-deltas-20260906.json` records the final build,
25 passing focused tests, and zero memcheck errors for the graph kernels and
native retained-registry fixture. The latter exercises unchanged/transient edges
with zero uploads, deferred insertion, touch and kinematic changes, live-storage
growth, removal/handle reuse, and runtime reset. Kernel tests compare successive
transactions against an independent CPU flood fill and require complete
state preservation when an out-of-range or unsorted/duplicate batch is rejected.
Existing fracture decisions and trajectory tolerances were not loosened.

The final 64-building run completed 600 steps with 28,416 chunks, 57,344 bonds,
256 projectiles and 104 single-correction steps. All stress solves converged;
1,242 boundary audits passed with zero registry fallback or motion-audit error.
It submitted 7,593 upserts and 7,593 removals (242,976 H2D bytes). An initial delta
implementation had uploaded 1,152,207 commands / 18,435,312 bytes because native
manager churn produced removals for never-published edges. Publication receipts
and pre-insertion filtering remove that unnecessary traffic. The initial capture
is preserved; these chaotic runs are not a matched-workload speedup comparison.

The final registry reserved 451,584 slots (7,281,804 device bytes for slot storage,
active bits and count words, excluding update staging), with 3,836 peak live
retained edges. Component observation still transferred 439,114,032 D2H bytes.
Mean measured physics time was 55.25 ms, maximum 298.01 ms, or 30.17% of real time;
499 of 600 steps missed 16.67 ms. Auditing/profiling were enabled on a shared GPU.
This qualifies the lifecycle change at the tested scale, not a full GPU-owned
island solver, large-scene memory safety, or an isolated performance improvement.
The prior real-fracture sanitizer failure and unexplained native crash remain open.
