# Rejected: GPU-cached rigid additive correction

❌ **Rejected and production changes reverted. Never deployed.** Moved topology-derived factor construction to a separate GPU kernel, cached the exact six-mode factor by topology generation, and kept the iterative correction within the resident CUDA component. Hot-kernel registers fell from 128 to 102; extra factor storage and launch remain real costs.

Matched isolated short screen: **256 buildings, 113,664 chunks, 229,376 bonds, 768 physical projectiles over 600 steps / 10 simulated seconds per run**, plus a separate 600-step intact-idle run with no commands or destruction. Direct GPU off, sleep on, dt 1/60, correction ≤1, stress evaluations ≤2. One run per arm/regime; every step and startup spike retained. Timer includes commands, physics, stress, topology, correction and accepted game observations/events; rendering/network encoding excluded.

Complete fracture peak 141.272 → 141.127 ms (0.1%, not convincing); mean 44.918 → 41.664 ms; all-step peak 161.138 → 162.586 ms. Fresh idle mean 0.849 → 0.919 ms and peak 163.550 → 166.423 ms. The lower mean is insufficient for the peak objective. Late chaotic trajectories differ; final counts and first divergence remain in the generated reports.

[Destruction comparison](shots/report.md) · [Required paired intact-idle comparison](idle/report.md). Together these provide both regimes; neither establishes endurance or comparison against historical Vibe-land.

✅ Three numerical suites, all-basis independent long-double dense-operator/symmetry/SPD oracle (12 chunks/20 bonds; 11 dynamic rows in its supported variant, unchanged 2e-11 thresholds), CUDA memcheck, nine ordinary lifecycle tests, 513-collider compound sleep/rollback and exact 444-chunk/896-bond one-projectile penetration fixture passed. Wall retains 398 chunks, detaches 46 and breaks 199 bonds. Full 256-building mapping audit was deferred because the candidate failed the initial peak screen; do not infer it passed from these checks.

Raw timings, command tapes, mapped-library hashes and test receipts are under `out/rigid-additive-cached-20260909/screen`; relevant receipts and reports are archived here. The candidate patch/private CUDA file and test changes are retained only as experiment artifacts. Candidate module copies were later deduplicated by content hash to one immutable shared artifact; current symlinks must be resolved for a future map-attested rerun.
