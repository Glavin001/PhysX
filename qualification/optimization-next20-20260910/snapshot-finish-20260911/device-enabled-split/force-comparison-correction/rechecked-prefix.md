# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Shared-GPU unprofiled comparison; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.616 / 9.490 | 8.741 / 10.877 | 9.229 / 11.824 | 0.181 | -0.254–0.654 |
| bridge64-warm | 8.803 / 12.188 | 8.655 / 10.004 | 9.267 / 11.359 | 0.379 | -0.169–0.982 |
| building-cold | 4.765 / 7.722 | 4.621 / 7.377 | 4.625 / 5.997 | 0.074 | -0.460–0.590 |
| building-fragmented | 7.933 / 11.217 | 7.478 / 10.174 | 9.786 / 15.090 | 1.381 | 0.431–2.454 |
| building-warm | 5.657 / 9.132 | 4.694 / 7.958 | 5.245 / 8.386 | 0.758 | 0.086–1.524 |
| cantilever64-cold | 7.951 / 10.794 | 7.817 / 10.420 | 7.132 / 9.442 | -0.275 | -0.793–0.265 |
| cantilever64-warm | 7.878 / 8.846 | 7.935 / 10.121 | 7.478 / 9.955 | -0.257 | -0.686–0.183 |
| chain256-cold | 7.495 / 11.073 | 7.703 / 11.836 | 7.531 / 9.245 | -0.189 | -0.851–0.460 |
| chain256-warm | 7.571 / 10.371 | 7.602 / 10.095 | 6.456 / 8.197 | -0.589 | -1.129–-0.046 |
| chain32-cold | 3.694 / 6.692 | 2.911 / 6.649 | 3.639 / 6.830 | 0.756 | 0.095–1.433 |
| chain32-warm | 3.433 / 7.516 | 3.239 / 7.224 | 2.850 / 6.638 | -0.098 | -0.909–0.686 |
| dense12-cold | 32.810 / 34.335 | 33.203 / 35.869 | 33.328 / 36.760 | -0.133 | -0.776–0.522 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >60 Hz | A / B >120 Hz | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|
| bridge64-cold | 20 / 20 | 0 / 0 | 17 / 16 | 136.222 / 129.573 |
| bridge64-warm | 20 / 20 | 0 / 0 | 15 / 13 | 134.643 / 130.668 |
| building-cold | 20 / 20 | 0 / 0 | 0 / 0 | 134.766 / 126.635 |
| building-fragmented | 20 / 20 | 0 / 0 | 15 / 4 | 141.161 / 140.890 |
| building-warm | 20 / 20 | 0 / 0 | 2 / 0 | 133.614 / 131.095 |
| cantilever64-cold | 20 / 20 | 0 / 0 | 3 / 1 | 128.712 / 127.268 |
| cantilever64-warm | 20 / 20 | 0 / 0 | 3 / 3 | 128.202 / 128.215 |
| chain256-cold | 20 / 20 | 0 / 0 | 2 / 2 | 130.847 / 126.342 |
| chain256-warm | 20 / 20 | 0 / 0 | 1 / 2 | 130.049 / 125.668 |
| chain32-cold | 20 / 20 | 0 / 0 | 0 / 0 | 128.022 / 122.221 |
| chain32-warm | 20 / 20 | 0 / 0 | 0 / 0 | 129.934 / 123.877 |
| dense12-cold | 20 / 20 | 20 / 20 | 20 / 20 | 148.318 / 150.649 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000122 / 0.000153 | 8.713318 / 8.554261 | 0.209162 / 0.186964 |
| bridge64-warm | 0.000122 / 0.000133 | 8.850275 / 8.476195 | 0.184255 / 0.178969 |
| building-cold | 0.000123 / 0.000143 | 4.491897 / 4.437814 | 0.202872 / 0.183159 |
| building-fragmented | 0.000114 / 0.000105 | 8.655275 / 7.296869 | 0.204137 / 0.181461 |
| building-warm | 0.000116 / 0.000143 | 5.273062 / 4.508404 | 0.178180 / 0.185164 |
| cantilever64-cold | 0.000122 / 0.000169 | 7.357075 / 7.659288 | 0.184600 / 0.157688 |
| cantilever64-warm | 0.000145 / 0.000134 | 7.499476 / 7.731624 | 0.178433 / 0.203737 |
| chain256-cold | 0.000125 / 0.000119 | 7.307361 / 7.516286 | 0.205636 / 0.186171 |
| chain256-warm | 0.000117 / 0.000129 | 6.833114 / 7.406277 | 0.180099 / 0.195799 |
| chain32-cold | 0.000103 / 0.000104 | 3.500643 / 2.731450 | 0.165542 / 0.178983 |
| chain32-warm | 0.000148 / 0.000108 | 2.978046 / 3.064392 | 0.162920 / 0.174667 |
| dense12-cold | 0.000117 / 0.000117 | 32.851953 / 32.946567 | 0.217073 / 0.255897 |
