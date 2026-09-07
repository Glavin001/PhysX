# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 198 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 256 | 12469 | 3 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 1 | 180 | 1.130 | 17.953 | 36.759 | 56.632 | 59.470 | 99 | 103 | 0.000 | 59.413 | 0.057 |
| 256 buildings, simultaneous aerial impacts | 2 | 180 | 1.164 | 18.029 | 36.499 | 60.645 | 60.821 | 99 | 82 | 0.000 | 60.730 | 0.092 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings, simultaneous aerial impacts

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.077 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.015 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.130 | 0.161 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 11.113 | 18.437 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.002 | 0.126 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.030 | 0.067 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.122 | 3.350 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.002 | 0.007 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.003 | 0.021 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.008 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.006 | 0.031 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.011 | 0.024 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.007 | 0.016 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.080 | 0.211 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.016 | 0.350 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.004 | 0.064 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.006 | 0.134 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.042 | 1.000 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.021 | 0.532 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.010 | 0.219 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.034 | 0.816 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.067 | 1.681 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.034 | 0.109 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.024 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 2.205 | 23.988 |
| Accept corrected step | GPU commit/status completion and CPU publication | 1.193 | 2.838 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 2.917 | 7.925 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.055 | 0.062 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 18.216 | 62.214 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.093 | 0.138 |
| Iterative stress solve to convergence | 10.670 | 17.836 |
| Evaluate material damage and fracture | 0.070 | 0.067 |
| Connectivity, cluster mass and fragment candidates | 0.239 | 0.487 |
| Commit changes and rebuild stress topology | 0.145 | 0.039 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.042 | 0.495 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.040 | 0.070 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.047 | 0.170 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.077 | 0.321 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.449 | 1.267 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.436 | 1.255 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.014 | 0.046 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.209 | 0.474 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.096 | 0.292 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.033 | 0.056 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.080 | 0.174 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.070 | 0.091 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.059 | 0.210 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.118 | 0.566 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.049 | 1.057 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.009 | 0.625 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.025 | 0.547 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.060 | 1.505 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.801 | 4.672 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.796 | 4.657 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.036 | 0.927 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.122 | 1.082 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.053 | 1.145 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.008 | 0.061 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.054 | 2.087 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.077 | 6.049 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.004 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.025 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.038 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

Scoped peak: repeat 1, step 103, complete advance 62.214 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 18.216 ms versus untraced repeat means 17.953–18.029 ms; scoped peak 62.214 ms versus untraced peaks 59.470–60.821 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 58475, first untraced 58475. These are separate trajectories, not a decomposition of the same measured peak.
