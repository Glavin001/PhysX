# 🔬 Native game stress work: both evaluations

**256 buildings / 113,664 chunks / 229,376 bonds / 768 physical rounds; 600 steps / 10 simulated seconds.** Direct GPU API off, sleep on, correction ≤1 and stress evaluations ≤2.

All **920 stress evaluations** map to their accepted ticks and reconcile with individual component records. First counted-state difference from the untraced reference: tick **71**. Matching counts are not proof of identical trajectories.

This intrusive runtime synchronizes and reads diagnostic records. Its times are not performance results. Reference complete-step times select a tick; component work describes the separate diagnostic replay. CTA cycles overlap across SMs and include probe overhead; they are not additive milliseconds or hardware utilization.

**Component updates** are numerical solver iterations summed across components, not physics replays. **Fine inverse application** means one cached 6×6 matrix-vector product used by the preconditioner. All listed computational phases run on the GPU; record readback/formatting belongs only to this CPU diagnostic.

## Tick 48

Untraced reference complete step: **146.181 ms**. Diagnostic accepted state: 10,449 fragment bodies / 10,193 awake, 216,220 reported normal contacts, 57,788 cumulative broken bonds. The work below occurs before each evaluation commits its fractures.

| Evaluation | Components | Component updates | Outer live adjacency visits | Polynomial live adjacency visits | Fine inverse applications |
|---|---:|---:|---:|---:|---:|
| trial | 1,030 | 42,342 | 108,468,281 | 52,977,482 | 29,293,140 |
| after correction | 1,793 | 64,748 | 134,005,650 | 66,135,676 | 40,091,884 |

| Cohort (both evaluations) | Component evaluations | Updates | Share of live adjacency visits |
|---|---:|---:|---:|
| Anchored structures | 512 | 104,134 | 99.990% |
| Free components | 2,311 | 2,956 | 0.010% |
| More than 256 updates | 157 | 43,976 | 38.007% |
| At most 256 updates | 2,666 | 63,114 | 61.993% |

Anchored/free and update-range rows are two separate partitions; do not add all four rows together.

| Phase | Share of summed CTA phase cycles |
|---|---:|
| Residual preparation/projection | 8.03% |
| Residual operator and verification | 9.03% |
| Convergence decision | 0.43% |
| Preconditioning and reductions | 66.14% |
| Direction update | 1.84% |
| Direction operator | 8.78% |
| Solution update | 5.75% |
| Dispatch/other | 0.01% |

Within instrumented preconditioning: polynomial/application 82.61%, null projection 1.49%, normalization reduction 6.98%, conversion/gamma 8.93%.

## Tick 52

Untraced reference complete step: **70.655 ms**. Diagnostic accepted state: 11,401 fragment bodies / 11,145 awake, 291,149 reported normal contacts, 61,997 cumulative broken bonds. The work below occurs before each evaluation commits its fractures.

| Evaluation | Components | Component updates | Outer live adjacency visits | Polynomial live adjacency visits | Fine inverse applications |
|---|---:|---:|---:|---:|---:|
| trial | 1,897 | 71,884 | 142,235,646 | 70,278,690 | 42,948,056 |
| after correction | 1,899 | 56,429 | 114,729,846 | 56,597,222 | 34,566,254 |

| Cohort (both evaluations) | Component evaluations | Updates | Share of live adjacency visits |
|---|---:|---:|---:|
| Anchored structures | 512 | 123,237 | 99.961% |
| Free components | 3,284 | 5,076 | 0.039% |
| More than 256 updates | 179 | 50,262 | 40.972% |
| At most 256 updates | 3,617 | 78,051 | 59.028% |

Anchored/free and update-range rows are two separate partitions; do not add all four rows together.

| Phase | Share of summed CTA phase cycles |
|---|---:|
| Residual preparation/projection | 7.30% |
| Residual operator and verification | 9.45% |
| Convergence decision | 0.46% |
| Preconditioning and reductions | 65.91% |
| Direction update | 1.88% |
| Direction operator | 9.09% |
| Solution update | 5.90% |
| Dispatch/other | 0.01% |

Within instrumented preconditioning: polynomial/application 81.97%, null projection 1.94%, normalization reduction 7.18%, conversion/gamma 8.91%.

## Scope

Outer-operator counts cover residual, verification and direction sweeps. Polynomial counts cover eligible off-diagonal visits; inverse applications count the two node-block products per polynomial sweep. Neither count includes every flop, cache-line transaction, initial factor build, hierarchy/null-mode setup or reliable-residual reconstruction. This is an algorithmic work census, not a complete hardware roofline. No physical budget was reduced.

Regenerate with `report-vibe-component-work.py CAPTURE REFERENCE COMPONENTS_JSONL_GZ OUTPUT`.
