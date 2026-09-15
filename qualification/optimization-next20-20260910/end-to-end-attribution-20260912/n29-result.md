# N29: correct exact-solve reuse, mixed application result; not promoted

Commit `91c27a12b5ea5ec308cfe9187a40a84f1b978bd6` passes original numerical/targeted asynchronous memory gates,120 light ticks,480 confirmation ticks, and12 subsequent profiled physical ticks. Per-component equality is established before aliasing; original recurrence, force recovery and material verdicts remain unchanged.

Twenty samples per arm: city256 idle54.137ms versus66.853/59.563 controls and city25 impact32.474 versus37.363/38.380 improve in this cohort. Large impact218.320 versus212.063/219.188 is neutral. Large debris353.410 versus345.900/333.093 and two-chunk stimulus4.239 versus3.190/3.392 regress. Control drift and observed maxima remain visible in [all eight scenario/stage results](n29-confirmation.md). **No full52/warm promotion or application-wide speedup.** Main runtime/SDK unchanged.

Matched Systems traces show idle component-solve aggregate8.386→1.339ms, with0.785ms of new matching/scatter work. Debris component solves66.528→66.453ms while matching/scatter costs2.559ms. These are profiler-only timings, not application savings. Tiny-scene profiling does not reproduce its normal timing regression. Within-tick allocation counts match both arms (9 tiny,8 idle,41 debris), so three new allocations do not explain that tick regression. Preserve this refuted suspicion; do not optimize it as a proven cause.

The original profile attempt used a normal probe without snapshot NVTX ranges. The application completed, but attribution correctly failed. `profiles-v2` uses the existing qualified profiling probe and all six captured cases pass same-arm normal physical comparisons. No checker was weakened.

Next N29b integrates a cheap current-node-input key into existing ordinal initialization, reads an immutable scratch key in the full fingerprint phase, and skips full operator/cache scans where no other key matches. Full comparisons still decide equality. Captured eligible-node scans rejected: city25 initial100%/correction44%; city64 initial93.75–96.88%/correction56.25–62.5%; city256 initial78.52–91.80%/correction33.20–33.59%; city256 idle0% (all potential reuse preserved); debris first100%/correction99.99%. These are counts, not speedups. [Census](n29-cheap-key-census.json).

N29b is isolated commit `c2644fa00b64f6a3f34ca8ced02b5825803bd860`, building under `out/n29b-cheap-rejection-20260913/`. No new launch or allocation; original full comparison/solve/scatter stays unchanged. Two new tests cover unique keys and one eligible component. It remains unqualified until original tests, asynchronous checks and full-step comparisons pass.

[Structured evidence and profile locations](n29-result.json).
