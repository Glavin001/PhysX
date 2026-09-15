# Nsight conditional-graph thread boundary — 10 September 2026

The stage-1288 native profiling failure now has a **standalone reproducer**:
Nsight Compute 2026.3.0 executes false conditional branches when the graph is
instantiated on one CPU thread and launched on another. Creating the graph on
one thread but instantiating and launching it on the worker passes. Upload or
re-upload on the launching thread alone does not repair the failure.

This identifies a reproducible trigger in the tested instrumentation stack,
not the exact defective vendor component. It is not a hardware-counter permission
failure. Production sources, SDK libraries and four-worker scheduling remain
unchanged from the ordinary-command guard qualification.

## Minimal controlled reproduction

[Standalone source and runner](../../tools/diagnostics/nsight-cross-thread-conditional/README.md)
use two one-thread kernels, one IF node, one nonblocking stream, one explicit
CUDA context and eight alternating inputs. There is no PhysX, Blast, CUB,
cooperative launch, capture, dynamic library, graph update or concurrent graph
API access. The graph must invoke its body zero times for input zero and once
for input one. Both CPU threads explicitly use the same CUDA context. Thread
start/join and stream completion serialize access as required by
[NVIDIA's graph API contract](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/cuda-graphs.html#using-graph-apis).

RTX 5060 Ti / sm_120, driver 615.71.09, CUDA 13.4.59, Nsight Compute
2026.3.0.0 build 38525999. **Two repetitions per cell**; attached runs use
`--profile-from-start off`, collecting no counters:

| Graph creation | Instantiation | Upload | Launch | Plain | Attached |
| --- | --- | --- | --- | --- | --- |
| main | main | main | main | pass | pass |
| main | main | main | worker | pass | **four incorrect false branches** |
| main | worker | worker | worker | pass | pass |
| worker | worker | worker | worker | pass | pass |
| main | main | worker | worker | pass | **four incorrect false branches** |
| main | main | main + worker | worker | pass | **four incorrect false branches** |

All 12 plain executions pass. Six attached executions pass and six fail with
exactly four wrong outputs each. Cross-thread memcheck passes with zero errors.
The runner intentionally exits 1 because the six numerical failures are retained.
[Results, commands and loaded-module hashes](minimal-results.json).

Minimal manual commands after building the reproducer:

```bash
out/nsight-small-context-20260910/minimal-verified/repro cross
/usr/local/cuda-13.4/bin/ncu --profile-from-start off \
  out/nsight-small-context-20260910/minimal-verified/repro cross
/usr/local/cuda-13.4/bin/ncu --profile-from-start off \
  out/nsight-small-context-20260910/minimal-verified/repro instantiate-worker
```

The archive `standalone-reproducer.tar.gz` contains only the minimal source,
runner, instructions and its recorded results; it contains no native engine source
or binary. Nothing was submitted externally.

## Controls that narrow the trigger

The raw investigation at `out/nsight-small-context-20260910/` preserves each
attempt, code variant, build command and result. These controls pass with the
profiler attached:

- Explicit CUDA contexts with default and PhysX-like flags; worker creation and
  execution entirely on one thread.
- A conditional/cooperative control inside the actual PhysX process, both before
  simulation setup and after stress graph configuration. The subsequent native
  four-worker fracture still fails at stage 1288.
- Production motion allocation with a conditional continuation, including the
  existing capacity-growth and ownership checks through 113,664 slots.
- The same allocator compiled inside the full runtime CUDA translation unit,
  exercised independently of native scene tasks: failed-capacity receipt remains
  a retry, then allocation succeeds after growth.
- Eight simultaneously live conditional graphs; a conditional memset;
  a nonblocking stream; a control linked into the full runtime shared library.

Moving launch alone to another CPU thread makes the small shared-library control
fail, motivating the smaller two-kernel executable above. A separate primary-
context/shared-library control aborts with a double-free report under attachment;
it is preserved as a distinct observation and is not used to explain the native
failure. Native whole-graph attachment also still exits 11. Neither outcome is
hidden or treated as a successful profiling route.

## Working native profiling diagnostic

PhysX's existing zero-worker inline CPU dispatcher keeps the relevant graph
instantiation and launch on one thread in this fixture. An **isolated executable**
changes only `PxDefaultCpuDispatcherCreate(4)` to `(0)` in a copied scene source;
it links the unchanged current SDK. The reusable helper is
[build-native-inline.py](../../tools/diagnostics/nsight-cross-thread-conditional/build-native-inline.py).
This is a profiler diagnostic, not a production scheduling change or performance
optimization.

The native correction fixture runs 29 configurations: 16 ordinary force/torque/
zero-load cases plus 13 pre-existing Direct GPU correction cases. Each starts
with three authored chunks, one bond, zero projectiles and three actors, advances
a setup step and attempts the fracture step at dt 1/60. Rejection cases remain
intentional; unloaded controls complete one correction. All original motion,
momentum, ownership, load and invalid-input assertions remain.

Plain execution, attachment with collection disabled, and selected counter
profiling **all pass**, with all 29 result lines identical. The selected
`inspectCorrectionSourceLoads` launch completes ten replay passes; the process
then completes the entire fixture:

| Counter sample | Result |
| --- | ---: |
| Launch | 1 block × 128 threads; 2 source clusters |
| Profiler duration | 3.23 µs |
| Registers/thread | 22 |
| Achieved occupancy | 3.77% |
| DRAM throughput | 0.33% |
| Spilling requests | 0 |

[Counter details](inline-guard-counters.txt). Cache flushing enabled, clocks
unlocked, desktop graphics active. This tiny native kernel establishes a working
counter capture with checked native behavior; its low occupancy is a small-grid
observation, not evidence of a city stress bottleneck. No complete-step or CPU
speedup is claimed. Inline-dispatch timing cannot stand in for four-worker timing.

## Next use and limits

Build the diagnostic `native_destruction_demo` with the same helper. First compare
its 256-building trial/correction and material histories to matched four-worker
inputs. Then profile the real expensive stress launches, including later peaks,
and verify that the profiled run completes with matching physical work. Those
city captures have **not yet been qualified** with this diagnostic.

Keep normal scheduling for untraced complete-step timing, including all startup
spikes and exact 120 Hz / 60 Hz exceedances. The native architecture, physical
migration gates, full command/material integration and real-time target remain
unfinished. Do not move production graph construction/instantiation or serialize
production tasks solely to accommodate this profiler failure.
