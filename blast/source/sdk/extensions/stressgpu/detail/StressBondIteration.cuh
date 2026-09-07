// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
__global__ void checkConvergencePerIsland(
    std::uint32_t* islandActive,
    std::uint32_t* islandConverged,
    const float* residualSquared,
    const float* deltaSquared,
    std::uint32_t* blockActiveCounts,
    std::uint32_t islandCount)
{
    __shared__ std::uint32_t partial[kBlockSize];
    const std::uint32_t tid = threadIdx.x;
    const std::uint32_t id = blockIdx.x * blockDim.x + tid;

    std::uint32_t active = 0;
    if (id < islandCount && islandActive[id])
    {
        if (residualSquared[id] <= deltaSquared[id])
        {
            islandActive[id] = 0;
            // Reaching tolerance is what earns the right to be skipped later,
            // and it is recorded separately from `active` because retiring a
            // degenerate island also clears `active` -- freezing an island
            // that gave up rather than converged would preserve stale,
            // inflated stress and keep breaking bonds off it.
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
        blockActiveCounts[blockIdx.x] = partial[0];
    }
}

/// Roll the per-island flags up into the single status the host reads.
/// Zero the active counter before the parallel tally below accumulates into it.
///
/// Split from the tally so the tally can be a grid-wide reduction: a kernel
/// that both clears and accumulates a shared counter would race itself across
/// blocks.
__global__ void resetActiveCount(SolveStatus* status)
{
    if (threadIdx.x == 0 && blockIdx.x == 0)
    {
        status->active = 0;
    }
}

/// Count active islands in parallel and latch convergence.
///
/// MEASURED, and this was the single biggest cost in the whole solve. The
/// previous version ran <<<1,1>>> -- one thread walking every island, every
/// iteration. Per-kernel event timing at city scale (24k nodes, 34k bonds,
/// 2000 islands, 32 iterations):
///
///   summarizeIslands            0.7932 ms/solve   24.79 us/launch   34.8%
///   couplingRightMultiply       0.3846 ms/solve   11.66 us/launch   16.9%
///   accumulateSquaredByIsland   0.2506 ms/solve    3.86 us/launch   11.0%
///   ...every other kernel        2.8-4.2 us/launch
///
/// 2000 serial iterations on one CUDA core is ~24 us, which is exactly what
/// it measured -- real serial work, not launch overhead, and it stalled the
/// pipeline between the two halves of every CG iteration. One thread was
/// doing what 16,384 could.
///
/// Block-level reduction in shared memory, then one integer atomicAdd per
/// block. Integer atomics are exact and order-independent, so the result is
/// identical to the serial sum, not merely close -- the same count, every
/// run.
__global__ void summarizeIslands(
    SolveStatus* status,
    const std::uint32_t* islandActive,
    std::uint32_t islandCount,
    std::uint32_t iteration)
{
    __shared__ std::uint32_t partial[kBlockSize];
    const std::uint32_t tid = threadIdx.x;
    const std::uint32_t index = blockIdx.x * blockDim.x + tid;
    partial[tid] = (index < islandCount && islandActive[index] != 0u) ? 1u : 0u;
    __syncthreads();
    for (std::uint32_t stride = blockDim.x / 2; stride > 0; stride >>= 1)
    {
        if (tid < stride)
        {
            partial[tid] += partial[tid + stride];
        }
        __syncthreads();
    }
    if (tid == 0 && partial[0] != 0u)
    {
        atomicAdd(&status->active, partial[0]);
    }
}

/// Latch convergence once the tally above is complete.
///
/// Separate launch because the decision needs the FINAL count, and a block
/// cannot know whether it was the last to contribute without another
/// synchronisation. One thread is correct here: the work is O(1).
__global__ void latchConvergence(SolveStatus* status, std::uint32_t iteration)
{
    if (threadIdx.x == 0 && blockIdx.x == 0)
    {
        if (status->active == 0 && !status->converged)
        {
            status->converged = 1;
            status->iterations = iteration;
        }
    }
}

__global__ void checkConvergence(
    SolveStatus* status,
    const float* residualSquared,
    const float* deltaSquared,
    std::uint32_t iteration)
{
    if (threadIdx.x == 0 && blockIdx.x == 0
        && status->active
        && *residualSquared <= *deltaSquared)
    {
        status->active = 0;
        status->iterations = iteration;
        status->converged = 1;
    }
}

__global__ void updateDirectionPerIsland(
    AngLin* direction,
    const AngLin* gradient,
    const float* gradientSquared,
    const float* previousGradientSquared,
    const std::uint32_t* bondIsland,
    const std::uint32_t* islandActive,
    const std::uint32_t* activeBonds,
    const std::uint32_t* activeCounts,
    const std::uint32_t* iterationPtr)
{
    const std::uint32_t iteration = *iterationPtr;
    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot >= activeCounts[0])
    {
        return;
    }
    const std::uint32_t index = activeBonds[slot];
    const std::uint32_t id = bondIsland[index];
    if (id == kNoIsland || !islandActive[id])
    {
        return;
    }
    if (iteration == 0)
    {
        direction[index] = gradient[index];
        return;
    }
    const float denominator = previousGradientSquared[id];
    const float beta = denominator > 0.0f ? gradientSquared[id] / denominator : 0.0f;
    direction[index].angular =
        add(gradient[index].angular, mul(direction[index].angular, beta));
    direction[index].linear =
        add(gradient[index].linear, mul(direction[index].linear, beta));
}

__global__ void saveGradientSquaredPerIsland(
    float* previousGradientSquared,
    const float* gradientSquared,
    const std::uint32_t* islandActive,
    std::uint32_t islandCount)
{
    const std::uint32_t id = blockIdx.x * blockDim.x + threadIdx.x;
    if (id < islandCount && islandActive[id])
    {
        previousGradientSquared[id] = gradientSquared[id];
    }
}

/// Each island advances by its own step size. A degenerate island (zero or
/// non-finite denominator) retires itself without disturbing the others.
__global__ void updateSolutionAndResidualPerIsland(
    const std::uint32_t* iterationPtr,
    std::uint32_t maxIterations,
    AngLin* solution,
    AngLin* residual,
    const AngLin* direction,
    const AngLin* projectedDirection,
    const float* gradientSquared,
    const float* projectedDirectionSquared,
    std::uint32_t* islandActive,
    const std::uint32_t* bondIsland,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* activeBonds,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts)
{
    // Chunked loop control (see launchConditionalLoopCaptured): the while-node
    // condition is evaluated every kChunk iterations, so the body can overshoot
    // the budget by up to kChunk-1 iterations. This is the one kernel that
    // mutates the solution, so guarding it here makes the overshoot a pure
    // no-op and keeps the chunked, unchunked and unrolled paths bit-identical.
    // Every other per-iteration buffer is scratch that only feeds this kernel.
    if (*iterationPtr > maxIterations)
    {
        return;
    }

    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot < activeCounts[0])
    {
        const std::uint32_t index = activeBonds[slot];
        const std::uint32_t id = bondIsland[index];
        if (id != kNoIsland && islandActive[id])
        {
            const float denominator = projectedDirectionSquared[id];
            if (denominator > 0.0f && isfinite(denominator))
            {
                const float step = gradientSquared[id] / denominator;
                solution[index].angular =
                    add(solution[index].angular, mul(direction[index].angular, step));
                solution[index].linear =
                    add(solution[index].linear, mul(direction[index].linear, step));
            }
        }
    }
    if (slot < activeCounts[1])
    {
        const std::uint32_t index = activeNodes[slot];
        const std::uint32_t id = nodeIsland[index];
        if (id != kNoIsland && islandActive[id])
        {
            const float denominator = projectedDirectionSquared[id];
            if (denominator > 0.0f && isfinite(denominator))
            {
                const float step = gradientSquared[id] / denominator;
                residual[index].angular =
                    sub(residual[index].angular, mul(projectedDirection[index].angular, step));
                residual[index].linear =
                    sub(residual[index].linear, mul(projectedDirection[index].linear, step));
            }
        }
    }
}

/// Retire islands whose step is degenerate. Separate pass so the update above
/// stays branch-simple and every island sees a consistent active flag.
/// Retire degenerate islands, roll the gradient norm forward, and latch
/// convergence -- three island-grid launches fused into one.
///
/// The ordering that makes this legal: saveGradientSquared must run after
/// updateDirection has READ previousGradientSquared, and by this point in the
/// iteration it has. Latching needs the completed active tally from
/// checkConvergencePerIsland, and that kernel finished earlier on the same
/// stream. Every read here is of a value already final.
__global__ void retireDegenerateIslands(
    std::uint32_t* islandActive,
    const float* projectedDirectionSquared,
    float* previousGradientSquared,
    const float* gradientSquared,
    SolveStatus* status,
    const std::uint32_t* blockActiveCounts,
    std::uint32_t blockCount,
    std::uint32_t* iterationPtr,
    std::uint32_t islandCount,
    // Loop control, folded in here rather than run as its own kernel: this is
    // already the one place that knows how many islands are still active, and
    // at ~30k islands an extra launch per iteration cost ~8% of the intact
    // city's solve for a value that was sitting in a register.
    cudaGraphConditionalHandle loopHandle,
    std::uint32_t maxIterations)
{
    const std::uint32_t id = blockIdx.x * blockDim.x + threadIdx.x;
    if (id < islandCount)
    {
        if (islandActive[id])
        {
            const float denominator = projectedDirectionSquared[id];
            if (!(denominator > 0.0f) || !isfinite(denominator))
            {
                islandActive[id] = 0;
            }
            // Fold of saveGradientSquaredPerIsland: an island that is not
            // active never reads this again, so rolling it forward only for
            // active islands preserves every value the split kernels
            // produced. (The original guarded on islandActive too.)
            previousGradientSquared[id] = gradientSquared[id];
        }
    }

    if (blockIdx.x == 0 && threadIdx.x == 0)
    {
        // Only this thread touches the counter, and only after every other
        // kernel in the iteration has read it, so the read-modify-write needs
        // no synchronisation.
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
            // Non-zero keeps the enclosing cudaGraphCondTypeWhile node looping.
            // `active` is this iteration's count, not last iteration's, which
            // is why folding the decision in here is also more accurate than
            // the separate kernel it replaces.
            cudaGraphSetConditional(
                loopHandle, (active != 0u && next < maxIterations) ? 1u : 0u);
        }
    }
}

