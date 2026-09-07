# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 173 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 16 buildings, simultaneous aerial impacts | 7104 | 14336 | 16 | 847 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 16 buildings, simultaneous aerial impacts | 1 | 600 | 0.534 | 5.899 | 9.128 | 11.085 | 12.912 | 87 | 102 | 0.000 | 12.857 | 0.055 |
| 16 buildings, simultaneous aerial impacts | 2 | 600 | 0.517 | 5.919 | 9.322 | 11.010 | 13.090 | 86 | 102 | 0.000 | 13.035 | 0.055 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
