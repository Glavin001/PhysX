# Recursive GPU preconditioner progress

**Construction and compact recursive levels are qualified. The production
stress solver is unchanged; no new simulation speedup is claimed.**

- ✅ GPU-resident aggregation, compaction, stable radix ordering and CSR.
- ✅ Persistent buffers; used counts and rebuild decisions stay on the GPU.
- ✅ Exact coarse coefficients, authored ancestry and generation/recovery gates.
- ✅ Full correctness, memory/leak, synchronization and race checks.
- 🚧 Terminal coarse solve, compact-vector V-cycle and production integration.

## What changed

One cooperative packing kernel replaces the unqualified conditional CUB graph
experiment. It scans actual device counts, uses producer-owned partials and a
stable tiled radix sort, and constructs canonical CSR with parallel row
prefixes. No host count readback or per-generation graph recapture is required.
Only exactly zero coarse columns/rows are removed; original chunks, bonds and
the fine physical operator remain unchanged. Rounded nonzero self-edge moments
survive.

The earlier conditional implementation passed functional/memory checks but
failed synchronization checking and crashed its race-check process. It is
retained only as rejected evidence. During cooperative implementation, tests
caught a register-order assumption after a CUB store and an error-gate race;
both are fixed. No tolerance or timeout was loosened.

## Verified recursive workload

The largest **algebra fixture** has 100,000 fine nodes and 199,997 bonds. The
following is its initial connected state; these are preconditioner sizes, not
physical chunks removed from a scene. Six transitions also cover splitting,
unchanged input, complete bond removal and restoration.

| Packed level | Nodes | Bonds | Next aggregate groups |
|---:|---:|---:|---:|
| 1 | 27,321 | 78,816 | 10,833 |
| 2 | 10,833 | 32,053 | 4,517 |
| 3 | 4,517 | 13,496 | 1,927 |
| 4 | 1,927 | 5,772 | 824 |
| 5 | 824 | 2,468 | 356 |
| 6 | 356 | 1,064 | 152 |
| 7 | 152 | 453 | 66 |
| 8 | 66 | 195 | 30 |

Independent original-fine equations verify the composed factors and coarse
operator at 2e-12 scaled tolerance. Small fixtures sweep every coarse basis
column; the largest fixture uses vector/operator and exact topology checks.
Tests also prove every level skips unchanged generations, rejected transactions
preserve committed statuses, and overflow/stale-source/invalid-origin failures
reject and recover explicitly.

## Integrated regression and performance scope

The unchanged production binary ran the **10-second wall penetration**: 444
chunks, 896 bonds, one projectile, timestep 1/60 and correction limit one. The
exact gate passes: 398 supported chunks, 46 detached, 199 broken bonds, entry/exit
holes, clearance step 39, zero collision/render position mismatch and the
established COM/convergence checks. Binary hashes match the prior wall audit.

The optimization target remains **256 buildings, 113,664 chunks, 229,376 bonds
and 256 simultaneous projectiles**. Its retained [full-step timing report](../component-restored-impacts-256/report.html)
is unchanged. This work is not yet a production preconditioner or an 8 ms pass.

[Validation and source hashes](validation.json) · [Test summary](tests.log) ·
[Detailed tests](test-details.log) · [Wall audit](wall-quality.json).
