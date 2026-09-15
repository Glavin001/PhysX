# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.688 / 11.088 | 8.715 / 11.516 | 8.369 / 11.409 | -0.187 | -0.584–0.157 |
| chain256-cold | 7.289 / 9.845 | 6.484 / 7.846 | 7.213 / 9.798 | 0.767 | 0.477–1.059 |
| dense12-cold | 31.025 / 33.839 | 31.295 / 33.854 | 31.317 / 33.348 | -0.124 | -0.475–0.188 |
| destruction-stimulus | 4.173 / 7.714 | 4.164 / 7.994 | 4.416 / 8.214 | 0.131 | -0.396–0.561 |
| city25-initial-impact | 38.695 / 49.129 | 37.291 / 49.044 | 37.769 / 47.494 | 0.940 | -1.021–2.869 |
| city256-intact-idle | 59.691 / 76.293 | 59.327 / 75.698 | 64.219 / 85.663 | 2.628 | -0.456–5.736 |
| city256-late-debris | 337.833 / 401.256 | 342.080 / 413.748 | 342.995 / 378.979 | -1.666 | -13.690–10.476 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 40 / 20 | 33 (82.5%) / 20 (100.0%) | 0 (0.0%) / 0 (0.0%) | 28 (70.0%) / 20 (100.0%) | 19.812 / 20.276 |
| chain256-cold | 40 / 20 | 2 (5.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 2 (5.0%) / 0 (0.0%) | 17.598 / 15.857 |
| dense12-cold | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 38.211 / 36.360 |
| destruction-stimulus | 40 / 20 | 1 (2.5%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 15.546 / 15.810 |
| city25-initial-impact | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 62.081 / 63.313 |
| city256-intact-idle | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 437.180 / 437.444 |
| city256-late-debris | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 498.555 / 490.994 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000100 / 0.000094 | 8.354686 / 8.544952 | 0.173550 / 0.170027 |
| chain256-cold | 0.000124 / 0.000113 | 7.038823 / 6.290909 | 0.211972 / 0.193306 |
| dense12-cold | 0.000204 / 0.000157 | 30.985736 / 31.133308 | 0.184870 / 0.161096 |
| destruction-stimulus | 0.001748 / 0.001757 | 4.113808 / 3.964832 | 0.179086 / 0.196922 |
| city25-initial-impact | 0.000127 / 0.000083 | 38.044358 / 37.045168 | 0.187243 / 0.246213 |
| city256-intact-idle | 0.000125 / 0.000136 | 61.702613 / 59.072892 | 0.252298 / 0.253542 |
| city256-late-debris | 0.000156 / 0.000143 | 340.193277 / 341.861824 | 0.220595 / 0.217718 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 578.200 / 471.482 / 519.449 | 184–184 / 184–184 |
| chain256-cold | 561.336 / 500.229 / 532.740 | 492–492 / 492–492 |
| dense12-cold | 529.382 / 461.171 / 497.425 | 34–34 / 34–34 |
| destruction-stimulus | 534.097 / 482.464 / 533.220 | 1–1 / 1–1 |
| city25-initial-impact | 693.149 / 677.173 / 619.686 | 304–304 / 304–304 |
| city256-intact-idle | 1838.826 / 1815.570 / 1835.811 | 88–88 / 88–88 |
| city256-late-debris | 1812.941 / 1830.085 / 1838.605 | 1084–1084 / 1084–1084 |
