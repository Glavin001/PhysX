# Thirty-second optimization screen

The fixed light preset passes in **27.99 s and 28.44 s** on the current shared RTX 5060 Ti. Each run covers seven scenarios and 40 independent complete ticks. Timing is measured from before argument/input processing through report generation: it includes startup, input hashing, restore, checks, teardown and reporting. This is the budget for **one baseline or candidate arm**; A/B is approximately one minute and A/B/A approximately 90 seconds.

## Shortlist and measured signal

| Scenario | Chunks | Repeats | Full tick mean / peak ms | What it tests |
|---|---:|---:|---:|---|
| bridge64-cold | 768 | 8 | 8.571 / 10.619 | Spanning structure, two supports, bending and load redistribution. |
| chain256-cold | 256 | 8 | 7.243 / 10.107 | Long sparse path; equilibrium propagation and solver iteration sensitivity. |
| dense12-cold | 1,728 | 6 | 33.472 / 36.885 | Dense three-dimensional loops and redundant load paths. |
| destruction-stimulus | 2 | 8 | 3.452 / 4.923 | CPU command submission inside the full tick. |
| city25-initial-impact | 11,100 | 4 | 41.205 / 46.275 | 11,100 chunks: contact, first fracture, correction and second stress solve. |
| city256-intact-idle | 113,664 | 3 | 62.529 / 69.986 | 113,664 chunks: intact gravity equilibrium with 256 separate buildings. |
| city256-late-debris | 113,664 | 3 | 435.357 / 451.327 | 113,664 chunks: many fragmented owners, contacts and further fracture/correction. |

Values are from the second confirmation run. All samples, including the first tick, are retained. Detailed spread, medians, phases, active work and deadline misses are in [the report](confirmation-report.md), with structured data in [JSON](confirmation-report.json). The full tick includes CPU commands, integrated rigid physics and destruction, GPU work/transfers/synchronization, and correction plus the second stress solve when needed. Restore and validation are excluded from these tick numbers, but included in the 30-second suite budget.

## Checks and limits

Both final light runs pass all repeatability/import/quality checks and the frozen fracture/correction/cluster counters. Initial impact and large late debris each actually execute one correction and two stress evaluations. The other destructive cases execute one stress evaluation. Counter expectations come from the previously qualified 52-case physical run, rather than names or assumed activity.

The preset retains the existing exact physical-state re-export check, repeated physical output comparison, damage monotonicity, convergence, motion and correction limits. It omits the large diagnostic observation dumps used for cross-build physical comparisons. A light pass therefore prioritizes a candidate; it does **not** replace full candidate/control physical validation. Three samples in the largest cases have limited precision. Use adjacent same-preset controls, examine spread, and expand ambiguous signals rather than asserting a small win from this screen. Never change case counts, inputs or tolerances between arms.

The initial nine-case/64-tick trial passed correctness but exceeded budget at 32.95 s. Free flight and tower were removed from this shortlist, and repetition counts fixed to 40 total ticks. They remain in the complete suite, alongside cantilever, ladder, panel and all other scales/events. Largest idle and debris remain 113,664 chunks. The full default manifest still contains the same 52 cases, 20 repetitions, and identical input hashes. Light case/repetition overrides are rejected.

## Commands and promotion policy

Use [the exact command in OPTIMIZATION.md](../../../OPTIMIZATION.md#thirty-second-candidate-screen), adding `--preset light` to the existing suite runner. The preset is [destruction-snapshot-light.json](../../../tools/profiles/destruction-snapshot-light.json). The runner writes `report.md`, `report.json`, `campaign.json`, input/artifact receipts, and `suite-summary.json`. Actual wall time and `within_target` are recorded separately from correctness; a slower machine/run is not silently truncated.

Finalists must pass the **full 52-case ×20** run with diagnostic observations and cross-build physical comparison, full asynchronous memory qualification, and continuous ordinary/sleeping physics plus matched idle/heavy timing. Use the full commands already in OPTIMIZATION.md. `--preset full` remains the default. No cases were deleted from the master catalog and no runtime/CUDA implementation changed. This setup work is not an N-series experiment or an application speedup.

Raw evidence: `out/snapshot-light-20260911/`. Matching probe/runtime artifacts: `out/snapshot-reset-20260911/local-probe/` and `local-artifacts/`. Two final light runs used identical preset and input hashes. All owned GPU jobs ended.
