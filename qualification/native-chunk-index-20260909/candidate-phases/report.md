# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **143.295 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 33.579 | 42.276 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 56.382 | 19.549 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 20.294 | 19.336 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 9.555 | 2.500 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.632 | 2.471 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 7.677 | 1.585 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 3.251 | 0.720 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.291 | 0.654 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.198 | 0.400 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.890 | 0.385 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.374 | 0.358 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.302 | 0.307 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.265 | 0.292 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.088 | 0.232 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.123 | 0.135 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.476 | 0.117 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.506 | 0.109 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.081 | 0.065 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.045 | 0.061 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.067 | 0.038 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.006 | 0.037 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.031 | 0.036 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.020 | 0.018 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.130 | 0.017 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.014 | 0.016 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.011 | 0.012 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 32.313 |
| Connectivity, cluster mass and fragment candidates | 0.956 |
| Convert solved contact impulses into chunk loads | 0.271 |
| Evaluate material damage and fracture | 0.140 |
| Commit changes and rebuild stress topology | 0.097 |
| GPU checkpoint restore (device-to-device copies) | 0.014 |
| GPU fragment motion installation before replay | 0.011 |
| GPU end-state copy for final splits (no time rewind) | 0.011 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split motion installation after replay | 0.004 |
| GPU final-split shape ownership after replay | 0.003 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Calls | Longest call ms | Union wall ms | Reported thread CPU ms |
|---|---:|---:|---:|---:|
| detail.postBroadPhase | 1 | 6.159 | 6.159 | 6.159 |
| detail.broadPhaseWait | 1 | 6.148 | 6.148 | 6.148 |
| detail.islandInsertion | 1 | 6.092 | 6.092 | 6.085 |
| detail.registerSceneInteractions | 1 | 5.907 | 5.907 | 5.876 |
| detail.preallocateContactManagers | 1 | 5.393 | 5.393 | 5.384 |
| detail.updateDynamics | 1 | 5.053 | 5.053 | 5.053 |
| detail.postBroadPhaseStage2 | 1 | 3.404 | 3.404 | 3.391 |
| detail.registerInteractions | 1 | 2.961 | 2.961 | 2.808 |
| detail.postNarrowPhase | 1 | 2.485 | 2.485 | 2.124 |
| task.queryMembership | 1 | 0.530 | 0.530 | 0.530 |
| task.afterIntegration | 2 | 0.370 | 0.512 | 0.478 |
| detail.islandGen | 1 | 0.511 | 0.511 | 0.509 |
| task.accurateIslandMaintenance | 2 | 0.285 | 0.429 | 0.429 |
| task.queryMembershipQueue | 4 | 0.238 | 0.425 | 0.401 |
| task.contactGraph | 2 | 0.289 | 0.333 | 0.319 |
| detail.registerContactManagers | 1 | 0.328 | 0.328 | 0.328 |
| task.speculativeIslandMaintenance | 2 | 0.174 | 0.300 | 0.300 |
| task.accurateIsland.findPathsAndBreakIslands | 2 | 0.202 | 0.230 | 0.230 |
| detail.updateDynamicsPostPartitioning | 1 | 0.152 | 0.152 | 0.152 |
| task.sleepCommit | 1 | 0.144 | 0.144 | 0.084 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
