# Rejected: inline-setup rigid additive correction

❌ **Rejected and production changes reverted. Never deployed.** Added the SPD six-mode correction Z (Zᵀ A Z)⁻¹ Zᵀ to the existing polynomial, with analytic rigid-body Gram assembly and per-component Cholesky inside the resident CUDA kernel. No material, physical operator, convergence threshold or correction limit changed. Hot-kernel registers rose from 94 to 128.

Matched isolated short screen: **256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles over 600 steps / 10 simulated seconds per run**, plus a separate 600-step intact-idle run with no commands or destruction. Direct GPU off, sleep on, dt 1/60, correction ≤1, stress evaluations ≤2. One run per arm/regime; every step and startup spike retained. Timer includes commands, physics, stress, topology, correction and accepted game observations/events; rendering/network encoding excluded.

Complete fracture peak 132.147 → 133.081 ms; mean 44.700 → 43.391 ms; all-step peak 160.248 → 160.570 ms. Fresh idle mean 0.845 → 0.879 ms and peak 158.272 → 162.107 ms. The lower mean is insufficient for the peak objective. Late chaotic trajectories differ; final counts and first divergence remain in the generated reports.

[Destruction comparison](shots/report.md) · [Required paired intact-idle comparison](idle/report.md). Together these provide both regimes; neither establishes endurance or comparison against historical Vibe-land.

✅ Three numerical suites, all-basis independent long-double dense-operator/symmetry/SPD oracle (12 chunks/20 bonds; 11 dynamic rows in its supported variant, unchanged 2e-11 thresholds), CUDA memcheck, nine ordinary lifecycle tests, 513-collider compound sleep/rollback and exact 444-chunk/896-bond one-projectile penetration fixture passed. Wall retains 398 chunks, detaches 46 and breaks 199 bonds. Full 256-building mapping audit was deferred because the candidate failed the initial peak screen; do not infer it passed from these checks.

Raw timings, command tapes, mapped-library hashes and test receipts are under `out/rigid-additive-20260909/screen`; relevant receipts and reports are archived here. The candidate patch/private CUDA file and test changes are retained only as experiment artifacts. Candidate module copies were later deduplicated by content hash to one immutable shared artifact; current symlinks must be resolved for a future map-attested rerun.

The separate instrumented replay measured peak GPU stress at 30.510 ms baseline versus 30.465 ms candidate, with identical tick-48 physical counts (10,449 fragments, 10,193 awake, 216,220 normal contacts, 57,788 broken bonds, one correction). Its complete peaks were 145.462 and 157.138 ms; these intrusive timings are not substituted for the untraced results. [Baseline phases](baseline-phases/report.md) · [Candidate phases](candidate-phases/report.md).
