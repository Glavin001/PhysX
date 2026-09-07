# PhysX GPU destruction — measured timing breakdown

Detailed focus: 256 buildings, simultaneous aerial impacts — 113,664 chunks, 229,376 bonds. All configured scenes appear in the comparison table; detailed sections use this first configured scene.

The selected scene’s simulate/fetch subinterval averages 20.045 ms per step across 2 untraced repeats; the worst measured step is 64.676 ms. 0/360 steps are below 1 ms. GPU stress occupies a mean 12.715 ms of destruction-stream elapsed time in the separate host-scope capture (63.4% of its simulation bracket; this overlaps submission/wait).

## 🎯 Authoritative complete advance — commands through committed completion

❌ Deadline failed: 198 complete steps exceeded 8.0 ms. Every measured step is retained. Full plan and endurance qualification remain incomplete.

| Untraced repeat | Steps | Mean ms | Peak ms | >8 ms | Peak step | CPU commands at peak ms | PhysX/destruction at peak ms | Completion at peak ms |
|---|---|---|---|---|---|---|---|---|
| 1 | 180 | 20.057 | 64.738 | 99 | 103 | 0.000 | 64.676 | 0.062 |
| 2 | 180 | 20.292 | 64.347 | 99 | 103 | 0.000 | 64.286 | 0.060 |

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
| 256 buildings, simultaneous aerial impacts | 113664 | 229376 | 360 | 1.008 | 20.045 | 27.015 | 40.235 | 54.595 | 64.676 | 360 | 196 |

| Selected scene repeat | Mean ms | Worst ms | Worst step | Sim time s | Resim | Stress iterations | Clusters | Scheduled active bodies | Solved contact reports |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 19.942 | 64.676 | 103 | 1.733 | 1 | 537 | 11816 | 12072 | 109383 |
| 2 | 20.147 | 64.286 | 103 | 1.733 | 1 | 537 | 11816 | 12072 | 109383 |

## Event-based windows — no fixed impact frame or hidden warm-up cutoff

| Window (overlapping; do not add) | Steps | Mean ms | p50 ms | p95 ms | Max ms |
|---|---|---|---|---|---|
| First accepted step | 2 | 9.657 | 8.532 | 10.782 | 10.782 |
| After startup, before first broken bond | 162 | 1.113 | 1.097 | 1.227 | 1.361 |
| Steps that execute correction | 154 | 37.862 | 37.630 | 43.173 | 64.676 |
| Last two simulated seconds | 240 | 29.450 | 35.946 | 41.857 | 64.676 |

## Instrumentation overhead — never mix these captures

| Mode | Runs | Mean ms | Max ms | Mean / untraced mean |
|---|---|---|---|---|
| No detailed profiling | 2 | 20.045 | 64.676 | 1.00× |
| CPU scopes + CUDA stream events | 1 | 20.069 | 66.777 | 1.00× |
| CPU scopes + CUDA events + CUPTI | 1 | 20.991 | 70.506 | 1.05× |

Profiling changes scheduling and adds overhead. Detailed tables describe their own measured capture; they are not a retrospective decomposition of the video or of an untraced maximum. Overhead is observed, not subtracted as a guessed correction.

## Additive wall-time breakdown — host-scope capture

Columns show all-step mean, first fracture (step 82), this capture's worst step (82), and the last-two-seconds mean. CPU/GPU designations describe what happens inside the scope, not exclusive processor execution. Rows are disjoint and add to the timestamp bracket. The bracket includes clock-read bookends around simulate/fetch; mean difference from the simulation timer is 1.58 µs.

| Operation | CPU / GPU responsibility | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|---|
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.017 | 0.010 | 0.010 | 0.022 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.129 | 0.296 | 0.296 | 0.131 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 13.158 | 10.898 | 10.898 | 19.536 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.002 | 0.032 | 0.032 | 0.003 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.028 | 0.164 | 0.164 | 0.041 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.117 | 5.883 | 5.883 | 0.175 |
| Upload allocated body bindings | CPU → GPU indices for the reserved bodies | 0.000 | 0.000 | 0.000 | 0.000 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.002 | 0.020 | 0.020 | 0.003 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.003 | 0.056 | 0.056 | 0.004 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.006 | 0.006 | 0.006 | 0.007 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.006 | 0.079 | 0.079 | 0.010 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.011 | 0.201 | 0.201 | 0.016 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.008 | 0.082 | 0.082 | 0.011 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.079 | 0.170 | 0.170 | 0.119 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.018 | 0.939 | 0.939 | 0.027 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.004 | 0.272 | 0.272 | 0.006 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.006 | 0.302 | 0.302 | 0.009 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.044 | 0.621 | 0.621 | 0.066 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.021 | 0.828 | 0.828 | 0.032 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.010 | 0.489 | 0.489 | 0.014 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.035 | 1.674 | 1.674 | 0.053 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.073 | 5.194 | 5.194 | 0.110 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.034 | 0.115 | 0.115 | 0.050 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.008 | 0.146 | 0.146 | 0.012 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.003 | 0.007 | 0.007 | 0.004 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 2.187 | 32.191 | 32.191 | 3.281 |
| Accept corrected step | GPU commit/status completion and CPU publication | 1.195 | 2.981 | 2.981 | 1.793 |
| Trial physics and remaining scene tasks | Original physics pass plus task/driver gaps outside destruction scopes | 2.865 | 3.122 | 3.122 | 3.929 |
| TOTAL | Measured simulate/fetch bracket | 20.070 | 66.778 | 66.778 | 29.464 |

## Inside the destruction wait — GPU-stream elapsed time

These consecutive CUDA-event intervals include GPU execution plus stream scheduling/dependency gaps. They overlap the CPU submission/wait above and must NOT be added to wall time. The wait is the host observing completion of required work, not a second computation. Exact kernel execution is shown separately below.

| GPU stream operation | Mean ms | First fracture ms | Worst step ms | Last 2 s ms |
|---|---|---|---|---|
| Convert solved contact impulses into chunk loads | 0.094 | 0.198 | 0.198 | 0.122 |
| Iterative stress solve to convergence | 12.715 | 10.401 | 10.401 | 18.914 |
| Evaluate material damage and fracture | 0.069 | 0.077 | 0.077 | 0.067 |
| Connectivity, cluster mass and fragment candidates | 0.239 | 0.453 | 0.453 | 0.342 |
| Commit changes and rebuild stress topology | 0.145 | 0.041 | 0.041 | 0.195 |

## Actual GPU execution versus elapsed gaps — CUPTI capture

Detailed GPU tables use repetition 1; all 1 repetitions pass full validation and contribute to the overhead table. GPU capture duration: 3 s. Its final-two-seconds column covers simulation seconds 1–3. This capture's first fracture is step 82; its worst step is 103. Concurrent GPU intervals are merged before summing. No GPU activity means no recorded kernel/copy/memset from this process, not proof of global GPU idleness or useful CPU computation. CPU core-time can exceed elapsed time and is never added to it.

| Disjoint wall-time category | Mean ms | First fracture ms | Worst step ms | Trace final 2 s ms |
|---|---|---|---|---|
| GPU kernel execution (union) | 16.810 | 22.363 | 34.732 | 24.819 |
| GPU copy/memset time not overlapping kernels | 0.500 | 0.774 | 1.386 | 0.730 |
| No recorded GPU execution | 3.683 | 38.073 | 34.390 | 5.097 |
| TOTAL measured bracket | 20.993 | 61.210 | 70.507 | 30.646 |

| Important region | Wall mean ms | GPU activity mean ms | No GPU activity mean ms |
|---|---|---|---|
| Trial physics and remaining scene tasks | 3.061 | 1.280 | 1.781 |
| Finish GPU work and reserve bodies | 0.315 | 0.108 | 0.207 |
| Resimulate changed interaction | 2.280 | 1.454 | 0.825 |

## Ordinary physics and resimulation — observed host substeps

Inclusive observed host scopes below can nest or overlap across worker threads. These rows explain the broad trial/correction regions; do not add them together. GPU work is dispatched asynchronously and need not execute inside its submitting host scope. Missing coverage remains in the parent region, rather than being presented as a measured operation.

| Host task / callback | Trial mean wall ms | Correction mean wall ms | Trial first-fracture ms | Correction first-fracture ms |
|---|---|---|---|---|
| Allocate contact-manager storage | 0.040 | 0.043 | 0.190 | 3.213 |
| Register contact managers | 0.033 | 0.007 | 0.059 | 0.287 |
| Register body/shape interactions | 0.045 | 0.023 | 0.216 | 1.602 |
| Register scene interactions | 0.074 | 0.049 | 0.085 | 2.465 |
| Complete broad phase and callbacks | 0.452 | 0.800 | 0.273 | 7.424 |
| Wait for GPU broad phase and pair publication | 0.440 | 0.795 | 0.262 | 7.409 |
| Broad-phase completion stage 2 | 0.013 | 0.039 | 0.032 | 1.529 |
| Broad-phase completion stage 3 | 0.001 | 0.000 | 0.001 | 0.001 |
| Complete narrow phase | 0.208 | 0.117 | 0.109 | 0.790 |
| Insert contact dependencies into islands | 0.086 | 0.052 | 0.099 | 2.696 |
| Generate simulation islands | 0.030 | 0.008 | 0.028 | 0.220 |
| Finish island scheduling | 0.001 | 0.001 | 0.001 | 0.001 |
| Prepare dynamics tasks | 0.002 | 0.001 | 0.002 | 0.002 |
| Submit dynamics/constraint solve | 0.079 | 0.055 | 0.032 | 1.348 |
| Finish constraint partitioning | 0.056 | 0.074 | 0.098 | 0.610 |
| Dispatch lost contacts | 0.002 | 0.002 | 0.001 | 0.004 |
| Lost-contact completion stage 2 | 0.052 | 0.002 | 0.001 | 0.001 |
| Lost-contact completion stage 3 | 0.114 | 0.002 | 0.001 | 0.001 |
| Finish motion integration and solver tasks | 0.001 | 0.001 | 0.002 | 0.002 |

## Which GPU work consumes execution time?

Kernel durations below are execution sums. They can overlap across streams and are NOT additive elapsed wall time. Classification uses kernel symbols and CUDA source files; unknown symbols stay explicitly unclassified.

| GPU kernel family | Mean execution sum ms | First-fracture sum ms | Worst-step sum ms | Trace final 2 s sum ms |
|---|---|---|---|---|
| stress solver / stress topology | 12.849 | 10.254 | 23.020 | 19.123 |
| unclassified | 1.235 | 2.659 | 2.633 | 1.844 |
| physics broad phase | 1.015 | 7.333 | 5.660 | 1.443 |
| physics constraint preparation / solve / integration | 0.840 | 0.645 | 1.795 | 1.234 |
| shared physics utilities | 0.206 | 0.348 | 0.336 | 0.254 |
| physics narrow phase / contact lifecycle | 0.198 | 0.123 | 0.621 | 0.298 |
| destruction orchestration / motion | 0.152 | 0.372 | 0.325 | 0.215 |
| destruction connectivity / mass / slots | 0.141 | 0.251 | 0.309 | 0.209 |
| destruction load gathering | 0.086 | 0.044 | 0.126 | 0.114 |
| destruction material / damage | 0.062 | 0.077 | 0.067 | 0.064 |
| shared CUDA scan / sort primitives | 0.049 | 0.107 | 0.178 | 0.073 |
| physics body / shape updates | 0.034 | 0.049 | 0.053 | 0.043 |
| CUDA memory utility kernels | 0.031 | 0.067 | 0.065 | 0.046 |
| destruction contact graph | 0.027 | 0.034 | 0.071 | 0.039 |
| destruction pre-solve contacts / islands | 0.019 | 0.008 | 0.021 | 0.025 |

Mean kernel dispatches per step: 353.5; first-fracture dispatches: 547. CUDA API wall union averages 16.687 ms, overlapping GPU work. Time inside synchronization APIs with no recorded GPU activity averages 0.141 ms; this includes driver/scheduler/dependency overhead, not proven useful CPU computation.

| Largest individual GPU kernels | Operation | Calls / step | Mean µs / call | Execution sum ms / step |
|---|---|---|---|---|
| componentStressSolve | stress solver / stress topology | 1.000 | 12702.788 | 12.703 |
| _ZN2Nv5Blast15StressHierarchy9constructENS1_5InputENS1_7BuffersEPNS1_6StatusEPNS1_4WorkE | unclassified | 7.467 | 82.724 | 0.618 |
| performIncrementalSAP | physics broad phase | 1.422 | 341.582 | 0.486 |
| _ZN2Nv5Blast15StressHierarchy20constructMotionModesENS1_5InputEPKjNS1_13MotionBuffersEPNS1_6StatusEPNS1_4WorkE | unclassified | 0.467 | 736.769 | 0.344 |
| solveStaticBlockTGS | Solve contacts against static boundaries | 4.861 | 59.500 | 0.289 |
| solveBlockUnified | physics constraint preparation / solve / integration | 38.667 | 7.140 | 0.276 |
| computeStartAndActiveRegionHistogram | physics broad phase | 0.433 | 361.820 | 0.157 |
| radixSortMultiCalculateRanksLaunchWithCount | shared physics utilities | 18.400 | 7.391 | 0.136 |
| _ZN2Nv5Blast15StressHierarchy9packLevelILb1EEEvNS1_5InputENS1_7BuffersEPKNS1_6StatusEPS5_NS1_14PackingBuffersEPNS1_11PackingWorkEjNS1_18TerminalRetirementE | unclassified | 7.000 | 19.149 | 0.134 |
| boxBoxNphase_Kernel | physics narrow phase / contact lifecycle | 1.928 | 69.256 | 0.134 |
| computeIncrementalComparisonHistograms_Stage1 | physics broad phase | 1.422 | 60.800 | 0.086 |
| contactConstraintBlockPrepareParallelLaunchTGS | physics constraint preparation / solve / integration | 0.972 | 84.158 | 0.082 |

Stress iterations are numerical convergence iterations, not additional resimulations. CUDA-graph guarded tail kernels can execute beyond the reported iteration count; kernel dispatch counts are shown separately. Small per-call times combined with repeated dependent launches identify a scheduling/fusion investigation, not proof of a particular hardware throughput limit.

## CPU execution — core time, separate from elapsed wall time

| Host scope | Mean exclusive CPU core-ms / step |
|---|---|
| finishDetail.waitForGpu | 13.148 |
| acceptCorrection | 1.195 |
| detail.broadPhaseWait | 0.795 |
| trialDetail.broadPhaseWait | 0.440 |
| applyDetail.migrateShapes | 0.190 |
| trialDetail.postNarrowPhase | 0.134 |
| submit | 0.129 |
| finishDetail.allocateNativeBodies | 0.117 |
| trialDetail.processLostContacts3 | 0.114 |
| trialDetail.islandInsertion | 0.086 |

Process CPU time averages 22.749 core-ms per step in the host-scope capture. CPU thread clocks include busy waiting, driver and profiling work, but exclude descheduling. Same-thread children are subtracted from their parent; detached/cross-thread spans are excluded. Parallel CPU core-ms must not be added to wall-ms or GPU time. A large wait scope's CPU time does not mean the stress math runs on the CPU.

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
| Reported stress iterations | 281.594 | 0.000 | 634.000 | 421.675 |
| New broken bonds | 324.861 | 0.000 | 28160.000 | 487.292 |
| Correction passes | 0.428 | 0.000 | 1.000 | 0.642 |

Active-body counters come from CPU scheduling, not a qualified GPU sleep mask; sleeping is disabled here. Contact reports/pair visits are work counts, not unique collisions. Retained stress bonds are topology membership, not the number processed in every iteration. Legacy public contact-pair/solver-row counters are incomplete on this GPU path and are excluded. Allocation capacity and memory-bandwidth/occupancy counters are not collected in this report.

| Counter association (host-scope capture) | Pearson r with total step time | Pearson r with stress-stream time |
|---|---|---|
| Stress iterations | 0.936 | 0.995 |
| Scheduled active bodies | 0.925 | 0.992 |
| Retained stress bonds | -0.930 | -0.992 |
| Solved contact reports | 0.893 | 0.983 |
| Correction passes | 0.860 | 0.790 |

Associations describe this one evolving scene; they are not causal scaling laws. A dash means a constant/insufficient sample. In particular, retained-body and bond counts co-vary with impact time; controlled workload variations are needed to establish their independent costs.

## Automatic bottleneck summary and next decision

Largest elapsed regions: Wait for GPU destruction result: 13.158 ms/step; Trial physics and remaining scene tasks: 2.865 ms/step; Resimulate changed interaction: 2.187 ms/step.

Largest GPU-stream stage: Iterative stress solve to convergence (12.715 ms/step). A sub-1-ms target needs this measured cost reduced if it already exceeds 1 ms; increasing scene size would not remove it.

Late-scene stress remains active: 421.7 reported iterations/step in the last two seconds. No new fracture does not imply no stress work. Compare convergence, applied loads and contact changes before considering any result reuse; this report does not authorize skipped physics or relaxed convergence.

Evidence supports targeting the largest measured stages and investigating small-kernel/iteration scheduling. It does not distinguish memory-bandwidth limitation from arithmetic throughput: SM occupancy, bandwidth and instruction counters require a separate hardware-counter experiment. Scale an active workload only after comparing these per-step costs; the intact controls show geometry scaling alone.

## Reproduce, audit and extend

Capture and generate in one command: python3 tools/scripts/run-destruction-timing.py NEW_CAPTURE_DIRECTORY --trials 5 --gpu-trials 3 --seconds 10. Reports appear in NEW_CAPTURE_DIRECTORY/report. Regenerate from captures only: python3 tools/scripts/report-destruction-timing.py CAPTURE_DIRECTORY --output REPORT_DIRECTORY. Change the versioned tools/profiles/wall-penetration-timing.json configuration for additional physical workloads; every resolved command is retained.

report.json.gz contains every per-step partition, GPU region, CPU exclusive core-time scope, kernel symbol/source, transfer byte count, run signature and summary. campaign.json beside the captures records binary/library SHA-256 hashes, exact inputs, driver, GPU process/clock samples, and hashes of all raw files. Reports are generated from those recorded files, without querying the current GPU or inserting a generation timestamp.

Percentiles use nearest rank ceil(p × N), with 1-based ranks. Means pool equally long untraced runs; maxima retain all measured spikes. Event windows overlap and must not be added. Zero-size windows are omitted. Rounded display values can differ from the exact total by rounding; raw JSON preserves full precision.
