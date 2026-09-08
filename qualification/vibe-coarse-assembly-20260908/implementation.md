# Coarse hierarchy scheduling improvement — short qualification

This changes our destruction stress hierarchy, not NVIDIA rigid-body solvers.

1. Coarse terminal and smoother construction distribute each matrix coefficient's bond sum across a warp. FP64 contributions, diagonal factorization and stopping tolerances remain.
2. Deep coarse residual and correction rows use eight CTAs with persistent partial storage and a fixed reduction tree. The local qualifier executes the same schedule serially across tiles. No physical rows are omitted.
3. Restriction at levels of at most 128 nodes reads their existing unique ownership map instead of scanning long adjacency lists with parallel bonds to rediscover membership.

Each candidate was built into a separate runtime. The table compares them against the deployed `007cf782…` embedded runtime with identical assets and recorded commands. It is **not** an external-backend comparison or real-time qualification. No candidate passes the peak deadline.

The final candidate passes the resident analytic, 3D and motion suites, supported-hierarchy transitions, long-row independent dense V-cycle oracle, local/cooperative parity, CUDA synccheck and memcheck. The exact frozen wall has 444 chunks, 896 bonds, one projectile, 398 retained chunks, 46 detached chunks, 199 broken bonds, and unchanged topology signature/clearance. Receipts and logs are adjacent.

The ordinary-scene penetration audit was initially invoked against the Direct-GPU frozen golden. That invocation failed on topology identity (201 broken bonds rather than 199); it was retained, and the exact frozen configuration was then run unchanged and passed. This is not a waived assertion: ordinary mode is validated separately, and the differently configured observation requires a baseline control.

Downtown is not bit-identical across changes to FP64 reduction ordering. Per-tick differences and final workload counts are in analysis.json. The tiled candidates end with 480 broken bonds and 31 fragment bodies versus 481 and 32 in the deployed replay. The controlled frozen fixture remains exact. These short chaotic-scene screens cannot establish absence of all physical regressions or endurance.

The original intrusive Nsight trace attributes 92.4% of aggregate CUDA kernel duration in the 600-step three-shot city replay to the large-component resident stress kernel. That is aggregate device work, not a partition of the worst wall-clock step. It also records expensive terminal/smoother construction. The trace is in `out/vibe-after-shots-trace-b-20260908`; it is separate from untraced performance captures.
