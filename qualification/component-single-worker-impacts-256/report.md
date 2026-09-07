# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 1038 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 256 | 14219 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 1 | 600 | 1.010 | 11.483 | 18.283 | 26.680 | 52.439 | 519 | 82 | 0.000 | 52.364 | 0.075 |
| 256 buildings, simultaneous aerial impacts | 2 | 600 | 0.980 | 11.659 | 18.761 | 25.719 | 48.525 | 519 | 82 | 0.000 | 48.460 | 0.065 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings, simultaneous aerial impacts

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.023 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.016 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.117 | 0.133 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 5.999 | 3.650 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.021 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.022 | 0.134 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.047 | 5.670 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.002 | 0.018 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.017 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.005 | 0.066 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.009 | 0.105 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.006 | 0.072 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.066 | 0.175 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.006 | 0.756 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.002 | 0.234 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.002 | 0.313 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.018 | 0.647 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.008 | 1.022 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.004 | 0.440 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.013 | 1.675 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.023 | 4.667 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.029 | 0.105 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.006 | 0.063 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.559 | 26.214 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.107 | 0.453 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.477 | 3.169 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.053 | 0.059 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 11.629 | 49.897 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.169 | 0.055 |
| Iterative stress solve to convergence | 5.599 | 3.149 |
| Evaluate material damage and fracture | 0.065 | 0.072 |
| Connectivity, cluster mass and fragment candidates | 0.215 | 0.449 |
| Commit changes and rebuild stress topology | 0.043 | 0.039 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.020 | 0.110 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.019 | 0.043 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.025 | 0.177 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.043 | 0.145 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.466 | 0.274 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.453 | 0.264 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.009 | 0.094 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.310 | 0.100 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.051 | 0.157 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.025 | 0.023 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.064 | 0.072 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.068 | 0.079 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.031 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.058 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.014 | 2.885 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.410 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.008 | 1.374 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.020 | 3.057 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.553 | 7.451 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.548 | 7.437 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.015 | 1.396 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.105 | 0.801 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.022 | 2.261 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.191 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.025 | 1.378 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.042 | 0.651 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.005 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |

Scoped peak: repeat 1, step 82, complete advance 49.897 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 11.629 ms versus untraced repeat means 11.483–11.659 ms; scoped peak 49.897 ms versus untraced peaks 48.525–52.439 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 62728, first untraced 62728. These are separate trajectories, not a decomposition of the same measured peak.
