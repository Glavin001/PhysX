# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 891 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 64 buildings, simultaneous aerial impacts | 28416 | 57344 | 64 | 3211 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 64 buildings, simultaneous aerial impacts | 1 | 600 | 0.587 | 8.985 | 15.178 | 17.142 | 25.177 | 445 | 82 | 0.000 | 25.115 | 0.063 |
| 64 buildings, simultaneous aerial impacts | 2 | 600 | 0.589 | 9.068 | 15.369 | 19.048 | 26.120 | 446 | 82 | 0.000 | 26.070 | 0.050 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 64 buildings, simultaneous aerial impacts

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.112 | 0.140 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 6.648 | 3.275 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.007 | 0.096 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.006 | 1.285 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.001 | 0.021 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.001 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.025 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.007 | 0.079 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.004 | 0.068 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.004 | 0.071 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.017 | 0.070 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.122 | 9.019 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.003 | 0.054 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.001 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.450 | 8.502 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.028 | 0.199 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.610 | 1.816 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.050 | 0.053 |
| Iterative stress solve to convergence | 6.551 | 3.077 |
| Evaluate material damage and fracture | 0.026 | 0.027 |
| Connectivity, cluster mass and fragment candidates | 0.074 | 0.210 |
| Commit changes and rebuild stress topology | 0.037 | 0.031 |

Scoped peak: repeat 1, step 82, complete advance 25.010 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 14711, first untraced 14711. These are separate trajectories, not a decomposition of the same measured peak.
