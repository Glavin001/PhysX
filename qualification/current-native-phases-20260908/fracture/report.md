# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **151.620 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 32.180 | 42.189 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 20.791 | 19.341 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 52.336 | 18.660 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 21.146 | 4.836 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.572 | 2.358 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 9.257 | 1.696 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 2.926 | 0.669 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.446 | 0.653 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.269 | 0.451 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.773 | 0.370 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.428 | 0.362 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.354 | 0.317 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.299 | 0.294 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.225 | 0.246 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.135 | 0.138 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.519 | 0.116 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.506 | 0.110 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.087 | 0.063 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.045 | 0.061 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.066 | 0.038 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.030 | 0.036 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.035 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.165 | 0.019 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.016 | 0.015 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.020 | 0.015 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.012 | 0.012 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.010 | 0.006 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 30.929 |
| Connectivity, cluster mass and fragment candidates | 0.956 |
| Convert solved contact impulses into chunk loads | 0.284 |
| Evaluate material damage and fracture | 0.140 |
| Commit changes and rebuild stress topology | 0.091 |
| GPU checkpoint restore (device-to-device copies) | 0.019 |
| GPU end-state copy for final splits (no time rewind) | 0.011 |
| GPU fragment motion installation before replay | 0.011 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split motion installation after replay | 0.004 |
| GPU final-split shape ownership after replay | 0.003 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Union wall ms | Reported thread CPU ms |
|---|---:|---:|
| detail.preallocateContactManagers | 7.794 | 7.786 |
| detail.postBroadPhase | 6.187 | 6.187 |
| detail.broadPhaseWait | 6.173 | 6.173 |
| detail.registerSceneInteractions | 5.473 | 5.473 |
| task.sleepCommit | 4.929 | 4.614 |
| detail.updateDynamics | 4.740 | 4.740 |
| detail.islandInsertion | 3.795 | 3.789 |
| detail.postNarrowPhase | 2.281 | 1.910 |
| detail.postBroadPhaseStage2 | 1.978 | 1.979 |
| detail.registerInteractions | 1.924 | 1.924 |
| task.afterIntegration | 0.863 | 0.859 |
| task.queryMembership | 0.580 | 0.580 |
| detail.registerContactManagers | 0.526 | 0.523 |
| task.queryMembershipQueue | 0.518 | 0.513 |
| task.accurateIslandMaintenance | 0.406 | 0.406 |
| task.contactGraph | 0.345 | 0.317 |
| task.bodyDmaWait | 0.325 | 0.325 |
| task.speculativeIslandMaintenance | 0.315 | 0.315 |
| detail.islandGen | 0.296 | 0.296 |
| task.accurateIsland.findPathsAndBreakIslands | 0.202 | 0.203 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
