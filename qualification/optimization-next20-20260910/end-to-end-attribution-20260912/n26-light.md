# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.923 / 11.456 | 9.366 / 11.997 | 8.566 / 10.801 | -0.622 | -1.531–0.113 |
| chain256-cold | 7.575 / 10.025 | 7.421 / 9.797 | 7.401 / 9.772 | 0.067 | -0.766–0.768 |
| dense12-cold | 31.568 / 33.688 | 31.777 / 33.575 | 31.563 / 33.703 | -0.212 | -1.113–0.606 |
| destruction-stimulus | 4.433 / 7.634 | 4.351 / 7.790 | 4.239 / 7.586 | -0.015 | -1.190–0.985 |
| city25-initial-impact | 40.384 / 47.911 | 39.042 / 48.771 | 42.497 / 50.650 | 2.398 | -4.699–8.966 |
| city256-intact-idle | 78.536 / 86.161 | 78.185 / 83.798 | 72.004 / 79.727 | -2.915 | -10.191–3.835 |
| city256-late-debris | 379.596 / 405.687 | 356.373 / 376.736 | 378.411 / 387.183 | 22.631 | 1.389–42.043 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 15 (93.8%) / 8 (100.0%) | 0 (0.0%) / 0 (0.0%) | 11 (68.8%) / 8 (100.0%) | 34.635 / 35.167 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 1 (12.5%) | 30.282 / 31.539 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 54.071 / 55.396 |
| destruction-stimulus | 16 / 8 | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 31.593 / 31.843 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 122.716 / 120.976 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 859.045 / 862.829 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 916.720 / 974.907 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000087 / 0.000089 | 8.575585 / 9.221120 | 0.169084 / 0.145227 |
| chain256-cold | 0.000102 / 0.000110 | 7.322342 / 7.250248 | 0.165587 / 0.170984 |
| dense12-cold | 0.000146 / 0.000157 | 31.378435 / 31.564178 | 0.186991 / 0.213080 |
| destruction-stimulus | 0.001588 / 0.001563 | 4.174035 / 4.183756 | 0.160416 / 0.165751 |
| city25-initial-impact | 0.000122 / 0.000091 | 41.239173 / 38.851101 | 0.201647 / 0.191268 |
| city256-intact-idle | 0.000215 / 0.000203 | 75.024343 / 78.034255 | 0.245358 / 0.150644 |
| city256-late-debris | 0.000144 / 0.000133 | 378.773924 / 356.154312 | 0.229619 / 0.218378 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 593.274 / 524.926 / 477.349 | 184–184 / 184–184 |
| chain256-cold | 491.398 / 477.524 / 541.157 | 492–492 / 492–492 |
| dense12-cold | 530.148 / 520.549 / 560.265 | 34–34 / 34–34 |
| destruction-stimulus | 541.816 / 506.671 / 539.324 | 1–1 / 1–1 |
| city25-initial-impact | 655.028 / 660.489 / 658.403 | 304–304 / 304–304 |
| city256-intact-idle | 1838.782 / 1833.344 / 1856.342 | 88–88 / 88–88 |
| city256-late-debris | 1839.931 / 1979.288 / 1839.156 | 1084–1084 / 1084–1084 |
