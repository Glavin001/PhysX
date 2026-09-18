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
| One building, projectile penetration | 1 | 3600 | 0.497 | 2.887 | 3.268 | 3.998 | 6.119 | 0 | 123 | 0.000 | 6.070 | 0.049 |
| One building, projectile penetration | 2 | 3600 | 0.522 | 2.897 | 3.277 | 3.950 | 6.348 | 0 | 33 | 0.000 | 6.290 | 0.058 |
| One building, projectile penetration | 3 | 3600 | 0.505 | 2.898 | 3.271 | 4.043 | 5.983 | 0 | 33 | 0.000 | 5.941 | 0.042 |
| One building, projectile penetration | 4 | 3600 | 0.532 | 2.902 | 3.278 | 4.013 | 7.041 | 0 | 32 | 0.000 | 6.975 | 0.066 |
| One building, projectile penetration | 5 | 3600 | 0.508 | 2.893 | 3.267 | 3.977 | 6.162 | 0 | 33 | 0.000 | 6.099 | 0.062 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
