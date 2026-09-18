# 🏙️ Integrated PhysX GPU destruction — scaling measurements

All measured advances include recorded commands, projectile insertion, ordinary physics, CUDA stress/material/topology work, up to one correction and mandatory completion. Timestep is 1/60 second. Rendering, video encoding, asset preparation and initial CUDA setup are excluded; initialization is reported separately. Every measured step is retained.

Run count and duration are reported per scenario. Five × 60-second runs with every complete step at or below 8 ms satisfy the timing gate; shorter captures are diagnostic. Timing alone does not establish full physical or ten-minute lifecycle qualification. A mean below a deadline does not pass the peak requirement. Sleeping is disabled in these fixtures.

| Scenario | Buildings | Chunks | Bonds | Projectiles | Launch | Runs × seconds | Peak clusters |
|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 1 | 444 | 896 | 1 | through-wall | 5 × 60 | 43 |
| 16 buildings, simultaneous aerial impacts | 16 | 7104 | 14336 | 16 | aerial | 2 × 10 | 865 |
| 256 buildings, simultaneous aerial impacts | 256 | 113664 | 229376 | 256 | aerial | 2 × 10 | 14219 |

World-size cases keep the original target and wall projectile unchanged; extra buildings sit beside its flight corridor. Concurrent-impact cases use the existing aerial launch. Aerial and wall trajectories are different workloads; compare scaling within each family.

Recorded settings: projectile masses (kg) [18000], material-strength scales [24], frame-strength scales [40].

## ⏱️ Complete advance — all repeats pooled

| Scenario | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Worst ms | >8 ms / steps | >16.67 ms / steps | Mean simulation / realtime |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 0.493 | 2.368 | 2.317 | 2.496 | 3.850 | 6.663 | 0 / 18000 | 0 / 18000 | 7.04× |
| 16 buildings, simultaneous aerial impacts | 0.517 | 4.633 | 4.923 | 7.246 | 8.494 | 10.162 | 39 / 1200 | 0 / 1200 | 3.60× |
| 256 buildings, simultaneous aerial impacts | 0.920 | 18.661 | 16.493 | 31.388 | 38.228 | 63.505 | 1038 / 1200 | 594 / 1200 | 0.89× |

The realtime ratio divides 16.667 ms of simulated time by mean complete-advance cost. It describes physics/destruction throughput, not rendering or a complete game tick. The 60 Hz miss counter uses the exact 1000/60 ms threshold.

## 💥 Actual work and memory

| Scenario | Peak registered bodies | Peak active dynamic bodies | Peak active kinematic bodies | Peak contact reports/step | Peak retained stress nodes | Peak retained stress bonds | Broken bonds | Corrected steps | Sampled GPU MiB |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 44 | 43 | 1 | 506 | 380 | 784 | [199, 199] | [3, 3] | 580.000 |
| 16 buildings, simultaneous aerial impacts | 881 | 865 | 16 | 12227 | 6080 | 12544 | [3996, 3996] | [47, 47] | 984.000 |
| 256 buildings, simultaneous aerial impacts | 14475 | 14219 | 256 | 205914 | 97280 | 200704 | [62728, 62728] | [224, 224] | 5948.000 |

Chunks are persistent geometry/connectivity units; intact chunks share cluster motion. Active-body counts are PhysX scheduler observations, not chunk counts. Retained stress rows/bonds are not proof every row executed every solver iteration. GPU memory is sampled roughly every 250 ms and can miss brief allocation peaks; it includes the CUDA context and PhysX storage. Corrected steps count the whole run, while each step permits at most one correction.

## 🔍 What happened during each worst complete step

| Scenario | Repeat / step | Total ms | Commands ms | Physics + destruction ms | Completion ms | Active dynamic bodies | Contact reports | Stress iterations | Corrections |
|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 2 / 33 | 6.663 | 0.000 | 6.601 | 0.062 | 43 | 488 | 476 | 1 |
| 16 buildings, simultaneous aerial impacts | 1 / 103 | 10.162 | 0.000 | 10.114 | 0.048 | 722 | 6677 | 615 | 1 |
| 256 buildings, simultaneous aerial impacts | 2 / 82 | 63.505 | 0.000 | 63.421 | 0.084 | 5120 | 1024 | 192 | 1 |

These three subintervals add to the complete timer. Untraced captures do not separately measure stress, collision or host waits: the zero stress_solve_ms placeholder is not a zero-cost measurement. Further attribution requires a separate scoped capture; it cannot be inferred from counts or another run’s maximum.

## 🛡️ Quality observations and initialization

| Scenario | All frames converged / correction ≤1 | Repeated counter history | Original wall counters | Initialization ms range |
|---|---|---|---|---|
| One building, projectile penetration | Passed | Match | Match | 309.678–324.881 |
| 16 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 443.703–451.386 |
| 256 buildings, simultaneous aerial impacts | Passed | Match | Different aerial workload | 1666.443–1667.930 |

Wall counters require 199 broken bonds, three corrected steps and exactly 42 additional clusters. This does not replace the full trajectory, exact bond-identity or chunk-membership audit at each new size. Counter agreement is reported separately from physical qualification; no new large workload is declared fully qualified here.

## 🧭 Separate phase attribution: penetration

One scoped 60-second run: 444 chunks, 896 bonds, 1 projectiles. Scoped peak step 33: 6.735 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.111 | 0.113 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 1.469 | 3.611 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.032 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.005 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.007 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.008 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.042 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.020 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.014 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.057 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.000 | 0.088 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.014 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.001 | 1.204 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.000 | 0.123 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.803 | 1.142 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.023 | 0.022 |
| Iterative stress solve to convergence | 1.462 | 3.509 |
| Evaluate material damage and fracture | 0.018 | 0.018 |
| Connectivity, cluster mass and fragment candidates | 0.026 | 0.120 |
| Commit changes and rebuild stress topology | 0.031 | 0.031 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 199, first untraced 199. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-16

One scoped 10-second run: 7104 chunks, 14336 bonds, 16 projectiles. Scoped peak step 103: 10.161 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.021 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.109 | 0.110 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 3.168 | 5.153 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.003 | 0.028 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.002 | 0.080 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.001 | 0.007 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.006 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.007 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.006 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.003 | 0.037 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.003 | 0.019 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.013 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.006 | 0.063 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.011 | 0.276 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.001 | 0.013 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.001 | 0.005 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.118 | 2.398 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.012 | 0.152 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 1.179 | 1.510 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.024 | 0.026 |
| Iterative stress solve to convergence | 3.140 | 4.995 |
| Evaluate material damage and fracture | 0.018 | 0.018 |
| Connectivity, cluster mass and fragment candidates | 0.040 | 0.170 |
| Commit changes and rebuild stress topology | 0.033 | 0.031 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 3996, first untraced 3996. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## 🧭 Separate phase attribution: impacts-256

One scoped 10-second run: 113664 chunks, 229376 bonds, 256 projectiles. Scoped peak step 82: 63.957 ms. This is not the same measured peak as the untraced table. CPU elapsed regions below form a partition; GPU stream timings overlap them and must not be added.

| Operation | CPU / GPU responsibility | Mean ms | At scoped peak ms |
|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.012 | 0.011 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.120 | 0.170 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 12.750 | 3.804 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.027 | 0.115 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.044 | 6.627 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.003 | 0.031 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.003 | 0.008 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.004 | 0.073 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.009 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.019 | 0.129 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.009 | 0.121 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.007 | 0.094 |
| Observe prepared correction verdicts | GPU → CPU compact validation status at the remaining ownership bridge; includes completion wait | 0.071 | 0.162 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.169 | 15.306 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.006 | 0.084 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.009 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.581 | 32.428 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.108 | 0.395 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 3.697 | 4.133 |

| GPU stream stage | Mean ms | At scoped peak ms |
|---|---|---|
| Convert solved contact impulses into chunk loads | 0.169 | 0.061 |
| Iterative stress solve to convergence | 12.352 | 3.318 |
| Evaluate material damage and fracture | 0.065 | 0.074 |
| Connectivity, cluster mass and fragment candidates | 0.216 | 0.455 |
| Commit changes and rebuild stress topology | 0.043 | 0.039 |

Scoped versus first untraced counter history: full run matches; through this peak matches. Broken bonds: scoped 62728, first untraced 62728. CUDA events include stream gaps; these data do not identify a hardware bandwidth or SM-utilization limit.

## Reproduce and inspect

Inputs: tools/profiles/destruction-scaling.json. Capture one case with run-destruction-timing.py NEW_OUTPUT --config tools/profiles/destruction-scaling.json --case CASE_ID --gate-only --trials 2 --seconds 10. Regenerate this document with report-destruction-scaling.py CAPTURE... --output REPORT. Each capture retains exact commands, binary hashes, GPU isolation observations and lossless per-step CSVs.
