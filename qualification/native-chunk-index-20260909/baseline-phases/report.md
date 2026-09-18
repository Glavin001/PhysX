# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **48**, complete advance **142.946 ms**: 10,449 fragments / 10,193 awake, 256 projectiles present, 216,220 reported normal-contact count, 57,788 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 32.255 | 42.416 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 53.663 | 19.094 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 20.882 | 18.798 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 10.786 | 2.535 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.626 | 2.389 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 9.220 | 1.659 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 3.153 | 0.715 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 2.386 | 0.661 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 1.802 | 0.406 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.421 | 0.404 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 1.291 | 0.396 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 1.340 | 0.308 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.274 | 0.303 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.152 | 0.300 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 1.209 | 0.250 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.485 | 0.118 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.511 | 0.111 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.045 | 0.066 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.080 | 0.059 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.070 | 0.038 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.031 | 0.037 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.008 | 0.036 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.076 | 0.021 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.145 | 0.017 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.015 | 0.015 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.011 | 0.012 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 31.004 |
| Connectivity, cluster mass and fragment candidates | 0.952 |
| Convert solved contact impulses into chunk loads | 0.279 |
| Evaluate material damage and fracture | 0.140 |
| Commit changes and rebuild stress topology | 0.093 |
| GPU checkpoint restore (device-to-device copies) | 0.014 |
| GPU end-state copy for final splits (no time rewind) | 0.011 |
| GPU fragment motion installation before replay | 0.010 |
| GPU shape ownership installation before replay | 0.006 |
| GPU final-split motion installation after replay | 0.004 |
| GPU final-split shape ownership after replay | 0.003 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Calls | Longest call ms | Union wall ms | Reported thread CPU ms |
|---|---:|---:|---:|---:|
| detail.preallocateContactManagers | 1 | 7.167 | 7.167 | 7.160 |
| detail.registerSceneInteractions | 1 | 6.200 | 6.200 | 6.158 |
| detail.postBroadPhase | 1 | 6.176 | 6.176 | 6.176 |
| detail.broadPhaseWait | 1 | 6.164 | 6.164 | 6.164 |
| detail.updateDynamics | 1 | 4.987 | 4.987 | 4.987 |
| detail.islandInsertion | 1 | 4.279 | 4.279 | 4.275 |
| detail.registerInteractions | 1 | 2.987 | 2.987 | 2.828 |
| detail.postNarrowPhase | 1 | 2.351 | 2.351 | 1.956 |
| detail.postBroadPhaseStage2 | 1 | 2.111 | 2.111 | 2.071 |
| task.queryMembership | 1 | 0.523 | 0.523 | 0.523 |
| task.afterIntegration | 2 | 0.335 | 0.465 | 0.464 |
| task.accurateIslandMaintenance | 2 | 0.262 | 0.419 | 0.419 |
| task.queryMembershipQueue | 4 | 0.222 | 0.383 | 0.383 |
| task.contactGraph | 2 | 0.333 | 0.378 | 0.350 |
| detail.islandGen | 1 | 0.319 | 0.319 | 0.319 |
| task.speculativeIslandMaintenance | 2 | 0.185 | 0.298 | 0.298 |
| detail.registerContactManagers | 1 | 0.271 | 0.271 | 0.271 |
| task.accurateIsland.findPathsAndBreakIslands | 2 | 0.188 | 0.218 | 0.218 |
| task.sleepCommit | 1 | 0.143 | 0.143 | 0.092 |
| task.activityRestore | 1 | 0.142 | 0.142 | 0.143 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
