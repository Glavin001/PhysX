# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Shared-GPU unprofiled comparison; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| flying | 2.378 / 2.597 | 2.489 / 2.956 | 2.718 / 2.852 | 0.059 | -0.579–0.699 |
| city25-initial-impact | 43.812 / 49.977 | 50.829 / 58.576 | 44.112 / 46.742 | -6.868 | -17.697–3.962 |
| city256-late-debris | 563.742 / 739.590 | 485.031 / 532.853 | 462.895 / 487.730 | 28.287 | -107.459–179.176 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >60 Hz | A / B >120 Hz | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|
| flying | 4 / 2 | 0 / 0 | 0 / 0 | 121.994 / 127.563 |
| city25-initial-impact | 4 / 2 | 4 / 2 | 4 / 2 | 323.465 / 319.837 |
| city256-late-debris | 4 / 2 | 4 / 2 | 4 / 2 | 2107.558 / 2049.647 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| flying | 0.000189 / 0.000170 | 2.547149 / 2.488612 | 0.000414 / 0.000396 |
| city25-initial-impact | 0.000094 / 0.000132 | 43.753146 / 50.592404 | 0.208675 / 0.236950 |
| city256-late-debris | 0.000160 / 0.000174 | 513.030373 / 484.423333 | 0.287744 / 0.607390 |
