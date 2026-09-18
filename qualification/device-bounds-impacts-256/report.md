# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 7038 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 256 | 14128 | 60 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 1 | 3600 | 0.920 | 20.983 | 32.014 | 38.351 | 90.513 | 3519 | 82 | 0.000 | 90.459 | 0.054 |
| 256 buildings, simultaneous aerial impacts | 2 | 3600 | 0.942 | 20.952 | 32.150 | 38.048 | 100.029 | 3519 | 82 | 0.000 | 99.945 | 0.084 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings, simultaneous aerial impacts

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.116 | 0.165 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 16.771 | 9.406 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.004 | 0.092 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.008 | 6.691 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.001 | 0.046 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.009 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.064 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.004 | 0.143 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.002 | 0.091 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.083 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.013 | 0.181 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.117 | 40.879 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.001 | 0.166 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.001 | 0.011 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.308 | 29.227 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.015 | 0.307 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.548 | 3.637 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.204 | 0.057 |
| Iterative stress solve to convergence | 16.487 | 8.951 |
| Evaluate material damage and fracture | 0.064 | 0.073 |
| Connectivity, cluster mass and fragment candidates | 0.066 | 0.433 |
| Commit changes and rebuild stress topology | 0.041 | 0.038 |

Scoped peak: repeat 1, step 82, complete advance 91.468 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 62640, first untraced 62640. These are separate trajectories, not a decomposition of the same measured peak.
