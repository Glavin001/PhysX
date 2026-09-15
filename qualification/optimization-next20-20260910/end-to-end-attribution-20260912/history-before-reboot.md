Historical record before user-authorized recovery; superseded by README.md.

# Complete-step attribution expansion — incomplete, GPU recovery required

The user requests complete CPU attribution and every significant GPU kernel,
accepting a pinned Nsight Compute collector. No application optimization or
speedup is claimed. Runtime libraries, physical inputs, ordinary APIs, sleep,
correction limits and tolerances are unchanged. Profiling uses an isolated probe.

## Verified and remaining coverage

**38/52 CPU-attribution cases qualify: 76 checked ticks, 6,536 CPU samples,
11,307 engine scopes and 9,280 GPU kernel launches.** Position, linear velocity
and angular velocity differences from unprofiled references are zero. Existing
orientation/force tolerances are unchanged. [All 52 baselines, stages, deadlines,
CPU coverage and raw links](report.md), [structured report](report.json).

| Scenario group | Qualified CPU cases | Outstanding |
|---|---:|---|
| Original structural cases | 28/28 | None in this capture tier |
| 25 buildings / 11,100 chunks | 8/8 | None in this capture tier |
| 64 buildings / 28,416 chunks | 2/8 | Impact quarantined; remaining five not qualified |
| 256 buildings / 113,664 chunks | 0/8 | All eight |

Each qualified case has DWARF CPU samples, OS scheduling, CUDA and OS call stacks,
all traced GPU launches/copies/memsets, launch/stream correlations, and native
destruction phase wall/thread CPU/device event data. The existing native phase
recorder is connected to NVTX in the diagnostic executable. Normal builds have
no new profiling callback. Both profiling and normal probe builds pass; five
CPU accounting/selection regression tests pass.

The raw Systems/SQLite files retain complete recorded stacks and scheduling
events. Proprietary driver/kernel frames can remain unresolved, and short cases
have statistical sampling limits. These gaps are counted, not silently assigned
to application CPU work. CUDA waits and GPU activity overlap; no subtraction
between profiled GPU time and unprofiled application time is used.

The **prior 52-scenario NCU qualification remains targeted**, 62 files / 86
launches. Broad capture is implemented but not qualified. Its default inventory
selects >=99% of aggregate kernel time, every family >=0.1ms, and stress; it then
captures **all invocations** of selected families, including changing grids and
trial/correction. Thresholds are adjustable through 100%. Omitted work stays in
the complete timeline. Exact inventory comparison rejects missing captures.

## Conditional graph limitation

An explicit two-family pilot on city25 initial impact requested component stress
and `constructMotionModes`. The pinned 2025.3.1 collector recorded stress but
skipped the conditional-graph kernel, warning that such nodes are unsupported.
A successful profiler exit therefore does not establish full kernel coverage.
Repeated `--kernel-id` arguments are not supported; the corrected tool uses one
anchored mangled-name regex and records every matching invocation.

NVIDIA's newer documentation describes conditional-node profiling support with
driver >=590. Archived **2026.2.1** was downloaded/extracted locally to test this
capability without the known 2026.3.0 heap abort. **That GPU test has not run**:
its queued job aborted when the CPU campaign failed. The installed 2025.3.1 pin
remains unchanged. No driver/toolkit update was performed.

Sources: [NVIDIA graph profiling](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#graph-profiling),
[kernel identifier syntax](https://docs.nvidia.com/nsight-compute/NsightComputeCli/index.html#profile),
[official archived collectors](https://developer.download.nvidia.com/compute/cuda/redist/nsight_compute/linux-x86_64/).

## Machine failure, separate from the older NCU heap abort

At **2026-09-12 05:30:46 UTC**, the kernel logged **Xid120**, a GSP task store-access
page fault, for PID **1671498**, `CUPTI worker th`. This is the city64 initial-impact
Systems process. Its first tick ran 05:30:43.890237–05:30:44.101778; the last
recorded GPU kernel ended at 05:30:45.158204. `cuCtxDestroy_v2` began at
05:30:46.471075 and took 30,125.121ms. Thus the fault was reported during context
teardown, after the measured tick. This does not identify the faulty instruction
or establish which profiling option triggered it.

The application and physical comparison returned successfully, and NVML briefly
retained a normal temperature. **The capture is nevertheless quarantined.** The
following city64 post-impact process failed CUDA initialization with code100;
NVML now reports `GPU requires reset` and `GPU Recovery Action: Reset`.
The wrapper now rejects reset-required state and checks kernel Xids after a run.

NVIDIA identifies Xid120 as a GSP error with GPU reset as the recovery action:
[Xid catalog](https://docs.nvidia.com/deploy/xid-errors/analyzing-xid-catalog.html).
The fault log and context-teardown timing are preserved under
`out/end-to-end-attribution-20260912/gpu-fault/`. No service was stopped, GPU reset
performed, reboot requested, or external report submitted.

GPU device users remain `web-fps-server` PID435374, desktop locker PID5246 and
`nvidia-persistenced` PID717. Recovery can disrupt the other project and desktop.
It requires the user's approval under the existing AGENTS instruction not to
stop other users' services/desktop/GPU jobs. Do not reset or stop them merely
because this document describes the recovery.

## Resume after authorized recovery

1. Recheck device users and host GPU health. Preserve the fault logs first.
   Coordinate stopping/restarting affected clients before a GPU reset; if the
   hardware requires a VM power cycle, obtain authorization for that separately.
2. Pilot city64 impact with CPU sampling, scheduling, native phases and CUDA/OS
   backtraces, **without** optional GPU-allocation/all-API tracing. This reduced
   combination is an untested diagnostic hypothesis, not a proven fix. If the
   firmware fault recurs, stop the campaign and investigate collector/driver
   teardown rather than repeatedly resetting and rerunning the same work.
3. Resume the CPU campaign. It preserves the 38 qualified cases and creates new
   attempt directories for the quarantined/failed cases, leaving their raw data.
4. Test 2026.2.1 on the saved two-family pilot and compare physical observations.
   If it qualifies, expand the kernel inventory campaign; otherwise investigate
   graph-level counters/replay without changing production synchronization.
5. Add CPU-enabled continuous native idle/heavy profiles on the same artifacts;
   existing warm profiles and the 20-sample cold suite remain different workloads.
6. Audit every manifest case and kernel selection, report remaining unresolved
   attribution, then resume optimization using unprofiled light/full acceptance.

Exact tooling and commands are in [OPTIMIZATION.md](../../../OPTIMIZATION.md).
No owned GPU jobs remain live. The attribution expansion is **not complete**.
