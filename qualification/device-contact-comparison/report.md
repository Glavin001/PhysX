# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Shared PhysX index | 0.908 | 11.529 | 18.495 | 27.352 | 55.572 | 1038 | +0.00% | 14219 | Not established |
| GPU contact lifetimes | 0.902 | 11.578 | 18.428 | 27.904 | 60.016 | 1038 | +0.43% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

GPU owns contact lifetime allocation and retained identity storage; CPU island-edge creation remains. Two short repeats are diagnostic, not full deadline qualification.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Shared PhysX index | /root/workspace/physx-2/out/shared-shape-impacts-256 | 05c62a4624be3e6be9493aaeba394d1798e611e53df12eccafb37c23a2430678 |
| GPU contact lifetimes | /root/workspace/physx-2/out/device-contact-impacts-256 | dce4a7b106c6a9a746f60c8ab9a5895478762b05883ab061d55e9f837949b43f |
