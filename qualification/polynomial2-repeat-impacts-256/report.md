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
| 256 buildings, simultaneous aerial impacts | 1 | 180 | 1.128 | 17.924 | 36.121 | 58.019 | 60.165 | 99 | 103 | 0.000 | 60.105 | 0.060 |
| 256 buildings, simultaneous aerial impacts | 2 | 180 | 1.130 | 17.896 | 35.940 | 53.642 | 59.945 | 99 | 103 | 0.000 | 59.887 | 0.058 |
| 256 buildings, simultaneous aerial impacts | 3 | 180 | 1.140 | 18.000 | 36.442 | 54.305 | 61.585 | 99 | 103 | 0.000 | 61.482 | 0.102 |
| 256 buildings, simultaneous aerial impacts | 4 | 180 | 1.134 | 17.924 | 35.444 | 57.747 | 59.958 | 99 | 103 | 0.000 | 59.898 | 0.061 |
| 256 buildings, simultaneous aerial impacts | 5 | 180 | 1.123 | 17.854 | 36.098 | 53.087 | 60.697 | 99 | 103 | 0.000 | 60.638 | 0.059 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
