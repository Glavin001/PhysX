# Independent one-tick file replay

One full tick per fresh restore, fixed file inputs, ordinary GPU/TGS, dt=1/60, at most one correction. Independent physical reconstructions; shared-GPU descriptive timings, not matched A/B performance qualification. Restore includes scene creation and stress configuration; context initialization and validation are outside both reported intervals. No capture-prefix simulation.

| Saved scenario | Repeatability gate | n | Full tick mean / max ms | Median ms | Restore mean ms | >8 / >120Hz / >60Hz | Correction / stress evaluations |
|---|---|---:|---:|---:|---:|---|---|
| bridge64-cold | PASS | 8 | 9.036 / 11.346 | 8.710 | 36.996 | 8 (100%) / 6 (75%) / 0 (0%) | [0] / [1] |
| chain256-cold | PASS | 8 | 7.765 / 10.129 | 7.456 | 33.689 | 1 (12%) / 1 (12%) / 0 (0%) | [0] / [1] |
| dense12-cold | PASS | 6 | 33.339 / 36.129 | 33.139 | 53.992 | 6 (100%) / 6 (100%) / 6 (100%) | [0] / [1] |
| destruction-stimulus | PASS | 8 | 4.845 / 8.591 | 4.304 | 31.992 | 1 (12%) / 1 (12%) / 0 (0%) | [0] / [1] |
| city25-initial-impact | PASS | 4 | 44.563 / 52.508 | 42.044 | 131.347 | 4 (100%) / 4 (100%) / 4 (100%) | [1] / [2] |
| city256-intact-idle | PASS | 3 | 65.289 / 75.818 | 64.747 | 843.145 | 3 (100%) / 3 (100%) / 3 (100%) | [0] / [1] |
| city256-late-debris | PASS | 3 | 448.610 / 478.520 | 437.105 | 951.089 | 3 (100%) / 3 (100%) / 3 (100%) | [1] / [2] |

Repeatability qualification is explicit in each row. Failed comparisons remain failures; their timings are diagnostic only. The adjacent JSON reports measured motion differences and fracture/correction counts for every scenario. Scene scale and source-step metadata, when available, are listed below. Fresh restore rebuilds caches, so these timings do not replace warm continuous city trajectories.

The input hashes, iteration counts, ranges and raw sample locations are in the adjacent JSON. Repeat counts describe observed variability; they do not establish a candidate speedup or guarantee statistical significance. Retain continuous warm trajectories and matched A/B controls for optimization decisions.

## Complete-step phases

The integrated simulate/fetch interval includes rigid physics, stress, transfers, correction and accepted publication. The completion interval includes the native benchmark’s two compact GPU status transfers and readiness synchronization. Large output validation is outside all three intervals.

| Scenario | Command mean ms | Integrated simulate/fetch mean ms | Completion mean ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000108 | 8.805 | 0.231 |
| chain256-cold | 0.000108 | 7.471 | 0.294 |
| dense12-cold | 0.000139 | 33.113 | 0.226 |
| destruction-stimulus | 0.001767 | 4.648 | 0.196 |
| city25-initial-impact | 0.000111 | 44.347 | 0.216 |
| city256-intact-idle | 0.000250 | 65.039 | 0.250 |
| city256-late-debris | 0.000179 | 448.322 | 0.289 |

## Scale and timing spread

| Scenario | Chunks / bonds | Input → output clusters | New broken bonds | Standard deviation ms | Mean 95% resampling interval ms | Harness seconds |
|---|---:|---|---|---:|---|---:|
| bridge64-cold | ? / ? | ? → [1] | [0] | 1.011 | 8.499–9.773 | 1.46 |
| chain256-cold | ? / ? | ? → [1] | [0] | 0.991 | 7.291–8.500 | 1.42 |
| dense12-cold | ? / ? | ? → [1] | [0] | 1.486 | 32.423–34.538 | 1.42 |
| destruction-stimulus | ? / ? | ? → [1] | [0] | 1.595 | 4.064–6.014 | 1.41 |
| city25-initial-impact | 11100 / 22400 | 25 → [537] | [3412] | 5.300 | 41.753–49.890 | 2.03 |
| city256-intact-idle | 113664 / 229376 | 256 → [256] | [0] | 10.269 | 55.302–75.818 | 6.77 |
| city256-late-debris | 113664 / 229376 | 12214 → [16135] | [11051] | 26.131 | 430.207–478.520 | 8.78 |

Intervals describe variation in these samples, assuming exchangeable observations; they do not bound systematic shared-GPU interference. JSON includes first-half versus last-half means to expose drift. All samples, including first restored ticks, are retained.
