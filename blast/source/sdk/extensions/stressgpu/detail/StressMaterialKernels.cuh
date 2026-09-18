// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
__global__ void applyStressDamage(
    float bendGainMax,
    const AngLin* impulses,
    const float* colScale,
    const Vec4* normals,
    const float* areas,
    const float* nodeDistances,
    const std::uint32_t* bondMaterials,
    const ExtStressGpuMaterial* materials,
    std::uint32_t materialCount,
    float* health,
    std::uint32_t* brokenBonds,
    std::uint32_t* brokenCount,
    std::uint32_t bondCount,
    float linearImpulseScale,
    float angularImpulseScale)
{
    const std::uint32_t bond = blockIdx.x * blockDim.x + threadIdx.x;
    if (bond >= bondCount || health[bond] <= 0.0f)
    {
        return;
    }

    // Device impulses are solver-scaled; convert to physical units here. Two
    // multiplies on a value this kernel already has in registers.
    AngLin impulse = impulses[bond];
    const float s_j = colScale[bond];
    impulse.angular = mul(impulse.angular, angularImpulseScale * s_j);
    impulse.linear = mul(impulse.linear, linearImpulseScale * s_j);
    const Vec4 normal = normals[bond];
    const float area = areas[bond];
    const float distance = nodeDistances[bond];
    // Same body as the host walk -- see NvBlastExtStressFormula.h.
    float stressNormal, stressShear, stressBend;
    extStressCalcBondStress(
        ExtStressVec3{impulse.linear.x, impulse.linear.y, impulse.linear.z},
        ExtStressVec3{impulse.angular.x, impulse.angular.y, impulse.angular.z},
        ExtStressVec3{normal.x, normal.y, normal.z},
        area, distance, bendGainMax, stressNormal, stressShear, stressBend);

    // Each bond fails against its OWN material. The table is tiny and
    // L2-resident; a plain global read is sufficient.
    const std::uint32_t materialIndex = bondMaterials[bond];
    const ExtStressGpuMaterial material =
        materials[materialIndex < materialCount ? materialIndex : 0];

    const float compression = fmaxf(0.0f, -stressNormal);
    const float tension = fmaxf(0.0f, stressNormal);
    float multiplier = 0.0f;
    if (compression > material.compressionElasticLimit)
    {
        multiplier +=
            (compression - material.compressionElasticLimit)
            / fmaxf(material.compressionFatalLimit - material.compressionElasticLimit, 1.0f);
    }
    if (tension > material.tensionElasticLimit)
    {
        multiplier +=
            (tension - material.tensionElasticLimit)
            / fmaxf(material.tensionFatalLimit - material.tensionElasticLimit, 1.0f);
    }
    if (stressShear > material.shearElasticLimit)
    {
        multiplier +=
            (stressShear - material.shearElasticLimit)
            / fmaxf(material.shearFatalLimit - material.shearElasticLimit, 1.0f);
    }
    if (multiplier <= 0.0f)
    {
        return;
    }

    const float oldHealth = health[bond];
    const float newHealth = fmaxf(0.0f, oldHealth - oldHealth * multiplier);
    health[bond] = newHealth;
    if (oldHealth > 0.0f && newHealth <= 0.0f)
    {
        const std::uint32_t output = atomicAdd(brokenCount, 1u);
        if (output < bondCount)
        {
            brokenBonds[output] = bond;
        }
    }
}


/// The bond-stress walk, one thread per solver bond group.
///
/// One thread per group with the member loop run SERIALLY in slot order, not a
/// warp-level segmented reduction. Two reasons, and the second is the deciding
/// one:
///   - groups hold 1-4 blast bonds in practice, so a warp per group would idle
///     most of its lanes;
///   - a tree reduction sums the area-weighted accumulators in a different
///     order than the host walk, which would make the dual-run audit a
///     tolerance comparison. Accumulating serially in slot order reproduces the
///     host's float arithmetic operation for operation, so the audit can demand
///     equality instead. Given that a 0.0975% divergence once passed every
///     broad gate in this repo, an exact audit is worth more than the lanes.
///
/// Everything here mirrors SupportGraphProcessor::processBondGroup, including
/// the parts that are easy to miss: the unbreakable member takes over the
/// group's values and STOPS the walk (so later members are never even examined
/// for removal), normalizeSafe multiplies by a reciprocal and leaves a
/// degenerate normal untouched rather than zeroing it, and the centroid and
/// node displacement are only divided through when the total area can take
/// damage.
/// The host's ExtStressSolverImpl::fibreStresses, operation for operation:
/// a bending moment loads both extreme fibres at once, so it adds to the
/// axial stress on one face and subtracts on the other. Which face fails is
/// what the overstress test below has to decide, exactly as the host does.
__device__ __forceinline__ void bondStressFibre(
    int fibreBending, float stressNormal, float stressBend,
    float& compression, float& tension)
{
    if (!fibreBending)
    {
        const float combined = stressNormal + copysignf(stressBend, stressNormal);
        compression = combined <= 0.0f ? -combined : 0.0f;
        tension = combined > 0.0f ? combined : 0.0f;
        return;
    }
    const float t = stressNormal + stressBend;
    const float c = stressBend - stressNormal;
    tension = t > 0.0f ? t : 0.0f;
    compression = c > 0.0f ? c : 0.0f;
}

__global__ void bondStressWalk(
    float bendGainMax,
    int fibreBending,
    const std::uint32_t* groupBegin,
    const std::uint32_t* groupSize,
    const std::uint32_t* memberBlastBond,
    const std::uint32_t* bondNode0,
    const std::uint32_t* bondNode1,
    const std::uint32_t* bondMaterial,
    const float* bondNormal,
    const float* bondCentroid,
    const float* bondNodeDisp,
    const float* health,
    const AngLin* impulses,
    const float* colScale,
    float bsLinearScale,
    float bsAngularScale,
    const float* materialElasticLimits,
    std::uint32_t materialCount,
    float unbreakableLimit,
    std::uint32_t groupCount,
    float* groupStressNormal,
    float* groupStressShear,
    float* groupStressBend,
    float* groupNormalOut,
    float* groupCentroidOut,
    std::uint8_t* nodeOverstressed,
    std::uint32_t* groupRemoveCount,
    std::uint32_t* removeFlag,
    std::uint32_t* overstressedCount,
    std::uint32_t* overGroupIds,
    float* overGroupRecords,
    std::uint32_t* overGroupCount,
    std::uint32_t* utilMaxBits,
    std::uint32_t* aboveHalfCount)
{
    const std::uint32_t g = blockIdx.x * blockDim.x + threadIdx.x;
    if (g >= groupCount)
    {
        return;
    }

    const std::uint32_t begin = groupBegin[g];
    const std::uint32_t size = groupSize[g];

    // Cleared up front rather than as we go: the unbreakable break leaves the
    // tail of the group unvisited, and a stale flag there would resurrect a
    // removal the host never emitted.
    for (std::uint32_t k = 0; k < size; ++k)
    {
        removeFlag[begin + k] = 0u;
    }

    float totalArea = 0.0f;
    float nx = 0.0f, ny = 0.0f, nz = 0.0f;
    float cx = 0.0f, cy = 0.0f, cz = 0.0f;
    float dx = 0.0f, dy = 0.0f, dz = 0.0f;
    std::uint32_t removeCount = 0;

    for (std::uint32_t k = 0; k < size; ++k)
    {
        const std::uint32_t slot = begin + k;
        const std::uint32_t bb = memberBlastBond[slot];
        const float remainingArea = health[bb];
        if (remainingArea > 0.0f)
        {
            const std::size_t base = 3u * static_cast<std::size_t>(bb);
            const float mnx = bondNormal[base + 0];
            const float mny = bondNormal[base + 1];
            const float mnz = bondNormal[base + 2];
            const float mcx = bondCentroid[base + 0];
            const float mcy = bondCentroid[base + 1];
            const float mcz = bondCentroid[base + 2];
            const float mdx = bondNodeDisp[base + 0];
            const float mdy = bondNodeDisp[base + 1];
            const float mdz = bondNodeDisp[base + 2];

            // canTakeDamage: health in (0, kUnbreakableLimit).
            if (!(remainingArea < unbreakableLimit))
            {
                totalArea = unbreakableLimit;
                nx = mnx; ny = mny; nz = mnz;
                cx = mcx; cy = mcy; cz = mcz;
                dx = mdx; dy = mdy; dz = mdz;
                break;
            }

            // fmaf, because the host accumulates with `v += u * area` and is
            // compiled with -mfma, so gcc contracts it. Matching that
            // explicitly is what keeps the two walks bit-identical.
            nx = fmaf(mnx, remainingArea, nx);
            ny = fmaf(mny, remainingArea, ny);
            nz = fmaf(mnz, remainingArea, nz);
            cx = fmaf(mcx, remainingArea, cx);
            cy = fmaf(mcy, remainingArea, cy);
            cz = fmaf(mcz, remainingArea, cz);
            dx = fmaf(mdx, remainingArea, dx);
            dy = fmaf(mdy, remainingArea, dy);
            dz = fmaf(mdz, remainingArea, dz);
            totalArea += remainingArea;
        }
        else
        {
            removeFlag[slot] = 1u;
            ++removeCount;
        }
    }

    groupRemoveCount[g] = removeCount;

    if (totalArea == 0.0f)
    {
        return;
    }

    // NvVec3::normalizeSafe -- reciprocal multiply, and a degenerate normal is
    // left alone rather than zeroed.
    {
        const float mag =
            sqrtf(extStressDot(ExtStressVec3{nx, ny, nz}, ExtStressVec3{nx, ny, nz}));
        if (!(mag < NVBLAST_STRESS_NORMALIZATION_EPSILON))
        {
            const float inv = 1.0f / mag;
            nx *= inv;
            ny *= inv;
            nz *= inv;
        }
    }

    if (totalArea > 0.0f && totalArea < unbreakableLimit)
    {
        // NvVec3::operator/= takes the reciprocal ONCE and multiplies. A true
        // per-component division is a different value in the last bit, and
        // that difference showed up as whole batches of bonds flipping across
        // an elastic limit together while the city was still settling.
        const float inv = 1.0f / totalArea;
        cx *= inv; cy *= inv; cz *= inv;
        dx *= inv; dy *= inv; dz *= inv;
    }

    float stressNormal = 0.0f;
    float stressShear = 0.0f;
    float stressBend = 0.0f;
    if (totalArea > 0.0f && totalArea < unbreakableLimit)
    {
        // Solver-scaled -> physical, same as applyStressDamage.
        AngLin impulse = impulses[g];
        const float s_g = colScale[g];
        impulse.angular = mul(impulse.angular, bsAngularScale * s_g);
        impulse.linear = mul(impulse.linear, bsLinearScale * s_g);
        const float nodeDist =
            sqrtf(extStressDot(ExtStressVec3{dx, dy, dz}, ExtStressVec3{dx, dy, dz}));
        extStressCalcBondStress(
            ExtStressVec3{impulse.linear.x, impulse.linear.y, impulse.linear.z},
            ExtStressVec3{impulse.angular.x, impulse.angular.y, impulse.angular.z},
            ExtStressVec3{nx, ny, nz},
            totalArea, nodeDist, bendGainMax, stressNormal, stressShear, stressBend);
    }

    groupStressNormal[g] = stressNormal;
    groupStressShear[g] = stressShear;
    groupStressBend[g] = stressBend;
    groupNormalOut[3u * g + 0u] = nx;
    groupNormalOut[3u * g + 1u] = ny;
    groupNormalOut[3u * g + 2u] = nz;
    groupCentroidOut[3u * g + 0u] = cx;
    groupCentroidOut[3u * g + 1u] = cy;
    groupCentroidOut[3u * g + 2u] = cz;

    // Every member shares the group's stress but fails against its OWN
    // material, so overstress is counted per member. The axial test is on the
    // extreme fibres (normal +/- bend), as on the host; testing the raw normal
    // stress here would let a bond fail on the host walk and not on this one.
    float fibreCompression = 0.0f;
    float fibreTension = 0.0f;
    bondStressFibre(fibreBending, stressNormal, stressBend, fibreCompression, fibreTension);
    std::uint32_t overstressed = 0;
    std::uint32_t aboveHalf = 0;
    float utilMax = 0.0f;
    for (std::uint32_t k = 0; k < size; ++k)
    {
        const std::uint32_t bb = memberBlastBond[begin + k];
        const std::uint32_t node0 = bondNode0[bb];
        if (node0 == 0xFFFFFFFFu || !(health[bb] > 0.0f))
        {
            continue;
        }
        const std::uint32_t rawIndex = bondMaterial[bb];
        const std::uint32_t materialIndex = rawIndex < materialCount ? rawIndex : 0u;
        const float compressionElastic = materialElasticLimits[3u * materialIndex + 0u];
        const float tensionElastic = materialElasticLimits[3u * materialIndex + 1u];
        const float shearElastic = materialElasticLimits[3u * materialIndex + 2u];
        if (fibreCompression > compressionElastic
            || fibreTension > tensionElastic
            || stressShear > shearElastic)
        {
            ++overstressed;
            nodeOverstressed[node0] = 1u;
            nodeOverstressed[bondNode1[bb]] = 1u;
        }
        // Utilisation, as ExtStressSolverImpl::getBondUtilisations defines
        // it: the largest stress-to-elastic-limit ratio, taken in the same
        // order with the same "keep the old value unless strictly less"
        // comparison, so the summary equals the host's per-bond scan.
        float util = 0.0f;
        if (compressionElastic > 0.0f)
        {
            const float r = fibreCompression / compressionElastic;
            util = util < r ? r : util;
        }
        if (tensionElastic > 0.0f)
        {
            const float r = fibreTension / tensionElastic;
            util = util < r ? r : util;
        }
        if (shearElastic > 0.0f)
        {
            const float r = stressShear / shearElastic;
            util = util < r ? r : util;
        }
        utilMax = utilMax < util ? util : utilMax;
        if (util >= 0.5f)
        {
            ++aboveHalf;
        }
    }
    // Non-negative floats order like their bit patterns, so a uint atomicMax
    // is an exact float max; the count is a plain sum.
    if (utilMax > 0.0f)
    {
        atomicMax(utilMaxBits, __float_as_uint(utilMax));
    }
    if (aboveHalf != 0)
    {
        atomicAdd(aboveHalfCount, aboveHalf);
    }
    if (overstressed != 0)
    {
        atomicAdd(overstressedCount, overstressed);
        // Compact this group's outputs for the host: the fracture path reads
        // stresses only for flagged groups, and those are a few hundred out of
        // ~70k, so this is what rides the readback instead of the full arrays.
        const std::uint32_t slot = atomicAdd(overGroupCount, 1u);
        overGroupIds[slot] = g;
        float* rec = overGroupRecords + 9u * static_cast<std::size_t>(slot);
        rec[0] = stressNormal;
        rec[1] = stressShear;
        rec[2] = stressBend;
        rec[3] = nx; rec[4] = ny; rec[5] = nz;
        rec[6] = cx; rec[7] = cy; rec[8] = cz;
    }
}

/// Stable segmented compaction of the removal list.
///
/// Groups ascending (the offsets come from an exclusive scan over group index)
/// and slots ascending inside each group -- which IS the serial walk's emission
/// order. It is emphatically not sorted by blast bond index: measured on a
/// grid-1 shot run, 2 of 200 non-empty removal lists came out non-ascending,
/// so a sort would diverge from the host on ~1% of the ticks that break bonds,
/// and removal order feeds back into topology.
__global__ void bondStressNullKernel() {}

__global__ void bondStressCompactRemovals(
    const std::uint32_t* groupBegin,
    const std::uint32_t* groupSize,
    const std::uint32_t* memberBlastBond,
    const std::uint32_t* removeFlag,
    const std::uint32_t* removeOffset,
    std::uint32_t groupCount,
    std::uint32_t* removeList)
{
    const std::uint32_t g = blockIdx.x * blockDim.x + threadIdx.x;
    if (g >= groupCount)
    {
        return;
    }
    const std::uint32_t begin = groupBegin[g];
    const std::uint32_t size = groupSize[g];
    std::uint32_t out = removeOffset[g];
    for (std::uint32_t k = 0; k < size; ++k)
    {
        if (removeFlag[begin + k] != 0u)
        {
            removeList[out++] = memberBlastBond[begin + k];
        }
    }
}

