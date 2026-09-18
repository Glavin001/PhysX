# Scenario hardware-counter atlas

Unprofiled tick baseline is separate from diagnostic instrumented timeline/counter launches. NCU replays kernels with cache flushing, clocks unlocked; shared graphics/server contexts remain. No optimization gain established.

All rows include Systems GPU kernels, memory transfers, CUDA API calls and disjoint full-tick host ranges. Non-replaying PM hardware counters cover the complete tick and sufficiently long kernel interiors. Detailed NCU data supplements cases where profiling completed correctly. Failed NCU captures are excluded. Two independent restores verify each capture; only the first tick is analyzed. The process trace drains at normal exit; all four declared tick ranges must be present and closed. CUDA event-completeness warnings reject the capture; generic NVTX warnings are retained in JSON.

| Scenario | Unprofiled tick mean / peak ms | Traced GPU active ms | Kernel / copy calls | Copy bytes | Dominant kernel |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.753 / 10.257 | 5.541 | 161 / 40 | 171,692 | Nv::Blast::<unnamed>::componentStressSolve |
| bridge64-warm | 8.822 / 11.872 | 5.579 | 156 / 40 | 171,692 | Nv::Blast::<unnamed>::componentStressSolve |
| building-cold | 4.835 / 8.352 | 1.843 | 161 / 40 | 101,540 | Nv::Blast::<unnamed>::componentStressSolve |
| building-fragmented | 8.887 / 15.415 | 1.198 | 242 / 118 | 1,135,268 | Nv::Blast::<unnamed>::componentStressSolve |
| building-warm | 4.818 / 7.386 | 1.847 | 156 / 40 | 101,540 | Nv::Blast::<unnamed>::componentStressSolve |
| cantilever64-cold | 7.694 / 11.224 | 4.813 | 161 / 34 | 19,484 | Nv::Blast::<unnamed>::componentStressSolve |
| cantilever64-warm | 6.954 / 8.594 | 4.813 | 156 / 34 | 19,484 | Nv::Blast::<unnamed>::componentStressSolve |
| chain256-cold | 7.234 / 8.594 | 4.509 | 161 / 40 | 75,180 | Nv::Blast::<unnamed>::componentStressSolve |
| chain256-warm | 7.325 / 9.971 | 4.646 | 156 / 40 | 75,180 | Nv::Blast::<unnamed>::componentStressSolve |
| chain32-cold | 2.841 / 6.643 | 0.498 | 161 / 34 | 11,908 | Nv::Blast::<unnamed>::componentStressSolve |
| chain32-warm | 2.646 / 5.140 | 0.494 | 156 / 34 | 11,908 | Nv::Blast::<unnamed>::componentStressSolve |
| dense12-cold | 33.748 / 36.679 | 29.173 | 161 / 40 | 355,740 | void Nv::Blast::<unnamed>::persistentStressSolve< |
| dense12-warm | 33.302 / 36.078 | 29.778 | 156 / 40 | 355,740 | void Nv::Blast::<unnamed>::persistentStressSolve< |
| destruction-cold | 2.567 / 6.115 | 0.355 | 161 / 34 | 4,812 | radixSortMultiCalculateRanksLaunchWithCount |
| destruction-damaged | 3.228 / 7.648 | 0.349 | 156 / 34 | 4,812 | radixSortMultiCalculateRanksLaunchWithCount |
| destruction-fractured | 4.329 / 7.641 | 0.452 | 209 / 93 | 33,380 | radixSortMultiCalculateRanksLaunchWithCount |
| destruction-intact | 2.595 / 7.536 | 0.351 | 156 / 34 | 4,812 | radixSortMultiCalculateRanksLaunchWithCount |
| destruction-onset | 3.768 / 8.894 | 0.398 | 186 / 58 | 9,496 | radixSortMultiCalculateRanksLaunchWithCount |
| destruction-stimulus | 4.105 / 8.249 | 0.401 | 188 / 59 | 9,560 | radixSortMultiCalculateRanksLaunchWithCount |
| flying | 1.706 / 2.321 | 0.196 | 72 / 43 | 7,392 | radixSortMultiCalculateRanksLaunchWithCount |
| ladder128-cold | 5.576 / 6.952 | 2.801 | 161 / 40 | 79,668 | Nv::Blast::<unnamed>::componentStressSolve |
| ladder128-warm | 5.592 / 7.505 | 2.785 | 156 / 40 | 79,668 | Nv::Blast::<unnamed>::componentStressSolve |
| panel32-cold | 22.249 / 25.250 | 18.751 | 161 / 40 | 257,004 | Nv::Blast::<unnamed>::componentStressSolve |
| panel32-warm | 22.338 / 24.648 | 19.303 | 156 / 40 | 257,004 | Nv::Blast::<unnamed>::componentStressSolve |
| resting | 1.634 / 2.588 | 0.148 | 43 / 20 | 3,756 | radixSortMultiCalculateRanksLaunchWithCount |
| sliding | 2.662 / 3.717 | 0.260 | 93 / 72 | 30,684 | radixSortMultiCalculateRanksLaunchWithCount |
| tower64-cold | 117.766 / 120.598 | 115.955 | 161 / 40 | 544,316 | void Nv::Blast::<unnamed>::persistentStressSolve< |
| tower64-warm | 117.626 / 119.558 | 114.350 | 156 / 40 | 544,316 | void Nv::Blast::<unnamed>::persistentStressSolve< |
| city25-intact-idle | 9.601 / 15.944 | 3.384 | 157 / 40 | 2,374,156 | Nv::Blast::<unnamed>::componentStressSolve |
| city25-airborne | 10.871 / 14.362 | 3.612 | 189 / 67 | 3,238,844 | Nv::Blast::<unnamed>::componentStressSolve |
| city25-initial-impact | 40.812 / 52.200 | 15.251 | 756 / 240 | 6,640,640 | Nv::Blast::<unnamed>::componentStressSolve |
| city25-post-impact | 24.484 / 30.557 | 8.896 | 248 / 122 | 4,853,000 | Nv::Blast::<unnamed>::componentStressSolve |
| city25-cascading-fracture | 39.495 / 48.003 | 17.492 | 702 / 263 | 8,259,216 | Nv::Blast::<unnamed>::componentStressSolve |
| city25-fragmented-loaded | 52.834 / 65.842 | 24.794 | 830 / 289 | 13,608,400 | Nv::Blast::<unnamed>::componentStressSolve |
| city25-late-debris | 69.946 / 86.042 | 26.103 | 849 / 325 | 16,242,560 | Nv::Blast::<unnamed>::componentStressSolve |
| city25-ten-second-debris | 70.265 / 88.090 | 34.589 | 840 / 320 | 9,526,272 | Nv::Blast::<unnamed>::componentStressSolve |
| city64-intact-idle | 16.898 / 25.849 | 4.971 | 159 / 40 | 5,613,228 | Nv::Blast::<unnamed>::componentStressSolve |
| city64-airborne | 18.495 / 22.528 | 5.071 | 191 / 67 | 7,601,208 | Nv::Blast::<unnamed>::componentStressSolve |
| city64-initial-impact | 64.630 / 83.817 | 20.583 | 760 / 240 | 16,082,260 | Nv::Blast::<unnamed>::componentStressSolve |
| city64-post-impact | 35.363 / 41.564 | 12.103 | 278 / 122 | 11,781,252 | Nv::Blast::<unnamed>::componentStressSolve |
| city64-cascading-fracture | 56.874 / 68.731 | 23.829 | 706 / 263 | 19,718,412 | Nv::Blast::<unnamed>::componentStressSolve |
| city64-fragmented-loaded | 90.634 / 117.658 | 35.314 | 852 / 291 | 33,597,744 | Nv::Blast::<unnamed>::componentStressSolve |
| city64-late-debris | 132.341 / 166.994 | 40.697 | 871 / 326 | 41,708,404 | Nv::Blast::<unnamed>::componentStressSolve |
| city64-ten-second-debris | 99.766 / 139.785 | 40.856 | 874 / 341 | 23,882,536 | Nv::Blast::<unnamed>::componentStressSolve |
| city256-intact-idle | 59.200 / 73.979 | 18.753 | 160 / 40 | 22,410,732 | Nv::Blast::<unnamed>::componentStressSolve |
| city256-airborne | 66.190 / 83.926 | 19.769 | 192 / 67 | 30,352,224 | Nv::Blast::<unnamed>::componentStressSolve |
| city256-initial-impact | 236.880 / 254.511 | 89.257 | 780 / 240 | 64,210,324 | Nv::Blast::<unnamed>::componentStressSolve |
| city256-post-impact | 139.608 / 166.765 | 41.445 | 279 / 122 | 46,899,348 | Nv::Blast::<unnamed>::componentStressSolve |
| city256-cascading-fracture | 190.403 / 218.459 | 83.660 | 726 / 263 | 78,009,744 | Nv::Blast::<unnamed>::componentStressSolve |
| city256-fragmented-loaded | 283.125 / 311.861 | 117.382 | 861 / 296 | 124,653,744 | Nv::Blast::<unnamed>::componentStressSolve |
| city256-late-debris | 394.491 / 458.203 | 124.759 | 884 / 347 | 136,267,596 | Nv::Blast::<unnamed>::componentStressSolve |
| city256-ten-second-debris | 264.837 / 350.839 | 93.836 | 873 / 334 | 78,555,972 | Nv::Blast::<unnamed>::componentStressSolve |

## Unprofiled full-step stages

These baseline means partition the full tick; simulate/fetch includes integrated physics, stress and any correction. They are not profiler durations. Restore/validation are excluded.

| Scenario | Commands ms | Simulate/fetch ms | Completion ms | 60 Hz misses | 120 Hz misses |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 0.000 | 8.559 | 0.194 | 0/20 | 18/20 |
| bridge64-warm | 0.000 | 8.623 | 0.199 | 0/20 | 20/20 |
| building-cold | 0.000 | 4.651 | 0.183 | 0/20 | 1/20 |
| building-fragmented | 0.000 | 8.661 | 0.225 | 0/20 | 11/20 |
| building-warm | 0.000 | 4.644 | 0.173 | 0/20 | 0/20 |
| cantilever64-cold | 0.000 | 7.484 | 0.210 | 0/20 | 2/20 |
| cantilever64-warm | 0.000 | 6.758 | 0.196 | 0/20 | 1/20 |
| chain256-cold | 0.000 | 7.096 | 0.137 | 0/20 | 1/20 |
| chain256-warm | 0.000 | 7.100 | 0.225 | 0/20 | 1/20 |
| chain32-cold | 0.000 | 2.649 | 0.192 | 0/20 | 0/20 |
| chain32-warm | 0.000 | 2.481 | 0.165 | 0/20 | 0/20 |
| dense12-cold | 0.000 | 33.498 | 0.249 | 20/20 | 20/20 |
| dense12-warm | 0.000 | 33.089 | 0.213 | 20/20 | 20/20 |
| destruction-cold | 0.000 | 2.379 | 0.187 | 0/20 | 0/20 |
| destruction-damaged | 0.000 | 2.983 | 0.245 | 0/20 | 0/20 |
| destruction-fractured | 0.000 | 4.112 | 0.217 | 0/20 | 0/20 |
| destruction-intact | 0.000 | 2.362 | 0.233 | 0/20 | 0/20 |
| destruction-onset | 0.000 | 3.577 | 0.191 | 0/20 | 1/20 |
| destruction-stimulus | 0.002 | 3.957 | 0.146 | 0/20 | 0/20 |
| flying | 0.000 | 1.706 | 0.000 | 0/20 | 0/20 |
| ladder128-cold | 0.000 | 5.392 | 0.184 | 0/20 | 0/20 |
| ladder128-warm | 0.000 | 5.398 | 0.194 | 0/20 | 0/20 |
| panel32-cold | 0.000 | 22.011 | 0.238 | 20/20 | 20/20 |
| panel32-warm | 0.000 | 22.139 | 0.198 | 20/20 | 20/20 |
| resting | 0.000 | 1.633 | 0.000 | 0/20 | 0/20 |
| sliding | 0.000 | 2.660 | 0.001 | 0/20 | 0/20 |
| tower64-cold | 0.000 | 117.532 | 0.234 | 20/20 | 20/20 |
| tower64-warm | 0.000 | 117.390 | 0.236 | 20/20 | 20/20 |
| city25-intact-idle | 0.000 | 9.375 | 0.226 | 0/20 | 20/20 |
| city25-airborne | 0.000 | 10.655 | 0.217 | 0/20 | 20/20 |
| city25-initial-impact | 0.000 | 40.602 | 0.210 | 20/20 | 20/20 |
| city25-post-impact | 0.000 | 24.277 | 0.207 | 20/20 | 20/20 |
| city25-cascading-fracture | 0.000 | 39.298 | 0.197 | 20/20 | 20/20 |
| city25-fragmented-loaded | 0.000 | 52.592 | 0.242 | 20/20 | 20/20 |
| city25-late-debris | 0.000 | 69.739 | 0.206 | 20/20 | 20/20 |
| city25-ten-second-debris | 0.000 | 70.068 | 0.197 | 20/20 | 20/20 |
| city64-intact-idle | 0.000 | 16.640 | 0.259 | 5/20 | 20/20 |
| city64-airborne | 0.000 | 18.274 | 0.222 | 20/20 | 20/20 |
| city64-initial-impact | 0.000 | 64.404 | 0.225 | 20/20 | 20/20 |
| city64-post-impact | 0.000 | 35.148 | 0.214 | 20/20 | 20/20 |
| city64-cascading-fracture | 0.000 | 56.666 | 0.208 | 20/20 | 20/20 |
| city64-fragmented-loaded | 0.000 | 90.400 | 0.234 | 20/20 | 20/20 |
| city64-late-debris | 0.000 | 132.125 | 0.216 | 20/20 | 20/20 |
| city64-ten-second-debris | 0.000 | 99.559 | 0.207 | 20/20 | 20/20 |
| city256-intact-idle | 0.000 | 58.977 | 0.223 | 20/20 | 20/20 |
| city256-airborne | 0.000 | 65.931 | 0.259 | 20/20 | 20/20 |
| city256-initial-impact | 0.000 | 236.657 | 0.223 | 20/20 | 20/20 |
| city256-post-impact | 0.000 | 139.356 | 0.251 | 20/20 | 20/20 |
| city256-cascading-fracture | 0.000 | 190.145 | 0.258 | 20/20 | 20/20 |
| city256-fragmented-loaded | 0.000 | 282.869 | 0.256 | 20/20 | 20/20 |
| city256-late-debris | 0.000 | 394.227 | 0.263 | 20/20 | 20/20 |
| city256-ten-second-debris | 0.000 | 264.592 | 0.245 | 20/20 | 20/20 |

## Whole-tick hardware sampling

These are device-wide samples inside the traced tick, including CPU gaps and other GPU contexts. Elapsed resident-warps percentage is distinct from NCU active occupancy. Do not attribute all sampled DRAM traffic to this application. Short kernels may lack interior samples; JSON retains coverage and exclusions.

| Scenario | Samples | Interior coverage | Resident warps / elapsed % | Instructions / SM cycle | DRAM GB/s |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 188 | 99.5% | 1.283 | 0.033 | 0.952 |
| bridge64-warm | 184 | 99.2% | 1.002 | 0.026 | 0.313 |
| building-cold | 144 | 99.0% | 1.137 | 0.030 | 0.668 |
| building-fragmented | 242 | 99.7% | 0.701 | 0.019 | 0.631 |
| building-warm | 149 | 99.2% | 1.097 | 0.029 | 0.693 |
| cantilever64-cold | 173 | 99.7% | 1.016 | 0.026 | 0.843 |
| cantilever64-warm | 164 | 99.7% | 1.073 | 0.027 | 0.785 |
| chain256-cold | 134 | 98.8% | 1.317 | 0.034 | 1.001 |
| chain256-warm | 169 | 99.2% | 1.037 | 0.027 | 0.721 |
| chain32-cold | 123 | 98.6% | 1.255 | 0.033 | 0.710 |
| chain32-warm | 122 | 98.9% | 1.276 | 0.034 | 0.926 |
| dense12-cold | 432 | 99.8% | 17.203 | 0.106 | 3.445 |
| dense12-warm | 388 | 99.7% | 18.993 | 0.114 | 3.416 |
| destruction-cold | 125 | 98.9% | 0.774 | 0.021 | 0.148 |
| destruction-damaged | 127 | 98.7% | 1.212 | 0.032 | 0.722 |
| destruction-fractured | 156 | 99.1% | 1.006 | 0.027 | 0.936 |
| destruction-intact | 121 | 99.5% | 1.273 | 0.034 | 0.796 |
| destruction-onset | 139 | 99.3% | 0.712 | 0.019 | 0.301 |
| destruction-stimulus | 122 | 99.4% | 1.272 | 0.034 | 0.780 |
| flying | 54 | 98.5% | 2.151 | 0.057 | 0.837 |
| ladder128-cold | 155 | 99.4% | 1.084 | 0.028 | 0.702 |
| ladder128-warm | 137 | 99.5% | 1.229 | 0.032 | 1.108 |
| panel32-cold | 318 | 99.7% | 0.947 | 0.024 | 0.702 |
| panel32-warm | 329 | 100.0% | 0.920 | 0.023 | 0.705 |
| resting | 48 | 96.9% | 1.223 | 0.032 | 0.615 |
| sliding | 86 | 98.8% | 0.698 | 0.019 | 0.062 |
| tower64-cold | 1259 | 99.9% | 28.588 | 0.151 | 4.840 |
| tower64-warm | 1288 | 100.0% | 27.863 | 0.147 | 4.466 |
| city25-intact-idle | 248 | 99.5% | 2.774 | 0.044 | 1.674 |
| city25-airborne | 238 | 99.7% | 2.774 | 0.040 | 1.791 |
| city25-initial-impact | 842 | 99.9% | 2.927 | 0.049 | 2.570 |
| city25-post-impact | 388 | 99.7% | 2.903 | 0.054 | 1.846 |
| city25-cascading-fracture | 679 | 99.9% | 2.930 | 0.053 | 2.391 |
| city25-fragmented-loaded | 837 | 99.9% | 3.727 | 0.058 | 3.158 |
| city25-late-debris | 1028 | 99.9% | 3.370 | 0.052 | 2.594 |
| city25-ten-second-debris | 1069 | 99.9% | 2.469 | 0.038 | 2.137 |
| city64-intact-idle | 269 | 99.7% | 5.971 | 0.075 | 5.877 |
| city64-airborne | 345 | 99.8% | 4.541 | 0.057 | 4.062 |
| city64-initial-impact | 857 | 99.9% | 7.340 | 0.108 | 5.713 |
| city64-post-impact | 686 | 99.8% | 4.270 | 0.067 | 2.967 |
| city64-cascading-fracture | 957 | 100.0% | 5.580 | 0.089 | 4.879 |
| city64-fragmented-loaded | 1310 | 99.9% | 6.236 | 0.089 | 5.105 |
| city64-late-debris | 1870 | 99.9% | 4.750 | 0.065 | 3.706 |
| city64-ten-second-debris | 1562 | 99.9% | 4.129 | 0.055 | 3.252 |
| city256-intact-idle | 982 | 99.8% | 6.801 | 0.080 | 7.568 |
| city256-airborne | 1077 | 99.8% | 6.175 | 0.072 | 8.201 |
| city256-initial-impact | 3262 | 100.0% | 9.963 | 0.158 | 10.025 |
| city256-post-impact | 2073 | 100.0% | 5.847 | 0.085 | 6.198 |
| city256-cascading-fracture | 2806 | 100.0% | 10.246 | 0.168 | 9.582 |
| city256-fragmented-loaded | 3975 | 100.0% | 9.985 | 0.146 | 9.022 |
| city256-late-debris | 5403 | 100.0% | 7.726 | 0.110 | 6.809 |
| city256-ten-second-debris | 3949 | 100.0% | 7.639 | 0.105 | 7.109 |

## Selected detailed NCU counters

Coverage: 52/52 scenarios, 86 selected launches.

Rows correspond to selected kernel launches, not the entire tick. Occupancy is achieved active warps; eligible warps measure readiness to issue. DRAM rates retain the profiler's explicit units. Stall ratios and cache/local-memory metrics are in JSON and full raw CSV.

| Scenario / launch | Registers | Occupancy % | Eligible warps | Issue active % | FP64 active % | DRAM rate |
|---|---:|---:|---:|---:|---:|---:|
| bridge64-cold / 0 | 109.0 | 16.764 | 0.105 | 9.45 | 1.074 | 99.654 Mbyte/s |
| bridge64-warm / 0 | 109.0 | 16.739 | 0.105 | 9.485 | 1.077 | 101.989 Mbyte/s |
| building-cold / 0 | 109.0 | 16.941 | 0.104 | 9.412 | 0.992 | 402.729 Mbyte/s |
| building-fragmented / 0 | 109.0 | 26.058 | 0.049 | 4.275 | 2.053 | 831.22 Mbyte/s |
| building-warm / 0 | 109.0 | 16.929 | 0.104 | 9.409 | 0.985 | 530.673 Mbyte/s |
| cantilever64-cold / 0 | 109.0 | 16.74 | 0.083 | 7.959 | 0.679 | 33.261 Mbyte/s |
| cantilever64-warm / 0 | 109.0 | 16.743 | 0.083 | 7.962 | 0.68 | 34.711 Mbyte/s |
| chain256-cold / 0 | 109.0 | 16.762 | 0.107 | 9.595 | 1.189 | 55.466 Mbyte/s |
| chain256-warm / 0 | 109.0 | 16.764 | 0.107 | 9.612 | 1.191 | 55.863 Mbyte/s |
| chain32-cold / 0 | 109.0 | 16.656 | 0.056 | 5.293 | 0.441 | 747.005 Mbyte/s |
| chain32-warm / 0 | 109.0 | 16.148 | 0.056 | 5.303 | 0.442 | 748.72 Mbyte/s |
| dense12-cold / 0 | 128.0 | 25.941 | 0.041 | 3.575 | 38.887 | 105.047 Mbyte/s |
| dense12-cold / 1 | 109.0 | 32.775 | 0.114 | 6.437 | 0.0 | 24.094 Gbyte/s |
| dense12-warm / 0 | 128.0 | 25.945 | 0.041 | 3.576 | 38.952 | 106.024 Mbyte/s |
| dense12-warm / 1 | 109.0 | 32.033 | 0.12 | 6.783 | 0.0 | 24.675 Gbyte/s |
| destruction-cold / 0 | 64.0 | 65.32 | 1.138 | 37.141 | 0.0 | 4.063 Gbyte/s |
| destruction-cold / 1 | 64.0 | 68.498 | 1.143 | 37.303 | 0.0 | 3.937 Gbyte/s |
| destruction-cold / 2 | 109.0 | 16.66 | 0.026 | 2.479 | 0.428 | 2.952 Gbyte/s |
| destruction-damaged / 0 | 64.0 | 68.855 | 1.136 | 37.047 | 0.0 | 3.937 Gbyte/s |
| destruction-damaged / 1 | 64.0 | 66.704 | 1.133 | 37.033 | 0.0 | 4.129 Gbyte/s |
| destruction-damaged / 2 | 109.0 | 16.662 | 0.026 | 2.474 | 0.425 | 3.969 Gbyte/s |
| destruction-fractured / 0 | 64.0 | 67.669 | 1.135 | 36.961 | 0.0 | 3.907 Gbyte/s |
| destruction-fractured / 1 | 64.0 | 65.641 | 1.144 | 37.28 | 0.0 | 5.143 Gbyte/s |
| destruction-fractured / 2 | 109.0 | 16.188 | 0.039 | 3.338 | 0.0 | 32.125 Gbyte/s |
| destruction-intact / 0 | 64.0 | 67.192 | 1.144 | 37.256 | 0.0 | 3.875 Gbyte/s |
| destruction-intact / 1 | 64.0 | 66.51 | 1.156 | 37.672 | 0.0 | 4.472 Gbyte/s |
| destruction-intact / 2 | 109.0 | 16.813 | 0.026 | 2.489 | 0.427 | 2.931 Gbyte/s |
| destruction-onset / 0 | 64.0 | 65.516 | 1.13 | 36.804 | 0.0 | 4.065 Gbyte/s |
| destruction-onset / 1 | 64.0 | 66.765 | 1.18 | 38.389 | 0.0 | 4.19 Gbyte/s |
| destruction-onset / 2 | 109.0 | 16.596 | 0.026 | 2.465 | 0.425 | 2.923 Gbyte/s |
| destruction-stimulus / 0 | 64.0 | 64.249 | 1.136 | 37.137 | 0.0 | 4.0 Gbyte/s |
| destruction-stimulus / 1 | 64.0 | 63.296 | 1.072 | 34.983 | 0.0 | 4.063 Gbyte/s |
| destruction-stimulus / 2 | 109.0 | 16.674 | 0.026 | 2.478 | 0.427 | 2.991 Gbyte/s |
| flying / 0 | 64.0 | 65.761 | 1.285 | 42.045 | 0.0 | 2.492 Gbyte/s |
| flying / 1 | 64.0 | 65.721 | 1.283 | 42.073 | 0.0 | 2.471 Gbyte/s |
| ladder128-cold / 0 | 109.0 | 16.755 | 0.093 | 8.247 | 0.929 | 101.682 Mbyte/s |
| ladder128-warm / 0 | 109.0 | 16.656 | 0.093 | 8.239 | 0.928 | 122.594 Mbyte/s |
| panel32-cold / 0 | 109.0 | 16.531 | 0.112 | 9.938 | 1.07 | 68.332 Mbyte/s |
| panel32-warm / 0 | 109.0 | 16.705 | 0.113 | 10.051 | 1.072 | 37.449 Mbyte/s |
| resting / 0 | 64.0 | 66.091 | 1.268 | 41.417 | 0.0 | 2.481 Gbyte/s |
| resting / 1 | 64.0 | 66.391 | 1.281 | 41.947 | 0.0 | 3.023 Gbyte/s |
| sliding / 0 | 64.0 | 65.248 | 1.29 | 42.216 | 0.0 | 2.462 Gbyte/s |
| sliding / 1 | 64.0 | 65.304 | 1.272 | 41.643 | 0.0 | 2.44 Gbyte/s |
| tower64-cold / 0 | 128.0 | 33.368 | 0.05 | 4.217 | 45.085 | 47.761 Mbyte/s |
| tower64-cold / 1 | 109.0 | 32.087 | 0.118 | 6.694 | 0.0 | 23.814 Gbyte/s |
| tower64-warm / 0 | 128.0 | 33.307 | 0.05 | 4.213 | 45.116 | 37.842 Mbyte/s |
| tower64-warm / 1 | 109.0 | 30.752 | 0.103 | 5.819 | 0.0 | 24.381 Gbyte/s |
| city25-intact-idle / 0 | 109.0 | 30.878 | 0.157 | 12.708 | 16.045 | 2.204 Gbyte/s |
| city25-airborne / 0 | 109.0 | 33.347 | 0.159 | 12.825 | 16.028 | 2.218 Gbyte/s |
| city25-initial-impact / 0 | 109.0 | 32.729 | 0.159 | 12.783 | 15.208 | 1.096 Gbyte/s |
| city25-initial-impact / 1 | 109.0 | 19.439 | 0.113 | 9.858 | 16.425 | 0.64 Gbyte/s |
| city25-post-impact / 0 | 109.0 | 21.241 | 0.119 | 10.331 | 14.109 | 1.351 Gbyte/s |
| city25-cascading-fracture / 0 | 109.0 | 23.676 | 0.119 | 10.329 | 15.233 | 638.195 Mbyte/s |
| city25-cascading-fracture / 1 | 109.0 | 20.088 | 0.103 | 9.208 | 6.428 | 742.972 Mbyte/s |
| city25-fragmented-loaded / 0 | 109.0 | 21.309 | 0.104 | 9.229 | 16.147 | 525.922 Mbyte/s |
| city25-fragmented-loaded / 1 | 109.0 | 20.464 | 0.109 | 9.672 | 12.24 | 490.658 Mbyte/s |
| city25-late-debris / 0 | 109.0 | 23.814 | 0.105 | 9.228 | 15.943 | 506.695 Mbyte/s |
| city25-late-debris / 1 | 109.0 | 22.624 | 0.099 | 8.85 | 12.181 | 619.657 Mbyte/s |
| city25-ten-second-debris / 0 | 109.0 | 21.268 | 0.098 | 8.729 | 9.319 | 297.084 Mbyte/s |
| city25-ten-second-debris / 1 | 109.0 | 19.622 | 0.072 | 6.58 | 2.806 | 389.116 Mbyte/s |
| city64-intact-idle / 0 | 109.0 | 32.716 | 0.161 | 13.059 | 39.729 | 14.081 Gbyte/s |
| city64-airborne / 0 | 109.0 | 33.38 | 0.162 | 13.152 | 40.791 | 17.424 Gbyte/s |
| city64-initial-impact / 0 | 109.0 | 32.617 | 0.164 | 13.275 | 38.532 | 24.925 Gbyte/s |
| city64-initial-impact / 1 | 109.0 | 30.21 | 0.155 | 12.816 | 39.926 | 18.399 Gbyte/s |
| city64-post-impact / 0 | 109.0 | 29.65 | 0.159 | 13.118 | 38.32 | 11.612 Gbyte/s |
| city64-cascading-fracture / 0 | 109.0 | 29.819 | 0.153 | 12.683 | 35.543 | 5.093 Gbyte/s |
| city64-cascading-fracture / 1 | 109.0 | 24.047 | 0.119 | 10.576 | 12.033 | 2.066 Gbyte/s |
| city64-fragmented-loaded / 0 | 109.0 | 29.439 | 0.128 | 10.776 | 30.965 | 1.552 Gbyte/s |
| city64-fragmented-loaded / 1 | 109.0 | 27.728 | 0.117 | 9.994 | 24.647 | 1.281 Gbyte/s |
| city64-late-debris / 0 | 109.0 | 29.246 | 0.121 | 10.324 | 31.987 | 1.933 Gbyte/s |
| city64-late-debris / 1 | 109.0 | 27.529 | 0.114 | 9.888 | 24.68 | 0.96 Gbyte/s |
| city64-ten-second-debris / 0 | 109.0 | 29.038 | 0.131 | 11.023 | 28.382 | 1.284 Gbyte/s |
| city64-ten-second-debris / 1 | 109.0 | 23.227 | 0.074 | 6.82 | 4.717 | 0.729 Gbyte/s |
| city256-intact-idle / 0 | 109.0 | 32.789 | 0.162 | 13.266 | 44.664 | 12.415 Gbyte/s |
| city256-airborne / 0 | 109.0 | 32.848 | 0.163 | 13.328 | 44.567 | 12.448 Gbyte/s |
| city256-initial-impact / 0 | 109.0 | 32.748 | 0.169 | 13.795 | 43.893 | 9.91 Gbyte/s |
| city256-initial-impact / 1 | 109.0 | 31.913 | 0.162 | 13.338 | 44.202 | 6.949 Gbyte/s |
| city256-post-impact / 0 | 109.0 | 32.129 | 0.163 | 13.366 | 42.846 | 13.958 Gbyte/s |
| city256-cascading-fracture / 0 | 109.0 | 31.82 | 0.161 | 13.266 | 42.815 | 6.909 Gbyte/s |
| city256-cascading-fracture / 1 | 109.0 | 30.897 | 0.145 | 12.081 | 29.964 | 14.19 Gbyte/s |
| city256-fragmented-loaded / 0 | 109.0 | 32.124 | 0.135 | 11.297 | 39.477 | 5.741 Gbyte/s |
| city256-fragmented-loaded / 1 | 109.0 | 31.937 | 0.136 | 11.374 | 37.084 | 6.423 Gbyte/s |
| city256-late-debris / 0 | 109.0 | 32.3 | 0.131 | 10.996 | 40.989 | 4.983 Gbyte/s |
| city256-late-debris / 1 | 109.0 | 31.893 | 0.132 | 11.095 | 36.539 | 4.959 Gbyte/s |
| city256-ten-second-debris / 0 | 109.0 | 31.987 | 0.143 | 11.83 | 38.015 | 4.007 Gbyte/s |
| city256-ten-second-debris / 1 | 109.0 | 26.714 | 0.084 | 7.428 | 18.062 | 3.513 Gbyte/s |

## Interpretation limits

Profiler launch replay and tracing overhead are excluded from speedup claims. GPU activity is the union of intervals; kernel/API aggregate durations can overlap. Time without traced GPU activity includes CPU work, submission gaps and instrumentation; it is not a proven removable CPU cost. Some shared-device, cross-pass metrics can be out of bounds; flagged percentages are preserved but excluded from quantitative diagnosis. No fixed occupancy/throughput threshold or predicted speedup is treated as proof.

Full `.nsys-rep`, SQLite, `.ncu-repz`, raw CSV, per-launch JSON, exact commands, tool versions, input/module hashes and physical receipts remain in the raw paths listed in report.json. The baseline rows retain all20 unprofiled samples per case; the current timing cohort is from the prior qualified full suite.

See [NVIDIA's profiling guide](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html) for replay, scheduler metric definitions, and out-of-range metrics.
