# Native destruction timing report

Capture: `out/recordings/native-gpu-support-large-20260906`. 1,800 accepted steps; 385 steps used one resimulation.

These are host-wall timings including GPU waits, measured with profiling and audits on a shared GPU. They are not isolated CUDA kernel timings or a whole-game performance qualification.

| Complete step | Minimum ms | Average ms | Maximum ms | p95 ms |
| --- | ---: | ---: | ---: | ---: |
| Simulation/destruction | 1.027 | 226.148 | 1616.300 | 620.564 |
| Capture tick including observation and I/O | 6.920 | 244.172 | 1640.270 | 642.344 |

Simulation speed: **0.074x real time** (4.42 steps/s). 1,706/1,800 steps exceeded 16.667 ms.

## Outer simulation intervals

This table averages over **all** accepted steps, counting absent correction phases as zero. These selected outer intervals plus the residual reconcile to the complete simulation step. The residual contains ordinary physics, checkpointing, nested tasks and other work; it is not a measurement of one GPU kernel.

| Interval | Average ms per accepted step |
| --- | ---: |
| Submit contact loads, motion inputs and destruction work (`submit`) | 0.264 |
| Wait for destruction completion and reserve bodies (`finishAndReserve`) | 2.682 |
| Prepare collision ownership bindings (`collisionBindings`) | 0.016 |
| Prepare bodies for correction (`correctionBodies`) | 0.041 |
| Initialize reserved body state (`initializeReserved`) | 0.014 |
| Apply changed collision ownership (`applyBindings`) | 0.159 |
| Restore/install provisional motion (`restoreInstall`) | 0.005 |
| Reset affected contact caches (`resetContactCaches`) | 0.003 |
| Correction collision/solve (including refilter) (`correctedCollisionSolve`) | 17.325 |
| Accept corrected state (`acceptCorrection`) | 0.079 |
| Ordinary physics/checkpoint/other residual | 205.559 |
| **Complete simulation step** | **226.148** |

## Every recorded phase/task

**Do not add this table:** parent/child scopes and parallel tasks overlap. The active-step columns summarize only steps where that scope appeared. The all-step average counts absent scopes as zero. `task.*` values sum invocations within each accepted step across trial and correction. `trialDetail.*` is the ordinary pass; `detail.*` is inside correction. `refilter` is included in `correctedCollisionSolve`.

| Scope | Active steps | Active-step min ms | Active-step avg ms | Active-step max ms | All-step avg ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| `acceptCorrection` | 385 | 0.260 | 0.372 | 1.432 | 0.079 |
| `applyBindings` | 385 | 0.106 | 0.745 | 2.360 | 0.159 |
| `collisionBindings` | 1,800 | 0.000 | 0.016 | 0.806 | 0.016 |
| `correctedCollisionSolve` | 385 | 4.964 | 80.998 | 559.334 | 17.325 |
| `correctionBodies` | 1,800 | 0.000 | 0.041 | 0.736 | 0.041 |
| `detail.beforeSolver` | 385 | 0.001 | 0.002 | 0.008 | 0.001 |
| `detail.islandGen` | 385 | 0.005 | 0.525 | 8.732 | 0.112 |
| `detail.islandInsertion` | 385 | 0.043 | 1.467 | 5.382 | 0.314 |
| `detail.postBroadPhase` | 385 | 0.924 | 17.842 | 94.356 | 3.816 |
| `detail.postBroadPhaseStage2` | 385 | 0.037 | 0.324 | 1.939 | 0.069 |
| `detail.postBroadPhaseStage3` | 385 | 0.000 | 0.000 | 0.001 | 0.000 |
| `detail.postIslandGen` | 385 | 0.000 | 0.001 | 0.003 | 0.000 |
| `detail.postNarrowPhase` | 385 | 0.161 | 2.037 | 16.163 | 0.436 |
| `detail.postSolver` | 385 | 0.001 | 0.002 | 0.006 | 0.000 |
| `detail.preallocateContactManagers` | 385 | 0.006 | 0.552 | 1.681 | 0.118 |
| `detail.processLostContacts` | 385 | 0.000 | 0.005 | 0.498 | 0.001 |
| `detail.processLostContacts2` | 385 | 0.000 | 2.002 | 24.472 | 0.428 |
| `detail.processLostContacts3` | 385 | 0.000 | 2.964 | 50.905 | 0.634 |
| `detail.registerContactManagers` | 385 | 0.002 | 0.205 | 1.045 | 0.044 |
| `detail.registerInteractions` | 385 | 0.005 | 0.371 | 1.506 | 0.079 |
| `detail.registerSceneInteractions` | 385 | 0.009 | 0.574 | 2.009 | 0.123 |
| `detail.updateDynamics` | 385 | 0.049 | 0.885 | 41.506 | 0.189 |
| `detail.updateDynamicsPostPartitioning` | 385 | 0.115 | 0.563 | 1.790 | 0.120 |
| `finishAndReserve` | 1,800 | 0.061 | 2.682 | 36.331 | 2.682 |
| `initializeReserved` | 385 | 0.038 | 0.067 | 1.228 | 0.014 |
| `refilter` | 385 | 0.776 | 1.452 | 3.659 | 0.311 |
| `resetContactCaches` | 385 | 0.006 | 0.015 | 0.071 | 0.003 |
| `restoreInstall` | 385 | 0.016 | 0.025 | 0.075 | 0.005 |
| `submit` | 1,800 | 0.135 | 0.264 | 1.537 | 0.264 |
| `task.accurateIsland.boundaryAudit` | 1,800 | 0.000 | 34.574 | 98.423 | 34.574 |
| `task.accurateIsland.clearDestroyedEdges` | 1,800 | 0.000 | 5.741 | 73.938 | 5.741 |
| `task.accurateIsland.clearDestroyedNodes` | 1,800 | 0.000 | 0.000 | 0.008 | 0.000 |
| `task.accurateIsland.deactivation` | 1,800 | 0.000 | 1.616 | 170.312 | 1.616 |
| `task.accurateIsland.findPathsAndBreakIslands` | 1,800 | 0.000 | 2.726 | 46.390 | 2.726 |
| `task.accurateIsland.removeDestroyedConnections` | 1,800 | 0.000 | 4.940 | 57.885 | 4.940 |
| `task.accurateIsland.removeEdgesFromIslands` | 1,800 | 0.000 | 4.771 | 57.896 | 4.771 |
| `task.accurateIsland.resetDirtyEdges` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.accurateIslandMaintenance` | 1,800 | 0.001 | 54.378 | 271.829 | 54.378 |
| `task.contactGraph` | 1,800 | 0.000 | 0.003 | 0.014 | 0.003 |
| `task.prepareIslandRepair` | 1,800 | 0.013 | 2.188 | 9.459 | 2.188 |
| `task.speculativeIsland.boundaryAudit` | 1,800 | 0.000 | 51.978 | 162.930 | 51.978 |
| `task.speculativeIsland.clearDestroyedEdges` | 1,800 | 0.000 | 4.844 | 67.801 | 4.844 |
| `task.speculativeIsland.clearDestroyedNodes` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.speculativeIsland.deactivation` | 1,800 | 0.000 | 1.986 | 50.167 | 1.986 |
| `task.speculativeIsland.findPathsAndBreakIslands` | 1,800 | 0.000 | 2.730 | 107.982 | 2.730 |
| `task.speculativeIsland.removeDestroyedConnections` | 1,800 | 0.000 | 4.967 | 56.650 | 4.967 |
| `task.speculativeIsland.removeEdgesFromIslands` | 1,800 | 0.000 | 5.038 | 55.983 | 5.038 |
| `task.speculativeIsland.resetDirtyEdges` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.speculativeIslandMaintenance` | 1,800 | 0.001 | 71.551 | 333.912 | 71.551 |
| `trialDetail.beforeSolver` | 1,800 | 0.000 | 0.004 | 0.015 | 0.004 |
| `trialDetail.islandGen` | 1,800 | 0.001 | 1.932 | 11.633 | 1.932 |
| `trialDetail.islandInsertion` | 1,800 | 0.001 | 12.945 | 100.067 | 12.945 |
| `trialDetail.postBroadPhase` | 1,800 | 0.155 | 24.289 | 92.397 | 24.289 |
| `trialDetail.postBroadPhaseStage2` | 1,800 | 0.000 | 0.646 | 5.603 | 0.646 |
| `trialDetail.postBroadPhaseStage3` | 1,800 | 0.000 | 0.000 | 0.003 | 0.000 |
| `trialDetail.postIslandGen` | 1,800 | 0.000 | 0.001 | 0.005 | 0.001 |
| `trialDetail.postNarrowPhase` | 1,800 | 0.009 | 7.804 | 55.648 | 7.804 |
| `trialDetail.postSolver` | 1,800 | 0.000 | 0.002 | 0.014 | 0.002 |
| `trialDetail.preallocateContactManagers` | 1,800 | 0.000 | 6.617 | 45.947 | 6.617 |
| `trialDetail.processLostContacts` | 1,800 | 0.000 | 0.006 | 2.915 | 0.006 |
| `trialDetail.processLostContacts2` | 1,800 | 0.000 | 3.710 | 37.650 | 3.710 |
| `trialDetail.processLostContacts3` | 1,800 | 0.000 | 6.871 | 51.430 | 6.871 |
| `trialDetail.registerContactManagers` | 1,718 | 0.001 | 7.416 | 55.037 | 7.078 |
| `trialDetail.registerInteractions` | 1,718 | 0.002 | 6.115 | 42.822 | 5.836 |
| `trialDetail.registerSceneInteractions` | 1,718 | 0.002 | 8.519 | 76.909 | 8.130 |
| `trialDetail.updateDynamics` | 1,800 | 0.010 | 7.011 | 58.577 | 7.011 |
| `trialDetail.updateDynamicsPostPartitioning` | 1,800 | 0.033 | 0.790 | 2.934 | 0.790 |

Pure CUDA stress, topology, broadphase, narrowphase and rigid-solver kernel durations are not separately isolated in this capture. In particular, the short `task.contactGraph` host scope is not the GPU graph-computation duration, and `finishAndReserve` is not pure stress time.
