# First-class GPU destruction implementation

**The complete plan is not implemented or qualified yet.** The repository now
contains a buildable reference SDK plus GPU topology/motion foundations. These
foundations do not yet drive the PhysX collision/constraint solver.

Source repositories `blast-stress-solver-2` and `vibe-land-4` remain read-only.
The SDK branch is `codex/gpu-destruction`; the integration game is `vibe-land-2`
on `codex/gpu-destruction-integration`. No service, deployment, or publication was
performed. Exact revisions and source hashes are in `provenance/import.json` and
`provenance/game-import.json`. Build commands are in `BUILD.md`.

## CPU/GPU ownership target

The GPU must own persistent chunk connectivity/damage/support, cluster motion,
contact-to-load conversion, the existing stress/material model, fracture decisions,
topology transactions, correction work sets, and runtime structural activity.
The CPU loads authored assets, submits commands/tasks, manages allocations and
receives requested committed observations. Per-step graph traversal, contact
readback, stress preparation, and fracture orchestration on the CPU are migration
work, not the target design.

Current exceptions: the imported reference adapter still prepares loads, applies
fractures through CPU actors/shapes, and orchestrates replay on the host. PhysX's
island/activity coordination remains on the CPU. The new GPU topology/motion
primitive does its calculations without graph/motion readback, but is not wired
into the scene lifecycle. Its immutable chunk records describe mass properties;
cooked collision geometry and persistent shape ownership are not implemented by
that primitive. The reference retains its existing GPU stress solver.

## Completed and verified work

- Cloned fork main at `4f2103c3a9052906296defb12166753450ef787c`; created both branches.
- Imported source changes and fixtures with hashes, preserving upstream changes.
  Imported the recorded game's 12 destruction-related changes into `vibe-land-2`.
- Ported native sleep, host observation, contact identity and rotational bounds.
- Built PhysX GPU from source and installed a relocatable SDK with CMake consumer
  dependencies. CPU and GPU consumers pass from the original and relocated prefix.
- Removed historical absolute SDK paths from native Rust and active game builds.
- Added persistent GPU connectivity with deterministic minimum-ID components,
  stable chunk ordering, full cluster inertia, and whole-batch edit rejection.
  Offset-asset inertia avoids world-origin cancellation. Empty topology batches
  preserve the graph without repeating connectivity/sort/mass work.
- Added compact live cluster motion records and GPU parent-to-child motion
  transfer, including COM velocity reconciliation through rotated, repeated splits.
  Only active clusters have live motion entries; storage reserves capacity for all
  original chunks to separate. This is not yet a growable scene allocator.
- Added independent CPU graph/mass comparisons, 10k-chunk and randomized graphs,
  cyclic paths, root removal, invalid batches, and analytic momentum/point-velocity
  tests. GPU producer/consumer events order motion input and topology mutation.
- Added a metadata-upload warp barrier and event-ordered index transfers in native
  sleep, checkpoint and activity paths. The observation fixture now orders its
  reused index slot before reading it from a nonblocking GPU stream. It previously
  sometimes observed another body's pose; unchanged assertions now pass five runs.

## Remaining completion gates

- Scene-attached `PxDestructionScene` and SDK-wide stable generation-bearing
  structure/chunk/cluster handles, removal/reinsertion and crush ancestry.
- Engine-owned persistent collision geometry and GPU shape/cluster rebinding;
  new fragment pair eligibility and contact/constraint cache invalidation.
- GPU stress load preparation and the complete material/crush/fracture verdict
  integrated into PhysX's task graph. No predicted breakage is permitted.
- Full internal correction of all participants and joints, state/damage/command
  transaction accounting, committed-only event publication, and explicit errors
  for incomplete steps. Existing external replay is still the reference.
- Validated dependency work sets and selective collision/constraint reuse with
  instrumented full-correction fallback. Existing GPU solver islands do not by
  themselves supply independent scheduling.
- Growable persistent scene capacity, mutable GPU support state, and convergence-
  validated structural activity invalidation distinct from rigid-body sleep.
- Replace the game's external stress/replay orchestration with one integrated
  scene advance, then complete command/query/rendering/streaming qualification.
- Full consumer/demo/test coverage and separately tested fidelity fixes. No test
  tolerances have been loosened and material/force/velocity limits have not been
  changed as a substitute for computational optimization.
- Isolated GPU performance campaign: five trials/workload, warm-up plus >=60 s
  measured simulation, capacity search, all-step 16.67 ms deadline accounting,
  and separate whole-game tick timing. The GPU is shared; no scaling/60 Hz claim
  has been made and no other developer's service has been stopped.

## Test evidence

Logs are in `baseline/`. They document tests of the reference and the standalone
GPU topology/motion component, not integrated-path qualification.

- Initial native: 25/32 pass. Three missing default-scene-path failures were fixed
  by resolving the imported asset within this SDK. The intermittent activity
  observation failure was diagnosed and fixed without relaxing assertions.
- Current native CUDA architecture 89: **30/33 pass**. Remaining failures:
  `blast_stress_load_path`, `blast_stress_reference_building_load_path`, and
  `blast_stress_destruction_quality`. All existed in the initial baseline.
- Rust CPU/Rapier/scenarios: six failing targets before solver changes:
  `cross_validation_test`, `excess_force_integration_test`,
  `excess_force_persistence_test`, `headless_scenarios_test`,
  `projectile_impact_test`, `solver_mechanisms_test`. See the complete log.
- Rust PhysX conformance/thread safety: **5/5 pass**.
- TypeScript/WASM: **51/70 files pass**; 472 passed, 54 failed, 1 skipped tests.
  These are recorded migration baseline failures, not qualified material behavior.
- Integration game GPU/destruction/velocity smoke: **8/8 pass** against this SDK.
- Native activity fixture with ordered reads: **five consecutive passes**,
  including 1,577 batch-metadata samples/run and existing physical tolerances.
- New GPU topology/motion suite: passes independent graph/mass tests and analytic
  momentum/point-velocity checks. No timestep, collision or stress advancement is
  implemented by this primitive.

A copied adapter, wrapper, isolated kernel test, or unqualified fast path does
not satisfy the plan's completion definition. Reference failures must be resolved
without weakening tests; full GPU destruction and its qualification remain open.
