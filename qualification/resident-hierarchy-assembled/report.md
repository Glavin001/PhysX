# Assembled resident stress hierarchy — qualification

✅ One captured GPU pipeline now constructs the hierarchy, assigns terminal solve ownership, removes terminal components from deeper numerical work and validates completion. Fine physical chunks/bonds are unchanged. The assembled path requires retirement metadata and adds no runtime backend switch.

✅ All hierarchy levels share one terminal factor pool. Tests verify disjoint authored-origin storage and byte-identical solves against independently owned per-level workspaces after deeper construction finishes. Retired coordinates prolong to zero; required nonterminal roots and coarse coefficients remain exact.

✅ Two correctness suites and six CUDA memory/leak, synchronization and race audits pass without relaxed tolerances, suppressions or timeouts. The largest fixture has 100,000 stress nodes and 199,997 bonds, six topology/generation transitions and sixteen allocated levels. These are stress-hierarchy checks, not rigid-body simulation benchmarks. Twelve levels initially rejected a changed topology with error 256; the explicit incomplete-depth gate remains covered.

📦 The terminal pool layout uses 99,200,000 bytes at 100,000 authored-node capacity, shared across all levels. This calculated size covers terminal factors, scaling, lift diagnostics and ownership metadata only; it excludes the other hierarchy and PhysX allocations.

✅ Frozen wall quality passes: ten simulated seconds, 444 chunks, 896 bonds, one projectile, dt 1/60, correction limit one. Exactly 398 chunks remain supported, 46 detach and 199 bonds break. Frozen topology identity, projectile clearance/holes, convergence and render/collision checks pass. Production binary hashes are unchanged.

🚧 Coarse smoothing, the complete preconditioning cycle and native CGLS integration remain. This is hierarchy-construction qualification, not a production speedup or an 8 ms full-step result. Incidental physics_ms in the copied wall artifact is narrower regression telemetry.

Reproduce: build `gpu_resident_hierarchy_test` in `out/destruction-sdk`; run `ctest --test-dir out/destruction-sdk -R '^blast_stress_gpu_(assembled|resident)_hierarchy($|_)' --output-on-failure -j 1`; then separately run `python3 tools/scripts/run-destruction-penetration-regression.py out/hierarchy-assembled-wall-quality`.

Evidence: [validation, source hashes and level counts](validation.json), [correctness](correctness.log), [CUDA safety](safety.log), [wall quality](wall-quality.json).
