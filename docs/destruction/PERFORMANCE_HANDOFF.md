# Dated performance handoff and implementation map

## 2026-09-08: structured inverse screened; downtown consumer deployed on baseline

The new `StressNativeRigidInverse.cuh` candidate stores ten coefficients for the
physical block D=[A,-K;K,cI], applying its Schur block inverse instead of a full
21-coefficient symmetric matrix. Same physical operator/precision/tolerances;
general coarse solvers are unchanged. General dense-cache tests remain test-only.
A new 257-physical-block oracle validates actual cache construction/application
and cold/reuse/unknown/generation semantics. GPU memcheck reports zero errors;
three resident suites, eight ordinary tests and the exact 10-second frozen wall
signature all pass (398 supported / 46 detached chunks / 199 broken bonds).

[Screening evidence](../../qualification/vibe-rigid-inverse-20260908/comparison/report.md):
256 buildings / 113,664 chunks / 229,376 bonds / 768 physical rounds, two untraced
600-step / 10-second runs per arm in baseline/candidate/candidate/baseline order.
Baseline fracture peaks 145.893 / 140.909 ms; candidate 138.129 / 139.459 ms.
Complete peaks overlap (baseline 151.165 / 149.301; candidate 150.722 / 150.594 ms).
This is a promising short screen, not endurance or real-time qualification.
Further phase attribution / qualification and the deployment decision are pending.
Archives/runner: `out/vibe-rigid-inverse-20260908`, `/tmp/run-vibe-rigid-inverse.py`.
The live library remains the qualified 45ae3488 behavior, SHA-256
`1437bd31b875b71222331224aa6c3670a8d53bc812095727b7d67d60ec733f9e`.
Candidate and baseline libraries are separately archived; do not accidentally
replace the live library while the user is playing.

The user steered this turn to a larger, more interesting playable city. Game
commit `ad57f01` changes the launcher default to `fractured-downtown.json`, grid 1:
27 connected building groups / 24,105 chunks / 74,543 bonds, mixed heights/hulls.
Both grid 1 and grid 2 (108 groups / 96,420 chunks / 298,172 bonds) passed browser
join, physical shooting, native correction, movement, ownership, 30 settling
samples and reset. Grid 2 has excessive even-quiet server cost (~50–60 ms in the
browser session); grid 1 is the playable default. Impact pauses remain in both.
No real-time claim. All eleven detached bodies slept in the final grid-1 sample.
Evidence: `vibe-land-2/docs/reports/embedded-downtown-2026-09-08/`.
The browser uses local WT host/port routing, not independent external testing;
the user separately confirmed the public demo works. Do not restart an occupied
owned server or disturb another developer's process. Next work returns to the
larger-scale peak objective while preserving the user's playable deployment.

## 2026-09-08: diagnostic census fixed; production remains 45ae3488 behavior

Latest work is diagnostic-only: component work maps both evaluations per tick,
counts polynomial visits / fine inverse applications, and records anchor cohorts.
The old reporter's one-solve/tick assumption is not applicable to the native game.
New reporter: `tools/scripts/report-vibe-component-work.py`; seven new tests plus
six existing component-accounting tests pass. Actual macro publication is tested
on the host; missing/invalid subphase GPU counters reject the small smoke capture
before the full job. Global subphase atomics now publish once per CTA, not inside
every iteration. Production preprocessing equivalence is archived.

[Accepted report](../../qualification/vibe-component-work-accepted-20260908/report.md):
256 buildings / 113,664 chunks / 229,376 bonds / 768 rounds, 600 steps / 10 seconds,
920 stress evaluations. First split's 69.4M inverse applications are overwhelmingly
anchored-building work (99.990% of combined outer/polynomial adjacency visits).
Preconditioner = 66.14% instrumented CTA cycles; polynomial = 82.61% of that
subphase census. These are not wall-time savings or hardware-counter conclusions.
Full raw/packed census paths and hashes are retained in the report folder.

Earlier diagnostic paths `out/vibe-component-work-{,local-,final-}20260908`
are superseded or contain the rejected zero-counter publication bug. Use
`out/vibe-component-work-accepted-20260908`, its archived runner and the final
runtime hash. The owned server was restored; production runtime remains the
previously qualified anchored-residual build, not the intrusive diagnostic.

A separate isolated sparse-inverse reproduction again fails memcheck (30 errors).
Adding address prints masks the failure; no cause or safe optimization is proven.
Source copies/binaries are under `out/sparse-inverse-repro-20260908`, evidence under
`qualification/sparse-inverse-repro-20260908`. Do not enable it in production.
Next meaningful solver work should reduce retained-component preconditioner cost
or its required iteration count with full residual/physical checks; do not repeat
the already rejected queue-order or partial cache changes without new evidence.


## 2026-09-08: anchored residual cleanup retained after numerical and timing checks

Engine `45ae3488` is deployed and passed browser join/shoot/move/settle/reset:
444 chunks / 896 bonds, four 150 ms trigger holds, 265 broken bonds / 57 fragment
bodies after shooting, 30 settling samples, then reset to zero broken/detached.
Six known resource errors remain; local WT routing is used by browser tests.
Evidence is in `qualification/vibe-anchored-residual-20260908/browser/`.

The size-priority queue remains reverted. The only subsequent production change
is a six-line guard in `detail/StressNativePreconditioner.cuh`, deleting identity
FP32/FP64 residual rewrites and a barrier for a fully anchored component. The
current validated motion-mode certificate makes this decision, not sleeping,
convergence guesses or a user-selected alternate backend. Free components retain
full projection. All focused numerical/ordinary and frozen-wall checks pass.

[Evidence](../../qualification/vibe-anchored-residual-20260908/comparison/report.md).
Matched game-consumer 256 buildings / 113,664 chunks / 229,376 bonds / 768 rounds,
two 600-step/10-second untraced runs per arm: baseline fracture-peak range
146.158–158.171 ms versus candidate 146.181–151.395 ms. These overlap, and means
overlap too; do not call this a robust complete-peak improvement. Separate CUDA
event captures at first split show stress 35.978 -> 33.728 ms over two evaluations,
with matching reported work counts. Retained as deletion of redundant work, not
an 8 ms/60 Hz or historical external-backend superiority qualification.

Runtime archives and runners: `out/vibe-anchored-residual-20260908`,
`out/vibe-anchored-residual-phases-20260908`,
`/tmp/run-vibe-anchored-residual.py`, `/tmp/run-vibe-anchored-residual-phases.py`.
Production candidate runtime hash is recorded in the receipt. The CPU-compatible
body creation phase still creates `NpRigidDynamic` / `BodySim` and island nodes
before correction; GPU slot assignment alone has not removed that dependence.
Do not optimize these CPU mirrors as though that completes GPU-owned lifecycle.
The current component-work diagnostic reporter still assumes one solve/tick;
fix its mapping before using it with the present two-evaluation game consumer.


## 2026-09-08: size-priority stress dispatch rejected; deployed runtime unchanged

A GPU-only descending-size permutation was added to the existing dynamic CTA
queue and tested, then reverted. It changed dispatch order only, preserving
component/node identities and internal numerical order. Three resident suites,
eight ordinary integration tests and the frozen penetration signature passed.

Matched game consumer: 256 buildings / 113,664 chunks / 229,376 bonds / 768
physical projectiles, 600 steps / 10 simulated seconds, two untraced runs per
arm in baseline/candidate/candidate/baseline order. Direct GPU API off, sleeping
on, correction <=1, stress evaluations <=2. Worst complete peaks 150.872 ->
152.147 ms; worst fracture peaks 140.191 -> 143.766 ms. Lower averages are not a
peak win. First fracture peak remains tick 48. Do not reactivate this experiment
merely because its mean improved. Report includes baseline-to-baseline physical
count divergence and all accepted samples; no endurance or 60 Hz claim.

[Generated report](../../qualification/vibe-stress-order-20260908/comparison/report.md),
[patch](../../qualification/vibe-stress-order-20260908/rejected-scheduling.patch).
The benchmark comparison now supports repeated baseline runs and experiment
notes, and removes hardcoded claims of passing tests or startup being the peak.
Three reporter validation tests cover malformed/instrumented data, altered
commands, retained first-step peaks and absence of invented qualification.
Production code remains the targeted-report-repair runtime (69fe462a behavior).
Remaining priority is reducing required stress work at the retained-building
peaks and replacing CPU compatibility fragment creation with its final GPU
owner, not another queue-order-only change. Existing phase evidence still
applies; this experiment provides no hardware-counter bottleneck conclusion.


## 2026-09-08: targeted report repair wins the native game-consumer screen

Engine `69fe462a`, game `45b41d2`. The previous full-world refilter opportunity
is now addressed; do not repeat that optimization. See
[local contact-report repair](LOCAL_CONTACT_REPORT_REPAIR.md), the generated
[comparison](../../qualification/vibe-consumer-local-report-repair-20260908/report.md)
and [new fracture-peak phases](../../qualification/vibe-consumer-local-report-fracture-20260908/report.md).

Workload: 256 buildings / 113,664 chunks / 229,376 bonds / 768 physical rounds,
600 steps (10 simulated seconds), Direct GPU API off, sleep on, correction <=1,
max two stress evaluations. One baseline and two candidate untraced runs with
identical recorded command tapes. Complete peaks: 186.782 -> 151.490/151.405 ms
(startup now largest). Fracture peaks: 186.782 -> 135.903/147.162 ms. Means:
94.641 -> 55.996/57.516 ms. Worse-candidate peak reductions: 18.9% overall,
21.2% fracture. This is a short screen, not an 8 ms/60 Hz/endurance or historical
external-backend superiority qualification. Final broken bonds differ (78,046
baseline; 76,217/76,743 candidate); raw work counts and divergence are published.

Ordinary reports now select only their active dynamic shapes for CPU report
relationship repair, keeping unrelated GPU managers/islands. Static boundaries
and sleepers are excluded. Trigger/modifier/CPU-contact fallback remains complete.
Eight ordinary tests, an additional reported-reuse sleep-boundary comparison,
and exact frozen penetration pass. The optimized server was rebuilt without the
profiling feature and passed browser join/shoot/move/settle/reset on 444 chunks /
896 bonds with six rounds (310 broken bonds, 74 fragments). Public demo remains
one building; six known browser COEP/404 resource errors remain.

Remaining measured opportunity: the initial large split at tick 48, not the old
late refilter peak. New diagnostic fracture peak: 10,449 fragments / 10,193 awake,
256 projectiles present, 216,220 reported normal contacts, 57,788 cumulative breaks;
CUDA stress 33.479 ms, compatibility body creation 20.397 ms, correction 51.371 ms.
GPU completion/stress dominates the ten worst fracture steps. Subsequent corrected
step 78: correction 20.411 ms, refilter 0.016651 ms, GPU completion wait 52.013 ms.
These are different physical states; use untraced comparison for speed claims.

Game `embedded-profiling` is optional and excluded from the production dependency
graph. It reuses the SDK profiler through Rust and writes host/CUDA phase CSVs.
`report-vibe-consumer-phases.py --fracture-peak` uses existing disjoint accounting;
`compare-vibe-consumer-bench.py` checks input tapes/settings and archives full rows.
Never mix instrumented samples into the untraced report. Capture roots are
`out/vibe-game-local-report-repair-20260908` and
`out/vibe-game-local-report-phases-20260908`. The source reference repos remain
read-only. The full goal is still incomplete.


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
