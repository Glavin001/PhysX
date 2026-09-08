# Ordinary PhysX GPU + embedded destruction: load comparison

**Direct GPU OFF · Sleeping ON · CUDA physics/destruction · resim limit 1 · dt 1/60 s.**

Maximum stress/material evaluations per tick in these captures: 2.

Procedural native buildings and ballistic projectiles approximate the recorded work range; they do not reproduce Vibe-land geometry, hitscan inputs, materials or convergence/freezing policy. All scenes use the same physical parameters: 18,000 kg projectiles, wall strength scale 24, frame strength scale 40, stress tolerance 1e-5 and maximum 8,192 iterations with convergence required.

Each measured run covers 30 simulated seconds / 1,800 steps. A separate warm-up precedes two unrendered trials; no first-step or allocation outlier is removed. Phase captures and videos run separately. Complete-step timing includes commands, physics, destruction, correction and mandatory completion, excluding setup, optional observation, graphics and encoding.

## Unrendered measurements

| Buildings / trial | Chunks / bonds / projectiles | Peak bodies / awake | Broken bonds | Min / mean / p95 / max ms | >16.667 ms | >8 ms |
|---|---|---|---:|---|---:|---:|
| 256 / 1 | 113,664 / 229,376 / 768 | 40,926 / 26,039 | 116,609 | 2.70 / 47.12 / 76.73 / 118.47 | 1718/1800 | 1719/1800 |
| 256 / 2 | 113,664 / 229,376 / 768 | 39,505 / 25,312 | 114,982 | 2.71 / 50.12 / 79.43 / 143.40 | 1718/1800 | 1719/1800 |

## Impacts, correction and late rubble

| Buildings / trial | Subset | Steps | Mean / max ms |
|---|---|---:|---|
| 256 / 1 | impact_0_to_15s | 900 | 58.13 / 118.47 |
| 256 / 1 | rubble_20_to_30s | 600 | 35.93 / 59.86 |
| 256 / 1 | corrected_steps | 1198 | 60.23 / 118.47 |
| 256 / 2 | impact_0_to_15s | 900 | 59.41 / 107.95 |
| 256 / 2 | rubble_20_to_30s | 600 | 34.29 / 102.60 |
| 256 / 2 | corrected_steps | 981 | 67.58 / 143.40 |

## Closest recorded workload bands

Only the newest verified Vibe-land executable/session with resim=1 is used. Its player reports show 96,420 chunks; total authored bonds are absent. Newer headless observations lack their own geometry count. Vibe timings are broader server-tick rolling windows. We select a non-overlapping 180-step native band using body, awake and broken-bond counts (sum of absolute log ratios), never its timing. Native bodies/awake are band medians; broken bonds are cumulative at band end. Vibe counters are snapshots. These bands are descriptive comparisons, not matched trials or a scale model. Native body counts include spawned projectiles; Vibe city body counts exclude other gameplay actors. The native stress graph is partitioned into many small buildings, unlike the city asset, so matching chunk totals does not match connected solve complexity.

| Reference / native band | Bodies / awake / broken bonds | Mean / p95 / max ms |
|---|---|---|
| Vibe 2026-09-06T04:46:05.665Z (player) | 2,187 / 1,579 / 7,717 | 24.57 / 48.38 / 91.77 |
| Native sleeping-256-plain-0, steps 0–179 | 535 / 286 / 22,654 | 23.04 / 46.48 / 50.06 |
| Vibe 2026-09-06T04:47:58.335Z (player) | 9,581 / 7,887 / 35,434 | 235.51 / 450.28 / 487.70 |
| Native sleeping-256-plain-0, steps 180–359 | 11,548 / 9,152 / 78,378 | 59.44 / 72.86 / 87.35 |
| Vibe 2026-09-06T07:55:48.657Z (headless) | 34,172 / 9,641 / 126,442 | 152.26 / 174.05 / 192.33 |
| Native sleeping-256-plain-1, steps 1440–1619 | 39,501 / 9,951 / 114,977 | 27.63 / 30.48 / 58.72 |

## Videos

Video recordings are separate physical runs and can fracture differently. On-screen timing comes from that exact video capture, not the unrendered trials.

## Qualification limits and reproduction

Every completed run is checked for accepted steps, convergence, correction <=1, total broken-bond/correction consistency and complete-timer closure. These counters do not prove matching physical trajectories, collision/render parity, or absence of all geometry bugs. The ordinary-mode frozen penetration topology discrepancy remains open. This is not five 60-second trials or full lifecycle endurance. Absent solver-row/pair counters are not evidence that PhysX performed no work.

[Detailed timing and separate phase breakdown](timing/report.md) · [Machine-readable comparison](comparison.json)

`python3 tools/scripts/run-destruction-timing.py out/NEW --config tools/profiles/standard-scene-bombardment-comparison.json --trials 2 --seconds 30 --gate-only --phase-scopes`

Exit 2 from the timing report means a deadline/duration gate failed; it is not a failed simulation. Keep that result visible.
