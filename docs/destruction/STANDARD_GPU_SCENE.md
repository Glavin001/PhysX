# Embedded destruction with ordinary PhysX actors

The native scene can run CUDA rigid-body physics and embedded CUDA destruction
without `eENABLE_DIRECT_GPU_API`. Enable GPU dynamics and GPU broad phase, keep
sleeping enabled, and advance with the ordinary `simulate` / `fetchResults`
lifecycle. This remains the experimental rigid-scene correction API; it is not
qualification of arbitrary PhysX features or of the Vibe-land integration.

## C++ use

Create ordinary actors and exclusive chunk shapes and prepare their authored
stress/mass graph. The demo completes its initial scene setup before configuring
the destruction stage:

```cpp
// sceneDesc: GPU dynamics + GPU broad phase; no Direct GPU flag;
// do not set eDISABLE_SLEEPING.
PxDestructionScene* destruction = scene->getDestructionScene();
chunk.contactIndex = destruction->getShapeContactIndex(*chunkShape);
// Fill desc with persistent chunks, bonds, materials and initial cluster bindings.
desc.internalCorrectionLimit = 1;
desc.gpuIslandRepair = true;
if (!destruction->configureStress(desc)) { /* reject invalid configuration */ }

scene->simulate(1.0f / 60.0f);
PxU32 error = 0;
if (!scene->fetchResults(true, &error) || error || destruction->getLastStatus().error) {
    // Incomplete step: do not publish gameplay state.
}
// Ordinary actor getters and scene raycasts / overlaps / sweeps now observe
// accepted fragment actors, collider ownership, poses and mass properties.
```

The API header version is 13. Rebuild the SDK and its C++ consumers together.
`getShapeContactIndex` returns the persistent transform-cache identity needed by
stress, not a cooked-geometry ID. Shape release invalidates that lifetime.

`readRigidBodyData` is an optional CUDA-to-CUDA observer for ordinary and
fragment bodies after successful `fetchResults`. The caller supplies device
index/output buffers and optional input/output CUDA events. Finish consuming
those buffers before starting the next simulation; ordinary CPU actor access
remains enabled. The demo renderer uses this entry point without public Direct
GPU mode. No separate application stress solve or replay loop is introduced.

## Where work runs

| Work | Owner in this implementation |
|---|---|
| Solved contact loads, stress/material evaluation, topology and mass/inertia calculations | GPU CUDA |
| Rigid motion checkpoint, fragment motion preparation and corrected rigid solve | GPU, ordered by the PhysX task graph |
| Collision geometry and bounds | Persistent GPU state; CPU insertion/edit commands update changed entries |
| Ordinary actor poses, query structures and sleep membership | CPU compatibility observations and native PhysX scheduling |
| Fragment actor/shape lifecycle | Existing internal CPU compatibility registration around GPU ownership transactions |
| Changed cluster mass/COM observation | Compact GPU-computed records copied for ordinary getters; no CPU stress or mass recomputation |
| Sleep motion commit | Sparse transition IDs invoke GPU pose rollback and velocity/force clearing |
| Application callbacks | Accepted state only, once per timestep |

Ordinary CPU query support still uses PhysX's bounds/transform readback. This
change removes the repeated full upload back into collision, not all observation
readback. Sparse observation and entirely device-owned fragment/contact lifecycle
remain separate architectural work.

GPU-computed contact components can repair native island membership with
sleeping enabled. **Discarding the native membership mirror is not supported
with ordinary sleeping yet**: the existing CPU sleep scheduler requires it to
let disconnected bodies sleep independently. The demo explicitly rejects
`--standard-scene 1 --gpu-connectivity-owner 1`; select owner `0` while retaining
GPU pre-solve components, contacts, support and island repair. This is a remaining
scheduler integration task, not a CPU stress fallback.

## Reproduction

```sh
cmake --build out/sdk-release --target PhysX PhysXGpu PhysXDestructionGpuRuntime -j4
cmake --build out/destruction-sdk --target native_standard_scene_test native_destruction_demo -j4
ctest --test-dir out/destruction-sdk -R '^physx_native_standard_' --output-on-failure
python3 tools/scripts/run-destruction-penetration-regression.py out/NEW-reference
python3 tools/scripts/run-destruction-penetration-regression.py out/NEW-standard --standard-scene --video
```

The building audit uses the frozen 444-chunk, 896-bond, one-projectile scene for
600 steps, with timestep 1/60 and at most one correction per step. It enables
heavy collision/render/COM checks; its timings are not an isolated performance
qualification. Failed captures are retained and do not qualify as parity.

The small regression uses two physical chunks joined by one bond, one initial
projectile, one independent resting body and a ground plane. It checks supported
and detached mass/inertia, COM-frame continuity, ordinary queries, ordered public
GPU observation, correction publication, sleep, force-driven wake and collision
wake. The late-impact variant inserts a second projectile after settling.

## Remaining restrictions

Existing correction admission still excludes joints, articulations, CCD,
deformables, custom filter/contact-modification behavior and moving kinematic
targets. Crushing/removal and unapportioned source-force correction also retain
explicit rejection paths. Player-controller interaction and its moving kinematic
actor must be qualified before claiming complete gameplay integration. No Rust
wrapper or game checkout is changed by this native implementation.

See the accompanying `qualification/native-standard-scene` artifacts for the
actual test and building-audit results. Neither functional success nor an offline
video establishes large-scene 60 Hz performance.

## Qualification status (2026-09-08)

**Working native prototype; full migration parity remains open.**

- Fifteen selected tests pass, including six new ordinary-scene variants.
- Memcheck reports zero errors for the two-chunk / one-bond sleep-boundary
  comparison (no-fracture control and one-correction case, 600 steps each).
- The unchanged Direct GPU building reference passes the original frozen gate:
  398 supported chunks, 46 detached, 199 broken bonds, 43 final clusters.
- The ordinary sleeping building passes the existing functional/analytic
  invariants: 400 supported chunks, 44 detached, 197 broken bonds, 41 final
  clusters, actual front/rear holes and projectile clearance, at most one
  correction per step, converged stress and collision/render agreement.
- **It fails the original frozen topology identity/count comparison.** Do not
  update the golden, report full parity, or use the mode as a qualified speedup.
  Ordinary awake control also produces the different history; sleeping alone
  does not explain it. The recorded GPU words show identical body state before
  impact, small motion differences in the first corrected solve, and legacy
  allocation-default damping later replacing authored values in the Direct path.
  These observations do not yet prove the complete cause of the final topology
  discrepancy.

The failed intermediate captures remain under `out/standard-scene-*`. The
reviewable video is `out/standard-scene-sleeping-wall-v4/native-captioned.mp4`;
its overlay identifies the measured workload, audited complete-step timings,
offline rendering and outstanding parity gate. GPU word traces are emitted
alongside the existing heavy motion audit, without another device readback.

Before game integration: resolve the cross-mode fracture discrepancy, qualify
moving kinematic/controller interaction and supported constraints, then measure
ordinary-mode observation/sleep scheduling on the 256-building workload. The
remaining fully GPU-owned sleep/lifecycle work is not represented as complete.
