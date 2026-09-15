# Removal priorities from current per-component work

**The dominant iterative work is in surviving anchored structures, not tiny debris.** Across25/64/256 buildings, anchored components account for99.998/99.997/99.999% of node updates at first impact and99.625/99.405/99.429% at tick179. Before impact every one of the256 intact components already skips iteration. These are work shares, not wall-time savings.

Reused the existing native component recorder, adding an explicit settled-skip flag. Isolated diagnostic commit `16895e325d2f87e1ff8672825e73024de8e1d1f3`. All five continuous cases pass exact physical/work/iteration counters against matching uninstrumented controls:900 compared ticks,1800 executed control/diagnostic ticks. The one-building recorder also passes180 additional memcheck ticks with zero errors. Five accounting tests reject missing correction passes, contradictory skips and incorrect totals; larger unmeasured components remain explicit. There are no unmeasured large components in these city captures. This does not constitute a full physical body/force comparison or normal asynchronous production memory gate.

## Whole-step controls

One unprofiled180-tick control per case, ordinary APIs and sleeping, same timestep and correction cap. No restore occurs inside these continuous runs. These controls qualify the diagnostic history; they are not repeated candidate performance comparisons. Diagnostic timings are deliberately omitted because the recorder synchronizes and exports after each solve.

| Case | Chunks / bonds / projectiles | Full-step mean / peak ms | Peak tick | >60Hz /180 | Command / integrated physics+destruction / completion mean ms | Initialization ms |
|---|---:|---:|---:|---:|---:|---:|
| pilot-1 | 444 / 896 / 1 | 5.949 / 23.242 | 0 | 5 | 0.076393 / 5.681944 / 0.190916 | 669.971 |
| idle-256 | 113664 / 229376 / 0 | 1.691 / 14.162 | 0 | 0 | 0.000260 / 1.479933 / 0.210503 | 2347.989 |
| impacts-256 | 113664 / 229376 / 256 | 55.609 / 181.062 | 82 | 99 | 0.183223 / 55.220566 / 0.204999 | 2216.652 |
| impacts-25 | 11100 / 22400 / 25 | 13.263 / 45.200 | 102 | 48 | 0.069784 / 12.969980 / 0.223604 | 854.606 |
| impacts-64 | 28416 / 57344 / 64 | 19.775 / 53.643 | 82 | 94 | 0.087628 / 19.472003 / 0.215413 | 1559.870 |

## Semantic work checkpoints

Each row sums first and correction stress passes within the same tick. A component processed twice is counted twice. Node updates count dynamic nodes multiplied by executed direction/update sweeps, not floating-point operations or equal-cost iterations. Raw per-pass groups, residual sweeps, CSR visits and top components remain in the linked JSON.

| Case / tick | Stress passes | Component passes / settled passes | Node updates | Anchored share | Tiny (<=32 node) updates |
|---|---:|---:|---:|---:|---:|
| pilot-1 / 0 | 1 | 1 / 0 | 33440 | 100.0000% | 0 |
| pilot-1 / 81 | 1 | 1 / 1 | 0 | no updates | 0 |
| pilot-1 / 82 | 2 | 3 / 0 | 171888 | 99.9930% | 12 |
| pilot-1 / 103 | 2 | 15 / 6 | 241752 | 99.9851% | 36 |
| pilot-1 / 179 | 1 | 8 / 2 | 109564 | 99.9744% | 28 |
| idle-256 / 0 | 1 | 256 / 0 | 8560640 | 100.0000% | 0 |
| idle-256 / 81 | 1 | 256 / 256 | 0 | no updates | 0 |
| idle-256 / 82 | 1 | 256 / 256 | 0 | no updates | 0 |
| idle-256 / 103 | 1 | 256 / 256 | 0 | no updates | 0 |
| idle-256 / 179 | 1 | 256 / 256 | 0 | no updates | 0 |
| impacts-256 / 0 | 1 | 256 / 0 | 8560640 | 100.0000% | 0 |
| impacts-256 / 81 | 1 | 256 / 256 | 0 | no updates | 0 |
| impacts-256 / 82 | 2 | 768 / 0 | 43098892 | 99.9990% | 444 |
| impacts-256 / 103 | 2 | 3284 / 708 | 52276304 | 99.9123% | 45844 |
| impacts-256 / 179 | 2 | 4527 / 972 | 46638856 | 99.4286% | 147184 |
| impacts-25 / 0 | 1 | 25 / 0 | 836000 | 100.0000% | 0 |
| impacts-25 / 81 | 1 | 25 / 25 | 0 | no updates | 0 |
| impacts-25 / 82 | 2 | 75 / 0 | 4216568 | 99.9980% | 84 |
| impacts-25 / 103 | 2 | 308 / 114 | 5162880 | 99.9390% | 3148 |
| impacts-25 / 179 | 1 | 223 / 28 | 2690668 | 99.6252% | 10196 |
| impacts-64 / 0 | 1 | 64 / 0 | 2140160 | 100.0000% | 0 |
| impacts-64 / 81 | 1 | 64 / 64 | 0 | no updates | 0 |
| impacts-64 / 82 | 2 | 192 / 0 | 10886932 | 99.9971% | 312 |
| impacts-64 / 103 | 2 | 765 / 173 | 14135324 | 99.9232% | 10860 |
| impacts-64 / 179 | 1 | 666 / 88 | 6946828 | 99.4050% | 30424 |

## Revised experiment decision

1. **N24 component-local multilevel preconditioning:** use the existing symmetric multilevel cycle for33–1024-node components, keeping tiny block-Jacobi and large cooperative paths. The current dominant anchored remnants fit this range. Hypothesis0–30ms per active heavy step; low-confidence time estimate until extra hierarchy construction and cycle cost are measured. Same final convergence/physics gates. Isolated commit `c96626dfd43123e667ba0241ef3028c9e37a5c5e` failed the unchanged live-force gate despite reducing impact iterations304 to64. [Failure and independent equation audit](n24-result.md); not retained.
2. **Batch mandatory fragment lifecycle work:** still substantial at fracture; the pointer-cache-only variant is held before implementation because validation is only1.593ms at first fracture and0.127ms at late tick179. Do not assign all allocation/migration time to repeated resolution.
3. **Localized topology rebuild:** pursue changed-old-component locality inside actual rebuilds; whole-generation gating already exists.
4. **Earlier settled/material skip:** valid idle and architecture opportunities, but selected warm idle input/material kernels total roughly0.16ms, versus41–62ms of iteration during active destruction. Do not advertise large heavy gains from those small budgets.
5. **Shared factors / Tile batching:** consider for the remaining repeated anchored operator work after the algorithm test; compilers cannot infer physical cache validity. Tile availability is proven only by compilation so far.

[All52 scenario exposure and all360 continuous attribution frames](removal-exposure.md), [structured census](removal-work-census.json), and [previous retained N20 all-scenario performance](n20-final.md). No new optimization is counted or promoted by this diagnostic.
