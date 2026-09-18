# Downtown destruction candidate screens

RTX 4090; 27 buildings, 24,105 chunks, 74,543 bonds. Direct GPU API off, native sleeping on, dt 1/60, at most one correction and two stress/fracture evaluations per tick. Each row is one 600-step (10 simulated seconds) run: zero projectiles for pristine idle, three recorded projectiles for destruction.

Complete-step timer includes physical commands, physics, stress, fracture/correction, mandatory completion and game observation staging. Asset preparation, rendering, network encoding and report generation are excluded. First-step and all later spikes are retained.

| Implementation / regime | Decision | Mean ms | Median ms | First step ms | All-step peak ms | Destruction/aftermath peak ms | New-fracture peak ms | Missed 60 Hz / 600 |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| deployed / idle | reference | 5.252 | 4.185 | 631.682 | 631.682 | — | — | 1 |
| deployed / shots | reference | 63.855 | 62.953 | 616.620 | 719.880 | 719.880 | 719.880 | 542 |
| vibe-coarse-assembly-20260908/screen-narrow-inverse / idle | 🟰 deployed reference | 2.469 | 2.119 | 207.461 | 207.461 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-narrow-inverse / shots | 🟰 deployed reference | 28.970 | 30.130 | 199.904 | 199.904 | 130.319 | 130.319 | 524 |
| vibe-coarse-assembly-20260908/screen-canonical-norm / idle | 🗑️ redundant endpoint work removed; no robust peak win | 2.457 | 2.110 | 207.185 | 207.185 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-canonical-norm / shots | 🗑️ redundant endpoint work removed; no robust peak win | 28.859 | 30.128 | 200.515 | 200.515 | 130.559 | 130.559 | 524 |
| vibe-coarse-assembly-20260908/screen-warm-residual / idle | ✅ accurate warm initialization; idle improvement, scale still fails | 1.000 | 0.641 | 209.173 | 209.173 | — | — | 1 |
| vibe-coarse-assembly-20260908/screen-warm-residual / shots | ✅ accurate warm initialization; idle improvement, scale still fails | 28.175 | 29.486 | 201.239 | 201.239 | 129.777 | 129.777 | 522 |

Destruction/aftermath starts at the first recorded command and includes settling. New-fracture peaks require an increase in broken bonds. Neither replaces the all-step peak.

These are short screens, not five-trial or endurance qualification. Physical counter differences and peak workload details are retained in [analysis.json](analysis.json); equal final counts do not prove identical trajectories. The independent wall and hierarchy quality checks are recorded separately.

The deployed comparison arm is the prior embedded runtime. This report does not establish superiority over the external Vibe-land/Blast baseline.
