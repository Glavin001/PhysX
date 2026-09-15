---
name: physx-destruction-profiling
description: Investigate destruction peak and idle costs using available Nsight counters, CUDA timelines and untraced complete-step measurements on the migrated PhysX VM.
---

# Destruction profiling with hardware counters

## Current warm profiling route — 2026-09-14

Start with [fast warm measurement](../physx-destruction-performance/references/fast-warm-measurement.md)
and the [complete warm52 evidence](../../../reports/destruction-warm-full52-20260914/README.md).
Use saved matching timelines to select the missing question, then collect a bounded
profile. Default to the calibrated warm screen for completed runtime mechanisms;
its two stress launches are not exhaustive coverage. Keep unprofiled full steps
as the performance outcome and record all capture/check/export costs.

The full52 core pass covers52/52 scenarios, but takes23m55s just for counters.
Do not repeat it per edit. One-pass core metrics avoid the detailed pilot's
three-pass host-memory backups. Use selected-tick Systems recording; preserve
boundary warnings and low/unresolved CPU-sample limits. Read normalized API counts
because nested versioned aliases inflate raw counts. Pin Compute2025.3.1; graph
aggregates do not provide conditional-node/source counters. Cache-control all replay
is not production warm-L2 timing. Exact settings, recovery limits, partial-resume
rules and known rejected histories are in the fast-measurement reference.

The older migration investigations and probe commands below are historical.
They are not the default route or evidence that the current selected runtime
cannot be captured. Read current AGENTS.md before using a dated status statement.

Current procedure (2026-09-13): follow the
[removal-first workflow](../../../docs/destruction/REMOVAL_FIRST_WORKFLOW.md)
and [measured representative protocol](../../../reports/destruction-baseline-20260913/measured-experiment-protocol.md).
Use existing matching timelines, targeted work counters for intermediate
mechanisms, and full-step timing for completed bets. Pin the qualified
Nsight Compute 2025.3.1 collector for the current snapshot workflow. The
migration-specific failures and older capture entrypoints below are historical;
do not rerun them as the default or assume they describe current coverage.

Read [AGENTS.md](../../../AGENTS.md) for machine/status and the
[performance skill](../../../.agents/skills/physx-destruction-performance/SKILL.md)
for physical and experiment requirements. Actual legacy peak and new offline
numerical kernels have counter evidence; see the dated reports linked below.
No physically equivalent complete-step optimization win is qualified.

## Evidence levels

1. Exact equation replay or small fixture: screen mechanisms/correctness quickly.
2. Diagnostic trajectory + timeline/counters: identify work, latency/dependencies
   and resource pressure. Label numerical parity failures independently.
3. Matched untraced complete advances: establish actual performance improvement.

A `ncu`-replayed kernel duration is not production latency. Do not run the entire
600-step bombardment under full counter collection: discover the hot kernels
first, select a small relevant launch range and sections, then expand only to
resolve a specific hypothesis. Keep all untraced first steps and peaks.

## Historical migration probe

`out/vm-port-20260910/motion-slots-counters.ncu-repz` demonstrates real destruction
kernel collection; the allocator fixture exercises capacities through 113,664
slots. It is not a stress or city-performance capture. The synthetic probe under
`/root/cuda-upgrade-check/postboot.qVQlHO/` also does not describe the stress solver.

```bash
export PATH="$PWD/.toolchains/build-env/bin:/usr/local/cuda-13.4/bin:$PATH"
ncu --version
nsys --version
nvidia-smi
ncu --import out/vm-port-20260910/motion-slots-counters.ncu-repz --page details
```

One-kernel proof, only if environment changed (use a fresh report destination):

```bash
ncu --section SpeedOfLight --launch-count 1 \
  --export out/NEW-EXPERIMENT-motion-slots \
  out/vm-topology/destruction_motion_slots_test
```

This command was successfully exercised during migration. Do not rerun it as a
substitute for profiling the expensive real scene.

## Historical newer-collector thread-boundary issue

[Standalone reproduction and native diagnostic](../../../qualification/nsight-cross-thread-20260910/README.md)
is now the fastest entrypoint for the stage-1288 attachment failure. On the tested
Nsight 2026.3 / CUDA 13.4 / driver 615.71 stack, conditional executable graphs
instantiated on one CPU thread and launched on another execute false branches
under attachment even with collection off. Instantiation on the launching thread
passes; merely uploading again does not. The minimal program has two kernels,
one IF node and serialized API access; repeated plain controls and memcheck pass.

An isolated zero-worker inline CPU dispatcher build passes the 29-case native
correction fixture under actual counter collection. Build it using
`tools/diagnostics/nsight-cross-thread-conditional/build-native-inline.py`; the
helper also supports `--target native_destruction_demo`. The [city diagnostic](../../../qualification/ncu-city-20260910/README.md)
now completes first/later stress counter captures with recorded poses byte-identical
to a matched four-worker control over 180 steps; iteration histories still differ.
Use its three mapped launches and source/PC evidence rather than repeating the
attachment investigation. Production scheduling stays unchanged. Its inline
CPU/complete-step timing cannot qualify production speed or full physical parity.
Do not repeat the unchanged huge failing capture or alter production conditional
branches/synchronization to accommodate the profiler. The exact vendor-component
fault is still unidentified; the standalone report is prepared but not submitted.

## Offline numerical replay and software instrumentation

[Native load-join evidence](../../../qualification/elastic-load-join-20260910/README.md)
contains a separate CUDA 702 launch timeout in `SW Counters::1` on a multi-second
rejected numerical solve. Hardware-only metrics complete on that same saved
executable. Start with `gpu__time_duration.sum`,
`sm__pipe_fp64_cycles_active.avg.pct_of_peak_sustained_elapsed`,
`sm__warps_active.avg.pct_of_peak_sustained_active`,
`smsp__warps_eligible.avg.per_cycle_active` and
`dram__throughput.avg.pct_of_peak_sustained_elapsed` for that case. They do not
establish spilling or source-PC attribution. Preserve the failed full-section
capture; do not change driver timeouts or repeat it unchanged.

The `--fine-setup` replay permits attribution and profiling of setup without
repeating failed 8192-iteration solves. Distinguish profiler collection success
from a diagnostic application's intentional rejected-query exit 1. Check exact
setup/solve receipts and exported numerical data before comparing versions.
An uncalibrated stiffness profile and a successful initial solve do not establish
native physical equivalence, accepted material behavior or real-time capacity.

## Actual peak investigation

1. Record revision/dirty patch, binary/library hashes, driver/toolkit, clocks,
   temperatures and all competing GPU processes (including graphics). Desktop
   Xorg/KDE is running; do not stop it without authorization. If not isolated,
   label the measurements diagnostic. Do not infer that absence of compute
   processes means no graphics interference.
2. Use the existing recorded scene/commands, not a visually similar recreation.
   `tools/profiles/destruction-scaling.json` case `impacts-256` is 256 buildings,
   113,664 chunks, 229,376 bonds, one 256-shot wave. Historical 768-shot/600-step
   reports are different command tapes: never compare them as matched workloads.
3. The existing scaling/wall JSON common arguments select GPU connectivity owner
   1. For the intended ordinary API use a versioned derived config with
   `--gpu-connectivity-owner 0 --standard-scene 1 --sleeping 1`, leaving physical
   inputs unchanged. Record the exact derived config/hash and actual scene flags.
   Add a genuinely pristine idle case with no projectiles. `world-256` means a
   localized impact in a large world, not automatically idle.
4. Use `run-destruction-timing.py --help` to select the derived config/case and
   separate `--gate-only` timing from `--phase-scopes` attribution. Existing
   `analyze-native-destruction-phases.py`, `report-native-destruction-phases.py`
   and `analyze-native-gpu-profile.py` provide accounting; extend these instead
   of inventing another report system.
5. Timeline first: use Nsight Systems CUDA/NVTX tracing or existing phase/CUDA
   activity capture on a short trajectory that reaches the relevant peak. Inspect
   gaps, dependencies, CPU registration and GPU serial tails. Identify actual
   kernel names and solve ordinals; old tick 48/solve 50-51 mappings are historical
   and must not be assumed on the changed GPU/toolchain/API mode.
6. Counter second: select those stress, ownership or topology launches via ncu's
   kernel filter and launch skip/count options (check installed `ncu --help`).
   Start with SpeedOfLight, MemoryWorkloadAnalysis and SchedulerStats; add launch,
   occupancy, source or warp-stall sections to test a particular explanation.
   Record replay/cache policy and whether the target uses cooperative/graph
   launches. If collection is unsupported for a launch, preserve the error and
   use a matching isolated replay; do not change production synchronization to
   make profiling succeed.
7. Rank opportunities by measured peak exposure, necessary work, critical-path
   dependency and replacement cost. Check multiple peak ticks. Idle reuse has a
   separate benefit; do not discard it because simultaneous destruction dominates.

The old `run-native-scaling-profile.py` defaults to sleeping off and analysis
excludes warmup; older analyzer explanatory strings can assume Direct GPU mode.
It is not a ready-made ordinary-API every-step gate. Inspect options/metadata and
use zero excluded steps for authoritative deadlines. Missing/incorrect metadata
needs a report fix, not an inferred favorable result.

## Interpret and optimize

- Low DRAM throughput does not prove compute-bound; it can reflect dependent
  gathers, insufficient eligible warps, synchronization or a small working set.
- Distinguish logical adjacency traffic from measured DRAM traffic and cache hits.
  Do not extrapolate 4090 results linearly from SM count, FLOPS or bandwidth.
- Inspect spills/local memory, registers/shared memory per block, active/eligible
  warps, stalled issue and occupancy alongside elapsed time. More shared caching
  can reduce useful residency; theoretical occupancy alone is not a goal.
- Stress already uses resident component iteration and independent convergence.
  Sum actual component iterations/operator/preconditioner visits; maximum
  iterations times total bonds is not actual work. Stress islands differ from
  motion clusters and collision/constraint correction closures.
- A CPU wait may include GPU stress; correction includes physics and lifecycle.
  Do not sum overlapping GPU/CPU scopes or promise the entire wait is removable.
- Fewer iterations or a faster isolated kernel is insufficient if setup, packing,
  synchronization, damage evaluation or publication offsets it. Preserve exact
  physical requirements and separately score architecture/maintainability.

For claims, measure matched fresh idle and destruction without profiling, alternate
baseline/candidate order, retain every sample and expose first-step/runtime-growth
spikes. Report total/active motion bodies, chunks/bonds, contacts, processed stress
work, fractures, correction participants, simulation duration/repeats and complete
peak. Full promotion requires five 60-second trials and endurance after focused
quality gates pass. Current migration failures prevent parity/performance promotion;
they do not prevent gathering honestly labeled diagnostic evidence.
