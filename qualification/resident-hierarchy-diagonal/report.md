# GPU preconditioner progress — qualified building blocks

**The production stress solver is unchanged. No new simulation speedup is claimed.**

| Stage | Owner | Status |
|---|---|---|
| Connected first-level aggregates and sparse coarse factor | GPU | ✅ Qualified |
| Rigid transfer, transpose restriction, coarse application | GPU | ✅ Qualified |
| Local 6×6 factors and forward/back solve | GPU | ✅ Qualified |
| Recursive levels and terminal coarse solve | GPU | ⬜ Remaining |
| Resident V-cycle and production CGLS integration | GPU | ⬜ Remaining |
| 256-building performance and full-plan gates | Complete simulation | ⬜ Remaining |

The local solve uses 21 lower-triangle coefficients per chunk, retains a Cholesky
factor instead of an inverse, and needs no host numerical work or allocation
during application. Construction errors reject the result; no alternate solver
or identity fallback is selected. The original bond energy proves a fine-level
spectral bound for choosing stable damping.

## Automated verification

All four registered checks pass: captured-graph correctness, memory/leaks,
synchronization and race checking. Independent coupling equations validate every
scalar basis load for small fixtures at **2e-12 scaled tolerance**. Larger
fixtures use vector/operator checks, exact connectivity and repeated transitions.
These are algebra fixtures; their node counts are not simulated rigid-body counts.

| Fine nodes | Bonds |
|---:|---:|
| 0 | 0 |
| 1 | 0 |
| 2 | 1 |
| 4 | 3 |
| 6 | 10 |
| 24 | 11 |
| 24 | 33 |
| 129 | 121 |
| 257 | 256 |
| 100,000 | 199,997 |

Coverage includes fixed boundaries, parallel bonds, six free rigid modes,
repeated application, topology split/restore, native isolated dynamic rows,
invalid mass scaling, omitted live work, unfactorable blocks and recovery.

## Integrated physics regression

The unchanged production binary ran the frozen **10-second wall penetration**:
444 chunks, 896 bonds, one projectile, timestep 1/60 and correction limit one.
The exact gate passes: **398 supported chunks, 46 detached, 199 broken bonds**,
entry/exit holes, clearance step 39, zero collision/render position mismatch and
the established COM/convergence checks. Binary artifact hashes match the prior
wall audit. This audit is not a candidate performance run of the new hierarchy.

The primary optimization target remains **256 buildings, 113,664 chunks,
229,376 bonds and 256 simultaneous projectiles**. Its latest retained timing
report remains [the restored production benchmark](../component-restored-impacts-256/report.html).
The five 60-second runs under an 8 ms full-step peak have not been achieved.

[Validation and source hashes](validation.json) · [Test summary](tests.log) ·
[Detailed test output](test-details.log) · [Wall audit](wall-quality.json).
