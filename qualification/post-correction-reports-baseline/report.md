# 🎯 Complete PhysX destruction advance — 8 ms gate

60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.

❌ Deadline failed: 1278 steps exceeded 8.0 ms. Diagnostic only: five × 60-second qualification duration not met.

This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.

⚠️ Chaotic workload variation: 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles, repeat 2: per-step counter history differs. Convergence and correction-limit checks passed, but exact trajectories and full physical quality are not qualified.

| Scene | Chunks | Bonds | Projectiles | Peak destruction clusters | Seconds per run | Correction limit | Sleeping |
|---|---|---|---|---|---|---|---|
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 113664 | 229376 | 767 | 31570 | 12 | 1 | Enabled |

Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.

| Scene | Repeat | Steps | Min ms | Mean ms | p95 ms | p99 ms | Peak ms | Misses | Peak step | Commands at peak ms | Physics/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 1 | 720 | 2.714 | 171.583 | 313.374 | 334.327 | 355.506 | 639 | 642 | 0.106 | 355.315 | 0.085 |
| 256 buildings / 113664 chunks / 229376 bonds / 768 aerial projectiles | 2 | 720 | 2.741 | 178.964 | 319.591 | 332.642 | 341.509 | 639 | 531 | 0.099 | 341.359 | 0.051 |

Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.
