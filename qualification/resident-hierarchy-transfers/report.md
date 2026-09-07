# Compact resident stress transfers — qualification

✅ Direct compact P/Pᵀ transfers and current-level CSR operator pass independent equation checks at the existing 2e-12 scaled tolerance. No intermediate parent-sized coarse vector/copy is required.

✅ Correctness, CUDA memory/leak, synchronization, and race checks pass. Fixtures range from empty and fixed systems through 100,000 stress nodes / 199,997 bonds. Small fixtures cover full bases; the largest exercises eight compact levels and topology transitions. This is solver qualification, not a rigid-body performance benchmark.

✅ The unchanged production wall regression passes: 10 simulated seconds, 444 chunks, 896 bonds, one projectile, dt 1/60, correction limit one. It retains 398 supported chunks, detaches 46, breaks 199 bonds, and matches the exact frozen topology signature. Projectile clearance, entry/exit holes, convergence, and render/collision checks pass. Production binary hashes are unchanged.

🚧 Terminal component grouping/factors, coarse smoothers, V-cycle, and production CGLS integration remain. These headers are independently qualified but not connected to the production solver. No production speedup or 8 ms deadline qualification is claimed. The physics_ms field in the copied quality artifact is incidental regression telemetry, not the authoritative full-step campaign.

Evidence: [validation](validation.json), [correctness](correctness.log), [CUDA safety](safety.log), [wall quality](wall-quality.json).
