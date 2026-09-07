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
| 256 buildings, simultaneous aerial impacts | 1 | 180 | 1.136 | 18.596 | 36.915 | 56.548 | 63.372 | 99 | 103 | 0.000 | 63.318 | 0.055 |
| 256 buildings, simultaneous aerial impacts | 2 | 180 | 1.139 | 18.554 | 38.377 | 55.795 | 62.515 | 99 | 103 | 0.000 | 62.457 | 0.057 |
| 256 buildings, simultaneous aerial impacts | 3 | 180 | 1.136 | 18.764 | 37.407 | 56.281 | 61.904 | 99 | 103 | 0.000 | 61.849 | 0.055 |
| 256 buildings, simultaneous aerial impacts | 4 | 180 | 1.155 | 18.539 | 37.302 | 61.170 | 61.667 | 99 | 103 | 0.000 | 61.612 | 0.055 |
| 256 buildings, simultaneous aerial impacts | 5 | 180 | 1.129 | 18.613 | 37.472 | 56.778 | 62.821 | 99 | 103 | 0.000 | 62.768 | 0.053 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
