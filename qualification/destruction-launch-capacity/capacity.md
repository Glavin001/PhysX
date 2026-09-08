# 💥 Active destruction capacity: 256-building launch scheduling

Fixed scene: **256 buildings, 113,664 chunks, 229,376 bonds and 256 projectiles**. Each projectile targets a different building. Same masses, material laws, aerial launch generator, 1/60-second timestep and correction limit one. Sleeping remains disabled. Launch timing changes the interaction history, so this is a workload-capacity comparison, not an equal-work implementation speedup.

Each measured run covers **15 simulated seconds**. Separate warm-ups and phase captures are excluded from the table; every step of each untraced run is included, including insertion, first fracture and allocation peaks. Complete time covers commands, physics, destruction, correction and mandatory completion. Initialization, rendering and report generation are excluded. GPU process monitoring is retained in the campaign; clocks were observed, not locked.

| Workload/run | Launch window s | Complete mean / min / max ms | Misses >16.67 ms / >8 ms | Bonds broken | Net new clusters | Peak bonds broken in 1 simulated second | Worst ms in that 1 s |
|---|---:|---:|---:|---:|---:|---:|---:|
| stagger-256-10s-plain-0 | 10 | 24.07 / 1.13 / 37.96 | 794 / 819 of 900 | 66,480 | 14,399 | 7,462 | 28.81 |
| burst-256-plain-0 | 0 | 22.06 / 1.15 / 52.03 | 819 / 819 of 900 | 62,674 | 13,911 | 57,666 | 52.03 |
| stagger-256-10s-plain-1 | 10 | 24.10 / 1.13 / 37.18 | 795 / 819 of 900 | 66,480 | 14,399 | 7,462 | 26.27 |
| burst-256-plain-1 | 0 | 22.08 / 1.13 / 53.78 | 819 / 819 of 900 | 62,674 | 13,911 | 57,666 | 53.78 |

**Interpretation:** launches per second are input pressure, not destruction throughput. Broken bonds measure actual fracture events; net new clusters measure fragmentation, not detached chunk count. Neither alone captures stress iterations, collision density or rubble cost. A short passing interval is not a sustainable-capacity result.

## Peak-step work

| Run | Step / simulation s | Complete ms | Awake bodies | Contact loads | Active stress nodes / bonds | Stress islands / max iterations | Broken bonds / correction passes |
|---|---:|---:|---:|---:|---:|---:|---:|
| stagger-256-10s-plain-0 | 702 / 11.700 | 37.96 | 14,670 | 218,731 | 86,278 / 134,814 | 3,412 / 297 | 81 / 1 |
| burst-256-plain-0 | 103 / 1.717 | 52.03 | 12,072 | 109,383 | 87,306 / 143,980 | 1,842 / 276 | 7300 / 1 |
| stagger-256-10s-plain-1 | 726 / 12.100 | 37.18 | 14,744 | 222,378 | 86,243 / 134,578 | 3,451 / 288 | 17 / 1 |
| burst-256-plain-1 | 103 / 1.717 | 53.78 | 12,072 | 109,383 | 87,306 / 143,980 | 1,842 / 276 | 7300 / 1 |

Contact loads are the recorded contacts_frame counter, not unique collision pairs or solver rows. Stress topology counts do not represent per-iteration work; iteration count is the maximum component count, not a sum.

## Separate instrumented phase samples

These are separate replays at selected steps, not a decomposition of the exact untraced peak. Host elapsed groups include device waits; **GPU stress is nested inside stress/dependencies and must not be added again**. Step 82 is the first impact; later rows expose peak or post-impact costs.

| Workload / step | Awake bodies | Active stress nodes / bonds | Bonds broken | CPU lifecycle + GPU ownership ms | Correction ms | Stress/dependencies ms | Nested GPU stress ms | Commit ms | Trial/other ms |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| stagger-256-10s / 82 | 55 | 97,262 / 200,594 | 110 | 0.83 | 2.55 | 4.99 | 4.47 | 2.34 | 1.70 |
| stagger-256-10s / 702 | 14,670 | 86,278 / 134,814 | 81 | 0.53 | 4.75 | 24.19 | 23.31 | 2.38 | 4.80 |
| stagger-256-10s / 840 | 14,909 | 86,128 / 134,227 | 0 | 0.01 | 0.00 | 21.25 | 20.85 | 0.00 | 3.96 |
| burst-256 / 82 | 5,376 | 92,672 / 172,544 | 28160 | 17.11 | 27.95 | 8.30 | 7.64 | 2.38 | 3.39 |
| burst-256 / 103 | 12,072 | 87,306 / 143,980 | 7300 | 8.15 | 17.58 | 18.91 | 18.14 | 2.28 | 7.97 |
| burst-256 / 840 | 14,423 | 85,803 / 138,030 | 0 | 0.01 | 0.00 | 17.70 | 17.32 | 0.00 | 4.00 |

The staggered peak shifts toward GPU stress and accumulated contacts. Even post-impact steps with no new fracture can still perform substantial stress work. Zero broken bonds does not prove that those solves can safely be skipped: changed contact loads, residual/convergence, supports and damage inputs need a validity test.

## Capacity verdict

No tested run passes every complete step at 60 Hz. A maximum sustainable real-time destruction rate has **not been established**.

All captured runs must report convergence, no incomplete correction, at most one correction per step, complete launch schedules and consistent fracture totals. These telemetry checks do not replace trajectory, hole-retention, momentum or sanitizer qualification.

## Evolution through each run

### stagger-256-10s-plain-0

| Simulation second | Worst complete ms | Bonds broken | Net new clusters | Maximum awake bodies | Correction steps |
|---|---:|---:|---:|---:|---:|
| 0–1 | 14.66 | 0 | 0 | 26 | 0 |
| 1–2 | 23.72 | 2,696 | 479 | 546 | 29 |
| 2–3 | 24.81 | 6,196 | 1,270 | 1,868 | 55 |
| 3–4 | 24.91 | 6,443 | 1,333 | 3,252 | 55 |
| 4–5 | 28.81 | 7,435 | 1,603 | 4,907 | 56 |
| 5–6 | 29.99 | 6,637 | 1,486 | 6,444 | 60 |
| 6–7 | 30.81 | 6,220 | 1,311 | 7,805 | 56 |
| 7–8 | 30.34 | 6,430 | 1,369 | 9,227 | 57 |
| 8–9 | 30.56 | 6,913 | 1,530 | 10,806 | 58 |
| 9–10 | 33.68 | 6,513 | 1,456 | 12,314 | 58 |
| 10–11 | 35.76 | 6,978 | 1,482 | 13,822 | 58 |
| 11–12 | 37.96 | 3,555 | 879 | 14,710 | 52 |
| 12–13 | 35.76 | 412 | 162 | 14,872 | 26 |
| 13–14 | 33.59 | 49 | 37 | 14,909 | 15 |
| 14–15 | 31.72 | 3 | 2 | 14,911 | 2 |

### burst-256-plain-0

| Simulation second | Worst complete ms | Bonds broken | Net new clusters | Maximum awake bodies | Correction steps |
|---|---:|---:|---:|---:|---:|
| 0–1 | 22.10 | 0 | 0 | 256 | 0 |
| 1–2 | 52.03 | 57,572 | 11,789 | 12,301 | 26 |
| 2–3 | 33.53 | 903 | 424 | 12,725 | 51 |
| 3–4 | 34.36 | 2,996 | 1,126 | 13,851 | 58 |
| 4–5 | 33.88 | 847 | 396 | 14,247 | 46 |
| 5–6 | 31.36 | 268 | 130 | 14,377 | 25 |
| 6–7 | 30.58 | 34 | 13 | 14,390 | 7 |
| 7–8 | 30.04 | 53 | 32 | 14,422 | 11 |
| 8–9 | 27.20 | 1 | 1 | 14,423 | 1 |
| 9–10 | 23.29 | 0 | 0 | 14,423 | 0 |
| 10–11 | 23.10 | 0 | 0 | 14,423 | 0 |
| 11–12 | 22.90 | 0 | 0 | 14,423 | 0 |
| 12–13 | 22.73 | 0 | 0 | 14,423 | 0 |
| 13–14 | 23.73 | 0 | 0 | 14,423 | 0 |
| 14–15 | 22.52 | 0 | 0 | 14,423 | 0 |

### stagger-256-10s-plain-1

| Simulation second | Worst complete ms | Bonds broken | Net new clusters | Maximum awake bodies | Correction steps |
|---|---:|---:|---:|---:|---:|
| 0–1 | 13.92 | 0 | 0 | 26 | 0 |
| 1–2 | 22.49 | 2,696 | 479 | 546 | 29 |
| 2–3 | 26.72 | 6,196 | 1,270 | 1,868 | 55 |
| 3–4 | 25.11 | 6,443 | 1,333 | 3,252 | 55 |
| 4–5 | 26.27 | 7,435 | 1,603 | 4,907 | 56 |
| 5–6 | 29.98 | 6,637 | 1,486 | 6,444 | 60 |
| 6–7 | 29.37 | 6,220 | 1,311 | 7,805 | 56 |
| 7–8 | 29.21 | 6,430 | 1,369 | 9,227 | 57 |
| 8–9 | 31.59 | 6,913 | 1,530 | 10,806 | 58 |
| 9–10 | 33.80 | 6,513 | 1,456 | 12,314 | 58 |
| 10–11 | 36.54 | 6,978 | 1,482 | 13,822 | 58 |
| 11–12 | 35.73 | 3,555 | 879 | 14,710 | 52 |
| 12–13 | 37.18 | 412 | 162 | 14,872 | 26 |
| 13–14 | 34.19 | 49 | 37 | 14,909 | 15 |
| 14–15 | 32.04 | 3 | 2 | 14,911 | 2 |

### burst-256-plain-1

| Simulation second | Worst complete ms | Bonds broken | Net new clusters | Maximum awake bodies | Correction steps |
|---|---:|---:|---:|---:|---:|
| 0–1 | 26.73 | 0 | 0 | 256 | 0 |
| 1–2 | 53.78 | 57,572 | 11,789 | 12,301 | 26 |
| 2–3 | 32.41 | 903 | 424 | 12,725 | 51 |
| 3–4 | 33.23 | 2,996 | 1,126 | 13,851 | 58 |
| 4–5 | 33.75 | 847 | 396 | 14,247 | 46 |
| 5–6 | 31.07 | 268 | 130 | 14,377 | 25 |
| 6–7 | 30.16 | 34 | 13 | 14,390 | 7 |
| 7–8 | 29.48 | 53 | 32 | 14,422 | 11 |
| 8–9 | 29.27 | 1 | 1 | 14,423 | 1 |
| 9–10 | 23.19 | 0 | 0 | 14,423 | 0 |
| 10–11 | 23.49 | 0 | 0 | 14,423 | 0 |
| 11–12 | 23.29 | 0 | 0 | 14,423 | 0 |
| 12–13 | 22.88 | 0 | 0 | 14,423 | 0 |
| 13–14 | 24.50 | 0 | 0 | 14,423 | 0 |
| 14–15 | 22.62 | 0 | 0 | 14,423 | 0 |

Raw provenance and all per-second values: [capacity.json](capacity.json). Detailed separately instrumented phases: [timing report](timing/report.md).
