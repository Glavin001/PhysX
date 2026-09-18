# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

✅ Measured deadlines passed: 0 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 444 | 896 | 1 | 43 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 600 | 0.528 | 2.230 | 3.320 | 4.093 | 6.163 | 0 | 0 | 1.389 | 4.717 | 0.057 |
| One building, projectile penetration | 2 | 600 | 0.536 | 2.235 | 3.329 | 3.994 | 5.895 | 0 | 33 | 0.000 | 5.839 | 0.055 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: One building, projectile penetration

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.002 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.112 | 0.127 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 1.318 | 2.843 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.032 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.005 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.007 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.006 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.053 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.022 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.015 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.064 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.002 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.001 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.000 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.000 | 0.004 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.001 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.000 |
| Rebind CPU query and actor-shape records | CPU query removal/insertion and compatibility shape-array updates | 0.000 | 0.005 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.000 | 0.004 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.000 | 0.067 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.013 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.008 | 1.546 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.121 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.802 | 1.299 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.050 | 0.049 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 2.310 | 6.310 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.022 | 0.022 |
| Iterative stress solve to convergence | 1.311 | 2.754 |
| Evaluate material damage and fracture | 0.018 | 0.018 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.119 |
| Commit changes and rebuild stress topology | 0.031 | 0.030 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.021 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.007 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.013 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.012 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.051 | 0.059 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.003 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.112 | 0.181 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.015 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.007 | 0.016 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.013 | 0.015 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.056 | 0.112 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.003 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.003 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.004 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.003 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.002 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.006 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.002 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.109 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.009 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.116 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.005 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.005 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.038 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.145 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.004 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.003 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.003 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |

Scoped peak: repeat 1, step 33, complete advance 6.310 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 2.310 ms versus untraced repeat means 2.230–2.235 ms; scoped peak 6.310 ms versus untraced peaks 5.895–6.163 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 199, first untraced 199. These are separate trajectories, not a decomposition of the same measured peak.
