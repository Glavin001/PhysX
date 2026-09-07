# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 1 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 4 buildings, one unchanged wall impact | 1776 | 3584 | 1 | 46 | 10 | 1 | Disabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 4 buildings, one unchanged wall impact | 1 | 600 | 0.513 | 4.119 | 5.556 | 6.882 | 8.055 | 1 | 33 | 0.000 | 7.986 | 0.069 |
| 4 buildings, one unchanged wall impact | 2 | 600 | 0.512 | 4.120 | 5.569 | 6.839 | 7.835 | 0 | 33 | 0.000 | 7.772 | 0.062 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
