# Downtown idle scheduling fix

27 buildings, **24,105 chunks / 74,543 bonds** on RTX 4090. Each arm runs 600 steps / 10 simulated seconds. Direct GPU off, native sleeping on, dt 1/60, at most one correction and two stress evaluations per tick.

Timer: physical commands through accepted physics, stress, fracture/correction, mandatory events and game snapshot staging. Excludes initial asset preparation, rendering, network encoding and report generation. Every step, including step zero, is retained.

| Run | Steps | Projectiles | Min ms | Mean ms | Median ms | All-step max ms | Impact/aftermath max ms | New-fracture max ms | >16.67 ms steps |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| baseline-idle | 600 | 0 | 38.611 | 43.674 | 38.834 | 2907.103 | — | — | 600 |
| candidate-idle | 600 | 0 | 4.124 | 5.233 | 4.201 | 615.273 | — | — | 1 |
| baseline-impact | 600 | 3 | 21.591 | 591.284 | 624.160 | 2899.945 | 2450.005 | 2450.005 | 600 |
| candidate-impact | 600 | 3 | 3.719 | 63.970 | 62.720 | 726.606 | 726.606 | 726.606 | 542 |

Impact/aftermath starts at the first recorded command and includes settling. New-fracture peaks select steps that actually increase broken-bond count. Neither replaces the all-step deadline gate. Idle has no destruction or fragment bodies.

## What changed

The coarse hierarchy retained tens of thousands of bond contributions while reducing node count. Eight-lane row processing serialized that work. Long coarse rows now use full CUDA blocks, FP64 accumulation and a shared reduction schedule for cooperative and block-local execution. No bonds, stress iterations, convergence requirements or material evaluations are suppressed.

The isolated baseline phase replay measured about 38.4 ms in CUDA stress per steady idle advance. A separate kernel trace identified persistentStressSolve; temporary internal probes identified coarse residual/restriction/correction reductions. These diagnostic timings are separate from the untraced table.

## Validation and limits

Resident analytic/3D/motion suites, the independent dense V-cycle oracle, a new 24-node / 1,472-bond parallel-column fixture, synchronization checks, ordinary-scene tests and the frozen 444-chunk / 896-bond / one-projectile penetration audit are recorded alongside the capture. The frozen wall retains 398 chunks and detaches 46 with 199 broken bonds.

Downtown impact runs end with the same broken-bond/fragment totals, but are not bit-identical trajectories. Per-step counter differences are retained in analysis.json: {'broken_bonds': [463, 464, 465], 'fragment_bodies': [463, 464, 465], 'awake_fragment_bodies': [463, 466], 'native_corrections': [463, 466]}. These differences do not replace the unchanged exact frozen-wall gate.

The separate 256-building bombardment screen uses 113,664 chunks, 229,376 bonds and 768 projectiles for 600 steps. It still fails real-time peaks; this is a downtown idle fix, not large-destruction completion. One paired run per regime is a short screen, not five-trial or endurance qualification. Startup peaks remain failures.

Qualified runtime SHA-256: `007cf78206ac00abdacf5498d7244cd5fd1c3678597be9e67c57f2d8ca5e0372`.

[Machine-readable report and accepted-work counts](analysis.json). All paired raw samples and input tapes are archived as compressed JSON alongside this file.
