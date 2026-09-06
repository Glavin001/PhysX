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
72 steps above 16.67 ms, including the first fracture at step 136. The first-fracture
outlier was subsequently attributed and fixed; see the follow-up below. Observation/capture cost is recorded
separately and is not part of the physics timing. This shared-GPU run is **not** a
strict 60 Hz result, an isolated benchmark, whole-game timing, or evidence of
100,000-chunk scaling.

The full suite retains five pre-existing reference/fidelity failures. Its latest
result and exact failure names are recorded in the qualification JSON and test
logs. Full native memory-check qualification also remains open as documented in
`CUDA_GRAPH_DIAGNOSTIC.md`; this proof does not resolve that independent tool/runtime
issue or replace the full SDK backlog.

## First-fracture allocation fix

The native owner shells have no public actor-array index. Their 27-bit unused
index was passed to `Gu::ActorShapeMap`, whose uncached sentinel is 0xffffffff.
The mismatch caused the first fragment query registration to allocate and zero
268,435,456 cache entries: **4 GiB** on the tested 64-bit build. Noncompound query
registration, lookup, update and removal now translate the private-owner index
to the existing actor/shape hash-map path. Ordinary indexed actors and compound
query indexing keep their existing paths. No physical settings or CUDA formulas
changed. Temporary profiling code was removed.

On the same 3-second, 9-building, 9-projectile diagnostic workload, first fracture
at step 136 fell from 2,062.53 ms to 9.01 ms. The fixed run's worst step was
15.22 ms. Both runs reached 1,877 clusters, 4,588 broken bonds and 27 corrected
steps, with at most one correction per step. This is a development observation,
not an isolated scaling benchmark. The native impact test now rejects an
oversized single allocation, checks ordinary and cached fragment raycasts after
explicit committed-pose observation, and verifies that query registration does
not expose private fragments through the public actor list. Automatic CPU pose
freshness remains outside this test's claim.

The unchanged 30-second workload was rerun into
`out/recordings/native-mvp-20260906-e`. All 1,800 steps completed with converged
stress; 265 used one correction, none exceeded one. It reached 3,001 clusters
and 6,607 broken bonds. The largest stress solve again used 924 iterations.
Simulation timing was p50 2.73 ms, p95 21.34 ms, p99 24.75 ms, worst 38.16 ms,
with 201 missed 16.67 ms deadlines. The two-second allocation stall is gone;
the sustained workload is still not a strict 60 Hz result. These shared-GPU
runs do not establish a general throughput improvement or bit-identical chaotic
trajectories. Capture E records source/binary hashes, patch, state, CSV and
validation alongside its summary. The linked D video remains a valid earlier
end-to-end demonstration.

The follow-up full suite passed 54/60: the same five reference failures plus one
`physx_persistent_shape_owner_gpu_bounds` depenetration assertion. That unchanged
bounds fixture then passed three consecutive isolated reruns. The intermittent
failure is recorded, not marked resolved. The native resimulation regression
passed. Exact results are in `qualification/native-query-index-20260906.json`
and the corresponding baseline logs.

## Short integrated scale check above 100,000 chunks

Private owner validation now uses a persistent pointer-to-membership hash map,
with separate reserved/accepted states. This removes the repeated linear scans
of all accepted fragments from each source/target lookup. Existing island-node
and controller registration checks still precede pointer dereference; membership
is erased before pool storage is released. Acceptance updates existing entries
without allocating. Allocation and teardown order still follow the original
arrays. GPU stress, topology, mass and motion calculations are unchanged.

Four targeted native suites passed: body allocation, collision preparation,
correction bodies and end-to-end resimulation. The allocation suite adds three
257-owner lifecycle cycles, including reservation reuse, accepted fragments as
new split sources, reservation discard, clear, deferred node deletion and pool
reuse. These metadata tests supplement the existing physical initialization and
momentum fixtures. The full suite was not rerun for this focused allocator change;
the previously recorded reference failures and intermittent bounds failure remain
open.

A **three-second functional scale check**, not sustained performance qualification,
completed with 256 buildings, **113,664 chunks and 229,376 bonds**. It launched
252 projectiles before the short capture ended, broke 185,011 bonds and reached
89,923 destruction clusters. All 180 accepted stress solves converged (maximum
170 iterations). Exactly 56 steps used correction, each using only one resim.
The peak reported normal contact-load count was 886,214 in one trial step.

Simulation timings were p50 0.65 ms, p95 621.92 ms, p99 772.59 ms and worst
822.29 ms. The overall median is dominated by the initial intact interval;
corrected steps had a median of 298.36 ms. All 56 corrected steps exceeded
16.67 ms. Observation and recording costs are separate. This shared-GPU check
proves functional processing at this scene size, **not real-time operation**,
long-duration stability, or an isolated comparison with the prior implementation.
The first correction occurs at step 124; the capture includes less than one
second of active bombardment. A 30–60-second run at this scale remains pending.

The verified 1920x1080, 180-frame video is:

```
out/recordings/native-scale-113664-20260906-a/native-scale-113664-overview.mp4
```

It is labeled offline playback and renders committed native GPU poses. The state,
CSV, source/binary hashes, patch and video validation are beside it. Reproduce
into a fresh output directory:

```sh
out/destruction-sdk/reference/native_destruction_demo \
  --grid 16 --waves 1 --seconds 3 --stress-iterations 2048 \
  --output out/recordings/native-scale-new
demos/blast-stress-demo/recorder/target/release/blast-mini-city-recorder render \
  --state out/recordings/native-scale-new/native.twstate \
  --output out/recordings/native-scale-new/overview.mp4 \
  --camera 0 --compact-hud --ground-y 0 \
  --focus-center 120 4 120 --focus-radius 130 --camera-margin 0.05 \
  --title 'NATIVE PHYSX GPU + CUDA | 113664 CHUNKS | 1 RESIM | OFFLINE PLAYBACK'
```

Phase timing is the next prerequisite for targeting the remaining cost: full
collision rebuilding, corrected solving, GPU stress/topology and CPU ownership
application are not yet separately measured in this large-scene result. Selective
correction or contact reuse still requires explicit validity checks; scene size
must not be handled by dropping physical work or accepting unconverged stress.

Optional release-build phase reporting is now available with `--profile-phases 1`.
See [native profiling](NATIVE_PROFILING.md) for verified large-scene phase costs,
reproduction commands and timing limits. GPU kernel timings and selective
correction optimization remain outstanding.

## GPU-selected owner updates

The correction bridge now consumes CUDA's compact affected-owner set instead
of reading back and scanning every cluster. An impact with 128 unrelated
structures updates only two affected CPU owners and preserves the analytic
projectile response. Six native suites and the independent build/install pass.
A 113,664-chunk diagnostic and a 30-second small-city convergence run complete;
the latter required a higher iteration ceiling at unchanged tolerance. CPU
contact lifecycle integration remains unfinished. See
[GPU ownership and qualification](GPU_OWNERSHIP.md) for the inherited machinery,
our bridge, failed 2,048-iteration run and remaining device-integration work.
