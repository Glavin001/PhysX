# GPU destruction candidate comparison

Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 767 projectiles; 720 steps / 12 simulated seconds per run. Correction limit 1; sleeping True.

Complete wall-clock advance includes commands, physics, destruction, correction, synchronization and runtime growth. Initialization, rendering and report generation are excluded. Every measured step is retained. These short, ordered screens do not establish the five 60-second peak gate or endurance.

| Version | Runs | Mean ms | Median run peak ms | Worst ms |
|---|---:|---:|---:|---:|
| baseline | 2 | 175.274 | 348.507 | 355.506 |
| candidate | 2 | 59.420 | 111.778 | 118.007 |

| Version/run | Peak step | Peak ms | Awake bodies | Contacts | Stress iterations | Misses >8 ms / >16.67 ms |
|---|---:|---:|---:|---:|---:|---:|
| baseline/sleeping-256-plain-0 | 642 | 355.506 | 19131 | 599789 | 353 | 639 / 638 |
| baseline/sleeping-256-plain-1 | 531 | 341.509 | 20383 | 618709 | 343 | 639 / 638 |
| candidate/sleeping-256-plain-0 | 397 | 105.549 | 17321 | 451764 | 364 | 639 / 638 |
| candidate/sleeping-256-plain-1 | 395 | 118.007 | 17093 | 449582 | 458 | 639 / 638 |

## Same-step comparisons

| Step | Baseline min / median / max ms | Candidate min / median / max ms |
|---|---:|---:|
| 395 | 194.197 / 211.432 / 228.667 | 75.030 / 96.519 / 118.007 |
| 397 | 195.440 / 204.614 / 213.788 | 78.663 / 92.106 / 105.549 |
| 531 | 290.944 / 316.227 / 341.509 | 76.762 / 79.224 / 81.686 |
| 642 | 318.870 / 337.188 / 355.506 | 71.872 / 73.672 / 75.473 |

## Separate instrumented phase captures

Host elapsed scopes include GPU waits. CUDA stages overlap these scopes and must not be added again. Each table compares the same step in both captures; instrumented timing is not the authoritative peak.

## Connectivity bookkeeping (whole run)

| Counter | Baseline range | Candidate range |
|---|---:|---:|
| host_connectivity_restores | 0–0 | 0–0 |
| cuda_pre_solve_node_full_snapshots | 1–1 | 1–1 |
| cuda_pre_solve_fallbacks | 1,202–1,206 | 1,227–1,233 |
| cuda_pre_solve_host_to_device_bytes | 758,968–780,408 | 889,264–909,968 |
| solver_metadata_full_uploads | 900–909 | 884–896 |
| solver_metadata_host_to_device_bytes | 129,561,264–131,555,492 | 156,084,892–158,033,804 |

## Quality and provenance

- Physical counter differences: **20075**. Full differences are retained in JSON.
- Iteration-count differences: **2493** across all comparisons, including separate phase captures. Iteration counts alone do not prove or disprove equal physical output.
- All captured solves report convergence and at most one correction. Counter agreement is not proof of identical trajectories.
- Independent physical, memory and lifecycle test evidence must accompany acceptance of a candidate.
- Raw samples are archived and checked against capture hashes. Both manifests retain commands and runtime hashes.
