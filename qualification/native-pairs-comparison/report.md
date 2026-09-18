# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Previous | 0.912 | 11.428 | 18.066 | 26.176 | 49.302 | 1038 | +0.00% | 14219 | Not established |
| GPU pair canonicalization | 0.966 | 11.380 | 18.050 | 25.608 | 50.600 | 1038 | -0.42% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

The native path now canonicalizes actor contact pairs on GPU using existing PhysX report buffers. CPU pair sorting/duplicate removal is deleted from that path. This removes a CPU responsibility but does not demonstrate a material end-to-end speedup; the 8 ms deadline still fails. CPU contact creation/registration, fragment compatibility records and remaining ownership migration still need structural replacement.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Previous | /root/workspace/physx-2/out/persistent-query-impacts-256 | d4283145bf39d552d3306a4c14c708f52a0929fe622689e0a136503fc457fe67 |
| GPU pair canonicalization | /root/workspace/physx-2/out/native-pairs-final-impacts-256 | 173c58aca739f0ea09f012ceebcd1b8e4c819a2a409106bc3f14d828fe7be1ba |
