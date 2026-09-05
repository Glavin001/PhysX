# Standalone GPU destruction demo

The demo runs wholly inside this PhysX checkout. It uses the source-built PhysX
GPU rigid-body pipeline and CUDA stress solver, with the **external reference's
CPU load preparation, material/fracture processing and replay orchestration**.
It does not yet exercise engine-owned GPU chunk collision ownership or internal
fracture correction in PhysX's task graph.

## Reproduce

From the repository root:

```sh
python3 tools/scripts/record-destruction-demo.py --build
```

After the SDK and recorder are built:

```sh
python3 tools/scripts/record-destruction-demo.py
```

Requirements: the SDK's Linux/CUDA build prerequisites, Rust/Cargo, a Vulkan-capable
NVIDIA GPU, `ffmpeg`, `ffprobe`, and `nvidia-smi`. No display server, browser, game
server or deployment is required. Outputs go to a fresh timestamped directory
under `out/recordings/`. `--output-dir PATH` selects a new directory;
`--scenes wall` records only the wall. The script refuses to mix a new run with
an existing output directory.

The output `physx-gpu-destruction-demo.mp4` combines:

| Scene | Authored chunks | Projectile | Recorded simulation |
|---|---:|---|---:|
| Wall impact/crushing | 216 | 4,800 kg at 51.45 m/s | 2 s settling + 8 s |
| Heavy building impact/collapse | 64 | 16,000 kg at 18.9 m/s | 2 s settling + 10 s |

The material tables and contact gain stay at their authored values; gain is
one in both selected assets. Projectile mass/speed are explicit physical inputs,
not a modification to transferred impulses. The heavy building case uses the
existing hard-impact mass scale. Each projectile remains alive throughout its
capture. All material verdicts and fracture counts remain uncapped. Reference
correction has an eight-pass guard: if that is insufficient, recording fails.
There is no scoped freezing or quiet-checkpoint omission in this preset.

The pass limits below belong to the historical multi-pass reference demo. They
are a departure from the intended single-rewind native lifecycle; see
[resimulation terminology and counts](RESIMULATION.md).

## Sustained city bombardment

```sh
python3 tools/scripts/record-destruction-demo.py --scenes city --city-grid 20
```

The city preset uses 400 three-floor buildings (25,600 authored chunks), four
waves totaling 1,600 projectiles, 2 seconds of intact settling, launches across
48 seconds, and aftermath to 60 seconds. `--city-grid`, `--city-waves`,
`--city-duration` (excluding settling) and `--city-launch-window` are configurable.
The default city grid is 12; the command above explicitly selects 20.

Shots begin above the tallest building, alternate their approach between waves,
and remain physical bodies through the end. The forward waves launch 16,000 kg
balls at 37.8 m/s; opposite waves use 18,400 kg at 32.4 m/s. Gravity subsequently
changes their speed. Materials, stress thresholds and unity impulse transfer
remain unchanged. The renderer follows captured poses; it does not script collapse.

The native demo exposes `--projectile-pattern overhead`, `--keep-projectiles`
and `--projectile-launch-window SECONDS` independently of the old TTL-based
facade demo. The city preset permits up to 64 correction passes, still failing
explicitly if topology changes exhaust that guard. This was necessary after the
400-building sizing probe hit the old eight-pass limit at step 174. The native
CLI accepts 0–256 passes; legacy presets retain their previous values.
The native grid limit is now 64 (up to 4,096 instances of the selected asset).

The city report includes peak destruction/awake body counts, retained balls,
contacts, stress transfer bytes, per-phase step timings and missed 16.67 ms
deadlines. Destruction body counts include supported clusters, so they are not
counts of independently moving chunks. Phase totals overlap (and per-structure
stress work can run concurrently); do not sum them as elapsed frame time.
GPU utilization/memory is sampled throughout simulation into `city.gpu.csv`.
This is a shared-GPU development stress run, not an isolated scale certification.

## 100,000-chunk distributed bombardment

```sh
python3 tools/scripts/record-destruction-demo.py --scenes city \
  --city-grid 40 --city-target-stride 4 --city-waves 4 \
  --city-duration 30 --city-launch-window 24
```

This scene contains **1,600 buildings, 102,400 authored chunks and 211,200 authored
bonds**. The initial intact structures share one rigid motion state per building.
The attack targets every fourth row and column: **100 buildings receive 400 shots**
over 24 seconds, after two seconds of settling, followed by six seconds of
additional simulation. Untargeted structures still participate in ordinary
collision, stress and correction, including any secondary impacts. The attack
selection is an authored workload; it changes no collision or fracture filters.
This exercises a large resident city with distributed destruction. Its actual
active-body count must be reported separately from its authored chunk count.

`city-detail.mp4` is a neighborhood camera of the **same captured scene**. It
introduces no separate simulation or reduced workload. Both videos use all 1,921
captured states at 60 fps (32.017 seconds including the initial state).

By default, failed native/continuity validation stops the recording workflow.
The optional `--render-diagnostic-on-failure` preserves a video of a completed
capture that failed final validation. Its HUD says **VALIDATION FAILED**, its
manifest status is `diagnostic-failed-validation`, and the script exits **2**.
It does not change the 1e-3 continuity tolerance or accept incomplete correction,
non-finite diagnostics, dropped contacts or missing simulation steps. Such a
video is evidence of a failure, not a passing result.

The 400-building, 800-shot sizing probe with a 7-second launch window exposed
two reference-path limits: an eight-pass run stopped at step 174; a 64-pass run
completed 720 steps but failed velocity continuity at **0.00103771 m/s** against
**0.001 m/s**. Its peak position drift was 0.00004278 m and it needed 1,485
correction passes. The failure is retained; no material or tolerance was changed
to make the stress run pass. This probe is distinct from the longer distributed
100,000-chunk workload above, so its timings are not a scaling comparison.

## What is verified

The script requires active GPU physics, actual CUDA stress work, intact topology
before launch, a real projectile impulse, visible fracture motion, split
continuity within the existing 1e-3 tolerances, zero dropped contacts, zero frozen
outsiders, and no incomplete corrections. It saves per-step telemetry, raw state
streams, exact commands, asset/binary hashes, revision/working-tree provenance,
GPU observations and a validation report. It counts and decodes the finished
H.264 stream to check that all captured frames are present.

Rendering happens **after** simulation. The video is 1920×1080 at 60 fps and lasts
about 22 seconds for the wall/building pair, or 60 seconds for the city. That playback rate is not a claim of qualified real-time engine
performance. Recorded step timings are development diagnostics; this is not the
five-trial isolated scaling campaign. The rendering grid represents the existing
y=0 ground plane. Yellow dust particles are visual effects driven by crush events.

A verified capture is available in this workspace at:

`out/recordings/destruction-demo-20260905-v2/physx-gpu-destruction-demo.mp4`

The same directory contains `manifest.json`, `wall.validation.json`,
`building.validation.json`, both source clips and their state/telemetry sidecars.
Generated media are intentionally excluded from Git.

The measured 100,000-chunk run and both video paths are documented in
[`100K_BOMBARDMENT.md`](100K_BOMBARDMENT.md).

## Next engine milestone

Use this scene and capture protocol to qualify each migration step:

1. Bind persistent chunk collision identities to the GPU cluster ownership/motion
   state. Update solver ownership and contact eligibility through native topology
   transactions instead of CPU shape detach/attach operations.
2. Feed solved normal/friction impulses, application points and support evidence
   into GPU loads and the complete stress/material/crush verdict.
3. Move checkpoint, topology change and correction into PhysX's task graph;
   include ordinary bodies and joints, prevent repeated damage/commands, and
   publish observations/events only after commit.
4. Run the same controlled impacts against the reference, then qualify larger
   collapse/rubble workloads and record a video of the integrated implementation.

The native fidelity issues, including the newly exposed ordinary-impact crushing
failure, are tracked in `CONTACT_STRESS_FIXES.md` and `IMPLEMENTATION.md`.
The complete engine plan remains unfinished.
