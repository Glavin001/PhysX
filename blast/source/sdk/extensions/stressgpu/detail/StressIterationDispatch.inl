// Private member definitions; included once inside ExtStressGpuSolverImpl.
// BEGIN UNCHANGED SOURCE
    /// One CG iteration. Parameterised on the stream so it can be captured
    /// either into the main graph (unrolled fallback) or into a conditional
    /// while-node's body graph, which is what gives device-side early exit.
    /// One node-space CGLS iteration. Same scalars, same stopping test, one
    /// fewer per-island reduction, and no bond-length vector in the loop.
    void launchNodeSpaceIteration(
        const ExtStressGpuSolveParams& params,
        const std::uint32_t* islandSkip,
        cudaStream_t stream,
        cudaGraphConditionalHandle loopHandle)
    {
        const std::uint32_t nodeBlocks =
            (m_graphNodeCap + kBlockSize - 1) / kBlockSize;
        const std::uint32_t islandBlocks =
            (m_islandCount + kBlockSize - 1) / kBlockSize;
        const std::uint32_t slots = reductionSlots(m_graphNodeCap);

        // w = L rho, and z_sq = ||W rho||^2 out of the same pass.
        float* output = clearReduction(stream, 1u, slots);
        m_kernelProfile.begin("nodeSpaceMatvec", stream);
        nodeSpaceMatvec<<<nodeBlocks, kBlockSize, 0, stream>>>(
            m_nsW, m_residual, m_inertia, m_nodeBondBegin, m_nodeBondRef,
            m_node0, m_node1, m_offset0, m_offset1, m_health, m_colScales,
            m_bondIsland, islandSkip, m_nodeIsland, m_islandActive, skipConvergedEnabled(),
            output, slots, m_activeNodes, m_activeCounts,
            m_iteration, 0u);
        m_kernelProfile.end(stream);
        const float* partials = finishReductionTiles(stream, 1u);
        m_kernelProfile.begin("finalizeAndCheckConvergence", stream);
        finalizeAndCheckConvergence<<<islandBlocks, kBlockSize, 0, stream>>>(
            partials, m_gradientSquared, slots,
            m_islandActive, m_islandConverged, m_deltaSquared,
            m_blockActiveCounts, m_islandCount, reductionPartialBegin(1u));
        m_kernelProfile.end(stream);

        // Preconditioned form: the direction is built from g = N w rather than
        // from rho, the numerator becomes gamma = w^T g, and q therefore needs
        // its own matvec (L g) because it can no longer reuse w. That second
        // matvec is the price of preconditioning here -- see the derivation in
        // the plan; it is why block-Jacobi has to more than halve the iteration
        // count merely to break even.
        const AngLin* directionSource = m_residual;
        const float* numerator = m_gradientSquared;
        float* numeratorPrev = m_previousGradientSquared;
        if (jacobiEnabled())
        {
            output = clearReduction(stream, 1u, slots);
            m_kernelProfile.begin("nodeSpaceApplyJacobi", stream);
            nodeSpaceApplyJacobi<<<nodeBlocks, kBlockSize, 0, stream>>>(
                m_nsG, m_nsW, m_nsJacobi, m_nodeIsland, m_islandActive,
                output, slots, m_activeNodes, m_activeCounts);
            m_kernelProfile.end(stream);
            partials = finishReductionTiles(stream, 1u);
            m_kernelProfile.begin("finalizeIslandReduction", stream);
            finalizeIslandReduction<<<islandBlocks, kBlockSize, 0, stream>>>(
                partials, m_nsGamma, m_islandCount, slots, reductionPartialBegin(1u));
            m_kernelProfile.end(stream);
            directionSource = m_nsG;
            numerator = m_nsGamma;
            numeratorPrev = m_nsGammaPrev;

            // q's own matvec: L g, written into m_nsW2.
            m_kernelProfile.begin("nodeSpaceMatvecG", stream);
            nodeSpaceMatvec<<<nodeBlocks, kBlockSize, 0, stream>>>(
                m_nsW2, m_nsG, m_inertia, m_nodeBondBegin, m_nodeBondRef,
                m_node0, m_node1, m_offset0, m_offset1, m_health, m_colScales,
                m_bondIsland, islandSkip, m_nodeIsland, m_islandActive, skipConvergedEnabled(),
                nullptr, slots, m_activeNodes, m_activeCounts,
                m_iteration, 0u);
            m_kernelProfile.end(stream);
        }
        output = clearReduction(stream, 1u, slots);
        m_kernelProfile.begin("nodeSpaceUpdateDirection", stream);
        nodeSpaceUpdateDirection<<<nodeBlocks, kBlockSize, 0, stream>>>(
            m_nsPi, m_nsQ, directionSource, jacobiEnabled() ? m_nsW2 : m_nsW,
            numerator, numeratorPrev,
            m_nodeIsland, m_islandActive, output, slots,
            m_activeNodes, m_activeCounts, m_iteration);
        m_kernelProfile.end(stream);

        // NOTE: the periodic explicit refresh of q = L pi was removed here.
        // Once ||q||^2 is accumulated by the direction update that WRITES q, a
        // later refresh would replace q while leaving its norm stale, so alpha
        // would be computed from a vector that no longer exists. It was also
        // not earning its place: at every-8 it cost ~6% of the solve and closed
        // only ~2% of the residual gap against the CPU, which is what showed
        // the recurrence is not the main source of that gap.
        // ||q||^2 was accumulated by the direction update itself; just collapse
        // the padded slots.
        partials = finishReductionTiles(stream, 1u);
        m_kernelProfile.begin("finalizeAndRetire", stream);
        finalizeAndRetire<<<islandBlocks, kBlockSize, 0, stream>>>(
            partials, m_projectedDirectionSquared, slots,
            m_islandActive, numeratorPrev, numerator,
            m_status, m_blockActiveCounts, islandBlocks,
            m_iteration, m_islandCount, loopHandle, params.maxIterations, reductionPartialBegin(1u));
        m_kernelProfile.end(stream);

        m_kernelProfile.begin("nodeSpaceUpdateSolution", stream);
        nodeSpaceUpdateSolution<<<nodeBlocks, kBlockSize, 0, stream>>>(
            m_iteration, params.maxIterations, m_nsMu, m_residual, m_nsPi, m_nsQ,
            numerator, m_projectedDirectionSquared,
            m_nodeIsland, m_islandActive, m_activeNodes, m_activeCounts);
        m_kernelProfile.end(stream);
    }

    void launchIterationBody(
        const ExtStressGpuSolveParams& params,
        const std::uint32_t* islandSkip,
        std::uint32_t maxCap,
        cudaStream_t stream,
        cudaGraphConditionalHandle loopHandle)
    {
        if (nodeSpaceEnabled())
        {
            launchNodeSpaceIteration(params, islandSkip, stream, loopHandle);
            return;
        }

            m_kernelProfile.begin("couplingLeftMultiply", stream);
            couplingLeftMultiply<<<
                (m_graphBondCap + kBlockSize - 1) / kBlockSize,
                kBlockSize,
                0,
                stream>>>(
                m_gradient,
                m_residual,
                m_inertia,
                m_node0,
                m_node1,
                m_offset0,
                m_offset1,
                m_health,
                m_colScales,
                m_bondIsland,
                islandSkip,
                m_activeBonds,
                m_activeCounts);
            m_kernelProfile.end(stream);
            const std::uint32_t islandBlocks =
                (m_islandCount + kBlockSize - 1) / kBlockSize;
            reduceByIsland(stream, 
                m_gradient, m_bondIsland, islandSkip, m_activeBonds, 0u,
                m_graphBondCap, m_gradientSquared);
            m_kernelProfile.begin("checkConvergencePerIsland", stream);
            checkConvergencePerIsland<<<islandBlocks, kBlockSize, 0, stream>>>(
                m_islandActive,
                m_islandConverged,
                m_gradientSquared,
                m_deltaSquared,
                m_blockActiveCounts,
                m_islandCount);
            m_kernelProfile.end(stream);
            m_kernelProfile.begin("updateDirectionPerIsland", stream);
            updateDirectionPerIsland<<<
                (m_graphBondCap + kBlockSize - 1) / kBlockSize,
                kBlockSize,
                0,
                stream>>>(
                m_direction,
                m_gradient,
                m_gradientSquared,
                m_previousGradientSquared,
                m_bondIsland,
                m_islandActive,
                m_activeBonds,
                m_activeCounts,
                m_iteration);
            m_kernelProfile.end(stream);

            rightMultiply(stream, m_direction, m_projectedDirection, islandSkip);
            reduceByIsland(stream, 
                m_projectedDirection,
                m_nodeIsland,
                islandSkip,
                m_activeNodes,
                1u,
                m_graphNodeCap,
                m_projectedDirectionSquared);
            m_kernelProfile.begin("retireDegenerateIslands", stream);
            retireDegenerateIslands<<<islandBlocks, kBlockSize, 0, stream>>>(
                m_islandActive,
                m_projectedDirectionSquared,
                m_previousGradientSquared,
                m_gradientSquared,
                m_status,
                m_blockActiveCounts,
                islandBlocks,
                m_iteration,
                m_islandCount,
                loopHandle,
                params.maxIterations);
            m_kernelProfile.end(stream);
            m_kernelProfile.begin("updateSolutionAndResidualPerIsland", stream);
            updateSolutionAndResidualPerIsland<<<
                (maxCap + kBlockSize - 1) / kBlockSize,
                kBlockSize,
                0,
                stream>>>(
                m_iteration,
                params.maxIterations,
                m_impulses,
                m_residual,
                m_direction,
                m_projectedDirection,
                m_gradientSquared,
                m_projectedDirectionSquared,
                m_islandActive,
                m_bondIsland,
                m_nodeIsland,
                m_activeBonds,
                m_activeNodes,
                m_activeCounts);
            m_kernelProfile.end(stream);
            }

    /// Run the CG loop, with device-side early exit when it is available.
    ///
    /// Two shapes, and the difference is the whole point:
    ///
    /// - CONDITIONAL (preferred): one `cudaGraphCondTypeWhile` node whose body
    ///   is a single copy of the iteration. The device decides each round
    ///   whether to go again, so a scene whose islands all converged at
    ///   iteration 3 costs three iterations, not maxIterations. Requires that
    ///   we are inside stream capture, which is the normal path.
    ///
    /// - UNROLLED (fallback): maxIterations copies of the body, as before.
    ///   Used when not capturing (the eager kernel-profile path), and when the
    ///   conditional path is switched off. Bit-identical results, just slower
    ///   whenever the solve converges early.
    ///
    /// Both call the same launchIterationBody, so there is one implementation
    /// of the iteration and no chance of the two shapes drifting apart.
    void launchPersistentStress(const ExtStressGpuSolveParams& params) {
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if(deterministicReductionsEnabled())throw std::runtime_error("Reference reduction override is not supported by the integrated solver");
        const unsigned nodeBlocks=(m_graphNodeCap+kBlockSize-1)/kBlockSize;
        const unsigned islandBlocks=(m_islandCount+kBlockSize-1)/kBlockSize;
        const unsigned slots=reductionSlots(m_graphNodeCap),maxIterations=params.maxIterations;
        PersistentStressArgs args{m_nsW,m_residual,m_inertia,m_nodeBondBegin,m_nodeBondRef,m_node0,m_node1,m_offset0,m_offset1,m_health,m_colScales,m_bondIsland,m_nodeIsland,m_islandActive,m_reduceSlots,slots,m_activeNodes,m_activeCounts,m_iteration,m_gradientSquared,m_islandConverged,m_deltaSquared,m_blockActiveCounts,m_islandCount,m_nsPi,m_nsQ,m_previousGradientSquared,m_projectedDirectionSquared,m_status,islandBlocks,maxIterations,m_nsMu,nodeBlocks,m_deviceTopology ? m_deviceTopology->islandIds() : nullptr,m_deviceTopology ? &m_deviceTopology->status()->islandCount : nullptr,false};
        // Residency is a launch constraint, not a physical-work limit. All
        // virtual node/island blocks are processed by the resident grid.
        const auto kernel=m_deviceTopology?persistentStressSolve<true>:persistentStressSolve<false>;
        if(m_deviceTopology){args.hierarchy=m_deviceTopology->cycleView();args.input=m_input;args.impulses=m_impulses;args.originalRhs=m_rhs;args.warmStart=params.warmStart && m_hasWarmStart;args.settledIslands=m_islandSkip;}
        int blocksPerSm=0,device=0,sms=0;
        checkCuda(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&blocksPerSm,kernel,kBlockSize,0),"persistent stress occupancy");
        checkCuda(cudaGetDevice(&device),"persistent stress device");
        checkCuda(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device),"persistent stress multiprocessors");
        if(blocksPerSm<=0 || sms<=0)throw std::runtime_error("Persistent stress cooperative launch has no legal residency");
        // Multilevel rows use eight lanes per node, so provision the resident
        // grid for that dominant work rather than only the scalar vector sweeps.
        // Small complete problems remain within one block: shared-block
        // barriers avoid cross-SM rendezvous for a few hundred nodes.
        const unsigned blocks=m_nodeCount<=1024 ? 1u : std::min(std::max(nodeBlocks*8u,islandBlocks),unsigned(blocksPerSm*sms));
        ResidentStressComponentView components{};
        if(m_deviceTopology) {
            initializeNativeWarmResidual<<<nodeBlocks,kBlockSize,0,m_stream>>>(args);
#ifdef BLAST_GPU_NATIVE_PROBLEM_CAPTURE
            captureStressProblem<<<(std::max(m_nodeCount,m_bondCount)+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(args,m_nodeCount,m_bondCount);
#endif
            components=m_deviceTopology->components();
            // Cached direct factors, original schedule: claim slots and refactor
            // the invalid ones before the iterative kernel. Deferred mode does
            // this after the solve's completion event (solveDeviceAsync).
            if(m_direct.enabled && !m_direct.deferred)launchNativeDirectFactor();
            // The device list controls the live work; a bounded persistent
            // grid distributes independent components without a host count.
            componentStressSolve<<<std::min(m_nodeCount,unsigned(sms*2)),kBlockSize,0,m_stream>>>(args,components);
            args.islandIds=components.largeIds;
            args.liveIslandCount=components.largeCount;
            args.largeComponentsOnly=true;
        }
        void* arguments[]={&args};
        checkCuda(cudaLaunchCooperativeKernel((void*)kernel,dim3(blocks),dim3(kBlockSize),arguments,0,m_stream),"capture persistent stress solve");
        if(m_deviceTopology)
            finishComponentStress<<<1,kBlockSize,0,m_stream>>>(args,components);
#else
        (void)params;
#endif
    }

    void launchConditionalLoop(
        const ExtStressGpuSolveParams& params,
        const std::uint32_t* islandSkip,
        std::uint32_t maxCap)
    {
#ifdef PHYSX_RESIDENT_DESTRUCTION
        launchPersistentStress(params);return;
#else

        if (conditionalLoopEnabled())
        {
            cudaStreamCaptureStatus captureStatus = cudaStreamCaptureStatusNone;
            unsigned long long captureId = 0;
            cudaGraph_t capturing = nullptr;
            const cudaGraphNode_t* deps = nullptr;
            std::size_t depCount = 0;
            if (cudaStreamGetCaptureInfo(
                    m_stream, &captureStatus, &captureId, &capturing, &deps,nullptr, &depCount)
                    == cudaSuccess
                && captureStatus == cudaStreamCaptureStatusActive
                && capturing != nullptr)
            {
                if (launchConditionalLoopCaptured(
                        params, islandSkip, maxCap, capturing, deps, depCount))
                {
                    return;
                }
                // Fall through to the unrolled form. Any failure here is a
                // performance regression, never a wrong answer, because the
                // two shapes compute the same thing.
                cudaGetLastError();
            }
        }

        for (std::uint32_t iteration = 0; iteration < params.maxIterations; ++iteration)
        {
            // The unrolled form still reads the counter from device memory, so
            // the two paths share one kernel signature. Bump it per copy.
            launchIterationBody(params, islandSkip, maxCap, m_stream, 0);
        }
#endif
    }

    /// Build the while-node. Returns false if anything is unsupported, leaving
    /// the caller to use the unrolled form.
    bool launchConditionalLoopCaptured(
        const ExtStressGpuSolveParams& params,
        const std::uint32_t* islandSkip,
        std::uint32_t maxCap,
        cudaGraph_t capturing,
        const cudaGraphNode_t* deps,
        std::size_t depCount)
    {
        cudaGraphConditionalHandle handle = 0;
        // Default 1: the body must run at least once, exactly like a do/while.
        // A solve that is already converged still has to produce its outputs.
        if (cudaGraphConditionalHandleCreate(
                &handle, capturing, 1, cudaGraphCondAssignDefault) != cudaSuccess)
        {
            return false;
        }

        cudaGraphNodeParams nodeParams{};
        nodeParams.type = cudaGraphNodeTypeConditional;
        nodeParams.conditional.handle = handle;
        nodeParams.conditional.type = cudaGraphCondTypeWhile;
        nodeParams.conditional.size = 1;

        cudaGraphNode_t whileNode = nullptr;
        if (cudaGraphAddNode(&whileNode, capturing, deps,nullptr, depCount, &nodeParams)
                != cudaSuccess
            || nodeParams.conditional.phGraph_out == nullptr)
        {
            return false;
        }

        // Everything captured after this point must depend on the while node,
        // or the epilogue would be free to run alongside the loop.
        if (cudaStreamUpdateCaptureDependencies(
                m_stream, &whileNode, nullptr, 1, cudaStreamSetCaptureDependencies) != cudaSuccess)
        {
            return false;
        }

        cudaGraph_t body = nodeParams.conditional.phGraph_out[0];
        if (cudaStreamBeginCaptureToGraph(
                m_bodyStream, body, nullptr, nullptr, 0,
                cudaStreamCaptureModeThreadLocal) != cudaSuccess)
        {
            return false;
        }

        // Check the condition every kChunk iterations instead of every one.
        // The while-node's per-execution dispatch cost showed up as a stable
        // +3.7% on scenes that run their full budget (0/7 pairs faster,
        // counterbalanced n=8); amortising it over a chunk removes most of
        // that while still exiting ~8x earlier than the budget on scenes that
        // converge immediately. Exactness comes from the guard in
        // updateSolutionAndResidualPerIsland, so kChunk is purely a cost knob.
        const std::uint32_t chunk = conditionalLoopChunk();
        for (std::uint32_t k = 0; k < chunk; ++k)
        {
            launchIterationBody(params, islandSkip, maxCap, m_bodyStream, handle);
        }

        cudaGraph_t bodyOut = nullptr;
        if (cudaStreamEndCapture(m_bodyStream, &bodyOut) != cudaSuccess)
        {
            return false;
        }
        ++m_statConditionalLoops;
        return true;
    }

