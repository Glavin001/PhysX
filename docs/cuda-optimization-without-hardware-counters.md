# CUDA Optimization Without Hardware Counters

The most productive starting point is to explain where one completed frame or simulation step spends its time. Then remove unnecessary work and CPU–GPU dependencies, and only afterward tune the kernels responsible for the remaining delay. You can do this with ordinary CPU timers, CUDA events, software execution traces when available, compiler reports, and controlled experiments.

This guide targets custom CUDA C++ on a discrete NVIDIA GPU in a cloud environment where performance counters are unavailable. It assumes familiarity with C++ but limited CUDA optimization experience. Examples include array processing and irregular workloads such as simulation, queues, and graph traversal. They are illustrative; no particular application bottleneck or speedup is assumed.

The tool behavior described here was checked against NVIDIA documentation available on September 9, 2026. Installed CUDA, Nsight, driver, and cloud configurations can differ. The workflow does not require changing host permissions, enabling counters, or controlling GPU clocks.

## 1. The order of investigation

Use this as the working sequence, adjusting it when measurements clearly point elsewhere.

| Priority | Question | First investigation | Possible next change |
|---|---|---|---|
| 1 | Is the measured time meaningful? | Verify optimized build, warm-up, completion boundary, representative input | Correct the benchmark before judging code |
| 2 | Is useful GPU work waiting on the CPU? | Trace gaps; time host stages; count readbacks and synchronization | Remove an unnecessary dependency; overlap independent bookkeeping |
| 3 | Is repeated dispatch or allocation expensive? | Count launches, allocations, copies, and graph construction per step | Reuse storage; batch operations; replay a graph |
| 4 | Is the algorithm doing avoidable work? | Record active items, candidate counts, iterations, rebuilds, and rescans | Compact, cache, prune, or update incrementally |
| 5 | Are hot kernels moving data inefficiently? | Map the addresses touched by a warp; estimate useful bytes | Improve layout, locality, reuse, or eliminate an intermediate pass |
| 6 | Is work poorly distributed or serialized? | Sweep task shape and launch size; inspect atomics and work histograms | Split large tasks, aggregate updates, specialize work classes |
| 7 | Does compiled code have resource or arithmetic problems? | Inspect register/local-memory reports and machine instructions | Reduce live state; change mapping; make precision intentional |

This ordering is an engineering recommendation, not a claim that one category dominates every CUDA program. A single long kernel may warrant immediate attention. Conversely, hundreds of individually fast kernels can form a slow application.

### Define the actual real-time requirement

At 60 updates per second, the entire update period is approximately 16.67 ms; at 120, it is 8.33 ms. Decide how much of that budget this CUDA subsystem receives after rendering, input processing, networking, and other tasks. Also decide whether the requirement is completion latency, sustained throughput, or both.

These are different tests:

- **Step latency:** how long one input takes to become a usable output.
- **Throughput:** how many completed steps are produced per second after the pipeline fills.
- **Deadline behavior:** how often steps miss their budget, how badly, and whether misses cluster.

A pipeline can deliver one result every 10 ms while each result is 30 ms old. A benchmark that queues thousands of operations and divides total time by their count can establish throughput, but cannot establish interactive latency.

Set a target such as “the simulation completes within its 10 ms budget for at least 99% of the specified workload distribution, with separately bounded exceptional cases.” This is an example of a measurable requirement, not a recommended universal percentile. Hard real-time guarantees require stronger platform and worst-case analysis than a shared cloud GPU plus an empirical p99 can provide.

### Budget potential gains before implementing them

For non-overlapping work, a simple planning estimate is:

`new step time = unaffected time + affected time / local speedup`

If a 50 ms step contains a 5 ms kernel, doubling that kernel's speed gives 47.5 ms overall. Even deleting the kernel entirely only gets to 45 ms. If the deadline is 12 ms, that change cannot solve the main problem.

With overlapping streams, use the critical path—the dependent chain that determines completion. Do not add every CPU duration, kernel duration, and copy duration together. Speeding up an operation that finishes well before the final dependency may change no externally visible latency.

## 2. What remains available without counters

Performance counters report low-level activity such as cache behavior, instruction issue, and stalls. NVIDIA documents counter access as a permission-controlled facility. Consumer branding alone does not mean that the hardware lacks counters; cloud policy and driver configuration are separate constraints.[^1]

| Method | What you can learn | Important limit |
|---|---|---|
| `std::chrono::steady_clock` | CPU work and end-to-end completion latency | A timer around an asynchronous launch measures submission unless you wait for completion |
| CUDA events | Elapsed device-timeline intervals in a stream | Includes intervening delays and interference; not a stall breakdown |
| Nsight Systems software tracing | CUDA calls, kernel/copy intervals, sequencing, CPU annotations | Tracing must be supported by the provider; instrumentation can perturb short operations |
| NVTX annotations | Which application phase launches or performs work | A CPU range's width is not automatically the duration of its GPU work |
| `ptxas` reports and binary inspection | Registers, local memory, spills, emitted instructions | Static information does not measure runtime utilization |
| CUDA occupancy API | Resource-based potential block residency | Predicted occupancy is not achieved occupancy or useful work rate |
| Compute Sanitizer | Memory and synchronization correctness problems | Diagnostic runs are unsuitable for performance timing |
| `nvidia-smi`, if exposed | Device identity and coarse operating conditions | Utilization does not establish efficient kernel execution |
| Application statistics and A/B experiments | Sensitivity to work size, data shape, layout, dependencies | Usually identifies likely mechanisms, not a unique hardware-level cause |

The reference sections below explain each method. You do not need every tool before starting: CPU timers, CUDA events, and application statistics form a useful minimum.

### Try a software execution trace

First inspect the locally installed CLI:

```bash
nsys --version
nsys profile --help
nsys stats --help-reports
```

Current Nsight Systems documentation exposes `cuda-sw` to request software tracing explicitly. On supported systems, `cuda` can select hardware tracing, which is a separate facility from ordinary software instrumentation. Use this when the installed CLI lists `cuda-sw`:[^2]

```bash
nsys profile --trace=cuda-sw,nvtx \
  --sample=none --cpuctxsw=none \
  --output=cuda_trace ./app
```

On older versions without `cuda-sw`, use the documented `cuda` trace option:

```bash
nsys profile --trace=cuda,nvtx \
  --sample=none --cpuctxsw=none \
  --output=cuda_trace ./app
```

Do not enable GPU metrics or hardware sampling. Check the report's diagnostics to see what was actually collected. Summarize a successful capture with:

```bash
nsys stats \
  --report=cuda_api_sum,cuda_gpu_kern_sum,cuda_gpu_mem_time_sum \
  cuda_trace.nsys-rep
```

Capture a short representative run that exits normally. For focused capture, instrument `cudaProfilerStart()` / `cudaProfilerStop()` and use `--capture-range=cudaProfilerApi`. Verify exact flags against local help.[^2]

If software tracing is also blocked or incompatible, continue with the event-based workflow. Counter denial is not proof that tracing will fail, and tracing availability is not guaranteed merely because CUDA execution works.

### Label application stages

NVTX provides annotations that a tracing tool can associate with your application. NVTX v3 offers a C++ scoped range interface:[^7]

```cpp
#include <nvtx3/nvtx3.hpp>

void submit_step(cudaStream_t stream) {
    nvtx3::scoped_range step{"simulation_step"};
    {
        nvtx3::scoped_range phase{"prepare_work"};
        // CPU work and/or CUDA submissions for this phase.
    }
    {
        nvtx3::scoped_range phase{"solve"};
        // Submit solver kernels to stream.
    }
}
```

Add the SDK include path or use its CMake integration. Use stable names rather than formatting large strings per launch. Annotate the CPU bookkeeping too: it may explain the gaps between GPU operations.

## 3. Establish a trustworthy baseline

### Inspect the build and environment first

NVIDIA explicitly discourages device-debug `-G` for profiling: without an overriding optimization option it disables device optimization. Use line information for source correlation. Enable compiler resource reporting so register and spill information is visible.[^4]

An example single-file build, when compiling on the intended GPU, is:

```bash
nvcc -O3 -lineinfo -std=c++17 -arch=native \
  -Xptxas=-v,-warn-spills app.cu -o app
```

For deployment or compilation elsewhere, select the actual supported target architecture explicitly instead of `native`; configure your existing build system accordingly. Inspect its real compiler commands, including those for CPU-only translation units. Merely naming a build directory “Release” is not evidence of optimization.[^4]

Check for `CUDA_LAUNCH_BLOCKING=1`, which changes launch behavior for debugging, and for forced PTX JIT settings. Record relevant environment overrides rather than leaving them implicit.[^32] Remove per-thread GPU printing and verbose per-launch host logging from timing runs. Keep error checking; detect failed launches and execution errors so an accidentally skipped computation does not look fast.

Record GPU model, driver, toolkit, SM count, VRAM, compiler flags, commit, CPU allocation, and input seed. Use `cudaGetDeviceProperties` once at startup for device properties. If available:

```bash
nvidia-smi
nvcc --version
nvidia-smi --query-gpu=name,driver_version,pstate,temperature.gpu,power.draw,clocks.sm,clocks.mem,utilization.gpu,memory.used,memory.total --format=csv
```

Some fields may be unsupported. Sample operating conditions outside the inner timing loop. GPU utilization is the fraction of a sampling interval with one or more kernels executing; 100% does not mean all SMs, arithmetic units, or memory bandwidth are efficiently used.[^6]

### Check correctness with a small case

Use Compute Sanitizer on a reduced, representative workload before relying on optimizations that change ordering or memory access:[^5]

```bash
compute-sanitizer --tool memcheck ./app
compute-sanitizer --tool initcheck ./app
compute-sanitizer --tool racecheck ./app
compute-sanitizer --tool synccheck ./app
```

These commands run the application separately. Provide your own small-input arguments if required. Run `memcheck` first. `racecheck` principally detects shared-memory hazards; it does not prove that arbitrary global-memory accesses or CPU–GPU interactions are race-free. Sanitizer support itself can depend on the environment. Never report these instrumented runtimes as release performance.[^5]

Define application-specific correctness checks: output tolerances, valid indices, no dropped queue entries, capacity bounds, convergence criteria, or conservation/residual checks appropriate to the algorithm. A faster implementation that silently drops work is a different computation.

### Warm up representative paths, then measure

Create streams, events, buffers, library state, and graphs before steady-state timing. Exercise the kernels and branches that the measured workload will actually use. Keep startup and first-use latency in a separate result; they still matter when they can occur during live operation.

Use fixed input snapshots for kernel comparisons and a recorded input sequence for whole-application comparisons. For a stateful simulation, repeated execution can change object positions, active counts, solver difficulty, or convergence. “Run the same kernel 1,000 times” is not the same experiment as “run the same input 1,000 times.”

Choose explicitly between two modes:

- **Snapshot mode:** restore a known state before each sample; exclude restoration only when measuring the isolated stage, and disclose its effect on cache state.
- **Trajectory mode:** replay the same input sequence from the same initial state; include normal state evolution and compare completion behavior across the sequence.

Collect enough observations for the percentile being reported. A p99 from 100 samples is effectively a statement about a single tail observation. Start with hundreds of steps for gross problems, then use thousands across several representative runs for deadline analysis. Examine individual slow steps and their workload statistics.

### Measure three different quantities

| Quantity | Start | Finish | Interpretation |
|---|---|---|---|
| Host submission time | Before submitting work | After submission returns | CPU dispatch and submission-path overhead |
| GPU interval | Event before the region | Event after its dependent work | Device-timeline elapsed time for the region |
| End-to-end latency | Input becomes available / CPU preparation starts | Required output is complete and usable | The metric to compare against the application deadline |

CUDA events report milliseconds with approximately 0.5 microsecond resolution. Record both events in the intended stream, ensure the stop event has completed, then calculate elapsed time. Other work can affect the interval, so this is elapsed time, not an exclusive measure of the kernel's execution resources.[^3]

For a single-stream step:

```cpp
const auto begin = std::chrono::steady_clock::now();
prepare_cpu_inputs();
enqueue_uploads_kernels_and_required_downloads(stream);
CUDA_CHECK(cudaEventRecord(done, stream));
CUDA_CHECK(cudaEventSynchronize(done));
consume_required_cpu_output();
const auto end = std::chrono::steady_clock::now();
const double latency_ms =
    std::chrono::duration<double, std::milli>(end - begin).count();
```

This is an integration sketch: supply the application functions and the error-checking helper from Appendix A. Preallocate `done`. It assumes no unrelated backlog at the start and that all required work belongs to this stream or has explicitly joined it.

For multiple streams, record a common start event, make each worker stream wait for it, record a completion event on each worker after its required work, then make a joining stream wait for every completion before recording the stop event. Dependencies, not adding durations, define the measured interval.[^10]

In a pipelined production loop, do not add a new blocking wait after every step solely for instrumentation. Retain each step's start timestamp and completion event in a reusable ring. Query completed entries later. CPU observation can lag actual completion, so distinguish observed readiness from exact GPU interval timing and keep queue depth visible.

### Avoid perturbing the behavior being measured

Start with a few stage events, then zoom in. Recording and waiting after every tiny kernel can change scheduling. Prefer recording several events and resolving them at an existing completion boundary. Keep detailed tracing and final uninstrumented acceptance measurements separate.

For tiny stateless kernels, batch repeated launches to improve measurement resolution; report the result as a batch average. An event interval around a host launch loop can include gaps while the CPU submits more work. It is not automatically pure kernel time. Appendix A demonstrates this distinction.

Alternate baseline and candidate runs—such as A/B/B/A—rather than doing every baseline before every candidate. Keep warm-up, input, backlog, and instrumentation comparable. If a claimed 2% gain moves with run order or disappears outside a profiler, treat it as unresolved.

## 4. Turn measurements into a bottleneck hypothesis

Build one table for the busiest representative step and another for a deadline-missing step. Include stage name, call count, total and maximum duration, input/output counts, bytes copied, CPU readbacks, and allocations. Group repeated kernels by their role in the application when the same kernel serves several stages.

Prioritize total contribution and critical-path position. One 3 ms kernel might matter less than a 15 microsecond kernel launched 400 times. Conversely, a kernel's percentage of summed GPU time is not its percentage of wall-clock time when operations overlap.

### Read a trace without confusing waiting with work

The CPU launch call, the time before the kernel begins, and the kernel's execution interval are different quantities. Long launch-to-start delay can simply mean earlier queued work is still executing. NVIDIA's explanation of Nsight timelines distinguishes those cases and discusses instrumentation overhead.[^8]

| Observation | Working hypothesis | Next experiment |
|---|---|---|
| GPU gaps align with CPU preparation | Host work is delaying submission | Time that preparation; replay prebuilt commands in a diagnostic run |
| Many short kernels separated by gaps | Dispatch or dependencies matter | Compare repeated graph replay with ordinary submission |
| Long `cudaDeviceSynchronize` call | CPU is waiting for previously submitted work | Locate the GPU work it waits for; test whether this wait is needed here |
| Tiny device-to-host copy before each phase | A host decision forces a round trip | Keep the decision/count on device in a variant |
| Long kernels with few CPU gaps | Device-side work matters | Isolate dominant kernels; sweep size, layout, and work distribution |
| Spikes coincide with allocations or first-use paths | Resource setup is exposed | Preallocate or exercise that path before the timed sequence |
| Same item count, very different time | Data shape changes actual work | Record iteration lengths, degree, occupancy of bins, and contention proxies |
| Steady slowdown across unrelated kernels | Platform conditions or larger state may matter | Replay the same snapshot; compare clocks, memory footprint, and other available telemetry |

These are hypotheses. A long synchronization call is often where time is observed, not the operation that consumed it. Removing a necessary wait only moves that wait elsewhere or introduces a race.

## 5. The highest-value optimization opportunities

### 5.1 Remove avoidable CPU–GPU round trips

Audit every value the CPU reads during a step. For each value, ask: “Does a CPU consumer need this now, or does only the next GPU operation need it?” The amount of CPU code is a poor proxy for its effect on latency.

Consider a sequence that generates candidates, copies a candidate count to the CPU, waits, computes a launch size, and launches processing. A four-byte count can expose the entire producer's completion latency. The synchronous device-to-host copy does not return until its copy completes; pageable memory can also make supposedly asynchronous copies block or stage data.[^9]

**Experiment:** retain the count in device memory and launch a bounded grid whose threads read that count and process entries with a grid-stride loop. Put producer and consumer in the same stream, or express the dependency with an event. Preserve capacity checks and overflow handling. Compare whole-step latency, including any extra inactive-thread work.

For convergence loops, a useful variant checks convergence on the CPU every small group of iterations instead of after each iteration. Another uses a device-resident completion flag that later iterations consult. Both need carefully defined semantics: extra iterations can cost time or change results, and early exits must remain compatible with block-wide synchronization. Treat these as algorithm changes to validate.

Keep genuinely useful CPU work on the CPU when it can run independently. Metadata that changes rarely can be uploaded in batches. Optional diagnostics can often consume an earlier completed snapshot, provided the application explicitly tolerates stale information. The goal is to eliminate unnecessary dependency edges, not to move every line of C++ onto the GPU.

### 5.2 Reuse memory, streams, events, and temporary storage

Search hot loops for allocation, deallocation, container growth, resource construction, and full-capacity clearing. Preallocate reusable storage for the expected operating range and define an explicit exceptional-growth path. On the CPU, reserve vectors and reuse staging buffers where measurements show allocation or copying costs.

CUDA's stream-ordered allocator provides `cudaMallocAsync` and `cudaFreeAsync` with pool-based reuse. Cross-stream access must be ordered after allocation and before deallocation. Pool release policy matters: synchronization can allow unused memory to be returned depending on the configured threshold. Traditional allocation can introduce expensive synchronization.[^13]

**Experiment:** replace per-step temporary allocation with a persistent buffer of the same size. This isolates allocation/lifetime overhead more cleanly than changing the entire memory-management subsystem at once. If dynamic sizes make persistence awkward, evaluate a bounded memory pool and its retention behavior.

Count bytes cleared as well as bytes allocated. If a step clears a two-million-entry array but uses only 20,000 entries, consider clearing the used range, resetting only counters, or tracking validity with generation tags. Tags introduce wraparound and stale-entry handling; a small explicit clear may remain simpler and faster.

When using CUB's traditional interface, query scratch requirements, allocate sufficient storage, and reuse it across executions. Requirements depend on the API, types, and problem shape. Concurrent operations must not share writable scratch unless their use is ordered.[^28] Newer CUB interfaces can manage scratch through an execution environment; verify behavior in the installed version rather than assuming every convenient call is allocation-free.[^29]

### 5.3 Use CUDA Graphs when repeated submission matters

Graphs represent operations and their dependencies for repeated execution. They can be constructed explicitly or through compatible stream capture. Capture has restrictions: code that requires host synchronization or unsupported operations cannot simply be wrapped unchanged. Graph parameters and updates need deliberate handling.[^14]

A good first candidate is a stable repeated stage with many small launches. Build and instantiate outside steady-state timing, exercise the first launch, then compare replay with the original stage. Keep pointer lifetimes stable and include recurring graph-update costs in the application result. Rebuilding the graph every step may erase the benefit.

NVIDIA has demonstrated substantial reductions in repeated CPU launch overhead, including a consumer RTX 3060 example. Its reported microsecond values depend on graph shape, architecture, software, and host system; they are not universal launch costs. Graphs can also affect device-side gaps, so compare time to completed output, not only CPU submission.[^15]

**Experiment:** capture one repeated section, change no kernel math, and compare A/B latency. If submission time falls but step time stays constant, graph replay was not on the limiting path under that workload. Keep the change only if its other benefits justify the complexity.

### 5.4 Fuse kernels when it removes meaningful overhead or traffic

Suppose stage A writes an intermediate array and stage B immediately reads it. Fusion can avoid that write/read round trip and a launch when both stages can perform the required per-item work together. Write down exactly which bytes and operations disappear; then measure both stage time and overall time.

Fusion can increase live registers, make branches less uniform, or combine stages that want different launch configurations. It can also remove a required synchronization boundary. Two kernels ordered in a stream provide a producer/consumer ordering that an ordinary fused kernel does not automatically reproduce across blocks.[^10][^18]

**Experiment:** fuse a small pair of per-item stages first. Compare emitted resource usage and correctness alongside timing. If stage B reads neighboring items produced by arbitrary blocks of stage A, preserve a valid global synchronization mechanism; `__syncthreads()` only coordinates a block. Avoid improvised whole-grid spin barriers, which can deadlock when waiting blocks prevent unscheduled producers from running.

Use graphs to investigate dispatch overhead without changing kernel bodies, then consider fusion where eliminating intermediate data movement offers additional value. Neither technique substitutes for checking the algorithm's dependencies.

### 5.5 Reduce the amount of work before making each operation faster

This is especially valuable for simulations, spatial algorithms, and dynamic graphs. Record how much useful work actually exists, not just the maximum allocation capacity.

Look for full scans of mostly inactive data, repeated sorting of nearly unchanged keys, rebuilding topology that did not change, rediscovering the same relationships, or evaluating expensive predicates for obviously irrelevant items. Also check nested loops: a parallel outer loop does not remove quadratic total work.

**Experiment:** hold total capacity fixed and vary the fraction of active items. If runtime barely changes, inspect how much of the full array is still visited. Compare an explicit active list with the existing representation, including list maintenance and any gather/scatter cost.

An active list is worthwhile when:

`list maintenance + processing active entries + indirection < scanning all entries`

The crossover depends on density, locality, update frequency, and per-item cost. If only a small region changes, also compare incremental repair with a full rebuild. Keep a correctness fallback for exceptional updates; report how often it runs and its tail cost.

### 5.6 Fix memory access at the warp level

Adjacent threads should, where practical, access adjacent useful data. Inspect one executed load or store across the 32 lanes of a warp. Looking only at whether one thread walks a contiguous region misses the main coalescing question.[^16]

For example, an array of large `Body` records might be convenient for CPU code, but a kernel that reads only `position.x` touches widely separated fields. A structure-of-arrays layout places those x values together. An array-of-structures-of-arrays can be a useful compromise. The best representation depends on which fields each hot kernel consumes together.

**Experiment:** change the layout of one dominant field or hot subset. Measure the full group of affected kernels and include conversion/reordering costs. Do not declare structure-of-arrays universally better: later kernels may consume whole records, and arbitrary indirect indices can defeat locality in either layout.

For indirect access, compare a semantically equivalent local ordering with the current ordering, including the cost of producing that order. For multidimensional arrays, check the mapping of `threadIdx.x` to the fastest-varying dimension. Vectorized loads can reduce memory-instruction count when alignment, bounds, and data use support them; they do not automatically reduce total bytes.[^31]

### 5.7 Use shared memory for a specific reuse or layout benefit

Shared memory is valuable when threads can reuse loaded data or reorganize accesses. A classic transpose loads a tile with coalesced accesses and writes it out in a different arrangement. Padding can remove a particular shared-memory bank-conflict pattern; the familiar 32-by-33 float tile is a technique for that access pattern, not a universal padding rule.[^21]

**Experiment:** state the benefit before coding: “This tile replaces repeated loads of these values” or “This changes the output access pattern.” Include tile loading, synchronization, and edge handling in the benchmark. Sweep a small set of tile sizes on representative inputs.

If each element is loaded once and used once with an already efficient access pattern, staging everything through shared memory may add work. A larger tile can also reduce how many blocks fit on an SM. Judge the complete kernel, not the isolated speed of a shared-memory access.

### 5.8 Audit registers and thread-local arrays

Registers are finite on-chip storage. A large per-thread working set can limit block residency or cause spills. Thread-local arrays with runtime indexing and large local structures may reside in device-backed local memory even when compiler spill counts are zero. “Local” describes ownership, not necessarily fast physical storage.[^18]

Inspect the final binary:

```bash
cuobjdump --dump-resource-usage ./app
cuobjdump --dump-sass ./app > app.sass.txt
```

`cuobjdump` accepts executables and CUDA binary files; `nvdisasm` provides richer analysis for cubin files. Read architecture-appropriate machine instructions, not just PTX, to see the actual compiled implementation.[^20]

**Experiment:** shorten variable lifetimes, process a smaller per-thread tile, reduce an over-unrolled loop, or separate an unusually large temporary calculation. Compare register/local-memory usage and runtime. Do not force a low register limit merely to raise occupancy; that can introduce more spilling or instructions.

A source declaration such as `float scratch[64]` is a reason to investigate, not proof of a bottleneck. The compiler may scalarize it, place it in local memory, or optimize parts away. Conversely, “zero spills” does not establish that all thread-local state stayed in registers.

### 5.9 Tune launch shape and task granularity

Occupancy is the fraction of possible resident warps that are active on an SM. Higher occupancy is not a performance target by itself. NVIDIA suggests 128–256 threads per block as a starting range; the best choice depends on registers, shared memory, block shape, and the workload.[^17]

Use `cudaOccupancyMaxActiveBlocksPerMultiprocessor` with the real kernel, block size, and dynamic shared-memory size to estimate potential residency. This calculation does not use performance counters and does not measure achieved occupancy.[^19]

**Experiment:** test supported block sizes such as 64, 128, 256, and 512, respecting kernel assumptions. Record total blocks, registers, shared memory, and time. For a 2D kernel, preserve or deliberately test the memory-access mapping as you change shape; equal thread counts do not imply equivalent accesses.

Then ask what one unit of parallel work should be. One thread per object is convenient but can be poor when one object requires thousands of interactions. Compare a thread per interaction, a warp per moderate task, or a block per larger task. Include the cost of assembling and combining work.

Grid-stride loops decouple grid size from problem size while keeping adjacent lanes on adjacent indices for simple linear data. They are useful for launch sweeps and bounded grids; they do not imply that a tiny grid or persistent kernel is optimal.[^25]

### 5.10 Investigate divergence, imbalance, and atomic contention separately

These problems can coexist but are different. Divergence means lanes in a warp follow different work paths. Imbalance means some tasks, warps, or blocks have much more work. Contention means many operations compete to update the same location.

For variable-length tasks, record a histogram of iterations or interactions per item, plus the maximum. Compare equal total work distributed evenly with work concentrated in a few items. A kernel can finish most of its work quickly and then wait for a small number of stragglers. A small final wave of blocks can also leave much of the GPU idle.[^24]

**Experiment:** split high-cost tasks or bucket tasks by size/type. Measure the bucketing overhead. Compare behavior at the same total work count so a change in candidate generation does not masquerade as better scheduling.

For atomics, compare a uniform destination distribution with a concentrated one while holding the number and type of updates fixed. Strong sensitivity suggests contention, though changed locality also matters. Try private partial results with a later reduction, or aggregation at warp/block scope. Include extra storage and merge cost.

Warp aggregation can combine several updates to the same counter. NVIDIA notes that the compiler automatically performs some such transformations, so inspect or benchmark generated code before adding a manual version. Aggregating arbitrary keyed floating-point updates needs additional grouping and numerical validation.[^22]

Do not implement warp communication by assuming lanes always advance together. Use supported synchronization and collective primitives with correct participant masks; all named participating lanes must obey the collective's contract. Calling `__activemask()` inside a divergent region does not necessarily recover the complete group you intended to participate.[^23]

### 5.11 Make precision and arithmetic intentional

Audit accidental double precision, especially unsuffixed literals and mismatched math overloads. For an intentionally FP32 calculation, use appropriately typed constants and functions, then inspect the emitted instructions. Do not assume one fixed FP64-to-FP32 throughput ratio across all consumer GPUs.

Replace repeated invariant work with a precomputed value where doing so preserves the intended behavior. Investigate expensive special functions or divisions only when the hot path and compilation report justify it. A memory-limited kernel may barely improve when arithmetic is reduced.

Changing precision, reduction order, fusion, reciprocal approximations, or fast-math settings can change numerical behavior. NVIDIA's floating-point guidance explains why even valid implementations can differ. Define acceptable error and test representative difficult cases before accepting such changes.[^27]

**Experiment:** first eliminate unintended precision promotions without broadly enabling fast math. Then evaluate any approximation separately, measuring both error and time. For an iterative solver, compare time to the same residual or quality criterion; a faster iteration that needs more iterations may be a regression.

### 5.12 Check managed-memory migration and transfer design

Managed memory can migrate pages between CPU and GPU. A first GPU access to CPU-resident data can incur faults and movement; repeated CPU inspection can also change residency. Explicit prefetching can help appropriate workloads, but it does not remove transfer costs or make oversubscription free.[^26]

**Experiment:** compare a representative stage using explicitly device-resident storage and bounded transfers against the current managed-memory path. Keep initialization and required output movement equivalent. If you test prefetching, measure the full step including prefetch, not just the kernel after its data has been moved elsewhere in the schedule.

For explicit transfers, reduce bytes and batch small copies before trying elaborate overlap. Use persistent pinned staging buffers where asynchronous host/device transfers are needed, and avoid excessive pinning. Keep repeated GPU-consumed state on the device when possible.[^11]

Transfer/compute overlap needs suitable hardware, independent work, appropriate streams, and pinned host memory. A copy and dependent kernel in one stream remain ordered. A multi-buffer pipeline also needs buffer ownership rules so the CPU does not overwrite an upload source or read an unfinished download.[^12]

Check default-stream semantics explicitly. Work submitted to the legacy default stream can implicitly serialize work in other blocking streams. Explicit streams created with `cudaStreamNonBlocking` avoid that implicit relationship; per-thread default-stream mode is another option, with compilation-unit implications. Neither creates the dependencies your program still needs.[^33] Audit library stream settings as well. Introduce explicit event ordering before removing implicit ordering, and verify actual overlap rather than assuming more streams must be faster.

If simulation state is immediately rendered through a graphics API, investigate supported CUDA/graphics interoperability in that actual stack. A full download followed by a graphics upload is a candidate to eliminate, but interoperability availability depends on the APIs and cloud setup. Measure it as a transfer-path change, not as kernel tuning.

### 5.13 Compare handwritten primitives with CUB

CUB supplies optimized reduction, scan, selection, sorting, and other collective operations at several scopes.[^34] They are useful reference implementations when custom code has a serial bottleneck or a naive multi-pass algorithm.

| Operation in your code | CUB family to investigate |
|---|---|
| Sum or aggregate an array | `DeviceReduce` |
| Prefix sum for output offsets | `DeviceScan` |
| Build a compact active list | `DeviceSelect` |
| Sort integer or radix-compatible keys | `DeviceRadixSort` |
| Combine values inside a custom kernel | `BlockReduce` or `WarpReduce` |

**Experiment:** replace one standalone primitive and compare at identical size, type, ordering, and numerical requirements. Include scratch storage, allocation policy, output-count handling, and any format conversion. A fused application-specific kernel may still win by avoiding passes that a standalone library call requires. Treat the library result as evidence about what is achievable, not a mandate to replace every custom kernel.

## 6. Diagnose kernels with controlled experiments

Without counters, the strongest approach is triangulation: use a source-level hypothesis, a measurement that should respond to it, and a second observation that checks an alternative explanation. The following experiments are recommendations for doing that. They are not guaranteed classifiers.

| Hypothesis | Change one variable | Evidence that supports it | What could mislead you |
|---|---|---|---|
| Fixed submission overhead matters | Vary input size over an order of magnitude; try graph replay | Small-input time changes little; graph reduces completion time | Cache effects or a constant amount of algorithmic work |
| Work scales poorly | Measure several sizes and count actual operations | Time follows superlinear candidate/interaction growth | Changing density or convergence difficulty |
| Layout/locality matters | Change ordering/layout while preserving the result | Net improvement after conversion and sorting costs | A different work distribution or cache footprint |
| Excess memory traffic matters | Remove a verified intermediate write/read pass | Stage and end-to-end time fall consistently | Fusion also changes registers, instructions, and scheduling |
| A few tasks dominate | Equalize work distribution at fixed total work | Lower time with reduced longest-task length | Reordering improves locality at the same time |
| Atomic collisions matter | Sweep destination concentration at fixed update count | Concentrated updates are much slower | Different cache residency or compiler aggregation |
| Resource pressure matters | Reduce local state or change block size | Timing tracks a resource threshold or disappears with fewer local accesses | Multiple code-generation effects change together |
| CPU decisions limit progress | Replay precomputed decisions or use device-resident counts | GPU gaps and completed-step latency shrink | The diagnostic path skips required work |

For every experiment, preserve output observability. Replacing expensive math with a constant can let the compiler delete loads, branches, or whole loops. A “memory-only” variant that writes nothing useful may tell you nothing about the original kernel. Inspect compiled code when interpreting such ablations.

### Estimate useful bandwidth, and label it honestly

For a simple elementwise kernel reading two FP32 arrays and writing one FP32 array, the logical traffic is `12 × N` bytes. Effective bandwidth is logical bytes divided by elapsed time. NVIDIA distinguishes effective bandwidth based on requested work from actual memory-system traffic.[^17]

For an illustrative `N = 10,000,000` and `t = 0.30 ms`:

`120,000,000 bytes / 0.00030 seconds = 400 GB/s`

This is an invented arithmetic example, not a measurement of your GPU. It does not establish DRAM throughput: cache hits, extra transactions, write behavior, spills, and repeated accesses can change the relation between logical bytes and physical memory traffic.

Create a same-machine streaming reference with comparable reads, writes, size, and cache conditions. Use a sufficiently large working set for a DRAM-oriented test, within available memory. A copy-engine device-to-device transfer can be a useful reference but is not identical to a load/store kernel. Also test the warm-cache behavior that the application actually has.

For planning, an optimistic roofline-style estimate is:

`time ≳ max(required bytes / achievable bandwidth, operations / achievable compute rate)`

Use this only with explicitly stated traffic, cache, operation-type, and concurrency assumptions. A measured streaming benchmark is a reference, not a rigorous upper bound for every other kernel. FP32 arithmetic throughput does not bound the rate of integer address calculations, atomics, or transcendental functions.

Low effective bandwidth alone cannot distinguish poor coalescing, pointer chasing, contention, insufficient parallelism, computation, or CPU starvation. High logical bandwidth can reflect cache reuse or an incomplete byte model. Report the model and timing together.

### Count algorithmic work in software

Add low-overhead per-stage statistics: active items, candidates, accepted items, iterations, bucket sizes, queue high-water marks, allocation growth, and bytes reset. These are application counters, not restricted GPU hardware counters.

Avoid adding a contended global atomic for every event solely to diagnose performance. Prefer sampled recording, per-block partial statistics, or a separate diagnostic pass. Resolve and copy statistics after the timed region where possible, and compare instrumented and uninstrumented behavior.

For an irregular solver, “5 ms per step” is much more informative when accompanied by “200,000 active constraints, 12 iterations, longest adjacency 430.” It lets you distinguish a slower kernel from a workload that became harder.

## 7. A practical first-pass code audit

Run these searches from the source root, excluding generated and vendored code as appropriate. Matches are review candidates, not automatic defects. In particular, keep synchronization that enforces a real dependency.

```bash
rg -n 'cuda(Device|Stream|Event)Synchronize|cudaMemcpy\(|cudaMemcpyAsync' src
rg -n 'cudaMalloc|cudaFree|cudaHostAlloc|cudaMallocHost|cudaMemset' src
rg -n 'cudaStreamCreate|cudaEventCreate|cudaGraphInstantiate|cudaGraphLaunch' src
rg -n 'cudaMallocManaged|__managed__|cudaMemPrefetchAsync' src
rg -n 'atomic(Add|CAS|Exch|Min|Max)|__syncthreads|__syncwarp' src
rg -n 'thrust::|cub::|printf\(|std::endl|\.resize\(|\.push_back\(' src
rg -n 'double|pow\(|sqrt\(|sin\(|cos\(|exp\(|log\(' src
```

Then trace a single step through the code and answer these questions in order:

1. Which functions wait for GPU completion? What exact consumer needs each wait?
2. Which CPU reads exist only to select a launch size, branch, or loop termination condition?
3. What is allocated, freed, initialized, resized, or constructed repeatedly?
4. How many kernels, copies, and host decisions occur per step and per solver iteration?
5. Which stages scan capacity rather than active work, and which structures are rebuilt unnecessarily?
6. What addresses do adjacent lanes access in the hottest kernels? Which fields are unused?
7. Which threads/tasks have the longest loops? Which atomic destinations are concentrated?
8. What do the final compiler reports show for local storage and registers?
9. Does each optimization preserve output, capacities, buffer lifetimes, and convergence requirements?

Inspect library calls as well as handwritten code. A host-returned reduction result or data-dependent output length can introduce a completion dependency even if the call looks like ordinary C++. Check the actual API contract and trace. A stream parameter alone does not prove that the host never waits.

CPU bookkeeping deserves ordinary C++ analysis: nested container copies, sorting, map lookups, heap churn, formatting, locking, and repeated reconstruction of dispatch metadata. Time those regions independently. If CPU sampling is unavailable, coarse `steady_clock` scopes plus workload counts are enough to locate large costs. Optimize CPU work that is on the submission or completion path first.

## 8. Special considerations for simulation and irregular workloads

For this workload class, start with a work ledger alongside the timing table. The following are design-review questions, not assumptions about a particular physics engine.

| Stage or data | Record | Question to investigate |
|---|---|---|
| Active state | Total capacity, active count, transitions per step | Can inactive state be omitted from most passes? |
| Candidate generation | Candidates and accepted interactions | Is excessive candidate growth causing the expensive downstream work? |
| Spatial partition | Cell/bin populations and maxima | Do dense regions create quadratic work or hotspots? |
| Constraint/graph processing | Edge counts, degree distribution, iterations | Does the mapping handle high-degree items efficiently? |
| Topology changes | Changed elements and rebuilt elements | Can updates be restricted to affected regions? |
| State snapshots | Bytes saved/restored and frequency | Is full-state copying necessary for each event? |
| Recovery/resimulation | Extra steps, affected region, worst-case count | Does exceptional work dominate deadline misses? |
| Output/telemetry | Bytes and age requirements | Which outputs must be fresh for this step? |

Compare throughput at the same physical or algorithmic quality. Reducing solver iterations, collision checks, update frequency, or rollback scope can change the computation. Such changes may be legitimate design choices, but they should not be presented as equivalent low-level optimizations without validating the consequences.

Also separate the number of simulation steps from the number of rendered frames. If one frame sometimes requires multiple catch-up or recovery steps, speeding up the average step is insufficient unless the burst still fits the application's policy. Record backlog and recovery behavior, not just mean GPU time.

For bursts, compare several strategies on the recorded workload: reserving capacity in advance, incremental maintenance, earlier detection of exceptional work, or a documented quality/time tradeoff. Do not silently cap work queues or drop constraints to manufacture a passing frame-time result.

## 9. Turn findings into an optimization plan

### The first focused session

**First, establish truth.** Write down the deadline, build flags, input sequence, and completion definition. Capture an uninstrumented baseline with stage-level event timing and host timing in a separate diagnostic run. Check correctness on a small case.

**Next, identify the largest opportunity.** Obtain a short software trace if available. Otherwise combine stage timing with counts of launches, transfers, waits, and allocations. Estimate whether your leading hypothesis could close a meaningful portion of the deadline gap.

**Then, run one discriminating experiment.** Examples are persistent scratch storage, device-resident counts, graph replay of one repeated stage, or a corrected field layout. Choose the smallest change that can test the hypothesis.

**Finally, validate in context.** Replay the representative application workload without the profiler. Keep the change only when it improves the target metric with acceptable correctness, memory, and complexity. Update the timing table because the bottleneck may have moved.

### Use a compact experiment log

| Field | What to write |
|---|---|
| Hypothesis | A causal claim, such as “one host count readback per iteration stalls dispatch” |
| Evidence | Trace interval, stage timing, launch count, or work statistic |
| Change | The one mechanism being varied |
| Measurement | Input, warm-up, repetitions, cache/reset policy, queue depth |
| Result | Baseline/candidate latency and spread; deadline misses |
| Correctness | Tolerance, residual, invariants, and capacity behavior |
| Cost | Additional memory, setup, CPU work, or implementation complexity |
| Decision | Keep, reject, or inconclusive; what to investigate next |

An inconclusive result is useful. It prevents a plausible story from turning into permanent complexity. If an optimization helps one input class and hurts another, retain that distinction rather than averaging it away.

### Acceptance checklist

- [ ] The measured boundary includes the completed result the application needs.
- [ ] Baseline and candidate use the same release configuration and workload semantics.
- [ ] Startup, cache warm-up, and state-reset behavior are documented.
- [ ] CPU, GPU, and transfer intervals are not incorrectly added despite overlap.
- [ ] Improvement persists in unprofiled application runs and across alternating run order.
- [ ] Deadline misses and exceptional workloads are evaluated, not only average throughput.
- [ ] Correctness, convergence, capacity, and asynchronous buffer lifetimes remain valid.
- [ ] Additional memory and recurring setup/rebuild costs are included.
- [ ] The remaining gap to the real-time target is explicit.

Defer persistent kernels, handwritten PTX, elaborate multi-stream scheduling, architecture-specific asynchronous pipelines, and blanket fast math until a measured bottleneck gives them a clear purpose. They can be valuable, but they require more evidence and validation than removing an unnecessary round trip or full-array pass.

## Appendix A. Minimal CUDA event benchmark

Save the following code as `benchmark.cu` and build it with the compiler command from section 3, replacing the source and output names. It requires CUDA and C++17. This example was reviewed against the documented API contracts; it has not been compiled or executed on a CUDA system as part of this guide.

The kernel overwrites output from unchanged input, so repetitions do not evolve the workload. Allocation, initial upload, warm-up, validation, and printing are outside the timed batches. Launch error checking remains inside the submission path. The reported p95 is a **p95 of per-batch averages**, not a frame-latency percentile.

```cpp
#include <cuda_runtime.h>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <vector>

inline void check_cuda(cudaError_t status,
                       const char* expression,
                       const char* file, int line) {
    if (status != cudaSuccess) {
        std::fprintf(stderr, "%s:%d: %s: %s\n", file, line,
                     expression, cudaGetErrorString(status));
        std::exit(EXIT_FAILURE);
    }
}
#define CUDA_CHECK(expr) \
    check_cuda((expr), #expr, __FILE__, __LINE__)

__global__ void affine(const float* input, float* output, int n) {
    const int stride = blockDim.x * gridDim.x;
    for (int i = blockIdx.x * blockDim.x + threadIdx.x;
         i < n; i += stride) {
        output[i] = 2.0f * input[i] + 1.0f;
    }
}

double percentile(std::vector<double> values, double fraction) {
    std::sort(values.begin(), values.end());
    // Nearest-rank percentile; caller supplies nonempty samples.
    const auto rank = static_cast<std::size_t>(
        std::ceil(fraction * values.size()));
    const auto index = std::min(values.size() - 1,
        rank == 0 ? std::size_t{0} : rank - 1);
    return values[index];
}

int main() {
    CUDA_CHECK(cudaSetDevice(0));
    cudaDeviceProp properties{};
    CUDA_CHECK(cudaGetDeviceProperties(&properties, 0));

    constexpr int n = 1 << 22;
    constexpr int block_size = 256;
    constexpr int warmup = 20;
    constexpr int repeats = 100;
    constexpr int samples = 31;
    const int grid_size = 32 * properties.multiProcessorCount;
    const std::size_t bytes = std::size_t{n} * sizeof(float);

    cudaStream_t stream{};
    cudaEvent_t start{}, stop{};
    CUDA_CHECK(cudaStreamCreateWithFlags(&stream,
                                         cudaStreamNonBlocking));
    // Timing must be enabled on these events.
    CUDA_CHECK(cudaEventCreate(&start));
    CUDA_CHECK(cudaEventCreate(&stop));

    float* d_input = nullptr;
    float* d_output = nullptr;
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&d_input), bytes));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&d_output), bytes));
    std::vector<float> input(n), output(n);
    for (int i = 0; i < n; ++i)
        input[i] = static_cast<float>((i % 101) - 50) * 0.125f;

    CUDA_CHECK(cudaMemcpy(d_input, input.data(), bytes,
                           cudaMemcpyHostToDevice));
    // Explicitly finish setup before using a nonblocking stream.
    CUDA_CHECK(cudaDeviceSynchronize());

    auto enqueue = [&] {
        affine<<<grid_size, block_size, 0, stream>>>(
            d_input, d_output, n);
        CUDA_CHECK(cudaGetLastError());
    };

    for (int i = 0; i < warmup; ++i) enqueue();
    CUDA_CHECK(cudaStreamSynchronize(stream));

    std::vector<double> device_ms, completed_ms, submitted_ms;
    device_ms.reserve(samples);
    completed_ms.reserve(samples);
    submitted_ms.reserve(samples);

    for (int sample = 0; sample < samples; ++sample) {
        // No previous batch remains outstanding here.
        const auto begin = std::chrono::steady_clock::now();
        CUDA_CHECK(cudaEventRecord(start, stream));
        for (int r = 0; r < repeats; ++r) enqueue();
        CUDA_CHECK(cudaEventRecord(stop, stream));
        const auto submitted = std::chrono::steady_clock::now();
        CUDA_CHECK(cudaEventSynchronize(stop));
        const auto completed = std::chrono::steady_clock::now();

        float elapsed = 0.0f;
        CUDA_CHECK(cudaEventElapsedTime(&elapsed, start, stop));
        device_ms.push_back(elapsed / repeats);
        submitted_ms.push_back(
            std::chrono::duration<double, std::milli>(
                submitted - begin).count() / repeats);
        completed_ms.push_back(
            std::chrono::duration<double, std::milli>(
                completed - begin).count() / repeats);
    }

    CUDA_CHECK(cudaMemcpy(output.data(), d_output, bytes,
                           cudaMemcpyDeviceToHost));
    for (int i = 0; i < n; ++i) {
        const float expected = 2.0f * input[i] + 1.0f;
        if (!std::isfinite(output[i]) ||
            std::fabs(output[i] - expected) > 1e-6f) {
            std::fprintf(stderr, "Validation failed at %d\n", i);
            return EXIT_FAILURE;
        }
    }

    std::printf("GPU: %s; SMs: %d\n", properties.name,
                 properties.multiProcessorCount);
    std::printf("Each sample averages %d launches.\n", repeats);
    std::printf("Device interval: median %.6f, p95 %.6f ms/launch\n",
        percentile(device_ms, 0.5), percentile(device_ms, 0.95));
    std::printf("Host submission: median %.6f ms/launch\n",
        percentile(submitted_ms, 0.5));
    std::printf("Completed batch: median %.6f ms/launch\n",
        percentile(completed_ms, 0.5));

    CUDA_CHECK(cudaFree(d_input));
    CUDA_CHECK(cudaFree(d_output));
    CUDA_CHECK(cudaEventDestroy(start));
    CUDA_CHECK(cudaEventDestroy(stop));
    CUDA_CHECK(cudaStreamDestroy(stream));
    return EXIT_SUCCESS;
}
```

Interpretation and adaptation:

- The input/output footprint may fit in cache on some GPUs. This intentionally permits warm-cache behavior; it is not a DRAM bandwidth benchmark by default.
- Device intervals can include host-submission gaps and other GPU interference. The host measurements include event API calls and launch error checks.
- Neither host figure includes application input preparation, required transfers, or output consumption. Use section 3's application boundary to measure actual step latency.
- For a stateful kernel, design snapshot restoration or trajectory replay before reusing this repetition loop.
- Increase or decrease batch size so timing is stable without hiding the application's relevant behavior. For real-time tails, collect actual per-step samples rather than batch averages.

NVBench is an optional next step when many kernel parameters need systematic sweeps. It supports parameter axes, timing modes, and structured output; its cold-cache and batched measurements answer different questions. Use timing-only functionality in a restricted environment and do not depend on privileged clock control or hardware-metric collection.[^30]

## Appendix B. A reusable performance brief

Fill this in before a code review or optimization session:

```text
Target:
  Update frequency:
  CUDA subsystem budget:
  Latency / throughput / deadline requirement:
  Required output freshness:

Environment:
  GPU model and SM count:
  Driver / CUDA / compiler / Nsight versions:
  CPU allocation and cloud sharing information, if known:
  Build flags, commit, and relevant environment overrides:
  Available diagnostics: events / software trace / sanitizer / telemetry:

Workload:
  Reproduction command and input seed or recording:
  Startup versus steady-state boundary:
  Snapshot reset or trajectory replay:
  Active count, capacity, interactions, iteration distribution:
  Correctness and quality acceptance criteria:

Baseline:
  Completed-step median / p95 / p99 / observed maximum:
  Sample count, run duration, misses, and consecutive misses:
  CPU submission and preparation time:
  Major GPU stage intervals:
  Launches / readbacks / bytes transferred / allocations per step:
  Queue depth and memory high-water mark:

Leading hypothesis:
  Evidence:
  Estimated maximum useful time saving:
  Smallest discriminating experiment:
  Result and correctness check:
  Keep / reject / inconclusive:
```

## Sources

Numbered notes link to primary NVIDIA documentation and engineering articles. Older articles are used for enduring mechanisms, not their historical hardware performance figures. Live documentation should be matched to the installed release; the CCCL links below explicitly point to its development documentation. All online references were accessed September 9, 2026.

[^1]: NVIDIA. [ERR_NVGPUCTRPERM: Permission issue with Performance Counters](https://developer.nvidia.com/nvidia-development-tools-solutions-err_nvgpuctrperm-permission-issue-performance-counters). Live support documentation. Counter and tracing permissions.

[^2]: NVIDIA. [Nsight Systems User Guide](https://docs.nvidia.com/nsight-systems/UserGuide/index.html). Live documentation; sections “CLI Profile Command Switch Options,” “CUDA trace methods,” and report scripts. Software tracing, CLI flags, focused capture, and diagnostics.

[^3]: NVIDIA. [CUDA Runtime API: Event Management](https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__EVENT.html). CUDA Toolkit documentation, `cudaEventElapsedTime`, recording, and completion semantics.

[^4]: NVIDIA. [NVCC Compiler Driver](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html). CUDA 13.3 documentation as accessed. Optimization, device debug, line information, architecture targets, and assembler reports.

[^5]: NVIDIA. [Compute Sanitizer](https://docs.nvidia.com/compute-sanitizer/ComputeSanitizer/index.html). Live documentation. Memcheck, initcheck, racecheck, and synccheck scope.

[^6]: NVIDIA. [NVIDIA System Management Interface](https://docs.nvidia.com/deploy/nvidia-smi/index.html). Live documentation, especially utilization definitions and query fields.

[^7]: NVIDIA. [NVIDIA Tools Extension SDK (NVTX)](https://github.com/NVIDIA/NVTX). Official SDK repository and integration documentation. Application annotations and C++ scoped ranges.

[^8]: Holly Wilper, Robert Knight, and Jason Cohen, NVIDIA. [Understanding the Visualization of Overhead and Latency in NVIDIA Nsight Systems](https://developer.nvidia.com/blog/understanding-the-visualization-of-overhead-and-latency-in-nsight-systems/). September 18, 2020. Launch timing and interpretation of trace intervals.

[^9]: NVIDIA. [CUDA Runtime API: API Synchronization Behavior](https://docs.nvidia.com/cuda/cuda-runtime-api/api-sync-behavior.html). Live CUDA Toolkit documentation. Host blocking, pageable staging, and memcpy semantics.

[^10]: NVIDIA. [CUDA Programming Guide: Asynchronous Execution](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/asynchronous-execution.html). Live documentation. Streams, ordering, completion, and events.

[^11]: Mark Harris, NVIDIA. [How to Optimize Data Transfers in CUDA C/C++](https://developer.nvidia.com/blog/how-optimize-data-transfers-cuda-cc/). December 4, 2012. Transfer minimization, batching, and pinned buffers.

[^12]: Mark Harris, NVIDIA. [How to Overlap Data Transfers in CUDA C/C++](https://developer.nvidia.com/blog/how-overlap-data-transfers-cuda-cc/). December 13, 2012. Conditions and ordering for copy/compute overlap.

[^13]: NVIDIA. [CUDA Programming Guide: Stream-Ordered Memory Allocator](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/stream-ordered-memory-allocation.html). Live documentation. Allocation lifetime, pool reuse, release thresholds, and cross-stream ordering.

[^14]: NVIDIA. [CUDA Programming Guide: CUDA Graphs](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/cuda-graphs.html). Live documentation. Graph construction, capture restrictions, replay, and updates.

[^15]: Houston Hoffman and Fred Oh, NVIDIA. [Constant Time Launch for Straight-Line CUDA Graphs and Other Performance Enhancements](https://developer.nvidia.com/blog/constant-time-launch-for-straight-line-cuda-graphs-and-other-performance-enhancements/). September 11, 2024. Graph overhead mechanisms and an explicitly scoped RTX 3060 study.

[^16]: NVIDIA. [Unlock GPU Performance: Global Memory Access in CUDA](https://developer.nvidia.com/blog/unlock-gpu-performance-global-memory-access-in-cuda/). September 29, 2025. Warp-level memory access and coalescing.

[^17]: NVIDIA. [CUDA C++ Best Practices Guide](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html). CUDA 13.3 documentation as accessed. Effective bandwidth, occupancy tradeoffs, and initial block-size heuristics.

[^18]: NVIDIA. [CUDA Programming Guide: Writing SIMT Kernels](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/writing-cuda-kernels.html). Live documentation. Thread-local memory, register spilling, and block execution.

[^19]: NVIDIA. [CUDA Runtime API: Occupancy](https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__OCCUPANCY.html). Live CUDA Toolkit documentation. Resource-based residency calculations.

[^20]: NVIDIA. [CUDA Binary Utilities](https://docs.nvidia.com/cuda/cuda-binary-utilities/index.html). CUDA 13.3 documentation as accessed. `cuobjdump`, resource information, SASS, and `nvdisasm`.

[^21]: Mark Harris, NVIDIA. [An Efficient Matrix Transpose in CUDA C/C++](https://developer.nvidia.com/blog/efficient-matrix-transpose-cuda-cc/). February 18, 2013. Tiling, coalescing, and bank-conflict padding.

[^22]: Andy Adinets, NVIDIA. [Optimized Filtering with Warp-Aggregated Atomics](https://developer.nvidia.com/blog/cuda-pro-tip-optimized-filtering-warp-aggregated-atomics/). October 1, 2014; updated November 2017. Aggregation and compiler automation.

[^23]: Yuan Lin and Vinod Grover, NVIDIA. [Using CUDA Warp-Level Primitives](https://developer.nvidia.com/blog/using-cuda-warp-level-primitives/). January 15, 2018. Collective participation and synchronization correctness.

[^24]: Julien Demouth, NVIDIA. [Minimize the Tail Effect](https://developer.nvidia.com/blog/cuda-pro-tip-minimize-the-tail-effect/). June 4, 2014. Incomplete waves and the distinction between theoretical and achieved occupancy.

[^25]: Mark Harris, NVIDIA. [Write Flexible Kernels with Grid-Stride Loops](https://developer.nvidia.com/blog/cuda-pro-tip-write-flexible-kernels-grid-stride-loops/). April 22, 2013. Grid-size flexibility and linear access mapping.

[^26]: Mark Harris, NVIDIA. [An Even Easier Introduction to CUDA (Updated)](https://developer.nvidia.com/blog/even-easier-introduction-cuda/). May 2, 2025. Managed-memory migration and prefetching.

[^27]: NVIDIA. [Floating Point and IEEE 754](https://docs.nvidia.com/cuda/floating-point/index.html). CUDA Toolkit white paper. Precision, operation order, FMA, and numerical comparison.

[^28]: NVIDIA. [CUB Device-Wide Primitives](https://nvidia.github.io/cccl/unstable/cub/device_wide.html). CCCL development documentation as accessed. Scratch-storage query and execution phases; match the installed CCCL release.

[^29]: NVIDIA. [Streamlining CUB with a Single-Call API](https://developer.nvidia.com/blog/streamlining-cub-with-a-single-call-api/). January 21, 2026. Execution environments and temporary-memory management.

[^30]: NVIDIA. [NVBench: CUDA Kernel Benchmarking Library](https://github.com/NVIDIA/nvbench). Official repository and README as accessed. Parameter sweeps, cold measurements, batch measurements, and output formats.

[^31]: NVIDIA. [Increase Performance with Vectorized Memory Access](https://developer.nvidia.com/blog/cuda-pro-tip-increase-performance-with-vectorized-memory-access/). Technical Blog, current revision as accessed. Vectorized loads/stores and alignment requirements.

[^32]: NVIDIA. [CUDA Programming Guide: CUDA Environment Variables](https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/environment-variables.html). Live documentation. Launch blocking, JIT, and runtime configuration.

[^33]: Mark Harris, NVIDIA. [CUDA 7 Streams Simplify Concurrency](https://developer.nvidia.com/blog/gpu-pro-tip-cuda-7-streams-simplify-concurrency/). January 22, 2015. Legacy, per-thread, and nonblocking stream semantics.

[^34]: NVIDIA. [CUB Overview](https://nvidia.github.io/cccl/unstable/cub/index.html). CCCL development documentation as accessed. Device, block, and warp collective algorithm families.
