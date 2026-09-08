# GPU destruction candidate comparison

Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles; 180 steps / 3 simulated seconds per run. Correction limit 1; sleeping False.

Complete wall-clock advance includes commands, physics, destruction, correction, synchronization and runtime growth. Initialization, rendering and report generation are excluded. Every measured step is retained. These short, ordered screens do not establish the five 60-second peak gate or endurance.

| Version | Runs | Mean ms | Median run peak ms | Worst ms |
|---|---:|---:|---:|---:|
| baseline | 2 | 16.717 | 53.388 | 53.603 |
| candidate | 2 | 16.755 | 54.589 | 56.664 |

| Version/run | Peak step | Peak ms | Awake bodies | Contacts | Stress iterations | Misses >8 ms / >16.67 ms |
|---|---:|---:|---:|---:|---:|---:|
| baseline/impacts-256-plain-0 | 103 | 53.603 | 12072 | 109383 | 276 | 99 / 99 |
| baseline/impacts-256-plain-1 | 82 | 53.174 | 5376 | 1024 | 95 | 99 / 98 |
| candidate/impacts-256-plain-0 | 82 | 56.664 | 5376 | 1024 | 95 | 99 / 99 |
| candidate/impacts-256-plain-1 | 103 | 52.515 | 12072 | 109383 | 276 | 99 / 98 |

## Same-step comparisons

| Step | Baseline min / median / max ms | Candidate min / median / max ms |
|---|---:|---:|
| 82 | 51.774 / 52.474 / 53.174 | 51.883 / 54.273 / 56.664 |
| 103 | 52.497 / 53.050 / 53.603 | 52.476 / 52.496 / 52.515 |

## Separate instrumented phase captures

Host elapsed scopes include GPU waits. CUDA stages overlap these scopes and must not be added again. Each table compares the same step in both captures; instrumented timing is not the authoritative peak.

### Step 82

| Responsibility / owner | Baseline ms | Candidate ms |
|---|---:|---:|
| 🧮 Destruction submission and completion dependency — CPU submission/wait; GPU stress, loads and topology | 8.254 | 8.064 |
| 🚚 Fragment ownership and lifecycle bridge — CPU lifecycle/queries; GPU ownership updates | 16.072 | 16.359 |
| ⏪ Correction orchestration and repeated interaction — CPU scheduling; GPU restore, collision and solve | 26.473 | 27.061 |
| 📤 Accepted-state publication — CPU completion; GPU publication | 2.363 | 2.390 |
| 💾 Checkpoint — CPU submission; GPU copy | 0.009 | 0.010 |
| 🟰 Trial physics and unassigned scene tasks — PhysX CPU tasks and GPU physics | 3.110 | 3.215 |
| 📥 Recorded commands — CPU submission and GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion — CPU final completion boundary | 0.057 | 0.054 |

| Nested GPU stage (overlaps above) | Baseline ms | Candidate ms |
|---|---:|---:|
| commitAndStressTopology | 0.044 | 0.044 |
| contactLoads | 0.055 | 0.065 |
| materials | 0.077 | 0.077 |
| stress | 7.606 | 7.397 |
| topologyAndCandidates | 0.453 | 0.458 |

### Step 103

| Responsibility / owner | Baseline ms | Candidate ms |
|---|---:|---:|
| 🧮 Destruction submission and completion dependency — CPU submission/wait; GPU stress, loads and topology | 19.445 | 18.100 |
| 🚚 Fragment ownership and lifecycle bridge — CPU lifecycle/queries; GPU ownership updates | 8.650 | 7.747 |
| ⏪ Correction orchestration and repeated interaction — CPU scheduling; GPU restore, collision and solve | 19.870 | 17.695 |
| 📤 Accepted-state publication — CPU completion; GPU publication | 2.295 | 2.299 |
| 💾 Checkpoint — CPU submission; GPU copy | 0.009 | 0.007 |
| 🟰 Trial physics and unassigned scene tasks — PhysX CPU tasks and GPU physics | 8.032 | 7.963 |
| 📥 Recorded commands — CPU submission and GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion — CPU final completion boundary | 0.100 | 0.052 |

| Nested GPU stage (overlaps above) | Baseline ms | Candidate ms |
|---|---:|---:|
| commitAndStressTopology | 0.041 | 0.041 |
| contactLoads | 0.137 | 0.136 |
| materials | 0.070 | 0.070 |
| stress | 18.668 | 17.330 |
| topologyAndCandidates | 0.499 | 0.496 |

## Connectivity bookkeeping (whole run)

| Counter | Baseline range | Candidate range |
|---|---:|---:|
| host_connectivity_restores | 0–0 | 0–0 |
| cuda_pre_solve_node_full_snapshots | 1–1 | 1–1 |
| cuda_pre_solve_fallbacks | 1–1 | 1–1 |
| cuda_pre_solve_host_to_device_bytes | 305,400–305,400 | 305,400–305,400 |
| solver_metadata_full_uploads | 1–1 | 1–1 |
| solver_metadata_host_to_device_bytes | 3,072–3,072 | 3,072–3,072 |

## Quality and provenance

- Physical counter differences: **0**. Full differences are retained in JSON.
- Iteration-count differences: **10** across all comparisons, including separate phase captures. Iteration counts alone do not prove or disprove equal physical output.
- All captured solves report convergence and at most one correction. Counter agreement is not proof of identical trajectories.
- Independent physical, memory and lifecycle test evidence must accompany acceptance of a candidate.
- Raw samples are archived and checked against capture hashes. Both manifests retain commands and runtime hashes.
