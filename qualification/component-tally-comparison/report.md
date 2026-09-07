# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Device component queue | 0.916 | 12.145 | 19.348 | 28.543 | 63.634 | 1038 | +0.00% | 14219 | Not established |
| Scalar component tally | 0.883 | 11.603 | 18.594 | 27.443 | 63.182 | 1038 | -4.46% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

The single-component convergence tally no longer performs an unnecessary block-wide integer reduction. Convergence equations and physical settings are unchanged. Focused tests and the frozen penetration audit pass; full large-scene qualification remains incomplete. Neither two-by-ten-second diagnostic capture passes the 8 ms peak deadline.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Device component queue | /root/workspace/physx-2/out/component-queue-impacts-256 | fcec03126157b7c88d2ce7e4c9629bbb4afc27a4bd163343c53b3397d5cba48e |
| Scalar component tally | /root/workspace/physx-2/out/component-tally-impacts-256 | c227211c1d34c52bf33a3ddbd25ad2175174a9cb74e8061d6f7572114ec68fdb |
