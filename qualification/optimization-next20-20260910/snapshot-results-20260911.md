# Snapshot correctness and diagnostic stage timings

26 GPU correctness fixtures, ten sequential continuation ticks each; not independent repeats or paired performance acceptance. Shared GPU, no profiler. Includes physics/stress/correction/fetch; serialization and verification excluded. Initialization not timed. N14-based snapshot implementation, not retained N13 performance artifact.

| Case | Chunks | Source mean / max ms | Restored mean / max ms | Max position error m |
|---|---:|---:|---:|---:|
| bridge64-cold | 768 | 2.261 / 8.424 | 2.208 / 8.547 | 0 |
| bridge64-warm | 768 | 1.558 / 2.075 | 1.760 / 4.059 | 0 |
| building-cold | 444 | 1.804 / 4.695 | 1.847 / 5.092 | 0 |
| building-warm | 444 | 1.346 / 2.111 | 1.310 / 2.785 | 0 |
| cantilever64-cold | 64 | 2.146 / 8.181 | 2.057 / 7.326 | 0 |
| cantilever64-warm | 64 | 1.569 / 2.004 | 1.645 / 3.542 | 0 |
| chain256-cold | 256 | 1.674 / 7.046 | 1.698 / 7.436 | 0 |
| chain256-warm | 256 | 1.086 / 1.353 | 1.282 / 2.048 | 0 |
| chain32-cold | 32 | 1.442 / 3.397 | 1.320 / 2.845 | 0 |
| chain32-warm | 32 | 1.245 / 1.591 | 1.316 / 2.148 | 0 |
| dense12-cold | 1728 | 4.329 / 31.839 | 4.188 / 32.022 | 0 |
| dense12-warm | 1728 | 1.305 / 1.658 | 1.415 / 3.639 | 0 |
| destruction-cold | 2 | 1.367 / 4.440 | 1.300 / 3.010 | 0 |
| destruction-damaged | 2 | 1.482 / 2.126 | 1.469 / 2.875 | 0 |
| destruction-fractured | 2 | 2.623 / 3.134 | 3.060 / 6.950 | 0 |
| destruction-intact | 2 | 1.616 / 2.292 | 1.729 / 4.162 | 0 |
| destruction-onset | 2 | 2.890 / 10.425 | 3.013 / 10.294 | 0 |
| flying | 0 | 1.507 / 1.922 | 1.657 / 2.462 | 0 |
| ladder128-cold | 288 | 1.449 / 5.659 | 1.436 / 5.027 | 0 |
| ladder128-warm | 288 | 1.378 / 1.819 | 1.581 / 3.020 | 0 |
| panel32-cold | 1024 | 3.492 / 21.353 | 3.507 / 21.902 | 0 |
| panel32-warm | 1024 | 1.515 / 2.158 | 1.662 / 3.634 | 0 |
| resting | 0 | 0.495 / 0.650 | 0.722 / 2.148 | 0 |
| sliding | 0 | 1.530 / 1.961 | 1.756 / 3.521 | 0 |
| tower64-cold | 2368 | 13.425 / 116.277 | 13.081 / 117.297 | 0 |
| tower64-warm | 2368 | 1.424 / 1.649 | 1.658 / 3.977 | 0 |

The additional projectile-fractured building fails: 444 chunks, 378 owners, 781 previously broken bonds. On the first resumed tick, maximum chunk pose error is 8.871 mm, velocity error 1.46746, and orientation dot error 4.339e-5. Both worlds report 4,537 contact points and matching checked destruction/material histories. Source/restored single tick: 5.779/10.011 ms; this is not a performance comparison. Recreating actors in source native order gives the same errors. CPU/GPU mirror audit: 2.13248 micrometres maximum pose difference, exactly equal linear/angular velocity. Cause still under investigation; do not qualify this case or broaden tolerances.

Raw: `out/snapshot-20260911/run-v3/`, `run-v4/`, `run-v5-fragmented/`, `run-v6-mirror/`, `run-v7-native-order/`.
