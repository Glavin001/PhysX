// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
__device__ void atomicAddVec(Vec4& target, const Vec4& value)
{
    atomicAdd(&target.x, value.x);
    atomicAdd(&target.y, value.y);
    atomicAdd(&target.z, value.z);
}

__global__ void initializeSolve(
    const ExtStressGpuImpulse* input,
    AngLin* rhs,
    AngLin* residual,
    AngLin* impulses,
    const Inertia* inertia,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* bondIsland,
    const std::uint32_t* islandSkip,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeBonds,
    const std::uint32_t* activeCounts,
    float reciprocalLengthScale,
    float reciprocalLinearImpulseScale,
    float reciprocalAngularImpulseScale,
    bool warmStart)
{
    // Threads walk the compacted active lists, not the raw arrays: a settled
    // city launches what moved, not what exists. The settled guards below are
    // kept even though the lists pre-filter -- they are what make this kernel
    // bit-identical to the full launch, list or no list.
    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot < activeCounts[1])
    {
        const std::uint32_t index = activeNodes[slot];
        if (!nodeSettled(islandSkip, nodeIsland[index]))
        {
        const Inertia value = inertia[index];
        const ExtStressGpuImpulse velocity = input[index];
        AngLin b{};
        // Reciprocate ONCE. This was six float divisions per node, and the
        // compiler cannot hoist them because the denominators are data --
        // even though under equalizeMasses they are only ever 0 or 1.
        const float invAngular = value.angular > 0.0f ? 1.0f / value.angular : 1.0f;
        const float invLinear =
            value.linear > 0.0f ? reciprocalLengthScale / value.linear : reciprocalLengthScale;
        b.angular = makeVec(
            -velocity.angular.x * invAngular,
            -velocity.angular.y * invAngular,
            -velocity.angular.z * invAngular);
        b.linear = makeVec(
            -velocity.linear.x * invLinear,
            -velocity.linear.y * invLinear,
            -velocity.linear.z * invLinear);
        rhs[index] = b;
        residual[index] = b;
        }
    }
    // A settled island's impulses are the output the caller is still holding.
    // They must not even be rescaled: impulse*(1/s) followed by impulse*s is
    // not the identity in float, so re-entering the solve at all would walk a
    // frozen island's stress by an ulp per tick for as long as it sits there.
    if (slot < activeCounts[0])
    {
        const std::uint32_t index = activeBonds[slot];
        if (!bondSettled(islandSkip, bondIsland[index]))
        {
        // NOTHING to do on a warm start. Impulses are stored in SOLVER-SCALED
        // units on the device and never round-tripped: this used to multiply
        // every bond by 1/scale here so unscaleImpulses could multiply it back
        // at the end of the solve -- a full read-modify-write over every bond,
        // twice per solve, purely to undo itself. It was 70% of the fixed
        // overhead, which is itself a third of the solve.
        //
        // Keeping them scaled also removes a real numerical wart: x*(1/s)
        // followed by x*s is not the identity in float, so the old round-trip
        // walked a warm-started island's stress by an ulp per tick forever.
        (void)reciprocalAngularImpulseScale;
        (void)reciprocalLinearImpulseScale;
        if (!warmStart)
        {
            impulses[index] = AngLin{};
        }
        }
    }
}

__global__ void couplingRightMultiply(
    AngLin* nodes,
    const AngLin* bonds,
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
    if (health[bond] <= 0.0f)
    {
        return;
    }
    // A settled island contributes nothing to any node another island reads:
    // dynamic nodes belong to exactly one island, and the static nodes it does
    // share are zeroed by their inverse inertia. Dropping the atomics here is
    // most of the saving, because they are the expensive part of the solve.
    if (bondSettled(islandSkip, bondIsland[bond]))
    {
        return;
    }

    // Column scale: the operator is C*S, one multiply per bond.
    AngLin impulse = bonds[bond];
    {
        const float s_j = colScale[bond];
        impulse.angular = mul(impulse.angular, s_j);
        impulse.linear = mul(impulse.linear, s_j);
    }
    const Vec4 node0Angular = sub(impulse.angular, cross(offset0[bond], impulse.linear));
    const Vec4 node1Angular = sub(cross(offset1[bond], impulse.linear), impulse.angular);
    atomicAddVec(nodes[node0[bond]].angular, node0Angular);
    atomicAddVec(nodes[node0[bond]].linear, impulse.linear);
    atomicAddVec(nodes[node1[bond]].angular, node1Angular);
    atomicAddVec(nodes[node1[bond]].linear, mul(impulse.linear, -1.0f));
}

/// The transpose of couplingRightMultiply: one thread per ACTIVE NODE, summing
/// its own incident bonds instead of every bond racing to add into its nodes.
///
/// The CSR is node -> refs, each ref packing (bondIndex, endpoint) so the
/// thread knows which of the two sign conventions to apply. The two branches
/// below are exactly couplingRightMultiply's two halves, unchanged; what is
/// gone is the atomicAdd and the memset that had to precede it, because this
/// kernel writes every active node's slot unconditionally.
///
/// The scale by inverse inertia is folded in here, which also retires the
/// separate scaleNodes launch on this path.
__global__ void gatherRightMultiply(
    AngLin* nodes,
    const AngLin* bonds,
    const std::uint32_t* nodeBondBegin,
    const std::uint32_t* nodeBondRef,
    const Vec4* offset0,
    const Vec4* offset1,
    const float* health,
    const float* colScale,
    const std::uint32_t* bondIsland,
    const std::uint32_t* islandSkip,
    const Inertia* inertia,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts)
{
    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot >= activeCounts[1])
    {
        return;
    }
    const std::uint32_t node = activeNodes[slot];

    Vec4 angular{0.0f, 0.0f, 0.0f, 0.0f};
    Vec4 linear{0.0f, 0.0f, 0.0f, 0.0f};

    // A static node's sum is multiplied by a zero inverse inertia below, so the
    // whole accumulation is discarded -- and static nodes are exactly the
    // high-degree ones. The city's terrain is a single node shared by every
    // building, so ONE thread was walking thousands of scattered bonds while
    // its warpmates sat idle, to produce a value that is defined to be zero.
    // Measured: dropping this loop took the kernel from 200 us to 4 us.
    const Inertia inv = inertia[node];
    if (inv.angular == 0.0f && inv.linear == 0.0f)
    {
        nodes[node].angular = angular;
        nodes[node].linear = linear;
        return;
    }

    const std::uint32_t begin = nodeBondBegin[node];
    const std::uint32_t end = nodeBondBegin[node + 1];
    for (std::uint32_t i = begin; i < end; ++i)
    {
        const std::uint32_t ref = nodeBondRef[i];
        if (ref == kDeadBondRef)
        {
            continue;   // tombstone from an in-place removal
        }
        const std::uint32_t bond = ref & 0x7FFFFFFFu;
        const bool isSecond = (ref & 0x80000000u) != 0u;
        if (health[bond] <= 0.0f)
        {
            continue;
        }
        if (bondSettled(islandSkip, bondIsland[bond]))
        {
            continue;
        }
        AngLin impulse = bonds[bond];
        {
            const float s_j = colScale[bond];
            impulse.angular = mul(impulse.angular, s_j);
            impulse.linear = mul(impulse.linear, s_j);
        }
        if (!isSecond)
        {
            angular = add(angular, sub(impulse.angular, cross(offset0[bond], impulse.linear)));
            linear = add(linear, impulse.linear);
        }
        else
        {
            angular = add(angular, sub(cross(offset1[bond], impulse.linear), impulse.angular));
            linear = add(linear, mul(impulse.linear, -1.0f));
        }
    }

    // Exclusive write, and the inverse-inertia scale folded in: a static node
    // has zero inertia, so its slot lands at zero exactly as the memset +
    // scaleNodes pair produced before.
    nodes[node].angular = mul(angular, inertia[node].angular);
    nodes[node].linear = mul(linear, inertia[node].linear);
}

__global__ void scaleNodes(
    AngLin* nodes,
    const Inertia* inertia,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts)
{
    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot < activeCounts[1])
    {
        const std::uint32_t node = activeNodes[slot];
        nodes[node].angular = mul(nodes[node].angular, inertia[node].angular);
        nodes[node].linear = mul(nodes[node].linear, inertia[node].linear);
    }
}

__global__ void subtractResidual(
    AngLin* residual,
    const AngLin* value,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts)
{
    const std::uint32_t slot = blockIdx.x * blockDim.x + threadIdx.x;
    if (slot < activeCounts[1])
    {
        const std::uint32_t index = activeNodes[slot];
        residual[index].angular =
            sub(residual[index].angular, value[index].angular);
        residual[index].linear =
            sub(residual[index].linear, value[index].linear);
    }
}

__global__ void couplingLeftMultiply(
    AngLin* bonds,
    const AngLin* nodes,
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
        return;     // gradient for a settled island is never read
    }
    if (health[bond] <= 0.0f)
    {
        bonds[bond] = {};
        return;
    }

    const std::uint32_t first = node0[bond];
    const std::uint32_t second = node1[bond];
    AngLin x0 = nodes[first];
    AngLin x1 = nodes[second];
    x0.angular = mul(x0.angular, inertia[first].angular);
    x0.linear = mul(x0.linear, inertia[first].linear);
    x1.angular = mul(x1.angular, inertia[second].angular);
    x1.linear = mul(x1.linear, inertia[second].linear);

    AngLin result;
    result.angular = sub(x0.angular, x1.angular);
    result.linear = add(
        sub(x0.linear, x1.linear),
        sub(cross(offset0[bond], x0.angular), cross(offset1[bond], x1.angular)));
    // Transpose of the column scale: y = S * C^T * (...).
    {
        const float s_j = colScale[bond];
        result.angular = mul(result.angular, s_j);
        result.linear = mul(result.linear, s_j);
    }
    bonds[bond] = result;
}

__global__ void squaredMagnitude(
    const AngLin* values,
    float* output,
    std::uint32_t count)
{
    const std::uint32_t index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < count)
    {
        const AngLin value = values[index];
        output[index] =
            value.angular.x * value.angular.x
            + value.angular.y * value.angular.y
            + value.angular.z * value.angular.z
            + value.linear.x * value.linear.x
            + value.linear.y * value.linear.y
            + value.linear.z * value.linear.z;
    }
}

__global__ void setTolerance(float* deltaSquared, const float* rhsSquared, float tolerance)
{
    if (threadIdx.x == 0 && blockIdx.x == 0)
    {
        *deltaSquared = tolerance * tolerance * *rhsSquared;
    }
}

/// Seed each island's squared residual target and mark it active.
__global__ void setTolerancePerIsland(
    float* deltaSquared,
    std::uint32_t* islandActive,
    std::uint32_t* islandConverged,
    const std::uint32_t* islandSkip,
    const float* rhsSquared,
    float tolerance,
    std::uint32_t islandCount)
{
    const std::uint32_t id = blockIdx.x * blockDim.x + threadIdx.x;
    if (id >= islandCount)
    {
        return;
    }
    if (islandSkip != nullptr && islandSkip[id] != 0u)
    {
        // Inactive for every kernel below, and its convergence flag is left
        // alone: that flag IS the baseline saying this island may be skipped
        // again next frame, and clearing it here would make a settled island
        // alternate solve/skip forever.
        islandActive[id] = 0;
        return;
    }
    deltaSquared[id] = rhsSquared[id] * tolerance * tolerance;
    islandActive[id] = 1;
    islandConverged[id] = 0;
}

__global__ void initializeStatus(
    SolveStatus* status, std::uint32_t* iteration, std::uint32_t maxIterations)
{
    if (threadIdx.x == 0 && blockIdx.x == 0)
    {
        status->active = 1;
        status->iterations = maxIterations;
        status->converged = 0;
        // The loop counter lives on the device so the CG body can be ONE graph
        // node executed repeatedly, instead of maxIterations copies of it.
        *iteration = 0u;
    }
}



