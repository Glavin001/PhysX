# Independent one-tick file replay

One full tick per fresh restore, fixed file inputs, ordinary GPU/TGS, dt=1/60, at most one correction. Independent physical reconstructions; shared-GPU descriptive timings, not matched A/B performance qualification. Restore includes scene creation and stress configuration; context initialization and validation are outside both reported intervals. No capture-prefix simulation.

| Saved scenario | n | Full tick mean / max ms | Median ms | Restore mean ms | >8 / >120Hz / >60Hz | Correction / stress evaluations |
|---|---:|---:|---:|---:|---|---|
| building-warm | 20 | 4.676 / 8.306 | 4.457 | 139.355 | 1 (5%) / 0 (0%) / 0 (0%) | [0] / [1] |
| building-fragmented | 20 | 8.909 / 13.781 | 8.439 | 142.725 | 18 (90%) / 13 (65%) / 0 (0%) | [0] / [1] |
| tower64-warm | 20 | 117.788 / 120.782 | 117.749 | 150.893 | 20 (100%) / 20 (100%) / 20 (100%) | [0] / [1] |
| destruction-damaged | 20 | 3.167 / 6.315 | 2.981 | 128.290 | 0 (0%) / 0 (0%) / 0 (0%) | [0] / [1] |
| destruction-onset-first-fracture | 20 | 11.186 / 19.042 | 10.869 | 128.062 | 20 (100%) / 19 (95%) / 1 (5%) | [1] / [2] |
| destruction-stimulus | 20 | 4.196 / 8.215 | 3.887 | 129.907 | 1 (5%) / 0 (0%) / 0 (0%) | [0] / [1] |

Every repeat passed the physical/material/motion checks. The adjacent JSON reports measured motion differences and fracture/correction counts for every scenario. These small/scaled fixtures are not the 256-building city benchmark.

The input hashes, iteration counts, ranges and raw sample locations are in the adjacent JSON. Repeat counts describe observed variability; they do not establish a candidate speedup or guarantee statistical significance. Retain continuous warm trajectories and matched A/B controls for optimization decisions.
