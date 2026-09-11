# All destruction snapshot scenarios

**52 catalog entries: 28 original structural/rigid-body cases plus 24 large native city cases.** The city expansion adds coverage; it does not replace the bridge, cantilever, chain, flying-body, ladder, panel, tower or other original cases. Flying-body and ladder are separate fixtures.

The two groups currently have different measurement protocols and artifact cohorts. Do not compare their means as matched performance results. Restore and output validation are outside the reported tick intervals. The older structural timer stops at simulate/fetch; the newer city complete-step timer also includes mandatory completion status transfers.

## Original structural and rigid-body cases — 28

[Original measurements and provenance](snapshot-v20-results.md). These are **two independent restores, ten consecutive ticks per restore**, giving 20 continuation samples per case. They are not 20 independently restored single ticks. Cold/warm suffixes describe the source history before export, not preservation of solver/contact caches. All 28 passed the recorded correctness checks; this does not qualify every native integration or historical physical-equivalence gate.

| Scenario | Destruction chunks | Historical simulate/fetch mean / max ms | Recorded check |
|---|---:|---:|---|
| bridge64-cold | 768 | 2.138 / 9.130 | PASS |
| bridge64-warm | 768 | 1.977 / 8.842 | PASS |
| building-cold | 444 | 1.759 / 6.206 | PASS |
| building-fragmented | 444 | 4.751 / 9.811 | PASS |
| building-warm | 444 | 1.453 / 4.836 | PASS |
| cantilever64-cold | 64 | 2.104 / 8.187 | PASS |
| cantilever64-warm | 64 | 1.932 / 7.448 | PASS |
| chain256-cold | 256 | 2.018 / 8.274 | PASS |
| chain256-warm | 256 | 1.921 / 6.958 | PASS |
| chain32-cold | 32 | 1.587 / 5.231 | PASS |
| chain32-warm | 32 | 1.295 / 2.645 | PASS |
| dense12-cold | 1,728 | 4.607 / 34.295 | PASS |
| dense12-warm | 1,728 | 4.501 / 33.100 | PASS |
| destruction-cold | 2 | 1.627 / 4.910 | PASS |
| destruction-damaged | 2 | 1.438 / 3.010 | PASS |
| destruction-fractured | 2 | 2.796 / 5.267 | PASS |
| destruction-intact | 2 | 1.581 / 3.439 | PASS |
| destruction-onset | 2 | 3.211 / 10.229 | PASS |
| destruction-stimulus | 2 | 2.981 / 9.998 | PASS |
| flying | 0 | 1.199 / 1.849 | PASS |
| ladder128-cold | 288 | 1.807 / 6.308 | PASS |
| ladder128-warm | 288 | 1.676 / 5.483 | PASS |
| panel32-cold | 1,024 | 3.775 / 23.215 | PASS |
| panel32-warm | 1,024 | 3.565 / 22.963 | PASS |
| resting | 0 | 0.617 / 1.915 | PASS |
| sliding | 0 | 1.272 / 3.029 | PASS |
| tower64-cold | 2,368 | 13.078 / 118.570 | PASS |
| tower64-warm | 2,368 | 13.147 / 117.927 | PASS |

Zero destruction chunks identifies a rigid-body-only control, not an empty physics scene.

## Large native city cases — 24

[Large-scene measurements, stages and provenance](snapshot-large-20260911/README.md). These use **20 independent restores, exactly one full tick each**. Each tick includes current physics, destruction/stress, at most one correction and second stress pass, accepted publication and mandatory completion synchronization/transfers. Fifteen cases pass strict repeatability in this cohort; nine retain bond-health differences. [Memory and physical-quality limitations remain open](snapshot-large-20260911/investigation.md).

| Scenario | Chunks / bonds | Full-step mean / max ms | Repeatability in this cohort |
|---|---:|---:|---|
| city25-intact-idle | 11,100 / 22,400 | 11.113 / 21.975 | PASS |
| city25-airborne | 11,100 / 22,400 | 12.107 / 18.479 | PASS |
| city25-initial-impact | 11,100 / 22,400 | 44.796 / 53.138 | PASS |
| city25-post-impact | 11,100 / 22,400 | 24.240 / 33.632 | FAIL: bond-health equality |
| city25-cascading-fracture | 11,100 / 22,400 | 40.561 / 52.502 | PASS |
| city25-fragmented-loaded | 11,100 / 22,400 | 55.292 / 68.102 | PASS |
| city25-late-debris | 11,100 / 22,400 | 72.481 / 90.525 | FAIL: bond-health equality |
| city25-ten-second-debris | 11,100 / 22,400 | 74.306 / 87.830 | FAIL: bond-health equality |
| city64-intact-idle | 28,416 / 57,344 | 18.986 / 25.729 | PASS |
| city64-airborne | 28,416 / 57,344 | 19.901 / 23.106 | PASS |
| city64-initial-impact | 28,416 / 57,344 | 68.260 / 91.882 | PASS |
| city64-post-impact | 28,416 / 57,344 | 40.462 / 54.142 | PASS |
| city64-cascading-fracture | 28,416 / 57,344 | 62.321 / 76.200 | PASS |
| city64-fragmented-loaded | 28,416 / 57,344 | 97.738 / 128.962 | FAIL: bond-health equality |
| city64-late-debris | 28,416 / 57,344 | 148.717 / 176.702 | FAIL: bond-health equality |
| city64-ten-second-debris | 28,416 / 57,344 | 106.140 / 128.426 | FAIL: bond-health equality |
| city256-intact-idle | 113,664 / 229,376 | 69.177 / 85.129 | PASS |
| city256-airborne | 113,664 / 229,376 | 75.031 / 84.846 | PASS |
| city256-initial-impact | 113,664 / 229,376 | 260.453 / 288.678 | PASS |
| city256-post-impact | 113,664 / 229,376 | 149.502 / 172.789 | PASS |
| city256-cascading-fracture | 113,664 / 229,376 | 210.019 / 242.847 | PASS |
| city256-fragmented-loaded | 113,664 / 229,376 | 323.701 / 363.873 | FAIL: bond-health equality |
| city256-late-debris | 113,664 / 229,376 | 463.076 / 502.288 | FAIL: bond-health equality |
| city256-ten-second-debris | 113,664 / 229,376 | 274.528 / 357.086 | FAIL: bond-health equality |

## Remaining protocol coverage

The original 28 cases remain in `native_destruction_snapshot_test`. The 24-city selector in `tools/profiles/destruction-snapshot-large.json` covers only the added city group. Six smaller saved fixtures also have earlier single-tick replay evidence ([results](snapshot-v20-file-replay.md)); that does not cover all original structural cases or use the final city completion boundary. Converting every original structural case to the final 20-restores/one-tick protocol remains pending. Do not describe the 52-entry catalog as a uniformly measured single-tick acceptance suite.
