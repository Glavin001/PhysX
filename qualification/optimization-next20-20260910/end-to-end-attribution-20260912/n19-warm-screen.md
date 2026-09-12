# N19 continuous full-step screen

No warm mean/peak/deadline gain established; idle may cost more. Repeat three preselected cold scenarios with20/20/20 before rejecting or sending to full gates.

Unprofiled complete ticks including CPU, GPU, transfers, waits, correction and publication. Equal600 ticks per run, two runs per stage per scenario; no restore cost. Both continuous trajectories and cold light scenarios are preserved. This report does not automatically qualify retention.

Commit `9c6891f2b30089df3548a32451862374842e9e19`. exact history required. Physical/work differences: 0. Iteration differences: 0.

| Scenario / stage / trial | Mean / peak ms (peak tick) | >8ms /120Hz /60Hz misses of600 | Initialization ms | Command / integrated physics / completion mean ms |
|---|---:|---:|---:|---:|
| idle-256-A-before-0 | 1.631 / 14.128 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2349.334 | 0.000 / 1.411 / 0.219 |
| idle-256-A-before-1 | 1.634 / 12.206 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2248.877 | 0.000 / 1.421 / 0.213 |
| idle-256-B-0 | 1.779 / 13.698 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2258.906 | 0.000 / 1.549 / 0.230 |
| idle-256-B-1 | 1.605 / 14.242 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2222.935 | 0.000 / 1.397 / 0.208 |
| idle-256-A-after-0 | 1.439 / 13.446 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2226.146 | 0.000 / 1.269 / 0.169 |
| idle-256-A-after-1 | 1.583 / 13.559 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2228.527 | 0.000 / 1.381 / 0.202 |
| impacts-256-A-before-0 | 51.838 / 192.471 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2279.072 | 0.052 / 51.553 / 0.232 |
| impacts-256-A-before-1 | 51.467 / 183.890 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2208.547 | 0.052 / 51.194 / 0.221 |
| impacts-256-B-0 | 51.928 / 191.170 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2276.499 | 0.052 / 51.637 / 0.239 |
| impacts-256-B-1 | 51.566 / 184.200 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2243.990 | 0.053 / 51.285 / 0.228 |
| impacts-256-A-after-0 | 51.575 / 194.853 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2235.402 | 0.051 / 51.299 / 0.225 |
| impacts-256-A-after-1 | 52.032 / 186.524 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2231.875 | 0.052 / 51.757 / 0.224 |

Integrated physics contains destruction/stress/correction. Stages are host wall intervals, not isolated stock-PhysX or pure GPU time. Full initialization-plus-step costs and physical/work observations are retained in JSON.

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 9.107 / 11.865 | 7.780 / 9.140 | 9.431 / 11.736 | 1.489 | 0.753–2.174 |
| chain256-cold | 7.598 / 10.153 | 7.552 / 10.004 | 6.729 / 9.295 | -0.389 | -1.250–0.387 |
| dense12-cold | 31.541 / 33.653 | 31.696 / 33.904 | 31.716 / 33.508 | -0.067 | -1.089–0.807 |
| destruction-stimulus | 4.838 / 8.056 | 4.275 / 7.754 | 4.374 / 7.932 | 0.331 | -0.861–1.369 |
| city25-initial-impact | 44.318 / 50.109 | 42.928 / 48.831 | 37.400 / 42.298 | -2.070 | -7.464–3.065 |
| city256-intact-idle | 65.552 / 73.998 | 67.387 / 75.981 | 66.284 / 75.724 | -1.469 | -11.922–8.458 |
| city256-late-debris | 427.746 / 451.067 | 410.835 / 430.205 | 422.684 / 433.622 | 14.380 | -13.967–47.479 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 15 (93.8%) / 2 (25.0%) | 0 (0.0%) / 0 (0.0%) | 15 (93.8%) / 1 (12.5%) | 36.194 / 35.205 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 1 (12.5%) | 32.655 / 31.283 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 57.109 / 53.916 |
| destruction-stimulus | 16 / 8 | 1 (6.2%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 31.198 / 29.595 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 125.943 / 127.667 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 845.680 / 868.347 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 1030.026 / 973.070 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000088 / 0.000115 | 9.085385 / 7.646894 | 0.183531 / 0.132893 |
| chain256-cold | 0.000102 / 0.000119 | 6.980979 / 7.367310 | 0.182445 / 0.184734 |
| dense12-cold | 0.000146 / 0.000119 | 31.440570 / 31.365956 | 0.187767 / 0.329904 |
| destruction-stimulus | 0.001871 / 0.001880 | 4.436600 / 4.131363 | 0.167172 / 0.141371 |
| city25-initial-impact | 0.000110 / 0.000138 | 40.664558 / 42.755473 | 0.194226 / 0.172842 |
| city256-intact-idle | 0.000267 / 0.000141 | 65.630034 / 67.150487 | 0.287656 / 0.236504 |
| city256-late-debris | 0.000164 / 0.000269 | 424.967940 / 410.560900 | 0.246901 / 0.274300 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 545.274 / 481.470 / 541.508 | 184–184 / 184–184 |
| chain256-cold | 480.473 / 533.061 / 481.030 | 492–492 / 492–492 |
| dense12-cold | 528.004 / 529.607 / 548.871 | 34–34 / 34–34 |
| destruction-stimulus | 563.187 / 501.535 / 493.288 | 1–1 / 1–1 |
| city25-initial-impact | 640.196 / 629.029 / 653.977 | 304–304 / 304–304 |
| city256-intact-idle | 1786.298 / 1832.471 / 1744.092 | 88–88 / 88–88 |
| city256-late-debris | 1927.851 / 1838.242 / 1891.185 | 1084–1084 / 1084–1084 |
