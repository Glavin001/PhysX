# GPU destruction candidate comparison

Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles; 180 steps / 3 simulated seconds per run. Correction limit 1; sleeping False.

Complete wall-clock advance includes commands, physics, destruction, correction, synchronization and runtime growth. Initialization, rendering and report generation are excluded. Every measured step is retained. These short, ordered screens do not establish the five 60-second peak gate or endurance.

| Version | Runs | Mean ms | Median run peak ms | Worst ms |
|---|---:|---:|---:|---:|
| baseline | 2 | 16.998 | 60.193 | 63.034 |
| candidate | 2 | 16.806 | 53.931 | 55.269 |

| Version/run | Peak step | Peak ms | Awake bodies | Contacts | Stress iterations | Misses >8 ms / >16.67 ms |
|---|---:|---:|---:|---:|---:|---:|
| baseline/impacts-256-plain-0 | 82 | 63.034 | 5376 | 1024 | 95 | 99 / 99 |
| baseline/impacts-256-plain-1 | 82 | 57.353 | 5376 | 1024 | 95 | 99 / 99 |
| candidate/impacts-256-plain-0 | 82 | 52.593 | 5376 | 1024 | 95 | 99 / 98 |
| candidate/impacts-256-plain-1 | 82 | 55.269 | 5376 | 1024 | 95 | 99 / 99 |

## Same-step comparisons

| Step | Baseline min / median / max ms | Candidate min / median / max ms |
|---|---:|---:|
| 82 | 57.353 / 60.193 / 63.034 | 52.593 / 53.931 / 55.269 |

## Separate instrumented phase captures

Host elapsed scopes include GPU waits. CUDA stages overlap these scopes and must not be added again. Each table compares the same step in both captures; instrumented timing is not the authoritative peak.

### Step 82

| Responsibility / owner | Baseline ms | Candidate ms |
|---|---:|---:|
| 🧮 Destruction submission and completion dependency — CPU submission/wait; GPU stress, loads and topology | 8.237 | 8.288 |
| 🚚 Fragment ownership and lifecycle bridge — CPU lifecycle/queries; GPU ownership updates | 15.723 | 16.695 |
| ⏪ Correction orchestration and repeated interaction — CPU scheduling; GPU restore, collision and solve | 33.122 | 29.137 |
| 📤 Accepted-state publication — CPU completion; GPU publication | 2.996 | 2.380 |
| 💾 Checkpoint — CPU submission; GPU copy | 0.006 | 0.010 |
| 🟰 Trial physics and unassigned scene tasks — PhysX CPU tasks and GPU physics | 3.364 | 3.411 |
| 📥 Recorded commands — CPU submission and GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion — CPU final completion boundary | 0.064 | 0.063 |

| Nested GPU stage (overlaps above) | Baseline ms | Candidate ms |
|---|---:|---:|
| commitAndStressTopology | 0.038 | 0.044 |
| contactLoads | 0.059 | 0.063 |
| materials | 0.077 | 0.075 |
| stress | 7.586 | 7.621 |
| topologyAndCandidates | 0.454 | 0.457 |

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
- Iteration-count differences: **11** across all comparisons, including separate phase captures. Iteration counts alone do not prove or disprove equal physical output.
- All captured solves report convergence and at most one correction. Counter agreement is not proof of identical trajectories.
- Independent physical, memory and lifecycle test evidence must accompany acceptance of a candidate.
- Raw samples are archived and checked against capture hashes. Both manifests retain commands and runtime hashes.
