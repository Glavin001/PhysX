# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

✅ Measured deadlines passed: 0 steps exceeded 8.0 ms. Five × 60-second duration requirement met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 444 | 896 | 1 | 43 | 60 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 3600 | 0.529 | 3.023 | 3.416 | 4.200 | 6.483 | 0 | 1670 | 0.000 | 6.442 | 0.041 |
| One building, projectile penetration | 2 | 3600 | 0.532 | 3.028 | 3.423 | 4.184 | 6.576 | 0 | 33 | 0.000 | 6.521 | 0.055 |
| One building, projectile penetration | 3 | 3600 | 0.517 | 3.028 | 3.427 | 4.202 | 6.366 | 0 | 33 | 0.000 | 6.308 | 0.058 |
| One building, projectile penetration | 4 | 3600 | 0.569 | 3.026 | 3.424 | 4.259 | 6.762 | 0 | 33 | 0.000 | 6.685 | 0.077 |
| One building, projectile penetration | 5 | 3600 | 0.506 | 3.025 | 3.436 | 4.177 | 6.355 | 0 | 33 | 0.000 | 6.304 | 0.051 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
