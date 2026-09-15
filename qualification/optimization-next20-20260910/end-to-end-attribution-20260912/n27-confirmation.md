# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.674 / 12.083 | 8.555 / 11.337 | 8.646 / 11.264 | 0.105 | -0.274–0.435 |
| chain256-cold | 7.096 / 10.027 | 7.162 / 9.964 | 6.888 / 10.353 | -0.169 | -0.598–0.222 |
| dense12-cold | 31.313 / 33.423 | 31.269 / 33.513 | 31.482 / 33.395 | 0.128 | -0.197–0.416 |
| destruction-stimulus | 4.064 / 7.621 | 4.058 / 7.789 | 2.720 / 5.376 | -0.667 | -1.255–-0.197 |
| city25-initial-impact | 35.966 / 48.593 | 40.485 / 48.367 | 37.928 / 47.507 | -3.538 | -5.323–-1.819 |
| city256-intact-idle | 65.649 / 83.502 | 60.820 / 70.903 | 59.715 / 75.629 | 1.861 | -0.720–4.563 |
| city256-late-debris | 356.533 / 420.038 | 337.209 / 430.975 | 345.791 / 408.016 | 13.953 | -0.591–26.753 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 0 (0.0%) / 0 (0.0%) | 36 (90.0%) / 16 (80.0%) | 19.271 / 20.092 |
| chain256-cold | 40 / 20 | 2 (5.0%) / 1 (5.0%) | 0 (0.0%) / 0 (0.0%) | 2 (5.0%) / 1 (5.0%) | 16.410 / 16.523 |
| dense12-cold | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 35.582 / 36.461 |
| destruction-stimulus | 40 / 20 | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 14.850 / 15.197 |
| city25-initial-impact | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 65.109 / 59.826 |
| city256-intact-idle | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 433.857 / 438.879 |
| city256-late-debris | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 499.314 / 500.900 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000096 / 0.000110 | 8.472431 / 8.392253 | 0.187540 / 0.162259 |
| chain256-cold | 0.000102 / 0.000107 | 6.811105 / 6.953631 | 0.181084 / 0.208037 |
| dense12-cold | 0.000155 / 0.000190 | 31.192764 / 31.043837 | 0.204522 / 0.225206 |
| destruction-stimulus | 0.001650 / 0.001519 | 3.223489 / 3.884733 | 0.166757 / 0.172152 |
| city25-initial-impact | 0.000134 / 0.000129 | 36.702481 / 40.300328 | 0.244259 / 0.184090 |
| city256-intact-idle | 0.000169 / 0.000206 | 62.467339 / 60.541435 | 0.214231 / 0.278665 |
| city256-late-debris | 0.000161 / 0.000127 | 350.884069 / 336.974320 | 0.277929 / 0.234247 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 568.917 / 549.487 / 525.175 | 184–184 / 184–184 |
| chain256-cold | 507.260 / 522.637 / 542.467 | 492–492 / 492–492 |
| dense12-cold | 539.096 / 535.926 / 548.295 | 34–34 / 34–34 |
| destruction-stimulus | 526.672 / 522.692 / 452.495 | 1–1 / 1–1 |
| city25-initial-impact | 677.659 / 677.728 / 675.066 | 304–304 / 304–304 |
| city256-intact-idle | 1850.136 / 1810.783 / 1754.998 | 88–88 / 88–88 |
| city256-late-debris | 1926.052 / 1906.507 / 1825.611 | 1084–1084 / 1084–1084 |
