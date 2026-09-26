# Vehicle moving stress geometry — GPU-tested WIP

2026-09-26. Extends the separately qualified operator-revision work. This is a
stress-operator prerequisite, not live vehicle destruction or a scene API.

`ExtStressGpuUpdateDeviceGeometry` accepts device-resident node positions,
scalar inertias, bond centroids/normals and a geometry revision. It validates
the entire batch before writes, retains bond health and connectivity generation,
and advances the operator revision to invalidate inverses, warm ranges and
settled-input certificates. Repeated accepted revisions are no-ops; stale or
invalid revisions reject and prevent successful subsequent solves. This also
applies when fracture has left no live islands. Skipped submissions do not
clear an earlier rejection. Host enqueue exceptions poison the solver instance.
No extra per-solve geometry guard launches occur before this extension is used.

The API does not change the existing public solver vtable or device-view layout.
It freezes original mass/length normalization, support classification, endpoints,
materials and areas. Scene collision shapes, full inertia tensors, aggregate
COM frames, material-evaluation geometry and fragment momentum are NOT updated
by this API. They must be coordinated before enabling moving vehicle chunks.

## Build evidence and limits

The FP64 CuMetal package build successfully built `gpu_resident_geometry_test`
and `gpu_resident_stress_test` on 2026-09-26. The geometry harness uses ordinary
C++ compilation because it calls GPU APIs but launches no kernels itself.
The earlier `.cu` attempt failed with "CUDA host compilation produced no kernel
launch stubs". The kernel helper uses explicit trailing fields to initialize
its aligned return value rather than passing undefined padding through CuMetal.

The new test contains deformation plus inertia changes; comparison against a
fresh solver; independent supported force/moment equilibrium; both support
endpoint orders; host argument rejection; six whole-batch invalid input cases;
repeated/stale/rejected revisions; accepted-state recovery without partial
writes; broken-bond preservation; and an all-bonds-removed negative control.

**First GPU execution (2026-09-26, local CuMetal FP64).** The original
fresh-solver oracle failed at 5.27%. That was an oracle defect, not a defect in the API. The
free 4-node/6-bond graph is statically indeterminate, so the solver returns
the minimum-norm impulses in its own scaled metric, where angular/linear scale by L²M/LM. The update keeps the
rest-pose length/mass normalization by design, while a fresh solver on stretched geometry picks a different L.
The test now separates the cases:
- a rigid motion (same metric) must match a fresh solver exactly: error 0
- a stretched *supported tree* (determinate, metric-independent) must match: 1.8e-6
- the stretched indeterminate gap is printed, not asserted

Consequence for vehicles: in a redundant graph, how load is shared between parallel bonds is set by the
rest-pose metric and does not follow a re-derived one.

The independent support-equilibrium oracle also failed at first. It had not applied Blast's
opposite-handed angular coordinates, which production uses
(`PxgDestructionRuntime`: `inputs.angular = -torque / inertia`). A new regression pins that convention.
A free shear bond is recovered exactly (moment 9e-10) from Blast-convention inputs, and not
from un-negated Newton-Euler inputs (0.04 N instead of 1 N). Both endpoint orders then pass.
The operator-epoch suites (`blast_stress_gpu_operator_epochs`, `..._integration`) also pass.
Logs are in vibe-land `docs/reports/vehicle-suspension-geometry-2026-09-26/`.
Frozen penetration, full native vehicle dynamics, endurance, CUDA and performance
qualification remain pending.

Run the geometry executable and the existing `epochs`
integration suite serially under vibe-land/scripts/perf/gpu-run.sh, with
CUMETAL_USE_METAL_DEVICE_ADDRESSES=1 and CUMETAL_SYNC_EACH_LAUNCH=0. The package
is out/build/garage-multihull/package; its explicit hierarchy/motion/aggregate
roots, block-voted traps and packed bond stress options match the previous
operator-revision qualification. Do not execute the unrelated FP32 runtime build.

## Next integration boundary

A geometry revision must commit consistently to stress nodes/bonds, native
material bond normals/centroids, chunk full tensors/centers and attached collider
poses. Retained clusters need updated aggregate mass frames without unintended
momentum injection; detached chunks retain their independent rigid transforms.
Vehicle2 corner poses must have an explicit stage ordering, and release velocity
must account for suspension/steering/spin motion. Existing fracture generations,
material damage and unaffected city structures must survive these updates.

The small geometry derivation currently mirrors the established prepare() math.
Consolidate it in a separate behavior-preserving change after the new API is
numerically qualified, retaining the independent equilibrium oracle.

## Integration design for moving vehicle chunks (mapped 2026-09-26, not implemented)

The CPU reference exists in vibe-land (`server/src/vehicle_assets/{rig,posed}.rs`). It gives each chunk:
- a hull map, which may be non-rigid (the coil and CV shaft need `PxMeshScale`)
- full mass properties
- node inertia (trace/3)

and each bond its posed centroid and normal. It also provides `rebase_momentum`.

Four device geometry copies are uploaded once in `configureStress` and must advance together:
1. the Blast operator (`ExtStressGpuUpdateDeviceGeometry`)
2. `mChunks` position/inertia (used by `prepareLoads`, `routeContacts`, `routeConstraintLoads` and `sumChunkCommands`)
3. material bond geometry (`mBonds`, `mBondCentroids`)
4. topology chunk mass properties, plus the cluster frames `massProperties` derives from them (otherwise the next fracture restores the rest frame)

Proposed contract:
- **API:** add `PxDestructionScene::setChunkGeometry(revision, chunks, bonds)` (version 23), staged like `setChunkLoads`.
- **Runtime:** consume it in `advanceFull` on pass 0 only, after the `mInput` wait and before `observeNativeClusters`. Apply it to carrier-owned chunks only, and fail the whole step if any copy rejects.
- **Bridge:** in `prepare_vehicles`, before `vehicle->step`:
  - set the carrier hull shapes' local poses and mesh scale
  - set the actor's `cMassLocalPose` and inertia, and rebase its velocity
  - refresh the host `nodes/properties/clusters` mirrors used by `submit_vehicle_loads`
- **Timing:** this has to happen before `vehicle->step`, because Vehicle2's replayed world rows and `chunkCommandsMatch` fix geometry for the whole `simulate`. So the pose uses the previous step's wheel state, one step of lag.

Known limits:
- Bond compliance stays at rest-pose distances.
- Load sharing in redundant graphs keeps the rest-pose metric.
- The vehicle qualification overlay `/tmp/vehicle-convergence-gate-libs` (sha `adf645bb…`) is `PhysXDestructionGpuRuntime` built in `out/build/garage-multihull/physx` with `BLAST_STRESS_GPU_FP64=ON`, from the working tree just before `6938aa7d` was committed. The recipe is recorded in vibe-land `docs/reports/vehicle-authored-impact-2026-09-26/fp64/`. That tree is now configured `OFF` (single precision), so its current dylib differs. Before changing the runtime, rebuild `6938aa7d` with FP64 on and confirm the vehicle tests match.
