# Independent one-tick file replay

One full tick per fresh restore, fixed file inputs, ordinary GPU/TGS, dt=1/60, at most one correction. Independent physical reconstructions; shared-GPU descriptive timings, not matched A/B performance qualification. Restore includes scene creation and stress configuration; context initialization and validation are outside both reported intervals. No capture-prefix simulation.

| Saved scenario | Repeatability gate | n | Full tick mean / max ms | Median ms | Restore mean ms | >8 / >120Hz / >60Hz | Correction / stress evaluations |
|---|---|---:|---:|---:|---:|---|---|
| bridge64-cold | PASS | 20 | 9.157 / 13.206 | 8.992 | 139.286 | 20 (100%) / 20 (100%) / 0 (0%) | [0] / [1] |
| bridge64-warm | PASS | 20 | 8.609 / 10.617 | 8.449 | 129.560 | 17 (85%) / 16 (80%) / 0 (0%) | [0] / [1] |
| building-cold | PASS | 20 | 5.174 / 7.812 | 4.873 | 129.845 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| building-fragmented | PASS | 20 | 9.033 / 15.601 | 8.900 | 140.685 | 17 (85%) / 15 (75%) / 0 (0%) | [0] / [1] |
| building-warm | PASS | 20 | 4.349 / 6.120 | 4.276 | 132.248 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| cantilever64-cold | PASS | 20 | 8.153 / 13.410 | 7.732 | 123.042 | 4 (20%) / 4 (20%) / 0 (0%) | [0] / [1] |
| cantilever64-warm | PASS | 20 | 7.735 / 11.659 | 7.474 | 127.912 | 4 (20%) / 2 (10%) / 0 (0%) | [0] / [1] |
| chain256-cold | PASS | 20 | 7.089 / 10.465 | 6.910 | 123.540 | 2 (10%) / 1 (5%) / 0 (0%) | [0] / [1] |
| chain256-warm | PASS | 20 | 7.636 / 11.444 | 7.405 | 139.266 | 4 (20%) / 1 (5%) / 0 (0%) | [0] / [1] |
| chain32-cold | PASS | 20 | 2.975 / 7.308 | 2.976 | 125.424 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| chain32-warm | PASS | 20 | 2.988 / 5.294 | 3.094 | 130.301 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| dense12-cold | PASS | 20 | 33.114 / 36.063 | 32.987 | 135.271 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| dense12-warm | PASS | 20 | 33.039 / 35.770 | 32.807 | 136.514 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| destruction-cold | PASS | 20 | 3.833 / 7.149 | 3.520 | 123.419 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| destruction-damaged | PASS | 20 | 3.614 / 6.930 | 3.434 | 125.205 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| destruction-fractured | PASS | 20 | 5.273 / 10.139 | 5.117 | 122.980 | 1 (5%) / 1 (5%) / 0 (0%) | [0] / [1] |
| destruction-intact | PASS | 20 | 3.601 / 7.868 | 3.429 | 123.584 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| destruction-onset | PASS | 20 | 4.299 / 8.875 | 4.084 | 124.027 | 1 (5%) / 1 (5%) / 0 (0%) | [0] / [1] |
| destruction-stimulus | PASS | 20 | 4.819 / 8.952 | 4.465 | 126.540 | 1 (5%) / 1 (5%) / 0 (0%) | [0] / [1] |
| flying | PASS | 20 | 1.876 / 2.384 | 1.913 | 115.266 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [0] |
| ladder128-cold | PASS | 20 | 6.082 / 9.589 | 5.770 | 130.517 | 1 (5%) / 1 (5%) / 0 (0%) | [0] / [1] |
| ladder128-warm | PASS | 20 | 5.532 / 6.350 | 5.535 | 129.332 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| panel32-cold | PASS | 20 | 21.883 / 24.456 | 21.825 | 131.483 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| panel32-warm | PASS | 20 | 22.277 / 24.364 | 22.335 | 139.514 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| resting | PASS | 20 | 1.815 / 2.770 | 1.690 | 113.939 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [0] |
| sliding | PASS | 20 | 2.876 / 4.072 | 2.710 | 118.061 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [0] |
| tower64-cold | PASS | 20 | 116.912 / 121.191 | 116.747 | 137.507 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| tower64-warm | PASS | 20 | 117.293 / 119.586 | 117.325 | 147.611 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |

Repeatability qualification is explicit in each row. Failed comparisons remain failures; their timings are diagnostic only. The adjacent JSON reports measured motion differences and fracture/correction counts for every scenario. Scene scale and source-step metadata, when available, are listed below. Fresh restore rebuilds caches, so these timings do not replace warm continuous city trajectories.

The input hashes, iteration counts, ranges and raw sample locations are in the adjacent JSON. Repeat counts describe observed variability; they do not establish a candidate speedup or guarantee statistical significance. Retain continuous warm trajectories and matched A/B controls for optimization decisions.

## Complete-step phases

The integrated simulate/fetch interval includes rigid physics, stress, transfers, correction and accepted publication. The completion interval includes the native benchmark’s two compact GPU status transfers and readiness synchronization. Large output validation is outside all three intervals.

| Scenario | Command mean ms | Integrated simulate/fetch mean ms | Completion mean ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000120 | 8.940 | 0.217 |
| bridge64-warm | 0.000111 | 8.424 | 0.185 |
| building-cold | 0.000122 | 4.986 | 0.188 |
| building-fragmented | 0.000135 | 8.832 | 0.201 |
| building-warm | 0.000112 | 4.161 | 0.189 |
| cantilever64-cold | 0.000119 | 7.977 | 0.176 |
| cantilever64-warm | 0.000137 | 7.519 | 0.216 |
| chain256-cold | 0.000139 | 6.892 | 0.197 |
| chain256-warm | 0.000121 | 7.399 | 0.237 |
| chain32-cold | 0.000105 | 2.796 | 0.178 |
| chain32-warm | 0.000108 | 2.802 | 0.186 |
| dense12-cold | 0.000104 | 32.920 | 0.194 |
| dense12-warm | 0.000119 | 32.864 | 0.175 |
| destruction-cold | 0.000123 | 3.684 | 0.149 |
| destruction-damaged | 0.000109 | 3.433 | 0.181 |
| destruction-fractured | 0.000117 | 5.110 | 0.163 |
| destruction-intact | 0.000137 | 3.412 | 0.189 |
| destruction-onset | 0.000120 | 4.125 | 0.174 |
| destruction-stimulus | 0.002338 | 4.654 | 0.162 |
| flying | 0.000125 | 1.875 | 0.000 |
| ladder128-cold | 0.000116 | 5.887 | 0.195 |
| ladder128-warm | 0.000120 | 5.246 | 0.286 |
| panel32-cold | 0.000102 | 21.684 | 0.199 |
| panel32-warm | 0.000144 | 22.055 | 0.222 |
| resting | 0.000127 | 1.814 | 0.000 |
| sliding | 0.000107 | 2.875 | 0.000 |
| tower64-cold | 0.000124 | 116.707 | 0.204 |
| tower64-warm | 0.000122 | 117.068 | 0.225 |

## Scale and timing spread

| Scenario | Chunks / bonds | Input → output clusters | New broken bonds | Standard deviation ms | Mean 95% resampling interval ms | Harness seconds |
|---|---:|---|---|---:|---|---:|
| bridge64-cold | ? / ? | ? → [1] | [0] | 1.030 | 8.813–9.676 | 5.07 |
| bridge64-warm | ? / ? | ? → [1] | [0] | 0.673 | 8.347–8.918 | 4.80 |
| building-cold | ? / ? | ? → [1] | [0] | 0.747 | 4.905–5.544 | 4.83 |
| building-fragmented | ? / ? | ? → [378] | [0] | 1.737 | 8.426–9.905 | 5.42 |
| building-warm | ? / ? | ? → [1] | [0] | 0.678 | 4.072–4.658 | 4.86 |
| cantilever64-cold | ? / ? | ? → [1] | [0] | 1.428 | 7.664–8.856 | 4.45 |
| cantilever64-warm | ? / ? | ? → [1] | [0] | 1.181 | 7.301–8.277 | 4.71 |
| chain256-cold | ? / ? | ? → [1] | [0] | 0.969 | 6.726–7.562 | 4.37 |
| chain256-warm | ? / ? | ? → [1] | [0] | 0.991 | 7.292–8.141 | 5.09 |
| chain32-cold | ? / ? | ? → [1] | [0] | 1.205 | 2.524–3.585 | 4.47 |
| chain32-warm | ? / ? | ? → [1] | [0] | 0.769 | 2.669–3.342 | 4.68 |
| dense12-cold | ? / ? | ? → [1] | [0] | 0.904 | 32.766–33.539 | 5.53 |
| dense12-warm | ? / ? | ? → [1] | [0] | 0.776 | 32.761–33.414 | 5.49 |
| destruction-cold | ? / ? | ? → [1] | [0] | 0.849 | 3.557–4.269 | 4.48 |
| destruction-damaged | ? / ? | ? → [1] | [0] | 0.948 | 3.263–4.081 | 4.42 |
| destruction-fractured | ? / ? | ? → [2] | [0] | 1.416 | 4.724–5.938 | 4.46 |
| destruction-intact | ? / ? | ? → [1] | [0] | 1.180 | 3.176–4.184 | 4.48 |
| destruction-onset | ? / ? | ? → [1] | [0] | 1.240 | 3.841–4.910 | 4.41 |
| destruction-stimulus | ? / ? | ? → [1] | [0] | 1.365 | 4.306–5.482 | 4.44 |
| flying | ? / ? | ? → [0] | [0] | 0.252 | 1.757–1.974 | 4.24 |
| ladder128-cold | ? / ? | ? → [1] | [0] | 1.050 | 5.679–6.581 | 4.81 |
| ladder128-warm | ? / ? | ? → [1] | [0] | 0.522 | 5.306–5.753 | 4.89 |
| panel32-cold | ? / ? | ? → [1] | [0] | 0.917 | 21.503–22.289 | 5.03 |
| panel32-warm | ? / ? | ? → [1] | [0] | 0.736 | 21.975–22.601 | 5.64 |
| resting | ? / ? | ? → [0] | [0] | 0.434 | 1.636–2.012 | 4.20 |
| sliding | ? / ? | ? → [0] | [0] | 0.411 | 2.717–3.073 | 4.46 |
| tower64-cold | ? / ? | ? → [1] | [0] | 1.375 | 116.368–117.548 | 7.29 |
| tower64-warm | ? / ? | ? → [1] | [0] | 0.873 | 116.937–117.694 | 7.99 |

Intervals describe variation in these samples, assuming exchangeable observations; they do not bound systematic shared-GPU interference. JSON includes first-half versus last-half means to expose drift. All samples, including first restored ticks, are retained.
