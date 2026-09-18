# GPU affected-component warm starts

🟡 Implemented and short-run tested. Full peak and endurance gates remain incomplete. Preserve the initial guess only for unchanged components; every solve still evaluates its current loads and true residual. Changed old components cold-start before relabeling, including internal cuts and removed support bonds.

## Workload and timing

256 buildings, 113,664 chunks, 229,376 bonds, 256 simultaneous aerial projectiles; 180 steps / 3 simulated seconds per run; timestep 1/60 second, correction limit one, sleeping disabled. At peak step 103: 12,072 recorded bodies/awake bodies, 11,816 destruction clusters and 109,383 contacts. Body/awake counters are scene scheduler observations, not an independently qualified device sleep mask.

Complete timing includes commands, insertion, physics, stress/destruction, correction, capacity growth and mandatory completion. Initialization, rendering and report generation are excluded. Separate warm-up processes are excluded; every measured step remains. Earlier polynomial runs plus a reverse-order baseline control are compared with all candidate runs. These unequal-sized, short batches are not randomized trials, five 60-second acceptance runs, or 10-minute endurance.

| Version | Runs | Mean complete ms | Median run peak ms | Worst complete ms |
|---|---|---|---|---|
| baseline | 9 | 17.958 | 60.165 | 64.135 |
| candidate | 7 | 17.352 | 60.445 | 62.260 |

The candidate lowers repeated mean cost, but does not establish a peak improvement: median run peaks are slightly worse, and observed absolute maxima are not a worst-case bound. Retain it for correct unaffected-component reuse, not as a demonstrated real-time peak fix. Neither version passes 8 ms or every-step 60 Hz.

| Version / batch | Repeat | Mean ms | Peak ms | Peak step | Misses >8 ms | Misses >16.67 ms |
|---|---|---|---|---|---|---|
| baseline / polynomial2-impacts-256 | 1 | 18.045 | 57.798 | 103 | 99 | 99 |
| baseline / polynomial2-impacts-256 | 2 | 17.992 | 64.135 | 103 | 99 | 99 |
| baseline / polynomial2-repeat-impacts-256 | 1 | 17.924 | 60.165 | 103 | 99 | 99 |
| baseline / polynomial2-repeat-impacts-256 | 2 | 17.896 | 59.945 | 103 | 99 | 98 |
| baseline / polynomial2-repeat-impacts-256 | 3 | 18.000 | 61.585 | 103 | 99 | 99 |
| baseline / polynomial2-repeat-impacts-256 | 4 | 17.924 | 59.958 | 103 | 99 | 98 |
| baseline / polynomial2-repeat-impacts-256 | 5 | 17.854 | 60.697 | 103 | 99 | 99 |
| candidate / affected-warm-impacts-256 | 1 | 17.302 | 60.561 | 103 | 99 | 98 |
| candidate / affected-warm-impacts-256 | 2 | 17.263 | 58.820 | 103 | 99 | 99 |
| candidate / affected-warm-repeat-256 | 1 | 17.324 | 59.050 | 103 | 99 | 99 |
| candidate / affected-warm-repeat-256 | 2 | 17.498 | 62.059 | 82 | 99 | 99 |
| candidate / affected-warm-repeat-256 | 3 | 17.468 | 62.260 | 103 | 99 | 99 |
| candidate / affected-warm-repeat-256 | 4 | 17.428 | 60.407 | 103 | 99 | 99 |
| candidate / affected-warm-repeat-256 | 5 | 17.178 | 60.445 | 103 | 99 | 98 |
| baseline / affected-warm-baseline-control | 1 | 17.953 | 59.470 | 103 | 99 | 99 |
| baseline / affected-warm-baseline-control | 2 | 18.029 | 60.821 | 82 | 99 | 99 |

## Separate instrumented peak phases

These CPU elapsed groups partition each instrumented step and include GPU waits. GPU stress timing below overlaps them; do not add it again. Controls include the same NVIDIA physics.

| Responsibility | Owner | Baseline ms | Candidate ms |
|---|---|---|---|
| 🧮 Destruction submission and completion dependency | CPU submit/wait; GPU destruction | 18.598 | 19.155 |
| 🚚 Fragment ownership and lifecycle bridge | CPU lifecycle plus GPU slots/ownership | 8.765 | 7.835 |
| ⏪ Correction orchestration and repeated interaction | CPU scheduling; GPU restore/collision/solve | 24.018 | 24.118 |
| 📤 Accepted-state publication | CPU completion; GPU publication | 2.838 | 2.836 |
| 💾 Checkpoint | CPU submission; GPU copy | 0.010 | 0.012 |
| 🟰 Trial physics and unassigned scene tasks | PhysX CPU tasks and GPU physics | 7.925 | 8.338 |
| 📥 Recorded commands | CPU submission; GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion | CPU completion boundary | 0.062 | 0.095 |

GPU stages at those same scoped peaks:

| Stage | Baseline ms | Candidate ms |
|---|---|---|
| GPU commitAndStressTopology | 0.039 | 0.040 |
| GPU contactLoads | 0.138 | 0.136 |
| GPU materials | 0.067 | 0.067 |
| GPU stress | 17.836 | 18.397 |
| GPU topologyAndCandidates | 0.487 | 0.480 |

## Correctness and limits

- All compared untraced runs match body, contact, fracture and convergence histories. Iterations may differ; matching counters alone do not prove identical chaotic trajectories.
- Independent native analytic and 3D force tests pass unchanged tolerances. Two supported columns (64 nodes, 62 bonds) verify removal, doubled and zero loads: the untouched column needs zero iterations after fracture versus 30 initially, with a fresh residual check.
- Device storage checks cover 9 nodes / 7 bonds: cold initialization, unchanged topology, internal cut, support cut and a different affected component. No allocation or CPU transfer is added; existing root-flag scratch is reused before relabeling.
- Full native analytic initcheck and small motion/topology memcheck report zero errors; memcheck reports no leaks.
- Frozen wall: 444 chunks, 896 bonds, one projectile, 10 simulated seconds; same identity signature, both-wall clearance, 398 retained chunks, 46 detached, 199 broken bonds, correction limit one.
- Remaining global partition/hierarchy rebuild and inverse-cache invalidation are NOT solved by retaining bond initial guesses. General settled-component skipping is still absent. The peak is still dominated by real stress work and correction/ownership costs.
- Changes are limited to native topology transactions. The reference implementation retains global cold restarts. No physical tolerances, equations, materials, damage accounting or correction limits changed.

## Reproduce

Run `python3 qualification/affected-warm-start/generate_report.py`. Archived raw samples are verified against capture manifests; generated Markdown, HTML and JSON retain every measured peak. Campaign reports record commands, GPU observations and binary hashes.
