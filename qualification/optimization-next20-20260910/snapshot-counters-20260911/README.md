# Per-scenario hardware-counter atlas

The light suite established a reliable capture path: external CUPTI hardware
sampling alongside a same-run Nsight Systems timeline. It preserves normal
simulation execution, captures the first complete restored tick, and runs a second
independent restored tick to check repeatability. The full52-case campaign uses
this path. The final full-process-drained refresh reused one matching pilot;
its other51 cases were refreshed to eliminate CUDA collection warnings. Detailed Nsight Compute
reports supplement four supported light scenarios; they are not available for all
fracture cases. See [all52 scenario metrics](report.md), [structured results](report.json),
[qualification checks](qualification.json) and [ranked hypotheses](queue.json).

The report keeps the prior **unprofiled20-sample full-tick baseline** separate from
instrumented timings. The unprofiled light suite remains27.99–28.44 seconds.
Hardware profiling is a separate workflow and takes longer. No runtime/CUDA
solver change, application speedup or additional N-series experiment is credited.
The installed SDK and unrelated source changes remain untouched.


## Final qualification

- **52/52 scenarios,104 checked ticks**, two independent physical restores per
  case; first full tick analyzed. Exact import state, repeatability, convergence
  and correction caps pass with unchanged tolerances.
- Final refresh: **388.11 seconds**,51 new captures plus one reused full-process
  pilot. This is diagnostic collection time, not the roughly28-second light
  timing screen. Initial light capture succeeded before the full campaign.
- **43,788 valid first-tick PM samples**, minimum96.90% interior coverage,
  maximum clock-anchor discrepancy7565 ns. No buffer overflow; all drains finish.
- **Zero CUDA event-completeness warnings**. Nsight reports a generic NVTX
  collection warning; every declared full-tick/command/simulate-fetch/completion
  range is present, closed and bounded. That warning is retained, not suppressed.
- Kernel count, copy count and copied bytes match the initial range-stopped
  capture for all52 cases. The initial captures remain raw diagnostic evidence;
  final reports use full-process draining and select only the first tick.
- Detailed NCU: **four scenarios, seven launches**, six reports. The first-fracture
  failures are indexed in [ncu-failures.json](ncu-failures.json), not included as
  successful hardware metrics. Full-world PM coverage does not imply full NCU
  coverage.
- Rebuilt normal, non-profiling probe passes bridge and city25 initial-impact
  import/repeatability plus cross-build physical comparison against the previous
  qualified full-suite outputs (four ticks; [checks](normal-checks.json)). Runtime
  libraries did not change. The full suite here validates profiling; it is not a
  new optimization acceptance campaign.

| City scale (authored chunks / bonds) | Idle mean / peak ms | Initial impact mean / peak ms | Late debris mean / peak ms |
|---|---:|---:|---:|
|25 buildings (11,100 /22,400)|9.601 /15.944|40.812 /52.200|69.946 /86.042|
|64 buildings (28,416 /57,344)|16.898 /25.849|64.630 /83.817|132.341 /166.994|
|256 buildings (113,664 /229,376)|59.200 /73.979|236.880 /254.511|394.491 /458.203|

Those are prior **unprofiled20-sample full-step measurements**, including commands,
physics, stress, transfers, synchronization and any correction; restore is
excluded. These are cold restored inputs, not continuous warm gameplay. All
structural shapes and eight phases at each city scale remain in the full report.
The baseline report retains deadline misses, spreads and per-sample stage times.

In the new diagnostic timeline, the largest late-debris tick contains884 kernel
launches and347 copies. Its two stress launches take41.95 and32.08 ms; H2D and D2H
copies total6.22 and6.08 ms respectively, versus0.23 ms D2D. These are profiled
aggregate device durations, potentially overlapping, and cannot be subtracted
from the unprofiled tick mean or treated as available savings. CPU lifecycle and
coordination remain relevant; pure kernel tuning cannot be assumed to solve the
full-step cost. All scenario stage, API, copy and kernel details are in JSON.

Raw final campaign: `out/snapshot-counters-20260911/full-drained/`.
[Artifact hashes](artifact-index.json) pin commands, inputs, binaries, receipts and
reports. Initial range-stopped reports are retained under `full/`; the CUDA-event
warning there is why the final collection was refreshed.

## What is saved

- Per scenario: full-tick/command/simulate-fetch/completion ranges; GPU activity
  interval union; every kernel launch and its register/block/grid/shared-memory
  metadata; CUDA API calls; copies split by direction/count/bytes/device duration.
- Whole-tick and sufficiently long kernel-interior hardware samples: resident
  warps over elapsed cycles, instruction rate, DRAM traffic, valid sample count,
  coverage and clock alignment. Short kernels can have no interior samples.
- Where NCU succeeds: full metric CSV/JSON, including achieved occupancy, eligible
  warps, issue activity, FP64 activity, registers, cache/local-memory metrics and
  warp-stall ratios. Source/PC details remain in the native NCU report.
- Native `.nsys-rep`, SQLite, `.ncu-repz`, raw PM CSV, config/clock anchors, exact
  commands, profiler versions, input hashes, loaded-module hashes and physical
  receipts. Raw root: `out/snapshot-counters-20260911/`.

The normal benchmark build has disabled/no-op profiling hooks. Only the isolated
`build-probe.py --profile` binary enables CUDA profiler start/stop and NVTX ranges.
The report tools reject instrumented runs as unprofiled performance data.

## Nsight Compute limitation, preserved rather than waived

Bridge, chain, dense connectivity and explicit-stimulus cases completed detailed
NCU captures and independent restored-tick checks. The first-fracture city case
aborted with `free(): invalid next size (fast)` under all three tested modes:

1. Full metrics, kernel replay (41 passes).
2. Hardware-only metrics, kernel replay (3 passes).
3. Hardware-only metrics, application replay (first pass).

These attempts and any reports they produced remain **unqualified**, under
`light-complete/`, `light-hardware/` and `light-application/`. The exact cause is
unresolved; do not assume a proved vendor-only defect or waive application memory
findings. The same input passes Nsight Systems and the external sampler. No
simulation waits, precision changes, CPU scheduling changes or suppressions were
introduced to accommodate the profiler. After the three failures, collection
switched to the existing external sampler instead of repeating the same approach.

An earlier dense-case NCU filter incorrectly included a template delimiter and
captured no kernel. The filter was corrected; successful timelines were reused.
An initial CSV importer expected the long format; current NCU exports wide rows
with a units row. Both formats now parse, without recapturing reports.

## How to interpret the counters

PM values are **device-wide**, including the explicitly recorded desktop/server
contexts. PM elapsed resident-warps percentage is not NCU achieved active
occupancy. The PM set does not provide eligible warps, FP64 utilization or detailed
stall reasons. Do not invent those fields for unsupported cases.

GPU activity uses the union of concurrent intervals. Kernel/API aggregates can
overlap; a CUDA wait can contain GPU execution. Time with no traced GPU activity
contains CPU work, submission gaps and profiler overhead and is not a proved
removable CPU cost. Some NCU cache percentages exceed100%; those are preserved and
flagged, not clamped or used as reliable quantitative evidence. See
[NVIDIA's range/precision guidance](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#range-and-precision).

Cold restored inputs also differ from continuous warm gameplay: large pristine
idle has about20 MB H2D traffic in its first tick, versus only1288 bytes D2H in
this capture. Large debris transfers about42.36 MB H2D,43.21 MB D2H and50.70 MB D2D.
These are whole integrated-step transfers, not all destruction-specific traffic.
Check which work persists in warm simulation before making an optimization claim.

## Next investigations

1. **Fragment lifecycle and CPU/GPU coordination.** First impact/debris have many
   more launches, copies and CPU decisions than intact idle. Attribute current
   compatibility allocation, owner migration, contact registration and accepted
   publication before altering ordering. Retain same-tick correction and sleep.
2. **Transfer and publication granularity.** Investigate changed-owner/chunk data,
   batching at existing mandatory joins, and redundant host mirrors. Separate
   H2D/D2H from cheap D2D checkpoint copies. Never defer a needed contact or query
   update. Confirm benefits in warm gameplay as well as restored inputs.
3. **Necessary solver work and decomposition.** Dense structures select a different
   dominant solver family from sparse chains/cities. Investigate redundant setup,
   active component sizing and dependency stalls before broad parameter tuning.
   Occupancy alone is not a diagnosis or a promised speedup.

The dated CPU/GPU [dataflow audit](../dataflow-audit.md) supplies source anchors and
older warm-phase evidence; its timings are a different implementation/cohort and
are not added to this atlas. The next ranked hypotheses are in `queue.json`.

Exact build, light/full capture, report and artifact-reuse commands are in
[OPTIMIZATION.md](../../../OPTIMIZATION.md#per-scenario-hardware-counter-atlas).
