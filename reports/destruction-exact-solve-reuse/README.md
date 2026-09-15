# Exact current-solve reuse: full-tick qualification

Published and measured2026-09-13. **N29b is unpromoted.** All52 scenario physical comparisons pass3,120 complete ticks:20 A-before,20 candidate,20 A-after each. Performance is mixed; the eight-case repeat confirms a ladder regression. This candidate is closed without promotion.

Candidate `c2644fa00b64f6a3f34ca8ced02b5825803bd860`; control `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`. Ordinary APIs, sleeping, maximum one correction. Restore, validation and teardown are outside full-step timing; commands, CPU/GPU integration, stress/material work, transfers, waits and correction remain inside. Initialization and restore are recorded separately. No first-use/outlier exclusions.

The GPU detects exactly equal current anchored problems, solves once per equality group and scatters results before unchanged material evaluation. An inexpensive immutable load key rejects unique inputs before full comparison. This does not use stale inputs or share merely similar solutions.

## Large city and structural results

| Scenario | A before mean / max ms | Candidate mean / max ms | A after mean / max ms | Candidate60Hz misses |
|---|---:|---:|---:|---:|
| bridge64-cold | 8.744 / 11.702 | 8.628 / 13.819 | 8.734 / 11.234 | 0/20 |
| chain256-cold | 6.598 / 7.871 | 7.078 / 10.475 | 6.384 / 9.161 | 0/20 |
| dense12-cold | 31.037 / 32.863 | 30.880 / 34.264 | 30.849 / 33.073 | 20/20 |
| destruction-stimulus | 3.299 / 7.996 | 4.017 / 7.898 | 2.910 / 6.705 | 0/20 |
| tower64-cold | 107.885 / 110.274 | 108.170 / 111.460 | 108.169 / 111.561 | 20/20 |
| city25-intact-idle | 9.686 / 12.708 | 9.173 / 13.501 | 9.790 / 12.920 | 0/20 |
| city25-airborne | 10.791 / 16.753 | 9.741 / 13.643 | 10.718 / 14.110 | 0/20 |
| city25-initial-impact | 39.535 / 49.892 | 36.008 / 45.316 | 38.903 / 47.935 | 20/20 |
| city25-post-impact | 22.474 / 29.413 | 22.295 / 34.906 | 22.429 / 28.915 | 20/20 |
| city25-cascading-fracture | 39.097 / 49.896 | 38.343 / 49.228 | 40.581 / 50.606 | 20/20 |
| city25-fragmented-loaded | 52.568 / 61.315 | 53.209 / 65.424 | 51.503 / 62.744 | 20/20 |
| city25-late-debris | 66.861 / 75.383 | 67.679 / 82.363 | 69.164 / 86.901 | 20/20 |
| city25-ten-second-debris | 68.771 / 88.203 | 68.890 / 90.203 | 62.816 / 86.306 | 20/20 |
| city64-intact-idle | 18.670 / 23.709 | 15.588 / 21.439 | 16.198 / 21.347 | 3/20 |
| city64-airborne | 18.083 / 23.105 | 16.240 / 19.276 | 17.924 / 24.369 | 8/20 |
| city64-initial-impact | 59.599 / 78.027 | 63.738 / 83.085 | 60.787 / 77.638 | 20/20 |
| city64-post-impact | 36.218 / 48.444 | 37.468 / 48.141 | 36.083 / 47.023 | 20/20 |
| city64-cascading-fracture | 57.055 / 73.030 | 56.988 / 69.226 | 55.883 / 74.086 | 20/20 |
| city64-fragmented-loaded | 88.726 / 112.849 | 87.647 / 104.542 | 86.789 / 102.250 | 20/20 |
| city64-late-debris | 130.395 / 150.872 | 132.430 / 158.933 | 123.426 / 154.962 | 20/20 |
| city64-ten-second-debris | 100.945 / 136.854 | 97.846 / 133.170 | 100.042 / 140.173 | 20/20 |
| city256-intact-idle | 60.711 / 76.776 | 56.508 / 73.586 | 60.826 / 81.674 | 20/20 |
| city256-airborne | 65.417 / 82.021 | 62.606 / 80.119 | 65.469 / 78.018 | 20/20 |
| city256-initial-impact | 222.703 / 234.849 | 215.163 / 270.599 | 212.549 / 248.629 | 20/20 |
| city256-post-impact | 125.797 / 185.274 | 135.489 / 164.600 | 134.581 / 174.292 | 20/20 |
| city256-cascading-fracture | 192.704 / 217.039 | 180.297 / 206.111 | 190.312 / 223.961 | 20/20 |
| city256-fragmented-loaded | 270.831 / 322.840 | 277.552 / 321.390 | 272.240 / 315.134 | 20/20 |
| city256-late-debris | 350.885 / 407.887 | 339.540 / 419.868 | 334.403 / 401.877 | 20/20 |
| city256-ten-second-debris | 258.200 / 336.654 | 249.329 / 349.815 | 240.951 / 334.353 | 20/20 |

All52 cases, spread, stages, setup, iterations and exact deadline misses: [full table](evidence/full52.md), [CSV](scenarios.csv), [all3,120 samples](samples.csv), [module/input/checker identity](evidence/full52.json). Maxima are observed sample maxima, not bounds.

## Continuous idle and heavy — separate cohort

Two600-tick runs per A-before/B/A-after stage. All7,200 recorded physical-work/convergence and iteration histories match. Candidate heavy means51.060–51.556ms versus controls51.028–51.676; peaks164.154–169.612 versus175.622–194.571ms. Every heavy run misses60Hz on519/600 ticks. Idle candidate means1.453/1.853ms versus controls1.271–1.704ms; maxima7.261/7.803 versus12.038–13.508ms, zero60Hz misses. The possible0.138ms pooled idle cost remains unresolved; consecutive frames are not independent trials.

[All continuous stages and initialization](evidence/warm.md), [raw continuous report](evidence/warm.json). Work/history checks do not replace body/force trajectory qualification.

## Decision and next action

Original N29 had mixed/regressing application performance and was not promoted. N29b is closed without promotion after a repeated ladder regression. Full52 asynchronous memory and wall body/force trajectory extensions are not pursued for this regressing candidate. No runtime/SDK deployment. The eight preselected negative signals completed a fresh20/20/20 repeat after full52; all480 physical ticks pass. Ladder remains slower:5.699ms versus4.909/4.998ms controls. City64 impact/debris regression signals did not repeat. [All eight repeat means/maxima/stages](evidence/regression-repeat.md). The driver retains its historical `impact64-repeat` name.

Descriptive negative intervals: chain256-cold, chain32-warm, destruction-cold, destruction-onset, destruction-stimulus, ladder128-warm, city64-initial-impact, city64-late-debris. Positive intervals: cantilever64-warm, city25-airborne, city25-initial-impact, city64-intact-idle, city64-airborne, city256-intact-idle, city256-cascading-fracture. These are screening signals, not multiplicity/drift-corrected evidence of causal gains or losses.

[Prior causal profiles and rejected original matcher](../../qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n29-result.md). [N30 independent medium-component hypothesis](../../qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n30-preparation.md).

## Provenance

[Source-summary hashes and limitations](provenance.json). Raw physical observations remain in the original `out/n29b-cheap-rejection-20260913/` archive; this package contains summaries and timing samples, not full worlds or profiler captures. All saved timing summaries were recomputed from samples, including stage sums and exact1000/60 deadline tests. No GPU rerun, browser rendering or original heavy capture hash audit was performed to generate this report. [Recompute scenario tables and validate all samples](rebuild.py): `python3 reports/destruction-exact-solve-reuse/rebuild.py`. This uses only the archived package and does not alter experiment status.

The [exact physical checker used by these runs](evidence/physical-checker.py) is archived at SHA256`6f256f04de9fd87774593cba6ef1dc5455bfbb5cbbd909779ec9e3afb0bbab31`. Concurrent later checker edits were preserved separately and were not used to qualify these experiments.
