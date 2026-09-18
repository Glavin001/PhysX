# R1 feasibility gates: cached direct factorization per anchored component

Executed 2026-09-15 on the RTX 5060 Ti (no other GPU clients), offline, with no
runtime, SDK or benchmark change. Inputs are the saved native captures of the
city256 late-debris world (`out/n28-duplicate-census-20260912/city256-late-debris-problem.world-0.solve-{0,1}.{nodes,bonds}.bin`,
113,664 nodes, 229,376 bonds, 173,379 live at solve 0) and the intact/fractured
parent building capture (`out/prepared-remnant-20260913/inputs-v3`). Components
are assembled exactly as the repository's own assessor does
(`out/n28-native-factor-20260912/assess-native-stress-problems.py`: `A = B Bᵀ`,
`B = D C S`), and the right-hand side is the captured warm residual. Tools:
`tools/diagnostics/destruction-direct-factor/{gate_raw.py, gate_c.py, tri_bench.cu}`.
Raw outputs: `out/direct-factor-feasibility-20260915/` (ignored, local).

**Verdict: GO.** All five gates pass their pre-declared thresholds. The direct
route replaces the two ~35 ms PCG passes of a late-debris tick with two
~2.4 ms batched triangular-solve passes plus at most one FP64 refinement each,
with factor lifetime spanning many ticks in the sustained regime.

## Population

| solve | anchored components ≥32 nodes | rows (DOF) min / median / max | nnz(A) mean | nnz(L) mean / max | FP32 factor bytes, all components |
|---|---:|---:|---:|---:|---:|
| 0 | 255 | 450 / 1,860 / 2,082 | 10,688 | 58,690 / 103,737 | 64.4 MB |
| 1 | 255 | same population | | | |

These are the components that carry 97.9% of iterative work in the work census.
Six additional components were skipped (free or zero load). Ordering is
SuperLU minimum degree on A+Aᵀ (`MMD_AT_PLUS_A`, symmetric mode, no pivoting);
a nested-dissection ordering would reduce both fill and level count further.

## (a) Fill and memory: pass

Mean 59k nonzeros per factor, 64 MB for the whole city's anchored remnants in
FP32. Budgeting 2× for a fractured population plus capacitance blocks keeps the
city under 0.2 GB, far below the 0.3–0.5 GB allowance in the ranking report.

## (b) FP32 factor + FP64 refinement accuracy: pass (510/510)

Dense FP32 Cholesky of each system, FP64 residual, refinement with the same
FP32 factor, gate = relative residual ≤ 1e-5 (the solver's own criterion).

| metric | value |
|---|---:|
| systems reaching the gate with 0 refinement steps | 254 |
| with 1 step | 256 |
| needing ≥2 steps | 0 |
| FP32-only relative residual, median / max | 1.0e-5 / 3.3e-3 |
| relative solution error vs FP64 direct, max | 1.2e-4 |
| relative bond-force error `‖Bᵀ(x−x*)‖/‖Bᵀx*‖`, max | 4.8e-5 |
| condition number, sampled min / max | 8.9e3 / 1.6e6 |

Even the worst-conditioned remnant (κ ≈ 1.6e6) reaches 1e-5 after one
refinement step. The 1e-5 gate corresponds to bond-force errors well inside the
2e-4 scaled-force acceptance used by the physical checker.

## (c) Factor reuse under bond removal (Woodbury / capacitance): pass

*Synthetic, intact parent (2,280 DOF, 784 bonds).* Remove k random bonds,
regularize any detached nodes with identity columns (`Ã = A0 − UUᵀ + EEᵀ`), solve
with the cached FP32 factor of A0 plus an FP64 capacitance of size m = 6k + 6·|det|:

| k removed | m | detached nodes | residual after 0 / 1 refinement | error vs direct |
|---:|---:|---:|---|---:|
| 1–16 | 6–96 | 0 | 2.7e-5 / 1.2e-9 | ≤1.9e-9 |
| 32–64 | 192–384 | 0 | 3.0e-5 / 1.7e-9 | ≤3.4e-9 |
| 128 | 768–774 | 0–1 | 3.6e-5 / 2.7e-9 | ≤4.9e-9 |
| 200 (26% of bonds) | 1,206–1,230 | 1–5 | 4.9e-5 / 4.1e-9 | ≤9.4e-9 |

Capacitance stays well conditioned (min |eig| ≥ 1.7e-3 at k = 200).

*Real successive passes.* Between solve 0 and solve 1 of the same captured
tick, 139 of 255 anchored components keep identical node sets; **128 have an
unchanged operator** (factor reused as is) and **11 lost 1–9 bonds**. For all 11,
the solve-1 operator equals `A0 − UUᵀ` exactly (max reconstruction difference
0), and the Woodbury solve from the solve-0 FP32 factor reaches the 1e-5 gate
with 0 (7 cases) or 1 (4 cases) refinement steps; max error vs direct 7.8e-5.
The remaining 116 components changed node membership (splits), which is the
sub-mesh / refactor path.

## (d) GPU batched triangular solves: pass (2.40 ms per pass)

`tri_bench.cu`, one CTA per component, host level scheduling of L and Lᵀ,
FP32, all 255 solve-0 factors (474,972 rows, 16.1 M nonzeros, ≤454 levels):

| kernel | threads | ms per pass (fwd + bwd, all 255 systems) |
|---|---:|---:|
| thread-per-row, vectors in global memory | 256 | 13.30 |
| warp-per-row shuffle reduction, vectors in shared memory | 128 | 2.80 |
| same | **256** | **2.40** |
| same | 512 | 3.02 |

Host-verified residual of the FP32 result on the first system: 1.2e-5 (one
refinement step needed, as in (b)). A refinement step costs one FP64 sparse
product on A (10.7k nonzeros per component, negligible) plus a second solve
pass, so the worst-case cost per stress evaluation is ≈2 × 2.4 ms ≈ 5 ms versus
≈35 ms for the current PCG pass at this scale. Untested here: supernodal dense
blocks and nested-dissection ordering (fewer levels), which should reduce the
2.4 ms further; the level chain, not bandwidth, is the limiter (128 MB of factor
data per pass is <0.5 ms at memory speed).

## (e) Refactor rate: sustained regime is Woodbury-only

From a continuous city256 heavy run (600 ticks, 256 projectiles,
`out/ownership-scheduling-20260915/observation-continuous-v2/impacts-256-3-A`):

| window | bonds broken per tick |
|---|---|
| tick 82 (first impact) | 28,596 (≈112 per building; one shared intact operator) |
| ticks 84–103 | 600–6,100 per tick on 9 ticks |
| ticks 300–599 | mean 0.9, median 0, p90 2, max 30 |

Ticks 300–599 still average 29.3 ms of complete-step time with almost no
topology change: that cost is repeated PCG on unchanged operators. The impact
tick itself needs no refactorization: every building shares the same intact
operator (`unique_anchored_operators = 1` in the census), so the first-impact
solve is one factor applied to 256 right-hand sides, followed by ≈112-bond
Woodbury corrections per building (tested to 200 above). Refactors are needed
only when accumulated removals exceed the capacitance budget or a component
splits.

Refactor cost bound from the exported factor structures: right-looking sparse
Cholesky of all 255 remnants totals 2.1 GFLOP (mean 8.3 M, max 19.6 M per
component; max column count 336). At 10–30% of the 5060 Ti's FP32 peak this is
7–2 ms for a full-city refactor burst; per-component refactors in the sustained
regime are microseconds. This is an estimate, not a measured kernel.

## R3 corollary: FP32-first is sufficient for anchored components

Gate (b) doubles as the R3 replay for the anchored population: FP32 factors
plus at most one FP64 refinement reach the solver's 1e-5 gate on all 510
systems, including κ ≈ 1.6e6. Any FP64 that remains in R1 is one sparse
residual product per component per refinement step, so the 1/64 FP64 rate of
consumer Ada/Blackwell no longer sits on the per-iteration path. For components
that stay on the existing PCG (free debris, fallbacks), the same FP32-iterate /
FP64-gate structure applies and still needs its own runtime qualification.

## Reproduction

```bash
cd /root/workspace/physx-2
.toolchains/build-env/bin/python tools/diagnostics/destruction-direct-factor/gate_raw.py \
  out/n28-duplicate-census-20260912/city256-late-debris-problem.world-0 \
  out/direct-factor-feasibility-20260915/late-debris 32
.toolchains/build-env/bin/python tools/diagnostics/destruction-direct-factor/gate_c.py
/usr/local/cuda-13.4/bin/nvcc -O3 -arch=sm_120 -std=c++17 \
  -o out/direct-factor-feasibility-20260915/tri_bench tools/diagnostics/destruction-direct-factor/tri_bench.cu
ls out/direct-factor-feasibility-20260915/late-debris/factors | grep meta | sed 's/^c\([0-9]*\)\.meta\.i32/\1/' \
  > out/direct-factor-feasibility-20260915/late-debris/ids.txt
out/direct-factor-feasibility-20260915/tri_bench out/direct-factor-feasibility-20260915/late-debris/factors \
  out/direct-factor-feasibility-20260915/late-debris/ids.txt 50
```

The build-env Python needed `scipy` (installed 1.15.3 into
`.toolchains/build-env`). `gate_raw.py` takes ≈130 s on the CPU; the GPU
benchmark takes seconds.

## Limits

- Accuracy is measured against FP64 direct solves and the solver's residual
  gate, not against the full material/trajectory checker; that remains a
  runtime qualification step.
- The batch layout in `out/prepared-remnant-20260913/batch-inputs` is not
  aligned for assets other than 0 (negative eigenvalues), so gates use the raw
  captures instead.
- Free components (rigid null space) were excluded; they need the existing
  projection or a regularized factor and are <1% of iterative work.
- The benchmark measures the solve only: RHS assembly, capacitance application
  and result scatter are not included, and the refactor kernel is not written.
