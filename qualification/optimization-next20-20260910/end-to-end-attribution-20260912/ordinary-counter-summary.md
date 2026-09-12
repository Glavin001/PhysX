# Ordinary-kernel counter guide

Ranked by matched Systems kernel duration, not replay duration. Each case includes its three largest ordinary families; the structured file contains every selected family. Register/occupancy ranges describe captured representatives across configurations and invocations. They are not weighted averages or speedup predictions. Graph work is reported separately.

| Scenario | Unprofiled complete step mean / peak ms | Largest ordinary families: timeline aggregate ms |
|---|---:|---|
| bridge64-cold | 8.753 / 10.257 | radixSortMultiCalculateRanksLaunchWithCount: 0.101; radixSortMultiBlockLaunchWithCount: 0.078; MemCopyBalanced: 0.016 |
| bridge64-warm | 8.822 / 11.872 | radixSortMultiCalculateRanksLaunchWithCount: 0.101; radixSortMultiBlockLaunchWithCount: 0.078; MemCopyBalanced: 0.016 |
| building-cold | 4.835 / 8.352 | radixSortMultiCalculateRanksLaunchWithCount: 0.100; radixSortMultiBlockLaunchWithCount: 0.078; MemCopyBalanced: 0.012 |
| building-fragmented | 8.887 / 15.415 | solveWholeIslandTGS: 0.154; radixSortMultiCalculateRanksLaunchWithCount: 0.100; solveStaticBlockTGS: 0.090 |
| building-warm | 4.818 / 7.386 | radixSortMultiCalculateRanksLaunchWithCount: 0.100; radixSortMultiBlockLaunchWithCount: 0.078; MemCopyBalanced: 0.011 |
| cantilever64-cold | 7.694 / 11.224 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; nativePairSortTiles: 0.009 |
| cantilever64-warm | 6.954 / 8.594 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; nativePairSortTiles: 0.009 |
| chain256-cold | 7.234 / 8.594 | radixSortMultiCalculateRanksLaunchWithCount: 0.100; radixSortMultiBlockLaunchWithCount: 0.078; nativePairSortTiles: 0.009 |
| chain256-warm | 7.325 / 9.971 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; MemCopyBalanced: 0.009 |
| chain32-cold | 2.841 / 6.643 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; nativePairSortTiles: 0.009 |
| chain32-warm | 2.646 / 5.140 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; nativePairSortTiles: 0.009 |
| dense12-cold | 33.748 / 36.679 | radixSortMultiCalculateRanksLaunchWithCount: 0.105 |
| dense12-warm | 33.302 / 36.078 | radixSortMultiCalculateRanksLaunchWithCount: 0.105 |
| destruction-cold | 2.567 / 6.115 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; nativePairSortTiles: 0.009 |
| destruction-damaged | 3.228 / 7.648 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; nativePairSortTiles: 0.009 |
| destruction-fractured | 4.329 / 7.641 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; solveWholeIslandTGS: 0.015 |
| destruction-intact | 2.595 / 7.536 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; nativePairSortTiles: 0.009 |
| destruction-onset | 3.768 / 8.894 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; propagateAverageSolverBodyVelocityTGS: 0.010 |
| destruction-stimulus | 4.105 / 8.249 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; propagateAverageSolverBodyVelocityTGS: 0.010 |
| flying | 1.706 / 2.321 | radixSortMultiCalculateRanksLaunchWithCount: 0.057; radixSortMultiBlockLaunchWithCount: 0.045; propagateAverageSolverBodyVelocityTGS: 0.010 |
| ladder128-cold | 5.576 / 6.952 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; MemCopyBalanced: 0.010 |
| ladder128-warm | 5.592 / 7.505 | radixSortMultiCalculateRanksLaunchWithCount: 0.099; radixSortMultiBlockLaunchWithCount: 0.078; MemCopyBalanced: 0.010 |
| panel32-cold | 22.249 / 25.250 | radixSortMultiCalculateRanksLaunchWithCount: 0.102; radixSortMultiBlockLaunchWithCount: 0.078 |
| panel32-warm | 22.338 / 24.648 | radixSortMultiCalculateRanksLaunchWithCount: 0.102; radixSortMultiBlockLaunchWithCount: 0.078 |
| resting | 1.634 / 2.588 | radixSortMultiCalculateRanksLaunchWithCount: 0.056; radixSortMultiBlockLaunchWithCount: 0.045; MemCopyBalanced: 0.003 |
| sliding | 2.662 / 3.717 | radixSortMultiCalculateRanksLaunchWithCount: 0.056; radixSortMultiBlockLaunchWithCount: 0.045; solveStaticBlockTGS: 0.018 |
| tower64-cold | 117.766 / 120.598 | radixSortMultiCalculateRanksLaunchWithCount: 0.108 |
| tower64-warm | 117.626 / 119.558 | radixSortMultiCalculateRanksLaunchWithCount: 0.108 |
| city25-intact-idle | 9.601 / 15.944 | MemCopyBalanced: 0.214; radixSortMultiCalculateRanksLaunchWithCount: 0.123; generateFoundPairsForNewBoundsRegion: 0.086 |
| city25-airborne | 10.871 / 14.362 | MemCopyBalanced: 0.242; radixSortMultiCalculateRanksLaunchWithCount: 0.123; radixSortMultiBlockLaunchWithCount: 0.086 |
| city25-initial-impact | 40.812 / 52.200 | radixSortMultiCalculateRanksLaunchWithCount: 0.246; MemCopyBalanced: 0.241; solveStaticBlockTGS: 0.178 |
| city25-post-impact | 24.484 / 30.557 | MemCopyBalanced: 0.242; solveStaticBlockTGS: 0.187; solveWholeIslandTGS: 0.142 |
| city25-cascading-fracture | 39.495 / 48.003 | running |
| city25-fragmented-loaded | 52.834 / 65.842 | not_captured |
| city25-late-debris | 69.946 / 86.042 | not_captured |
| city25-ten-second-debris | 70.265 / 88.090 | not_captured |
| city64-intact-idle | 16.898 / 25.849 | not_captured |
| city64-airborne | 18.495 / 22.528 | not_captured |
| city64-initial-impact | 64.630 / 83.817 | not_captured |
| city64-post-impact | 35.363 / 41.564 | not_captured |
| city64-cascading-fracture | 56.874 / 68.731 | not_captured |
| city64-fragmented-loaded | 90.634 / 117.658 | not_captured |
| city64-late-debris | 132.341 / 166.994 | not_captured |
| city64-ten-second-debris | 99.766 / 139.785 | not_captured |
| city256-intact-idle | 59.200 / 73.979 | not_captured |
| city256-airborne | 66.190 / 83.926 | not_captured |
| city256-initial-impact | 236.880 / 254.511 | not_captured |
| city256-post-impact | 139.608 / 166.765 | not_captured |
| city256-cascading-fracture | 190.403 / 218.459 | not_captured |
| city256-fragmented-loaded | 283.125 / 311.861 | not_captured |
| city256-late-debris | 394.491 / 458.203 | not_captured |
| city256-ten-second-debris | 264.837 / 350.839 | not_captured |

[Every selected family, configuration count and counter range](ordinary-counter-summary.json). [Graph-tier coverage and limitations](coverage-tiers.md).
