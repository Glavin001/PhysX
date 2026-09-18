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
| One building, projectile penetration | 1 | 3600 | 0.525 | 3.024 | 3.414 | 4.168 | 6.506 | 0 | 33 | 0.000 | 6.452 | 0.054 |
| One building, projectile penetration | 2 | 3600 | 0.527 | 3.033 | 3.432 | 4.191 | 6.460 | 0 | 33 | 0.000 | 6.409 | 0.052 |
| One building, projectile penetration | 3 | 3600 | 0.523 | 3.031 | 3.446 | 4.149 | 6.831 | 0 | 1743 | 0.000 | 6.781 | 0.050 |
| One building, projectile penetration | 4 | 3600 | 0.523 | 3.028 | 3.425 | 4.198 | 6.335 | 0 | 33 | 0.000 | 6.285 | 0.050 |
| One building, projectile penetration | 5 | 3600 | 0.503 | 3.025 | 3.433 | 4.249 | 6.137 | 0 | 33 | 0.000 | 6.088 | 0.049 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
