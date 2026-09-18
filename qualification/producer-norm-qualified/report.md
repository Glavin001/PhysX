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
| One building, projectile penetration | 1 | 3600 | 0.517 | 2.828 | 3.185 | 3.878 | 6.201 | 0 | 0 | 1.409 | 4.731 | 0.061 |
| One building, projectile penetration | 2 | 3600 | 0.542 | 2.808 | 3.165 | 3.904 | 5.895 | 0 | 32 | 0.000 | 5.845 | 0.051 |
| One building, projectile penetration | 3 | 3600 | 0.540 | 2.810 | 3.171 | 3.871 | 6.084 | 0 | 33 | 0.000 | 6.024 | 0.060 |
| One building, projectile penetration | 4 | 3600 | 0.524 | 2.813 | 3.180 | 3.919 | 6.131 | 0 | 0 | 1.415 | 4.659 | 0.056 |
| One building, projectile penetration | 5 | 3600 | 0.519 | 2.825 | 3.191 | 3.927 | 5.992 | 0 | 33 | 0.000 | 5.934 | 0.059 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
