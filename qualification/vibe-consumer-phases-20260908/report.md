# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 768 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak tick **128**, complete advance **191.094 ms**: 16,487 fragments / 14,240 awake, 256 projectiles present, 407,641 reported normal-contact count, 72,319 cumulative broken bonds, 1 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Resimulate changed interaction | CPU task scheduling + GPU collision, constraints and motion solve | 104.815 | 99.776 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 53.624 | 53.471 |
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 28.669 | 27.699 |
| Accept corrected step | GPU commit/status completion and CPU publication | 2.394 | 2.422 |
| Observe initialization/collision/correction verdicts | GPU → CPU combined validation status at the remaining ownership bridge; includes completion wait | 0.378 | 0.356 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 0.301 | 0.326 |
| Other ownership bridge work | GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping | 0.319 | 0.231 |
| Assign GPU motion slots and observe compatibility requests | GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency | 0.215 | 0.179 |
| Create compatibility records for selected fragments | CPU PhysX body/lifecycle records at GPU-selected indices | 0.055 | 0.128 |
| Rewind and install fractured motion | CPU dispatch + GPU checkpoint restore and owner installation | 0.064 | 0.059 |
| Retire old-owner contact managers | CPU releases shape interactions, contact managers and lost-touch bookkeeping | 0.024 | 0.054 |
| Prepare chunk collision ownership | CPU dispatch + GPU persistent-shape ownership preparation | 0.056 | 0.054 |
| Submit fragment initialization | CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback | 0.039 | 0.039 |
| Prepare corrected motion states | CPU dispatch + GPU cluster/body preparation | 0.036 | 0.035 |
| Other shape migration work | CPU validation, target storage and gaps around instrumented migration operations | 0.016 | 0.031 |
| Other destruction completion bookkeeping | Remaining host scope around destruction completion | 0.021 | 0.020 |
| Update persistent query-owner observation | CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist | 0.007 | 0.015 |
| Validate fragment owners and shape identities | CPU validates the migration batch against compatibility actors and persistent shapes | 0.008 | 0.012 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.015 | 0.012 |
| Validate compatibility registration | CPU dispatch → GPU failure merge; preserves device allocation verdict | 0.012 | 0.012 |
| Update narrow-phase ownership mirror | CPU updates persistent narrow-phase owner references; no geometry upload | 0.005 | 0.011 |
| Other reservation bookkeeping | Uninstrumented remainder within CPU reservation scope | 0.011 | 0.010 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 52.047 |
| Connectivity, cluster mass and fragment candidates | 1.085 |
| Convert solved contact impulses into chunk loads | 0.436 |
| Evaluate material damage and fracture | 0.135 |
| Commit changes and rebuild stress topology | 0.079 |
| GPU checkpoint restore (device-to-device copies) | 0.015 |
| GPU end-state copy for final splits (no time rewind) | 0.014 |
| GPU shape ownership installation before replay | 0.004 |
| GPU final-split motion installation after replay | 0.003 |
| GPU fragment motion installation before replay | 0.003 |
| GPU final-split shape ownership after replay | 0.003 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Union wall ms | Reported thread CPU ms |
|---|---:|---:|
| refilter | 30.086 | 30.079 |
| detail.updateDynamics | 11.098 | 11.098 |
| detail.islandInsertion | 10.959 | 10.959 |
| detail.preallocateContactManagers | 7.231 | 7.232 |
| detail.registerContactManagers | 7.162 | 7.155 |
| detail.postNarrowPhase | 6.443 | 6.009 |
| detail.registerSceneInteractions | 6.046 | 6.046 |
| detail.registerInteractions | 4.397 | 4.398 |
| task.speculativeIslandMaintenance | 4.066 | 4.066 |
| task.speculativeIsland.findPathsAndBreakIslands | 3.421 | 3.422 |
| task.accurateIslandMaintenance | 3.385 | 3.385 |
| task.accurateIsland.findPathsAndBreakIslands | 2.664 | 2.664 |
| detail.postBroadPhase | 2.225 | 2.225 |
| detail.broadPhaseWait | 2.202 | 2.202 |
| task.activityRestore | 0.909 | 0.909 |
| task.sleepCommit | 0.611 | 0.231 |
| task.activityCheckpoint | 0.557 | 0.557 |
| detail.islandGen | 0.420 | 0.417 |
| task.bodyStatusWork | 0.367 | 1.213 |
| task.accurateIsland.deactivation | 0.327 | 0.328 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
