# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **144.025 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 31.867 | 42.262 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 21.240 | 19.432 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 55.150 | 19.335 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 10.766 | 2.564 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.582 | 2.349 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 9.054 | 1.670 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 3.091 | 0.698 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.311 | 0.647 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.413 | 0.414 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.352 | 0.402 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.716 | 0.370 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.329 | 0.306 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.256 | 0.290 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.227 | 0.239 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.185 | 0.167 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.495 | 0.119 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.498 | 0.107 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.050 | 0.061 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.080 | 0.057 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.067 | 0.036 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.011 | 0.036 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.031 | 0.035 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.189 | 0.023 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.037 | 0.019 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.012 | 0.014 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.011 | 0.011 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 30.606 |
| Connectivity, cluster mass and fragment candidates | 0.949 |
| Convert solved contact impulses into chunk loads | 0.274 |
| Evaluate material damage and fracture | 0.141 |
| Commit changes and rebuild stress topology | 0.093 |
| GPU checkpoint restore (device-to-device copies) | 0.015 |
| GPU end-state copy for final splits (no time rewind) | 0.011 |
| GPU fragment motion installation before replay | 0.010 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split shape ownership after replay | 0.004 |
| GPU final-split motion installation after replay | 0.003 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Calls | Longest call ms | Union wall ms | Reported thread CPU ms |
|---|---:|---:|---:|---:|
| detail.postBroadPhase | 1 | 6.161 | 6.161 | 6.161 |
| detail.broadPhaseWait | 1 | 6.149 | 6.149 | 6.149 |
| detail.preallocateContactManagers | 1 | 5.474 | 5.474 | 5.475 |
| detail.registerSceneInteractions | 1 | 4.885 | 4.885 | 4.885 |
| detail.updateDynamics | 1 | 4.369 | 4.369 | 4.369 |
| detail.islandInsertion | 1 | 3.864 | 3.864 | 3.859 |
| detail.postBroadPhaseStage2 | 1 | 3.396 | 3.396 | 3.388 |
| detail.registerInteractions | 1 | 2.828 | 2.828 | 2.817 |
| detail.postNarrowPhase | 1 | 2.577 | 2.577 | 2.200 |
| task.afterIntegration | 2 | 0.579 | 0.801 | 0.801 |
| task.queryMembership | 1 | 0.585 | 0.585 | 0.585 |
| detail.islandGen | 1 | 0.543 | 0.543 | 0.543 |
| detail.registerContactManagers | 1 | 0.496 | 0.496 | 0.496 |
| task.queryMembershipQueue | 4 | 0.210 | 0.448 | 0.449 |
| task.accurateIslandMaintenance | 2 | 0.269 | 0.419 | 0.419 |
| task.bodyDmaWait | 2 | 0.254 | 0.328 | 0.328 |
| task.contactGraph | 2 | 0.279 | 0.324 | 0.275 |
| task.speculativeIslandMaintenance | 2 | 0.175 | 0.310 | 0.310 |
| task.sleepCommit | 1 | 0.247 | 0.247 | 0.083 |
| task.accurateIsland.findPathsAndBreakIslands | 2 | 0.192 | 0.222 | 0.222 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
