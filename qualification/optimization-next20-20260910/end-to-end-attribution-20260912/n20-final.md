# N20 complete-step qualification

All52 physical comparisons pass,3120 full ticks. Large restored late-debris benefit repeats:382.883ms versus422.663/426.525ms controls,9.83% versus pooled control in this cohort. Earlier independent20/20/20 result was357.108 versus395.160/396.107ms; do not combine cohorts. First-impact, cold-panel and city64 cascade losses do not consistently repeat in reversed order. Warm600 heavy mean advantage remains~0.079ms, with519/600 60Hz misses unchanged. Warm180 fracture-burst repeat is161.241 versus166.641/163.340ms; modest event benefit, not a whole-game speedup. Full memory gate pending; no promotion of N14 or installed SDK.

Commit `b7918affda83942dba04e8626db696cca7fd283a`. The only change is reserving the lifetime array to the existing node capacity before appending. It eliminates repeated copying during fragment registration. No physical arithmetic, step order or cache state changes.

## Full52 restored comparison

Each arm has20 independently restored full ticks per scenario, including its first tick. Restore, export and comparison are outside the timer. All52 cases and original quality gates are preserved. Separate before/after controls expose drift; bootstrap intervals are descriptive, not independent-run significance. This is a cold reconstructed workload, distinct from continuous play.

| Scenario | Control before / candidate / control after mean ms | Peaks ms, same order | 60Hz misses, each /20 | Candidate command / physics+destruction / completion ms | Candidate restore ms, excluded |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 8.811 / 8.745 / 8.895 | 11.116 / 11.703 / 11.091 | 0 / 0 / 0 | 0.000103 / 8.537151 / 0.207939 | 22.174 |
| bridge64-warm | 8.820 / 8.644 / 8.880 | 11.160 / 10.758 / 11.128 | 0 / 0 / 0 | 0.000135 / 8.435806 / 0.208142 | 21.238 |
| building-cold | 4.773 / 4.984 / 5.097 | 7.027 / 7.282 / 7.989 | 0 / 0 / 0 | 0.000168 / 4.828628 / 0.155220 | 25.405 |
| building-fragmented | 8.186 / 8.279 / 8.657 | 13.403 / 11.952 / 13.794 | 0 / 0 / 0 | 0.000105 / 8.078132 / 0.200923 | 21.228 |
| building-warm | 4.892 / 4.846 / 4.943 | 6.980 / 7.238 / 7.355 | 0 / 0 / 0 | 0.000090 / 4.638953 / 0.207307 | 20.415 |
| cantilever64-cold | 7.718 / 7.501 / 7.271 | 10.465 / 9.920 / 9.611 | 0 / 0 / 0 | 0.000143 / 7.330678 / 0.170136 | 17.384 |
| cantilever64-warm | 7.466 / 7.547 / 7.443 | 10.116 / 12.291 / 10.244 | 0 / 0 / 0 | 0.000137 / 7.383143 / 0.163291 | 18.853 |
| chain256-cold | 7.223 / 7.313 / 7.427 | 9.588 / 9.050 / 10.302 | 0 / 0 / 0 | 0.000138 / 7.133989 / 0.178791 | 18.225 |
| chain256-warm | 7.469 / 7.428 / 7.397 | 9.793 / 9.547 / 9.430 | 0 / 0 / 0 | 0.000127 / 7.217799 / 0.210012 | 18.170 |
| chain32-cold | 3.114 / 3.121 / 3.254 | 9.813 / 6.051 / 6.285 | 0 / 0 / 0 | 0.000110 / 2.940078 / 0.180708 | 18.229 |
| chain32-warm | 3.209 / 3.230 / 3.183 | 6.285 / 6.283 / 6.345 | 0 / 0 / 0 | 0.000120 / 2.949310 / 0.280556 | 17.616 |
| dense12-cold | 31.128 / 31.329 / 31.284 | 33.368 / 33.495 / 33.573 | 20 / 20 / 20 | 0.000237 / 31.122158 / 0.206823 | 34.981 |
| dense12-warm | 31.143 / 31.321 / 31.255 | 32.971 / 34.019 / 33.520 | 20 / 20 / 20 | 0.000192 / 31.210201 / 0.111014 | 40.144 |
| destruction-cold | 3.462 / 3.661 / 3.482 | 6.150 / 6.418 / 7.022 | 0 / 0 / 0 | 0.000121 / 3.468460 / 0.192294 | 17.435 |
| destruction-damaged | 3.524 / 3.473 / 3.685 | 6.495 / 6.437 / 7.092 | 0 / 0 / 0 | 0.000100 / 3.280881 / 0.192499 | 17.054 |
| destruction-fractured | 5.000 / 5.080 / 5.361 | 9.426 / 9.223 / 9.234 | 0 / 0 / 0 | 0.000127 / 4.890405 / 0.189261 | 16.619 |
| destruction-intact | 3.669 / 3.637 / 3.635 | 7.212 / 6.126 / 7.078 | 0 / 0 / 0 | 0.000239 / 3.412630 / 0.223944 | 18.661 |
| destruction-onset | 3.908 / 4.188 / 3.988 | 7.505 / 7.442 / 7.305 | 0 / 0 / 0 | 0.000129 / 3.999288 / 0.189055 | 16.290 |
| destruction-stimulus | 4.338 / 4.251 / 4.370 | 7.956 / 7.641 / 7.699 | 0 / 0 / 0 | 0.003076 / 4.058445 / 0.189208 | 16.427 |
| flying | 1.803 / 1.751 / 1.730 | 2.392 / 2.353 / 2.235 | 0 / 0 / 0 | 0.000076 / 1.750347 / 0.000576 | 7.652 |
| ladder128-cold | 5.775 / 5.786 / 5.751 | 8.107 / 8.063 / 7.954 | 0 / 0 / 0 | 0.000080 / 5.582281 / 0.203817 | 19.781 |
| ladder128-warm | 5.915 / 5.771 / 5.642 | 7.838 / 7.909 / 7.967 | 0 / 0 / 0 | 0.000105 / 5.572697 / 0.198405 | 22.176 |
| panel32-cold | 21.132 / 21.415 / 21.074 | 23.409 / 23.987 / 23.251 | 20 / 20 / 20 | 0.000194 / 21.292499 / 0.122789 | 27.115 |
| panel32-warm | 21.114 / 21.141 / 20.968 | 23.951 / 23.593 / 22.669 | 20 / 20 / 20 | 0.000185 / 20.971790 / 0.168604 | 26.759 |
| resting | 1.535 / 1.467 / 1.498 | 2.399 / 2.272 / 2.283 | 0 / 0 / 0 | 0.000129 / 1.465596 / 0.000828 | 6.767 |
| sliding | 2.485 / 2.543 / 2.474 | 3.428 / 3.554 / 3.268 | 0 / 0 / 0 | 0.000105 / 2.541853 / 0.000808 | 6.795 |
| tower64-cold | 108.358 / 108.434 / 108.486 | 110.536 / 111.349 / 111.661 | 20 / 20 / 20 | 0.000220 / 108.315771 / 0.118026 | 41.545 |
| tower64-warm | 108.339 / 108.494 / 108.445 | 110.510 / 111.316 / 110.965 | 20 / 20 / 20 | 0.000266 / 108.352707 / 0.140680 | 41.019 |
| city25-intact-idle | 10.394 / 10.145 / 10.802 | 13.348 / 13.082 / 13.197 | 0 / 0 / 0 | 0.000243 / 9.929243 / 0.215971 | 67.304 |
| city25-airborne | 11.286 / 11.599 / 11.445 | 14.206 / 14.435 / 14.155 | 0 / 0 / 0 | 0.000172 / 11.379797 / 0.219402 | 72.289 |
| city25-initial-impact | 39.996 / 39.264 / 37.963 | 48.876 / 48.881 / 46.115 | 20 / 20 / 20 | 0.000128 / 39.017976 / 0.245459 | 72.785 |
| city25-post-impact | 22.368 / 22.258 / 22.284 | 29.766 / 29.290 / 28.791 | 20 / 20 / 20 | 0.000181 / 22.019181 / 0.239083 | 70.927 |
| city25-cascading-fracture | 40.584 / 38.297 / 40.852 | 48.912 / 42.759 / 53.447 | 20 / 20 / 20 | 0.000131 / 38.080323 / 0.216535 | 72.703 |
| city25-fragmented-loaded | 53.149 / 54.236 / 52.894 | 68.162 / 63.798 / 65.864 | 20 / 20 / 20 | 0.000159 / 53.970071 / 0.265988 | 74.101 |
| city25-late-debris | 69.784 / 66.349 / 67.626 | 83.981 / 85.751 / 78.302 | 20 / 20 / 20 | 0.000143 / 66.109995 / 0.239023 | 80.946 |
| city25-ten-second-debris | 69.498 / 69.181 / 67.357 | 88.007 / 95.080 / 77.832 | 20 / 20 / 20 | 0.000158 / 68.943390 / 0.237134 | 79.250 |
| city64-intact-idle | 17.433 / 17.949 / 17.718 | 22.071 / 21.129 / 21.519 | 16 / 19 / 17 | 0.000166 / 17.695412 / 0.253087 | 171.831 |
| city64-airborne | 19.063 / 18.850 / 19.195 | 23.628 / 25.336 / 21.655 | 19 / 18 / 20 | 0.000140 / 18.598427 / 0.251931 | 170.587 |
| city64-initial-impact | 65.508 / 63.334 / 61.467 | 81.976 / 76.530 / 72.606 | 20 / 20 / 20 | 0.000147 / 63.104672 / 0.228893 | 168.400 |
| city64-post-impact | 38.442 / 37.395 / 38.502 | 50.414 / 46.823 / 48.065 | 20 / 20 / 20 | 0.000221 / 37.152364 / 0.242050 | 169.889 |
| city64-cascading-fracture | 58.155 / 59.518 / 56.705 | 69.671 / 71.194 / 66.709 | 20 / 20 / 20 | 0.000138 / 59.296430 / 0.221863 | 173.558 |
| city64-fragmented-loaded | 94.960 / 94.428 / 93.376 | 113.185 / 117.259 / 111.398 | 20 / 20 / 20 | 0.000129 / 94.174527 / 0.253391 | 190.278 |
| city64-late-debris | 136.995 / 133.798 / 138.131 | 166.599 / 171.554 / 180.973 | 20 / 20 / 20 | 0.000161 / 133.553859 / 0.244046 | 197.976 |
| city64-ten-second-debris | 99.281 / 96.681 / 95.817 | 133.313 / 131.263 / 130.581 | 20 / 20 / 20 | 0.000653 / 96.440220 / 0.240607 | 182.032 |
| city256-intact-idle | 63.720 / 65.998 / 67.906 | 76.316 / 79.530 / 87.329 | 20 / 20 / 20 | 0.000196 / 65.748968 / 0.248733 | 523.098 |
| city256-airborne | 71.387 / 72.020 / 76.370 | 85.390 / 83.666 / 84.851 | 20 / 20 / 20 | 0.000193 / 71.740794 / 0.278949 | 522.087 |
| city256-initial-impact | 247.735 / 240.893 / 251.125 | 303.397 / 288.232 / 301.476 | 20 / 20 / 20 | 0.000199 / 240.638684 / 0.254449 | 530.182 |
| city256-post-impact | 145.589 / 145.421 / 150.555 | 175.540 / 170.425 / 173.690 | 20 / 20 / 20 | 0.000173 / 145.263730 / 0.157538 | 557.746 |
| city256-cascading-fracture | 197.209 / 197.229 / 198.858 | 227.759 / 223.423 / 222.505 | 20 / 20 / 20 | 0.000213 / 196.988218 / 0.240240 | 566.327 |
| city256-fragmented-loaded | 306.688 / 292.395 / 308.063 | 337.908 / 325.613 / 359.966 | 20 / 20 / 20 | 0.000179 / 292.169435 / 0.225351 | 587.982 |
| city256-late-debris | 422.663 / 382.883 / 426.525 | 466.125 / 452.158 / 498.697 | 20 / 20 / 20 | 0.000178 / 382.640600 / 0.242495 | 596.122 |
| city256-ten-second-debris | 266.156 / 258.889 / 263.031 | 347.710 / 347.191 / 346.223 | 20 / 20 / 20 | 0.000225 / 258.637544 / 0.250923 | 612.142 |

Full initialization,120Hz/8ms misses, iteration ranges, first-use values, spread and raw paths are in `n20-full52.json`. No peak/deadline benefit is claimed from a mean-only result.

## Reversed repeats of flagged regressions

Predeclared rule: repeat losses exceeding both0.1ms and1%, slower than both controls, and with a descriptive interval wholly negative. Reverse order is N20/original/N20; all60 ticks per case pass physical comparisons. Original losses remain in the full table.

| Scenario | N20 / original / N20 means ms | Peaks ms, same order |
|---|---:|---:|
| panel32-cold | 21.151 / 21.478 / 21.271 | 24.652 / 25.044 / 23.280 |
| city64-cascading-fracture | 55.465 / 57.527 / 57.713 | 64.075 / 65.813 / 63.445 |

## Continuous simulation

The600-tick idle/heavy A/B/A campaign and its full mean/peak/budget/stage/initialization table remain in [the prior follow-up](n20-followup.md). Exact work/convergence/correction histories pass. Both600-tick ordinary/sleeping wall runs additionally pass the pinned reference, exact topology counters and zero observed position difference.

Four independent180-tick processes per A-before/B/A-after stage confirm the originally fixed heavy semantic frames. Inputs, solver caps and tolerances are unchanged; each prefix counter is compared with the600-tick control. These are corresponding trajectory events, not identical-input snapshots. Neither four samples nor blocked execution supports a strong tail/significance claim.

| Event | Control before / candidate / control after mean ms | Observed maxima ms |
|---|---:|---:|
| first-contact-fracture-correction | 191.682 / 186.216 / 187.848 | 210.700 / 201.507 / 212.464 |
| loaded-fractured-no-new-breakage | 48.461 / 49.761 / 51.541 | 49.003 / 52.675 / 56.122 |
| later-large-fracture-burst | 166.641 / 161.241 / 163.340 | 170.640 / 163.640 / 171.012 |
| later-contact-rich-correction | 109.099 / 109.901 / 110.539 | 110.141 / 111.726 / 112.144 |

## Diagnosis and decision

Large-debris CPU profiles reduce lifetime-array recreation leaf samples from225/220 to0 and node-add inclusive samples from242/247 to8. Inclusive preparation thread CPU drops79.773/83.059ms to6.767ms; binding CPU106.664/104.407ms to64.848ms. Scope times overlap and cannot be added. Profiler tick times are excluded from speedup evidence. Continuous worlds reuse allocated storage, explaining why the large cold benefit does not translate into a similar600-tick mean improvement.

**Pending:** all52 normal asynchronous memory checks on the candidate CPU binary. The unchanged GPU-module baseline already passed this gate, but candidate acceptance still requires its own full run. N20 remains isolated until that completes. N14 numerical policy remains explicitly unaccepted; selecting this CPU change does not select N14. Installed SDK and main source are unchanged.
