# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 1038 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

⚠️ Chaotic workload variation: 256 buildings, simultaneous aerial impacts, repeat 2: per-step counter history differs. Convergence and correction-limit checks passed, but exact trajectories and full physical quality are not qualified.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 256 | 14070 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 1 | 600 | 0.918 | 24.527 | 38.446 | 62.314 | 91.629 | 519 | 82 | 0.000 | 91.568 | 0.060 |
| 256 buildings, simultaneous aerial impacts | 2 | 600 | 0.931 | 24.649 | 38.432 | 64.728 | 95.908 | 519 | 82 | 0.000 | 95.854 | 0.054 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.

## Separate phase capture: 256 buildings, simultaneous aerial impacts

This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.

| Operation | Owner / responsibility | Mean elapsed ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.011 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.121 | 0.143 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 17.995 | 9.432 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.024 | 0.071 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.042 | 5.626 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.003 | 0.022 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.003 | 0.007 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.004 | 0.053 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.017 | 0.094 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.008 | 0.078 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.007 | 0.068 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.066 | 0.171 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.686 | 46.083 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.178 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.011 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.777 | 34.988 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.086 | 0.339 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.795 | 3.794 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.171 | 0.053 |
| Iterative stress solve to convergence | 17.604 | 8.959 |
| Evaluate material damage and fracture | 0.065 | 0.072 |
| Connectivity, cluster mass and fragment candidates | 0.209 | 0.433 |
| Commit changes and rebuild stress topology | 0.042 | 0.038 |

Scoped peak: repeat 1, step 82, complete advance 101.434 ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.

Scoped versus first untraced counter history: complete run differs; through the scoped peak matches. Broken bonds: scoped 62582, first untraced 62476. These are separate trajectories, not a decomposition of the same measured peak.
