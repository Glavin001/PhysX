# PhysX GPU destruction — measured timing breakdown

Detailed focus: 256 buildings, simultaneous aerial impacts — 113,664 chunks, 229,376 bonds. All configured scenes appear in the comparison table; detailed sections use this first configured scene.

The selected scene’s simulate/fetch subinterval averages 39.161 ms per step across 2 untraced repeats; the worst measured step is 99.033 ms. 2/360 steps are below 1 ms. GPU stress occupies a mean 30.304 ms of destruction-stream elapsed time in the separate host-scope capture (77.0% of its simulation bracket; this overlaps submission/wait).

## 🎯 Authoritative complete advance — commands through committed completion

❌ Deadline failed: 198 complete steps exceeded 8.0 ms. Every measured step is retained. Full plan and endurance qualification remain incomplete.

| Untraced repeat | Steps | Mean ms | Peak ms | >8 ms | Peak step | CPU commands at peak ms | PhysX/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|
| 1 | 180 | 39.237 | 99.093 | 99 | 103 | 0.000 | 99.033 | 0.060 |
| 2 | 180 | 39.335 | 98.866 | 99 | 103 | 0.000 | 98.802 | 0.064 |

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

Hardware: NVIDIA GeForce RTX 4090; driver 595.71.05. Revision bb8ed952b6611548a6fd3d56ce080417dfd61710. One separate process per case is discarded. All measured frames, including first impact and first allocation, are retained. All modes advance 3 simulated seconds; 1 complete CUPTI repetitions per scene, at 60 Hz. This short diagnostic campaign is not the planned five × 60-second scale qualification.

The detailed profiling bracket starts immediately before scene.simulate and ends after blocking scene.fetchResults, including embedded destruction and correction. Scene construction, projectile creation before the step, compact post-step status observation, CSV output and GPU activity flush are outside this bracket. This is simulation cost, not the complete application tick. CPU profiling callbacks and concurrent CUPTI collection can still perturb the measured interval.

## Untraced simulate/fetch cost — subinterval of the complete advance

| Scene | Chunks | Bonds | Steps | Min ms | Mean ms | p50 ms | p95 ms | p99 ms | Max ms | ≥1 ms | >16.67 ms |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 360 | 0.998 | 39.161 | 56.878 | 76.227 | 86.453 | 99.033 | 358 | 198 |

| Selected scene repeat | Mean ms | Worst ms | Worst step | Sim time s | Resim | Stress iterations | Clusters | Scheduled active bodies | Solved contact reports |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 39.122 | 99.033 | 103 | 1.733 | 1 | 96 | 11816 | 12072 | 109383 |
| 2 | 39.200 | 98.802 | 103 | 1.733 | 1 | 96 | 11816 | 12072 | 109383 |

## Event-based windows — no fixed impact frame or hidden warm-up cutoff

| Window (overlapping; do not add) | Steps | Mean ms | p50 ms | p95 ms | Max ms |
|---|---|---|---|---|---|
| First accepted step | 2 | 40.361 | 40.266 | 40.456 | 40.456 |
| After startup, before first broken bond | 162 | 1.069 | 1.056 | 1.166 | 1.461 |
| Steps that execute correction | 154 | 73.219 | 74.308 | 78.098 | 99.033 |
| Last two simulated seconds | 240 | 57.885 | 71.654 | 76.875 | 99.033 |

## Instrumentation overhead — never mix these captures

| Mode | Runs | Mean ms | Max ms | Mean / untraced mean |
|---|---|---|---|---|
| No detailed profiling | 2 | 39.161 | 99.033 | 1.00× |
| CPU scopes + CUDA stream events | 1 | 39.363 | 103.688 | 1.01× |
| CPU scopes + CUDA events + CUPTI | 1 | 40.442 | 102.518 | 1.03× |

Profiling changes scheduling and adds overhead. Detailed tables describe their own measured capture; they are not a retrospective decomposition of the video or of an untraced maximum. Overhead is observed, not subtracted as a guessed correction.

## Additive wall-time breakdown — host-scope capture

Columns show all-step mean, first fracture (step 82), this capture's worst step (103), and the last-two-seconds mean. CPU/GPU designations describe what happens inside the scope, not exclusive processor execution. Rows are disjoint and add to the timestamp bracket. The bracket includes clock-read bookends around simulate/fetch; mean difference from the simulation timer is 1.63 µs.

| Operation | CPU / GPU responsibility | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.017 | 0.007 | 0.011 | 0.021 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.128 | 0.153 | 0.180 | 0.129 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 30.888 | 33.152 | 54.616 | 45.919 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.002 | 0.036 | 0.103 | 0.002 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.031 | 0.161 | 0.076 | 0.047 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.120 | 6.022 | 3.554 | 0.179 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.003 | 0.019 | 0.008 | 0.004 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.003 | 0.052 | 0.017 | 0.004 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 | 0.009 | 0.007 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.007 | 0.074 | 0.038 | 0.010 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.011 | 0.113 | 0.026 | 0.016 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.008 | 0.074 | 0.018 | 0.011 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.084 | 0.177 | 0.181 | 0.126 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.017 | 0.784 | 0.381 | 0.025 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.004 | 0.198 | 0.068 | 0.005 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.006 | 0.296 | 0.148 | 0.009 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.044 | 0.654 | 1.284 | 0.065 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.022 | 0.988 | 0.552 | 0.033 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.009 | 0.373 | 0.208 | 0.014 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.035 | 1.603 | 0.801 | 0.052 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.070 | 4.655 | 1.578 | 0.104 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.033 | 0.110 | 0.118 | 0.049 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.007 | 0.065 | 0.028 | 0.011 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.012 | 0.010 | 0.004 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 2.208 | 28.460 | 25.364 | 3.311 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.697 | 6.663 | 6.290 | 4.046 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 2.905 | 3.477 | 8.024 | 3.962 |
| TOTAL | Measured simulate/fetch bracket | 39.364 | 88.382 | 103.690 | 58.166 |

## Inside the destruction wait — GPU-stream elapsed time

These consecutive CUDA-event intervals include GPU execution plus stream scheduling/dependency gaps. They overlap the CPU submission/wait above and must NOT be added to wall time. The wait is the host observing completion of required work, not a second computation. Exact kernel execution is shown separately below.

| GPU stream operation | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|
| Convert solved contact impulses into chunk loads | 0.093 | 0.064 | 0.135 | 0.121 |
| Iterative stress solve to convergence | 30.304 | 32.637 | 54.039 | 45.086 |
| Evaluate material damage and fracture | 0.069 | 0.077 | 0.065 | 0.067 |
| Connectivity, cluster mass and fragment candidates | 0.239 | 0.455 | 0.482 | 0.341 |
| Commit changes and rebuild stress topology | 0.284 | 0.043 | 0.039 | 0.405 |

## Actual GPU execution versus elapsed gaps — CUPTI capture

Detailed GPU tables use repetition 1; all 1 repetitions pass full validation and contribute to the overhead table. GPU capture duration: 3 s. Its final-two-seconds column covers simulation seconds 1–3. This capture's first fracture is step 82; its worst step is 103. Concurrent GPU intervals are merged before summing. No GPU activity means no recorded kernel/copy/memset from this process, not proof of global GPU idleness or useful CPU computation. CPU core-time can exceed elapsed time and is never added to it.

| Disjoint wall-time category | Mean ms | First fracture ms | Worst step ms | Trace final 2 s ms |
|---|---|---|---|---|
| GPU kernel execution (union) | 35.976 | 48.450 | 69.379 | 53.360 |
| GPU copy/memset time not overlapping kernels | 0.501 | 0.756 | 1.359 | 0.731 |
| No recorded GPU execution | 3.966 | 38.427 | 31.782 | 5.452 |
| TOTAL measured bracket | 40.444 | 87.634 | 102.520 | 59.543 |

| Important region | Wall mean ms | GPU activity mean ms | No GPU activity mean ms |
|---|---|---|---|
| Trial physics and remaining scene tasks | 3.233 | 1.295 | 1.938 |
| Finish GPU work and reserve bodies | 0.460 | 0.247 | 0.213 |
| Resimulate changed interaction | 2.280 | 1.457 | 0.823 |

## Ordinary physics and resimulation — observed host substeps

Inclusive observed host scopes below can nest or overlap across worker threads. These rows explain the broad trial/correction regions; do not add them together. GPU work is dispatched asynchronously and need not execute inside its submitting host scope. Missing coverage remains in the parent region, rather than being presented as a measured operation.

| Host task / callback | Trial mean wall ms | Correction mean wall ms | Trial first-fracture ms | Correction first-fracture ms |
|---|---|---|---|---|
| Allocate contact-manager storage | 0.042 | 0.050 | 0.291 | 3.901 |
| Register contact managers | 0.035 | 0.008 | 0.055 | 0.414 |
| Register body/shape interactions | 0.045 | 0.024 | 0.189 | 1.516 |
| Register scene interactions | 0.077 | 0.045 | 0.128 | 1.946 |
| Complete broad phase and callbacks | 0.445 | 0.801 | 0.272 | 7.272 |
| Wait for GPU broad phase and pair publication | 0.432 | 0.796 | 0.260 | 7.261 |
| Broad-phase completion stage 2 | 0.013 | 0.041 | 0.089 | 1.659 |
| Broad-phase completion stage 3 | 0.001 | 0.000 | 0.001 | 0.001 |
| Complete narrow phase | 0.213 | 0.130 | 0.106 | 0.859 |
| Insert contact dependencies into islands | 0.095 | 0.055 | 0.098 | 2.672 |
| Generate simulation islands | 0.030 | 0.009 | 0.009 | 0.213 |
| Finish island scheduling | 0.001 | 0.001 | 0.001 | 0.001 |
| Prepare dynamics tasks | 0.002 | 0.001 | 0.001 | 0.003 |
| Submit dynamics/constraint solve | 0.080 | 0.056 | 0.036 | 1.365 |
| Finish constraint partitioning | 0.070 | 0.077 | 0.092 | 0.702 |
| Dispatch lost contacts | 0.003 | 0.002 | 0.001 | 0.003 |
| Lost-contact completion stage 2 | 0.057 | 0.002 | 0.001 | 0.001 |
| Lost-contact completion stage 3 | 0.115 | 0.002 | 0.001 | 0.001 |
| Finish motion integration and solver tasks | 0.001 | 0.001 | 0.001 | 0.002 |

## Which GPU work consumes execution time?

Kernel durations below are execution sums. They can overlap across streams and are NOT additive elapsed wall time. Classification uses kernel symbols and CUDA source files; unknown symbols stay explicitly unclassified.

| GPU kernel family | Mean execution sum ms | First-fracture sum ms | Worst-step sum ms | Trace final 2 s sum ms |
|---|---|---|---|---|
| stress solver / stress topology | 30.366 | 32.625 | 54.037 | 45.188 |
| unclassified | 2.871 | 6.381 | 6.064 | 4.297 |
| physics broad phase | 1.025 | 7.344 | 5.889 | 1.457 |
| physics constraint preparation / solve / integration | 0.840 | 0.631 | 1.803 | 1.234 |
| shared physics utilities | 0.205 | 0.348 | 0.334 | 0.252 |
| physics narrow phase / contact lifecycle | 0.196 | 0.122 | 0.634 | 0.293 |
| destruction orchestration / motion | 0.153 | 0.369 | 0.322 | 0.216 |
| destruction connectivity / mass / slots | 0.141 | 0.251 | 0.311 | 0.209 |
| destruction load gathering | 0.087 | 0.045 | 0.128 | 0.114 |
| destruction material / damage | 0.062 | 0.077 | 0.066 | 0.064 |
| shared CUDA scan / sort primitives | 0.049 | 0.105 | 0.206 | 0.073 |
| physics body / shape updates | 0.040 | 0.057 | 0.068 | 0.051 |
| CUDA memory utility kernels | 0.030 | 0.065 | 0.065 | 0.045 |
| destruction contact graph | 0.027 | 0.031 | 0.074 | 0.040 |
| destruction pre-solve contacts / islands | 0.019 | 0.008 | 0.018 | 0.025 |

Mean kernel dispatches per step: 353.5; first-fracture dispatches: 547. CUDA API wall union averages 36.003 ms, overlapping GPU work. Time inside synchronization APIs with no recorded GPU activity averages 0.148 ms; this includes driver/scheduler/dependency overhead, not proven useful CPU computation.

| Largest individual GPU kernels | Operation | Calls / step | Mean µs / call | Execution sum ms / step |
|---|---|---|---|---|
| componentStressSolve | stress solver / stress topology | 1.000 | 30217.768 | 30.218 |
| _ZN2Nv5Blast15StressHierarchy9constructENS1_5InputENS1_7BuffersEPNS1_6StatusEPNS1_4WorkE | unclassified | 7.467 | 145.197 | 1.084 |
| _ZN2Nv5Blast15StressHierarchy17constructSmootherENS1_5InputEPKNS1_6StatusEPS3_PNS1_4WorkENS1_7BuffersENS1_15TerminalBuffersEj | unclassified | 7.000 | 105.557 | 0.739 |
| performIncrementalSAP | physics broad phase | 1.422 | 344.609 | 0.490 |
| _ZN2Nv5Blast15StressHierarchy18constructTerminalsENS1_5InputEPKNS1_6StatusEPS3_PNS1_4WorkENS1_15TerminalBuffersEj | unclassified | 7.467 | 56.054 | 0.419 |
| _ZN2Nv5Blast15StressHierarchy20constructMotionModesENS1_5InputEPKjNS1_13MotionBuffersEPNS1_6StatusEPNS1_4WorkE | unclassified | 0.467 | 736.750 | 0.344 |
| solveStaticBlockTGS | Solve contacts against static boundaries | 4.861 | 59.505 | 0.289 |
| solveBlockUnified | physics constraint preparation / solve / integration | 38.667 | 7.146 | 0.276 |
| _ZN2Nv5Blast15StressHierarchy9packLevelILb1EEEvNS1_5InputENS1_7BuffersEPKNS1_6StatusEPS5_NS1_14PackingBuffersEPNS1_11PackingWorkEjNS1_18TerminalRetirementE | unclassified | 7.000 | 31.703 | 0.222 |
| computeStartAndActiveRegionHistogram | physics broad phase | 0.433 | 364.085 | 0.158 |
| radixSortMultiCalculateRanksLaunchWithCount | shared physics utilities | 18.400 | 7.391 | 0.136 |
| boxBoxNphase_Kernel | physics narrow phase / contact lifecycle | 1.928 | 67.761 | 0.131 |

Stress iterations are numerical convergence iterations, not additional resimulations. CUDA-graph guarded tail kernels can execute beyond the reported iteration count; kernel dispatch counts are shown separately. Small per-call times combined with repeated dependent launches identify a scheduling/fusion investigation, not proof of a particular hardware throughput limit.

## CPU execution — core time, separate from elapsed wall time

| Host scope | Mean exclusive CPU core-ms / step |
|---|---|
| finishDetail.waitForGpu | 30.879 |
| acceptCorrection | 2.697 |
| detail.broadPhaseWait | 0.796 |
| trialDetail.broadPhaseWait | 0.432 |
| applyDetail.migrateShapes | 0.185 |
| trialDetail.postNarrowPhase | 0.133 |
| submit | 0.129 |
| finishDetail.allocateNativeBodies | 0.120 |
| trialDetail.processLostContacts3 | 0.115 |
| trialDetail.islandInsertion | 0.094 |

Process CPU time averages 42.087 core-ms per step in the host-scope capture. CPU thread clocks include busy waiting, driver and profiling work, but exclude descheduling. Same-thread children are subtracted from their parent; detached/cross-thread spans are excluded. Parallel CPU core-ms must not be added to wall-ms or GPU time. A large wait scope's CPU time does not mean the stress math runs on the CPU.

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
| Reported stress iterations | 44.183 | 0.000 | 96.000 | 65.933 |
| New broken bonds | 324.861 | 0.000 | 28160.000 | 487.292 |
| Correction passes | 0.428 | 0.000 | 1.000 | 0.642 |

Active-body counters come from CPU scheduling, not a qualified GPU sleep mask; sleeping is disabled here. Contact reports/pair visits are work counts, not unique collisions. Retained stress bonds are topology membership, not the number processed in every iteration. Legacy public contact-pair/solver-row counters are incomplete on this GPU path and are excluded. Allocation capacity and memory-bandwidth/occupancy counters are not collected in this report.

| Counter association (host-scope capture) | Pearson r with total step time | Pearson r with stress-stream time |
|---|---|---|
| Stress iterations | 0.983 | 0.996 |
| Scheduled active bodies | 0.949 | 0.972 |
| Retained stress bonds | -0.954 | -0.974 |
| Solved contact reports | 0.924 | 0.957 |
| Correction passes | 0.842 | 0.789 |

Associations describe this one evolving scene; they are not causal scaling laws. A dash means a constant/insufficient sample. In particular, retained-body and bond counts co-vary with impact time; controlled workload variations are needed to establish their independent costs.

## Automatic bottleneck summary and next decision

Largest elapsed regions: Wait for GPU destruction result: 30.888 ms/step; Trial physics and remaining scene tasks: 2.905 ms/step; Accept corrected step: 2.697 ms/step.

Largest GPU-stream stage: Iterative stress solve to convergence (30.304 ms/step). A sub-1-ms target needs this measured cost reduced if it already exceeds 1 ms; increasing scene size would not remove it.

Late-scene stress remains active: 65.9 reported iterations/step in the last two seconds. No new fracture does not imply no stress work. Compare convergence, applied loads and contact changes before considering any result reuse; this report does not authorize skipped physics or relaxed convergence.

Evidence supports targeting the largest measured stages and investigating small-kernel/iteration scheduling. It does not distinguish memory-bandwidth limitation from arithmetic throughput: SM occupancy, bandwidth and instruction counters require a separate hardware-counter experiment. Scale an active workload only after comparing these per-step costs; the intact controls show geometry scaling alone.

## Reproduce, audit and extend

Capture and generate in one command: python3 tools/scripts/run-destruction-timing.py NEW_CAPTURE_DIRECTORY --trials 5 --gpu-trials 3 --seconds 10. Reports appear in NEW_CAPTURE_DIRECTORY/report. Regenerate from captures only: python3 tools/scripts/report-destruction-timing.py CAPTURE_DIRECTORY --output REPORT_DIRECTORY. Change the versioned tools/profiles/wall-penetration-timing.json configuration for additional physical workloads; every resolved command is retained.

report.json.gz contains every per-step partition, GPU region, CPU exclusive core-time scope, kernel symbol/source, transfer byte count, run signature and summary. campaign.json beside the captures records binary/library SHA-256 hashes, exact inputs, driver, GPU process/clock samples, and hashes of all raw files. Reports are generated from those recorded files, without querying the current GPU or inserting a generation timestamp.

Percentiles use nearest rank ceil(p × N), with 1-based ranks. Means pool equally long untraced runs; maxima retain all measured spikes. Event windows overlap and must not be added. Zero-size windows are omitted. Rounded display values can differ from the exact total by rounding; raw JSON preserves full precision.
