# 🔎 Correction broad phase: GPU execution versus CPU waiting

256 buildings, 113664 chunks, 229376 bonds, 256 projectiles. Each capture covers 3 simulated seconds at 1/60 s; correction limit 1. The table isolates correction step 82, not the maximum across all frames.

These are separate instrumented CUDA/CPU diagnostics. Complete-step deadline decisions use the untraced campaigns. GPU intervals are clipped to the host broad-phase scope. Busy time is their union, so concurrent kernels and copies are not added twice. CPU thread time includes the existing spin wait; it is not evidence of additional collision computation on CPU.

| Capture | Host broad-phase span ms | CPU thread time incl. spin ms | GPU busy union ms | Incremental SAP kernel ms |
|---|---|---|---|---|
| Before | 9.091 | 9.085 | 9.045 | 7.944 |
| Warp aggregation | 7.408 | 7.407 | 7.358 | 6.129 |

The original broad-phase span was dominated by GPU execution while the CPU waited. GPU warp lookup/report aggregation improves the measured kernel, but a single diagnostic comparison does not establish a repeatable end-to-end speedup. Hardware-counter collection was separately denied (ERR_NVGPUCTRPERM), so these timings do not establish an occupancy, bandwidth or arithmetic-throughput limit.

## Before — observed kernels

| Kernel | Calls overlapping scope | Summed clipped kernel ms |
|---|---|---|
| performIncrementalSAP | 1 | 7.944 |
| computeStartAndActiveRegionHistogram | 1 | 0.367 |
| generateFoundPairsForNewBoundsRegion | 1 | 0.230 |
| writeOutOverlapChecksForInsertedBoundsRegionsHistogram | 1 | 0.056 |
| createRegionsKernel | 1 | 0.042 |
| outputOrderedActiveRegionHistogram | 1 | 0.041 |
| nativePairMerge | 13 | 0.036 |
| writeOutStartAndActiveRegionHistogram | 1 | 0.031 |
| computeIncrementalComparisonHistograms_Stage1 | 1 | 0.028 |
| clearNewFlagLaunch | 1 | 0.023 |
| computeEndPtsHistogram | 1 | 0.013 |
| outputEndPtsHistogram | 1 | 0.013 |

Kernel rows can overlap; do not add them to the host task or the union total.

## Warp aggregation — observed kernels

| Kernel | Calls overlapping scope | Summed clipped kernel ms |
|---|---|---|
| performIncrementalSAP | 1 | 6.129 |
| computeStartAndActiveRegionHistogram | 1 | 0.370 |
| generateFoundPairsForNewBoundsRegion | 1 | 0.232 |
| computeIncrementalComparisonHistograms_Stage1 | 1 | 0.064 |
| writeOutOverlapChecksForInsertedBoundsRegionsHistogram | 1 | 0.056 |
| radixSortMultiCalculateRanksLaunchWithCount | 6 | 0.049 |
| createRegionsKernel | 1 | 0.042 |
| outputOrderedActiveRegionHistogram | 1 | 0.041 |
| nativePairMerge | 13 | 0.037 |
| writeOutStartAndActiveRegionHistogram | 1 | 0.031 |
| clearNewFlagLaunch | 1 | 0.023 |
| radixSortMultiBlockLaunchWithCount | 5 | 0.020 |

Kernel rows can overlap; do not add them to the host task or the union total.

## Evidence

| Capture | Directory | Dropped activity records |
|---|---|---|
| Before | /root/workspace/physx-2/out/native-contact-lifecycle-trace | 0 |
| Warp aggregation | /root/workspace/physx-2/out/native-warp-incremental-trace | 0 |
