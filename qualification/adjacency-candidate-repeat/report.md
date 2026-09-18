# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 495 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 256 | 12469 | 3 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 1 | 180 | 1.140 | 18.464 | 37.702 | 56.516 | 62.608 | 99 | 103 | 0.000 | 62.549 | 0.059 |
| 256 buildings, simultaneous aerial impacts | 2 | 180 | 1.133 | 18.494 | 37.162 | 54.071 | 61.600 | 99 | 103 | 0.000 | 61.525 | 0.075 |
| 256 buildings, simultaneous aerial impacts | 3 | 180 | 1.141 | 18.492 | 36.934 | 54.378 | 64.557 | 99 | 103 | 0.000 | 64.494 | 0.063 |
| 256 buildings, simultaneous aerial impacts | 4 | 180 | 1.138 | 18.432 | 36.838 | 56.352 | 62.528 | 99 | 103 | 0.000 | 62.461 | 0.067 |
| 256 buildings, simultaneous aerial impacts | 5 | 180 | 1.141 | 18.533 | 36.539 | 55.826 | 61.435 | 99 | 103 | 0.000 | 61.373 | 0.062 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
