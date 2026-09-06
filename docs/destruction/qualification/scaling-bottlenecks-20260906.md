# Native PhysX GPU destruction: scaling and phase profile

**The principal scaling bottleneck in these collapse workloads is CPU contact and island lifecycle processing.** Raw authored chunk/bond count and raw awake-body count do not explain the slowdown.

- The intact 113,664-chunk / 229,376-bond city averages **0.518 ms**. It has 256 motion clusters and zero awake bodies.
- **96,000 separated awake bodies** average **2.883 ms**; 24,000 average **0.847 ms**. They are moving, gravity-free ordinary bodies in empty space, an explicitly different control workload.
- Bombardment with approximately **21,087 awake bodies** and **140,672 processed contact pairs/step** averages **46.431 ms**. Contact workload and lifecycle churn dominate the comparison.
- In its detailed trace, **6.703 of 45.945 ms** contains this process's GPU execution; **39.242 ms (85.4%)** has none. Measured CPU tasks identify registration, allocation, lost-contact processing, and island graph maintenance as major costs. The remaining host gap is not automatically classified as CPU arithmetic.
- GPU stress kernels, including stress-topology maintenance, average **0.271 ms** in this bombardment. On the isolated-impact large city they take a larger share; optimization priorities are workload-dependent.
- The 113,664-chunk burst and sustained-impact variants fail on contact/friction solver memory growth under the shared GPU conditions. This is a separate capacity bottleneck, not a valid completed timing result.

**Where to focus next:** move contact/interaction lifecycle and island scheduling onto the resident GPU path; address the dense-contact solver allocation footprint; then optimize broad-phase candidate generation. Checkpoint copies and the stress solver are smaller costs in the measured large-collapse case. No physics shortcut is justified by these measurements.

## What grows with what

| Work | Relevant workload term | Evidence / interpretation |
|---|---|---|
| CPU active-body/deactivation scans | Active/native body slots | Separated 6k/24k/96k controls expose body-count cost without contacts. At 96k, accurate + speculative deactivation consume about 1.8 CPU core-ms/step. |
| CPU interaction registration and retirement | New/lost contact-manager edges and shapes | Dominant measured task family during dense collapse; less expensive after the contact set settles. |
| CPU island maintenance | Contact graph size, removed edges, connectivity searches | Accurate-island path finding reaches 236 CPU core-ms in one measured step. This work can persist without any newly broken destruction bonds. |
| GPU broad phase | Updated shape bounds and spatial overlap candidates | Largest GPU category in the collapse; incremental sweep-and-prune is the largest individual kernel. |
| GPU narrow phase / constraint solve | Candidate pairs, touching contacts, friction rows, solver iterations | Contact-rich scenes cost much more than separated bodies; allocations for contact/friction blocks can exhaust available VRAM. |
| GPU stress | Active stress nodes/bonds, convergence iterations, island distribution | 200k retained stress bonds in the intact city are cheap after convergence; an impact changes convergence work. Counts alone do not predict iteration cost. |
| GPU topology changes | Affected chunks/bonds/components and new cluster slots | Occurs on fracture decisions; report includes corrected versus noncorrected steps. It is not the sustained-collapse bottleneck here. |
| Checkpoint | Allocated native rigid-state slots | At 96k free bodies, approximately 23 MB of device-to-device checkpoint copies take 0.024 ms/step in the trace; no CPU pose transfer. |

These are dependencies supported by the controls and implementation, not fitted Big-O claims. Contact count and topology churn are related; the campaign does not independently fix one while sweeping the other.

Measured on the available RTX 4090, with another GPU process present. This is a bottleneck investigation, **not isolated 60 Hz qualification**. No physical settings, stress tolerances, damage model, or one-correction limit were reduced. Rendering, video export, and motion auditing were off.

Each run advances 720 steps (12 simulated seconds); the first 60 steps are excluded from the tables. Untraced comparisons use two repeat runs per workload. Separate CUPTI runs provide actual concurrent kernel/copy intervals and timestamped, per-thread CPU scopes. First-impact allocation and correction spikes remain in the measured interval. The campaign also retains incomplete runs; they are not successful timing samples.

## Baseline workloads

Bodies are registered PhysX dynamic + kinematic bodies; awake counts are the last solver pass’s island scheduling counts. Supported buildings use kinematic clusters. Sleeping remains disabled in this integrated correction path. “Pairs/step” counts contact managers processed across trial and correction, not unique touching pairs. Stress-active bonds are the retained stress graph, not the number visited by every iterative kernel.

| Workload | Authored chunks / bonds | Bodies mean / max | Awake mean / max | Pairs/step mean | Mean ms | Min / p95 / max ms | >16.67 ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| idle g1 | 444 / 896 | 1 / 1 | 0 / 0 | 0 | 0.332 | 0.243 / 0.449 / 1.630 | 0/1320 |
| idle g4 | 7,104 / 14,336 | 16 / 16 | 0 / 0 | 0 | 0.328 | 0.238 / 0.407 / 2.440 | 0/1320 |
| idle g8 | 28,416 / 57,344 | 64 / 64 | 0 / 0 | 0 | 0.350 | 0.269 / 0.449 / 1.785 | 0/1320 |
| idle g16 | 113,664 / 229,376 | 256 / 256 | 0 / 0 | 0 | 0.518 | 0.428 / 0.618 / 2.107 | 0/1320 |
| single-impact g16 | 113,664 / 229,376 | 1,110 / 1,932 | 633 / 1,311 | 3,023 | 4.555 | 0.963 / 12.783 / 27.659 | 14/1320 |
| burst g1 | 444 / 896 | 367 / 380 | 286 / 380 | 924 | 1.154 | 0.472 / 1.649 / 9.425 | 0/1320 |
| burst g4 | 7,104 / 14,336 | 5,757 / 6,094 | 5,386 / 5,983 | 25,137 | 4.346 | 0.509 / 11.519 / 30.517 | 9/1320 |
| burst g8 | 28,416 / 57,344 | 22,982 / 24,355 | 21,087 / 23,740 | 140,672 | 46.431 | 0.620 / 244.379 / 771.244 | 622/1320 |
| burst g16 | — | — | — | — | **INCOMPLETE** | GPU allocation failure | — |
| sustained g16 | — | — | — | — | **INCOMPLETE** | GPU allocation failure | — |
| free-24000 g1 | 444 / 896 | 24,001 / 24,001 | 24,000 / 24,000 | 0 | 0.847 | 0.761 / 0.935 / 2.422 | 0/1320 |
| free-6000 g1 | 444 / 896 | 6,001 / 6,001 | 6,000 / 6,000 | 0 | 0.622 | 0.558 / 0.684 / 2.016 | 0/1320 |
| free-96000 g1 | 444 / 896 | 96,001 / 96,001 | 96,000 / 96,000 | 0 | 2.883 | 2.374 / 3.287 / 4.396 | 0/1320 |

A fast mean is insufficient for strict 60 Hz: the deadline column includes allocation, impact, and correction spikes. These are 11-second measured windows, not the specified future five-by-60-second qualification.

## GPU execution versus host-controlled gaps

These rows come from the **traced** runs, so their wall times differ from the untraced baseline above. Kernel union + copy-only union + no-GPU interval sum to the timestamped simulation interval (within rounding). No-GPU means no traced GPU activity from this process; another process may still be using the GPU. Thread/process CPU core-ms include spinning and profiler/driver work and cannot be added to wall-ms.

| Workload | Wall ms | Kernel union ms | Copy-only ms | No GPU activity ms | Process CPU core-ms | Instrumented CPU core-ms |
|---|---:|---:|---:|---:|---:|---:|
| idle g1 | 0.581 | 0.079 | 0.013 | 0.488 | 0.990 | 0.413 |
| idle g4 | 0.605 | 0.084 | 0.014 | 0.506 | 1.071 | 0.439 |
| idle g8 | 0.623 | 0.108 | 0.016 | 0.499 | 1.090 | 0.457 |
| idle g16 | 0.699 | 0.247 | 0.017 | 0.435 | 1.184 | 0.549 |
| single-impact g16 | 4.826 | 2.705 | 0.183 | 1.938 | 6.848 | 3.819 |
| burst g1 | 1.546 | 0.567 | 0.098 | 0.881 | 2.846 | 0.925 |
| burst g4 | 5.094 | 1.308 | 0.317 | 3.470 | 9.389 | 3.787 |
| burst g8 | 45.945 | 5.377 | 1.327 | 39.242 | 89.005 | 38.077 |
| free-24000 g1 | 1.213 | 0.273 | 0.078 | 0.862 | 2.210 | 0.762 |
| free-6000 g1 | 0.940 | 0.237 | 0.045 | 0.658 | 1.693 | 0.546 |
| free-96000 g1 | 3.277 | 0.587 | 0.214 | 2.476 | 5.542 | 2.560 |

## Phase costs across workloads

CPU columns are exclusive **core-ms/step**, so the two task families do not double-count their synchronous children. GPU columns are summed kernel ms/step; these columns are not an additive wall-time decomposition.

| Workload | CPU contact lifecycle | CPU island maintenance | CPU new-body allocation | GPU broad phase | GPU rigid solve/preparation | GPU stress |
|---|---:|---:|---:|---:|---:|---:|
| idle g1 | 0.008 | 0.043 | 0.000 | 0.002 | 0.000 | 0.038 |
| idle g4 | 0.008 | 0.044 | 0.000 | 0.002 | 0.000 | 0.041 |
| idle g8 | 0.008 | 0.044 | 0.000 | 0.002 | 0.000 | 0.049 |
| idle g16 | 0.008 | 0.044 | 0.000 | 0.002 | 0.000 | 0.113 |
| single-impact g16 | 0.068 | 0.097 | 0.003 | 0.271 | 0.398 | 1.432 |
| burst g1 | 0.037 | 0.067 | 0.001 | 0.030 | 0.273 | 0.056 |
| burst g4 | 0.817 | 0.882 | 0.012 | 0.167 | 0.464 | 0.188 |
| burst g8 | 14.253 | 13.007 | 0.107 | 2.804 | 1.005 | 0.271 |
| free-24000 g1 | 0.008 | 0.288 | 0.000 | 0.042 | 0.074 | 0.039 |
| free-6000 g1 | 0.008 | 0.093 | 0.000 | 0.028 | 0.057 | 0.038 |
| free-96000 g1 | 0.008 | 1.854 | 0.000 | 0.119 | 0.239 | 0.043 |

Contact lifecycle groups insertion/registration/preallocation and lost-contact processing in trial and correction. Island maintenance groups accurate/speculative graph maintenance and their children. All individual scopes remain available below and in JSON.


## Detailed largest completed bombardment trace

Source: `out/scaling-final-20260906/burst-g8-t0`. All means below are amortized over 660 measured steps. Nested host timings and simultaneous kernels are not an additive wall-time breakdown.

### GPU kernel categories

| Category | Sum mean ms | Per-step p95 ms | Per-step max ms |
|---|---:|---:|---:|
| physics broad phase | 2.804 | 8.563 | 26.645 |
| physics constraint preparation / solve / integration | 1.005 | 1.959 | 3.296 |
| physics narrow phase / contact lifecycle | 0.604 | 1.509 | 4.664 |
| destruction contact graph | 0.419 | 0.743 | 3.337 |
| stress solver / stress topology | 0.271 | 0.160 | 3.337 |
| destruction pre-solve contacts / islands | 0.170 | 0.352 | 2.171 |
| destruction load gathering | 0.169 | 0.276 | 0.563 |
| shared CUDA scan / sort primitives | 0.091 | 0.214 | 0.263 |
| shared physics utilities | 0.091 | 0.269 | 0.283 |
| destruction orchestration / motion | 0.052 | 0.164 | 0.183 |
| CUDA memory utility kernels | 0.041 | 0.067 | 0.488 |
| destruction connectivity / mass / slots | 0.039 | 0.403 | 0.427 |
| physics body / shape updates | 0.025 | 0.047 | 0.099 |
| destruction material / damage | 0.015 | 0.018 | 0.021 |

Category timings are sums of observed kernel durations, including contention. They are not hardware utilization percentages and do not establish DRAM-bandwidth versus SM-throughput saturation. Source-based classification and every kernel name are retained in the JSON report.

### CPU tasks

| Scope | Exclusive CPU core-ms mean | p95 / max core-ms per step | Inclusive wall-ms mean | GPU overlap within scope ms |
|---|---:|---:|---:|---:|
| trialDetail.islandInsertion | 2.634 | 10.809 / 32.558 | 2.636 | 0.000 |
| trialDetail.postBroadPhase | 2.623 | 8.262 / 13.517 | 2.625 | 2.609 |
| task.accurateIsland.findPathsAndBreakIslands | 2.497 | 8.041 / 236.277 | 2.498 | 0.000 |
| trialDetail.registerSceneInteractions | 2.460 | 10.837 / 38.392 | 2.463 | 0.000 |
| trialDetail.updateDynamics | 2.322 | 9.848 / 29.633 | 2.324 | 0.014 |
| trialDetail.postNarrowPhase | 2.206 | 9.871 / 25.309 | 2.639 | 0.489 |
| trialDetail.processLostContacts3 | 2.142 | 9.024 / 27.579 | 2.148 | 0.000 |
| trialDetail.registerContactManagers | 1.985 | 10.416 / 27.993 | 1.988 | 0.000 |
| trialDetail.preallocateContactManagers | 1.840 | 8.307 / 17.589 | 1.846 | 0.002 |
| task.accurateIsland.clearDestroyedEdges | 1.714 | 7.992 / 34.212 | 1.715 | 0.000 |
| trialDetail.registerInteractions | 1.665 | 8.223 / 21.086 | 1.665 | 0.000 |
| task.accurateIsland.removeDestroyedConnections | 1.405 | 5.827 / 20.659 | 1.406 | 0.000 |
| task.speculativeIsland.removeDestroyedConnections | 1.382 | 5.468 / 16.505 | 1.385 | 0.000 |
| task.speculativeIsland.removeEdgesFromIslands | 1.331 | 5.411 / 19.091 | 1.333 | 0.000 |
| trialDetail.processLostContacts2 | 1.182 | 5.400 / 14.344 | 1.183 | 0.174 |
| task.accurateIsland.removeEdgesFromIslands | 1.177 | 5.291 / 21.161 | 1.179 | 0.000 |
| task.speculativeIsland.findPathsAndBreakIslands | 1.170 | 8.075 / 23.015 | 1.170 | 0.000 |
| task.prepareIslandRepair | 1.019 | 1.578 / 5.425 | 1.095 | 0.804 |
| task.speculativeIsland.clearDestroyedEdges | 0.974 | 4.844 / 23.911 | 0.975 | 0.000 |
| task.speculativeIsland.deactivation | 0.930 | 4.355 / 11.040 | 0.930 | 0.000 |
| finishDetail.waitForGpu | 0.577 | 1.088 / 5.807 | 0.578 | 0.366 |
| trialDetail.islandGen | 0.577 | 2.580 / 4.132 | 0.580 | 0.000 |
| task.accurateIsland.deactivation | 0.382 | 1.497 / 5.056 | 0.382 | 0.001 |
| submit | 0.374 | 0.593 / 0.752 | 0.373 | 0.259 |
| trialDetail.postBroadPhaseStage2 | 0.216 | 0.838 / 2.613 | 0.217 | 0.000 |
| trialDetail.updateDynamicsPostPartitioning | 0.211 | 0.313 / 0.457 | 0.211 | 0.141 |
| detail.postBroadPhase | 0.191 | 0.835 / 13.431 | 0.191 | 0.188 |
| detail.processLostContacts3 | 0.108 | 0.132 / 23.228 | 0.108 | 0.000 |
| finishDetail.allocateNativeBodies | 0.107 | 0.197 / 4.067 | 0.107 | 0.000 |
| detail.islandInsertion | 0.078 | 0.524 / 2.538 | 0.078 | 0.000 |
| detail.postNarrowPhase | 0.074 | 0.378 / 9.316 | 0.096 | 0.026 |
| detail.processLostContacts2 | 0.070 | 0.122 / 12.552 | 0.070 | 0.007 |
| applyBindings | 0.068 | 0.280 / 2.129 | 0.070 | 0.000 |
| detail.updateDynamics | 0.054 | 0.416 / 3.889 | 0.054 | 0.001 |
| detail.registerSceneInteractions | 0.035 | 0.316 / 2.191 | 0.035 | 0.000 |
| refilter | 0.029 | 0.310 / 0.471 | 0.029 | 0.000 |
| acceptCorrection | 0.025 | 0.244 / 0.366 | 0.025 | 0.010 |
| detail.preallocateContactManagers | 0.022 | 0.169 / 0.727 | 0.022 | 0.002 |
| checkpoint | 0.022 | 0.033 / 0.277 | 0.022 | 0.006 |
| detail.islandGen | 0.021 | 0.050 / 3.580 | 0.021 | 0.000 |
| detail.postBroadPhaseStage2 | 0.020 | 0.113 / 1.232 | 0.020 | 0.000 |
| task.accurateIslandMaintenance | 0.018 | 0.030 / 0.044 | 7.205 | 0.003 |
| task.speculativeIslandMaintenance | 0.018 | 0.030 / 0.042 | 5.816 | 0.002 |
| detail.registerInteractions | 0.017 | 0.131 / 0.823 | 0.017 | 0.000 |
| detail.updateDynamicsPostPartitioning | 0.017 | 0.152 / 0.588 | 0.017 | 0.009 |
| finishAndReserve | 0.011 | 0.015 / 0.019 | 0.706 | 0.368 |
| initializeReserved | 0.008 | 0.049 / 2.250 | 0.009 | 0.001 |
| detail.registerContactManagers | 0.008 | 0.028 / 0.574 | 0.008 | 0.000 |
| collisionBindings | 0.007 | 0.054 / 0.123 | 0.008 | 0.001 |
| correctionBodies | 0.007 | 0.052 / 0.139 | 0.011 | 0.005 |
| task.cpuNarrowPhaseMerge | 0.006 | 0.009 / 0.021 | 0.006 | 0.000 |
| trialDetail.beforeSolver | 0.005 | 0.013 / 0.021 | 0.005 | 0.000 |
| trialDetail.processLostContacts | 0.005 | 0.008 / 0.036 | 0.008 | 0.007 |
| finishDetail.requestReadback | 0.004 | 0.038 / 0.088 | 0.005 | 0.001 |
| task.contactGraph | 0.003 | 0.006 / 0.012 | 0.003 | 0.000 |
| restoreInstall | 0.003 | 0.032 / 0.056 | 0.003 | 0.001 |
| finishDetail.reserveBodies | 0.003 | 0.009 / 0.177 | 0.118 | 0.001 |
| trialDetail.postSolver | 0.002 | 0.004 / 0.006 | 0.002 | 0.000 |
| trialDetail.postIslandGen | 0.002 | 0.003 / 0.008 | 0.002 | 0.000 |
| finishDetail.uploadBindings | 0.002 | 0.014 / 0.029 | 0.002 | 0.000 |
| task.accurateIsland.boundaryAudit | 0.001 | 0.003 / 0.007 | 0.001 | 0.000 |
| task.speculativeIsland.boundaryAudit | 0.001 | 0.003 / 0.006 | 0.001 | 0.000 |
| trialDetail.postBroadPhaseStage3 | 0.001 | 0.002 / 0.008 | 0.001 | 0.000 |
| resetContactCaches | 0.001 | 0.013 / 0.022 | 0.001 | 0.000 |
| task.speculativeIsland.resetDirtyEdges | 0.001 | 0.002 / 0.007 | 0.001 | 0.000 |
| task.accurateIsland.resetDirtyEdges | 0.001 | 0.002 / 0.003 | 0.001 | 0.000 |
| task.speculativeIsland.clearDestroyedNodes | 0.001 | 0.002 / 0.005 | 0.001 | 0.000 |
| task.accurateIsland.clearDestroyedNodes | 0.001 | 0.002 / 0.004 | 0.001 | 0.000 |
| finishDetail.publishReservation | 0.001 | 0.010 / 0.020 | 0.001 | 0.000 |
| detail.beforeSolver | 0.000 | 0.004 / 0.014 | 0.000 | 0.000 |
| detail.processLostContacts | 0.000 | 0.003 / 0.010 | 0.000 | 0.000 |
| detail.postSolver | 0.000 | 0.002 / 0.004 | 0.000 | 0.000 |
| detail.postIslandGen | 0.000 | 0.002 / 0.006 | 0.000 | 0.000 |
| detail.postBroadPhaseStage3 | 0.000 | 0.001 / 0.002 | 0.000 | 0.000 |
| correctedCollisionSolve | 0.000 | 0.000 / 0.000 | 3.293 | 0.405 |

Synchronous children on the same OS thread are subtracted from CPU time. Detached correction spans have wall time only. Uninstrumented CPU time remains visible as the difference from total process CPU core-ms; it includes dispatcher work/spinning, callbacks, and profiling overhead and is not automatically classified as useful physics calculation.

### Correction, checkpoint, and waiting

| Measurement | Mean | p95 | Max |
|---|---:|---:|---:|
| correction_wall_ms | 3.293 | 11.003 | 443.169 |
| correction_gpu_busy_ms | 0.405 | 3.399 | 16.914 |
| trial_and_other_gpu_busy_ms | 6.298 | 13.767 | 26.166 |
| checkpoint_gpu_copy_union_ms | 0.011 | 0.013 | 0.084 |
| checkpoint_gpu_copy_bytes | 5506850.909 | 5844720.000 | 5844720.000 |
| cuda_wait_api_union_ms | 1.776 | 6.146 | 8.611 |
| no_gpu_inside_cuda_wait_ms | 0.396 | 0.714 | 2.244 |

Corrected steps: 65. Mean corrected collision/solve wall interval **when it ran**: 33.434 ms. No step exceeds one correction.

Checkpoint copies are device-to-device transfers associated with APIs inside the explicit checkpoint scope by CUPTI correlation IDs; their execution can occur after that CPU scope returns. CUDA wait-API durations overlap GPU execution, CPU work, and one another; they are not an additional simulation cost. A wait marks a dependency, and its CPU clock may include active polling.

| CUDA API | Summed host duration / measured step, ms |
|---|---:|
| cudaEventSynchronize_v3020 | 1.2048 |
| cuLaunchKernel | 0.6386 |
| cuStreamSynchronize | 0.4689 |
| cudaLaunchKernel_v7000 | 0.3131 |
| cuMemcpyHtoDAsync_v2 | 0.2496 |
| cuMemcpyDtoDAsync_v2 | 0.1716 |
| cudaGraphLaunch_v10000 | 0.1156 |
| cudaMemsetAsync_v3020 | 0.1139 |
| cuMemcpyDtoHAsync_v2 | 0.1059 |
| cudaMemcpyAsync_v3020 | 0.0908 |
| cuMemsetD32Async | 0.0703 |
| cudaStreamSynchronize_v3020 | 0.0580 |
| cudaMemcpy_v3020 | 0.0440 |
| cudaEventRecord_v3020 | 0.0255 |
| cudaMalloc_v3020 | 0.0200 |
| cudaFree_v3020 | 0.0158 |
| cudaStreamWaitEvent_v3020 | 0.0157 |
| cuEventRecord | 0.0100 |
| cuStreamQuery | 0.0090 |
| cuMemHostGetDevicePointer_v2 | 0.0079 |
| cuStreamWaitEvent | 0.0076 |
| cuCtxPopCurrent_v2 | 0.0073 |
| cuCtxPushCurrent_v2 | 0.0072 |
| cudaGetLastError_v3020 | 0.0055 |
| cuMemsetD8Async | 0.0053 |

### Continued contacts without new breakage

- corrected: 65 steps; mean **78.064 ms**, p95 263.582, max 847.320; awake mean 16,610, processed pairs mean 195,768.
- uncorrected: 595 steps; mean **42.434 ms**, p95 173.150, max 395.572; awake mean 21,749, processed pairs mean 131,694.
- late_rubble: 241 steps; mean **11.034 ms**, p95 14.066, max 15.617; awake mean 23,195, processed pairs mean 113,843.
- contact_without_new_fracture: 573 steps; mean **44.027 ms**, p95 174.908, max 395.572; awake mean 22,579, processed pairs mean 136,750.

## Scaling associations

The correlations below use frame samples within each traced workload. They are associations, not fitted algorithmic complexity or causal coefficients: body count, pair count, damage, and simulation time co-vary. The separated-body and intact-city controls provide the stronger comparisons.

| Workload | Step time vs awake bodies | vs processed pairs | vs retained stress bonds | vs stress iterations | vs newly broken bonds | vs correction flag |
|---|---:|---:|---:|---:|---:|---:|
| idle g1 | — | — | — | — | — | — |
| idle g4 | — | — | — | — | — | — |
| idle g8 | — | — | — | — | — | — |
| idle g16 | — | — | — | — | — | — |
| single-impact g16 | -0.032 | 0.703 | -0.005 | 0.858 | 0.281 | 0.758 |
| burst g1 | 0.293 | 0.266 | -0.263 | 0.772 | 0.760 | 0.684 |
| burst g4 | 0.027 | 0.728 | -0.072 | 0.298 | 0.308 | 0.488 |
| burst g8 | -0.005 | 0.910 | -0.139 | -0.067 | -0.069 | 0.151 |
| free-24000 g1 | — | — | — | — | — | — |
| free-6000 g1 | — | — | — | — | — | — |
| free-96000 g1 | — | — | — | — | — | — |

## Instrumentation and limitations

- CUPTI concurrent-kernel, memcpy, memset, driver and runtime activity tracing; no per-kernel synchronization or kernel replay. Every successful trace must have zero dropped records and zero invalid timestamps. Old initial traces have driver-only APIs; final detailed traces include runtime APIs too.
- Frame, scope, and activity clocks share CUPTI timestamps when tracing is enabled. GPU overlap is computed from interval unions, not the sum of durations. CPU clocks are process CPU time and per-OS-thread CPU time.
- CUDA-event stress-stage intervals remain in `native.phases.csv.device.csv.gz`; they include dependencies and launch gaps. They are not substituted for measured kernel execution.
- The legacy `stress_solve_ms` column is an unavailable zero placeholder; this report never uses it. Public contact/solver statistics do not include all GPU work and are also excluded; use processed contact-manager pairs and solved contact reports.
- Counter observations are small fixed-size diagnostic reads after simulation; pose arrays are not read. Diagnostic observations and input placement are outside `physics_step_ms`, and could still affect following-step GPU conditions. CUPTI transferred-byte counts exclude implicit mapped-memory traffic.
- All physical parameters, actual-impulse fracture decisions, stress convergence checks, and one-correction limit are retained. Large chaotic trajectories vary between repeats, so trace-versus-baseline differences are not a precise subtractable profiler overhead. Idle and separated-body repeats are the cleaner overhead checks.
- Native corrected-path sleeping is still unsupported here. These results do not establish the scale of a sleeping integrated scene. Existing native CUDA memory-sanitizer qualification is a separate unresolved gate; these successful runs do not resolve it.
- Build commands, exact binary/shared-library hashes, modified-source hashes, run arguments, GPU-process inventory, and sampled GPU conditions are in each campaign JSON. Traced and untraced captures differ only in diagnostic instrumentation; final traces add explicit checkpoint and CPU fallback scopes to the same physics implementation. Failed runs retain their logs and partial traces.
- Scope accounting tests cover overlap, nested/parallel CPU scopes, crossing-scope rejection, frame clipping, and constant-counter correlations. These timing changes do not alter solver equations.

## Failure inventory

- `out/scaling-profile-20260906/burst-g16-t0.log`: [PhysX:16] PxgCudaDeviceMemoryAllocator failed to allocate memory 1073741824 bytes requested at /root/workspace/physx-2/physx/source/gpusolver/src/PxgTGSCudaSolverCore.cpp:603! Result = 2 (/root/workspace/physx-2/physx/source/gpucommon/src/PxgCudaMemoryAllocator.cpp:164) INCOMPLETE native step 168: fetch=2 stage=0 broken=0 crushed=0
- `out/scaling-profile-20260906/sustained-g16-t0.log`: [PhysX:16] PxgCudaDeviceMemoryAllocator failed to allocate memory 945815552 bytes requested at /root/workspace/physx-2/physx/source/gpusolver/src/PxgTGSCudaSolverCore.cpp:605! Result = 2 (/root/workspace/physx-2/physx/source/gpucommon/src/PxgCudaMemoryAllocator.cpp:164) INCOMPLETE native step 328: fetch=2 stage=0 broken=0 crushed=0
- `out/scaling-profile-20260906/burst-g16-t1.log`: [PhysX:16] PxgCudaDeviceMemoryAllocator failed to allocate memory 1073741824 bytes requested at /root/workspace/physx-2/physx/source/gpusolver/src/PxgTGSCudaSolverCore.cpp:585! Result = 2 (/root/workspace/physx-2/physx/source/gpucommon/src/PxgCudaMemoryAllocator.cpp:164) INCOMPLETE native step 180: fetch=2 stage=0 broken=0 crushed=0
- `out/scaling-profile-20260906/sustained-g16-t1.log`: [PhysX:16] PxgCudaDeviceMemoryAllocator failed to allocate memory 1031798784 bytes requested at /root/workspace/physx-2/physx/source/gpusolver/src/PxgTGSCudaSolverCore.cpp:607! Result = 2 (/root/workspace/physx-2/physx/source/gpucommon/src/PxgCudaMemoryAllocator.cpp:164) INCOMPLETE native step 359: fetch=2 stage=0 broken=0 crushed=0
- `out/scaling-profile-20260906/burst-g16-t2.log`: [PhysX:16] PxgCudaDeviceMemoryAllocator failed to allocate memory 1073741824 bytes requested at /root/workspace/physx-2/physx/source/gpusolver/src/PxgTGSCudaSolverCore.cpp:585! Result = 2 (/root/workspace/physx-2/physx/source/gpucommon/src/PxgCudaMemoryAllocator.cpp:164) INCOMPLETE native step 179: fetch=2 stage=0 broken=0 crushed=0
- `out/scaling-profile-20260906/sustained-g16-t2.log`: [PhysX:16] PxgCudaDeviceMemoryAllocator failed to allocate memory 1031798784 bytes requested at /root/workspace/physx-2/physx/source/gpusolver/src/PxgTGSCudaSolverCore.cpp:607! Result = 2 (/root/workspace/physx-2/physx/source/gpucommon/src/PxgCudaMemoryAllocator.cpp:164) INCOMPLETE native step 331: fetch=2 stage=0 broken=0 crushed=0
