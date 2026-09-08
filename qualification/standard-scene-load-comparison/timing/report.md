# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 9523 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

⚠️ Chaotic workload variation: 16 buildings / 7104 chunks / 14336 bonds / 48 aerial projectiles, repeat 2: per-step counter history differs. Convergence and correction-limit checks passed, but exact trajectories and full physical quality are not qualified.

⚠️ Chaotic workload variation: 64 buildings / 28416 chunks / 57344 bonds / 192 aerial projectiles, repeat 2: per-step counter history differs. Convergence and correction-limit checks passed, but exact trajectories and full physical quality are not qualified.

⚠️ Chaotic workload variation: 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles, repeat 2: per-step counter history differs. Convergence and correction-limit checks passed, but exact trajectories and full physical quality are not qualified.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 16 buildings / 7104 chunks / 14336 bonds / 48 aerial projectiles | 7104 | 14336 | 48 | 2292 | 30 | 1 | Enabled |
| 64 buildings / 28416 chunks / 57344 bonds / 192 aerial projectiles | 28416 | 57344 | 192 | 8085 | 30 | 1 | Enabled |
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 113664 | 229376 | 768 | 33552 | 30 | 1 | Enabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 16 buildings / 7104 chunks / 14336 bonds / 48 aerial projectiles | 1 | 1800 | 0.658 | 9.730 | 18.060 | 21.890 | 28.150 | 996 | 560 | 0.000 | 28.104 | 0.046 |
| 16 buildings / 7104 chunks / 14336 bonds / 48 aerial projectiles | 2 | 1800 | 0.629 | 10.896 | 18.572 | 21.855 | 29.041 | 1651 | 460 | 0.000 | 28.965 | 0.076 |
| 64 buildings / 28416 chunks / 57344 bonds / 192 aerial projectiles | 1 | 1800 | 0.803 | 18.819 | 41.484 | 44.285 | 48.505 | 1719 | 658 | 0.000 | 48.403 | 0.102 |
| 64 buildings / 28416 chunks / 57344 bonds / 192 aerial projectiles | 2 | 1800 | 0.818 | 19.723 | 44.509 | 48.687 | 52.997 | 1719 | 506 | 0.000 | 52.886 | 0.111 |
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 1 | 1800 | 2.720 | 111.479 | 264.259 | 277.351 | 309.156 | 1719 | 571 | 0.110 | 308.962 | 0.085 |
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 2 | 1800 | 2.689 | 114.046 | 266.933 | 276.233 | 301.029 | 1719 | 648 | 0.108 | 300.858 | 0.064 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 16 buildings / 7104 chunks / 14336 bonds / 48 aerial projectiles

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.003 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.007 | 0.006 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.108 | 0.098 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 7.708 | 14.312 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.007 | 0.079 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.001 | 0.014 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.004 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.004 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.005 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.001 | 0.011 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.004 | 0.019 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.012 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.008 | 0.077 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.002 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.001 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.000 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.001 | 0.005 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.001 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.001 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.001 | 0.001 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.001 | 0.003 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.010 | 0.141 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.001 | 0.012 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.426 | 4.932 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.089 | 0.840 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.859 | 2.666 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.058 | 0.084 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 10.301 | 23.331 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.027 | 0.031 |
| Iterative stress solve to convergence | 7.600 | 14.050 |
| Evaluate material damage and fracture | 0.019 | 0.019 |
| Connectivity, cluster mass and fragment candidates | 0.050 | 0.190 |
| Commit changes and rebuild stress topology | 0.060 | 0.034 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.004 | 0.006 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.006 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.006 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.008 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.100 | 0.091 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.087 | 0.078 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.005 | 0.002 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.171 | 0.234 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.005 | 0.016 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.008 | 0.009 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.007 | 0.032 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.019 | 0.020 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.096 | 0.056 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.005 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.007 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.012 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.007 | 0.079 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.011 | 0.107 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.009 | 0.102 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.014 | 0.181 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.028 | 0.281 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.027 | 0.271 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.015 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.028 | 0.315 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.035 | 0.415 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.026 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.018 | 0.216 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.008 | 0.076 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |

Scoped peak: repeat 1, step 428, complete advance 23.331 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 10.301 ms versus untraced repeat means 9.730–10.896 ms; scoped peak 23.331 ms versus untraced peaks 28.150–29.041 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run differs; through the scoped peak differs. Broken bonds: scoped 6802, first untraced 7024. These are separate trajectories, not a decomposition of the same measured peak.

## Separate phase capture: 64 buildings / 28416 chunks / 57344 bonds / 192 aerial projectiles

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.010 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.011 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.123 | 0.154 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 10.081 | 12.957 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.023 | 0.111 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.005 | 0.014 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.001 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.006 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.011 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.004 | 0.019 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.011 | 0.030 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.006 | 0.019 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.030 | 0.103 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.002 | 0.004 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.001 | 0.003 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.001 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.005 | 0.012 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.002 | 0.002 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.002 | 0.003 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.003 | 0.003 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.005 | 0.008 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.032 | 0.174 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.005 | 0.021 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 5.320 | 30.307 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.372 | 1.186 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.444 | 6.222 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.066 | 0.062 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 19.567 | 51.446 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.053 | 0.081 |
| Iterative stress solve to convergence | 9.838 | 12.581 |
| Evaluate material damage and fracture | 0.027 | 0.029 |
| Connectivity, cluster mass and fragment candidates | 0.119 | 0.293 |
| Commit changes and rebuild stress topology | 0.086 | 0.041 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.007 | 0.018 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.006 | 0.012 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.007 | 0.013 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.012 | 0.031 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.170 | 0.174 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.157 | 0.162 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.005 | 0.002 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.215 | 0.300 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.032 | 0.133 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.012 | 0.013 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.027 | 0.078 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.030 | 0.040 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.249 | 0.213 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.005 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.008 | 0.019 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 0.028 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.002 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.114 | 1.067 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.154 | 0.632 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.135 | 0.681 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.231 | 1.169 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.160 | 0.469 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.156 | 0.456 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.014 | 0.037 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.181 | 1.036 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.628 | 2.906 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.022 | 0.098 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.004 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.392 | 2.229 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.055 | 0.287 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.012 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.003 |

Scoped peak: repeat 1, step 674, complete advance 51.446 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 19.567 ms versus untraced repeat means 18.819–19.723 ms; scoped peak 51.446 ms versus untraced peaks 48.505–52.997 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run differs; through the scoped peak differs. Broken bonds: scoped 26488, first untraced 26018. These are separate trajectories, not a decomposition of the same measured peak.

## Separate phase capture: 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.041 | 0.100 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.010 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.152 | 0.157 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 16.304 | 28.374 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.000 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.057 | 0.073 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.019 | 0.085 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.003 | 0.005 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.003 | 0.007 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.010 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.009 | 0.021 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.034 | 0.067 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.010 | 0.017 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.113 | 0.178 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.007 | 0.032 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.002 | 0.007 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.003 | 0.011 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.039 | 0.211 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.010 | 0.038 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.009 | 0.043 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.014 | 0.065 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.026 | 0.116 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.071 | 0.124 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.011 | 0.022 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 80.016 | 219.543 |
| Accept corrected step | GPU commit/status completion and CPU publication | 1.600 | 2.784 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 14.537 | 31.514 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.068 | 0.060 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 113.172 | 283.672 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.179 | 0.291 |
| Iterative stress solve to convergence | 15.622 | 27.311 |
| Evaluate material damage and fracture | 0.068 | 0.069 |
| Connectivity, cluster mass and fragment candidates | 0.422 | 0.737 |
| Commit changes and rebuild stress topology | 0.058 | 0.042 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.048 | 0.171 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.027 | 0.061 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.038 | 0.106 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.084 | 0.236 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.887 | 1.916 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 0.872 | 1.899 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.005 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.397 | 0.648 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.273 | 0.730 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.032 | 0.070 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.272 | 0.942 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.153 | 0.288 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.965 | 0.690 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.004 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.046 | 0.117 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.079 | 0.260 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.004 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 3.265 | 10.672 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 3.239 | 10.307 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 2.580 | 8.422 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 3.692 | 10.720 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 1.227 | 2.757 |
| Wait for GPU broad phase and pair publication | CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work | 1.212 | 2.727 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.110 | 0.372 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 2.480 | 9.331 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 6.197 | 16.382 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.208 | 0.771 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.008 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 5.202 | 15.095 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.476 | 0.800 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.008 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.008 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.007 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |

Scoped peak: repeat 1, step 535, complete advance 283.672 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 113.172 ms versus untraced repeat means 111.479–114.046 ms; scoped peak 283.672 ms versus untraced peaks 301.029–309.156 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run differs; through the scoped peak differs. Broken bonds: scoped 107092, first untraced 107620. These are separate trajectories, not a decomposition of the same measured peak.
