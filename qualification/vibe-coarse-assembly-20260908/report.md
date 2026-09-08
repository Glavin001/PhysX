# Downtown destruction candidate screens

RTX 4090; 27 buildings, 24,105 chunks, 74,543 bonds. Direct GPU API off, native sleeping on, dt 1/60, at most one correction and two stress/fracture evaluations per tick. Each row is one 600-step (10 simulated seconds) run: zero projectiles for pristine idle, three recorded projectiles for destruction.

Complete-step timer includes physical commands, physics, stress, fracture/correction, mandatory completion and game observation staging. Asset preparation, rendering, network encoding and report generation are excluded. First-step and all later spikes are retained.

| Implementation / regime | Mean ms | Median ms | First step ms | All-step peak ms | Destruction/aftermath peak ms | New-fracture peak ms | Missed 60 Hz / 600 |
|---|---:|---:|---:|---:|---:|---:|---:|
| deployed / idle | 5.252 | 4.185 | 631.682 | 631.682 | — | — | 1 |
| deployed / shots | 63.855 | 62.953 | 616.620 | 719.880 | 719.880 | 719.880 | 542 |
| vibe-coarse-assembly-20260908/screen-b / idle | 4.989 | 4.203 | 471.200 | 471.200 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-b / shots | 61.734 | 62.905 | 472.388 | 472.388 | 464.168 | 464.168 | 542 |
| vibe-coarse-assembly-20260908/screen-tiled / idle | 3.370 | 2.730 | 383.681 | 383.681 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-tiled / shots | 42.380 | 42.266 | 379.673 | 401.941 | 401.941 | 401.941 | 541 |
| vibe-coarse-assembly-20260908/screen-members / idle | 3.220 | 2.586 | 378.842 | 378.842 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-members / shots | 40.312 | 40.171 | 368.856 | 395.103 | 395.103 | 395.103 | 540 |

Destruction/aftermath starts at the first recorded command and includes settling. New-fracture peaks require an increase in broken bonds. Neither replaces the all-step peak.

These are short screens, not five-trial or endurance qualification. Physical counter differences and peak workload details are retained in [analysis.json](analysis.json); equal final counts do not prove identical trajectories. The independent wall and hierarchy quality checks are recorded separately.

The deployed comparison arm is the prior embedded runtime. This report does not establish superiority over the external Vibe-land/Blast baseline.
