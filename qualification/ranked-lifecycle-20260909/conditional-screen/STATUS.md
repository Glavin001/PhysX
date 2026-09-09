# Ranked replacement 1: device-owned allocation checkpoint

Partial architecture implementation; replacement 1 is not complete. Replacements 2–7 have not been started in this sequence.

GPU allocation consumes actual device request counts, validates/compacts in stable order and assigns motion addresses before the first status observation. A conditional graph skips allocation work on unchanged steps. Capacity growth retries allocation only; physical/stress/material work is not repeated. No spare actor is created. CPU compatibility construction, simulation registration and shape rebinding remain prerequisites for corrected physics.

Candidate runtime SHA-256: `b3574ebb18e585a2e87cf2fbe3d23ed8c89d679c7d0ee188fb427136fc85ea64`. Baseline runtime: `b715e377a67be27afa853b9f3b04d703fb2353c0fe65ceb62c8467a321dffb78`. Matching GPU module: `3fda147cc0a0c10a247fe8eac8779032ec872c867e5beecee11ebbd272b46096`.

## Correctness

- Historical 600-step wall: 444 chunks, 896 bonds, one projectile, 398 retained / 46 detached chunks / 199 broken bonds, exact original topology signature. Capture `out/ranked-lifecycle-20260909/conditional-full`.
- Ordinary mode 32-step wall prefix: exact mode-matched topology and motion within existing tolerance. Capture `out/ranked-lifecycle-20260909/conditional-standard-early`.
- Device allocation tests cover counts/capacities 1,127,128,129,444,4099,113664, stable selection, retry, retained owners, registration failure and transactional rejection. All four sanitizer tools pass; final expanded allocation oracle rechecked with memcheck/synccheck.
- After rebuilding all native consumers, 38/43 native tests pass. The five failures listed in attached logs reproduce against the restored baseline: connectivity-fracture host-restore assertion, consumer/renderer pre-solve live-node coverage, retained contact rows, bombardment contact rows. They remain unresolved; assertions were not weakened.
- The first body-state crash was a stale executable against a changed private ABI; it reproduced with baseline and disappeared after rebuilding all consumers. `native_destruction_consumers` now builds that group together.

## Performance: short screen only

See generated idle/report.md and shots/report.md. Each arm has two runs, 96 steps / 1.6 simulated seconds. Scene: 256 buildings, 113664 chunks, 229376 bonds; idle has no shots, destruction executes the first 256 shots of the unchanged 768-shot tape. Direct GPU off, sleep on, one correction, up to two stress evaluations. Complete timer includes commands, physics/destruction, exceptional growth and accepted observations.

Candidate fracture peaks 136.027/137.812 ms overlap baseline 139.604/132.805 ms. Idle medians candidate .450/.432 ms, baseline .450/.438 ms. No demonstrated significant performance win; retain as partial ownership migration, not a qualified optimization or deadline pass. Startup/all-step peaks remain in reports. Trajectories first diverge at step72 for baseline/baseline and candidate/baseline.

## Rejected candidates

Unconditional cooperative allocation regressed idle and fracture peaks; patch and screen preserved in ../cooperative-screen and ../screen. Conditional multi-kernel compaction failed synccheck, including an isolated reduction-plus-empty-kernel reproduction; evidence in ../conditional-multikernel. Production uses a single legal cooperative child in a conditional graph, passing all sanitizer gates. No alternate production execution switches were retained.

## Next

Continue replacement 1: initialize native motion storage directly from GPU decisions before CPU compatibility construction, then remove simulation registration and ownership prerequisites. Do not advance to ranked replacement 2 merely because the allocator passes.
