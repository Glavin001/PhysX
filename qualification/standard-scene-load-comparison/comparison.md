# Ordinary PhysX GPU + embedded destruction: load comparison

**Direct GPU OFF · Sleeping ON · CUDA physics/destruction · resim limit 1 · dt 1/60 s.**

Procedural native buildings and ballistic projectiles approximate the recorded work range; they do not reproduce Vibe-land geometry, hitscan inputs, materials or convergence/freezing policy. All scenes use the same physical parameters: 18,000 kg projectiles, wall strength scale 24, frame strength scale 40, stress tolerance 1e-5 and maximum 8,192 iterations with convergence required.

Each measured run covers 30 simulated seconds / 1,800 steps. A separate warm-up precedes two unrendered trials; no first-step or allocation outlier is removed. Phase captures and videos run separately. Complete-step timing includes commands, physics, destruction, correction and mandatory completion, excluding setup, optional observation, graphics and encoding.

## Unrendered measurements

| Buildings / trial | Chunks / bonds / projectiles | Peak bodies / awake | Broken bonds | Min / mean / p95 / max ms | >16.667 ms | >8 ms |
|---|---|---|---:|---|---:|---:|
| 16 / 1 | 7,104 / 14,336 / 48 | 2,340 / 1,557 | 7,024 | 0.66 / 9.73 / 18.06 / 28.15 | 136/1800 | 996/1800 |
| 64 / 1 | 28,416 / 57,344 / 192 | 7,906 / 4,369 | 26,018 | 0.80 / 18.82 / 41.48 / 48.50 | 758/1800 | 1719/1800 |
| 256 / 1 | 113,664 / 229,376 / 768 | 34,320 / 20,903 | 107,620 | 2.72 / 111.48 / 264.26 / 309.16 | 1516/1800 | 1719/1800 |
| 16 / 2 | 7,104 / 14,336 / 48 | 2,228 / 1,423 | 6,871 | 0.63 / 10.90 / 18.57 / 29.04 | 152/1800 | 1651/1800 |
| 64 / 2 | 28,416 / 57,344 / 192 | 8,277 / 4,821 | 26,537 | 0.82 / 19.72 / 44.51 / 53.00 | 737/1800 | 1719/1800 |
| 256 / 2 | 113,664 / 229,376 / 768 | 33,967 / 20,328 | 107,306 | 2.69 / 114.05 / 266.93 / 301.03 | 1640/1800 | 1719/1800 |

## Impacts, correction and late rubble

| Buildings / trial | Subset | Steps | Mean / max ms |
|---|---|---:|---|
| 16 / 1 | impact_0_to_15s | 900 | 11.92 / 28.15 |
| 16 / 1 | rubble_20_to_30s | 600 | 7.11 / 11.03 |
| 16 / 1 | corrected_steps | 211 | 17.49 / 28.15 |
| 64 / 1 | impact_0_to_15s | 900 | 25.75 / 48.50 |
| 64 / 1 | rubble_20_to_30s | 600 | 10.13 / 23.33 |
| 64 / 1 | corrected_steps | 640 | 32.44 / 48.50 |
| 256 / 1 | impact_0_to_15s | 900 | 161.46 / 309.16 |
| 256 / 1 | rubble_20_to_30s | 600 | 23.80 / 125.78 |
| 256 / 1 | corrected_steps | 1036 | 180.03 / 309.16 |
| 16 / 2 | impact_0_to_15s | 900 | 12.47 / 29.04 |
| 16 / 2 | rubble_20_to_30s | 600 | 8.80 / 13.82 |
| 16 / 2 | corrected_steps | 217 | 17.85 / 29.04 |
| 64 / 2 | impact_0_to_15s | 900 | 26.69 / 53.00 |
| 64 / 2 | rubble_20_to_30s | 600 | 11.32 / 24.01 |
| 64 / 2 | corrected_steps | 620 | 34.41 / 53.00 |
| 256 / 2 | impact_0_to_15s | 900 | 166.30 / 301.03 |
| 256 / 2 | rubble_20_to_30s | 600 | 26.23 / 130.90 |
| 256 / 2 | corrected_steps | 1036 | 183.80 / 301.03 |

## Closest recorded workload bands

Only the newest verified Vibe-land executable/session with resim=1 is used. Its player reports show 96,420 chunks; total authored bonds are absent. Newer headless observations lack their own geometry count. Vibe timings are broader server-tick rolling windows. We select a non-overlapping 180-step native band using body, awake and broken-bond counts (sum of absolute log ratios), never its timing. Native bodies/awake are band medians; broken bonds are cumulative at band end. Vibe counters are snapshots. These bands are descriptive comparisons, not matched trials or a scale model. Native body counts include spawned projectiles; Vibe city body counts exclude other gameplay actors. The native stress graph is partitioned into many small buildings, unlike the city asset, so matching chunk totals does not match connected solve complexity.

| Reference / native band | Bodies / awake / broken bonds | Mean / p95 / max ms |
|---|---|---|
| Vibe 2026-09-06T04:46:05.665Z (player) | 2,187 / 1,579 / 7,717 | 24.57 / 48.38 / 91.77 |
| Native sleeping-16-plain-0, steps 540–719 | 2,249 / 1,364 / 6,978 | 13.26 / 22.43 / 28.15 |
| Vibe 2026-09-06T04:47:58.335Z (player) | 9,581 / 7,887 / 35,434 | 235.51 / 450.28 / 487.70 |
| Native sleeping-256-plain-0, steps 180–359 | 10,326 / 8,226 / 69,663 | 92.53 / 136.79 / 148.23 |
| Vibe 2026-09-06T07:55:48.657Z (headless) | 34,172 / 9,641 / 126,442 | 152.26 / 174.05 / 192.33 |
| Native sleeping-256-plain-0, steps 900–1079 | 33,939 / 11,627 / 107,387 | 180.75 / 246.93 / 276.66 |

## Separately measured phase peaks

These are the instrumented runs, not a decomposition of an unrendered peak. Correction includes CPU scheduling/lifecycle and GPU physics. The GPU stress stage overlaps the CPU wait for destruction; never add both to the total.

| Buildings | Scoped complete peak ms | Correction ms | Trial/remaining ms | Wait for destruction ms | GPU stress ms (overlapping) |
|---|---:|---:|---:|---:|---:|
| sleeping-16 | 23.33 | 4.93 | 2.67 | 14.31 | 14.05 |
| sleeping-64 | 51.45 | 30.31 | 6.22 | 12.96 | 12.58 |
| sleeping-256 | 283.67 | 219.54 | 31.51 | 28.37 | 27.31 |

The full phase report expands fragment allocation, ownership migration, contact-manager registration, island updates, checkpoint/restore, stress/material/topology stages and accepted publication, with CPU/GPU owners. Task scopes can overlap and are not isolated GPU kernel timings.

## Videos

Video recordings are separate physical runs and can fracture differently. On-screen timing comes from that exact video capture, not the unrendered trials.

- [256-building video](/root/workspace/physx-2/out/standard-scene-load-videos/sleeping-256/native-captioned.mp4): 113,664 chunks, 229,376 bonds, 768 projectiles; 107,580 broken bonds; exact capture complete-step mean/max 111.21/303.57 ms.

- [64-building video](/root/workspace/physx-2/out/standard-scene-load-videos/sleeping-64/native-captioned.mp4): 28,416 chunks, 57,344 bonds, 192 projectiles; 26,467 broken bonds; exact capture complete-step mean/max 19.37/59.96 ms.

## Qualification limits and reproduction

Every completed run is checked for accepted steps, convergence, correction <=1, total broken-bond/correction consistency and complete-timer closure. These counters do not prove matching physical trajectories, collision/render parity, or absence of all geometry bugs. The ordinary-mode frozen penetration topology discrepancy remains open. This is not five 60-second trials or full lifecycle endurance. Absent solver-row/pair counters are not evidence that PhysX performed no work.

[Detailed timing and separate phase breakdown](timing/report.md) · [Machine-readable comparison](comparison.json)

`python3 tools/scripts/run-destruction-timing.py out/NEW --config tools/profiles/standard-scene-bombardment-comparison.json --trials 2 --seconds 30 --gate-only --phase-scopes`

Exit 2 from the timing report means a deadline/duration gate failed; it is not a failed simulation. Keep that result visible.
