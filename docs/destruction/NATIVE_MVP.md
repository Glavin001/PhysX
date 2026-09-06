# Native PhysX GPU destruction proof

The native rigid path now runs end to end through `PxScene::simulate()` and
`fetchResults()`. It consumes actual solved normal/friction impulses on CUDA,
evaluates the existing stress/material model, splits GPU connectivity and rigid
clusters, transfers persistent shape ownership internally, restores the GPU
rigid checkpoint and executes one corrected collision/solver pass. The application
performs no stress solve, fracture orchestration or replay.

## Evidence

`native_gpu_resimulation_test` compares the same two-body collision with an intact
wall and with fracture enabled. The intact wall stops a 2 kg projectile from
12 m/s to 0 m/s. The fracture case accepts exactly one internal resim: the 2 kg
projectile and released 2 kg chunk each move at 6 m/s. Initial momentum is
preserved. Shape contact identity remains stable, the fragment continues to
simulate, and the pose callback fires once per timestep. Additional cases verify
gravity and ordinary-body force commands are applied once, unsupported
speculative CCD is rejected before ownership application, and an exhausted
stress iteration budget is rejected by native mode. Diagnostic mode remains
selectable for reference comparisons.

The **passing 30-second capture** is:

```
out/recordings/native-mvp-20260906-d/native-physx-gpu-destruction.mp4
```

It contains 9 buildings, 3,996 persistent chunks, 8,064 authored bonds and 36
retained projectiles. Intact buildings initially share 9 cluster motion states.
The run reaches 2,989 clusters and breaks 6,587 bonds. All 1,800 timesteps finish:
250 steps use one correction each, none uses more than one, and every accepted
stress solve reports convergence. The explicit stress budget is 2,048 iterations
at tolerance 1e-5; the largest observed solve uses 924 iterations. Stress iterations
are not additional physics correction passes.

The video is H.264, 1920x1080, 60 playback frames/s and exactly 30 seconds. Rendering
follows captured committed GPU cluster and projectile poses. It does not animate
or script fracture. Raw state, per-step CSV, source patch, source/binary hashes,
SDK build provenance, summary and validation are beside the video.

The earlier `native-mvp-20260906-c` recording completed its physics steps but had
34 unconverged stress solves at its 256-iteration cap. Its `validation.json` marks
it diagnostic. Native correction now returns an incomplete step (error bit 4096)
instead of silently accepting such a stress result. Material thresholds, contact
loads, timestep and the one-resim policy are unchanged between these runs.

## Reproduce

From the repository root, with the Linux/CUDA prerequisites already installed:

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4
ctest --test-dir out/destruction-sdk -R '^physx_native_gpu_resimulation$' --output-on-failure
out/destruction-sdk/reference/native_destruction_demo \
  --grid 3 --waves 4 --seconds 30 --stress-iterations 2048 \
  --output out/recordings/native-proof-new
```

The output directory must not exist. The demo creates homogeneous brittle block
buildings: 1 m chunk spacing, 0.48 m box half-extents, density 1,000 kg/m3,
compression elastic/fatal limits 250/500 kPa, tension 30/60 kPa and shear 80/160 kPa.
Ground-floor chunks are authored supports. Crushing is not enabled for this
material. The 20,000 kg, 0.75 m-radius projectiles launch at 32 m/s; all remain
physical bodies. These are explicit demo inputs, not changes to transferred
impulses or hidden runtime cutoffs.

Build the existing offline renderer if needed:

```sh
cargo build --release --locked --manifest-path demos/blast-stress-demo/recorder/Cargo.toml
demos/blast-stress-demo/recorder/target/release/blast-mini-city-recorder render \
  --state out/recordings/native-proof-new/native.twstate \
  --output out/recordings/native-proof-new/native-physx-gpu-destruction.mp4 \
  --camera 0 --compact-hud --ground-y 0 \
  --title 'NATIVE PHYSX GPU + CUDA DESTRUCTION | 3996 CHUNKS | 1 RESIM LIMIT'
```

Keep the native timing CSV as a sidecar. The reference renderer's detailed CSV
schema expects external adapter phases, which the integrated native path does
not have. The video uses a backend label rather than inventing those timings.

## Scope and remaining work

Enable this experimental path with `PxDestructionStressDesc::internalCorrectionLimit=1`.
Zero preserves the previous diagnostic preparation path. Native correction currently
requires awake rigid scenes (`eDISABLE_SLEEPING`) with stationary kinematic supports;
joints, articulations, CCD/speculative CCD, moving kinematic targets, custom filter
callbacks and deformables are outside this correction path. Crushing/removal and
unapportioned external commands on a fractured source reject before application.
Ordinary-body commands are included in the rigid checkpoint and tested.

GPU calculations include contact-to-load assembly, stress/material evaluation,
connectivity, full cluster inertia/COM, motion preparation, and rigid checkpoint
restore. CPU work still includes normal PhysX scheduling, allocation and
collision/island/query membership metadata updates from device-produced IDs.
The complete collision set is rebuilt for correction. CPU query/actor mirrors,
sleep/activity rollback, committed event API design, selective scheduling and
higher scale remain unfinished. This is an opt-in native proof, not the final
public destruction SDK or full-plan qualification.

A sustained run exposed a false rejection of tiny settling-motion components.
Motion conversion now uses ordinary finite float conversion, including subnormal
values/underflow to zero. Strict nonzero/representability checks for mass and
inverse inertia remain unchanged. The analytic GPU body test covers this
separately; existing invalid mass/inertia assertions were not weakened.

## Performance limits

For the passing development run, simulation time (including embedded destruction)
was p50 1.95 ms, p95 16.21 ms, p99 19.26 ms and worst 2,126.78 ms. There were
72 steps above 16.67 ms, including the first fracture at step 136. The cost of
that outlier has not yet been attributed. Observation/capture cost is recorded
separately and is not part of the physics timing. This shared-GPU run is **not** a
strict 60 Hz result, an isolated benchmark, whole-game timing, or evidence of
100,000-chunk scaling.

The full suite retains five pre-existing reference/fidelity failures. Its latest
result and exact failure names are recorded in the qualification JSON and test
logs. Full native memory-check qualification also remains open as documented in
`CUDA_GRAPH_DIAGNOSTIC.md`; this proof does not resolve that independent tool/runtime
issue or replace the full SDK backlog.
