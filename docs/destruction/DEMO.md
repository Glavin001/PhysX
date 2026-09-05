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
| Wall impact/crushing | 216 | 4,800 kg at 49 m/s | 2 s settling + 8 s |
| Heavy building impact/collapse | 64 | 16,000 kg at 18 m/s | 2 s settling + 10 s |

The material tables and contact gain stay at their authored values; gain is
one in both selected assets. Projectile mass/speed are explicit physical inputs,
not a modification to transferred impulses. The heavy building case uses the
existing hard-impact mass scale. Each projectile remains alive throughout its
capture. All material verdicts and fracture counts remain uncapped. Reference
correction has an eight-pass guard: if that is insufficient, recording fails.
There is no scoped freezing or quiet-checkpoint omission in this preset.

## What is verified

The script requires active GPU physics, actual CUDA stress work, intact topology
before launch, a real projectile impulse, visible fracture motion, split
continuity within the existing 1e-3 tolerances, zero dropped contacts, zero frozen
outsiders, and no incomplete corrections. It saves per-step telemetry, raw state
streams, exact commands, asset/binary hashes, revision/working-tree provenance,
GPU observations and a validation report. It counts and decodes the finished
H.264 stream to check that all captured frames are present.

Rendering happens **after** simulation. The video is 1920×1080 at 60 fps and lasts
about 22 seconds. That playback rate is not a claim of qualified real-time engine
performance. Recorded step timings are development diagnostics; this is not the
five-trial isolated scaling campaign. The rendering grid represents the existing
y=0 ground plane. Yellow dust particles are visual effects driven by crush events.

A verified capture is available in this workspace at:

`out/recordings/destruction-demo-20260905-v2/physx-gpu-destruction-demo.mp4`

The same directory contains `manifest.json`, `wall.validation.json`,
`building.validation.json`, both source clips and their state/telemetry sidecars.
Generated media are intentionally excluded from Git.

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
