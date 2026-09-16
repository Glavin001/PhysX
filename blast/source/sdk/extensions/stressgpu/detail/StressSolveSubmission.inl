// Private member definitions; included once inside ExtStressGpuSolverImpl.
// BEGIN UNCHANGED SOURCE
    void launchSolve(const ExtStressGpuSolveParams& params)
    {
        const bool warmStart = params.warmStart && m_hasWarmStart;

        const float reciprocalLengthScale = 1.0f / m_lengthScale;
        const float reciprocalMassScale = 1.0f / m_massScale;
        const float reciprocalLinearImpulseScale =
            reciprocalLengthScale * reciprocalMassScale;
        const float reciprocalAngularImpulseScale =
            reciprocalLengthScale * reciprocalLinearImpulseScale;
        const std::uint32_t maxCap = std::max(m_graphNodeCap, m_graphBondCap);
        // Null when the feature is off, so every skip test below compiles down
        // to one comparison against a register and the pre-skip behaviour is
        // restored exactly rather than approximately. It is a capture-time
        // argument, so flipping the flag recaptures the graph (graphMatches);
        // the mask it points at changes every frame and does not.
        const std::uint32_t* islandSkip =
            (params.skipSettledIslands && warmStart) ? m_islandSkip : nullptr;
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if(m_deviceTopology){
            islandSkip=m_islandSkip;
            beginNativeSettledReuse<<<std::min(m_nodeCount,256u),128,0,m_stream>>>(
                m_deviceTopology->cycleView().settled,m_deviceTopology->components(),m_deviceTopology->status(),
                m_input,m_islandConverged,m_islandSkip,warmStart,params.tolerance,params.maxIterations);
            if(nativeElasticMargin()>0.f)
                beginNativeElasticReuse<<<std::min(m_nodeCount,256u),kBlockSize,0,m_stream>>>(
                    m_deviceTopology->cycleView().settled,m_deviceTopology->components(),m_deviceTopology->status(),m_deviceTopology->batchView(),
                    m_input,m_nodeBondBegin,m_nodeBondRef,m_health,m_islandConverged,m_islandSkip,warmStart,nativeElasticMargin(),nativeElasticChangeFraction(),
                    m_deviceTopology->cycleView().settled.counters,nativeExactReuse());
            // Island-scoped correction: parked components keep their previous
            // output; marked after every other writer of the skip mask. Always
            // captured: the flags buffer is solver-owned and refreshed per solve
            // (all zero outside a corrected pass).
            markParkedNativeComponents<<<(m_nodeCount+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(m_islandSkip,m_parkedFlags,m_deviceTopology->components(),
                m_deviceTopology->cycleView().settled,m_islandConverged);
        }
#endif

        m_kernelProfile.begin("initializeSolve", m_stream);
        initializeSolve<<<
            (maxCap + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            m_stream>>>(
            m_input,
            m_rhs,
            m_residual,
            m_impulses,
            m_inertia,
            m_nodeIsland,
            m_bondIsland,
            islandSkip,
            m_activeNodes,
            m_activeBonds,
            m_activeCounts,
            reciprocalLengthScale,
            reciprocalLinearImpulseScale,
            reciprocalAngularImpulseScale,
            warmStart);
        m_kernelProfile.end(m_stream);
        // Deliberately NOT guarded on warmStart. These two are a no-op on a
        // cold start, exactly: initializeSolve has just written impulses = {},
        // gatherRightMultiply WRITES each active node's slot rather than
        // accumulating into it (see the comment in rightMultiply), so
        // m_projectedDirection comes out zero, and subtractResidual then
        // subtracts zero from the residual.
        //
        // Running them unconditionally is what makes warmStart a pure kernel
        // ARGUMENT rather than a change to the graph's node set. That is worth
        // two no-op kernels on cold-start ticks: with the branch in place, a
        // warm-start flip forced a full graph re-instantiation, and
        // BLAST_GPU_WHOLE_RESET_ON_TOPOLOGY flips it on every fracture tick --
        // measured at 33.6% of solves even after cudaGraphExecUpdate had
        // removed every other recapture driver.
        //
        // That flag cannot simply be turned off to avoid this: it is load
        // bearing for the scene. Without it the suite fails T2 "one shot
        // pulverizes" (3726 bonds vs a <=2028 band), T2 bodies (1087 vs <=707)
        // and T4 awake-declined (0.42 vs <=0.10). So the graph has to tolerate
        // the flip instead.
        // Native solving initializes directly with its accurate verification
        // operator after reset. Avoid the adapter's FP32 multiply/subtract pair.
        bool nativeResidual = false;
#ifdef PHYSX_RESIDENT_DESTRUCTION
        nativeResidual = m_deviceTopology != nullptr;
#endif
        if (!nativeResidual && (warmStart || stableGraphEnabled()))
        {
            rightMultiply(m_stream, m_impulses, m_projectedDirection, islandSkip);
            m_kernelProfile.begin("subtractResidual", m_stream);
            subtractResidual<<<
                (m_graphNodeCap + kBlockSize - 1) / kBlockSize,
                kBlockSize,
                0,
                m_stream>>>(
                m_residual, m_projectedDirection, m_activeNodes, m_activeCounts);
            m_kernelProfile.end(m_stream);
        }

        // Tolerance is relative to each island's own load, not the whole
        // graph's: a small island next to a heavily loaded one would otherwise
        // inherit a threshold it can never meaningfully meet.
        reduceByIsland(
            m_stream,
            m_rhs, m_nodeIsland, islandSkip, m_activeNodes, 1u, m_graphNodeCap,
            m_gradientSquared);
        m_kernelProfile.begin("setTolerancePerIsland", m_stream);
        setTolerancePerIsland<<<
            (m_islandCount + kBlockSize - 1) / kBlockSize,
            kBlockSize,
            0,
            m_stream>>>(
            m_deltaSquared,
            m_islandActive,
            m_islandConverged,
            islandSkip,
            m_gradientSquared,
            params.tolerance,
            m_islandCount);
        m_kernelProfile.end(m_stream);
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if(m_deviceTopology && nativeContinuingTolerance()>0.f)
            relaxNativeContinuingTolerance<<<std::min(m_nodeCount,256u),kBlockSize,0,m_stream>>>(
                m_deviceTopology->cycleView().settled,m_deviceTopology->components(),m_deviceTopology->status(),
                m_input,m_deltaSquared,m_gradientSquared,islandSkip,nativeContinuingTolerance(),nativeContinuingChangeFraction(),warmStart);
#endif
        m_kernelProfile.begin("initializeStatus", m_stream);
        initializeStatus<<<1, 1, 0, m_stream>>>(
            m_status, m_iteration, params.maxIterations,
            m_deviceTopology ? m_deviceTopology->components().workCursor : nullptr);
        m_kernelProfile.end(m_stream);

        if (nodeSpaceEnabled() && jacobiEnabled() && !m_jacobiBuilt)
        {
            m_kernelProfile.begin("nodeSpaceBuildJacobi", m_stream);
            nodeSpaceBuildJacobi<<<
                (m_nodeCount + kBlockSize - 1) / kBlockSize, kBlockSize, 0, m_stream>>>(
                m_nsJacobi, m_inertia, m_nodeBondBegin, m_nodeBondRef,
                m_node0, m_node1, m_offset0, m_offset1, m_health, m_colScales,
                m_nodeCount, m_bondCount);
            m_kernelProfile.end(m_stream);
            m_jacobiBuilt = true;
        }
        if (nodeSpaceEnabled() && jacobiEnabled())
        {
            // gamma_prev must be zero at iteration 0 so beta is zero there.
            // Left uninitialised it is whatever the allocator handed back, and
            // if those bits happen to be NaN then beta is NaN, pi = g + NaN*0
            // is NaN, and mu accumulates the poison for the rest of the solve.
            // The unpreconditioned path never showed this because it reuses
            // m_previousGradientSquared, which earlier solves have already
            // filled with real values.
            checkCuda(
                cudaMemsetAsync(m_nsGammaPrev, 0,
                                sizeof(float) * m_islandCapacity, m_stream),
                "clear node-space gamma prev");
            checkCuda(
                cudaMemsetAsync(m_nsGamma, 0,
                                sizeof(float) * m_islandCapacity, m_stream),
                "clear node-space gamma");
        }
        if (nodeSpaceEnabled())
        {
            // mu accumulates the whole correction, so it must start at zero
            // every solve; pi and q are recurrences and must not inherit the
            // previous solve's Krylov state.
            m_kernelProfile.begin("nodeSpaceReset", m_stream);
#ifdef PHYSX_RESIDENT_DESTRUCTION
            if(m_deviceTopology)resetNativeStressSolution<<<(m_nodeCount+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(
                m_deviceTopology->cycleView(),m_nsPi,m_nsQ,m_nodeCount,warmStart);
            else
#endif
            nodeSpaceReset<<<
                (m_nodeCount + kBlockSize - 1) / kBlockSize,
                kBlockSize, 0, m_stream>>>(
                m_nsMu, m_nsPi, m_nsQ, m_nsG, m_nodeCount);
            m_kernelProfile.end(m_stream);
        }

        launchConditionalLoop(params, islandSkip, maxCap);

        if (nodeSpaceEnabled())
        {
            // lambda = lambda0 + W mu. One C^T D pass over bonds, once per
            // solve, instead of a bond-length update every iteration.
            m_kernelProfile.begin("nodeSpaceApplySolution", m_stream);
#ifdef PHYSX_RESIDENT_DESTRUCTION
            if(m_deviceTopology)applyNativeStressSolution<<<(m_graphBondCap+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(
                m_impulses,m_deviceTopology->cycleView().solution,m_inertia,m_node0,m_node1,m_offset0,m_offset1,m_health,m_colScales,m_bondIsland,islandSkip,m_activeBonds,m_activeCounts);
            else
#endif
            nodeSpaceApplySolution<<<
                (m_graphBondCap + kBlockSize - 1) / kBlockSize,
                kBlockSize, 0, m_stream>>>(
                m_impulses, m_nsMu, m_inertia, m_node0, m_node1,
                m_offset0, m_offset1, m_health, m_colScales, m_bondIsland, islandSkip,
                m_activeBonds, m_activeCounts);
            m_kernelProfile.end(m_stream);
        }


#ifdef PHYSX_RESIDENT_DESTRUCTION
        if(m_deviceTopology)commitNativeSettledReuse<<<std::min(m_nodeCount,256u),128,0,m_stream>>>(
            m_deviceTopology->cycleView().settled,m_deviceTopology->components(),m_deviceTopology->status(),
            m_input,m_islandConverged,m_islandSkip,params.tolerance,params.maxIterations);
#endif
        // No unscale pass. Impulses stay in solver-scaled units on the device;
        // the three places that read them for the OUTSIDE world apply the scale
        // themselves (applyStressDamage, bondStressWalk, and the host repack in
        // finishImpulseReadback). See initializeSolve.
        //
        // Column scaling (the CPU processor's compliance weights, colScale) is
        // part of the stored variable too: the device holds J' = J / colScale,
        // the operator is C*S on the way out and S*C^T on the way back, and the
        // same three consumers multiply by colScale when converting to physical.
        checkCuda(
            cudaMemsetAsync(
                m_brokenCount,
                0,
                sizeof(std::uint32_t),
                m_stream),
            "clear broken bond count");
        // Deliberately NOT gated on the skip mask. A settled island's stress
        // is unchanged, not absent: re-solving it would produce the same
        // impulses and charge the same damage, so charging it here is what
        // makes skipping observationally identical. This is also what the CPU
        // path does -- its updateBondStress runs over every bond whether or
        // not the island was skipped.
        if (params.applyDamage)
        {
            m_kernelProfile.begin("applyStressDamage", m_stream);
            applyStressDamage<<<
                (m_bondCount + kBlockSize - 1) / kBlockSize,
                kBlockSize,
                0,
                m_stream>>>(
                m_bendGainMax,
                m_impulses,
                m_colScales,
                m_normals,
                m_areas,
                m_nodeDistances,
                m_bondMaterials,
                m_materials,
                m_materialCount,
                m_health,
                m_brokenBonds,
                m_brokenCount,
                m_bondCount,
                m_lengthScale * m_massScale,
                m_lengthScale * m_lengthScale * m_massScale);
            m_kernelProfile.end(m_stream);
        }
    }

