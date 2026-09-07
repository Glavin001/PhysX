# 🏙️ Integrated PhysX GPU destruction — scaling measurements

All measured advances include recorded commands, projectile insertion, ordinary physics, CUDA stress/material/topology work, up to one correction and mandatory completion. Timestep is 1/60 second. Rendering, video encoding, asset preparation and initial CUDA setup are excluded; initialization is reported separately. Every measured step is retained.

These are diagnostic scaling runs, not the five × 60-second deadline or ten-minute endurance qualification. A mean below a deadline does not pass the peak requirement. Sleeping is disabled in these fixtures.

| Scenario | Buildings | Chunks | Bonds | Projectiles | Launch | Runs × seconds | Peak clusters |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 444 | 896 | 1 | through-wall | 5 × 60 | 43 |
| 256 buildings, one unchanged wall impact | 256 | 113664 | 229376 | 1 | through-wall | 2 × 10 | 298 |
| 256 buildings, simultaneous aerial impacts | 256 | 113664 | 229376 | 256 | aerial | 2 × 10 | 14096 |

World-size cases keep the original target and wall projectile unchanged; extra buildings sit beside its flight corridor. Concurrent-impact cases use the existing aerial launch. Aerial and wall trajectories are different workloads; compare scaling within each family.

Recorded settings: projectile masses (kg) [18000], material-strength scales [24], frame-strength scales [40].

## ⏱️ Complete advance — all repeats pooled

| Scenario | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Worst ms | >8 ms / steps | >16.67 ms / steps | Mean simulation / realtime |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 0.506 | 3.026 | 3.005 | 3.425 | 4.221 | 6.762 | 0 / 18000 | 0 / 18000 | 5.51× |
| 256 buildings, one unchanged wall impact | 0.912 | 6.797 | 6.455 | 9.330 | 11.565 | 15.634 | 211 / 1200 | 0 / 1200 | 2.45× |
| 256 buildings, simultaneous aerial impacts | 0.944 | 24.684 | 21.785 | 38.466 | 63.740 | 98.047 | 1038 / 1200 | 1038 / 1200 | 0.68× |

The realtime ratio divides 16.667 ms of simulated time by mean complete-advance cost. It describes physics/destruction throughput, not rendering or a complete game tick. The 60 Hz miss counter uses the exact 1000/60 ms threshold.

## 💥 Actual work and memory

| Scenario | Peak registered bodies | Peak active dynamic bodies | Peak active kinematic bodies | Peak contact reports/step | Peak retained stress nodes | Peak retained stress bonds | Broken bonds | Corrected steps | Sampled GPU MiB |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 44 | 43 | 1 | 537 | 380 | 784 | [199, 199] | [3, 3] | 580.000 |
| 256 buildings, one unchanged wall impact | 299 | 43 | 1 | 537 | 97280 | 200704 | [199, 199] | [3, 3] | 3880.000 |
| 256 buildings, simultaneous aerial impacts | 14352 | 14096 | 256 | 211948 | 97280 | 200704 | [62582, 62582] | [215, 215] | 5942.000 |

Chunks are persistent geometry/connectivity units; intact chunks share cluster motion. Active-body counts are PhysX scheduler observations, not chunk counts. Retained stress rows/bonds are not proof every row executed every solver iteration. GPU memory is sampled roughly every 250 ms and can miss brief allocation peaks; it includes the CUDA context and PhysX storage. Corrected steps count the whole run, while each step permits at most one correction.

## 🔍 What happened during each worst complete step

| Scenario | Repeat / step | Total ms | Commands ms | Physics + destruction ms | Completion ms | Active dynamic bodies | Contact reports | Stress iterations | Corrections |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 4 / 33 | 6.762 | 0.000 | 6.685 | 0.077 | 43 | 500 | 390 | 1 |
| 256 buildings, one unchanged wall impact | 1 / 33 | 15.634 | 0.000 | 15.571 | 0.062 | 43 | 500 | 391 | 1 |
| 256 buildings, simultaneous aerial impacts | 1 / 82 | 98.047 | 0.000 | 97.984 | 0.063 | 5120 | 1024 | 192 | 1 |

These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.

## 🛡️ Quality observations and initialization

| Scenario | All frames converged / correction ≤1 | Repeated counter history | Original wall counters | Initialization ms range |
|---|---|---|---|---|
| One building, projectile penetration | Passed | Match | Match | 315.670–326.049 |
| 256 buildings, one unchanged wall impact | Passed | Match | Match | 1663.337–1672.325 |
| 256 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1672.175–1673.748 |

Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.

## 🧭 Separate phase attribution: world-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 1 projectiles. Scoped peak step 33: 15.749 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.012 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.108 | 0.127 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 5.514 | 10.639 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.045 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.008 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.009 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.008 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.010 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.011 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.043 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.020 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.016 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.002 | 0.175 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.002 | 0.256 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.016 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.007 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.012 | 2.346 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.261 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.180 | 1.481 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.056 | 0.056 |
| Iterative stress solve to convergence | 5.407 | 10.282 |
| Evaluate material damage and fracture | 0.067 | 0.067 |
| Connectivity, cluster mass and fragment candidates | 0.033 | 0.299 |
| Commit changes and rebuild stress topology | 0.038 | 0.036 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 199, first untraced 199. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 256 projectiles. Scoped peak step 82: 100.416 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.008 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.121 | 0.162 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 17.993 | 9.898 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.023 | 0.093 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.045 | 7.066 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.003 | 0.040 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.003 | 0.009 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.004 | 0.066 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.008 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.017 | 0.116 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.008 | 0.094 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.007 | 0.084 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.068 | 0.789 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.698 | 42.444 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.177 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.011 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.814 | 34.823 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.086 | 0.354 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.771 | 3.927 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.171 | 0.063 |
| Iterative stress solve to convergence | 17.602 | 9.407 |
| Evaluate material damage and fracture | 0.065 | 0.074 |
| Connectivity, cluster mass and fragment candidates | 0.209 | 0.454 |
| Commit changes and rebuild stress topology | 0.042 | 0.040 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 62582, first untraced 62582. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## Reproduce and inspect

Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.
