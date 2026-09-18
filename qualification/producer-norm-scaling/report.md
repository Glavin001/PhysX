# 🏙️ Integrated PhysX GPU destruction — scaling measurements

All measured advances include recorded commands, projectile insertion, ordinary physics, CUDA stress/material/topology work, up to one correction and mandatory completion. Timestep is 1/60 second. Rendering, video encoding, asset preparation and initial CUDA setup are excluded; initialization is reported separately. Every measured step is retained.

Run count and duration are reported per scenario. Five × 60-second runs with every complete step at or below 8 ms satisfy the timing gate; shorter captures are diagnostic. Timing alone does not establish full physical or ten-minute lifecycle qualification. A mean below a deadline does not pass the peak requirement. Sleeping is disabled in these fixtures.

| Scenario | Buildings | Chunks | Bonds | Projectiles | Launch | Runs × seconds | Peak clusters |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 444 | 896 | 1 | through-wall | 5 × 60 | 43 |
| 144 buildings, one unchanged wall impact | 144 | 63936 | 129024 | 1 | through-wall | 5 × 60 | 186 |
| 256 buildings, one unchanged wall impact | 256 | 113664 | 229376 | 1 | through-wall | 2 × 10 | 298 |
| 256 buildings, simultaneous aerial impacts | 256 | 113664 | 229376 | 256 | aerial | 2 × 10 | 14096 |

World-size cases keep the original target and wall projectile unchanged; extra buildings sit beside its flight corridor. Concurrent-impact cases use the existing aerial launch. Aerial and wall trajectories are different workloads; compare scaling within each family.

Recorded settings: projectile masses (kg) [18000], material-strength scales [24], frame-strength scales [40].

## ⏱️ Complete advance — all repeats pooled

| Scenario | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Worst ms | >8 ms / steps | >16.67 ms / steps | Mean simulation / realtime |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 0.517 | 2.817 | 2.798 | 3.181 | 3.904 | 6.201 | 0 / 18000 | 0 / 18000 | 5.92× |
| 144 buildings, one unchanged wall impact | 0.702 | 3.058 | 3.032 | 3.431 | 4.208 | 7.786 | 0 / 18000 | 0 / 18000 | 5.45× |
| 256 buildings, one unchanged wall impact | 0.929 | 3.472 | 3.326 | 4.461 | 5.822 | 9.526 | 4 / 1200 | 0 / 1200 | 4.80× |
| 256 buildings, simultaneous aerial impacts | 0.929 | 18.896 | 15.543 | 33.352 | 55.171 | 86.243 | 1038 / 1200 | 547 / 1200 | 0.88× |

The realtime ratio divides 16.667 ms of simulated time by mean complete-advance cost. It describes physics/destruction throughput, not rendering or a complete game tick. The 60 Hz miss counter uses the exact 1000/60 ms threshold.

## 💥 Actual work and memory

| Scenario | Peak registered bodies | Peak active dynamic bodies | Peak active kinematic bodies | Peak contact reports/step | Peak retained stress nodes | Peak retained stress bonds | Broken bonds | Corrected steps | Sampled GPU MiB |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 44 | 43 | 1 | 537 | 380 | 784 | [199, 199] | [3, 3] | 580.000 |
| 144 buildings, one unchanged wall impact | 187 | 43 | 1 | 537 | 54720 | 112896 | [199, 199] | [3, 3] | 2698.000 |
| 256 buildings, one unchanged wall impact | 299 | 43 | 1 | 537 | 97280 | 200704 | [199, 199] | [3, 3] | 3886.000 |
| 256 buildings, simultaneous aerial impacts | 14352 | 14096 | 256 | 211948 | 97280 | 200704 | [62582, 62582] | [215, 215] | 5946.000 |

Chunks are persistent geometry/connectivity units; intact chunks share cluster motion. Active-body counts are PhysX scheduler observations, not chunk counts. Retained stress rows/bonds are not proof every row executed every solver iteration. GPU memory is sampled roughly every 250 ms and can miss brief allocation peaks; it includes the CUDA context and PhysX storage. Corrected steps count the whole run, while each step permits at most one correction.

## 🔍 What happened during each worst complete step

| Scenario | Repeat / step | Total ms | Commands ms | Physics + destruction ms | Completion ms | Active dynamic bodies | Contact reports | Stress iterations | Corrections |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 / 0 | 6.201 | 1.409 | 4.731 | 0.061 | 1 | 0 | 86 | 0 |
| 144 buildings, one unchanged wall impact | 4 / 33 | 7.786 | 0.000 | 7.733 | 0.052 | 43 | 500 | 390 | 1 |
| 256 buildings, one unchanged wall impact | 2 / 33 | 9.526 | 0.000 | 9.475 | 0.051 | 43 | 500 | 390 | 1 |
| 256 buildings, simultaneous aerial impacts | 1 / 82 | 86.243 | 0.000 | 86.170 | 0.072 | 5120 | 1024 | 192 | 1 |

These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.

## 🛡️ Quality observations and initialization

| Scenario | All frames converged / correction ≤1 | Repeated counter history | Original wall counters | Initialization ms range |
|---|---|---|---|---|
| One building, projectile penetration | Passed | Match | Match | 305.959–324.625 |
| 144 buildings, one unchanged wall impact | Passed | Match | Match | 1286.954–1303.915 |
| 256 buildings, one unchanged wall impact | Passed | Match | Match | 1672.995–1674.384 |
| 256 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1675.413–1681.780 |

Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.

## 🧭 Separate phase attribution: world-144

One scoped 60-second run: 63936 chunks, 129024 bonds, 1 projectiles. Scoped peak step 33: 7.869 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.008 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.109 | 0.121 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 1.909 | 3.753 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.030 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.013 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.007 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.007 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.008 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.033 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.016 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.014 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.122 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.000 | 0.232 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.013 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.001 | 1.672 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.000 | 0.238 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.044 | 1.352 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.042 | 0.048 |
| Iterative stress solve to convergence | 1.849 | 3.478 |
| Evaluate material damage and fracture | 0.041 | 0.045 |
| Connectivity, cluster mass and fragment candidates | 0.030 | 0.244 |
| Commit changes and rebuild stress topology | 0.035 | 0.035 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 199, first untraced 199. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: world-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 1 projectiles. Scoped peak step 33: 9.926 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.007 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.110 | 0.098 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 2.248 | 4.987 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.029 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.005 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.006 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.005 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.008 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.006 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.034 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.015 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.013 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.002 | 0.179 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.002 | 0.228 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.013 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.012 | 2.225 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.002 | 0.317 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.192 | 1.519 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.056 | 0.057 |
| Iterative stress solve to convergence | 2.141 | 4.590 |
| Evaluate material damage and fracture | 0.067 | 0.070 |
| Connectivity, cluster mass and fragment candidates | 0.033 | 0.308 |
| Commit changes and rebuild stress topology | 0.038 | 0.036 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 199, first untraced 199. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 256 projectiles. Scoped peak step 82: 90.041 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.014 | 0.014 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.121 | 0.161 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 12.266 | 3.769 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.024 | 0.093 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.044 | 5.680 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.003 | 0.022 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.002 | 0.007 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.004 | 0.058 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.015 | 0.100 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.007 | 0.083 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.007 | 0.072 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.064 | 0.181 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.674 | 38.639 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.139 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.009 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.777 | 35.953 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.104 | 0.423 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.750 | 4.314 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.171 | 0.066 |
| Iterative stress solve to convergence | 11.873 | 3.267 |
| Evaluate material damage and fracture | 0.065 | 0.075 |
| Connectivity, cluster mass and fragment candidates | 0.209 | 0.454 |
| Commit changes and rebuild stress topology | 0.043 | 0.041 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 62582, first untraced 62582. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## Reproduce and inspect

Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.
