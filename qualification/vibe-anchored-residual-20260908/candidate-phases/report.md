# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **158.263 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 34.981 | 48.077 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 22.237 | 29.771 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 58.561 | 17.286 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 19.449 | 3.605 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.573 | 2.428 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 7.278 | 1.064 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.337 | 0.620 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 2.970 | 0.538 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.557 | 0.531 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.230 | 0.376 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.838 | 0.328 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.145 | 0.322 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.247 | 0.274 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.312 | 0.232 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.124 | 0.189 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.482 | 0.091 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.501 | 0.084 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.085 | 0.059 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.045 | 0.047 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.009 | 0.037 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.065 | 0.034 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.031 | 0.032 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.150 | 0.015 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.013 | 0.014 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.023 | 0.012 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.012 | 0.011 |
| Invalidate incompatible contact caches | CPU dispatch + GPU contact/friction cache reset | 0.011 | 0.006 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 33.728 |
| Connectivity, cluster mass and fragment candidates | 0.948 |
| Convert solved contact impulses into chunk loads | 0.281 |
| Evaluate material damage and fracture | 0.139 |
| Commit changes and rebuild stress topology | 0.082 |
| GPU checkpoint restore (device-to-device copies) | 0.018 |
| GPU end-state copy for final splits (no time rewind) | 0.011 |
| GPU fragment motion installation before replay | 0.010 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split motion installation after replay | 0.004 |
| GPU final-split shape ownership after replay | 0.004 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Union wall ms | Reported thread CPU ms |
|---|---:|---:|
| detail.preallocateContactManagers | 8.268 | 7.618 |
| detail.postBroadPhase | 6.128 | 6.112 |
| detail.broadPhaseWait | 6.089 | 6.090 |
| detail.islandInsertion | 5.965 | 5.959 |
| detail.registerSceneInteractions | 5.335 | 5.330 |
| task.sleepCommit | 4.862 | 4.565 |
| detail.updateDynamics | 4.597 | 4.597 |
| detail.postBroadPhaseStage2 | 2.509 | 2.509 |
| detail.postNarrowPhase | 2.478 | 2.096 |
| detail.registerInteractions | 1.931 | 1.931 |
| task.afterIntegration | 0.769 | 0.769 |
| task.queryMembership | 0.595 | 0.595 |
| detail.islandGen | 0.521 | 0.521 |
| task.queryMembershipQueue | 0.415 | 0.415 |
| task.accurateIslandMaintenance | 0.414 | 0.414 |
| task.contactGraph | 0.394 | 0.365 |
| task.bodyDmaWait | 0.332 | 0.332 |
| task.speculativeIslandMaintenance | 0.320 | 0.319 |
| detail.registerContactManagers | 0.302 | 0.302 |
| task.accurateIsland.findPathsAndBreakIslands | 0.220 | 0.220 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
