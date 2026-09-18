# Exact settled stress reuse — idle

**256 buildings, 113,664 chunks, 229,376 bonds, 0 physical projectiles over 600 steps / 10 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. 2 baseline and 2 candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline-1 | 0.851 | 159.677 (0) | not measured | 0 | 0 | 0 |
| baseline-2 | 0.842 | 160.986 (0) | not measured | 0 | 0 | 0 |
| candidate-1 | 0.700 | 159.060 (0) | not measured | 0 | 0 | 0 |
| candidate-2 | 0.686 | 162.111 (0) | not measured | 0 | 0 | 0 |

Comparing the **worst run in each arm**, observed complete-peak reduction is **-0.7%**; fracture-step peak reduction is not measured. Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.
- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; these short runs are not a complete parity/endurance oracle.
- This report does not infer numerical-test, penetration or browser-test success from timing captures.

## Required idle and destruction measurements

| Run | Fresh intact idle | Idle min / mean / p50 / p95 / p99 / max ms | Impact + aftermath peak ms (tick) |
|---|---|---|---:|
| baseline-1 | yes | 0.530 / 0.851 / 0.580 / 0.627 / 0.656 / 159.677 | not measured |
| baseline-2 | yes | 0.534 / 0.842 / 0.567 / 0.609 / 0.645 / 160.986 | not measured |
| candidate-1 | yes | 0.396 / 0.700 / 0.433 / 0.463 / 0.489 / 159.060 | not measured |
| candidate-2 | yes | 0.373 / 0.686 / 0.413 / 0.440 / 0.463 / 162.111 | not measured |

This table retains step zero. Fresh intact idle requires an empty command tape, zero projectiles, zero broken bonds and zero fragment bodies throughout. A short pre-impact window or sleeping debris after damage does not replace the fresh idle run. The impact/aftermath interval starts with the first recorded command and includes late rubble costs, even on steps without new fractures.

**Paired performance qualification is incomplete in this single-regime comparison:** attach the matching intact-idle or destruction comparison for the same scene and settings. Both regimes are required.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- baseline-2 versus baseline-1: first difference at tick None; command SHA-256 `4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945`.
- candidate-1 versus baseline-1: first difference at tick None; command SHA-256 `4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945`.
- candidate-2 versus baseline-1: first difference at tick None; command SHA-256 `4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945`.

Raw accepted samples and summaries for every run are archived alongside this report. CUDA stage durations must not be added to overlapping CPU wait intervals.
