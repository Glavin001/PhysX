# CUDA optimization with hardware counters

Practical workflow for fast, correct CUDA software, with examples for an irregular, real-time destruction stress solver.

Prepared September 10, 2026. This is a standalone companion to the earlier guide about optimization without counters. No application code, GPU model, or profiler capture was supplied for this turn, so the bottlenecks and experiments below are hypotheses to test, not findings about your implementation. Commands are documented examples, not executed benchmark results.

## 1. Optimize completed, useful work

Use a repeating loop:

1. Select a representative workload and define acceptable output quality.
2. Measure its completed execution without profiling.
3. Find the stage delaying completion using a timeline.
4. Use counters to identify that stage's limiting mechanism.
5. Predict what one proposed change should alter.
6. Implement the smallest useful experiment.
7. Check correctness, counters, and unprofiled application time.
8. Keep or revert the change, then find the new bottleneck.

This follows NVIDIA's analysis-driven approach: prioritize the largest performance limiter, make a change, and analyze again. Hardware counters strengthen the explanation of a bottleneck; the experiment establishes whether addressing it improves your application. [NVIDIA's analysis-driven optimization introduction](https://developer.nvidia.com/blog/analysis-driven-optimization-preparing-for-analysis-with-nvidia-nsight-compute-part-1/).

For your solver, the objective should be **minimum completed-step latency at an explicitly acceptable simulation quality**, subject to a memory budget. Also evaluate quality achievable within a fixed time budget. A kernel's occupancy, FLOP/s, bandwidth, or iteration rate is diagnostic evidence, not the final objective.

For 60 FPS, the entire frame has approximately 16.67 ms. Give stress solving its own budget after accounting for rigid-body physics, rendering, and other work. Test the integrated workload because isolated kernels do not experience the same contention or cache behavior.

Separate two experiment classes:

| Class | What changes | Acceptance requirement |
| --- | --- | --- |
| Implementation optimization | Layout, ownership, scheduling, redundant computation, launch structure | Preserve the intended mathematical method within specified numerical tolerances |
| Algorithm or approximation | Solver method, stopping policy, active-region truncation, precision, update frequency | Establish the resulting quality/performance tradeoff explicitly |

Changing an in-place iteration to a parallel out-of-place iteration can change convergence. Compare the time needed to reach the same acceptance criteria, including setup and extra iterations.

## 2. Build a small but representative benchmark suite

Use recorded initial states and input/event sequences. Keep a fixed-input kernel benchmark for diagnosis and a full simulation replay for final acceptance. Record topology, material parameters, loads, warm-start state, and relevant random seeds—not just geometry.

Recommended cases for your application:

| Case | Purpose | Particularly useful measurements |
| --- | --- | --- |
| Settled world, no relevant changes | Expose polling and unnecessary scans | Solver launches, visited nodes/bonds, maintenance time |
| One local disturbance in a large world | Check locality of activation | Active fraction, visited/active ratio, wake-up delay |
| Many small independent bond islands | Expose launch and task-allocation overhead | Launch count, scheduling time, work per block |
| One large connected structure | Expose insufficient internal parallelism and convergence cost | Node degree distribution, iteration count, completion time |
| Thin chains and highly unequal degrees | Expose dependency depth and load imbalance | Work distribution, slowest tasks, residual progress |
| Burst of bond failures | Expose topology maintenance spikes | Split detection, rebuilding, invalidation, allocation |
| Mixed island sizes during settling | Check dispatch crossover and tail behavior | Per-size latency, task distribution, total work |
| Representative physics plus rendering | Check product performance | Full-frame p50/p95/p99, deadline misses, memory peak |

Keep a few additional scenes and seeds out of the tuning set to catch overfitting.

Measure three layers together:

| Layer | Record |
| --- | --- |
| Product | Completed frame/step latency, tail latency, deadline misses, memory peak |
| Algorithm | Active and visited bonds, iterations per island, residual or equilibrium error, topology changes, rebuild frequency |
| Hardware | Kernel duration, transferred bytes, instruction work, scheduler activity, occupancy, memory behavior |

Define counters precisely. For example, count a bond evaluated on five iterations as five bond visits. If one implementation uses directed edges and another uses undirected bonds, normalize their work accounting before comparison. Avoid adding contended instrumentation atomics to a hot loop; use existing work counts or separate diagnostic passes where possible.

A useful decomposition for a sequential stage is:

`time ≈ fixed overhead + performed work × average cost per work item`

This is an accounting approximation, not a universal GPU timing law. It separates two opportunities: execute each visit more cheaply, and require fewer visits.

## 3. Make measurements trustworthy

Build the production configuration, targeting the actual GPU, and add source line information. Preserve compiler flags and resource-usage output with each result. NVCC's `-lineinfo` supports profiling; `-G` is intended for device debugging and normally disables device optimizations unless additional options change that behavior. [NVCC documentation](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html).

For each baseline, record the commit, GPU model, driver, CUDA/compiler/profiler versions, build flags, input identifier, solver settings, and clock/power/temperature conditions. Remove avoidable competing GPU work for controlled comparisons, then separately test the intended shared workload.

Separate startup and steady-state measurements. Warm up context creation, JIT compilation, allocations, and kernels, but restore simulation state as needed so warming up does not turn a collapse test into a settled-world test.

Use CPU elapsed time through the actual completion boundary for end-to-end latency. Use CUDA events for device intervals with the appropriate stream dependencies. Across several streams, record the end only after all required work joins. Host submission time alone is not completion time. Do not add synchronization after every kernel to the production path just to simplify timing. NVIDIA discusses CPU and GPU timing and synchronization requirements in its [CUDA Best Practices Guide](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html).

For A/B comparisons:

- Run baseline and candidate in interleaved or randomized order on identical replay inputs.
- Use repeated runs; estimate variation instead of keeping the fastest sample.
- Report per-scenario absolute milliseconds and percentage changes.
- For frame distributions, capture enough frames and independent replays to characterize spikes; a p99 from a handful of samples is not useful.
- Treat changes inside the measurement uncertainty as inconclusive.
- Preserve the original baseline as well as the current best version.

Keep **counter collection** and **acceptance timing** separate. Nsight Compute can replay kernels, modify clocks, flush caches, and serialize work. Its default cache flushing isolates kernel behavior; application replay or suitable range profiling can answer different questions. Check replay requirements for host interaction and mandatory concurrent kernels. Simply disabling cache flushing during repeated kernel replay does not reconstruct production cache history. [Nsight Compute profiling guide](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html).

Record the chosen replay, cache, and clock settings. Defaults and available controls vary by version and GPU. Hardware-counter access does not imply permission or support for every clock-control operation. Use the installed tool's help and report actual settings rather than assuming them.

## 4. Use the timeline to choose the target

Add stable NVTX ranges around meaningful phases: load ingestion, activation, solve, failure evaluation, island splitting, and output publication. Include frame/step identifiers in your application telemetry. A CPU NVTX range marks submission context; it does not by itself measure completion of asynchronous GPU work.

Capture a short representative interval with Nsight Systems, including a slow step. The following commands assume `./stress_bench` is your executable and that it runs a bounded representative scenario; replace it with your own binary and arguments.

```bash
nsys profile --trace=cuda,nvtx,osrt --sample=none --cpuctxsw=none \
  -o stress-timeline ./stress_bench
```

`--trace=cuda` uses the CUDA tracing method selected by the installed Nsight Systems version. Current documentation describes hardware tracing where supported and software fallback; inspect report diagnostics. CPU sampling can be enabled in a separate focused capture if CPU computation is the issue. [Nsight Systems user guide](https://docs.nvidia.com/nsight-systems/UserGuide/index.html).

Inspect:

- Gaps before the GPU receives ready work.
- CPU readbacks that force the next stage to wait.
- Repeated allocations, copies, or tiny launches.
- Missing or ineffective overlap between independent work.
- Long solves, topology updates, and occasional outlier steps.

Rank targets by **recoverable time on the path to completion**, not by a kernel's alarming percentage. Do not add overlapping kernel durations or count a CPU wait and the GPU work it waits for as separate savings.

For a sequential fraction `f` accelerated by a factor `s`, Amdahl's law gives:

`overall speedup = 1 / ((1 − f) + f/s)`

For example, halving a stage responsible for 60% of elapsed time gives approximately 1.43× overall speedup. Eliminating it entirely would give at most 2.5× under that decomposition. In a concurrent application, estimate the effect from the timeline and verify it experimentally.

## 5. Collect focused counters

Discover what the installed profiler supports:

```bash
ncu --version
ncu --list-sets
ncu --list-sections
ncu --query-metrics
```

Instrument one chosen step with a default-domain NVTX push/pop range named `profile_step`. The examples below select the first matching `BondSolve` kernel submitted in that range. Substitute your actual kernel name; confirm the report contains the intended launch.

```bash
ncu --set basic --nvtx --nvtx-include 'profile_step/' \
  --kernel-name-base demangled --kernel-name 'regex:BondSolve' \
  --launch-count 1 -o bondsolve-basic ./stress_bench
```

Then collect evidence relevant to the suspected mechanism. For a memory hypothesis:

```bash
ncu --section MemoryWorkloadAnalysis --section SourceCounters \
  --nvtx --nvtx-include 'profile_step/' \
  --kernel-name-base demangled --kernel-name 'regex:BondSolve' \
  --launch-count 1 -o bondsolve-memory ./stress_bench
```

For poor issue rate or unexplained latency:

```bash
ncu --section SchedulerStats --section WarpStateStats \
  --section Occupancy --section SourceCounters \
  --nvtx --nvtx-include 'profile_step/' \
  --kernel-name-base demangled --kernel-name 'regex:BondSolve' \
  --launch-count 1 -o bondsolve-scheduling ./stress_bench
```

Use `ComputeWorkloadAnalysis` and `InstructionStats` for instruction-pipeline questions, or `SpeedOfLight_RooflineChart` for arithmetic/memory analysis when supported. A full report is useful for a selected reproducible case; it is usually excessive for every launch of an entire simulation.

Section availability is version dependent. The trailing `/` selects a push/pop NVTX range. If using `--launch-skip`, it counts matching kernel launches, not frames or solver iterations. Save commands alongside reports. [Nsight Compute CLI documentation](https://docs.nvidia.com/nsight-compute/NsightComputeCli/index.html).

Repeat targeted captures for materially different states: first iteration versus nearly converged, large island versus small-island batch, and ordinary step versus fracture burst. A representative name is not necessarily a representative launch.

## 6. Translate evidence into experiments

The experiments in this table are proposed engineering tests. A symptom supports a hypothesis; it does not uniquely establish its cause.

| Observation | Question to resolve | Candidate experiment and predicted effect |
| --- | --- | --- |
| Too few blocks, low utilization, large per-thread inner loops | Did the mapping expose enough independent work? | Parallelize across bonds or adjacency entries; expect more schedulable work, while measuring reduction overhead |
| Many active warps but few eligible warps and poor issue rate | What dependency prevents progress? | Inspect the stalled consumer and its producer; test independent work interleaving or a different ownership scheme |
| Excess memory sectors for useful data | Are neighboring lanes fetching scattered fields? | Compare SoA or reordered adjacency; expect fewer sectors per equivalent evaluation |
| DRAM near sustainable bandwidth | Can the algorithm move fewer bytes? | Remove redundant passes, reduce hot payload, or reuse data; expect fewer bytes and shorter completion time |
| Low DRAM traffic but poor memory-related progress | Is a cache path, instruction pipe, pointer dependency, or atomic target limiting? | Examine the relevant path and source, then change access structure rather than assuming DRAM saturation |
| Local-memory traffic plus large live state | Are spills or indexed thread-local arrays expensive? | Reduce live ranges, arrays, or unrolling; expect reduced local traffic, with any extra instructions accounted for |
| Slow completion after most tasks finish | Are a few blocks or rows disproportionately large? | Split large rows, bucket sizes, or redistribute tasks; expect a shorter tail including dispatch cost |
| Heavy atomic traffic and concentrated destinations | Is output ownership causing contention? | Compare grouped contributions or owner-gather; expect fewer contended updates, including reduction costs |
| Shared-memory conflict evidence and waits | Is the bank mapping or synchronization pattern poor? | Remap indices, pad, or use a warp-level primitive; measure total time and added storage |
| High instruction work per useful update | Is bookkeeping or recomputation dominating? | Precompute stable terms or specialize a common path; expect fewer executed instructions per accepted update |

The launch-mapping and memory-access problems are illustrated in NVIDIA's [analysis-driven optimization, part 2](https://developer.nvidia.com/blog/analysis-driven-optimization-analyzing-and-improving-performance-with-nvidia-nsight-compute-part-2/). Its [Compute Triage Guide](https://docs.nvidia.com/nsight-compute/ComputeTriage/index.html) distinguishes memory subsystems, spills, contention, and synchronization. NVIDIA's [tail-effect explanation](https://developer.nvidia.com/blog/cuda-pro-tip-minimize-the-tail-effect/) explains partially populated execution waves; unequal task durations are another reason to investigate the end of a kernel.

Interpret these signals carefully:

- **Occupancy:** resource residency, not useful work per cycle. Higher occupancy can lose to better reuse or less spilling.
- **Stall samples:** investigate them when issue opportunities are being lost. A large category can coexist with useful work from other warps.
- **Not selected:** a ready warp lost selection to another ready warp; this is not automatically a problem.
- **Cache hit rate:** compare absolute traffic and time as well as percentages.
- **Memory throughput:** inspect which subsystem contributes; the headline number is not synonymous with DRAM bandwidth.

These distinctions follow the profiler's [section and metric definitions](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html).

Do not apply one universal sectors/request threshold. For example, a full warp loading 32 distinct adjacent 4-byte values from a suitably aligned address needs four 32-byte sectors. Different widths, active masks, broadcasts, and alignments change the ideal. Compare against the access pattern actually being executed. NVIDIA describes transaction utilization through a worked example in [analysis-driven optimization, part 2](https://developer.nvidia.com/blog/analysis-driven-optimization-analyzing-and-improving-performance-with-nvidia-nsight-compute-part-2/).

Use the Source page to correlate CUDA with SASS and instruction-level measurements. Inspect the machine instructions generated for hot code, not just the apparent C++ operation count. Keep source and binary matched, and use the baseline comparison to inspect changes. [Nsight Compute source and baseline features](https://docs.nvidia.com/nsight-compute/NsightCompute/index.html).

## 7. Keep algorithm review ahead of instruction tuning

Counters cannot tell you that an entire operation was unnecessary. Audit the computational dependency graph as well as the hardware execution.

For every expensive loop, ask:

1. What is the input state and who owns each output?
2. Is ordering mathematically required, or imposed by the implementation?
3. How much independent work exists at each nested level?
4. What communication, storage, and numerical changes would parallelization introduce?
5. Is this work still necessary for the current state?

Consider 64 islands, each with 4,096 independent bond evaluations in a particular phase. One thread per island exposes only 64 threads despite 262,144 evaluations. A warp, block, or multiple blocks per island might expose more useful parallelism. However, reduction and update semantics must remain valid; an independent bond evaluation does not imply independent writes to shared node state.

Short loops can improve reuse, and grid-stride loops can combine broad parallelism with controlled thread allocation. The objective is sufficient useful parallelism, not removal of every loop. [NVIDIA's grid-stride loop guidance](https://developer.nvidia.com/blog/cuda-pro-tip-write-flexible-kernels-grid-stride-loops/).

For each structural pattern, establish a baseline against an appropriate primitive:

| Pattern | Candidate formulation | Cost to include |
| --- | --- | --- |
| Sequential append | Selection/compaction or batched atomic reservation | Temporary storage, extra passes, ordering requirement |
| Repeated global accumulator update | Warp/block reduction then combination | Synchronization and final merge |
| Neighbor scatter | Contribution generation plus reduction, or owner-gather | Duplicated work, storage, and numerical ordering |
| One launch per tiny island | Batched island work | Metadata packing, dispatch, poor-fit cases |
| One worker per variable-length row | Thread/warp/block mapping by row size | Bucketing and crossover overhead |
| Repeated unchanged calculation | Cached values with explicit invalidation | Cache construction, memory traffic, invalidation |

NVIDIA's CCCL contains CUB and Thrust as reference implementations for common parallel operations. Use them as baselines before committing to custom primitives. [NVIDIA CCCL](https://github.com/NVIDIA/cccl).

Warp aggregation can reduce contended atomic operations, but grouping is valid only for compatible updates to the same destination or separately grouped destinations. The compiler already performs some aggregation automatically; measure the emitted behavior. [NVIDIA's warp-aggregated atomics article](https://developer.nvidia.com/blog/cuda-pro-tip-optimized-filtering-warp-aggregated-atomics/).

For your split-only bond graph, specifically investigate whether topology maintenance is revisiting unaffected regions. Preserve valid cached structure after splits where the algorithm permits it. Measure rebuilding and packing over realistic split sequences. A disconnected bond island can be solved independently for fixed external loads and boundary conditions; physical contact coupling can still require coordination through the surrounding simulation.

An idle solver needs a definition of unchanged state. No new collision event alone does not prove equilibrium: changed supports, persistent loads, unresolved residuals, material evolution, or delayed damage may still require work. Invalidation and wake-up correctness are part of the optimization.

## 8. Use cost models to choose where to invest

For memory traffic at a chosen level:

`time floor ≈ required bytes / sustainable bandwidth`

The roofline model relates achievable arithmetic throughput to compute capacity and arithmetic intensity:

`attainable FLOP/s ≤ min(compute ceiling, bandwidth × FLOPs/byte)`

Use compatible units, precision, and hardware. A hierarchy of roofs distinguishes DRAM from cache traffic. NVIDIA demonstrates this approach in its [roofline analysis tutorial](https://developer.nvidia.com/blog/accelerating-hpc-applications-with-nvidia-nsight-compute-roofline-analysis/).

For irregular graph code, treat a FLOP roofline as one bound. Address calculations, atomics, dependency latency, and uneven work may dominate without approaching the FP32 ceiling. Do not compare ordinary floating-point kernels with a marketed Tensor Core throughput figure.

Maintain two byte counts: a model of useful payload required by the algorithm, and measured traffic at the relevant hierarchy level. They answer different questions. A coalesced streaming bandwidth test provides an optimistic comparison for a random gather, not proof that the gather should reach the same rate.

Illustration only: if a pass transfers 240 MB and sustains 600 GB/s, the traffic alone implies approximately 0.40 ms. A measured 0.45 ms leaves little opportunity without reducing traffic; a measured 4 ms warrants investigation into why the assumed bandwidth is not achieved or whether the model omitted work.

For caching, sorting, packing, or preconditioning, calculate an amortization threshold:

`reuse count to break even > setup cost / savings per subsequent use`

Then measure whether your changing topology actually provides that many uses. An optimized solve can lose overall if its data structure is constantly rebuilt.

A library or algorithm change can also beat tuning the original formulation. NVIDIA's [analysis-driven optimization, part 3](https://developer.nvidia.com/blog/analysis-driven-optimization-finishing-the-analysis-with-nvidia-nsight-compute-part-3/) demonstrates reformulating repeated matrix-vector work and using a library, even though this introduces intermediate global-memory storage. The appropriate stopping question is how much application time another change can realistically save.

## 9. Require a written prediction for each experiment

Use this compact record:

```text
Experiment ID / parent commit:
Scenario, state snapshot, seed, solver quality settings:
Observed problem and relevant evidence:
Hypothesis:
Proposed change:
Predicted counter changes:
Predicted application effect:
Numerical or semantic risks:
Baseline and candidate completed-step p50/p95/p99:
Iterations, visited bonds, final quality, memory peak:
Observed counter changes:
Result: keep / revert / inconclusive
Explanation, regression coverage, next bottleneck:
```

Example hypothesis: “The node-gather phase has one thread per node and a heavy degree tail. Large rows leave a few workers running after most work completes. Assigning a warp to sufficiently large rows should shorten the tail, at the cost of shuffle reduction and more idle lanes for small rows.”

Test a small bounded family of mappings, then tune the crossover on multiple degree distributions. Include classification and dispatch in total time. If the candidate is faster but the predicted mechanism does not change, retain the measured observation and revise the explanation instead of presenting the hypothesis as proven.

A useful experiment can change a small coherent group of implementation details. Avoid simultaneously changing layout, precision, solver method, and stopping criteria: the resulting comparison becomes hard to interpret.

For diagnostic ablations, prevent dead-code elimination and recognize semantic changes. Removing atomics, skipping loads, or suppressing failure events can estimate an upper bound or isolate a cost; it does not demonstrate a shippable optimization.

## 10. Preserve quality and correctness

Before changing arithmetic or synchronization, establish small trusted cases. Use an analytical result or a separately checked reference with tighter convergence and sufficient precision. A higher-precision reference is helpful but not automatically correct.

For suitable linear equilibrium subproblems, report a normalized residual such as:

`||A x − b|| / (||b|| + epsilon)`

Use a scale-appropriate epsilon and additionally check local errors; a global norm can hide a bad small region. Nonlinear damage, inequality constraints, and failure rules require their own acceptance measures. Evaluate physical quality against the actual model, rather than assuming one residual captures everything.

Recommended solver checks include:

- Force and moment balance in controlled static cases.
- Stress/deformation error before failure thresholds are crossed.
- No NaNs, stale references, missing contributions, or invalid islands.
- Correct treatment of deleted bonds, changed supports, and sleeping/waking regions.
- Convergence and failure behavior across repeated impacts and long settling runs.
- Sensitivity around damage thresholds, including event ordering where it matters.
- Memory and time spikes during large split events.

Floating-point addition is order dependent, and fused operations or precision changes can alter results. Preserve exact invariants where required and use explicitly chosen tolerances elsewhere. Treat `--use_fast_math`, reduced precision, and reassociation as measured numerical decisions. [NVIDIA's floating-point guide](https://docs.nvidia.com/cuda/floating-point/index.html).

On small representative validation cases, use:

```bash
compute-sanitizer --tool memcheck ./stress_bench
compute-sanitizer --tool racecheck ./stress_bench
compute-sanitizer --tool initcheck ./stress_bench
compute-sanitizer --tool synccheck ./stress_bench
```

Run memory checking first. Racecheck targets shared-memory hazards; passing it is not proof of correct global-memory synchronization, atomics, or algorithm semantics. These instrumented runs validate behavior, not performance. Re-run the relevant checks after changes to ownership, barriers, indexing, or memory lifecycle. [Compute Sanitizer documentation](https://docs.nvidia.com/compute-sanitizer/ComputeSanitizer/index.html).

Use two performance evaluations for any solver-method change: time to meet common quality criteria, and achieved quality at a common time budget. If altered failure decisions reduce the number of remaining bonds, document that difference; a shorter replay may otherwise reflect a changed simulation rather than a more efficient implementation.

## 11. Turn accepted improvements into durable code

Keep a clear reference path and a small number of measured specializations. Document each specialized kernel's valid sizes, alignment, aliasing assumptions, synchronization requirements, numerical contract, and fallback. Assertions and focused tests should protect those assumptions.

Automate ordinary benchmark replays and result comparisons on a stable GPU runner. Save input manifests, build information, raw timings, quality results, and selected profiler reports with the change. Perform expensive counter capture when diagnosing a change or regression; every ordinary timing run does not need it.

Tune parameters only after selecting a sound formulation. Candidate dimensions include block size, rows per block, thread/warp/block mapping, bounded unrolling, and a small number of size thresholds. Profile Series can assist supported launch-parameter experiments, but validate winners through the ordinary benchmark suite. Avoid an unbounded collection of special cases that only wins on the training scenes.

For a performance change, the review should answer:

1. Which completion bottleneck motivated the change?
2. What implementation or algorithm contract changed?
3. What evidence supports the proposed mechanism?
4. How much time did representative workloads save, with what uncertainty?
5. Which quality, memory, or worst-case tradeoffs remain?

Stop local tuning when the frame budget is met with suitable headroom, the next plausible saving is too small, or a cost model points to an algorithmic limit. Revisit the full timeline after each substantial improvement: bottlenecks move.

## 12. First optimization pass

1. Choose settled, local-impact, large-connected, small-island, and fracture-burst replays.
2. Establish unprofiled completed-step and integrated-frame baselines with quality metrics.
3. Capture a short timeline and identify the largest recoverable delay.
4. Check unnecessary work, launch structure, and exposed parallelism before fine tuning.
5. Collect a basic profile of a relevant launch; add only the sections needed to resolve its bottleneck.
6. Write one prediction, implement one bounded experiment, and validate it.
7. Keep a change only when completed useful work improves and required quality remains satisfied.
8. Re-profile the new baseline and repeat.

For this project, the highest-value initial audit is the combination of work avoidance, island/bond parallelism, convergence cost, and topology maintenance. Counters will identify how the selected implementation consumes the GPU; your application metrics must establish whether that work needed to happen at all.
