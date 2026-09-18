# 102,400-chunk PhysX GPU bombardment — 2026-09-05

A standalone, source-built PhysX GPU scene completed 32 seconds of distributed
bombardment. The native capture checks passed. **The current CPU-orchestrated
reference destruction path does not meet 60 Hz at this workload.** The planned
engine-owned GPU destruction integration remains unfinished.

## Videos and reproduction

Workspace artifacts:

- `out/recordings/physx-100k-bombardment-20260905/physx-gpu-destruction-demo.mp4`: city overview.
- `out/recordings/physx-100k-bombardment-20260905/city-detail.mp4`: neighborhood view of the same captured world.
- Each is H.264, 1920×1080, 60 fps, 1,921 frames, 32.016667 seconds. Both streams
  were fully decoded and their frame counts checked. The extra initial state
  accounts for the fraction of a second beyond the 32 simulated seconds.

```sh
python3 tools/scripts/record-destruction-demo.py --build --scenes city \
  --city-grid 40 --city-target-stride 4 --city-waves 4 \
  --city-duration 30 --city-launch-window 24 \
  --render-diagnostic-on-failure
```

The actual capture used previously built binaries and a fresh explicit output
directory. Its exact commands, binary/module/asset hashes, per-step telemetry,
GPU samples and original source patch are beside the videos. All original
manifest artifact hashes were verified after recording. The source patch hash
matches the working-tree diff recorded at the start. A copy of the manifest is
[`captures/20260905-100k.json`](captures/20260905-100k.json).

## Workload and results

| Quantity | Measured/configured value |
|---|---:|
| Buildings / initial rigid clusters | 1,600 |
| Authored chunks | 102,400 |
| Authored bonds | 211,200 |
| Directly targeted buildings | 100, distributed across the city |
| Projectiles launched and retained through the end | 400 |
| Structures with visibly moved chunks, including secondary impacts | 157 |
| Peak destruction bodies, including supported clusters | 9,491 |
| Peak awake destruction bodies | 3,069 |
| Moved / fallen chunks | 6,971 / 6,523 |
| Split events / crushed chunks | 1,753 / 572 |
| Stress-contact records processed, including correction work | 101,111,388 |
| Extra correction passes | 1,229; maximum 8 in one step |
| Simulated duration / simulation wall time | 32 s / 123.004 s |
| Host step p50 / p95 / p99 | 35.633 / 203.190 / 316.304 ms |
| Worst host step | 574.794 ms |
| Steps exceeding 16.667 ms | 1,736 of 1,920 |
| Peak sampled total GPU memory | 10,513 MiB |
| Peak sampled total GPU utilization | 55% |

The authored count describes resident geometry/bonds; it is not a claim that
102,400 independently moving chunks collapsed simultaneously. All buildings
remain in the same scene and participate in contact/stress/correction. The
launch pattern targets every fourth row and column; it changes no collision
filter, material law or fracture threshold. Projectiles are not retired after
impact. No fracture-count budget, scoped freezing or quiet-checkpoint omission
was enabled. Actual forward/opposite wave launch masses and speeds are recorded
in the manifest; unity impulse-to-load transfer is retained.

This was a single development run on a shared RTX 4090. No other developer's
services were stopped. GPU samples include other workloads where present.
The result is neither an isolated five-trial scaling campaign nor a measurement
of a complete game tick. Offline 60 fps rendering does not establish real-time
simulation performance.

## What a correction pass does here

The reference adapter solves an intact contact, sends its actual solved impulses
to stress/material evaluation, changes topology, restores pre-step motion and
solves the same timestep again. Ordinary participants, including the projectiles,
are restored too. Further topology changes require another pass. Simulation time
advances once. These recordings use full-scene correction with a 64-pass failure
guard; this capture needed at most eight passes in a step.

Recorded restore plus repeated physics and stress orchestration consumed about
65.4 seconds of the 123-second run. Checkpoint capture added another 3.85 seconds.
These serial phase counters show why whole-scene replay is a substantial target
for optimization. Per-structure CPU/GPU stress timers are accumulated across
concurrent work and must not be added together as elapsed wall time.

The migration target is persistent engine-owned GPU chunk/cluster collision
ownership, device load/material/topology evaluation and internal correction with
validated reuse and affected-participant work sets. Geometry/motion separation
saves intact motion states; resolving the changed interaction is still necessary
to preserve the impulse-driven fracture result.

## Validation and remaining failures

This capture had zero dropped contacts, frozen outsiders or incomplete correction
steps, retained all 400 launched balls, and remained intact before launch. Peak
split position drift was 0.0000641182 m; peak point-velocity drift was
0.000923457 m/s. Both passed the existing 0.001 tolerances. Native exit status
was zero. Six selected CPU/GPU contract, replay, velocity and crushing regressions
passed; their log is in `baseline/bombardment-regression.log`. This does not
supersede the broader pre-existing failures tracked in `IMPLEMENTATION.md`.

A different, denser 400-building probe failed: 800 shots over seven seconds first
exhausted eight correction passes at step 174. With a 64-pass ceiling it completed
12 seconds but exceeded point-velocity continuity at 0.00103771 m/s. Its failed
report is retained in `captures/20260905-400-buildings-failed.json`; the tolerance
was not loosened. Different attack density makes it unsuitable for a speedup or
scene-size comparison with the distributed city capture.
