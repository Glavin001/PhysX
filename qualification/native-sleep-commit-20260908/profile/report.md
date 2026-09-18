# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **152.231 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 31.767 | 41.463 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 20.205 | 18.981 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 52.070 | 18.229 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 21.599 | 4.972 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.560 | 2.349 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 9.918 | 1.745 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 3.051 | 0.674 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.594 | 0.652 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.343 | 0.463 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.410 | 0.458 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.957 | 0.402 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.618 | 0.332 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.263 | 0.290 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.130 | 0.272 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.238 | 0.239 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.543 | 0.117 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.492 | 0.105 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.086 | 0.064 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.047 | 0.061 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.087 | 0.040 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.037 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.031 | 0.036 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.150 | 0.018 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.028 | 0.016 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.012 | 0.013 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.013 | 0.012 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 30.496 |
| Connectivity, cluster mass and fragment candidates | 0.955 |
| Convert solved contact impulses into chunk loads | 0.280 |
| Evaluate material damage and fracture | 0.137 |
| Commit changes and rebuild stress topology | 0.092 |
| GPU checkpoint restore (device-to-device copies) | 0.018 |
| GPU end-state copy for final splits (no time rewind) | 0.010 |
| GPU fragment motion installation before replay | 0.010 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split motion installation after replay | 0.003 |
| GPU final-split shape ownership after replay | 0.003 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Union wall ms | Reported thread CPU ms |
|---|---:|---:|
| detail.postBroadPhase | 6.168 | 6.168 |
| detail.broadPhaseWait | 6.155 | 6.155 |
| detail.registerSceneInteractions | 5.694 | 5.687 |
| detail.preallocateContactManagers | 5.590 | 5.590 |
| task.sleepCommit | 4.842 | 4.588 |
| detail.islandInsertion | 4.230 | 4.231 |
| detail.updateDynamics | 4.144 | 4.144 |
| detail.postNarrowPhase | 3.038 | 2.658 |
| detail.registerInteractions | 2.911 | 2.904 |
| detail.postBroadPhaseStage2 | 1.860 | 1.860 |
| task.afterIntegration | 0.584 | 0.584 |
| task.queryMembership | 0.583 | 0.583 |
| detail.registerContactManagers | 0.498 | 0.498 |
| detail.islandGen | 0.493 | 0.493 |
| task.queryMembershipQueue | 0.485 | 0.485 |
| task.accurateIslandMaintenance | 0.404 | 0.403 |
| task.contactGraph | 0.338 | 0.326 |
| task.speculativeIslandMaintenance | 0.315 | 0.305 |
| task.accurateIsland.findPathsAndBreakIslands | 0.209 | 0.209 |
| task.activityRestore | 0.148 | 0.149 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
