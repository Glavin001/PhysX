# Nsight conditional-graph investigation — 2026-09-10

Follow-up: [direct CUPTI PM sampling](../../pm-sampling-rtx5060ti-20260910/README.md)
now provides real-trajectory later-peak counters with unchanged production
binaries. This resolves the immediate inability to collect those counters;
the Nsight Compute graph interaction below remains unresolved.

Hardware-counter access works on the RTX 5060 Ti / driver 615.71.09 / CUDA
13.4.59 / Nsight Compute 2026.3.0 installation. The integrated simulation's
failure is an execution discrepancy while the profiler is attached, not a
counter-permission error. Its underlying cause is not yet isolated to a specific
profiler defect or application integration error.

## Observed failure mechanism

The same ordinary, sleeping-enabled workload uses 256 buildings, 113,664 chunks,
229,376 bonds and 256 simultaneous projectiles. Runs request 180 steps / three
simulated seconds. Failed native runs stop at step 82; they are not completed
trajectories or performance measurements.

An isolated diagnostic library adds device logging to the allocation graph.
Under Nsight node profiling, `allocateNativeMotionRequests` executes on intact
steps with stage error zero, although `beginNativeMotionAllocation` sets its
conditional handle to zero and returns. At the first fracture:

```text
DIAG begin gen=83 stage=8 requests=4864 capacity=0 work=2 continuation=1
DIAG allocation gen=83 stage=8 error=1 capacity=0
DIAG collision stage=264 allocationError=1
INCOMPLETE native step 82: fetch=1 stage=1288 broken=28160 crushed=0
```

Error 1 in the allocation receipt means capacity growth is required. The normal
path skips both allocation and preparation branches, observes the receipt on the
CPU, grows storage and retries allocation. Under the profiler, the allocation
branch instead promotes that receipt to stage bit 256, and collision preparation
adds bit 1024. The CPU then rejects the incomplete step. This is not evidence
that CPU actor creation failed or that GPU memory was exhausted.

Without Nsight, the same diagnostic library completes all 180 steps. Its first
fracture logs the expected sequence: capacity zero → CPU growth → capacity 4,864
→ valid allocation. No allocation kernel executes during the preceding intact
steps. The profiled topology generation has also advanced to 83, whereas the
unprofiled first-fracture generation is 1. Thus the discrepancy precedes the
reported failure and is not confined to the final handoff.

The unprofiled diagnostic agrees with the existing Systems capture on all 180
steps for broken bonds, logical clusters, contact loads, correction/stress pass
counts and stress topology node/bond counts. Maximum stress iteration counts
differ on 25 later steps, first at step 132. This comparison does not establish
full numerical equivalence; exact differences are retained in `evidence.json`.

## Controls and dispositions

| Control | Outcome |
| --- | --- |
| Original runtime; select only later stress launch 130 | Fails at step 82 before selected counter collection (previous evidence) |
| Failure-only host logging; select launch 130 | Same failure; allocation error 1, zero slot capacity, 4,864 requests |
| Same host logging; `--profile-from-start off` | Same failure without counter collection |
| Isolated device logging; node mode | Shows execution of branches that should be skipped |
| Same device logging; no Nsight | Completes 180 steps, expected capacity-growth branch |
| Graph mode with kernel replay | Application exits with code 11 before first reported step; cause not diagnosed |
| Application-range, node mode, tick-108 start/stop | Nsight graph-node timeout after 30 seconds, target exit 9; internal log retained |
| Application-range plus graph mode | Rejected by this CLI: graph profiling only supported with kernel replay |
| Application-range plus profile-from-start off | Rejected option; corrected attempt is separately retained |
| Small conditional/cooperative/captured-branch examples | Correct with and without Nsight; no kernels selected |
| Existing standalone motion-slot allocation fixture | Passes under Nsight attachment, including capacity growth and negative cases; no kernels selected |

The small examples also test reversed conditional-handle creation order, early
returns, dynamic library loading and the production compilation/link pattern.
They do **not** reproduce the integrated failure. They are controls, not an
independent reproducer of a confirmed NVIDIA bug. No driver change or service
shutdown was attempted.

## Counter interpretation and next work

The earlier first-fracture stress capture remains an indicative kernel sample:
about 61% FP64-pipeline elapsed utilization, 2.3% DRAM utilization, 33.3% achieved
occupancy, and zero reported local spilling requests. Since preceding graph
execution differs under node profiling, it is not a verified replay of an
identical production state. Do not use it alone to qualify a bottleneck, a
precision change, or a performance win.

Next isolate the integrated graph interaction, including its multiple graphs,
contexts and runtime modules, against these passing controls. In parallel with
that reasoning, the alternative capture design is to save a real later-peak
stress problem and replay the same production kernel with verified input/output
agreement. Any such replay still needs an actual implementation and validation;
none was created here. Preserve normal graph synchronization and physical gates.

Once reliable capture is available, collect the trial and correction solves at
step 82 and the expensive step-108 trial; add source/PC stall attribution to
distinguish FP64 arithmetic, dependencies and collectives. Compare any candidate
against untraced complete-step maxima, with numerical qualification reported
separately. Active desktop graphics also prevent treating L2/DRAM counters as
fully isolated measurements.

## Reproduction and artifact integrity

`evidence.json` records exact commands, exit codes, production and diagnostic
binary hashes, loaded-module hashes and graphics processes. Diagnostic build
recipes and source copies are included. The standard production runtime hash
still matches `out/sdk-artifacts.json`; no production source, runtime library or
baseline executable was replaced. Logging builds and range-marker builds live
only in fresh subdirectories of `out/baseline-20260910-ordinary-sleeping/`.

For device logging, the recorded invocation additionally uses
`LD_LIBRARY_PATH=/root/workspace/physx-2/out/baseline-20260910-ordinary-sleeping/runtime-diagnostic-build`.
All diagnostic executable selections use `DESTRUCTION_PROFILE_BINARY`; actual
paths appear in commands and loaded maps. The checked-in scripts are archival
copies: run them from the original raw-capture layout, whose config they read,
using fresh destination names. Full GPU samples and `/proc/PID/maps` remain in
the raw capture directories. No investigation GPU jobs remain running.
