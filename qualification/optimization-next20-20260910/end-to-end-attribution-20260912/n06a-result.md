# N06a: rejected cooperative launch pilot

Reject. Dense full-step mean32.106→513.374ms and tower109.121→2284.911ms. Reduced parallelism overwhelms any synchronization benefit. This rejects the one-block pilot, not every size-specialized or component-local multilevel design.

Four A/B×scenario normal asynchronous memcheck runs pass with zero errors; all compare against the existing unprofiled physical reference. Matched A/B/A physical checks pass, iteration counts remain34 dense and137 tower.

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| dense12-cold | 32.053 / 33.910 | 513.374 / 514.950 | 32.160 / 34.481 | -481.268 | -482.595–-479.979 |
| tower64-cold | 109.008 / 110.683 | 2284.911 / 2287.329 | 109.234 / 111.091 | -2175.790 | -2177.603–-2174.205 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| dense12-cold | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 72.985 / 76.803 |
| tower64-cold | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 75.569 / 77.246 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| dense12-cold | 0.000147 / 0.000176 | 31.930370 / 513.243265 | 0.175569 / 0.130298 |
| tower64-cold | 0.000157 / 0.000175 | 108.972376 / 2284.767034 | 0.148400 / 0.143457 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| dense12-cold | 559.492 / 529.415 / 535.245 | 34–34 / 34–34 |
| tower64-cold | 540.459 / 501.592 / 471.701 | 137–137 / 137–137 |
