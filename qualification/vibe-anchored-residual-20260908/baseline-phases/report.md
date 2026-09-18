# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **167.931 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 37.221 | 47.704 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 21.776 | 28.286 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 55.673 | 19.791 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 24.407 | 5.283 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.541 | 2.418 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 11.262 | 1.835 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 3.432 | 0.723 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.755 | 0.665 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.434 | 0.435 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.397 | 0.424 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 2.062 | 0.408 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.551 | 0.319 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.268 | 0.280 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.367 | 0.252 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.156 | 0.152 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.570 | 0.123 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.558 | 0.115 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.100 | 0.061 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.051 | 0.052 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.092 | 0.041 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.037 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.033 | 0.036 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.147 | 0.018 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.026 | 0.016 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.018 | 0.015 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.015 | 0.012 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.012 | 0.006 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 35.978 |
| Connectivity, cluster mass and fragment candidates | 0.951 |
| Convert solved contact impulses into chunk loads | 0.278 |
| Evaluate material damage and fracture | 0.139 |
| Commit changes and rebuild stress topology | 0.082 |
| GPU checkpoint restore (device-to-device copies) | 0.019 |
| GPU end-state copy for final splits (no time rewind) | 0.013 |
| GPU fragment motion installation before replay | 0.010 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split motion installation after replay | 0.006 |
| GPU final-split shape ownership after replay | 0.003 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Union wall ms | Reported thread CPU ms |
|---|---:|---:|
| detail.postBroadPhase | 6.150 | 6.150 |
| detail.broadPhaseWait | 6.136 | 6.136 |
| detail.registerSceneInteractions | 6.060 | 6.060 |
| task.sleepCommit | 5.609 | 5.283 |
| detail.preallocateContactManagers | 5.568 | 5.568 |
| detail.islandInsertion | 4.633 | 4.633 |
| detail.updateDynamics | 4.185 | 4.185 |
| detail.postBroadPhaseStage2 | 3.387 | 3.373 |
| detail.postNarrowPhase | 2.511 | 2.148 |
| detail.registerInteractions | 1.962 | 1.928 |
| task.queryMembership | 0.622 | 0.622 |
| task.afterIntegration | 0.591 | 0.591 |
| detail.registerContactManagers | 0.506 | 0.507 |
| task.accurateIslandMaintenance | 0.438 | 0.432 |
| task.queryMembershipQueue | 0.424 | 0.424 |
| task.contactGraph | 0.410 | 0.382 |
| detail.islandGen | 0.331 | 0.331 |
| task.speculativeIslandMaintenance | 0.299 | 0.299 |
| task.accurateIsland.findPathsAndBreakIslands | 0.253 | 0.247 |
| task.activityRestore | 0.163 | 0.163 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
