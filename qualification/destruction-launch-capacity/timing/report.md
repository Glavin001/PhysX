# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 3276 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings, 256 shots spread over 10 seconds (25.6 launches per simulated second) | 113664 | 229376 | 256 | 14655 | 15 | 1 | Disabled |
| 256 buildings, 256 simultaneous shots | 113664 | 229376 | 256 | 14167 | 15 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, 256 shots spread over 10 seconds (25.6 launches per simulated second) | 1 | 900 | 1.133 | 24.068 | 33.796 | 35.758 | 37.965 | 819 | 702 | 0.000 | 37.899 | 0.066 |
| 256 buildings, 256 shots spread over 10 seconds (25.6 launches per simulated second) | 2 | 900 | 1.131 | 24.096 | 33.815 | 35.577 | 37.177 | 819 | 726 | 0.000 | 37.083 | 0.094 |
| 256 buildings, 256 simultaneous shots | 1 | 900 | 1.148 | 22.057 | 31.702 | 34.094 | 52.034 | 819 | 103 | 0.000 | 51.964 | 0.069 |
| 256 buildings, 256 simultaneous shots | 2 | 900 | 1.131 | 22.079 | 31.500 | 33.749 | 53.780 | 819 | 103 | 0.000 | 53.711 | 0.068 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings, 256 shots spread over 10 seconds (25.6 launches per simulated second)

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.024 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.011 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.122 | 0.120 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 16.059 | 26.515 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.001 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.055 | 0.055 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.012 | 0.016 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.003 | 0.005 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.004 | 0.004 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.009 | 0.012 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.026 | 0.023 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.011 | 0.016 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.133 | 0.186 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.005 | 0.006 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.001 | 0.002 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.002 | 0.002 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.013 | 0.019 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.007 | 0.005 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.002 | 0.002 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.010 | 0.008 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.015 | 0.012 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.062 | 0.153 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.010 | 0.015 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.005 | 0.008 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 2.453 | 4.165 |
| Accept corrected step | GPU commit/status completion and CPU publication | 1.630 | 2.393 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.569 | 4.323 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.062 | 0.049 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 24.320 | 38.128 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.140 | 0.208 |
| Iterative stress solve to convergence | 15.475 | 25.781 |
| Evaluate material damage and fracture | 0.070 | 0.071 |
| Connectivity, cluster mass and fragment candidates | 0.344 | 0.514 |
| Commit changes and rebuild stress topology | 0.127 | 0.039 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.015 | 0.017 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.015 | 0.018 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.016 | 0.022 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.034 | 0.065 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.679 | 0.503 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.665 | 0.492 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.008 | 0.009 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.303 | 0.405 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.029 | 0.042 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.019 | 0.023 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.057 | 0.074 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.072 | 0.067 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.020 | 0.028 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.036 | 0.064 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.008 | 0.009 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.006 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.008 | 0.009 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.018 | 0.026 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.874 | 1.332 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.866 | 1.322 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.011 | 0.018 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.173 | 0.303 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.016 | 0.016 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 0.016 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.028 | 0.039 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.053 | 0.079 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.003 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |

Scoped peak: repeat 1, step 655, complete advance 38.128 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 24.320 ms versus untraced repeat means 24.068–24.096 ms; scoped peak 38.128 ms versus untraced peaks 37.177–37.965 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 66480, first untraced 66480. These are separate trajectories, not a decomposition of the same measured peak.

## Separate phase capture: 256 buildings, 256 simultaneous shots

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.016 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.123 | 0.152 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 16.577 | 8.149 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.040 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.017 | 0.181 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.031 | 6.132 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.001 | 0.025 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.062 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.008 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.003 | 0.079 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.006 | 0.104 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.004 | 0.075 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.047 | 0.185 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.004 | 0.851 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.001 | 0.272 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.001 | 0.288 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.012 | 0.618 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.005 | 1.045 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.002 | 0.506 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.009 | 1.721 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.016 | 4.811 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.020 | 0.112 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.004 | 0.064 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.002 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.053 | 27.878 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.569 | 2.376 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.605 | 3.395 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.063 | 0.085 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 22.211 | 59.226 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.179 | 0.065 |
| Iterative stress solve to convergence | 16.146 | 7.638 |
| Evaluate material damage and fracture | 0.068 | 0.076 |
| Connectivity, cluster mass and fragment candidates | 0.168 | 0.461 |
| Commit changes and rebuild stress topology | 0.112 | 0.043 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.017 | 0.258 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.018 | 0.063 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.019 | 0.112 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.033 | 0.140 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.449 | 0.275 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.436 | 0.265 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.009 | 0.082 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.328 | 0.109 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.037 | 0.113 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.023 | 0.027 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.061 | 0.062 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.073 | 0.090 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.022 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.040 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.009 | 3.897 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.280 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.005 | 1.303 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.012 | 2.401 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.374 | 7.501 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.371 | 7.490 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 1.318 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.072 | 0.832 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.014 | 2.780 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.186 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.004 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.017 | 1.376 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.021 | 0.294 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |

Scoped peak: repeat 1, step 82, complete advance 59.226 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 22.211 ms versus untraced repeat means 22.057–22.079 ms; scoped peak 59.226 ms versus untraced peaks 52.034–53.780 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 62674, first untraced 62674. These are separate trajectories, not a decomposition of the same measured peak.
