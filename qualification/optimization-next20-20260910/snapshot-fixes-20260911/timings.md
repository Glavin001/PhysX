# Independent one-tick file replay

One full tick per fresh restore, fixed file inputs, ordinary GPU/TGS, dt=1/60, at most one correction. Independent physical reconstructions; shared-GPU descriptive timings, not matched A/B performance qualification. Restore includes scene creation and stress configuration; context initialization and validation are outside both reported intervals. No capture-prefix simulation.

| Saved scenario | Repeatability gate | n | Full tick mean / max ms | Median ms | Restore mean ms | >8 / >120Hz / >60Hz | Correction / stress evaluations |
|---|---|---:|---:|---:|---:|---|---|
| bridge64-cold | PASS | 20 | 8.597 / 11.830 | 8.341 | 128.683 | 17 (85%) / 10 (50%) / 0 (0%) | [0] / [1] |
| bridge64-warm | PASS | 20 | 8.883 / 11.336 | 8.764 | 126.976 | 20 (100%) / 19 (95%) / 0 (0%) | [0] / [1] |
| building-cold | PASS | 20 | 4.459 / 6.977 | 4.413 | 126.469 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| building-fragmented | PASS | 20 | 7.439 / 10.868 | 7.120 | 135.366 | 5 (25%) / 4 (20%) / 0 (0%) | [0] / [1] |
| building-warm | PASS | 20 | 4.636 / 7.685 | 4.623 | 133.188 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| cantilever64-cold | PASS | 20 | 7.279 / 8.167 | 7.271 | 127.435 | 1 (5%) / 0 (0%) / 0 (0%) | [0] / [1] |
| cantilever64-warm | PASS | 20 | 7.440 / 8.605 | 7.461 | 124.575 | 2 (10%) / 2 (10%) / 0 (0%) | [0] / [1] |
| chain256-cold | PASS | 20 | 6.621 / 8.392 | 6.423 | 125.449 | 1 (5%) / 1 (5%) / 0 (0%) | [0] / [1] |
| chain256-warm | PASS | 20 | 7.238 / 11.440 | 7.116 | 123.563 | 2 (10%) / 2 (10%) / 0 (0%) | [0] / [1] |
| chain32-cold | PASS | 20 | 2.536 / 4.805 | 2.311 | 127.672 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| chain32-warm | PASS | 20 | 3.281 / 7.092 | 3.259 | 124.787 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| city25-airborne | PASS | 20 | 11.150 / 14.306 | 10.942 | 283.479 | 20 (100%) / 20 (100%) / 0 (0%) | [0] / [1] |
| city25-cascading-fracture | PASS | 20 | 40.491 / 47.415 | 40.180 | 297.859 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city25-fragmented-loaded | PASS | 20 | 52.519 / 65.702 | 52.868 | 319.515 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city25-initial-impact | PASS | 20 | 40.391 / 50.071 | 40.465 | 287.975 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city25-intact-idle | PASS | 20 | 9.782 / 12.846 | 9.563 | 284.079 | 20 (100%) / 20 (100%) / 0 (0%) | [0] / [1] |
| city25-late-debris | PASS | 20 | 70.379 / 90.692 | 69.177 | 320.117 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city25-post-impact | PASS | 20 | 22.668 / 29.432 | 22.045 | 295.671 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city25-ten-second-debris | PASS | 20 | 71.560 / 94.281 | 70.477 | 325.562 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-airborne | PASS | 20 | 69.057 / 88.200 | 65.086 | 1678.501 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city256-cascading-fracture | PASS | 20 | 195.092 / 231.301 | 196.569 | 1819.789 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-fragmented-loaded | PASS | 20 | 284.296 / 302.733 | 289.384 | 1926.654 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-initial-impact | PASS | 20 | 242.483 / 278.238 | 244.822 | 1675.456 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-intact-idle | PASS | 20 | 62.324 / 82.158 | 59.828 | 1676.697 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city256-late-debris | PASS | 20 | 403.159 / 502.157 | 400.150 | 1982.028 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city256-post-impact | PASS | 20 | 141.450 / 158.709 | 143.601 | 1803.404 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city256-ten-second-debris | PASS | 20 | 264.161 / 380.940 | 258.822 | 2058.842 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-airborne | PASS | 20 | 17.494 / 21.955 | 17.122 | 1002.299 | 20 (100%) / 20 (100%) / 14 (70%) | [0] / [1] |
| city64-cascading-fracture | PASS | 20 | 56.115 / 74.762 | 56.916 | 1027.010 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-fragmented-loaded | PASS | 20 | 89.950 / 116.396 | 88.081 | 1103.190 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-initial-impact | PASS | 20 | 64.118 / 80.362 | 63.294 | 997.196 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-intact-idle | PASS | 20 | 15.999 / 19.102 | 15.983 | 1000.719 | 20 (100%) / 20 (100%) / 3 (15%) | [0] / [1] |
| city64-late-debris | PASS | 20 | 134.623 / 171.881 | 133.177 | 1084.089 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| city64-post-impact | PASS | 20 | 37.898 / 44.096 | 37.526 | 1018.472 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| city64-ten-second-debris | PASS | 20 | 102.570 / 143.140 | 101.643 | 1110.582 | 20 (100%) / 20 (100%) / 20 (100%) | [1] / [2] |
| dense12-cold | PASS | 20 | 33.196 / 36.218 | 33.013 | 139.574 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| dense12-warm | PASS | 20 | 32.891 / 35.581 | 32.695 | 137.664 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| destruction-cold | PASS | 20 | 3.285 / 5.859 | 3.233 | 125.246 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| destruction-damaged | PASS | 20 | 3.428 / 6.724 | 3.386 | 125.830 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| destruction-fractured | PASS | 20 | 5.513 / 10.554 | 5.306 | 127.442 | 1 (5%) / 1 (5%) / 0 (0%) | [0] / [1] |
| destruction-intact | PASS | 20 | 3.122 / 6.379 | 2.979 | 123.599 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| destruction-onset | PASS | 20 | 4.090 / 4.847 | 4.155 | 125.036 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| destruction-stimulus | PASS | 20 | 4.089 / 8.595 | 3.856 | 125.325 | 1 (5%) / 1 (5%) / 0 (0%) | [0] / [1] |
| flying | PASS | 20 | 2.129 / 4.421 | 1.973 | 113.349 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [0] |
| ladder128-cold | PASS | 20 | 5.521 / 8.511 | 5.592 | 129.096 | 1 (5%) / 1 (5%) / 0 (0%) | [0] / [1] |
| ladder128-warm | PASS | 20 | 5.283 / 8.227 | 5.000 | 129.559 | 1 (5%) / 0 (0%) / 0 (0%) | [0] / [1] |
| panel32-cold | PASS | 20 | 22.108 / 29.287 | 21.582 | 131.671 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| panel32-warm | PASS | 20 | 22.026 / 25.136 | 21.948 | 131.225 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| resting | PASS | 20 | 1.566 / 2.972 | 1.500 | 115.347 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [0] |
| sliding | PASS | 20 | 2.858 / 3.772 | 2.732 | 118.287 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [0] |
| tower64-cold | PASS | 20 | 117.537 / 119.683 | 117.337 | 151.658 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| tower64-warm | PASS | 20 | 117.216 / 121.710 | 117.073 | 153.741 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |

Repeatability qualification is explicit in each row. Failed comparisons remain failures; their timings are diagnostic only. The adjacent JSON reports measured motion differences and fracture/correction counts for every scenario. Scene scale and source-step metadata, when available, are listed below. Fresh restore rebuilds caches, so these timings do not replace warm continuous city trajectories.

The input hashes, iteration counts, ranges and raw sample locations are in the adjacent JSON. Repeat counts describe observed variability; they do not establish a candidate speedup or guarantee statistical significance. Retain continuous warm trajectories and matched A/B controls for optimization decisions.

## Complete-step phases

The integrated simulate/fetch interval includes rigid physics, stress, transfers, correction and accepted publication. The completion interval includes the native benchmark’s two compact GPU status transfers and readiness synchronization. Large output validation is outside all three intervals.

| Scenario | Command mean ms | Integrated simulate/fetch mean ms | Completion mean ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000104 | 8.397 | 0.200 |
| bridge64-warm | 0.000086 | 8.736 | 0.146 |
| building-cold | 0.000107 | 4.318 | 0.141 |
| building-fragmented | 0.000106 | 7.265 | 0.174 |
| building-warm | 0.000145 | 4.461 | 0.175 |
| cantilever64-cold | 0.000108 | 7.092 | 0.187 |
| cantilever64-warm | 0.000114 | 7.258 | 0.182 |
| chain256-cold | 0.000104 | 6.407 | 0.214 |
| chain256-warm | 0.000109 | 7.070 | 0.168 |
| chain32-cold | 0.000115 | 2.361 | 0.175 |
| chain32-warm | 0.001126 | 3.114 | 0.166 |
| city25-airborne | 0.000121 | 10.948 | 0.202 |
| city25-cascading-fracture | 0.000125 | 40.279 | 0.212 |
| city25-fragmented-loaded | 0.000112 | 52.307 | 0.211 |
| city25-initial-impact | 0.000101 | 40.179 | 0.212 |
| city25-intact-idle | 0.000129 | 9.583 | 0.198 |
| city25-late-debris | 0.000098 | 70.170 | 0.209 |
| city25-post-impact | 0.000168 | 22.468 | 0.200 |
| city25-ten-second-debris | 0.000108 | 71.329 | 0.231 |
| city256-airborne | 0.000151 | 68.786 | 0.270 |
| city256-cascading-fracture | 0.000198 | 194.809 | 0.283 |
| city256-fragmented-loaded | 0.000203 | 284.058 | 0.238 |
| city256-initial-impact | 0.000176 | 242.202 | 0.281 |
| city256-intact-idle | 0.000192 | 62.081 | 0.242 |
| city256-late-debris | 0.000191 | 402.870 | 0.289 |
| city256-post-impact | 0.000187 | 141.175 | 0.275 |
| city256-ten-second-debris | 0.000197 | 263.910 | 0.251 |
| city64-airborne | 0.000153 | 17.197 | 0.296 |
| city64-cascading-fracture | 0.000153 | 55.893 | 0.222 |
| city64-fragmented-loaded | 0.000163 | 89.680 | 0.270 |
| city64-initial-impact | 0.000132 | 63.911 | 0.207 |
| city64-intact-idle | 0.000143 | 15.712 | 0.287 |
| city64-late-debris | 0.000190 | 134.382 | 0.240 |
| city64-post-impact | 0.000236 | 37.676 | 0.222 |
| city64-ten-second-debris | 0.000161 | 102.331 | 0.239 |
| dense12-cold | 0.000100 | 32.974 | 0.221 |
| dense12-warm | 0.000134 | 32.683 | 0.208 |
| destruction-cold | 0.000097 | 3.111 | 0.174 |
| destruction-damaged | 0.000156 | 3.267 | 0.160 |
| destruction-fractured | 0.000122 | 5.298 | 0.214 |
| destruction-intact | 0.000095 | 2.951 | 0.171 |
| destruction-onset | 0.000098 | 3.940 | 0.150 |
| destruction-stimulus | 0.002598 | 3.918 | 0.168 |
| flying | 0.000148 | 2.128 | 0.000 |
| ladder128-cold | 0.000132 | 5.346 | 0.175 |
| ladder128-warm | 0.000127 | 5.087 | 0.196 |
| panel32-cold | 0.000094 | 21.905 | 0.203 |
| panel32-warm | 0.000112 | 21.811 | 0.215 |
| resting | 0.000161 | 1.565 | 0.000 |
| sliding | 0.000132 | 2.858 | 0.000 |
| tower64-cold | 0.000125 | 117.286 | 0.251 |
| tower64-warm | 0.000158 | 116.987 | 0.230 |

## Scale and timing spread

| Scenario | Chunks / bonds | Input → output clusters | New broken bonds | Standard deviation ms | Mean 95% resampling interval ms | Harness seconds |
|---|---:|---|---|---:|---|---:|
| bridge64-cold | ? / ? | ? → [1] | [0] | 0.908 | 8.282–9.057 | 4.77 |
| bridge64-warm | ? / ? | ? → [1] | [0] | 0.603 | 8.694–9.187 | 4.79 |
| building-cold | ? / ? | ? → [1] | [0] | 0.807 | 4.144–4.829 | 4.43 |
| building-fragmented | ? / ? | ? → [378] | [0] | 1.279 | 6.927–8.043 | 5.00 |
| building-warm | ? / ? | ? → [1] | [0] | 0.977 | 4.237–5.092 | 5.01 |
| cantilever64-cold | ? / ? | ? → [1] | [0] | 0.437 | 7.089–7.461 | 4.77 |
| cantilever64-warm | ? / ? | ? → [1] | [0] | 0.532 | 7.215–7.675 | 4.52 |
| chain256-cold | ? / ? | ? → [1] | [0] | 0.521 | 6.430–6.882 | 4.46 |
| chain256-warm | ? / ? | ? → [1] | [0] | 1.189 | 6.797–7.807 | 4.44 |
| chain32-cold | ? / ? | ? → [1] | [0] | 0.666 | 2.284–2.862 | 4.41 |
| chain32-warm | ? / ? | ? → [1] | [0] | 0.980 | 2.938–3.781 | 4.48 |
| city25-airborne | 11100 / 22400 | 25 → [25] | [0] | 1.104 | 10.711–11.668 | 9.58 |
| city25-cascading-fracture | 11100 / 22400 | 600 → [610] | [10] | 2.649 | 39.341–41.645 | 11.03 |
| city25-fragmented-loaded | 11100 / 22400 | 1282 → [1321] | [100] | 4.721 | 50.534–54.680 | 12.21 |
| city25-initial-impact | 11100 / 22400 | 25 → [537] | [3412] | 2.919 | 39.280–41.830 | 10.38 |
| city25-intact-idle | 11100 / 22400 | 25 → [25] | [0] | 0.773 | 9.531–10.173 | 9.35 |
| city25-late-debris | 11100 / 22400 | 1488 → [2063] | [1424] | 5.853 | 68.178–73.309 | 12.71 |
| city25-post-impact | 11100 / 22400 | 526 → [526] | [0] | 2.171 | 21.825–23.710 | 10.53 |
| city25-ten-second-debris | 11100 / 22400 | 1683 → [1776] | [184] | 5.890 | 69.523–74.659 | 13.29 |
| city256-airborne | 113664 / 229376 | 256 → [256] | [0] | 7.516 | 66.014–72.393 | 54.37 |
| city256-cascading-fracture | 113664 / 229376 | 5827 → [5852] | [25] | 14.676 | 188.884–201.619 | 65.69 |
| city256-fragmented-loaded | 113664 / 229376 | 10905 → [11382] | [1229] | 13.474 | 278.247–289.912 | 73.66 |
| city256-initial-impact | 113664 / 229376 | 256 → [5417] | [34802] | 16.810 | 235.083–249.436 | 58.99 |
| city256-intact-idle | 113664 / 229376 | 256 → [256] | [0] | 6.794 | 59.637–65.510 | 54.86 |
| city256-late-debris | 113664 / 229376 | 12214 → [16135] | [11051] | 29.127 | 391.662–417.672 | 78.72 |
| city256-post-impact | 113664 / 229376 | 5204 → [5204] | [0] | 8.184 | 137.997–144.898 | 63.95 |
| city256-ten-second-debris | 113664 / 229376 | 14795 → [15187] | [819] | 37.205 | 249.866–282.009 | 78.84 |
| city64-airborne | 28416 / 57344 | 64 → [64] | [0] | 1.914 | 16.724–18.348 | 31.54 |
| city64-cascading-fracture | 28416 / 57344 | 1460 → [1473] | [13] | 6.650 | 53.393–59.105 | 34.16 |
| city64-fragmented-loaded | 28416 / 57344 | 3010 → [3144] | [425] | 7.742 | 87.002–93.701 | 38.54 |
| city64-initial-impact | 28416 / 57344 | 64 → [1364] | [8760] | 4.555 | 62.376–66.355 | 32.23 |
| city64-intact-idle | 28416 / 57344 | 64 → [64] | [0] | 1.181 | 15.503–16.548 | 31.30 |
| city64-late-debris | 28416 / 57344 | 3957 → [5130] | [2768] | 10.958 | 130.353–139.887 | 39.28 |
| city64-post-impact | 28416 / 57344 | 1320 → [1320] | [0] | 2.463 | 36.870–38.996 | 33.13 |
| city64-ten-second-debris | 28416 / 57344 | 4565 → [4705] | [202] | 11.286 | 98.265–108.082 | 40.17 |
| dense12-cold | ? / ? | ? → [1] | [0] | 0.923 | 32.830–33.643 | 5.65 |
| dense12-warm | ? / ? | ? → [1] | [0] | 0.878 | 32.550–33.312 | 5.67 |
| destruction-cold | ? / ? | ? → [1] | [0] | 0.810 | 2.967–3.654 | 4.50 |
| destruction-damaged | ? / ? | ? → [1] | [0] | 0.977 | 3.053–3.900 | 4.45 |
| destruction-fractured | ? / ? | ? → [2] | [0] | 1.332 | 5.037–6.186 | 4.45 |
| destruction-intact | ? / ? | ? → [1] | [0] | 0.897 | 2.794–3.578 | 4.45 |
| destruction-onset | ? / ? | ? → [1] | [0] | 0.394 | 3.915–4.253 | 4.41 |
| destruction-stimulus | ? / ? | ? → [1] | [0] | 1.216 | 3.665–4.688 | 4.43 |
| flying | ? / ? | ? → [0] | [0] | 0.561 | 1.959–2.403 | 4.18 |
| ladder128-cold | ? / ? | ? → [1] | [0] | 0.821 | 5.212–5.924 | 4.81 |
| ladder128-warm | ? / ? | ? → [1] | [0] | 0.845 | 4.961–5.709 | 4.82 |
| panel32-cold | ? / ? | ? → [1] | [0] | 1.825 | 21.517–23.038 | 5.13 |
| panel32-warm | ? / ? | ? → [1] | [0] | 0.968 | 21.652–22.480 | 5.07 |
| resting | ? / ? | ? → [0] | [0] | 0.506 | 1.364–1.789 | 4.23 |
| sliding | ? / ? | ? → [0] | [0] | 0.423 | 2.686–3.054 | 4.48 |
| tower64-cold | ? / ? | ? → [1] | [0] | 0.856 | 117.185–117.929 | 8.06 |
| tower64-warm | ? / ? | ? → [1] | [0] | 1.314 | 116.723–117.855 | 8.09 |

Intervals describe variation in these samples, assuming exchangeable observations; they do not bound systematic shared-GPU interference. JSON includes first-half versus last-half means to expose drift. All samples, including first restored ticks, are retained.
