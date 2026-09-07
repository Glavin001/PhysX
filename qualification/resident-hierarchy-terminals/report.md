# Resident terminal solves — qualification

✅ Implemented GPU construction and application of small per-component Cholesky preconditioners: at most six nodes / 36 coordinates per component. Factors and solves use the shared fine/coarse operator views and GPU component partition. No CPU matrix construction or dense inverse is part of the implementation.

✅ Independent matrix reconstruction, solve backward residual, symmetry/positivity, compatible free-body equations, and inconsistent-offset moment checks pass at the existing 2e-12 scaled tolerance. Fixed supports and parallel bonds are covered. A zero operator returns zero; larger components remain nonterminal. The free-body anchor exists only in the numerical preconditioner and does not modify the authoritative physical operator.

✅ Correctness and CUDA memory/leak, synchronization, and race audits pass. The hierarchy fixture reaches 100,000 stress nodes / 199,997 bonds through eight compact levels and topology transitions. Large terminal application checks scheduling, finite output, byte repeatability and untouched nonterminal output; detailed independent dense checks cover terminal components in levels of at most 257 nodes. These are solver audits, not rigid-body benchmark timings.

✅ Rejected transactions preserve status; stale source generations fail and recover. A finite unfactorable two-endpoint fixture reports numerical error 128 and recovers with valid data. No alternate solve is selected. An earlier one-sided failure-injection fixture did not trigger rejection and was corrected; numerical tolerances were unchanged.

✅ Frozen production wall regression passes: 10 simulated seconds, 444 chunks, 896 bonds, one projectile, dt 1/60, correction limit one. It retains 398 supported chunks, detaches 46, breaks 199 bonds and matches the exact topology signature. Projectile clearance/holes, convergence and render/collision checks pass. Production artifact hashes are unchanged.

🚧 Terminal retirement, shared factor storage, coarse smoothers, the full V-cycle and native CGLS integration remain. The new solver is not production-integrated; no speedup or 8 ms deadline claim is made. Incidental physics_ms in wall-quality.json is narrower regression telemetry, not the full-step performance campaign.

Reproduce with `cmake --build out/destruction-sdk --target gpu_resident_hierarchy_test -j 4`, then `ctest --test-dir out/destruction-sdk -R '^blast_stress_gpu_resident_hierarchy($|_)' --output-on-failure -j 1`. Run the frozen regression separately with `python3 tools/scripts/run-destruction-penetration-regression.py out/hierarchy-terminals-wall-quality`.

Evidence: [validation and hashes](validation.json), [test summary](tests.log), [detailed audit output](test-details.log), [wall quality](wall-quality.json).
