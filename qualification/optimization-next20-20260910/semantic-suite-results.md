# Semantic baseline results — 2026-09-11

Retained N13 solver; new geometry-capable native consumer. Ten independent fresh-process prefixes per case; all24 frozen predicates pass all10 repetitions. This is **not snapshot replay**, an A/B result, or a new speedup. Shared GPU with the recorded graphics processes and PID435374. Native convergence and correction/evaluation caps pass; historical physical/memory gaps remain. Full raw commands, maps, hashes and GPU samples: `out/semantic-suite-20260911/repeatability-10/`.

## Complete-tick semantic measurements

Mean confidence intervals are descriptive independent-run bootstrap95; no suite-wide significance claim. The maximum is the largest of10 samples. Stages in the JSON are command / integrated physics+destruction / mandatory completion; detailed host/CUDA stage capture is deferred while export/restore is prioritized.

| ID | Scenario | Mean ms | Mean95% interval ms | Observed max ms | CV % |
|---|---|---:|---:|---:|---:|
| R01 | Single building: first gravity equilibrium | 6.002 | 5.655–6.278 | 6.599 | 8.95 |
| R02 | Single building: intact quiescence | 1.705 | 1.564–1.852 | 2.129 | 14.51 |
| R03 | City: first gravity equilibrium | 13.763 | 13.101–14.370 | 15.477 | 7.91 |
| R04 | City: intact quiescence | 1.751 | 1.653–1.873 | 2.205 | 10.74 |
| R05 | City: projectiles in flight | 4.104 | 3.992–4.221 | 4.490 | 4.73 |
| R06 | City: first fracture and correction cascade | 205.307 | 199.640–210.971 | 220.601 | 4.68 |
| R07 | City: changed loads on fractured topology | 48.703 | 47.887–49.659 | 51.988 | 3.07 |
| R08 | City: later mass fracture burst | 124.433 | 123.120–125.851 | 129.515 | 1.91 |
| R09 | City: dense fragment contacts | 121.891 | 120.800–123.083 | 124.893 | 1.60 |
| R10 | Wall: first puncture fracture | 21.087 | 20.150–22.064 | 23.663 | 7.81 |
| R11 | Wall: subsequent fracture episode | 22.183 | 21.500–22.845 | 24.101 | 5.27 |
| R12 | Wall: moving fragments after impact | 8.779 | 8.548–9.029 | 9.519 | 4.70 |
| R13 | 16 buildings: first correction cascade | 36.440 | 35.568–37.455 | 40.053 | 4.40 |
| R14 | 16 buildings: loaded fractured state | 13.851 | 13.381–14.293 | 14.784 | 5.56 |
| R15 | 16 buildings: fragment contact burst | 26.084 | 25.620–26.595 | 27.635 | 3.20 |
| R16 | One localized impact in a retained city | 28.913 | 28.393–29.500 | 30.842 | 3.23 |
| S01 | 32-node vertical chain | 5.475 | 4.827–6.086 | 7.142 | 19.64 |
| S02 | 256-node vertical chain | 9.091 | 8.805–9.445 | 10.080 | 5.97 |
| S03 | 64-node horizontal cantilever | 9.340 | 9.149–9.508 | 9.744 | 3.37 |
| S04 | 12 cubed solid block | 33.701 | 33.310–34.124 | 35.040 | 2.05 |
| S05 | 64-storey hollow frame | 118.018 | 117.572–118.390 | 118.985 | 0.59 |
| S06 | 32 by 32 corner-supported panel | 34.325 | 33.961–34.723 | 35.425 | 1.93 |
| S07 | 64-span hollow bridge | 14.467 | 14.259–14.689 | 15.137 | 2.55 |
| S08 | 128-high ladder with sparse rungs | 6.681 | 6.214–7.160 | 7.864 | 12.23 |

## Entire measured prefixes, including startup ticks

These prefixes have different lengths by design; compare each fixture only to itself. They do not replace the retained600-step idle/heavy suite. Totals below include initialization plus every complete step; process teardown and benchmark reporting are separately available in raw run receipts.

| Fixture | Ticks/run | Mean of run means ms | Largest full-step max ms | Mean init ms | Mean init + steps ms | >8ms | >120Hz | >60Hz |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| cantilever64 | 2 | 5.781 | 9.744 | 539.986 | 551.547 | 10/20 (50.00%) | 10/20 (50.00%) | 0/20 (0.00%) |
| wall-1 | 180 | 8.535 | 24.101 | 559.259 | 2095.546 | 1338/1800 (74.33%) | 1146/1800 (63.67%) | 50/1800 (2.78%) |
| impacts-16 | 180 | 12.168 | 42.494 | 693.513 | 2883.736 | 990/1800 (55.00%) | 990/1800 (55.00%) | 394/1800 (21.89%) |
| localized-256 | 180 | 10.467 | 31.881 | 2200.247 | 4084.293 | 1638/1800 (91.00%) | 1632/1800 (90.67%) | 50/1800 (2.78%) |
| ladder128 | 2 | 4.249 | 7.864 | 543.224 | 551.722 | 0/20 (0.00%) | 0/20 (0.00%) | 0/20 (0.00%) |
| idle-256 | 61 | 1.904 | 15.477 | 2169.376 | 2285.548 | 10/610 (1.64%) | 10/610 (1.64%) | 0/610 (0.00%) |
| idle-1 | 61 | 1.638 | 6.599 | 543.597 | 643.536 | 0/610 (0.00%) | 0/610 (0.00%) | 0/610 (0.00%) |
| dense12 | 2 | 17.958 | 35.040 | 560.766 | 596.682 | 10/20 (50.00%) | 10/20 (50.00%) | 10/20 (50.00%) |
| impacts-256 | 180 | 60.402 | 220.601 | 2198.979 | 13071.413 | 990/1800 (55.00%) | 990/1800 (55.00%) | 990/1800 (55.00%) |
| chain256 | 2 | 5.739 | 10.080 | 550.042 | 561.520 | 10/20 (50.00%) | 10/20 (50.00%) | 0/20 (0.00%) |
| bridge64 | 2 | 8.331 | 15.137 | 540.303 | 556.966 | 10/20 (50.00%) | 10/20 (50.00%) | 0/20 (0.00%) |
| panel32 | 2 | 18.355 | 35.425 | 547.637 | 584.347 | 10/20 (50.00%) | 10/20 (50.00%) | 10/20 (50.00%) |
| chain32 | 2 | 3.715 | 7.142 | 528.404 | 535.833 | 0/20 (0.00%) | 0/20 (0.00%) | 0/20 (0.00%) |
| tower64 | 2 | 60.062 | 118.985 | 562.132 | 682.257 | 10/20 (50.00%) | 10/20 (50.00%) | 10/20 (50.00%) |

At the initially declared max(0.05ms,1%) effect target, the unpaired pilot variance estimate calls for more than100 independent pairs in several city cases. Adjacent pairing may reduce that variance, but it must be measured. More repetitions alone cannot repair changing interference or incomplete state restoration. The tall frame has lower timing CV than the small/idle cases despite far higher cost. This argues for per-case uncertainty, not one fixed repetition count or a pooled mean.

No additional optimization was accepted. N13 remains incumbent; N14 remains unaccepted. The next priority is a native export/restore feature and untouched-versus-restored continuation tests, then single-tick A/A and A/B measurements on these frozen semantic cases.
