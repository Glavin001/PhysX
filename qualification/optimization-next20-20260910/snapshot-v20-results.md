# Physical-state save/load results

Shared-GPU correctness diagnostics: two independent restores per case, ten consecutive full ticks each. Export and paired restoration/validation measured separately. Continuation samples are correlated; no speedup or continuous-city performance claim.

| Scenario | Chunks | Broken at export | First tick median ms | Full-tick mean / max ms | >8 / >120Hz / >60Hz | Samples | Pass |
|---|---:|---:|---:|---:|---:|---:|---|
| bridge64-cold | 768 | 0 | 8.779 | 2.138 / 9.130 | 2 (10.0%) / 2 (10.0%) / 0 (0.0%) | 20 | Yes |
| bridge64-warm | 768 | 0 | 8.515 | 1.977 / 8.842 | 2 (10.0%) / 1 (5.0%) / 0 (0.0%) | 20 | Yes |
| building-cold | 444 | 0 | 5.330 | 1.759 / 6.206 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| building-fragmented | 444 | 781 | 9.711 | 4.751 / 9.811 | 2 (10.0%) / 2 (10.0%) / 0 (0.0%) | 20 | Yes |
| building-warm | 444 | 0 | 4.486 | 1.453 / 4.836 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| cantilever64-cold | 64 | 0 | 7.813 | 2.104 / 8.187 | 1 (5.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| cantilever64-warm | 64 | 0 | 7.423 | 1.932 / 7.448 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| chain256-cold | 256 | 0 | 7.769 | 2.018 / 8.274 | 1 (5.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| chain256-warm | 256 | 0 | 6.954 | 1.921 / 6.958 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| chain32-cold | 32 | 0 | 3.938 | 1.587 / 5.231 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| chain32-warm | 32 | 0 | 2.327 | 1.295 / 2.645 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| dense12-cold | 1728 | 0 | 33.841 | 4.607 / 34.295 | 2 (10.0%) / 2 (10.0%) / 2 (10.0%) | 20 | Yes |
| dense12-warm | 1728 | 0 | 32.957 | 4.501 / 33.100 | 2 (10.0%) / 2 (10.0%) / 2 (10.0%) | 20 | Yes |
| destruction-cold | 2 | 0 | 3.922 | 1.627 / 4.910 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| destruction-damaged | 2 | 0 | 2.833 | 1.438 / 3.010 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| destruction-fractured | 2 | 1 | 5.231 | 2.796 / 5.267 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| destruction-intact | 2 | 0 | 3.397 | 1.581 / 3.439 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| destruction-onset | 2 | 0 | 3.794 | 3.211 / 10.229 | 2 (10.0%) / 2 (10.0%) / 0 (0.0%) | 20 | Yes |
| destruction-stimulus | 2 | 0 | 3.176 | 2.981 / 9.998 | 2 (10.0%) / 2 (10.0%) / 0 (0.0%) | 20 | Yes |
| flying | 0 | 0 | 1.725 | 1.199 / 1.849 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| ladder128-cold | 288 | 0 | 5.790 | 1.807 / 6.308 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| ladder128-warm | 288 | 0 | 5.414 | 1.676 / 5.483 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| panel32-cold | 1024 | 0 | 23.011 | 3.775 / 23.215 | 2 (10.0%) / 2 (10.0%) / 2 (10.0%) | 20 | Yes |
| panel32-warm | 1024 | 0 | 22.070 | 3.565 / 22.963 | 2 (10.0%) / 2 (10.0%) / 2 (10.0%) | 20 | Yes |
| resting | 0 | 0 | 1.678 | 0.617 / 1.915 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| sliding | 0 | 0 | 2.981 | 1.272 / 3.029 | 0 (0.0%) / 0 (0.0%) / 0 (0.0%) | 20 | Yes |
| tower64-cold | 2368 | 0 | 118.489 | 13.078 / 118.570 | 2 (10.0%) / 2 (10.0%) / 2 (10.0%) | 20 | Yes |
| tower64-warm | 2368 | 0 | 117.892 | 13.147 / 117.927 | 2 (10.0%) / 2 (10.0%) / 2 (10.0%) | 20 | Yes |

Exact samples, separate export/setup observations, byte sizes and motion errors are in the adjacent JSON. Budget counts use the complete denominator shown in each row. These fixture geometries are not the 256-building city benchmark.
