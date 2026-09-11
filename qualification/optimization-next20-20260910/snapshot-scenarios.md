# All destruction snapshot scenarios

**52 scenarios, 20 independent restores per scenario, exactly one complete tick per restore: 1,040 measured ticks.** All 28 structural/rigid-body cases pass repeatability; 15 of 24 city cases pass, with nine bond-health-only comparison failures. These are two sequential campaigns using the same frozen executable and runtime modules. No tolerance changed.

Every full tick includes input commands, integrated physics/stress/fracture, at most one correction and second stress evaluation, accepted publication, and required completion synchronization/status transfers. **Restore and output validation are excluded.** Source cold/warm labels describe pre-export history; solver/contact caches are rebuilt.

The structural campaign took **139.01 seconds** including restoration and validation. Summed harness time for both campaigns is **1,159.65 seconds (19.33 minutes)**; measured ticks total 63.68 seconds, restoration 623.50 seconds, and other setup/validation/teardown 472.47 seconds. These are observed shared-GPU costs, not a guarantee of future suite duration.

Use the [unified runner and exact commands](../../tools/diagnostics/destruction-snapshot/README.md). The [record audit](snapshot-unified-verification.json) verifies sample counts, fixed input hashes, matching executable/modules, and complete-step stage sums.

## Structural and rigid-body scenarios — 28

[Full timings, spread, stages, restore costs and budget misses](snapshot-structural-one-tick-20260911.md). All 560 independently restored ticks completed and passed exact material/topology and bounded motion comparison; observed pose/velocity differences were zero. The original [two-restores/ten-continuation-ticks regression](snapshot-v20-results.md) remains separate correctness coverage.

| Scenario | Chunks | Purpose | Full tick mean / max ms | Repeatability |
|---|---:|---|---:|---|
| bridge64-cold | 768 | Two supports and a spanning load path; bending and load redistribution. | 9.157 / 13.206 | PASS |
| bridge64-warm | 768 | Two supports and a spanning load path; bending and load redistribution. | 8.609 / 10.617 | PASS |
| building-cold | 444 | Multi-storey wall/slab connectivity and shared supports. | 5.174 / 7.812 | PASS |
| building-fragmented | 444 | Multi-storey wall/slab connectivity and shared supports. | 9.033 / 15.601 | PASS |
| building-warm | 444 | Multi-storey wall/slab connectivity and shared supports. | 4.349 / 6.120 | PASS |
| cantilever64-cold | 64 | One-sided support and a long bending lever arm. | 8.153 / 13.410 | PASS |
| cantilever64-warm | 64 | One-sided support and a long bending lever arm. | 7.735 / 11.659 | PASS |
| chain256-cold | 256 | Long sparse chain with slow stress propagation. | 7.089 / 10.465 | PASS |
| chain256-warm | 256 | Long sparse chain with slow stress propagation. | 7.636 / 11.444 | PASS |
| chain32-cold | 32 | Short sparse-chain control. | 2.975 / 7.308 | PASS |
| chain32-warm | 32 | Short sparse-chain control. | 2.988 / 5.294 | PASS |
| dense12-cold | 1,728 | Dense 3D connectivity and redundant load paths. | 33.114 / 36.063 | PASS |
| dense12-warm | 1,728 | Dense 3D connectivity and redundant load paths. | 33.039 / 35.770 | PASS |
| destruction-cold | 2 | Fresh intact two-chunk structure. | 3.833 / 7.149 | PASS |
| destruction-damaged | 2 | Partially damaged bond with persistent material history. | 3.614 / 6.930 | PASS |
| destruction-fractured | 2 | Already fractured chunks and physical ownership. | 5.273 / 10.139 | PASS |
| destruction-intact | 2 | Intact bond after prior physical evolution. | 3.601 / 7.868 | PASS |
| destruction-onset | 2 | Projectile approaching the two-chunk fracture fixture. | 4.299 / 8.875 | PASS |
| destruction-stimulus | 2 | New impulse and angular velocity submitted inside the measured tick. | 4.819 / 8.952 | PASS |
| flying | 0 | Free-flight gravity reference without destruction. | 1.876 / 2.384 | PASS |
| ladder128-cold | 288 | Repeated loops joined by long parallel rails. | 6.082 / 9.589 | PASS |
| ladder128-warm | 288 | Repeated loops joined by long parallel rails. | 5.532 / 6.350 | PASS |
| panel32-cold | 1,024 | Broad thin surface with many in-plane paths. | 21.883 / 24.456 | PASS |
| panel32-warm | 1,024 | Broad thin surface with many in-plane paths. | 22.277 / 24.364 | PASS |
| resting | 0 | Resting rigid-body contact/sleep control. | 1.815 / 2.770 | PASS |
| sliding | 0 | Frictional rigid-body contact control. | 2.876 / 4.072 | PASS |
| tower64-cold | 2,368 | Tall slender structure under gravity and bending. | 116.912 / 121.191 | PASS |
| tower64-warm | 2,368 | Tall slender structure under gravity and bending. | 117.293 / 119.586 | PASS |

Zero destruction chunks identifies a rigid-body-only control, not an empty scene. `destruction-stimulus` submits its impulse and angular setter inside the measured tick.

## Large native city scenarios — 24

[Full city measurements and stages](snapshot-large-20260911/README.md). Each state comes from a real native demo trajectory at fixed settings. The ten-second debris state is not asserted settled or asleep.

| Scenario | Chunks / bonds | Full tick mean / max ms | Repeatability |
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

## Remaining qualification

The nine city failures are output comparisons, not missing timings. Maximum observed bond-health difference is 0.000006079673767; motion and topology matched. Their physical significance and accumulation remain unqualified. One additional city case passed this cohort but failed an earlier cohort, so a pass is not a determinism guarantee.

Native memory checking also fails without any export/restore. The alternate compile-time instrumentation control still fails. [Investigation and controls](snapshot-large-20260911/investigation.md) distinguish this unresolved integration/tool question from repeatability. Restored versus uninterrupted fracture verdicts differ materially and still need physical-quality assessment; exact cached execution continuation is not required.

The suite now has uniform single-tick coverage, but it is **not a fully qualified optimization acceptance gate**. Fresh-restored timings also do not replace continuous warm gameplay measurements. No optimization speedup is claimed.
