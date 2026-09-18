# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak tick **0**, complete advance **158.558 ms**: 0 fragments / 0 awake, 0 projectiles present, 0 reported normal-contact count, 0 cumulative broken bonds, 0 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 3.198 | 37.304 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 154.321 | 34.807 |
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 0.000 | 20.038 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.000 | 2.701 |
| Accept corrected step | GPU commit/status completion and CPU publication | 0.000 | 2.207 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.000 | 1.730 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.000 | 0.755 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.000 | 0.749 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.000 | 0.436 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.000 | 0.420 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 1.004 | 0.402 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.000 | 0.341 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.001 | 0.315 |
| Update shape/actor links and query-bound membership | CPU transfers element ownership and registers query-bound tracking | 0.000 | 0.256 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.000 | 0.162 |
| Activate fragment scheduler metadata | CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned | 0.000 | 0.119 |
| Mark changed collision filtering | CPU broad-phase lifecycle bookkeeping for migrating persistent shapes | 0.000 | 0.110 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.001 | 0.071 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.000 | 0.065 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.000 | 0.048 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.029 | 0.040 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.001 | 0.037 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.002 | 0.022 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.007 | 0.021 |
| Grow native motion address capacity | CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies | 0.000 | 0.019 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.000 | 0.014 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 3.825 |
| Evaluate material damage and fracture | 0.097 |
| Commit changes and rebuild stress topology | 0.084 |
| Connectivity, cluster mass and fragment candidates | 0.075 |
| Convert solved contact impulses into chunk loads | 0.055 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Calls | Longest call ms | Union wall ms | Reported thread CPU ms |
|---|---:|---:|---:|---:|
| task.contactGraph | 1 | 0.062 | 0.062 | 0.062 |
| task.speculativeIslandMaintenance | 1 | 0.038 | 0.038 | 0.021 |
| task.accurateIslandMaintenance | 1 | 0.035 | 0.035 | 0.035 |
| task.activityCheckpoint | 1 | 0.004 | 0.004 | 0.004 |
| task.afterIntegration | 1 | 0.004 | 0.004 | 0.003 |
| task.cpuNarrowPhaseMerge | 1 | 0.002 | 0.002 | 0.002 |
| task.accurateIsland.boundaryAudit | 1 | 0.001 | 0.001 | 0.001 |
| task.accurateIsland.resetDirtyEdges | 1 | 0.001 | 0.001 | 0.001 |
| task.speculativeIsland.boundaryAudit | 1 | 0.001 | 0.001 | 0.001 |
| task.speculativeIsland.resetDirtyEdges | 1 | 0.001 | 0.001 | 0.001 |
| task.accurateIsland.removeDestroyedConnections | 1 | 0.001 | 0.001 | 0.001 |
| task.speculativeIsland.findPathsAndBreakIslands | 1 | 0.001 | 0.001 | 0.001 |
| task.accurateIsland.deactivation | 1 | 0.001 | 0.001 | 0.001 |
| task.speculativeIsland.deactivation | 1 | 0.001 | 0.001 | 0.001 |
| task.accurateIsland.findPathsAndBreakIslands | 1 | 0.001 | 0.001 | 0.001 |
| task.accurateIsland.clearDestroyedEdges | 1 | 0.001 | 0.001 | 0.001 |
| task.bodyDmaWait | 1 | 0.001 | 0.001 | 0.001 |
| task.speculativeIsland.removeDestroyedConnections | 1 | 0.001 | 0.001 | 0.001 |
| task.speculativeIsland.clearDestroyedEdges | 1 | 0.001 | 0.001 | 0.001 |
| task.accurateIsland.clearDestroyedNodes | 1 | 0.001 | 0.001 | 0.001 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
