# Independent one-tick file replay

One full tick per fresh restore, fixed file inputs, ordinary GPU/TGS, dt=1/60, at most one correction. Independent physical reconstructions; shared-GPU descriptive timings, not matched A/B performance qualification. Restore includes scene creation and stress configuration; context initialization and validation are outside both reported intervals. No capture-prefix simulation.

| Saved scenario | Repeatability gate | n | Full tick mean / max ms | Median ms | Restore mean ms | >8 / >120Hz / >60Hz | Correction / stress evaluations |
|---|---|---:|---:|---:|---:|---|---|
| city25-intact-idle | PASS | 20 | 11.113 / 21.975 | 10.501 | 308.951 | 20 (100%) / 20 (100%) / 1 (5%) | [0] / [1] |
| city25-airborne | PASS | 20 | 12.107 / 18.479 | 11.623 | 313.587 | 20 (100%) / 20 (100%) / 1 (5%) | [0] / [1] |
| city25-initial-impact | PASS | 20 | 44.796 / 53.138 | 44.355 | 329.024 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city25-post-impact | FAIL: bond-health equality | 20 | 24.240 / 33.632 | 23.228 | 350.650 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city25-cascading-fracture | PASS | 20 | 40.561 / 52.502 | 39.862 | 335.852 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city25-fragmented-loaded | PASS | 20 | 55.292 / 68.102 | 54.355 | 338.346 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city25-late-debris | FAIL: bond-health equality | 20 | 72.481 / 90.525 | 71.799 | 346.702 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city25-ten-second-debris | FAIL: bond-health equality | 20 | 74.306 / 87.830 | 74.220 | 352.175 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-intact-idle | PASS | 20 | 18.986 / 25.729 | 18.047 | 1079.660 | 20 (100%) / 20 (100%) / 17 (85%) | [0] / [1] |
| city64-airborne | PASS | 20 | 19.901 / 23.106 | 19.696 | 1089.719 | 20 (100%) / 20 (100%) / 19 (95%) | [0] / [1] |
| city64-initial-impact | PASS | 20 | 68.260 / 91.882 | 66.497 | 1061.398 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-post-impact | PASS | 20 | 40.462 / 54.142 | 39.431 | 1126.852 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city64-cascading-fracture | PASS | 20 | 62.321 / 76.200 | 62.552 | 1099.658 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-fragmented-loaded | FAIL: bond-health equality | 20 | 97.738 / 128.962 | 98.333 | 1147.446 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-late-debris | FAIL: bond-health equality | 20 | 148.717 / 176.702 | 146.781 | 1150.482 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-ten-second-debris | FAIL: bond-health equality | 20 | 106.140 / 128.426 | 103.733 | 1208.425 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-intact-idle | PASS | 20 | 69.177 / 85.129 | 68.948 | 1862.605 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city256-airborne | PASS | 20 | 75.031 / 84.846 | 76.279 | 1846.996 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city256-initial-impact | PASS | 20 | 260.453 / 288.678 | 262.524 | 1856.150 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-post-impact | PASS | 20 | 149.502 / 172.789 | 149.128 | 1953.298 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city256-cascading-fracture | PASS | 20 | 210.019 / 242.847 | 208.396 | 1998.266 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-fragmented-loaded | FAIL: bond-health equality | 20 | 323.701 / 363.873 | 324.648 | 2072.068 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-late-debris | FAIL: bond-health equality | 20 | 463.076 / 502.288 | 469.603 | 2097.327 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-ten-second-debris | FAIL: bond-health equality | 20 | 274.528 / 357.086 | 268.619 | 2227.663 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |

Repeatability qualification is explicit in each row. Failed comparisons remain failures; their timings are diagnostic only. The adjacent JSON reports measured motion differences and fracture/correction counts for every scenario. Scene scale and source-step metadata, when available, are listed below. Fresh restore rebuilds caches, so these timings do not replace warm continuous city trajectories.

The input hashes, iteration counts, ranges and raw sample locations are in the adjacent JSON. Repeat counts describe observed variability; they do not establish a candidate speedup or guarantee statistical significance. Retain continuous warm trajectories and matched A/B controls for optimization decisions.

## Complete-step phases

The integrated simulate/fetch interval includes rigid physics, stress, transfers, correction and accepted publication. The completion interval includes the native benchmark’s two compact GPU status transfers and readiness synchronization. Large output validation is outside all three intervals.

| Scenario | Command mean ms | Integrated simulate/fetch mean ms | Completion mean ms |
|---|---:|---:|---:|
| city25-intact-idle | 0.000181 | 10.811 | 0.302 |
| city25-airborne | 0.000177 | 11.839 | 0.268 |
| city25-initial-impact | 0.000193 | 44.541 | 0.255 |
| city25-post-impact | 0.000198 | 23.912 | 0.328 |
| city25-cascading-fracture | 0.000166 | 40.289 | 0.273 |
| city25-fragmented-loaded | 0.000188 | 55.035 | 0.257 |
| city25-late-debris | 0.000208 | 72.196 | 0.284 |
| city25-ten-second-debris | 0.000193 | 74.052 | 0.254 |
| city64-intact-idle | 0.000204 | 18.673 | 0.313 |
| city64-airborne | 0.000206 | 19.593 | 0.308 |
| city64-initial-impact | 0.000182 | 67.988 | 0.272 |
| city64-post-impact | 0.000206 | 40.191 | 0.270 |
| city64-cascading-fracture | 0.000211 | 62.052 | 0.269 |
| city64-fragmented-loaded | 0.000204 | 97.478 | 0.260 |
| city64-late-debris | 0.000193 | 148.461 | 0.256 |
| city64-ten-second-debris | 0.000187 | 105.863 | 0.277 |
| city256-intact-idle | 0.000194 | 68.854 | 0.323 |
| city256-airborne | 0.000200 | 74.750 | 0.281 |
| city256-initial-impact | 0.000217 | 260.201 | 0.251 |
| city256-post-impact | 0.000188 | 149.244 | 0.257 |
| city256-cascading-fracture | 0.000266 | 209.733 | 0.286 |
| city256-fragmented-loaded | 0.000186 | 323.432 | 0.269 |
| city256-late-debris | 0.000209 | 462.805 | 0.270 |
| city256-ten-second-debris | 0.000198 | 274.259 | 0.269 |

## Scale and timing spread

| Scenario | Chunks / bonds | Input → output clusters | New broken bonds | Standard deviation ms | Mean 95% resampling interval ms | Harness seconds |
|---|---:|---|---|---:|---|---:|
| city25-intact-idle | 11100 / 22400 | 25 → [25] | [0] | 2.683 | 10.259–12.471 | 10.79 |
| city25-airborne | 11100 / 22400 | 25 → [25] | [0] | 1.785 | 11.463–12.963 | 10.66 |
| city25-initial-impact | 11100 / 22400 | 25 → [537] | [3412] | 3.852 | 43.216–46.500 | 11.77 |
| city25-post-impact | 11100 / 22400 | 526 → [526] | [0] | 3.466 | 22.833–25.800 | 12.93 |
| city25-cascading-fracture | 11100 / 22400 | 600 → [610] | [10] | 3.414 | 39.329–42.290 | 12.74 |
| city25-fragmented-loaded | 11100 / 22400 | 1282 → [1321] | [100] | 5.143 | 53.258–57.582 | 13.33 |
| city25-late-debris | 11100 / 22400 | 1488 → [2063] | [1424] | 5.339 | 70.414–75.126 | 14.94 |
| city25-ten-second-debris | 11100 / 22400 | 1683 → [1776] | [184] | 5.489 | 72.085–76.725 | 14.90 |
| city64-intact-idle | 28416 / 57344 | 64 → [64] | [0] | 2.984 | 17.784–20.327 | 35.23 |
| city64-airborne | 28416 / 57344 | 64 → [64] | [0] | 1.483 | 19.280–20.555 | 35.24 |
| city64-initial-impact | 28416 / 57344 | 64 → [1364] | [8760] | 8.015 | 65.060–71.975 | 35.80 |
| city64-post-impact | 28416 / 57344 | 1320 → [1320] | [0] | 5.528 | 38.177–42.911 | 37.83 |
| city64-cascading-fracture | 28416 / 57344 | 1460 → [1473] | [13] | 4.977 | 60.318–64.618 | 38.36 |
| city64-fragmented-loaded | 28416 / 57344 | 3010 → [3144] | [425] | 10.035 | 93.826–102.208 | 41.62 |
| city64-late-debris | 28416 / 57344 | 3957 → [5130] | [2768] | 11.285 | 144.162–153.834 | 43.46 |
| city64-ten-second-debris | 28416 / 57344 | 4565 → [4705] | [202] | 8.844 | 102.480–110.156 | 44.85 |
| city256-intact-idle | 113664 / 229376 | 256 → [256] | [0] | 7.979 | 65.723–72.533 | 62.42 |
| city256-airborne | 113664 / 229376 | 256 → [256] | [0] | 6.905 | 72.140–77.941 | 61.37 |
| city256-initial-impact | 113664 / 229376 | 256 → [5417] | [34802] | 16.548 | 253.423–267.282 | 67.75 |
| city256-post-impact | 113664 / 229376 | 5204 → [5204] | [0] | 9.995 | 145.207–153.876 | 72.36 |
| city256-cascading-fracture | 113664 / 229376 | 5827 → [5852] | [25] | 16.815 | 202.603–217.135 | 74.61 |
| city256-fragmented-loaded | 113664 / 229376 | 10905 → [11382] | [1229] | 18.701 | 315.878–331.712 | 85.47 |
| city256-late-debris | 113664 / 229376 | 12214 → [16135] | [11051] | 22.301 | 453.502–472.500 | 90.69 |
| city256-ten-second-debris | 113664 / 229376 | 14795 → [15187] | [819] | 25.325 | 264.795–286.550 | 91.55 |

Intervals describe variation in these samples, assuming exchangeable observations; they do not bound systematic shared-GPU interference. JSON includes first-half versus last-half means to expose drift. All samples, including first restored ticks, are retained.
