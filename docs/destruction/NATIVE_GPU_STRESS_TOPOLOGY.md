# GPU-owned stress connectivity after fracture

The native scene can now commit a broken bond when every persistent chunk keeps
the same rigid cluster. Its material state, accepted bond graph, stress islands,
active rows and solver caches update on the GPU. Subsequent normal scene steps
solve the surviving constraints. This is an intermediate part of the destruction
engine: a fracture that creates a new rigid cluster or destroys chunk geometry
still returns incomplete-step error bit 8. Native body/collision ownership and
internal motion resimulation remain unfinished.

## Native commit rules

The ordinary PhysX trial solve supplies actual contact impulses and provisional
motion. Native stress and material evaluation produce the fracture verdict, then
the GPU topology transaction prepares a candidate. A device comparison checks
that every chunk has the same active flag and minimum-ID cluster owner as in the
accepted topology. Only this unchanged-motion case can commit in this stage.

A cut on a cycle can satisfy that comparison: removing one bond changes internal
stress connectivity without changing cluster mass, inertia, collision geometry,
contact ownership or the rigid motion equations. It therefore needs no physics
resim. No predicted breakage or reduced material verdict is introduced. A verdict
containing a real split or destroyed chunk is rejected as a whole; its accepted
material and topology stay unchanged.

After a successful topology commit, the solver consumes the accepted bond mask
and topology generation through CUDA events. The next normal scene advance uses
that connectivity. A bond already dead in accepted state does not emit another
break decision on subsequent timesteps. Material damage is evaluated once per
native step; this change adds no replay or extra damage evaluation.

## Stress topology API and storage

`ExtStressGpuSolver::enableDeviceTopology()` is a configuration boundary that may
allocate and synchronize. It selects immutable original bond slots and GPU-owned
connectivity. Subsequent `updateDeviceTopologyAsync` calls take a complete device
0/1 bond mask, a device generation and an optional device acceptance flag. Host
solving, bond removal and material-walk entry points reject this mode; observer
readbacks remain available. Existing external reference operation is unchanged.

A strictly newer generation validates the entire mask before changing state.
Equal generation is a no-op and requires an unchanged mask. A zero acceptance
flag rejects the update without reading its mask. Invalid values, resurrection
and stale generations produce errors 1, 2 and 4 respectively, retaining accepted
constraints and generation. Producer and consumer events order the borrowed
buffers; no per-update host graph transfer or completion wait is required.

GPU kernels calculate minimum-ID dynamic components, cut connectivity at
prescribed mass-zero support nodes, and compact active rows in stable original
order. A support is a boundary, not a bridge between independent stress islands.
Immutable endpoint, offset and CSR storage is shared with the stress solver.
Topology updates invalidate warm starts, static/isolated boundary vectors,
convergence state and optional Jacobi preconditioners together. The deterministic
reduction variant builds its ascending order and the reference's 1,024-element
reduction tiles on the GPU. The ordinary legacy reduction path is retained.

`PxDestructionScene.h` API version 4 adds event-ordered stress topology status,
node islands and bond islands to the device view. Status includes accepted
`generation`, `solvedGeneration`, rebuild count and exact live row/island counts.
The physical force buffer describes the last trial solve; after a topology
commit, its `solvedGeneration` remains the old generation until the next solve.
It must not be interpreted as a solution for the newly committed graph. Native
error bit 64 identifies a stress-topology transaction failure. The CPU stage
completion/error observation remains 40 bytes.

## Verification

On the available RTX 4090 with CUDA 12.8:

- The new stress suite compares GPU connectivity with an independent CPU graph
  and forces with the host-managed reference solver at the existing `2e-4`
  relative tolerance. It covers cyclic and support-separated components, warm
  resets, repeated loads, unchanged generations, rejection, invalid masks,
  resurrection, stale generations, recovery and complete bond removal.
- Default, deterministic reductions, Jacobi and bond-space variants pass. Each
  includes a **100,000-node / 200,000-bond** graph, a 100-component partition and
  complete bond removal with exact zero forces. This is stress graph coverage,
  not a 100,000-body collision/destruction or nonzero-load throughput benchmark.
- The native material fixture cuts the weak edge of a supported triangle and
  commits one topology generation while retaining one rigid body and all three
  persistent shapes. Following timesteps carry the analytic 20 N and 10 N loads
  through the surviving bonds. A later verdict producing three clusters fails
  explicitly, preserving the previously accepted graph and material state.
- Full native regression: **41/46 pass**, with the same five failures as before
  this change. Four precede the single-resim policy; `blast_stress_crush_wall_bite`
  is the separately recorded single-verdict behavior gap. No assertion or
  material setting was weakened.
- Compute Sanitizer memcheck reports zero errors for default and deterministic
  stress topology tests and the native material fixture. Installed full-reference
  and native-only consumers pass on CPU and GPU.

Commands and hashes are recorded in
`qualification/native-stress-topology-20260905.json`. Logs are
`out/native-stress-topology-regression.log`,
`out/device-stress-topology-memcheck.log`,
`out/device-stress-topology-deterministic-memcheck.log`,
`out/native-stress-topology-memcheck.log`, and
`out/native-stress-topology-package-consumer.log`.

## Remaining work and performance limits

This implementation retains fixed nodes, support masses, geometry, compliance
and original bond capacity. Mutable support, new bonds, growing storage and
lifecycle handles still need integration. A changed generation rebuilds the
whole configured stress graph. Sparse minimum-node labels currently launch
scalar island work at node capacity; active row counts and deterministic tile
counts stay device-resident. These choices require further scheduling and
capacity optimization before large-scene performance qualification.

True cluster splitting still needs native PhysX body allocation, persistent
collision rebinding, new-pair eligibility, incompatible cache invalidation and
participant checkpoint/restore. The current incomplete path does not roll back
ordinary PhysX provisional motion and is not a completed correction transaction.
The target remains **one physics rewind/resimulation per timestep**, configurable
for more later. Stress CG iterations are separate. No full-scale or 60 Hz claim
is made from these shared-GPU correctness checks.
