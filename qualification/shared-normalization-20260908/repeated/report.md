# Shared component normalization — repeated complete-step comparison

**256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles over 600 steps / 10 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. 3 baseline and 3 candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline-1 | 45.596 | 163.361 (0) | 140.902 (48) | 76,543 | 18,890 | 356 |
| baseline-2 | 45.033 | 162.529 (0) | 139.732 (48) | 76,634 | 19,008 | 339 |
| baseline-3 | 46.666 | 161.689 (0) | 136.912 (48) | 76,808 | 19,080 | 343 |
| candidate-1 | 44.298 | 158.945 (0) | 132.604 (48) | 76,237 | 18,745 | 327 |
| candidate-2 | 44.155 | 163.280 (0) | 134.733 (48) | 76,215 | 18,717 | 331 |
| candidate-3 | 44.881 | 158.906 (0) | 138.325 (48) | 76,255 | 18,759 | 338 |

Comparing the **worst run in each arm**, observed complete-peak reduction is **0.0%**; fracture-step peak reduction is **1.8%**. Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.
- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; these short runs are not a complete parity/endurance oracle.
- This report does not infer numerical-test, penetration or browser-test success from timing captures.

## Required idle and destruction measurements

| Run | Fresh intact idle | Idle min / mean / p50 / p95 / p99 / max ms | Impact + aftermath peak ms (tick) |
|---|---|---|---:|
| baseline-1 | no | not measured | 140.902 (48) |
| baseline-2 | no | not measured | 139.732 (48) |
| baseline-3 | no | not measured | 136.912 (48) |
| candidate-1 | no | not measured | 132.604 (48) |
| candidate-2 | no | not measured | 134.733 (48) |
| candidate-3 | no | not measured | 138.325 (48) |

This table retains step zero. Fresh intact idle requires an empty command tape, zero projectiles, zero broken bonds and zero fragment bodies throughout. A short pre-impact window or sleeping debris after damage does not replace the fresh idle run. The impact/aftermath interval starts with the first recorded command and includes late rubble costs, even on steps without new fractures.

**Paired performance qualification is incomplete in this single-regime comparison:** attach the matching intact-idle or destruction comparison for the same scene and settings. Both regimes are required.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- baseline-2 versus baseline-1: first difference at tick 71; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- baseline-3 versus baseline-1: first difference at tick 71; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-1 versus baseline-1: first difference at tick 71; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-2 versus baseline-1: first difference at tick 71; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-3 versus baseline-1: first difference at tick 71; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.

Raw accepted samples and summaries for every run are archived alongside this report. CUDA stage durations must not be added to overlapping CPU wait intervals.
