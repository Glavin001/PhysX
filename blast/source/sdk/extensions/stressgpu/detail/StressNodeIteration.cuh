// Private implementation fragment; included once inside the owning .cu namespace.
// Shared direction, motion update and initialization kernels.
/// pi = rho + beta pi ;  q = w + beta q, and ||q||^2 accumulated in the same
/// pass.
///
/// This kernel already has the new q in registers, so reducing it here removes
/// a whole separate pass that re-read q from memory (32 B/node) plus its kernel
/// launch, every iteration.
__device__ __forceinline__ void nodeSpaceUpdateDirectionBody(
    AngLin* pi,
    AngLin* q,
    const AngLin* rho,
    const AngLin* w,
    const float* zSq,
    const float* zSqPrev,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* islandActive,
    float* qSqSlots,
    std::uint32_t slotCount,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts,
    const std::uint32_t* iteration, unsigned logicalBlock,
    float* nodeContribution = nullptr)
{
    const std::uint32_t slot = logicalBlock * blockDim.x + threadIdx.x;
    if (slot >= activeCounts[1])
    {
        return;
    }
    const std::uint32_t node = activeNodes[slot];
    const std::uint32_t island = nodeIsland[node];
    if (island == kNoIsland || !islandActive[island])
    {
        return;
    }
    // A first solve has no previous gradient value. Do not even read that
    // storage on the restart iteration; the first beta is exactly zero.
    const float denominator = *iteration != 0u ? zSqPrev[island] : 0.0f;
    // The first direction belongs to this solve. A quiet previous solve can
    // leave a subnormal denominator; forming new/old then multiplying the
    // reset vectors by infinity produces NaNs and retires a loaded island.
    // Match the bond-space solver's explicit first-iteration restart.
    const float beta = *iteration != 0u && denominator > 0.0f
        ? zSq[island] / denominator : 0.0f;
    // `rho` is the preconditioned direction source: it is rho itself when
    // unpreconditioned, and g = N w when preconditioned.
    pi[node].angular = add(rho[node].angular, mul(pi[node].angular, beta));
    pi[node].linear = add(rho[node].linear, mul(pi[node].linear, beta));
    const Vec4 qa = add(w[node].angular, mul(q[node].angular, beta));
    const Vec4 ql = add(w[node].linear, mul(q[node].linear, beta));
    q[node].angular = qa;
    q[node].linear = ql;
    const float qSq = qa.x * qa.x + qa.y * qa.y + qa.z * qa.z
                    + ql.x * ql.x + ql.y * ql.y + ql.z * ql.z;
    if (nodeContribution) *nodeContribution = stressSquaredContribution(qSq);
    else if (slotCount == 0u) qSqSlots[node] = qSq;
    else atomicAdd(&qSqSlots[island * slotCount + (slot & (slotCount - 1u))], qSq);
}

__global__ void nodeSpaceUpdateDirection(
    AngLin* pi,
    AngLin* q,
    const AngLin* rho,
    const AngLin* w,
    const float* zSq,
    const float* zSqPrev,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* islandActive,
    float* qSqSlots,
    std::uint32_t slotCount,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts,
    const std::uint32_t* iteration)
{ nodeSpaceUpdateDirectionBody(pi, q, rho, w, zSq, zSqPrev, nodeIsland, islandActive, qSqSlots, slotCount, activeNodes, activeCounts, iteration, blockIdx.x); }

/// mu += alpha pi ;  rho -= alpha q
__device__ __forceinline__ void nodeSpaceUpdateSolutionBody(
    const std::uint32_t* iterationPtr,
    std::uint32_t maxIterations,
    AngLin* mu,
    AngLin* rho,
    const AngLin* pi,
    const AngLin* q,
    const float* zSq,
    const float* qSq,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* islandActive,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts, unsigned logicalBlock)
{
    if (*iterationPtr > maxIterations)
    {
        return;   // chunked-loop overshoot guard; see the bond-space twin
    }
    const std::uint32_t slot = logicalBlock * blockDim.x + threadIdx.x;
    if (slot >= activeCounts[1])
    {
        return;
    }
    const std::uint32_t node = activeNodes[slot];
    const std::uint32_t island = nodeIsland[node];
    if (island == kNoIsland || !islandActive[island])
    {
        return;
    }
    const float denominator = qSq[island];
    if (!(denominator > 0.0f) || !isfinite(denominator))
    {
        return;
    }
    const float alpha = zSq[island] / denominator;
    mu[node].angular = add(mu[node].angular, mul(pi[node].angular, alpha));
    mu[node].linear = add(mu[node].linear, mul(pi[node].linear, alpha));
    rho[node].angular = sub(rho[node].angular, mul(q[node].angular, alpha));
    rho[node].linear = sub(rho[node].linear, mul(q[node].linear, alpha));
}

__global__ void nodeSpaceUpdateSolution(
    const std::uint32_t* iterationPtr,
    std::uint32_t maxIterations,
    AngLin* mu,
    AngLin* rho,
    const AngLin* pi,
    const AngLin* q,
    const float* zSq,
    const float* qSq,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* islandActive,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts)
{ nodeSpaceUpdateSolutionBody(iterationPtr, maxIterations, mu, rho, pi, q, zSq, qSq, nodeIsland, islandActive, activeNodes, activeCounts, blockIdx.x); }

/// lambda += W mu, i.e. one C^T D pass, run once at the end of the solve.
__global__ void nodeSpaceApplySolution(
    AngLin* impulses,
    const AngLin* mu,
    const Inertia* inertia,
    const std::uint32_t* node0,
    const std::uint32_t* node1,
    const Vec4* offset0,
    const Vec4* offset1,
    const float* health,
    const float* colScale,
    const std::uint32_t* bondIsland,
    const std::uint32_t* islandSkip,
    const std::uint32_t* activeBonds,
    const std::uint32_t* activeCounts)
{
    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot >= activeCounts[0])
    {
        return;
    }
    const std::uint32_t bond = activeBonds[slot];
    if (bondSettled(islandSkip, bondIsland[bond]))
    {
        return;
    }
    if (health[bond] <= 0.0f)
    {
        impulses[bond] = AngLin{};
        return;
    }
    const std::uint32_t first = node0[bond];
    const std::uint32_t second = node1[bond];
    AngLin x0 = mu[first];
    AngLin x1 = mu[second];
    x0.angular = mul(x0.angular, inertia[first].angular);
    x0.linear = mul(x0.linear, inertia[first].linear);
    x1.angular = mul(x1.angular, inertia[second].angular);
    x1.linear = mul(x1.linear, inertia[second].linear);

    // J' = J'0 + S C^T D mu: one column-scale multiply per bond.
    const float s_j = colScale[bond];
    const Vec4 tAng = mul(sub(x0.angular, x1.angular), s_j);
    const Vec4 tLin = mul(add(
        sub(x0.linear, x1.linear),
        sub(cross(offset0[bond], x0.angular), cross(offset1[bond], x1.angular))), s_j);
    impulses[bond].angular = add(impulses[bond].angular, tAng);
    impulses[bond].linear = add(impulses[bond].linear, tLin);
}

/// Zero the node-space accumulators that must start each solve at zero.
__global__ void nodeSpaceReset(
    AngLin* mu,
    AngLin* pi,
    AngLin* q,
    AngLin* g,
    std::uint32_t nodeCount)
{
    // Over ALL nodes, not the active list. The matvec reads its neighbour's
    // value at every half-edge including static ones, where it is multiplied by
    // a zero inertia -- and 0 * NaN is NaN, so an uninitialised slot that the
    // active list never covers still poisons the result. Measured: it turned a
    // 2.5e-02 residual into 1.5e+00.
    const std::uint32_t node = blockIdx.x * blockDim.x + threadIdx.x;
    if (node >= nodeCount)
    {
        return;
    }
    mu[node] = AngLin{};
    pi[node] = AngLin{};
    q[node] = AngLin{};
    if (g) g[node] = AngLin{};
}

