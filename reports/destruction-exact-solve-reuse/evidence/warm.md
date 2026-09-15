# N29b continuous screen — 2026-09-13

Unpromoted finalist, source `c2644fa00b64f6a3f34ca8ced02b5825803bd860`; control `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`. Two independent 600-tick runs per stage, A-before/B/A-after. Ordinary APIs, sleeping, correction limit one, unprofiled, exclusive GPU. Each scene has 113,664 chunks / 229,376 bonds; heavy uses 256 projectiles. No exclusion of first ticks or outliers. Initialization is outside the whole-step timer; commands, integrated physics/destruction, completion and waits remain inside.

All 7,200 ticks pass recorded physical-work/convergence and iteration-history comparisons. These counters do not establish full body/force trajectory equivalence. Seven-case light and focused normal asynchronous memory checks pass. Full52 matched comparison is running; full52 memory and wall trajectory qualification remain pending.

Heavy candidate peaks164.154–169.612ms are below all four controls175.622–194.571ms. Heavy mean is essentially unchanged;519/600 deadline misses remain in every heavy run. Idle means vary widely: pooled candidate1.653180ms versus control1.515389ms, a possible0.137791ms cost. Do not call idle neutral. Consecutive ticks are not independent run replications; no significance inferred by treating600 ticks as600 trials.

| Scenario / stage / run | Mean / max ms | SD ms | 60Hz misses | Initialization ms | Commands / integrated / completion ms |
|---|---:|---:|---:|---:|---:|
| idle-256-A-before-0 | 1.600736 / 13.508373 | 0.521191 | 0/600 | 2142.473 | 0.000200 / 1.381757 / 0.218779 |
| idle-256-A-before-1 | 1.486109 / 12.809593 | 0.489996 | 0/600 | 2186.451 | 0.000254 / 1.265103 / 0.220752 |
| idle-256-B-0 | 1.453001 / 7.261137 | 0.282585 | 0/600 | 2139.926 | 0.000336 / 1.240233 / 0.212432 |
| idle-256-B-1 | 1.853360 / 7.803434 | 0.285194 | 0/600 | 2213.761 | 0.000296 / 1.604846 / 0.248218 |
| idle-256-A-after-0 | 1.271184 / 12.037925 | 0.449722 | 0/600 | 2169.190 | 0.000193 / 1.090568 / 0.180422 |
| idle-256-A-after-1 | 1.703526 / 12.069268 | 0.436832 | 0/600 | 2165.492 | 0.000439 / 1.497348 / 0.205739 |
| impacts-256-A-before-0 | 51.675792 / 194.570800 | 40.131273 | 519/600 | 2259.008 | 0.054030 / 51.381287 / 0.240475 |
| impacts-256-A-before-1 | 51.304192 / 189.542164 | 39.603036 | 519/600 | 2172.385 | 0.053100 / 51.018123 / 0.232969 |
| impacts-256-B-0 | 51.555792 / 169.612249 | 39.660092 | 519/600 | 2197.246 | 0.057799 / 51.263700 / 0.234293 |
| impacts-256-B-1 | 51.060182 / 164.154219 | 39.212797 | 519/600 | 2207.769 | 0.052522 / 50.781251 / 0.226409 |
| impacts-256-A-after-0 | 51.353132 / 186.057129 | 39.635809 | 519/600 | 2175.340 | 0.060549 / 51.069582 / 0.223001 |
| impacts-256-A-after-1 | 51.028231 / 175.622359 | 39.404563 | 519/600 | 2184.448 | 0.055401 / 50.732051 / 0.240779 |

[Full machine-readable results, modules, commands and frame hashes](warm.json). [All seven light cases, stages, setup and physical comparisons](light.md). Original N29 regressions remain in [n29-result.md](../../../qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n29-result.md). No installed/runtime promotion.
