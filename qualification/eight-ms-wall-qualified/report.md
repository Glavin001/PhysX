# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

✅ Measured deadlines passed: 0 steps exceeded 8.0 ms. Five × 60-second duration requirement met.

This timing gate checks convergence, correction limit, frozen wall counters and repeat topology signatures. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 3600 | 0.489 | 3.047 | 3.447 | 4.244 | 6.530 | 0 | 33 | 0.000 | 6.493 | 0.037 |
| One building, projectile penetration | 2 | 3600 | 0.497 | 3.043 | 3.444 | 4.221 | 6.606 | 0 | 33 | 0.000 | 6.541 | 0.065 |
| One building, projectile penetration | 3 | 3600 | 0.495 | 3.042 | 3.449 | 4.191 | 6.729 | 0 | 33 | 0.000 | 6.665 | 0.065 |
| One building, projectile penetration | 4 | 3600 | 0.502 | 3.043 | 3.445 | 4.179 | 6.724 | 0 | 33 | 0.000 | 6.673 | 0.051 |
| One building, projectile penetration | 5 | 3600 | 0.521 | 3.046 | 3.446 | 4.211 | 6.226 | 0 | 33 | 0.000 | 6.178 | 0.048 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
