# Nsight Compute scenario-capture qualification

The recording fix pins the collector to the already installed Nsight Compute
2025.3.1. Application, CUDA runtime libraries, inputs, ordinary APIs, sleep,
correction cap and numerical tolerances remain unchanged. This is profiling
infrastructure, not an application optimization or an N-series experiment.

## Verified result

**52/52 scenarios now have qualified full Nsight Compute captures** of the selected
bottleneck kernels: **62 capture files, 86 kernel launches,
124 checked full ticks**. Each capture completes a full restored tick
and independent repeat, then passes the existing physical comparison against the
unprofiled reference. All required counter groups are present and finite; full
exports contain 2,250 metric fields per launch.

Light qualification: **238.48 seconds**. Full expansion:
**1280.28 seconds**, reusing 7 matching light scenarios
and existing 52-case Systems/PM timelines. These are profiler campaign times,
including exports and physical checking, not benchmark tick times. The separate
normal light benchmark remains the prior 27.99–28.44-second workflow.

Maximum observed position difference: 0 m; linear velocity:
0 m/s; angular velocity:0 rad/s.
Maximum scaled bond-force difference: 5.44101313e-05, below the unchanged
2e-4 gate. Persistent material/topology/load arrays compare exactly. Convergence,
repeatability and the at-most-one correction contract remain required.

[All 52 scenario timings, stages and counters](report.md), [structured atlas](report.json),
[full qualification](full-audit.json), [campaign](campaign.json),
[artifact hashes](artifact-index.json). The normal benchmark rejects instrumented
receipts. No simulation/runtime library changed and no application speedup is claimed.

| Buildings (authored chunks) | Idle mean / peak ms | Initial impact mean / peak ms | Late debris mean / peak ms |
|---|---:|---:|---:|
| 25 (11,100) | 9.601 / 15.944 | 40.812 / 52.200 | 69.946 / 86.042 |
| 64 (28,416) | 16.898 / 25.849 | 64.630 / 83.817 | 132.341 / 166.994 |
| 256 (113,664) | 59.200 / 73.979 | 236.880 / 254.511 | 394.491 / 458.203 |

These are the unchanged prior 20-sample **unprofiled** full-step baselines, excluding
restore/validation. They include commands, integrated physics/stress, transfers,
synchronization and any correction. Cold restored ticks differ from continuous
warm gameplay. All original 28 structural cases and 24 city phases remain in the
linked report. Detailed counters cover selected launches, not every helper launch.

Twelve of 86 profiled launches have flagged cache percentages outside [0,100].
Those raw values remain visible but are excluded from quantitative diagnosis;
shared-context and multi-pass counter limits still apply. This is distinct from
failed collection or failed physical continuation.

## Diagnosis

The 2026.3.0 collector fails on the 11,100-chunk city initial-impact tick. The
abort stack is on a profiler worker thread: `free` is called through
`libcuda-injection.so`, with no application frames on that thread. That identifies
the detection path, not the original corrupting write. No vendor root-cause claim
or sanitizer exemption follows from it.

Controlled observations on matching frozen artifacts:

| Control | Result |
|---|---|
| First stress launch only, reduced hardware metrics, 2026.3.0 | Same heap abort |
| Graph profiling mode, first selected launch, 2026.3.0 | Same heap abort |
| No matching kernel / no hardware collection, 2026.3.0 | Same heap abort |
| City25 intact idle, 2026.3.0 | Completes two independent ticks |
| City256 intact idle, 2026.3.0 | Completes two independent ticks |
| Already-fragmented building, 4,537 contacts, no new correction, 2026.3.0 | Completes two independent ticks |
| City25 initial impact, hardware counters, 2025.3.1 | Completes two independent ticks |
| City25 initial impact, full metrics on both stress launches, 2025.3.1 | Completes two independent ticks, 39 collection passes per launch |

The failure does not require kernel replay or large scene size. New fracture /
correction is the distinguishing path in this tested matrix. The older collector
completing the identical input supports a version-dependent injection interaction;
it does not identify its precise defective instruction or prove all application
memory handling correct.

A target-preload AddressSanitizer attempt failed during tool startup with repeated
`DEADLYSIGNAL`, before usable application diagnostics. Its two owned Nsight
processes were stopped; no other process was stopped. This is an unusable
diagnostic, not a sanitizer pass. Raw output and commands are preserved. A first
cross-run physical comparison of the pilot could not run because observation
dumps were absent; the qualified campaign explicitly enables them for each
counter capture and compares against the existing unprofiled physical baseline.

## Acceptance requirements

Run the seven light scenarios before expanding to all 52. For each case, reuse its
qualified Systems timeline, select the dominant kernel family and component stress
if different, and capture the first two matching launches with `--set full`.
This includes trial/correction stress where both execute; it is targeted kernel
coverage, not every launch of every helper kernel. All scenario/kernel selections
remain explicit in `campaign.json` and the report.

Every capture must finish the complete tick and independent restored repeat,
export full counter CSV/JSON, and pass the existing physical observation comparison
against the unprofiled full-suite reference. Exact persistent material/topology/
load state, existing force/motion bounds, convergence and correction caps remain
required. Raw captures without successful physical continuation are unqualified.

Timeline/PM data retains the prior instrumented cohort; application timing retains
the separate unprofiled20-sample full-step baseline. Do not subtract profiler GPU
costs from unprofiled step times, or treat cross-pass cache percentages outside
[0,100] as quantitatively reliable. No new application speedup is claimed.

Raw diagnostic and campaign root: `out/ncu-fix-20260912/`.


## Reproduce

The following completed light and full commands use the existing
profiling probe and runtime, with no build or runtime change:

```bash
python3 tools/diagnostics/destruction-snapshot/profile-suite.py out/ncu-fix-20260912/light-full \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --preset light --counter-mode full \
  --reuse out/snapshot-counters-20260911/full-drained \
  --binary out/snapshot-counters-20260911/probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --allow-existing-graphics --allow-compute-pid 435374
python3 tools/diagnostics/destruction-snapshot/profile-suite.py out/ncu-fix-20260912/full \
  --manifest out/snapshot-light-20260911/full-manifest/manifest.json \
  --preset full --counter-mode full --reuse out/ncu-fix-20260912/reuse-index \
  --binary out/snapshot-counters-20260911/probe/serialization-probe \
  --artifacts out/snapshot-reset-20260911/local-artifacts \
  --allow-existing-graphics --allow-compute-pid 435374
```

Use new output directories when rerunning. The reuse index joins the seven
qualified light rows with the prior 52 matching timeline rows; it does not create
new measurements. Its source paths are recorded in its campaign metadata.
`commands.json` records each actual child invocation, including the collector,
input prefix, metric mode, export and physical comparison. The existing
`PHYSX_SNAPSHOT_DUMP_OBSERVATIONS=1` diagnostic is enabled by the campaign for
physical comparisons outside the measured tick.

```bash
python3 tools/diagnostics/destruction-snapshot/audit-counter-suite.py \
  out/ncu-fix-20260912/full out/ncu-fix-20260912/full-audit.json
python3 tools/diagnostics/destruction-snapshot/report-profile-suite.py \
  out/ncu-fix-20260912/full out/ncu-fix-20260912/report \
  --baseline qualification/optimization-next20-20260910/snapshot-reset-20260911/report.json
```

The audit checks manifest coverage, exact input/module identities, required
hardware metric groups, report hashes, successful complete ticks and physical
comparisons. [Collector hashes](collectors.json), [diagnostic commands/outcomes](diagnostics.json)
and [light qualification](light-audit.json) are preserved beside this report.
