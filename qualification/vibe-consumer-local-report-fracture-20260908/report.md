# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **151.041 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 34.702 | 47.114 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 21.502 | 26.953 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 51.371 | 18.814 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 20.397 | 4.780 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.591 | 2.359 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 7.166 | 1.403 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 3.186 | 0.697 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.316 | 0.632 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.408 | 0.439 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.988 | 0.425 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.160 | 0.393 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.289 | 0.292 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.288 | 0.290 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.132 | 0.240 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.135 | 0.165 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.495 | 0.112 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.508 | 0.108 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.081 | 0.059 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.046 | 0.051 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.010 | 0.037 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.063 | 0.036 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.033 | 0.035 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.020 | 0.016 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.117 | 0.015 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.015 | 0.013 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.014 | 0.012 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 33.479 |
| Connectivity, cluster mass and fragment candidates | 0.952 |
| Convert solved contact impulses into chunk loads | 0.277 |
| Evaluate material damage and fracture | 0.140 |
| Commit changes and rebuild stress topology | 0.084 |
| GPU checkpoint restore (device-to-device copies) | 0.016 |
| GPU fragment motion installation before replay | 0.011 |
| GPU end-state copy for final splits (no time rewind) | 0.011 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split motion installation after replay | 0.004 |
| GPU final-split shape ownership after replay | 0.003 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Union wall ms | Reported thread CPU ms |
|---|---:|---:|
| detail.preallocateContactManagers | 7.220 | 7.220 |
| detail.postBroadPhase | 6.168 | 6.168 |
| detail.broadPhaseWait | 6.156 | 6.156 |
| detail.registerSceneInteractions | 5.983 | 5.975 |
| task.sleepCommit | 4.987 | 4.715 |
| detail.updateDynamics | 4.669 | 4.669 |
| detail.islandInsertion | 4.372 | 4.358 |
| detail.registerInteractions | 2.765 | 2.754 |
| detail.postNarrowPhase | 2.224 | 1.866 |
| detail.postBroadPhaseStage2 | 1.795 | 1.795 |
| task.afterIntegration | 0.689 | 0.689 |
| task.queryMembership | 0.569 | 0.569 |
| detail.registerContactManagers | 0.452 | 0.452 |
| task.contactGraph | 0.449 | 0.434 |
| task.accurateIslandMaintenance | 0.440 | 0.440 |
| task.speculativeIslandMaintenance | 0.356 | 0.351 |
| task.queryMembershipQueue | 0.336 | 0.336 |
| task.bodyDmaWait | 0.333 | 0.333 |
| detail.islandGen | 0.269 | 0.269 |
| task.accurateIsland.findPathsAndBreakIslands | 0.222 | 0.223 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
