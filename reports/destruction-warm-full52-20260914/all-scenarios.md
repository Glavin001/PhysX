# All52 warm scenarios

All52 physical comparisons pass. 1696 complete measured ticks; 2992 warmup ticks stored separately. Two independent processes, two restores per process. Ranges span process means; adjacent ticks are correlated. No optimization or speedup claim.

A source label ending `cold` describes the original snapshot. Every row below measures its explicit W/M continuation; it is not the original cold tick. City impact/post-impact/cascade windows warm from snapshot40 to their original event time.

| Scenario | Chunks / bonds | W / M | Mean range ms | Peak ms | 60 Hz misses | CPU / counters |
|---|---:|---:|---:|---:|---:|---|
| bridge64-cold | 768 / 1,524 | 8 / 8 | 1.462–1.691 | 2.251 | 0/32 | complete / complete |
| bridge64-warm | 768 / 1,524 | 8 / 8 | 1.353–1.385 | 1.733 | 0/32 | complete / complete |
| building-cold | 444 / 896 | 8 / 8 | 1.161–1.360 | 1.435 | 0/32 | complete / complete |
| building-fragmented | 444 / 896 | 8 / 8 | 3.670–3.858 | 4.550 | 0/32 | complete / complete |
| building-warm | 444 / 896 | 8 / 8 | 1.372–1.381 | 1.495 | 0/32 | complete / complete |
| cantilever64-cold | 64 / 63 | 8 / 8 | 1.401–1.438 | 1.822 | 0/32 | complete / complete |
| cantilever64-warm | 64 / 63 | 8 / 8 | 1.427–1.455 | 1.714 | 0/32 | complete / complete |
| chain256-cold | 256 / 255 | 8 / 8 | 1.392–1.579 | 1.799 | 0/32 | complete / complete |
| chain256-warm | 256 / 255 | 8 / 8 | 1.372–1.421 | 1.551 | 0/32 | complete / complete |
| chain32-cold | 32 / 31 | 8 / 8 | 1.385–1.419 | 1.550 | 0/32 | complete / complete |
| chain32-warm | 32 / 31 | 8 / 8 | 1.379–1.592 | 1.892 | 0/32 | complete / complete |
| dense12-cold | 1,728 / 4,752 | 8 / 8 | 1.272–1.515 | 2.351 | 0/32 | complete / complete |
| dense12-warm | 1,728 / 4,752 | 8 / 8 | 1.428–1.441 | 1.888 | 0/32 | complete / complete |
| destruction-cold | 2 / 1 | 8 / 8 | 1.007–1.277 | 1.537 | 0/32 | complete / complete |
| destruction-damaged | 2 / 1 | 8 / 8 | 1.312–1.375 | 1.534 | 0/32 | complete / complete |
| destruction-fractured | 2 / 1 | 8 / 8 | 2.469–2.609 | 3.781 | 0/32 | complete / complete |
| destruction-intact | 2 / 1 | 8 / 8 | 1.397–1.553 | 1.871 | 0/32 | complete / complete |
| destruction-onset | 2 / 1 | 8 / 8 | 2.670–2.697 | 3.288 | 0/32 | complete / complete |
| destruction-stimulus | 2 / 1 | 8 / 8 | 2.614–2.631 | 3.036 | 0/32 | complete / complete |
| flying | 0 / 0 | 8 / 8 | 1.180–1.278 | 1.388 | 0/32 | complete / complete |
| ladder128-cold | 288 / 318 | 8 / 8 | 1.156–1.386 | 1.609 | 0/32 | complete / complete |
| ladder128-warm | 288 / 318 | 8 / 8 | 1.390–1.397 | 1.641 | 0/32 | complete / complete |
| panel32-cold | 1,024 / 1,984 | 8 / 8 | 1.131–1.638 | 1.856 | 0/32 | complete / complete |
| panel32-warm | 1,024 / 1,984 | 8 / 8 | 1.075–1.401 | 1.481 | 0/32 | complete / complete |
| resting | 0 / 0 | 8 / 8 | 0.571–0.662 | 0.894 | 0/32 | complete / complete |
| sliding | 0 / 0 | 8 / 8 | 1.501–1.554 | 1.878 | 0/32 | complete / complete |
| tower64-cold | 2,368 / 4,900 | 8 / 8 | 1.145–1.447 | 1.861 | 0/32 | complete / complete |
| tower64-warm | 2,368 / 4,900 | 8 / 8 | 1.255–1.374 | 1.532 | 0/32 | complete / complete |
| city25-intact-idle | 11,100 / 22,400 | 8 / 8 | 1.279–1.531 | 1.838 | 0/32 | complete / complete |
| city25-airborne | 11,100 / 22,400 | 8 / 8 | 1.998–2.290 | 2.458 | 0/32 | complete / complete |
| city25-initial-impact | 11,100 / 22,400 | 42 / 8 | 22.607–22.761 | 36.917 | 20/32 | complete / complete |
| city25-post-impact | 11,100 / 22,400 | 43 / 8 | 19.669–20.097 | 30.319 | 16/32 | complete / complete |
| city25-cascading-fracture | 11,100 / 22,400 | 47 / 8 | 23.394–23.472 | 29.766 | 24/32 | complete / complete |
| city25-fragmented-loaded | 11,100 / 22,400 | 8 / 8 | 15.726–15.854 | 28.044 | 4/32 | complete / complete |
| city25-late-debris | 11,100 / 22,400 | 8 / 8 | 29.766–30.211 | 38.445 | 31/32 | complete / complete |
| city25-ten-second-debris | 11,100 / 22,400 | 8 / 8 | 20.443–20.615 | 33.471 | 19/32 | complete / complete |
| city64-intact-idle | 28,416 / 57,344 | 8 / 8 | 1.258–1.407 | 1.546 | 0/32 | complete / complete |
| city64-airborne | 28,416 / 57,344 | 8 / 8 | 2.374–2.498 | 2.757 | 0/32 | complete / complete |
| city64-initial-impact | 28,416 / 57,344 | 42 / 8 | 28.301–28.641 | 57.795 | 22/32 | complete / complete |
| city64-post-impact | 28,416 / 57,344 | 43 / 8 | 23.205–23.710 | 35.360 | 18/32 | complete / complete |
| city64-cascading-fracture | 28,416 / 57,344 | 47 / 8 | 20.040–20.651 | 31.003 | 12/32 | complete / complete |
| city64-fragmented-loaded | 28,416 / 57,344 | 8 / 8 | 22.681–22.946 | 41.240 | 32/32 | complete / complete |
| city64-late-debris | 28,416 / 57,344 | 8 / 8 | 49.351–49.380 | 51.906 | 32/32 | complete / complete |
| city64-ten-second-debris | 28,416 / 57,344 | 8 / 8 | 22.652–22.982 | 37.756 | 31/32 | complete / complete |
| city256-intact-idle | 113,664 / 229,376 | 16 / 16 | 1.659–1.692 | 3.927 | 0/64 | complete / complete |
| city256-airborne | 113,664 / 229,376 | 8 / 8 | 3.784–4.063 | 4.544 | 0/32 | complete / complete |
| city256-initial-impact | 113,664 / 229,376 | 42 / 8 | 88.772–90.104 | 187.800 | 32/32 | complete / complete |
| city256-post-impact | 113,664 / 229,376 | 43 / 8 | 72.831–73.196 | 117.094 | 32/32 | complete / complete |
| city256-cascading-fracture | 113,664 / 229,376 | 47 / 8 | 77.277–77.409 | 99.809 | 32/32 | complete / complete |
| city256-fragmented-loaded | 113,664 / 229,376 | 8 / 8 | 80.534–82.198 | 103.085 | 32/32 | complete / complete |
| city256-late-debris | 113,664 / 229,376 | 8 / 8 | 124.455–124.662 | 129.219 | 32/32 | complete / complete |
| city256-ten-second-debris | 113,664 / 229,376 | 8 / 8 | 40.834–41.383 | 59.954 | 32/32 | complete / complete |

## Stage and preparation costs

Stages include all overlapping work inside the integrated simulate/fetch interval. Restore/setup/warmup are separate.

| Scenario | Command / integrated / completion mean ms | Context setup ms/process | Restore ms/trajectory | Warmup total ms/trajectory | Iteration mean / max | Contacts at peak | Clusters at peak |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64-cold | 0.0001 / 1.369 / 0.207 | 462.6 | 114.5 | 22.7 | 0.0 / 0 | 0 | 1 |
| bridge64-warm | 0.0001 / 1.162 / 0.207 | 453.8 | 115.3 | 20.4 | 0.0 / 0 | 0 | 1 |
| building-cold | 0.0000 / 1.103 / 0.157 | 435.8 | 112.0 | 15.7 | 0.0 / 0 | 0 | 1 |
| building-fragmented | 0.0001 / 3.565 / 0.199 | 447.0 | 116.3 | 41.8 | 4.0 / 4 | 3513 | 378 |
| building-warm | 0.0000 / 1.222 / 0.155 | 437.8 | 112.8 | 15.9 | 0.0 / 0 | 0 | 1 |
| cantilever64-cold | 0.0001 / 1.255 / 0.165 | 441.8 | 107.3 | 19.2 | 8.0 / 8 | 0 | 1 |
| cantilever64-warm | 0.0001 / 1.254 / 0.187 | 439.3 | 109.1 | 19.5 | 8.0 / 8 | 0 | 1 |
| chain256-cold | 0.0001 / 1.319 / 0.167 | 434.5 | 107.9 | 19.7 | 1.0 / 4 | 0 | 1 |
| chain256-warm | 0.0001 / 1.200 / 0.196 | 429.7 | 108.0 | 18.8 | 1.0 / 4 | 0 | 1 |
| chain32-cold | 0.0001 / 1.235 / 0.167 | 439.0 | 108.0 | 15.4 | 0.0 / 0 | 0 | 1 |
| chain32-warm | 0.0001 / 1.311 / 0.175 | 437.7 | 110.8 | 16.2 | 0.0 / 0 | 0 | 1 |
| dense12-cold | 0.0001 / 1.202 / 0.192 | 446.8 | 117.4 | 42.2 | 0.0 / 0 | 0 | 1 |
| dense12-warm | 0.0001 / 1.223 / 0.212 | 442.1 | 121.7 | 42.9 | 0.0 / 0 | 0 | 1 |
| destruction-cold | 0.0000 / 1.009 / 0.133 | 435.6 | 110.5 | 13.3 | 0.0 / 0 | 0 | 1 |
| destruction-damaged | 0.0001 / 1.173 / 0.171 | 444.3 | 106.3 | 15.0 | 0.0 / 0 | 0 | 1 |
| destruction-fractured | 0.0001 / 2.335 / 0.204 | 440.3 | 105.9 | 23.9 | 0.0 / 0 | 0 | 2 |
| destruction-intact | 0.0001 / 1.301 / 0.174 | 458.4 | 111.8 | 16.1 | 0.0 / 0 | 0 | 1 |
| destruction-onset | 0.0001 / 2.494 / 0.190 | 446.6 | 104.4 | 30.3 | 0.0 / 0 | 1 | 2 |
| destruction-stimulus | 0.0006 / 2.428 / 0.194 | 428.3 | 107.3 | 30.7 | 0.0 / 0 | 1 | 2 |
| flying | 0.0001 / 1.229 / 0.000 | 437.4 | 63.9 | 10.9 | 0.0 / 0 | 0 | 0 |
| ladder128-cold | 0.0001 / 1.153 / 0.117 | 427.2 | 112.1 | 17.1 | 0.0 / 0 | 0 | 1 |
| ladder128-warm | 0.0001 / 1.235 / 0.158 | 432.1 | 108.2 | 17.0 | 0.0 / 0 | 0 | 1 |
| panel32-cold | 0.0001 / 1.194 / 0.190 | 436.1 | 114.1 | 32.6 | 0.0 / 0 | 0 | 1 |
| panel32-warm | 0.0001 / 1.056 / 0.182 | 436.7 | 118.0 | 31.4 | 0.0 / 0 | 0 | 1 |
| resting | 0.0000 / 0.617 / 0.000 | 433.9 | 62.9 | 7.5 | 0.0 / 0 | 0 | 0 |
| sliding | 0.0000 / 1.527 / 0.000 | 435.6 | 64.6 | 14.7 | 0.0 / 0 | 0 | 0 |
| tower64-cold | 0.0001 / 1.097 / 0.199 | 439.0 | 127.6 | 119.4 | 0.0 / 0 | 0 | 1 |
| tower64-warm | 0.0001 / 1.119 / 0.196 | 426.3 | 119.2 | 118.9 | 0.0 / 0 | 0 | 1 |
| city25-intact-idle | 0.0000 / 1.245 / 0.160 | 579.7 | 205.3 | 23.1 | 0.0 / 0 | 0 | 25 |
| city25-airborne | 0.0001 / 1.966 / 0.178 | 573.4 | 203.3 | 28.4 | 0.0 / 0 | 0 | 25 |
| city25-initial-impact | 0.0001 / 22.468 / 0.215 | 585.6 | 208.8 | 109.8 | 361.0 / 416 | 3582 | 526 |
| city25-post-impact | 0.0001 / 19.669 / 0.214 | 572.8 | 212.4 | 141.3 | 374.5 / 416 | 10906 | 600 |
| city25-cascading-fracture | 0.0001 / 23.229 / 0.204 | 594.0 | 220.3 | 228.7 | 419.5 / 524 | 10190 | 701 |
| city25-fragmented-loaded | 0.0001 / 15.569 / 0.221 | 579.9 | 219.0 | 220.9 | 491.5 / 540 | 25567 | 1344 |
| city25-late-debris | 0.0001 / 29.783 / 0.205 | 588.7 | 214.2 | 333.4 | 532.5 / 552 | 37472 | 2268 |
| city25-ten-second-debris | 0.0001 / 20.325 / 0.204 | 600.8 | 213.1 | 292.9 | 658.5 / 672 | 7556 | 1829 |
| city64-intact-idle | 0.0001 / 1.150 / 0.183 | 1274.6 | 607.5 | 28.4 | 0.0 / 0 | 0 | 64 |
| city64-airborne | 0.0001 / 2.258 / 0.178 | 1261.0 | 585.8 | 38.8 | 0.0 / 0 | 0 | 64 |
| city64-initial-impact | 0.0001 / 28.243 / 0.227 | 1268.3 | 585.7 | 126.9 | 365.5 / 420 | 10959 | 1320 |
| city64-post-impact | 0.0001 / 23.251 / 0.206 | 1228.6 | 589.7 | 178.1 | 379.5 / 420 | 27857 | 1460 |
| city64-cascading-fracture | 0.0001 / 20.147 / 0.199 | 1266.7 | 590.2 | 267.9 | 396.0 / 420 | 23254 | 1523 |
| city64-fragmented-loaded | 0.0001 / 22.606 / 0.208 | 1314.5 | 597.2 | 335.2 | 611.5 / 632 | 66719 | 3187 |
| city64-late-debris | 0.0001 / 49.132 / 0.233 | 1312.0 | 612.3 | 569.1 | 697.0 / 732 | 87150 | 5620 |
| city64-ten-second-debris | 0.0001 / 22.601 / 0.216 | 1276.3 | 629.6 | 337.7 | 430.0 / 448 | 15412 | 4751 |
| city256-intact-idle | 0.0001 / 1.486 / 0.190 | 1730.7 | 1092.6 | 99.1 | 0.0 / 0 | 0 | 256 |
| city256-airborne | 0.0001 / 3.732 / 0.191 | 1795.5 | 1131.4 | 106.3 | 0.0 / 0 | 0 | 256 |
| city256-initial-impact | 0.0001 / 89.200 / 0.238 | 1713.0 | 1095.9 | 248.7 | 368.0 / 436 | 39499 | 5204 |
| city256-post-impact | 0.0001 / 72.774 / 0.238 | 1722.0 | 1119.5 | 401.8 | 382.5 / 436 | 114081 | 5827 |
| city256-cascading-fracture | 0.0001 / 77.123 / 0.219 | 1712.5 | 1088.9 | 717.9 | 439.0 / 592 | 99910 | 6062 |
| city256-fragmented-loaded | 0.0001 / 81.144 / 0.222 | 1801.0 | 1212.4 | 1034.5 | 601.5 / 636 | 233555 | 11690 |
| city256-late-debris | 0.0001 / 124.309 / 0.249 | 1777.6 | 1179.0 | 1352.6 | 838.5 / 924 | 302533 | 17445 |
| city256-ten-second-debris | 0.0001 / 40.866 / 0.242 | 1759.1 | 1172.7 | 725.7 | 665.0 / 728 | 39324 | 15368 |

[Structured timing/work/coverage index](data/scenarios.json) includes input histories and raw paths. The iteration counter is not total operator/node work. No deadline misses or first-use costs have been discarded; warmup first-use samples are separately recorded.
