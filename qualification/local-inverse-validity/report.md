# Preserve unchanged GPU local stress inverses

Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 aerial projectiles. Each run measures every complete advance for 180 steps / 3 simulated seconds; timestep 1/60 second, correction limit one, sleeping disabled. Two earlier baseline runs, five candidate runs, then two baseline control runs. Ordered short screens are not randomized five-minute qualification or endurance.

Timer includes commands, physics, destruction, correction, synchronization and runtime growth through committed completion. Initialization, rendering and report generation are excluded. Every measured step remains in the raw samples.

| Version | Runs | Mean complete ms | Median run peak ms | Worst complete ms |
|---|---|---|---|---|
| baseline | 4 | 17.272 | 60.499 | 61.697 |
| candidate | 5 | 17.054 | 59.195 | 60.396 |

This change deletes unnecessary local inverse reconstruction after fractures. It does not implement affected-only connectivity/hierarchy rebuilding or settled-island skipping. Peak ranges overlap; this short comparison is not evidence of a large peak improvement or a passing deadline.

| Version / batch | Repeat | Mean ms | Peak ms | Peak step | Misses >8 ms | Misses >16.67 ms |
|---|---|---|---|---|---|---|
| baseline / colored-sweep-baseline-control | 1 | 17.254 | 61.596 | 82 | 99 | 99 |
| baseline / colored-sweep-baseline-control | 2 | 17.348 | 59.144 | 103 | 99 | 99 |
| candidate / local-inverse-validity-impacts-256 | 1 | 16.986 | 59.195 | 103 | 99 | 99 |
| candidate / local-inverse-validity-impacts-256 | 2 | 17.040 | 60.359 | 103 | 99 | 99 |
| candidate / local-inverse-validity-impacts-256 | 3 | 17.082 | 58.388 | 103 | 99 | 99 |
| candidate / local-inverse-validity-impacts-256 | 4 | 16.985 | 59.150 | 103 | 99 | 99 |
| candidate / local-inverse-validity-impacts-256 | 5 | 17.175 | 60.396 | 103 | 99 | 99 |
| baseline / local-inverse-validity-baseline-control | 1 | 17.336 | 61.697 | 103 | 99 | 99 |
| baseline / local-inverse-validity-baseline-control | 2 | 17.148 | 59.401 | 103 | 99 | 99 |

## Peak workload

| Version / repeat | Bodies | Awake | Clusters | Contacts | Max stress iterations | Correction passes |
|---|---|---|---|---|---|---|
| baseline / colored-sweep-baseline-control / 1 | 5376 | 5376 | 5120 | 1024 | 95 | 1 |
| baseline / colored-sweep-baseline-control / 2 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |
| candidate / local-inverse-validity-impacts-256 / 1 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |
| candidate / local-inverse-validity-impacts-256 / 2 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |
| candidate / local-inverse-validity-impacts-256 / 3 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |
| candidate / local-inverse-validity-impacts-256 / 4 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |
| candidate / local-inverse-validity-impacts-256 / 5 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |
| baseline / local-inverse-validity-baseline-control / 1 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |
| baseline / local-inverse-validity-baseline-control / 2 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |

## Separate instrumented phase capture

Baseline scoped peak: step 103, 63.466 ms. Candidate: step 103, 63.546 ms. CPU elapsed scopes include GPU waits; CUDA stages overlap and must not be added again.

| Responsibility | CPU / GPU | Baseline ms | Candidate ms |
|---|---|---|---|
| 🧮 Destruction submission and completion dependency | CPU submit/wait; GPU stress | 20.406 | 19.933 |
| 🚚 Fragment ownership and lifecycle bridge | CPU lifecycle + GPU ownership | 8.558 | 8.742 |
| ⏪ Correction orchestration and repeated interaction | CPU scheduling + GPU restore/collision/solve | 23.292 | 24.156 |
| 📤 Accepted-state publication | CPU completion + GPU publication | 2.849 | 2.824 |
| 💾 Checkpoint | CPU submission + GPU copy | 0.011 | 0.010 |
| 🟰 Trial physics and unassigned scene tasks | PhysX CPU tasks + GPU physics | 8.299 | 7.816 |
| 📥 Recorded commands | CPU submission + GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion | CPU final boundary | 0.051 | 0.066 |

| Overlapping GPU stage | Baseline ms | Candidate ms |
|---|---|---|
| commitAndStressTopology | 0.039 | 0.038 |
| contactLoads | 0.136 | 0.138 |
| materials | 0.065 | 0.066 |
| stress | 19.649 | 19.178 |
| topologyAndCandidates | 0.482 | 0.483 |

## What changed and why it is valid

- Local inverse coefficients depend only on live incident bonds and immutable coupling/inertia/offset data. Loads, connectivity labels and rigid-mode projection do not enter those local coefficients.
- Inside the validated GPU topology transaction, each cached node checks its incident removal mask. Changed, unknown and stale entries lose validity. Unchanged entries carry their generation certificate forward without touching the packed inverse.
- One additional GPU validation pass on topology changes; no extra allocation, CPU observation or host decision. Unchanged topology remains guarded out. The reference solver is unchanged.
- Bond insertion/resurrection is rejected by the existing resident topology API. Future mutable coefficients must invalidate this cache explicitly; this implementation does not claim support for silent coefficient mutation.
- The CPU actor/contact/query lifecycle bridge remains. This optimization removes GPU rebuild work; it does not represent completion of the CPU-to-GPU ownership migration.

## Validation and remaining gates

- Native analytic, 3D and motion suites pass existing tolerances. Focused cache lifetime fixture: 6 nodes / 5 bonds, shared support; six cold/unknown/stale/internal-cut/support-cut/repeated-removal cases.
- Motion/cache and full native analytic initcheck report zero errors. Existing inverse basis and public removal/doubled-load/zero-load tests still pass.
- Frozen penetration: 444 chunks / 896 bonds, one projectile, ten simulated seconds; exact controlled topology signature, both-wall clearance, 398 retained chunks, 46 detached, 199 broken bonds, correction maximum one.
- All 9 untraced runs match the recorded body/contact/fracture/convergence histories. Stress iteration histories have 20 differing step comparisons. Counter agreement alone is not bit-identical chaotic trajectory proof.
- No scene passes the required 8 ms peak campaign here; these screens are not five 60-second runs or the 10-minute lifecycle endurance gate.

## Reproduce

Run `python3 qualification/local-inverse-validity/generate_report.py`. Archived raw samples are checked against capture manifests, physical configuration, complete-step accounting and frozen quality. The script regenerates Markdown, HTML and JSON without manual timing tables.
