# Warm screen: every measured scenario

Receipt: `out/ownership-scheduling-20260915/observation-full52-v2/campaign.json`. Campaign status: complete; capture/check time 293.719s. All durations below are milliseconds. Each arm/slot is a separate process; its schedule is recorded in the plan. Two restores per process, fixed real warmup; first measured tick retained. Restore and warmup are excluded from complete-step timing. Samples within a trajectory are correlated; these are descriptive results, not independent statistical trials.

## Complete-step and stages

`simulate/fetch` includes PhysX, stress/material, transfers, waits and optional corrected physics. Completion includes the remaining publication/observation work. Fine-grained native scopes are only available in the separately instrumented selected profile.

| Scenario/arm | N | Mean | Peak | >16.667ms | Command | Simulate/fetch | Completion |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64-cold-B | 16 | 1.408 | 1.508 | 0/16 | 0.000063 | 1.227 | 0.181 |
| bridge64-warm-B | 16 | 1.434 | 1.635 | 0/16 | 0.000056 | 1.251 | 0.183 |
| building-cold-B | 16 | 1.431 | 1.723 | 0/16 | 0.000047 | 1.256 | 0.176 |
| building-fragmented-B | 16 | 3.913 | 4.061 | 0/16 | 0.000074 | 3.688 | 0.225 |
| building-warm-B | 16 | 1.377 | 1.512 | 0/16 | 0.000055 | 1.212 | 0.165 |
| cantilever64-cold-B | 16 | 1.306 | 1.636 | 0/16 | 0.000104 | 1.139 | 0.167 |
| cantilever64-warm-B | 16 | 1.421 | 1.516 | 0/16 | 0.000069 | 1.219 | 0.202 |
| chain256-cold-B | 16 | 1.060 | 1.273 | 0/16 | 0.000048 | 0.902 | 0.157 |
| chain256-warm-B | 16 | 1.422 | 1.563 | 0/16 | 0.000043 | 1.272 | 0.150 |
| chain32-cold-B | 16 | 1.461 | 1.617 | 0/16 | 0.000067 | 1.295 | 0.166 |
| chain32-warm-B | 16 | 1.388 | 1.572 | 0/16 | 0.000095 | 1.176 | 0.213 |
| dense12-cold-B | 16 | 1.650 | 1.905 | 0/16 | 0.000077 | 1.444 | 0.206 |
| dense12-warm-B | 16 | 1.447 | 1.807 | 0/16 | 0.000073 | 1.248 | 0.199 |
| destruction-cold-B | 16 | 1.440 | 1.572 | 0/16 | 0.000093 | 1.248 | 0.192 |
| destruction-damaged-B | 16 | 1.406 | 1.489 | 0/16 | 0.000091 | 1.214 | 0.191 |
| destruction-fractured-B | 16 | 2.229 | 2.747 | 0/16 | 0.000070 | 2.041 | 0.187 |
| destruction-intact-B | 16 | 1.377 | 1.528 | 0/16 | 0.000060 | 1.218 | 0.159 |
| destruction-onset-B | 16 | 2.621 | 3.104 | 0/16 | 0.000068 | 2.431 | 0.190 |
| destruction-stimulus-B | 16 | 2.470 | 3.040 | 0/16 | 0.000574 | 2.283 | 0.187 |
| flying-B | 16 | 1.373 | 1.864 | 0/16 | 0.000064 | 1.372 | 0.000 |
| ladder128-cold-B | 16 | 1.392 | 1.611 | 0/16 | 0.000042 | 1.243 | 0.150 |
| ladder128-warm-B | 16 | 1.359 | 1.473 | 0/16 | 0.000052 | 1.208 | 0.151 |
| panel32-cold-B | 16 | 1.337 | 1.495 | 0/16 | 0.000052 | 1.229 | 0.108 |
| panel32-warm-B | 16 | 1.425 | 1.505 | 0/16 | 0.000055 | 1.249 | 0.176 |
| resting-B | 16 | 0.581 | 0.690 | 0/16 | 0.000065 | 0.581 | 0.000 |
| sliding-B | 16 | 1.496 | 1.597 | 0/16 | 0.000045 | 1.496 | 0.000 |
| tower64-cold-B | 16 | 1.439 | 1.659 | 0/16 | 0.000080 | 1.209 | 0.230 |
| tower64-warm-B | 16 | 1.464 | 1.731 | 0/16 | 0.000074 | 1.261 | 0.202 |
| city25-intact-idle-B | 16 | 1.371 | 1.612 | 0/16 | 0.000050 | 1.187 | 0.185 |
| city25-airborne-B | 16 | 2.135 | 2.480 | 0/16 | 0.000054 | 1.933 | 0.203 |
| city25-initial-impact-B | 16 | 22.247 | 35.518 | 10/16 | 0.000096 | 22.019 | 0.227 |
| city25-post-impact-B | 16 | 19.344 | 28.356 | 8/16 | 0.000081 | 19.135 | 0.209 |
| city25-cascading-fracture-B | 16 | 22.796 | 29.179 | 12/16 | 0.000092 | 22.579 | 0.217 |
| city25-fragmented-loaded-B | 16 | 15.858 | 28.411 | 2/16 | 0.000089 | 15.691 | 0.166 |
| city25-late-debris-B | 16 | 29.838 | 36.566 | 15/16 | 0.000087 | 29.623 | 0.215 |
| city25-ten-second-debris-B | 16 | 20.499 | 33.881 | 9/16 | 0.000097 | 20.313 | 0.186 |
| city64-intact-idle-B | 16 | 1.240 | 1.563 | 0/16 | 0.000046 | 1.081 | 0.159 |
| city64-airborne-B | 16 | 2.496 | 2.612 | 0/16 | 0.000057 | 2.349 | 0.147 |
| city64-initial-impact-B | 16 | 26.539 | 46.390 | 10/16 | 0.000115 | 26.359 | 0.180 |
| city64-post-impact-B | 16 | 23.746 | 34.882 | 9/16 | 0.000105 | 23.504 | 0.242 |
| city64-cascading-fracture-B | 16 | 20.251 | 30.510 | 6/16 | 0.000077 | 20.036 | 0.214 |
| city64-fragmented-loaded-B | 16 | 22.372 | 38.593 | 16/16 | 0.000124 | 22.178 | 0.194 |
| city64-late-debris-B | 16 | 48.537 | 50.797 | 16/16 | 0.000109 | 48.294 | 0.243 |
| city64-ten-second-debris-B | 16 | 22.751 | 38.125 | 16/16 | 0.000104 | 22.526 | 0.225 |
| city256-intact-idle-B | 32 | 1.482 | 1.962 | 0/32 | 0.000084 | 1.287 | 0.194 |
| city256-airborne-B | 16 | 4.022 | 4.113 | 0/16 | 0.000093 | 3.810 | 0.212 |
| city256-initial-impact-B | 16 | 87.934 | 180.840 | 16/16 | 0.000076 | 87.704 | 0.230 |
| city256-post-impact-B | 16 | 72.832 | 116.723 | 16/16 | 0.000182 | 72.637 | 0.195 |
| city256-cascading-fracture-B | 16 | 76.607 | 98.512 | 16/16 | 0.000121 | 76.358 | 0.249 |
| city256-fragmented-loaded-B | 16 | 80.578 | 100.220 | 16/16 | 0.000100 | 80.335 | 0.243 |
| city256-late-debris-B | 16 | 123.010 | 125.943 | 16/16 | 0.000113 | 122.770 | 0.240 |
| city256-ten-second-debris-B | 16 | 41.089 | 56.361 | 16/16 | 0.000100 | 40.862 | 0.227 |

## Preparation excluded from tick timing

Context setup is once per process; restore is the mean per trajectory; warm tick is the mean over the fixed physical warmup. Costs remain recorded rather than silently primed away.

| Scenario/arm | Context setup | Restore | Warm tick |
|---|---:|---:|---:|
| bridge64-cold-B | 457.798 | 113.556 | 2.611 |
| bridge64-warm-B | 429.984 | 112.040 | 2.570 |
| building-cold-B | 429.805 | 107.179 | 1.988 |
| building-fragmented-B | 443.490 | 113.207 | 5.181 |
| building-warm-B | 434.721 | 112.607 | 2.078 |
| cantilever64-cold-B | 436.432 | 109.385 | 2.420 |
| cantilever64-warm-B | 458.884 | 110.757 | 2.399 |
| chain256-cold-B | 437.770 | 108.623 | 1.947 |
| chain256-warm-B | 430.818 | 107.005 | 2.463 |
| chain32-cold-B | 440.635 | 106.971 | 1.945 |
| chain32-warm-B | 434.841 | 108.703 | 1.750 |
| dense12-cold-B | 429.735 | 118.395 | 5.586 |
| dense12-warm-B | 440.123 | 122.031 | 5.385 |
| destruction-cold-B | 435.992 | 108.300 | 2.030 |
| destruction-damaged-B | 445.063 | 107.412 | 1.957 |
| destruction-fractured-B | 441.476 | 106.209 | 2.705 |
| destruction-intact-B | 413.320 | 97.879 | 1.936 |
| destruction-onset-B | 441.077 | 109.081 | 3.615 |
| destruction-stimulus-B | 450.101 | 106.352 | 3.087 |
| flying-B | 427.548 | 64.816 | 1.462 |
| ladder128-cold-B | 446.523 | 110.243 | 2.138 |
| ladder128-warm-B | 439.901 | 110.271 | 2.146 |
| panel32-cold-B | 425.972 | 105.351 | 4.061 |
| panel32-warm-B | 438.705 | 112.649 | 4.106 |
| resting-B | 429.251 | 64.225 | 0.864 |
| sliding-B | 439.222 | 66.279 | 1.823 |
| tower64-cold-B | 441.852 | 127.501 | 14.871 |
| tower64-warm-B | 433.835 | 124.832 | 14.984 |
| city25-intact-idle-B | 573.748 | 203.084 | 2.799 |
| city25-airborne-B | 585.071 | 209.261 | 3.237 |
| city25-initial-impact-B | 620.198 | 225.512 | 2.834 |
| city25-post-impact-B | 594.718 | 207.741 | 3.212 |
| city25-cascading-fracture-B | 602.524 | 218.224 | 4.725 |
| city25-fragmented-loaded-B | 598.087 | 219.768 | 27.396 |
| city25-late-debris-B | 563.614 | 209.788 | 42.512 |
| city25-ten-second-debris-B | 592.714 | 210.219 | 35.192 |
| city64-intact-idle-B | 1274.998 | 587.469 | 3.630 |
| city64-airborne-B | 1275.333 | 587.922 | 4.962 |
| city64-initial-impact-B | 1342.558 | 611.422 | 2.744 |
| city64-post-impact-B | 1303.733 | 603.011 | 4.188 |
| city64-cascading-fracture-B | 1347.387 | 592.551 | 6.126 |
| city64-fragmented-loaded-B | 1277.902 | 603.428 | 40.542 |
| city64-late-debris-B | 1267.634 | 602.995 | 71.851 |
| city64-ten-second-debris-B | 1306.528 | 614.367 | 44.140 |
| city256-intact-idle-B | 1781.739 | 1100.777 | 5.681 |
| city256-airborne-B | 1727.602 | 1105.793 | 13.446 |
| city256-initial-impact-B | 1671.976 | 1096.040 | 5.582 |
| city256-post-impact-B | 1818.800 | 1115.881 | 10.081 |
| city256-cascading-fracture-B | 1761.290 | 1089.727 | 15.208 |
| city256-fragmented-loaded-B | 1764.928 | 1147.041 | 127.434 |
| city256-late-debris-B | 1791.169 | 1175.251 | 168.717 |
| city256-ten-second-debris-B | 1761.540 | 1189.532 | 88.104 |

## Actual work, mean per measured tick

The physical checker compares complete work histories, including warmup. Counts below are window means, not reconstructed compute scores. Fractures, contacts and component sizes can vary through a window.

| Scenario/arm | Stress iterations | New broken bonds | Corrections | Stress islands | Active nodes | Active bonds | Contacts | Friction anchors |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| bridge64-cold-B | 0.000 | 0.000 | 0.000 | 1.000 | 744.000 | 1500.000 | 0.000 | 0.000 |
| bridge64-warm-B | 0.000 | 0.000 | 0.000 | 1.000 | 744.000 | 1500.000 | 0.000 | 0.000 |
| building-cold-B | 0.000 | 0.000 | 0.000 | 1.000 | 380.000 | 784.000 | 0.000 | 0.000 |
| building-fragmented-B | 4.000 | 0.000 | 0.000 | 3.000 | 6.000 | 3.000 | 3316.000 | 676.500 |
| building-warm-B | 0.000 | 0.000 | 0.000 | 1.000 | 380.000 | 784.000 | 0.000 | 0.000 |
| cantilever64-cold-B | 8.000 | 0.000 | 0.000 | 1.000 | 63.000 | 63.000 | 0.000 | 0.000 |
| cantilever64-warm-B | 8.000 | 0.000 | 0.000 | 1.000 | 63.000 | 63.000 | 0.000 | 0.000 |
| chain256-cold-B | 1.000 | 0.000 | 0.000 | 1.000 | 255.000 | 255.000 | 0.000 | 0.000 |
| chain256-warm-B | 1.000 | 0.000 | 0.000 | 1.000 | 255.000 | 255.000 | 0.000 | 0.000 |
| chain32-cold-B | 0.000 | 0.000 | 0.000 | 1.000 | 31.000 | 31.000 | 0.000 | 0.000 |
| chain32-warm-B | 0.000 | 0.000 | 0.000 | 1.000 | 31.000 | 31.000 | 0.000 | 0.000 |
| dense12-cold-B | 0.000 | 0.000 | 0.000 | 1.000 | 1584.000 | 4488.000 | 0.000 | 0.000 |
| dense12-warm-B | 0.000 | 0.000 | 0.000 | 1.000 | 1584.000 | 4488.000 | 0.000 | 0.000 |
| destruction-cold-B | 0.000 | 0.000 | 0.000 | 1.000 | 1.000 | 1.000 | 0.000 | 0.000 |
| destruction-damaged-B | 0.000 | 0.000 | 0.000 | 1.000 | 1.000 | 1.000 | 0.000 | 0.000 |
| destruction-fractured-B | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.750 | 0.000 |
| destruction-intact-B | 0.000 | 0.000 | 0.000 | 1.000 | 1.000 | 1.000 | 0.000 | 0.000 |
| destruction-onset-B | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 4.750 | 1.125 |
| destruction-stimulus-B | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 4.750 | 2.500 |
| flying-B | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| ladder128-cold-B | 0.000 | 0.000 | 0.000 | 1.000 | 285.000 | 316.000 | 0.000 | 0.000 |
| ladder128-warm-B | 0.000 | 0.000 | 0.000 | 1.000 | 285.000 | 316.000 | 0.000 | 0.000 |
| panel32-cold-B | 0.000 | 0.000 | 0.000 | 1.000 | 1020.000 | 1984.000 | 0.000 | 0.000 |
| panel32-warm-B | 0.000 | 0.000 | 0.000 | 1.000 | 1020.000 | 1984.000 | 0.000 | 0.000 |
| resting-B | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| sliding-B | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| tower64-cold-B | 0.000 | 0.000 | 0.000 | 1.000 | 2304.000 | 4788.000 | 0.000 | 0.000 |
| tower64-warm-B | 0.000 | 0.000 | 0.000 | 1.000 | 2304.000 | 4788.000 | 0.000 | 0.000 |
| city25-intact-idle-B | 0.000 | 0.000 | 0.000 | 25.000 | 9500.000 | 19600.000 | 0.000 | 0.000 |
| city25-airborne-B | 0.000 | 0.000 | 0.000 | 25.000 | 9500.000 | 19600.000 | 0.000 | 0.000 |
| city25-initial-impact-B | 361.000 | 394.375 | 0.625 | 59.125 | 8978.750 | 16579.375 | 7456.750 | 1533.125 |
| city25-post-impact-B | 374.500 | 42.875 | 0.500 | 60.750 | 8968.000 | 16536.500 | 7588.875 | 1546.000 |
| city25-cascading-fracture-B | 419.500 | 54.000 | 0.750 | 69.125 | 8913.750 | 16300.125 | 8578.625 | 1495.000 |
| city25-fragmented-loaded-B | 491.500 | 0.250 | 0.125 | 176.500 | 8334.000 | 13579.500 | 14524.250 | 2904.375 |
| city25-late-debris-B | 532.500 | 7.625 | 0.750 | 386.750 | 7600.875 | 11389.125 | 31731.000 | 6411.750 |
| city25-ten-second-debris-B | 658.500 | 2.875 | 0.250 | 288.000 | 7958.125 | 12489.750 | 4446.750 | 1162.875 |
| city64-intact-idle-B | 0.000 | 0.000 | 0.000 | 64.000 | 24320.000 | 50176.000 | 0.000 | 0.000 |
| city64-airborne-B | 0.000 | 0.000 | 0.000 | 64.000 | 24320.000 | 50176.000 | 0.000 | 0.000 |
| city64-initial-impact-B | 365.500 | 1001.125 | 0.625 | 145.375 | 23041.125 | 42485.125 | 19163.125 | 3897.500 |
| city64-post-impact-B | 379.500 | 98.250 | 0.500 | 149.750 | 23020.125 | 42386.875 | 19223.250 | 3848.500 |
| city64-cascading-fracture-B | 396.000 | 55.125 | 0.375 | 163.250 | 22968.000 | 42082.125 | 16157.125 | 2801.000 |
| city64-fragmented-loaded-B | 611.500 | 0.625 | 0.125 | 499.750 | 21633.000 | 35261.625 | 37270.500 | 7129.625 |
| city64-late-debris-B | 697.000 | 37.500 | 1.000 | 908.375 | 19615.750 | 29914.750 | 86290.875 | 17995.125 |
| city64-ten-second-debris-B | 430.000 | 0.375 | 0.250 | 821.000 | 20389.125 | 31810.125 | 8992.500 | 2288.125 |
| city256-intact-idle-B | 0.000 | 0.000 | 0.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| city256-airborne-B | 0.000 | 0.000 | 0.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| city256-initial-impact-B | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
| city256-post-impact-B | 382.500 | 371.125 | 0.500 | 622.375 | 92142.250 | 170070.875 | 78407.000 | 15628.250 |
| city256-cascading-fracture-B | 439.000 | 326.750 | 0.750 | 717.875 | 91863.875 | 168596.000 | 90109.375 | 15556.375 |
| city256-fragmented-loaded-B | 601.500 | 5.125 | 0.625 | 1936.125 | 87530.625 | 145403.000 | 190941.000 | 37785.875 |
| city256-late-debris-B | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |
| city256-ten-second-debris-B | 665.000 | 1.625 | 0.625 | 3058.125 | 84972.625 | 136913.750 | 32286.375 | 7792.000 |

Raw observations and profiler artifacts are local ignored evidence and are not included in a fresh clone.
