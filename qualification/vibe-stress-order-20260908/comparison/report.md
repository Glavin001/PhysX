# GPU component-size scheduling: rejected peak experiment

**256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles over 600 steps / 10 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. 2 baseline and 2 candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline-1 | 55.642 | 149.313 (0) | 136.240 (48) | 76,268 | 18,810 | 334 |
| baseline-2 | 57.303 | 150.872 (0) | 140.191 (48) | 76,637 | 19,090 | 339 |
| candidate-1 | 51.492 | 151.483 (0) | 136.378 (48) | 76,695 | 19,095 | 354 |
| candidate-2 | 52.396 | 152.147 (0) | 143.766 (48) | 76,863 | 18,894 | 343 |

Comparing the **worst run in each arm**, observed complete-peak reduction is **-0.8%**; fracture-step peak reduction is **-2.5%**. Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.
- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; these short runs are not a complete parity/endurance oracle.
- This report does not infer numerical-test, penetration or browser-test success from timing captures.

## Experiment notes

❌ **Rejected and reverted from production.** The candidate sorted independent stress components by descending node count on the GPU, only when topology changed. Stable identities and each component's node order remained unchanged. The aim was to start long component solves earlier. Extra persistent dispatch storage was 4 bytes per authored node; sorting reused existing scratch.

Execution order: baseline A → candidate A → candidate B → baseline B. The same untraced consumer binary and recorded command tape were used with separately hashed runtime libraries. Only this owned, empty server was stopped during the isolated runs and it was restored afterward. No other developer services were stopped.

Three resident numerical suites, eight ordinary native integration tests, and the frozen 10-second wall audit passed. The wall contains 444 chunks / 896 bonds / one projectile: 398 retained, 46 detached, 199 broken bonds, exact topology signature unchanged, projectile clears at tick 39. Logs and quality JSON accompany this report. These checks do not establish full endurance or broad gameplay parity.

Both candidate averages improved, but the worst complete and fracture-step peaks did not. Do not retain the candidate or claim progress toward the strict peak deadline from its average. This rejects this size-ordering implementation as a peak optimization; it does not prove scheduling is universally optimal. The first large split remains the fracture peak; do not attribute these complete times solely to stress kernels. No hardware-counter bottleneck claim is made.

Restored production browser smoke passed again: 444 chunks / 896 bonds, four 150 ms trigger holds, 299 broken bonds and 76 fragment bodies after shooting, 30 one-second settling samples, then successful reset. Movement, native correction, rendering ownership and transport assertions passed. The settled screenshot was inspected. Six known resource-loading errors remain. The test rewrites only the advertised WebTransport hostname/port for local access; it does not independently verify a remote browser connection. Runtime was restored to the exact baseline library hash. See the browser receipt and raw artifacts one directory above.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- baseline-2 versus baseline-1: first difference at tick 77; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-1 versus baseline-1: first difference at tick 74; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-2 versus baseline-1: first difference at tick 74; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.

Raw accepted samples and summaries for every run are archived alongside this report. CUDA stage durations must not be added to overlapping CPU wait intervals.
