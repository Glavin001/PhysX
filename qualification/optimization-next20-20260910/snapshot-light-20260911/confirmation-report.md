# Independent one-tick file replay

One full tick per fresh restore, fixed file inputs, ordinary GPU/TGS, dt=1/60, at most one correction. Independent physical reconstructions; shared-GPU descriptive timings, not matched A/B performance qualification. Restore includes scene creation and stress configuration; context initialization and validation are outside both reported intervals. No capture-prefix simulation.

| Saved scenario | Repeatability gate | n | Full tick mean / max ms | Median ms | Restore mean ms | >8 / >120Hz / >60Hz | Correction / stress evaluations |
|---|---|---:|---:|---:|---:|---|---|
| bridge64-cold | PASS | 8 | 8.571 / 10.619 | 8.334 | 37.485 | 6 (75%) / 4 (50%) / 0 (0%) | [0] / [1] |
| chain256-cold | PASS | 8 | 7.243 / 10.107 | 6.846 | 33.184 | 1 (12%) / 1 (12%) / 0 (0%) | [0] / [1] |
| dense12-cold | PASS | 6 | 33.472 / 36.885 | 32.897 | 58.482 | 6 (100%) / 6 (100%) / 6 (100%) | [0] / [1] |
| destruction-stimulus | PASS | 8 | 3.452 / 4.923 | 3.373 | 32.226 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| city25-initial-impact | PASS | 4 | 41.205 / 46.275 | 40.494 | 124.993 | 4 (100%) / 4 (100%) / 4 (100%) | [1] / [2] |
| city256-intact-idle | PASS | 3 | 62.529 / 69.986 | 60.138 | 850.095 | 3 (100%) / 3 (100%) / 3 (100%) | [0] / [1] |
| city256-late-debris | PASS | 3 | 435.357 / 451.327 | 435.762 | 942.259 | 3 (100%) / 3 (100%) / 3 (100%) | [1] / [2] |

Repeatability qualification is explicit in each row. Failed comparisons remain failures; their timings are diagnostic only. The adjacent JSON reports measured motion differences and fracture/correction counts for every scenario. Scene scale and source-step metadata, when available, are listed below. Fresh restore rebuilds caches, so these timings do not replace warm continuous city trajectories.

The input hashes, iteration counts, ranges and raw sample locations are in the adjacent JSON. Repeat counts describe observed variability; they do not establish a candidate speedup or guarantee statistical significance. Retain continuous warm trajectories and matched A/B controls for optimization decisions.

## Complete-step phases

The integrated simulate/fetch interval includes rigid physics, stress, transfers, correction and accepted publication. The completion interval includes the native benchmark’s two compact GPU status transfers and readiness synchronization. Large output validation is outside all three intervals.

| Scenario | Command mean ms | Integrated simulate/fetch mean ms | Completion mean ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000112 | 8.369 | 0.202 |
| chain256-cold | 0.000134 | 7.034 | 0.209 |
| dense12-cold | 0.000143 | 33.242 | 0.229 |
| destruction-stimulus | 0.001991 | 3.286 | 0.163 |
| city25-initial-impact | 0.000115 | 41.014 | 0.191 |
| city256-intact-idle | 0.000186 | 62.287 | 0.242 |
| city256-late-debris | 0.000181 | 434.967 | 0.390 |

## Scale and timing spread

| Scenario | Chunks / bonds | Input → output clusters | New broken bonds | Standard deviation ms | Mean 95% resampling interval ms | Harness seconds |
|---|---:|---|---|---:|---|---:|
| bridge64-cold | ? / ? | ? → [1] | [0] | 0.886 | 8.126–9.223 | 1.43 |
| chain256-cold | ? / ? | ? → [1] | [0] | 1.232 | 6.620–8.148 | 1.41 |
| dense12-cold | ? / ? | ? → [1] | [0] | 1.755 | 32.460–34.899 | 1.80 |
| destruction-stimulus | ? / ? | ? → [1] | [0] | 0.703 | 3.038–3.948 | 1.41 |
| city25-initial-impact | 11100 / 22400 | 25 → [537] | [3412] | 3.659 | 38.355–44.765 | 2.01 |
| city256-intact-idle | 113664 / 229376 | 256 → [256] | [0] | 6.594 | 57.464–69.986 | 6.88 |
| city256-late-debris | 113664 / 229376 | 12214 → [16135] | [11051] | 16.176 | 418.982–451.327 | 8.69 |

Intervals describe variation in these samples, assuming exchangeable observations; they do not bound systematic shared-GPU interference. JSON includes first-half versus last-half means to expose drift. All samples, including first restored ticks, are retained.
