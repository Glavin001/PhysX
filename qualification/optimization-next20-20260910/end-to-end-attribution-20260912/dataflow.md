# Current transfer exposure

The dependency order is correct. Contacts and stress inputs already stay on GPU. Fragment collision registration must finish before corrected physics; ordinary activity/sleep processing consumes trial body mirrors before final acceptance. The first structural opportunity remains batching fragment lifecycle work. Changed-state export is a separate, smaller hypothesis.

The tables exclude restore, validation and observation exports. Copy-only time means no overlapping **kernel**, not idle CPU or removable critical-path time. These are diagnostic traces; only the separately identified unprofiled full-step columns are application measurements. Transfer sums must not be added to full-step times.

| Snapshot | Unprofiled full step mean / peak ms (20) | H2D / D2H / D2D MB | Copy union / overlap with kernels / without kernels ms |
|---|---:|---:|---:|
| bridge64-cold | 8.753 / 10.257 | 0.145 / 0.001 / 0.026 | 0.032 / 0.000 / 0.032 |
| bridge64-warm | 8.822 / 11.872 | 0.145 / 0.001 / 0.026 | 0.037 / 0.000 / 0.037 |
| building-cold | 4.835 / 8.352 | 0.081 / 0.001 / 0.019 | 0.026 / 0.000 / 0.026 |
| building-fragmented | 8.887 / 15.415 | 0.439 / 0.418 / 0.278 | 0.136 / 0.000 / 0.136 |
| building-warm | 4.818 / 7.386 | 0.081 / 0.001 / 0.019 | 0.023 / 0.000 / 0.023 |
| cantilever64-cold | 7.694 / 11.224 | 0.017 / 0.001 / 0.002 | 0.011 / 0.000 / 0.011 |
| cantilever64-warm | 6.954 / 8.594 | 0.017 / 0.001 / 0.002 | 0.013 / 0.000 / 0.013 |
| chain256-cold | 7.234 / 8.594 | 0.058 / 0.001 / 0.016 | 0.016 / 0.000 / 0.016 |
| chain256-warm | 7.325 / 9.971 | 0.058 / 0.001 / 0.016 | 0.016 / 0.000 / 0.016 |
| chain32-cold | 2.841 / 6.643 | 0.010 / 0.001 / 0.001 | 0.025 / 0.000 / 0.025 |
| chain32-warm | 2.646 / 5.140 | 0.010 / 0.001 / 0.001 | 0.011 / 0.000 / 0.011 |
| dense12-cold | 33.748 / 36.679 | 0.309 / 0.001 / 0.045 | 0.060 / 0.000 / 0.060 |
| dense12-warm | 33.302 / 36.078 | 0.309 / 0.001 / 0.045 | 0.059 / 0.000 / 0.059 |
| destruction-cold | 2.567 / 6.115 | 0.003 / 0.001 / 0.000 | 0.011 / 0.000 / 0.011 |
| destruction-damaged | 3.228 / 7.648 | 0.003 / 0.001 / 0.000 | 0.012 / 0.000 / 0.012 |
| destruction-fractured | 4.329 / 7.641 | 0.030 / 0.003 / 0.001 | 0.035 / 0.000 / 0.035 |
| destruction-intact | 2.595 / 7.536 | 0.003 / 0.001 / 0.000 | 0.011 / 0.000 / 0.011 |
| destruction-onset | 3.768 / 8.894 | 0.007 / 0.002 / 0.001 | 0.019 / 0.000 / 0.019 |
| destruction-stimulus | 4.105 / 8.249 | 0.007 / 0.002 / 0.001 | 0.024 / 0.000 / 0.024 |
| flying | 1.706 / 2.321 | 0.006 / 0.002 / 0.000 | 0.014 / 0.000 / 0.014 |
| ladder128-cold | 5.576 / 6.952 | 0.062 / 0.001 / 0.016 | 0.020 / 0.000 / 0.020 |
| ladder128-warm | 5.592 / 7.505 | 0.062 / 0.001 / 0.016 | 0.018 / 0.000 / 0.018 |
| panel32-cold | 22.249 / 25.250 | 0.225 / 0.001 / 0.031 | 0.048 / 0.000 / 0.048 |
| panel32-warm | 22.338 / 24.648 | 0.225 / 0.001 / 0.031 | 0.051 / 0.000 / 0.051 |
| resting | 1.634 / 2.588 | 0.003 / 0.001 / 0.000 | 0.005 / 0.000 / 0.005 |
| sliding | 2.662 / 3.717 | 0.028 / 0.002 / 0.000 | 0.027 / 0.000 / 0.027 |
| tower64-cold | 117.766 / 120.598 | 0.485 / 0.001 / 0.058 | 0.083 / 0.000 / 0.083 |
| tower64-warm | 117.626 / 119.558 | 0.485 / 0.001 / 0.058 | 0.083 / 0.000 / 0.083 |
| city25-intact-idle | 9.601 / 15.944 | 2.134 / 0.001 / 0.239 | 0.334 / 0.000 / 0.334 |
| city25-airborne | 10.871 / 14.362 | 2.149 / 0.844 / 0.246 | 0.454 / 0.000 / 0.454 |
| city25-initial-impact | 40.812 / 52.200 | 2.753 / 2.600 / 1.287 | 0.839 / 0.000 / 0.839 |
| city25-post-impact | 24.484 / 30.557 | 2.756 / 1.424 / 0.673 | 0.647 / 0.000 / 0.647 |
| city25-cascading-fracture | 39.495 / 48.003 | 3.013 / 2.851 / 2.395 | 0.906 / 0.000 / 0.906 |
| city25-fragmented-loaded | 52.834 / 65.842 | 4.137 / 4.344 / 5.128 | 1.325 / 0.000 / 1.325 |
| city25-late-debris | 69.946 / 86.042 | 4.822 / 5.216 / 6.205 | 1.552 / 0.001 / 1.551 |
| city25-ten-second-debris | 70.265 / 88.090 | 3.191 / 2.535 / 3.800 | 0.904 / 0.000 / 0.903 |
| city64-intact-idle | 16.898 / 25.849 | 5.017 / 0.001 / 0.595 | 0.745 / 0.000 / 0.745 |
| city64-airborne | 18.495 / 22.528 | 5.050 / 1.937 / 0.615 | 1.027 / 0.000 / 1.027 |
| city64-initial-impact | 64.630 / 83.817 | 6.542 / 6.252 / 3.287 | 1.891 / 0.003 / 1.888 |
| city64-post-impact | 35.363 / 41.564 | 6.590 / 3.477 / 1.715 | 1.472 / 0.000 / 1.472 |
| city64-cascading-fracture | 56.874 / 68.731 | 7.123 / 6.669 / 5.926 | 2.054 / 0.001 / 2.053 |
| city64-fragmented-loaded | 90.634 / 117.658 | 10.311 / 10.632 / 12.655 | 3.110 / 0.008 / 3.103 |
| city64-late-debris | 132.341 / 166.994 | 12.086 / 13.278 / 16.344 | 3.799 / 0.013 / 3.786 |
| city64-ten-second-debris | 99.766 / 139.785 | 7.796 / 6.045 / 10.042 | 2.122 / 0.000 / 2.122 |
| city256-intact-idle | 59.200 / 73.979 | 20.060 / 0.001 / 2.349 | 2.937 / 0.000 / 2.937 |
| city256-airborne | 66.190 / 83.926 | 20.183 / 7.741 / 2.428 | 4.041 / 0.000 / 4.041 |
| city256-initial-impact | 236.880 / 254.511 | 26.106 / 24.951 / 13.153 | 7.364 / 0.023 / 7.341 |
| city256-post-impact | 139.608 / 166.765 | 26.246 / 13.842 / 6.812 | 5.784 / 0.007 / 5.777 |
| city256-cascading-fracture | 190.403 / 218.459 | 28.325 / 26.488 / 23.197 | 7.995 / 0.022 / 7.973 |
| city256-fragmented-loaded | 283.125 / 311.861 | 39.314 / 39.245 / 46.095 | 11.519 / 0.037 / 11.482 |
| city256-late-debris | 394.491 / 458.203 | 42.359 / 43.208 / 50.701 | 12.522 / 0.095 / 12.428 |
| city256-ten-second-debris | 264.837 / 350.839 | 27.672 / 19.646 / 31.238 | 6.945 / 0.010 / 6.935 |

## Continuous trace checkpoints

Each workload has180 ordinary/sleeping ticks and113,664 chunks /229,376 bonds. Heavy uses256 projectiles. Steps0/81/82/179 cover initialization, pre-impact, first fracture and later debris; each traced full-step peak is included too. [Unprofiled continuous mean/peak, stages and deadline counts](coverage-tiers.md) are separate.

| Workload / step | Profiled full step ms | H2D / D2H / D2D MB | Copy union / overlap with kernels / without kernels ms |
|---|---:|---:|---:|
| idle-256 / 0 (trace peak) | 26.893 | 0.002 / 0.001 / 2.339 | 0.015 / 0.000 / 0.015 |
| idle-256 / 81 | 6.889 | 0.002 / 0.001 / 0.066 | 0.004 / 0.000 / 0.004 |
| idle-256 / 82 | 7.095 | 0.002 / 0.001 / 0.066 | 0.005 / 0.000 / 0.005 |
| idle-256 / 179 | 8.725 | 0.002 / 0.001 / 0.066 | 0.004 / 0.000 / 0.004 |
| impacts-256 / 0 | 101.049 | 10.578 / 7.742 / 35.219 | 3.007 / 0.000 / 3.007 |
| impacts-256 / 81 | 9.384 | 0.027 / 7.741 / 0.139 | 1.106 / 0.000 / 1.106 |
| impacts-256 / 82 (trace peak) | 223.856 | 5.714 / 24.516 / 10.581 | 4.321 / 0.013 / 4.308 |
| impacts-256 / 179 | 149.120 | 10.297 / 35.386 / 27.641 | 6.674 / 0.081 / 6.593 |

[Structured transfer directions and launch-scope attribution](dataflow.json). Every raw transfer, CUDA caller, stream and available engine scope remains in the corresponding `attribution.json`/Systems database. Missing scope attribution is explicit. No transfer removal or application speedup is established by this census.
