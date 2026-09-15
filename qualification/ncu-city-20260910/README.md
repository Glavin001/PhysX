# Native city stress counters — 10 September 2026

**Nsight Compute now profiles both first-fracture and later expensive stress
kernels through completed city trajectories.** The isolated inline-dispatch
executable avoids the previously reproduced cross-thread conditional-graph
instrumentation failure. Normal four-worker scheduling and production SDK
binaries are unchanged. This qualifies a diagnostic route, not a solver speedup
or complete physical equivalence.

## Workload and matching controls

RTX 5060 Ti 16 GB, sm_120; driver 615.71.09, CUDA 13.4.59, Nsight Compute
2026.3.0.0 and Systems 2026.3.2. Source HEAD 1155b7ff plus existing WIP;
installed private runtime V14 with the ordinary-command correction guard.
Each run: **256 buildings, 113,664 chunks, 229,376 bonds, one simultaneous
256-projectile aerial wave, 180 steps / 3 simulated seconds**. Ordinary API,
Direct GPU off, sleeping on, dt 1/60, at most one correction, stress cap 8192,
unchanged solver tolerance. Pose recording and CPU phase scopes are enabled;
GPU rendering and GPU event profiling are off. Existing desktop graphics stay
active. These runs do not replace the untraced timing baseline.

Six runs completed with exit zero: production four-worker control, inline plain
control, inline Systems timeline, late counters, first-fracture counters, and
late source sampling. All recorded chunk/projectile positions and orientations
are **byte-identical across all 180 frames**, with TWSTATE SHA256
`872bc4e40b99d904366d3b9d47a58b61fb3a783de509af718e21c0b1de316ecd`.
Accepted pose recording carries unchanged entries and checks every actor; this
is stronger than comparing only final topology counters. The recorded sleeping
flag is always false in this exporter and does not independently audit sleep.

All six recorded projectile launch tapes are byte-identical.
All checked per-step fracture/contact/cluster/active-body/correction histories
match, and all steps report convergence, zero correction status and evaluation
cap compliance. Each ends with 56,077 broken bonds, 12,248 peak clusters and
87 corrections. Relative to inline plain, maximum stress iteration counts differ
on 24 production, 30 timeline, 28 late-counter, 27 first-counter and 26 late-source
steps. **This is not bit-identical numerical history**; full load/material
buffers and frozen migration physical gates are not qualified by pose equality.
No tolerances or expected physical outputs were changed.

## Selected kernel counters

The fresh Systems trace maps all 267 stress launches to their actual step and
trial/correction interval, checking the CPU timestamp bounds. Launch ordinals
below are zero-based. Frame-level active counts are retained in `kernel-map.json`
as `frame_*`; they are not independent per-evaluation work censuses.

Each counter target is the unchanged production `componentStressSolve`, launched
as 72 blocks × 256 threads on 36 SMs. Kernel replay, graph node profiling,
cache flush on, clocks unlocked. First trial/correction use 23 passes each;
late full counters use 22; separate late source sampling uses seven.
All processes continue to the end; no intentional one-kernel termination.

| Metric | Step 82 trial / launch 82 | Step 82 correction / launch 83 | Step 108 trial / launch 130 |
| --- | ---: | ---: | ---: |
| Separate Systems kernel duration, ms | 22.974 | 34.497 | 45.988 |
| Nsight Compute kernel replay duration, ms | 22.958 | 34.307 | 47.353 |
| FP64 pipeline, % sustained elapsed | 60.84 | 61.11 | 54.42 |
| DRAM throughput, % sustained elapsed | 3.41 | 3.27 | 1.69 |
| Achieved occupancy, % | 33.23 | 31.77 | 32.27 |
| Eligible warps / scheduler / active cycle | 0.100 | 0.096 | 0.088 |
| Scheduler cycles without issue, % | 91.75 | 91.98 | 92.51 |
| Barrier stall cycles / issued instruction | 12.02 | 12.28 | 18.73 |
| Short-scoreboard stall cycles / issued instruction | 17.18 | 17.10 | 15.69 |
| Long-scoreboard stall cycles / issued instruction | 10.31 | 9.69 | 9.30 |
| Registers / thread | 110 | 110 | 110 |
| Reported local/shared spilling requests | 0 / 0 | 0 / 0 | 0 / 0 |

Register use permits two resident blocks/SM, giving 33.33% theoretical occupancy;
measured occupancy is close to that ceiling. FP64 is the highest-utilized pipe,
but utilization alone does not establish a single throughput bottleneck.
The later launch has greater barrier exposure despite comparable occupancy.
The low DRAM figures do not exclude cache/gather dependency latency. The late
multi-pass report includes an L2 hit-rate value of 100.13%; it is retained raw
and is not used as a literal cache probability or evidence of perfect locality.
Profiler estimated speedups are not adopted as predictions.

## Source and instruction evidence

PC sampling is available for both first-fracture launches and the later trial.
Correlated source can attribute one physical instruction to multiple lines;
`summarize.py` deduplicates by (launch, instruction address) and checks matching
metrics before summing. Among those source-correlated short-scoreboard samples,
**64.30%, 64.68% and 62.05%** occur at DADD/DMUL/DFMA instructions respectively.
Conversions add further samples. These are sample-location fractions, not
fractions of whole-step time or a proof that every dependency originates there.

The highest short-scoreboard sites include double cross/add/subtract operations
in `StressHierarchyOperator.cuh`. The hottest trial DADD is preceded by a chain
of DMUL/DFMA/DADD instructions producing its operands. This is evidence for
investigating arithmetic dependencies; a generic short-scoreboard warning alone
would not justify assuming shared-memory bank conflicts.

Prominent barrier sample locations correlate with `StressNativePolynomial.cuh`
lines 44/50 and the component norm reduction in `StressComponentIteration.cuh`
line 16. Samples can point to an instruction following synchronization, rather
than the barrier opcode itself. The final polynomial boundary remains prominent
in the later trial. Barriers must remain until their data dependencies are
proved unnecessary; waiting warps can reflect unequal preceding work.

## Next implementation decision

1. Use these three launches as the counter baseline. Measure actual operator,
   preconditioner and component work, including slow components, before changing
   scheduling or register allocation. Maximum iterations × all bonds is not a
   valid work count.
2. Prioritize reducing repeated structural/preconditioner work and its dependency
   chain in the six-channel solver replacement. Current evidence does not justify
   another inverse shared-cache experiment, dropping FP64 or deleting barriers.
   The historical rejected mechanisms remain documented in PERFORMANCE_FINDINGS.
3. Finish native command/load/material integration and qualify the new fine
   equations before claiming physically equivalent speed. Test any candidate on
   matched fresh intact idle and impacts with normal scheduling and untraced
   complete-step timing, retaining startup/maxima and exact >1000/120 and
   >1000/60 ms counts and percentages.

## Reproduction and provenance

[Receipt and run commands](receipt.json), [counter values and deduplicated PC
hotspots](counter-summary.json), [all stress launch mappings](kernel-map.json),
[artifact hashes](artifact-hashes.json), and per-pair comparison JSONs are retained
here. Raw `.ncu-repz`, `.nsys-rep`, SQLite, module maps, all frame/pose files,
exact configs and scripts are under `out/ncu-city-20260910/`. The build recipe
is `inline-build/build.json`; only the copied CPU dispatcher scene object differs.

```bash
# Fresh name required; all operations stay in this repository.
DESTRUCTION_PROFILE_BINARY="$PWD/out/ncu-city-20260910/inline-build/native_destruction_demo-ncu-inline" \
  python3 out/ncu-city-20260910/capture.py source-NEW 130
.toolchains/build-env/bin/python out/ncu-city-20260910/compare.py plain-inline source-NEW
```

`capture.py` adapts the existing baseline capture wrapper. It records GPU
processes, actual loaded modules/maps, commands and hashes. One initial wrapper
invocation exited before any GPU launch due to a missing positional skip; its
empty `plain-production/` directory is retained. That argument is now optional.
The first comparison attempt completed pose analysis but failed at final hashing
on Python 3.10's absent `hashlib.file_digest`; the compatible hashing rerun passes.
No simulation was repeated for that analysis-only correction.

Actual loaded runtime SHA256:
`93846c918089a61d5883790fd101199f08ffae701599d715eedf7c247961a126`;
GPU activity module:
`63510ee906965de8a44e2c94a825dcfea197cc15ba00da15b126cb5fb29a6406`.
Both match the preceding command-guard qualification. All owned jobs finished.
