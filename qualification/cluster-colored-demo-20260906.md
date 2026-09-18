# Stable cluster colors and partial-impact demo — 2026-09-06

`--color-by-cluster 1` derives each visible chunk's color from accepted GPU
cluster root and generation. Connected chunks share a color; motion and packed
slot order do not change it. A recycled generation gets a different color.
Colors are hashed visual aids, not globally unique IDs. The white projectile is
visually distinct from the connected-group palette. Defaults preserve the former
building palette and orange projectile.

Coloring runs in the existing CUDA-to-OpenGL instance writer. It introduces no
normal-path CPU topology or pose readback and does not change physics. The
optional motion audit used for membership verification remains explicit CPU
observation outside simulation timing.

## Demonstrations

The original projectile mass was 20,000 kg. A new explicit `--projectile-mass`
option preserves that default and permits authored comparison loads. Both cases
below use identical 444-chunk/896-bond buildings, projectile radius/launch path,
materials, solver settings and a limit of one correction per step. Only the
projectile mass and its corresponding sphere inertia differ physically.

| Result after 10 s | Partial impact | Original heavy impact |
|---|---:|---:|
| Projectile mass | 200 kg | 20,000 kg |
| Broken bonds | 12 | 784 |
| Connected rigid clusters | 2 | 381 |
| Corrected steps | 1 | 5 |
| Simulation mean / min / max | 2.303 / 0.519 / 6.621 ms | 1.200 / 0.519 / 8.603 ms |

In the partial case, every observed frame after the split has **443 chunks in
supported root 0, generation 1**, and **one detached chunk in root 420,
generation 1**. Root 0 retains its red color; root 420 is green. Before the split,
all 444 chunks belong to root 0. These are actual connectivity observations, not
visual groups or artificial bonds.

The selected clip demonstrates a chip separating while the structure remains
connected. It does not claim a large section separates intact. Lighter mass
controls were explored explicitly: 10–100 kg caused no fracture and tripped the
demo's existing destruction-demonstration gate; 125–210 kg left two groups;
220 kg left three; 230 kg and above could trigger large subsequent collapse.
No material parameters, convergence requirements or fracture suppression were
used to manufacture a partial result.

The partial case is not necessarily cheaper per step: during its final two
seconds it still processes 772 active stress bonds and reports 123 iterations
per step. The heavy case has zero active stress bonds/iterations at that point.
These are different physical workloads, not a performance comparison between
implementations. Timings exclude rendering/observation/encoding and are not
isolated throughput qualification.

## Timing operations in plain language

These times explain the **previous 8.992 ms first-impact profile of the 20-tonne
case**, not the new 200 kg clip. They are elapsed wall times including applicable
CPU submission and waiting, not exclusively CPU or GPU compute times.

| Operation | What it does | Where it runs now | Time |
|---|---|---|---:|
| Ordinary trial and remaining scene work | Find collisions and solve the impact with the building still intact; run scene tasks. | GPU collision/rigid-body calculations; CPU task, contact and island bookkeeping. This row includes an explicit unscoped remainder. | 1.123 ms |
| Checkpoint | Save starting rigid-body state so correction can rewind. | GPU-to-GPU copy; CPU submits it. | 0.010 ms |
| Submit destruction | Queue conversion of actual contact impulses into loads, stress, fracture and topology work. | CPU queues CUDA kernels/graphs; calculations run on GPU. | 0.306 ms |
| Wait for destruction | Await the already-submitted fracture result before reserving its new bodies. | CPU waits while GPU progresses; not an additional physical calculation. | 3.195 ms |
| Reserve bodies and finish bookkeeping | Reserve native PhysX records for the newly separated rigid groups. | CPU allocation/lifecycle records, with compact metadata readback and upload. | 0.595 ms |
| Initialize bodies | Install each new group's mass, center of mass, inertia and motion. | GPU kernels; CPU dispatch/completion handling. | 0.093 ms |
| Prepare collision bindings | Determine which persistent chunk shapes now belong to which rigid groups. | GPU mapping/compaction, plus CPU receipt of preparation status. | 0.137 ms |
| Prepare correction bodies | Compute the groups' starting motion from the saved state for the corrected step. | GPU calculations, plus CPU status/dispatch handling. | 0.140 ms |
| Apply ownership changes | Update native actor/shape ownership and lifecycle metadata. | CPU bookkeeping after GPU metadata readback. | 0.471 ms |
| Restore/install motion | Rewind saved bodies and install new-group motion and GPU shape ownership. | GPU state restoration; CPU clears pending upload flags. | 0.042 ms |
| Reset contact caches | Remove cached solver/friction data that is invalid after the split. | GPU cache resets; CPU dispatch. | 0.006 ms |
| Corrected collision/solve | Recompute the physical interaction with the fractured groups. | GPU collision/rigid-body solve; CPU contacts, islands and task scheduling. | 2.759 ms |
| Accept correction | Commit topology, damage and final motion, then accept native reservations. | GPU commits; CPU status receipt and lifecycle acceptance. | 0.116 ms |
| **Total** | | | **8.992 ms** |

The GPU-stream work overlapping submission/wait includes 0.051 ms contact loads,
3.129 ms stress, 0.020 ms material evaluation, 0.118 ms connectivity/mass/candidate
preparation and 0.031 ms topology commit/stress-graph update. Do not add these to
the wall-time table. The detailed timing report records GPU execution and overlap
separately: `qualification/single-impact-timing-20260906.md`.

## Artifacts, commands and checks

- Partial video: `out/cluster-demo-20260906/partial-labeled.mp4`.
- Original heavy impact with colors: `out/cluster-demo-20260906/heavy-labeled.mp4`.
- Exact final commands: `out/cluster-demo-20260906/{partial-final,heavy-final}/command.json`.
- Membership trace: `out/cluster-demo-20260906/partial-colored/native.motion.csv`.
- Selected membership snapshots: `out/cluster-demo-20260906/partial-colored/cluster-observations.json`.
- GPU coloring/clearance, consumer, renderer and projectile launch tests: **4/4 pass**;
  log `out/cluster-color-final-tests.log`.
- GPU unit coverage includes same-color connected chunks with different authored
  palettes, distinct groups, unchanged transforms, stable unaffected groups,
  generation reuse, neutral projectile color and stale-handle rejection.
- Final partial rendering and audited capture match all 600 steps for group count,
  fracture decisions, correction counts, stress iterations and contact reports.
- Annotation changes exported pixels only; the GPU renderer already supplied
  cluster-colored geometry. The annotation script records counts and timing.

To repeat, use the saved command with unused output/video paths. The reusable
annotation command is:

```bash
python3 tools/scripts/annotate-native-cluster-video.py \
  out/cluster-demo-20260906/partial-final \
  out/cluster-demo-20260906/partial-final.mp4 \
  out/cluster-demo-20260906/partial-labeled-reproduction.mp4 \
  --group-observations out/cluster-demo-20260906/partial-colored/native.motion.csv
```
