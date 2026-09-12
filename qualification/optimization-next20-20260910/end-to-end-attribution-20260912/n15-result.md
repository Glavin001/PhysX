# N15 anchored/free execution split

Reject. No convincing scenario improvement; city256 late-debris mean483.504ms versus459.421/457.057ms controls,5.51% above pooled control. Three large-case samples are screening evidence, not a precise regression estimate. Anchored specialization changes109 to108 registers, stack48 to0, shared1600 to1168bytes; free path retains original resources. No occupancy or critical-path benefit established. Additional dispatch does not earn retention or a neutral architecture exemption.

Commit `dccbe23f0022b2d3b68c66bb97a877ff5e3532a4`. Existing analytic, independent3D and motion-mode oracles; 3D memcheck/initcheck/synccheck; flying,city25 impact,city256 late-debris normal asynchronous memchecks and unprofiled-reference comparisons, both arms. Seven matched light physical comparisons. Full52 not run after no useful screen signal.

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.462 / 9.991 | 9.131 / 11.481 | 9.201 / 11.051 | -0.300 | -1.089–0.337 |
| chain256-cold | 7.685 / 9.512 | 7.778 / 10.644 | 7.601 / 9.599 | -0.134 | -1.063–0.557 |
| dense12-cold | 31.658 / 33.506 | 31.803 / 33.728 | 31.593 / 34.019 | -0.178 | -1.120–0.653 |
| destruction-stimulus | 4.425 / 7.497 | 4.900 / 9.265 | 4.612 / 7.607 | -0.381 | -1.806–0.744 |
| city25-initial-impact | 40.513 / 46.222 | 43.026 / 49.386 | 42.895 / 49.082 | -1.322 | -5.756–2.782 |
| city256-intact-idle | 73.469 / 86.625 | 73.253 / 87.068 | 73.984 / 79.157 | 0.474 | -13.350–11.847 |
| city256-late-debris | 459.421 / 506.815 | 483.504 / 542.775 | 457.057 / 490.157 | -25.264 | -84.036–26.071 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 15 (93.8%) / 8 (100.0%) | 0 (0.0%) / 0 (0.0%) | 11 (68.8%) / 8 (100.0%) | 37.112 / 36.852 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 1 (12.5%) | 32.196 / 32.433 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 60.171 / 56.957 |
| destruction-stimulus | 16 / 8 | 0 (0.0%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 1 (12.5%) | 32.622 / 31.230 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 134.537 / 135.770 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 950.465 / 992.823 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 1095.232 / 1097.798 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000109 / 0.000096 | 8.666635 / 8.920199 | 0.164339 / 0.211060 |
| chain256-cold | 0.000143 / 0.000093 | 7.434325 / 7.542836 | 0.208895 / 0.234636 |
| dense12-cold | 0.000138 / 0.000147 | 31.443544 / 31.612417 | 0.181845 / 0.190921 |
| destruction-stimulus | 0.003046 / 0.002788 | 4.326407 / 4.715066 | 0.189203 / 0.181880 |
| city25-initial-impact | 0.000183 / 0.000132 | 41.426875 / 42.770138 | 0.277282 / 0.255986 |
| city256-intact-idle | 0.000200 / 0.000297 | 73.429778 / 73.016115 | 0.296626 / 0.236220 |
| city256-late-debris | 0.000207 / 0.000209 | 458.007097 / 483.292713 | 0.232014 / 0.210745 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 625.995 / 534.043 / 549.696 | 184–184 / 184–184 |
| chain256-cold | 545.494 / 481.645 / 531.469 | 492–492 / 492–492 |
| dense12-cold | 495.611 / 566.315 / 621.815 | 34–34 / 34–34 |
| destruction-stimulus | 551.853 / 580.246 / 504.817 | 1–1 / 1–1 |
| city25-initial-impact | 723.981 / 740.512 / 610.717 | 304–304 / 304–304 |
| city256-intact-idle | 1903.839 / 1891.061 / 1842.879 | 88–88 / 88–88 |
| city256-late-debris | 1931.804 / 1874.815 / 1957.916 | 1084–1084 / 1084–1084 |


Existing matched baseline attribution and compiler resource inspection. No candidate NCU capture: correctness-qualified unprofiled screen provides no promising application result. Frozen N13 and main runtime unchanged; N20 remains independently under full memory qualification. No N14 promotion.

N19 reduces GPU-to-CPU publication traffic; N16 tests component-local vector storage independently, with extra shared-storage cost explicitly charged. Reconsider anchored specialization only if a concrete later design makes its measured resource change valuable.
