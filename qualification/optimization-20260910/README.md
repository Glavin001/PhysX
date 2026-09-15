# Integrated optimization setup — 2026-09-10

## Current goal continuation: ten experiments

Current completion: **10/10**. [E12](E12.md), combining [E3 factor reuse](E3.md)
and [E10 block-Jacobi](E10.md), is retained in source and local runtime/tests.
Matched 600-step heavy mean: **62.312 ms versus E3 63.365/63.199 ms**, an
additional **0.886 ms (1.4%)** improvement. Five-repeat idle confirmation:
**1.624 ms versus 1.598/1.640 ms**; no repeated idle regression. Heavy maxima
overlap, and every run still misses both 120/60 Hz on **519/600 steps (86.5%)**.
Initialization plus 600 heavy steps: **39.705 s versus 40.384/40.209 s**.
Earlier E3 independently improved original A by ~4.1%; these are separate matched
cohorts. [Full scenario/stage report](status-scenarios.md).

[E5](E5.md), [E6](E6.md), [E4](E4.md) failed timing screens; [E1](E1.md) and
[E8](E8.md) failed memory qualification before timing. [E9](E9.md) regressed;
[E11](E11.md) improved means but worsened measured peaks. All candidates,
commits and conclusions remain in the [queue](queue.json). All owned jobs are
terminal. Original A and the installed SDK remain preserved. Shared-GPU and
unresolved fidelity/endurance gates limit the claim; no deployment occurred.
Final source/runtime/test hashes: [selection receipt](selected-implementation.json).

**All continuation entries below this paragraph are historical snapshots.**

Latest results: fresh shared-GPU A baseline completed with 720 measured steps
converged and correction-capped. **E5 completed and was rejected**: impacts mean
75.435502 ms versus A-before 75.227034 and A-after 75.317993 ms; peaks did not
improve consistently. All four comparisons have zero checked physical-history
differences. [Full E5 report](E5.md). Completion: **1/10**. The polynomial header
was restored from A. E6 is building a separate deferred-inverse candidate and
remains unaccepted; no claimed speedup yet.

**Resumed on the shared GPU at the user's explicit direction.** The instruction
"You have GPU available, use it" supersedes waiting for exclusive compute access.
The runner now offers an explicit `--allow-compute-pid` option, records exact
existing identities, preserves samples and rejects unlisted processes. Default
admission remains unchanged; matching and changed-name negative controls pass.
Fresh native A baseline is running in `out/optimization-20260910/shared-baseline-1/`.
These measurements will be labeled shared-GPU diagnostics. No foreign service
was stopped. The blocked audits below are historical.

**Current status: blocked after three consecutive resource checks.** The third
check again confirms foreign compute PID 435374 live (23:35 elapsed, 928 MiB GPU
allocation). Baseline admission cannot proceed, no owned GPU experiment is live,
and setup/source triage is complete. The goal is blocked pending GPU availability;
it is not complete. Evidence: `out/optimization-20260910/goal-next10-audit-3.json`.
Earlier active-status entries below describe their respective historical checks.

The current objective is **ten completed prioritized integrated experiments**,
superseding the initial five-experiment count below. Completed: **0/10**.
The fresh `goal-next10-baseline-1` admission returned exit 3 / `blocked_gpu`:
foreign server PID 435374 was confirmed live by both GPU inventory and process
inspection. No owned simulation/profiler job is live. This is the first recorded
blocked audit for the ten-experiment goal; the goal remains active.

Second continuation audit: the same GPU compute PID 435374 is still live
(22:59 process elapsed, 928 MiB GPU allocation). No owned GPU jobs were observed.
No benchmark was launched, and completion remains 0/10. This verified resource
wait is recorded in `out/optimization-20260910/goal-next10-audit-2.json`; the goal
remains active pending GPU availability. No further source changes were made.

Source inspection changes the next selection: E2's proposed offset-construction
cache lacks its presumed work. `StressHierarchyViews.cuh:11–13` merely selects
stored offsets and promotes float components to double. The subsequent
`couple`/`transposeCouple` arithmetic depends on changing solver vectors. The
prior 2–8 ms savings estimate is unsupported and E2 now requires a distinct,
evidence-backed mechanism before execution. This is a source review, not a
completed optimization experiment or measured failure. E1 also already reserves
its temporary arrays; per-body pool locking remains but has no isolated timing.
E3's existing unchanged-generation guard is confirmed and must be preserved.

After baseline verification, resolve E5, then prioritize E1/E3/E4 and select the
remaining experiments from measured evidence until ten are complete. The current
[queue.json](queue.json) supersedes the historical ranking table below. Evidence:
`out/optimization-20260910/goal-next10-audit-1.json` and
`goal-next10-baseline-1/experiment.json`. No engine edit or tolerance change was
made during this continuation. The original setup/history follows unchanged.

**Setup implemented; fresh GPU baseline and five-experiment batch blocked.**
No new engine change or GPU experiment was executed. No new runtime gain is
verified. The inherited barrier candidate B remains unaccepted and unchanged.
The current user instruction resumes optimization; it does not authorize
stopping the other project's GPU server. See [workflow](../../OPTIMIZATION.md).

## Inspection and verification completed

- Read the current handoff, native build/cache/test definitions, performance
  playbook, measurement contract, failed-experiment history, source at the hot
  preconditioner/reduction/motion-construction paths and CPU fragment allocator.
- Reused CMake SDK/native targets, numerical CTests, frozen penetration audit,
  timing/report/comparison scripts, Systems timeline and targeted NCU reports.
- Added `run-destruction-ab.py`: serial A-before/B/A-after, both frozen cases,
  explicit module selection and mapped-hash validation, cooperating-runner lock,
  config/source/artifact provenance, raw reports and structured experiment receipt.
  It has no promotion, build or process-eviction action. Baseline-only mode is
  available. Correctness evidence is required for a candidate and is not waived.
- Added `destruction-ordinary-ab.json`, preserving the handoff's common/case
  arguments exactly. Added exact 120 Hz counts and all three deadline percentages
  to the existing candidate comparator, which previously omitted 120 Hz.
- All **59 CPU tests pass**: timing 36, phase accounting 11, GPU-profile accounting
  7, new A/B admission/provenance controls 5. The first new test attempt failed
  because mocking subprocess.run also intercepted check_output; the test now
  provides explicit Git responses. This was a test-harness error, not a CUDA result.
- Offline A-against-A report controls pass for both scenarios, retaining raw
  hashes and physical histories. These exercise reporting, not new physics runs.
- A/B demo and runtime hashes match the handoff. Every archived A-screen output
  file hash and actual mapped runtime hash passes verification. All 720 measured
  steps converge with at most one correction. This verifies preserved evidence;
  it does not establish a fresh baseline under today's GPU occupancy.

Source base: `1155b7ffb60d4d65853f448b00485c21cfd06b99` plus pre-existing WIP and
this uncommitted setup. No experiment commit exists because no new experiment
ran. Setup/source hashes and a scoped patch are retained in
`out/optimization-20260910/setup-receipt.json` and `setup.patch`.

## Baseline observations and limits

Preserved A, two 180-step/3-simulated-second repeats per regime, ordinary API,
sleeping on, 256 buildings / 113,664 chunks / 229,376 bonds. Idle has no shots;
impacts has one simultaneous 256-shot wave. Complete-step milliseconds include
commands, simulation/destruction/correction, synchronization and completion.

| Case/run | Mean ms | All-step maximum ms | >120 Hz budget | >60 Hz budget |
|---|---:|---:|---:|---:|
| Idle 0 | 1.654892 | 16.185299 | 1/180 (0.56%) | 0/180 (0%) |
| Idle 1 | 1.668137 | 16.359856 | 1/180 (0.56%) | 0/180 (0%) |
| Impacts 0 | 70.990195 | 228.195461 | 99/180 (55.00%) | 99/180 (55.00%) |
| Impacts 1 | 70.382600 | 226.601661 | **100/180 (55.56%)** | 99/180 (55.00%) |

Thresholds are strictly >1000/120 and >1000/60 ms. Rechecking raw samples found
the handoff's statement of 99 misses at both budgets in both impacts repeats was
inaccurate: repeat 1 has 100 at 120 Hz. Raw data was not changed. The generated
report controls also retain the separate >8 ms counts and percentages.

Historical wall golden identity, Direct GPU wall behavior, large exact-pose
audits and accepted-properties initchecks remain unresolved. B's broad 3D
racecheck is also unresolved, as is A's matching control. Geometric wall/pose
agreement is useful evidence but does not resolve these gates. No fidelity or
tolerance was changed, no native test result was newly claimed.

## Remaining bottleneck and reused profiles

Offline Systems import succeeded from the retained same-A runtime trace:
267 resident stress launches consume 7,150.826 ms, **77.5% of aggregate GPU
kernel time**. Hierarchy construction adds 650.730 ms (157 launches, 7.1%);
motion-mode construction adds 293.093 ms (157 launches, 3.2%). These are workload
totals, not disjoint portions of a complete-step maximum.

The first trial/correction and later trial stress launches map to zero-based
ordinals 82/83/130 at steps 82/82/108. Systems durations are 22.974/34.497/45.988 ms.
Targeted NCU reports show 54.42–61.11% FP64 pipeline activity, 31.77–33.23%
occupancy, 0.088–0.100 eligible warps/scheduler, 110 registers and no reported
spills. Source sampling shows dependent FP64 arithmetic and polynomial/reduction
barrier exposure. Low DRAM traffic does not prove a bandwidth-independent cause.

The same-A ordinary phase report's first split also exposes 39.511 ms in required
CPU fragment compatibility construction and 18.321 ms in other shape migration.
The 87.809 ms correction and 58.710 ms GPU wait contain nested GPU work and must
not be added to kernel savings. Stress and required CPU lifecycle work both
remain targets. The inline dispatcher profile is diagnostic, not production
wall-clock timing; the existing normal-dispatch timing controls remain separate.

Reused primary repository evidence:
[city profiles](../ncu-city-20260910/README.md),
[ordinary phase report](../baseline-rtx5060ti-20260910/README.md),
[failed hypotheses](../../docs/destruction/PERFORMANCE_FINDINGS.md).
Raw imports are `out/optimization-20260910/reused-systems-kernels.csv` and
`reused-ncu-late.csv`. No new profiler attachment occurred.

## Initial batch: ranked queue, not executed results

Estimated savings below are **hypotheses about complete-step milliseconds**, not
measured or additive gains. They assume some exposed scope is on the critical
path; complete A/B screens must test that assumption. Costs are engineering
estimates including focused correctness and a short matched campaign, not
deadlines. Re-rank after every result. Resolve already-built E5 first after A
verification, then test the remaining hypotheses in benefit order; do not stack
new edits on unaccepted B.

| Rank/ID, family | Evidence and proposed mechanism | Scenarios | Estimated saved application ms; confidence; cost | Support / refutation |
|---|---|---|---|---|
| 1 / E1, CPU lifecycle batching | First-split compatibility construction 39.511 ms. Inspect and batch repeated pool/container capacity and insertion bookkeeping inside the accepted reservation transaction; retain every addBody, actor/query link, failure rollback and corrected-contact prerequisite. Existing placeholder sleep deletion is already present and is not repeated. | First large fracture, correction, idle startup | 4–12 ms at first split if 10–30% is repeated bookkeeping; low; 1–2 days | Support: fewer repeated allocations/insertions and lower disjoint construction plus untraced peak with identical accepted owners/contacts/poses. Refute: cost belongs to required body initialization, moved startup cost, lifecycle failure or overlapping A/B ranges. |
| 2 / E2, repeated structural algebra | FP64-dependent polynomial gather dominates selected stress kernels. Precompute invariant endpoint transport/scale data per validated operator generation in compact global storage, preserving each row's arithmetic order; remove repeated sourceOffset construction in live nativeOffDiagonal. This is not the rejected shared inverse cache. | Initial/impact/correction/later stress; setup and idle controls | 2–8 ms on loaded steps if 5–15% of exposed stress is removable, after setup cost; low; 1–2 days | Support: lower dynamic transport work and critical-path stress time, unchanged independent inverse/polynomial checks and city outputs, complete-step gain net of build/storage. Refute: sourceOffset already compiles away, cache traffic/setup erases gain, spills or numerical divergence. |
| 3 / E3, component-local topology lifetime | 157 hierarchy/motion rebuilds cost about 6 ms combined per rebuild in this trace. Determine whether unchanged components can retain existing factors/modes using exact producer-owned dirty revisions instead of whole-generation invalidation. The current generation guard already skips globally unchanged topology; do not duplicate it. | Ongoing partial fracture and late impacts; idle must remain unchanged | 1–5 ms per affected rebuild if 20–80% is unchanged; low; 2–3 days | Support: independent dirty-closure audit proves unchanged coefficients/geometry/support and fewer rebuilt rows; complete-step saves after revision bookkeeping. Refute: topology/geometry churn invalidates most components or stale setup/failed correction appears. |
| 4 / E4, residual producer/consumer fusion | prepareNativeResidualComponent promotes every FP32 residual into FP64 RHS each iteration before polynomial consumption. For anchored components, examine fusing exact promotion into its first local consumer and retaining required stored RHS for gamma; free projection remains complete. | Anchored stress at first/later peaks; free fragments and idle controls | 0.5–3 ms if a repeated pass/synchronization can be removed without extra work; low–medium; 0.5–1 day | Support: preserved casts/operations and fewer full-node visits/barriers; unchanged numerical/city gates and net complete-step gain. Refute: later consumers force the pass, register lifetime/spilling increases, or measured win disappears. |
| 5 / E5, polynomial synchronization | Existing B deletes only the trailing polynomial barrier; producers and initial consumers own the same rows. Static barriers 45→44, resources unchanged, focused checks and wall equality already retained. Earlier neighbor-gather barrier remains. | Every polynomial iteration, particularly later peak; idle control | 0–2 ms on loaded steps; medium dependency proof, low speed confidence; 0.5 day to finish existing evidence | Support: matched A/B/A untraced gain and correct city/independent outputs, reduced relevant barrier exposure. Refute: no gain, adverse numerical/sanitizer result or missing matching controls. The interrupted B campaign is not a win or a completed failed hypothesis. |

Queue machine-readable fields are in [queue.json](queue.json). None of E1–E5
counts as an executed experiment in this batch. No new failed optimization
hypothesis can be reported. Historical shared inverse cache, forced residency,
FP32 preconditioning, and local multilevel retries remain rejected/unqualified
as recorded; they are excluded from the unchanged retry queue. After three
unsuccessful trials in one family, research primary implementations and change
approach/target before another experiment.

## Blocker and next executable action

Read-only GPU observation confirms PID **435374**,
`/root/workspace/vibe-land-4/target/release/web-fps-server`, type C. Desktop
graphics also remain. No foreign service was stopped. Automatic approval review
initially rejected the baseline command, citing the stopped handoff and competing
compute. After documenting the current explicit resumption and verifying the
no-launch admission test, review approved the retry. The actual wrapper then
exited **3 / blocked_gpu**, correctly refusing foreign compute. No child CUDA
simulation launched. The user was asked to arrange GPU availability.

When the GPU is available, run the baseline-only command
in `OPTIMIZATION.md` to a fresh output, then finish E5 with identical A/B/A settings
and city/fidelity controls. Proceed through E1–E4 only after baseline verification
and a recorded E5 disposition. Keep all failed captures and avoid unrelated WIP.

Evidence: `out/optimization-20260910/gpu-preflight.xml`, `gpu-preflight.json`,
`baseline-launch-rejection.json`, `baseline-attempt-2/experiment.json`,
`historical-baseline-verification.json`,
`idle-256-report-control/`, `impacts-256-report-control/`. The five-experiment
request remains incomplete; this report records the actual stopping boundary.
