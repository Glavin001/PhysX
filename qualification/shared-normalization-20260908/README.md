# Shared component normalization

Accepted deletion of redundant arithmetic; deployment pending. Each CUDA block now computes the component-wide FP64 reciprocal once in its existing maximum reduction, rather than once per node. The cooperative large-component path is unchanged. No equations, convergence thresholds, physical iteration budgets, precision or graph ownership change. Compiler resources remain 94 registers / 48-byte stack; shared storage increases by 8 bytes.

[Repeated bombardment report](repeated/report.md): three 600-step runs per arm, 256 buildings / 113,664 chunks / 229,376 bonds / 768 physical projectiles each. Candidate means 44.155–44.881 ms versus 45.033–46.666 ms. Fracture peaks 132.604–138.325 ms versus 136.912–140.902 ms overlap, so no robust peak or real-time win is claimed. Startup peaks remain roughly 160 ms. [Pristine idle](idle/report.md) remains intact.

Three resident numerical suites pass, including a new 517-node zero/tiny/unit/large-value normalization test requiring bit-identical directions, gamma and error flags. Exact frozen wall passes (444 chunks / 896 bonds / one projectile; 398 retained, 46 detached, 199 broken). Eight ordinary native lifecycle checks pass. A separate heavy 256-building / 768-projectile / 600-step run checks full committed GPU/CPU mappings every tick and passes; it is excluded from performance results. All mapped library paths/hashes are attested in receipts.

At the first mass fracture both arms have 10,449 fragments, 10,193 awake fragments, 57,788 broken bonds and 357 maximum stress iterations, two stress evaluations and one correction. Later chaotic trajectories diverge; counts alone are not parity evidence. No 60-second or endurance gate, historical external-backend parity or completion is established.
