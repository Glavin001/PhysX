---
name: physx-destruction-performance
description: Reproduce, interpret and improve complete-step performance of this repository's integrated RTX 4090 PhysX destruction pipeline. Use for destruction peak investigations, GPU ownership or stress optimizations, benchmark comparisons and real-time destruction-capacity tests.
---

# PhysX destruction performance

Optimize verified physical work per complete simulation advance. The primary
workload is 256-building bombardment; sustained/staggered bombardment is a
separate capacity axis. The physical timestep remains 1/60 second, with at most
one internal correction. The targets are every step <=8 ms, and separately
real-time at <=1000/60 ms. A low mean or a real-time-looking video is insufficient.

This is a repository-local skill. Run its commands from the repository root;
resolve the documentation below relative to this skill, not the shell cwd.

## Read only what the task needs

- **Running/building/comparing:** [Performance playbook](../../../docs/destruction/PERFORMANCE_PLAYBOOK.md).
- **Interpreting timings or ranking ideas:** [Measurement contract](../../../docs/destruction/PERFORMANCE_MEASUREMENT.md).
- **Choosing an optimization / avoiding repeats:** [Findings and failed experiments](../../../docs/destruction/PERFORMANCE_FINDINGS.md), then the relevant rows of [optimization inventory](../../../docs/destruction/OPTIMIZATION_INDEX.md).
- **Resuming implementation:** [Dated handoff and code map](../../../docs/destruction/PERFORMANCE_HANDOFF.md). Verify current source and artifacts before treating dated status as current.

## Essential decisions

1. Inspect Git changes, any live GPU/build job, matching runtime/demo artifacts,
   configuration and existing evidence. Continue a confirmed live job; an
   observation timeout is not failure. Do not rerun an unchanged measurement
   merely because conversation context was lost.
2. State one mechanism, its measured exposure at the relevant peaks, the work it
   will remove and its correctness conditions. Prioritize deletion and final
   GPU ownership before tuning necessary kernels. Do not optimize a CPU bridge
   that the intended architecture removes.
3. Keep NVIDIA rigid-body computation as the foundation. Our integration can
   remove redundant lifecycle work at producer boundaries; rewriting ordinary
   broad/narrow phase is not the current focus.
4. Preserve actual solved normal/friction impulses, force/torque application,
   complete stress/material verdicts, convergence, damage accounting and motion
   correction of affected ordinary participants. Never obtain a speedup by
   suppressing fragments/contacts, relaxing tolerances, adding damping/freezing,
   predicting breakage or spending the stress iteration budget across frames.
   The last policy exists in the historical source but changes the frozen
   native within-step-convergence contract; discuss/qualify it separately.
5. Build all affected ABI consumers before execution. Run focused checks and the
   frozen penetration regression. Screen candidates on matched untraced inputs;
   profile separately. Reject isolated-kernel wins that fail whole-step peaks.
6. Record one outcome: accepted with its actual qualification level, rejected
   with evidence and reverted production changes, or still unqualified WIP.
   Preserve a patch, hashes and raw samples for rejected experiments; don't
   retain an alternate production switch to make them selectable.

## Non-obvious pitfalls

- `complete_step_ms` is authoritative. `physics_step_ms` excludes commands and
  mandatory completion. `stress_solve_ms` can be a compatibility zero field.
- A wait containing GPU stress is not removable CPU overhead. Nested CUDA
  intervals, parallel CPU tasks and aggregate kernel durations cannot be summed
  into wall time. Use the generated disjoint phase report.
- Native stress iterations already run inside component kernels with independent
  convergence retirement. General settled-island reuse across timesteps is
  still incomplete; zero fracture or sleeping does not establish valid reuse.
- Stress islands, motion clusters and contact/constraint islands differ.
  `stress_iterations` is a maximum, not total numerical work. Authored chunks
  are not independently simulated rigid bodies.
- Staggering changes input history and possibly the total fracture. It measures
  capacity; it is not an equal-input implementation speedup. Include late rubble
  and actual broken bonds/new clusters, not just projectile rate.
- No available hardware counters means no proved bandwidth/compute/occupancy
  bottleneck. Use event timelines, actual work counters and controlled matched
  experiments; label remaining hypotheses.
- Timing report exit 2 can mean a completed run failed the deadline/duration
  gate. Inspect `campaign.json` and logs before retrying. Never hide that exit
  with an unconditional success wrapper.

## Scope and reporting

Work stays in this repository. `vibe-land-4` and `blast-stress-solver-2` are
read-only references. Current native optimization targets RTX 4090/sm_89 and
CUDA >=12.8; do not introduce compatibility fallbacks. Keep unrelated upstream
platform support and independent physical reference targets.

Run GPU jobs sequentially and keep builds/heavy audits outside performance
captures. Never stop another developer's GPU process/service. If the environment
cannot isolate the GPU, preserve diagnostic evidence without claiming isolated
performance qualification.

Every reported timing needs workload, chunks/bonds/projectiles, active work at
its peak where available, duration/repeats, timer scope and qualification limits.
Link the generated report. A proposed savings percentage is an assumption, not
measured evidence: account for overlaps and the next-worst step becoming the
peak. Completion requires the original architecture, physical-quality and
endurance gates, not just a short successful demo.
