# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| chain256-cold | 6.938 / 9.901 | 7.271 / 10.671 | 7.299 / 9.763 | -0.153 | -0.634–0.214 |
| chain32-warm | 2.600 / 5.958 | 2.689 / 7.063 | 2.606 / 9.874 | -0.086 | -0.748–0.553 |
| destruction-cold | 3.432 / 6.881 | 2.606 / 6.760 | 3.278 / 7.124 | 0.749 | 0.233–1.212 |
| destruction-onset | 2.883 / 4.687 | 4.044 / 8.215 | 4.304 / 7.946 | -0.451 | -1.038–0.050 |
| destruction-stimulus | 4.013 / 8.045 | 4.073 / 8.004 | 4.141 / 7.475 | 0.004 | -0.553–0.449 |
| ladder128-warm | 4.909 / 7.564 | 5.699 / 8.836 | 4.998 / 7.845 | -0.746 | -1.184–-0.391 |
| city64-initial-impact | 54.953 / 67.605 | 55.527 / 61.674 | 61.574 / 82.094 | 2.737 | 0.128–5.365 |
| city64-late-debris | 123.994 / 169.267 | 120.376 / 157.014 | 127.088 / 141.874 | 5.165 | -0.381–10.014 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| chain256-cold | 40 / 20 | 2 (5.0%) / 1 (5.0%) | 0 (0.0%) / 0 (0.0%) | 2 (5.0%) / 1 (5.0%) | 18.249 / 17.514 |
| chain32-warm | 40 / 20 | 1 (2.5%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 1 (2.5%) / 0 (0.0%) | 16.272 / 16.252 |
| destruction-cold | 40 / 20 | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 15.263 / 16.441 |
| destruction-onset | 40 / 20 | 0 (0.0%) / 1 (5.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 16.612 / 15.996 |
| destruction-stimulus | 40 / 20 | 1 (2.5%) / 1 (5.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 15.809 / 16.265 |
| ladder128-warm | 40 / 20 | 0 (0.0%) / 1 (5.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 1 (5.0%) | 19.640 / 19.622 |
| city64-initial-impact | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 149.789 / 149.362 |
| city64-late-debris | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 156.401 / 158.640 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| chain256-cold | 0.000133 / 0.000155 | 6.942240 / 7.055718 | 0.175941 / 0.215571 |
| chain32-warm | 0.000091 / 0.000082 | 2.430521 / 2.525952 | 0.172589 / 0.162745 |
| destruction-cold | 0.000091 / 0.000099 | 3.186088 / 2.437471 | 0.168608 / 0.168410 |
| destruction-onset | 0.000112 / 0.000097 | 3.427268 / 3.927828 | 0.165904 / 0.115864 |
| destruction-stimulus | 0.001727 / 0.001753 | 3.907455 / 3.902997 | 0.167677 / 0.168422 |
| ladder128-warm | 0.000097 / 0.000115 | 4.786146 / 5.505939 | 0.167636 / 0.193377 |
| city64-initial-impact | 0.000133 / 0.000117 | 58.080710 / 55.336797 | 0.182994 / 0.189620 |
| city64-late-debris | 0.000168 / 0.000126 | 125.334435 / 120.181342 | 0.206535 / 0.194683 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| chain256-cold | 491.224 / 431.382 / 441.807 | 492–492 / 492–492 |
| chain32-warm | 437.613 / 422.432 / 450.826 | 32–32 / 32–32 |
| destruction-cold | 479.478 / 433.842 / 406.435 | 1–1 / 1–1 |
| destruction-onset | 436.297 / 432.132 / 427.696 | 1–1 / 1–1 |
| destruction-stimulus | 437.030 / 429.202 / 432.341 | 1–1 / 1–1 |
| ladder128-warm | 427.479 / 442.661 / 431.003 | 192–192 / 192–192 |
| city64-initial-impact | 1192.307 / 1270.151 / 1261.835 | 304–304 / 304–304 |
| city64-late-debris | 1268.087 / 1246.033 / 1278.771 | 948–948 / 948–948 |
