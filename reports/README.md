WIP branch handoff: [current implementation, validation limits and portable candidate source](../docs/destruction/HANDOFF-20260915-ownership-wip.md).

# Reports

Each report lives in `reports/<report-headline>/` with its analysis, figures,
structured measurements and source provenance. Reports preserve dated evidence;
later results are linked explicitly rather than silently changing old conclusions.

| Report | Published | Evidence and scope |
|---|---|---|
| [GPU ownership hypothesis and acceptance contract](destruction-gpu-ownership-hypothesis-20260915/README.md) | 2026-09-15 | Complete fracture-to-correction migration proposal and [implementation checklist](destruction-gpu-ownership-hypothesis-20260915/PLAN.md); explicit scope, 10 ms full-impact-window target, physical and regression gates; isolated transaction foundation built; native GPU checks pass, including focused memory/synchronization; main contact/solver migration and performance validation remain pending |
| [Ownership and scheduling implementation](destruction-ownership-implementation-20260915/README.md) | 2026-09-15 | Three isolated lifecycle/handoff changes; coalesced readback passes full52 warm physical gates, timing confirmation and continuous checks recorded separately; native initialization gap remains; selected runtime unchanged |
| [CPU/GPU ownership and scheduling audit](destruction-cpu-gpu-boundaries-20260914/README.md) | 2026-09-14 | Sleeping restricts GPU island ownership; first-impact CPU registration gates corrected physics; graph-launch time overlaps stress; all52 boundary tables, event-instance audit and current/proposed data-flow diagrams; no runtime change |
| [Warm destruction bottlenecks and removal priorities](destruction-warm-bottlenecks-20260914/README.md) | 2026-09-14 | Offline full52 warm analysis: data ownership, impact/debris timelines, register and issue limits, CPU scope/transfer attribution, ranked experiments and failed hypotheses; no runtime change |
| [Full52 warm measurements and attribution](destruction-warm-full52-20260914/README.md) | 2026-09-14 | Complete52/52 warm timings, physical gates, CPU/GPU traces and core counters; full-step plots, stages, work, saved evidence and explicit profiling limits |
| [Restore, warm, measure](destruction-warm-window-benchmarks-20260914/README.md) | 2026-09-14 | New complete-step warm-window benchmark; fixed physical warmup, matched endpoint/work checks, qualified short windows and rejected long-history comparison; runtime unchanged |
| [Native convergence policy experiment](destruction-convergence-policy-20260913/README.md) | 2026-09-13 | Four stopping policies, 2,919 ticks in 203.56s; heavy mean 55.10→45.43→23.16ms, with changed fracture behavior; strict rebuild control passes; production unchanged |
| [Vibe versus native PhysX destruction](destruction-vibe-native-comparison-20260913/README.md) | 2026-09-13 | Offline source and report comparison; 7,480 archived ticks verified; CPU/GPU ownership, numerical contracts, live-game versus restored/continuous timing, interactive explorer; no matched cross-engine speed winner established |
| [Removal implementation experiments](destruction-removal-implementation-20260913/README.md) | 2026-09-13 | Prepared-factor GPU replay; two isolated topology candidates pass nine-case profiled screens without a substantial verified full-step gain; all scenario, peak, stage and deadline results; major integration work remains |
| [Workspace checkpoint](destruction-workspace-checkpoint-20260913/README.md) | 2026-09-13 | Source, skills, documentation, readable reports and provenance saved; raw experimental data remains local and ignored; mixed source is not promoted |
| [Destruction regression suite](destruction-regression-suite/README.md) | 2026-09-13 | Physical checker cleanup, independent equilibrium/motion/damage oracles; 52 historical scenarios rechecked; remaining GPU validation queued; unequal-mass model gap explicit |
| [Selected destruction baseline](destruction-baseline-20260913/README.md) | 2026-09-13 | Exhaustive expansion stopped at user budget; CPU 52/52 and graph 48/52 preserved. [Fast profiled-loop calibration](destruction-baseline-20260913/fast-calibration.md): 164s for timing plus Systems; NCU cutoff retained. [Measured nine-case protocol and precision](destruction-baseline-20260913/measured-experiment-protocol.md):284.09s complete including Systems/counters;416.49s additional paired noise calibration. |
| [Destruction test coverage audit](destruction-test-coverage-audit/README.md) | 2026-09-13 | Native, snapshot, continuous, numerical, legacy and browser test contracts; registration inventory, checker challenges and coverage gaps |
| [Exact current-solve reuse](destruction-exact-solve-reuse/README.md) | 2026-09-13 | N29b52 cases plus8-case repeat and continuous idle/heavy; not promoted after repeated ladder regression |
| [Destruction full-step bottlenecks](destruction-full-step-bottlenecks/README.md) | 2026-09-13 | 2026-09-12 N20 cohort: 52 restored scenarios, continuous idle/heavy runs, CPU/GPU data flow and attribution |

Use the repository [insight-reporting skill](../.agents/skills/insight-reporting/SKILL.md)
when preparing or updating an analytical report. Benchmark execution and
optimization acceptance continue to follow [OPTIMIZATION.md](../OPTIMIZATION.md).
