# Downtown destruction candidate screens

RTX 4090; 27 buildings, 24,105 chunks, 74,543 bonds. Direct GPU API off, native sleeping on, dt 1/60, at most one correction and two stress/fracture evaluations per tick. Each row is one 600-step (10 simulated seconds) run: zero projectiles for pristine idle, three recorded projectiles for destruction.

Complete-step timer includes physical commands, physics, stress, fracture/correction, mandatory completion and game observation staging. Asset preparation, rendering, network encoding and report generation are excluded. First-step and all later spikes are retained.

| Implementation / regime | Decision | Mean ms | Median ms | First step ms | All-step peak ms | Destruction/aftermath peak ms | New-fracture peak ms | Missed 60 Hz / 600 |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| deployed / idle | 🟰 comparison / intermediate | 5.252 | 4.185 | 631.682 | 631.682 | — | — | 1 |
| deployed / shots | 🟰 comparison / intermediate | 63.855 | 62.953 | 616.620 | 719.880 | 719.880 | 719.880 | 542 |
| vibe-coarse-assembly-20260908/screen-b / idle | 🟰 comparison / intermediate | 4.989 | 4.203 | 471.200 | 471.200 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-b / shots | 🟰 comparison / intermediate | 61.734 | 62.905 | 472.388 | 472.388 | 464.168 | 464.168 | 542 |
| vibe-coarse-assembly-20260908/screen-tiled / idle | ✅ superseded | 3.370 | 2.730 | 383.681 | 383.681 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-tiled / shots | ✅ superseded | 42.380 | 42.266 | 379.673 | 401.941 | 401.941 | 401.941 | 541 |
| vibe-coarse-assembly-20260908/screen-members / idle | ✅ superseded | 3.220 | 2.586 | 378.842 | 378.842 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-members / shots | ✅ superseded | 40.312 | 40.171 | 368.856 | 395.103 | 395.103 | 395.103 | 540 |
| vibe-coarse-assembly-20260908/screen-self-cache / idle | ✅ superseded | 2.887 | 2.329 | 332.011 | 332.011 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-self-cache / shots | ✅ superseded | 36.668 | 36.719 | 324.139 | 335.232 | 335.232 | 335.232 | 537 |
| vibe-coarse-assembly-20260908/screen-wide-cache / idle | ✅ superseded | 2.653 | 2.130 | 311.800 | 311.800 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-wide-cache / shots | ✅ superseded | 33.815 | 33.183 | 309.047 | 321.122 | 321.122 | 321.122 | 534 |
| vibe-coarse-assembly-20260908/screen-compact-build / idle | ✅ superseded | 2.562 | 2.125 | 257.993 | 257.993 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-compact-build / shots | ✅ superseded | 32.559 | 33.015 | 249.996 | 249.996 | 222.105 | 222.105 | 533 |
| vibe-coarse-assembly-20260908/screen-cached-rows / idle | ❌ smaller row groups reverted | 3.029 | 2.615 | 247.646 | 247.646 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-cached-rows / shots | ❌ smaller row groups reverted | 42.310 | 44.548 | 239.748 | 239.748 | 174.392 | 174.392 | 541 |
| vibe-coarse-assembly-20260908/screen-expanded-cache / idle | ✅ retained cache | 2.426 | 2.074 | 209.861 | 209.861 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-expanded-cache / shots | ✅ retained cache | 30.247 | 31.479 | 206.320 | 206.320 | 132.568 | 132.568 | 527 |
| vibe-coarse-assembly-20260908/screen-resident-grid / idle | ✅ retained large solver schedule | 2.495 | 2.142 | 208.022 | 208.022 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-resident-grid / shots | ✅ retained large solver schedule | 28.877 | 30.046 | 201.847 | 201.847 | 130.255 | 130.255 | 525 |
| vibe-coarse-assembly-20260908/screen-grid-constant / idle | ❌ annotation reverted | 2.486 | 2.125 | 208.724 | 208.724 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-grid-constant / shots | ❌ annotation reverted | 28.936 | 30.086 | 201.379 | 201.379 | 130.187 | 130.187 | 525 |
| vibe-coarse-assembly-20260908/screen-narrow-inverse / idle | ✅ narrow call retained; no timing win | 2.469 | 2.119 | 207.461 | 207.461 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-narrow-inverse / shots | ✅ narrow call retained; no timing win | 28.970 | 30.130 | 199.904 | 199.904 | 130.319 | 130.319 | 524 |

Destruction/aftermath starts at the first recorded command and includes settling. New-fracture peaks require an increase in broken bonds. Neither replaces the all-step peak.

These are short screens, not five-trial or endurance qualification. Physical counter differences and peak workload details are retained in [analysis.json](analysis.json); equal final counts do not prove identical trajectories. The independent wall and hierarchy quality checks are recorded separately.

The deployed comparison arm is the prior embedded runtime. This report does not establish superiority over the external Vibe-land/Blast baseline.
