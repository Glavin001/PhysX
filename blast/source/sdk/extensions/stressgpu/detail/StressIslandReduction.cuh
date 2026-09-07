// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
/// Per-island sum of squared magnitudes, accumulated into PADDED slots.
///
/// Islands are disconnected components, so their conjugate-gradient scalars
/// must be independent: a shared alpha/beta compromises every island toward
/// the average, and a shared convergence test lets a large well-conditioned
/// island hide a small badly-solved one. Bonds and nodes are not stored
/// island-contiguous, so a segmented library reduce is not available and this
/// has to be an atomic scatter.
///
/// The naive form -- one atomicAdd per element onto ONE accumulator per island
/// -- was measured at 76% of the entire solve (6.88 ms of 9.04 ms, 106 us per
/// launch, twice per CG iteration) on the 298k-bond city. The cause is
/// contention, not bandwidth: 298k atomics onto 108 addresses is 2,760-way
/// serialization per address, while the two matvecs either side of it run at
/// 2-3 TB/s because the working set is L2-resident.
///
/// So give each island `slots` accumulators and hash the element onto one by
/// its thread index. Consecutive lanes in a warp land on consecutive slots, so
/// a warp's 32 atomics go to 32 distinct addresses and never serialize against
/// each other. `finalizeIslandReduction` then sums the slots.
///
/// `slots` is chosen per call from the average island occupancy, because the
/// padding is a pure loss in the regime it is not needed for: a fully
/// fractured city is ~96k islands of ~4 elements, where contention is already
/// nil and a wide second pass would cost more than the atomics it saves.
/// See ExtStressGpuSolverImpl::reductionSlots.
__global__ void accumulateSquaredByIsland(
    const AngLin* values,
    const std::uint32_t* island,
    const std::uint32_t* islandSkip,
    float* perIslandSlots,
    const std::uint32_t* activeList,
    const std::uint32_t* activeCounts,
    std::uint32_t whichCount,
    std::uint32_t slotCount)
{
    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot >= activeCounts[whichCount])
    {
        return;
    }
    const std::uint32_t index = activeList[slot];
    const std::uint32_t id = island[index];
    if (id == kNoIsland)
    {
        return;
    }
    if (islandSkip != nullptr && islandSkip[id] != 0u)
    {
        return;     // settled: its scalars are never consulted this solve
    }
    const AngLin& value = values[index];
    const float squared =
        value.angular.x * value.angular.x + value.angular.y * value.angular.y +
        value.angular.z * value.angular.z + value.linear.x * value.linear.x +
        value.linear.y * value.linear.y + value.linear.z * value.linear.z;
    if (slotCount == 0u) perIslandSlots[index] = squared;
    else atomicAdd(&perIslandSlots[id * slotCount + (slot & (slotCount - 1u))], squared);
}

// Each tile belongs to one island and covers up to 1,024 ascending element
// indices. Several CTAs can reduce a large island concurrently; small islands
// need only one tile. Every addition has a fixed position in the tree, with no
// cross-CTA floating atomics. Tile storage is O(nodes + bonds + islands).
constexpr std::uint32_t kDeterministicTileSize = 1024u;
__global__ void reduceIslandTiles(
    const float* values, const std::uint32_t* order,
    const uint2* tiles, float* results, const std::uint32_t* tileCount)
{
    __shared__ float partial[kBlockSize];
    const std::uint32_t end = tileCount ? *tileCount : gridDim.x;
    for (std::uint32_t tileIndex=blockIdx.x; tileIndex<end; tileIndex+=gridDim.x)
    {
    const uint2 tile = tiles[tileIndex];
    float sum = 0.0f;
    for (std::uint32_t i = tile.x + threadIdx.x; i < tile.y; i += blockDim.x)
        sum += values[order[i]];
    partial[threadIdx.x] = sum;
    __syncthreads();
    for (std::uint32_t stride = blockDim.x / 2u; stride; stride >>= 1u)
    {
        if (threadIdx.x < stride) partial[threadIdx.x] += partial[threadIdx.x + stride];
        __syncthreads();
    }
    if (threadIdx.x == 0u) results[tileIndex] = partial[0];
    __syncthreads();
    }
}

__device__ float sumIslandPartials(
    const float* values, std::uint32_t id, std::uint32_t slots,
    const std::uint32_t* partialBegin)
{
    const std::size_t begin = partialBegin ? partialBegin[id] : static_cast<std::size_t>(id) * slots;
    const std::size_t end = partialBegin ? partialBegin[id + 1u] : begin + slots;
    float sum = 0.0f;
    for (std::size_t i = begin; i < end; ++i) sum += values[i];
    return sum;
}

/// Collapse the padded slots to one value per island.
///
/// One thread per island, reading `slots` contiguous floats. At 108 islands
/// and 32 slots that is 13.8 KB -- far below the cost of the contention it
/// removes. Summation order is fixed (ascending slot), so this pass is
/// deterministic. The optional partialBegin selects fixed-order tiled sums;
/// the legacy padded slots still contain unordered atomic accumulation.
__global__ void finalizeIslandReduction(
    const float* perIslandSlots,
    float* result,
    std::uint32_t islandCount,
    std::uint32_t slots,
    const std::uint32_t* partialBegin)
{
    const std::uint32_t id = blockIdx.x * blockDim.x + threadIdx.x;
    if (id >= islandCount)
    {
        return;
    }
    result[id] = sumIslandPartials(perIslandSlots, id, slots, partialBegin);
}

/// One thread per island: retire islands that have reached tolerance. An
/// island that stops here stops costing iterations, which is what makes
/// solving to a residual tolerance affordable instead of running a fixed
/// budget for the whole graph.
/// Convergence test AND the active tally, fused.
///
/// They were two launches over the same island grid, back to back, reading
/// the same array. At ~3 us of launch latency per kernel -- which is what
/// every small kernel in this solve costs, measured -- a launch that does one
/// comparison per island is nearly all overhead. Fusing removes one launch
/// per iteration and the separate counter reset with it.
///
/// The tally writes ONE partial per block instead of accumulating into a
/// shared counter: with ~8 blocks at city scale the final sum is trivial for
/// the latch kernel, it needs no reset beforehand, and it is exact and
/// order-independent by construction rather than by argument.
/// Slot-sum + convergence test + block tally, in one launch.
///
/// These were three separate island-grid kernels. At realistic island counts
/// that is almost pure launch overhead: 1,243 islands is five blocks of work,
/// and the three kernels measured 3.5-4.6 us EACH per launch against ~10-25 us
/// for the kernels that do real work. Fusing the pairs that were already
/// adjacent and share a grid shape removes two launches per CG iteration.
__device__ __forceinline__ void finalizeAndCheckConvergenceBody(
    const float* perIslandSlots,
    float* result,
    std::uint32_t slots,
    std::uint32_t* islandActive,
    std::uint32_t* islandConverged,
    const float* deltaSquared,
    std::uint32_t* blockActiveCounts,
    std::uint32_t islandCount,
    const std::uint32_t* partialBegin, unsigned logicalBlock)
{
    __shared__ std::uint32_t partial[kBlockSize];
    const std::uint32_t tid = threadIdx.x;
    const std::uint32_t id = logicalBlock * blockDim.x + tid;

    float sum = 0.0f;
    if (id < islandCount)
    {
        sum = sumIslandPartials(perIslandSlots, id, slots, partialBegin);
        result[id] = sum;
    }

    std::uint32_t active = 0;
    if (id < islandCount && islandActive[id])
    {
        if (sum <= deltaSquared[id])
        {
            islandActive[id] = 0;
            islandConverged[id] = 1;
        }
        else
        {
            active = 1;
        }
    }
    partial[tid] = active;
    __syncthreads();
    for (std::uint32_t stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if (tid < stride)
        {
            partial[tid] += partial[tid + stride];
        }
        __syncthreads();
    }
    if (tid == 0)
    {
        blockActiveCounts[logicalBlock] = partial[0];
    }
}

__global__ void finalizeAndCheckConvergence(
    const float* perIslandSlots,
    float* result,
    std::uint32_t slots,
    std::uint32_t* islandActive,
    std::uint32_t* islandConverged,
    const float* deltaSquared,
    std::uint32_t* blockActiveCounts,
    std::uint32_t islandCount,
    const std::uint32_t* partialBegin)
{ finalizeAndCheckConvergenceBody(perIslandSlots, result, slots, islandActive, islandConverged, deltaSquared, blockActiveCounts, islandCount, partialBegin, blockIdx.x); }

/// Slot-sum + degenerate retirement + loop control, in one launch.
__device__ __forceinline__ void finalizeAndRetireBody(
    const float* perIslandSlots,
    float* result,
    std::uint32_t slots,
    std::uint32_t* islandActive,
    float* previousNumerator,
    const float* numerator,
    SolveStatus* status,
    const std::uint32_t* blockActiveCounts,
    std::uint32_t blockCount,
    std::uint32_t* iterationPtr,
    std::uint32_t islandCount,
    cudaGraphConditionalHandle loopHandle,
    std::uint32_t maxIterations,
    const std::uint32_t* partialBegin, unsigned logicalBlock)
{
    const std::uint32_t id = logicalBlock * blockDim.x + threadIdx.x;
    if (id < islandCount)
    {
        const float sum = sumIslandPartials(perIslandSlots, id, slots, partialBegin);
        result[id] = sum;
        if (islandActive[id])
        {
            if (!(sum > 0.0f) || !isfinite(sum))
            {
                islandActive[id] = 0;
            }
            previousNumerator[id] = numerator[id];
        }
    }

    if (logicalBlock == 0 && threadIdx.x == 0)
    {
        const std::uint32_t iteration = *iterationPtr;
        std::uint32_t active = 0;
        for (std::uint32_t i = 0; i < blockCount; ++i)
        {
            active += blockActiveCounts[i];
        }
        status->active = active;
        if (active == 0 && !status->converged)
        {
            status->converged = 1;
            status->iterations = iteration;
        }
        const std::uint32_t next = iteration + 1u;
        *iterationPtr = next;
        if (loopHandle != 0)
        {
            cudaGraphSetConditional(
                loopHandle, (active != 0u && next < maxIterations) ? 1u : 0u);
        }
    }
}

__global__ void finalizeAndRetire(
    const float* perIslandSlots,
    float* result,
    std::uint32_t slots,
    std::uint32_t* islandActive,
    float* previousNumerator,
    const float* numerator,
    SolveStatus* status,
    const std::uint32_t* blockActiveCounts,
    std::uint32_t blockCount,
    std::uint32_t* iterationPtr,
    std::uint32_t islandCount,
    cudaGraphConditionalHandle loopHandle,
    std::uint32_t maxIterations,
    const std::uint32_t* partialBegin)
{ finalizeAndRetireBody(perIslandSlots, result, slots, islandActive, previousNumerator, numerator, status, blockActiveCounts, blockCount, iterationPtr, islandCount, loopHandle, maxIterations, partialBegin, blockIdx.x); }

