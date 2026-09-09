# GPU preparation before CPU compatibility — shots

**256 buildings, 113,664 chunks, 229,376 bonds, 256 physical projectiles over 96 steps / 1.6 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. 2 baseline and 2 candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline-1 | 37.139 | 158.305 (0) | 137.794 (48) | 71,152 | 15,760 | 42 |
| baseline-2 | 37.414 | 162.506 (0) | 136.278 (48) | 71,202 | 15,790 | 42 |
| candidate-1 | 37.586 | 159.717 (0) | 135.083 (48) | 71,094 | 15,739 | 42 |
| candidate-2 | 37.223 | 158.845 (0) | 134.795 (48) | 71,146 | 15,759 | 42 |

Comparing the **worst run in each arm**, observed complete-peak reduction is **1.7%**; fracture-step peak reduction is **2.0%**. Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.
- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; these short runs are not a complete parity/endurance oracle.
- This report does not infer numerical-test, penetration or browser-test success from timing captures.

## Required idle and destruction measurements

| Run | Fresh intact idle | Idle min / mean / p50 / p95 / p99 / max ms | Impact + aftermath peak ms (tick) |
|---|---|---|---:|
| baseline-1 | no | not measured | 137.794 (48) |
| baseline-2 | no | not measured | 136.278 (48) |
| candidate-1 | no | not measured | 135.083 (48) |
| candidate-2 | no | not measured | 134.795 (48) |

This table retains step zero. Fresh intact idle requires an empty command tape, zero projectiles, zero broken bonds and zero fragment bodies throughout. A short pre-impact window or sleeping debris after damage does not replace the fresh idle run. The impact/aftermath interval starts with the first recorded command and includes late rubble costs, even on steps without new fractures.

**Paired performance qualification is incomplete in this single-regime comparison:** attach the matching intact-idle or destruction comparison for the same scene and settings. Both regimes are required.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- baseline-2 versus baseline-1: first difference at tick 74; command SHA-256 `4629dee8470bbbb269d4ca1105ddef804ae60cb22f45ac13954b6f43b3924ea9`.
- candidate-1 versus baseline-1: first difference at tick 77; command SHA-256 `4629dee8470bbbb269d4ca1105ddef804ae60cb22f45ac13954b6f43b3924ea9`.
- candidate-2 versus baseline-1: first difference at tick 74; command SHA-256 `4629dee8470bbbb269d4ca1105ddef804ae60cb22f45ac13954b6f43b3924ea9`.

Raw accepted samples and summaries for every run are archived alongside this report. CUDA stage durations must not be added to overlapping CPU wait intervals.
