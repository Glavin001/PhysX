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
This is prerequisite identity plumbing: it does not move island traversal to
CUDA, establish body-handle generations, or qualify a performance improvement.
Reusing authored bond connectivity as contact connectivity would be incorrect.

The next implementation should consume resident pair ownership and touch state
on CUDA, build accurate and speculative contact components, and replace the CPU
component-traversal path through the existing island/solver integration. CPU
compatibility registries must reflect the committed result. A shadow GPU graph
is an intermediate parity check, not completion or a second simulation.

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
