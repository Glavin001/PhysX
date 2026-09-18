# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| GPU contact lifetimes | 0.902 | 11.578 | 18.428 | 27.904 | 60.016 | 1038 | +0.00% | 14219 | Not established |
| GPU initialization dependency | 0.913 | 11.554 | 18.432 | 27.317 | 54.048 | 1038 | -0.22% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

Initialization now queues device validation without an intermediate host observation. Full CPU fragment/contact lifecycle and the 8 ms bombardment gate remain unfinished. Two short repeats are diagnostic.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| GPU contact lifetimes | /root/workspace/physx-2/out/device-contact-impacts-256 | dce4a7b106c6a9a746f60c8ab9a5895478762b05883ab061d55e9f837949b43f |
| GPU initialization dependency | /root/workspace/physx-2/out/device-initialization-impacts-256 | fa607ec34a14c8ab8242012f3046bef00d087a940de3cd736b98179d045fe00d |
