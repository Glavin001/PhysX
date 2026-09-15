# Fast, trustworthy destruction measurement

Use from the repository root. Read current AGENTS.md for authorization, selected
runtime and live jobs. This reference routes measurement work; it does not resume
a stopped optimization campaign. Prefer existing runners and immutable evidence.

## Choose the smallest useful measurement

| Question | Procedure | Measured cost / limit |
|---|---|---|
| What is expensive, or did a parser/report fail? | Read matching saved traces, work counts and receipts; re-export/re-audit offline | No GPU rerun needed |
| Does an intermediate removal do the correct work? | Focused correctness and actual work counts on affected inputs | Measure the check; no universal timing requirement |
| Does a completed mechanism improve warm runtime? | Nine-window A0/B/A1 screen, then selected Systems/NCU evidence | Same-build A0/A1 calibration: 204.338s + 1.512s exports; A0/B/A1 is longer and not yet calibrated to this duration |
| Does it affect cold numerical work or continuous gameplay? | Relevant cold companions and uninterrupted idle/heavy; existing representative runner when its suite fits | Historical nine-case cold/continuous same-build procedure: about 4m45s; not the warm nine-window suite |
| Is a promising candidate ready for promotion? | Full52 and required trajectory, numerical and memory qualification | Separate from the per-edit loop; do not start exhaustive counters automatically |

Target roughly five minutes for representative candidate feedback. Record actual
capture/check/export time and build/queue time separately. A watchdog bounds a
run; it does not guarantee precision or permit silently dropping scenarios.
Noisy effects get fixed, independent confirmation of predeclared primary cases
and regressions. Do not keep sampling until a favorable result appears.

## Measured ownership campaign follow-up — 2026-09-15

The first genuine warm candidate A0/B/A1 screen completed in278.991s plus1.650s
exports. Two related screens, each with an extra rebuilt-control process, took
306.791s+1.506s and293.910s+1.610s. These changed the selected profile target;
they are measured examples, not a universal five-minute guarantee. Fixed
four-window A/B/B/A confirmation took222.688s. A single candidate's full52 warm
physical comparison against hash-checked preserved controls took293.719s
(848 measured+1,496 warmup ticks). That reuse qualifies physical histories and
endpoints; historical control wall times cannot establish a new performance win.
[Exact variants, all scenarios and qualifications](../../../../reports/destruction-ownership-implementation-20260915/README.md).

A sanitizer launcher can exit while its GPU target remains alive. Watchdogs must
clean the entire owned process group, including after the immediate child exits,
before releasing the lease. Verify actual GPU clients outside sandbox process
namespaces after a failed run. Preserve failed admissions/timeouts and their logs.
A matching baseline/candidate initialization failure is still a qualification gap;
label scoped device-only checks explicitly and never call them full initcheck.

## Reuse and identity before work

- Baseline entry: [full52 warm report](../../../../reports/destruction-warm-full52-20260914/README.md).
  Its `data/coverage.json` maps timing/CPU/counter artifacts; `all-scenarios.md`
  and `attribution.md` expose every case. Raw files live in ignored `out/`.
- Check executable, loaded-module and snapshot hashes, W/M, stimulus history,
  checker version, profiling mode and hardware/tool versions. Do not treat a
  matching scenario name or commit alone as matching execution.
- Reuse matching profiles for diagnosis. Performance comparison still needs
  contemporary matched controls; yesterday's wall times are not today's A arm.
- Reuse existing consumers when their identities/ABI match. The warm builder
  only builds a benchmark consumer against frozen selected host libraries; it
  cannot build a candidate's changed PhysX implementation. Candidate host/CUDA
  libraries and both consumers must come from that candidate's coherent build.
- Read terminal receipts and actual processes before resuming. Never restart a
  completed campaign because context was lost. All GPU work is serialized under
  `out/destruction-ab.lock`; keep builds/heavy audits outside captures. Use the
  existing reversible desktop management within current user authorization.

## Execute the warm screen

`tools/profiles/destruction-warm-suite.json` is the nine-window source of truth:
bridge, long chain, dense structure, tower, city25 impact, and city256 idle,
impact, cascade and debris. It fixes histories and the default profile target.
Preserve these windows; version deliberate suite changes and requalify them.

Create a fresh candidate plan using all three candidate paths:

```bash
python3 tools/diagnostics/destruction-snapshot/make-warm-screen.py \
  out/NEW-warm-screen/plan.json \
  --binary out/warm-replay-20260914/plain/serialization-probe \
  --profile-binary out/warm-replay-20260914/profile/serialization-probe \
  --artifacts out/destruction-baseline-20260913/artifacts \
  --candidate-binary out/CANDIDATE/plain/serialization-probe \
  --candidate-profile-binary out/CANDIDATE/profile/serialization-probe \
  --candidate-artifacts out/CANDIDATE/artifacts

python3 tools/diagnostics/destruction-snapshot/run-warm-suite.py \
  out/NEW-warm-screen/plan.json out/NEW-warm-screen/results \
  --manage-desktop --budget-seconds 300 --contract-version 2

python3 tools/diagnostics/destruction-snapshot/export-warm-profiles.py \
  out/NEW-warm-screen/results
```

Replace candidate placeholders with verified artifacts. Omit all three candidate
options only for an intentional identical-build calibration. The generator creates
18 plain jobs + 2 profiles for calibration; with a candidate, 27 plain jobs + 2
profiles. A1 reverses scenario order. Two restores per process each advance W+M
ticks; they are not two restores per measured tick. Capture budgets exclude build
and the separate export command. Inspect `campaign.json` and `exports.json`.
The export helper refuses existing exports; resume only missing export/analysis
steps instead of rerunning physics or overwriting evidence.

The stock screen profiles the first measured debris tick with Systems and two
stress-kernel NCU launches. It is a screen, not full kernel or CPU-stack coverage.
It retains its calibrated Systems settings and known boundary/sampling warnings;
do not claim it has the reduced-sampling full52 collector's settings. If the
hypothesis targets another phase, choose that case explicitly in a versioned suite
or collect a bounded missing profile using the existing helpers.

## Preserve the physics and measurement meaning

- Primary latency is `complete_step_ms`: commands, CPU preparation, PhysX,
  stress/material, transfers/waits, optional correction/second stress, publication.
  Preserve current-tick inputs, sleeping, ordinary APIs and at most one correction.
- Restore and W real warmup ticks are outside primary timing but remain recorded,
  including first-use costs. Warmup advances physical time. Never restore only
  poses while retaining numerical/contact caches from another state.
- Warm dense/tower fixtures mostly exercise equilibrium reuse; cold solves must
  remain companions for algorithm/preparation changes. Cold52, warm windows and
  uninterrupted trajectories are distinct cohorts, never pooled as equal inputs.
- The nine-window city256 cascade uses snapshot40 + W55/M8 (ticks95..102).
  Full52's cascading-fracture uses W47/M8 (ticks87..94). Those timings are not
  interchangeable. Impact/post-impact/cascade windows can overlap in physical time.
- Snapshot179 + W8/M8 debris is a qualified post-restore continuation, not proof
  of the original uninterrupted history. Snapshot40 + W147 failed cross-process
  physical equivalence; do not revive it unchanged or loosen tolerances.
- V2 fixes the ordinary-body inactive destruction clock without changing quality.
  Check each trajectory's schedule and repeated-work invariants, cross-process
  work histories and exported endpoint forces/material/motion. Timed ticks are
  not independent statistical samples or full-array physical comparisons at each
  intermediate tick. Keep uninterrupted physical qualification for finalists.
- Failed physical admission blocks performance promotion and subsequent profiler
  expansion. Preserve original failure receipts; a proven parser correction can
  re-audit saved native outputs without repeating their execution.

## Profile only the unresolved question

Pin the qualified NCU2025.3.1; the current full52 cohort used Systems2026.3.2,
CUDA13.4 and driver615.71.09. Requalify changed stacks instead of assuming failure
or compatibility. The [full52 report](../../../../reports/destruction-warm-full52-20260914/README.md)
contains exact graph/configuration collector and offline audit commands.

- Prefer selected full-tick Systems ranges. The full52 continuation uses CPU
  sampling period2,000,000 reference cycles. Full-process collection hit a CUPTI
  teardown Xid120/154; keep the failed trace. On recurrence, stop owned collection,
  inspect device health, and follow the preserved reversible recovery evidence
  only within existing authority. Do not blindly retry or reset active clients.
- Broad core counters completed in one pass; the detailed pilot required three
  passes and host-memory backups. Pilot the required metrics on the expensive
  target before expansion. Add cache/stall/FP64/source detail only when it can
  discriminate the mechanism. Never request full sections suite-wide by default.
- Core full52 coverage is >=99% of observed timeline kernel duration, including
  all nonempty graph invocations and selected ordinary launch configurations.
  Conditional graph node/source counters are unavailable; aggregates are not
  node detail. Replay uses cache-control all / clock-control none: its durations
  and DRAM traffic are not production warm-L2 behavior.
- Use `attribution-normalized.json` for physical CUDA calls. Systems can emit
  versioned nested aliases with one correlation. Existing normalization verifies
  correlation/thread/name/nesting; do not deduplicate by name alone. Preserve raw
  SQLite/JSON. Boundary warnings, low CPU sample counts and unresolved symbols
  remain limits even when physical and selected-range inventory checks pass.
- Resume only missing cases in new output directories. CPU collection supports
  completed-row reuse via `--cpu`; counter collection supports `--scenarios`, not
  automatic in-place resume. Record consolidated coverage explicitly after a
  partial retry. Never present an interrupted parent receipt as full completion.

## Close the loop so the next run is cheaper

For every completed experiment, extend its existing report/history with:
the mechanism and decision; exact artifacts, plan/commands and checker identity;
every scenario's mean/range, peak, misses, stages, preparation and actual work;
physical gates and profile locators; build, queue, capture, validation and export
wall times when available; failed attempts, rerun reason and remaining uncertainty.
Use processes/trajectories as replicates, not individual adjacent frames. Pair
confirmed full-step gains with correctness; classify neutral architecture separately.

Record the reusable lesson as **observation → scope/root-cause confidence →
effective workaround → next validation trigger**, then make the smallest relevant
skill/runner correction. Measure claimed harness savings; distinguish measured
costs from estimates. After three failures in one hypothesis family, reassess and
change approach. Keep failed evidence, avoid rediscovering it, and update the report
index/current handoff. Follow current session/AGENTS commit scope: raw data stays
ignored; documentation work does not imply permission to commit source or restart
runtime experiments. No GPU job is needed just to update this documentation.
