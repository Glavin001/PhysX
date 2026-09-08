# Dated performance handoff and implementation map

## 2026-09-08: actual Vibe-land consumer scale screen and contact-report crash

Engine `6ef3fd47`, game `5ec74bf` (vibe-land-2). See
[contact report correction](CONTACT_REPORT_CORRECTION.md). The game now has an
`embedded_city_bench` example and validated automatic report generator. Four
buildings per asset let 64 wire asset IDs represent 256 independent buildings.

Three baseline 256-building attempts crashed during the second wave in CPU
`onContact` / `PxContactPair::extractContacts`. Correction recycled trial report
storage without invalidating retained actor/shape report stamps. The fix preserves
ordinary callbacks and the single accepted scene timestamp. Eight ordinary native
tests, the unchanged frozen penetration signature, and browser play/reset pass.

Fixed isolated screens: one 600-step / 10-second run each, 4/64/256 buildings,
1,776/28,416/113,664 chunks, 3,584/57,344/229,376 bonds, 12/192/768 physical
18,000 kg spheres at 40 m/s in three waves. Direct GPU API off, sleep on,
correction <=1 and exactly one additional stress evaluation after correction.
Complete-step peaks: 40.234 / 70.608 / 186.782 ms. This is not a performance win
or a 60 Hz qualification. First-step setup remains measured; no peaks discarded.

At the 256-building peak (tick 139): 256 projectiles present, 16,587 fragment
bodies / 13,747 awake, 16,843 total destruction clusters, 400,481 reported native
normal-contact count, 72,407 cumulative broken bonds, one correction/two stress
passes. Native advance = 169.699817 ms; accepted game event/snapshot processing =
17.081810 ms. These disjoint intervals do not identify native CPU vs CUDA limits.
Next useful measurement is the existing internal phase profiler on this exact
consumer workload, not another unmatched standalone scene or optimization of the
legacy CPU bridge. Accepted GPU event/topology deltas remain a final-owner gap,
but removing all current observation cost would still miss 60 Hz substantially.

Game report: `vibe-land-2/docs/reports/embedded-scale-2026-09-08/report.md` with
compressed raw samples, command tapes, build receipts and debugger captures.
Native capture root: `out/vibe-game-screen-20260908-fixed2`. The live public game
was restored to the tested one-building scene. Larger browser/network/endurance
qualification and matched external-backend speed superiority remain unproven.


Snapshot: **2026-09-08**, base commit `ab30a85b410603c284255f562f92f7733ab5ad8e`
plus native contact-property WIP. This is a resumption aid, not live status.
Inspect Git changes, processes and artifact hashes first. The goal remains full
integrated GPU destruction with more verified work inside an 8 ms complete-step
peak; no completion or real-time qualification is claimed.

Latest change: native freeze/unfreeze query membership is deferred to one accepted publication; see `ACCEPTED_QUERY_OBSERVATION.md` and `qualification/native-query-publish/cpu-sync.md`. CPU activity rollback and body/shape readback remain. Earlier CPU synchronization/activity evidence is in `qualification/native-cpu-sync/`.

Newer work: [two-evaluation correction and ordinary-mode report deletion](POST_CORRECTION_FRACTURE.md), with current measured results at the top of [findings](PERFORMANCE_FINDINGS.md). The dated implementation notes below predate that change.

Navigation: [playbook](PERFORMANCE_PLAYBOOK.md),
[measurement contract](PERFORMANCE_MEASUREMENT.md),
[findings/rejections](PERFORMANCE_FINDINGS.md),
[full optimization inventory](OPTIMIZATION_INDEX.md).

## Current contact-property migration

The native contact-input builder now derives rest distance and torsional-friction
parameters on the GPU from a persistent per-geometry property palette. CPU
loading/property-edit commands update changed palette entries. Ordinary PhysX
retains its existing path. Native per-contact rest/torsion uploads are removed;
quiet steps skip palette scanning/upload. This is a prerequisite for GPU-owned
pair allocation, not completion of contact/fragment lifecycle.

| Location | Responsibility |
|---|---|
| `physx/source/gpunarrowphase/src/PxgShapeContactProperties.inl` | Persistent property storage, changed-entry commands, growth and upload scheduling |
| `physx/source/gpunarrowphase/include/PxgContactManager.h` | 16-byte property record; distinct from PxgShape/PxgShapeSim layout |
| `physx/source/gpunarrowphase/src/PxgNarrowphaseCore.cpp` | Registration, palette update/scheduling, native payload-upload bypass |
| `physx/source/gpudestruction/src/PxgDestructionRuntime.cu` | GPU contact descriptor/parameter construction and bounds validation |
| `physx/source/physx/src/NpShape.cpp` | Shape-property edit notification, including shared shapes |
| `demos/blast-stress-demo/tests/native_gpu_collision_test.cpp` | Ordinary/native parameter law, shared edits, quiet upload skip, reuse and disable transition |

Final palette-guard revision: six focused collision/lifecycle suites passed and
the frozen **444-chunk / 896-bond / one-projectile, 10-second** wall audit passed
with 398 retained, 46 detached and 199 broken bonds. Evidence:
[collision tests](../../qualification/native-contact-properties/final-collision-tests.log),
[wall audit log](../../qualification/native-contact-properties/final-wall.log),
[archived quality result](../../qualification/native-contact-properties/final-wall-quality.json).
Earlier revision parameter memcheck reported zero errors. Do not call the final
revision sanitizer-qualified merely from that earlier result.

The earlier property migration's **256-building / 113,664-chunk / 229,376-bond /
256-projectile, two 3-second runs per arm** comparison had mean/worst
**16.751 / 58.579 ms** baseline versus **16.740 / 58.068 ms** candidate. Its other
impact peak worsened. This establishes no speedup; the final quiet guard was
added afterward. [Comparison](../../qualification/native-contact-properties-initial-comparison/comparison.md).
The later 15-second launch-capacity campaign uses the final matched build and
compares schedules, not old/new implementations.

## Known pre-existing sanitizer issue

`compute-sanitizer --tool initcheck` reports uninitialized global reads in the
rigid-to-shape radix sort, including `radixSortWarp` and
`radixSortCalculateRanks`, called from
`PxgGpuNarrowphaseCore::computeRigidsToShapes()`.

The saved original baseline produces the same category of errors. The baseline
used the broader `--reference` fixture; the candidate used `--contact-properties`.
Different total error counts are **not** a regression-rate comparison. Neither
log establishes a clean path. Suspected tail/vectorized-read initialization is
not a proven diagnosis; inspect producers, active count and sort padding before
adding clears or changing sorting.

Evidence: [candidate initcheck](../../qualification/native-contact-properties/initcheck.log),
[baseline initcheck](../../qualification/native-contact-properties/baseline-initcheck.log),
[earlier memcheck](../../qualification/native-contact-properties/memcheck.log).
Keep this fix separate from the property migration and performance attribution.

## Code map: measured work to final owner

Paths are relative to repository root. Use source symbols, not stale line numbers.

| Area | Source / symbol | Current gap or rule |
|---|---|---|
| Scene lifecycle | `physx/source/simulationcontroller/src/ScPipeline.cpp`, `canCorrect`, finalization and correction tasks | Trial, stress, restore/correction and acceptance; correction still has sleep/joint/CCD restrictions |
| Fragment reservation | `physx/source/physx/src/NpDestructionBodyAllocator.h`, `prepare`, `applyBindings` | GPU chooses slots but CPU creates compatibility actors/BodySim and applies shape/query lifecycle |
| Shape migration | `physx/source/simulationcontroller/src/ScShapeSimBase.cpp`, `rebindRigidOwner`; `physx/source/physx/src/NpShapeManager.cpp`, `rebindShapeInternal` | GPU physical ownership does not delete CPU actor links/filter/query dependencies |
| New contacts | `physx/source/gpunarrowphase/src/PxgNarrowphaseCore.cpp`, `registerContactManagerInternal`; `ScPipeline.cpp`, `postBroadPhaseStage2` | Native GPU descriptors exist; CPU contact-manager/interaction/edge allocation still remains |
| GPU body scheduling | `physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp`; `physx/source/gpudynamics/src/PxgContext.cpp` | Active CPU body lists and internal pointers have consumers; cannot delete BodySim independently |
| Native CUDA integration | `physx/source/gpudestruction/src/PxgDestructionRuntime.cu` and private `.cuh` files | Contact loads, stress/material/topology, checkpoints, correction preparation and commit |
| Topology transaction | `physx/source/gpudestruction/src/PxgDestructionTransaction.cuh`, `buildPrepare`, `buildCommit` | GPU accepted/trial topology; some capacity-sized copies remain; copy cost not separately established |
| Stress iteration | `blast/source/sdk/extensions/stressgpu/detail/StressComponentIteration.cuh` | CTA-resident full component loop and work queue; vectors still use global arrays |
| Preconditioner | `.../detail/StressNativePreconditioner.cuh`, `StressNativePolynomial.cuh` | Current two-stage polynomial; qualify cost of the whole recurrence, not one cache fragment |
| Stress hierarchy/modes | `.../NvBlastExtStressGpuTopology.cuh`, `.../detail/StressMotionModes.cuh` | Changed setup still broad; protect support/free-body null spaces and stable topology |
| Activity/reuse entry | `.../detail/StressResidentAPI.inl`, `solveDeviceAsync` | General settled/unconverged skip flags rejected; device validity mechanism still needed |
| Benchmarks/consumer | `demos/blast-stress-demo/native_destruction_main.cpp`, `native_gpu_consumer.cpp` | Complete timer, committed observations, safe aerial launch and optional GPU rendering |

## What the next implementation should resolve

1. Preserve the matched build and qualify/archive the property migration
   independently. Investigate the pre-existing sort initialization issue without
   attributing it to the new palette or hiding it.
2. For **simultaneous mass fracture**, finish GPU motion/shape/contact lifecycle
   with generation-bearing handles, capacity growth/failure, ordinary-body
   interaction, filtering, query observation and removal/reuse. Avoid a faster
   version of the CPU bridge as the architectural destination.
3. For **sustained destruction**, refresh current component work/phase attribution
   before another recurrence variant. The new staggered evidence puts stress
   above the whole 60 Hz budget. Fix the old diagnostic reader's schema mismatch
   before launching it; count polynomial traversal too. Evaluate full local
   recurrence/preconditioner cost and valid across-step reuse separately.
4. Preserve full correction when selective reuse cannot prove validity. Measure
   actual affected closure and new contact candidates before promising savings.
5. Re-rank using both workload axes, then short physical/performance checks,
   five 60-second gates and full lifecycle endurance. No existing short run
   establishes the maximum sustainable destruction rate.

## Existing architecture documentation

Read only the relevant module; older documents can describe intermediate states:

- [Native MVP/support boundary](NATIVE_MVP.md), [GPU ownership](GPU_OWNERSHIP.md),
  [reservation flow](WIP_GPU_RESERVATION_FLOW.md).
- [GPU connectivity ownership](GPU_CONNECTIVITY_OWNERSHIP.md),
  [stable motion slots](GPU_STABLE_MOTION_SLOTS.md),
  [persistent collision ownership](PERSISTENT_GPU_COLLISION_OWNERSHIP.md).
- [Contact inputs](GPU_CONTACT_INPUTS.md), [contact reuse](GPU_CONTACT_REUSE.md),
  [pre-solve contacts](GPU_PRE_SOLVE_CONTACT_INPUTS.md),
  [pre-solve support](GPU_PRE_SOLVE_STATIC_SUPPORT.md).
- [Rigid checkpoint](NATIVE_GPU_RIGID_CHECKPOINT.md),
  [correction bodies](NATIVE_GPU_CORRECTION_BODIES.md),
  [single-resimulation reference](SINGLE_RESIM_REFERENCE.md).
- [Native stress](NATIVE_GPU_STRESS.md),
  [stress topology](NATIVE_GPU_STRESS_TOPOLOGY.md),
  [GPU render consumer](GPU_RENDER_CONSUMER.md),
  [bombardment recording](NATIVE_BOMBARDMENT_RECORDING.md).

Both original source repositories remain read-only. Their historical policy,
CPU/WASM compatibility and game orchestration are not the final native CUDA
architecture. Deployment and service changes remain outside this work.
