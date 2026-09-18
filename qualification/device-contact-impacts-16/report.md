# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 10 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 16 buildings, simultaneous aerial impacts | 7104 | 14336 | 16 | 865 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 16 buildings, simultaneous aerial impacts | 1 | 600 | 0.504 | 4.096 | 6.830 | 7.983 | 9.330 | 6 | 257 | 0.000 | 9.284 | 0.046 |
| 16 buildings, simultaneous aerial impacts | 2 | 600 | 0.520 | 4.099 | 6.918 | 7.593 | 8.761 | 4 | 103 | 0.000 | 8.710 | 0.052 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 16 buildings, simultaneous aerial impacts

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Apply recorded commands | CPU submission and GPU command execution | 0.003 | 0.000 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.026 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.107 | 0.111 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 2.703 | 4.040 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.003 | 0.031 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.002 | 0.070 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.001 | 0.007 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.007 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.003 | 0.042 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.003 | 0.020 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.013 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.006 | 0.071 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.012 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.004 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.003 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.001 | 0.050 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.009 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.012 |
| Rebind CPU query and actor-shape records | CPU query removal/insertion and compatibility shape-array updates | 0.002 | 0.112 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.002 | 0.109 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.005 | 0.071 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.001 | 0.014 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.001 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.116 | 2.682 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.012 | 0.154 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.154 | 1.596 |
| Mandatory completion and status | CPU completion boundary and compact GPU status observation | 0.048 | 0.056 |
| TOTAL complete advance | Commands through accepted state and mandatory status | 4.188 | 9.339 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.024 | 0.026 |
| Iterative stress solve to convergence | 2.674 | 3.881 |
| Evaluate material damage and fracture | 0.018 | 0.019 |
| Connectivity, cluster mass and fragment candidates | 0.040 | 0.169 |
| Commit changes and rebuild stress topology | 0.033 | 0.031 |

## Trial physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.004 | 0.016 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.010 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.002 | 0.025 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.003 | 0.024 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.073 | 0.070 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.004 | 0.004 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.130 | 0.181 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.004 | 0.020 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.008 | 0.015 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.001 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.002 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.017 | 0.030 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.057 | 0.068 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.004 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.025 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.003 | 0.038 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.001 |

## Correction physics tasks — overlapping diagnostic spans

These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.

| Task | Owner / responsibility | All-step mean ms | At scoped peak ms |
|---|---|---|---|
| Allocate contact-manager storage | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.026 |
| Register contact managers | CPU contact/interaction lifecycle bookkeeping | 0.000 | 0.007 |
| Register body/shape interactions | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.046 |
| Register scene interactions | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.051 |
| Complete broad phase and callbacks | CPU task; elapsed includes any GPU submission/dependency waits | 0.015 | 0.198 |
| Broad-phase completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.021 |
| Broad-phase completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Complete narrow phase | CPU task; elapsed includes any GPU submission/dependency waits | 0.010 | 0.201 |
| Insert contact dependencies into islands | CPU contact/interaction lifecycle bookkeeping | 0.001 | 0.051 |
| Generate simulation islands | CPU task; elapsed includes any GPU submission/dependency waits | 0.001 | 0.011 |
| Finish island scheduling | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |
| Prepare dynamics tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Submit dynamics/constraint solve | CPU task; elapsed includes any GPU submission/dependency waits | 0.002 | 0.152 |
| Finish constraint partitioning | CPU task; elapsed includes any GPU submission/dependency waits | 0.006 | 0.471 |
| Dispatch lost contacts | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.005 |
| Lost-contact completion stage 2 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Lost-contact completion stage 3 | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.001 |
| Finish motion integration and solver tasks | CPU task; elapsed includes any GPU submission/dependency waits | 0.000 | 0.002 |

Scoped peak: repeat 1, step 103, complete advance 9.339 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Observer comparison: scoped mean 4.188 ms versus untraced repeat means 4.096–4.099 ms; scoped peak 9.339 ms versus untraced peaks 8.761–9.330 ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 3996, first untraced 3996. These are separate trajectories, not a decomposition of the same measured peak.
