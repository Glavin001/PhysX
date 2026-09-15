# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Shared-GPU unprofiled comparison; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| chain256-warm | 7.323 / 10.131 | 7.237 / 10.641 | 7.180 / 9.758 | 0.014 | -0.486–0.505 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >60 Hz | A / B >120 Hz | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|
| chain256-warm | 40 / 20 | 0 / 0 | 2 / 1 | 128.081 / 129.025 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| chain256-warm | 0.000103 / 0.000148 | 7.051647 / 7.068959 | 0.199394 / 0.168221 |
