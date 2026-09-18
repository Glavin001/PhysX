# GPU destruction candidate comparison

Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 767 projectiles; 720 steps / 12 simulated seconds per run. Correction limit 1; sleeping True.

Complete wall-clock advance includes commands, physics, destruction, correction, synchronization and runtime growth. Initialization, rendering and report generation are excluded. Every measured step is retained. These short, ordered screens do not establish the five 60-second peak gate or endurance.

| Version | Runs | Mean ms | Median run peak ms | Worst ms |
|---|---:|---:|---:|---:|
| baseline | 2 | 59.420 | 111.778 | 118.007 |
| candidate | 2 | 57.481 | 117.358 | 124.409 |

| Version/run | Peak step | Peak ms | Awake bodies | Contacts | Stress iterations | Misses >8 ms / >16.67 ms |
|---|---:|---:|---:|---:|---:|---:|
| baseline/sleeping-256-plain-0 | 397 | 105.549 | 17321 | 451764 | 364 | 639 / 638 |
| baseline/sleeping-256-plain-1 | 395 | 118.007 | 17093 | 449582 | 458 | 639 / 638 |
| candidate/sleeping-256-plain-0 | 392 | 124.409 | 17585 | 462789 | 408 | 639 / 638 |
| candidate/sleeping-256-plain-1 | 402 | 110.307 | 17192 | 461692 | 410 | 639 / 638 |

## Same-step comparisons

| Step | Baseline min / median / max ms | Candidate min / median / max ms |
|---|---:|---:|
| 392 | 70.455 / 72.882 / 75.308 | 73.764 / 99.086 / 124.409 |
| 395 | 75.030 / 96.519 / 118.007 | 76.131 / 76.770 / 77.410 |
| 397 | 78.663 / 92.106 / 105.549 | 75.837 / 79.212 / 82.586 |
| 402 | 75.022 / 78.041 / 81.059 | 76.898 / 93.602 / 110.307 |

## Separate instrumented phase captures

Host elapsed scopes include GPU waits. CUDA stages overlap these scopes and must not be added again. Each table compares the same step in both captures; instrumented timing is not the authoritative peak.

## Connectivity bookkeeping (whole run)

| Counter | Baseline range | Candidate range |
|---|---:|---:|
| host_connectivity_restores | 0–0 | 0–0 |
| cuda_pre_solve_node_full_snapshots | 1–1 | 1–1 |
| cuda_pre_solve_fallbacks | 1,227–1,233 | 1,226–1,228 |
| cuda_pre_solve_host_to_device_bytes | 889,264–909,968 | 875,032–895,624 |
| solver_metadata_full_uploads | 884–896 | 856–884 |
| solver_metadata_host_to_device_bytes | 156,084,892–158,033,804 | 151,669,368–155,600,268 |

## Quality and provenance

- Physical counter differences: **18586**. Full differences are retained in JSON.
- Iteration-count differences: **2352** across all comparisons, including separate phase captures. Iteration counts alone do not prove or disprove equal physical output.
- All captured solves report convergence and at most one correction. Counter agreement is not proof of identical trajectories.
- Independent physical, memory and lifecycle test evidence must accompany acceptance of a candidate.
- Raw samples are archived and checked against capture hashes. Both manifests retain commands and runtime hashes.
