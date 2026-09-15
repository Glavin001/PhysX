# N16 component-local vector workspace

Reject. Bridge10.491ms versus8.720/8.985ms controls, chain8.657 versus7.662/7.491, city256 late-debris429.384 versus420.758/412.486. No convincing full-step improvement. The three-sample large-case cohort is a screen, not a precise regression estimate. Component registers rise109 to116 and shared memory1600 to17984bytes; occupancy loss and bank conflicts are hypotheses, not measured causes.

Commit `c20f12709eb2d0b012c4e7cd910e4b5cc1c43d53`. Analytic including512/516 interleaved boundary cases, independent3D and motion-mode oracles; 3D memcheck/initcheck/synccheck; flying,city25 impact,city256 late-debris normal asynchronous memchecks and physical comparisons, both arms. All seven light physical comparisons pass. No full52 after negative screen.

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.720 / 9.189 | 10.491 / 12.947 | 8.985 / 11.386 | -1.638 | -2.486–-0.984 |
| chain256-cold | 7.662 / 10.059 | 8.657 / 11.520 | 7.491 / 10.045 | -1.081 | -2.048–-0.303 |
| dense12-cold | 31.573 / 34.389 | 31.643 / 33.742 | 32.065 / 34.130 | 0.176 | -0.938–1.232 |
| destruction-stimulus | 4.267 / 7.750 | 4.298 / 7.871 | 4.414 / 7.987 | 0.042 | -1.197–1.086 |
| city25-initial-impact | 41.720 / 48.408 | 44.491 / 52.303 | 37.177 / 48.866 | -5.043 | -11.351–0.798 |
| city256-intact-idle | 73.704 / 98.853 | 70.966 / 73.067 | 65.535 / 73.855 | -1.347 | -10.962–11.373 |
| city256-late-debris | 420.758 / 465.582 | 429.384 / 481.243 | 412.486 / 441.498 | -12.761 | -63.338–30.247 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 16 (100.0%) / 8 (100.0%) | 0 (0.0%) / 0 (0.0%) | 16 (100.0%) / 8 (100.0%) | 34.231 / 37.579 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 8 (100.0%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 3 (37.5%) | 31.803 / 33.968 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 55.115 / 54.491 |
| destruction-stimulus | 16 / 8 | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 29.357 / 31.261 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 126.656 / 127.401 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 858.986 / 861.488 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 968.347 / 947.775 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000101 / 0.000127 | 8.695469 / 10.301381 | 0.157026 / 0.189425 |
| chain256-cold | 0.000096 / 0.000109 | 7.410188 / 8.466459 | 0.166451 / 0.190778 |
| dense12-cold | 0.000121 / 0.000158 | 31.630383 / 31.441867 | 0.188600 / 0.200657 |
| destruction-stimulus | 0.001771 / 0.001779 | 4.180904 / 4.121408 | 0.157546 / 0.175090 |
| city25-initial-impact | 0.000096 / 0.000112 | 39.263618 / 44.319597 | 0.184920 / 0.171493 |
| city256-intact-idle | 0.000140 / 0.000116 | 69.371515 / 70.734242 | 0.247704 / 0.231798 |
| city256-late-debris | 0.000192 / 0.000162 | 416.387950 / 429.162585 | 0.234019 / 0.220890 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 581.133 / 476.197 / 514.732 | 184–184 / 184–184 |
| chain256-cold | 553.275 / 502.108 / 526.800 | 492–492 / 492–492 |
| dense12-cold | 478.928 / 481.981 / 502.295 | 34–34 / 34–34 |
| destruction-stimulus | 539.902 / 528.473 / 515.105 | 1–1 / 1–1 |
| city25-initial-impact | 709.871 / 673.124 / 682.865 | 304–304 / 304–304 |
| city256-intact-idle | 1764.686 / 1809.335 / 1818.573 | 88–88 / 88–88 |
| city256-late-debris | 1881.564 / 1829.521 / 1820.248 | 1084–1084 / 1084–1084 |


Pause shared-vector caching family. Prior partial-cache failures and this full local-recurrence failure do not justify more blind parameter tuning. Next N06b changes parallel decomposition for tiny components while retaining global vector storage. Shared-memory SoA/bank behavior would require instruction/counter evidence before another cache experiment. See [NVIDIA shared-memory guidance](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html); bank conflicts are an untested explanation here.

N16 not applied. N13 remains the selected numerical policy; N20 retained isolated CPU change remains separate. No N14 promotion.
