# PhysX GPU destruction — measured timing breakdown

Detailed focus: 256 buildings, simultaneous aerial impacts — 113,664 chunks, 229,376 bonds. All configured scenes appear in the comparison table; detailed sections use this first configured scene.

The selected scene’s simulate/fetch subinterval averages 19.965 ms per step across 2 untraced repeats; the worst measured step is 65.883 ms. 0/360 steps are below 1 ms. GPU stress occupies a mean 12.851 ms of destruction-stream elapsed time in the separate host-scope capture (63.5% of its simulation bracket; this overlaps submission/wait).

## 🎯 Authoritative complete advance — commands through committed completion

❌ Deadline failed: 198 complete steps exceeded 8.0 ms. Every measured step is retained. Full plan and endurance qualification remain incomplete.

| Untraced repeat | Steps | Mean ms | Peak ms | >8 ms | Peak step | CPU commands at peak ms | PhysX/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|
| 1 | 180 | 19.962 | 65.942 | 99 | 103 | 0.000 | 65.883 | 0.058 |
| 2 | 180 | 20.222 | 64.653 | 99 | 103 | 0.000 | 64.592 | 0.060 |

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

Hardware: NVIDIA GeForce RTX 4090; driver 595.71.05. Revision 15a3edd84b795cf12cacfb6636d0aa1fe7ff7883. One separate process per case is discarded. All measured frames, including first impact and first allocation, are retained. All modes advance 3 simulated seconds; 1 complete CUPTI repetitions per scene, at 60 Hz. This short diagnostic campaign is not the planned five × 60-second scale qualification.

The detailed profiling bracket starts immediately before scene.simulate and ends after blocking scene.fetchResults, including embedded destruction and correction. Scene construction, projectile creation before the step, compact post-step status observation, CSV output and GPU activity flush are outside this bracket. This is simulation cost, not the complete application tick. CPU profiling callbacks and concurrent CUPTI collection can still perturb the measured interval.

## Untraced simulate/fetch cost — subinterval of the complete advance

| Scene | Chunks | Bonds | Steps | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Max ms | ≥1 ms | >16.67 ms |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 360 | 1.039 | 19.965 | 27.248 | 40.061 | 55.758 | 65.883 | 360 | 196 |

| Selected scene repeat | Mean ms | Worst ms | Worst step | Sim time s | Resim | Stress iterations | Clusters | Scheduled active bodies | Solved contact reports |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 19.845 | 65.883 | 103 | 1.733 | 1 | 537 | 11816 | 12072 | 109383 |
| 2 | 20.084 | 64.592 | 103 | 1.733 | 1 | 537 | 11816 | 12072 | 109383 |

## Event-based windows — no fixed impact frame or hidden warm-up cutoff

| Window (overlapping; do not add) | Steps | Mean ms | p50 ms | p95 ms | Max ms |
|---|---|---|---|---|---|
| First accepted step | 2 | 9.925 | 8.628 | 11.223 | 11.223 |
| After startup, before first broken bond | 162 | 1.133 | 1.112 | 1.223 | 2.089 |
| Steps that execute correction | 154 | 37.672 | 37.392 | 43.813 | 65.883 |
| Last two simulated seconds | 240 | 29.316 | 35.733 | 41.579 | 65.883 |

## Instrumentation overhead — never mix these captures

| Mode | Runs | Mean ms | Max ms | Mean / untraced mean |
|---|---|---|---|---|
| No detailed profiling | 2 | 19.965 | 65.883 | 1.00× |
| CPU scopes + CUDA stream events | 1 | 20.247 | 66.542 | 1.01× |
| CPU scopes + CUDA events + CUPTI | 1 | 20.938 | 67.991 | 1.05× |

Profiling changes scheduling and adds overhead. Detailed tables describe their own measured capture; they are not a retrospective decomposition of the video or of an untraced maximum. Overhead is observed, not subtracted as a guessed correction.

## Additive wall-time breakdown — host-scope capture

Columns show all-step mean, first fracture (step 82), this capture's worst step (103), and the last-two-seconds mean. CPU/GPU designations describe what happens inside the scope, not exclusive processor execution. Rows are disjoint and add to the timestamp bracket. The bracket includes clock-read bookends around simulate/fetch; mean difference from the simulation timer is 1.51 µs.

| Operation | CPU / GPU responsibility | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.014 | 0.009 | 0.009 | 0.016 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.132 | 0.697 | 0.162 | 0.136 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 13.292 | 10.959 | 23.164 | 19.736 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.002 | 0.022 | 0.120 | 0.003 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.048 | 0.145 | 0.114 | 0.072 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.121 | 5.752 | 3.885 | 0.182 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.002 | 0.020 | 0.008 | 0.003 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.003 | 0.011 | 0.012 | 0.004 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.007 | 0.011 | 0.007 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.007 | 0.077 | 0.039 | 0.010 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.011 | 0.183 | 0.024 | 0.016 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.008 | 0.073 | 0.017 | 0.011 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.083 | 0.188 | 0.196 | 0.124 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.016 | 0.833 | 0.362 | 0.025 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.004 | 0.239 | 0.068 | 0.006 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.006 | 0.273 | 0.144 | 0.009 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.041 | 0.590 | 1.001 | 0.061 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.019 | 0.622 | 0.507 | 0.029 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.010 | 0.515 | 0.205 | 0.015 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.034 | 1.608 | 0.808 | 0.051 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.068 | 4.811 | 1.316 | 0.102 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.039 | 0.118 | 0.120 | 0.059 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.062 | 0.023 | 0.011 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.006 | 0.006 | 0.004 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 2.211 | 32.379 | 23.614 | 3.316 |
| Accept corrected step | GPU commit/status completion and CPU publication | 1.188 | 2.856 | 2.818 | 1.781 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 2.874 | 3.188 | 7.792 | 3.942 |
| TOTAL | Measured simulate/fetch bracket | 20.249 | 66.239 | 66.543 | 29.731 |

## Inside the destruction wait — GPU-stream elapsed time

These consecutive CUDA-event intervals include GPU execution plus stream scheduling/dependency gaps. They overlap the CPU submission/wait above and must NOT be added to wall time. The wait is the host observing completion of required work, not a second computation. Exact kernel execution is shown separately below.

| GPU stream operation | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|
| Convert solved contact impulses into chunk loads | 0.096 | 0.607 | 0.137 | 0.126 |
| Iterative stress solve to convergence | 12.851 | 10.463 | 22.569 | 19.116 |
| Evaluate material damage and fracture | 0.069 | 0.076 | 0.068 | 0.067 |
| Connectivity, cluster mass and fragment candidates | 0.239 | 0.451 | 0.484 | 0.341 |
| Commit changes and rebuild stress topology | 0.144 | 0.040 | 0.038 | 0.194 |

## Actual GPU execution versus elapsed gaps — CUPTI capture

Detailed GPU tables use repetition 1; all 1 repetitions pass full validation and contribute to the overhead table. GPU capture duration: 3 s. Its final-two-seconds column covers simulation seconds 1–3. This capture's first fracture is step 82; its worst step is 103. Concurrent GPU intervals are merged before summing. No GPU activity means no recorded kernel/copy/memset from this process, not proof of global GPU idleness or useful CPU computation. CPU core-time can exceed elapsed time and is never added to it.

| Disjoint wall-time category | Mean ms | First fracture ms | Worst step ms | Trace final 2 s ms |
|---|---|---|---|---|
| GPU kernel execution (union) | 16.747 | 22.305 | 33.845 | 24.725 |
| GPU copy/memset time not overlapping kernels | 0.499 | 0.728 | 1.366 | 0.727 |
| No recorded GPU execution | 3.694 | 39.691 | 32.783 | 5.115 |
| TOTAL measured bracket | 20.940 | 62.724 | 67.994 | 30.568 |

| Important region | Wall mean ms | GPU activity mean ms | No GPU activity mean ms |
|---|---|---|---|
| Trial physics and remaining scene tasks | 3.091 | 1.289 | 1.802 |
| Finish GPU work and reserve bodies | 0.315 | 0.107 | 0.208 |
| Resimulate changed interaction | 2.253 | 1.455 | 0.798 |

## Ordinary physics and resimulation — observed host substeps

Inclusive observed host scopes below can nest or overlap across worker threads. These rows explain the broad trial/correction regions; do not add them together. GPU work is dispatched asynchronously and need not execute inside its submitting host scope. Missing coverage remains in the parent region, rather than being presented as a measured operation.

| Host task / callback | Trial mean wall ms | Correction mean wall ms | Trial first-fracture ms | Correction first-fracture ms |
|---|---|---|---|---|
| Allocate contact-manager storage | 0.042 | 0.037 | 0.341 | 2.961 |
| Register contact managers | 0.032 | 0.005 | 0.130 | 0.128 |
| Register body/shape interactions | 0.043 | 0.023 | 0.195 | 1.842 |
| Register scene interactions | 0.073 | 0.052 | 0.056 | 3.371 |
| Complete broad phase and callbacks | 0.449 | 0.804 | 0.276 | 7.464 |
| Wait for GPU broad phase and pair publication | 0.436 | 0.799 | 0.266 | 7.449 |
| Broad-phase completion stage 2 | 0.013 | 0.037 | 0.017 | 1.627 |
| Broad-phase completion stage 3 | 0.001 | 0.000 | 0.001 | 0.001 |
| Complete narrow phase | 0.218 | 0.125 | 0.118 | 0.811 |
| Insert contact dependencies into islands | 0.090 | 0.052 | 0.082 | 2.647 |
| Generate simulation islands | 0.029 | 0.009 | 0.048 | 0.207 |
| Finish island scheduling | 0.002 | 0.001 | 0.002 | 0.001 |
| Prepare dynamics tasks | 0.002 | 0.001 | 0.002 | 0.002 |
| Submit dynamics/constraint solve | 0.079 | 0.054 | 0.031 | 1.336 |
| Finish constraint partitioning | 0.058 | 0.076 | 0.084 | 1.090 |
| Dispatch lost contacts | 0.003 | 0.002 | 0.001 | 0.003 |
| Lost-contact completion stage 2 | 0.053 | 0.002 | 0.001 | 0.002 |
| Lost-contact completion stage 3 | 0.109 | 0.001 | 0.001 | 0.002 |
| Finish motion integration and solver tasks | 0.001 | 0.001 | 0.002 | 0.003 |

## Which GPU work consumes execution time?

Kernel durations below are execution sums. They can overlap across streams and are NOT additive elapsed wall time. Classification uses kernel symbols and CUDA source files; unknown symbols stay explicitly unclassified.

| GPU kernel family | Mean execution sum ms | First-fracture sum ms | Worst-step sum ms | Trace final 2 s sum ms |
|---|---|---|---|---|
| stress solver / stress topology | 12.783 | 10.342 | 21.821 | 19.024 |
| unclassified | 1.228 | 2.536 | 2.618 | 1.833 |
| physics broad phase | 1.016 | 7.308 | 6.037 | 1.445 |
| physics constraint preparation / solve / integration | 0.841 | 0.646 | 1.797 | 1.235 |
| shared physics utilities | 0.205 | 0.348 | 0.333 | 0.253 |
| physics narrow phase / contact lifecycle | 0.197 | 0.121 | 0.633 | 0.296 |
| destruction orchestration / motion | 0.152 | 0.370 | 0.322 | 0.215 |
| destruction connectivity / mass / slots | 0.141 | 0.250 | 0.310 | 0.209 |
| destruction load gathering | 0.086 | 0.045 | 0.127 | 0.114 |
| destruction material / damage | 0.062 | 0.078 | 0.067 | 0.064 |
| shared CUDA scan / sort primitives | 0.049 | 0.105 | 0.206 | 0.073 |
| physics body / shape updates | 0.041 | 0.057 | 0.069 | 0.053 |
| CUDA memory utility kernels | 0.031 | 0.067 | 0.066 | 0.046 |
| destruction contact graph | 0.028 | 0.034 | 0.071 | 0.040 |
| destruction pre-solve contacts / islands | 0.019 | 0.008 | 0.021 | 0.025 |

Mean kernel dispatches per step: 353.5; first-fracture dispatches: 547. CUDA API wall union averages 16.605 ms, overlapping GPU work. Time inside synchronization APIs with no recorded GPU activity averages 0.140 ms; this includes driver/scheduler/dependency overhead, not proven useful CPU computation.

| Largest individual GPU kernels | Operation | Calls / step | Mean µs / call | Execution sum ms / step |
|---|---|---|---|---|
| componentStressSolve | stress solver / stress topology | 1.000 | 12636.785 | 12.637 |
| _ZN2Nv5Blast15StressHierarchy9constructENS1_5InputENS1_7BuffersEPNS1_6StatusEPNS1_4WorkE | unclassified | 7.467 | 81.892 | 0.611 |
| performIncrementalSAP | physics broad phase | 1.422 | 340.092 | 0.484 |
| _ZN2Nv5Blast15StressHierarchy20constructMotionModesENS1_5InputEPKjNS1_13MotionBuffersEPNS1_6StatusEPNS1_4WorkE | unclassified | 0.467 | 736.414 | 0.344 |
| solveStaticBlockTGS | Solve contacts against static boundaries | 4.861 | 59.584 | 0.290 |
| solveBlockUnified | physics constraint preparation / solve / integration | 38.667 | 7.148 | 0.276 |
| computeStartAndActiveRegionHistogram | physics broad phase | 0.433 | 361.958 | 0.157 |
| radixSortMultiCalculateRanksLaunchWithCount | shared physics utilities | 18.400 | 7.402 | 0.136 |
| _ZN2Nv5Blast15StressHierarchy9packLevelILb1EEEvNS1_5InputENS1_7BuffersEPKNS1_6StatusEPS5_NS1_14PackingBuffersEPNS1_11PackingWorkEjNS1_18TerminalRetirementE | unclassified | 7.000 | 19.179 | 0.134 |
| boxBoxNphase_Kernel | physics narrow phase / contact lifecycle | 1.928 | 69.185 | 0.133 |
| computeIncrementalComparisonHistograms_Stage1 | physics broad phase | 1.422 | 60.494 | 0.086 |
| contactConstraintBlockPrepareParallelLaunchTGS | physics constraint preparation / solve / integration | 0.972 | 84.306 | 0.082 |

Stress iterations are numerical convergence iterations, not additional resimulations. CUDA-graph guarded tail kernels can execute beyond the reported iteration count; kernel dispatch counts are shown separately. Small per-call times combined with repeated dependent launches identify a scheduling/fusion investigation, not proof of a particular hardware throughput limit.

## CPU execution — core time, separate from elapsed wall time

| Host scope | Mean exclusive CPU core-ms / step |
|---|---|
| finishDetail.waitForGpu | 13.289 |
| acceptCorrection | 1.187 |
| detail.broadPhaseWait | 0.799 |
| trialDetail.broadPhaseWait | 0.436 |
| applyDetail.migrateShapes | 0.178 |
| trialDetail.postNarrowPhase | 0.136 |
| submit | 0.130 |
| finishDetail.allocateNativeBodies | 0.121 |
| trialDetail.processLostContacts3 | 0.109 |
| trialDetail.islandInsertion | 0.090 |

Process CPU time averages 22.913 core-ms per step in the host-scope capture. CPU thread clocks include busy waiting, driver and profiling work, but exclude descheduling. Same-thread children are subtracted from their parent; detached/cross-thread spans are excluded. Parallel CPU core-ms must not be added to wall-ms or GPU time. A large wait scope's CPU time does not mean the stress math runs on the CPU.

## Work quantities — physical workload, not just allocated capacity

| Counter (untraced repeat 1) | Mean | Minimum | Maximum | Last 2 s mean |
|---|---|---|---|---|
| Connected rigid clusters | 6089.772 | 256.000 | 12469.000 | 9006.658 |
| Registered PhysX bodies | 6345.772 | 512.000 | 12725.000 | 9262.658 |
| CPU-scheduled active bodies | 6229.150 | 256.000 | 12725.000 | 9215.725 |
| Solved contact reports | 64951.733 | 0.000 | 146476.000 | 97427.600 |
| GPU pre-solve pair visits | 53050.961 | 0.000 | 139634.000 | 79576.442 |
| Retained stress nodes | 92253.989 | 86927.000 | 97280.000 | 89740.983 |
| Retained stress bonds | 172160.544 | 142229.000 | 200704.000 | 157888.817 |
| Retained stress islands | 1063.761 | 256.000 | 2116.000 | 1467.642 |
| Reported stress iterations | 281.589 | 0.000 | 634.000 | 421.667 |
| New broken bonds | 324.861 | 0.000 | 28160.000 | 487.292 |
| Correction passes | 0.428 | 0.000 | 1.000 | 0.642 |

Active-body counters come from CPU scheduling, not a qualified GPU sleep mask; sleeping is disabled here. Contact reports/pair visits are work counts, not unique collisions. Retained stress bonds are topology membership, not the number processed in every iteration. Legacy public contact-pair/solver-row counters are incomplete on this GPU path and are excluded. Allocation capacity and memory-bandwidth/occupancy counters are not collected in this report.

| Counter association (host-scope capture) | Pearson r with total step time | Pearson r with stress-stream time |
|---|---|---|
| Stress iterations | 0.941 | 0.996 |
| Scheduled active bodies | 0.931 | 0.991 |
| Retained stress bonds | -0.936 | -0.992 |
| Solved contact reports | 0.900 | 0.983 |
| Correction passes | 0.859 | 0.787 |

Associations describe this one evolving scene; they are not causal scaling laws. A dash means a constant/insufficient sample. In particular, retained-body and bond counts co-vary with impact time; controlled workload variations are needed to establish their independent costs.

## Automatic bottleneck summary and next decision

Largest elapsed regions: Wait for GPU destruction result: 13.292 ms/step; Trial physics and remaining scene tasks: 2.874 ms/step; Resimulate changed interaction: 2.211 ms/step.

Largest GPU-stream stage: Iterative stress solve to convergence (12.851 ms/step). A sub-1-ms target needs this measured cost reduced if it already exceeds 1 ms; increasing scene size would not remove it.

Late-scene stress remains active: 421.7 reported iterations/step in the last two seconds. No new fracture does not imply no stress work. Compare convergence, applied loads and contact changes before considering any result reuse; this report does not authorize skipped physics or relaxed convergence.

Evidence supports targeting the largest measured stages and investigating small-kernel/iteration scheduling. It does not distinguish memory-bandwidth limitation from arithmetic throughput: SM occupancy, bandwidth and instruction counters require a separate hardware-counter experiment. Scale an active workload only after comparing these per-step costs; the intact controls show geometry scaling alone.

## Reproduce, audit and extend

Capture and generate in one command: python3 tools/scripts/run-destruction-timing.py NEW_CAPTURE_DIRECTORY --trials 5 --gpu-trials 3 --seconds 10. Reports appear in NEW_CAPTURE_DIRECTORY/report. Regenerate from captures only: python3 tools/scripts/report-destruction-timing.py CAPTURE_DIRECTORY --output REPORT_DIRECTORY. Change the versioned tools/profiles/wall-penetration-timing.json configuration for additional physical workloads; every resolved command is retained.

report.json.gz contains every per-step partition, GPU region, CPU exclusive core-time scope, kernel symbol/source, transfer byte count, run signature and summary. campaign.json beside the captures records binary/library SHA-256 hashes, exact inputs, driver, GPU process/clock samples, and hashes of all raw files. Reports are generated from those recorded files, without querying the current GPU or inserting a generation timestamp.

Percentiles use nearest rank ceil(p × N), with 1-based ranks. Means pool equally long untraced runs; maxima retain all measured spikes. Event windows overlap and must not be added. Zero-size windows are omitted. Rounded display values can differ from the exact total by rounding; raw JSON preserves full precision.
