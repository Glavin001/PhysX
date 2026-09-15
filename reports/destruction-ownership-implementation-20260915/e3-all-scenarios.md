# Warm screen: every measured scenario

Receipt: `out/ownership-scheduling-20260915/observation-screen-v1/campaign.json`. Capture/check time 293.908s. All durations below are milliseconds. A0/B/A1 are separate processes. Two restores per process, fixed real warmup; first measured tick retained. Restore and warmup are excluded from complete-step timing. Samples within a trajectory are correlated; these are descriptive results, not independent statistical trials.

## Complete-step and stages

`simulate/fetch` includes PhysX, stress/material, transfers, waits and optional corrected physics. Completion includes the remaining publication/observation work. Fine-grained native scopes are only available in the separately instrumented selected profile.

| Scenario/arm | N | Mean | Peak | >16.667ms | Command | Simulate/fetch | Completion |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64-A0 | 16 | 1.462 | 1.717 | 0/16 | 0.000046 | 1.330 | 0.132 |
| chain256-A0 | 16 | 1.183 | 1.319 | 0/16 | 0.000054 | 1.056 | 0.127 |
| dense12-A0 | 16 | 1.437 | 1.544 | 0/16 | 0.000093 | 1.235 | 0.202 |
| tower64-A0 | 16 | 1.523 | 1.588 | 0/16 | 0.000083 | 1.245 | 0.278 |
| city25-impact-A0 | 16 | 22.799 | 37.178 | 10/16 | 0.000110 | 22.603 | 0.195 |
| city256-idle-A0 | 32 | 1.881 | 4.938 | 0/32 | 0.000087 | 1.686 | 0.195 |
| city256-impact-A0 | 16 | 88.237 | 187.606 | 16/16 | 0.000113 | 88.021 | 0.215 |
| city256-cascade-A0 | 16 | 103.089 | 139.084 | 16/16 | 0.000113 | 102.846 | 0.243 |
| city256-debris-A0 | 16 | 123.178 | 126.641 | 16/16 | 0.000105 | 122.942 | 0.236 |
| city256-impact-rebuilt-control | 16 | 89.491 | 188.927 | 16/16 | 0.000101 | 89.256 | 0.235 |
| bridge64-B | 16 | 1.527 | 1.858 | 0/16 | 0.000067 | 1.340 | 0.188 |
| chain256-B | 16 | 1.440 | 1.614 | 0/16 | 0.000079 | 1.245 | 0.195 |
| dense12-B | 16 | 1.459 | 1.590 | 0/16 | 0.000081 | 1.252 | 0.207 |
| tower64-B | 16 | 1.351 | 1.649 | 0/16 | 0.000086 | 1.137 | 0.213 |
| city25-impact-B | 16 | 21.826 | 35.404 | 10/16 | 0.000077 | 21.631 | 0.195 |
| city256-idle-B | 32 | 1.653 | 5.251 | 0/32 | 0.000068 | 1.457 | 0.195 |
| city256-impact-B | 16 | 88.274 | 178.627 | 16/16 | 0.000084 | 88.057 | 0.217 |
| city256-cascade-B | 16 | 104.180 | 141.941 | 16/16 | 0.000109 | 103.931 | 0.248 |
| city256-debris-B | 16 | 123.798 | 128.496 | 16/16 | 0.000123 | 123.561 | 0.237 |
| city256-debris-A1 | 16 | 123.655 | 127.212 | 16/16 | 0.000100 | 123.420 | 0.235 |
| city256-cascade-A1 | 16 | 104.255 | 141.735 | 16/16 | 0.000119 | 104.015 | 0.240 |
| city256-impact-A1 | 16 | 86.182 | 158.636 | 16/16 | 0.000099 | 85.954 | 0.227 |
| city256-idle-A1 | 32 | 1.800 | 5.397 | 0/32 | 0.000077 | 1.600 | 0.200 |
| city25-impact-A1 | 16 | 22.808 | 33.621 | 10/16 | 0.000091 | 22.592 | 0.215 |
| tower64-A1 | 16 | 1.443 | 1.538 | 0/16 | 0.000080 | 1.233 | 0.210 |
| dense12-A1 | 16 | 1.397 | 1.539 | 0/16 | 0.000085 | 1.203 | 0.194 |
| chain256-A1 | 16 | 1.485 | 1.748 | 0/16 | 0.000061 | 1.224 | 0.261 |
| bridge64-A1 | 16 | 1.359 | 1.469 | 0/16 | 0.000057 | 1.182 | 0.178 |

## Preparation excluded from tick timing

Context setup is once per process; restore is the mean per trajectory; warm tick is the mean over the fixed physical warmup. Costs remain recorded rather than silently primed away.

| Scenario/arm | Context setup | Restore | Warm tick |
|---|---:|---:|---:|
| bridge64-A0 | 478.039 | 112.515 | 2.750 |
| chain256-A0 | 442.105 | 109.630 | 2.102 |
| dense12-A0 | 453.917 | 123.052 | 5.436 |
| tower64-A0 | 440.235 | 127.582 | 14.958 |
| city25-impact-A0 | 578.999 | 205.502 | 2.752 |
| city256-idle-A0 | 1750.158 | 1110.795 | 6.623 |
| city256-impact-A0 | 1801.195 | 1123.305 | 6.056 |
| city256-cascade-A0 | 1772.560 | 1098.065 | 23.771 |
| city256-debris-A0 | 1783.481 | 1175.647 | 168.981 |
| city256-impact-rebuilt-control | 1773.680 | 1105.783 | 5.894 |
| bridge64-B | 455.752 | 113.161 | 2.609 |
| chain256-B | 440.999 | 109.667 | 2.414 |
| dense12-B | 446.653 | 122.124 | 5.497 |
| tower64-B | 433.973 | 124.178 | 14.739 |
| city25-impact-B | 567.767 | 201.522 | 2.404 |
| city256-idle-B | 1745.690 | 1097.946 | 6.351 |
| city256-impact-B | 1764.074 | 1109.554 | 5.918 |
| city256-cascade-B | 1820.918 | 1114.748 | 24.003 |
| city256-debris-B | 1775.200 | 1167.475 | 168.058 |
| city256-debris-A1 | 1775.559 | 1154.584 | 165.684 |
| city256-cascade-A1 | 1749.133 | 1092.834 | 24.444 |
| city256-impact-A1 | 1739.410 | 1113.331 | 5.183 |
| city256-idle-A1 | 1789.452 | 1112.680 | 5.901 |
| city25-impact-A1 | 607.604 | 209.690 | 2.545 |
| tower64-A1 | 450.063 | 124.135 | 14.929 |
| dense12-A1 | 431.003 | 121.560 | 5.364 |
| chain256-A1 | 447.031 | 108.833 | 2.488 |
| bridge64-A1 | 465.172 | 111.976 | 2.583 |

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
| city256-impact-rebuilt-control | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
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
