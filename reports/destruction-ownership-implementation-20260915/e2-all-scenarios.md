# Warm screen: every measured scenario

Receipt: `out/ownership-scheduling-20260915/sleep-screen-v1/campaign.json`. Capture/check time 306.791s. All durations below are milliseconds. A0/B/A1 are separate processes. Two restores per process, fixed real warmup; first measured tick retained. Restore and warmup are excluded from complete-step timing. Samples within a trajectory are correlated; these are descriptive results, not independent statistical trials.

## Complete-step and stages

`simulate/fetch` includes PhysX, stress/material, transfers, waits and optional corrected physics. Completion includes the remaining publication/observation work. Fine-grained native scopes are only available in the separately instrumented selected profile.

| Scenario/arm | N | Mean | Peak | >16.667ms | Command | Simulate/fetch | Completion |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64-A0 | 16 | 1.419 | 1.624 | 0/16 | 0.000075 | 1.221 | 0.198 |
| chain256-A0 | 16 | 1.437 | 1.743 | 0/16 | 0.000049 | 1.272 | 0.165 |
| dense12-A0 | 16 | 1.473 | 1.653 | 0/16 | 0.000087 | 1.270 | 0.203 |
| tower64-A0 | 16 | 1.446 | 1.667 | 0/16 | 0.000080 | 1.235 | 0.211 |
| city25-impact-A0 | 16 | 22.507 | 38.037 | 10/16 | 0.000082 | 22.316 | 0.191 |
| city256-idle-A0 | 32 | 1.677 | 2.882 | 0/32 | 0.000080 | 1.487 | 0.191 |
| city256-impact-A0 | 16 | 86.708 | 173.600 | 16/16 | 0.000083 | 86.478 | 0.230 |
| city256-cascade-A0 | 16 | 103.315 | 136.123 | 16/16 | 0.000098 | 103.082 | 0.233 |
| city256-debris-A0 | 16 | 125.084 | 128.166 | 16/16 | 0.000103 | 124.843 | 0.241 |
| city256-debris-rebuilt-control | 16 | 124.676 | 127.481 | 16/16 | 0.000116 | 124.374 | 0.302 |
| bridge64-B | 16 | 1.560 | 2.037 | 0/16 | 0.000050 | 1.387 | 0.173 |
| chain256-B | 16 | 1.378 | 1.579 | 0/16 | 0.000091 | 1.208 | 0.170 |
| dense12-B | 16 | 1.444 | 1.664 | 0/16 | 0.000086 | 1.219 | 0.225 |
| tower64-B | 16 | 1.376 | 1.541 | 0/16 | 0.000094 | 1.188 | 0.188 |
| city25-impact-B | 16 | 22.385 | 36.936 | 10/16 | 0.000105 | 22.195 | 0.189 |
| city256-idle-B | 32 | 1.666 | 2.060 | 0/32 | 0.000081 | 1.473 | 0.193 |
| city256-impact-B | 16 | 87.957 | 184.688 | 16/16 | 0.000112 | 87.750 | 0.207 |
| city256-cascade-B | 16 | 104.663 | 142.502 | 16/16 | 0.000096 | 104.426 | 0.237 |
| city256-debris-B | 16 | 123.804 | 127.558 | 16/16 | 0.000112 | 123.580 | 0.224 |
| city256-debris-A1 | 16 | 123.939 | 128.020 | 16/16 | 0.000097 | 123.699 | 0.239 |
| city256-cascade-A1 | 16 | 103.749 | 142.606 | 16/16 | 0.000121 | 103.534 | 0.215 |
| city256-impact-A1 | 16 | 86.409 | 160.074 | 16/16 | 0.000081 | 86.186 | 0.223 |
| city256-idle-A1 | 32 | 1.606 | 1.780 | 0/32 | 0.000078 | 1.407 | 0.199 |
| city25-impact-A1 | 16 | 23.167 | 37.061 | 10/16 | 0.000087 | 22.968 | 0.198 |
| tower64-A1 | 16 | 1.453 | 2.215 | 0/16 | 0.000088 | 1.229 | 0.224 |
| dense12-A1 | 16 | 1.608 | 2.020 | 0/16 | 0.000072 | 1.418 | 0.191 |
| chain256-A1 | 16 | 1.442 | 1.590 | 0/16 | 0.000064 | 1.260 | 0.182 |
| bridge64-A1 | 16 | 1.201 | 1.435 | 0/16 | 0.000043 | 1.034 | 0.167 |

## Preparation excluded from tick timing

Context setup is once per process; restore is the mean per trajectory; warm tick is the mean over the fixed physical warmup. Costs remain recorded rather than silently primed away.

| Scenario/arm | Context setup | Restore | Warm tick |
|---|---:|---:|---:|
| bridge64-A0 | 451.056 | 115.752 | 2.495 |
| chain256-A0 | 447.000 | 108.085 | 2.495 |
| dense12-A0 | 436.160 | 123.007 | 5.426 |
| tower64-A0 | 454.791 | 127.154 | 14.922 |
| city25-impact-A0 | 572.518 | 204.989 | 2.640 |
| city256-idle-A0 | 1754.135 | 1104.556 | 6.080 |
| city256-impact-A0 | 1747.980 | 1129.098 | 5.295 |
| city256-cascade-A0 | 1869.514 | 1155.562 | 24.466 |
| city256-debris-A0 | 1820.796 | 1187.370 | 166.635 |
| city256-debris-rebuilt-control | 1790.415 | 1171.071 | 167.442 |
| bridge64-B | 454.073 | 113.425 | 2.814 |
| chain256-B | 436.723 | 108.341 | 2.333 |
| dense12-B | 448.687 | 123.117 | 5.421 |
| tower64-B | 462.538 | 136.240 | 14.910 |
| city25-impact-B | 623.332 | 235.170 | 2.489 |
| city256-idle-B | 1749.916 | 1090.985 | 5.871 |
| city256-impact-B | 1800.598 | 1099.487 | 5.370 |
| city256-cascade-B | 1746.980 | 1093.264 | 24.297 |
| city256-debris-B | 1759.440 | 1153.761 | 166.737 |
| city256-debris-A1 | 1767.072 | 1150.206 | 167.617 |
| city256-cascade-A1 | 1765.511 | 1145.865 | 24.601 |
| city256-impact-A1 | 1799.890 | 1096.917 | 5.615 |
| city256-idle-A1 | 1698.981 | 1102.733 | 5.849 |
| city25-impact-A1 | 596.121 | 217.411 | 2.652 |
| tower64-A1 | 433.142 | 120.691 | 15.024 |
| dense12-A1 | 440.684 | 117.101 | 5.601 |
| chain256-A1 | 460.454 | 99.818 | 2.378 |
| bridge64-A1 | 438.770 | 112.061 | 2.348 |

## Actual work, mean per measured tick

The physical checker compares complete work histories, including warmup. Counts below are window means, not reconstructed compute scores. Fractures, contacts and component sizes can vary through a window.

| Scenario/arm | Stress iterations | New broken bonds | Corrections | Stress islands | Active nodes | Active bonds | Contacts | Friction anchors |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| bridge64-A0 | 0.000 | 0.000 | 0.000 | 1.000 | 744.000 | 1500.000 | 0.000 | 0.000 |
| chain256-A0 | 1.000 | 0.000 | 0.000 | 1.000 | 255.000 | 255.000 | 0.000 | 0.000 |
| dense12-A0 | 0.000 | 0.000 | 0.000 | 1.000 | 1584.000 | 4488.000 | 0.000 | 0.000 |
| tower64-A0 | 0.000 | 0.000 | 0.000 | 1.000 | 2304.000 | 4788.000 | 0.000 | 0.000 |
| city25-impact-A0 | 361.000 | 394.375 | 0.625 | 59.125 | 8978.750 | 16579.375 | 7456.750 | 1533.125 |
| city256-idle-A0 | 0.000 | 0.000 | 0.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| city256-impact-A0 | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
| city256-cascade-A0 | 531.000 | 1788.875 | 1.000 | 1111.375 | 90883.875 | 162309.750 | 121295.875 | 21891.000 |
| city256-debris-A0 | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |
| city256-debris-rebuilt-control | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |
| bridge64-B | 0.000 | 0.000 | 0.000 | 1.000 | 744.000 | 1500.000 | 0.000 | 0.000 |
| chain256-B | 1.000 | 0.000 | 0.000 | 1.000 | 255.000 | 255.000 | 0.000 | 0.000 |
| dense12-B | 0.000 | 0.000 | 0.000 | 1.000 | 1584.000 | 4488.000 | 0.000 | 0.000 |
| tower64-B | 0.000 | 0.000 | 0.000 | 1.000 | 2304.000 | 4788.000 | 0.000 | 0.000 |
| city25-impact-B | 361.000 | 394.375 | 0.625 | 59.125 | 8978.750 | 16579.375 | 7456.750 | 1533.125 |
| city256-idle-B | 0.000 | 0.000 | 0.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| city256-impact-B | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
| city256-cascade-B | 531.000 | 1788.875 | 1.000 | 1111.375 | 90883.875 | 162309.750 | 121295.875 | 21891.000 |
| city256-debris-B | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |
| city256-debris-A1 | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |
| city256-cascade-A1 | 531.000 | 1788.875 | 1.000 | 1111.375 | 90883.875 | 162309.750 | 121295.875 | 21891.000 |
| city256-impact-A1 | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
| city256-idle-A1 | 0.000 | 0.000 | 0.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| city25-impact-A1 | 361.000 | 394.375 | 0.625 | 59.125 | 8978.750 | 16579.375 | 7456.750 | 1533.125 |
| tower64-A1 | 0.000 | 0.000 | 0.000 | 1.000 | 2304.000 | 4788.000 | 0.000 | 0.000 |
| dense12-A1 | 0.000 | 0.000 | 0.000 | 1.000 | 1584.000 | 4488.000 | 0.000 | 0.000 |
| chain256-A1 | 1.000 | 0.000 | 0.000 | 1.000 | 255.000 | 255.000 | 0.000 | 0.000 |
| bridge64-A1 | 0.000 | 0.000 | 0.000 | 1.000 | 744.000 | 1500.000 | 0.000 | 0.000 |

Raw observations and profiler artifacts are local ignored evidence and are not included in a fresh clone.
