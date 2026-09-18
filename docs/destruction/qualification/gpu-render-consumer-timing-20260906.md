# Native destruction timing report

Capture: `out/recordings/native-gpu-resident-consumer-large-20260906`. 1,800 accepted steps; 368 steps used one resimulation.

These are host-wall timings including GPU waits, measured with profiling on a shared GPU. Audit settings are recorded in `native.summary.json`. They are not isolated CUDA kernel timings or a whole-game performance qualification.

| Complete step | Minimum ms | Average ms | Maximum ms | p95 ms |
| --- | ---: | ---: | ---: | ---: |
| Simulation/destruction | 1.033 | 183.424 | 1474.740 | 605.224 |
| Capture tick including observation and I/O | 2.117 | 185.128 | 1476.140 | 607.033 |

Simulation speed: **0.091x real time** (5.45 steps/s). 1,697/1,800 steps exceeded 16.667 ms.

## Outer simulation intervals

This table averages over **all** accepted steps, counting absent correction phases as zero. These selected outer intervals plus the residual reconcile to the complete simulation step. The residual contains ordinary physics, checkpointing, nested tasks and other work; it is not a measurement of one GPU kernel.

| Interval | Average ms per accepted step |
| --- | ---: |
| Submit contact loads, motion inputs and destruction work (`submit`) | 0.262 |
| Wait for destruction completion and reserve bodies (`finishAndReserve`) | 2.615 |
| Prepare collision ownership bindings (`collisionBindings`) | 0.017 |
| Prepare bodies for correction (`correctionBodies`) | 0.040 |
| Initialize reserved body state (`initializeReserved`) | 0.018 |
| Apply changed collision ownership (`applyBindings`) | 0.167 |
| Restore/install provisional motion (`restoreInstall`) | 0.005 |
| Reset affected contact caches (`resetContactCaches`) | 0.003 |
| Correction collision/solve (including refilter) (`correctedCollisionSolve`) | 11.056 |
| Accept corrected state (`acceptCorrection`) | 0.071 |
| Ordinary physics/checkpoint/other residual | 169.170 |
| **Complete simulation step** | **183.424** |

## Every recorded phase/task

**Do not add this table:** parent/child scopes and parallel tasks overlap. The active-step columns summarize only steps where that scope appeared. The all-step average counts absent scopes as zero. `task.*` values sum invocations within each accepted step across trial and correction. `trialDetail.*` is the ordinary pass; `detail.*` is inside correction. `refilter` is included in `correctedCollisionSolve`.

| Scope | Active steps | Active-step min ms | Active-step avg ms | Active-step max ms | All-step avg ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| `acceptCorrection` | 368 | 0.251 | 0.345 | 1.125 | 0.071 |
| `applyBindings` | 368 | 0.109 | 0.816 | 2.250 | 0.167 |
| `collisionBindings` | 1,800 | 0.000 | 0.017 | 1.334 | 0.017 |
| `correctedCollisionSolve` | 368 | 4.456 | 54.079 | 522.100 | 11.056 |
| `correctionBodies` | 1,800 | 0.000 | 0.040 | 1.352 | 0.040 |
| `detail.beforeSolver` | 368 | 0.000 | 0.002 | 0.010 | 0.000 |
| `detail.islandGen` | 368 | 0.007 | 0.465 | 9.480 | 0.095 |
| `detail.islandInsertion` | 368 | 0.089 | 1.469 | 6.005 | 0.300 |
| `detail.postBroadPhase` | 368 | 0.995 | 16.133 | 99.454 | 3.298 |
| `detail.postBroadPhaseStage2` | 368 | 0.028 | 0.314 | 2.591 | 0.064 |
| `detail.postBroadPhaseStage3` | 368 | 0.000 | 0.000 | 0.001 | 0.000 |
| `detail.postIslandGen` | 368 | 0.000 | 0.001 | 0.002 | 0.000 |
| `detail.postNarrowPhase` | 368 | 0.133 | 1.869 | 15.319 | 0.382 |
| `detail.postSolver` | 368 | 0.000 | 0.002 | 0.009 | 0.000 |
| `detail.preallocateContactManagers` | 368 | 0.003 | 0.521 | 1.659 | 0.107 |
| `detail.processLostContacts` | 368 | 0.000 | 0.003 | 0.043 | 0.001 |
| `detail.processLostContacts2` | 368 | 0.000 | 1.684 | 27.081 | 0.344 |
| `detail.processLostContacts3` | 368 | 0.000 | 2.643 | 45.024 | 0.540 |
| `detail.registerContactManagers` | 368 | 0.002 | 0.190 | 1.276 | 0.039 |
| `detail.registerInteractions` | 368 | 0.009 | 0.349 | 1.562 | 0.071 |
| `detail.registerSceneInteractions` | 368 | 0.010 | 0.561 | 1.886 | 0.115 |
| `detail.updateDynamics` | 368 | 0.070 | 0.840 | 45.308 | 0.172 |
| `detail.updateDynamicsPostPartitioning` | 368 | 0.073 | 0.230 | 1.543 | 0.047 |
| `finishAndReserve` | 1,800 | 0.115 | 2.615 | 37.522 | 2.615 |
| `finishDetail.allocateNativeBodies` | 368 | 0.014 | 2.391 | 31.889 | 0.489 |
| `finishDetail.publishReservation` | 368 | 0.006 | 0.009 | 0.028 | 0.002 |
| `finishDetail.requestReadback` | 368 | 0.032 | 0.111 | 1.176 | 0.023 |
| `finishDetail.reserveBodies` | 1,800 | 0.000 | 0.517 | 32.023 | 0.517 |
| `finishDetail.uploadBindings` | 368 | 0.007 | 0.013 | 0.059 | 0.003 |
| `finishDetail.waitForGpu` | 1,800 | 0.108 | 2.092 | 8.274 | 2.092 |
| `initializeReserved` | 368 | 0.037 | 0.088 | 1.078 | 0.018 |
| `refilter` | 368 | 0.736 | 1.437 | 3.653 | 0.294 |
| `resetContactCaches` | 368 | 0.005 | 0.014 | 0.045 | 0.003 |
| `restoreInstall` | 368 | 0.016 | 0.025 | 0.074 | 0.005 |
| `submit` | 1,800 | 0.108 | 0.262 | 2.800 | 0.262 |
| `task.accurateIsland.boundaryAudit` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.accurateIsland.clearDestroyedEdges` | 1,800 | 0.000 | 5.801 | 82.680 | 5.801 |
| `task.accurateIsland.clearDestroyedNodes` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.accurateIsland.deactivation` | 1,800 | 0.000 | 3.300 | 156.899 | 3.300 |
| `task.accurateIsland.findPathsAndBreakIslands` | 1,800 | 0.000 | 2.848 | 81.613 | 2.848 |
| `task.accurateIsland.removeDestroyedConnections` | 1,800 | 0.000 | 5.097 | 61.715 | 5.097 |
| `task.accurateIsland.removeEdgesFromIslands` | 1,800 | 0.000 | 5.169 | 86.371 | 5.169 |
| `task.accurateIsland.resetDirtyEdges` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.accurateIslandMaintenance` | 1,800 | 0.001 | 22.223 | 243.539 | 22.223 |
| `task.contactGraph` | 1,800 | 0.000 | 0.003 | 0.013 | 0.003 |
| `task.prepareIslandRepair` | 1,800 | 0.010 | 2.158 | 13.149 | 2.158 |
| `task.speculativeIsland.boundaryAudit` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.speculativeIsland.clearDestroyedEdges` | 1,800 | 0.000 | 4.888 | 66.970 | 4.888 |
| `task.speculativeIsland.clearDestroyedNodes` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.speculativeIsland.deactivation` | 1,800 | 0.000 | 1.962 | 95.118 | 1.962 |
| `task.speculativeIsland.findPathsAndBreakIslands` | 1,800 | 0.000 | 2.616 | 89.729 | 2.616 |
| `task.speculativeIsland.removeDestroyedConnections` | 1,800 | 0.000 | 5.207 | 53.510 | 5.207 |
| `task.speculativeIsland.removeEdgesFromIslands` | 1,800 | 0.000 | 5.528 | 74.498 | 5.528 |
| `task.speculativeIsland.resetDirtyEdges` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `task.speculativeIslandMaintenance` | 1,800 | 0.001 | 20.209 | 230.980 | 20.209 |
| `trialDetail.beforeSolver` | 1,800 | 0.000 | 0.004 | 0.013 | 0.004 |
| `trialDetail.islandGen` | 1,800 | 0.001 | 2.048 | 11.904 | 2.048 |
| `trialDetail.islandInsertion` | 1,800 | 0.000 | 13.430 | 117.214 | 13.430 |
| `trialDetail.postBroadPhase` | 1,800 | 0.187 | 23.621 | 102.919 | 23.621 |
| `trialDetail.postBroadPhaseStage2` | 1,800 | 0.000 | 0.681 | 8.444 | 0.681 |
| `trialDetail.postBroadPhaseStage3` | 1,800 | 0.000 | 0.000 | 0.001 | 0.000 |
| `trialDetail.postIslandGen` | 1,800 | 0.000 | 0.001 | 0.006 | 0.001 |
| `trialDetail.postNarrowPhase` | 1,800 | 0.006 | 8.270 | 62.555 | 8.270 |
| `trialDetail.postSolver` | 1,800 | 0.000 | 0.002 | 0.010 | 0.002 |
| `trialDetail.preallocateContactManagers` | 1,800 | 0.000 | 6.790 | 50.164 | 6.790 |
| `trialDetail.processLostContacts` | 1,800 | 0.000 | 0.005 | 0.997 | 0.005 |
| `trialDetail.processLostContacts2` | 1,800 | 0.000 | 3.865 | 39.841 | 3.865 |
| `trialDetail.processLostContacts3` | 1,800 | 0.000 | 7.394 | 68.866 | 7.394 |
| `trialDetail.registerContactManagers` | 1,718 | 0.001 | 7.800 | 75.055 | 7.444 |
| `trialDetail.registerInteractions` | 1,718 | 0.002 | 6.291 | 54.273 | 6.005 |
| `trialDetail.registerSceneInteractions` | 1,718 | 0.001 | 9.051 | 99.743 | 8.639 |
| `trialDetail.updateDynamics` | 1,800 | 0.010 | 7.666 | 80.824 | 7.666 |
| `trialDetail.updateDynamicsPostPartitioning` | 1,800 | 0.028 | 0.394 | 3.009 | 0.394 |

## CUDA destruction stages

Consecutive CUDA event intervals on the destruction stream; includes cross-stream dependencies, contention and host submission gaps, not pure kernel execution. Excludes ordinary/corrected rigid solving, reservation and acceptance after correction. Collected after an existing completion wait, with no added synchronization.

These stages are separate from the host-wall scopes above. Do not add them to the simulation total.

| Device stage | Min ms | Average ms | Max ms | p95 ms |
| --- | ---: | ---: | ---: | ---: |
| commitAndStressTopology | 0.032 | 0.064 | 1.581 | 0.073 |
| contactLoads | 0.033 | 0.550 | 1.444 | 0.850 |
| materials | 0.048 | 0.057 | 1.594 | 0.069 |
| stress | 0.144 | 1.053 | 6.802 | 4.957 |
| topologyAndCandidates | 0.030 | 0.311 | 3.314 | 1.713 |
| Total destruction stage sequence | 0.318 | 2.034 | 8.158 | 6.359 |

Individual CUDA kernel durations for stress, topology, broadphase, narrowphase and rigid solving are not separately isolated in this capture. In particular, the short `task.contactGraph` host scope is not the GPU graph-computation duration, and `finishAndReserve` is not pure stress time.
