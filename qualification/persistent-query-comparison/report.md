# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| GPU slots baseline | 0.931 | 11.548 | 18.428 | 27.316 | 59.478 | 1038 | +0.00% | 14219 | Not established |
| Persistent query geometry | 0.912 | 11.428 | 18.066 | 26.176 | 49.302 | 1038 | -1.04% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

Retain query reconstruction deletion: identical-input short runs show reduced fracture-time query overhead and lower observed complete-step peaks. Average improves slightly; neither build meets the 8 ms primary-workload gate. CPU fragment/contact lifecycle and full correction remain.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| GPU slots baseline | /root/workspace/physx-2/out/device-motion-slots-impacts-256 | c3dc6d9d3b84573788a77067b9912a20c7c45d1e536070b1d51a55b1dec9d33d |
| Persistent query geometry | /root/workspace/physx-2/out/persistent-query-impacts-256 | d4283145bf39d552d3306a4c14c708f52a0929fe622689e0a136503fc457fe67 |
