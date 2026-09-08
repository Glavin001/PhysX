# 🎯 Destruction peak opportunities

Workload: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles; 15 simulated seconds per run; correction limit 1; sleeping False.

Source: validated timing-report snapshot (SHA-256 e6fc2cb691153806f79bfbc9a28ca195d04ffe68b961522bdc075bf25cb70a3c). This analysis checks timer closure; it does not independently revalidate the raw CUPTI trace. No simulation or profiling is run during report generation.

| Untraced run | Steps | Mean complete ms | Peak complete ms | Peak step | >8 ms | >1/60 s |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 900 | 24.068 | 37.965 | 702 | 819 | 794 |
| 2 | 900 | 24.096 | 37.177 | 726 | 819 | 795 |

## Separate scoped capture 1: rank by its ten worst complete steps

All steps remain eligible, including startup. The selected steps are: [655, 636, 691, 702, 653, 684, 690, 688, 660, 661]. This ranking is measured elapsed exposure, not a promised saving. Submission and completion wait are grouped because GPU work can execute inside either host scope. Rows form a disjoint partition apart from small recorded timestamp bookends.

| Responsibility | Mean of selected peaks ms | At this capture’s worst step ms | All-step mean ms | Optimization owner |
|---|---:|---:|---:|---|
| 🧮 Destruction submission and completion dependency | 24.477 | 26.635 | 16.181 | Our CUDA stress/load/topology pipeline; inspect CUDA stages below |
| 🟰 Trial physics and unassigned scene tasks | 4.711 | 4.323 | 3.569 | Control/context; not a recommendation to rewrite NVIDIA kernels |
| ⏪ Correction orchestration and repeated interaction | 4.467 | 4.188 | 2.469 | Optimize our work selection/reuse; keep NVIDIA collision/solve kernels |
| 📤 Accepted-state publication | 2.382 | 2.393 | 1.630 | Our correction completion and publication |
| 🚚 Fragment ownership and lifecycle bridge | 0.574 | 0.532 | 0.374 | Our integration: allocation, registration, ownership, filtering and query mirrors |
| ✅ Mandatory completion | 0.059 | 0.049 | 0.062 | Application completion/status boundary |
| 💾 Checkpoint | 0.010 | 0.009 | 0.011 | Our checkpoint selection/submission |
| 📥 Recorded commands | 0.000 | 0.000 | 0.024 | Command application including runtime insertion |

Scoped worst complete step: 655, 38.128 ms.

| Work at that step | Count |
|---|---:|
| bodies | 13725 |
| awake_bodies | 13714 |
| logical_clusters | 13469 |
| contacts_frame | 203560 |
| stress_active_nodes | 86988 |
| stress_active_bonds | 138741 |
| stress_islands | 3177 |
| stress_iterations | 364 |
| bonds_broken | 71 |
| resim_passes | 1 |

Contacts are reports, awake bodies are CPU scheduling counts, retained stress bonds are not bond-iterations. The stress iteration counter is not a resimulation count.

| CUDA stream interval at scoped peak (overlaps table above) | ms |
|---|---:|
| commitAndStressTopology | 0.039 |
| contactLoads | 0.208 |
| materials | 0.071 |
| stress | 25.781 |
| topologyAndCandidates | 0.514 |

## Evidence required before choosing an optimization

| Question | Evidence available without privileged counters | Decision |
|---|---|---|
| Where is the peak spent? | Disjoint CPU timeline + CUDA events + CUPTI execution unions | Rank critical elapsed regions; never sum overlapping waits and kernels |
| Why does stress get expensive? | Add per-component node/bond iterations, iteration distribution and preconditioner/reduction phase clocks | Separate too much work from slow execution or a few long-running components |
| Why does correction get expensive? | Count new fragments, ownership changes, pair invalidations, regenerated constraints and correction participants | Remove our unnecessary lifecycle/rebuild work; keep NVIDIA solver kernels |
| Would more parallel work help? | Fixed-input component batching and block-size experiments; per-block duration distributions | Compare same physical work and end-to-end peaks, not utilization percentages |
| Is memory or arithmetic limiting? | Static operation counts, standalone bandwidth/arithmetic controls, controlled layout/reuse experiments | Supporting evidence only; do not claim a measured roofline or occupancy without counters |
| Did the change actually help? | Interleaved A/B runs with identical recorded commands, settings and quality audits | Require repeatable complete-step peak reduction; preserve every spike |

## Repeatable decision loop

1. Freeze inputs, iteration policy, binaries, CUDA settings and quality requirements. Capture the entire impact sequence, not a synthetic idle fragment.
2. Rank peak exposure above. Investigate our largest stages first. Use a PhysX-only run only as a control; removing destruction changes the workload and cannot establish a production speedup.
3. State one falsifiable hypothesis and change one implementation responsibility. Use diagnostic builds for counters/probes, separate from untraced performance builds.
4. Interleave baseline/candidate runs to expose clock and host scheduling drift. Match event windows as well as absolute worst steps. Record all physical counters and flag trajectory differences.
5. Run physical quality gates; counts alone are insufficient. Report result as verified improvement, inconclusive noise, regression, or changed workload—not simply a faster mean.
6. Only qualifying candidates proceed to five 60-second runs and endurance. Re-rank after every accepted change.

## Current limitations

Hardware counters unavailable: memory saturation, occupancy and instruction stalls remain unmeasured. Existing solver-row counters are incomplete. Per-component weighted iteration work and exact correction invalidation counts remain instrumentation TODOs. A capped cross-frame iteration policy must be compared separately from mandatory within-step convergence; changing that policy is not an implementation-only A/B test. Short diagnostic campaigns do not establish 60 Hz or the 8 ms gate.

## Reproduce

Run `python3 tools/scripts/destruction-peak-opportunities.py REPORT_JSON_GZ --case stagger-256-10s --output OUTPUT_DIRECTORY` against a full timing report. The output is deterministic and includes a source hash.
