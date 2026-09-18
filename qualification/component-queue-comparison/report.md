# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Committed retained owners | 0.920 | 18.661 | 31.388 | 38.228 | 63.505 | 1038 | +0.00% | 14219 | Not established |
| Device component queue | 0.916 | 12.145 | 19.348 | 28.543 | 63.634 | 1038 | -34.92% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

The device queue changes assignment of independent components without changing their equations or reduction order. Complete-run fracture/correction/cluster histories are checked separately. Both captures still fail the 8 ms peak deadline; these two 10-second runs are diagnostic, not full five-run qualification.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Committed retained owners | /root/workspace/physx-2/out/retained-owner-final-impacts-256 | 3456eb0212320aa5e873acd952833a6308f5eb8a902e378c05c4e068639a8d75 |
| Device component queue | /root/workspace/physx-2/out/component-queue-impacts-256 | fcec03126157b7c88d2ce7e4c9629bbb4afc27a4bd163343c53b3397d5cba48e |
