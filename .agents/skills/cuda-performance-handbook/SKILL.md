---
name: cuda-performance-handbook
description: Diagnose and tune native C++/CUDA performance on Linux using Nsight Systems, Nsight Compute, CPU profiling, and correctness checks. Use for profiling commands, timeline and counter interpretation, kernel bottlenecks, memory behavior, occupancy, synchronization, and numerical performance analysis.
---

# CUDA performance engineering for real-time C++ applications

A practical handbook for headless Linux: measurement, Nsight Systems, Nsight Compute, CPU profiling, GPU architecture, numerical algorithms, and continuous performance validation.

The objective is **the fastest complete application that meets a defined numerical-quality contract across its supported workloads**. A fast isolated kernel, high GPU utilization, high occupancy, and low iteration counts are useful observations, but none is sufficient to establish that objective.

This handbook proceeds from a first useful capture to advanced diagnosis. The recommended experiments and worked examples are engineering proposals, not measured results from a particular application. Tool behavior is tied to the documented versions; architecture-dependent features require a capability check. The documentation baseline includes Nsight Compute 2026.3 and CUDA 13.4. Your installed tools may differ. [NVIDIA release information][ncu-release]

## Contents

1. [The optimization loop](#1-the-optimization-loop)
2. [A first useful profiling session](#2-a-first-useful-profiling-session)
3. [The CPU–GPU execution model](#3-the-cpugpu-execution-model)
4. [Define performance and correctness](#4-define-performance-and-correctness)
5. [Build a reproducible benchmark](#5-build-a-reproducible-benchmark)
6. [Prepare the Linux environment and build](#6-prepare-the-linux-environment-and-build)
7. [Instrument meaningful work](#7-instrument-meaningful-work)
8. [Establish correctness](#8-establish-correctness)
9. [Nsight Systems from the terminal](#9-nsight-systems-from-the-terminal)
10. [Read timelines without a GUI](#10-read-timelines-without-a-gui)
11. [Profile and optimize the CPU](#11-profile-and-optimize-the-cpu)
12. [Nsight Compute collection recipes](#12-nsight-compute-collection-recipes)
13. [Replay, clocks, caches, and trustworthy counters](#13-replay-clocks-caches-and-trustworthy-counters)
14. [Interpret hardware metrics](#14-interpret-hardware-metrics)
15. [Diagnose kernels systematically](#15-diagnose-kernels-systematically)
16. [Expose parallelism and balance work](#16-expose-parallelism-and-balance-work)
17. [Optimize memory access](#17-optimize-memory-access)
18. [Occupancy, registers, and latency hiding](#18-occupancy-registers-and-latency-hiding)
19. [Instructions, divergence, atomics, and synchronization](#19-instructions-divergence-atomics-and-synchronization)
20. [Streams, transfers, allocation, fusion, and graphs](#20-streams-transfers-allocation-fusion-and-graphs)
21. [Numerical algorithms and sparse solvers](#21-numerical-algorithms-and-sparse-solvers)
22. [Precision and numerical quality](#22-precision-and-numerical-quality)
23. [Real-time scheduling and workload sparsity](#23-real-time-scheduling-and-workload-sparsity)
24. [Roofline, cost models, and stopping decisions](#24-roofline-cost-models-and-stopping-decisions)
25. [Advanced architecture and multi-GPU work](#25-advanced-architecture-and-multi-gpu-work)
26. [Automate analysis and regression checks](#26-automate-analysis-and-regression-checks)
27. [Worked investigations](#27-worked-investigations)
28. [Troubleshooting](#28-troubleshooting)
29. [Practice sequence and review checklists](#29-practice-sequence-and-review-checklists)
30. [Source map and further study](#30-source-map-and-further-study)

## 1. The optimization loop

Use the tools in this order:

| Question | Primary evidence | Tool |
|---|---|---|
| Is the complete application fast enough? | Completion latency, throughput, deadline misses, quality | Application benchmark |
| Where does elapsed time go? | CPU work, submission, waits, kernels, transfers, overlap | `nsys` |
| Why is a selected GPU workload expensive? | Launch geometry, counters, instruction/source attribution | `ncu` |
| Why is host work expensive? | CPU samples, scheduling, cache and branch events | `perf`, `nsys` |
| Is the implementation valid? | Memory/synchronization checks and numerical validation | `compute-sanitizer`, application checks |
| Did the change improve the product? | Same workload and acceptance contract, without profiler | Application benchmark again |

NVIDIA's analysis-driven optimization examples illustrate an important pattern: expose the work, inspect the current limiter, change the implementation, and inspect again. The limiter changes as optimization succeeds. Their examples are useful exercises; their hardware measurements are not predictions for another application. [ADO part 1][ado1], [part 2][ado2], [part 3][ado3]

For each proposed change, write five statements before implementing it:

1. **Observation:** what was measured, with scope, units, workload, and report.
2. **Hypothesis:** the mechanism that could explain it.
3. **Experiment:** the smallest change that distinguishes this explanation from alternatives.
4. **Prediction:** which absolute costs and counters should change, and in which direction.
5. **Acceptance:** the performance improvement and numerical checks required to keep it.

Example:

> Observation: the target phase contains many launches, and the GPU activity trace has gaps after scalar readbacks. Hypothesis: host-driven convergence checks prevent the GPU from receiving the next iteration promptly. Experiment: check convergence every four iterations while keeping the original stopping threshold and a final true-residual check. Prediction: fewer readbacks and gaps, possibly more iterations. Acceptance: lower completion p99 and unchanged quality on the stress suite.

A hypothesis becomes a supported explanation when the experiment changes the predicted mechanism and improves the relevant outcome. A counter screenshot alone does not establish causality.

Maintain separate backlogs for **removing unnecessary work**, **changing algorithms**, **changing CPU/GPU coordination**, and **making remaining kernels cheaper**. A faster instruction sequence is often less valuable than avoiding an entire repeated pass.

## 2. A first useful profiling session

The following commands assume Bash, an executable `./app`, and a writable `profiles` directory. Application switches such as `--scenario`, `--warmup`, `--steps`, and `--seed` are a **proposed benchmark interface to implement or replace with your existing options**. They are not CUDA or Nsight switches.

### Step 1: inventory the tools

```bash
mkdir -p profiles
nvidia-smi
nvcc --version
nsys --version
ncu --version
compute-sanitizer --version
nsys status --environment
ncu --list-sets
ncu --list-sections
nsys stats --help-reports
```

The CUDA version displayed by `nvidia-smi` indicates driver CUDA compatibility, not the version of `nvcc` installed in your build environment. Record both. [NVIDIA SMI][smi]

### Step 2: measure the normal application

```bash
./app --scenario typical --warmup 200 --steps 2000 --seed 42
```

Record completed-step timings and quality results. Repeat with several fixed scenarios. Do not proceed on the assumption that printed kernel enqueue time is completion time.

### Step 3: check a short representative run

```bash
compute-sanitizer --tool memcheck --error-exitcode 99 \
  ./app --scenario small --warmup 1 --steps 20 --seed 42
```

### Step 4: capture system activity

```bash
nsys profile \
  --trace=cuda,nvtx,osrt \
  --sample=none --cpuctxsw=none \
  --output=profiles/system-01 \
  ./app --scenario typical --warmup 200 --steps 200 --seed 42
```

This short first capture includes startup. Section 7 shows how to restrict collection to a measured region. The two disabled CPU collectors make this a simpler initial trace, not a complete CPU investigation.

### Step 5: obtain text reports

```bash
nsys stats \
  --report=cuda_api_sum,cuda_gpu_kern_sum,cuda_gpu_mem_time_sum,nvtx_sum \
  profiles/system-01.nsys-rep

nsys stats --report=cuda_kern_exec_sum profiles/system-01.nsys-rep
nsys stats --report=cuda_gpu_trace profiles/system-01.nsys-rep
```

Look for expensive phases, repeated short launches, transfers, waiting, and variation. A kernel's percentage in a kernel summary is its fraction of the listed kernel-duration sum, not its fraction of application wall time. [Nsight Systems analysis reference][nsys-analysis]

### Step 6: inspect one relevant kernel invocation

Replace `apply_operator` with an actual kernel name from the trace:

```bash
ncu \
  --kernel-name-base function \
  --kernel-name 'regex:apply_operator' \
  --launch-skip 20 --launch-count 1 \
  --section SpeedOfLight \
  --section LaunchStats \
  --section Occupancy \
  --export profiles/operator-01 \
  ./app --scenario typical --warmup 200 --steps 50 --seed 42

ncu --import profiles/operator-01.ncu-rep --page details
```

`--launch-skip 20` skips twenty launches matching the kernel filter; it does **not** skip twenty application steps. `--launch-skip-before-match` counts all launches. Verify that the chosen instance is in the intended phase; use NVTX filtering for reliable selection. [Nsight Compute CLI][ncu-cli]

### Step 7: make one change and repeat normal timing

Preserve the original report and binary. Capture the same workload after the change, then benchmark without Nsight. Keep the change only if it improves the chosen application metric within the quality contract.

This sequence should yield a useful first diagnosis. The remaining chapters explain how to avoid false conclusions and choose better experiments.

## 3. The CPU–GPU execution model

A CUDA application has at least two schedules: CPU execution and GPU execution. Host code usually submits GPU work and continues. A CUDA API duration is the time spent in that host call; it is not generally the duration of the GPU operation it requested.

A kernel launches a grid of thread blocks. A block executes on one streaming multiprocessor, or **SM**, during its lifetime. Its threads are grouped into warps of 32 lanes. Many blocks may be queued while only a subset is resident. Threads in a block can cooperate through shared memory and block synchronization. Ordinary blocks must not rely on an execution order or on every block being resident simultaneously. [CUDA programming model][gpu-model], [writing kernels][kernels]

| Term | Practical meaning |
|---|---|
| Grid | All blocks belonging to one kernel launch |
| Warp | The group of 32 lanes used for instruction scheduling |
| Resident/active warp | A warp whose execution state occupies SM resources |
| Eligible warp | A resident warp ready to issue its next instruction |
| Issued instruction | Work a scheduler actually dispatches |
| Occupancy | Resident warps relative to the architecture's residency limit |
| Throughput | Work completed per unit time |
| Latency | Time from a defined start to a defined completion |
| Critical path | The dependency chain determining completion time |
| Tail | The final, poorly balanced work keeping a phase alive |
| Replay | Re-execution used by a profiler to collect more metrics |
| SASS | GPU machine instructions for a concrete architecture |
| PTX | A virtual instruction representation that still requires compilation |

The design question is not just “can this loop run on the GPU?” Ask:

- Which iterations are independent?
- How much independent work exists simultaneously?
- Which data must be available before each operation?
- Which results force the CPU or another kernel to wait?
- How much memory traffic and coordination does this decomposition introduce?

A loop over six tightly related components inside each of 100,000 node threads may be efficient. A loop over 100,000 independent nodes inside one thread is suspicious. Sequential work is not automatically wrong; **unnecessarily limited parallelism** is the problem.

For example, a local recurrence may be inherently sequential within one problem. You can still solve many independent problems concurrently, change the recurrence algorithm, or introduce a hierarchy. Moving the exact same serial organization into `__global__` code does not exploit the device well.

## 4. Define performance and correctness

Write a contract before tuning:

| Dimension | Example specification to adapt |
|---|---|
| Completion boundary | Input accepted to numerically validated state ready for consumption |
| Deadline | A step must finish before its next scheduled release |
| Latency distribution | p50, p95, p99, observed maximum, miss rate |
| Throughput | Completed steps or solved problems per second |
| Quality | Residual threshold, constraint error, drift, event agreement |
| Scale | Problem sizes, graph structure, active fraction, input rate |
| Hardware | Exact supported GPUs, CPU topology, deployment power policy |
| Memory | Peak device memory and host workspace limits |
| Overload | Explicit fallback when the deadline cannot be met |

At 60 Hz the interval is about 16.667 ms. That is not automatically the numerical solver's budget: input handling, other compute, rendering if present, and queueing may share it. If phases overlap, reason about dependencies instead of subtracting a sum of overlapping durations.

Measure at least three distinct quantities:

- **Service time:** how long a step takes after work begins.
- **Response time:** how long an arriving input waits until its result is ready, including queueing.
- **Completion cadence:** spacing between completed outputs.

A deep queue can improve measured GPU throughput while making response latency unacceptable. A loop that generates its next input only after finishing the previous one hides this effect. For a real-time workload, include a replay with scheduled arrivals and count missed deadlines against those arrivals.

Use a scenario matrix that includes tiny, typical, large, irregular, bursty, settled, and adversarial numerical cases. Add cases with equal object counts but different connectivity, degree distribution, conditioning, or active fraction. These can have very different costs.

“Observed maximum” is a finite-test result, not a worst-case execution-time proof. A Linux process on a shared GPU does not acquire a hard real-time guarantee merely by meeting p99 in a benchmark. Treat predictable scheduling and reserved resources as deployment properties to verify.

## 5. Build a reproducible benchmark

### Separate four kinds of runs

| Run type | Purpose | What to exclude from its conclusions |
|---|---|---|
| Normal release benchmark | Product latency and throughput | Profiler-derived explanations without a separate capture |
| Correctness run | Memory, synchronization, mathematical validity | Performance conclusions from instrumentation slowdown |
| Systems trace | CPU/GPU coordination and timeline | Assuming trace overhead is zero |
| Compute capture | Selected workload's hardware behavior | End-to-end frame time under replay |

Use the same input tape, random seed, initial state, tolerance, and completion semantics for A/B comparisons. Save the executable hash, source revision, dirty diff, configuration, and input hash. For stateful applications, a seed alone is insufficient if thread ordering, wall-clock input, or external data changes execution.

### Warm up the code paths that matter

Warmup may need to exercise CUDA context initialization, module loading, JIT compilation, memory pools, graph instantiation, library setup, and representative kernel variants. A warmup loop that never enters the expensive burst path does not warm that path.

Also measure cold startup separately if it matters. Lazy loading can shift a one-time cost into the first use of a previously untouched kernel or module. Preload or explicitly exercise required paths before a latency-sensitive period when appropriate. [CUDA lazy loading][lazy]

Prefer a normal deployment workload long enough for frequency and thermal behavior to stabilize. Record the resulting clocks and temperature. Do not equate a short high-boost microbenchmark with sustained operation.

### Measure completion correctly

For **an isolated same-stream batch**, CUDA events are useful:

```cpp
// Illustration: stream and events are created once outside this region.
// CUDA_CHECK is an error-checking wrapper, defined in section 8.
CUDA_CHECK(cudaEventRecord(begin, stream));
for (int i = 0; i < repetitions; ++i) {
    launch_step(stream);  // Your implementation, same stream for this example.
}
CUDA_CHECK(cudaEventRecord(end, stream));
CUDA_CHECK(cudaEventSynchronize(end));
float elapsed_ms = 0.0f;
CUDA_CHECK(cudaEventElapsedTime(&elapsed_ms, begin, end));
```

Divide by `repetitions` only if that is the metric you intend: it gives an average over the batch, not per-step tail latency. The event interval can include stream idle gaps caused by delayed host submission. It is not necessarily a sum of kernel durations.

For work across multiple streams, a timing stream must wait on **every contributing stream's completion event** before recording the end event. Establish a shared start dependency if measuring a controlled phase. Otherwise one stream can finish its timer while another still runs. CUDA events and stream waits express these dependencies without a device-wide wait. [Asynchronous execution][async]

For end-to-end latency, use `std::chrono::steady_clock` at the defined input and completion boundaries. If measuring with `cudaDeviceSynchronize()`, understand that it waits for all relevant preceding work on the device/context and can include unrelated work. It also changes overlap if inserted after every operation.

In a production-like pipeline, prefer a ring of preallocated completion events. Associate each event with the original release timestamp; process completed events later. Polling detects completion after some delay, so distinguish the host-observed response timestamp from device event timing. Keep the polling policy identical across comparisons.

### Make the samples interpretable

Write a CSV with one row per completed step, for example:

```text
run_id,scenario,step,release_ns,start_ns,completion_ns,latency_ms,service_ms,iterations,active_nodes,active_edges,true_residual,quality_ok
```

Use unambiguous units. Avoid per-element logging in the measured path. Buffer records and write them after the capture or in a bounded background path whose cost is included in deployment tests.

Report sample count alongside quantiles. Twenty samples do not characterize p99. A few thousand frames can still miss rare event-driven spikes. Use repeated scenario tapes and long runs for workload-specific tails; do not assume adjacent frames are independent samples.

Interleave baseline and candidate runs to reduce thermal or machine-load drift. Summarize per-run outcomes rather than treating every correlated frame as an independent statistical trial. Investigate results near the noise floor before accepting them.

The companion `summarize_timings.py` accepts a CSV `latency_ms` column and prints nearest-rank quantiles, deadline misses, and the longest miss streak. It does not decide statistical significance or mathematical correctness.

## 6. Prepare the Linux environment and build

### Record the machine and toolchain

```bash
uname -a
lscpu
nvidia-smi -L
nvidia-smi topo -m
nvidia-smi -q
nvcc --version
nsys --version
ncu --version
compute-sanitizer --version
```

Record the selected GPU UUID, not just ordinal `0`. `CUDA_VISIBLE_DEVICES` can change ordinal mappings. Record container image/version, CPU affinity, scheduler allocation, compiler flags, CUDA library versions, and whether other jobs share the GPU.

A lightweight telemetry sample is useful:

```bash
nvidia-smi \
  --query-gpu=timestamp,uuid,name,pstate,temperature.gpu,power.draw,clocks.sm,clocks.mem,utilization.gpu,memory.used \
  --format=csv --loop=1
```

Stop it after the experiment. Field availability varies; use `nvidia-smi --help-query-gpu`. Utilization is a sampled activity measure, not a hardware efficiency score. Frequent monitoring can itself perturb short or shared experiments. [NVIDIA SMI][smi]

### Build optimized code with attribution

For a single-file experiment on the server's GPU:

```bash
nvcc -O3 -lineinfo -arch=native \
  -Xcompiler=-g,-fno-omit-frame-pointer \
  -Xptxas=-v \
  -o app experiment.cu
```

Use `-arch=native` only if the installed compiler supports it and the build host exposes the intended GPU. For deployable builds, explicitly select supported architectures and appropriate PTX fallback. Preserve your existing numerical flags; do not silently add fast math.

`-lineinfo` supports source attribution without requesting a device debug build. `-G` requests device debugging and changes optimization behavior; it is unsuitable as the default performance build. Host debug symbols are compatible with optimized host code. Compiler support and the exact generated architecture must be checked in the installed NVCC documentation. [NVCC][nvcc]

For a CMake project, use a separate release/profile build directory, enable exported compile commands, and inspect the actual compile and link commands. `RelWithDebInfo` is convenient, but the name alone does not prove your CUDA targets receive the intended flags. Preserve representative optimization, link-time optimization, and library settings.

Use `-Xptxas=-v` output to record registers, shared memory, stack frame, and spill load/store bytes. These are compiler resource diagnostics, not dynamic traffic measurements.

### Hardware-counter access

If `ncu` reports `ERR_NVGPUCTRPERM`, the device can execute CUDA while performance-counter access is restricted. Check the documented host-driver policy with the server administrator. In containers, guest root alone does not establish that the host exposes the required profiling privileges. Request the minimum approved access rather than making blanket privilege changes. [NVIDIA counter permissions][counter-permissions]

`nsys` CPU sampling and `perf` have separate Linux permissions. Check `nsys status --environment` and your kernel's perf policy. If hardware counters are unavailable, continue with timings, CUDA trace, geometry, operation counts, compiler reports, and algorithmic analysis; label counter-dependent conclusions as unverified.

## 7. Instrument meaningful work

Use stable, hierarchical NVTX names for application phases, such as:

```text
step
  prepare_inputs
  solve
    build_active_work
    apply_operator
    precondition
    reduce
    update
  publish_results
```

The indentation above describes naming hierarchy, not a required execution order. In code, use scoped ranges:

```cpp
#include <nvtx3/nvtx3.hpp>

void submit_step(cudaStream_t stream) {
    nvtx3::scoped_range step_range{"step"};
    prepare_inputs();
    {
        nvtx3::scoped_range solve_range{"solve"};
        enqueue_solver(stream);
    }
    enqueue_output(stream);
}
```

The NVTX v3 headers are header-only; Linux builds commonly need the dynamic-loader library, for example `-ldl`, depending on integration. Prefer its documented CMake target when vendoring NVTX. Use named domains, categories, payloads, and resource names when useful. Avoid formatting millions of dynamic strings. [NVTX][nvtx]

**An NVTX range around enqueue calls measures a host range.** Closing it does not wait for GPU completion. GPU projection associates launched operations with the range; do not insert synchronizations solely to make the range look like GPU elapsed time.

Add an optional controlled capture window after warmup:

```cpp
#include <cuda_profiler_api.h>

// Initialization and warmup have completed. This is a controlled experiment.
CUDA_CHECK(cudaDeviceSynchronize());
CUDA_CHECK(cudaProfilerStart());
for (int i = 0; i < measured_steps; ++i) {
    submit_step(stream);
}
CUDA_CHECK(cudaDeviceSynchronize());
CUDA_CHECK(cudaProfilerStop());
```

The boundary synchronizations intentionally isolate the experiment. They are not instructions to synchronize inside every phase. In a continuously pipelined application, a separate capture mode can isolate a window while the normal benchmark retains actual pipeline behavior.

Capture it with:

```bash
nsys profile \
  --trace=cuda,nvtx,osrt \
  --sample=none --cpuctxsw=none \
  --capture-range=cudaProfilerApi --capture-range-end=stop \
  --output=profiles/steady-01 \
  ./app --scenario typical --warmup 200 --steps 200 --seed 42
```

For `ncu`, use `--profile-from-start off` to honor the enabled region, then combine with a kernel or NVTX filter. A no-match report often means the range was never reached or the selected launch occurred outside it. [Nsight Systems user guide][nsys-user]

Add **work counters** alongside time ranges: input size, active elements, accepted work, edge visits, iterations, queue occupancy, allocations, transferred bytes, and early-exit reasons. These explain why a frame is slow in ways hardware counters cannot.

## 8. Establish correctness

An optimization that occasionally corrupts state is not a performance improvement. Start with small deterministic cases and preserve a trusted reference or independently validated oracle.

```cpp
#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

#define CUDA_CHECK(call) do {                                      \
    cudaError_t status_ = (call);                                  \
    if (status_ != cudaSuccess) {                                  \
        std::fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__,     \
                     cudaGetErrorString(status_));                \
        std::exit(EXIT_FAILURE);                                  \
    }                                                             \
} while (0)
```

After a kernel launch, check `cudaGetLastError()` for launch errors. Check the return from an appropriate later synchronization or completion operation for asynchronous execution errors. Error handling must not disappear from release builds just because an `assert` would be compiled out.

```bash
compute-sanitizer --tool memcheck --leak-check full --error-exitcode 99 \
  ./app --scenario small --steps 20 --seed 42

compute-sanitizer --tool racecheck --error-exitcode 99 \
  ./app --scenario small --steps 20 --seed 42

compute-sanitizer --tool initcheck --error-exitcode 99 \
  ./app --scenario small --steps 20 --seed 42

compute-sanitizer --tool synccheck --error-exitcode 99 \
  ./app --scenario small --steps 20 --seed 42
```

Run memory checking first. Racecheck focuses on supported shared-memory hazards; it is not a universal global-memory race detector. Initcheck and synccheck have distinct scopes. A clean run is evidence about the paths exercised, not proof of all possible executions. Some recent instrumentation features require newer toolchains. [Compute Sanitizer][sanitizer]

Cover empty inputs, one item, partial warps, partial blocks, maximum index values, capacity exhaustion, changes in topology, disconnected components, and nonuniform iteration counts. These are common failure surfaces for optimized kernels.

For CPU code, use appropriate host sanitizers in a separate correctness configuration where supported by the host toolchain and CUDA integration. Check thread ownership, buffer lifetime, and asynchronous completion explicitly. A CPU sanitizer does not understand all device-side accesses.

`CUDA_LAUNCH_BLOCKING=1` can help localize asynchronous errors during debugging. Remove it for performance measurement: it changes execution behavior.

## 9. Nsight Systems from the terminal

### Collect narrowly and escalate deliberately

Begin with the trace recipe in section 7. Enable CPU sampling only when the trace raises a host-side question:

```bash
nsys profile \
  --trace=cuda,nvtx,osrt \
  --sample=process-tree --backtrace=dwarf \
  --capture-range=cudaProfilerApi --capture-range-end=stop \
  --output=profiles/cpu-focus-01 \
  ./app --scenario typical --warmup 200 --steps 200 --seed 42
```

Choose `--backtrace=fp` when frame pointers are present and appropriate. DWARF unwinding can cost more. Check supported values on your platform. If you use `--duration`, explicitly check process termination behavior; a time-limited collection is not automatically a harmless detach. The documented `--kill=none` option can preserve a launched application when that is intended. [Nsight Systems user guide][nsys-user]

Do not record hours of detailed trace just because the process is long-lived. Capture short representative normal and slow windows. Preserve the input and logical step identifier that reproduce each window.

### The reports to learn first

```bash
nsys stats --help-reports
nsys stats --help-reports cuda_kern_exec_trace
```

| Report | Use it to ask |
|---|---|
| `cuda_api_sum` | Which host CUDA calls consume time, and how often? |
| `cuda_gpu_kern_sum` | Which kernel families account for summed device duration? |
| `cuda_gpu_kern_gb_sum` | Does cost vary with grid/block configuration? |
| `cuda_gpu_mem_time_sum` | How much transfer/memory-operation duration appears? |
| `cuda_gpu_mem_size_sum` | Are transfers too numerous or unnecessarily large? |
| `cuda_kern_exec_sum` | What are API, queue, and execution distributions? |
| `cuda_kern_exec_trace` | What happened to a particular launch? |
| `cuda_gpu_trace` | What was the device operation sequence? |
| `nvtx_sum` | Which named host phases are expensive? |
| `nvtx_gpu_proj_sum` | What GPU span corresponds to work submitted in each range? |
| `nvtx_gpu_proj_trace` | Which named instance corresponds to a slow span? |
| `osrt_sum` | Which traced OS runtime calls spend time waiting or working? |

Report availability depends on the installed version and collected data. Ask for one report at a time when diagnosing a missing-data message.

For machine-readable exports, let `nsys` create the files rather than assuming redirected console output contains only CSV:

```bash
nsys stats \
  --report=cuda_gpu_trace,cuda_kern_exec_trace,nvtx_gpu_proj_trace \
  --format=csv --output=profiles/steady-export \
  profiles/steady-01.nsys-rep
```

The resulting filenames include the report name, such as `steady-export_cuda_gpu_trace.csv`. Retain headers and units. Ordinary `cut -d,` and `awk -F,` do not correctly parse quoted kernel names containing commas; use a CSV parser.

### Interpret API and queue time causally

A long `cudaStreamSynchronize` may be waiting for necessary GPU work. Removing that wait without changing the dependency can produce wrong answers. A long launch call can involve runtime/driver work, locking, or queue pressure. A large queue delay can mean useful work was submitted ahead of a busy GPU. Inspect correlated timestamps and the preceding work before calling any of these “overhead.” [Overhead and latency in Nsight Systems][nsys-latency]

A good investigation identifies a chain such as:

> Input preparation finishes late → launch arrives after the GPU becomes idle → the solver begins late → output misses its deadline.

That supports optimizing preparation or moving its dependency boundary. A table showing that a kernel has a large average duration does not establish the same explanation.

## 10. Read timelines without a GUI

### Export SQLite and inspect its schema

```bash
nsys export --type=sqlite \
  --output=profiles/steady-01.sqlite \
  profiles/steady-01.nsys-rep

sqlite3 profiles/steady-01.sqlite '.tables'
sqlite3 profiles/steady-01.sqlite '.schema CUPTI_ACTIVITY_KIND_KERNEL'
sqlite3 profiles/steady-01.sqlite '.schema CUPTI_ACTIVITY_KIND_RUNTIME'
```

Treat the schema as versioned. Do not paste an old query and interpret an empty result as zero work. A table can be absent because that activity was not collected. The shipped report scripts are useful examples for decoding names and correlating activity. [Nsight Systems post-collection analysis][nsys-analysis]

For a standard kernel table with these verified columns:

```sql
SELECT start, end, deviceId, streamId, correlationId
FROM CUPTI_ACTIVITY_KIND_KERNEL
ORDER BY start
LIMIT 30;
```

Joining GPU operations to runtime calls generally requires correlation information **plus the appropriate process/context scope**. Correlation IDs alone are not universal identifiers across all processes. Use the shipped launch trace report before writing that join yourself.

### Use interval unions, not summed durations

Suppose one kernel runs from 0–6 ms and another from 4–9 ms. Their duration sum is 11 ms; their union covers 9 ms. Adding copies that overlap them can increase the sum again without increasing elapsed time.

For a chosen measurement window of duration `W`, compute:

- `sum_kernel_duration`: useful for an aggregate work inventory.
- `union_kernel_duration`: time covered by at least one traced kernel.
- `union_gpu_activity_duration`: time covered by any included kernel/copy/memset.
- `uncovered_duration = W - union_gpu_activity_duration`.

The last value means **no included traced activity covers that interval**. It does not prove the physical GPU is idle: another process, uncollected graphics work, graph-level collection, missing records, or unsupported activity may exist. Nor does kernel coverage measure SM occupancy.

The companion `trace_intervals.py` calculates these quantities for a selected device, optional process, and explicit nanosecond window. It also lists the largest uncovered intervals. It refuses unsupported kernel schemas and reports which activity tables were included. Use it as a lead generator, then explain gaps with CPU and dependency records.

```bash
python3 cuda-performance-toolkit/trace_intervals.py \
  profiles/steady-01.sqlite \
  --device 0 --start-ns 1000000000 --end-ns 1016666667
```

Replace those timestamps with actual boundaries from the same exported report. Nsight timestamps are not interchangeable with arbitrary `steady_clock` values or Unix epoch timestamps.

### Preserve phase and tail information

A global average can conceal one expensive input or final island. Export per-invocation traces, join them to application step IDs, and sort by completion duration. Compare normal versus slow cases by counts, geometry, degree/size bins, iterations, and transfer behavior.

An NVTX GPU projection spans the first to last associated operation; it can include gaps. Nested projected ranges may overlap, so summing parent and child projections double-counts work. Use a consistent non-overlapping phase partition for an accounting table.

For CUDA Graphs, capture node granularity when you need kernel details and graph granularity when you need lower trace volume or graph-level behavior. The `--cuda-graph-trace` syntax and choices are version-dependent. A graph-level trace may not contain the ordinary kernel records expected by a custom SQLite script; missing kernel rows then do not mean no computation occurred.

## 11. Profile and optimize the CPU

CPU overhead matters when it delays the critical path, even if it is a small fraction of all host-thread time. A single dispatch thread can starve a GPU while other CPU cores are idle.

Start with an unprofiled run and compare against a CPU-profiled run:

```bash
perf stat -r 5 \
  -e task-clock,cycles,instructions,branches,branch-misses,cache-misses,context-switches,cpu-migrations,page-faults \
  -- ./app --scenario typical --warmup 200 --steps 2000 --seed 42
```

`perf stat` counts events and repeats the process with `-r`. Interpret events using your CPU's PMU; generic cache-miss events are not a universal breakdown of all cache levels. Multiplexed counters are scaled estimates, and unavailable events must not silently become zeros in a dashboard. [perf stat manual][perf-stat]

Find hot host call stacks:

```bash
perf record -F 199 -g --call-graph dwarf -o profiles/cpu.data \
  -- ./app --scenario typical --warmup 200 --steps 500 --seed 42

perf report --stdio --no-children -i profiles/cpu.data
perf report --stdio -i profiles/cpu.data
```

The first report emphasizes self cost; the second helps inspect accumulated call chains. Sampling frequency is an experiment choice. DWARF unwinding uses stack samples and may need more buffer space for deep stacks. Frame-pointer unwinding is an alternative when the binary supports it. [perf record][perf-record], [perf report][perf-report]

Inspect selected functions with:

```bash
perf annotate --stdio -i profiles/cpu.data
```

Use the installed help to select a symbol and display options. Optimized source lines may correspond to multiple instructions or inlined call sites. [perf annotate][perf-annotate]

Review these host mechanisms in order of measured importance:

| Evidence | Candidate experiment |
|---|---|
| CPU preparation delays every launch batch | Reuse/precompute metadata; parallelize independent preparation |
| Frequent allocations on the critical thread | Preallocate capacity; reuse scratch; remove hidden temporary containers |
| Lock contention in submission or queues | Assign clear ownership; batch operations; reduce shared mutable state |
| Excessive threads and scheduling | Bound thread pools; control library worker counts; measure affinity |
| Pointer-heavy traversals | Flatten hot data; process contiguous batches; improve locality |
| Logging or file I/O in slow frames | Buffer or move work off the critical path with bounded queues |
| NUMA-remote preparation/copies | Bind compatible CPU threads and memory placement after inspecting topology |
| Busy polling consumes a core | Tune completion notification/polling against response-latency needs |

Do not assume low IPC is itself a bug, or that a blocked thread needs faster arithmetic. Use off-CPU scheduling evidence to distinguish waiting from executing. Likewise, reducing CPU utilization can be harmful if it makes the dispatch thread slower.

If a GPU-resident algorithm needs a CPU decision each iteration, examine whether that decision can remain on the device, occur less often, or be batched. Include the cost of maintaining a second copy of metadata before declaring a CPU/GPU split efficient.

## 12. Nsight Compute collection recipes

Use `ncu` after identifying a workload worth improving. Preserve the original `.ncu-rep`; exports are views of that evidence and cannot reconstruct uncollected metrics.

### Discover before collecting

```bash
ncu --help > profiles/ncu-help.txt
ncu --list-sets > profiles/ncu-sets.txt
ncu --list-sections > profiles/ncu-sections.txt
ncu --list-rules > profiles/ncu-rules.txt
ncu --query-metrics --query-metrics-mode all > profiles/ncu-metrics.txt

rg 'dram__bytes|warps_eligible|issue_active|long_scoreboard' \
  profiles/ncu-metrics.txt
```

To inspect suffixes for particular metric families:

```bash
ncu --query-metrics --query-metrics-mode suffix \
  --metrics sm__throughput,dram__bytes
```

Discovery uses the available device unless you select another supported device/chip. Section names, metric availability, and suffixes vary. A missing metric is **unknown**, not zero.

### Select a logical phase

For the scoped `solve` push/pop range from section 7:

```bash
ncu \
  --profile-from-start off \
  --nvtx --nvtx-include 'solve/' \
  --kernel-name-base function \
  --kernel-name 'regex:apply_operator' \
  --launch-count 1 \
  --set basic \
  --export profiles/operator-basic \
  ./app --scenario typical --warmup 200 --steps 50 --seed 42
```

The trailing `/` denotes a push/pop range. A start/end range uses different filter syntax. For an NVTX domain, a configuration can look like `solver@solve/`. Do not mix up the NVTX filter syntaxes of different tools. Ranges on one host thread do not automatically annotate submissions from another thread. [NVTX documentation][nvtx], [Nsight Compute CLI][ncu-cli]

If the executable launches the actual CUDA worker as a child process, consider `--target-processes all`. Verify which process owns the selected kernels before increasing launch limits.

### Escalate by the question

Reuse the same verified filter and workload arguments for each recipe:

| Question | Sections worth collecting, when available |
|---|---|
| Is the launch large enough and what limits residency? | `LaunchStats`, `Occupancy`, `SpeedOfLight` |
| Is memory traffic inefficient? | `MemoryWorkloadAnalysis`, `MemoryWorkloadAnalysis_Tables` |
| Are schedulers starved? | `SchedulerStats`, `WarpStateStats` |
| Which instructions and lines contribute? | `InstructionStats`, `SourceCounters` |
| Is there unequal work across hardware units? | `WorkloadDistribution` |
| How does behavior change within a long workload? | `PmSampling` and supported timeline sections |
| Is arithmetic intensity a likely limit? | Available roofline sections |

For a targeted deeper investigation:

```bash
ncu \
  --kernel-name-base function --kernel-name 'regex:apply_operator' \
  --launch-skip 20 --launch-count 1 \
  --section SpeedOfLight --section LaunchStats --section Occupancy \
  --section MemoryWorkloadAnalysis --section MemoryWorkloadAnalysis_Tables \
  --section SchedulerStats --section WarpStateStats \
  --section SourceCounters \
  --import-source on \
  --export profiles/operator-deep \
  ./app --scenario typical --warmup 200 --steps 50 --seed 42
```

Use `--set full` for a **narrowly selected workload** when comprehensive diagnosis is justified. Avoid making it the default across thousands of launches: more counters can require more replay, memory backup, patching, and report processing.

### Export readable text, raw CSV, and source/SASS

```bash
ncu --import profiles/operator-deep.ncu-rep \
  --page details --print-details all --print-metric-name name \
  > profiles/operator-details.txt

ncu --import profiles/operator-deep.ncu-rep \
  --page raw --csv --print-units base \
  > profiles/operator-raw.csv

ncu --import profiles/operator-deep.ncu-rep \
  --page source --print-source cuda,sass \
  > profiles/operator-source.txt
```

`--print-details all` is the current replacement for the older `--details-all`. Inspect the exported source for actual correlation; source files must have been imported or be resolvable locally. Supply collection-time source paths with `--source-folders` when needed.

The `.ncu-rep` can contain multiple actions, configurations, contexts, and devices. Match the logical workload before comparing rows. Exporting one selected action can simplify investigation; keep the original unfiltered report.

For a minimal numeric capture, first confirm every requested full metric name exists:

```bash
ncu \
  --kernel-name 'regex:apply_operator' --launch-count 1 \
  --metrics gpu__time_duration.sum,dram__bytes_read.sum,dram__bytes_write.sum \
  --export profiles/operator-bytes \
  ./app --scenario typical --warmup 200 --steps 50 --seed 42
```

Use collection parameters as a recipe template, not as proof that the first matching invocation is representative.

## 13. Replay, clocks, caches, and trustworthy counters

Nsight Compute may re-execute selected work, serialize launches, change clocks, flush caches, or patch instructions to collect requested data. These controls explain why its workload timing can differ from a normal run. Use a focused counter capture to diagnose a mechanism, and normal timing to validate the application's result. [Nsight Compute profiling guide][ncu-profiling]

### Choose replay deliberately

| Mode | Suitable question | Main constraint to check |
|---|---|---|
| `kernel` | What limits an isolated kernel? | Replays can change cache/concurrency context; backup overhead can be large |
| `application` | Does the same kernel depend on naturally produced state/cache history? | Whole application must reproduce matchable work each pass |
| `range` | What limits a cooperating range of kernels? | API capture support and memory-lifetime restrictions |
| `app-range` | What limits a range that is easier to recreate by rerunning? | Repeatable application execution; range-level attribution |

A range aggregates evidence across its operations. It is not an individual-kernel report with concurrency magically preserved. Kernel-level application replay is also not equivalent to range profiling: rerunning the application alone does not remove all serialization effects.

When a kernel depends on a concurrently running peer or on host interaction, default replay can prevent progress. Select a supported range/application mode or build a finite reproducible harness; do not “fix” the algorithm based on a profiler-induced hang.

### Use two explicit measurement intentions

**Controlled kernel comparison:** keep replay, clocks, cache control, and target invocation identical. A cold-cache capture can be valuable when both versions face the same condition, even if it is not the application's normal cache state.

**Application-context investigation:** recreate the preceding workload with suitable application or range replay, preserve relevant cache history, and check against `nsys` and unprofiled completion time. A useful conditional recipe is:

```bash
ncu \
  --replay-mode application \
  --clock-control none --cache-control none \
  --kernel-name 'regex:apply_operator' \
  --launch-skip 20 --launch-count 1 \
  --section SpeedOfLight --section MemoryWorkloadAnalysis \
  --export profiles/operator-context \
  ./app --scenario typical --warmup 200 --steps 50 --seed 42
```

This requires repeatable execution and is not a claim of zero profiler perturbation. Simply using `--cache-control none` with multi-pass kernel replay can warm later passes artificially and produce inconsistent derived ratios.

For a bounded NVTX range with compatible APIs:

```bash
ncu \
  --replay-mode range \
  --nvtx --nvtx-include 'solve/' \
  --launch-count 1 \
  --section SpeedOfLight \
  --export profiles/solve-range \
  ./app --scenario typical --warmup 200 --steps 50 --seed 42
```

Inspect the workload type and report scope. Allocation, host-memory mutation, and unsupported API activity can invalidate capture assumptions. The exact compatibility matrix is version-specific.

### Do not rely on remembered defaults

The current documentation lists `boost` as the clock-control default; older releases used different behavior. `boost` may fall back when unsupported. Thermal or power limits can still override requested behavior. Record both the requested policy and observed clocks. [Nsight Compute release information][ncu-release]

When counters disagree with expectations, check these before editing code:

1. Same binary, input state, launch, dimensions, precision, and tolerance?
2. Same clock, cache, replay, and metric settings?
3. Long enough and stable enough workload for these measurements?
4. Any profiler warnings, missing data, unsupported features, or other GPU users?
5. Matching units, normalization, clock domains, and aggregation scopes?
6. Did later passes process equivalent work?

Small excursions above a nominal peak can occur in derived metrics. Large contradictions call for investigation. Never clamp suspicious values into a dashboard and silently treat them as trustworthy.

## 14. Interpret hardware metrics

### Read the name as part of the measurement

A typical metric such as `sm__throughput.avg.pct_of_peak_sustained_elapsed` encodes a hardware unit, quantity, aggregation, and normalization. Do not drop the suffix in your stored data. `sum`, `avg`, `min`, and `max` may aggregate across hardware instances rather than across repeated application invocations.

An `active` denominator asks about cycles when the unit was active; an `elapsed` denominator includes the entire observation interval. A busy subset of the chip and a fully used chip can look different depending on the denominator. Prefer coherent built-in breakdowns over ratios assembled from unrelated units. [Metric structure and interpretation][ncu-profiling]

### Keep an absolute-work ledger

For each representative kernel or range, track:

| Quantity | Why it matters |
|---|---|
| Duration | Actual time in the chosen observation scope |
| Input and accepted-work counts | Whether the two versions did comparable work |
| Grid, block, shared memory, registers | What execution configuration changed |
| DRAM bytes read/written | Off-chip traffic actually observed |
| Cache-level traffic and requests | Where work is generated and served |
| Instruction mix | Whether arithmetic, indexing, or data movement dominates |
| Eligible/issued warp evidence | Whether resident work can advance |
| Iterations and convergence result | Whether kernel savings changed algorithmic work |

A high-level compute or memory throughput percentage is a classifier. Expand its constituents to identify the busy resource. Low DRAM throughput does not exclude a bottleneck in L1TEX, L2, load/store issue, atomics, or latency hiding.

### Separate four different “efficiencies”

- **Coverage:** was some kernel active during the window?
- **Residency:** how many warps could remain on the SM?
- **Issue efficiency:** how often did the scheduler dispatch useful instructions?
- **Algorithmic efficiency:** how much of all executed work was necessary to obtain the result?

A persistent kernel can have nearly continuous coverage while most lanes wait. A redundant full-world scan can achieve high bandwidth while doing unnecessary work. A smaller active queue can lower apparent GPU utilization and improve the application substantially.

### Warp stall evidence is diagnostic, not a score

| Observation | Possible mechanism | Evidence needed before acting |
|---|---|---|
| `long_scoreboard` | Waiting for global/local/texture-path data | Consumer/producer instructions, memory traffic, cache and issue evidence |
| `short_scoreboard` | Shorter-latency dependencies, often involving shared-memory/MIO paths | Instruction context, bank conflicts, dependency chain |
| `barrier` | Warps reach a synchronization point at different times | Per-warp work balance and barrier placement |
| `mio_throttle` | Pressure on relevant memory/intermediate-operation queues | Shared-memory/instruction mix and request generation |
| `lg_throttle` | Pressure in the local/global instruction queue | Access width, instruction count, local-memory traffic |
| `math_pipe_throttle` | Demand exceeds a particular arithmetic pipeline's capacity | Actual instruction mix and busy-pipeline breakdown |
| `wait` | Fixed-latency execution dependencies | Dependency chain and independent work available |
| `not_selected` | A ready warp was not chosen this cycle | Often normal competition; not inherently a defect |
| `no_instruction` | Instruction fetch/availability effects or boundary behavior | Code footprint, duration, and source context |

Use the definitions shipped with your architecture/tool. Stall samples commonly identify the **consumer waiting for a result**, not the load or arithmetic producer responsible for the delay. Inspect both.

Do not rank “top stall percentage” above workload duration, issue behavior, and absolute sample contribution. After an optimization removes one type of work, another category's percentage can rise without becoming slower.

## 15. Diagnose kernels systematically

NVIDIA's current Compute Triage Guide starts with measurement validity and insufficient parallel work before descending into throughput, memory, scheduling, and source-level causes. Use that ordering; numerical thresholds in diagnostic rules are heuristics, not universal acceptance criteria. [Compute Triage Guide][ncu-triage]

### Decision A: is there enough independent work?

Inspect grid size, useful blocks, residency limits, and the distribution of work per block. If one block processes a long loop over independent objects, parallelize the outer dimension before tuning cache hints. If only a few useful items exist, batching unrelated independent work may help; expanding dummy work to improve utilization does not.

### Decision B: is execution waiting or saturating a resource?

- If a specific memory tier is near its effective ceiling, reduce traffic or improve reuse at that tier.
- If an arithmetic/instruction pipeline is saturated, reduce its work or use a different valid implementation path.
- If utilization is low, inspect size, eligibility, dependencies, synchronization, and tails.
- If several phases have different limits, inspect them separately before choosing fusion or splitting.

### Decision C: which exact mechanism generates the cost?

Examples of discriminating questions:

- Do extra sectors come from misalignment, stride, sparse gathers, or more valid data per lane?
- Are local-memory accesses compiler spills or intentionally addressed thread-private arrays?
- Are barriers expensive because they are unnecessary or because one warp has much more work?
- Is “compute-heavy” actually integer indexing, FP64 promotion, transcendental arithmetic, or useful FP32 work?
- Is low occupancy a resource limit, small grid, or the final tail?

### Decision D: what should the experiment change?

| Hypothesis | Change one variable | Predicted evidence |
|---|---|---|
| Independent outer work is serialized | Map outer items to blocks | More useful blocks, shorter duration |
| Hot AoS field loads waste sectors | Try SoA/AoSoA layout | Fewer sectors for equal useful work |
| Long dependency chain limits issue | Try independent accumulators | More eligible work, possibly more registers |
| A few large rows dominate | Bin or split large rows | Shorter tail; account for dispatch/reduction cost |
| Global atomics contend | Aggregate locally | Fewer contended updates; added local work |
| Full scans dominate sparse inputs | Queue changed items | Fewer visits; account for queue upkeep |
| Solver performs too many sweeps | Improve preconditioning | Fewer iterations; include setup/application cost |

A useful experiment can fail. Preserve negative results with the input distribution and evidence; otherwise the same attractive but ineffective optimization gets retried repeatedly.

## 16. Expose parallelism and balance work

### Audit every loop by dependency

Classify loops as independent across objects, reductions/scans, local recurrences, graph traversals, or global iterative dependencies. Each category needs a different transformation.

| CPU-shaped pattern | GPU candidate | Cost or correctness question |
|---|---|---|
| One thread loops over many independent objects | Thread/warp/block per object | Enough useful work per assignment? |
| One launch per tiny object | Batched launch over objects | Can objects share a representation? |
| Serial sum | Hierarchical reduction | Floating-point order and scratch storage? |
| Serial append/filter | Flags plus scan/compaction, or aggregated queues | Stable ordering needed? |
| Pointer-linked work list | Flat arrays/frontiers | Construction and update cost? |
| Serial graph walk | Parallel frontier traversal | Duplicates, visited state, and frontier sparsity? |
| Strict in-place sweep | Coloring, block method, or alternative iteration | Does convergence or mathematical meaning change? |

CUB/Thrust provide reference building blocks for reductions, scans, sorting, and selection, with block/warp/device scopes. Compare against them before maintaining a custom general primitive. Reuse required temporary storage and specify execution/stream behavior deliberately. [NVIDIA CCCL][cccl]

### Choose the assignment based on the work distribution

**Thread per item** works well for many short, relatively uniform items. **Warp per item** can help cooperative reductions or medium rows. **Block per item** can retain local state and perform repeated cooperation. **Several blocks per item** expose large-item parallelism but introduce inter-block coordination and intermediate storage.

Do not select one mapping for every size just to simplify the implementation. Record a histogram of sizes, degrees, iterations, and bytes per item. Benchmark a small number of dispatch bins against a single general path.

For a sparse row with four neighbors, dedicating 32 lanes to neighbors alone can leave most lanes unused. Packing several rows into a warp or letting one lane process a short row may win. For a row with thousands of entries, one lane can create a severe tail. These are hypotheses to test with actual structure and numerical operations.

### Quantify the tail

For each phase, record median, p95, maximum item cost, and the share of total work in the largest items. Compare “many identical components” against “one very large component plus many tiny ones.” They can have the same total nodes and radically different completion time.

Useful experiments include size binning, longest-item-first scheduling, work splitting, adaptive chunk size, and persistent work queues. Include queue contention, scratch traffic, and loss of locality in the measured cost.

Persistent scheduling is appropriate when repeated dispatch or imbalance is demonstrated. It also introduces termination detection, memory-ordering, residency, fairness, and concurrency concerns. An ordinary global spin barrier can deadlock if waiting blocks occupy resources needed by unscheduled blocks. Use a supported cooperative mechanism or separate kernel boundaries when a global barrier is necessary. [Cooperative Groups][groups]

## 17. Optimize memory access

### Start with a traffic model

For each operation, write which arrays are read/written, how many bytes per element, expected reuse, index width, and whether each load is contiguous or indirect. Then compare predicted logical traffic with observed traffic at the relevant hierarchy level.

For an FP32 AXPY-style update `y[i] = a*x[i] + y[i]` the simple logical model is 4 bytes for `x`, 4 for old `y`, and 4 for new `y`: 12 bytes per element. Real DRAM traffic can differ because of caches, transaction granularity, or additional implementation work. Keep **logical bytes**, **cache traffic**, and **DRAM bytes** as separate columns.

### Coalescing is about addresses across lanes

Neighboring lanes should ideally request neighboring useful bytes for a common instruction. For 32 active lanes, each loading one aligned contiguous 32-bit value, 128 useful bytes cover four 32-byte sectors. The corresponding ideal for 64-bit values is eight sectors; for 128-bit lane accesses, sixteen. A broadcast or partially active warp has a different expectation. Misalignment can add a sector. [Memory workload tables][ncu-profiling]

Therefore, “sectors/request > 4 means uncoalesced” is only a conditional shortcut for a particular access pattern. Inspect access width, active lanes, addresses, instruction decomposition, and cache level before applying it.

A useful approximate efficiency for distinct useful bytes is:

`useful distinct bytes / (sectors touched × 32)`.

Do not count the same broadcast bytes 32 times and call that transaction inefficiency. Also distinguish requested sectors from misses that travel further down the hierarchy.

### AoS, SoA, and AoSoA

Suppose every lane accesses only `position.x` from a large structure. An array of structures can space those loads by the structure stride. A structure of arrays places the hot field contiguously. An array of small structure-of-array tiles can balance field locality with grouping.

The best layout depends on all hot phases. Moving to SoA can make one kernel faster and make another gather many separate fields. Evaluate total phase cost and conversion/maintenance costs. For frequently accessed metadata, split hot fields from cold descriptive fields instead of hauling the full object through the kernel.

Use smaller index types only when all sizes and offsets are proven to fit. Compute allocation byte sizes and potentially large products in a sufficiently wide type. Integer overflow is not a legitimate bandwidth optimization.

### Sparse gathers and reordering

Contiguous adjacency entries do not guarantee contiguous endpoint-state loads. In a graph kernel, separately measure the adjacency stream, endpoint gathers, per-node state, and output writes.

Potential experiments:

- Reorder nodes to place commonly interacting data nearby.
- Group edges by owner or destination.
- Retain component-local state in a compact contiguous region.
- Duplicate a small read-only field if saved gathers outweigh update/storage costs.
- Use block-sparse structure when physical degrees of freedom naturally form dense blocks.

Record permutation build cost, update cost, extra memory, and whether reproducibility/order-sensitive behavior changes. Do not rebuild a global ordering each frame unless its measured benefit pays for that rebuild.

### Shared memory is a managed cache, not a universal speed switch

Stage data when several threads reuse it, when it enables a better access pattern, or when it supports a necessary collective operation. Compare bytes saved against load/store instructions, barriers, capacity, and occupancy effects. Staging single-use data can add cost.

Shared-memory bank conflicts depend on addresses, width, and instruction form. The classic padded tile—such as an extra column for a transposed access—can fix a particular stride conflict. It does not prove every multidimensional array needs padding. Measure conflicts on the actual accesses. [CUDA memory basics][memory]

### Local memory and registers

“Local” refers to per-thread address space, not guaranteed on-chip storage. Local accesses may result from spilling or thread-private arrays that cannot be held in registers. Diagnose with compiler output, local load/store traffic, and SASS. A dynamically indexed array can use local memory without a compiler report saying it spilled registers.

Reduce live ranges, unnecessary temporaries, oversized per-thread arrays, or excessive unrolling when they cause material local traffic. Do not arbitrarily cap registers and assume spills will disappear.

### Advanced data movement

Asynchronous global-to-shared copies and pipelines can overlap staging with computation and change register pressure. They require correct completion waits, aligned/supported transfers, sufficient work to overlap, and suitable hardware. Double buffering increases storage; triple buffering is not automatically better. Inspect generated instructions and measure the entire loop. [Asynchronous copies][async-copy], [CUDA pipelines][pipeline]

L2 persistence/access-policy hints can help a reusable working set when supported. They consume a shared resource and can hurt competing streams if overcommitted. Test them after establishing reuse and working-set size, not as a default switch. [L2 cache control][l2-cache]

Unified Memory simplifies addressing, but migration, page faults, ownership changes, and oversubscription can affect real-time tails. Inspect actual residency and transfers. Prefetch/advice can help predictable ownership; explicit device allocation is a useful comparison baseline. Integrated/coherent systems differ from discrete PCIe systems, so do not generalize transfer advice across them. [Unified Memory][um]

## 18. Occupancy, registers, and latency hiding

Occupancy is constrained by threads/warps, blocks, registers, shared memory, and other architecture-specific resources. Allocation is granular, so a small resource change can cross a residency threshold. Use CUDA occupancy APIs or the Nsight occupancy calculator instead of assuming a simple continuous formula. [Advanced kernel programming][advanced-kernel], [occupancy calculator interface][ncu-occupancy]

For an ordinary fixed-resource kernel, a planning estimate is:

`concurrent_blocks ≈ SM_count × resident_blocks_per_SM`.

Then compare grid size with that capacity. This is a planning approximation; clusters, heterogeneous work, tails, and scheduling details need separate treatment.

### Distinguish three problems

1. **Insufficient grid:** not enough blocks exist.
2. **Low resident capacity:** each block consumes too many constrained resources.
3. **Low eligibility:** many resident warps exist but cannot issue useful work.

Increasing block size addresses none of these automatically. A larger block can reduce resident block count or amplify a tail. A smaller block can increase scheduling overhead or lose cooperative reuse.

Sweep a modest set of legal sizes—often 64, 128, 256, and 512 for ordinary kernels—while preserving the algorithm. These are candidate experiments, not recommended universal settings. Record duration, registers, shared memory, achieved occupancy, and spills. Include small and large inputs.

### More independent work per thread can help

If each operation depends on the previous one, a single accumulator can form a long chain. Several independent accumulators or overlapped loads can expose instruction-level parallelism. The tradeoff is more registers, instruction footprint, and possibly lower residency.

A rough latency-hiding model is:

`required outstanding bytes ≈ target bandwidth × memory latency`.

This describes aggregate bytes in flight at a specified memory boundary; it is not a register-allocation formula. It helps explain why low bandwidth plus memory stalls can call for more independent requests rather than fewer arithmetic instructions.

### Tune register pressure after identifying a problem

Possible experiments include shortening variable lifetimes, splitting phases, reducing unroll factors, changing per-thread work, or using shared memory for a carefully chosen subset of state. `__launch_bounds__` and register caps constrain compiler choices; they do not promise better performance.

Accept a lower occupancy configuration if it is faster with the same workload and quality. It may have better reuse or instruction-level parallelism. Accept higher occupancy only when its extra resident work outweighs any spills or lost reuse.

## 19. Instructions, divergence, atomics, and synchronization

### Inspect the generated code

```bash
cuobjdump --dump-resource-usage ./app
cuobjdump --dump-sass ./app > profiles/app-sass.txt
cuobjdump --dump-ptx ./app > profiles/app-ptx.txt
```

`cuobjdump` extracts information from executables and device code containers. `nvdisasm` provides detailed disassembly of suitable cubins. PTX is not the final executed instruction sequence; verify SASS for the target architecture. [CUDA binary utilities][binary]

Look for unnecessary double-precision operations, repeated address calculations, integer division/modulo in hot loops, expensive transcendental functions, redundant conversions, local loads/stores, unexpected barriers, and excessive code expansion.

Hoist expressions only when their inputs really remain invariant. `__restrict__` is a non-aliasing promise: using it on overlapping data can make the program wrong. Specialized paths can simplify code, but over-specialization may increase instruction-cache pressure and binary/JIT cost.

### Branching and predication

A branch uniform across a warp can be cheap. A branch where lanes take substantial different paths may waste lane execution. Replacing branching with unconditional arithmetic can make the program slower by doing more work.

Group similar tasks, separate qualitatively different paths, or compact active work if the grouping cost pays for itself. Inspect average active/predicated-on lanes in context: partial boundaries and intentionally subwarp work are not automatically defects.

### Atomics

Contention, not merely the presence of an atomic instruction, is often the issue. Compare these designs:

| Pattern | Benefit | Added cost |
|---|---|---|
| Direct global atomic | Simple, low setup | Contention and nondeterministic accumulation order |
| Warp aggregation | Fewer global updates | Local grouping/reduction |
| Block aggregation | More reuse/aggregation | Shared memory and barriers |
| Owner-computes gather | Avoids conflicting writes | Repeated/irregular reads |
| Sort/segment/reduce | Groups updates deterministically when designed so | Sorting, scratch, extra passes |

Select the narrowest memory scope that correctly covers participants. A counter increment does not necessarily publish an associated payload safely. Work-queue producers and consumers need a valid ownership and acquire/release protocol, not just an atomic index.

### Synchronization correctness comes first

`__syncthreads()` requires the appropriate block participants to reach a valid collective point. Warp collectives require correct participation masks. Old assumptions that lanes execute in implicit lockstep are unsafe on modern independently scheduled threads. Use supported intrinsics/collectives and test partial participation. [Cooperative Groups][groups]

A memory fence establishes ordering/visibility constraints at its scope; it is not a collective rendezvous. `volatile` is not a substitute for a race-free synchronization protocol. Ordinary cross-block producer/consumer code must have both a memory-ordering proof and a progress argument. [CUDA memory model][memory-model]

If a global barrier is only needed between major phases, separate kernels in an ordered stream may be simpler and faster than a complicated persistent barrier. If launch overhead is then dominant, consider graphs or a correctly bounded cooperative approach.

## 20. Streams, transfers, allocation, fusion, and graphs

### Keep the steady-state data where it is used

For a discrete GPU, repeatedly copying large solver state to the CPU for bookkeeping can dominate an otherwise efficient computation. Prefer device-resident state, small changed-input batches, and small output summaries when that fits the application's semantics.

A reduction returning a scalar to the host may force a synchronization. cuBLAS supports device pointer mode for appropriate scalar inputs/results, allowing follow-on GPU work without an immediate host readback. Set stream, pointer mode, workspace, and math behavior explicitly in a reusable handle configuration. [cuBLAS][cublas]

### Overlap requires independence and correct lifetime

To overlap copies and computation, use supported hardware, suitable streams, and pinned host buffers where required. `cudaMemcpyAsync` in a source file does not prove overlap occurred. Dependencies, pageable memory handling, the default stream, copy-engine limits, or resource saturation can prevent it. [Asynchronous execution][async]

A correct buffered pipeline gives each in-flight batch ownership of its input/output buffers until its completion event. Reusing host input while a transfer still reads it, or freeing device scratch before a dependent kernel finishes, is a race.

Benchmark one, two, and a few in-flight batches against both throughput and response latency. More streams can increase contention and queueing. Stream priorities are scheduling hints, not a guarantee of arbitrary immediate preemption or deadline completion.

### Remove allocation and setup from hot paths

Preallocate and reuse ordinary device buffers, pinned transfer buffers, library scratch, events, and streams. Track capacity growth and define what happens on exhaustion.

`cudaMallocAsync`/`cudaFreeAsync` provide stream-ordered allocation with memory pools. Pool reuse and release thresholds affect latency and retained memory. Cross-stream use still needs explicit dependencies; switching allocators does not solve lifetime bugs. Synchronization can affect when cached pool memory is returned, so benchmark the actual synchronization pattern. [Stream-ordered allocation][pools]

### Fusion and splitting are both valid experiments

Fuse when it saves intermediate traffic, redundant loads, repeated indexing, or dispatch without adding excessive resource pressure. Split when phases have conflicting parallelism/layout needs, divergent control flow, incompatible occupancy, or unnecessary live state.

Estimate:

`fusion benefit = saved transfers + saved launches + saved recomputation - added spills - lost parallelism - added work`.

This is an accounting framework, not an additive timing identity in an overlapped pipeline. Measure the real phase after implementing the candidate.

### CUDA Graphs

Graphs encode a dependency structure that can be instantiated and repeatedly launched. They can reduce CPU submission overhead for repeated workflows. Creation, instantiation, updates, memory management, and synchronization still have costs. Capture a representative stable graph, reuse it, and verify the same data dependencies and outputs. [CUDA Graphs][graphs]

A good first graph experiment is a repeated sequence of short kernels with stable buffer ownership. Compare:

- Host time spent submitting a step.
- GPU gaps between operations.
- Complete response latency and throughput.
- Graph update/rebuild frequency.
- Device memory and output correctness.

Graphs do not automatically fuse kernels, repair a serial numerical algorithm, or make data-dependent work free. Conditional nodes and device graph launch can support more advanced control flow on supported configurations, but require a separate capability and correctness review.

For profiling, distinguish Nsight Compute's `--graph-profiling node` from `--graph-profiling graph`, and check replay compatibility. A whole-graph result has a different attribution scope from a kernel node. Validate the graph's product benefit with normal execution and a Systems capture.

## 21. Numerical algorithms and sparse solvers

For iterative numerical work, optimize **time to an acceptable solution**, including setup and recovery. A faster iteration can lose if it needs substantially more iterations.

A useful cost model is:

`T_solve = T_setup + N_iterations × T_iteration + T_validation + T_recovery`.

When iteration costs vary, replace the product with a sum. When several independent components run concurrently, the schedule and longest remaining component matter; summing component times does not give application wall time.

### Inventory the mathematics before tuning

Record unknown count, nonzeros/edges, block dimension, degree distribution, connected-component sizes, boundary conditions, symmetry, definiteness, null spaces, conditioning, and change frequency. Also record which quantities change between solves: right-hand side, coefficients, topology, constraints, or only the requested output.

This inventory guides different decisions:

| Mathematical structure | Candidate design |
|---|---|
| Many small independent systems | Batched solves; local state retained per warp/block |
| One large sparse system | Parallel operator plus scalable global solver/preconditioner |
| Repeated identical matrix, changing RHS | Reuse valid setup/factorization/preconditioner |
| Fixed topology, changing coefficients | Reuse symbolic structure; update affected numerical data |
| Matrix available as cheap local action | Compare matrix-free operator with explicit sparse storage |
| Dense blocks per node/edge | Block-sparse format or specialized local operator |
| Strong long-range coupling | Hierarchical/coarse correction, not just more local sweeps |

These are candidate directions. Numerical properties determine whether each solver is valid; profiler throughput cannot establish that validity.

### Use a mathematically compatible solver

Ordinary preconditioned CG is a natural candidate for appropriate symmetric positive-definite systems with a compatible fixed SPD preconditioner. General nonsymmetric or indefinite systems need different methods or a justified reformulation. Do not retain CG after changing the operator/preconditioner in a way that breaks its assumptions. [PETSc CG reference][petsc-cg]

A preconditioner whose action changes during an outer solve, or is nonlinear because it runs a variable inner iteration, may require a flexible method. Flexible GMRES is one reference design; it has different storage, orthogonalization, and arithmetic costs. [PETSc FGMRES reference][petsc-fgmres]

Chebyshev/polynomial methods can reduce global-reduction needs and use parallel operator applications, but need suitable spectral bounds and stability checks. A polynomial that is fast on one spectrum can be poor or unstable after material/topology changes. Compare actual convergence and total operator applications. [PETSc linear-solver manual][petsc]

### Distinguish residuals

For `Ax = b`, the true residual is `r = b - Ax`. An iterative recurrence may maintain an approximation to it; preconditioning may change the norm used for stopping. Print what is actually checked.

A practical mixed absolute/relative criterion is:

`||b - Ax|| <= atol + rtol × ||b||`.

Choose the norm and tolerances according to the numerical task. Near zero right-hand sides need an absolute term. A small residual does not by itself guarantee a small forward error in an ill-conditioned system.

For a scale-aware validation measure, consider normwise backward error:

`eta = ||b - Ax|| / (||A|| × ||x|| + ||b||)`.

Define the norm consistently and handle a zero denominator explicitly. Computing an exact matrix norm may be unnecessary for every step; a validated bound or occasional reference check can be more appropriate.

Periodically recompute the true residual, especially after mixed-precision work, long recurrences, or aggressive convergence changes. Record stagnation, breakdown, nonfinite values, and fallback counts. Do not silently stop at a fixed iteration cap and label the result converged.

### Count all work inside preconditioning

A “single iteration” might include multiple operator applications, several vector passes, one or more reductions, and local dense algebra. Instrument these separately.

For a graph solver, record:

- Live and dead adjacency references visited.
- Operator applications per accepted solve.
- Preconditioner applications and their internal sweeps.
- Dense-block applications/factorizations.
- Vector reads/writes and reduction passes.
- Components skipped, resumed, converged, failed, or rebuilt.

Suppose an alternative preconditioner doubles per-iteration cost but cuts iterations by 60%. Ignoring setup, total iteration work falls to `2 × 0.4 = 0.8` of baseline. That is a 20% reduction, not a 60% reduction. Now add setup, scratch, and the distribution of component sizes before accepting it.

### Sparse formats and library baselines

CSR is a useful general reference. BSR can amortize indices and express block structure, but padding zeros or poor block occupancy can add arithmetic. SELL-like sliced layouts and degree bins can regularize work at the cost of padding and reordering. Edge-centric application can avoid assembling a full matrix, but may introduce gather/scatter or atomic costs.

For repeated sparse operations, inspect cuSPARSE algorithm choices, workspace requirements, preprocessing, supported formats, and determinism guarantees for the **specific routine and algorithm**. Library calls are useful performance baselines, not automatically optimal for tiny custom blocks or highly specialized matrix-free operations. [cuSPARSE][cusparse]

### Reuse safely

Treat cached setup as a versioned dependency graph. For each cached object, list the input versions that determine it:

| Cached item | Examples of invalidators |
|---|---|
| Adjacency/index layout | Topology or reordering |
| Local block factor/inverse | Coefficients, constraints, local topology |
| Coarse hierarchy | Coupling structure or invalidated strength model |
| Warm-start vector | Remapping, changed constraints, incompatible state |
| Previously accepted solution | RHS, operator, boundary data, acceptance rule |

Warm starts are guesses to validate. Exact solution reuse requires proving the result remains valid, or checking a valid certificate. Reusing an old preconditioner can remain numerically useful after an operator change, but “still valid to apply” and “still effective enough” are different questions.

For tiny fixed-size blocks, compare factor-and-solve with cached inverse application. An inverse can make repeated application regular and cheap, but construction cost, conditioning, symmetry, and storage matter. Do not form a general large inverse merely to avoid a solve.

### Long-range coupling and multilevel methods

If iteration count grows sharply with connected diameter or resolution, optimizing the same local sweep may have limited benefit. Investigate a coarse correction, domain decomposition, block methods, or a stronger preconditioner that addresses long-wavelength error.

AMG setup has a real cost; coarse levels can become too small to use the GPU efficiently. Track hierarchy construction, operator complexity, coarse solve time, and reuse count. GPU-supported parameter choices may differ from CPU defaults. [hypre BoomerAMG][hypre]

For elasticity-like systems, rigid-body null/near-null modes can be central. An unsupported free body is not the same mathematical system as a supported structure. Treat null spaces, compatibility of loads, and constraints explicitly rather than stabilizing everything with an unexplained diagonal constant. [PETSc rigid-body null spaces][petsc-nullspace]

### Many independent components

A reasonable architecture experiment is a small-component local path plus a separate large-component path. Determine the threshold from measurements of resources, iterations, and distribution; do not hardcode a universally “correct” node count.

Retire converged components independently. A global loop that keeps every small component active until the hardest one converges wastes work. Compare masks, periodic compaction, and work queues, including their costs and numerical stopping semantics.

If topology only splits, exploit that property in invalidation and connectivity maintenance. A split still changes membership, constraints, local indexing, and potentially hierarchy validity; it does not make all updates free. This is a problem-specific architectural opportunity to validate, not a generic property of CUDA solvers.

## 22. Precision and numerical quality

Floating-point addition is not associative. Parallel reductions, compiler transformations, fused multiply-add, and different CPU/GPU implementations can produce different rounded results. FMA performs a multiply-add with one final rounding and often improves accuracy, so disabling it to match another path is not automatically a numerical improvement. [NVIDIA floating-point guide][floating-point]

### Define what agreement means

Use a combination of:

- Absolute and relative error against a trusted result.
- True residual or backward error.
- Conservation, constraint, or symmetry invariants where applicable.
- Long-horizon drift.
- Stability and nonfinite-value checks.
- Agreement of threshold-triggered decisions.

For stateful simulation, a small local numerical difference can change a discrete event and lead to diverging trajectories. Compare the meaningful behavior/quality criteria over time; neither bitwise inequality nor visual similarity alone is a complete validation method.

### Change precision by role

An experiment might keep persistent state in FP32, accumulate sensitive reductions in FP64, and use lower precision for an approximate preconditioner. Another might use a lower-precision solve followed by a higher-precision residual/correction step. Whether this converges depends on conditioning, scaling, and the particular method.

Build a precision table for every quantity: storage type, arithmetic type, accumulation type, dynamic range, error sensitivity, and conversion points. Check constants such as `0.5` versus `0.5f` and accidental promotions in hot expressions. On a GPU with limited FP64 throughput, unintended double operations can matter; record the actual device capability rather than assuming all NVIDIA GPUs have similar FP64 rates.

Test one precision change at a time. Compare **time to tolerance**, not only instruction throughput. Include difficult cancellation, very small and very large magnitudes, badly scaled coefficients, near-singular cases, and threshold-adjacent decisions.

### Fast math is a policy change

`--use_fast_math` changes multiple floating-point behaviors, including use of faster approximations and handling associated with division/square-root precision and denormals. Verify the exact installed compiler options. Prefer targeted substitutions when only one expensive function needs an approximation, and keep a reference path for validation. [NVCC options][nvcc]

Document the changed error contract, if any. Do not count a looser tolerance or skipped validation as a pure implementation speedup.

### Reproducibility tiers

| Tier | Suitable interpretation |
|---|---|
| Bitwise repeatability on fixed configuration | Strict replay/debugging needs; may restrict reduction order |
| Numerically bounded variation | Same error and stability contract despite rounding differences |
| Behavioral equivalence | Application decisions and long-term quality stay within defined limits |

Choose explicitly. Atomic floating-point accumulation may vary with execution order. Library determinism may depend on algorithm, workspace, streams, version, and hardware. Record those conditions instead of labelling the entire application “deterministic.”

## 23. Real-time scheduling and workload sparsity

### Make inactivity cheap

When only a small subset changes, compare processing all elements against maintaining active work. The bookkeeping must be included:

`T_sparse = T_dirty_tracking + T_queue/compaction + T_active_work + T_required_global_work`.

Scanning every element to discover that none changed can defeat the purpose of an active set. Prefer producer-maintained dirty flags or compact work queues when the producers already know what changed. Deduplicate updates and define ownership, queue capacity, and overflow behavior.

An element is not necessarily inactive just because it received no external event. Its operator, neighboring state, constraints, time-dependent load, or convergence certificate may have changed. Invalidate through the real dependency graph.

### Exact reuse versus approximation

| Technique | Required justification |
|---|---|
| Reuse identical cached result | All relevant inputs and acceptance conditions remain valid |
| Reuse with a certificate | Certificate bounds the changed result sufficiently |
| Warm start | Result is only an initial guess; solver still validates |
| Delayed update | Explicit stale-data/error budget and wake-up policy |
| Lower tolerance/fewer iterations | Explicit quality tradeoff and fallback |
| Sleeping/freezing | Correct conditions for waking after relevant changes |

This distinction prevents a performance cache from quietly becoming an undocumented physical approximation.

### Decide when compaction pays

If dead entries cost `T_dead_per_step`, rebuilding costs `T_rebuild`, and the compact representation is expected to survive `R` steps, the simple break-even test is:

`R × T_dead_per_step > T_rebuild`.

Extend it to include cache effects, remapping, scratch, and update work. A validity mask can be better than rebuilding for a few dead entries; compaction can win after substantial fragmentation. Measure the distribution over a realistic lifecycle.

### Bound expensive exceptional work

Capacity growth, hierarchy rebuilds, connectivity updates, graph recapture, module loading, and pathological convergence can dominate p99 while barely affecting the average. Make these explicit phases with counts and worst observed costs.

Possible policies include amortized maintenance, preallocated capacity, priority queues, bounded batches, or reduced-quality fallback. Their correctness must be defined: deferring a required dependency is not valid merely because it prevents a spike.

If the application permits approximate results, expose clear controls such as maximum work budget, residual target, refinement frequency, and stale-state limit. Evaluate a quality/latency Pareto frontier and choose a policy with margin. Keep algorithmic architecture decisions distinct from reversible numerical knobs.

### Design for overload

Define how the application behaves when more work arrives than it can complete: queue, coalesce obsolete inputs, reduce optional refinement, retain the last accepted state, or signal a failure. Which choice is valid depends on the product.

Measure queue length, oldest-work age, completed-work age, and deadline miss streaks. A system that processes every old update at high throughput while falling farther behind is not meeting a real-time response goal.

## 24. Roofline, cost models, and stopping decisions

### Use lower bounds as reasoning tools

For compute work `F`, data traffic `Q`, sustainable relevant throughput `P`, and sustainable bandwidth `B`:

`T >= max(F/P, Q/B)`.

Arithmetic intensity is `I = F/Q`, giving the roofline relation:

`performance <= min(P, B × I)`.

Use the appropriate arithmetic type, operation counting, memory boundary, and achieved sustainable hardware rates. A DRAM roofline will not explain a kernel limited by L2, atomics, dependencies, or sparse indexing. Nsight offers several roofline variants; use their definitions rather than mixing incompatible metrics. [Nsight roofline analysis][ncu-profiling]

### A worked estimate

Assume, purely for illustration, an operation performs 2 FLOPs and logically transfers 12 bytes per item. Its logical arithmetic intensity is `1/6 FLOP/byte`. At a sustainable 600 GB/s, the bandwidth-limited logical work rate would be 100 GFLOP/s and 50 billion items/s.

These are model ceilings under the assumptions, not performance promises. If observed DRAM traffic is twice the logical traffic, or the kernel cannot create enough outstanding requests, the attainable rate is lower. If input reuse avoids DRAM reads, a model based on logical bytes at DRAM can instead underestimate the achievable rate.

### Model application benefit

For a purely serial fraction `p` sped up by factor `s`, Amdahl's law gives:

`S_total = 1 / ((1 - p) + p/s)`.

If a phase is 40% of serial runtime and becomes twice as fast, total speedup is 1.25×. If it were removed entirely, the limit is about 1.667×. For overlapping phases, use critical-path contribution rather than a fraction from a summed-kernel report. [CUDA Best Practices][best-practices]

Use a rough opportunity estimate:

`recoverable_ms ≈ relevant_phase_ms × plausible_fraction_removed`.

Rank by expected recovered milliseconds, confidence, implementation cost, and correctness risk. Do not add multiple rule-estimated speedups: they can describe the same wasted work.

### What saturation tells you

If an unavoidable memory stream is close to its measured sustainable ceiling, micro-tuning instruction scheduling may have little headroom. The next useful question is whether you can reduce bytes, reuse data, change representation, or eliminate repeated passes.

Conversely, “not near peak” does not imply an easy optimization. A dependency chain, tiny workload, or irregular access structure can impose a real algorithmic limit. Set a practical stopping criterion based on the remaining opportunity and engineering cost, while keeping architectural changes on the backlog.

## 25. Advanced architecture and multi-GPU work

Learn architecture features after the basic evidence is reliable. Match features to the **exact compute capability and supported compiler target**, not only a family name. Architecture- and family-specific target suffixes have different portability rules. Datacenter and consumer GPUs in a named generation need not support the same specialized operations. [Compute capabilities][compute-capabilities]

| Feature | Consider when | Proof required |
|---|---|---|
| Async global-to-shared copies | Staging/reuse and latency overlap dominate | Correct waits, actual instruction path, net phase improvement |
| TMA or specialized transfer paths | Supported bulk/tiled movement fits the workload | Capability, layout, setup cost, reuse |
| Thread-block clusters/distributed shared memory | Cross-block cooperation fits supported architecture | Cluster occupancy, synchronization, resource use |
| Tensor Cores | Substantial compatible matrix work exists | Numerical contract, packing/padding cost, actual tensor execution |
| Cooperative persistent kernels | Launch/repeated-state costs justify residency | Legal launch size, progress, fairness, termination |
| Cluster launch control | Supported dynamic work scheduling is useful | Capability-specific implementation and measured tail improvement |
| Graph device/conditional control | Device-owned dynamic decisions fit supported graph semantics | Node/update restrictions and lifecycle correctness |

The CUDA feature survey is a map to specialized documentation, not evidence that every feature benefits every numerical kernel. [CUDA feature survey][features]

Tiny 6×6 block operations do not automatically become faster on Tensor Cores. Packing many blocks, padding, converting precision, and scattering results can overwhelm arithmetic savings. Batch enough compatible work and include all transformations in the comparison.

### PM sampling and source sampling

PM sampling records changing metric behavior across a workload. Warp sampling attributes sampled scheduler states to instructions. They answer different questions, and their units and precision differ. A long persistent kernel may need both to reveal internal phases hidden by averages.

Discover available sampling metrics before selecting them:

```bash
ncu --query-metrics --query-metrics-collection pmsampling
ncu --query-metrics --query-metrics-collection warpsampling
```

Then try the supported `PmSampling` section on one representative long workload. Sampling can still involve multiple passes, finite buffers, alignment issues, and perturbation. Do not treat every sample as an exact cycle counter. Recent report interfaces expose more timeline data, but exporting aggregate CSV alone does not preserve all timeline structure. [Nsight Compute Python interface][ncu-python]

### Multiple GPUs and processes

Only scale out after understanding one GPU. Add communication to the dependency graph: peer transfers, host staging, synchronization, reductions, imbalance, and CPU/NUMA placement.

Validate peer access and actual topology. Same-server devices are not automatically connected by a fast peer link. Include data partitioning and communication in response time; faster aggregate compute can coexist with worse latency for a coupled problem. [CUDA multi-GPU programming][multi-gpu]

Nsight Compute's ordinary serialization can interfere with kernels that require concurrent participants. Current releases provide specialized multi-process communicator options, with strict version/mode requirements. Use the corresponding installed documentation for mandatory concurrent kernels; do not assume profiling a single rank in isolation is valid.

Save unique report names per process/device and retain process, context, stream, device UUID, and logical work identity. Global percentages across dissimilar devices are usually less informative than per-device work and critical-path timing.

## 26. Automate analysis and regression checks

### Keep a small reproducibility bundle

For each accepted experiment, retain:

- Source revision, dirty diff, executable hash, and compile/link commands.
- Input/configuration hashes and logical capture identifiers.
- Tool versions, GPU UUID, CPU/topology, and relevant environment settings.
- Unprofiled timing CSV and numerical validation results.
- Original `.nsys-rep` and selected `.ncu-rep` files.
- Exported text/CSV/JSON, commands, and an explanation of the result.

Avoid dumping the entire process environment into a bundle: it can contain credentials. Record an explicit allowlist of performance-relevant variables.

### Programmatic `.ncu-rep` access

The `ncu_report` module can read report ranges, actions, metric names, values, units, and metadata. It is available with the Nsight Compute installation; newer releases also offer a standalone package. Keep the report reader compatible with the report producer. [Python Report Interface][ncu-python]

```bash
# Set this to the actual installed extras/python directory.
NCU_PYTHON_DIR=/opt/nvidia/nsight-compute/2026.3/extras/python
PYTHONPATH="$NCU_PYTHON_DIR${PYTHONPATH:+:$PYTHONPATH}" \
  python3 cuda-performance-toolkit/export_ncu.py \
  profiles/operator-deep.ncu-rep \
  --metric gpu__time_duration.sum \
  --metric dram__bytes_read.sum \
  --metric dram__bytes_write.sum \
  > profiles/operator-selected.json
```

That installation path is illustrative; locate your real version. The supplied exporter retains range/action indices, workload name, metric units/descriptions, and missing values. It does not silently equate similarly named kernels across reports.

When comparing repeated actions, create a key from logical phase, kernel, configuration, device, precision, and representative input class. A launch number can shift after fusion or adding a helper kernel; do not compare row 21 to row 21 blindly.

### Custom sections and rules

A custom section can collect the recurring metrics that answer a specific application question. A rule can flag conditions and produce guidance. Store the section/rule version with reports and run against the matching Nsight interface. Built-in/custom rule suggestions remain hypotheses that need application validation. [Customization Guide][ncu-custom], [NvRules API][ncu-rules]

### CI gates

Use a dedicated or controlled performance runner when possible. Suggested gates are:

| Gate | What it establishes |
|---|---|
| Build and correctness cases | Supported code paths compile and satisfy known invariants |
| Short memory/synchronization check | Relevant invalid accesses or collective misuse are caught |
| Fixed scenario benchmark | Latency, work count, memory, and quality remain acceptable |
| Tail/overload replay | Burst and long-lived behavior stay within the product contract |
| Targeted counter capture on selected changes | Mechanism-level regressions can be explained |

Avoid running `--set full` on every commit and every frame. Use fast normal benchmarks as routine gates, then collect diagnostic evidence when a regression appears or a mechanism changes.

A performance gate should specify acceptable measurement variance and a repeat procedure. A single slow shared-machine run should trigger investigation, not an automatic claim that the algorithm regressed. Conversely, repeated clear regression should not be averaged away with unrelated fast scenarios.

### A useful report for a reviewer or coding agent

```text
Goal and acceptance contract:
Hardware / toolchain / build / input identifiers:
Observed bottleneck, with report and units:
Hypothesis and plausible alternatives:
Change made:
Predicted mechanism and counter changes:
Normal-run before/after results, sample counts, variation:
Work-count and numerical-quality before/after results:
Counter evidence:
Cases that regressed or remain untested:
Keep / revert / investigate:
```

Ask an agent to distinguish observations from inferences, cite exact metric names/units, estimate application benefit, and propose a falsifiable experiment. Reject invented counters, universal tuning thresholds, or performance claims without the normal benchmark.

## 27. Worked investigations

The numbers below are invented for instruction. They show how to reason, not results from a real application.

### A. The GPU is frequently uncovered in the trace

**Observation:** a measured 20 ms step has 8 ms of union kernel activity. The trace shows repeated tiny device-to-host scalar copies, CPU checks, and late next-iteration submissions.

**Wrong conclusion:** the 8 ms of kernels is the entire GPU-side critical path, or every remaining millisecond can be removed.

**Investigation:** correlate the scalar copies with convergence checks and input/output dependencies. Check whether graph/copy operations or untraced activity explain some intervals. Count iterations and how often a host answer is actually needed.

**Experiment:** retain convergence state on the GPU and read a status summary less often, with an unchanged true-residual acceptance check. Alternatively, batch a fixed number of iterations and preserve the original final acceptance logic.

**Prediction:** fewer host round trips and gaps; possible extra iterations. **Accept** only if completed-step latency improves without increased quality failures. If iteration cost rises enough to erase the benefit, use a smaller batch or a different control design.

### B. High memory stalls, low bandwidth

**Observation:** the operator takes 2.0 ms, has substantial long-scoreboard samples, and DRAM bandwidth is far below the measured sustainable rate. Requests appear well coalesced.

**Investigation:** inspect L1/L2/load-store pressure, available blocks, eligible warps, and the consumer's dependency chain. Low DRAM alone does not tell whether the problem is another saturated tier or insufficient independent requests.

**Experiment:** process two independent rows per thread with separate accumulators, or change row assignment to provide more concurrent work.

**Prediction:** more independent loads and eligible instructions; registers may rise. **Accept** if equal-work duration improves, even if occupancy falls. **Reject** if spills or a larger tail dominate.

### C. A fast sweep still produces a slow solve

**Observation:** sweep A takes 40 microseconds and needs 100 sweeps. Sweep B takes 65 microseconds and needs 40 sweeps.

Their iteration totals are 4.0 ms and 2.6 ms respectively. If B adds 0.4 ms of setup per solve, it still takes 3.0 ms before shared validation/recovery costs. If B instead adds 3 ms of uncached setup every solve, it loses.

**Investigation:** compare across sizes, conditioning, topology changes, and reuse counts. **Accept** based on total time to the same true-residual and application-quality threshold. Do not choose A simply because its kernel is faster.

### D. The average improves while p99 regresses

**Observation:** active queues reduce typical work, but capacity growth and queue rebuilding produce occasional large spikes.

**Investigation:** align spikes with allocation/rebuild counters, inspect queue occupancy before them, and test worst expected bursts.

**Experiment:** preallocate known capacity and define a bounded overflow/rebuild policy. **Accept** if steady-state savings remain and tail behavior meets the contract. A larger memory footprint is a visible tradeoff, not a hidden cost.

### E. A memory-layout optimization fails

**Observation:** converting a graph operator to SoA halves its requested sectors, but complete solve time does not improve.

**Investigation:** check conversion cost, downstream kernels, cache residency, and changed instruction count. Perhaps the original kernel was latency-limited by dependent gathers rather than the sequential field loads that improved.

**Experiment:** retain SoA persistently, change only the hot fields, or revert if another phase dominates. A reduced sector count validates the local mechanism but does not establish application value.

## 28. Troubleshooting

| Symptom | First checks and next action |
|---|---|
| `ERR_NVGPUCTRPERM` | Host driver profiling policy, approved privileges, container exposure |
| `ncu` unavailable | Toolkit/tool installation and `PATH`; record explicit executable paths |
| GPU supported by CUDA but not by `ncu` | Nsight version and GPU support matrix |
| No kernels profiled | Name basis, NVTX syntax/domain/thread, start/stop region, child process, skip/count |
| Huge profile time | Number of launches, sections, replay passes, accessed/written memory, patching |
| Replay hangs | Mandatory concurrency, host interaction, unsupported range activity, nondeterminism |
| Metrics missing or `N/A` | Collection sections, device support, scope, warnings; never substitute zero |
| Implausible ratios or varying counters | Multi-pass consistency, caches, clocks, short kernels, shared traffic |
| `ncu` time differs from `nsys` | Same scope/input; clock, cache, replay, serialization and instrumentation |
| Profiling resource unavailable | Another profiler or monitoring client may own the counter resource; coordinate access |
| No source lines | Optimized build with line info, correct source path/import, binary/source identity |
| CSV parsing breaks | Quoted fields, units, multiple report headers; use a real CSV parser |
| SQLite query finds no kernel rows | Schema/table names, capture selection, graph granularity, missing activity |
| CPU samples unavailable | Linux perf permissions, platform support, collector configuration |
| Results shift after a tool upgrade | Metric/section/rule changes, clock defaults, report-reader compatibility |
| Changes help one GPU and hurt another | Re-evaluate resource limits, cache/SM sizes, arithmetic rates, capability paths |
| First burst is much slower | Lazy loading, JIT, library/graph setup, allocation, cold data path |
| Long-run performance declines | Temperature/power policy, retained memory, dead work, queue growth, changing conditioning |
| Kernel speedup does not help response time | Critical path moved or lies elsewhere; inspect complete timeline |

For a server with unsupported counter access, make progress using low-overhead timing and work counts. For a report-format incompatibility, use the matching tool version to export it. Do not modify a binary report or assume a newer schema can be reconstructed by renaming an extension.

Nsight Compute's documented clock reset option can help when a killed profiler leaves its own clock settings behind. Coordinate device-wide state changes with the owner of a shared machine and preserve any intentional administrator policy.

## 29. Practice sequence and review checklists

### Learn by producing evidence

| Stage | Exercise | Completion evidence |
|---|---|---|
| 1. Timing | Time a same-stream batch and end-to-end completion | Explain why enqueue, event, and host times differ |
| 2. Whole application | Capture startup and a steady-state window | Identify one actual delay chain |
| 3. Parallelism | Compare serial outer work with independent blocks | Equal results; geometry and elapsed-time change |
| 4. Memory | Compare contiguous, strided, and reordered accesses | Predicted versus measured requests/bytes |
| 5. Residency/latency | Sweep block size and per-thread work | Explain a winner using resources and issue evidence |
| 6. Coordination | Batch launches or introduce a graph | Submission/gap reduction and application benefit |
| 7. Numerical method | Compare two preconditioner/iteration policies | Time to the same quality target across cases |
| 8. Sparsity | Compare full scan with active work | Break-even curve including maintenance |
| 9. Regression discipline | Introduce and detect a controlled slowdown | Reproducible gate and a useful diagnostic bundle |
| 10. Architecture | Repeat the bottleneck analysis on another GPU | Explain which former assumptions changed |

Work through NVIDIA's ADO examples as historical exercises, then repeat the reasoning on your application. Do not chase their exact timings on different hardware. [ADO tutorial series][ado1]

### Before collecting

- What exact question will this capture answer?
- Is the selected workload representative and reproducible?
- Is the binary optimized, with source attribution available?
- Have warmup and completion boundaries been defined?
- Are clock/cache/replay settings and other machine users known?
- Can fewer launches or sections answer the question?

### Before accepting a change

- Did the complete normal-run metric improve beyond ordinary variation?
- Was the same work and quality contract used?
- Does the predicted mechanism explain the observed change?
- Were typical, small, large, irregular, burst, and settled cases considered?
- Did memory footprint, setup, maintenance, or numerical iterations regress?
- Are the new synchronization and lifetime rules correct?
- Is the result reproducible from the retained bundle?

### When to change architecture

Consider a larger redesign when the dominant cost is repeated unnecessary work, an inherently serial mapping, CPU/device round trips, poor scaling with connected size, incompatible task sizes, or a saturated unavoidable resource whose demand can be reduced mathematically.

Consider stopping the current optimization line when its remaining plausible application benefit is small, results are within noise, or the next change adds disproportionate complexity. Preserve the measurement and move to the next important bottleneck. Performance expertise consists of making these decisions reliably, not memorizing every counter name.

## 30. Source map and further study

The references below are primary documentation or original NVIDIA tutorials. References checked on 13 September 2026. Living documentation can change; save the versions corresponding to the tools used in an experiment. Historical tutorials are best used for reasoning exercises, while installed help and version-matched manuals govern command syntax.

### The supplied NVIDIA resources

| Resource | Role in this handbook |
|---|---|
| [Nsight Compute overview][ncu-overview] | Tool purpose, guided analysis, source attribution and extensibility |
| [Getting Started / documentation][ncu-release] | Releases, support matrix, current documentation entry points |
| [Nsight tutorial center][tutorials] | Further training and demonstrations |
| [Profiling Guide][ncu-profiling] | Collection semantics, metric interpretation, replay, sampling and reproducibility |
| [Nsight Compute UI manual][ncu-ui] | Meaning of report views, source inspection, comparisons and occupancy analysis |
| [Nsight Compute CLI manual][ncu-cli] | Filtering, capture, import/export, source pages and headless operation |
| [CUDA Toolkit][toolkit] | Compiler, libraries, correctness tools and toolkit distribution |
| [Nsight Systems timeline resource][timeline-resource] | Video/resource landing page; accessible page does not provide a substantive transcript |

The UI manual remains useful on a headless project because it explains the report concepts. Use this translation:

| GUI concept | Headless route |
|---|---|
| Details and guided rules | `ncu --import ... --page details` |
| Raw metric table | `--page raw --csv` or Python report API |
| Source/SASS view | `--page source --print-source cuda,sass` |
| Baseline comparison | Retain matching action metadata and compare exported values |
| Occupancy calculator | CUDA occupancy APIs or `ncu_occupancy` Python interface |
| Systems timeline | Per-operation text/CSV traces, SQLite, and correlation reports |
| Sampling timeline | Supported report API/timeline exports; aggregate CSV alone is incomplete |

These are functional routes, not a promise of exact GUI/CLI feature parity. [Nsight Compute UI manual][ncu-ui]

### Reference library

| Reference | Main topics |
|---|---|
| [Compute Triage Guide][ncu-triage] | Top-down workload diagnosis; heuristic thresholds require context |
| [Nsight Systems user guide][nsys-user] | Capture controls, CPU sampling, tracing and CLI commands |
| [Nsight Systems analysis guide][nsys-analysis] | Text/CSV reports, SQLite and report semantics |
| [Overhead and latency tutorial][nsys-latency] | API time, launch delay, queueing and tracing overhead |
| [CUDA Best Practices][best-practices] | APOD workflow, performance measurement, memory and scaling |
| [Compute Sanitizer][sanitizer] | Memory, race, initialization and synchronization checks |
| [CUDA programming model][gpu-model] | Host/device model, threads, warps, blocks and execution |
| [Writing CUDA kernels][kernels] | Kernel construction, indexing and synchronization |
| [Asynchronous execution][async] | Streams, events, transfers and overlap |
| [Understanding memory][memory] | Address spaces and memory behavior |
| [Advanced kernel programming][advanced-kernel] | SM execution, occupancy and advanced kernel concerns |
| [Advanced host programming][advanced-host] | Host integration and execution management |
| [NVCC compiler driver][nvcc] | Build flags, targets, optimization and numerical switches |
| [Binary utilities][binary] | `cuobjdump`, `nvdisasm`, resource and instruction inspection |
| [NVTX][nvtx] | Structured annotations and C/C++ integration |
| [Counter permission reference][counter-permissions] | Diagnosing restricted performance counters |
| [NVIDIA SMI][smi] | Device inventory and telemetry |
| [CUDA Graphs][graphs] | Construction, instantiation, update, launch and dynamic graph features |
| [Stream-ordered allocation][pools] | Asynchronous allocation and memory pools |
| [Cooperative Groups][groups] | Supported cooperative execution and collective scope |
| [Unified Memory][um] | Residency, migration and advice |
| [Asynchronous copies][async-copy] | Global/shared transfer mechanisms and synchronization |
| [Pipelines][pipeline] | Staged asynchronous work |
| [L2 cache control][l2-cache] | Persistence and access-policy management |
| [Lazy loading][lazy] | First-use costs and module/kernel loading |
| [CUDA memory model][memory-model] | Atomicity, scope and memory ordering |
| [Compute capabilities][compute-capabilities] | Architecture support and compiler feature targets |
| [CUDA feature survey][features] | Map of advanced features and their detailed references |
| [Multi-GPU programming][multi-gpu] | Device management, communication and topology |
| [Floating-point guide][floating-point] | Rounding, FMA, precision and CPU/GPU comparisons |
| [cuBLAS][cublas] | Dense operations, handles, scalar modes, workspace and math behavior |
| [cuSPARSE][cusparse] | Sparse operations, algorithms and preprocessing |
| [CCCL repository and documentation][cccl] | CUB, Thrust, libcudacxx and parallel building blocks |
| [PETSc KSP manual][petsc] | Solver/preconditioner design, convergence and reuse |
| [PETSc CG][petsc-cg] | CG assumptions and variants |
| [PETSc flexible GMRES][petsc-fgmres] | Variable/nonlinear preconditioner support |
| [PETSc rigid-body null spaces][petsc-nullspace] | Null/near-null modes in elasticity-like problems |
| [hypre BoomerAMG][hypre] | Multilevel methods and GPU-supported choices |
| [Nsight Python Report Interface][ncu-python] | Structured programmatic access to reports |
| [Nsight customization][ncu-custom] | Custom metric sections and analysis workflows |
| [NvRules API][ncu-rules] | Rule and metric APIs |
| [Occupancy Python interface][ncu-occupancy] | Programmatic occupancy modeling |
| [perf stat][perf-stat] | CPU hardware/software event counts |
| [perf record][perf-record] | CPU sampling and call-chain collection |
| [perf report][perf-report] | Text analysis of CPU profiles |
| [perf annotate][perf-annotate] | CPU source/instruction annotation |
| [ADO part 1][ado1], [part 2][ado2], [part 3][ado3] | Complete iterative optimization example; NVIDIA, 2021 |

### Companion utilities

The optional `CUDA-Performance-Toolkit.zip` includes this handbook and:

| File | Purpose |
|---|---|
| `summarize_timings.py` | Timing quantiles, deadline miss rates and consecutive misses from CSV |
| `trace_intervals.py` | Device/process-filtered interval unions and uncovered trace windows |
| `export_ncu.py` | Selected typed metrics and metadata from `.ncu-rep` files |
| `experiment-template.md` | Reproducible experiment record |
| `README.md` | Usage, input contracts, validation scope and limitations |

The Python scripts use the standard library except `export_ncu.py`, which requires NVIDIA's `ncu_report` module. They analyze evidence; they do not execute or optimize the application automatically. GPU collection commands must be run on the target CUDA server with its installed tools.

[ado1]: https://developer.nvidia.com/blog/analysis-driven-optimization-preparing-for-analysis-with-nvidia-nsight-compute-part-1/
[ado2]: https://developer.nvidia.com/blog/analysis-driven-optimization-analyzing-and-improving-performance-with-nvidia-nsight-compute-part-2/
[ado3]: https://developer.nvidia.com/blog/analysis-driven-optimization-finishing-the-analysis-with-nvidia-nsight-compute-part-3/
[advanced-host]: https://docs.nvidia.com/cuda/cuda-programming-guide/03-advanced/advanced-host-programming.html
[advanced-kernel]: https://docs.nvidia.com/cuda/cuda-programming-guide/03-advanced/advanced-kernel-programming.html
[async]: https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/asynchronous-execution.html
[async-copy]: https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/async-copies.html
[best-practices]: https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html
[binary]: https://docs.nvidia.com/cuda/cuda-binary-utilities/index.html
[cccl]: https://github.com/NVIDIA/cccl
[compute-capabilities]: https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/compute-capabilities.html
[counter-permissions]: https://developer.nvidia.com/ERR_NVGPUCTRPERM
[cublas]: https://docs.nvidia.com/cuda/cublas/index.html
[cusparse]: https://docs.nvidia.com/cuda/cusparse/index.html
[features]: https://docs.nvidia.com/cuda/cuda-programming-guide/03-advanced/feature-survey.html
[floating-point]: https://docs.nvidia.com/cuda/floating-point/index.html
[gpu-model]: https://docs.nvidia.com/cuda/cuda-programming-guide/01-introduction/programming-model.html
[graphs]: https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/cuda-graphs.html
[groups]: https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/cooperative-groups.html
[hypre]: https://hypre.readthedocs.io/en/latest/solvers-boomeramg.html
[kernels]: https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/writing-cuda-kernels.html
[l2-cache]: https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/l2-cache-control.html
[lazy]: https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/lazy-loading.html
[memory]: https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/understanding-memory.html
[memory-model]: https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/cuda-cpp-memory-model.html
[multi-gpu]: https://docs.nvidia.com/cuda/cuda-programming-guide/03-advanced/multi-gpu-systems.html
[ncu-cli]: https://docs.nvidia.com/nsight-compute/NsightComputeCli/index.html
[ncu-custom]: https://docs.nvidia.com/nsight-compute/CustomizationGuide/index.html
[ncu-occupancy]: https://docs.nvidia.com/nsight-compute/OccupancyCalculatorPythonInterface/index.html
[ncu-overview]: https://developer.nvidia.com/nsight-compute
[ncu-profiling]: https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html
[ncu-python]: https://docs.nvidia.com/nsight-compute/PythonReportInterface/index.html
[ncu-release]: https://developer.nvidia.com/tools-overview/nsight-compute/get-started#documentation
[ncu-rules]: https://docs.nvidia.com/nsight-compute/NvRulesAPI/index.html
[ncu-triage]: https://docs.nvidia.com/nsight-compute/ComputeTriage/index.html
[ncu-ui]: https://docs.nvidia.com/nsight-compute/NsightCompute/index.html
[nsys-analysis]: https://docs.nvidia.com/nsight-systems/AnalysisGuide/index.html
[nsys-latency]: https://developer.nvidia.com/blog/understanding-the-visualization-of-overhead-and-latency-in-nsight-systems/
[nsys-user]: https://docs.nvidia.com/nsight-systems/UserGuide/index.html
[nvcc]: https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html
[nvtx]: https://nvidia.github.io/NVTX/
[perf-annotate]: https://man7.org/linux/man-pages/man1/perf-annotate.1.html
[perf-record]: https://man7.org/linux/man-pages/man1/perf-record.1.html
[perf-report]: https://man7.org/linux/man-pages/man1/perf-report.1.html
[perf-stat]: https://man7.org/linux/man-pages/man1/perf-stat.1.html
[petsc]: https://petsc.org/release/manual/ksp/
[petsc-cg]: https://petsc.org/release/manualpages/KSP/KSPCG/
[petsc-fgmres]: https://petsc.org/release/manualpages/KSP/KSPFGMRES/
[petsc-nullspace]: https://petsc.org/release/manualpages/Mat/MatNullSpaceCreateRigidBody/
[pipeline]: https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/pipelines.html
[pools]: https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/stream-ordered-memory-allocation.html
[sanitizer]: https://docs.nvidia.com/compute-sanitizer/ComputeSanitizer/index.html
[smi]: https://docs.nvidia.com/deploy/nvidia-smi/index.html
[timeline-resource]: https://resources.nvidia.com/en-us-nsight-developer-tools/nsight-systems-timeline-view
[toolkit]: https://developer.nvidia.com/cuda/toolkit
[tutorials]: https://developer.nvidia.com/tools-tutorials
[um]: https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/unified-memory.html
