# N29b outcome — 2026-09-13

**Closed without promotion.** Source `c2644fa00b64f6a3f34ca8ced02b5825803bd860` remains isolated. All52 physical comparisons pass3,120 restored ticks; all eight flagged cases pass a further480 physical ticks. Continuous7,200-tick physical-work and iteration histories match. Original/20 exact tests and focused asynchronous memory checks pass. This is not full memory/trajectory acceptance: that extension is not pursued for the regressing candidate.

Warm heavy candidate means51.060–51.556ms versus51.028–51.676 controls; maxima164.154–169.612 versus175.622–194.571ms. All heavy runs still miss60Hz on519/600 ticks. Idle candidate means1.453/1.853ms versus1.271–1.704 controls, zero60Hz misses; possible0.138ms pooled cost remains unqualified.

The full52 cohort shows selected idle/cascade improvements and other mixed results. Eight negative descriptive intervals were repeated. The city64 initial-impact and late-debris regression signals did not repeat, while ladder128-warm did: candidate5.699ms versus4.909/4.998ms, about0.745ms slower than pooled controls. Full52 originally measured5.693 versus5.387/4.922ms for the same case. Controls drift and individual-tick bootstrap intervals are not run-level causal confidence. Nonetheless the repeated ladder cost plus unresolved idle mean prevent a broad promotion, despite promising heavy peaks.

## Repeat of all eight flagged cases

| Scenario | A before mean / max ms | Candidate mean / max ms | A after mean / max ms | Candidate60Hz misses |
|---|---:|---:|---:|---:|
| chain256-cold | 6.938 / 9.901 | 7.271 / 10.671 | 7.299 / 9.763 | 0/20 |
| chain32-warm | 2.600 / 5.958 | 2.689 / 7.063 | 2.606 / 9.874 | 0/20 |
| destruction-cold | 3.432 / 6.881 | 2.606 / 6.760 | 3.278 / 7.124 | 0/20 |
| destruction-onset | 2.883 / 4.687 | 4.044 / 8.215 | 4.304 / 7.946 | 0/20 |
| destruction-stimulus | 4.013 / 8.045 | 4.073 / 8.004 | 4.141 / 7.475 | 0/20 |
| ladder128-warm | 4.909 / 7.564 | 5.699 / 8.836 | 4.998 / 7.845 | 0/20 |
| city64-initial-impact | 54.953 / 67.605 | 55.527 / 61.674 | 61.574 / 82.094 | 20/20 |
| city64-late-debris | 123.994 / 169.267 | 120.376 / 157.014 | 127.088 / 141.874 | 20/20 |

[All52 scenarios, stages, spread, setup and exact misses](n29b-full52.md). [Repeat details and commands](n29b-regression-repeat.json). [Continuous stages/setup and limits](n29b-warm.md). [Original N29 causal profiles](n29-result.md). [Portable result package](../../../reports/destruction-exact-solve-reuse/README.md).

Next independent experiment N30 changes the medium-component algorithm. A separate follow-up hypothesis would bypass the equivalence pipeline when fewer than two current components can participate. With one component equality sharing is impossible, yet the current source still launches the search pipeline. This would remove provably unnecessary work; it is NOT yet proven to explain the0.745ms ladder regression. Hypothesis0–0.8ms per affected small tick, low confidence; exact current-state guard and stale-leader invalidation are required. No such change has been implemented or benchmarked.
