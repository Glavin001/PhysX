# N06b experiment decision

Reject warp-sized tiny-component execution. All independent numerical, boundary32/36, normal asynchronous native memory and seven light physical checks pass. Bridge B9.592ms versusA8.237/8.776; chain7.485 versus6.683/7.176; dense31.708 versus31.736/31.704; stimulus4.440 versus3.719/4.501; impact38.646 versus40.720/40.928; large idle66.748 versus64.655/65.660; late debris431.111 versus442.760/419.449. One short impact signal does not justify small-structure/idle losses with no consistent late-debris gain. Compiler registers rise109 to112 in both class kernels; shared1600 and stack48bytes remain unchanged. Increased useful block concurrency was plausible but did not establish application savings. Do not pursue more size thresholds without a measured active-component/iteration critical-path census.

Commit `eca61ee266f91658d7525cd760c36b23bc7a40d2`. One coherent isolated hypothesis. No full52 or warm timing after rejection at the correctness/light/target screen. Baseline counter attribution and compiler resources guide diagnosis; profiler timing is not an application gain. Every completed sample and failure is retained.

No rejected runtime applied to main or installed SDK. Selected N13 numerical policy and isolated N20 CPU change preserved; composition still requires qualification.

# Matched restored full ticks

One full tick per independent physical restore. A-before / B / A-after per scenario. All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.

| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |
|---|---:|---:|---:|---:|---|
| bridge64-cold | 8.237 / 11.431 | 9.592 / 10.523 | 8.776 / 10.121 | -1.086 | -1.722–-0.438 |
| chain256-cold | 6.683 / 8.931 | 7.485 / 10.324 | 7.176 / 8.383 | -0.556 | -1.540–0.230 |
| dense12-cold | 31.736 / 35.007 | 31.708 / 34.731 | 31.704 / 33.775 | 0.011 | -1.455–1.259 |
| destruction-stimulus | 3.719 / 5.781 | 4.440 / 8.595 | 4.501 / 8.215 | -0.330 | -1.695–0.764 |
| city25-initial-impact | 40.720 / 42.562 | 38.646 / 42.042 | 40.928 / 50.030 | 2.178 | -1.999–6.481 |
| city256-intact-idle | 64.655 / 71.616 | 66.748 / 74.450 | 65.660 / 76.781 | -1.590 | -11.203–7.301 |
| city256-late-debris | 442.760 / 486.076 | 431.111 / 472.681 | 419.449 / 468.834 | -0.006 | -51.260–55.558 |

Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.

| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 16 / 8 | 12 (75.0%) / 8 (100.0%) | 0 (0.0%) / 0 (0.0%) | 8 (50.0%) / 8 (100.0%) | 35.289 / 40.157 |
| chain256-cold | 16 / 8 | 2 (12.5%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 2 (12.5%) / 1 (12.5%) | 34.822 / 31.686 |
| dense12-cold | 12 / 6 | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 12 (100.0%) / 6 (100.0%) | 55.757 / 58.168 |
| destruction-stimulus | 16 / 8 | 1 (6.2%) / 1 (12.5%) | 0 (0.0%) / 0 (0.0%) | 0 (0.0%) / 1 (12.5%) | 29.591 / 30.099 |
| city25-initial-impact | 8 / 4 | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 8 (100.0%) / 4 (100.0%) | 125.540 / 121.483 |
| city256-intact-idle | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 843.024 / 848.994 |
| city256-late-debris | 6 / 3 | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 6 (100.0%) / 3 (100.0%) | 979.029 / 978.397 |

| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |
|---|---:|---:|---:|
| bridge64-cold | 0.000111 / 0.000102 | 8.319972 / 9.416141 | 0.186600 / 0.176048 |
| chain256-cold | 0.000098 / 0.000095 | 6.758544 / 7.289618 | 0.170614 / 0.195172 |
| dense12-cold | 0.000141 / 0.000179 | 31.517793 / 31.505332 | 0.201699 / 0.202940 |
| destruction-stimulus | 0.001854 / 0.002897 | 3.948622 / 4.249911 | 0.159666 / 0.187629 |
| city25-initial-impact | 0.000117 / 0.000087 | 40.634569 / 38.490864 | 0.189290 / 0.155321 |
| city256-intact-idle | 0.000197 / 0.000165 | 64.945292 / 66.506493 | 0.211946 / 0.240878 |
| city256-late-debris | 0.000225 / 0.000120 | 430.869082 / 430.866136 | 0.234853 / 0.244344 |

| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |
|---|---:|---:|
| bridge64-cold | 565.105 / 523.141 / 510.993 | 184–184 / 184–184 |
| chain256-cold | 584.588 / 535.764 / 484.347 | 492–492 / 492–492 |
| dense12-cold | 622.076 / 492.922 / 502.083 | 34–34 / 34–34 |
| destruction-stimulus | 492.478 / 487.662 / 541.060 | 1–1 / 1–1 |
| city25-initial-impact | 615.835 / 666.697 / 661.136 | 304–304 / 304–304 |
| city256-intact-idle | 1792.867 / 1786.712 / 1764.407 | 88–88 / 88–88 |
| city256-late-debris | 1934.846 / 1876.433 / 1787.830 | 1084–1084 / 1084–1084 |
