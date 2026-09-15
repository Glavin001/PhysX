# R2 gate: CPU consumers between "GPU fracture verdict ready" and "corrected collision/solver pass submitted"

Source inventory at commit `13b11af2` (read-only, 2026-09-15). Classification:
(A) mandatory physical update whose consumer is the GPU collision/solver, (B) redundant
reconstruction of state the GPU already holds or that survives fracture, (C) CPU-facing
observation that can be deferred to publication after the corrected pass.

## Execution order

1. `PxgSimulationController::advanceDestruction` (`PxgSimulationController.cpp:756`): GPU `advance()` (line 800), then the CPU sequence at 806–909.
2. Runtime host stages in `PxgDestructionRuntime.cu`: `finish()`:2044 → `reserveBodySlots()`:1574 → `observeCorrectionPreparation()`:1905 → GPU installs (`installCorrectionBodies`:1934, `installCollisionOwners`:1952) → `completeCorrectionPreparation()`:1921 → `prepareBodyCompatibility()`:1624 → `applyCorrectionBindings()`:1976.
3. Allocator bridge `NpDestructionBodyAllocator.h`: `reserveNodeCapacity`:221, `prepare`:237, `reserve`:79, `discard`:47, `applyBindings`:278.
4. `NpShapeManager::rebindShapeInternal` (`NpShapeManager.cpp:184`, device branch 216–221) → `Sc::ShapeSimBase::rebindRigidOwner` (`ScShapeSimBase.cpp:93`).
5. Controller bookkeeping `PxgSimulationController.cpp:870–884`.
6. Scene repair `ScPipeline.cpp:3057–3137`, then `restoreDestructionActivity`:2063 and `stepSetupCollide`:83 re-entry.
7. Corrected collide pass re-runs the standard pipeline: `finishBroadPhase`:500, `preallocateContactManagers`:720, `OnOverlapCreatedTask`:666, `ShapeInteraction::createManager` (`ScShapeInteraction.cpp:1025`), `postBroadPhaseStage2`:1024, `IslandInsertionTask`:966, `islandInsertion`:1160, `registerContactManagers`:1218, `registerInteractions`:1248, `registerSceneInteractions`:1293, `secondPassIslandGen`:1820/1837, `beforeSolver`:2097, then `PxgGpuContext::update` (`PxgContext.cpp:2234`) and `updatePostPartitioning`:2428.

## Inventory

| # | file:line | function | what it does | reads | writes | loop shape | class |
|---|---|---|---|---|---|---|---|
| 1 | PxgDestructionRuntime.cu:1574 | `reserveBodySlots` | copies body-allocation observation to host, grows motion slots, requests node handles | GPU: preparation count/requests, allocation error | host scalars | per scene | A |
| 2 | NpDestructionBodyAllocator.h:221 | `reserveNodeCapacity` | reserves native node handles, grows granted-node mask | CPU: node handle count | island-manager handle pool, allocator bitmap | per grown capacity | A |
| 3 | PxgDestructionRuntime.cu:1624 | `prepareBodyCompatibility` | D2H compact body requests + returned indices, then `cudaStreamSynchronize` | GPU-produced | host reserved indices | 2 memcpys, **one full stream sync** | B (indices already exist in the GPU mapping) |
| 4 | NpDestructionBodyAllocator.h:237 | `prepare` | validates every GPU-chosen node, hash maps over cluster/target, reuse-vs-new decision | CPU IslandSim nodes, kinematic flags; GPU requests | `mBodies` | per fragment + 3 hash maps | B |
| 5 | NpDestructionBodyAllocator.h:79 | `reserve` | creates `NpRigidDynamic`, `Sc::Scene::addBody(..., PxNodeIndex)` | CPU | NpRigidDynamic pool, **BodySim**, island node binding, `addDynamic`, CCD bitmap | per new fragment | A |
| 6 | ScScene.cpp:2408 | `Sc::Scene::addBody` | constructs BodySim, registers node object, `addDynamic`, `addShapes`, `setStateDirty` | CPU | BodySim pool, island node, `PxgBodySimManager` lists, active list | per new fragment | A |
| 7 | NpDestructionBodyAllocator.h:47 | `discard` | releases unmatched reservations | CPU | BodySim destruction, island node release, SQ pruner, shape manager | per stale reservation | A |
| 8 | PxgDestructionRuntime.cu:1976 | `applyCorrectionBindings` | event sync, gather kernel, 3 D2H copies, **second event sync** | GPU bindings/requests/targets | host vectors | 3 copies, 2 full syncs | B/A (payload GPU-produced; host detour redundant) |
| 9 | NpDestructionBodyAllocator.h:293–317 | `validateOwners` | re-validates every parent/target actor and every shape binding | CPU shape/actor flags | none | per body + per shape, 2 hash maps | B |
| 10 | NpDestructionBodyAllocator.h:321–341 | `scheduleOwners` | kinematic flag, `eDESTRUCTION_MASS_GPU`, `setActive(true)`, `notifyNotReadyForSleeping()` | GPU `request.supported` | BodyCore flags, active list, island node activation | per correction body | A |
| 11 | NpShapeManager.cpp:216–221 | `rebindShapeInternal` | geometry/scene/aggregate/SQ gating | CPU shape flags | none | per migrating shape | B |
| 12 | ScShapeSimBase.cpp:96–99 | `rebindRigidOwner` prologue | transform consistency check | CPU vs GPU local pose | none | per shape | C |
| 13 | ScShapeSimBase.cpp:105–107 | `refilterBounds` | device path only sets `mGPUStateChanged` | CPU volume data | broadphase state flag | per shape | A (already minimal) |
| 14 | ScShapeSimBase.cpp:134 | `onVolumeRemoved(eWAKE_ON_LOST_TOUCH)` | retires every interaction / contact manager on the migrating shape | CPU interaction lists | ShapeInteraction pool, CM pool, island edges, lost-touch pairs, report pairs | per shape × per interaction | A |
| 15 | ScShapeSimBase.cpp:139 → PxgNarrowphaseCore.cpp:7721 | `rebindShapeInstance(deviceOwnerTransaction=true)` | observes the already-installed owner | GPU owner | host mirror | per shape | B |
| 16 | ScShapeSimBase.cpp:148–151 | `destroySqBounds`, `rebindActor`, `setTransform` | element ↔ actor relink, shape transform, SQ bounds | CPU actor element lists | actor↔element links, transform, SQ bounds | per shape | A (`rebindActor`), C (SQ) |
| 17 | ScShapeSimBase.cpp:154 → PxgShapeSimManager.cpp:78 | `setPxgShapeBodyNodeIndex` | writes host mirror of `mBodySimIndex` | CPU mirror | `PxgShapeSimData::mBodySimIndex_GPU` | per shape | B |
| 18 | ScShapeSimBase.cpp:166 | `createSqBounds` if active | reads active state | CPU `BodySim::isActive()` | SQ bounds | per shape | C |
| 19 | PxgSimulationController.cpp:872–879 | flag-clear loop | clears GPU-copy flags, `mUpdatedMap` | GPU correction indices | `PxsRigidBody` flags, updated map | per correction body | A |
| 20 | PxgSimulationController.cpp:880 → PxgContext.h:350 | `acknowledgeNativeNodeBirths` | IslandSim pre-solve node births | GPU reserved indices | pre-solve node roster | per new body | A |
| 21 | PxgSimulationController.cpp:882–884 | pending-list compaction | filters `mNewOrUpdatedBodySims` | CPU | body-sim manager list | per pending body | A |
| 22 | PxgSimulationController.cpp:893–899 | contact/friction cache resets | invalidates GPU caches | — | GPU buffers | per scene | A |
| 23 | ScPipeline.cpp:3082–3095 | report-pair scan | walks every contact-report actor pair, collects active dynamic shapes, resets stream stamps | CPU report streams, active/kinematic state | repair shape list, stamps | per report pair × shape pair × 2 | C |
| 24 | ScPipeline.cpp:3097–3103 | report/trigger/constraint reset | clears report streams, trigger buffers, broken constraints, sleep/wake lists | CPU | publication buffers | per scene | C |
| 25 | ScPipeline.cpp:3108–3116 | preserve-pairs repair | sort/dedup + `onResetFiltering` per repaired shape | CPU | broadphase refilter, `onVolumeRemoved` | per repair shape | C/A boundary |
| 26 | ScPipeline.cpp:3118–3127 | full refilter fallback | **loops all scene shapes**, `onResetFiltering` on every active non-kinematic dynamic shape | CPU active/kinematic | broadphase groups, **all interactions/contact managers destroyed**, island edges removed | **O(all shapes)** | B |
| 27 | ScPipeline.cpp:2063 | `restoreDestructionActivity` | rewinds trial sleep/activity, poses, wake counters, both IslandSims | CPU captured activity | BodyCore pose/wake, flags, active lists, sleep/wake notifications | per active rigid node | A (activation) / B (`body2World`, GPU holds corrected `PxgBodySim`) |
| 28 | ScPipeline.cpp:83 | `stepSetupCollide` re-entry | timestamps, kinematics setup, `updateDirtyInteractions` | CPU | dirty interaction states | per scene + per dirty interaction | A |
| 29 | ScPipeline.cpp:500/720/666 | broadphase finish → overlap filter → CM preallocation → element interactions | second filtering + `createRbElementInteraction` | CPU overlap list, filter info | CM pool, ShapeInteraction pool | per created overlap | A |
| 30 | ScShapeInteraction.cpp:1025 | `createManager` | fills `PxcNpWorkUnit` (rigid bodies, shape/rigid cores, transform-cache IDs, pair flags) | CPU ShapeSim/BodySim links (rows 10/16) | contact-manager work unit | per new interaction | A (row the GPU NP consumes) |
| 31 | ScPipeline.cpp:966 | `IslandInsertionTask` | `addPreallocatedContactManager`, dirty edges, `mEdgeIndex` | CPU node indices, actor types | island edges, edge→CM maps | per new interaction | A (edge index is the partition key) |
| 32 | ScPipeline.cpp:1160 | `islandInsertion` | delayed dirty edges, GPU-type edges, `firstPassIslandGen` | CPU island state | speculative IslandSim | per task + per edge | A (speculative) / B (partition when GPU labels used) |
| 33 | ScPipeline.cpp:1218/1248/1293 | register CMs / interactions / scene interactions | NP registry, actor interaction lists, sleep counters, active CM list | CPU | NP registry, BodySim interaction counters, scene lists | per CM / interaction | A |
| 34 | ScPipeline.cpp:1820/1837 | `secondPassIslandGen` | wake islands, new/destroyed/lost edges, reclaim handles | CPU island graph | accurate partition, handle pool | per dirty node/edge | A (edge lifecycle) / B (partition when `mPreSolveIslandIds != 0`) |
| 35 | PxgContext.cpp:2255–2270, 2373–2380 | `PxgGpuContext::update` | active node/kinematic counts, memcpy active node indices, sizes solver body pools | CPU IslandSim active lists | solver body pools, `mActiveNodeIndex` | per active node | A |
| 36 | PxgContext.cpp:2415 | `updateIncrementalIslands` | partitions constraints/contacts from accurate IslandSim | CPU island edges/nodes | partition arrays | per edge | A |
| 37 | PxgContext.cpp:2570–2650 | pre-solve island production | builds pre-solve nodes/merges, `buildPreSolveIslands`, sets labels | CPU node/island/lifetime data; GPU contacts | host staging | per node or per changed node | A (produces `mPreSolveIslandIds`) |
| 38 | PxgContext.cpp:2649–2700 | solver island metadata upload | skipped when GPU-produced; otherwise host island upload | CPU partition | pinned pages | per node/island | B when GPU islands on |

## GPU-side equivalents already present for the (A) items

- Shape→body ownership (rows 15, 17): `PxgShapeSim::mBodySimIndex` (`PxgShapeSim.h:42`) and the `shapeToBody` remap are written by `installNativeCollisionOwners` (`PxgDestructionRuntime.cu:1952–1970`); the CPU mirror is `PxgShapeSimData::mBodySimIndex_GPU`.
- Body mass/inertia/COM/pose/velocity (rows 10, 19, 27): `PxgBodySim` (`PxgBodySim.h:50`), velocities and accelerations installed by `installCorrectionBodyInputs` (`PxgDestructionRuntime.cu:1944–1946`); CPU publication is already deferred to `publishCorrectionProperties`:130 after acceptance.
- Solver body identity (row 35): solver body data is already a single host record when `usesNativeKinematicInputs()` (`PxgContext.cpp:2346–2352`); only `mActiveNodeIndex` still comes from the CPU active-node roster.
- Island labels (rows 32/34/38): `mPreSolveIslandIds` / `mPreSolveStaticTouches` (`PxgSolverCore.h:309–310`), consumed by `PxgCudaSolverCore.cpp:1817` and `PxgTGSCudaSolverCore.cpp:1937`.
- Contact-graph edges (row 31): `PxgDestructionRetainedEdge` deltas uploaded by `buildDestructionContactGraph` (`PxgSimulationController.cpp:711–742`).

## CPU consumers that still need island node/edge inserts before the corrected pass (with GPU islands on)

Only three:
1. **Active-node roster**: `PxgGpuContext::update` reads the IslandSim active node/kinematic lists into `mActiveNodeIndex` (2255, 2262, 2373–2380); this defines `mBodyCount` and solver body ordering. Pre-solve islands replace only the label array, not the roster.
2. **Incremental partitioning**: `updateIncrementalIslands` (2415) consumes the accurate IslandSim plus edge→node aux data keyed by edge index, so `addPreallocatedContactManager` and `ShapeInteraction::mEdgeIndex` (ScPipeline.cpp:1000, 1015) carry contact-manager identity, not connectivity.
3. **Retained-edge upload**: `buildDestructionContactGraph` (`PxgSimulationController.cpp:711–742`) and `PxgContext.cpp:2593–2607` walk the retained-contact map through IslandSim edges.

Not needed once `mPreSolveIslandIds != 0`: the host island partition itself (`PxgContext.cpp:2649` short-circuits the upload; `PxsIslandSim.cpp:1998–2001` skips `rebuildHostConnectivity` under device ownership).

## Where sleeping state is read on this path

`ScPipeline.cpp:2843–2860` (nodes to deactivate → GPU sleep pending/rollback), `:3026–3032` (`finalizeGpuSleep` before `advanceDestruction`), `:2031–2060` (`captureDestructionActivity`: kinematic targets, sleep notify flags, active nodes, wake counters, sleeping flags, readiness from both IslandSims), `:2063–2096` (restore, including `activateNode` / `deactivateNode_ForGPUSolver`), `NpDestructionBodyAllocator.h:86` and `:336–339`, `ScPipeline.cpp:3090` and `:3126` (active non-kinematic gating), `ScShapeSimBase.cpp:166`, `PxsIslandSim.cpp:2104–2190` (deactivation inside `processLostEdges`), `PxgContext.cpp:2576`.

## Why `PxgContext.h:338` requires `mPreSolveSleepingDisabled` for device connectivity ownership

`mPreSolveSleepingDisabled` is `PxSceneFlag::eDISABLE_SLEEPING` captured in the constructor (`PxgContext.cpp:386`). With device ownership, `IslandSim::processLostEdges` skips `rebuildHostConnectivity` (`PxsIslandSim.cpp:1998–2001`), the routine that splits host islands. The GPU component mirror that answers connectivity (`mGpuComponentLabels/Members`, used by `findRoute` at `PxsIslandSim.cpp:1530–1557`) is installed only for the third pass (`PxgSimulationController.cpp:660–676`) and nulled right after (`PxsSimpleIslandManager.cpp:65`). Island **deactivation** runs inside the same `processLostEdges` call (`PxsIslandSim.cpp:2104–2190`) and walks host island membership directly (`mActiveIslands`, `mIslandAwake`, root-node chains, static-touch counts). Unsplit membership would let a fractured structure sleep or stay awake as one island. `restoreHostConnectivityImpl` (`PxsIslandSim.cpp:1483–1501`) repairs it but is only invoked on fallback. Requiring `eDISABLE_SLEEPING` makes the hazard unreachable (`ScBodySim.cpp:575–578`). The header comment at `PxgContext.h:604–605` states the contract: the sleep scheduler must consume device components before the mirror can be discarded. `acknowledgeNativeNodeBirths` (`PxgContext.h:350–356`) deliberately does not take the sleeping gate.

## Highest-value redundancy on the critical path

Rows 3, 4, 8, 9, 15, 17, 26 and 38. Rows 3 and 8 force three full stream synchronizations (`PxgDestructionRuntime.cu:1640`, `1993`, `1998`) purely to hand GPU-selected indices to a host validator that re-derives the same bindings (rows 4 and 9). Row 26 is the only O(all shapes) loop on the path and destroys contact managers for clusters the fracture never touched; `preserveUnchangedContactPairs` is the narrow alternative (rows 23/25) but falls back whenever triggers or a contact-modify callback are present (`ScPipeline.cpp:3053–3055`) or when CPU contact managers exist (`PxgSimulationController.cpp:893`).

## Consequence for the R2 design

The ownership transaction must (1) make the sleep scheduler consume device component membership (rows 27, 34, the `processLostEdges` deactivation loop) so the sleeping gate can be lifted; (2) replace rows 3/4/8/9 by a single device-side binding acceptance whose host observation is deferred; (3) keep rows 5/6/10/14/16/20/30/31/33 as the mandatory registrations but feed them from the GPU transaction in one batched pass; (4) make row 26 O(changed) by qualifying `preserveUnchangedContactPairs` and removing its trigger/callback fallbacks.
