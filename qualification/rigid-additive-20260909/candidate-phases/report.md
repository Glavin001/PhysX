# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **157.138 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 31.694 | 38.757 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 23.436 | 20.340 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 59.341 | 19.517 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 13.937 | 3.004 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.628 | 2.357 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 10.090 | 1.801 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 3.849 | 0.812 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.769 | 0.725 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 2.219 | 0.455 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.471 | 0.426 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.909 | 0.387 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.380 | 0.367 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.299 | 0.292 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.301 | 0.263 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.142 | 0.158 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.621 | 0.131 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.515 | 0.112 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.052 | 0.075 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.091 | 0.066 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.094 | 0.045 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.034 | 0.043 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.036 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.189 | 0.022 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.031 | 0.018 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.015 | 0.017 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.015 | 0.014 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 30.465 |
| Connectivity, cluster mass and fragment candidates | 0.953 |
| Convert solved contact impulses into chunk loads | 0.278 |
| Evaluate material damage and fracture | 0.138 |
| Commit changes and rebuild stress topology | 0.094 |
| GPU checkpoint restore (device-to-device copies) | 0.012 |
| GPU end-state copy for final splits (no time rewind) | 0.012 |
| GPU fragment motion installation before replay | 0.009 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split shape ownership after replay | 0.005 |
| GPU final-split motion installation after replay | 0.004 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Calls | Longest call ms | Union wall ms | Reported thread CPU ms |
|---|---:|---:|---:|---:|
| detail.registerSceneInteractions | 1 | 8.254 | 8.254 | 8.255 |
| detail.preallocateContactManagers | 1 | 6.765 | 6.765 | 6.765 |
| detail.postBroadPhase | 1 | 6.177 | 6.177 | 6.177 |
| detail.broadPhaseWait | 1 | 6.164 | 6.164 | 6.164 |
| detail.islandInsertion | 1 | 5.974 | 5.974 | 5.974 |
| detail.updateDynamics | 1 | 4.316 | 4.316 | 4.316 |
| detail.postNarrowPhase | 1 | 3.796 | 3.796 | 3.430 |
| detail.registerInteractions | 1 | 3.158 | 3.158 | 3.109 |
| detail.postBroadPhaseStage2 | 1 | 2.219 | 2.219 | 2.216 |
| task.queryMembership | 1 | 0.551 | 0.551 | 0.551 |
| detail.registerContactManagers | 1 | 0.493 | 0.493 | 0.493 |
| task.afterIntegration | 2 | 0.378 | 0.475 | 0.475 |
| task.accurateIslandMaintenance | 2 | 0.284 | 0.471 | 0.471 |
| task.queryMembershipQueue | 4 | 0.242 | 0.414 | 0.414 |
| task.contactGraph | 2 | 0.307 | 0.362 | 0.339 |
| task.speculativeIslandMaintenance | 2 | 0.208 | 0.346 | 0.346 |
| detail.islandGen | 1 | 0.339 | 0.339 | 0.336 |
| task.accurateIsland.findPathsAndBreakIslands | 2 | 0.218 | 0.256 | 0.256 |
| task.sleepCommit | 1 | 0.156 | 0.156 | 0.100 |
| detail.updateDynamicsPostPartitioning | 1 | 0.151 | 0.151 | 0.151 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
