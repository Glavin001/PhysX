# GPU destruction candidate comparison

Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles; 180 steps / 3 simulated seconds per run. Correction limit 1; sleeping False.

Complete wall-clock advance includes commands, physics, destruction, correction, synchronization and runtime growth. Initialization, rendering and report generation are excluded. Every measured step is retained. These short, ordered screens do not establish the five 60-second peak gate or endurance.

| Version | Runs | Mean ms | Median run peak ms | Worst ms |
|---|---:|---:|---:|---:|
| baseline | 2 | 16.751 | 55.925 | 58.579 |
| candidate | 2 | 16.740 | 55.917 | 58.068 |

| Version/run | Peak step | Peak ms | Awake bodies | Contacts | Stress iterations | Misses >8 ms / >16.67 ms |
|---|---:|---:|---:|---:|---:|---:|
| baseline/impacts-256-plain-0 | 82 | 58.579 | 5376 | 1024 | 95 | 99 / 99 |
| baseline/impacts-256-plain-1 | 103 | 53.271 | 12072 | 109383 | 276 | 99 / 99 |
| candidate/impacts-256-plain-0 | 103 | 53.766 | 12072 | 109383 | 276 | 99 / 98 |
| candidate/impacts-256-plain-1 | 82 | 58.068 | 5376 | 1024 | 95 | 99 / 99 |

## Same-step comparisons

| Step | Baseline min / median / max ms | Candidate min / median / max ms |
|---|---:|---:|
| 82 | 51.605 / 55.092 / 58.579 | 51.571 / 54.819 / 58.068 |
| 103 | 51.932 / 52.601 / 53.271 | 53.766 / 53.822 / 53.879 |

## Separate instrumented phase captures

Host elapsed scopes include GPU waits. CUDA stages overlap these scopes and must not be added again. Each table compares the same step in both captures; instrumented timing is not the authoritative peak.

### Step 82

| Responsibility / owner | Baseline ms | Candidate ms |
|---|---:|---:|
| 🧮 Destruction submission and completion dependency — CPU submission/wait; GPU stress, loads and topology | 8.280 | 8.200 |
| 🚚 Fragment ownership and lifecycle bridge — CPU lifecycle/queries; GPU ownership updates | 16.523 | 16.355 |
| ⏪ Correction orchestration and repeated interaction — CPU scheduling; GPU restore, collision and solve | 26.393 | 31.951 |
| 📤 Accepted-state publication — CPU completion; GPU publication | 2.283 | 2.247 |
| 💾 Checkpoint — CPU submission; GPU copy | 0.012 | 0.009 |
| 🟰 Trial physics and unassigned scene tasks — PhysX CPU tasks and GPU physics | 3.295 | 3.452 |
| 📥 Recorded commands — CPU submission and GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion — CPU final completion boundary | 0.074 | 0.062 |

| Nested GPU stage (overlaps above) | Baseline ms | Candidate ms |
|---|---:|---:|
| commitAndStressTopology | 0.044 | 0.043 |
| contactLoads | 0.065 | 0.062 |
| materials | 0.076 | 0.077 |
| stress | 7.618 | 7.539 |
| topologyAndCandidates | 0.457 | 0.454 |

### Step 103

| Responsibility / owner | Baseline ms | Candidate ms |
|---|---:|---:|
| 🧮 Destruction submission and completion dependency — CPU submission/wait; GPU stress, loads and topology | 18.168 | 18.267 |
| 🚚 Fragment ownership and lifecycle bridge — CPU lifecycle/queries; GPU ownership updates | 8.796 | 8.104 |
| ⏪ Correction orchestration and repeated interaction — CPU scheduling; GPU restore, collision and solve | 17.818 | 18.531 |
| 📤 Accepted-state publication — CPU completion; GPU publication | 2.312 | 2.281 |
| 💾 Checkpoint — CPU submission; GPU copy | 0.009 | 0.011 |
| 🟰 Trial physics and unassigned scene tasks — PhysX CPU tasks and GPU physics | 8.689 | 8.242 |
| 📥 Recorded commands — CPU submission and GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion — CPU final completion boundary | 0.087 | 0.063 |

| Nested GPU stage (overlaps above) | Baseline ms | Candidate ms |
|---|---:|---:|
| commitAndStressTopology | 0.041 | 0.041 |
| contactLoads | 0.137 | 0.137 |
| materials | 0.071 | 0.070 |
| stress | 17.389 | 17.490 |
| topologyAndCandidates | 0.498 | 0.499 |

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
- Iteration-count differences: **8** across all comparisons, including separate phase captures. Iteration counts alone do not prove or disprove equal physical output.
- All captured solves report convergence and at most one correction. Counter agreement is not proof of identical trajectories.
- Independent physical, memory and lifecycle test evidence must accompany acceptance of a candidate.
- Raw samples are archived and checked against capture hashes. Both manifests retain commands and runtime hashes.
