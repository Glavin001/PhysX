# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 256 rounds over 96 steps / 1.6 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **139.463 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 32.070 | 42.079 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 20.386 | 19.662 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 53.125 | 19.379 |
| Construct fragment compatibility objects | CPU PhysX body/lifecycle records after GPU preparation; still required before corrected simulation | 10.875 | 2.565 |
| Accept corrected step | GPU topology/motion commit and required status completion; older captures include CPU property publication | 2.569 | 2.436 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 7.196 | 1.388 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.271 | 0.646 |
| Publish final actor and query ownership | CPU applies the GPU-selected final shape-owner union after both stress evaluations; collision ownership is already installed | 2.739 | 0.630 |
| Finalize GPU state and CPU physical properties | GPU selection, final-state gathering and required completion, plus CPU property publication outside the shape-owner update | 1.654 | 0.445 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.829 | 0.399 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.299 | 0.317 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.240 | 0.283 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.106 | 0.241 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.180 | 0.166 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.528 | 0.129 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.513 | 0.111 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.608 | 0.093 |
| Observe GPU-selected fragment requests | GPU → CPU compact metadata after complete GPU collision and motion preparation | 0.088 | 0.088 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.050 | 0.055 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.039 |
| Validate GPU preparation verdicts | CPU validation/bookkeeping; legacy/manual paths may also wait; compatibility construction children are separate | 0.076 | 0.019 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.012 | 0.015 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.013 | 0.010 |
| Update fragment compatibility metadata | CPU registered-body range and suppression of placeholder uploads; GPU motion already initialized | 0.024 | 0.008 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 30.803 |
| Connectivity, cluster mass and fragment candidates | 0.953 |
| GPU allocation and preparation retry after exceptional storage growth | 0.379 |
| Convert solved contact impulses into chunk loads | 0.284 |
| Evaluate material damage and fracture | 0.141 |
| Commit changes and rebuild stress topology | 0.098 |
| GPU allocation, collision ownership preparation and corrected-motion preparation | 0.022 |
| GPU end-state copy for final splits (no time rewind) | 0.011 |
| GPU checkpoint restore (device-to-device copies) | 0.008 |
| GPU fragment motion installation before replay | 0.008 |
| GPU shape ownership installation before replay | 0.007 |
| GPU final-split shape ownership after replay | 0.007 |
| GPU final-split motion installation after replay | 0.004 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Calls | Longest call ms | Union wall ms | Reported thread CPU ms |
|---|---:|---:|---:|---:|
| detail.postBroadPhase | 1 | 6.158 | 6.158 | 6.158 |
| detail.broadPhaseWait | 1 | 6.146 | 6.146 | 6.146 |
| detail.registerSceneInteractions | 1 | 5.944 | 5.944 | 5.944 |
| detail.preallocateContactManagers | 1 | 5.583 | 5.583 | 5.583 |
| detail.islandInsertion | 1 | 4.613 | 4.613 | 4.613 |
| detail.updateDynamics | 1 | 4.084 | 4.084 | 4.084 |
| detail.postBroadPhaseStage2 | 1 | 3.176 | 3.176 | 3.176 |
| detail.postNarrowPhase | 1 | 2.320 | 2.320 | 1.958 |
| detail.registerInteractions | 1 | 1.787 | 1.787 | 1.787 |
| task.afterIntegration | 2 | 0.596 | 0.723 | 0.723 |
| task.queryMembershipQueue | 4 | 0.267 | 0.646 | 0.646 |
| task.accurateIslandMaintenance | 2 | 0.240 | 0.438 | 0.438 |
| detail.registerContactManagers | 1 | 0.391 | 0.391 | 0.391 |
| task.queryMembership | 1 | 0.354 | 0.354 | 0.354 |
| task.speculativeIslandMaintenance | 2 | 0.216 | 0.339 | 0.338 |
| task.contactGraph | 2 | 0.287 | 0.333 | 0.317 |
| detail.islandGen | 1 | 0.249 | 0.249 | 0.249 |
| task.accurateIsland.findPathsAndBreakIslands | 2 | 0.181 | 0.220 | 0.220 |
| task.sleepCommit | 1 | 0.142 | 0.142 | 0.079 |
| detail.updateDynamicsPostPartitioning | 1 | 0.135 | 0.135 | 0.135 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
