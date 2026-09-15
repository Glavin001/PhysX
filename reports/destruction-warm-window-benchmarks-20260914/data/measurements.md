# Measured warm-window calibration

Two independent plain processes per case, two restores per process. Mean range spans process means; peak includes every measured tick. Warmup remains separately recorded. This is not an optimization A/B result.

| Scenario | W / M per restore | Measured ticks | Mean range ms | Peak ms | 60 Hz misses | Command / integrated / completion ms, pooled | Physical |
|---|---:|---:|---:|---:|---:|---:|---|
| bridge64 | 8 / 8 | 32 | 1.462–1.691 | 2.251 | 0/32 | 0.000 / 1.369 / 0.207 | passed |
| chain256 | 8 / 8 | 32 | 1.392–1.579 | 1.799 | 0/32 | 0.000 / 1.319 / 0.167 | passed |
| dense12 | 8 / 8 | 32 | 1.272–1.515 | 2.351 | 0/32 | 0.000 / 1.202 / 0.192 | passed |
| tower64 | 8 / 8 | 32 | 1.145–1.447 | 1.861 | 0/32 | 0.000 / 1.097 / 0.199 | passed |
| city25-impact | 42 / 8 | 32 | 22.607–22.761 | 36.917 | 20/32 | 0.000 / 22.468 / 0.215 | passed |
| city256-idle | 16 / 16 | 64 | 1.659–1.692 | 3.927 | 0/64 | 0.000 / 1.486 / 0.190 | passed |
| city256-impact | 42 / 8 | 32 | 88.772–90.104 | 187.800 | 32/32 | 0.000 / 89.200 / 0.238 | passed |
| city256-cascade | 55 / 8 | 32 | 103.736–105.945 | 140.965 | 32/32 | 0.000 / 104.611 / 0.230 | passed |
| city256-debris | 8 / 8 | 32 | 124.455–124.662 | 129.219 | 32/32 | 0.000 / 124.309 / 0.249 | passed |

| Scenario | Context setup range ms/process | Restore range ms/trajectory | Total warmup range ms/trajectory | First restored tick range ms | Measured iteration mean | Fractures / corrections in measured ticks |
|---|---:|---:|---:|---:|---:|---:|
| bridge64 | 462.018–463.173 | 113.765–115.191 | 21.102–24.250 | 8.374–11.822 | 0.000–0.000 | 0 / 0 |
| chain256 | 433.440–435.503 | 106.062–109.650 | 19.385–19.982 | 7.251–9.993 | 1.000–1.000 | 0 / 0 |
| dense12 | 425.274–468.419 | 113.335–121.404 | 40.595–43.734 | 30.974–33.915 | 0.000–0.000 | 0 / 0 |
| tower64 | 435.843–442.251 | 126.632–128.496 | 119.040–119.787 | 107.861–111.193 | 0.000–0.000 | 0 / 0 |
| city25-impact | 569.548–601.749 | 203.644–213.917 | 109.068–110.578 | 10.662–14.451 | 361.000–361.000 | 12620 / 20 |
| city256-idle | 1726.212–1735.152 | 1091.130–1094.034 | 94.253–103.938 | 66.184–79.105 | 0.000–0.000 | 0 / 0 |
| city256-impact | 1701.923–1724.042 | 1092.217–1099.606 | 238.257–259.177 | 65.886–86.925 | 368.000–368.000 | 125648 / 20 |
| city256-cascade | 1725.477–1771.209 | 1102.777–1117.261 | 1347.969–1358.483 | 61.630–92.727 | 531.000–531.000 | 57244 / 32 |
| city256-debris | 1766.939–1788.342 | 1170.794–1187.149 | 1351.334–1353.782 | 334.302–434.165 | 838.500–838.500 | 3016 / 32 |

Campaign status: **complete**. Total wall time: **204.338s**, including GPU admission, desktop handling, validation and selected captures; builds separate.

Stress iteration count is a solver status count, not total GPU instructions. Integrated simulation time contains overlapping CPU/GPU work and both stress passes when required. The three timer partitions are additive; internal profiler scope/thread totals are not.
