# Measured fast-loop calibration

2026-09-13. Both comparisons use identical selected N13+N20 binaries and modules in all three slots. Differences below are timing noise, not implementation gains. All seven scenarios and 120 unprofiled complete ticks pass physical comparisons in each calibration. No first-use sample is discarded.

| Run | Matched timing/checks | Systems capture/export/checks | Total / outcome |
|---|---:|---:|---|
| fast-calibration | 132.356s | 0.000s | 134.105s; complete |
| profiled-fast-calibration | 130.821s | 31.405s | 180.035s; budget_exceeded |

The first full screen finished in 134.105s. In the profiled trial, timing through admission took 132.542s and the large-debris Systems stage 31.405s: 163.947s before NCU. Systems passed its physical comparison and retained full CPU/GPU attribution. The 180s hard cap interrupted NCU final bookkeeping after its native report was written; the original outcome remains `budget_exceeded`. Offline CSV export finds two selected kernel records; the log records one counter pass per launch. The frozen physical checker rejects that directory because the interrupted wrapper did not write `receipt.json`. That is an incomplete capture-admission record, not a measured physics mismatch, and the counter capture is not qualified.

This supports a 3-minute routine Systems-profiled loop and a 4–5-minute budget when focused hardware counters and validation are also included. The larger NCU budget is a recommendation, not a completed 4-minute retest. No further GPU baseline runs were launched after the bounded trial.

## Every scenario in the profiled trial

| Scenario | A before / identical B / A after mean ms | A before / B / A after peak ms | 60 Hz misses before / B / after |
|---|---:|---:|---:|
| bridge64-cold | 9.115 / 9.132 / 8.445 | 12.051 / 11.928 / 9.327 | 0/8 / 0/8 / 0/8 |
| chain256-cold | 7.728 / 6.839 / 7.001 | 10.193 / 9.237 / 8.919 | 0/8 / 0/8 / 0/8 |
| dense12-cold | 31.222 / 31.602 / 31.573 | 31.990 / 32.772 / 34.140 | 6/6 / 6/6 / 6/6 |
| destruction-stimulus | 4.360 / 4.551 / 4.289 | 7.377 / 8.301 / 7.813 | 0/8 / 0/8 / 0/8 |
| city25-initial-impact | 39.481 / 41.410 / 41.228 | 49.794 / 48.792 / 49.287 | 4/4 / 4/4 / 4/4 |
| city256-intact-idle | 64.713 / 66.544 / 58.054 | 79.363 / 77.050 / 68.373 | 3/3 / 3/3 / 3/3 |
| city256-late-debris | 395.823 / 382.327 / 378.510 | 406.973 / 424.183 / 407.630 | 3/3 / 3/3 / 3/3 |

All raw tick samples, excluded restore/setup costs, command/integrated/completion stages, work and iteration histories, physical comparisons and artifact hashes are in the linked JSON and raw campaign directories. `physics_step`/`simulate_fetch` includes the integrated stress and correction path; no stock-PhysX-only timing is inferred.

[Screen commands and tier policy](fast-profiled-loop.md). [First comparison](evidence/fast-loop/fast-calibration-comparison.json). [Profiled comparison](evidence/fast-loop/profiled-fast-calibration-comparison.json).
