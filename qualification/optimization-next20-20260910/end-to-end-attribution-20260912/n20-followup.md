# N20 capacity-growth requalification

Large restored debris improves38.525ms in20/20/20, consistent with reduced allocation samples. Initial impact regression does not consistently reproduce in reversed order. Warm600 heavy means differ by only~0.079ms; no substantial gameplay or peak/deadline win. Full52 qualification pending; no retention or completed-experiment credit yet.

Candidate `b7918affda83942dba04e8626db696cca7fd283a`. 16 existing behavior commands and3 normal asynchronous memory checks pass per arm, including29-case correction regression. Capacity-only CPU experiment on current snapshot-compatible runtime. N14 numerical work remains unaccepted; frozen N13 and installed SDK are unchanged.

The52-case final comparison is queued behind the current counter capture. Each case uses20/20/20 full ticks, preserving all first-use ticks at equal weight. Restore and observation are excluded. No numerical gate changed.

## Corrected seven-case light screen

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 9.040 / 10.877 | 8.941 / 11.380 | 9.014 / 10.975 | 0.086 | -0.743–0.768 |
| chain256-cold | 7.665 / 9.578 | 7.703 / 9.562 | 7.700 / 9.561 | -0.021 | -0.680–0.538 |
| dense12-cold | 31.687 / 33.851 | 31.640 / 33.705 | 31.423 / 33.278 | -0.085 | -1.085–0.729 |
| destruction-stimulus | 4.170 / 7.531 | 4.517 / 7.261 | 4.407 / 7.197 | -0.229 | -1.215–0.670 |
| city25-initial-impact | 42.682 / 49.886 | 40.338 / 45.055 | 44.329 / 48.733 | 3.168 | -0.493–6.972 |
| city256-intact-idle | 72.904 / 87.713 | 65.991 / 72.575 | 66.994 / 67.638 | 3.958 | -3.551–12.472 |
| city256-late-debris | 448.395 / 506.656 | 406.929 / 463.163 | 480.906 / 485.029 | 57.721 | 1.632–103.610 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 16 (100.0%) / 8 (100.0%) | 0 (0.0%) / 0 (0.0%) | 16 (100.0%) / 6 (75.0%) | 37.818 / 36.818 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 1 (12.5%) | 33.442 / 32.625 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 56.913 / 59.874 |
| destruction-stimulus | 16 / 8 | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 0 (0.0%) | 31.295 / 30.920 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 133.997 / 134.009 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 966.727 / 945.436 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 1075.570 / 1008.592 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000121 / 0.000117 | 8.816771 / 8.702541 | 0.210289 / 0.238435 |
| chain256-cold | 0.000104 / 0.000107 | 7.481549 / 7.527267 | 0.200791 / 0.176068 |
| dense12-cold | 0.000224 / 0.000176 | 31.385953 / 31.516033 | 0.169130 / 0.123695 |
| destruction-stimulus | 0.003119 / 0.003185 | 4.070501 / 4.322978 | 0.214813 / 0.191316 |
| city25-initial-impact | 0.000154 / 0.000140 | 43.265397 / 40.095140 | 0.240212 / 0.242840 |
| city256-intact-idle | 0.000180 / 0.000165 | 69.657160 / 65.747370 | 0.291659 / 0.243831 |
| city256-late-debris | 0.000229 / 0.000198 | 464.393960 / 406.644319 | 0.256385 / 0.284814 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 604.817 / 612.636 / 563.610 | 184–184 / 184–184 |
| chain256-cold | 532.501 / 467.783 / 549.555 | 492–492 / 492–492 |
| dense12-cold | 487.784 / 509.691 / 475.154 | 34–34 / 34–34 |
| destruction-stimulus | 568.176 / 533.764 / 482.172 | 1–1 / 1–1 |
| city25-initial-impact | 670.498 / 657.063 / 607.006 | 304–304 / 304–304 |
| city256-intact-idle | 1897.234 / 1852.440 / 2073.197 | 88–88 / 88–88 |
| city256-late-debris | 1935.953 / 1924.691 / 1896.761 | 1084–1084 / 1084–1084 |

## Targeted20/20/20 confirmation

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| city25-initial-impact | 40.042 / 50.168 | 42.286 / 52.647 | 40.679 / 50.251 | -1.926 | -3.435–-0.615 |
| city256-intact-idle | 62.792 / 74.978 | 63.452 / 76.993 | 62.793 / 73.075 | -0.660 | -3.842–2.298 |
| city256-late-debris | 395.160 / 470.015 | 357.108 / 431.175 | 396.107 / 439.306 | 38.525 | 25.352–50.455 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| city25-initial-impact | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 62.901 / 62.276 |
| city256-intact-idle | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 447.912 / 452.317 |
| city256-late-debris | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 551.498 / 517.887 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| city25-initial-impact | 0.000117 / 0.000096 | 40.183960 / 42.095704 | 0.176010 / 0.189998 |
| city256-intact-idle | 0.000158 / 0.000179 | 62.562041 / 63.145404 | 0.230247 / 0.306687 |
| city256-late-debris | 0.000164 / 0.000157 | 395.367548 / 356.875710 | 0.265580 / 0.232485 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| city25-initial-impact | 746.389 / 628.364 / 690.008 | 304–304 / 304–304 |
| city256-intact-idle | 1828.582 / 1795.680 / 1784.469 | 88–88 / 88–88 |
| city256-late-debris | 1823.882 / 1767.211 / 1813.297 | 1084–1084 / 1084–1084 |

## Reversed impact repeat

**Labels reversed in this section:** A before/after are N20; B is the original control. Positive saved milliseconds here favor the original control.

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| city25-initial-impact | 40.043 / 50.338 | 40.020 / 48.497 | 37.228 / 47.345 | -1.384 | -2.913–0.135 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| city25-initial-impact | 40 / 20 | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 40 (100.0%) / 20 (100.0%) | 68.519 / 71.286 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| city25-initial-impact | 0.000169 / 0.000148 | 38.375942 / 39.780957 | 0.259644 / 0.238949 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| city25-initial-impact | 782.578 / 655.324 / 672.683 | 304–304 / 304–304 |

## Continuous ordinary/sleeping600-tick screen

Two trials per A-before/B/A-after stage,113,664 chunks /229,376 bonds. Every tick included. Exact work, convergence and correction histories pass; this is not a substitute for full pose/force trajectory qualification. GPU modules and solver tolerances are unchanged.

| Scenario / stage / trial | Mean / peak ms | 8ms /120Hz /60Hz misses of600 | Initialization ms | Command / integrated physics / completion ms |
|---|---:|---:|---:|---:|
| idle-256 / A-before / 0 | 1.481 / 13.897 | 1 / 1 / 0 | 2439.825 | 0.000303 / 1.280821 / 0.199559 |
| idle-256 / A-before / 1 | 1.578 / 13.397 | 1 / 1 / 0 | 2363.757 | 0.000328 / 1.364109 / 0.213465 |
| idle-256 / B / 0 | 1.457 / 12.382 | 1 / 1 / 0 | 2268.975 | 0.000213 / 1.285471 / 0.171057 |
| idle-256 / B / 1 | 1.541 / 12.576 | 1 / 1 / 0 | 2282.665 | 0.000258 / 1.350499 / 0.190121 |
| idle-256 / A-after / 0 | 1.521 / 13.914 | 1 / 1 / 0 | 2358.705 | 0.000315 / 1.316699 / 0.204477 |
| idle-256 / A-after / 1 | 1.612 / 13.564 | 1 / 1 / 0 | 2463.928 | 0.000307 / 1.390184 / 0.221078 |
| impacts-256 / A-before / 0 | 54.466 / 205.662 | 519 / 519 / 519 | 2450.591 | 0.054990 / 54.215763 / 0.195125 |
| impacts-256 / A-before / 1 | 54.473 / 192.537 | 519 / 519 / 519 | 2288.233 | 0.056841 / 54.195390 / 0.220747 |
| impacts-256 / B / 0 | 54.378 / 194.894 | 519 / 519 / 519 | 2334.633 | 0.066754 / 54.114341 / 0.196839 |
| impacts-256 / B / 1 | 54.444 / 189.448 | 519 / 519 / 519 | 2422.667 | 0.052643 / 54.184067 / 0.207010 |
| impacts-256 / A-after / 0 | 54.517 / 216.550 | 519 / 519 / 519 | 2329.377 | 0.053115 / 54.266763 / 0.197034 |
| impacts-256 / A-after / 1 | 54.505 / 194.450 | 519 / 519 / 519 | 2393.236 | 0.056933 / 54.236027 / 0.212155 |

## CPU mechanism check

Intrusive profiler data supports diagnosis, not application speedup. Statistical sample counts are not milliseconds. The recorded native thread-clock scopes below are inclusive and must not be added to each other or GPU time. Six captures pass unprofiled-reference physical comparisons. The first failed local orchestration is preserved separately.

| Scenario / stage | CPU samples / unresolved leaves | Node-registration inclusive samples | Lifetime-array recreation leaf samples | Preparation / binding thread CPU ms |
|---|---:|---:|---:|---:|
| city25-initial-impact / A-before | 446 / 297 | 1 | 0 | 2.603 / 6.891 |
| city256-late-debris / A-before | 2767 / 791 | 242 | 225 | 79.773 / 106.664 |
| city25-initial-impact / B | 522 / 336 | 2 | 0 | 3.327 / 11.549 |
| city256-late-debris / B | 2694 / 832 | 8 | 0 | 6.767 / 64.848 |
| city25-initial-impact / A-after | 474 / 334 | 5 | 0 | 3.779 / 11.547 |
| city256-late-debris / A-after | 3124 / 915 | 247 | 220 | 83.059 / 104.407 |

The measured large-debris allocation reduction is substantial. Warm gameplay already retains storage across ticks, so it exposes a different cost distribution. The smaller impact trace has too few node-registration samples to explain its timing variation. Final decisions require the all-scenario result; no candidate is installed.
