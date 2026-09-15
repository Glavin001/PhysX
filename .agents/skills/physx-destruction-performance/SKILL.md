---
name: physx-destruction-performance
description: Reproduce, interpret and improve complete-step performance of this repository's integrated PhysX GPU destruction pipeline. Use for destruction peak investigations, GPU ownership or stress optimizations, benchmark comparisons and real-time destruction-capacity tests.
---

# PhysX destruction performance

## Fast measurement entrypoint

For running or resuming a benchmark, read
[fast warm measurement](references/fast-warm-measurement.md) first. It contains
verified commands, frozen-window selection, candidate/control setup, escalation
rules and the lessons from full52 collection. Reuse compatible saved evidence;
reserve full coverage expansion for a demonstrated gap or finalist qualification.
The measured warm A0/A1 screen took205.850s including exports. A0/B/A1 adds a
candidate arm; that turnaround is not yet calibrated. Cold solves and uninterrupted
idle/heavy remain required companions when the proposed mechanism affects them.
After each experiment, record actual turnaround and the smallest reusable lesson
in the existing history/skill; never describe an estimated harness saving as measured.

Follow the user-approved [removal-first workflow](../../../docs/destruction/REMOVAL_FIRST_WORKFLOW.md)
for current optimization work. Prioritize substantial application savings through
removal, conditional execution, data ownership and algorithm changes. Use work
counts to prove intermediate mechanism changes; do not demand a statistically
resolved tiny timing win at every edit. Confirm completed bets with matched
full-step timings and selected profiles, then qualify finalists across full52
and the required continuous/numerical/memory/trajectory gates. The measured
five-minute screen is not mandatory for every intermediate commit.

Current VM/toolchain and validation status are in [AGENTS.md](../../../AGENTS.md).
Use the [VM validation skill](../../../.agents/skills/physx-vm-validation/SKILL.md)
and [hardware-counter workflow](../../../.agents/skills/physx-destruction-profiling/SKILL.md)
for the RTX 5060 Ti / CUDA 13.4 port. Older 4090/no-counter statements in dated
playbooks describe historical evidence, not this machine.

Optimize verified physical work per complete simulation advance. The primary
workload is 256-building bombardment; sustained/staggered bombardment is a
separate capacity axis. The physical timestep remains 1/60 second, with at most
one internal correction. The targets are every step <=8 ms, and separately
real-time at <=1000/60 ms. A low mean or a real-time-looking video is insufficient.
Every application-performance qualification must measure fresh intact idle and peak
complete-step cost during destruction on matched scenes/settings. Keep startup
spikes; zero awake debris after damage is not an intact-idle sample. Report
missing regimes as incomplete qualification.

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
   The user's permission to explore precision tradeoffs is preserved: establish
   and document the physical-quality budget first, independently qualify it,
   and never waive a failed current gate or call changed quality an equal-quality win.
5. Build all affected ABI consumers before execution. Run focused checks and the
   frozen penetration regression. Screen candidates on matched untraced inputs;
   profile separately. Judge whole-step improvement in the declared target regime
   (idle, settling, sleeping rubble or active destruction), and check the other
   regimes for regressions. An idle win does not require a fracture-peak win;
   an isolated-kernel win alone is insufficient.
6. Evaluate correctness, architecture, maintainability and performance separately.
   A neutral timing result may retain a final-ownership change when a named next
   consumer needs it and redundant code/dependencies are removed. Label that as
   architectural progress, not a measured speedup or completed replacement. A
   reliable slowdown requires a concrete bounded tradeoff; a physical regression
   cannot be waived. Do not restore archived caches/layouts merely because they
   look GPU-oriented.
7. Record one outcome: accepted with its actual qualification level, rejected
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
- Hardware counters and extensive saved profiles are available. Read the current
  report's identity/coverage before reusing them; historical policies differ.
  Use targeted counters to test a mechanism and timelines to establish exposed
  critical-path work. Do not restart exhaustive capture to test each edit or
  equate fewer launches/instructions with a complete-step gain.
- Timing report exit 2 can mean a completed run failed the deadline/duration
  gate. Inspect `campaign.json` and logs before retrying. Never hide that exit
  with an unconditional success wrapper.

## Scope and reporting

Work stays in this repository. `vibe-land-4` and `blast-stress-solver-2` are
read-only references. Current VM work targets RTX 5060 Ti/sm_120 with CUDA >=13.4;
RTX 4090/sm_89 records are historical controls. Do not introduce compatibility
fallbacks. Keep unrelated upstream
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
