# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

✅ Measured deadlines passed: 0 steps exceeded 8.0 ms. Five × 60-second duration requirement met.

This timing gate checks convergence, correction limit, frozen wall counters and repeat topology signatures. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 3600 | 0.504 | 3.037 | 3.432 | 4.232 | 6.571 | 0 | 33 | 0.000 | 6.517 | 0.055 |
| One building, projectile penetration | 2 | 3600 | 0.517 | 3.046 | 3.453 | 4.204 | 6.556 | 0 | 33 | 0.000 | 6.510 | 0.046 |
| One building, projectile penetration | 3 | 3600 | 0.511 | 3.036 | 3.443 | 4.211 | 6.526 | 0 | 33 | 0.000 | 6.476 | 0.050 |
| One building, projectile penetration | 4 | 3600 | 0.529 | 3.038 | 3.437 | 4.231 | 6.332 | 0 | 33 | 0.000 | 6.278 | 0.054 |
| One building, projectile penetration | 5 | 3600 | 0.521 | 3.028 | 3.427 | 4.218 | 6.211 | 0 | 33 | 0.000 | 6.163 | 0.048 |
| One intact building, no projectile | 1 | 3600 | 0.242 | 0.299 | 0.332 | 0.356 | 4.070 | 0 | 0 | 0.002 | 3.994 | 0.074 |
| One intact building, no projectile | 2 | 3600 | 0.244 | 0.302 | 0.338 | 0.361 | 4.076 | 0 | 0 | 0.002 | 3.994 | 0.079 |
| One intact building, no projectile | 3 | 3600 | 0.244 | 0.296 | 0.330 | 0.349 | 3.994 | 0 | 0 | 0.002 | 3.910 | 0.083 |
| One intact building, no projectile | 4 | 3600 | 0.248 | 0.297 | 0.326 | 0.355 | 4.077 | 0 | 0 | 0.002 | 3.995 | 0.079 |
| One intact building, no projectile | 5 | 3600 | 0.252 | 0.292 | 0.321 | 0.342 | 4.059 | 0 | 0 | 0.002 | 3.978 | 0.080 |
| 16 intact buildings, no projectiles | 1 | 3600 | 0.250 | 0.308 | 0.347 | 0.372 | 4.429 | 0 | 0 | 0.002 | 4.348 | 0.079 |
| 16 intact buildings, no projectiles | 2 | 3600 | 0.251 | 0.310 | 0.347 | 0.370 | 4.455 | 0 | 0 | 0.001 | 4.372 | 0.082 |
| 16 intact buildings, no projectiles | 3 | 3600 | 0.253 | 0.306 | 0.348 | 0.371 | 4.063 | 0 | 2720 | 0.000 | 4.023 | 0.039 |
| 16 intact buildings, no projectiles | 4 | 3600 | 0.248 | 0.305 | 0.346 | 0.367 | 2.209 | 0 | 0 | 0.002 | 2.122 | 0.085 |
| 16 intact buildings, no projectiles | 5 | 3600 | 0.251 | 0.300 | 0.331 | 0.356 | 4.520 | 0 | 0 | 0.002 | 4.440 | 0.079 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
