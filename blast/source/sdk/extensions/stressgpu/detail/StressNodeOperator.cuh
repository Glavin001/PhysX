// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
// Global float atomics flush subnormal operands; preserve that behavior
// before combining nonnegative node contributions in a block-local tree.
__device__ __forceinline__ float stressSquaredContribution(float value)
{ return (__float_as_uint(value)&0x7f800000u)==0u ? 0.0f : value; }

/// ---------------------------------------------------------------------------
/// NODE-SPACE CGLS
///
/// The bond-space form solves  C^T D C lambda = -C^T D v  by CGNR on the factor
/// B = D C, carrying three BOND-length vectors (gradient, direction, impulses)
/// through every iteration. Substituting
///
///     lambda = lambda0 + W mu,      W := B^T = C^T D,   L := W^T W = D C C^T D
///
/// eliminates the bond-space vectors z, p and s ALGEBRAICALLY -- this is an
/// identity, not an approximation, and every scalar (z_sq, beta, alpha) is
/// unchanged. `r` in cgnr.h is already a node vector, so rho == r literally.
///
///     w  = L rho      and, from the same pass, z_sq = ||W rho||^2 = sum ||t_j||^2
///     beta = z_sq / z_sq_prev
///     pi = rho + beta pi ;  q = w + beta q          (q == L pi, by linearity)
///     alpha = z_sq / ||q||^2
///     mu += alpha pi ;      rho -= alpha q
///     ... and once, at the end, lambda = lambda0 + W mu
///
/// Why bother: the hot loop drops from ~112 B/bond to ~48 B/bond, because
/// `gradient` and `direction` cease to exist. At 671k bonds the old working set
/// no longer fits the 4090's 72 MB L2 and per-bond cost rises 72%; this brings
/// it back inside.
///
/// THREE TRAPS, all of which produce plausible-looking wrong answers:
///
/// 1. THIS IS NOT PLAIN CG ON L. Plain CG uses numerator rho^T rho; the correct
///    one is rho^T L rho = ||W rho||^2. null(L) is the rigid-body mode of any
///    island not anchored to a static node -- the stress suite measures 29,041
///    of those in one scene. With rho^T rho both alpha and beta inflate and the
///    residual test stalls forever on every free-floating fragment.
/// 2. z_sq MUST COUNT EACH BOND EXACTLY ONCE. Canonical owner: the node-0 side,
///    or the dynamic endpoint when node 0 is static. Double counting scales
///    alpha, beta and delta consistently, so it still converges -- just slower.
///    An endpoint test will not catch it.
/// 3. q = w + beta q IS A RECURRENCE where s = Bp was a fresh application. That
///    is the pipelined-CG trade; refresh q = L pi explicitly every kQRefresh
///    iterations.
/// ---------------------------------------------------------------------------

/// w = L rho, fused: the bond-space intermediate t_j is recomputed at each
/// endpoint rather than stored. The workload is ~2 flops/byte on a machine that
/// does 80, so recomputing is free and it removes a whole bond-length vector
/// from the loop.
__device__ __forceinline__ void nodeSpaceMatvecBody(
    AngLin* w,
    const AngLin* rho,
    const Inertia* inertia,
    const std::uint32_t* nodeBondBegin,
    const std::uint32_t* nodeBondRef,
    const std::uint32_t* node0,
    const std::uint32_t* node1,
    const Vec4* offset0,
    const Vec4* offset1,
    const float* health,
    const float* colScale,
    const std::uint32_t* bondIsland,
    const std::uint32_t* islandSkip,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* islandActive,
    bool skipConverged,
    float* zSqSlots,
    std::uint32_t slotCount,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts,
    // Refresh mode: when non-zero, this launch only does work on iterations
    // divisible by `refreshEvery`, and skips the z_sq accumulation. That is the
    // periodic explicit recomputation of q = L pi which keeps the recurrence
    // q = w + beta q from drifting (the pipelined-CG trade).
    const std::uint32_t* iterationPtr,
    std::uint32_t refreshEvery, unsigned logicalBlock,
    float* nodeContribution = nullptr)
{
    if (refreshEvery != 0u && (*iterationPtr % refreshEvery) != 0u)
    {
        return;
    }
    const std::uint32_t slot = logicalBlock * blockDim.x + threadIdx.x;
    if (slot >= activeCounts[1])
    {
        return;
    }
    const std::uint32_t node = activeNodes[slot];
    // An island that reached tolerance EARLIER IN THIS SOLVE is done: its pi,
    // q, mu and rho are frozen by the islandActive guard in the update kernels,
    // so the w and z_sq computed for it here would be written and never read.
    // The cross-tick islandSkip mask does not cover this -- that one only
    // retires islands that were already settled when the solve began. Islands
    // converge at very different rates once a scene is fragmented, so at
    // realistic island counts this is a large fraction of the matvec.
    // Read the island once and reuse it for the z_sq atomic below: the guard
    // then costs a single extra scattered load, not two.
    const std::uint32_t myIsland = nodeIsland[node];
    if (skipConverged && myIsland != kNoIsland && islandActive != nullptr
        && !islandActive[myIsland])
    {
        return;
    }
    const Inertia inv = inertia[node];
    if (inv.angular == 0.0f && inv.linear == 0.0f)
    {
        // Static: annihilated on both sides of L, so its row is identically
        // zero. Also the high-degree terrain node, which would otherwise walk
        // thousands of bonds to produce zero.
        if(w){w[node].angular = Vec4{0.0f, 0.0f, 0.0f, 0.0f};
            w[node].linear = Vec4{0.0f, 0.0f, 0.0f, 0.0f};}
        return;
    }

    const AngLin selfRho = rho[node];
    const Vec4 selfAng = mul(selfRho.angular, inv.angular);
    const Vec4 selfLin = mul(selfRho.linear, inv.linear);

    Vec4 accAng{0.0f, 0.0f, 0.0f, 0.0f};
    Vec4 accLin{0.0f, 0.0f, 0.0f, 0.0f};
    float zSq = 0.0f;

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
        if (health[bond] <= 0.0f || bondSettled(islandSkip, bondIsland[bond]))
        {
            continue;
        }
        const std::uint32_t other = isSecond ? node0[bond] : node1[bond];
        const Inertia otherInv = inertia[other];
        // Norm-only passes need the canonical endpoint's contribution once.
        // Reject the duplicate before loading motion/offsets or forming the
        // bond response. Matrix-vector passes still require both endpoints.
        const bool owns = !isSecond || (otherInv.angular == 0.0f && otherInv.linear == 0.0f);
        if (!w && !owns) continue;
        const AngLin otherRho = rho[other];
        const Vec4 otherAng = mul(otherRho.angular, otherInv.angular);
        const Vec4 otherLin = mul(otherRho.linear, otherInv.linear);

        // t_j = (C^T D rho)_j, with node 0 first regardless of which side we
        // are on -- the sign convention is a property of the bond, not of the
        // walker.
        const Vec4 a0 = isSecond ? otherAng : selfAng;
        const Vec4 l0 = isSecond ? otherLin : selfLin;
        const Vec4 a1 = isSecond ? selfAng : otherAng;
        const Vec4 l1 = isSecond ? selfLin : otherLin;
        const Vec4 o0 = offset0[bond];
        const Vec4 o1 = offset1[bond];

        // Column scaling: the operator is L_S = D C S^2 C^T D, where S is the
        // per-bond compliance weight (Young's modulus) the CPU processor
        // solves with. The bond-space intermediate is y_j = s_j t_j, the
        // numerator is ||y||^2, and the node accumulation applies S once more
        // on the way back -- so the whole bond term carries s_j^2.
        const float s_j = colScale[bond];
        const float s2 = s_j * s_j;
        const Vec4 tAng = mul(sub(a0, a1), s2);
        const Vec4 tLin =
            mul(add(sub(l0, l1), sub(cross(o0, a0), cross(o1, a1))), s2);

        // Own the bond from the node-0 side, or from the dynamic side when
        // node 0 is static (that side never runs). Exactly once, either way.
        if (owns)
        {
            // ||s_j t_j||^2 == |s_j^2 t_j|^2 / s_j^2
            zSq += (tAng.x * tAng.x + tAng.y * tAng.y + tAng.z * tAng.z
                 + tLin.x * tLin.x + tLin.y * tLin.y + tLin.z * tLin.z) / s2;
        }

        // (D C S^2 t)_node, the same accumulation gatherRightMultiply performs.
        if (w && !isSecond)
        {
            accAng = add(accAng, sub(tAng, cross(o0, tLin)));
            accLin = add(accLin, tLin);
        }
        else if(w)
        {
            accAng = add(accAng, sub(cross(o1, tLin), tAng));
            accLin = sub(accLin, tLin);
        }
    }

    // Native projected CG needs the original convergence norm, but not L*r.
    // A null destination removes the unused accumulation and output writes.
    if(w){w[node].angular = mul(accAng, inv.angular);
        w[node].linear = mul(accLin, inv.linear);}

    if ((zSqSlots != nullptr || nodeContribution != nullptr) && myIsland != kNoIsland)
    {
        // Zero slots selects an exclusive per-node output. Its reduction is
        // a separate fixed-order pass; no floating atomic participates.
        if (nodeContribution) *nodeContribution = stressSquaredContribution(zSq);
        else if (slotCount == 0u) zSqSlots[node] = zSq;
        else if (zSq > 0.0f)
            atomicAdd(&zSqSlots[myIsland * slotCount + (slot & (slotCount - 1u))], zSq);
    }
}

__global__ void nodeSpaceMatvec(
    AngLin* w,
    const AngLin* rho,
    const Inertia* inertia,
    const std::uint32_t* nodeBondBegin,
    const std::uint32_t* nodeBondRef,
    const std::uint32_t* node0,
    const std::uint32_t* node1,
    const Vec4* offset0,
    const Vec4* offset1,
    const float* health,
    const float* colScale,
    const std::uint32_t* bondIsland,
    const std::uint32_t* islandSkip,
    const std::uint32_t* nodeIsland,
    const std::uint32_t* islandActive,
    bool skipConverged,
    float* zSqSlots,
    std::uint32_t slotCount,
    const std::uint32_t* activeNodes,
    const std::uint32_t* activeCounts,
    // Refresh mode: when non-zero, this launch only does work on iterations
    // divisible by `refreshEvery`, and skips the z_sq accumulation. That is the
    // periodic explicit recomputation of q = L pi which keeps the recurrence
    // q = w + beta q from drifting (the pipelined-CG trade).
    const std::uint32_t* iterationPtr,
    std::uint32_t refreshEvery)
{ nodeSpaceMatvecBody(w, rho, inertia, nodeBondBegin, nodeBondRef, node0, node1, offset0, offset1, health, colScale, bondIsland, islandSkip, nodeIsland, islandActive, skipConverged, zSqSlots, slotCount, activeNodes, activeCounts, iterationPtr, refreshEvery, blockIdx.x); }

