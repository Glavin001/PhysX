---
name: insight-reporting
description: Create and maintain evidence-backed analytics and performance insight reports in this repository, including scenario comparisons, data-flow diagrams, timing attribution, plots, provenance and qualified conclusions. Use when asked to report findings or archive analysis, rather than for routine status replies.
---

# Insight reporting

Turn an analysis into a durable report that a reader can understand without the
conversation and another engineer can audit without guessing what was measured.
Use the user's chosen scope. This skill governs reporting, not permission to
start experiments or a replacement for the optimization acceptance protocol.

## Store the report with its evidence

Repository storage policy: the user explicitly excludes raw experimental evidence
from Git. Keep raw captures, observations, logs and generated datasets locally in
ignored `out/`, report `data/`/`evidence/`, or qualification output paths. Commit
readable reports, compact plots, reproduction source and concise provenance or
capture locators only within the current session/AGENTS commit scope. The current
scope keeps source/tools/skills/detailed reports local and uncommitted; only final
summaries/insights are eligible for a separately authorized commit. Updating a
report is not an instruction to commit it. Follow `.gitignore`; never force-add
ignored raw data. State
which report links require the local dataset and do not imply those payloads are
included in a fresh clone. Existing historical Git data need not be rewritten.

Create `reports/<descriptive-kebab-case-headline>/` and add a dated entry to
[the report index](../../../reports/README.md). Use `README.md` as the entrypoint.
Keep accompanying plots, diagram sources, CSV/JSON, provenance and any useful
regeneration script inside that folder; add subdirectories only when helpful.
The [first report](../../../reports/destruction-full-step-bottlenecks/README.md)
is a concrete example, not a requirement to repeat its size or exact layout.

Record the publication date separately from measurement dates and the code/data
cohort. Distinguish a historical report from current implementation status. Keep
original evidence unchanged; label corrections or subsequent findings with dates
and links. Never silently replace failed attempts or old baseline samples.

Archive portable chart outputs and the data behind them, not only chat links or
machine-local visualization paths. Prefer relative links within the package.
Keep very large profiler captures in their existing archive and give their exact
locator, identity/hash and availability; do not imply the package contains them.
Small decisive source summaries can be copied into the report. Record external
rendering dependencies and preserve an offline-readable table or data file.
Never include credentials, private service environments or unrelated dumps.

## Explain findings in the order a reader needs them

Lead with the observed outcome and its practical implication. Then show the
scope, supporting comparisons/figures, interpretation, limitations and next
experiments. Use clear paragraphs, descriptive captions, parallel lists and
comparison tables where useful. Explain technical terms at the point they matter;
put detailed commands, symbols and full tables after the main finding.

For each important claim, distinguish:
- **Measured:** source, scenario, units, sample count and observation.
- **Inference:** the mechanism suggested by the measurement and alternatives.
- **Hypothesis:** a proposed change, affected scenarios and how to refute it.
- **Decision:** retained, rejected, neutral architectural benefit, or unqualified.

For removal-first optimization, also show a before/after work ledger for the
affected scenarios: actual visits, solves/iterations, transfers/bytes, rebuilds
or allocations as appropriate. Define each counter and its collection scope;
mark missing instrumentation explicitly. A deterministic removal can be a
conclusive mechanism result without a new statistically significant timing gain.
Report it as such, with its named architectural follow-up and remaining
application qualification. Do not invent a universal compute score or require
a long timing campaign merely to document an intermediate removal.

Report regressions and missing evidence beside wins. Separate correctness,
performance and architectural simplification. An enabling change needs a concrete
follow-up it enables; it is not automatically a speedup. Do not infer equivalent
physics from timing or fewer solver iterations alone. Do not describe a build,
pilot, selected-kernel capture or light-suite pass as full qualification.

## Keep the measurement contract visible

For warm-window reports, follow the
[fast measurement reference](../physx-destruction-performance/references/fast-warm-measurement.md).
State W/M and stimulus history, distinguish warm/cold/uninterrupted cohorts, and
identify physical endpoint checks separately from timed-tick counts. Record actual
build/queue/capture/check/export turnaround where available, profiler warnings and
coverage tier. Same-build calibration time is not measured candidate turnaround.
End each experiment's report with the reusable lesson and the next condition that
requires fresh evidence; update the relevant skill narrowly when supported.

For this repository, follow [OPTIMIZATION.md](../../../OPTIMIZATION.md) and current
AGENTS.md for execution and acceptance. Reuse compatible existing evidence before
collecting more; report preparation alone should not interrupt live GPU jobs.

The primary latency is the complete real-time tick: commands and CPU preparation,
PhysX, stress/material/topology, transfers, waits, accepted publication and any
required correction/second stress. Preserve current-tick contacts, ordinary APIs,
sleeping and at most one correction. State the actual mode rather than assuming
it. Keep restore, validation and harness teardown outside tick latency; record
initialization and relevant setup costs separately. Do not hide setup moved into
the tick or amortize it without identifying the amortization workload.

Keep independent restores and continuous warm trajectories as separate cohorts.
A saved state's cold/warm label describes its physical history; restored numerical
and contact caches may be rebuilt. Do not pool different builds, configurations,
precision/tolerances, replay modes, workloads or profiler settings. Identify
executable/runtime commits or hashes, workload/input identity, hardware/toolchain,
measurement order and profiler status from the source evidence. Mark missing
metadata explicitly instead of inferring it from today's environment.

For scenario comparisons show scale and semantic traits (chunks, bonds, islands,
contacts, damage phase, correction count) where they explain cost. Always include
idle and heavy destruction when making broad performance claims; if absent,
state the coverage gap. Show each measured scenario in the data/full table even
when the main figure focuses on hard cases. Include full-step mean, observed
maximum, sample count, spread and exact deadline misses; for60Hz use1000/60 ms,
not a rounded threshold. Record initialization, stage costs and convergence work
when available. Label representative physical counts as such.

Preserve raw repetitions and first-use samples. State outlier/warmup exclusions
and why they apply. Use matched baseline/candidate order and repeat confirmation
appropriate to noise. Do not invent a universal sample count or treat20 samples
as proof of significance. If reporting intervals, state the method, sampling unit
and independence assumptions; consecutive frames are not independent runs.
Observed maxima are not worst-case bounds. Keep percentages within their matched
cohort; do not add speedups from unrelated experiments.

## Make attribution and plots honest

- Use a dependency/data-flow diagram for causality: label CPU/GPU ownership,
  payloads, transfers, required joins and conditional correction. Explain when
  it is conceptual rather than a measured execution timeline.
- Use aligned timeline lanes for overlap and stacked charts only for mutually
  exclusive time partitions. Nested scope totals and summed thread CPU time are
  not additive wall time. A blocked main thread can coexist with useful workers.
- Keep profiler durations separate from unprofiled full ticks. Instrumentation,
  replay and scheduling perturbation can be large. Never rescale profile fractions
  into production milliseconds or claim GPU inactivity is all removable work.
- Distinguish transfer bytes, summed duration and interval union; copies may
  overlap kernels or CPU work. Keep clocks aligned with verified anchors. Label
  unattributed gaps, sampling loss, invalid metrics and conditional-graph limits.
- Use labeled units, stable category colors, readable axes and a visible budget
  reference. Show mean versus observed maximum distinctly. Preserve narrow-screen
  readability and make important values available without hover. Prefer diagrams
  or small multiples over decorative dashboards. Choose interactive plots for
  exploration and standard static plots when export/publication is the purpose.
- A counter or iteration reduction is mechanism evidence, not an application win.
  Separate measured exposed work from estimated milliseconds saved; record the
  estimate's assumptions/confidence and the experiment that would support/refute it.

## Finish with an auditable package

Check links and exported assets. Recompute reported means, maxima, spread,
miss counts and any valid stage sums from saved samples. Verify figure values
match their declared cohort and retain data/source hashes. Run any new report
scripts; do not rerun GPU benchmarks just to validate formatting. State if browser
rendering or original-archive hash verification was not performed.

Provide the report link and the few conclusions or limitations the reader needs.
Keep the report index current; preserve unrelated files and staged changes.
