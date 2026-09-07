# 🧪 Destruction implementation comparison

Identical workload: 256 buildings, 113664 chunks, 229376 bonds, 256 projectile(s), 2 × 10 simulated seconds per implementation. Timestep 1/60 second; correction limit one; sleeping disabled.

Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. Initialization, rendering and reporting are excluded. Every measured step is retained. Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.

| Implementation | Min ms | Mean ms | p95 ms | p99 ms | Worst ms | >8 ms steps | Mean change | Peak clusters | Frozen wall counters |
|---|---|---|---|---|---|---|---|---|---|
| Retained original (rebuilt) | 0.974 | 11.379 | 17.920 | 26.188 | 51.781 | 1038 | +0.00% | 14219 | Not established |
| Earlier retained baseline | 0.973 | 11.395 | 17.885 | 25.720 | 49.174 | 1038 | +0.14% | 14219 | Not established |
| Rejected shared residual (AoS) | 0.989 | 13.486 | 21.079 | 26.640 | 51.598 | 1038 | +18.52% | 14219 | Not established |
| Rejected shared residual (SoA) | 1.000 | 13.149 | 20.685 | 27.136 | 50.459 | 1038 | +15.55% | 14219 | Not established |
| Rejected maximum workers | 0.980 | 12.462 | 19.882 | 27.215 | 51.169 | 1038 | +9.51% | 14219 | Not established |
| Rejected one worker per SM | 0.980 | 11.571 | 18.525 | 26.517 | 52.439 | 1038 | +1.69% | 14219 | Not established |

Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. See the separate physical and motion audits before treating an implementation as qualified. Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.

All four alternatives are removed from production. Neither shared-residual layout nor changing the resident worker count improved this workload. The original solver is restored and remeasured. The new analytic topology-transition regression remains. Peak 8 ms qualification, GPU lifecycle migration and resident multilevel preconditioning remain incomplete.

## Reproduce and inspect

| Implementation | Capture | Manifest SHA-256 |
|---|---|---|
| Retained original (rebuilt) | /root/workspace/physx-2/out/component-restored-impacts-256 | 6898ec6d71554d19d9806d3806027825f305cbe0188abfcd5cb8cdf53e12eb16 |
| Earlier retained baseline | /root/workspace/physx-2/out/warp-incremental-impacts-256 | 7d051a0cad290e6631312aca6ee7bd04e4278d5ff2be33bde5c76db180ce459a |
| Rejected shared residual (AoS) | /root/workspace/physx-2/out/component-residual-impacts-256 | 30be91d0d46a6d7d6eeb062ce39df22875365a2e2769089b347a5d7b98ad68dc |
| Rejected shared residual (SoA) | /root/workspace/physx-2/out/component-residual-soa-impacts-256 | d6fa8ba998f874276a214e383497d3b603ec7ae4b85b29264df85e2d8efbe6f0 |
| Rejected maximum workers | /root/workspace/physx-2/out/component-occupancy-impacts-256 | 6017b60b4b02645d49d19f90afa3267b9925cf981e21f42ed269c4004a8ec2a6 |
| Rejected one worker per SM | /root/workspace/physx-2/out/component-single-worker-impacts-256 | 86bfa90f0ab2db645ea58172e8cf1de2ef36e91faba8c6300b61a93a89a71bc8 |
