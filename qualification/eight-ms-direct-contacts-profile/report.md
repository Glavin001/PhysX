# PhysX GPU destruction — measured timing breakdown

The penetration simulate/fetch subinterval averages 3.144 ms per step across 2 untraced repeats; the worst measured step is 6.525 ms. 32/1200 steps are below 1 ms. GPU stress occupies a mean 2.207 ms of destruction-stream elapsed time in the separate host-scope capture (68.0% of its simulation bracket; this overlaps submission/wait).

## 🎯 Authoritative complete advance — commands through committed completion

| Untraced repeat | Steps | Mean ms | Peak ms | >8 ms | Peak step | CPU commands at peak ms | PhysX/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|
| 1 | 600 | 3.193 | 6.577 | 0 | 33 | 0.000 | 6.525 | 0.052 |
| 2 | 600 | 3.194 | 6.399 | 0 | 33 | 0.000 | 6.343 | 0.056 |

This is the deadline timer. It includes commands, insertion and mandatory completion in addition to simulate/fetch. The detailed CPU/GPU tables below subdivide simulate/fetch in separate profiling captures. These short runs do not establish the five × 60-second gate.

## Measurement contract and validity

| Check | Result |
|---|---|
| Capture completeness / recorded file hashes | PASS — every input capture hashed and validated |
| Stress convergence / correction limit | PASS — every accepted step converged; at most one correction per step |
| Fracture/cluster counter histories across repetitions and trace modes | MATCH across full-duration untraced, host-scope and GPU captures |
| CPU observations / rendering / video encoding | Disabled in measured runs; compact SDK status observation remains outside simulate/fetch |
| Wall-time partition / GPU overlap accounting | PASS — disjoint scope tree closes; GPU interval unions remain inside the measured bracket |
| CUPTI loss / malformed timestamps | PASS — every full-duration GPU repetition has zero dropped records and zero invalid timestamps |
| CUPTI configuration | Header/runtime API version 130202; device-graph trace buffer 512 MiB per context. No solver or physical-input changes. |
| GPU process isolation evidence | Require no GPU process before/after and at most one stable GPU PID during each run. GPU PIDs are in the host namespace; ownership is inferred from this lifecycle, not a container PID comparison. Clocks are observed, not locked. |
| Determinism | Same input configuration and stable report generation. GPU timings are not deterministic; repeated measurements retain variation. |

Hardware: NVIDIA GeForce RTX 4090; driver 595.71.05. Revision 9bffbea942dc0613aeccf08d56338c22d5aafe99. One separate process per case is discarded. All measured frames, including first impact and first allocation, are retained. All modes advance 10 simulated seconds; 1 complete CUPTI repetitions per scene, at 60 Hz. This short diagnostic campaign is not the planned five × 60-second scale qualification.

The detailed profiling bracket starts immediately before scene.simulate and ends after blocking scene.fetchResults, including embedded destruction and correction. Scene construction, projectile creation before the step, compact post-step status observation, CSV output and GPU activity flush are outside this bracket. This is simulation cost, not the complete application tick. CPU profiling callbacks and concurrent CUPTI collection can still perturb the measured interval.

## Untraced simulate/fetch cost — subinterval of the complete advance

| Scene | Chunks | Bonds | Steps | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Max ms | ≥1 ms | >16.67 ms |
|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 444 | 896 | 1200 | 0.460 | 3.144 | 3.024 | 4.197 | 5.147 | 6.525 | 1168 | 0 |

| Penetration repeat | Mean ms | Worst ms | Worst step | Sim time s | Resim | Stress iterations | Clusters | Scheduled active bodies | Solved contact reports |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 3.144 | 6.525 | 33 | 0.567 | 1 | 390 | 43 | 44 | 500 |
| 2 | 3.145 | 6.343 | 33 | 0.567 | 1 | 390 | 43 | 44 | 500 |

## Event-based windows — no fixed impact frame or hidden warm-up cutoff

| Window (overlapping; do not add) | Steps | Mean ms | p50 ms | p95 ms | Max ms |
|---|---|---|---|---|---|
| First accepted step | 2 | 4.337 | 4.120 | 4.553 | 4.553 |
| After startup, before first broken bond | 32 | 0.491 | 0.473 | 0.666 | 0.720 |
| Steps that execute correction | 6 | 6.009 | 5.963 | 6.525 | 6.525 |
| After the last newly broken bond | 1132 | 3.186 | 3.024 | 4.180 | 5.398 |
| Last two simulated seconds | 240 | 2.949 | 2.947 | 3.303 | 3.442 |

## Instrumentation overhead — never mix these captures

| Mode | Runs | Mean ms | Max ms | Mean / untraced mean |
|---|---|---|---|---|
| No detailed profiling | 2 | 3.144 | 6.525 | 1.00× |
| CPU scopes + CUDA stream events | 1 | 3.244 | 6.695 | 1.03× |
| CPU scopes + CUDA events + CUPTI | 1 | 3.729 | 8.145 | 1.19× |

Profiling changes scheduling and adds overhead. Detailed tables describe their own measured capture; they are not a retrospective decomposition of the video or of an untraced maximum. Overhead is observed, not subtracted as a guessed correction.

## Additive wall-time breakdown — host-scope capture

Columns show all-step mean, first fracture (step 17), this capture's worst step (33), and the last-two-seconds mean. CPU/GPU designations describe what happens inside the scope, not exclusive processor execution. Rows are disjoint and add to the timestamp bracket. The bracket includes clock-read bookends around simulate/fetch; mean difference from the simulation timer is 1.45 µs.

| Operation | CPU / GPU responsibility | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.008 | 0.008 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.114 | 0.175 | 0.135 | 0.119 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 2.211 | 1.693 | 3.375 | 2.034 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.080 | 0.036 | 0.000 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.027 | 0.006 | 0.000 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.017 | 0.008 | 0.000 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.007 | 0.007 | 0.000 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.008 | 0.008 | 0.001 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 | 0.008 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.085 | 0.051 | 0.000 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.002 | 0.114 | 0.050 | 0.001 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.136 | 0.046 | 0.001 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.001 | 0.274 | 0.270 | 0.000 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.040 | 0.016 | 0.000 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 | 0.007 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.008 | 1.688 | 1.328 | 0.000 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.169 | 0.103 | 0.000 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.889 | 1.209 | 1.237 | 0.910 |
| TOTAL | Measured simulate/fetch bracket | 3.246 | 5.743 | 6.697 | 3.083 |

## Inside the destruction wait — GPU-stream elapsed time

These consecutive CUDA-event intervals include GPU execution plus stream scheduling/dependency gaps. They overlap the CPU submission/wait above and must NOT be added to wall time. The wait is the host observing completion of required work, not a second computation. Exact kernel execution is shown separately below.

| GPU stream operation | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|
| Convert solved contact impulses into chunk loads | 0.022 | 0.058 | 0.023 | 0.023 |
| Iterative stress solve to convergence | 2.207 | 1.625 | 3.292 | 2.034 |
| Evaluate material damage and fracture | 0.017 | 0.019 | 0.017 | 0.017 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.113 | 0.122 | 0.026 |
| Commit changes and rebuild stress topology | 0.030 | 0.031 | 0.030 | 0.030 |

## Actual GPU execution versus elapsed gaps — CUPTI capture

Detailed GPU tables use repetition 1; all 1 repetitions pass full validation and contribute to the overhead table. GPU capture duration: 10 s. Its final-two-seconds column covers simulation seconds 8–10. This capture's first fracture is step 17; its worst step is 0. Concurrent GPU intervals are merged before summing. No GPU activity means no recorded kernel/copy/memset from this process, not proof of global GPU idleness or useful CPU computation. CPU core-time can exceed elapsed time and is never added to it.

| Disjoint wall-time category | Mean ms | First fracture ms | Worst step ms | Trace final 2 s ms |
|---|---|---|---|---|
| GPU kernel execution (union) | 2.662 | 2.606 | 1.096 | 2.494 |
| GPU copy/memset time not overlapping kernels | 0.066 | 0.138 | 0.070 | 0.065 |
| No recorded GPU execution | 1.003 | 4.275 | 6.984 | 0.982 |
| TOTAL measured bracket | 3.731 | 7.019 | 8.150 | 3.541 |

| Important region | Wall mean ms | GPU activity mean ms | No GPU activity mean ms |
|---|---|---|---|
| Trial physics and remaining scene tasks | 1.161 | 0.476 | 0.685 |
| Finish GPU work and reserve bodies | 0.015 | 0.000 | 0.015 |
| Resimulate changed interaction | 0.009 | 0.003 | 0.006 |

## Ordinary physics and resimulation — observed host substeps

Inclusive observed host scopes below can nest or overlap across worker threads. These rows explain the broad trial/correction regions; do not add them together. GPU work is dispatched asynchronously and need not execute inside its submitting host scope. Missing coverage remains in the parent region, rather than being presented as a measured operation.

| Host task / callback | Trial mean wall ms | Correction mean wall ms | Trial first-fracture ms | Correction first-fracture ms |
|---|---|---|---|---|
| Allocate contact-manager storage | 0.004 | 0.000 | 0.184 | 0.005 |
| Register contact managers | 0.002 | 0.000 | 0.008 | 0.002 |
| Register body/shape interactions | 0.002 | 0.000 | 0.004 | 0.017 |
| Register scene interactions | 0.001 | 0.000 | 0.002 | 0.018 |
| Complete broad phase and callbacks | 0.047 | 0.001 | 0.061 | 0.103 |
| Broad-phase completion stage 2 | 0.005 | 0.000 | 0.086 | 0.003 |
| Broad-phase completion stage 3 | 0.001 | 0.000 | 0.001 | 0.001 |
| Complete narrow phase | 0.125 | 0.001 | 0.083 | 0.202 |
| Insert contact dependencies into islands | 0.002 | 0.000 | 0.034 | 0.021 |
| Generate simulation islands | 0.011 | 0.000 | 0.010 | 0.021 |
| Finish island scheduling | 0.004 | 0.000 | 0.005 | 0.002 |
| Prepare dynamics tasks | 0.002 | 0.000 | 0.002 | 0.003 |
| Submit dynamics/constraint solve | 0.015 | 0.000 | 0.032 | 0.034 |
| Finish constraint partitioning | 0.059 | 0.001 | 0.093 | 0.123 |
| Dispatch lost contacts | 0.004 | 0.000 | 0.001 | 0.002 |
| Lost-contact completion stage 2 | 0.003 | 0.000 | 0.001 | 0.002 |
| Lost-contact completion stage 3 | 0.002 | 0.000 | 0.001 | 0.002 |
| Finish motion integration and solver tasks | 0.002 | 0.000 | 0.002 | 0.002 |

## Which GPU work consumes execution time?

Kernel durations below are execution sums. They can overlap across streams and are NOT additive elapsed wall time. Classification uses kernel symbols and CUDA source files; unknown symbols stay explicitly unclassified.

| GPU kernel family | Mean execution sum ms | First-fracture sum ms | Worst-step sum ms | Trace final 2 s sum ms |
|---|---|---|---|---|
| stress solver / stress topology | 2.197 | 1.648 | 0.766 | 2.026 |
| physics constraint preparation / solve / integration | 0.277 | 0.409 | 0.036 | 0.284 |
| shared physics utilities | 0.049 | 0.198 | 0.197 | 0.048 |
| physics narrow phase / contact lifecycle | 0.038 | 0.031 | 0.000 | 0.037 |
| physics broad phase | 0.030 | 0.086 | 0.050 | 0.029 |
| destruction orchestration / motion | 0.019 | 0.077 | 0.018 | 0.018 |
| destruction load gathering | 0.017 | 0.007 | 0.002 | 0.018 |
| destruction contact graph | 0.011 | 0.016 | 0.002 | 0.011 |
| destruction pre-solve contacts / islands | 0.008 | 0.007 | 0.001 | 0.009 |
| destruction material / damage | 0.007 | 0.008 | 0.007 | 0.007 |
| physics body / shape updates | 0.005 | 0.013 | 0.011 | 0.005 |
| destruction connectivity / mass / slots | 0.005 | 0.056 | 0.006 | 0.004 |
| shared CUDA scan / sort primitives | 0.000 | 0.027 | 0.000 | 0.000 |
| CUDA memory utility kernels | 0.000 | 0.025 | 0.000 | 0.000 |

Mean kernel dispatches per step: 152.7; first-fracture dispatches: 377. CUDA API wall union averages 3.317 ms, overlapping GPU work. Time inside synchronization APIs with no recorded GPU activity averages 0.036 ms; this includes driver/scheduler/dependency overhead, not proven useful CPU computation.

| Largest individual GPU kernels | Operation | Calls / step | Mean µs / call | Execution sum ms / step |
|---|---|---|---|---|
| persistentStressSolve | stress solver / stress topology | 1.000 | 2178.352 | 2.178 |
| solveStaticBlockTGS | Solve contacts against static boundaries | 4.883 | 22.926 | 0.112 |
| solveWholeIslandTGS | Solve a rigid-body constraint island | 4.020 | 14.876 | 0.060 |
| radixSortMultiCalculateRanksLaunchWithCount | shared physics utilities | 8.160 | 3.507 | 0.029 |
| solveBlockUnified | physics constraint preparation / solve / integration | 4.920 | 4.477 | 0.022 |
| radixSortMultiBlockLaunchWithCount | shared physics utilities | 8.160 | 2.512 | 0.020 |
| markActiveSlabTGS | physics constraint preparation / solve / integration | 4.875 | 3.094 | 0.015 |
| routeContacts | destruction load gathering | 0.972 | 15.256 | 0.015 |
| propagateAverageSolverBodyVelocityTGS | physics constraint preparation / solve / integration | 5.025 | 2.332 | 0.012 |
| computeAverageSolverBodyVelocityTGS | physics constraint preparation / solve / integration | 5.025 | 2.197 | 0.011 |
| boxBoxNphase_Kernel | physics narrow phase / contact lifecycle | 1.747 | 6.049 | 0.011 |
| prepareLostFoundPairs_Stage2 | physics narrow phase / contact lifecycle | 3.573 | 2.163 | 0.008 |

Stress iterations are numerical convergence iterations, not additional resimulations. CUDA-graph guarded tail kernels can execute beyond the reported iteration count; kernel dispatch counts are shown separately. Small per-call times combined with repeated dependent launches identify a scheduling/fusion investigation, not proof of a particular hardware throughput limit.

## CPU execution — core time, separate from elapsed wall time

| Host scope | Mean exclusive CPU core-ms / step |
|---|---|
| finishDetail.waitForGpu | 2.211 |
| submit | 0.114 |
| trialDetail.postNarrowPhase | 0.106 |
| trialDetail.updateDynamicsPostPartitioning | 0.059 |
| task.prepareIslandRepair | 0.055 |
| trialDetail.postBroadPhase | 0.046 |
| trialDetail.updateDynamics | 0.015 |
| task.speculativeIslandMaintenance | 0.012 |
| task.accurateIslandMaintenance | 0.012 |
| checkpoint | 0.009 |

Process CPU time averages 3.834 core-ms per step in the host-scope capture. CPU thread clocks include busy waiting, driver and profiling work, but exclude descheduling. Same-thread children are subtracted from their parent; detached/cross-thread spans are excluded. Parallel CPU core-ms must not be added to wall-ms or GPU time. A large wait scope's CPU time does not mean the stress math runs on the CPU.

## Work quantities — physical workload, not just allocated capacity

| Counter (untraced repeat 1) | Mean | Minimum | Maximum | Last 2 s mean |
|---|---|---|---|---|
| Connected rigid clusters | 41.132 | 1.000 | 43.000 | 43.000 |
| Registered PhysX bodies | 42.132 | 2.000 | 44.000 | 44.000 |
| CPU-scheduled active bodies | 42.103 | 1.000 | 44.000 | 44.000 |
| Solved contact reports | 456.917 | 0.000 | 537.000 | 496.150 |
| GPU pre-solve pair visits | 168.797 | 0.000 | 284.000 | 174.642 |
| Retained stress nodes | 343.730 | 342.000 | 380.000 | 342.000 |
| Retained stress bonds | 592.988 | 585.000 | 784.000 | 585.000 |
| Retained stress islands | 4.862 | 1.000 | 5.000 | 5.000 |
| Reported stress iterations | 258.995 | 0.000 | 504.000 | 238.758 |
| New broken bonds | 0.332 | 0.000 | 105.000 | 0.000 |
| Correction passes | 0.005 | 0.000 | 1.000 | 0.000 |

Active-body counters come from CPU scheduling, not a qualified GPU sleep mask; sleeping is disabled here. Contact reports/pair visits are work counts, not unique collisions. Retained stress bonds are topology membership, not the number processed in every iteration. Legacy public contact-pair/solver-row counters are incomplete on this GPU path and are excluded. Allocation capacity and memory-bandwidth/occupancy counters are not collected in this report.

| Counter association (host-scope capture) | Pearson r with total step time | Pearson r with stress-stream time |
|---|---|---|
| Stress iterations | 0.934 | 1.000 |
| Scheduled active bodies | 0.434 | 0.458 |
| Retained stress bonds | -0.486 | -0.506 |
| Solved contact reports | 0.186 | 0.207 |
| Correction passes | 0.317 | 0.049 |

Associations describe this one evolving scene; they are not causal scaling laws. A dash means a constant/insufficient sample. In particular, retained-body and bond counts co-vary with impact time; controlled workload variations are needed to establish their independent costs.

## Automatic bottleneck summary and next decision

Largest elapsed regions: Wait for GPU destruction result: 2.211 ms/step; Trial physics and remaining scene tasks: 0.889 ms/step; Submit contact loads and destruction: 0.114 ms/step.

Largest GPU-stream stage: Iterative stress solve to convergence (2.207 ms/step). A sub-1-ms target needs this measured cost reduced if it already exceeds 1 ms; increasing scene size would not remove it.

Late-scene stress remains active: 238.8 reported iterations/step in the last two seconds. No new fracture does not imply no stress work. Compare convergence, applied loads and contact changes before considering any result reuse; this report does not authorize skipped physics or relaxed convergence.

Evidence supports targeting the largest measured stages and investigating small-kernel/iteration scheduling. It does not distinguish memory-bandwidth limitation from arithmetic throughput: SM occupancy, bandwidth and instruction counters require a separate hardware-counter experiment. Scale an active workload only after comparing these per-step costs; the intact controls show geometry scaling alone.

## Reproduce, audit and extend

Capture and generate in one command: python3 tools/scripts/run-destruction-timing.py NEW_CAPTURE_DIRECTORY --trials 5 --gpu-trials 3 --seconds 10. Reports appear in NEW_CAPTURE_DIRECTORY/report. Regenerate from captures only: python3 tools/scripts/report-destruction-timing.py CAPTURE_DIRECTORY --output REPORT_DIRECTORY. Change the versioned tools/profiles/wall-penetration-timing.json configuration for additional physical workloads; every resolved command is retained.

report.json.gz contains every per-step partition, GPU region, CPU exclusive core-time scope, kernel symbol/source, transfer byte count, run signature and summary. campaign.json beside the captures records binary/library SHA-256 hashes, exact inputs, driver, GPU process/clock samples, and hashes of all raw files. Reports are generated from those recorded files, without querying the current GPU or inserting a generation timestamp.

Percentiles use nearest rank ceil(p × N), with 1-based ranks. Means pool equally long untraced runs; maxima retain all measured spikes. Event windows overlap and must not be added. Zero-size windows are omitted. Rounded display values can differ from the exact total by rounding; raw JSON preserves full precision.
