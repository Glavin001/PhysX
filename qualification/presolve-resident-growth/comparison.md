# GPU destruction candidate comparison

Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles; 180 steps / 3 simulated seconds per run. Correction limit 1; sleeping False.

Complete wall-clock advance includes commands, physics, destruction, correction, synchronization and runtime growth. Initialization, rendering and report generation are excluded. Every measured step is retained. These short, ordered screens do not establish the five 60-second peak gate or endurance.

| Version | Runs | Mean ms | Median run peak ms | Worst ms |
|---|---:|---:|---:|---:|
| baseline | 2 | 17.046 | 61.123 | 62.926 |
| candidate | 2 | 17.077 | 54.541 | 55.945 |

| Version/run | Peak step | Peak ms | Awake bodies | Contacts | Stress iterations | Misses >8 ms / >16.67 ms |
|---|---:|---:|---:|---:|---:|---:|
| baseline/impacts-256-plain-0 | 103 | 62.926 | 12072 | 109383 | 276 | 99 / 99 |
| baseline/impacts-256-plain-1 | 103 | 59.319 | 12072 | 109383 | 276 | 99 / 99 |
| candidate/impacts-256-plain-0 | 82 | 55.945 | 5376 | 1024 | 95 | 99 / 99 |
| candidate/impacts-256-plain-1 | 103 | 53.137 | 12072 | 109383 | 276 | 99 / 99 |

## Same-step comparisons

| Step | Baseline min / median / max ms | Candidate min / median / max ms |
|---|---:|---:|
| 82 | 52.445 / 52.861 / 53.277 | 51.458 / 53.701 / 55.945 |
| 103 | 59.319 / 61.123 / 62.926 | 53.137 / 54.006 / 54.875 |

## Separate instrumented phase captures

Host elapsed scopes include GPU waits. CUDA stages overlap these scopes and must not be added again. Each table compares the same step in both captures; instrumented timing is not the authoritative peak.

### Step 82

| Responsibility / owner | Baseline ms | Candidate ms |
|---|---:|---:|
| 🧮 Destruction submission and completion dependency — CPU submission/wait; GPU stress, loads and topology | 7.887 | 8.176 |
| 🚚 Fragment ownership and lifecycle bridge — CPU lifecycle/queries; GPU ownership updates | 16.740 | 15.624 |
| ⏪ Correction orchestration and repeated interaction — CPU scheduling; GPU restore, collision and solve | 28.833 | 31.180 |
| 📤 Accepted-state publication — CPU completion; GPU publication | 2.873 | 2.876 |
| 💾 Checkpoint — CPU submission; GPU copy | 0.026 | 0.010 |
| 🟰 Trial physics and unassigned scene tasks — PhysX CPU tasks and GPU physics | 3.127 | 3.328 |
| 📥 Recorded commands — CPU submission and GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion — CPU final completion boundary | 0.055 | 0.058 |

| Nested GPU stage (overlaps above) | Baseline ms | Candidate ms |
|---|---:|---:|
| commitAndStressTopology | 0.040 | 0.040 |
| contactLoads | 0.052 | 0.054 |
| materials | 0.074 | 0.075 |
| stress | 7.269 | 7.546 |
| topologyAndCandidates | 0.432 | 0.433 |

### Step 103

| Responsibility / owner | Baseline ms | Candidate ms |
|---|---:|---:|
| 🧮 Destruction submission and completion dependency — CPU submission/wait; GPU stress, loads and topology | 18.333 | 17.860 |
| 🚚 Fragment ownership and lifecycle bridge — CPU lifecycle/queries; GPU ownership updates | 7.922 | 8.841 |
| ⏪ Correction orchestration and repeated interaction — CPU scheduling; GPU restore, collision and solve | 25.215 | 19.060 |
| 📤 Accepted-state publication — CPU completion; GPU publication | 2.852 | 2.859 |
| 💾 Checkpoint — CPU submission; GPU copy | 0.010 | 0.009 |
| 🟰 Trial physics and unassigned scene tasks — PhysX CPU tasks and GPU physics | 7.914 | 8.595 |
| 📥 Recorded commands — CPU submission and GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion — CPU final completion boundary | 0.082 | 0.069 |

| Nested GPU stage (overlaps above) | Baseline ms | Candidate ms |
|---|---:|---:|
| commitAndStressTopology | 0.039 | 0.038 |
| contactLoads | 0.136 | 0.136 |
| materials | 0.067 | 0.067 |
| stress | 17.575 | 17.106 |
| topologyAndCandidates | 0.482 | 0.481 |

## Connectivity bookkeeping (whole run)

| Counter | Baseline range | Candidate range |
|---|---:|---:|
| host_connectivity_restores | 3–3 | 0–0 |
| cuda_pre_solve_node_full_snapshots | 4–4 | 1–1 |
| cuda_pre_solve_fallbacks | 4–4 | 1–1 |
| cuda_pre_solve_host_to_device_bytes | 699,216–699,216 | 305,400–305,400 |
| solver_metadata_full_uploads | 4–4 | 1–1 |
| solver_metadata_host_to_device_bytes | 156,936–156,936 | 3,072–3,072 |

## Quality and provenance

- Physical counter differences: **0**. Full differences are retained in JSON.
- Iteration-count differences: **13** across all comparisons, including separate phase captures. Iteration counts alone do not prove or disprove equal physical output.
- All captured solves report convergence and at most one correction. Counter agreement is not proof of identical trajectories.
- Independent physical, memory and lifecycle test evidence must accompany acceptance of a candidate.
- Raw samples are archived and checked against capture hashes. Both manifests retain commands and runtime hashes.
