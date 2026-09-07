# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Before | 0.966 | 11.380 | 18.050 | 25.608 | 50.600 | 1038 | +0.00% | 14219 | Not established |
| Warp broad phase | 0.973 | 11.395 | 17.885 | 25.720 | 49.174 | 1038 | +0.14% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

The GPU broad-phase kernel is faster in a focused diagnostic trace, but these complete-advance runs do not establish a material overall throughput improvement. CPU lifecycle work and other GPU destruction/correction work remain. The 8 ms peak gate still fails.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Before | /root/workspace/physx-2/out/native-pairs-final-impacts-256 | 173c58aca739f0ea09f012ceebcd1b8e4c819a2a409106bc3f14d828fe7be1ba |
| Warp broad phase | /root/workspace/physx-2/out/warp-incremental-impacts-256 | 7d051a0cad290e6631312aca6ee7bd04e4278d5ff2be33bde5c76db180ce459a |
