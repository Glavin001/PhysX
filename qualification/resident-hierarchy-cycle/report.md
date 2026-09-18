# Resident GPU stress cycle — qualification

✅ This stage implements the symmetric resident multilevel preconditioner. It is not yet connected to native CGLS and establishes no production simulation speedup or 8 ms result.

## Implemented

- One cooperative CUDA launch applies a symmetric V-cycle; one launch also supports its square, as required by the existing node-space CGLS derivation.
- Fine diagonal factors are borrowed from construction. Coarse diagonal factors are retained on the GPU and skip terminal/fixed rows.
- Pre/post block smoothing, compact restriction, terminal solves and correction all remain in the resident kernel. No intermediate host decision, numerical upload or iteration-time allocation occurs.
- The backward update directly uses retained coarse bond factors to evaluate B Hᵀ e (H=Pᵀ B), avoiding a separate expansion pass and cancellation when recomputing strain from large expanded coordinates.
- Stale and incomplete hierarchies must leave destination vectors untouched. Captured applications are reused across topology transitions.

## Numerical qualification

Fixtures cover empty/fixed/isolated rows, supported components, a free path, parallel bonds, inconsistent offsets with real self-edge moments, omitted inactive rows, a star and mixed components. The largest connected fixture contains **100,000 stress nodes and 199,997 bonds**, with sixteen allocated hierarchy levels and six topology/generation transitions. These are stress tests, not rigid-body simulation timings.

Small fixtures use an independent long-double dense V-cycle oracle, including every basis coordinate. The new free path has **24 nodes and 23 bonds** and exercises coarse smoothing. Full-basis tolerance remains 2e-12.

The new large-fixture linearity check originally used pointwise relative error. Cancellation made that inappropriate for small output entries beside very large responses. The test now measures normwise error separately for each physical component and each coordinate, retaining the 2e-12 coefficient and exact-zero checks for fixed/omitted rows. Local/global diagnostics remain in the logs. Existing physical golden tolerances and dense-oracle assertions were not changed.

The initial expanded backward update still failed the component-coordinate criterion (2.1023148261902041e-12). A compensated cross-product experiment also failed (2.712227745087447e-12) and was reverted. The retained-factor backward update passed; it initially exposed a lane-broadcast bug, which was fixed before qualification. This history is not a production speed comparison.

## Audit batching

The combined race audit exceeded its existing 120-second timeout. The supported fixture alone also exceeded it. Race checks are now split by fixture and, for expensive fixtures, by the transition whose cycle outputs are checked. Each selected transition replays the original full topology-build sequence. Across the registered matrix every original cycle/basis assertion is retained. The ordinary correctness suite continues to run all transitions together. No timeout was increased and no race suppression was added.

✅ All 28 race batches pass under the unchanged per-test timeout. The final source snapshot also passes three correctness suites plus CUDA memory/leak and synchronization checks. The largest-fixture component-coordinate linearity errors are recorded in validation.json; both M and M² remain below 2e-12.

✅ The frozen ten-second penetration regression passes: 444 chunks, 896 bonds, one projectile, dt 1/60, correction limit one; 398 supported chunks, 46 detached chunks and 199 broken bonds. The exact topology identity, entry/exit clearance, convergence and render/collision checks pass. Production binary hashes remain unchanged, so this is a baseline guard, not native preconditioner qualification.

Reproduce: build gpu_resident_hierarchy_test in out/destruction-sdk, run the resident_hierarchy, assembled_hierarchy and resident_cycle correctness tests, then resident_cycle_memcheck, resident_cycle_synccheck and every resident_cycle_racecheck_* test serially. Run tools/scripts/run-destruction-penetration-regression.py with a fresh output directory separately.

Evidence: [validation and source hashes](validation.json), [snapshot checks](snapshot-checks.log), [race batches](race-batches.log), [first supported transition](race-supported-first.log), [frozen wall quality](wall-quality.json). Test durations are audit wall time. The physics_ms field in the wall artifact is narrower incidental telemetry, not an 8 ms complete-step qualification.

## Native integration still required

1. Upload normalized authored chunk positions once during asset preparation, using the existing length scale. Borrow native CSR, coupling offsets, inertia masks, health, column weights and component order; do not construct another CPU partition.
2. Attach hierarchy construction to the accepted rebuild branch of DeviceStressTopology. Keep its completion/error state in device dependencies. Unchanged generations must bypass the entire hierarchy rebuild.
3. Adapt cycle scheduling to native component ownership: small components remain independently processed by their owning block; large components use legal cooperative residency. Share the numerical operations across these workload specializations.
4. Apply the squared preconditioner to the native node-space gradient, preserve the existing authoritative residual/convergence check and reconstruct physical bond impulses through the existing operator. Precision conversion, if needed, belongs in producers/consumers, not an adapter export/reimport.
5. Qualify native analytic tests and the frozen 444-chunk/896-bond penetration scenario before measuring the 256-building, 113,664-chunk, 229,376-bond, 256-projectile bombardment with the complete-step timer.

A cooperative whole-world cycle fixture alone does not establish efficient component scheduling or production integration.
