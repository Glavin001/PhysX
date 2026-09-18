# PhysX GPU destruction — measured timing breakdown

The penetration scene averages 4.732 ms per simulation/destruction step across 5 untraced repeats; the worst measured step is 8.980 ms. 80/3000 steps are below 1 ms. GPU stress occupies a mean 3.785 ms of destruction-stream elapsed time in the separate host-scope capture (78.4% of its simulation bracket; this overlaps submission/wait).

The intact one-building control costs 0.293 ms after its first step; 16 intact buildings cost 0.295 ms (1.01× for 16× geometry). This measures an idle baseline of the current implementation, not a fundamental GPU latency floor. Idle controls do not establish active-destruction scalability.

## Measurement contract and validity

| Check | Result |
|---|---|
| Capture completeness / recorded file hashes | PASS — every input capture hashed and validated |
| Stress convergence / correction limit | PASS — every accepted step converged; at most one correction per step |
| Fracture/topology signatures across repetitions and trace modes | MATCH across full-duration untraced, host-scope and GPU captures |
| CPU observations / rendering / video encoding | Disabled in measured runs; compact SDK status observation remains outside simulate/fetch |
| Wall-time partition / GPU overlap accounting | PASS — disjoint scope tree closes; GPU interval unions remain inside the measured bracket |
| CUPTI loss / malformed timestamps | PASS — every full-duration GPU repetition has zero dropped records and zero invalid timestamps |
| CUPTI configuration | Header/runtime API version 130202; device-graph trace buffer 512 MiB per context. No solver or physical-input changes. |
| GPU process isolation evidence | Require no GPU process before/after and at most one stable GPU PID during each run. GPU PIDs are in the host namespace; ownership is inferred from this lifecycle, not a container PID comparison. Clocks are observed, not locked. |
| Determinism | Same input configuration and stable report generation. GPU timings are not deterministic; repeated measurements retain variation. |

Hardware: NVIDIA GeForce RTX 4090; driver 595.71.05. Revision 99246900bfd95a4fb9dbd65dd9b720b0c0817b40. One separate process per case is discarded. All measured frames, including first impact and first allocation, are retained. All modes advance 10 simulated seconds; 3 complete CUPTI repetitions per scene, at 60 Hz. This short diagnostic campaign is not the planned five × 60-second scale qualification.

Timing starts immediately before scene.simulate and ends after blocking scene.fetchResults, including embedded destruction and correction. Scene construction, projectile creation before the step, compact post-step status observation, CSV output and GPU activity flush are outside this bracket. This is simulation cost, not the complete application tick. CPU profiling callbacks and concurrent CUPTI collection can still perturb the measured interval.

## Untraced simulation cost — authoritative elapsed-time measurements

| Scene | Chunks | Bonds | Steps | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Max ms | ≥1 ms | >16.67 ms |
|---|---|---|---|---|---|---|---|---|---|---|---|
| One building, projectile penetration | 444 | 896 | 3000 | 0.488 | 4.732 | 4.518 | 6.544 | 8.064 | 8.980 | 2920 | 0 |
| One intact building, no projectile | 444 | 896 | 3000 | 0.234 | 0.300 | 0.288 | 0.329 | 0.358 | 4.657 | 8 | 0 |
| 16 intact buildings, no projectiles | 7104 | 14336 | 3000 | 0.253 | 0.301 | 0.289 | 0.331 | 0.354 | 4.808 | 8 | 0 |

| Penetration repeat | Mean ms | Worst ms | Worst step | Sim time s | Resim | Stress iterations | Clusters | Scheduled active bodies | Solved contact reports |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 4.724 | 8.544 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |
| 2 | 4.727 | 8.860 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |
| 3 | 4.741 | 8.980 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |
| 4 | 4.746 | 8.843 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |
| 5 | 4.722 | 8.576 | 33 | 0.567 | 1 | 391 | 43 | 44 | 500 |

## Event-based windows — no fixed impact frame or hidden warm-up cutoff

| Window (overlapping; do not add) | Steps | Mean ms | p50 ms | p95 ms | Max ms |
|---|---|---|---|---|---|
| First accepted step | 5 | 3.449 | 3.013 | 5.256 | 5.256 |
| After startup, before first broken bond | 80 | 0.549 | 0.525 | 0.747 | 0.944 |
| Steps that execute correction | 15 | 7.946 | 8.031 | 8.980 | 8.980 |
| After the last newly broken bond | 2830 | 4.808 | 4.518 | 6.494 | 8.723 |
| Last two simulated seconds | 600 | 4.420 | 4.418 | 5.071 | 6.568 |

## Instrumentation overhead — never mix these captures

| Mode | Runs | Mean ms | Max ms | Mean / untraced mean |
|---|---|---|---|---|
| No detailed profiling | 5 | 4.732 | 8.980 | 1.00× |
| CPU scopes + CUDA stream events | 1 | 4.825 | 9.328 | 1.02× |
| CPU scopes + CUDA events + CUPTI | 3 | 8.320 | 26.164 | 1.76× |

Profiling changes scheduling and adds overhead. Detailed tables describe their own measured capture; they are not a retrospective decomposition of the video or of an untraced maximum. Overhead is observed, not subtracted as a guessed correction.

## Additive wall-time breakdown — host-scope capture

Columns show all-step mean, first fracture (step 17), this capture's worst step (33), and the last-two-seconds mean. CPU/GPU designations describe what happens inside the scope, not exclusive processor execution. Rows are disjoint and add to the timestamp bracket. The bracket includes clock-read bookends around simulate/fetch; mean difference from the simulation timer is 1.51 µs.

| Operation | CPU / GPU responsibility | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.010 | 0.008 | 0.009 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.128 | 0.369 | 0.137 | 0.122 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 3.785 | 3.102 | 6.013 | 3.483 |
| Read fragment-allocation requests | GPU → CPU allocation metadata and completion dependency | 0.000 | 0.137 | 0.035 | 0.000 |
| Reserve native fragment bodies | CPU PhysX body/lifecycle allocation | 0.000 | 0.029 | 0.006 | 0.000 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.030 | 0.007 | 0.000 |
| Publish reservation metadata | CPU bookkeeping and GPU status submission | 0.000 | 0.009 | 0.007 | 0.000 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.001 | 0.011 | 0.008 | 0.001 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.012 | 0.007 | 0.007 |
| Initialize reserved fragment bodies | CPU dispatch/lifecycle + GPU state initialization | 0.000 | 0.111 | 0.046 | 0.000 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.135 | 0.042 | 0.001 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.002 | 0.184 | 0.057 | 0.001 |
| Apply ownership/lifecycle changes | CPU PhysX ownership and lifecycle bridge | 0.001 | 0.298 | 0.251 | 0.000 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.044 | 0.019 | 0.000 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.000 | 0.006 | 0.006 | 0.000 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.008 | 1.623 | 1.374 | 0.000 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.001 | 0.137 | 0.105 | 0.000 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 0.884 | 1.167 | 1.201 | 0.886 |
| TOTAL | Measured simulate/fetch bracket | 4.826 | 7.412 | 9.329 | 4.510 |

## Inside the destruction wait — GPU-stream elapsed time

These consecutive CUDA-event intervals include GPU execution plus stream scheduling/dependency gaps. They overlap the CPU submission/wait above and must NOT be added to wall time. The wait is the host observing completion of required work, not a second computation. Exact kernel execution is shown separately below.

| GPU stream operation | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|
| Convert solved contact impulses into chunk loads | 0.023 | 0.063 | 0.024 | 0.023 |
| Iterative stress solve to convergence | 3.785 | 3.040 | 5.914 | 3.479 |
| Evaluate material damage and fracture | 0.017 | 0.020 | 0.017 | 0.017 |
| Connectivity, cluster mass and fragment candidates | 0.027 | 0.120 | 0.126 | 0.026 |
| Commit changes and rebuild stress topology | 0.031 | 0.032 | 0.030 | 0.030 |

## Actual GPU execution versus elapsed gaps — CUPTI capture

Detailed GPU tables use repetition 1; all 3 repetitions pass full validation and contribute to the overhead table. GPU capture duration: 10 s. Its final-two-seconds column covers simulation seconds 8–10. This capture's first fracture is step 17; its worst step is 236. Concurrent GPU intervals are merged before summing. No GPU activity means no recorded kernel/copy/memset from this process, not proof of global GPU idleness or useful CPU computation. CPU core-time can exceed elapsed time and is never added to it.

| Disjoint wall-time category | Mean ms | First fracture ms | Worst step ms | Trace final 2 s ms |
|---|---|---|---|---|
| GPU kernel execution (union) | 4.450 | 3.857 | 4.182 | 4.144 |
| GPU copy/memset time not overlapping kernels | 0.068 | 0.139 | 0.082 | 0.067 |
| No recorded GPU execution | 3.813 | 6.281 | 21.903 | 3.687 |
| TOTAL measured bracket | 8.331 | 10.276 | 26.166 | 7.898 |

| Important region | Wall mean ms | GPU activity mean ms | No GPU activity mean ms |
|---|---|---|---|
| Trial physics and remaining scene tasks | 1.179 | 0.476 | 0.703 |
| Finish GPU work and reserve bodies | 0.016 | 0.000 | 0.016 |
| Resimulate changed interaction | 0.009 | 0.003 | 0.006 |

## Ordinary physics and resimulation — observed host substeps

Inclusive observed host scopes below can nest or overlap across worker threads. These rows explain the broad trial/correction regions; do not add them together. GPU work is dispatched asynchronously and need not execute inside its submitting host scope. Missing coverage remains in the parent region, rather than being presented as a measured operation.

| Host task / callback | Trial mean wall ms | Correction mean wall ms | Trial first-fracture ms | Correction first-fracture ms |
|---|---|---|---|---|
| Allocate contact-manager storage | 0.004 | 0.000 | 0.163 | 0.009 |
| Register contact managers | 0.002 | 0.000 | 0.007 | 0.003 |
| Register body/shape interactions | 0.001 | 0.000 | 0.004 | 0.010 |
| Register scene interactions | 0.001 | 0.000 | 0.002 | 0.020 |
| Complete broad phase and callbacks | 0.049 | 0.001 | 0.067 | 0.110 |
| Broad-phase completion stage 2 | 0.005 | 0.000 | 0.080 | 0.014 |
| Broad-phase completion stage 3 | 0.001 | 0.000 | 0.001 | 0.001 |
| Complete narrow phase | 0.124 | 0.001 | 0.090 | 0.127 |
| Insert contact dependencies into islands | 0.002 | 0.000 | 0.036 | 0.018 |
| Generate simulation islands | 0.011 | 0.000 | 0.013 | 0.015 |
| Finish island scheduling | 0.004 | 0.000 | 0.001 | 0.009 |
| Prepare dynamics tasks | 0.002 | 0.000 | 0.002 | 0.004 |
| Submit dynamics/constraint solve | 0.015 | 0.000 | 0.030 | 0.027 |
| Finish constraint partitioning | 0.059 | 0.001 | 0.081 | 0.134 |
| Dispatch lost contacts | 0.003 | 0.000 | 0.001 | 0.001 |
| Lost-contact completion stage 2 | 0.003 | 0.000 | 0.002 | 0.001 |
| Lost-contact completion stage 3 | 0.002 | 0.000 | 0.001 | 0.001 |
| Finish motion integration and solver tasks | 0.002 | 0.000 | 0.002 | 0.002 |

## Which GPU work consumes execution time?

Kernel durations below are execution sums. They can overlap across streams and are NOT additive elapsed wall time. Classification uses kernel symbols and CUDA source files; unknown symbols stay explicitly unclassified.

| GPU kernel family | Mean execution sum ms | First-fracture sum ms | Worst-step sum ms | Trace final 2 s sum ms |
|---|---|---|---|---|
| stress solver / stress topology | 3.467 | 2.524 | 3.224 | 3.197 |
| CUDA memory utility kernels | 0.514 | 0.395 | 0.477 | 0.474 |
| physics constraint preparation / solve / integration | 0.278 | 0.410 | 0.286 | 0.285 |
| shared physics utilities | 0.049 | 0.198 | 0.048 | 0.048 |
| physics narrow phase / contact lifecycle | 0.042 | 0.035 | 0.045 | 0.041 |
| physics broad phase | 0.030 | 0.086 | 0.029 | 0.029 |
| destruction orchestration / motion | 0.019 | 0.077 | 0.019 | 0.018 |
| destruction load gathering | 0.017 | 0.007 | 0.018 | 0.018 |
| destruction contact graph | 0.011 | 0.016 | 0.011 | 0.011 |
| destruction pre-solve contacts / islands | 0.008 | 0.007 | 0.008 | 0.008 |
| destruction material / damage | 0.007 | 0.008 | 0.007 | 0.007 |
| physics body / shape updates | 0.005 | 0.013 | 0.006 | 0.005 |
| destruction connectivity / mass / slots | 0.005 | 0.056 | 0.004 | 0.004 |
| shared CUDA scan / sort primitives | 0.000 | 0.027 | 0.000 | 0.000 |

Mean kernel dispatches per step: 1977.6; first-fracture dispatches: 1694. CUDA API wall union averages 7.910 ms, overlapping GPU work. Time inside synchronization APIs with no recorded GPU activity averages 0.040 ms; this includes driver/scheduler/dependency overhead, not proven useful CPU computation.

| Largest individual GPU kernels | Operation | Calls / step | Mean µs / call | Execution sum ms / step |
|---|---|---|---|---|
| nodeSpaceMatvec | Stress matrix × search direction | 260.570 | 4.870 | 1.269 |
| nodeSpaceUpdateDirection | Update stress search direction | 260.570 | 2.511 | 0.654 |
| nodeSpaceUpdateSolution | Update stress solution and residual | 260.570 | 2.470 | 0.643 |
| memset32 | Clear GPU scratch values | 521.180 | 0.986 | 0.514 |
| finalizeAndCheckConvergence | Reduce residuals and check convergence | 260.570 | 1.736 | 0.452 |
| finalizeAndRetire | Retire converged stress islands | 260.570 | 1.648 | 0.429 |
| solveStaticBlockTGS | Solve contacts against static boundaries | 4.883 | 22.957 | 0.112 |
| solveWholeIslandTGS | Solve a rigid-body constraint island | 4.020 | 14.880 | 0.060 |
| radixSortMultiCalculateRanksLaunchWithCount | shared physics utilities | 8.160 | 3.515 | 0.029 |
| solveBlockUnified | physics constraint preparation / solve / integration | 4.920 | 4.480 | 0.022 |
| radixSortMultiBlockLaunchWithCount | shared physics utilities | 8.160 | 2.515 | 0.021 |
| routeContacts | destruction load gathering | 0.972 | 15.736 | 0.015 |

Stress iterations are numerical convergence iterations, not additional resimulations. CUDA-graph guarded tail kernels can execute beyond the reported iteration count; kernel dispatch counts are shown separately. Small per-call times combined with repeated dependent launches identify a scheduling/fusion investigation, not proof of a particular hardware throughput limit.

## CPU execution — core time, separate from elapsed wall time

| Host scope | Mean exclusive CPU core-ms / step |
|---|---|
| finishDetail.waitForGpu | 3.784 |
| submit | 0.128 |
| trialDetail.postNarrowPhase | 0.106 |
| trialDetail.updateDynamicsPostPartitioning | 0.058 |
| task.prepareIslandRepair | 0.052 |
| trialDetail.postBroadPhase | 0.047 |
| trialDetail.updateDynamics | 0.014 |
| task.speculativeIslandMaintenance | 0.012 |
| task.accurateIslandMaintenance | 0.011 |
| checkpoint | 0.008 |

Process CPU time averages 5.381 core-ms per step in the host-scope capture. CPU thread clocks include busy waiting, driver and profiling work, but exclude descheduling. Same-thread children are subtracted from their parent; detached/cross-thread spans are excluded. Parallel CPU core-ms must not be added to wall-ms or GPU time. A large wait scope's CPU time does not mean the stress math runs on the CPU.

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
| Reported stress iterations | 258.972 | 0.000 | 504.000 | 238.567 |
| New broken bonds | 0.332 | 0.000 | 105.000 | 0.000 |
| Correction passes | 0.005 | 0.000 | 1.000 | 0.000 |

Active-body counters come from CPU scheduling, not a qualified GPU sleep mask; sleeping is disabled here. Contact reports/pair visits are work counts, not unique collisions. Retained stress bonds are topology membership, not the number processed in every iteration. Legacy public contact-pair/solver-row counters are incomplete on this GPU path and are excluded. Allocation capacity and memory-bandwidth/occupancy counters are not collected in this report.

| Counter association (host-scope capture) | Pearson r with total step time | Pearson r with stress-stream time |
|---|---|---|
| Stress iterations | 0.969 | 0.999 |
| Scheduled active bodies | 0.421 | 0.440 |
| Retained stress bonds | -0.474 | -0.489 |
| Solved contact reports | 0.168 | 0.191 |
| Correction passes | 0.230 | 0.064 |

Associations describe this one evolving scene; they are not causal scaling laws. A dash means a constant/insufficient sample. In particular, retained-body and bond counts co-vary with impact time; controlled workload variations are needed to establish their independent costs.

## Automatic bottleneck summary and next decision

Largest elapsed regions: Wait for GPU destruction result: 3.785 ms/step; Trial physics and remaining scene tasks: 0.884 ms/step; Submit contact loads and destruction: 0.128 ms/step.

Largest GPU-stream stage: Iterative stress solve to convergence (3.785 ms/step). A sub-1-ms target needs this measured cost reduced if it already exceeds 1 ms; increasing scene size would not remove it.

Late-scene stress remains active: 238.6 reported iterations/step in the last two seconds. No new fracture does not imply no stress work. Compare convergence, applied loads and contact changes before considering any result reuse; this report does not authorize skipped physics or relaxed convergence.

Evidence supports targeting the largest measured stages and investigating small-kernel/iteration scheduling. It does not distinguish memory-bandwidth limitation from arithmetic throughput: SM occupancy, bandwidth and instruction counters require a separate hardware-counter experiment. Scale an active workload only after comparing these per-step costs; the intact controls show geometry scaling alone.

## Reproduce, audit and extend

Capture and generate in one command: python3 tools/scripts/run-destruction-timing.py NEW_CAPTURE_DIRECTORY --trials 5 --gpu-trials 3 --seconds 10. Reports appear in NEW_CAPTURE_DIRECTORY/report. Regenerate from captures only: python3 tools/scripts/report-destruction-timing.py CAPTURE_DIRECTORY --output REPORT_DIRECTORY. Change the versioned tools/profiles/wall-penetration-timing.json configuration for additional physical workloads; every resolved command is retained.

report.json.gz contains every per-step partition, GPU region, CPU exclusive core-time scope, kernel symbol/source, transfer byte count, run signature and summary. campaign.json beside the captures records binary/library SHA-256 hashes, exact inputs, driver, GPU process/clock samples, and hashes of all raw files. Reports are generated from those recorded files, without querying the current GPU or inserting a generation timestamp.

Percentiles use nearest rank ceil(p × N), with 1-based ranks. Means pool equally long untraced runs; maxima retain all measured spikes. Event windows overlap and must not be added. Zero-size windows are omitted. Rounded display values can differ from the exact total by rounding; raw JSON preserves full precision.
