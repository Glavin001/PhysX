# Cached native local preconditioner qualification

Candidate based on d55cfd97. Cache the symmetric 6x6 inverse per node on the GPU, then apply coalesced local matrix-vector products instead of repeated triangular divisions. Cache validity is per-node and topology generation. No whole-component dense inverse, CPU solve, relaxed tolerance or correction-policy change is introduced. Floating-point evaluation order changes; bitwise numerical equivalence is not claimed.

## Measurement

256 buildings, 113,664 chunks, 229,376 bonds, 256 simultaneous aerial projectiles; 1/60 s timestep, correction maximum one, sleeping disabled. Two untraced three-second runs (180 complete advances each), plus separate host and CUPTI captures. Initialization is separate; commands through required completion are measured, including every step. This is diagnostic, not the five by 60-second acceptance gate.

| Complete advance | Previous d55cfd97 | Candidate |
|---|---:|---:|
| Trial 1 mean / peak ms | 20.057 / 64.738 | 18.455 / 62.035 |
| Trial 2 mean / peak ms | 20.292 / 64.347 | 18.626 / 63.596 |
| Steps over 8 ms | 198 / 360 | 198 / 360 |

The observed maximum decreased about 1.8%; this is a modest short-run gain, not a proven universal speedup. Separate CUPTI componentStressSolve execution sums averaged 12.703 -> 11.178 ms/step. The cache allocates 180 extra bytes/node (21 doubles, validity, generation), or 20,459,520 bytes for this scene. Counters match across all 180 compared steps for bodies, awake bodies, clusters, fractures, contact reports, active stress topology, correction status and convergence. One step takes 580 rather than 579 iterations. Counter parity does not prove identical trajectories.

## Correctness evidence

- Final cache test: all six basis vectors on 257 SPD blocks plus cold/reuse/unknown-entry/generation lifetime checks; maximum scaled difference 6.39e-16 against the unchanged triangular reference, limit 2e-12.
- Native analytic fixtures and all 16 3D oracle cases pass unchanged limits. Independent sparse-direct audit maximum native scaled force error 1.201e-5 (limit 2e-4).
- Native analytic memcheck: zero errors/leaks. Cache/motion synccheck and initcheck: zero errors. Sanitizers predate only the final test-only basis expansion, not any production source change. These do not establish a clean full native racecheck.
- Ten-second frozen penetration audit: 444 chunks, 896 bonds, 398 supported chunks, 46 detached, 199 broken bonds, max one correction; exact topology identity passes. Heavy observation timings are not performance qualification.

See report.html/report.md for generated timing detail; validation/ contains raw checks. Reproduce timing with:

```sh
python3 tools/scripts/run-destruction-timing.py NEW_OUT --config tools/profiles/destruction-scaling.json --case impacts-256 --seconds 3 --trials 2 --gpu-trials 1 --report-output NEW_REPORT
```

The full 8 ms target, GPU ownership migration, selective correction and endurance remain incomplete.
