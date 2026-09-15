# Frozen native loads and GPU adapter replay — 10 September 2026

Follow-up: [GPU active partition](../elastic-partition-20260910/README.md) adds sparse layouts, retained native mappings and device-count load consumption. This report retains the earlier capture and single-body improvement evidence.

The actual native contact producer is now captured immediately after
`routeContacts`, before stress/material/topology dispatch. An isolated diagnostic
runtime records the impulses entering `contactLoad`, resulting surface wrenches,
legacy acceleration inputs, full physical mass/inertia, exact motion membership,
poses, body command fields, support masks and evaluation identities. The installed
SDK/runtime remains unchanged. Source is uncommitted WIP on `1155b7ff`.

## Native workload and capture boundary

RTX 5060 Ti 16 GB, CUDA 13.4.59, driver 615.71.09. One diagnostic run: 256
buildings, 113,664 chunks, 229,376 authored bonds, one simultaneous 256-projectile
wave, 180 steps / three simulated seconds. Ordinary scene API, sleeping enabled,
physical timestep 1/60 second, at most one correction. Desktop graphics remain
active. Copies, synchronization and file writes make this run unsuitable for
complete-step timing claims. The existing untraced baseline still owns 8 ms,
120 Hz and 60 Hz deadline reporting.

| Solve ordinal | Native tick / evaluation | Ownership generation | Motion aggregates | Live bonds | Routed contact sides | Chunks receiving contacts |
|---:|---|---:|---:|---:|---:|---:|
| 0 | 1 / trial | 0 | 256 | 229,376 | 0 | 0 |
| 82 | 83 / trial | 0 | 256 | 229,376 | 2,048 | 1,024 |
| 83 | 83 / correction | 1 | 5,120 | 201,216 | 87,312 | 12,160 |
| 130 | 109 / trial | 44 | 10,905 | 176,336 | 243,382 | 26,664 |

Ticks are one-based; native CSV steps are zero-based. A contact side is one
chunk's invocation of `contactLoad`, not a unique pair or normal/friction row.
All 113,664 chunks remain active in these captures. All four mappings agree
between packed runtime clusters, authored roots and stable motion slots; all
physical mass tensors are positive definite. There are 256 supported aggregates,
all stationary in the captured evaluations. Captured current/checkpoint command
accumulators, damping, locks and gravity-disable flags are zero for destruction
bodies. These snapshots do not establish a complete general engine command ledger.

The 180-step capture matches the existing Systems trajectory's fracture, cluster,
contact, correction/evaluation and stress-active-node/bond counts. Stress iteration
counts differ on 26 later steps, first at step 132. Convergence and correction
status checks pass. These observations do not resolve migration fidelity failures.

The actual input duration is the promoted native float
`0.01666666753590107`; its float reciprocal is `59.999996185302734`.
The recorded surface values already include that division. Reconstructing their
force/torque/virial from recorded impulses in double precision exposes the existing
float transform/accumulation rounding; the numerical differences are retained in
[analysis.json](analysis.json), rather than asserted to be exact native equivalence.
The adapter does not divide the force values again.

## Corrections discovered by real inputs

Native topology generation zero is valid. The adapter now accepts it, while still
requiring a nonzero published load generation, completeness and exact identity
matching. A new regression accepts generation zero and rejects an unpublished
load generation.

The first independent native-load comparison failed on tiny residuals for free
single-chunk aggregates: subtracting rounded external/inertial wrenches left up
to `4.66e-10` where the exact internal RHS is zero. Such a complete, unprescribed
one-node aggregate has only six rigid DOFs. The adapter now computes its physical
linear/Euler acceleration and publishes exactly zero internal load, avoiding
aggregate reductions and large-number subtraction. It still rejects invalid
mass, frames, intervals and nonfinite loads; supplied-engine-acceleration and
supported cases retain their existing checks. This is not a blanket small-load
clamp, nor a relaxation of compatibility or convergence.

The independent reference uses that same exact one-node physical identity, with
all other equations evaluated independently on the host. The original
`2e-11 * (1 + abs(reference))` comparison limit remains unchanged. A new 129-body
fixture covers large force/moment, spin, additional loads and nonfinite rejection.
The load test is slightly above the 500-line review target to retain these cases
beside their shared independent reference, rather than extract unrelated code.

## Validation and hardware counters

- All four real-load replays pass the independent Newton–Euler comparison:
  mass, COM, acceleration, angular acceleration and every effective force/moment.
- Four focused six-channel CTests pass.
- The later capture's full adapter replay passes memcheck, initcheck, synccheck
  and racecheck: zero errors/hazards.
- Nsight Compute completes on that replay. Profiled and unprofiled final receipt
  and effective-load buffers are byte-identical.

The counter workload is the **new adapter**, using tick-109 captured surface
loads and geometry: 113,664 chunks, 10,905 aggregates, including 9,114 free
singletons. It does not run the production stress/material/correction path.
Each version has one counter capture, ten replay passes, cache flushing enabled,
clocks unlocked, Nsight Compute 2026.3.0; desktop graphics remain active.

| Counter | Before exact single-body path | After |
|---|---:|---:|
| Profiler kernel duration | 5.89 ms | 1.96 ms |
| Registers/thread | 116 | 116 |
| Achieved occupancy | 33.17% | 26.57% |
| DRAM throughput / peak | 1.37% | 3.04% |
| Local/shared spilling requests | 0 / 0 | 0 / 0 |

This is evidence that removing unnecessary aggregate work helps this replay,
not a physically qualified engine speedup or an untraced timing claim. Lower
occupancy accompanied less work here; occupancy alone is not an optimization goal.

The replay explicitly defines its load case as captured surface wrenches plus
gravity, no additional commands, stationary prescribed supports and free inertial
relief elsewhere. Its completeness assertion applies to that numerical case.
**The native capture's general command-ledger completeness remains false.**
No new material verdict or fracture is published by the replay. GPU grouping here
uses the captured all-active permutation; general sparse active-node mapping and
live producer-owned receipts still require implementation.

## Reproduce and continue

From the repository root, create fresh destinations and leave earlier attempts:

```bash
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/build.py out/live-loads-NEW/build
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/run.py out/live-loads-NEW/native
/usr/local/cuda-13.4/bin/nvcc -std=c++17 -O3 -lineinfo -arch=sm_120 -ccbin /usr/bin/g++-12 \
  -Iphysx/include -Iphysx/source/gpudestruction/src -Iblast/source/sdk/extensions/stressgpu/detail \
  tools/diagnostics/destruction-load-capture/Replay.cu -o out/live-loads-NEW/replay
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/analyze.py out/live-loads-NEW/native
.toolchains/build-env/bin/python tools/diagnostics/destruction-load-capture/validate.py \
  --capture out/live-loads-NEW/native --replay out/live-loads-NEW/replay --output out/live-loads-NEW/validation
```

The capture builder reads current CMake compile/link settings and changes only an
isolated translation unit/library. The native runner records actual loaded
modules and refuses to reuse a capture directory. The validation wrapper retains
failed commands and checks counter-output identity. GPU availability must be
checked before a replay campaign; do not stop other users' jobs.

Raw inputs, original failed comparison, binaries, profiler reports and actual
process maps: `out/live-loads-20260910/`. [receipt.json](receipt.json) records
commands and source/binary/module/raw-input hashes. The [source patch](source.patch)
contains the current standalone solver, adapter and diagnostic tools;
[reference-check.json](reference-check.json) and [counters-after.txt](counters-after.txt)
record the final checks. Production runtime hash still matches SDK attestation.

Next implement the live producer's complete contact/command interval receipt,
canonical positions and active motion-to-fine-node mapping at the captured
boundary. Use native ownership generation zero directly. Do not infer engine
acceleration from these checkpoint snapshots: after correction, their lifecycle
can already include updated motion. Qualify prescribed motion and all applied
commands before claiming completeness. Then integrate full bond/material state,
trial/correction evaluation and accepted publication. Existing migration failures
and city-scale complete-step qualification remain open.
