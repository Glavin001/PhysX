# Warm screen: every measured scenario

Receipt: `out/ownership-scheduling-20260915/observation-confirm-v2/campaign.json`. Campaign status: complete; capture/check time 222.688s. All durations below are milliseconds. Each arm/slot is a separate process; its schedule is recorded in the plan. Two restores per process, fixed real warmup; first measured tick retained. Restore and warmup are excluded from complete-step timing. Samples within a trajectory are correlated; these are descriptive results, not independent statistical trials.

## Complete-step and stages

`simulate/fetch` includes PhysX, stress/material, transfers, waits and optional corrected physics. Completion includes the remaining publication/observation work. Fine-grained native scopes are only available in the separately instrumented selected profile.

| Scenario/arm | N | Mean | Peak | >16.667ms | Command | Simulate/fetch | Completion |
|---|---:|---:|---:|---:|---:|---:|---:|
| city25-impact-0-A | 16 | 24.087 | 51.016 | 10/16 | 0.000081 | 23.878 | 0.209 |
| city256-impact-0-A | 16 | 89.606 | 182.464 | 16/16 | 0.000103 | 89.366 | 0.240 |
| city256-cascade-0-A | 16 | 104.271 | 141.451 | 16/16 | 0.000127 | 104.021 | 0.250 |
| city256-debris-0-A | 16 | 125.069 | 129.108 | 16/16 | 0.000119 | 124.859 | 0.210 |
| city25-impact-1-B | 16 | 22.270 | 36.306 | 10/16 | 0.000075 | 22.074 | 0.196 |
| city256-impact-1-B | 16 | 88.316 | 183.495 | 16/16 | 0.000088 | 88.069 | 0.247 |
| city256-cascade-1-B | 16 | 103.907 | 132.595 | 16/16 | 0.000102 | 103.658 | 0.249 |
| city256-debris-1-B | 16 | 124.041 | 127.211 | 16/16 | 0.000119 | 123.782 | 0.259 |
| city25-impact-2-B | 16 | 22.292 | 37.718 | 10/16 | 0.000091 | 22.073 | 0.219 |
| city256-impact-2-B | 16 | 88.627 | 182.585 | 16/16 | 0.000097 | 88.410 | 0.217 |
| city256-cascade-2-B | 16 | 102.425 | 140.738 | 16/16 | 0.000109 | 102.166 | 0.259 |
| city256-debris-2-B | 16 | 123.404 | 127.090 | 16/16 | 0.000118 | 123.162 | 0.241 |
| city25-impact-3-A | 16 | 22.724 | 37.181 | 10/16 | 0.000083 | 22.534 | 0.191 |
| city256-impact-3-A | 16 | 89.858 | 189.953 | 16/16 | 0.000082 | 89.617 | 0.241 |
| city256-cascade-3-A | 16 | 105.282 | 144.856 | 16/16 | 0.000106 | 105.041 | 0.240 |
| city256-debris-3-A | 16 | 124.454 | 130.163 | 16/16 | 0.000095 | 124.212 | 0.243 |

## Preparation excluded from tick timing

Context setup is once per process; restore is the mean per trajectory; warm tick is the mean over the fixed physical warmup. Costs remain recorded rather than silently primed away.

| Scenario/arm | Context setup | Restore | Warm tick |
|---|---:|---:|---:|
| city25-impact-0-A | 632.314 | 209.822 | 2.793 |
| city256-impact-0-A | 1786.695 | 1130.943 | 5.707 |
| city256-cascade-0-A | 1782.998 | 1126.656 | 24.025 |
| city256-debris-0-A | 1812.783 | 1178.077 | 171.837 |
| city25-impact-1-B | 593.080 | 204.975 | 2.623 |
| city256-impact-1-B | 1777.258 | 1110.508 | 5.705 |
| city256-cascade-1-B | 1734.196 | 1102.312 | 24.610 |
| city256-debris-1-B | 1764.071 | 1156.902 | 168.385 |
| city25-impact-2-B | 593.684 | 209.565 | 2.667 |
| city256-impact-2-B | 1751.767 | 1094.139 | 5.803 |
| city256-cascade-2-B | 1766.251 | 1119.279 | 23.960 |
| city256-debris-2-B | 1808.335 | 1191.628 | 168.789 |
| city25-impact-3-A | 595.964 | 209.100 | 2.725 |
| city256-impact-3-A | 1788.100 | 1118.351 | 6.177 |
| city256-cascade-3-A | 1706.953 | 1111.167 | 24.464 |
| city256-debris-3-A | 1721.042 | 1151.489 | 169.358 |

## Actual work, mean per measured tick

The physical checker compares complete work histories, including warmup. Counts below are window means, not reconstructed compute scores. Fractures, contacts and component sizes can vary through a window.

| Scenario/arm | Stress iterations | New broken bonds | Corrections | Stress islands | Active nodes | Active bonds | Contacts | Friction anchors |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| city25-impact-0-A | 361.000 | 394.375 | 0.625 | 59.125 | 8978.750 | 16579.375 | 7456.750 | 1533.125 |
| city256-impact-0-A | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
| city256-cascade-0-A | 531.000 | 1788.875 | 1.000 | 1111.375 | 90883.875 | 162309.750 | 121295.875 | 21891.000 |
| city256-debris-0-A | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |
| city25-impact-1-B | 361.000 | 394.375 | 0.625 | 59.125 | 8978.750 | 16579.375 | 7456.750 | 1533.125 |
| city256-impact-1-B | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
| city256-cascade-1-B | 531.000 | 1788.875 | 1.000 | 1111.375 | 90883.875 | 162309.750 | 121295.875 | 21891.000 |
| city256-debris-1-B | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |
| city25-impact-2-B | 361.000 | 394.375 | 0.625 | 59.125 | 8978.750 | 16579.375 | 7456.750 | 1533.125 |
| city256-impact-2-B | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
| city256-cascade-2-B | 531.000 | 1788.875 | 1.000 | 1111.375 | 90883.875 | 162309.750 | 121295.875 | 21891.000 |
| city256-debris-2-B | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |
| city25-impact-3-A | 361.000 | 394.375 | 0.625 | 59.125 | 8978.750 | 16579.375 | 7456.750 | 1533.125 |
| city256-impact-3-A | 368.000 | 3926.500 | 0.625 | 596.750 | 92223.875 | 170442.000 | 77137.750 | 15571.125 |
| city256-cascade-3-A | 531.000 | 1788.875 | 1.000 | 1111.375 | 90883.875 | 162309.750 | 121295.875 | 21891.000 |
| city256-debris-3-A | 838.500 | 94.250 | 1.000 | 3199.250 | 82948.750 | 129706.500 | 301615.250 | 65197.500 |

Raw observations and profiler artifacts are local ignored evidence and are not included in a fresh clone.
