# Corrected N24 exploratory application screen

Headless sequential unprofiled A/B/A, same52-suite frozen light subset and per-case counts. Complete tick includes commands, integrated physics/destruction/correction and required completion. Restore and checks excluded. Each arm self-repeatability and fixed light semantic counters required. Cross-build force/health failures retained; not equal-quality speedup or promotion.

**No implementation is promoted.** All frozen self-repeatability and light semantic checks pass; the impact/debris force and exact-health cross-build gates remain failed.

| Scenario | Samples per arm | A before mean / max ms | B mean / max ms | A after mean / max ms | Exploratory mean change |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 8 | 9.048 / 11.898 | 1141.407 / 1146.348 | 9.281 / 11.724 | +12354.23% |
| chain256-cold | 8 | 7.512 / 10.532 | 539.812 / 542.909 | 7.466 / 9.844 | +7107.90% |
| dense12-cold | 6 | 31.493 / 33.522 | 31.684 / 34.136 | 31.653 / 34.351 | +0.35% |
| destruction-stimulus | 8 | 4.347 / 7.868 | 4.436 / 8.159 | 4.341 / 7.798 | +2.11% |
| city25-initial-impact | 4 | 40.321 / 43.612 | 146.208 / 150.840 | 41.742 / 48.388 | +256.33% |
| city256-intact-idle | 3 | 64.892 / 74.360 | 185.923 / 192.564 | 68.342 / 77.361 | +179.09% |
| city256-late-debris | 3 | 350.509 / 394.826 | 642.425 / 679.347 | 344.221 / 384.436 | +84.94% |

[All samples, stages, setup/restore costs, work counters, exact deadline misses and quality failures](n24-equation-screen-metrics.json). Raw unprofiled runs: `out/n24-live-cycle-tail-20260912/exploratory-screen/`. Existing warm scenario references and CPU/GPU work attribution remain separate in [the work census](removal-work-census.md). No warm or full52 candidate timing qualification is inferred from this shortlist.

Both runtime arms share empty-child correction `3e1e39c262149d35ddb66ab05c3ea1b313f41c20`. The full hierarchy mathematical/initcheck suite passes through100000 nodes; rebuilt analytic/3D/motion and standalone memory/initialization/synchronization checks pass in both arms. Integrated normal asynchronous memcheck passes twelve restored ticks across flying, city25 impact and city256 debris. Original broken masks, ownership, loads, crush and checked body state agree in those comparisons; force/health differences do not constitute acceptance.

The timeline confirms1,137.56ms of a1,153.47ms instrumented bridge tick in `componentStressSolve`; GPU activity outside that kernel is under0.4ms. The full hardware capture succeeds (one selected launch,39 passes), with both Systems and NCU physical observations passing against the same candidate's unprofiled reference. [Counters and source evidence](n24-equation-profile.json).

The source diagnosis revises the initial terminal-solve guess:80.2% of not-issued warp samples are short-scoreboard stalls,9.1% barrier.66.0% of all such samples map to one shuffle source location. `cycleTiledRows` deliberately reproduces eight cooperative CTA tiles sequentially inside one local block, even for empty or disabled contributions. Each tile repeats full-block reductions. This is concrete unnecessary scheduling work; source samples are not milliseconds and do not prove the net benefit of a replacement. Zero theoretical local sectors in this capture do not support a spill-traffic explanation.

Next test concurrent row ownership in the local cycle, preserving all bond terms, FP64 arithmetic, symmetry and original physical requirements. Cooperative large-component scheduling is a separate ownership case. Cached triangular inverses are lower priority because this capture does not support them as the main cost. Tile remains a possible implementation tool for the resulting regular row work; it cannot infer away an explicitly requested eight-tile schedule.

This full A/B/A screen rejects N24 independently of its quality failures. No warm/full52 extension is justified for the current candidate. The isolated empty-tail correctness fix remains available for follow-ups, but no application implementation or numerical policy is promoted. Batch stays18/20; this is diagnosis of the same hypothesis, not another completed optimization experiment.

All owned candidate jobs are terminal. The original counter collector resumed after47/52 ordinary cases; CPU/graph52/52. Service restoration watcher remains live. Do not overlap a new GPU experiment with that collector.
