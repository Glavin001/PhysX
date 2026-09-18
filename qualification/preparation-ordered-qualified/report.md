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
| One building, projectile penetration | 1 | 3600 | 0.497 | 3.022 | 3.425 | 4.196 | 6.199 | 0 | 33 | 0.000 | 6.152 | 0.047 |
| One building, projectile penetration | 2 | 3600 | 0.497 | 3.010 | 3.405 | 4.187 | 6.274 | 0 | 33 | 0.000 | 6.215 | 0.059 |
| One building, projectile penetration | 3 | 3600 | 0.525 | 3.016 | 3.418 | 4.215 | 6.649 | 0 | 33 | 0.000 | 6.590 | 0.059 |
| One building, projectile penetration | 4 | 3600 | 0.495 | 3.035 | 3.438 | 4.231 | 6.623 | 0 | 33 | 0.000 | 6.577 | 0.046 |
| One building, projectile penetration | 5 | 3600 | 0.514 | 3.027 | 3.420 | 4.213 | 6.644 | 0 | 33 | 0.000 | 6.593 | 0.051 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
