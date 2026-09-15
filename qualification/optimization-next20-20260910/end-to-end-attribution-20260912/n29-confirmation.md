# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.838 / 12.107 | 8.726 / 11.968 | 8.066 / 9.090 | -0.274 | -0.722–0.076 |
| chain256-cold | 7.163 / 9.746 | 7.216 / 10.211 | 7.237 / 9.871 | -0.016 | -0.460–0.314 |
| dense12-cold | 31.334 / 33.784 | 31.231 / 34.003 | 31.320 / 33.637 | 0.096 | -0.261–0.411 |
| destruction-stimulus | 3.190 / 5.338 | 4.239 / 8.086 | 3.392 / 5.047 | -0.949 | -1.469–-0.576 |
| city25-initial-impact | 37.363 / 47.261 | 32.474 / 36.130 | 38.380 / 50.406 | 5.398 | 4.201–6.776 |
| city256-intact-idle | 66.853 / 82.092 | 54.137 / 69.456 | 59.563 / 70.245 | 9.071 | 5.459–12.573 |
| city256-initial-impact | 212.063 / 268.683 | 218.320 / 259.586 | 219.188 / 272.730 | -2.694 | -11.326–6.738 |
| city256-late-debris | 345.900 / 435.544 | 353.410 / 396.285 | 333.093 / 415.961 | -13.913 | -26.556–-1.723 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 40 / 20 | 33 (82.5%) / 20 (100.0%) | 0 (0.0%) / 0 (0.0%) | 18 (45.0%) / 19 (95.0%) | 20.224 / 21.301 |
| chain256-cold | 40 / 20 | 2 (5.0%) / 1 (5.0%) | 0 (0.0%) / 0 (0.0%) | 2 (5.0%) / 1 (5.0%) | 17.422 / 17.570 |
| dense12-cold | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 35.308 / 36.987 |
| destruction-stimulus | 40 / 20 | 0 (0.0%) / 1 (5.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 16.559 / 18.450 |
| city25-initial-impact | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 61.140 / 62.647 |
| city256-intact-idle | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 432.214 / 440.854 |
| city256-initial-impact | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 435.727 / 435.461 |
| city256-late-debris | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 500.375 / 490.981 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000116 / 0.000105 | 8.274984 / 8.567965 | 0.176564 / 0.157820 |
| chain256-cold | 0.000141 / 0.000155 | 7.022006 / 7.046698 | 0.177977 / 0.169029 |
| dense12-cold | 0.000178 / 0.000227 | 31.136683 / 31.041283 | 0.190080 / 0.189923 |
| destruction-stimulus | 0.001826 / 0.002160 | 3.082787 / 3.965015 | 0.206087 / 0.272115 |
| city25-initial-impact | 0.000105 / 0.000117 | 37.686509 / 32.304474 | 0.185125 / 0.169594 |
| city256-intact-idle | 0.000151 / 0.000170 | 62.978976 / 53.851240 | 0.228777 / 0.285107 |
| city256-initial-impact | 0.000145 / 0.000159 | 215.366505 / 218.059529 | 0.258738 / 0.259887 |
| city256-late-debris | 0.000169 / 0.000128 | 339.259579 / 353.173908 | 0.236971 / 0.236077 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 485.588 / 437.116 / 436.176 | 184–184 / 184–184 |
| chain256-cold | 432.037 / 433.616 / 431.921 | 492–492 / 492–492 |
| dense12-cold | 430.592 / 434.843 / 427.248 | 34–34 / 34–34 |
| destruction-stimulus | 456.714 / 458.606 / 439.275 | 1–1 / 1–1 |
| city25-initial-impact | 574.210 / 583.324 / 600.806 | 304–304 / 304–304 |
| city256-intact-idle | 1779.424 / 1770.589 / 1739.981 | 88–88 / 88–88 |
| city256-initial-impact | 1779.189 / 1722.350 / 1748.165 | 312–312 / 312–312 |
| city256-late-debris | 1761.186 / 1738.764 / 1736.227 | 1084–1084 / 1084–1084 |
