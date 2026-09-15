# Warm screen: every measured scenario

Receipt: `out/ownership-scheduling-20260915/screen-v1/campaign.json`. Capture/check time 278.991s. All durations below are milliseconds. A0/B/A1 are separate processes. Two restores per process, fixed real warmup; first measured tick retained. Restore and warmup are excluded from complete-step timing. Samples within a trajectory are correlated; these are descriptive results, not independent statistical trials.

## Complete-step and stages

`simulate/fetch` includes PhysX, stress/material, transfers, waits and optional corrected physics. Completion includes the remaining publication/observation work. Fine-grained native scopes are only available in the separately instrumented selected profile.

| Scenario/arm | N | Mean | Peak | >16.667ms | Command | Simulate/fetch | Completion |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64-A0 | 16 | 1.128 | 1.323 | 0/16 | 0.000041 | 0.905 | 0.222 |
| chain256-A0 | 16 | 1.449 | 1.709 | 0/16 | 0.000056 | 1.265 | 0.184 |
| dense12-A0 | 16 | 1.172 | 1.531 | 0/16 | 0.000079 | 0.977 | 0.195 |
| tower64-A0 | 16 | 1.819 | 4.170 | 0/16 | 0.000079 | 1.628 | 0.190 |
| city25-impact-A0 | 16 | 22.750 | 37.576 | 10/16 | 0.000094 | 22.530 | 0.219 |
| city256-idle-A0 | 32 | 1.407 | 2.309 | 0/32 | 0.000057 | 1.247 | 0.160 |
| city256-impact-A0 | 16 | 88.393 | 184.662 | 16/16 | 0.000115 | 88.167 | 0.225 |
| city256-cascade-A0 | 16 | 104.506 | 144.193 | 16/16 | 0.000141 | 104.298 | 0.209 |
| city256-debris-A0 | 16 | 123.566 | 127.873 | 16/16 | 0.000118 | 123.331 | 0.234 |
| bridge64-B | 16 | 1.057 | 1.253 | 0/16 | 0.000047 | 0.917 | 0.140 |
| chain256-B | 16 | 1.433 | 1.569 | 0/16 | 0.000087 | 1.233 | 0.199 |
| dense12-B | 16 | 1.456 | 1.535 | 0/16 | 0.000077 | 1.245 | 0.211 |
| tower64-B | 16 | 1.477 | 1.565 | 0/16 | 0.000083 | 1.265 | 0.213 |
| city25-impact-B | 16 | 22.871 | 38.386 | 10/16 | 0.000092 | 22.662 | 0.209 |
| city256-idle-B | 32 | 1.644 | 2.004 | 0/32 | 0.000087 | 1.449 | 0.195 |
| city256-impact-B | 16 | 88.854 | 180.724 | 16/16 | 0.000092 | 88.613 | 0.241 |
| city256-cascade-B | 16 | 103.625 | 140.045 | 16/16 | 0.000113 | 103.395 | 0.230 |
| city256-debris-B | 16 | 123.680 | 126.784 | 16/16 | 0.000094 | 123.463 | 0.217 |
| city256-debris-A1 | 16 | 124.185 | 129.248 | 16/16 | 0.000126 | 123.935 | 0.250 |
| city256-cascade-A1 | 16 | 103.856 | 136.425 | 16/16 | 0.000129 | 103.613 | 0.242 |
| city256-impact-A1 | 16 | 88.541 | 185.844 | 16/16 | 0.000088 | 88.304 | 0.236 |
| city256-idle-A1 | 32 | 1.580 | 1.846 | 0/32 | 0.000082 | 1.371 | 0.209 |
| city25-impact-A1 | 16 | 22.517 | 37.713 | 10/16 | 0.000099 | 22.308 | 0.209 |
| tower64-A1 | 16 | 1.353 | 1.535 | 0/16 | 0.000090 | 1.129 | 0.224 |
| dense12-A1 | 16 | 1.537 | 1.671 | 0/16 | 0.000135 | 1.253 | 0.284 |
| chain256-A1 | 16 | 1.449 | 1.796 | 0/16 | 0.000099 | 1.262 | 0.187 |
| bridge64-A1 | 16 | 1.431 | 1.592 | 0/16 | 0.000105 | 1.217 | 0.214 |

## Preparation excluded from tick timing

Context setup is once per process; restore is the mean per trajectory; warm tick is the mean over the fixed physical warmup. Costs remain recorded rather than silently primed away.

| Scenario/arm | Context setup | Restore | Warm tick |
|---|---:|---:|---:|
| bridge64-A0 | 460.450 | 111.256 | 2.267 |
| chain256-A0 | 438.617 | 108.918 | 2.397 |
| dense12-A0 | 447.829 | 122.412 | 4.927 |
| tower64-A0 | 443.760 | 125.026 | 15.256 |
| city25-impact-A0 | 554.562 | 199.571 | 2.745 |
| city256-idle-A0 | 1745.752 | 1099.132 | 5.383 |
| city256-impact-A0 | 1767.155 | 1102.670 | 5.858 |
| city256-cascade-A0 | 1809.819 | 1147.187 | 24.094 |
| city256-debris-A0 | 1727.913 | 1143.399 | 168.475 |
| bridge64-B | 429.591 | 105.201 | 2.192 |
| chain256-B | 455.480 | 109.751 | 2.396 |
| dense12-B | 452.558 | 125.043 | 5.380 |
| tower64-B | 493.545 | 137.452 | 15.026 |
| city25-impact-B | 595.011 | 213.039 | 2.602 |
| city256-idle-B | 1782.163 | 1108.208 | 5.779 |
| city256-impact-B | 1816.157 | 1134.874 | 5.703 |
| city256-cascade-B | 1796.096 | 1115.153 | 24.186 |
| city256-debris-B | 1809.124 | 1182.754 | 169.152 |
| city256-debris-A1 | 1787.802 | 1171.509 | 169.840 |
| city256-cascade-A1 | 1755.302 | 1094.867 | 24.735 |
| city256-impact-A1 | 1745.516 | 1089.981 | 5.684 |
| city256-idle-A1 | 1758.571 | 1101.236 | 5.870 |
| city25-impact-A1 | 636.110 | 207.079 | 2.761 |
| tower64-A1 | 429.946 | 115.122 | 14.684 |
| dense12-A1 | 454.873 | 140.918 | 5.472 |
| chain256-A1 | 442.482 | 107.449 | 2.288 |
| bridge64-A1 | 440.929 | 111.800 | 2.585 |

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
