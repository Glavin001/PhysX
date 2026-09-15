# Uninterrupted City256 qualification

Capture/check/restore-services time: 161.638s. A/B/B/A, separate processes; each runs600 consecutive ticks with no restore. First-use ticks stay included. Both scenes contain113,664 chunks and229,376 original bonds; heavy launches256 projectiles, idle launches none. Same fixed settings as the existing600-tick baseline.

All4,800 ticks pass exact work and iteration history, convergence and at-most-one-correction checks. This is not full pose/force/energy-array comparison at every tick. No renderer or auxiliary physical-state dump is enabled.

| Scenario/arm | Mean ms | Peak ms | First tick ms | Misses | Command ms | Physics ms | Completion ms | Initialization ms |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| idle-256-0-A | 1.430 | 14.156 | 14.156 | 0/600 | 0.000209 | 1.263 | 0.167 | 2232.932 |
| impacts-256-0-A | 51.011 | 184.139 | 50.909 | 519/600 | 0.053244 | 50.737 | 0.220 | 2150.326 |
| idle-256-1-B | 1.438 | 13.311 | 13.311 | 0/600 | 0.000265 | 1.280 | 0.158 | 2242.923 |
| impacts-256-1-B | 50.518 | 185.709 | 51.703 | 519/600 | 0.053301 | 50.249 | 0.215 | 2155.399 |
| idle-256-2-B | 1.671 | 14.143 | 14.143 | 0/600 | 0.000191 | 1.448 | 0.223 | 2160.882 |
| impacts-256-2-B | 50.527 | 179.420 | 52.411 | 519/600 | 0.055339 | 50.257 | 0.215 | 2203.444 |
| idle-256-3-A | 1.712 | 14.005 | 14.005 | 0/600 | 0.000263 | 1.477 | 0.235 | 2232.027 |
| impacts-256-3-A | 50.808 | 176.412 | 49.398 | 519/600 | 0.049452 | 50.542 | 0.217 | 2183.034 |

## Mean work per tick

| Scenario/arm | Stress iterations | Broken bonds | Corrections | Stress passes | Stress islands | Active nodes | Active bonds | Contacts | Awake bodies |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| idle-256-0-A | 0.147 | 0.000 | 0.000 | 1.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| impacts-256-0-A | 493.840 | 104.443 | 0.392 | 1.392 | 2362.528 | 87744.713 | 149121.685 | 84553.417 | 4716.278 |
| idle-256-1-B | 0.147 | 0.000 | 0.000 | 1.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| impacts-256-1-B | 493.840 | 104.443 | 0.392 | 1.392 | 2362.528 | 87744.713 | 149121.685 | 84553.417 | 4716.278 |
| idle-256-2-B | 0.147 | 0.000 | 0.000 | 1.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| impacts-256-2-B | 493.840 | 104.443 | 0.392 | 1.392 | 2362.528 | 87744.713 | 149121.685 | 84553.417 | 4716.278 |
| idle-256-3-A | 0.147 | 0.000 | 0.000 | 1.000 | 256.000 | 97280.000 | 200704.000 | 0.000 | 0.000 |
| impacts-256-3-A | 493.840 | 104.443 | 0.392 | 1.392 | 2362.528 | 87744.713 | 149121.685 | 84553.417 | 4716.278 |

Heavy has a small consistent mean signal, but unchanged deadline misses and overlapping peaks. Idle process variation covers both arms. No confidence interval based on treating individual ticks as independent is claimed. Preserve all controls, first-use costs and peaks.

Raw receipt: `out/ownership-scheduling-20260915/observation-continuous-v2/campaign.json`. CSV traces, native summaries, loaded-module hashes and exact work histories remain local ignored evidence.
