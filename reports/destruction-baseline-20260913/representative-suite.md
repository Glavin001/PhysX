**Measured follow-up:** the nine-case protocol now completes in284.09s including Systems/counters/checks. [All scenarios and measured uncertainty/decision procedure](measured-experiment-protocol.md). The original proposal below is preserved; its unimplemented statements are historical.

# Representative measurements within a five-minute experiment

Recommended policy,2026-09-13. The existing seven-case timing+Systems loop is measured at164 seconds. The broader protocol below targets300 seconds; it is not yet an end-to-end calibrated implementation. The frozen52-case suite remains intact. The runnable wrapper currently supports snapshot A/B/A and selected profiling; mixed ABBA orders and continuous comparisons require orchestration before calling this expanded preset qualified.

## Fixed core: nine scenarios

| Scenario | Physical scale | What it protects | Existing measured full-step mean ms |
|---|---|---|---:|
| Continuous idle-256,180 ticks | 113,664 chunks;229,376 bonds;no projectiles | Warm equilibrium and sleeping; unchanged inputs | 1.780 |
| Continuous impacts-256,180 ticks | 113,664 chunks;229,376 bonds;256 projectiles | First contact, fracture/correction and continuing active debris | 54.861 |
| Restored bridge64-cold | 768 chunks;1,524 bonds | Two supports, bending and alternative load paths | 8.744 / 8.734 |
| Restored chain256-cold | 256 chunks;255 bonds | Long sparse load path and slow equilibrium propagation | 6.598 / 6.384 |
| Restored dense12-cold | 1,728 chunks;4,752 bonds | Dense three-dimensional bond loops | 31.037 / 30.849 |
| Restored tower64-cold | 2,368 chunks;4,900 bonds | Tall looped structure and long-range convergence | 107.885 / 108.169 |
| Restored city25-initial-impact | 11,100 chunks;22,400 bonds | Moderate-scale first fracture, correction and second stress | 39.535 / 38.903 |
| Restored city256-intact-idle | 113,664 chunks;229,376 bonds | Large authored state and first-use equilibrium work | 60.711 / 60.826 |
| Restored city256-late-debris | 113,664 chunks;229,376 bonds | Large fragmented population, contact pressure and further fracture | 350.885 / 334.403 |

Continuous values come from the fresh unprofiled180-tick cohort; snapshot values are A0/A1 means from20 restores each. They are different cache histories and sample schedules, not a pooled comparison. The continuous idle peak is14.139ms with0/180 missed60Hz deadlines; continuous heavy peak182.351ms with99/180 misses. [All saved snapshot means, maxima, stages and counts](all-scenarios.md).

The core replaces the tiny two-chunk stimulus slot with tower coverage; the original light preset and stimulus test are preserved. Every tick includes CPU preparation, current physics/contacts, GPU stress/material/topology, transfers/waits, accepted publication and up to one correction with a second stress pass. Restore remains outside tick timing. Initialization and first-use costs remain visible.

## Spend repetitions on independent evidence

The continuous cases use A/B/B/A: two independent processes per arm,180 ticks per process. Report per-process mean and peak, phase histories and deadline misses. Treat the process as the independent repeat;1440 consecutive tick samples across the two cases are not1440 independent trials.

All seven snapshot cases run A/B/A, using fixed per-process counts8,8,6,4,6,4,4 in table order (40 ticks per arm). Before a change is measured, select two primary affected snapshot cases and add a second independent B process to each, yielding A/B/B/A. Primary cases default to moderate first impact and large debris for fragmentation work; solver changes may choose chain/tower/dense instead. The remaining cases are regression guards, not high-confidence proofs of small gains. First-use weighting remains equal across arms for each schedule.

This deliberately separates discovery from confirmation. A guardrail improvement cannot be promoted from one B process. Any claimed gain needs repeat confirmation with both candidate process blocks agreeing, stable current controls, an effect larger than observed drift/noise, unchanged required physical quality and supporting profile evidence. If uncertainty is larger than the effect, report **inconclusive** and use a separate focused balanced run. No arbitrary sample count or five-minute deadline guarantees resolving every small effect.

The existing identical-build runs demonstrate the issue: large debris produced395.823,382.327 and378.510ms across A/A/A; large restored idle64.713,66.544 and58.054ms. These are the same implementation. [All calibration means and stages](fast-calibration.md), [observed noise data](data/fast-loop-noise.json). These spans are diagnostic observations, not95% confidence bounds.

## Hypothesis-specific companions

| Change being tested | Add/check from the existing catalog | Why |
|---|---|---|
| Anchoring, bending or sparse solver | cantilever64;bridge64;chain32;ladder128 | One-sided support, span, short-path control and sparse loops |
| Surface/loop layout | panel32;dense12;tower64 | Thin versus volumetric and tall structures |
| Damage validity or changed loads | destruction-damaged;city256-fragmented-loaded;city256-ten-second-debris | Persistent damage, surviving load paths and late state |
| Contact/ownership/topology work | city64/city256 initial impact and cascading fracture;building-fragmented | Scale-dependent allocation, migration and repeated topology changes |
| Commands, ordinary physics or sleeping | destruction-stimulus;flying;resting;sliding;city256-airborne | Input handling, unaffected rigid bodies, friction and sleep guards |
| Localized penetration | Existing wall-1 and localized-256 continuous fixtures | One active building versus widespread bombardment; these are authoring/native fixtures, not claimed members of the52 restored catalog |

Choose companions before seeing candidate results. Prefer an affected core case as the profile target. Add a companion when the mechanism would otherwise go untested; record its cost and keep both arms identical. If a large companion does not fit with complete profiling and checks, use another bounded focused block rather than silently deleting a core guard or shortening only the slower arm. Full52 qualification prevents missing cases from disappearing across optimization campaigns.

## Budget and decision

Aim for roughly210–240 seconds of timing/physical comparison and30–60 seconds of selected profiling/reporting. These are planning allocations, not measured phase guarantees for the new nine-case protocol. Systems records every traced launch/copy and CPU activity within one or two affected complete ticks. NCU samples representative launches with the counters required by the hypothesis. A CPU-only bookkeeping hypothesis may need Systems without fresh NCU counters. Existing baseline profiles supply broad context.

Do not use one weighted average of these scenarios as an invented game workload. Report each case, its scale, mean/peak, misses, stage/iteration/physical-work changes, control drift and qualification. Continuous heavy is the primary natural-runtime outcome; restored cases explain which traits regress or improve. Observed peaks are not worst-case bounds; later600-tick/full52 confirmation remains necessary for finalists.

The planned preset is [destruction-experiment-core.json](../../tools/profiles/destruction-experiment-core.json). The current [fast-loop command](fast-profiled-loop.md) is still the measured snapshot+profile implementation. No runtime optimization, changed fidelity threshold or new speedup is claimed.
