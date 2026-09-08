# Colored symmetric stress sweep — rejected from production

Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 aerial projectiles; 180 steps / 3 simulated seconds per run, fixed 1/60 second timestep, correction limit one, sleeping disabled. Two complete untraced runs per version, plus separate phase captures. Candidate ran first, then the restored baseline; these are short ordered screens, not randomized long qualification or endurance.

Timer: recorded command application through accepted simulation/destruction/event completion. Includes physics, stress, topology/lifecycle, correction and synchronization. Rendering, encoding and initialization excluded; all measured steps and spikes retained.

| Version | Repeat | Mean complete ms | Peak complete ms | Peak step | Steps >8 ms | Steps >16.67 ms |
|---|---|---|---|---|---|---|
| candidate | 1 | 20.769 | 68.182 | 103 | 99 | 99 |
| candidate | 2 | 20.717 | 66.043 | 103 | 99 | 99 |
| baseline | 1 | 17.254 | 61.596 | 82 | 99 | 99 |
| baseline | 2 | 17.348 | 59.144 | 103 | 99 | 99 |

The candidate does not establish a performance win. Its implementation and added tests were archived as a patch and reverted; the previously qualified polynomial + unaffected warm-start runtime is restored. Neither implementation meets the peak deadline.

## Work at each complete-step peak

| Version / repeat | Bodies | Awake bodies | Clusters | Contacts this step | Stress updates (maximum) | Corrections |
|---|---|---|---|---|---|---|
| candidate / 1 | 12072 | 12072 | 11816 | 109383 | 266 | 1 |
| candidate / 2 | 12072 | 12072 | 11816 | 109383 | 266 | 1 |
| baseline / 1 | 5376 | 5376 | 5120 | 1024 | 95 | 1 |
| baseline / 2 | 12072 | 12072 | 11816 | 109383 | 276 | 1 |

## Separate instrumented peak phases

CPU elapsed scopes below include GPU work/waits and partition each scoped peak: baseline step 103 (63.913 ms), candidate step 103 (69.384 ms). The CUDA durations below overlap these scopes and must not be added again.

| Responsibility | Owner | Baseline ms | Candidate ms |
|---|---|---|---|
| 🧮 Destruction submission and completion dependency | CPU submit/wait; GPU stress | 19.310 | 26.409 |
| 🚚 Fragment ownership and lifecycle bridge | CPU lifecycle + GPU ownership | 8.344 | 8.151 |
| ⏪ Correction orchestration and repeated interaction | CPU scheduling + GPU restore/collision/solve | 25.210 | 23.229 |
| 📤 Accepted-state publication | CPU completion + GPU publication | 2.852 | 2.842 |
| 💾 Checkpoint | CPU submission + GPU copy | 0.010 | 0.009 |
| 🟰 Trial physics and unassigned scene tasks | PhysX CPU tasks + GPU physics | 8.131 | 8.650 |
| 📥 Recorded commands | CPU submission + GPU execution | 0.000 | 0.000 |
| ✅ Mandatory completion | CPU final boundary | 0.058 | 0.096 |

| Overlapping GPU stage | Baseline ms | Candidate ms |
|---|---|---|
| commitAndStressTopology | 0.039 | 0.038 |
| contactLoads | 0.135 | 0.137 |
| materials | 0.067 | 0.067 |
| stress | 18.557 | 25.654 |
| topologyAndCandidates | 0.482 | 0.485 |

## Quality and interpretation

- Independent 12-node / 30-bond anchored and free fixtures assemble the physical matrix in long double and check all basis responses, symmetry and positive definiteness. Coloring is checked against independent sequential first-fit, including odd cycles and reuse after edge removal. Existing tolerances were not relaxed.
- Native analytic, 3D and motion suites pass. The focused motion/sweep memcheck and 256-building gravity-only synccheck report zero errors.
- Frozen penetration: 444 chunks / 896 bonds, one projectile, 10 simulated seconds. Both-wall clearance, 398 retained chunks, 46 detached, 199 broken bonds, exact controlled topology signature and at most one correction pass.
- Initial coloring probe stalled due to a cooperative round-counter race. It was terminated, the missing read-before-reset barrier was added, and the corrected scale probe completed under synccheck.
- Isolated instrumented gravity-only probe: 256 intact buildings / 113,664 chunks / 229,376 bonds; 44 iterations and 6.302823 ms for its cold stress submit/completion. No projectiles, rigid-body physics, damage or correction. This is not an end-to-end simulation timing.
- Fewer maximum stress updates at the bombardment peak do not compensate for more expensive updates. This is measured end-to-end evidence, not proof of a hardware bandwidth or compute limit.
- Physical counter-history differences against the first baseline run are recorded below. Matching counters do not prove identical chaotic trajectories.

```json
{
  "baseline-1": {
    "awake_bodies": 0,
    "bodies": 0,
    "bonds_broken": 0,
    "contacts_frame": 0,
    "logical_clusters": 0,
    "resim_passes": 0,
    "stress_active_bonds": 0,
    "stress_active_nodes": 0,
    "stress_converged": 0,
    "stress_islands": 0
  },
  "baseline-2": {
    "awake_bodies": 0,
    "bodies": 0,
    "bonds_broken": 0,
    "contacts_frame": 0,
    "logical_clusters": 0,
    "resim_passes": 0,
    "stress_active_bonds": 0,
    "stress_active_nodes": 0,
    "stress_converged": 0,
    "stress_islands": 0
  },
  "candidate-1": {
    "awake_bodies": 0,
    "bodies": 0,
    "bonds_broken": 0,
    "contacts_frame": 0,
    "logical_clusters": 0,
    "resim_passes": 0,
    "stress_active_bonds": 0,
    "stress_active_nodes": 0,
    "stress_converged": 0,
    "stress_islands": 0
  },
  "candidate-2": {
    "awake_bodies": 0,
    "bodies": 0,
    "bonds_broken": 0,
    "contacts_frame": 0,
    "logical_clusters": 0,
    "resim_passes": 0,
    "stress_active_bonds": 0,
    "stress_active_nodes": 0,
    "stress_converged": 0,
    "stress_islands": 0
  }
}
```

## Reproduce

Run `python3 qualification/colored-sweep-evaluation/generate_report.py`. The generator validates archived sample hashes, configuration, physical workload, complete-step metrics and controlled quality. Capture reports preserve exact commands and binary hashes. `candidate.patch` records all rejected source/test changes; `artifacts.json` records its base revision and runtime hashes.
