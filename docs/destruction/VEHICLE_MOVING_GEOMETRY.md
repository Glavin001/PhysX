# Vehicle moving stress geometry — unqualified WIP

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

**No GPU execution of this change has occurred.** The user requested a local
city play session, which holds the shared GPU lock. Do not stop that session or
claim the newly compiled assertions pass. No running SDK/library was replaced.
Frozen penetration, full native vehicle dynamics, endurance, CUDA and performance
qualification remain pending. Vast execution remains deferred by the user.

When the GPU is available, run the geometry executable and the existing `epochs`
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
