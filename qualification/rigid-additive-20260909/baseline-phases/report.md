# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **145.462 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 31.710 | 41.770 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 22.752 | 21.208 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 52.365 | 20.951 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 11.800 | 2.740 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.653 | 2.440 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 9.606 | 1.740 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.546 | 0.795 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 3.572 | 0.764 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 2.074 | 0.441 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.279 | 0.440 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.383 | 0.350 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.509 | 0.346 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.334 | 0.334 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.218 | 0.259 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.131 | 0.182 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.498 | 0.121 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.505 | 0.111 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.048 | 0.077 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.073 | 0.072 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.078 | 0.053 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.033 | 0.041 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.039 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.081 | 0.024 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.014 | 0.024 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.171 | 0.019 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.015 | 0.016 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 30.510 |
| Connectivity, cluster mass and fragment candidates | 0.957 |
| Convert solved contact impulses into chunk loads | 0.281 |
| Evaluate material damage and fracture | 0.139 |
| Commit changes and rebuild stress topology | 0.091 |
| GPU end-state copy for final splits (no time rewind) | 0.011 |
| GPU checkpoint restore (device-to-device copies) | 0.010 |
| GPU fragment motion installation before replay | 0.010 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split motion installation after replay | 0.004 |
| GPU final-split shape ownership after replay | 0.004 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Calls | Longest call ms | Union wall ms | Reported thread CPU ms |
|---|---:|---:|---:|---:|
| detail.preallocateContactManagers | 1 | 6.703 | 6.703 | 6.692 |
| detail.registerSceneInteractions | 1 | 6.560 | 6.560 | 6.561 |
| detail.postBroadPhase | 1 | 6.168 | 6.168 | 6.168 |
| detail.broadPhaseWait | 1 | 6.155 | 6.155 | 6.155 |
| detail.updateDynamics | 1 | 4.733 | 4.733 | 4.733 |
| detail.islandInsertion | 1 | 4.029 | 4.029 | 4.029 |
| detail.postBroadPhaseStage2 | 1 | 3.074 | 3.074 | 3.074 |
| detail.postNarrowPhase | 1 | 2.225 | 2.225 | 1.874 |
| detail.registerInteractions | 1 | 2.083 | 2.083 | 1.958 |
| task.afterIntegration | 2 | 0.330 | 0.583 | 0.583 |
| task.queryMembership | 1 | 0.579 | 0.579 | 0.579 |
| task.queryMembershipQueue | 4 | 0.213 | 0.507 | 0.507 |
| task.accurateIslandMaintenance | 2 | 0.239 | 0.459 | 0.459 |
| detail.islandGen | 1 | 0.413 | 0.413 | 0.409 |
| task.contactGraph | 2 | 0.343 | 0.394 | 0.358 |
| task.speculativeIslandMaintenance | 2 | 0.232 | 0.349 | 0.349 |
| detail.registerContactManagers | 1 | 0.258 | 0.258 | 0.258 |
| detail.updateDynamicsPostPartitioning | 1 | 0.230 | 0.230 | 0.230 |
| task.accurateIsland.findPathsAndBreakIslands | 2 | 0.174 | 0.220 | 0.220 |
| task.sleepCommit | 1 | 0.151 | 0.151 | 0.091 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
