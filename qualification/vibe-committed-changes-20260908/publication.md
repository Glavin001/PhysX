# Native committed publication

RTX 4090; Direct GPU API off, sleeping on, dt 1/60, correction ≤1 and stress evaluations ≤2. Each row retains every measured complete simulation step. The timer includes commands, physics, stress, correction, accepted events and game snapshot staging; excludes initialization, rendering, network encoding and report/audit work. First-step initialization performed inside advance remains measured.

| Capture | Buildings / chunks / bonds | Projectiles / steps | Complete mean / peak ms | Impact + aftermath peak ms | CPU event/snapshot mean / peak ms | GPU-selected chunks read by CPU, total | Readback MiB, total |
|---|---|---|---:|---:|---:|---:|---:|
| candidate-idle | 27 / 24,105 / 74,543 | 0 / 600 | 0.969 / 207.910 | 0.000 | 0.005 / 1.122 | 24,105 | 0.552 |
| candidate-shots | 27 / 24,105 / 74,543 | 3 / 600 | 28.112 / 201.408 | 128.767 | 0.014 / 0.970 | 36,428 | 0.836 |
| scale-idle | 256 / 113,664 / 229,376 | 0 / 600 | 0.836 / 160.005 | 0.000 | 0.012 / 3.976 | 113,664 | 2.602 |
| scale-shots | 256 / 113,664 / 229,376 | 768 / 600 | 45.284 / 160.760 | 134.091 | 3.122 / 11.626 | 823,263 | 19.149 |
| candidate1 | 256 / 113,664 / 229,376 | 768 / 600 | 47.698 / 161.653 | 137.259 | 3.036 / 12.299 | 826,282 | 19.218 |
| candidate2 | 256 / 113,664 / 229,376 | 768 / 600 | 44.285 / 159.157 | 136.942 | 2.874 / 12.027 | 822,368 | 19.128 |

A zero impact peak means no projectile commands. CPU event/snapshot time includes the explicit GPU readback and other game observation processing; it is not GPU kernel time. The byte counter covers topology publication only, not all simulation transfers. Readback totals include the initial full snapshot. Quiet ticks read no topology delta.

Publication is GPU-generated and compacted. CPU consumes changed group definitions; the renderer or another device consumer can instead use the ordered device view. The CPU compatibility actor creation and ordinary query mirror remain separate unfinished architecture work.

These short screens establish neither endurance nor every-step 60 Hz nor superiority over the historical user-land backend. Peak workload details and source paths are in [publication.json](publication.json).
