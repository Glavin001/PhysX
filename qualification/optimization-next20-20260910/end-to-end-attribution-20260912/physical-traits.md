# Observed physical traits

These are accepted **post-tick** outputs already recorded by the baseline. Cluster counts do not measure solver work. Identical bond-health arrays do not certify identical operators. All raw array hashes are preserved in the structured file.

| Scenario | Full step mean / peak ms | Clusters / largest chunk count | Singleton / 2–16 / 17–256 / 257–1024 / >1024 clusters | Active / partially damaged bonds | Distinct building health patterns |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 8.753 / 10.257 | 1 / 768 | 0 / 0 / 0 / 1 / 0 | 1524 / 0 | — |
| bridge64-warm | 8.822 / 11.872 | 1 / 768 | 0 / 0 / 0 / 1 / 0 | 1524 / 0 | — |
| building-cold | 4.835 / 8.352 | 1 / 444 | 0 / 0 / 0 / 1 / 0 | 896 / 0 | — |
| building-fragmented | 8.887 / 15.415 | 378 / 64 | 374 / 3 / 1 / 0 / 0 | 115 / 3 | — |
| building-warm | 4.818 / 7.386 | 1 / 444 | 0 / 0 / 0 / 1 / 0 | 896 / 0 | — |
| cantilever64-cold | 7.694 / 11.224 | 1 / 64 | 0 / 0 / 1 / 0 / 0 | 63 / 0 | — |
| cantilever64-warm | 6.954 / 8.594 | 1 / 64 | 0 / 0 / 1 / 0 / 0 | 63 / 0 | — |
| chain256-cold | 7.234 / 8.594 | 1 / 256 | 0 / 0 / 1 / 0 / 0 | 255 / 0 | — |
| chain256-warm | 7.325 / 9.971 | 1 / 256 | 0 / 0 / 1 / 0 / 0 | 255 / 0 | — |
| chain32-cold | 2.841 / 6.643 | 1 / 32 | 0 / 0 / 1 / 0 / 0 | 31 / 0 | — |
| chain32-warm | 2.646 / 5.140 | 1 / 32 | 0 / 0 / 1 / 0 / 0 | 31 / 0 | — |
| dense12-cold | 33.748 / 36.679 | 1 / 1728 | 0 / 0 / 0 / 0 / 1 | 4752 / 0 | — |
| dense12-warm | 33.302 / 36.078 | 1 / 1728 | 0 / 0 / 0 / 0 / 1 | 4752 / 0 | — |
| destruction-cold | 2.567 / 6.115 | 1 / 2 | 0 / 1 / 0 / 0 / 0 | 1 / 0 | — |
| destruction-damaged | 3.228 / 7.648 | 1 / 2 | 0 / 1 / 0 / 0 / 0 | 1 / 1 | — |
| destruction-fractured | 4.329 / 7.641 | 2 / 1 | 2 / 0 / 0 / 0 / 0 | 0 / 0 | — |
| destruction-intact | 2.595 / 7.536 | 1 / 2 | 0 / 1 / 0 / 0 / 0 | 1 / 0 | — |
| destruction-onset | 3.768 / 8.894 | 1 / 2 | 0 / 1 / 0 / 0 / 0 | 1 / 0 | — |
| destruction-stimulus | 4.105 / 8.249 | 1 / 2 | 0 / 1 / 0 / 0 / 0 | 1 / 0 | — |
| flying | 1.706 / 2.321 | no destruction observation | 0 / 0 / 0 / 0 / 0 | — / — | — |
| ladder128-cold | 5.576 / 6.952 | 1 / 288 | 0 / 0 / 0 / 1 / 0 | 318 / 0 | — |
| ladder128-warm | 5.592 / 7.505 | 1 / 288 | 0 / 0 / 0 / 1 / 0 | 318 / 0 | — |
| panel32-cold | 22.249 / 25.250 | 1 / 1024 | 0 / 0 / 0 / 1 / 0 | 1984 / 0 | — |
| panel32-warm | 22.338 / 24.648 | 1 / 1024 | 0 / 0 / 0 / 1 / 0 | 1984 / 0 | — |
| resting | 1.634 / 2.588 | no destruction observation | 0 / 0 / 0 / 0 / 0 | — / — | — |
| sliding | 2.662 / 3.717 | no destruction observation | 0 / 0 / 0 / 0 / 0 | — / — | — |
| tower64-cold | 117.766 / 120.598 | 1 / 2368 | 0 / 0 / 0 / 0 / 1 | 4900 / 0 | — |
| tower64-warm | 117.626 / 119.558 | 1 / 2368 | 0 / 0 / 0 / 0 / 1 | 4900 / 0 | — |
| city25-intact-idle | 9.601 / 15.944 | 25 / 444 | 0 / 0 / 0 / 25 / 0 | 22400 / 0 | 1 |
| city25-airborne | 10.871 / 14.362 | 25 / 444 | 0 / 0 / 0 / 25 / 0 | 22400 / 0 | 1 |
| city25-initial-impact | 40.812 / 52.200 | 537 / 420 | 460 / 52 / 0 / 25 / 0 | 18988 / 5029 | 15 |
| city25-post-impact | 24.484 / 30.557 | 526 / 423 | 473 / 28 / 0 / 25 / 0 | 19576 / 4692 | 15 |
| city25-cascading-fracture | 39.495 / 48.003 | 610 / 423 | 546 / 39 / 0 / 25 / 0 | 19276 / 4735 | 25 |
| city25-fragmented-loaded | 52.834 / 65.842 | 1321 / 408 | 1152 / 144 / 0 / 25 / 0 | 16445 / 3974 | 25 |
| city25-late-debris | 69.946 / 86.042 | 2063 / 408 | 1754 / 276 / 13 / 20 / 0 | 14625 / 3424 | 25 |
| city25-ten-second-debris | 70.265 / 88.090 | 1776 / 408 | 1493 / 254 / 6 / 23 / 0 | 15356 / 3622 | 25 |
| city64-intact-idle | 16.898 / 25.849 | 64 / 444 | 0 / 0 / 0 / 64 / 0 | 57344 / 0 | 1 |
| city64-airborne | 18.495 / 22.528 | 64 / 444 | 0 / 0 / 0 / 64 / 0 | 57344 / 0 | 1 |
| city64-initial-impact | 64.630 / 83.817 | 1364 / 420 | 1168 / 132 / 0 / 64 / 0 | 48584 / 12832 | 25 |
| city64-post-impact | 35.363 / 41.564 | 1320 / 423 | 1188 / 68 / 0 / 64 / 0 | 50097 / 11947 | 25 |
| city64-cascading-fracture | 56.874 / 68.731 | 1473 / 423 | 1320 / 89 / 0 / 64 / 0 | 49434 / 12118 | 48 |
| city64-fragmented-loaded | 90.634 / 117.658 | 3144 / 408 | 2663 / 411 / 6 / 64 / 0 | 42575 / 10285 | 64 |
| city64-late-debris | 132.341 / 166.994 | 5130 / 407 | 4365 / 678 / 34 / 53 / 0 | 38080 / 8724 | 64 |
| city64-ten-second-debris | 99.766 / 139.785 | 4705 / 408 | 3885 / 744 / 20 / 56 / 0 | 39038 / 9105 | 64 |
| city256-intact-idle | 59.200 / 73.979 | 256 / 444 | 0 / 0 / 0 / 256 / 0 | 229376 / 0 | 1 |
| city256-airborne | 66.190 / 83.926 | 256 / 444 | 0 / 0 / 0 / 256 / 0 | 229376 / 0 | 1 |
| city256-initial-impact | 236.880 / 254.511 | 5417 / 420 | 4641 / 520 / 0 / 256 / 0 | 194574 / 51390 | 59 |
| city256-post-impact | 139.608 / 166.765 | 5204 / 423 | 4684 / 264 / 0 / 256 / 0 | 200780 / 47932 | 62 |
| city256-cascading-fracture | 190.403 / 218.459 | 5852 / 423 | 5225 / 371 / 0 / 256 / 0 | 198288 / 49359 | 125 |
| city256-fragmented-loaded | 283.125 / 311.861 | 11382 / 417 | 9525 / 1584 / 17 / 256 / 0 | 175107 / 43665 | 256 |
| city256-late-debris | 394.491 / 458.203 | 16135 / 411 | 13395 / 2444 / 53 / 243 / 0 | 162328 / 39871 | 256 |
| city256-ten-second-debris | 264.837 / 350.839 | 15187 / 408 | 12154 / 2751 / 36 / 246 / 0 | 165891 / 41056 | 256 |

[Structured traits and array provenance](physical-traits.json). Sizes include chunks excluded from the dynamic stress unknowns; they are not equivalent to solver component sizes. Use a current weighted work census before choosing size-based solver changes.
