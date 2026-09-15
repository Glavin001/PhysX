# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.019 / 9.790 | 8.848 / 11.304 | 8.845 / 11.373 | -0.416 | -1.268–0.312 |
| chain256-cold | 7.497 / 9.901 | 6.928 / 7.900 | 7.263 / 9.378 | 0.452 | -0.061–1.028 |
| dense12-cold | 31.282 / 33.337 | 30.738 / 33.157 | 31.695 / 34.016 | 0.750 | -0.402–1.703 |
| destruction-stimulus | 3.659 / 7.845 | 4.334 / 8.000 | 3.694 / 7.059 | -0.657 | -1.932–0.483 |
| city25-initial-impact | 41.554 / 50.726 | 36.685 / 41.018 | 42.102 / 47.650 | 5.143 | 1.310–9.216 |
| city256-intact-idle | 64.271 / 65.579 | 65.062 / 78.293 | 69.422 / 75.076 | 1.785 | -10.905–11.947 |
| city256-late-debris | 380.232 / 416.587 | 368.467 / 417.265 | 383.464 / 430.427 | 13.382 | -33.601–52.949 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 11 (68.8%) / 8 (100.0%) | 0 (0.0%) / 0 (0.0%) | 8 (50.0%) / 8 (100.0%) | 33.579 / 33.702 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 0 (0.0%) | 31.110 / 31.542 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 55.335 / 52.149 |
| destruction-stimulus | 16 / 8 | 0 (0.0%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 30.029 / 30.649 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 125.554 / 123.467 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 863.225 / 861.398 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 915.484 / 935.227 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000094 / 0.000126 | 8.270047 / 8.676239 | 0.161705 / 0.171618 |
| chain256-cold | 0.000096 / 0.000121 | 7.189300 / 6.732765 | 0.190832 / 0.195518 |
| dense12-cold | 0.000142 / 0.000119 | 31.278744 / 30.510218 | 0.209759 / 0.228075 |
| destruction-stimulus | 0.004553 / 0.005985 | 3.493880 / 4.156069 | 0.178208 / 0.171971 |
| city25-initial-impact | 0.000103 / 0.000114 | 41.637158 / 36.507364 | 0.190655 / 0.177138 |
| city256-intact-idle | 0.000209 / 0.000160 | 66.610138 / 64.813411 | 0.236150 / 0.248376 |
| city256-late-debris | 0.000171 / 0.000170 | 381.601729 / 368.169331 | 0.246255 / 0.297051 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 574.128 / 465.743 / 521.029 | 184–184 / 184–184 |
| chain256-cold | 474.226 / 532.977 / 475.730 | 492–492 / 492–492 |
| dense12-cold | 537.107 / 543.069 / 541.834 | 34–34 / 34–34 |
| destruction-stimulus | 498.184 / 561.517 / 474.435 | 1–1 / 1–1 |
| city25-initial-impact | 653.944 / 662.449 / 620.985 | 304–304 / 304–304 |
| city256-intact-idle | 1771.518 / 1769.285 / 1784.058 | 88–88 / 88–88 |
| city256-late-debris | 1852.533 / 1876.754 / 1815.812 | 1084–1084 / 1084–1084 |
