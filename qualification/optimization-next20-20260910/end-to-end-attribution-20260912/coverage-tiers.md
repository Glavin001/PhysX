# Attribution tiers and remaining limits

CPU **52/52**; graph tier **52/52** (461 graph invocations); significant ordinary-kernel configuration tier **0/52** (0 representative invocations). Zero-work cases are explicit coverage rows, not additional measured ticks.

All CPU and GPU timings in profiler artifacts are diagnostic. [All52 unprofiled full-step baselines and CPU/stage data](report.md) remain separate.

| Scenario | CPU | Graph invocations: captured / expected | Ordinary configurations | Ordinary counter invocations |
|---|---|---:|---:|---:|
| bridge64-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| bridge64-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| building-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| building-fragmented | complete | 6 / 6 (complete) | — (not_captured) | — |
| building-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| cantilever64-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| cantilever64-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| chain256-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| chain256-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| chain32-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| chain32-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| dense12-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| dense12-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| destruction-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| destruction-damaged | complete | 6 / 6 (complete) | — (not_captured) | — |
| destruction-fractured | complete | 6 / 6 (complete) | — (not_captured) | — |
| destruction-intact | complete | 6 / 6 (complete) | — (not_captured) | — |
| destruction-onset | complete | 6 / 6 (complete) | — (not_captured) | — |
| destruction-stimulus | complete | 6 / 6 (complete) | — (not_captured) | — |
| flying | complete | 0 / 0 (complete) | — (not_captured) | — |
| ladder128-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| ladder128-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| panel32-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| panel32-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| resting | complete | 0 / 0 (complete) | — (not_captured) | — |
| sliding | complete | 0 / 0 (complete) | — (not_captured) | — |
| tower64-cold | complete | 6 / 6 (complete) | — (not_captured) | — |
| tower64-warm | complete | 6 / 6 (complete) | — (not_captured) | — |
| city25-intact-idle | complete | 6 / 6 (complete) | — (not_captured) | — |
| city25-airborne | complete | 6 / 6 (complete) | — (not_captured) | — |
| city25-initial-impact | complete | 18 / 18 (complete) | — (running) | — |
| city25-post-impact | complete | 6 / 6 (complete) | — (not_captured) | — |
| city25-cascading-fracture | complete | 15 / 15 (complete) | — (not_captured) | — |
| city25-fragmented-loaded | complete | 17 / 17 (complete) | — (not_captured) | — |
| city25-late-debris | complete | 18 / 18 (complete) | — (not_captured) | — |
| city25-ten-second-debris | complete | 17 / 17 (complete) | — (not_captured) | — |
| city64-intact-idle | complete | 6 / 6 (complete) | — (not_captured) | — |
| city64-airborne | complete | 6 / 6 (complete) | — (not_captured) | — |
| city64-initial-impact | complete | 18 / 18 (complete) | — (not_captured) | — |
| city64-post-impact | complete | 6 / 6 (complete) | — (not_captured) | — |
| city64-cascading-fracture | complete | 15 / 15 (complete) | — (not_captured) | — |
| city64-fragmented-loaded | complete | 17 / 17 (complete) | — (not_captured) | — |
| city64-late-debris | complete | 18 / 18 (complete) | — (not_captured) | — |
| city64-ten-second-debris | complete | 17 / 17 (complete) | — (not_captured) | — |
| city256-intact-idle | complete | 6 / 6 (complete) | — (not_captured) | — |
| city256-airborne | complete | 6 / 6 (complete) | — (not_captured) | — |
| city256-initial-impact | complete | 18 / 18 (complete) | — (not_captured) | — |
| city256-post-impact | complete | 6 / 6 (complete) | — (not_captured) | — |
| city256-cascading-fracture | complete | 15 / 15 (complete) | — (not_captured) | — |
| city256-fragmented-loaded | complete | 18 / 18 (complete) | — (not_captured) | — |
| city256-late-debris | complete | 18 / 18 (complete) | — (not_captured) | — |
| city256-ten-second-debris | complete | 18 / 18 (complete) | — (not_captured) | — |

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

Out-of-range counter ratios preserved and flagged: 49. See the structured report before using any such ratio quantitatively.
