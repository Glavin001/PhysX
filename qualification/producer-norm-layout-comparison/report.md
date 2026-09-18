# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 1 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Baseline | 0.900 | 3.621 | 4.653 | 5.966 | 9.898 | 3 | +0.00% | 298 | Match |
| Rejected coordinate cache | 0.938 | 4.854 | 6.488 | 8.311 | 12.436 | 19 | +34.04% | 298 | Match |
| Rejected packed cache | 0.898 | 4.863 | 6.479 | 8.040 | 12.018 | 14 | +34.28% | 298 | Match |
| Producer-owned reductions | 0.929 | 3.472 | 4.461 | 5.822 | 9.526 | 4 | -4.12% | 298 | Match |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

Both residual-vector cache experiments were slower and have been removed from production. Producer-owned reductions retain global vector storage and remove atomic reduction/clearing work inside small-component iterations.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Baseline | /root/workspace/physx-2/out/component-stress-world-256 | 14706d1b1de59923eace67aef5b2c7dc60c27232db1357062f7a87807c8d19c9 |
| Rejected coordinate cache | /root/workspace/physx-2/out/shared-residual-world-256 | b36d869641b44157a2cc9998ce9827af7d9f20c41a7afc1e91ad58a863330022 |
| Rejected packed cache | /root/workspace/physx-2/out/packed-residual-world-256 | 4eaa408f686c0e1d46d54c5a71fbda85a9da5202a9427a735f9355c29321de79 |
| Producer-owned reductions | /root/workspace/physx-2/out/producer-norm-world-256 | cde600397b654b117081bf12f3b5a7bd74de5c7c8ebc38c331a1beacbc508585 |
