# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.344 / 11.316 | 8.718 / 11.820 | 8.837 / 11.283 | -0.128 | -1.235–0.772 |
| chain256-cold | 7.481 / 9.814 | 7.582 / 10.482 | 7.133 / 8.765 | -0.275 | -1.224–0.441 |
| dense12-cold | 31.100 / 32.327 | 31.660 / 34.244 | 32.039 / 34.417 | -0.090 | -1.267–0.888 |
| destruction-stimulus | 4.316 / 7.726 | 3.378 / 5.370 | 3.807 / 6.086 | 0.684 | -0.087–1.469 |
| city25-initial-impact | 39.446 / 42.011 | 41.001 / 50.137 | 42.846 / 49.651 | 0.145 | -6.010–5.114 |
| city256-intact-idle | 62.264 / 66.481 | 55.596 / 65.457 | 62.488 / 66.668 | 6.780 | -2.949–13.766 |
| city256-late-debris | 370.556 / 409.129 | 359.691 / 436.742 | 388.495 / 420.596 | 19.834 | -50.723–72.761 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 11 (68.8%) / 6 (75.0%) | 0 (0.0%) / 0 (0.0%) | 8 (50.0%) / 5 (62.5%) | 35.780 / 36.303 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 1 (12.5%) | 32.143 / 32.926 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 57.081 / 55.971 |
| destruction-stimulus | 16 / 8 | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 30.718 / 31.943 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 124.472 / 130.390 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 850.982 / 869.206 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 919.711 / 966.068 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000123 / 0.000088 | 8.413473 / 8.544012 | 0.176981 / 0.174241 |
| chain256-cold | 0.000105 / 0.000111 | 7.109312 / 7.389252 | 0.197654 / 0.192613 |
| dense12-cold | 0.000153 / 0.000116 | 31.359914 / 31.460323 | 0.209462 / 0.199276 |
| destruction-stimulus | 0.001900 / 0.002516 | 3.897597 / 3.189836 | 0.162105 / 0.185405 |
| city25-initial-impact | 0.000121 / 0.000122 | 40.935516 / 40.819462 | 0.210704 / 0.181660 |
| city256-intact-idle | 0.000143 / 0.000188 | 62.142791 / 55.422016 | 0.233060 / 0.173343 |
| city256-late-debris | 0.000134 / 0.000126 | 379.276400 / 359.454338 | 0.248740 / 0.236486 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 460.532 / 460.988 / 424.654 | 184–184 / 184–184 |
| chain256-cold | 441.885 / 428.357 / 420.502 | 492–492 / 492–492 |
| dense12-cold | 447.066 / 433.094 / 430.994 | 34–34 / 34–34 |
| destruction-stimulus | 443.952 / 430.602 / 432.692 | 1–1 / 1–1 |
| city25-initial-impact | 568.996 / 593.279 / 546.845 | 304–304 / 304–304 |
| city256-intact-idle | 1724.417 / 1725.789 / 1680.271 | 88–88 / 88–88 |
| city256-late-debris | 1761.439 / 1838.348 / 1800.109 | 1084–1084 / 1084–1084 |
