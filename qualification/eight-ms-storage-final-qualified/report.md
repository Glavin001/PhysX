# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

✅ Measured deadlines passed: 0 steps exceeded 8.0 ms. Five × 60-second duration requirement met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 444 | 896 | 1 | 43 | 60 | 1 | Disabled |
| One intact building, no projectile | 444 | 896 | 0 | 1 | 60 | 1 | Disabled |
| 16 intact buildings, no projectiles | 7104 | 14336 | 0 | 16 | 60 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 3600 | 0.503 | 3.027 | 3.425 | 4.229 | 6.393 | 0 | 33 | 0.000 | 6.354 | 0.038 |
| One building, projectile penetration | 2 | 3600 | 0.510 | 3.013 | 3.409 | 4.159 | 6.440 | 0 | 33 | 0.000 | 6.389 | 0.051 |
| One building, projectile penetration | 3 | 3600 | 0.509 | 3.027 | 3.444 | 4.224 | 6.551 | 0 | 33 | 0.000 | 6.505 | 0.047 |
| One building, projectile penetration | 4 | 3600 | 0.511 | 3.022 | 3.416 | 4.204 | 6.512 | 0 | 33 | 0.000 | 6.453 | 0.059 |
| One building, projectile penetration | 5 | 3600 | 0.496 | 3.027 | 3.431 | 4.251 | 7.037 | 0 | 1382 | 0.000 | 3.422 | 3.616 |
| One intact building, no projectile | 1 | 3600 | 0.247 | 0.299 | 0.340 | 0.363 | 4.216 | 0 | 0 | 0.002 | 4.135 | 0.080 |
| One intact building, no projectile | 2 | 3600 | 0.245 | 0.295 | 0.328 | 0.358 | 2.328 | 0 | 3291 | 0.000 | 2.285 | 0.043 |
| One intact building, no projectile | 3 | 3600 | 0.249 | 0.296 | 0.339 | 0.365 | 1.720 | 0 | 0 | 0.002 | 1.649 | 0.069 |
| One intact building, no projectile | 4 | 3600 | 0.242 | 0.296 | 0.335 | 0.361 | 2.925 | 0 | 1459 | 0.000 | 2.878 | 0.047 |
| One intact building, no projectile | 5 | 3600 | 0.246 | 0.297 | 0.332 | 0.354 | 1.954 | 0 | 2672 | 0.000 | 0.245 | 1.709 |
| 16 intact buildings, no projectiles | 1 | 3600 | 0.254 | 0.302 | 0.337 | 0.360 | 4.649 | 0 | 0 | 0.002 | 4.563 | 0.084 |
| 16 intact buildings, no projectiles | 2 | 3600 | 0.259 | 0.311 | 0.351 | 0.383 | 4.343 | 0 | 0 | 0.001 | 4.260 | 0.081 |
| 16 intact buildings, no projectiles | 3 | 3600 | 0.256 | 0.308 | 0.352 | 0.382 | 4.422 | 0 | 0 | 0.002 | 4.344 | 0.076 |
| 16 intact buildings, no projectiles | 4 | 3600 | 0.255 | 0.305 | 0.343 | 0.365 | 4.560 | 0 | 0 | 0.002 | 4.479 | 0.078 |
| 16 intact buildings, no projectiles | 5 | 3600 | 0.253 | 0.301 | 0.335 | 0.364 | 3.317 | 0 | 834 | 0.000 | 3.265 | 0.052 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
