# Fast, profiled optimization experiments

The long campaign collected full hardware counters across 52 scenarios and many
launch configurations. The previous ordinary-counter tier alone required
24,709 seconds (6.86 hours). Full sets needed dozens of replay passes. That is an
exhaustive attribution audit, not an appropriate per-change feedback loop.
Making its completion a prerequisite for fast experimentation was unnecessary.

On 2026-09-13 the user limited additional baseline collection to roughly ten
minutes. The exhaustive expansion and its waiting collectors were stopped;
completed CPU 52 and graph 48 captures remain available. The extended continuous200
cohort is deferred. Existing full 180- and 600-tick trajectories remain usable.
No runtime or correctness policy changed.

## Routine profiled loop

Target about 3 minutes with Systems, and 4–5 minutes when focused hardware counters and their validation are also needed.
Compile/link time is separate and must also be recorded; these figures do not
promise a rebuild of the entire SDK in three minutes.

1. State the hypothesis and its affected scenarios. Reuse the frozen baseline's
   full 52 timeline/counter evidence and existing physical inputs.
2. Run the seven-case light A-before/B/A-after comparison: 120 complete ticks,
   equal first-use weighting, physical comparisons, fixed quality, no profiler.
   The measured same-build calibration took134.105 seconds including admission,
   temporary desktop isolation/restoration, restore, checks and report generation.
   Its tick latency excludes restore/check/export. This is the performance verdict.
3. Capture one or two affected candidate scenarios with Nsight Systems: full tick,
   CPU samples/stacks, native phases, every traced kernel and transfer, CUDA/OS
   waits and overlap. Reuse a compatible baseline trace for the same input.
4. For GPU mechanisms, capture one or two representative launches with Nsight
   Compute and the metrics needed to test the hypothesis. The initial five-metric
   set covers duration, registers, active warps, issue activity and DRAM bytes.
   Switch or expand the set when the diagnosis needs memory access, source stalls,
   precision instructions or another specific question. Do not collect every
   metric/configuration on every experiment. A CPU lifecycle change may need no
   new kernel counters; Systems is still collected.
5. Save full-step mean/peak/stages/deadline misses for every light scenario,
   physical results, profile locators, metric scope and wall cost. Classify as
   promising, slower, or inconclusive. No automatic promotion.

The profiler explains why performance changed; instrumented/replayed durations
do not decide application speedup. Systems retains every launch in the selected
tick, so a focused NCU selection does not erase visibility of other GPU work.
Individual conditional graph node/source counters remain unavailable with the
qualified collector; graph aggregates and timeline evidence are retained.

## Signal and escalation

The light suite covers bridge, long chain, dense loops, command stimulus, city25
initial fracture/correction, city256 intact idle and city256 debris. It does not
cover every possible semantic trait. Choose additional targeted timing/profile
cases from the existing 52 when the hypothesis affects a missing regime, such as
tower, panel, ladder, wall penetration or a later fracture stage. Report added
wall cost instead of silently changing the frozen light preset.

The first identical-build calibration already shows process-to-process noise.
Its descriptive sample intervals cannot establish uncertainty between independent
processes. A one-minute screen cannot reliably establish every small effect.
For an ambiguous result, repeat only the affected scenario with equal larger
cohorts and a fresh trailing control, usually within another 1–3 minutes. Preserve
all samples, especially the first tick, and compare against observed A/A variation.

Full 52, longer continuous trajectories and the required numerical/memory/physics
gates belong to finalist qualification. A targeted full NCU section is warranted
when a concrete unresolved question needs it. Another hours-long exhaustive
counter expansion is not part of routine optimization and is currently deferred.

## Reproducible command

The calibration uses the existing frozen replay/profiling harness and selected
N13+N20 artifacts. For an experiment, substitute the newly built candidate probe,
profile probe and GPU-library directory; all must describe the same candidate
source. The profile probe includes instrumentation, while the plain probe does not.

```bash
python3 tools/diagnostics/destruction-snapshot/run-experiment-screen.py out/NEW-experiment \
  --baseline out/destruction-baseline-20260913/fast-baseline.json \
  --candidate-binary out/CANDIDATE/plain/serialization-probe \
  --candidate-artifacts out/CANDIDATE/artifacts \
  --candidate-commit CANDIDATE_COMMIT \
  --hypothesis 'Concrete work removal and expected affected scenarios' \
  --candidate-profile-binary out/CANDIDATE/profile/serialization-probe \
  --profile-scenario city256-late-debris \
  --ncu-kernel regex:componentStressSolve \
  --manage-desktop --budget-seconds 240
```

The shared GPU lock spans the entire command. No build/other benchmark overlaps.
The budget covers timing, profiles, exports and checks; a timeout preserves partial
files and marks the screen incomplete. It does not turn an incomplete physical
comparison into a successful performance result. Use up to 300 seconds explicitly
for difficult scenarios instead of silently falling back to an hours-long run.

Outputs include `screen.json`, `matched/report.md` and JSON, raw per-arm replay
samples, observations/physical comparisons, receipts/hashes, `systems/` with
Nsight reports/SQLite/attribution, and `ncu/` with native report/CSV/JSON. No captured
data is deleted when the budget is exceeded. These local raw archives are not
automatically backed up remotely or committed to Git.

[Measured calibration, all scenarios and the preserved 180-second cutoff](fast-calibration.md). Systems finished; the NCU wrapper receipt was interrupted. Default budgets are180 seconds without NCU and 240 seconds with NCU.
