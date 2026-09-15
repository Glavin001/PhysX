# Real-trajectory hardware counters — RTX 5060 Ti, 2026-09-10

Direct CUPTI PM sampling successfully collects counters across the first and
later destruction peaks without the Nsight Compute conditional-graph failure.
The underlying Nsight Compute issue remains unresolved. This is an additional
diagnostic capture route, not an engine workaround or a measured speedup.

Two successful runs use the unchanged production binary/runtime: 256 buildings,
113,664 chunks, 229,376 bonds, 256 simultaneous projectiles, ordinary actor API,
sleeping enabled, fixed 1/60-second timestep, at most one correction. Each runs
180 steps / three simulated seconds. One has PM sampling plus native phase
scopes; the other additionally has Nsight Systems tracing. They are separate
from the three-repeat untraced timing baseline.

Both complete with convergence and correction limits satisfied. All 180 steps
match the earlier Systems trajectory for broken bonds, logical clusters, contact
loads, correction/evaluation counts and stress topology node/bond counts.
Maximum stress iteration counts differ on 27 and 28 steps respectively;
`evidence.json` records each difference. This is not full physical-equivalence
qualification; the migration's independent physical gates remain unresolved.

## Counters attached to the same-run kernel timeline

The combined capture has all 267 expected `componentStressSolve` launches.
Every launch maps to the correct physical-step bracket. The first native motion
allocation kernel executes in step 82, as expected, rather than during intact
steps as in the failing Nsight Compute diagnostic.

| Step | Evaluation | Traced kernel ms | Interior samples | Coverage | Resident warps, % of maximum | Instructions / SM cycle | DRAM GB/s |
|---:|---|---:|---:|---:|---:|---:|---:|
| 82 | Trial | 22.979 | 227 | 99.7% | 29.67 | 0.294 | 30.01 |
| 82 | Correction | 34.365 | 341 | 99.8% | 28.78 | 0.290 | 26.35 |
| 87 | Trial | 46.451 | 462 | 99.9% | 28.82 | 0.285 | 22.95 |
| 87 | Correction | 25.333 | 251 | 99.9% | 28.88 | 0.282 | 18.09 |
| 108 | Trial | 46.897 | 466 | 99.8% | 28.38 | 0.264 | 10.68 |
| 108 | Correction | 32.660 | 324 | 99.8% | 29.29 | 0.273 | 11.75 |

Kernel times are from this separate trace, not production complete-step timing.
Samples are device-wide and time-weighted within each kernel's interior. No
other traced CUDA kernel overlaps these six launches; desktop graphics remain
active and cannot be excluded. Coverage refers to the selected kernel interior
after boundary margins, not the whole scene. Sample windows are not independent
trajectory repetitions. Raw counters and all 267 summaries are retained.

**Interpretation:** the later trial takes about twice as long as the first
fracture trial while moving fewer DRAM bytes per second. These samples do not
support a bulk-DRAM-bandwidth rewrite as the first optimization. Arithmetic,
dependent accesses, convergence work and synchronization remain candidates;
resident warp occupancy does not identify which one limits issue. Next obtain
source/PC stall evidence and actual component work counts, then evaluate the
specified structural solver against independent physical references. Keep the
CPU fragment-registration and correction costs in the complete-step assessment.

FP64 activity is **not measured by this PM capture**. The requested FP64 metric
requires three passes here, even alone, whereas PM sampling requires one. The
earlier Nsight Compute FP64 sample remains indicative because its preceding
graph execution was altered. No precision reduction is justified by it alone.

## Data quality, failures and reproducibility

- Successful PM-only capture: 174,057 samples; four flagged timestamps, including
  the initial sample; maximum overlap 19,640 ns. Hardware overflow: zero.
- Successful PM + Systems capture: 257,893 samples; five flagged timestamps,
  including the initial sample; maximum overlap 16,664 ns. Hardware overflow:
  zero. Final buffer drains completed for both captures.
- The combined analyzer excludes flagged samples and clips 101,093 ns from
  each kernel boundary: one 100,000 ns sample period plus the 1,093 ns measured
  clock-anchor discrepancy. No simulation timing samples are discarded.
- Systems warns that some NVTX events may be missing. Attribution uses the
  verified CUDA-kernel/evaluation sequence, not NVTX completeness.
- The first PM scene attempt was stopped by the collector at a timestamp
  anomaly after reaching later peaks. Its partial results are not included in
  the table. The collector now preserves/flags anomalies instead of aborting.
- Explicit CUDA-context and worker-thread graph controls pass under Nsight
  Compute; they do not reproduce the integrated node-profiling failure.

[Evidence and exact commands](evidence.json), [kernel counters](kernel-counters.json),
and [collector instructions](../../tools/diagnostics/destruction-pm-sampling/README.md).
Source is `tools/diagnostics/destruction-pm-sampling/`. Raw captures, full GPU
samples, loaded maps, counter CSV, Systems report and SQLite reside in
`out/baseline-20260910-ordinary-sleeping/pm-{first,second,timeline}/`.
Builds, metric discovery, failed configurations and the control are in
`out/destruction-pm-sampling-20260910/`. The archived driver uses the original raw
directory layout and fresh mode names; it is not directly runnable from this
qualification directory.

The collector binary used in both successful scene runs is preserved separately
from the finished collector build. The latter adds child-process-group cleanup
on cancellation and passed the small graph/sampling control; the counter
collection and timestamp logic are unchanged. No production PhysX source,
solver settings, frozen tolerances, driver or desktop service changed. No live
GPU jobs remain from this investigation.
