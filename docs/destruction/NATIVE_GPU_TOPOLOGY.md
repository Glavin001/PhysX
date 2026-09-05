# Native GPU fracture topology transactions

The native `PxScene` destruction task now feeds its material verdict directly
into a persistent GPU topology transaction. This is an intermediate integration:
**candidate clusters do not yet replace PhysX collision/solver bodies**, and the
native internal resimulation is still unfinished. A topology-changing native
step continues to return error bit 8, preserving accepted material and topology.

## Data and execution

`PxDestructionStressDesc::chunkMassProperties` enables this path. It supplies
immutable physical mass, COM and the full symmetric inertia tensor in asset
axes. These properties are separate from the stress solver's mass-zero support
convention. Initial motion bindings must match connected components exactly;
independent components cannot alias one PhysX body. Configuration may prepare
arrays on the CPU; per-step edit counts, connectivity, mass properties and
candidate motion stay on the GPU.

The native task generates `BreakBond` and `DestroyChunk` edits from actual
stress/material decisions, using storage for every possible decision. It passes
a device count into `PxgDestructionTopologyTransaction::prepare`, ordered by a
CUDA event. No fracture list or cluster-count readback drives this process.

Preparation validates the entire batch before editing. Device-side conditions
skip the heavy work for empty, redundant, invalid, overflowing or rejected
batches. A valid changed batch creates a candidate using minimum-ID connected
components, stable chunk ordering, physical COM and full inertia. The immutable
chunk/bond records are shared by accepted and candidate views. Each view has
one live motion record per connected component, with capacity for every chunk
to separate.

Conditional CUDA graphs are created during configuration. They allow CUB sorting
and compaction to remain inside the conditional rebuild, rather than running
those operations on every quiet timestep. This uses CUDA 12.3 or newer; see
[NVIDIA's conditional graph documentation](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/cuda-graphs.html#conditional-nodes).
This does not yet restrict a changed transaction to affected components: a
changed transaction still rebuilds the whole configured graph.

## Motion and commit

Candidate motion comes from the ordinary PhysX trial step. Parent point velocity
is reconciled at the physical cluster COM, including an offset between actor
origin and body COM. Splitting transfers that rigid velocity field to each new
COM on the GPU. The transaction accepts a separate provisional motion input,
so preparing or discarding a candidate does not overwrite accepted motion.

The transaction's `commit` operation takes a device acceptance flag. Rejection
preserves accepted buffers; a successful commit updates connectivity, properties,
and motion once. Repeating commit has no effect. Native PhysX does not call this
commit yet: it first needs collision ownership rebinding, constraint/cache
invalidation, participant checkpoint/restore, and the corrected physics solve.
Normal nonfracturing native steps update the observed accepted cluster motion.
At configuration, topology motion starts at identity; it is a valid native motion
observation only after a successful native step. Initial and failed-step physical
motion checkpointing remains part of the missing correction lifecycle.

`PxDestructionDeviceView` exposes accepted and trial topology plus a transaction
status. Candidate arrays are valid only when `prepared` is nonzero. The native
ready event orders the complete stage, and the consumer event protects those
views through the next step or reconfiguration. The CPU still receives only the
existing 40-byte stage completion/error observation.

## Verification

- Native material tests require the candidate graph to match each actual bond
  failure and full-crush verdict, preserve support, and retain accepted mass and
  generation when correction is incomplete. Nonfracturing frames must perform
  zero topology rebuilds.
- A native rotating two-chunk actor with an offset COM produces the analytic
  centrifugal bond load. Candidate COM velocities, orientation, linear/angular
  momentum and kinetic energy meet the existing `2e-4` relative tolerance.
- Transaction tests cover device-produced counts, invalid mixed batches,
  overflow, producer rejection, empty/redundant work, discard, candidate
  replacement, committed generation and commit-once behavior.
- A **100,000-chunk / 200,000-bond** graph is split into 100 components and
  compared with independent CPU connectivity/mass calculations. A second
  candidate breaks all 200,000 bonds and yields 100,000 components without
  dropping edits or modifying the still-intact accepted graph. This is graph
  qualification, not a 100,000-body PhysX collision/destruction benchmark.
- Compute Sanitizer memcheck covers the transaction suite, including the large
  graph and overflow cases; its report is `out/topology-transaction-memcheck.log`.

The full native suite remains **36/40 passing**, with the same four recorded
baseline failures and no loosened tolerances. Installed CPU/GPU consumers for
both the reference SDK and native scene interface pass. The source/artifact
record is `qualification/native-scene-topology-20260905.json`; full regression
and package logs are `out/native-topology-regression.log` and
`out/native-topology-package-consumer.log`. Native scene memory-check results
are in `out/native-topology-memcheck.log` (zero errors).

The current resimulation setting is to be one per timestep, while allowing
additional passes as an explicit later configuration. Stress-solver iterations
are separate. See [RESIMULATION.md](RESIMULATION.md).

Required completion work remains: native collision ownership, GPU solver
connectivity updates after commit, checkpoint/restore and corrected interaction,
GPU support changes, generation-bearing lifecycle handles, crush geometry and
energy accounting, committed events/observations, and full-scale qualification.
