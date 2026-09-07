# Reliable native stress residuals and zero-load provenance

This is a numerical-correctness change, not a claimed performance improvement.
All production work remains in the resident CUDA solver. The CPU and SciPy
solvers below are independent test oracles only.

## Changes

- Before accepting a positive-threshold convergence verdict, reconstruct the
  residual from the original right-hand side and accumulated FP64 solution.
  Recheck convergence and restart that component's search direction if needed.
  Only candidate-converged components perform this reconstruction.
- A cold native solve establishes that warm bond forces originate in the
  operator's transpose range. An unchanged, valid topology generation retains
  that provenance. Exactly zero current inputs can then recover the exact
  minimum-energy zero-force solution, including cycles and supported graphs.
  This explicitly removes accumulated numerical null stress; it is not a
  generic policy to erase arbitrary warm forces or authored prestress.
- Uninitialized/error topology, generation changes/rewinds and unknown warm
  states invalidate that proof. Such states retain the independent free-tree
  certificate or execute the numerical solve. Every nonzero input component,
  including equal/opposite loads and FP32 subnormals, rejects the zero shortcut.
- Fixed-first bond clearing is owned by the active second endpoint; other
  bonds are cleared by their active first endpoint. Persistent GPU provenance
  and verification storage is allocated at preparation, not per iteration.

## Independent numerical qualification

The 3D suite tests free and supported spatial structures with 18 nodes / 33
bonds and 1,058 nodes / 2,553 bonds. Four successive force/torque amplitudes
(0.5, 1, 0, -0.75) cover cold start, warm changes, unloading and reversal.
All 16 cases pass. Native settings remain 256 iterations and tolerance 1e-5;
the all-force/moment comparison threshold remains 2e-4.

The old FP32 CPU oracle reported convergence but disagreed with an independent
sparse-direct solution by as much as 7.231e-4 scaled force error. The test now
uses independent long-double CGLS, keeping its original 4,000 iteration cap
and 1e-7 tolerance, and explicitly reconstructing its final residual.
Legacy CPU outputs are retained as diagnostics. No production CPU solver or
CUDA convergence limit was relaxed to make the tests pass.

Independent SciPy assembly and sparse LU verify both iterative implementations:
maximum native force error 1.198e-5; high-precision reference error 2.151e-6.
See `direct-oracle-results.json` and compressed coefficient/output exports.
The direct audit checks its own residual and rigid null-space construction.

FP32 published forces have a separate rounding floor: even rounded sparse-direct
forces can exceed a very small squared-gradient threshold. These results prove
internal residual checks plus independent force accuracy; they do not claim
that quantized published forces meet arbitrarily small residual thresholds.

## Other checks

- Analytic resident GPU suite passes, including mixed components and topology
  transitions; workloads include 131,072 nodes / 98,304 bonds.
- CUDA lifecycle tests cover 18 block/cooperative retirement cases on a supported
  3-node / 3-bond cycle. The cooperative test places its two active writers in
  separate blocks. Invalid provenance, nonzero/subnormal inputs and positive
  thresholds preserve warm values.
- Full motion-mode suite passes through 100,000 nodes / 199,997 bonds.
- Memcheck and synccheck pass for the 3D suite and the lifecycle/motion small
  suite. Memcheck reports zero errors and no leaks. This does not resolve the
  previously recorded allocator-abort under the separate mixed-scene racecheck.
- Frozen 10-second wall audit passes: 444 chunks / 896 bonds; 398 supported,
  46 detached, 199 broken bonds, unchanged exact topology signature, correction
  limit one and accepted correction steps 17/32/33. See `wall-quality.json`.
- Fixed-period residual replacement every 16 iterations was tried and rejected
  because it regressed convergence/cap behavior. Its logs are retained; it is
  absent from production.

## 256-building performance check

See [the generated report](../guarded-residual-impacts-256/report.md).
Two untraced 3-second runs each contain all 180 complete steps, with a separate
warm-up and separate full-duration host/GPU profiling. Scene: 256 buildings,
113,664 chunks, 229,376 bonds, 256 simultaneous aerial projectiles, dt=1/60,
maximum one correction per step. Mean complete steps: 21.783 / 21.777 ms;
peaks: 69.971 / 67.674 ms. 198/360 steps exceed 8 ms. Every accepted step
converges; fracture/cluster counters match across modes.

This is not the five-by-60-second gate or endurance qualification. The corrected
solver has not achieved a speedup over the prior short campaign. Component
stress iteration remains the largest kernel (12.796 ms per step execution sum
in the separate CUPTI capture). Hierarchy construction also consumes measurable
GPU time; several of its symbols are still labeled unclassified in this report.
Full architecture, performance and endurance requirements remain open.
