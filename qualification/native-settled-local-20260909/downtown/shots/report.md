# Exact settled stress reuse — shots

**27 buildings, 24,105 chunks, 74,543 bonds, 3 physical projectiles over 600 steps / 10 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. 2 baseline and 2 candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline-1 | 28.128 | 202.288 (0) | 128.777 (42) | 481 | 32 | 6 |
| baseline-2 | 28.132 | 201.589 (0) | 128.316 (42) | 481 | 32 | 6 |
| candidate-1 | 27.994 | 203.779 (0) | 128.398 (42) | 481 | 32 | 6 |
| candidate-2 | 27.941 | 200.478 (0) | 128.048 (42) | 481 | 32 | 6 |

Comparing the **worst run in each arm**, observed complete-peak reduction is **-0.7%**; fracture-step peak reduction is **0.3%**. Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.
- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; these short runs are not a complete parity/endurance oracle.
- This report does not infer numerical-test, penetration or browser-test success from timing captures.

## Required idle and destruction measurements

| Run | Fresh intact idle | Idle min / mean / p50 / p95 / p99 / max ms | Impact + aftermath peak ms (tick) |
|---|---|---|---:|
| baseline-1 | no | not measured | 128.777 (42) |
| baseline-2 | no | not measured | 128.316 (42) |
| candidate-1 | no | not measured | 128.398 (42) |
| candidate-2 | no | not measured | 128.048 (42) |

This table retains step zero. Fresh intact idle requires an empty command tape, zero projectiles, zero broken bonds and zero fragment bodies throughout. A short pre-impact window or sleeping debris after damage does not replace the fresh idle run. The impact/aftermath interval starts with the first recorded command and includes late rubble costs, even on steps without new fractures.

**Paired performance qualification is incomplete in this single-regime comparison:** attach the matching intact-idle or destruction comparison for the same scene and settings. Both regimes are required.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- baseline-2 versus baseline-1: first difference at tick 460; command SHA-256 `1df6569d4c4ace23c2cff043c72ac15e6085645bca88cd80e841ad072c2fbf5f`.
- candidate-1 versus baseline-1: first difference at tick 460; command SHA-256 `1df6569d4c4ace23c2cff043c72ac15e6085645bca88cd80e841ad072c2fbf5f`.
- candidate-2 versus baseline-1: first difference at tick 460; command SHA-256 `1df6569d4c4ace23c2cff043c72ac15e6085645bca88cd80e841ad072c2fbf5f`.

Raw accepted samples and summaries for every run are archived alongside this report. CUDA stage durations must not be added to overlapping CPU wait intervals.
