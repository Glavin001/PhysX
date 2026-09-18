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
| 256 buildings, simultaneous aerial impacts | 1 | 180 | 1.139 | 17.324 | 34.921 | 54.599 | 59.050 | 99 | 103 | 0.000 | 58.991 | 0.059 |
| 256 buildings, simultaneous aerial impacts | 2 | 180 | 1.151 | 17.498 | 35.444 | 60.278 | 62.059 | 99 | 82 | 0.000 | 61.990 | 0.069 |
| 256 buildings, simultaneous aerial impacts | 3 | 180 | 1.150 | 17.468 | 35.687 | 52.675 | 62.260 | 99 | 103 | 0.000 | 62.194 | 0.066 |
| 256 buildings, simultaneous aerial impacts | 4 | 180 | 1.117 | 17.428 | 35.397 | 53.007 | 60.407 | 99 | 103 | 0.000 | 60.345 | 0.062 |
| 256 buildings, simultaneous aerial impacts | 5 | 180 | 1.113 | 17.178 | 34.939 | 52.835 | 60.445 | 99 | 103 | 0.000 | 60.383 | 0.063 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
