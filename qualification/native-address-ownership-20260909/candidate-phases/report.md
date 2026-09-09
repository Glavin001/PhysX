# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 256 rounds over 96 steps / 1.6 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **143.270 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 32.254 | 42.022 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 56.975 | 19.200 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 20.025 | 18.815 |
| Construct fragment compatibility objects | CPU PhysX body/lifecycle records after GPU preparation; still required before corrected simulation | 10.756 | 2.500 |
| Accept corrected step | GPU topology/motion commit and required status completion; older captures include CPU property publication | 2.584 | 2.442 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 7.281 | 1.385 |
| Publish final actor and query ownership | CPU applies the GPU-selected final shape-owner union after both stress evaluations; collision ownership is already installed | 2.864 | 0.644 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.190 | 0.625 |
| Finalize GPU state and CPU physical properties | GPU selection, final-state gathering and required completion, plus CPU property publication outside the shape-owner update | 1.458 | 0.509 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.943 | 0.396 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.296 | 0.318 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.265 | 0.283 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.098 | 0.226 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.299 | 0.222 |
| Observe GPU-selected fragment requests | GPU → CPU compact metadata after complete GPU collision and motion preparation | 0.130 | 0.138 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.518 | 0.121 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.508 | 0.111 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.690 | 0.107 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.049 | 0.055 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.010 | 0.038 |
| Validate GPU preparation verdicts | CPU validation/bookkeeping; legacy/manual paths may also wait; compatibility construction children are separate | 0.020 | 0.016 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.013 | 0.014 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.014 | 0.010 |
| Update fragment compatibility metadata | CPU registered-body range and suppression of placeholder uploads; GPU motion already initialized | 0.023 | 0.007 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 30.974 |
| Connectivity, cluster mass and fragment candidates | 0.961 |
| GPU allocation and preparation retry after exceptional storage growth | 0.383 |
| Convert solved contact impulses into chunk loads | 0.289 |
| Evaluate material damage and fracture | 0.139 |
| Commit changes and rebuild stress topology | 0.098 |
| GPU allocation, collision ownership preparation and corrected-motion preparation | 0.020 |
| GPU end-state copy for final splits (no time rewind) | 0.012 |
| GPU checkpoint restore (device-to-device copies) | 0.008 |
| GPU fragment motion installation before replay | 0.007 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split shape ownership after replay | 0.005 |
| GPU final-split motion installation after replay | 0.004 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Calls | Longest call ms | Union wall ms | Reported thread CPU ms |
|---|---:|---:|---:|---:|
| detail.preallocateContactManagers | 1 | 7.340 | 7.340 | 7.339 |
| detail.postBroadPhase | 1 | 6.119 | 6.119 | 6.098 |
| detail.broadPhaseWait | 1 | 6.080 | 6.080 | 6.075 |
| detail.registerSceneInteractions | 1 | 5.654 | 5.654 | 5.644 |
| detail.updateDynamics | 1 | 4.734 | 4.734 | 4.735 |
| detail.islandInsertion | 1 | 4.181 | 4.181 | 4.181 |
| detail.postBroadPhaseStage2 | 1 | 3.530 | 3.530 | 3.517 |
| detail.postNarrowPhase | 1 | 2.606 | 2.606 | 2.267 |
| detail.registerInteractions | 1 | 2.092 | 2.092 | 2.092 |
| task.afterIntegration | 2 | 0.411 | 0.817 | 0.817 |
| detail.islandGen | 1 | 0.480 | 0.480 | 0.480 |
| task.queryMembershipQueue | 4 | 0.205 | 0.460 | 0.460 |
| detail.registerContactManagers | 1 | 0.424 | 0.424 | 0.424 |
| task.accurateIslandMaintenance | 2 | 0.244 | 0.394 | 0.391 |
| task.contactGraph | 2 | 0.327 | 0.374 | 0.325 |
| task.queryMembership | 1 | 0.368 | 0.368 | 0.368 |
| task.bodyDmaWait | 2 | 0.274 | 0.336 | 0.336 |
| task.speculativeIslandMaintenance | 2 | 0.164 | 0.277 | 0.277 |
| task.sleepCommit | 1 | 0.264 | 0.264 | 0.086 |
| task.accurateIsland.findPathsAndBreakIslands | 2 | 0.179 | 0.210 | 0.210 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
