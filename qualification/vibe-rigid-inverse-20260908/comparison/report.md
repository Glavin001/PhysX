# Structured rigid inverse: complete consumer comparison

**256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles over 600 steps / 10 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. 2 baseline and 2 candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline-1 | 57.990 | 151.165 (0) | 145.893 (48) | 76,767 | 19,109 | 359 |
| baseline-2 | 55.019 | 149.301 (0) | 140.909 (48) | 76,712 | 18,958 | 329 |
| candidate-1 | 55.008 | 150.722 (0) | 138.129 (48) | 76,719 | 18,960 | 345 |
| candidate-2 | 54.351 | 150.594 (0) | 139.459 (48) | 76,928 | 18,977 | 339 |

Comparing the **worst run in each arm**, observed complete-peak reduction is **0.3%**; fracture-step peak reduction is **4.4%**. Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.
- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; these short runs are not a complete parity/endurance oracle.
- This report does not infer numerical-test, penetration or browser-test success from timing captures.

## Experiment notes

The candidate replaces the fine 6x6 inverse application with the exact structured block identity D=[A,-K;K,cI], retaining all force/moment coupling. It stores ten coefficients rather than twenty-one; general coarse operators are unchanged. No precision/tolerance/material changes.

Qualification: GPU memcheck zero errors; three resident suites and eight ordinary-scene tests pass. The 444-chunk / 896-bond / one-projectile frozen 10-second wall retains its exact golden topology signature, 398 supported chunks, 46 detached chunks, 199 broken bonds and clearance at step 39. The new 257-physical-block cache oracle has worst scaled error 3.51e-15 against the triangular reference (unchanged 2e-12 tolerance); the independent 12-node / 20-bond full polynomial oracle passes.

This is still a short-screen candidate, not a deployed or endurance-qualified optimization. Both observed candidate fracture peaks are below both baselines, but complete peaks overlap and are still dominated by startup. The playable city expansion uses the previously qualified baseline runtime. Profiling, broader qualification and a deployment decision remain pending; do not claim historical Vibe-land superiority or real-time large-city performance.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- baseline-2 versus baseline-1: first difference at tick 74; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-1 versus baseline-1: first difference at tick 74; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-2 versus baseline-1: first difference at tick 72; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.

Raw accepted samples and summaries for every run are archived alongside this report. CUDA stage durations must not be added to overlapping CPU wait intervals.
