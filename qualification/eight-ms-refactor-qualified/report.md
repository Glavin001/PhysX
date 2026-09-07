# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

✅ Measured deadlines passed: 0 steps exceeded 8.0 ms. Five × 60-second duration requirement met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 3600 | 0.527 | 3.041 | 3.449 | 4.245 | 6.735 | 0 | 33 | 0.000 | 6.659 | 0.076 |
| One building, projectile penetration | 2 | 3600 | 0.550 | 3.042 | 3.445 | 4.220 | 7.850 | 0 | 33 | 0.000 | 7.795 | 0.055 |
| One building, projectile penetration | 3 | 3600 | 0.489 | 3.026 | 3.426 | 4.220 | 6.498 | 0 | 33 | 0.000 | 6.442 | 0.055 |
| One building, projectile penetration | 4 | 3600 | 0.508 | 3.028 | 3.436 | 4.283 | 7.219 | 0 | 37 | 0.000 | 7.166 | 0.053 |
| One building, projectile penetration | 5 | 3600 | 0.509 | 3.038 | 3.458 | 4.247 | 6.488 | 0 | 33 | 0.000 | 6.434 | 0.054 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
