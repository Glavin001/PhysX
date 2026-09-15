# Baseline collection checkpoint

Recorded 2026-09-13T02:17:58Z. **Collection is not finished.** No runtime optimization has started; after collection and report review, optimization remains paused for the user.

## Completed full continuous simulations

These are complete native physics/destruction trajectories, including required correction and second stress. They use ordinary APIs with sleeping enabled and no snapshot restores. Startup is separate. Each row is one fresh unprofiled 180-tick process; separate Systems runs match physical-work and iteration histories, which is not a full trajectory equivalence proof.

| Scenario | Buildings / chunks / bonds | Mean / observed peak ms | 60 Hz misses | Initialization ms |
|---|---:|---:|---:|---:|
| idle-256 | 256 / 113,664 / 229,376 | 1.780 / 14.139 | 0/180 | 2180.116 |
| impacts-256 | 256 / 113,664 / 229,376 | 54.861 / 182.351 | 99/180 | 2178.645 |

Heavy peaks occur during active fracture/correction, not initialization. In the fresh heavy run, tick82 took182.351ms with39,499 reported contacts,28,596 newly broken bonds,5,204 motion clusters,520 stress islands,288 maximum stress iterations and one correction/two stress passes. These counts are not interchangeable measures of work.

[Four saved 600-tick control runs per workload](continuous-controls.md) also cover later debris: heavy means51.028–51.676ms and519/600 missed deadlines in every run. Keep the 180- and600-tick cohorts separate.

## Restored scenario baseline

All52 scenarios retain40 unprofiled ticks each (20 A0 +20 A1), with restore excluded. Across the suite,28/52 pooled means exceed60Hz;1,097/2,080 ticks miss. Selected difficult cases below; [all52 with stages, spread and physical scale](all-scenarios.md).

| Scenario | A0 / A1 mean ms | A0 / A1 observed maximum ms |
|---|---:|---:|
| bridge64-cold | 8.744 / 8.734 | 11.702 / 11.234 |
| dense12-cold | 31.037 / 30.849 | 32.863 / 33.073 |
| tower64-cold | 107.885 / 108.169 | 110.274 / 111.561 |
| city256-intact-idle | 60.711 / 60.826 | 76.776 / 81.674 |
| city256-initial-impact | 222.703 / 212.549 | 234.849 / 248.629 |
| city256-late-debris | 350.885 / 334.403 | 407.887 / 401.877 |

A restored intact-idle tick rebuilds disposable execution state and is much more expensive than a naturally warm continuous idle tick. Both exclude restore cost; they measure different cache histories. Do not call their difference a runtime speedup.

## Work still in flight

| Tier | Status at checkpoint |
|---|---|
| cpu-full | complete; 52 complete |
| graphs-full | running; 45 complete |
| continuous200 | queued_before_ordinary_counters; 0 complete |
| configs-full | not_started; 0 complete |
| warm | complete; 2 complete |
| phase-only | waiting_primary_campaign; 0 complete |
| allocation-pilots | waiting_phase_campaign; 0 complete |

Seven existing continuous fixtures are queued for200 ticks each, with three plain processes plus separate native-phase and Systems diagnostics: idle256, bombardment16/256, wall1, localized impact256, bridge64, tower64. The plain cohort totals4,200 ticks with zero restores. This is additional temporal/scaling coverage, not replacement of any of the52 snapshot cases.

The longer hardware-counter stage replays selected GPU work to collect different metric groups. Its wall duration does not represent the cost of running the simulation in real time. All significant ordinary-kernel configurations are still pending on this exact frozen runtime; the completed old52-case captures remain historical evidence from a different numerical policy. Conditional graph counters are aggregate, not per-node/source metrics.

[Working analysis and ranked optimization plan](analysis-plan.md). [Current coordinator status](campaign-status.json). This dated checkpoint will remain explicit even when the main report is completed.
