# Destruction optimization: findings and agreed procedure

2026-09-13. Summary only; raw measurements, detailed experimental evidence,
implementation changes and tooling are not included in this summary commit.
No physically equivalent application speedup or fully qualified final implementation
is claimed. The convergence-policy diagnostic below deliberately changes numerical
acceptance and reports its resulting physics differences.

## Measured application baseline

Measured source: `13b11af2e0aeabf4e0070931fbd8a060f383dfaf` (selected N13+N20
composition). Its broad final composition/trajectory qualification remains
incomplete. The mixed development workspace is a different source state.

Times are complete accepted ticks: CPU preparation, physics, stress/material/
topology, transfers, waits, required correction and final publication. Restore,
validation and observation export are excluded from tick latency. Ordinary PhysX
APIs, sleeping, current-tick contacts and at most one correction are preserved.

The baseline entries in this section compare identical builds. Mean ranges describe separate
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

## Convergence-policy diagnostic — 2026-09-13

The user requested a surgical test of Vibe's looser tolerance and 32-iteration
stopping policy on the native implementation. Native already implements an
iteration cap; the important difference is that it rejects unconverged results,
whereas the deployed Vibe policy consumes them. Matching stopping settings does
not make the two different solvers or their resulting physics equivalent.

Four isolated modes retained the selected native operator, preconditioner,
arithmetic precision, materials, inputs, ordinary APIs, sleeping and at most one
same-tick correction. Only tolerance, maximum iterations and permission to consume
an unconverged result changed. Convergence flags remained truthful. Production
settings and the installed SDK were not changed by this experiment.

Continuous heavy scene: 256 buildings, 113664 chunks, 229376 bonds and one 256-projectile
wave. Each mode ran two independent 180-tick processes, in forward then reverse
mode order. All first-use ticks remain in the full-step timing.

| Mode | Tolerance / cap | Mean tick, ms | Range of process means, ms | Broken bonds per run | Unconverged ticks /360 |
|---|---|---:|---:|---:|---:|
| Strict control |1e-5 /8192|55.101|55.086–55.115|56077|0|
| Tolerance only |1e-3 /8192|45.430|45.166–45.695|58723|0|
| Cap only, accept unconverged |1e-5 /32|23.475|23.275–23.675|33213|202|
| Loose + cap, accept unconverged |1e-3 /32|23.160|23.064–23.257|33213|200|

Tolerance alone reduces the heavy mean 17.6% while meeting its requested, looser
convergence criterion, but breaks 4.7% more bonds. Combined settings reduce the
mean 58.0% and break 40.8% fewer bonds. Final clusters change from 12248 strict to
13230 tolerance-only and 8145 in either capped mode. The continuous gain includes
both cheaper solves and a different later workload; this test does not separate
their contributions. Recorded work and iteration histories repeat exactly within
each mode. An unconverged tick means at least one component/pass misses its
criterion, not that every component fails.

The largest heavy tick remains 179.370 ms with combined settings versus 188.800 ms
strict. Combined settings still miss 60 Hz on 193/360 ticks, versus 198/360 strict.
Continuous idle shows no reliable benefit: process means span 1.353–1.787 ms across
the modes, all meet 60 Hz, no bonds break and the final bodies are asleep.

Three full ticks per mode were also measured from each identical saved starting
state. Tower mean falls 108.904→72.323 ms with tolerance alone and 29.476 ms combined,
without breakage or observed motion changes in that tick. City25 initial impact
stays around 38–40 ms; capped output has 655 clusters instead of 537. City256 debris
means are 372.073 ms strict and 340.959 ms combined, but the short fixed-order screen
and large first-use variation do not establish a small performance win. Restore
and initialization are excluded from tick latency and retained in the local report.

The rebuilt strict mode passes the original frozen physical checker against a
fresh original binary/runtime on city25 impact. Every relaxed snapshot mode fails
at least one strict comparison. In city25 impact, the cap changes 2012 broken/intact
bond identities and produces about 52% relative L2 difference in end-of-tick bond
forces. This is a discrepancy from the strict output, not an independent exact-
solution error; once fracture changes, correction loads and final equations can
also change. Tolerance-only preserves city25 break identities in that tick but
changes health, and changes 83 break identities in the debris snapshot.

The campaign completes 29 processes and 2919 ticks (39 restored, 2880 continuous)
in 203.560 s including GPU isolation and desktop restoration, excluding builds,
the wait behind another qualification campaign and offline analysis. Complete
timers close for every tick; native error, correction/pass, finite snapshot and
non-healing checks remain enforced. No new GPU profiles or full trajectory/
independent-reference qualification were collected for these changed policies.

Decision: preserve as diagnostic evidence, with no runtime promotion. Unequal
numerical budgets materially affect the earlier comparison. Tolerance-only is a
more conservative candidate for further evaluation than a universal 32-iteration
cap, but its changed fracture behavior still needs an explicit quality decision.
Large impact stalls and debris costs remain separate performance concerns.

Source remains `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`; the diagnostic runtime
SHA256 is `9334bb97c3b16f2456c1bd2f5f35e74f1df426512353fc4b07717459ae76083b`.
Local-only details and chart: `reports/destruction-convergence-policy-20260913/`.
Raw receipts, inputs, observations and build records:
`out/destruction-convergence-policy-20260913/`, especially `screen/screen.json`,
`build/build.json` and `verification.json`. Source edits, tools, detailed reports
and raw evidence remain local and are excluded from this summary commit.

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

## Removal-plan implementation — stopped at user request

Three isolated native candidates were built: localized connectivity, topology-owned operator adjacency, and producer-owned exact load changes. Their nine-case screens pass the physical/work/profile checks but establish no substantial sustained-destruction gain. Adjacency additionally passes 3,120 full52 physical comparisons; mixed performance prevents promotion. The selected runtime remains unchanged.

The final load-producer screen completes in 284.732 seconds. All first-use ticks remain included; restore is excluded from tick latency. Means span separate processes, not confidence intervals. Peak values are observed maxima.

| Scenario | Control mean range, ms | Candidate mean range, ms | Control / candidate peak, ms | Candidate 60 Hz misses / ticks |
|---|---:|---:|---:|---:|
| bridge64-cold | 8.911–9.056 | 9.020 | 11.918 / 11.475 | 0/8 |
| chain256-cold | 7.588–7.627 | 7.751 | 10.769 / 10.552 | 0/8 |
| dense12-cold | 31.526–31.553 | 31.245 | 33.978 / 33.162 | 6/6 |
| tower64-cold | 108.433–108.844 | 108.786 | 110.816 / 110.745 | 4/4 |
| city25-initial-impact | 39.205–39.976 | 39.829–40.981 | 47.882 / 48.651 | 12/12 |
| city256-intact-idle | 64.358–64.736 | 63.777 | 73.121 / 66.307 | 4/4 |
| city256-late-debris | 353.548–354.846 | 367.553–373.595 | 406.925 / 419.145 | 8/8 |
| idle-256 | 1.661–1.676 | 1.673–1.731 | 14.023 / 14.162 | 0/360 |
| impacts-256 | 54.463–54.781 | 54.505–55.106 | 184.784 / 179.930 | 198/360 |

Prepared-factor prototypes reduce iteration counts but have not delivered a native improvement. Full debris numeric factor rebuilding costs about 48 ms; FP32 factors with ten FP64 corrections are slower. Selective masked factor updates fail correctness. Dense inverse-factor products pass residual checks, but fail the unchanged native force-compatibility gate on all 300 checked systems. Those results cannot qualify a drop-in solver replacement. A separately stored transpose removes padded FMA work but increases DRAM traffic and does not improve complete replay time; it was not retained.

The remaining numerical issue is both factor lifetime/cost and physical-force compatibility. The lifecycle work needs a deeper ownership/registration change; lookup-only work is already refuted. Phase-only debris contact retirement is about 10.23 ms, and first-pass contact-manager preparation about 26.50 ms CPU; these remain instrumented scopes, not additive production-stage estimates.

The five-part plan is incomplete. All owned jobs are terminal and no experiments are queued. Source, tools and evidence remain local; raw data remains ignored. This update is uncommitted. [All experiments, stages, qualification limits and evidence locations](../destruction-removal-implementation-20260913/README.md).
