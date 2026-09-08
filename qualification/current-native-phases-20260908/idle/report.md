# Native phases inside the Vibe-land consumer

**Diagnostic replay**, 256 buildings, 113,664 chunks, 229,376 bonds, 0 rounds over 600 steps / 10 simulated seconds. Direct GPU API off, sleep on, correction ≤1. This instrumented replay is separate from the untraced deadline result.

Peak tick **0**, complete advance **157.886 ms**: 0 fragments / 0 awake, 0 projectiles present, 0 reported normal-contact count, 0 cumulative broken bonds, 0 correction(s).

## Disjoint wall-time accounting

| Responsibility | Owner / meaning | Peak ms | Mean across 10 worst steps, ms |
|---|---|---:|---:|
| Other trial/game work | Trial physics, commands, game observations and remaining task/driver gaps | 153.580 | 15.661 |
| Wait for GPU destruction result | CPU blocked/spinning until required GPU work completes; not extra GPU work | 3.009 | 0.550 |
| Submit contact loads and destruction | CPU queues GPU loads, stress, material and topology work | 1.262 | 0.261 |
| Checkpoint moving-body state | CPU submission → GPU copy; save state for possible rewind | 0.029 | 0.014 |

Small rows omitted from display remain in the archived accounting. The complete partition sums to the profiler’s outer advance interval; its FFI/timestamp bookends slightly exceed the Rust timer.

## CUDA destruction stages at this peak

These durations overlap the wall table above. **Do not add them to it.** Each row sums the trial and corrected evaluation where present; device intervals are not hardware utilization counters.

| Stage | CUDA ms |
|---|---:|
| Iterative stress solve to convergence | 3.881 |
| Evaluate material damage and fracture | 0.096 |
| Commit changes and rebuild stress topology | 0.081 |
| Connectivity, cluster mass and fragment candidates | 0.072 |
| Convert solved contact impulses into chunk loads | 0.062 |

## Nested correction/task exposure

These scopes can nest or execute concurrently: **not additive**. Thread CPU time is core-time, not elapsed wall time. The refilter scope belongs to our correction orchestration; it is not ordinary PhysX workload.

| Scope | Union wall ms | Reported thread CPU ms |
|---|---:|---:|
| task.contactGraph | 0.086 | 0.087 |
| task.speculativeIslandMaintenance | 0.025 | 0.022 |
| task.accurateIslandMaintenance | 0.023 | 0.023 |
| task.activityCheckpoint | 0.004 | 0.004 |
| task.afterIntegration | 0.003 | 0.003 |
| task.cpuNarrowPhaseMerge | 0.002 | 0.002 |
| task.speculativeIsland.removeDestroyedConnections | 0.001 | 0.001 |
| task.speculativeIsland.boundaryAudit | 0.001 | 0.001 |
| task.speculativeIsland.findPathsAndBreakIslands | 0.001 | 0.001 |
| task.speculativeIsland.resetDirtyEdges | 0.001 | 0.001 |
| task.speculativeIsland.deactivation | 0.001 | 0.001 |
| task.speculativeIsland.removeEdgesFromIslands | 0.001 | 0.001 |
| task.speculativeIsland.clearDestroyedNodes | 0.001 | 0.001 |
| task.speculativeIsland.clearDestroyedEdges | 0.001 | 0.001 |
| task.bodyDmaWait | 0.001 | 0.001 |
| task.accurateIsland.findPathsAndBreakIslands | 0.001 | 0.001 |
| task.accurateIsland.deactivation | 0.001 | 0.001 |
| task.accurateIsland.resetDirtyEdges | 0.001 | 0.001 |
| task.accurateIsland.removeDestroyedConnections | 0.001 | 0.001 |
| task.accurateIsland.removeEdgesFromIslands | 0.001 | 0.001 |

[All phase partitions and CUDA intervals](analysis.json.gz). Raw host/device phase streams, accepted step samples and recorded commands are archived alongside the report. This analysis establishes cost exposure, not a promised saving or proof that a GPU kernel is bandwidth/compute bound.
