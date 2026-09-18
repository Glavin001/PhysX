# PhysX GPU destruction — measured timing breakdown

The penetration scene averages 4.741 ms per simulation/destruction step across 5 untraced repeats; the worst measured step is 9.017 ms. 80/3000 steps are below 1 ms. GPU stress occupies a mean 3.772 ms of destruction-stream elapsed time in the separate host-scope capture (78.6% of its simulation bracket; this overlaps submission/wait).

The intact one-building control costs 0.293 ms after its first step; 16 intact buildings cost 0.302 ms (1.03× for 16× geometry). This measures an idle baseline of the current implementation, not a fundamental GPU latency floor. Idle controls do not establish active-destruction scalability.

## Measurement contract and validity

| Check | Result |
|---|---|
| Capture completeness / recorded file hashes | PASS — every input capture hashed and validated |
| Stress convergence / correction limit | PASS — every accepted step converged; at most one correction per step |
| Fracture/topology signatures across repetitions and trace modes | MATCH over each capture duration (short GPU traces checked against the full-run prefix) |
| CPU observations / rendering / video encoding | Disabled in measured runs; compact SDK status observation remains outside simulate/fetch |
| Wall-time partition / GPU overlap accounting | PASS — disjoint scope tree closes; GPU interval unions remain inside the measured bracket |
| CUPTI loss / malformed timestamps | PASS — zero dropped activity records and zero invalid activity timestamps |
| GPU process isolation evidence | Require no GPU process before/after and at most one stable GPU PID during each run. GPU PIDs are in the host namespace; ownership is inferred from this lifecycle, not a container PID comparison. Clocks are observed, not locked. |
| Determinism | Same input configuration and stable report generation. GPU timings are not deterministic; repeated measurements retain variation. |

Hardware: NVIDIA GeForce RTX 4090; driver 595.71.05. Revision aa66b29c5d2e32e41ca9c0ad3bc8eecbd23f1ef7. One separate process per case is discarded. All measured frames, including first impact and first allocation, are retained. Untraced and host-scope runs advance 10 simulated seconds; CUPTI captures advance 3 seconds of the same input prefix, at 60 Hz. This short diagnostic campaign is not the planned five × 60-second scale qualification.

Timing starts immediately before scene.simulate and ends after blocking scene.fetchResults, including embedded destruction and correction. Scene construction, projectile creation before the step, compact post-step status observation, CSV output and GPU activity flush are outside this bracket. This is simulation cost, not the complete application tick. CPU profiling callbacks and concurrent CUPTI collection can still perturb the measured interval.

## Open capture limitation — failed traces are excluded, not repaired

2 earlier capture attempts failed. Their recorded errors and activity status are retained below and in the machine-readable data. Root cause is unresolved; the evidence does not distinguish a profiler/driver problem from a simulation issue exposed by tracing. No failed capture contributes timings. The full-duration untraced repetitions and host-scope captures completed. Kernel tables use separately completed short captures and make no claim about GPU execution after their end.

| Failed attempt | Exit | Step | Recorded error | Invalid activity timestamps |
|---|---|---|---|---|
| penetration-gpu-0 | 1 | 364 | INCOMPLETE native step 364: fetch=1 stage=4 broken=0 crushed=0 | 12918 |
| penetration-gpu-0-retry1 | 1 | 364 | INCOMPLETE native step 364: fetch=1 stage=4 broken=0 crushed=0 | 12918 |

## Untraced simulation cost — authoritative elapsed-time measurements

| Scene | Chunks | Bonds | Steps | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Max ms | ≥1 ms | >16.67 ms |
|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 444 | 896 | 3000 | 0.508 | 4.741 | 4.518 | 6.580 | 8.273 | 9.017 | 2920 | 0 |
| One intact building, no projectile | 444 | 896 | 3000 | 0.245 | 0.299 | 0.288 | 0.327 | 0.356 | 4.923 | 9 | 0 |
| 16 intact buildings, no projectiles | 7104 | 14336 | 3000 | 0.254 | 0.310 | 0.293 | 0.344 | 0.373 | 4.900 | 8 | 0 |

| Penetration repeat | Mean ms | Worst ms | Worst step | Sim time s | Resim | Stress iterations | Clusters | Scheduled active bodies | Solved contact reports |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 4.747 | 8.811 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |
| 2 | 4.742 | 8.792 | 37 | 0.633 | 0 | 503 | 43 | 44 | 473 |
| 3 | 4.734 | 8.796 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |
| 4 | 4.748 | 9.017 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |
| 5 | 4.731 | 8.728 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |

## Event-based windows — no fixed impact frame or hidden warm-up cutoff

| Window (overlapping; do not add) | Steps | Mean ms | p50 ms | p95 ms | Max ms |
|---|---|---|---|---|---|
| First accepted step | 5 | 4.420 | 5.175 | 5.531 | 5.531 |
| After startup, before first broken bond | 80 | 0.563 | 0.543 | 0.767 | 0.880 |
| Steps that execute correction | 15 | 8.036 | 8.287 | 9.017 | 9.017 |
| After the last newly broken bond | 2830 | 4.811 | 4.517 | 6.504 | 8.792 |
| Last two simulated seconds | 600 | 4.416 | 4.421 | 5.065 | 5.234 |

## Instrumentation overhead — never mix these captures

| Mode | Runs | Mean ms | Max ms | Mean / untraced same-prefix mean |
|---|---|---|---|---|
| No detailed profiling | 5 | 4.741 | 9.017 | 1.00× |
| CPU scopes + CUDA stream events | 1 | 4.801 | 9.072 | 1.01× |
| CPU scopes + CUDA events + CUPTI | 1 | 8.510 | 15.963 | 1.58× |

Profiling changes scheduling and adds overhead. Detailed tables describe their own measured capture; they are not a retrospective decomposition of the video or of an untraced maximum. Overhead is observed, not subtracted as a guessed correction.

## Additive wall-time breakdown — host-scope capture

Columns show all-step mean, first fracture (step 17), this capture's worst step (33), and the last-two-seconds mean. CPU/GPU designations describe what happens inside the scope, not exclusive processor execution. Rows are disjoint and add to the timestamp bracket. The bracket includes clock-read bookends around simulate/fetch; mean difference from the simulation timer is 1.47 µs.

| Operation | CPU / GPU responsibility | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.009 | 0.011 | 0.008 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.129 | 0.310 | 0.141 | 0.128 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 3.770 | 2.965 | 5.726 | 3.475 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.090 | 0.038 | 0.000 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.021 | 0.016 | 0.000 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.021 | 0.009 | 0.000 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.007 | 0.007 | 0.000 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.008 | 0.009 | 0.001 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 | 0.008 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.082 | 0.051 | 0.000 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.119 | 0.047 | 0.001 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.128 | 0.042 | 0.001 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.001 | 0.276 | 0.263 | 0.000 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.040 | 0.016 | 0.000 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.005 | 0.006 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.007 | 1.491 | 1.358 | 0.000 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.125 | 0.104 | 0.000 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.873 | 1.125 | 1.220 | 0.871 |
| TOTAL | Measured simulate/fetch bracket | 4.802 | 6.832 | 9.073 | 4.493 |

## Inside the destruction wait — GPU-stream elapsed time

These consecutive CUDA-event intervals include GPU execution plus stream scheduling/dependency gaps. They overlap the CPU submission/wait above and must NOT be added to wall time. The wait is the host observing completion of required work, not a second computation. Exact kernel execution is shown separately below.

| GPU stream operation | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|
| Convert solved contact impulses into chunk loads | 0.023 | 0.047 | 0.022 | 0.023 |
| Iterative stress solve to convergence | 3.772 | 2.892 | 5.639 | 3.477 |
| Evaluate material damage and fracture | 0.017 | 0.019 | 0.018 | 0.017 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.114 | 0.119 | 0.026 |
| Commit changes and rebuild stress topology | 0.030 | 0.032 | 0.029 | 0.030 |

## Actual GPU execution versus elapsed gaps — CUPTI capture

GPU capture duration: 3 s. Its final-two-seconds column covers simulation seconds 1–3, not the end of the full-duration run. This capture's first fracture is step 17; its worst step is 123. Concurrent GPU intervals are merged before summing. No GPU activity means no recorded kernel/copy/memset from this process, not proof of global GPU idleness or useful CPU computation. CPU core-time can exceed elapsed time and is never added to it.

| Disjoint wall-time category | Mean ms | First fracture ms | Worst step ms | Trace final 2 s ms |
|---|---|---|---|---|
| GPU kernel execution (union) | 4.686 | 3.855 | 6.525 | 4.720 |
| GPU copy/memset time not overlapping kernels | 0.070 | 0.145 | 0.069 | 0.072 |
| No recorded GPU execution | 3.755 | 4.987 | 9.371 | 4.079 |
| TOTAL measured bracket | 8.511 | 8.987 | 15.965 | 8.872 |

| Important region | Wall mean ms | GPU activity mean ms | No GPU activity mean ms |
|---|---|---|---|
| Trial physics and remaining scene tasks | 1.161 | 0.453 | 0.707 |
| Finish GPU work and reserve bodies | 7.082 | 4.181 | 2.901 |
| Resimulate changed interaction | 0.028 | 0.011 | 0.017 |

## Ordinary physics and resimulation — observed host substeps

Inclusive observed host scopes below can nest or overlap across worker threads. These rows explain the broad trial/correction regions; do not add them together. GPU work is dispatched asynchronously and need not execute inside its submitting host scope. Missing coverage remains in the parent region, rather than being presented as a measured operation.

| Host task / callback | Trial mean wall ms | Correction mean wall ms | Trial first-fracture ms | Correction first-fracture ms |
|---|---|---|---|---|
| Allocate contact-manager storage | 0.003 | 0.000 | 0.170 | 0.007 |
| Register contact managers | 0.002 | 0.000 | 0.007 | 0.002 |
| Register body/shape interactions | 0.001 | 0.000 | 0.003 | 0.018 |
| Register scene interactions | 0.001 | 0.000 | 0.002 | 0.014 |
| Complete broad phase and callbacks | 0.047 | 0.001 | 0.060 | 0.110 |
| Broad-phase completion stage 2 | 0.004 | 0.000 | 0.072 | 0.003 |
| Broad-phase completion stage 3 | 0.001 | 0.000 | 0.001 | 0.001 |
| Complete narrow phase | 0.128 | 0.001 | 0.077 | 0.112 |
| Insert contact dependencies into islands | 0.002 | 0.000 | 0.036 | 0.027 |
| Generate simulation islands | 0.011 | 0.000 | 0.009 | 0.006 |
| Finish island scheduling | 0.005 | 0.000 | 0.001 | 0.002 |
| Prepare dynamics tasks | 0.002 | 0.000 | 0.002 | 0.003 |
| Submit dynamics/constraint solve | 0.013 | 0.000 | 0.029 | 0.027 |
| Finish constraint partitioning | 0.058 | 0.001 | 0.073 | 0.148 |
| Dispatch lost contacts | 0.003 | 0.000 | 0.001 | 0.002 |
| Lost-contact completion stage 2 | 0.003 | 0.000 | 0.001 | 0.002 |
| Lost-contact completion stage 3 | 0.002 | 0.000 | 0.001 | 0.002 |
| Finish motion integration and solver tasks | 0.002 | 0.000 | 0.002 | 0.002 |

## Which GPU work consumes execution time?

Kernel durations below are execution sums. They can overlap across streams and are NOT additive elapsed wall time. Classification uses kernel symbols and CUDA source files; unknown symbols stay explicitly unclassified.

| GPU kernel family | Mean execution sum ms | First-fracture sum ms | Worst-step sum ms | Trace final 2 s sum ms |
|---|---|---|---|---|
| stress solver / stress topology | 3.686 | 2.524 | 5.259 | 3.696 |
| CUDA memory utility kernels | 0.547 | 0.395 | 0.780 | 0.548 |
| physics constraint preparation / solve / integration | 0.261 | 0.410 | 0.288 | 0.285 |
| shared physics utilities | 0.052 | 0.199 | 0.048 | 0.048 |
| physics narrow phase / contact lifecycle | 0.039 | 0.035 | 0.048 | 0.044 |
| physics broad phase | 0.031 | 0.087 | 0.030 | 0.030 |
| destruction orchestration / motion | 0.020 | 0.077 | 0.019 | 0.019 |
| destruction load gathering | 0.016 | 0.007 | 0.018 | 0.018 |
| destruction contact graph | 0.012 | 0.017 | 0.011 | 0.012 |
| destruction pre-solve contacts / islands | 0.008 | 0.007 | 0.008 | 0.009 |
| destruction material / damage | 0.007 | 0.008 | 0.007 | 0.007 |
| destruction connectivity / mass / slots | 0.005 | 0.056 | 0.004 | 0.004 |
| physics body / shape updates | 0.005 | 0.013 | 0.005 | 0.005 |
| shared CUDA scan / sort primitives | 0.001 | 0.027 | 0.000 | 0.000 |

Mean kernel dispatches per step: 2094.1; first-fracture dispatches: 1694. CUDA API wall union averages 8.064 ms, overlapping GPU work. Time inside synchronization APIs with no recorded GPU activity averages 2.923 ms; this includes driver/scheduler/dependency overhead, not proven useful CPU computation.

| Largest individual GPU kernels | Operation | Calls / step | Mean µs / call | Execution sum ms / step |
|---|---|---|---|---|
| nodeSpaceMatvec | Stress matrix × search direction | 277.183 | 4.870 | 1.350 |
| nodeSpaceUpdateDirection | Update stress search direction | 277.183 | 2.509 | 0.696 |
| nodeSpaceUpdateSolution | Update stress solution and residual | 277.183 | 2.469 | 0.684 |
| memset32 | Clear GPU scratch values | 554.500 | 0.986 | 0.547 |
| finalizeAndCheckConvergence | Reduce residuals and check convergence | 277.183 | 1.736 | 0.481 |
| finalizeAndRetire | Retire converged stress islands | 277.183 | 1.648 | 0.457 |
| solveStaticBlockTGS | Solve contacts against static boundaries | 4.611 | 21.792 | 0.100 |
| solveWholeIslandTGS | Solve a rigid-body constraint island | 4.067 | 14.352 | 0.058 |
| radixSortMultiCalculateRanksLaunchWithCount | shared physics utilities | 8.533 | 3.510 | 0.030 |
| radixSortMultiBlockLaunchWithCount | shared physics utilities | 8.533 | 2.515 | 0.021 |
| solveBlockUnified | physics constraint preparation / solve / integration | 4.733 | 4.498 | 0.021 |
| markActiveSlabTGS | physics constraint preparation / solve / integration | 4.583 | 3.075 | 0.014 |

Stress iterations are numerical convergence iterations, not additional resimulations. CUDA-graph guarded tail kernels can execute beyond the reported iteration count; kernel dispatch counts are shown separately. Small per-call times combined with repeated dependent launches identify a scheduling/fusion investigation, not proof of a particular hardware throughput limit.

## CPU execution — core time, separate from elapsed wall time

| Host scope | Mean exclusive CPU core-ms / step |
|---|---|
| finishDetail.waitForGpu | 3.769 |
| submit | 0.129 |
| trialDetail.postNarrowPhase | 0.108 |
| trialDetail.updateDynamicsPostPartitioning | 0.058 |
| task.prepareIslandRepair | 0.053 |
| trialDetail.postBroadPhase | 0.046 |
| trialDetail.updateDynamics | 0.013 |
| task.speculativeIslandMaintenance | 0.011 |
| task.accurateIslandMaintenance | 0.011 |
| checkpoint | 0.008 |

Process CPU time averages 5.326 core-ms per step in the host-scope capture. CPU thread clocks include busy waiting, driver and profiling work, but exclude descheduling. Same-thread children are subtracted from their parent; detached/cross-thread spans are excluded. Parallel CPU core-ms must not be added to wall-ms or GPU time. A large wait scope's CPU time does not mean the stress math runs on the CPU.

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
| Reported stress iterations | 258.990 | 0.000 | 504.000 | 238.550 |
| New broken bonds | 0.332 | 0.000 | 105.000 | 0.000 |
| Correction passes | 0.005 | 0.000 | 1.000 | 0.000 |

Active-body counters come from CPU scheduling, not a qualified GPU sleep mask; sleeping is disabled here. Contact reports/pair visits are work counts, not unique collisions. Retained stress bonds are topology membership, not the number processed in every iteration. Legacy public contact-pair/solver-row counters are incomplete on this GPU path and are excluded. Allocation capacity and memory-bandwidth/occupancy counters are not collected in this report.

| Counter association (host-scope capture) | Pearson r with total step time | Pearson r with stress-stream time |
|---|---|---|
| Stress iterations | 0.975 | 1.000 |
| Scheduled active bodies | 0.456 | 0.462 |
| Retained stress bonds | -0.506 | -0.508 |
| Solved contact reports | 0.202 | 0.210 |
| Correction passes | 0.218 | 0.051 |

Associations describe this one evolving scene; they are not causal scaling laws. A dash means a constant/insufficient sample. In particular, retained-body and bond counts co-vary with impact time; controlled workload variations are needed to establish their independent costs.

## Automatic bottleneck summary and next decision

Largest elapsed regions: Wait for GPU destruction result: 3.770 ms/step; Trial physics and remaining scene tasks: 0.873 ms/step; Submit contact loads and destruction: 0.129 ms/step.

Largest GPU-stream stage: Iterative stress solve to convergence (3.772 ms/step). A sub-1-ms target needs this measured cost reduced if it already exceeds 1 ms; increasing scene size would not remove it.

Late-scene stress remains active: 238.6 reported iterations/step in the last two seconds. No new fracture does not imply no stress work. Compare convergence, applied loads and contact changes before considering any result reuse; this report does not authorize skipped physics or relaxed convergence.

Evidence supports targeting the largest measured stages and investigating small-kernel/iteration scheduling. It does not distinguish memory-bandwidth limitation from arithmetic throughput: SM occupancy, bandwidth and instruction counters require a separate hardware-counter experiment. Scale an active workload only after comparing these per-step costs; the intact controls show geometry scaling alone.

## Reproduce, audit and extend

Capture and generate in one command: python3 tools/scripts/run-destruction-timing.py NEW_CAPTURE_DIRECTORY --trials 5 --seconds 10 --gpu-seconds 3. Reports appear in NEW_CAPTURE_DIRECTORY/report. Regenerate from captures only: python3 tools/scripts/report-destruction-timing.py CAPTURE_DIRECTORY --output REPORT_DIRECTORY. Change the versioned tools/profiles/wall-penetration-timing.json configuration for additional physical workloads; every resolved command is retained.

report.json.gz contains every per-step partition, GPU region, CPU exclusive core-time scope, kernel symbol/source, transfer byte count, run signature and summary. campaign.json beside the captures records binary/library SHA-256 hashes, exact inputs, driver, GPU process/clock samples, and hashes of all raw files. Reports are generated from those recorded files, without querying the current GPU or inserting a generation timestamp.

Percentiles use nearest rank ceil(p × N), with 1-based ranks. Means pool equally long untraced runs; maxima retain all measured spikes. Event windows overlap and must not be added. Zero-size windows are omitted. Rounded display values can differ from the exact total by rounding; raw JSON preserves full precision.
