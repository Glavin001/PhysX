# Destruction optimization: findings and agreed procedure

2026-09-13. Summary only; raw measurements, detailed experimental evidence,
implementation changes and tooling are not included in this summary commit.
No new application speedup or fully qualified final implementation is claimed.

## Measured application baseline

Measured source: `13b11af2e0aeabf4e0070931fbd8a060f383dfaf` (selected N13+N20
composition). Its broad final composition/trajectory qualification remains
incomplete. The mixed development workspace is a different source state.

Times are complete accepted ticks: CPU preparation, physics, stress/material/
topology, transfers, waits, required correction and final publication. Restore,
validation and observation export are excluded from tick latency. Ordinary PhysX
APIs, sleeping, current-tick contacts and at most one correction are preserved.

All entries below compare identical builds. Mean ranges describe separate
processes, not confidence intervals; peaks are observed maxima, not bounds.
Every first-use tick is retained.

| Scenario | Chunks / bonds | Processes × ticks each | Full-step mean range, ms | Observed peak, ms | 60Hz misses, pooled |
|---|---:|---:|---:|---:|---:|
| Restored bridge |768 /1524|3 ×8|7.809–8.919|11.330|0/24|
| Restored chain |256 /255|3 ×8|7.469–7.564|10.530|0/24|
| Restored dense structure |1728 /4752|3 ×6|31.283–32.111|33.820|18/18|
| Restored tower |2368 /4900|3 ×4|108.427–109.337|111.286|12/12|
| City25 initial impact |11100 /22400|4 ×6|36.127–41.589|50.921|24/24|
| City256 restored idle |113664 /229376|3 ×4|63.360–75.579|90.824|12/12|
| City256 restored debris |113664 /229376|4 ×4|361.515–382.628|418.510|16/16|
| Continuous idle |113664 /229376|4 ×180|1.658–1.722|14.264|0/720|
| Continuous destruction |113664 /229376|4 ×180|54.867–55.291|184.833|396/720|

Continuous destruction uses one wave of256 projectiles; idle uses none. Restored
and continuous cases have different cache histories and must not be pooled.
The nine-case cohort contains130 restored and1440 continuous timing ticks.
Snapshot physical checks and continuous work-history/convergence checks pass;
work counters alone do not prove complete force/material/motion trajectory parity.

A60Hz deadline is1000/60 ms. The heavy continuous mean needs roughly3.3× speedup,
tower6.5× and restored debris22×. The observed continuous peak needs about11×.
Ten successive1% reductions produce only about1.11× speedup. Substantial removal
and algorithmic/architectural changes must therefore carry the main improvement.

## Measurement cost and what it establishes

The representative GPU-exclusive pipeline completed in284.09 seconds:

| Phase | Seconds |
|---|---:|
| Seven restored scenarios and physical checks |152.26|
| Continuous idle/heavy and work-history checks |74.98|
| Selected Systems capture, export and physical check |33.18|
| Focused counters, export and physical check |22.93|
| Remaining admission/restoration/bookkeeping |0.74|

A separate measurement of input/artifact preflight took1.30–1.40 seconds, giving
approximately4m45s practical turnaround. These were separate measurements, not
one external stopwatch observation. Build and queue time are separate. Systems
captured2307 CPU samples,26959 native scopes and884 GPU launches in the selected
large-debris tick. Compute captured two stress-kernel launches with the five
requested metrics. This is focused attribution, not full counter coverage for
all52 scenarios or individual conditional-graph nodes.

An additional six independent randomized A/A pairs per idle/heavy/debris scenario
took416.49 seconds. Simultaneous95% paired-t intervals for A−B were:

| Scenario | Interval, ms |
|---|---:|
| Continuous idle |[−0.1030, −0.0240]|
| Continuous destruction |[−0.5059,1.1105]|
| Restored large debris |[−9.2308,17.8969]|

These assume independent, sufficiently stable/normal pair effects. They do not
establish the provisional max(0.1ms,1%) equivalence margins. Identical-code idle
produced a false signed implementation-effect signal, so confidence calculations
alone must not justify tiny wins. The five-minute screen cannot substantiate a1%
restored-debris gain. Fixed repetition counts never guarantee arbitrary precision.

## Main insights

- Count removed work to establish mechanisms: actual actor/contact/bond visits,
  solves and per-component iterations, allocations/rebuilds, readbacks and bytes.
  Define each counter; do not mistake maximum iterations for total solver work.
- Kernel-launch count is insufficient. Iterations run inside kernels; fewer
  launches can reduce useful parallelism, while additional GPU work can remove
  expensive CPU/GPU round trips. There is no universal operation-count score.
- Timing remains the final application outcome because operation costs, overlap
  and bottlenecks change with implementation. Profiler replay timing is separate
  from production full-step timing. A CPU wait may contain useful GPU execution.
- Reuse needs complete product-specific validity. Equilibrium, loads, damage,
  topology and publication have different dependencies. Unchanged equilibrium
  does not imply accumulated damage can be skipped.
- Existing GPU iteration loops, some settled reuse, dynamic component scheduling
  and compact correction publication are already implemented. Prior matching,
  lookup-only and multilevel experiments include failed/mixed application results;
  do not repeat them without new evidence or silently waive failed quality gates.
- Preserve setup and first-use costs. In the paired debris calibration, arbitrary
  A/B first-use means differed by16.338ms, versus0.331ms for subsequent means.
  This localizes variation but does not prove its cause or justify dropping samples.

## Agreed optimization procedure

Prioritize unnecessary work and conditional execution, then ownership/communication,
algorithms, decomposition/layout, and finally tuning necessary kernels. Keep the
same-tick physics → stress/fracture → optional correction → second stress order.

Each large bet must identify evidence, mechanism, affected scenarios, estimated
application milliseconds saved, confidence, experiment cost and support/refutation
measurements. Account for the untouched critical-path remainder; accelerating the
stress kernel alone cannot guarantee a10× complete-step improvement.

Develop coherent changes across C++ and CUDA as needed. Use correctness and work
counts to prove intermediate removals; do not require a statistically significant
1% timing gain at every edit. An architectural step may advance with a named
follow-up/simplification and explicit qualification, without being called a speedup.

For completed mechanisms, run a short matched full-step comparison and targeted
profiling, reusing compatible baseline reports. Spend extra repetitions on promising
uncertain candidates. Freeze meaningful millisecond margins, independent process-pair
counts and statistical rules before confirmation; never rerun until a favorable
result appears. Require evidence to distinguish improvement, regression and practical
equivalence. Report each scenario's mean, peak, stages, deadlines, setup and work.

Use full52 plus required numerical, memory and continuous trajectory checks for
finalists. Preserve the best verified implementation and all failed experiments.
After three failures in a hypothesis family, reassess and change approach/target.
Any deliberate precision compromise requires an explicit physical-quality budget
and independent qualification, not a relaxed gate after failure.

Raw data remains local under `out/destruction-baseline-20260913/` and other ignored
experiment/report paths. The representative results are in
`representative-calibration-v2/screen.json`; independent-pair results are in
`precision-calibration/{calibration,analysis}.json`. These payloads are not bundled
with this summary. No remote data backup or push is claimed.
