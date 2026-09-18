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
| One building, projectile penetration | 1 | 3600 | 0.490 | 3.035 | 3.432 | 4.177 | 6.578 | 0 | 33 | 0.000 | 6.517 | 0.061 |
| One building, projectile penetration | 2 | 3600 | 0.532 | 3.028 | 3.431 | 4.162 | 6.299 | 0 | 33 | 0.000 | 6.254 | 0.046 |
| One building, projectile penetration | 3 | 3600 | 0.531 | 3.039 | 3.450 | 4.224 | 7.556 | 0 | 33 | 0.000 | 7.475 | 0.080 |
| One building, projectile penetration | 4 | 3600 | 0.506 | 3.025 | 3.421 | 4.172 | 6.409 | 0 | 33 | 0.000 | 6.358 | 0.051 |
| One building, projectile penetration | 5 | 3600 | 0.504 | 3.019 | 3.413 | 4.164 | 6.317 | 0 | 33 | 0.000 | 6.281 | 0.036 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
