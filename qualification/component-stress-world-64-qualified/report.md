# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

✅ Measured deadlines passed: 0 steps exceeded 8.0 ms. Five × 60-second duration requirement met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 64 buildings, one unchanged wall impact | 28416 | 57344 | 1 | 106 | 60 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 64 buildings, one unchanged wall impact | 1 | 3600 | 0.596 | 3.016 | 3.397 | 4.191 | 6.703 | 0 | 33 | 0.000 | 6.649 | 0.053 |
| 64 buildings, one unchanged wall impact | 2 | 3600 | 0.616 | 3.018 | 3.393 | 4.294 | 6.946 | 0 | 35 | 0.000 | 5.269 | 1.676 |
| 64 buildings, one unchanged wall impact | 3 | 3600 | 0.595 | 3.096 | 3.501 | 4.287 | 7.122 | 0 | 33 | 0.000 | 7.065 | 0.056 |
| 64 buildings, one unchanged wall impact | 4 | 3600 | 0.593 | 3.008 | 3.384 | 4.213 | 6.894 | 0 | 33 | 0.000 | 6.830 | 0.065 |
| 64 buildings, one unchanged wall impact | 5 | 3600 | 0.581 | 3.049 | 3.433 | 4.252 | 6.637 | 0 | 33 | 0.000 | 6.588 | 0.048 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 64 buildings, one unchanged wall impact

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.008 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.110 | 0.117 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 2.072 | 3.680 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.030 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.011 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.007 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.007 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.006 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.036 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.016 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.013 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.092 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.000 | 0.200 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.013 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.001 | 1.322 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.000 | 0.182 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.951 | 1.213 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.031 | 0.034 |
| Iterative stress solve to convergence | 2.047 | 3.476 |
| Evaluate material damage and fracture | 0.025 | 0.028 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.194 |
| Commit changes and rebuild stress topology | 0.032 | 0.031 |

Scoped peak: repeat 1, step 33, complete advance 7.157 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 199, first untraced 199. These are separate trajectories, not a decomposition of the same measured peak.
