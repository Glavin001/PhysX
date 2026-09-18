# Targeted contact-report repair: consumer screen

**256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles over 600 steps / 10 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. One baseline and two candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline | 94.641 | 186.782 (139) | 186.782 (139) | 78,046 | 20,087 | 346 |
| candidate-1 | 55.996 | 151.490 (0) | 135.903 (48) | 76,217 | 18,695 | 341 |
| candidate-2 | 57.516 | 151.405 (0) | 147.162 (48) | 76,743 | 18,953 | 347 |

Using the **worse candidate run**, observed complete-peak reduction is **18.9%**; fracture-step peak reduction is **21.2%**. Startup becomes the overall maximum. This is measured screening evidence, not a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- The frozen 444-chunk / 896-bond penetration fixture retains its exact topology signature, 398 retained chunks and 199 broken bonds. Ordinary reported-contact and sleeping tests pass.
- These larger trajectories diverge after impact. Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; the short runs are not a complete parity/endurance oracle.
- The candidate repairs active dynamic shapes participating in CPU reports. Static ground and unrelated GPU contact relationships remain intact. GPU geometry/cache regeneration and both actual stress evaluations still occur; CPU-contact fallback, triggers and modification callbacks retain the complete repair.
- No tolerance, material, timestep, projectile or correction-budget change is included in this candidate.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- Candidate 1: first difference at tick 69; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- Candidate 2: first difference at tick 74; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.

Raw accepted samples and summaries for every run are archived alongside this report. The earlier phase replay identifies the removable refilter/registration cost; CUDA stage durations must not be added to overlapping CPU wait intervals.
