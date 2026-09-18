# End-to-end attribution coverage

Diagnostic CPU sampling, scheduling, engine phases, CUDA/OS calls and GPU activity. No application optimization or speedup. Baseline times are separate unprofiled 20-sample restored full ticks, excluding restore and validation.

CPU attribution: **52/52** qualified scenarios, **104** checked restored ticks, **21,401** CPU samples, **91,538** engine phase scopes and **18,376** GPU launches. Incomplete scenarios remain visible.

The user authorized reversible recovery and rebooted the host. The original faulted capture remains quarantined; a reduced-tracing retry and all remaining CPU scenarios now pass. No recurrent Xid was logged in the resumed campaign. The precise firmware fault trigger is unproven.

| Scenario | Unprofiled mean / peak ms | Command / simulate-fetch / completion means ms | 60 / 120 Hz misses (20 samples) | CPU attribution | CPU samples |
|---|---:|---:|---:|---|---:|
| bridge64-cold | 8.753 / 10.257 | 0.000 / 8.559 / 0.194 | 0 / 18 | complete | 101 |
| bridge64-warm | 8.822 / 11.872 | 0.000 / 8.623 / 0.199 | 0 / 20 | complete | 103 |
| building-cold | 4.835 / 8.352 | 0.000 / 4.651 / 0.183 | 0 / 1 | complete | 109 |
| building-fragmented | 8.887 / 15.415 | 0.000 / 8.661 / 0.225 | 0 / 11 | complete | 189 |
| building-warm | 4.818 / 7.386 | 0.000 / 4.644 / 0.173 | 0 / 0 | complete | 97 |
| cantilever64-cold | 7.694 / 11.224 | 0.000 / 7.484 / 0.210 | 0 / 2 | complete | 82 |
| cantilever64-warm | 6.954 / 8.594 | 0.000 / 6.758 / 0.196 | 0 / 1 | complete | 93 |
| chain256-cold | 7.234 / 8.594 | 0.000 / 7.096 / 0.137 | 0 / 1 | complete | 65 |
| chain256-warm | 7.325 / 9.971 | 0.000 / 7.100 / 0.225 | 0 / 1 | complete | 100 |
| chain32-cold | 2.841 / 6.643 | 0.000 / 2.649 / 0.192 | 0 / 0 | complete | 101 |
| chain32-warm | 2.646 / 5.140 | 0.000 / 2.481 / 0.165 | 0 / 0 | complete | 95 |
| dense12-cold | 33.748 / 36.679 | 0.000 / 33.498 / 0.249 | 20 / 20 | complete | 92 |
| dense12-warm | 33.302 / 36.078 | 0.000 / 33.089 / 0.213 | 20 / 20 | complete | 113 |
| destruction-cold | 2.567 / 6.115 | 0.000 / 2.379 / 0.187 | 0 / 0 | complete | 64 |
| destruction-damaged | 3.228 / 7.648 | 0.000 / 2.983 / 0.245 | 0 / 0 | complete | 117 |
| destruction-fractured | 4.329 / 7.641 | 0.000 / 4.112 / 0.217 | 0 / 0 | complete | 113 |
| destruction-intact | 2.595 / 7.536 | 0.000 / 2.362 / 0.233 | 0 / 0 | complete | 91 |
| destruction-onset | 3.768 / 8.894 | 0.000 / 3.577 / 0.191 | 0 / 1 | complete | 122 |
| destruction-stimulus | 4.105 / 8.249 | 0.002 / 3.957 / 0.146 | 0 / 0 | complete | 118 |
| flying | 1.706 / 2.321 | 0.000 / 1.706 / 0.000 | 0 / 0 | complete | 32 |
| ladder128-cold | 5.576 / 6.952 | 0.000 / 5.392 / 0.184 | 0 / 0 | complete | 73 |
| ladder128-warm | 5.592 / 7.505 | 0.000 / 5.398 / 0.194 | 0 / 0 | complete | 100 |
| panel32-cold | 22.249 / 25.250 | 0.000 / 22.011 / 0.238 | 20 / 20 | complete | 106 |
| panel32-warm | 22.338 / 24.648 | 0.000 / 22.139 / 0.198 | 20 / 20 | complete | 54 |
| resting | 1.634 / 2.588 | 0.000 / 1.633 / 0.000 | 0 / 0 | complete | 26 |
| sliding | 2.662 / 3.717 | 0.000 / 2.660 / 0.001 | 0 / 0 | complete | 56 |
| tower64-cold | 117.766 / 120.598 | 0.000 / 117.532 / 0.234 | 20 / 20 | complete | 117 |
| tower64-warm | 117.626 / 119.558 | 0.000 / 117.390 / 0.236 | 20 / 20 | complete | 118 |
| city25-intact-idle | 9.601 / 15.944 | 0.000 / 9.375 / 0.226 | 0 / 20 | complete | 164 |
| city25-airborne | 10.871 / 14.362 | 0.000 / 10.655 / 0.217 | 0 / 20 | complete | 187 |
| city25-initial-impact | 40.812 / 52.200 | 0.000 / 40.602 / 0.210 | 20 / 20 | complete | 529 |
| city25-post-impact | 24.484 / 30.557 | 0.000 / 24.277 / 0.207 | 20 / 20 | complete | 186 |
| city25-cascading-fracture | 39.495 / 48.003 | 0.000 / 39.298 / 0.197 | 20 / 20 | complete | 493 |
| city25-fragmented-loaded | 52.834 / 65.842 | 0.000 / 52.592 / 0.242 | 20 / 20 | complete | 537 |
| city25-late-debris | 69.946 / 86.042 | 0.000 / 69.739 / 0.206 | 20 / 20 | complete | 627 |
| city25-ten-second-debris | 70.265 / 88.090 | 0.000 / 70.068 / 0.197 | 20 / 20 | complete | 613 |
| city64-intact-idle | 16.898 / 25.849 | 0.000 / 16.640 / 0.259 | 5 / 20 | complete | 263 |
| city64-airborne | 18.495 / 22.528 | 0.000 / 18.274 / 0.222 | 20 / 20 | complete | 290 |
| city64-initial-impact | 64.630 / 83.817 | 0.000 / 64.404 / 0.225 | 20 / 20 | complete | 694 |
| city64-post-impact | 35.363 / 41.564 | 0.000 / 35.148 / 0.214 | 20 / 20 | complete | 396 |
| city64-cascading-fracture | 56.874 / 68.731 | 0.000 / 56.666 / 0.208 | 20 / 20 | complete | 581 |
| city64-fragmented-loaded | 90.634 / 117.658 | 0.000 / 90.400 / 0.234 | 20 / 20 | complete | 808 |
| city64-late-debris | 132.341 / 166.994 | 0.000 / 132.125 / 0.216 | 20 / 20 | complete | 1132 |
| city64-ten-second-debris | 99.766 / 139.785 | 0.000 / 99.559 / 0.207 | 20 / 20 | complete | 836 |
| city256-intact-idle | 59.200 / 73.979 | 0.000 / 58.977 / 0.223 | 20 / 20 | complete | 521 |
| city256-airborne | 66.190 / 83.926 | 0.000 / 65.931 / 0.259 | 20 / 20 | complete | 608 |
| city256-initial-impact | 236.880 / 254.511 | 0.000 / 236.657 / 0.223 | 20 / 20 | complete | 1705 |
| city256-post-impact | 139.608 / 166.765 | 0.000 / 139.356 / 0.251 | 20 / 20 | complete | 892 |
| city256-cascading-fracture | 190.403 / 218.459 | 0.000 / 190.145 / 0.258 | 20 / 20 | complete | 1013 |
| city256-fragmented-loaded | 283.125 / 311.861 | 0.000 / 282.869 / 0.256 | 20 / 20 | complete | 1766 |
| city256-late-debris | 394.491 / 458.203 | 0.000 / 394.227 / 0.263 | 20 / 20 | complete | 2561 |
| city256-ten-second-debris | 264.837 / 350.839 | 0.000 / 264.592 / 0.245 | 20 / 20 | complete | 1352 |

## Same-trace wall accounting

These instrumented durations include profiler overhead and are not benchmark results. The four columns form a disjoint partition of each tick; they must not be added to kernel/API sums or compared by subtraction with the unprofiled times above. Scheduled CPU includes observed profiler/driver threads. Neither is an observation gap, not proof of removable idle time.

| Scenario | GPU + scheduled CPU ms | GPU only ms | Scheduled CPU only ms | Neither ms | Unresolved leaf samples / total |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 3.388 | 2.299 | 31.531 | 0.831 | 73 / 101 |
| bridge64-warm | 2.960 | 2.737 | 32.650 | 0.771 | 80 / 103 |
| building-cold | 1.852 | 0.000 | 33.449 | 0.298 | 89 / 109 |
| building-fragmented | 1.197 | 0.000 | 55.644 | 0.502 | 134 / 189 |
| building-warm | 1.838 | 0.000 | 31.540 | 0.583 | 69 / 97 |
| cantilever64-cold | 3.271 | 1.543 | 23.202 | 0.463 | 67 / 82 |
| cantilever64-warm | 3.362 | 1.447 | 27.504 | 0.788 | 76 / 93 |
| chain256-cold | 1.679 | 2.826 | 19.652 | 0.772 | 54 / 65 |
| chain256-warm | 3.430 | 1.218 | 30.150 | 0.551 | 83 / 100 |
| chain32-cold | 0.511 | 0.000 | 35.001 | 1.717 | 73 / 101 |
| chain32-warm | 0.492 | 0.000 | 33.434 | 0.521 | 72 / 95 |
| dense12-cold | 6.023 | 23.090 | 26.956 | 1.168 | 69 / 92 |
| dense12-warm | 6.163 | 23.558 | 33.487 | 0.830 | 85 / 113 |
| destruction-cold | 0.354 | 0.000 | 20.011 | 0.976 | 51 / 64 |
| destruction-damaged | 0.345 | 0.000 | 40.130 | 0.132 | 97 / 117 |
| destruction-fractured | 0.449 | 0.000 | 35.190 | 2.837 | 89 / 113 |
| destruction-intact | 0.347 | 0.000 | 30.995 | 1.666 | 75 / 91 |
| destruction-onset | 0.396 | 0.000 | 38.885 | 2.895 | 95 / 122 |
| destruction-stimulus | 0.399 | 0.000 | 38.399 | 0.373 | 94 / 118 |
| flying | 0.191 | 0.000 | 12.057 | 0.442 | 24 / 32 |
| ladder128-cold | 3.366 | 0.011 | 21.883 | 0.692 | 60 / 73 |
| ladder128-warm | 2.804 | 0.000 | 31.595 | 0.671 | 80 / 100 |
| panel32-cold | 3.635 | 15.508 | 31.884 | 3.644 | 78 / 106 |
| panel32-warm | 1.813 | 17.279 | 16.094 | 0.783 | 40 / 54 |
| resting | 0.148 | 0.000 | 8.969 | 0.165 | 20 / 26 |
| sliding | 0.259 | 0.000 | 17.747 | 0.124 | 45 / 56 |
| tower64-cold | 7.175 | 108.666 | 34.245 | 0.691 | 90 / 117 |
| tower64-warm | 6.211 | 109.338 | 35.496 | 1.253 | 89 / 118 |
| city25-intact-idle | 3.391 | 0.000 | 46.350 | 0.520 | 114 / 164 |
| city25-airborne | 3.562 | 0.000 | 52.693 | 0.958 | 131 / 187 |
| city25-initial-impact | 8.804 | 6.385 | 137.628 | 3.304 | 375 / 529 |
| city25-post-impact | 4.997 | 3.358 | 50.549 | 1.726 | 113 / 186 |
| city25-cascading-fracture | 13.014 | 4.500 | 133.656 | 2.345 | 339 / 493 |
| city25-fragmented-loaded | 10.610 | 12.477 | 141.560 | 2.472 | 367 / 537 |
| city25-late-debris | 13.746 | 11.605 | 159.023 | 2.982 | 370 / 627 |
| city25-ten-second-debris | 10.909 | 25.714 | 174.730 | 2.694 | 399 / 613 |
| city64-intact-idle | 4.705 | 0.000 | 69.675 | 1.210 | 151 / 263 |
| city64-airborne | 4.615 | 0.364 | 78.495 | 1.326 | 178 / 290 |
| city64-initial-impact | 14.067 | 5.952 | 176.364 | 4.106 | 387 / 694 |
| city64-post-impact | 6.557 | 4.615 | 102.658 | 1.681 | 203 / 396 |
| city64-cascading-fracture | 14.935 | 7.388 | 152.040 | 3.005 | 366 / 581 |
| city64-fragmented-loaded | 20.031 | 13.986 | 202.202 | 3.777 | 421 / 808 |
| city64-late-debris | 18.081 | 20.591 | 272.851 | 3.486 | 526 / 1132 |
| city64-ten-second-debris | 14.822 | 24.256 | 218.096 | 4.148 | 415 / 836 |
| city256-intact-idle | 11.285 | 7.296 | 117.021 | 4.607 | 211 / 521 |
| city256-airborne | 12.046 | 7.311 | 146.019 | 4.207 | 192 / 608 |
| city256-initial-impact | 49.035 | 34.068 | 380.987 | 6.857 | 676 / 1705 |
| city256-post-impact | 16.781 | 22.796 | 213.512 | 6.935 | 303 / 892 |
| city256-cascading-fracture | 41.698 | 35.772 | 222.890 | 11.256 | 413 / 1013 |
| city256-fragmented-loaded | 52.974 | 57.890 | 399.644 | 5.839 | 629 / 1766 |
| city256-late-debris | 54.876 | 61.361 | 566.320 | 9.677 | 778 / 2561 |
| city256-ten-second-debris | 41.466 | 43.613 | 298.877 | 3.230 | 504 / 1352 |

## Reading the raw evidence

Each qualified scenario directory contains the native Systems report and SQLite database, `attribution.json`, exact command and module/input hashes, physical comparison, and the reused native host/CPU/device-phase CSVs. The JSON links kernels and copies to streams, launch APIs, CPU callers and engine scopes where present. All recorded CPU stack frames and thread scheduling events remain in SQLite; unresolved driver/kernel symbols are explicitly counted.

The native phase recorder provides thread CPU clocks and nested scope accounting. Detached cross-thread durations are wall intervals; unmeasured leaf CPU time is never invented. Samples are statistical counts. A low-count function needs additional samples before a fine-grained CPU performance claim. CUDA API waits can overlap useful GPU execution. Device phase event durations include dependencies and submission gaps, not just kernel execution.

The expanded kernel collector selects at least 99% of aggregate GPU kernel duration, every family costing at least 0.1ms and stress, then requests every invocation of those families, preserving trial/correction and launch configurations. Both thresholds are adjustable, including 100% coverage. An inventory audit rejects silently skipped kernels. This collector is implemented but its broad GPU qualification remains pending; conditional-graph support is a known gap in the pinned 2025 collector.

GPU allocation/all-API tracing is a separate opt-in diagnostic. Exact capture options remain in each receipt; mixed tracing options are not a matched timing comparison. Reduced tracing is not a proven firmware-fault fix.

Prior 52-scenario selected/stress captures remain available. See the accompanying qualification report for expanded inventory status.

See the separate continuous attribution campaign; snapshot coverage does not establish warm coverage.
