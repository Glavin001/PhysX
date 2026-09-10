---
name: physx-destruction-profiling
description: Investigate destruction peak and idle costs using available Nsight counters, CUDA timelines and untraced complete-step measurements on the migrated PhysX VM.
---

# Destruction profiling with hardware counters

Read [AGENTS.md](../../../AGENTS.md) for machine/status and the
[performance skill](../../../.agents/skills/physx-destruction-performance/SKILL.md)
for physical and experiment requirements. Counter availability is verified; a
stress bottleneck or optimization win has NOT yet been established by counters.

## Evidence levels

1. Exact equation replay or small fixture: screen mechanisms/correctness quickly.
2. Diagnostic trajectory + timeline/counters: identify work, latency/dependencies
   and resource pressure. Label numerical parity failures independently.
3. Matched untraced complete advances: establish actual performance improvement.

A `ncu`-replayed kernel duration is not production latency. Do not run the entire
600-step bombardment under full counter collection: discover the hot kernels
first, select a small relevant launch range and sections, then expand only to
resolve a specific hypothesis. Keep all untraced first steps and peaks.

## Start from current captures

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
