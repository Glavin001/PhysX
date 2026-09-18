# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 1038 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

⚠️ Chaotic workload variation: 256 buildings, simultaneous aerial impacts, repeat 2: per-step counter history differs. Convergence and correction-limit checks passed, but exact trajectories and full physical quality are not qualified.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 256 | 14096 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 1 | 600 | 0.928 | 25.665 | 44.948 | 61.317 | 88.600 | 519 | 82 | 0.000 | 88.535 | 0.064 |
| 256 buildings, simultaneous aerial impacts | 2 | 600 | 0.922 | 26.273 | 45.133 | 60.032 | 87.976 | 519 | 82 | 0.000 | 87.908 | 0.068 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings, simultaneous aerial impacts

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.016 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.123 | 0.147 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 19.109 | 4.868 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.022 | 0.078 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.043 | 5.604 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.003 | 0.024 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.003 | 0.007 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.004 | 0.029 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.006 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.016 | 0.098 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.007 | 0.092 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.007 | 0.077 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.066 | 0.176 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.687 | 41.779 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.154 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.010 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.782 | 34.252 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.105 | 0.425 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.816 | 4.303 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.171 | 0.053 |
| Iterative stress solve to convergence | 18.717 | 4.363 |
| Evaluate material damage and fracture | 0.065 | 0.075 |
| Connectivity, cluster mass and fragment candidates | 0.209 | 0.461 |
| Commit changes and rebuild stress topology | 0.044 | 0.038 |

Scoped peak: repeat 1, step 82, complete advance 92.418 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Scoped versus first untraced counter history: complete run matches; through the scoped peak matches. Broken bonds: scoped 62582, first untraced 62582. These are separate trajectories, not a decomposition of the same measured peak.
