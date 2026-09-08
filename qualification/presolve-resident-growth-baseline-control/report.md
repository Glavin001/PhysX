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
| 256 buildings, simultaneous aerial impacts | 1 | 180 | 1.122 | 17.072 | 35.539 | 53.277 | 62.926 | 99 | 103 | 0.000 | 62.842 | 0.084 |
| 256 buildings, simultaneous aerial impacts | 2 | 180 | 1.134 | 17.020 | 35.324 | 52.445 | 59.319 | 99 | 103 | 0.000 | 59.247 | 0.072 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings, simultaneous aerial impacts

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.063 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.013 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.129 | 0.167 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 10.259 | 18.166 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.001 | 0.116 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.047 | 0.069 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.118 | 3.096 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.002 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.003 | 0.025 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.007 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.006 | 0.029 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.011 | 0.023 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.007 | 0.016 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.084 | 0.204 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.017 | 0.344 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.004 | 0.067 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.006 | 0.141 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.039 | 0.927 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.022 | 0.529 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.009 | 0.188 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.035 | 0.807 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.066 | 1.228 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.037 | 0.101 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.023 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 2.168 | 25.186 |
| Accept corrected step | GPU commit/status completion and CPU publication | 1.198 | 2.852 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 2.809 | 7.914 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.059 | 0.082 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 17.228 | 62.325 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.093 | 0.136 |
| Iterative stress solve to convergence | 9.816 | 17.575 |
| Evaluate material damage and fracture | 0.070 | 0.067 |
| Connectivity, cluster mass and fragment candidates | 0.239 | 0.482 |
| Commit changes and rebuild stress topology | 0.145 | 0.039 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.039 | 0.524 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.029 | 0.074 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.043 | 0.148 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.071 | 0.273 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.449 | 1.270 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.437 | 1.249 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.012 | 0.042 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.211 | 0.531 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.087 | 0.275 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.028 | 0.069 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.077 | 0.178 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.055 | 0.077 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.004 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.052 | 0.192 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.106 | 0.518 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.045 | 0.852 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.007 | 0.569 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.024 | 0.871 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.045 | 1.481 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.819 | 4.701 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.814 | 4.691 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.035 | 0.678 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.122 | 1.089 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.052 | 1.239 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.008 | 0.061 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.052 | 2.014 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.068 | 5.248 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.006 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.022 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.046 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

Scoped peak: repeat 1, step 103, complete advance 62.325 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 17.228 ms versus untraced repeat means 17.020–17.072 ms; scoped peak 62.325 ms versus untraced peaks 59.319–62.926 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 58475, first untraced 58475. These are separate trajectories, not a decomposition of the same measured peak.
