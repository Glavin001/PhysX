# 256-building control: downtown changes and rejected compiler annotation

**256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles over 600 steps / 10 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. 1 baseline and 2 candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline-1 | 54.427 | 151.087 (0) | 135.994 (48) | 76,307 | 18,880 | 356 |
| candidate-1 | 54.035 | 159.902 (0) | 144.778 (48) | 76,345 | 18,838 | 345 |
| candidate-2 | 57.026 | 160.146 (0) | 140.595 (48) | 76,895 | 19,095 | 360 |

Comparing the **worst run in each arm**, observed complete-peak reduction is **-6.0%**; fracture-step peak reduction is **-6.5%**. Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.
- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; these short runs are not a complete parity/endurance oracle.
- This report does not infer numerical-test, penetration or browser-test success from timing captures.

## Required idle and destruction measurements

| Run | Fresh intact idle | Idle min / mean / p50 / p95 / p99 / max ms | Impact + aftermath peak ms (tick) |
|---|---|---|---:|
| baseline-1 | no | not measured | 135.994 (48) |
| candidate-1 | no | not measured | 144.778 (48) |
| candidate-2 | no | not measured | 140.595 (48) |

This table retains step zero. Fresh intact idle requires an empty command tape, zero projectiles, zero broken bonds and zero fragment bodies throughout. A short pre-impact window or sleeping debris after damage does not replace the fresh idle run. The impact/aftermath interval starts with the first recorded command and includes late rubble costs, even on steps without new fractures.

**Paired performance qualification is incomplete in this single-regime comparison:** attach the matching intact-idle or destruction comparison for the same scene and settings. Both regimes are required.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- candidate-1 versus baseline-1: first difference at tick 74; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-2 versus baseline-1: first difference at tick 74; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.

Raw accepted samples and summaries for every run are archived alongside this report. CUDA stage durations must not be added to overlapping CPU wait intervals.
