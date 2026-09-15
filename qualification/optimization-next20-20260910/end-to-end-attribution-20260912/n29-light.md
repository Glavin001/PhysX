# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.927 / 11.217 | 8.607 / 11.410 | 8.956 / 11.423 | 0.335 | -0.627–1.122 |
| chain256-cold | 7.500 / 9.646 | 7.674 / 10.274 | 7.555 / 9.884 | -0.147 | -0.998–0.574 |
| dense12-cold | 31.734 / 34.303 | 31.536 / 34.219 | 31.512 / 33.720 | 0.088 | -1.180–1.162 |
| destruction-stimulus | 4.326 / 7.750 | 4.367 / 8.005 | 4.570 / 7.795 | 0.080 | -1.136–1.100 |
| city25-initial-impact | 41.336 / 47.149 | 41.416 / 49.458 | 40.308 / 49.154 | -0.594 | -6.323–4.483 |
| city256-intact-idle | 69.089 / 86.422 | 58.179 / 67.323 | 67.488 / 75.465 | 10.110 | -1.326–21.265 |
| city256-late-debris | 382.805 / 425.969 | 370.126 / 423.403 | 365.574 / 404.732 | 4.063 | -47.487–50.490 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 16 (100.0%) / 6 (75.0%) | 0 (0.0%) / 0 (0.0%) | 16 (100.0%) / 4 (50.0%) | 32.788 / 34.614 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 1 (12.5%) | 31.384 / 36.638 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 58.279 / 54.585 |
| destruction-stimulus | 16 / 8 | 0 (0.0%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 29.484 / 31.776 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 125.868 / 130.039 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 863.403 / 874.622 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 916.391 / 929.089 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000106 / 0.000085 | 8.774181 / 8.425741 | 0.167087 / 0.180798 |
| chain256-cold | 0.000102 / 0.000177 | 7.355412 / 7.465787 | 0.171964 / 0.208265 |
| dense12-cold | 0.000182 / 0.000137 | 31.406236 / 31.342256 | 0.216691 / 0.193178 |
| destruction-stimulus | 0.001934 / 0.001832 | 4.268685 / 4.206429 | 0.177204 / 0.159086 |
| city25-initial-impact | 0.000107 / 0.000112 | 40.640007 / 41.241031 | 0.181847 / 0.175174 |
| city256-intact-idle | 0.000253 / 0.000138 | 68.051811 / 57.988034 | 0.236805 / 0.190460 |
| city256-late-debris | 0.000139 / 0.000122 | 373.964319 / 369.857718 | 0.224915 / 0.268617 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 444.695 / 421.497 / 439.663 | 184–184 / 184–184 |
| chain256-cold | 430.297 / 455.494 / 440.384 | 492–492 / 492–492 |
| dense12-cold | 446.167 / 446.252 / 424.526 | 34–34 / 34–34 |
| destruction-stimulus | 404.832 / 432.334 / 434.222 | 1–1 / 1–1 |
| city25-initial-impact | 573.214 / 589.462 / 599.085 | 304–304 / 304–304 |
| city256-intact-idle | 1750.825 / 1772.106 / 1802.722 | 88–88 / 88–88 |
| city256-late-debris | 1813.047 / 1768.834 / 1711.731 | 1084–1084 / 1084–1084 |
