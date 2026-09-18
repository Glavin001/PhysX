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
| One building, projectile penetration | 1 | 3600 | 0.538 | 3.021 | 3.418 | 4.186 | 6.553 | 0 | 33 | 0.000 | 6.490 | 0.063 |
| One building, projectile penetration | 2 | 3600 | 0.505 | 3.027 | 3.434 | 4.234 | 6.261 | 0 | 33 | 0.000 | 6.210 | 0.051 |
| One building, projectile penetration | 3 | 3600 | 0.529 | 3.031 | 3.438 | 4.213 | 6.508 | 0 | 33 | 0.000 | 6.463 | 0.045 |
| One building, projectile penetration | 4 | 3600 | 0.528 | 3.040 | 3.447 | 4.248 | 6.710 | 0 | 32 | 0.000 | 6.648 | 0.062 |
| One building, projectile penetration | 5 | 3600 | 0.536 | 3.032 | 3.439 | 4.199 | 6.361 | 0 | 33 | 0.000 | 6.306 | 0.055 |
| One intact building, no projectile | 1 | 3600 | 0.246 | 0.292 | 0.319 | 0.342 | 4.270 | 0 | 0 | 0.002 | 4.191 | 0.078 |
| One intact building, no projectile | 2 | 3600 | 0.251 | 0.302 | 0.340 | 0.360 | 1.766 | 0 | 0 | 0.002 | 1.668 | 0.095 |
| One intact building, no projectile | 3 | 3600 | 0.247 | 0.299 | 0.336 | 0.364 | 4.146 | 0 | 0 | 0.002 | 4.071 | 0.073 |
| One intact building, no projectile | 4 | 3600 | 0.242 | 0.297 | 0.329 | 0.349 | 2.947 | 0 | 2692 | 0.000 | 2.901 | 0.046 |
| One intact building, no projectile | 5 | 3600 | 0.249 | 0.301 | 0.333 | 0.356 | 4.286 | 0 | 0 | 0.001 | 4.211 | 0.073 |
| 16 intact buildings, no projectiles | 1 | 3600 | 0.255 | 0.301 | 0.331 | 0.349 | 4.399 | 0 | 0 | 0.002 | 4.326 | 0.072 |
| 16 intact buildings, no projectiles | 2 | 3600 | 0.257 | 0.304 | 0.340 | 0.367 | 4.653 | 0 | 0 | 0.002 | 4.573 | 0.078 |
| 16 intact buildings, no projectiles | 3 | 3600 | 0.250 | 0.309 | 0.349 | 0.367 | 4.543 | 0 | 0 | 0.002 | 4.458 | 0.082 |
| 16 intact buildings, no projectiles | 4 | 3600 | 0.258 | 0.308 | 0.349 | 0.373 | 4.529 | 0 | 0 | 0.002 | 4.449 | 0.079 |
| 16 intact buildings, no projectiles | 5 | 3600 | 0.257 | 0.305 | 0.338 | 0.360 | 4.606 | 0 | 0 | 0.002 | 4.524 | 0.081 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
