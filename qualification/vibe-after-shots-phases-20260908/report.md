# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 27 buildings, 24,105 chunks, 74,543 bonds, 3 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak fracture tick **199**, complete advance **726.794 ms**: 29 fragments / 25 awake, 2 projectiles present, 283 reported normal-contact count, 469 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 194.262 | 220.006 |
| Accept corrected step | GPU commit/status completion and CPU publication | 257.893 | 215.412 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 268.835 | 89.614 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 1.500 | 1.248 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 1.793 | 0.710 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.213 | 0.197 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.504 | 0.183 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.484 | 0.153 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.181 | 0.104 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.153 | 0.104 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.208 | 0.103 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.209 | 0.072 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.157 | 0.056 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.043 | 0.049 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.101 | 0.047 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.098 | 0.036 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.026 | 0.031 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.042 | 0.030 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.017 | 0.022 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.025 | 0.021 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.014 | 0.013 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.011 | 0.010 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 193.649 |
| Connectivity, cluster mass and fragment candidates | 0.598 |
| Commit changes and rebuild stress topology | 0.065 |
| Evaluate material damage and fracture | 0.058 |
| Convert solved contact impulses into chunk loads | 0.055 |
| GPU end-state copy for final splits (no time rewind) | 0.007 |
| GPU checkpoint restore (device-to-device copies) | 0.005 |
| GPU final-split motion installation after replay | 0.005 |
| GPU shape ownership installation before replay | 0.004 |
| GPU final-split shape ownership after replay | 0.004 |
| GPU fragment motion installation before replay | 0.004 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Union wall ms | Reported thread CPU ms |
|---|---:|---:|
| detail.postBroadPhase | 0.193 | 0.193 |
| detail.broadPhaseWait | 0.183 | 0.183 |
| task.afterIntegration | 0.181 | 0.181 |
| task.bodyDmaWait | 0.153 | 0.153 |
| detail.postNarrowPhase | 0.129 | 0.086 |
| detail.updateDynamicsPostPartitioning | 0.045 | 0.045 |
| task.contactGraph | 0.041 | 0.042 |
| task.speculativeIslandMaintenance | 0.035 | 0.035 |
| task.accurateIslandMaintenance | 0.034 | 0.034 |
| task.queryMembershipQueue | 0.016 | 0.016 |
| detail.updateDynamics | 0.010 | 0.010 |
| task.queryMembership | 0.010 | 0.010 |
| task.sleepCommit | 0.004 | 0.004 |
| detail.islandGen | 0.003 | 0.003 |
| task.bodyStatusWork | 0.003 | 0.003 |
| task.cpuNarrowPhaseMerge | 0.003 | 0.003 |
| refilter | 0.002 | 0.002 |
| task.accurateIsland.findPathsAndBreakIslands | 0.002 | 0.002 |
| task.speculativeIsland.removeDestroyedConnections | 0.002 | 0.002 |
| task.speculativeIsland.deactivation | 0.002 | 0.002 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
