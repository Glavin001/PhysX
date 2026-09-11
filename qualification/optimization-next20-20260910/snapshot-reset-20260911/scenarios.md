# Snapshot workspace cost report

52 scenarios retain their original physical inputs and checks. 20 full ticks each; restore/validation excluded from tick milliseconds. Reusable pinned storage does not preserve prior contact/solver data. First restore allocates capacity; subsequent restores reuse it.

| Scenario | Tick mean / max ms | Repeat restore mean / max ms | First restore ms | 60 Hz misses | 120 Hz misses |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 8.753 / 10.257 | 10.842 / 12.139 | 220.371 | 0/20 | 18/20 |
| bridge64-warm | 8.822 / 11.872 | 12.246 / 20.118 | 215.672 | 0/20 | 20/20 |
| building-cold | 4.835 / 8.352 | 11.949 / 18.954 | 219.353 | 0/20 | 1/20 |
| building-fragmented | 8.887 / 15.415 | 12.183 / 16.991 | 223.692 | 0/20 | 11/20 |
| building-warm | 4.818 / 7.386 | 12.152 / 20.676 | 217.198 | 0/20 | 0/20 |
| cantilever64-cold | 7.694 / 11.224 | 8.189 / 9.426 | 217.383 | 0/20 | 2/20 |
| cantilever64-warm | 6.954 / 8.594 | 7.138 / 9.056 | 213.345 | 0/20 | 1/20 |
| chain256-cold | 7.234 / 8.594 | 7.938 / 8.811 | 216.495 | 0/20 | 1/20 |
| chain256-warm | 7.325 / 9.971 | 9.879 / 13.469 | 214.033 | 0/20 | 1/20 |
| chain32-cold | 2.841 / 6.643 | 7.624 / 13.956 | 200.256 | 0/20 | 0/20 |
| chain32-warm | 2.646 / 5.140 | 7.560 / 13.047 | 216.443 | 0/20 | 0/20 |
| dense12-cold | 33.748 / 36.679 | 26.947 / 30.335 | 233.415 | 20/20 | 20/20 |
| dense12-warm | 33.302 / 36.078 | 29.767 / 41.857 | 239.652 | 20/20 | 20/20 |
| destruction-cold | 2.567 / 6.115 | 6.333 / 8.178 | 219.472 | 0/20 | 0/20 |
| destruction-damaged | 3.228 / 7.648 | 7.518 / 10.712 | 226.065 | 0/20 | 0/20 |
| destruction-fractured | 4.329 / 7.641 | 6.314 / 8.091 | 213.016 | 0/20 | 0/20 |
| destruction-intact | 2.595 / 7.536 | 6.189 / 7.151 | 216.994 | 0/20 | 0/20 |
| destruction-onset | 3.768 / 8.894 | 6.724 / 8.767 | 214.078 | 0/20 | 1/20 |
| destruction-stimulus | 4.105 / 8.249 | 6.094 / 7.447 | 215.137 | 0/20 | 0/20 |
| flying | 1.706 / 2.321 | 0.741 / 1.198 | 122.473 | 0/20 | 0/20 |
| ladder128-cold | 5.576 / 6.952 | 11.432 / 21.997 | 217.846 | 0/20 | 0/20 |
| ladder128-warm | 5.592 / 7.505 | 11.677 / 16.567 | 219.698 | 0/20 | 0/20 |
| panel32-cold | 22.249 / 25.250 | 17.188 / 20.956 | 220.099 | 20/20 | 20/20 |
| panel32-warm | 22.338 / 24.648 | 17.204 / 23.820 | 227.306 | 20/20 | 20/20 |
| resting | 1.634 / 2.588 | 0.730 / 1.148 | 124.127 | 0/20 | 0/20 |
| sliding | 2.662 / 3.717 | 0.975 / 1.616 | 125.682 | 0/20 | 0/20 |
| tower64-cold | 117.766 / 120.598 | 28.629 / 39.655 | 229.338 | 20/20 | 20/20 |
| tower64-warm | 117.626 / 119.558 | 27.686 / 34.110 | 210.867 | 20/20 | 20/20 |
| city25-intact-idle | 9.601 / 15.944 | 44.912 / 60.780 | 376.016 | 0/20 | 20/20 |
| city25-airborne | 10.871 / 14.362 | 43.677 / 57.187 | 392.023 | 0/20 | 20/20 |
| city25-initial-impact | 40.812 / 52.200 | 45.305 / 52.595 | 393.717 | 20/20 | 20/20 |
| city25-post-impact | 24.484 / 30.557 | 48.229 / 60.023 | 372.976 | 20/20 | 20/20 |
| city25-cascading-fracture | 39.495 / 48.003 | 47.429 / 60.156 | 366.552 | 20/20 | 20/20 |
| city25-fragmented-loaded | 52.834 / 65.842 | 50.754 / 58.429 | 376.164 | 20/20 | 20/20 |
| city25-late-debris | 69.946 / 86.042 | 53.345 / 64.097 | 394.842 | 20/20 | 20/20 |
| city25-ten-second-debris | 70.265 / 88.090 | 51.905 / 58.873 | 385.009 | 20/20 | 20/20 |
| city64-intact-idle | 16.898 / 25.849 | 102.126 / 116.187 | 1063.873 | 5/20 | 20/20 |
| city64-airborne | 18.495 / 22.528 | 101.844 / 111.415 | 1068.023 | 20/20 | 20/20 |
| city64-initial-impact | 64.630 / 83.817 | 109.427 / 135.263 | 1082.737 | 20/20 | 20/20 |
| city64-post-impact | 35.363 / 41.564 | 105.619 / 142.823 | 1144.699 | 20/20 | 20/20 |
| city64-cascading-fracture | 56.874 / 68.731 | 107.214 / 120.491 | 1084.218 | 20/20 | 20/20 |
| city64-fragmented-loaded | 90.634 / 117.658 | 116.530 / 131.688 | 1107.750 | 20/20 | 20/20 |
| city64-late-debris | 132.341 / 166.994 | 115.508 / 130.743 | 1093.219 | 20/20 | 20/20 |
| city64-ten-second-debris | 99.766 / 139.785 | 116.407 / 125.177 | 1094.861 | 20/20 | 20/20 |
| city256-intact-idle | 59.200 / 73.979 | 370.612 / 401.541 | 1868.813 | 20/20 | 20/20 |
| city256-airborne | 66.190 / 83.926 | 370.674 / 431.015 | 1852.933 | 20/20 | 20/20 |
| city256-initial-impact | 236.880 / 254.511 | 372.699 / 396.687 | 1838.402 | 20/20 | 20/20 |
| city256-post-impact | 139.608 / 166.765 | 419.678 / 449.106 | 1880.089 | 20/20 | 20/20 |
| city256-cascading-fracture | 190.403 / 218.459 | 424.093 / 479.549 | 1913.884 | 20/20 | 20/20 |
| city256-fragmented-loaded | 283.125 / 311.861 | 457.286 / 484.982 | 1935.709 | 20/20 | 20/20 |
| city256-late-debris | 394.491 / 458.203 | 468.164 / 505.606 | 1987.419 | 20/20 | 20/20 |
| city256-ten-second-debris | 264.837 / 350.839 | 497.298 / 536.252 | 1974.070 | 20/20 | 20/20 |

Totals (seconds):

- harness_s: 388.529
- ticks_s: 58.473
- restore_s: 127.149
- validation_s: 75.340
- teardown_s: 42.766
- context_setup_s: 40.560
- other_process_s: 44.242

`report.json` includes all disjoint stages, pool allocations/reuses/capacity and previous workflow measurements. Differences in full ticks are not claimed as application speedups. The combined physics/stress stage includes transfers and synchronization; no stock-PhysX-only timing is implied.
