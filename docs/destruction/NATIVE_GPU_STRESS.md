# Native scene GPU stress and material stage

This is an implemented intermediate stage of first-class destruction, **not the
completed destruction engine**. `PxScene::getDestructionScene()` exposes a
scene-owned graph that is advanced by `Sc::Scene::finalizationPhase`, after the
ordinary discrete contact solve and integration, before scene completion.
Applications call normal `simulate`/`fetchResults`; they do not invoke a Blast
adapter, stress callback, or external resimulation for this stage.

## Current data path

1. At configuration, upload fixed chunk stress properties, live rigid-cluster
   bindings, bonds, and a sorted shape-contact-index-to-chunk map. Prepare the
   reference CUDA solver's graph and connectivity once.
2. Obtain solved normal and friction contact streams internally. Capacity grows
   before copying; overflow is an explicit failed step, never accepted truncation.
3. Read cluster poses and angular velocities directly into device arrays. CUDA
   events order contact extraction, body reads, load assembly and stress solving
   in the scene's CUDA context.
4. GPU kernels accumulate chunk force, torque and surface virial at the actual
   contact/anchor points. They rotate loads into the chunk stress frame and use
   the reference acceleration/force conversion. Gravity and centrifugal loads
   are calculated on the GPU. The reference angular CG input remains zero;
   actual torque is preserved separately for the subsequent material/crush stage.
5. The asynchronous CUDA solver retains physical bond forces and convergence
   status on device. Borrowed device views include a ready event, and a consumer
   event prevents reuse before device observations finish.
6. Shared CPU/CUDA formulas evaluate material damage, remaining bond area,
   reinforcement, fibre bending, and chunk crushing on the GPU. Chunk virials
   combine contact tractions and solved bond forces. Contact strain rates use
   post-solve point velocities, including rotation, matching the reference.
7. Accepted bond health and crush state persist on device. Trial verdicts use
   separate storage. Nonfracturing valid steps commit the material transaction;
   any verdict requiring bond separation or full chunk crushing reports an
   incomplete step (error bit 8) and leaves the entire accepted material state
   unchanged. Actual topology and motion correction remain unfinished.
8. The native task waits for completion before PhysX publishes the scene. A
   40-byte status observation reaches the CPU; chunk, contact, and bond arrays do
   not. Submission/allocation failures and detected overflow/nonfinite forces
   produce an incomplete-step error through `fetchResults` and `errorState`.

CPU responsibilities here are asset preparation, scene task submission, CUDA
graph management, allocation growth, and the completion/error observation.
Ordinary PhysX still performs its existing CPU scheduling and bookkeeping.
There is no claim that the whole engine is CPU-free.

## API and binary boundary

The version 2 API is in `physx/include/PxDestructionScene.h`. Registered actors and
shapes must remain alive and attached until `clearStress` or reconfiguration,
which occur outside simulation. Shape identity is the transform-cache contact
index, not a geometry index. Existing Direct GPU host-access support can supply
that identity. Results become valid after the first completed stage (`frame>0`).
CPU scenes and CCD scenes return no native stage in this version. The normal
unconfigured scene retains ordinary simulation behavior.

Material configuration currently requires one bond per chunk pair, with
ascending endpoint IDs, and supplied compliance scales. Duplicate/reversed
pairs are rejected explicitly; parity for merged/reduced bond groups is still
required. Bondless graphs are supported: detached chunks retain contact and
crush evaluation without allocating or running a stiffness solve. Material
configuration is optional, preserving the stress-only stage.

`libPhysXDestructionGpuRuntime_64.so` contains the CUDA stress module and shares
the scene context. Its static CUDA runtime registration is bound locally on
Linux so PhysX's private kernel-wrangler registration symbols cannot intercept
its kernels. PhysX's GPU library links this dependency with an origin-relative
runtime search path. The stress module retains reference arithmetic flags;
upstream PhysX CUDA fast-math flags are not applied to it.

The standard SDK build/install command includes this library and records its
hash. `--cuda-architectures` also configures the native stress module. CPU/WASM
reference interfaces remain present; their complete qualification remains in
the overall implementation gates.

## Verification on RTX 4090 / CUDA 12.8

- `native_gpu_destruction_test` links neither Blast nor the CUDA runtime. It uses
  normal scene simulation with a rotated, offset kinematic cluster and an
  ordinary sliding projectile. Driver copies are test observations only.
- Native loads agree with independently decoded solved contacts at `2e-4`
  relative tolerance, including normal/friction force, torque, and all six
  surface-virial entries. Observed momentum error was `4.77433e-6 kg m/s`;
  relative torque error was `5.95374e-9` in the recorded run.
- The supported two-node gravity fixture produces `19.62 N`; empty frames clear
  contacts; clear/reconfiguration resets state. CPU scene compatibility and
  CUDA-event-ordered observations pass.
- Asynchronous versus blocking stress tests cover cold/warm solves, changed
  loads, dirty-topology rejection and preparation, and switching back to host
  input. Per-step asynchronous solve telemetry reports zero H2D/D2H transfers.
- `native_gpu_material_test` compares GPU decisions and persistent damage to
  the imported CPU reference across multiple frames: compression, tension,
  residual reinforcement, progressive and fatal failure, combined shear/bending,
  bond-driven crushing, timestep changes and the tension cutoff. Failed-step
  retry checks require unchanged accepted health and crush damage.
- Native contact tests also cover material-enabled and bondless graphs. An
  independent CPU observation of post-solve projectile translation and rotation
  matches the GPU contact strain rates at `2e-4` relative tolerance. A detached
  chunk's contact pressure matches the independently decoded virial; gravity
  alone does not produce crushing or fictitious bond work.
- The separate [quiet-load fidelity fix](GPU_QUIET_LOAD_FIX.md) passes four
  analytic solver variants. The pre-material full suite passed **35/39**, with
  four documented baseline failures. Current material-stage qualification is
  recorded separately: **36/40 pass**, with the same four baseline failures.
  No assertion was relaxed.
- Installed-package CPU and GPU consumers pass, including native graph
  configuration and scene advancement. Both the full reference package and
  `PhysXDestruction::NativeScene` pass from a relocated SDK; loader diagnostics
  confirm the relocated GPU libraries are used.

Build: `python3 tools/scripts/build-destruction-sdk.py --jobs 4`

Tests: `ctest --test-dir out/destruction-sdk --output-on-failure`

Reports: `out/native-regression.log`,
`out/destruction-sdk/out-native-regression.xml`, `out/native-package-consumer.log`.
A versioned source/artifact hash record is in
`docs/destruction/qualification/native-scene-stress-20260905.json`.
The material-stage record is
`docs/destruction/qualification/native-scene-material-20260905.json`, with logs
`out/native-material-regression.log`,
`out/destruction-sdk/out-native-material-regression.xml`, and
`out/native-material-package-consumer.log`. Installed full/native CPU and GPU
consumers pass with material-enabled and bondless native graphs.
These are correctness checks under shared GPU conditions, not an isolated
performance campaign or a 60 Hz scale qualification.

## Work still required

The stage does **not** yet commit topology-changing fracture verdicts, bind GPU
connectivity to persistent collision ownership, create clusters, or correct any
participant's motion. Full crushing still requires fragment geometry, ancestry,
mass/motion handling and energy accounting. Generation-bearing handles,
loads/commands through the final asset API, mutable support, joint/articulation
inputs, merged/reduced bond groups, CCD parity, event publication, and
convergence-validated structural activity remain unfinished.

Next, connect trial material verdicts to GPU topology and native collision
ownership, then implement the [single-rewind lifecycle](RESIMULATION.md) inside
PhysX. Stress or material diagnostics alone are not the complete simulation.
The old demos still use the external reference orchestration; these changes do
not make their recordings demonstrations of completed native destruction.
