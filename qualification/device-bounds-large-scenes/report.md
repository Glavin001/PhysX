# 🏙️ Integrated PhysX GPU destruction — scaling measurements

All measured advances include recorded commands, projectile insertion, ordinary physics, CUDA stress/material/topology work, up to one correction and mandatory completion. Timestep is 1/60 second. Rendering, video encoding, asset preparation and initial CUDA setup are excluded; initialization is reported separately. Every measured step is retained.

These are diagnostic scaling runs, not the five × 60-second deadline or ten-minute endurance qualification. A mean below a deadline does not pass the peak requirement. Sleeping is disabled in these fixtures.

| Scenario | Buildings | Chunks | Bonds | Projectiles | Launch | Runs × seconds | Peak clusters |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 444 | 896 | 1 | through-wall | 5 × 60 | 43 |
| 256 buildings, one unchanged wall impact | 256 | 113664 | 229376 | 1 | through-wall | 2 × 60 | 298 |
| 64 buildings, simultaneous aerial impacts | 64 | 28416 | 57344 | 64 | aerial | 2 × 60 | 3212 |
| 256 buildings, simultaneous aerial impacts | 256 | 113664 | 229376 | 256 | aerial | 2 × 60 | 14128 |

World-size cases keep the original target and wall projectile unchanged; extra buildings sit beside its flight corridor. Concurrent-impact cases use the existing aerial launch. Aerial and wall trajectories are different workloads; compare scaling within each family.

Recorded settings: projectile masses (kg) [18000], material-strength scales [24], frame-strength scales [40].

## ⏱️ Complete advance — all repeats pooled

| Scenario | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Worst ms | >8 ms / steps | >16.67 ms / steps | Mean simulation / realtime |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 0.510 | 3.026 | 3.006 | 3.425 | 4.201 | 7.203 | 0 / 18000 | 0 / 18000 | 5.51× |
| 256 buildings, one unchanged wall impact | 0.940 | 6.370 | 6.332 | 7.286 | 9.203 | 15.305 | 213 / 7200 | 0 / 7200 | 2.62× |
| 64 buildings, simultaneous aerial impacts | 0.578 | 8.060 | 7.904 | 10.501 | 14.934 | 26.188 | 2926 / 7200 | 20 / 7200 | 2.07× |
| 256 buildings, simultaneous aerial impacts | 0.920 | 20.967 | 20.278 | 32.150 | 38.213 | 100.029 | 7038 / 7200 | 7038 / 7200 | 0.79× |

The realtime ratio divides 16.667 ms of simulated time by mean complete-advance cost. It describes physics/destruction throughput, not rendering or a complete game tick. The 60 Hz miss counter uses the exact 1000/60 ms threshold.

## 💥 Actual work and memory

| Scenario | Peak registered bodies | Peak active dynamic bodies | Peak active kinematic bodies | Peak contact reports/step | Peak retained stress nodes | Peak retained stress bonds | Broken bonds | Corrected steps | Sampled GPU MiB |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 44 | 43 | 1 | 537 | 380 | 784 | [199, 199] | [3, 3] | 580.000 |
| 256 buildings, one unchanged wall impact | 299 | 43 | 2 | 537 | 97280 | 200704 | [199, 199] | [3, 3] | 3880.000 |
| 64 buildings, simultaneous aerial impacts | 3276 | 3212 | 64 | 46059 | 24320 | 50176 | [14714, 14714] | [116, 116] | 2596.000 |
| 256 buildings, simultaneous aerial impacts | 14384 | 14128 | 256 | 213113 | 97280 | 200704 | [62640, 62640] | [226, 226] | 5940.000 |

Chunks are persistent geometry/connectivity units; intact chunks share cluster motion. Active-body counts are PhysX scheduler observations, not chunk counts. Retained stress rows/bonds are not proof every row executed every solver iteration. GPU memory is sampled roughly every 250 ms and can miss brief allocation peaks; it includes the CUDA context and PhysX storage. Corrected steps count the whole run, while each step permits at most one correction.

## 🔍 What happened during each worst complete step

| Scenario | Repeat / step | Total ms | Commands ms | Physics + destruction ms | Completion ms | Active dynamic bodies | Contact reports | Stress iterations | Corrections |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 2 / 33 | 7.203 | 0.000 | 7.132 | 0.072 | 43 | 500 | 391 | 1 |
| 256 buildings, one unchanged wall impact | 1 / 33 | 15.305 | 0.000 | 15.244 | 0.060 | 43 | 500 | 391 | 1 |
| 64 buildings, simultaneous aerial impacts | 1 / 82 | 26.188 | 0.000 | 26.134 | 0.054 | 1280 | 256 | 192 | 1 |
| 256 buildings, simultaneous aerial impacts | 2 / 82 | 100.029 | 0.000 | 99.945 | 0.084 | 5120 | 1024 | 192 | 1 |

These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.

## 🛡️ Quality observations and initialization

| Scenario | All frames converged / correction ≤1 | Repeated counter history | Original wall counters | Initialization ms range |
|---|---|---|---|---|
| One building, projectile penetration | Passed | Match | Match | 306.650–327.243 |
| 256 buildings, one unchanged wall impact | Passed | Match | Match | 1674.788–1680.534 |
| 64 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1128.132–1132.195 |
| 256 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1682.338–1686.424 |

Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.

## 🧭 Separate phase attribution: world-256

One scoped 60-second run: 113664 chunks, 229376 bonds, 1 projectiles. Scoped peak step 33: 16.102 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.006 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.108 | 0.104 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 5.113 | 11.194 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.033 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.005 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.007 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.007 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.006 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.036 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.017 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.014 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.176 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.000 | 0.238 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.013 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.002 | 2.338 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.000 | 0.257 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.164 | 1.459 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.056 | 0.057 |
| Iterative stress solve to convergence | 5.008 | 10.800 |
| Evaluate material damage and fracture | 0.067 | 0.069 |
| Connectivity, cluster mass and fragment candidates | 0.032 | 0.312 |
| Commit changes and rebuild stress topology | 0.037 | 0.037 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 199, first untraced 199. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-64

One scoped 60-second run: 28416 chunks, 57344 bonds, 64 projectiles. Scoped peak step 82: 25.321 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.111 | 0.152 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 6.210 | 3.268 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.001 | 0.082 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.001 | 1.561 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.024 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.007 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.026 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.001 | 0.087 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.002 | 0.077 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.077 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.004 | 0.067 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.021 | 10.626 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.055 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.006 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.069 | 6.955 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.005 | 0.169 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.640 | 1.833 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.057 | 0.060 |
| Iterative stress solve to convergence | 6.145 | 3.071 |
| Evaluate material damage and fracture | 0.026 | 0.026 |
| Connectivity, cluster mass and fragment candidates | 0.036 | 0.209 |
| Commit changes and rebuild stress topology | 0.034 | 0.033 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 14714, first untraced 14714. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-256

One scoped 60-second run: 113664 chunks, 229376 bonds, 256 projectiles. Scoped peak step 82: 91.468 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.010 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.116 | 0.165 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 16.771 | 9.406 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.004 | 0.092 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.008 | 6.691 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.001 | 0.046 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.009 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.064 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.004 | 0.143 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.002 | 0.091 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.083 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.013 | 0.181 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.117 | 40.879 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.001 | 0.166 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.001 | 0.011 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.308 | 29.227 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.015 | 0.307 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.548 | 3.637 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.204 | 0.057 |
| Iterative stress solve to convergence | 16.487 | 8.951 |
| Evaluate material damage and fracture | 0.064 | 0.073 |
| Connectivity, cluster mass and fragment candidates | 0.066 | 0.433 |
| Commit changes and rebuild stress topology | 0.041 | 0.038 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 62640, first untraced 62640. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## Reproduce and inspect

Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.
