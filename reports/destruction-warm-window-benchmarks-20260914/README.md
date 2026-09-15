# Restore, warm, then measure complete destruction ticks

2026-09-14. Measurement-harness change only; selected runtime/source remain
`d5770a80` / `13b11af2`. No solver optimization or numerical-quality change.

The new replay mode restores a physical snapshot once, advances a fixed number
of real ticks, then measures one tick or a short consecutive window. This rebuilds
disposable state naturally and amortizes restoration across the measured window.
Warmup advances physical time: the measured tick is **not** the original snapshot's
next tick. Never rewind bodies while retaining caches built for another state.

All commands, CPU preparation, PhysX, destruction/stress/material/topology work,
transfers, synchronization, accepted publication, and any required correction and
second stress remain inside the complete-step timer. The maximum correction count
is one. Restore, full observation validation and teardown are outside that timer
and recorded separately. Warmup times are preserved, including first-use costs.
Sleeping and ordinary PhysX APIs remain supported; Direct GPU API is disabled.

## Measured result

The final nine-window same-build calibration passes all nine independent-process
physical comparisons and both profiled comparisons. It takes **204.338s (3m24s)**
for capture/checks, plus **1.512s** for offline SQLite/CSV export and extraction:
**205.850s of measured processing in total**; build time and the separate pilot/
rejected-history investigations are excluded. There are 320 plain measured ticks,
780 separately recorded warmup ticks and 36 reconstructed trajectories across18
plain processes. The two profiler runs add64 diagnostic ticks, including warmup.
The full current cold52 suite was not rerun for this harness-only task.

[All nine means, peaks, deadline misses, stages, preparation and work counts](measurements.md).
The large idle city now measures **1.659–1.692ms** per warm tick, versus
**66.184–79.105ms** for the first post-restore tick in this cohort. The restored
state represents the same intact stationary world, but its derived equilibrium
must be prepared on first use. This is a measurement distinction, not a solver
optimization. Dense/tower warm cases likewise mostly exercise equilibrium reuse;
their cold numerical-solve companions must remain in optimization coverage.

Active windows still miss real-time budgets: city25 impact22.607–22.761ms,
city256 impact88.772–90.104ms, cascade103.736–105.945ms and restored-debris
continuation124.455–124.662ms. All are complete ticks outside the profiler.
Large idle, impact and cascade windows match all nine archived uninterrupted
work counters in both processes against four historical controls. The restored
late-debris continuation differs; it is explicitly a different history.

The warmed Systems tick records903 kernels,307 copies totaling98,688,864bytes,
and579 CPU samples within its208.449ms instrumented range. Recorded GPU activity
union is99.959ms; the remaining interval is **not** an exclusive CPU compute
measurement. This capture reports boundary-event completeness warnings and42
CPU sampling throttles, so it is diagnostic and **not certified exhaustive
attribution**. Its physical endpoint and work history pass. The profiler tick
must not replace the124.5ms plain timing. Two one-pass NCU stress captures also
pass physical checks:32.05–32.21% achieved occupancy,10.65–10.69% issue activity,
109registers/thread. Hardware counters use the existing kernel-replay/cache-control
`all` configuration; those are not production warm-L2 latency measurements.
Raw reports, counter CSV, timeline SQLite, phase CSV and extracted analyses are
saved for later investigation. [Structured profile summary](data/profile-summary.json)
and [uninterrupted work comparison](data/continuous-work-audit.json) require local data.

The final screen qualifies this measurement mode for the declared windows. It
is a small same-build control study, not a claim that every restored scene is
identical to an uninterrupted scene or that tiny timing differences are resolved.

## What is implemented

- `serialization-probe --replay PREFIX --warmup-ticks W --measure-ticks M` keeps
  one reconstructed world alive through W+M real ticks per repetition. Omit both
  new options to retain the original one-tick cold replay behavior.
- Every warmup and measured tick records full-step time, command/integrated/completion
  partitions, frame, contacts, iterations, fractures, stress passes, correction,
  islands, active nodes/bonds and output clusters. Full state observations happen
  after the window, avoiding extra validation transfers between its ticks.
- The first measured tick of the first repetition has the existing full-tick
  CUDA-profiler/NVTX boundary in the profiling-only build. Nsight does not select
  the first cold tick by accident. Profiled times are not production timings.
- A separate versioned checker validates W/M/stimulus equality, consecutive frames,
  exact sample selection and timing partition, all tick work histories, and endpoint
  physical observations. Original motion/force tolerances and exact material/load
  checks remain unchanged. The frozen cold checker is untouched.
- The serial plan runner owns the shared GPU lease, records binary/module/input
  hashes, enforces a time budget, and restores the desktop. A failed plain
  qualification prevents subsequent profiling. The plan generator supports
  independent A0/B/A1 processes with candidate-specific consumer/runtime paths.

Two restores in a process are repetition checks, not two restores per measured
tick. With W=8 and M=8, one restore produces eight warmup and eight measured ticks.
For statistical confirmation, independently started trajectories/processes are
replicates; adjacent ticks are correlated and must not be treated as independent
samples. The small default screen detects substantial effects and regressions;
it does not promise 1% precision or replace finalist qualification.

## Qualification and the long-history limit

An initial old-consumer versus new W=0/M=1 bridge comparison passes the unchanged
physical gates. Warm idle/bridge and impact/debris pilots pass their repetition
checks. The contract tests deliberately reject hidden warmup, missing ticks,
nonconsecutive frames, mixed measurement selection and invalid timing partitions.

The first long-history proposal restored the intact city at nominal tick40,
warmed147 ticks, and measured187..194. Two identical-build processes first differ
at tick121 by two contact points, then diverge in later physical/work histories.
Both internally repeat, but their cross-process endpoint generations differ. This
proposal **fails equivalent-physics A/B qualification**. Its evidence is preserved;
no acceptance threshold was relaxed. The recorded divergence does not identify
its underlying numerical/contact-order cause.

For early impact, restoring at40 and warming42 ticks preserves the recorded
uninterrupted run's nine observed work counters throughout82..89. This is work-history
agreement, not a full force/pose proof against the original uninterrupted run.

For late debris, the short mode starts from the real snapshot179, warms8 ticks,
and measures the continuation187..194. These are qualified reproducible *post-restore*
continuations: their cross-process physical gates pass. Their results must
not be presented as the original uninterrupted trajectory: warmup cannot undo a
change in collision/solver history caused by restoration. Keep uninterrupted
heavy runs as the authoritative long-trajectory companion.

## Reproduction

From `/root/workspace/physx-2`, use fresh output directories:

```bash
python3 tools/diagnostics/destruction-snapshot/build-warm-probe.py out/NEW-warm/plain
python3 tools/diagnostics/destruction-snapshot/build-warm-probe.py out/NEW-warm/profile --profile
python3 tools/diagnostics/destruction-snapshot/make-warm-screen.py out/NEW-warm/plan.json \
  --binary out/NEW-warm/plain/serialization-probe \
  --profile-binary out/NEW-warm/profile/serialization-probe \
  --artifacts out/destruction-baseline-20260913/artifacts
python3 tools/diagnostics/destruction-snapshot/run-warm-suite.py \
  out/NEW-warm/plan.json out/NEW-warm/results --manage-desktop --budget-seconds 300
python3 tools/diagnostics/destruction-snapshot/export-warm-profiles.py out/NEW-warm/results
python3 tools/diagnostics/destruction-snapshot/test-warm-window-contract.py
```

The builder reuses hash-verified selected host objects/static libraries from the
N20 archive, compiles only the benchmark consumer, and records all dependencies.
It does not rebuild the mutable SDK or promote experimental source. Candidate
builds must use that candidate's matching host libraries; pass its consumer,
profile consumer and runtime artifacts to `make-warm-screen.py` via
`--candidate-binary`, `--candidate-profile-binary`, `--candidate-artifacts`.

For a single warmed measured tick on an already exclusive GPU:

```bash
PHYSX_SNAPSHOT_DUMP_OBSERVATIONS=first python3 tools/diagnostics/destruction-snapshot/run-probe.py \
  out/NEW-single-warm --binary out/warm-replay-20260914/plain/serialization-probe \
  --artifacts out/destruction-baseline-20260913/artifacts \
  --replay-prefix out/snapshot-large-20260911/capture-16-idle/native/snapshot-40 \
  --repetitions 2 --warmup-ticks 16 --measure-ticks 1
```

`--projectile-impulse`, if explicitly selected, is submitted on the first measured
tick, and its CPU submission is timed. Existing moving projectiles continue
through warmup. These fixture snapshots have no pending gameplay commands; a new
fixture with scheduled external input must record and replay that schedule too.

## Evidence locations

All raw evidence is ignored and local, not included in Git:

- `out/warm-replay-20260914/plain/build.json`, `profile/build.json`: builds/dependencies.
- `pilot/`: cold compatibility, bridge/idle warmup,17.21s total.
- `active/`: city25/city256 impacts and short restored-debris pilot,29.43s total.
- `screen/`: rejected long-history comparison and its preserved Systems trace;
  counter expansion stopped after cross-process trajectory qualification failed.
- `final/`: corrected nine-window same-build calibration and selected profiles.
- Each capture has `receipt.json`, `replay.json`, endpoint observations and logs.
  Plain timings and profiler evidence are separate captures.

The source, tools and report remain local and uncommitted under the current user
commit policy. The original cold52 suite, historical evidence and stopped runtime
optimization campaign remain preserved.
