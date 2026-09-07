# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Reconstructed index | 0.921 | 11.616 | 18.459 | 28.105 | 67.850 | 1038 | +0.00% | 14219 | Not established |
| Shared PhysX index | 0.908 | 11.529 | 18.495 | 27.352 | 55.572 | 1038 | -0.75% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

Delete the duplicate shape-ID representation. Native allocation and ownership still require CPU migration; this is not completion of GPU-native lifecycle.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Reconstructed index | /root/workspace/physx-2/out/lifecycle-verified-impacts-256 | 5bed6ef7c735c310d2ca6f983b66f6089f4b8052b7cb6e9e1e9a136722576429 |
| Shared PhysX index | /root/workspace/physx-2/out/shared-shape-impacts-256 | 05c62a4624be3e6be9493aaeba394d1798e611e53df12eccafb37c23a2430678 |
