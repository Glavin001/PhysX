# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Committed baseline | 0.929 | 18.896 | 33.352 | 55.171 | 86.243 | 1038 | +0.00% | 14096 | Not established |
| Retained GPU ownership | 0.920 | 18.661 | 31.388 | 38.228 | 63.505 | 1038 | -1.24% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

The candidate passes focused native tests, the frozen penetration audit and a separate 10-second bombardment contact/ownership/motion audit. Large-scene fracture histories differ from the baseline, so these measurements are not an identical-trajectory speedup claim. Both implementations fail the 8 ms bombardment gate; full quality and endurance qualification remain incomplete.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Committed baseline | /root/workspace/physx-2/out/producer-norm-impacts-256 | df91ea9529ac285ad200ca479720a61be2e3f57de7aac035a055babd10083238 |
| Retained GPU ownership | /root/workspace/physx-2/out/retained-owner-final-impacts-256 | 3456eb0212320aa5e873acd952833a6308f5eb8a902e378c05c4e068639a8d75 |
