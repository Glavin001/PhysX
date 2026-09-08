# Anchored residual: remove redundant GPU conversions

**256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles over 600 steps / 10 simulated seconds per run.** Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. Identical recorded commands and reported physical settings. 2 baseline and 2 candidate runs; short isolated screens, not endurance or a historical external-backend comparison.

The complete timer includes projectile insertion, native physics/stress/topology/correction and accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.

| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |
|---|---:|---:|---:|---:|---:|---:|
| baseline-1 | 57.521 | 158.171 (48) | 158.171 (48) | 76,136 | 18,700 | 347 |
| baseline-2 | 55.272 | 152.782 (0) | 146.158 (48) | 76,291 | 18,720 | 330 |
| candidate-1 | 55.656 | 153.169 (0) | 146.181 (48) | 76,390 | 18,771 | 336 |
| candidate-2 | 56.122 | 153.885 (0) | 151.395 (48) | 76,233 | 18,807 | 348 |

Comparing the **worst run in each arm**, observed complete-peak reduction is **2.7%**; fracture-step peak reduction is **4.3%**. Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.

## Physical-work checks and limits

- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.
- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; these short runs are not a complete parity/endurance oracle.
- This report does not infer numerical-test, penetration or browser-test success from timing captures.

## Experiment notes

✅ **Retained as deletion of redundant GPU work; short-screen qualification only.** The mode certificate already proves a fully anchored component has no rigid null motion to project. After creating the FP64 RHS from the FP32 residual, the candidate omits the identity conversion back into the residual and RHS, together with its trailing block barrier. Free components still execute their full projection. The validated topology generation owns the certificate. No tolerance, material law, precision, load, iteration cap, convergence verification or correction budget was changed.

Execution order: baseline A → candidate A → candidate B → baseline B. Same untraced consumer executable, separately hashed runtime libraries, identical recorded inputs. Only the empty owned server was stopped, then restored. These short runs do not qualify 60 Hz, the 8 ms deadline, endurance or superiority over the historical external backend.

Three resident numerical suites, eight ordinary native integration tests and the frozen 10-second wall audit passed. Wall workload: 444 chunks / 896 bonds / one projectile, 398 retained / 46 detached / 199 broken, unchanged exact topology signature, projectile clearance tick 39. The tests include anchored/free components and topology/motion cases; no assertions or golden outputs were relaxed.

Untraced ranges overlap: baseline fracture peaks 146.158–158.171 ms, candidate 146.181–151.395 ms. The lower worst observation does not establish a robust complete-peak win. Candidate averages lie inside the baseline range too. A separate instrumented replay measures the intended stress-phase reduction; those durations must not replace untraced complete-step measurements.

At the matching counted first-split state, tick 48, baseline/candidate CUDA stress totals over two solves are 35.978 / 33.728 ms. Both have 10,449 fragment bodies, 10,193 awake fragments, 216,220 reported normal contacts and 57,788 cumulative broken bonds. Counted states first differ at tick 76; this is not proof of identical trajectories. Compiler resources remain 96 registers, 560 shared bytes and 528 stack bytes per thread/block as reported by cuobjdump; those are compiler resources, not measured occupancy or hardware-counter attribution.

## First counted-state divergence

The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. It compares contact count, broken bonds, fragment count and awake fragment count at each tick.

- baseline-2 versus baseline-1: first difference at tick 75; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-1 versus baseline-1: first difference at tick 78; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.
- candidate-2 versus baseline-1: first difference at tick 74; command SHA-256 `2919968a907194684bc14351de6949fef8b25d0e6ffa83ab35bb3081ac6e1cbf`.

Raw accepted samples and summaries for every run are archived alongside this report. CUDA stage durations must not be added to overlapping CPU wait intervals.
