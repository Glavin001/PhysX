# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 93 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings, one unchanged wall impact | 113664 | 229376 | 1 | 298 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, one unchanged wall impact | 1 | 600 | 0.960 | 6.107 | 8.334 | 10.509 | 14.538 | 45 | 33 | 0.000 | 14.481 | 0.058 |
| 256 buildings, one unchanged wall impact | 2 | 600 | 0.906 | 6.113 | 8.309 | 10.606 | 14.647 | 48 | 33 | 0.000 | 14.585 | 0.062 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings, one unchanged wall impact

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.108 | 0.113 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 4.826 | 10.022 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.043 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.005 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.006 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.007 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.006 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.045 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.015 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.013 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.002 | 0.195 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.002 | 0.235 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.016 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.012 | 2.197 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.262 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.167 | 1.498 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.056 | 0.059 |
| Iterative stress solve to convergence | 4.718 | 9.636 |
| Evaluate material damage and fracture | 0.067 | 0.069 |
| Connectivity, cluster mass and fragment candidates | 0.033 | 0.310 |
| Commit changes and rebuild stress topology | 0.038 | 0.037 |

Scoped peak: repeat 1, step 33, complete advance 14.922 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 199, first untraced 199. These are separate trajectories, not a decomposition of the same measured peak.
