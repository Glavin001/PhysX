# N14 response-history closure

Do not promote N14 response-history caching: no convincing application-level advantage over selected N13 policy. In this reverse-policy comparison A has history and B removes it. Heavy B51.904ms is between A51.743/52.295; idle B1.549ms versusA1.553/1.483. Heavy peaks B194.167/197.227ms lie within controls180.781–204.631ms. All heavy runs miss60Hz on519/600 ticks. First-fracture group means B195.697 versusA187.721/192.706ms are an adverse removal signal, but variable controls and other stage tradeoffs do not establish a robust overall/peak history benefit. Keep every sample; no speedup claimed.

N13 remains the selected numerical policy. Isolated current-compatible history-off artifacts preserve all later snapshot/correction fixes. Final N20/selected-policy composition still requires full52 matched physical/timing, asynchronous memory and ordinary/sleeping wall qualification; main current WIP source is untouched.

Proceed to the remaining four distinct hypotheses. During final composition, recheck the first-fracture and late-debris removal signals against repeated controls; neither complexity preference nor this rejection waives a material regression.

# N14 continuous full-step screen

No verified warm application improvement. Heavy mean between controls; peak and semantic-frame spread retained. Full52/policy qualification remains open.

Unprofiled complete ticks including CPU, GPU, transfers, waits, correction and publication. Equal600 ticks per run, two runs per stage per scenario; no restore cost. Both continuous trajectories and cold light scenarios are preserved. This report does not automatically qualify retention.

Commit `8e4d46f6919efde1b668e80fa6040cb57d74724a`. reported separately; unchanged physical/work/convergence gates. Physical/work differences: 0. Iteration differences: 684.

| Scenario / stage / trial | Mean / peak ms (peak tick) | >8ms /120Hz /60Hz misses of600 | Initialization ms | Command / integrated physics / completion mean ms |
|---|---:|---:|---:|---:|
| idle-256-A-before-0 | 1.591 / 14.085 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2336.527 | 0.000 / 1.374 / 0.218 |
| idle-256-A-before-1 | 1.515 / 14.084 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2246.577 | 0.000 / 1.303 / 0.212 |
| idle-256-B-0 | 1.438 / 12.157 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2187.180 | 0.000 / 1.279 / 0.159 |
| idle-256-B-1 | 1.661 / 13.251 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2251.744 | 0.000 / 1.428 / 0.233 |
| idle-256-A-after-0 | 1.452 / 14.802 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2295.555 | 0.000 / 1.287 / 0.165 |
| idle-256-A-after-1 | 1.515 / 13.536 (0) | 1 (0.17%) / 1 (0.17%) / 0 (0.00%) | 2249.039 | 0.000 / 1.299 / 0.215 |
| impacts-256-A-before-0 | 51.616 / 187.880 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2215.787 | 0.052 / 51.340 / 0.224 |
| impacts-256-A-before-1 | 51.871 / 187.561 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2224.267 | 0.056 / 51.595 / 0.220 |
| impacts-256-B-0 | 51.970 / 194.167 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2199.198 | 0.051 / 51.679 / 0.239 |
| impacts-256-B-1 | 51.839 / 197.227 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2253.633 | 0.050 / 51.560 / 0.228 |
| impacts-256-A-after-0 | 52.123 / 180.781 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2281.149 | 0.052 / 51.846 / 0.225 |
| impacts-256-A-after-1 | 52.468 / 204.631 (82) | 519 (86.50%) / 519 (86.50%) / 519 (86.50%) | 2190.439 | 0.054 / 52.192 / 0.221 |

Integrated physics contains destruction/stress/correction. Stages are host wall intervals, not isolated stock-PhysX or pure GPU time. Full initialization-plus-step costs and physical/work observations are retained in JSON.

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.236 / 10.667 | 8.917 / 11.297 | 8.836 / 11.458 | -0.381 | -1.242–0.368 |
| chain256-cold | 7.536 / 10.020 | 7.391 / 9.900 | 7.691 / 9.816 | 0.222 | -0.629–0.928 |
| dense12-cold | 31.661 / 33.809 | 31.395 / 33.445 | 31.722 / 33.799 | 0.296 | -0.684–1.129 |
| destruction-stimulus | 3.316 / 7.876 | 4.205 / 7.532 | 4.362 / 7.864 | -0.366 | -1.575–0.747 |
| city25-initial-impact | 41.477 / 47.570 | 40.090 / 49.003 | 42.619 / 47.109 | 1.958 | -4.265–7.731 |
| city256-intact-idle | 76.471 / 85.463 | 74.991 / 76.141 | 78.724 / 86.649 | 2.606 | -2.442–7.818 |
| city256-late-debris | 417.146 / 463.561 | 428.385 / 470.424 | 416.644 / 446.347 | -11.490 | -53.800–26.225 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 12 (75.0%) / 8 (100.0%) | 0 (0.0%) / 0 (0.0%) | 7 (43.8%) / 8 (100.0%) | 35.771 / 36.725 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 1 (12.5%) | 32.666 / 32.417 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 55.847 / 54.487 |
| destruction-stimulus | 16 / 8 | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 30.258 / 28.414 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 124.930 / 124.875 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 842.927 / 838.280 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 953.627 / 956.190 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000098 / 0.000134 | 8.361111 / 8.711918 | 0.174963 / 0.204908 |
| chain256-cold | 0.000134 / 0.000118 | 7.394770 / 7.208541 | 0.218375 / 0.182395 |
| dense12-cold | 0.000159 / 0.000127 | 31.521630 / 31.201516 | 0.169850 / 0.193588 |
| destruction-stimulus | 0.001686 / 0.001739 | 3.669887 / 4.041372 | 0.167342 / 0.161729 |
| city25-initial-impact | 0.000104 / 0.000099 | 41.836726 / 39.894016 | 0.211037 / 0.196121 |
| city256-intact-idle | 0.000199 / 0.000240 | 77.352533 / 74.742996 | 0.244628 / 0.247751 |
| city256-late-debris | 0.000185 / 0.000124 | 416.646641 / 428.129485 | 0.248236 / 0.255197 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 587.639 / 479.047 / 527.545 | 184–184 / 184–184 |
| chain256-cold | 480.289 / 541.206 / 535.312 | 492–492 / 492–492 |
| dense12-cold | 488.967 / 478.551 / 528.808 | 34–34 / 34–34 |
| destruction-stimulus | 529.412 / 548.805 / 484.724 | 1–1 / 1–1 |
| city25-initial-impact | 699.785 / 644.536 / 623.545 | 304–304 / 304–304 |
| city256-intact-idle | 1785.994 / 1793.942 / 1880.449 | 88–88 / 88–88 |
| city256-late-debris | 1853.687 / 1793.785 / 1832.942 | 1084–1084 / 1084–1084 |
