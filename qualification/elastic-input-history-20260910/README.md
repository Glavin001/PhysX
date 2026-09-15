# Preserve original native rigid inputs — 10 September 2026

The installed destruction runtime now retains original post-command/pre-solve
rigid arrays while refreshing the corrected-motion checkpoint used by the
second verdict. Two reusable allocations rotate at that refresh, preserving
the original input without adding another full-array copy. The second allocation
adds memory and can incur growth cost; no performance win is claimed.

This is private producer ABI **V11**. The SDK, GPU module and native consumers
were rebuilt together using CUDA 13.4.59 / sm_120; SDK attestation was refreshed.
Public `PxDestructionScene` ABI and the production stress backend are unchanged.
Earlier reports saying the installed runtime was unchanged describe their earlier
captures, not this build. Source remains uncommitted WIP on `1155b7ff`.

`inputRigidCheckpoint()` is a borrowed, read-only original view until the next
BeforeSolve capture or clear. Consumers must honor its ready event and finish
before that lifetime boundary. Current and original generations/purposes are
explicit; repeated corrected refreshes reject before mutation. This raw body
history is **not a complete chunk-targeted command ledger**. Newly created body
indices cannot index the old input pool: ancestry and slot-generation mapping
remain necessary. Original inputs must not be restored over accepted corrected
motion. The one-correction/two-evaluation limit remains intact.

## Validation

- Seven focused native CTests pass, including rigid checkpoint, correction
  bodies, resimulation, post-correction and three ordinary/sleeping checks.
- The checkpoint fixture covers eight combinations of TGS/PGS, sleeping on/off
  and optional acceleration arrays on/off. It checks byte preservation, consumed
  force history, separate corrected state, next-tick growth and clear/stale-handle
  rejection. Memcheck passes with zero errors.
- Initcheck fails: **10,028 errors in both saved pre-change and rebuilt controls**.
  Full diagnostic categories and device sites/counts are identical. They include
  native radix sort, motion-slot allocation, broadphase, contact preparation and
  solver reads, plus host-access findings. Both matched ABI library sets were
  verified through actual process maps. This attributes these observations as
  predating the change; their causes remain unresolved. Nothing was suppressed
  or waived, and no production zeroing was added. This is not a clean sanitizer
  qualification or a conclusion about the older isolated CUB investigation.

An isolated capture of the current runtime completed one ordinary/sleeping
256-building trajectory: 113,664 chunks, 229,376 authored bonds, one 256-shot
wave, 180 steps / three simulated seconds, physical dt 1/60. The real
post-contact/pre-stress boundary produced these original-history receipts:

| Tick / evaluation | Original generation | Current checkpoint generation | Original body-pool entries |
| --- | ---: | ---: | ---: |
| 1 / trial | 1 | 1 | 512 |
| 83 / trial | 83 | 83 | 512 |
| 83 / correction | 83 | 84 | 512 |
| 109 / trial | 131 | 131 | 11,161 |

The 131,072 original body bytes at tick 83 are identical across actual fracture
correction. Optional previous-velocity/acceleration arrays are absent in this
native configuration; their retention is covered by the focused fixture.
The trajectory matches the preceding partition capture's fracture, cluster,
contact, correction/evaluation and active-node/bond histories. Iterations differ
on 21 later steps, first at step 133. These comparisons do not qualify full
physical equivalence or a general command-plus-fracture path.

The frozen ordinary/sleeping wall audit also completed 600 steps / ten simulated
seconds, 444 chunks, 896 bonds and one projectile. Physical invariants pass;
400 supported / 44 detached / 182 broken bonds / 39 clusters, topology identity,
clearance step 43 and fracture/correction steps match the prior migration capture.
The historical golden identity gate still fails, unchanged. The wrapper initially
rejected the module path: the demo loaded the rebuilt source-output library,
whose hash equals the installed library, rather than the requested install path.
Both module hashes were checked and the existing capture was independently
verified; the simulation was not repeated or its failed wrapper log discarded.

No timing from these copied/instrumented/sanitized audits is a speed claim.
The previous [untraced baseline](../baseline-rtx5060ti-20260910/README.md) remains
the measured performance reference. Report strict exceedances of 8 ms,
1000/120 ms and 1000/60 ms separately, retaining startup and all-step maxima.
Prior counter evidence remains valid for its recorded binaries/workloads; this
buffer-lifetime change has no new counter-derived optimization claim.

## Evidence and next boundary

Raw evidence: `out/elastic-input-history-20260910/`, including saved V10 binaries,
build logs, actual process maps, full failed sanitizer logs, native input blobs
and wall observations. [receipt.json](receipt.json) records hashes and commands;
[source.patch](source.patch) preserves the current change and capture helpers.
[input-history-check.json](input-history-check.json),
[native-analysis.json](native-analysis.json),
[initcheck-comparison.json](initcheck-comparison.json) and
[wall-invariants.json](wall-invariants.json) retain results. All owned jobs finished.

Next define the GPU command/contact interval producer and original-to-current
motion ancestry before interpreting raw external acceleration as chunk loads.
Prescribed motion, damping/locks, command modes and exactly-once correction need
explicit qualification. Fine bond/material conversion, numerical-component/setup
keys and accepted trial/correction transactions still precede backend replacement.

To reproduce with a fresh directory after rebuilding the SDK and consumers:

```bash
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/build.py out/history-NEW/build
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/run.py out/history-NEW/native
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/check_input_history.py out/history-NEW/native
```
