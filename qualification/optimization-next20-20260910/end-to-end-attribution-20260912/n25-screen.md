# N25 local row ownership application screen

Headless sequential unprofiled A/B/A, same52-suite frozen light subset and per-case counts. Complete tick includes commands, integrated physics/destruction/correction and required completion. Restore and checks excluded. Each arm self-repeatability and fixed light semantic counters required. Cross-build force/health failures retained; not equal-quality speedup or promotion.

**No implementation is promoted.** All frozen self-repeatability and light semantic checks pass; the impact/debris force and exact-health cross-build gates remain failed.

| Scenario | Samples per arm | A before mean / max ms | B mean / max ms | A after mean / max ms | Exploratory mean change |
|---|---:|---:|---:|---:|---:|
| bridge64-cold | 8 | 8.809 / 11.387 | 95.734 / 97.324 | 8.782 / 11.361 | +988.45% |
| chain256-cold | 8 | 6.749 / 10.165 | 19.313 / 22.004 | 7.507 / 9.879 | +170.95% |
| dense12-cold | 6 | 31.816 / 33.749 | 31.606 / 33.931 | 31.392 / 33.431 | +0.00% |
| destruction-stimulus | 8 | 4.428 / 7.619 | 4.016 / 6.174 | 3.289 / 6.981 | +4.09% |
| city25-initial-impact | 4 | 36.602 / 42.700 | 81.198 / 84.790 | 36.684 / 40.993 | +121.59% |
| city256-intact-idle | 3 | 65.203 / 67.543 | 197.800 / 204.721 | 65.248 / 74.011 | +203.25% |
| city256-late-debris | 3 | 380.595 / 403.905 | 630.808 / 666.760 | 387.505 / 411.179 | +64.25% |

[All samples, stages, setup/restore costs, work counters, exact deadline misses and quality failures](n25-screen-metrics.json). Raw unprofiled runs: `out/n25-local-row-ownership-20260912/exploratory-screen/`. Existing warm scenario references and CPU/GPU work attribution remain separate in [the work census](removal-work-census.md). No warm or full52 candidate timing qualification is inferred from this shortlist.

The candidate local-row scheduling commit is `37d7a3ddbc871d543419fd1a53b1b5a3b634182f`. The full hierarchy mathematical/initcheck suite passes through100000 nodes; rebuilt analytic/3D/motion and standalone memory/initialization/synchronization checks pass in both arms. Integrated normal asynchronous memcheck passes twelve restored ticks across flying, city25 impact and city256 debris. Original broken masks, ownership, loads, crush and checked body state agree in those comparisons; force/health differences do not constitute acceptance.

Targeted profiling passes against the same candidate's plain physical output (six checked ticks across plain/Systems/NCU). The bridge spends92.305ms of104.785ms instrumented tick in the component solver. Unique executed instruction counts fall from681,379,356 in rejected N24 to49,242,013 in N25; shuffle-source not-issued samples fall from66.0% to7.31%. This confirms removal, not an accepted application improvement. Full counters/source accounting: [result](n25-result.json).

An offline audit of the retained control's existing work census also prevents a premature scheduling rewrite: largest-city per-CTA recorded durations have max/mean ratios1.15–1.17 at impact/debris, while city25 correction/debris show2.54/3.36. The collector includes diagnostic overhead and lacks synchronized start/end times, so these ratios are not measured tail milliseconds. Current component ownership already uses dynamic work claiming. [All audited stages/scales](n25-retained-balance.json).
