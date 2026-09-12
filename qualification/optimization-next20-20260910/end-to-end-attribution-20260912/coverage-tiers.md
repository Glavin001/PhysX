# Attribution tiers and remaining limits

CPU **52/52**; graph tier **52/52** (461 graph invocations); significant ordinary-kernel configuration tier **40/52** (3243 representative invocations). Zero-work cases are explicit coverage rows, not additional measured ticks.

All CPU and GPU timings in profiler artifacts are diagnostic. [All52 unprofiled full-step baselines and CPU/stage data](report.md) remain separate.

| Scenario | CPU | Graph invocations: captured / expected | Ordinary configurations | Ordinary counter invocations | Represented families: timeline kernel time |
|---|---|---:|---:|---:|---:|
| bridge64-cold | complete | 6 / 6 (complete) | 18 (complete) | 30 | 99.009% |
| bridge64-warm | complete | 6 / 6 (complete) | 18 (complete) | 30 | 99.014% |
| building-cold | complete | 6 / 6 (complete) | 47 (complete) | 55 | 99.005% |
| building-fragmented | complete | 6 / 6 (complete) | 103 (complete) | 140 | 99.030% |
| building-warm | complete | 6 / 6 (complete) | 47 (complete) | 60 | 99.020% |
| cantilever64-cold | complete | 6 / 6 (complete) | 22 (complete) | 35 | 99.014% |
| cantilever64-warm | complete | 6 / 6 (complete) | 22 (complete) | 35 | 99.009% |
| chain256-cold | complete | 6 / 6 (complete) | 25 (complete) | 43 | 99.007% |
| chain256-warm | complete | 6 / 6 (complete) | 23 (complete) | 35 | 99.027% |
| chain32-cold | complete | 6 / 6 (complete) | 66 (complete) | 79 | 99.092% |
| chain32-warm | complete | 6 / 6 (complete) | 66 (complete) | 79 | 99.106% |
| dense12-cold | complete | 6 / 6 (complete) | 2 (complete) | 4 | 99.184% |
| dense12-warm | complete | 6 / 6 (complete) | 2 (complete) | 6 | 99.202% |
| destruction-cold | complete | 6 / 6 (complete) | 68 (complete) | 86 | 99.023% |
| destruction-damaged | complete | 6 / 6 (complete) | 68 (complete) | 76 | 99.027% |
| destruction-fractured | complete | 6 / 6 (complete) | 103 (complete) | 116 | 99.082% |
| destruction-intact | complete | 6 / 6 (complete) | 68 (complete) | 81 | 99.032% |
| destruction-onset | complete | 6 / 6 (complete) | 84 (complete) | 105 | 99.007% |
| destruction-stimulus | complete | 6 / 6 (complete) | 86 (complete) | 98 | 99.005% |
| flying | complete | 0 / 0 (complete) | 41 (complete) | 49 | 99.204% |
| ladder128-cold | complete | 6 / 6 (complete) | 38 (complete) | 53 | 99.032% |
| ladder128-warm | complete | 6 / 6 (complete) | 39 (complete) | 47 | 99.039% |
| panel32-cold | complete | 6 / 6 (complete) | 4 (complete) | 12 | 99.290% |
| panel32-warm | complete | 6 / 6 (complete) | 4 (complete) | 12 | 99.311% |
| resting | complete | 0 / 0 (complete) | 26 (complete) | 30 | 99.544% |
| sliding | complete | 0 / 0 (complete) | 53 (complete) | 63 | 99.175% |
| tower64-cold | complete | 6 / 6 (complete) | 2 (complete) | 4 | 99.775% |
| tower64-warm | complete | 6 / 6 (complete) | 2 (complete) | 4 | 99.770% |
| city25-intact-idle | complete | 6 / 6 (complete) | 39 (complete) | 52 | 99.010% |
| city25-airborne | complete | 6 / 6 (complete) | 56 (complete) | 74 | 99.021% |
| city25-initial-impact | complete | 18 / 18 (complete) | 93 (complete) | 215 | 99.023% |
| city25-post-impact | complete | 6 / 6 (complete) | 55 (complete) | 85 | 99.000% |
| city25-cascading-fracture | complete | 15 / 15 (complete) | 85 (complete) | 238 | 99.022% |
| city25-fragmented-loaded | complete | 17 / 17 (complete) | 76 (complete) | 216 | 99.000% |
| city25-late-debris | complete | 18 / 18 (complete) | 97 (complete) | 249 | 99.006% |
| city25-ten-second-debris | complete | 17 / 17 (complete) | 63 (complete) | 186 | 99.013% |
| city64-intact-idle | complete | 6 / 6 (complete) | 36 (complete) | 48 | 99.021% |
| city64-airborne | complete | 6 / 6 (complete) | 52 (complete) | 77 | 99.012% |
| city64-initial-impact | complete | 18 / 18 (complete) | 89 (complete) | 240 | 99.019% |
| city64-post-impact | complete | 6 / 6 (complete) | 56 (complete) | 96 | 99.013% |
| city64-cascading-fracture | complete | 15 / 15 (complete) | — (running) | — | — |
| city64-fragmented-loaded | complete | 17 / 17 (complete) | — (not_captured) | — | — |
| city64-late-debris | complete | 18 / 18 (complete) | — (not_captured) | — | — |
| city64-ten-second-debris | complete | 17 / 17 (complete) | — (not_captured) | — | — |
| city256-intact-idle | complete | 6 / 6 (complete) | — (not_captured) | — | — |
| city256-airborne | complete | 6 / 6 (complete) | — (not_captured) | — | — |
| city256-initial-impact | complete | 18 / 18 (complete) | — (not_captured) | — | — |
| city256-post-impact | complete | 6 / 6 (complete) | — (not_captured) | — | — |
| city256-cascading-fracture | complete | 15 / 15 (complete) | — (not_captured) | — | — |
| city256-fragmented-loaded | complete | 18 / 18 (complete) | — (not_captured) | — | — |
| city256-late-debris | complete | 18 / 18 (complete) | — (not_captured) | — | — |
| city256-ten-second-debris | complete | 18 / 18 (complete) | — (not_captured) | — | — |

## Continuous ordinary/sleeping controls

Each unprofiled row contains180 complete ticks, including startup. A corresponding CPU/Systems trace passes the same per-tick work/convergence/correction counters. These controls are not candidate speedup experiments.

| Workload | Full-step mean / peak ms | 8ms / 120Hz / 60Hz misses | Initialization ms | Command / integrated physics / completion mean ms |
|---|---:|---:|---:|---:|
| idle-256 | 1.678 / 12.426 | 1 / 1 / 0 of180 | 2373.039 | 0.000 / 1.495 / 0.183 |
| impacts-256 | 55.457 / 195.027 | 99 / 99 / 99 of180 | 2300.038 | 0.170 / 55.052 / 0.235 |

The lower-rate warm traces contain no sampling-throttle warning. The original higher-rate traces and warnings are retained in `warm/`; the qualified lower-rate set is `warm-reduced-sampling/`. The generic NVTX warning remains; continuous bounds are taken from the complete native frame CSV, and native phases are recorded separately. CUDA-event completeness warnings are rejected. Monotonic frame anchors sit inside the authoritative timer; any unlocated clock-boundary time is explicitly recorded rather than assigned to GPU or CPU work.

## Limits

- Graph counters aggregate nodes. Individual conditional-node and instruction-source counters remain unavailable with the stable collector.
- Ordinary kernel families cover at least 99% of matched kernel duration together with graphs, plus every family above 0.1ms; first and slowest observed launches per configuration are included. Other invocations remain in complete timelines. Set threshold to zero or use the all-invocation collector for further investigations.
- CPU samples are statistical; unresolved driver/kernel frames and any capture warnings are preserved. Native thread-clock phases and OS/CUDA calls supplement sampling.
- Cold restored ticks rebuild disposable caches; warm continuous gameplay is a separate workload. Neither includes restore/validation in the full-step timer.
- No runtime optimization or speedup is claimed.

Out-of-range counter ratios preserved and flagged: 88. See the structured report before using any such ratio quantitatively.
