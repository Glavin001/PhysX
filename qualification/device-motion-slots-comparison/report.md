# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Baseline | 0.913 | 11.554 | 18.432 | 27.317 | 54.048 | 1038 | +0.00% | 14219 | Not established |
| GPU slots | 0.931 | 11.548 | 18.428 | 27.316 | 59.478 | 1038 | -0.04% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

GPU native slot selection is retained as ownership migration. Complete-step mean is effectively unchanged; no end-to-end speedup is established. CPU compatibility lifecycle and full correction remain, and neither build meets the 8 ms primary-workload gate.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Baseline | /root/workspace/physx-2/out/device-initialization-impacts-256 | fa607ec34a14c8ab8242012f3046bef00d087a940de3cd736b98179d045fe00d |
| GPU slots | /root/workspace/physx-2/out/device-motion-slots-impacts-256 | c3dc6d9d3b84573788a77067b9912a20c7c45d1e536070b1d51a55b1dec9d33d |
