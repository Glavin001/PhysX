# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

✅ Measured deadlines passed: 0 steps exceeded 8.0 ms. Five × 60-second duration requirement met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 444 | 896 | 1 | 43 | 60 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 3600 | 0.498 | 2.919 | 3.294 | 3.996 | 6.756 | 0 | 45 | 0.000 | 6.704 | 0.052 |
| One building, projectile penetration | 2 | 3600 | 0.496 | 2.916 | 3.285 | 3.999 | 6.177 | 0 | 32 | 0.000 | 6.112 | 0.064 |
| One building, projectile penetration | 3 | 3600 | 0.514 | 2.924 | 3.306 | 4.076 | 6.485 | 0 | 33 | 0.000 | 6.431 | 0.053 |
| One building, projectile penetration | 4 | 3600 | 0.533 | 2.916 | 3.299 | 4.066 | 6.348 | 0 | 483 | 0.000 | 6.304 | 0.044 |
| One building, projectile penetration | 5 | 3600 | 0.527 | 2.913 | 3.288 | 4.049 | 7.881 | 0 | 32 | 0.000 | 7.824 | 0.056 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
