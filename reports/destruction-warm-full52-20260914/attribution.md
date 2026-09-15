# Warm CPU/GPU attribution and core-counter coverage

CPU/GPU traces: **52/52**; core counters: **52/52**. This is diagnostic coverage, not a speedup or exhaustive metric/source-counter claim.

1,799 CPU samples, 34,243 native phase scopes and 13,377 recorded kernel launches. Counter inventories cover 408 graph invocations and 4,480 ordinary launch representatives at 2,639 configurations.

Instrumented milliseconds below must not replace the unprofiled full-step timings. GPU activity is interval union; scheduled CPU may overlap it. Coverage fractions refer to observed kernel time in the matched timeline.

| Scenario | Profiled tick ms | GPU activity ms | CPU samples | Kernel launches | Copies / MB | Graph / ordinary counter launches | Observed kernel coverage | Warnings |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| bridge64-cold | 8.588 | 0.066 | 6 | 62 | 11 / 0.00 | 6 / 35 | 99.353% | NVTX boundary |
| bridge64-warm | 8.146 | 0.066 | 6 | 62 | 11 / 0.00 | 6 / 35 | 99.353% | NVTX boundary |
| building-cold | 7.942 | 0.063 | 7 | 62 | 11 / 0.00 | 6 / 35 | 99.273% | NVTX boundary |
| building-fragmented | 24.130 | 0.962 | 27 | 198 | 91 / 0.69 | 6 / 110 | 99.060% | NVTX boundary |
| building-warm | 8.106 | 0.063 | 10 | 62 | 11 / 0.00 | 6 / 35 | 99.325% | NVTX boundary |
| cantilever64-cold | 9.809 | 0.106 | 8 | 62 | 11 / 0.00 | 6 / 34 | 99.197% | NVTX boundary |
| cantilever64-warm | 8.671 | 0.106 | 7 | 62 | 11 / 0.00 | 6 / 34 | 99.195% | NVTX boundary |
| chain256-cold | 13.838 | 0.118 | 8 | 62 | 11 / 0.00 | 6 / 34 | 99.287% | NVTX boundary, CUDA boundary, OS boundary |
| chain256-warm | 12.367 | 0.118 | 7 | 62 | 11 / 0.00 | 6 / 34 | 99.258% | NVTX boundary, CUDA boundary, OS boundary |
| chain32-cold | 12.055 | 0.060 | 7 | 62 | 11 / 0.00 | 6 / 35 | 99.284% | NVTX boundary, CUDA boundary, OS boundary |
| chain32-warm | 13.226 | 0.060 | 7 | 62 | 11 / 0.00 | 6 / 35 | 99.282% | NVTX boundary, CUDA boundary, OS boundary |
| dense12-cold | 13.397 | 0.084 | 8 | 62 | 11 / 0.00 | 6 / 35 | 99.463% | NVTX boundary, CUDA boundary, OS boundary |
| dense12-warm | 13.794 | 0.084 | 8 | 62 | 11 / 0.00 | 6 / 35 | 99.503% | NVTX boundary, CUDA boundary, OS boundary |
| destruction-cold | 12.622 | 0.060 | 8 | 62 | 11 / 0.00 | 6 / 35 | 99.282% | NVTX boundary, CUDA boundary, OS boundary |
| destruction-damaged | 15.055 | 0.060 | 6 | 62 | 11 / 0.00 | 6 / 35 | 99.283% | NVTX boundary, CUDA boundary, OS boundary |
| destruction-fractured | 20.773 | 0.293 | 17 | 153 | 56 / 0.04 | 6 / 90 | 99.048% | NVTX boundary, CUDA boundary, OS boundary |
| destruction-intact | 9.644 | 0.060 | 5 | 62 | 11 / 0.00 | 6 / 35 | 99.284% | NVTX boundary, CUDA boundary, OS boundary |
| destruction-onset | 21.956 | 0.341 | 18 | 167 | 64 / 0.04 | 6 / 100 | 99.006% | NVTX boundary, CUDA boundary, OS boundary |
| destruction-stimulus | 23.144 | 0.346 | 19 | 170 | 69 / 0.04 | 6 / 100 | 99.017% | NVTX boundary, CUDA boundary, OS boundary |
| flying | 13.298 | 0.165 | 7 | 59 | 29 / 0.01 | 0 / 30 | 99.207% | NVTX boundary, CUDA boundary, OS boundary |
| ladder128-cold | 14.227 | 0.063 | 8 | 62 | 11 / 0.00 | 6 / 35 | 99.319% | NVTX boundary, CUDA boundary, OS boundary |
| ladder128-warm | 12.345 | 0.063 | 7 | 62 | 11 / 0.00 | 6 / 35 | 99.261% | NVTX boundary, CUDA boundary, OS boundary |
| panel32-cold | 12.988 | 0.067 | 7 | 62 | 11 / 0.00 | 6 / 35 | 99.358% | NVTX boundary, CUDA boundary, OS boundary |
| panel32-warm | 12.083 | 0.067 | 7 | 62 | 11 / 0.00 | 6 / 35 | 99.362% | NVTX boundary, CUDA boundary, OS boundary |
| resting | 6.034 | 0.003 | 1 | 1 | 5 / 0.00 | 0 / 1 | 100.000% | NVTX boundary, CUDA boundary, OS boundary |
| sliding | 12.899 | 0.217 | 10 | 78 | 46 / 0.03 | 0 / 42 | 99.075% | NVTX boundary, CUDA boundary, OS boundary |
| tower64-cold | 13.057 | 0.086 | 7 | 62 | 11 / 0.00 | 6 / 35 | 99.515% | NVTX boundary, CUDA boundary, OS boundary |
| tower64-warm | 13.282 | 0.086 | 8 | 62 | 11 / 0.00 | 6 / 34 | 99.029% | NVTX boundary, CUDA boundary, OS boundary |
| city25-intact-idle | 12.958 | 0.079 | 7 | 62 | 11 / 0.01 | 6 / 35 | 99.462% | NVTX boundary, CUDA boundary, OS boundary |
| city25-airborne | 19.415 | 0.395 | 13 | 138 | 34 / 0.86 | 6 / 78 | 99.022% | NVTX boundary, CUDA boundary, OS boundary |
| city25-initial-impact | 100.617 | 13.893 | 80 | 706 | 207 / 4.11 | 18 / 228 | 99.000% | none |
| city25-post-impact | 47.210 | 7.958 | 39 | 241 | 124 / 3.14 | 6 / 84 | 99.019% | NVTX boundary, CUDA boundary, OS boundary |
| city25-cascading-fracture | 67.168 | 16.798 | 49 | 635 | 242 / 4.60 | 14 / 230 | 99.010% | NVTX boundary, CUDA boundary, OS boundary |
| city25-fragmented-loaded | 39.273 | 10.065 | 31 | 251 | 110 / 3.67 | 6 / 68 | 99.009% | NVTX boundary, CUDA boundary, OS boundary |
| city25-late-debris | 98.583 | 25.955 | 81 | 868 | 314 / 11.79 | 16 / 239 | 99.009% | NVTX boundary, CUDA boundary, OS boundary |
| city25-ten-second-debris | 41.316 | 12.141 | 26 | 273 | 161 / 2.20 | 6 / 110 | 99.001% | NVTX boundary, CUDA boundary, OS boundary |
| city64-intact-idle | 12.834 | 0.109 | 7 | 62 | 11 / 0.02 | 6 / 34 | 99.211% | NVTX boundary, CUDA boundary, OS boundary |
| city64-airborne | 20.420 | 0.627 | 15 | 140 | 34 / 1.98 | 6 / 70 | 99.061% | NVTX boundary, CUDA boundary, OS boundary |
| city64-initial-impact | 123.449 | 17.487 | 120 | 710 | 207 / 10.17 | 18 / 182 | 99.011% | none |
| city64-post-impact | 45.493 | 9.456 | 39 | 271 | 124 / 7.91 | 6 / 98 | 99.010% | NVTX boundary, CUDA boundary, OS boundary |
| city64-cascading-fracture | 86.097 | 21.442 | 73 | 663 | 240 / 11.21 | 14 / 219 | 99.009% | NVTX boundary, CUDA boundary, OS boundary |
| city64-fragmented-loaded | 48.106 | 15.445 | 37 | 269 | 125 / 9.27 | 6 / 88 | 99.003% | NVTX boundary, CUDA boundary, OS boundary |
| city64-late-debris | 111.892 | 38.080 | 93 | 858 | 314 / 27.71 | 16 / 270 | 99.027% | NVTX boundary, CUDA boundary, OS boundary |
| city64-ten-second-debris | 95.060 | 28.272 | 71 | 778 | 295 / 12.80 | 14 / 201 | 99.005% | NVTX boundary, CUDA boundary, OS boundary |
| city256-intact-idle | 15.719 | 0.354 | 8 | 62 | 11 / 0.07 | 6 / 30 | 99.103% | NVTX boundary, CUDA boundary, OS boundary |
| city256-airborne | 21.464 | 1.924 | 17 | 141 | 34 / 7.91 | 6 / 67 | 99.047% | NVTX boundary, CUDA boundary, OS boundary |
| city256-initial-impact | 264.442 | 68.256 | 263 | 730 | 207 / 40.81 | 18 / 136 | 99.006% | NVTX boundary, CUDA boundary, OS boundary |
| city256-post-impact | 71.143 | 31.247 | 52 | 290 | 121 / 30.95 | 6 / 57 | 99.026% | NVTX boundary, CUDA boundary, OS boundary |
| city256-cascading-fracture | 136.783 | 66.866 | 99 | 709 | 247 / 45.23 | 14 / 145 | 99.005% | NVTX boundary, OS boundary |
| city256-fragmented-loaded | 157.414 | 83.203 | 106 | 721 | 247 / 71.34 | 14 / 149 | 99.017% | NVTX boundary, CUDA boundary, OS boundary |
| city256-late-debris | 180.464 | 100.092 | 139 | 903 | 307 / 98.69 | 16 / 206 | 99.021% | NVTX boundary |
| city256-ten-second-debris | 102.635 | 38.123 | 83 | 768 | 286 / 41.50 | 14 / 253 | 99.033% | NVTX boundary, CUDA boundary, OS boundary |

## CPU/GPU overlap per scenario

These four mutually exclusive wall intervals sum to the profiled tick. Scheduled CPU is not proof of useful engine computation; it can include collector or driver work. No recorded activity is not proof that the interval is removable. Unresolved samples remain visible.

| Scenario | CPU + GPU ms | GPU without scheduled CPU ms | CPU without recorded GPU ms | Neither recorded ms | Unresolved CPU samples |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 0.066 | 0.000 | 7.868 | 0.655 | 5/6 |
| bridge64-warm | 0.066 | 0.000 | 7.744 | 0.337 | 6/6 |
| building-cold | 0.063 | 0.000 | 7.504 | 0.374 | 5/7 |
| building-fragmented | 0.962 | 0.000 | 22.975 | 0.192 | 20/27 |
| building-warm | 0.063 | 0.000 | 7.764 | 0.279 | 8/10 |
| cantilever64-cold | 0.106 | 0.000 | 9.315 | 0.389 | 6/8 |
| cantilever64-warm | 0.106 | 0.000 | 8.311 | 0.255 | 6/7 |
| chain256-cold | 0.118 | 0.000 | 13.055 | 0.665 | 6/8 |
| chain256-warm | 0.118 | 0.000 | 12.010 | 0.239 | 5/7 |
| chain32-cold | 0.060 | 0.000 | 11.093 | 0.902 | 6/7 |
| chain32-warm | 0.060 | 0.000 | 12.506 | 0.660 | 7/7 |
| dense12-cold | 0.084 | 0.000 | 12.961 | 0.352 | 7/8 |
| dense12-warm | 0.084 | 0.000 | 13.298 | 0.412 | 6/8 |
| destruction-cold | 0.060 | 0.000 | 12.188 | 0.374 | 6/8 |
| destruction-damaged | 0.060 | 0.000 | 11.402 | 3.594 | 6/6 |
| destruction-fractured | 0.293 | 0.000 | 20.175 | 0.305 | 16/17 |
| destruction-intact | 0.060 | 0.000 | 9.014 | 0.570 | 4/5 |
| destruction-onset | 0.341 | 0.000 | 21.367 | 0.248 | 13/18 |
| destruction-stimulus | 0.346 | 0.000 | 22.642 | 0.157 | 16/19 |
| flying | 0.165 | 0.000 | 11.395 | 1.738 | 7/7 |
| ladder128-cold | 0.063 | 0.000 | 13.896 | 0.269 | 6/8 |
| ladder128-warm | 0.063 | 0.000 | 11.859 | 0.423 | 5/7 |
| panel32-cold | 0.067 | 0.000 | 12.208 | 0.713 | 7/7 |
| panel32-warm | 0.067 | 0.000 | 11.670 | 0.346 | 7/7 |
| resting | 0.003 | 0.000 | 5.784 | 0.248 | 0/1 |
| sliding | 0.217 | 0.000 | 12.528 | 0.154 | 7/10 |
| tower64-cold | 0.086 | 0.000 | 12.155 | 0.817 | 6/7 |
| tower64-warm | 0.086 | 0.000 | 11.927 | 1.269 | 5/8 |
| city25-intact-idle | 0.079 | 0.000 | 12.441 | 0.438 | 5/7 |
| city25-airborne | 0.395 | 0.000 | 18.383 | 0.637 | 12/13 |
| city25-initial-impact | 9.012 | 4.881 | 79.900 | 6.824 | 54/80 |
| city25-post-impact | 4.799 | 3.159 | 37.803 | 1.448 | 28/39 |
| city25-cascading-fracture | 5.781 | 11.017 | 48.066 | 2.304 | 44/49 |
| city25-fragmented-loaded | 3.934 | 6.131 | 28.813 | 0.395 | 22/31 |
| city25-late-debris | 10.229 | 15.726 | 70.192 | 2.435 | 67/81 |
| city25-ten-second-debris | 3.768 | 8.373 | 26.052 | 3.123 | 19/26 |
| city64-intact-idle | 0.109 | 0.000 | 12.223 | 0.502 | 6/7 |
| city64-airborne | 0.627 | 0.000 | 19.446 | 0.347 | 12/15 |
| city64-initial-impact | 11.802 | 5.684 | 104.487 | 1.475 | 77/120 |
| city64-post-impact | 3.425 | 6.031 | 35.605 | 0.433 | 30/39 |
| city64-cascading-fracture | 8.619 | 12.823 | 63.277 | 1.379 | 57/73 |
| city64-fragmented-loaded | 3.723 | 11.721 | 31.923 | 0.738 | 29/37 |
| city64-late-debris | 12.456 | 25.624 | 72.124 | 1.688 | 60/93 |
| city64-ten-second-debris | 8.524 | 19.749 | 64.281 | 2.507 | 60/71 |
| city256-intact-idle | 0.354 | 0.000 | 12.921 | 2.444 | 6/8 |
| city256-airborne | 1.924 | 0.000 | 19.291 | 0.249 | 11/17 |
| city256-initial-impact | 34.332 | 33.925 | 193.558 | 2.628 | 130/263 |
| city256-post-impact | 6.850 | 24.397 | 38.972 | 0.923 | 26/52 |
| city256-cascading-fracture | 17.956 | 48.911 | 68.329 | 1.587 | 64/99 |
| city256-fragmented-loaded | 21.803 | 61.400 | 72.187 | 2.024 | 65/106 |
| city256-late-debris | 32.083 | 68.008 | 77.680 | 2.692 | 74/139 |
| city256-ten-second-debris | 15.643 | 22.480 | 62.706 | 1.806 | 63/83 |

## Use the saved data

[Structured coverage index](data/coverage.json) links each capture directory and includes ranked kernel families and native CPU scopes. Read `attribution-normalized.json` for physical CUDA call counts, stacks, waits, thread CPU phases and disjoint wall accounting. Raw `attribution.json`/SQLite preserve original API aliases. `native.phases.csv` retains the detailed engine scopes. Each counter directory holds the native `.ncu-rep`, CSV and structured metrics. Each capture includes its exact command, binary/module/input hashes and physical comparison.

API normalization removed 15,901 verified nested/versioned alias records from physical call counts; raw evidence is unchanged. 0 out-of-range percentage ratios are retained and flagged in the coverage JSON, not silently interpreted.

Core metrics include duration, achieved occupancy, issue activity, DRAM throughput and kernel launch resources. Detailed cache/eligible-warp/FP64/stall metrics were not collected across all52. Conditional graph node/source counters remain unsupported; graph aggregates are separate. CPU sample counts can be low for short ticks; use native phase clocks and repeated targeted sampling before fine-grained CPU claims. The selected NVTX ranges and native scope inventories match, but range-boundary warnings preclude an unconditional exhaustive-event claim.
