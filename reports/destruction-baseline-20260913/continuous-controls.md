# Continuous selected-control baseline

Unprofiled, ordinary API, sleeping enabled, 256 buildings / 113,664 chunks / 229,376 bonds; 256 projectiles in heavy. Four runs per regime, all ticks retained. Restore is not part of this workload. This is separate from the restored snapshot cohort.

| Run | Mean / max ms | SD ms | 60 Hz misses | Initialization ms | Command / integrated / completion ms |
|---|---:|---:|---:|---:|---:|
| idle-256-A-before-0 | 1.601 / 13.508 | 0.521 | 0/600 | 2142.473 | 0.0002 / 1.382 / 0.219 |
| idle-256-A-before-1 | 1.486 / 12.810 | 0.490 | 0/600 | 2186.451 | 0.0003 / 1.265 / 0.221 |
| idle-256-A-after-0 | 1.271 / 12.038 | 0.450 | 0/600 | 2169.190 | 0.0002 / 1.091 / 0.180 |
| idle-256-A-after-1 | 1.704 / 12.069 | 0.437 | 0/600 | 2165.492 | 0.0004 / 1.497 / 0.206 |
| impacts-256-A-before-0 | 51.676 / 194.571 | 40.131 | 519/600 | 2259.008 | 0.0540 / 51.381 / 0.240 |
| impacts-256-A-before-1 | 51.304 / 189.542 | 39.603 | 519/600 | 2172.385 | 0.0531 / 51.018 / 0.233 |
| impacts-256-A-after-0 | 51.353 / 186.057 | 39.636 | 519/600 | 2175.340 | 0.0605 / 51.070 / 0.223 |
| impacts-256-A-after-1 | 51.028 / 175.622 | 39.405 | 519/600 | 2184.448 | 0.0554 / 50.732 / 0.241 |

Exact work/convergence histories pass the historical comparison. Full orientation/velocity/material trajectory qualification remains a separate requirement. No gain is claimed. [All frames](data/continuous-control-frames.csv).
