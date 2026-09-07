# Resident polynomial preconditioner — short-run qualification

The two-stage candidate is retained for lower repeated stress cost, with unchanged physical acceptance and matched scene counters. The absolute worst complete-step result is nearly unchanged, and the full 8 ms / 60 Hz objective is not met. Every measured candidate peak, including the earlier 64.135 ms result, remains below.

## Workload and protocol

256 buildings, 113,664 chunks, 229,376 bonds and 256 simultaneous aerial projectiles. Each run advances 180 steps / 3 simulated seconds, dt=1/60 s, maximum one correction, sleeping disabled. Chunks share cluster motion; they are not 113,664 independently simulated rigid bodies. At step 103 the recorded body/awake counts are 12,072 / 12,072, including 256 projectiles; the logical cluster count is 11,816. These body counters come from the scene scheduler, not a separately qualified GPU sleep mask.

Timing includes commands, insertion, simulation, destruction, correction, capacity growth and mandatory completion. Initialization, rendering, encoding and report generation are excluded. Each campaign has warm-up; every measured step is retained. Separate phase captures are instrumented and are not substituted for untraced deadline timing.

The baseline consists of two earlier runs, five recent baseline repeats and five reverse-order control repeats. The candidate has its initial two runs and five follow-up repeats. The reverse control checks batch drift; runs are not randomized individual-run interleaving. The unequal sample counts and short duration do not establish a statistical worst-case bound. These are not the planned five 60-second acceptance runs or the 10-minute endurance test.

## All complete-step results

| Arm / batch | Repeat | Mean ms | Peak ms | Peak step | Steps >8 ms | Steps >16.67 ms |
|---|---|---|---|---|---|---|
| baseline / adjacency-before-impacts-256 | 1 | 18.571 | 61.630 | 103 | 99 | 99 |
| baseline / adjacency-before-impacts-256 | 2 | 18.585 | 62.456 | 103 | 99 | 99 |
| baseline / adjacency-baseline-repeat | 1 | 18.596 | 63.372 | 103 | 99 | 99 |
| baseline / adjacency-baseline-repeat | 2 | 18.554 | 62.515 | 103 | 99 | 99 |
| baseline / adjacency-baseline-repeat | 3 | 18.764 | 61.904 | 103 | 99 | 99 |
| baseline / adjacency-baseline-repeat | 4 | 18.539 | 61.667 | 103 | 99 | 99 |
| baseline / adjacency-baseline-repeat | 5 | 18.613 | 62.821 | 103 | 99 | 99 |
| candidate / polynomial2-impacts-256 | 1 | 18.045 | 57.798 | 103 | 99 | 99 |
| candidate / polynomial2-impacts-256 | 2 | 17.992 | 64.135 | 103 | 99 | 99 |
| candidate / polynomial2-repeat-impacts-256 | 1 | 17.924 | 60.165 | 103 | 99 | 99 |
| candidate / polynomial2-repeat-impacts-256 | 2 | 17.896 | 59.945 | 103 | 99 | 98 |
| candidate / polynomial2-repeat-impacts-256 | 3 | 18.000 | 61.585 | 103 | 99 | 99 |
| candidate / polynomial2-repeat-impacts-256 | 4 | 17.924 | 59.958 | 103 | 99 | 98 |
| candidate / polynomial2-repeat-impacts-256 | 5 | 17.854 | 60.697 | 103 | 99 | 99 |
| baseline / polynomial2-baseline-control | 1 | 18.700 | 64.265 | 103 | 99 | 99 |
| baseline / polynomial2-baseline-control | 2 | 18.730 | 63.362 | 103 | 99 | 99 |
| baseline / polynomial2-baseline-control | 3 | 18.564 | 62.372 | 103 | 99 | 99 |
| baseline / polynomial2-baseline-control | 4 | 18.599 | 62.301 | 103 | 99 | 99 |
| baseline / polynomial2-baseline-control | 5 | 18.775 | 63.615 | 103 | 99 | 99 |

| All retained samples | Runs | Mean complete ms | Median run peak ms | Absolute worst complete ms |
|---|---|---|---|---|
| baseline | 12 | 18.632 | 62.485 | 64.265 |
| candidate | 7 | 17.948 | 60.165 | 64.135 |

Median run peak describes repeatability; it never replaces the absolute maximum for deadline acceptance. Neither arm passes 8 ms or 16.67 ms on every step.

## Separate phase breakdown

These rows compare each version’s instrumented peak. CPU elapsed scopes below partition the step; GPU stages in the next table overlap those scopes and must not be added to them. The baseline phase capture is the reverse control; the candidate capture accompanies its initial two timing runs.

| Responsibility | Owner | Baseline scoped peak ms | Candidate scoped peak ms |
|---|---|---|---|
| 🧮 Destruction submission and completion dependency | CPU submit/wait enclosing GPU destruction | 20.748 | 19.189 |
| 🚚 Fragment ownership and lifecycle bridge | CPU lifecycle/registration plus GPU slot and binding work | 7.914 | 8.536 |
| ⏪ Correction orchestration and repeated interaction | CPU scheduling plus GPU restore, collision and solve | 23.617 | 25.186 |
| 📤 Accepted-state publication | CPU completion plus GPU accepted-state publication | 2.842 | 2.852 |
| 🟰 Trial physics and unassigned scene tasks | PhysX CPU task scheduling plus GPU trial physics | 8.070 | 8.373 |
| 💾 Checkpoint | CPU submission, GPU motion copy | 0.011 | 0.011 |
| 📥 Recorded commands | CPU submission plus GPU command application | 0.000 | 0.000 |
| ✅ Mandatory completion | CPU completion boundary and GPU status observation | 0.060 | 0.072 |

| GPU stream stage | Baseline mean ms | Candidate mean ms | Baseline scoped peak ms | Candidate scoped peak ms |
|---|---|---|---|---|
| GPU: stress preparation and solve | 11.313 | 10.713 | 19.988 | 18.426 |
| GPU: solved contacts to chunk loads | 0.093 | 0.093 | 0.136 | 0.138 |
| GPU: material and damage verdicts | 0.070 | 0.070 | 0.067 | 0.068 |
| GPU: connectivity and fracture candidates | 0.239 | 0.240 | 0.486 | 0.485 |
| GPU: commit health and update stress topology | 0.144 | 0.145 | 0.038 | 0.039 |

## Numerical work and fidelity

At the same bombardment step 103, the reported maximum stress iteration count decreases from 537 to 280. A separate intact gravity-only fixture (256 buildings, the same chunk/bond counts; no projectile, physics response or correction) decreases from 86 to 45 iterations per building. These counts alone are not performance: each preconditioned update adds one cross-endpoint sparse traversal and a second cached local-inverse application. Existing outer-operator visit counters exclude those preconditioner operations. Complete timing includes them.

- Independent long-double polynomial oracle: 12 nodes / 20 bonds, both supported and free; all basis vectors, symmetry and positive definiteness pass. Existing full native analytical and 3D force/residual tests pass their unchanged thresholds.
- Candidate CUDA memory and synchronization checks pass. The expanded initialization audit exposed a separate reference first-iteration history read; commit 8c9a7146 fixes that read. The full initialization audit then passes with zero errors. Baseline reverse control and candidate both include that fix; it does not execute in the native projected component path.
- Final frozen penetration audit: 444 chunks, 896 bonds, one projectile, 10 simulated seconds. Same topology identity, both-wall clearance, 398 supported chunks, 46 detached chunks, 199 broken bonds, convergence and maximum one correction pass.
- All 19 untraced runs match the listed body/contact/fracture/convergence counters. Iteration counts differ in 703 step comparisons as expected. Counts are not proof of identical chaotic trajectories; the independent controlled audit is separate evidence.
- Four-stage polynomial and unfused two-stage probes are retained as intermediate diagnostics. Only the fused two-stage expression is active; no tuning switch or extra production backend is introduced.

## What remains

The reduction is useful but insufficient for massive real-time destruction. Stress still exceeds the desired total deadline during impacts, while correction orchestration and the ownership bridge remain major independent peak costs. The next changes must reduce those costs without dropping physical work, relaxing acceptance or hiding measured spikes. See ALGORITHM.md for the exact resident data flow and numerical identity.

## Reproduce

Run python3 qualification/polynomial-preconditioner/generate_report.py. It verifies archived raw samples against campaign hashes, checks complete-timer accounting and physical counters, and regenerates Markdown, HTML and JSON. The input timing reports contain commands, hardware sampling and binary hashes. All durations, peaks and exclusions remain explicit.
