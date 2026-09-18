# 🏙️ Integrated PhysX GPU destruction — scaling measurements

All measured advances include recorded commands, projectile insertion, ordinary physics, CUDA stress/material/topology work, up to one correction and mandatory completion. Timestep is 1/60 second. Rendering, video encoding, asset preparation and initial CUDA setup are excluded; initialization is reported separately. Every measured step is retained.

These are diagnostic scaling runs, not the five × 60-second deadline or ten-minute endurance qualification. A mean below a deadline does not pass the peak requirement. Sleeping is disabled in these fixtures.

| Scenario | Buildings | Chunks | Bonds | Projectiles | Launch | Runs × seconds | Peak clusters |
|---|---|---|---|---|---|---|---|
| 4 buildings, one unchanged wall impact | 4 | 1776 | 3584 | 1 | through-wall | 2 × 10 | 46 |
| 16 buildings, one unchanged wall impact | 16 | 7104 | 14336 | 1 | through-wall | 2 × 10 | 58 |
| 64 buildings, one unchanged wall impact | 64 | 28416 | 57344 | 1 | through-wall | 2 × 10 | 106 |
| 256 buildings, one unchanged wall impact | 256 | 113664 | 229376 | 1 | through-wall | 2 × 10 | 298 |
| 16 buildings, simultaneous aerial impacts | 16 | 7104 | 14336 | 16 | aerial | 2 × 10 | 847 |
| 64 buildings, simultaneous aerial impacts | 64 | 28416 | 57344 | 64 | aerial | 2 × 10 | 3211 |
| 256 buildings, simultaneous aerial impacts | 256 | 113664 | 229376 | 256 | aerial | 2 × 10 | 14096 |

World-size cases keep the original target and wall projectile unchanged; extra buildings sit beside its flight corridor. Concurrent-impact cases use the existing aerial launch. Aerial and wall trajectories are different workloads; compare scaling within each family.

Recorded settings: projectile masses (kg) [18000], material-strength scales [24], frame-strength scales [40].

## ⏱️ Complete advance — all repeats pooled

| Scenario | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Worst ms | >8 ms / steps | >16.67 ms / steps | Mean simulation / realtime |
|---|---|---|---|---|---|---|---|---|---|
| 4 buildings, one unchanged wall impact | 0.512 | 4.119 | 3.948 | 5.566 | 6.882 | 8.055 | 1 / 1200 | 0 / 1200 | 4.05× |
| 16 buildings, one unchanged wall impact | 0.532 | 4.138 | 3.960 | 5.586 | 6.958 | 8.187 | 1 / 1200 | 0 / 1200 | 4.03× |
| 64 buildings, one unchanged wall impact | 0.593 | 4.464 | 4.265 | 6.078 | 7.506 | 9.595 | 5 / 1200 | 0 / 1200 | 3.73× |
| 256 buildings, one unchanged wall impact | 0.902 | 6.792 | 6.465 | 9.347 | 11.413 | 16.162 | 212 / 1200 | 0 / 1200 | 2.45× |
| 16 buildings, simultaneous aerial impacts | 0.517 | 5.909 | 5.936 | 9.250 | 11.085 | 13.090 | 173 / 1200 | 0 / 1200 | 2.82× |
| 64 buildings, simultaneous aerial impacts | 0.563 | 9.030 | 8.619 | 15.303 | 18.964 | 24.651 | 888 / 1200 | 24 / 1200 | 1.85× |
| 256 buildings, simultaneous aerial impacts | 0.933 | 25.170 | 21.808 | 39.978 | 64.506 | 98.180 | 1038 / 1200 | 1038 / 1200 | 0.66× |

The realtime ratio divides 16.667 ms of simulated time by mean complete-advance cost. It describes physics/destruction throughput, not rendering or a complete game tick. The 60 Hz miss counter uses the exact 1000/60 ms threshold.

## 💥 Actual work and memory

| Scenario | Peak registered bodies | Peak active dynamic bodies | Peak active kinematic bodies | Peak contact reports/step | Peak retained stress nodes | Peak retained stress bonds | Broken bonds | Corrected steps | Sampled GPU MiB |
|---|---|---|---|---|---|---|---|---|---|
| 4 buildings, one unchanged wall impact | 47 | 43 | 1 | 537 | 1520 | 3136 | [199, 199] | [3, 3] | 584.000 |
| 16 buildings, one unchanged wall impact | 59 | 43 | 1 | 537 | 6080 | 12544 | [199, 199] | [3, 3] | 726.000 |
| 64 buildings, one unchanged wall impact | 107 | 43 | 1 | 537 | 24320 | 50176 | [199, 199] | [3, 3] | 1570.000 |
| 256 buildings, one unchanged wall impact | 299 | 43 | 1 | 537 | 97280 | 200704 | [199, 199] | [3, 3] | 3880.000 |
| 16 buildings, simultaneous aerial impacts | 863 | 847 | 16 | 11826 | 6080 | 12544 | [3833, 3833] | [37, 37] | 982.000 |
| 64 buildings, simultaneous aerial impacts | 3275 | 3211 | 64 | 45855 | 24320 | 50176 | [14711, 14711] | [115, 115] | 2596.000 |
| 256 buildings, simultaneous aerial impacts | 14352 | 14096 | 256 | 211948 | 97280 | 200704 | [62582, 62582] | [215, 215] | 5940.000 |

Chunks are persistent geometry/connectivity units; intact chunks share cluster motion. Active-body counts are PhysX scheduler observations, not chunk counts. Retained stress rows/bonds are not proof every row executed every solver iteration. GPU memory is sampled roughly every 250 ms and can miss brief allocation peaks; it includes the CUDA context and PhysX storage. Corrected steps count the whole run, while each step permits at most one correction.

## 🔍 What happened during each worst complete step

| Scenario | Repeat / step | Total ms | Commands ms | Physics + destruction ms | Completion ms | Active dynamic bodies | Contact reports | Stress iterations | Corrections |
|---|---|---|---|---|---|---|---|---|---|
| 4 buildings, one unchanged wall impact | 1 / 33 | 8.055 | 0.000 | 7.986 | 0.069 | 43 | 500 | 391 | 1 |
| 16 buildings, one unchanged wall impact | 1 / 18 | 8.187 | 0.000 | 8.130 | 0.057 | 16 | 240 | 333 | 0 |
| 64 buildings, one unchanged wall impact | 1 / 33 | 9.595 | 0.000 | 9.525 | 0.070 | 43 | 500 | 390 | 1 |
| 256 buildings, one unchanged wall impact | 1 / 33 | 16.162 | 0.000 | 16.092 | 0.069 | 43 | 500 | 390 | 1 |
| 16 buildings, simultaneous aerial impacts | 2 / 102 | 13.090 | 0.000 | 13.035 | 0.055 | 683 | 5202 | 557 | 1 |
| 64 buildings, simultaneous aerial impacts | 2 / 82 | 24.651 | 0.000 | 24.604 | 0.048 | 1280 | 256 | 192 | 1 |
| 256 buildings, simultaneous aerial impacts | 1 / 82 | 98.180 | 0.000 | 98.089 | 0.091 | 5120 | 1024 | 192 | 1 |

These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.

## 🛡️ Quality observations and initialization

| Scenario | All frames converged / correction ≤1 | Repeated counter history | Original wall counters | Initialization ms range |
|---|---|---|---|---|
| 4 buildings, one unchanged wall impact | Passed | Match | Match | 317.266–322.064 |
| 16 buildings, one unchanged wall impact | Passed | Match | Match | 431.599–435.542 |
| 64 buildings, one unchanged wall impact | Passed | Match | Match | 1115.207–1131.358 |
| 256 buildings, one unchanged wall impact | Passed | Match | Match | 1643.820–1680.607 |
| 16 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 427.120–435.800 |
| 64 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1126.880–1134.012 |
| 256 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1674.753–1676.909 |

Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.

## 🧭 Separate phase attribution: impacts-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 256 projectiles. Scoped peak step 82: 94.982 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.127 | 0.151 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 18.010 | 9.898 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.023 | 0.101 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.045 | 5.582 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.003 | 0.023 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.002 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.004 | 0.058 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.008 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.016 | 0.111 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.023 | 0.109 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.064 | 0.234 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.693 | 40.595 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.146 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.010 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 2.202 | 32.779 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.087 | 0.365 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.897 | 4.516 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.172 | 0.062 |
| Iterative stress solve to convergence | 17.624 | 9.404 |
| Evaluate material damage and fracture | 0.065 | 0.074 |
| Connectivity, cluster mass and fragment candidates | 0.209 | 0.454 |
| Commit changes and rebuild stress topology | 0.042 | 0.038 |

Scoped versus first untraced counter history: full run differs; through this peak matches. Broken bonds: scoped 62581, first untraced 62582. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## Reproduce and inspect

Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.
