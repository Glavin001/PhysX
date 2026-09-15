# Full-step performance visual atlas — 2026-09-12

The charts use the last fully qualified 52-case N20 capacity cohort, **not** an
unqualified final N13+N20 composition. All 52 candidate scenarios pass their
physical comparisons, with 20 independent restored ticks each. Restore, import
validation, output validation and teardown are outside the complete-step timer.
Commands, integrated physics/destruction, correction, accepted publication,
synchronization and completion transfers remain inside. Ordinary APIs and
sleeping remain enabled; Direct GPU is disabled. No new performance gain is
claimed by this visualization work.

**28/52 scenario means exceed 16.667 ms; 557/1,040 measured restored ticks miss
60 Hz.** There are 24 scenarios whose entire 20-sample cohort is within budget.
The worst case is city256 late debris, mean382.883 / maximum452.158 ms, or
22.97 times the budget at its mean. The 2,368-chunk tower also costs108.434 ms:
chunk count alone does not characterize the solver's difficulty or scheduling.

## Data movement and causality

This is a dependency diagram, not a claim that all CPU/GPU work is serialized.
The measured timeline shows actual overlap. CPU/GPU mirrors required by normal
PhysX contact/sleep processing also occur at each relevant integration boundary.

```mermaid
sequenceDiagram
    participant C as CPU orchestration and compatibility
    participant P as PhysX CPU and GPU
    participant D as GPU destruction
    C->>P: Current-tick commands; simulate
    P->>D: Current solved contacts, device buffers
    D->>D: Loads → equilibrium stress → material verdict
    alt Fracture needs one physics correction
        D->>D: Connectivity, mass, fragment motion preparation
        D->>C: Allocation and ownership metadata, GPU → CPU
        C->>C: Native bodies, shape owners, contact registration
        C->>D: Binding receipts and capacity, CPU → GPU
        D->>P: Rewind affected participants; install fragment state
        P->>D: Corrected physics contacts, device buffers
        D->>D: Second stress and material verdict; final topology
    end
    D->>C: Accepted state and required completion transfers
    C->>C: Finish accepted actor and query publication
```

Contacts, loads, bond state and numerical work stay on the GPU. CPU registration
is on the correction dependency path; moving stress to a later tick is not an
acceptable shortcut. Second-verdict splits can update final ownership without
a third physics advance. This simplifies the source-level ordering of individual
motion installation phases; it does not prescribe a new implementation.

## Continuous simulation is a separate workload

Two N20 runs per workload, 600 full ticks each, no profiler:

| Workload | Means ms | Observed maxima ms | 60 Hz misses per run | Initialization ms |
|---|---:|---:|---:|---:|
| 256-building intact idle | 1.457 / 1.541 | 12.382 / 12.576 | 0/600, 0/600 | 2268.975 / 2282.665 |
| 256-building bombardment | 54.378 / 54.444 | 194.894 / 189.448 | 519/600, 519/600 | 2334.633 / 2422.667 |

Both heavy peaks occur at tick82, the first correction: 39,499 contact records,
28,596 broken bonds, one correction and two stress passes. In run0 the full
194.894378 ms consists of command0.000379, integrated simulate/fetch194.626983,
completion0.267016 ms. The integrated field includes stress and CPU work; it is
not pure rigid-body physics or GPU duration. Projectile submission at tick0 is
also charged to the full tick. Initialization is recorded separately, not hidden.

Restored city256 idle costs65.998 ms versus continuous idle1.457–1.541 ms because
restored scenes rebuild disposable execution state. Restore itself is excluded;
the next real solve still experiences that state. Neither workload substitutes
for the other, and no cross-workload speedup is inferred. Source cold/warm labels
describe physical history, not retained numerical caches after restoration.

## Detailed attribution: what is measured, and what is not

The interactive atlas includes a city256 late-debris profile, city25 initial
impact and a tall-tower profile. The first two use N20 diagnostic builds; the
tower uses an explicitly labeled earlier all-scenario diagnostic build. These
are single instrumented observations, **not** unprofiled timing candidates.

The late-debris trace lasts661.872 ms compared with normal20-sample mean382.883.
Its disjoint wall partition is CPU scheduled/GPU inactive537.427 ms, both active
53.069 ms, GPU active/CPU not scheduled64.870 ms, neither observed active6.505 ms.
Scheduled CPU includes instrumentation and API overhead; the 537 ms is not a
claim of removable production work. No profiler percentages are rescaled into
normal application milliseconds.

Within that trace, exclusive scheduled CPU scope times include shape ownership
migration59.151 ms, contact-manager preparation25.918, dynamics update24.678,
physics island insertion22.934, scene interactions21.352 and interaction
registration16.050. They are thread times across scopes/threads, not an additive
wall partition. GPU stress-solve launches sum67.187 ms; collision broad-phase
kernels sum19.484 ms. Transfers include42.359 MB CPU→GPU over6.201 ms of active
copy time,43.208 MB GPU→CPU over6.076 ms and50.701 MB device-local over0.230 ms.
These directions may overlap kernels/CPU and must not be added to the wall tick.
There are884 kernels and347 copies inside this one tick. GPU activity union is
117.940 ms; deleting only transfer duration would not solve the whole problem.

The earlier tower profile lasts150.776 ms, with115.335 ms in a single persistent
stress solve; GPU activity union115.840 ms. This supports a distinct large
connected-component solver target, independent of fracture registration. Its
normal N20 mean is108.434 ms; the difference is not a measured optimization gain.

CPU collectors warned about throttled sampling and generic possible NVTX loss;
the accepted tick range checks are preserved. Tiny kernel/copy intervals in the
timeline have a minimum display width for visibility; numeric durations use
their exact intervals. Copies/memsets are included in the resource timeline.

## Removal priorities suggested by these measurements

1. Fragment ownership/contact lifecycle: remove repeated native bookkeeping and
   repeated shape/contact traversals while preserving sleep, current contacts,
   rollback and accepted actor/query semantics. N20's capacity-growth removal is
   already in this cohort. N26/N27 did not establish a retained broad win; their
   earlier light-suite signals are not credited here.
2. Current exact duplicate stress problems: the separate census finds99.6% of
   idle iteration-node work and63.5% of large-impact correction work duplicated.
   These are work counts, not speedups. N29's equality/leader/scatter candidate
   is compiled but untested. Debris has under0.001% such duplication, so this
   cannot be the sole solution for the worst case.
3. Connected-component solver decomposition and shared operators: the tower's
   persistent solve and debris's different load vectors need separate treatment.
   Existing multilevel/shared-factor attempts did not yield accepted application
   improvements. Preserve equilibrium and material gates while changing the
   algorithm; fewer iterations alone is insufficient.
4. Sparse changed-state publication and fewer CPU/GPU handshakes where the
   consumers permit it. Existing ordinary PhysX sleep/contact consumers prevent
   indiscriminate deferral. Transfer bandwidth alone is a smaller target than
   the observed lifecycle and solver costs; previous mapped-copy trials did not
   establish a retained gain.

## Reproduction and source provenance

- Full52 cohort: [n20-full52.json](n20-full52.json), B samples and exact binaries.
- Continuous runs: [n20-followup.json](n20-followup.json), `warm` section.
- Raw visual extraction and61 source SHA256 hashes:
  `out/performance-visuals-20260912/data.json`.
- Extractor: `python3 out/performance-visuals-20260912/extract.py`.
- CPU/GPU diagrams use existing `attribution.json` plus read-only SQLite queries
  for the exact `snapshot/full_tick` clock bounds. No trace re-export or new GPU
  capture was needed. Native CPU CSV timestamps are not mixed with Nsight clocks.
- Inline fragments are in the task's durable visualization directory, titled
  `destruction-scenarios`, `destruction-continuous`, `destruction-attribution`.
- This report uses all samples, including first-tick peaks; maxima are observed
  maxima over20 or600 ticks, not worst-case bounds or confidence intervals.

## All52 unprofiled candidate measurements

The stage field is the integrated `simulate`/`fetchResults` interval and includes
physics, CPU work, stress, fracture and correction. Stage means plus command and
completion means equal the complete-step mean to recorded precision.

| Scenario | Mean / max ms | SD ms | 60 Hz misses | Integrated ms | Command / completion ms | Iterations | Correction / stress passes |
|---|---:|---:|---:|---:|---:|---:|---:|
| bridge64-cold | 8.745 / 11.703 | 0.728 | 0/20 | 8.537 | 0.0001 / 0.208 | 184 | 0 / 1 |
| bridge64-warm | 8.644 / 10.758 | 0.576 | 0/20 | 8.436 | 0.0001 / 0.208 | 184 | 0 / 1 |
| building-cold | 4.984 / 7.282 | 0.594 | 0/20 | 4.829 | 0.0002 / 0.155 | 88 | 0 / 1 |
| building-fragmented | 8.279 / 11.952 | 0.979 | 0/20 | 8.078 | 0.0001 / 0.201 | 4 | 0 / 1 |
| building-warm | 4.846 / 7.238 | 0.626 | 0/20 | 4.639 | 0.0001 / 0.207 | 88 | 0 / 1 |
| cantilever64-cold | 7.501 / 9.920 | 0.610 | 0/20 | 7.331 | 0.0001 / 0.170 | 984 | 0 / 1 |
| cantilever64-warm | 7.547 / 12.291 | 1.143 | 0/20 | 7.383 | 0.0001 / 0.163 | 984 | 0 / 1 |
| chain256-cold | 7.313 / 9.050 | 0.524 | 0/20 | 7.134 | 0.0001 / 0.179 | 492 | 0 / 1 |
| chain256-warm | 7.428 / 9.547 | 0.509 | 0/20 | 7.218 | 0.0001 / 0.210 | 492 | 0 / 1 |
| chain32-cold | 3.121 / 6.051 | 0.721 | 0/20 | 2.940 | 0.0001 / 0.181 | 32 | 0 / 1 |
| chain32-warm | 3.230 / 6.283 | 0.761 | 0/20 | 2.949 | 0.0001 / 0.281 | 32 | 0 / 1 |
| dense12-cold | 31.329 / 33.495 | 0.604 | 20/20 | 31.122 | 0.0002 / 0.207 | 34 | 0 / 1 |
| dense12-warm | 31.321 / 34.019 | 0.669 | 20/20 | 31.210 | 0.0002 / 0.111 | 34 | 0 / 1 |
| destruction-cold | 3.661 / 6.418 | 0.734 | 0/20 | 3.468 | 0.0001 / 0.192 | 1 | 0 / 1 |
| destruction-damaged | 3.473 / 6.437 | 0.715 | 0/20 | 3.281 | 0.0001 / 0.192 | 1 | 0 / 1 |
| destruction-fractured | 5.080 / 9.223 | 1.026 | 0/20 | 4.890 | 0.0001 / 0.189 | 0 | 0 / 1 |
| destruction-intact | 3.637 / 6.126 | 0.679 | 0/20 | 3.413 | 0.0002 / 0.224 | 1 | 0 / 1 |
| destruction-onset | 4.188 / 7.442 | 0.825 | 0/20 | 3.999 | 0.0001 / 0.189 | 1 | 0 / 1 |
| destruction-stimulus | 4.251 / 7.641 | 0.835 | 0/20 | 4.058 | 0.0031 / 0.189 | 1 | 0 / 1 |
| flying | 1.751 / 2.353 | 0.152 | 0/20 | 1.750 | 0.0001 / 0.001 | 0 | 0 / 0 |
| ladder128-cold | 5.786 / 8.063 | 0.558 | 0/20 | 5.582 | 0.0001 / 0.204 | 192 | 0 / 1 |
| ladder128-warm | 5.771 / 7.909 | 0.546 | 0/20 | 5.573 | 0.0001 / 0.198 | 192 | 0 / 1 |
| panel32-cold | 21.415 / 23.987 | 0.637 | 20/20 | 21.292 | 0.0002 / 0.123 | 492 | 0 / 1 |
| panel32-warm | 21.141 / 23.593 | 0.605 | 20/20 | 20.972 | 0.0002 / 0.169 | 492 | 0 / 1 |
| resting | 1.467 / 2.272 | 0.386 | 0/20 | 1.466 | 0.0001 / 0.001 | 0 | 0 / 0 |
| sliding | 2.543 / 3.554 | 0.373 | 0/20 | 2.542 | 0.0001 / 0.001 | 0 | 0 / 0 |
| tower64-cold | 108.434 / 111.349 | 0.863 | 20/20 | 108.316 | 0.0002 / 0.118 | 137 | 0 / 1 |
| tower64-warm | 108.494 / 111.316 | 0.751 | 20/20 | 108.353 | 0.0003 / 0.141 | 137 | 0 / 1 |
| city25-intact-idle | 10.145 / 13.082 | 0.801 | 0/20 | 9.929 | 0.0002 / 0.216 | 88 | 0 / 1 |
| city25-airborne | 11.599 / 14.435 | 0.849 | 0/20 | 11.380 | 0.0002 / 0.219 | 88 | 0 / 1 |
| city25-initial-impact | 39.264 / 48.881 | 2.518 | 20/20 | 39.018 | 0.0001 / 0.245 | 304 | 1 / 2 |
| city25-post-impact | 22.258 / 29.290 | 1.963 | 20/20 | 22.019 | 0.0002 / 0.239 | 332 | 0 / 1 |
| city25-cascading-fracture | 38.297 / 42.759 | 1.991 | 20/20 | 38.080 | 0.0001 / 0.217 | 388 | 1 / 2 |
| city25-fragmented-loaded | 54.236 / 63.798 | 2.903 | 20/20 | 53.970 | 0.0002 / 0.266 | 536 | 1 / 2 |
| city25-late-debris | 66.349 / 85.751 | 6.453 | 20/20 | 66.110 | 0.0001 / 0.239 | 676 | 1 / 2 |
| city25-ten-second-debris | 69.181 / 95.080 | 6.807 | 20/20 | 68.943 | 0.0002 / 0.237 | 716 | 1 / 2 |
| city64-intact-idle | 17.949 / 21.129 | 1.503 | 19/20 | 17.695 | 0.0002 / 0.253 | 88 | 0 / 1 |
| city64-airborne | 18.850 / 25.336 | 2.252 | 18/20 | 18.598 | 0.0001 / 0.252 | 88 | 0 / 1 |
| city64-initial-impact | 63.334 / 76.530 | 3.495 | 20/20 | 63.105 | 0.0001 / 0.229 | 304 | 1 / 2 |
| city64-post-impact | 37.395 / 46.823 | 3.875 | 20/20 | 37.152 | 0.0002 / 0.242 | 332 | 0 / 1 |
| city64-cascading-fracture | 59.518 / 71.194 | 3.487 | 20/20 | 59.296 | 0.0001 / 0.222 | 400 | 1 / 2 |
| city64-fragmented-loaded | 94.428 / 117.259 | 6.703 | 20/20 | 94.175 | 0.0001 / 0.253 | 644 | 1 / 2 |
| city64-late-debris | 133.798 / 171.554 | 10.326 | 20/20 | 133.554 | 0.0002 / 0.244 | 948 | 1 / 2 |
| city64-ten-second-debris | 96.681 / 131.263 | 10.579 | 20/20 | 96.440 | 0.0007 / 0.241 | 736 | 1 / 2 |
| city256-intact-idle | 65.998 / 79.530 | 5.945 | 20/20 | 65.749 | 0.0002 / 0.249 | 88 | 0 / 1 |
| city256-airborne | 72.020 / 83.666 | 5.632 | 20/20 | 71.741 | 0.0002 / 0.279 | 88 | 0 / 1 |
| city256-initial-impact | 240.893 / 288.232 | 17.812 | 20/20 | 240.639 | 0.0002 / 0.254 | 312 | 1 / 2 |
| city256-post-impact | 145.421 / 170.425 | 13.601 | 20/20 | 145.264 | 0.0002 / 0.158 | 332 | 0 / 1 |
| city256-cascading-fracture | 197.229 / 223.423 | 16.100 | 20/20 | 196.988 | 0.0002 / 0.240 | 416 | 1 / 2 |
| city256-fragmented-loaded | 292.395 / 325.613 | 23.228 | 20/20 | 292.169 | 0.0002 / 0.225 | 604 | 1 / 2 |
| city256-late-debris | 382.883 / 452.158 | 24.771 | 20/20 | 382.641 | 0.0002 / 0.242 | 1084 | 1 / 2 |
| city256-ten-second-debris | 258.889 / 347.191 | 26.699 | 20/20 | 258.638 | 0.0002 / 0.251 | 676 | 1 / 2 |
