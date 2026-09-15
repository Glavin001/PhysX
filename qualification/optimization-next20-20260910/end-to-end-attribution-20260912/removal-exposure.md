# Measured exposure for removal priorities

Diagnostic exposure only. Kernel aggregates overlap CPU and may overlap each other. Exclusive thread CPU excludes nested recorded CPU scopes, not concurrent GPU work. These quantities are not predicted or subtractable full-step savings. Cold snapshot baseline has20 full ticks per case; current N20 comparisons remain a separate cohort.

A large parent scope does not justify attributing its cost to repeated pointer validation. That candidate is held before implementation; the next diagnostic reuses the existing per-component work recorder.

| Restored scenario | Unprofiled mean / peak ms | Iteration / modes / materials / input GPU aggregate ms | Allocation / validation / migration exclusive thread CPU ms |
|---|---:|---:|---:|
| bridge64-cold | 8.753 / 10.257 | 5.307 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| bridge64-warm | 8.822 / 11.872 | 5.317 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| building-cold | 4.835 / 8.352 | 1.492 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| building-fragmented | 8.887 / 15.415 | 0.188 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| building-warm | 4.818 / 7.386 | 1.487 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| cantilever64-cold | 7.694 / 11.224 | 4.487 / 0.000 / 0.004 / 0.003 | 0.000 / 0.000 / 0.000 |
| cantilever64-warm | 6.954 / 8.594 | 4.491 / 0.000 / 0.004 / 0.003 | 0.000 / 0.000 / 0.000 |
| chain256-cold | 7.234 / 8.594 | 4.162 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| chain256-warm | 7.325 / 9.971 | 4.311 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| chain32-cold | 2.841 / 6.643 | 0.174 / 0.000 / 0.004 / 0.003 | 0.000 / 0.000 / 0.000 |
| chain32-warm | 2.646 / 5.140 | 0.174 / 0.000 / 0.004 / 0.003 | 0.000 / 0.000 / 0.000 |
| dense12-cold | 33.748 / 36.679 | 28.666 / 0.000 / 0.006 / 0.004 | 0.000 / 0.000 / 0.000 |
| dense12-warm | 33.302 / 36.078 | 29.283 / 0.000 / 0.006 / 0.004 | 0.000 / 0.000 / 0.000 |
| destruction-cold | 2.567 / 6.115 | 0.034 / 0.000 / 0.005 / 0.003 | 0.000 / 0.000 / 0.000 |
| destruction-damaged | 3.228 / 7.648 | 0.034 / 0.000 / 0.005 / 0.003 | 0.000 / 0.000 / 0.000 |
| destruction-fractured | 4.329 / 7.641 | 0.002 / 0.000 / 0.003 / 0.002 | 0.000 / 0.000 / 0.000 |
| destruction-intact | 2.595 / 7.536 | 0.034 / 0.000 / 0.005 / 0.003 | 0.000 / 0.000 / 0.000 |
| destruction-onset | 3.768 / 8.894 | 0.034 / 0.000 / 0.005 / 0.003 | 0.000 / 0.000 / 0.000 |
| destruction-stimulus | 4.105 / 8.249 | 0.034 / 0.000 / 0.005 / 0.003 | 0.000 / 0.000 / 0.000 |
| flying | 1.706 / 2.321 | 0.000 / 0.000 / 0.000 / 0.000 | 0.000 / 0.000 / 0.000 |
| ladder128-cold | 5.576 / 6.952 | 3.028 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| ladder128-warm | 5.592 / 7.505 | 2.462 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| panel32-cold | 22.249 / 25.250 | 18.736 / 0.000 / 0.005 / 0.004 | 0.000 / 0.000 / 0.000 |
| panel32-warm | 22.338 / 24.648 | 18.686 / 0.000 / 0.006 / 0.004 | 0.000 / 0.000 / 0.000 |
| resting | 1.634 / 2.588 | 0.000 / 0.000 / 0.000 / 0.000 | 0.000 / 0.000 / 0.000 |
| sliding | 2.662 / 3.717 | 0.000 / 0.000 / 0.000 / 0.000 | 0.000 / 0.000 / 0.000 |
| tower64-cold | 117.766 / 120.598 | 115.336 / 0.000 / 0.006 / 0.004 | 0.000 / 0.000 / 0.000 |
| tower64-warm | 117.626 / 119.558 | 115.053 / 0.000 / 0.006 / 0.004 | 0.000 / 0.000 / 0.000 |
| city25-intact-idle | 9.601 / 15.944 | 2.327 / 0.000 / 0.010 / 0.008 | 0.000 / 0.000 / 0.000 |
| city25-airborne | 10.871 / 14.362 | 2.292 / 0.000 / 0.010 / 0.008 | 0.000 / 0.000 / 0.000 |
| city25-initial-impact | 40.812 / 52.200 | 10.715 / 0.461 / 0.020 / 0.018 | 3.126 / 0.299 / 9.628 |
| city25-post-impact | 24.484 / 30.557 | 6.271 / 0.000 / 0.010 / 0.008 | 0.000 / 0.000 / 0.000 |
| city25-cascading-fracture | 39.495 / 48.003 | 13.207 / 0.223 / 0.020 / 0.018 | 0.135 / 0.017 / 0.522 |
| city25-fragmented-loaded | 52.834 / 65.842 | 17.290 / 0.538 / 0.020 / 0.020 | 0.525 / 0.043 / 1.168 |
| city25-late-debris | 69.946 / 86.042 | 18.931 / 0.619 / 0.020 / 0.020 | 3.206 / 0.483 / 16.743 |
| city25-ten-second-debris | 70.265 / 88.090 | 30.229 / 0.591 / 0.022 / 0.020 | 1.010 / 0.121 / 8.836 |
| city64-intact-idle | 16.898 / 25.849 | 2.375 / 0.000 / 0.023 / 0.015 | 0.000 / 0.000 / 0.000 |
| city64-airborne | 18.495 / 22.528 | 2.377 / 0.000 / 0.025 / 0.015 | 0.000 / 0.000 / 0.000 |
| city64-initial-impact | 64.630 / 83.817 | 11.663 / 0.876 / 0.047 / 0.033 | 6.941 / 0.796 / 20.769 |
| city64-post-impact | 35.363 / 41.564 | 7.372 / 0.000 / 0.024 / 0.015 | 0.000 / 0.000 / 0.000 |
| city64-cascading-fracture | 56.874 / 68.731 | 14.417 / 0.429 / 0.045 / 0.033 | 0.275 / 0.019 / 0.578 |
| city64-fragmented-loaded | 90.634 / 117.658 | 23.100 / 1.090 / 0.047 / 0.037 | 1.377 / 0.189 / 3.987 |
| city64-late-debris | 132.341 / 166.994 | 26.156 / 1.272 / 0.047 / 0.038 | 11.637 / 1.054 / 43.294 |
| city64-ten-second-debris | 99.766 / 139.785 | 29.179 / 1.328 / 0.045 / 0.039 | 1.504 / 0.157 / 9.292 |
| city256-intact-idle | 59.200 / 73.979 | 8.428 / 0.000 / 0.100 / 0.047 | 0.000 / 0.000 / 0.000 |
| city256-airborne | 66.190 / 83.926 | 8.524 / 0.000 / 0.101 / 0.047 | 0.000 / 0.000 / 0.000 |
| city256-initial-impact | 236.880 / 254.511 | 42.382 / 3.048 / 0.207 / 0.103 | 25.425 / 1.958 / 49.115 |
| city256-post-impact | 139.608 / 166.765 | 25.450 / 0.000 / 0.105 / 0.049 | 0.000 / 0.000 / 0.000 |
| city256-cascading-fracture | 190.403 / 218.459 | 39.776 / 1.454 / 0.213 / 0.102 | 0.444 / 0.026 / 0.712 |
| city256-fragmented-loaded | 283.125 / 311.861 | 64.113 / 3.815 / 0.216 / 0.117 | 10.658 / 0.543 / 15.118 |
| city256-late-debris | 394.491 / 458.203 | 66.389 / 4.415 / 0.215 / 0.126 | 89.179 / 2.364 / 72.887 |
| city256-ten-second-debris | 264.837 / 350.839 | 46.834 / 4.697 / 0.218 / 0.130 | 6.788 / 0.352 / 11.274 |

## Continuous semantic checkpoints

| Case / tick | Iteration / modes / materials / input GPU aggregate ms | Allocation / validation / migration exclusive thread CPU ms |
|---|---:|---:|
| idle-256 / 0 | 8.470 / 0.000 / 0.102 / 0.047 | 0.000 / 0.000 / 0.000 |
| idle-256 / 81 | 0.007 / 0.000 / 0.107 / 0.055 | 0.000 / 0.000 / 0.000 |
| idle-256 / 82 | 0.007 / 0.000 / 0.105 / 0.055 | 0.000 / 0.000 / 0.000 |
| idle-256 / 103 | 0.006 / 0.000 / 0.104 / 0.055 | 0.000 / 0.000 / 0.000 |
| idle-256 / 179 | 0.007 / 0.000 / 0.104 / 0.056 | 0.000 / 0.000 / 0.000 |
| impacts-256 / 0 | 8.538 / 0.000 / 0.101 / 0.046 | 0.000 / 0.000 / 0.000 |
| impacts-256 / 81 | 0.007 / 0.000 / 0.106 / 0.056 | 0.000 / 0.000 / 0.000 |
| impacts-256 / 82 | 41.388 / 2.843 / 0.209 / 0.109 | 16.914 / 1.593 / 13.888 |
| impacts-256 / 103 | 61.547 / 3.720 / 0.211 / 0.128 | 14.364 / 0.761 / 7.476 |
| impacts-256 / 179 | 61.298 / 4.134 / 0.219 / 0.139 | 0.907 / 0.127 / 0.482 |

All360 continuous frames and source hashes are retained in `removal-exposure.json`. Full-step idle/heavy means, maxima, deadline misses, initialization and stage evidence remain in [the attribution report](coverage-tiers.md); retained N20 application comparisons are in [N20 qualification](n20-final.md). No runtime change or new application gain is claimed.
