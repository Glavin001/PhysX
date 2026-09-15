// Private member definitions; included once inside ExtStressGpuSolverImpl.
// Allocate only storage used by the selected build-time numerical path.
    template <typename T>
    void allocateDevice(T*& pointer, std::size_t count, const char* name)
    {
        checkCuda(cudaMalloc(&pointer, sizeof(T) * count), name);
    }

    template <typename T>
    void allocateHost(T*& pointer, std::size_t count, const char* name)
    {
        checkCuda(cudaMallocHost(&pointer, sizeof(T) * count), name);
    }

    void allocate()
    {
        allocateDevice(m_node0, m_bondCount, "allocate node0");
        allocateDevice(m_node1, m_bondCount, "allocate node1");
        allocateDevice(m_offset0, m_bondCount, "allocate offset0");
        allocateDevice(m_offset1, m_bondCount, "allocate offset1");
        allocateDevice(m_inertia, m_nodeCount, "allocate inertia");
#ifdef PHYSX_RESIDENT_DESTRUCTION
        allocateDevice(m_positions,m_nodeCount,"allocate persistent chunk positions");
#endif
        allocateDevice(m_normals, m_bondCount, "allocate normals");
        allocateDevice(m_areas, m_bondCount, "allocate areas");
        allocateDevice(m_colScales, m_bondCount, "allocate compliance weights");
        allocateDevice(m_bondMaterials, m_bondCount, "allocate bond materials");
        allocateDevice(m_materials, m_materialCount, "allocate material table");
        allocateDevice(m_nodeDistances, m_bondCount, "allocate node distances");
        allocateDevice(m_health, m_bondCount, "allocate health");
        allocateDevice(m_brokenBonds, m_bondCount, "allocate broken bonds");
        allocateDevice(m_brokenCount, 1, "allocate broken count");
        allocateDevice(m_input, m_nodeCount, "allocate input");
        allocateDevice(m_impulses, m_bondCount, "allocate impulses");
        allocateDevice(m_rhs, m_nodeCount, "allocate rhs");
        if (!nodeSpaceEnabled())
        {
            allocateDevice(m_gradient, m_bondCount, "allocate gradient");
            allocateDevice(m_direction, m_bondCount, "allocate direction");
        }
        allocateDevice(m_residual, m_nodeCount, "allocate residual");
        allocateDevice(m_projectedDirection, m_nodeCount, "allocate projected direction");
        if (deterministicReductionsEnabled())
            allocateDevice(m_reductionInput, std::max(m_nodeCount, m_bondCount),
                           "allocate reduction input");
        // Per-island conjugate-gradient scalars. One set per disconnected
        // component, so islands converge and step independently.
        // Sized for the worst case, not for today's partition: every bond that
        // breaks can split an island, and an island contains at least one
        // dynamic node, so the count can rise to m_nodeCount over the solver's
        // life. Allocating for that once is a few hundred kilobytes and means
        // a repartition never has to reallocate -- which is what would drag
        // the full-rebuild cost back in through the side door.
        m_islandCapacity = std::max(m_nodeCount, 1u);
        if (deterministicReductionsEnabled())
        {
            allocateDevice(m_deterministicPartials, std::max(m_nodeCount, m_bondCount), "allocate deterministic partials");
            for (std::uint32_t kind = 0; kind < 2u; ++kind)
            {
                auto& order = m_reductionOrder[kind];
                const auto capacity = std::max(kind ? m_nodeCount : m_bondCount, 1u);
                allocateDevice(order.deviceOrder, capacity, "allocate reduction index order");
                allocateDevice(order.deviceTiles, capacity, "allocate reduction tiles");
                allocateDevice(order.devicePartialBegin, m_islandCapacity + 1u, "allocate reduction island offsets");
            }
        }
        allocateDevice(m_gradientSquared, m_islandCapacity, "allocate gradient norm");
        allocateDevice(m_iteration, 1, "allocate device iteration counter");
        // Node-space CGLS working set. Node-length, so ~1/3 of the bond-length
        // vectors they replace.
        allocateDevice(m_nsPi, m_nodeCount, "allocate node-space direction");
        allocateDevice(m_nsQ, m_nodeCount, "allocate node-space projected direction");
        allocateDevice(m_nsW, m_nodeCount, "allocate node-space matvec output");
        allocateDevice(m_nsMu, m_nodeCount, "allocate node-space correction");
        // The native resident operator does not use reference Jacobi vectors
        // or inverses. Keep their storage out of the native memory footprint.
        if (jacobiEnabled())
        {
            allocateDevice(m_nsG, m_nodeCount, "allocate node-space preconditioned residual");
            allocateDevice(m_nsW2, m_nodeCount, "allocate node-space second matvec output");
            allocateDevice(m_nsJacobi, static_cast<std::size_t>(m_nodeCount) * 36,
                           "allocate node-space block-Jacobi inverses");
            allocateDevice(m_nsGamma, m_islandCapacity, "allocate node-space gamma");
            allocateDevice(m_nsGammaPrev, m_islandCapacity, "allocate node-space gamma prev");
        }
        // Padded accumulators for the per-island reduction. One buffer serves
        // every reduction because each is finalized into its own result array
        // before the next one starts.
        allocateDevice(
            m_reduceSlots,
            static_cast<std::size_t>(m_islandCapacity) * kReductionSlotsMax,
            "allocate padded island reduction slots");
        allocateDevice(
            m_projectedDirectionSquared, m_islandCapacity, "allocate projected norm");
        allocateDevice(m_deltaSquared, m_islandCapacity, "allocate tolerance");
        allocateDevice(
            m_previousGradientSquared, m_islandCapacity, "allocate previous gradient norm");
        allocateDevice(m_islandActive, m_islandCapacity, "allocate island active flags");
        allocateDevice(m_islandConverged, m_islandCapacity, "allocate island converged flags");
        allocateDevice(m_islandSkip, m_islandCapacity, "allocate island skip mask");
        allocateDevice(m_deviceIslandDirty, m_islandCapacity, "allocate device input dirty flags");
        allocateDevice(
            m_blockActiveCounts,
            (m_islandCapacity + kBlockSize - 1) / kBlockSize + 1,
            "allocate island block tallies");
        allocateDevice(m_nodeBondBegin, m_nodeCount + 1, "allocate node-bond csr offsets");
        allocateDevice(m_nodeBondRef, m_bondCount * 2 + 1, "allocate node-bond csr refs");
        allocateDevice(m_bondIsland, m_bondCount, "allocate bond island ids");
        allocateDevice(m_nodeIsland, m_nodeCount, "allocate node island ids");
        allocateDevice(m_scatterIndices, m_nodeCount, "allocate scatter indices");
        allocateDevice(m_scatterValues, m_nodeCount, "allocate scatter values");
        allocateDevice(m_gatherIndices, m_bondCount, "allocate gather indices");
        allocateDevice(m_gatherOutput, m_bondCount, "allocate gather output");
        allocateDevice(m_status, 1, "allocate solve status");
        allocateDevice(m_activeBonds, m_bondCount, "allocate active bond list");
        allocateDevice(m_activeNodes, m_nodeCount, "allocate active node list");
        allocateDevice(m_activeCounts, 2, "allocate active counts");
        allocateDevice(
            m_activeFlags, std::max(m_bondCount, m_nodeCount), "allocate active flags");
        {
            // Scratch for the order-preserving selects; sized for the larger
            // of the two so one buffer serves both.
            thrust::counting_iterator<std::uint32_t> identity(0u);
            std::size_t bondSelectBytes = 0;
            std::size_t nodeSelectBytes = 0;
            cub::DeviceSelect::Flagged(
                nullptr,
                bondSelectBytes,
                identity,
                m_activeFlags,
                m_activeBonds,
                m_activeCounts,
                static_cast<int>(m_bondCount));
            cub::DeviceSelect::Flagged(
                nullptr,
                nodeSelectBytes,
                identity,
                m_activeFlags,
                m_activeNodes,
                m_activeCounts + 1,
                static_cast<int>(m_nodeCount));
            m_selectScratchBytes = std::max(bondSelectBytes, nodeSelectBytes);
            checkCuda(
                cudaMalloc(&m_selectScratch, m_selectScratchBytes),
                "allocate select scratch");
        }
        allocateHost(m_hostActiveCounts, 2, "allocate pinned active counts");
        m_hostActiveCounts[0] = 0u;
        m_hostActiveCounts[1] = 0u;
        allocateHost(m_hostInput, m_nodeCount, "allocate pinned stress input");
        allocateHost(m_hostImpulses, m_bondCount, "allocate pinned stress impulses");
        allocateDevice(m_devicePhysicalImpulses, m_bondCount, "allocate resident physical bond forces");
        allocateHost(m_hostStatus, 1, "allocate pinned stress status");
        allocateHost(m_hostBrokenCount, 1, "allocate pinned broken count");
        *m_hostBrokenCount = 0u;
        allocateHost(m_hostIslandSkip, m_islandCapacity, "allocate pinned island skip mask");
        allocateHost(
            m_hostIslandConvergedPinned, m_islandCapacity, "allocate pinned island convergence");
        allocateHost(m_hostScatterIndices, m_nodeCount, "allocate pinned scatter indices");
        allocateHost(m_hostScatterValues, m_nodeCount, "allocate pinned scatter values");
        allocateHost(m_hostGatherIndices, m_bondCount, "allocate pinned gather indices");
        m_hostIslandConverged.assign(m_islandCapacity, 0u);
        m_islandDirty.assign(m_islandCapacity, 1u);
        m_changedNodes.reserve(m_nodeCount);
        m_changedBonds.reserve(m_bondCount);
        std::fill(m_hostIslandSkip, m_hostIslandSkip + m_islandCount, 0u);

        checkCuda(
            cudaStreamCreateWithPriority(&m_stream, cudaStreamNonBlocking, streamPriority()),
            "create solver stream");
#ifndef PHYSX_RESIDENT_DESTRUCTION
        // Capture-only: the conditional loop body is captured onto this stream
        // into the while-node's body graph. Nothing is ever launched on it
        // outside capture.
        checkCuda(
            cudaStreamCreateWithFlags(&m_bodyStream, cudaStreamNonBlocking),
            "create conditional body capture stream");
#endif
        checkCuda(cudaEventCreate(&m_uploadStart), "create upload start event");
        checkCuda(cudaEventCreate(&m_uploadStop), "create upload stop event");
        checkCuda(cudaEventCreate(&m_solveStart), "create solve start event");
        checkCuda(cudaEventCreate(&m_solveStop), "create solve stop event");
        checkCuda(cudaEventCreate(&m_statusReady), "create status-ready event");
        checkCuda(cudaEventCreate(&m_topoUploadDone), "create topology-upload event");
        checkCuda(cudaEventCreate(&m_downloadStart), "create download start event");
        checkCuda(cudaEventCreate(&m_downloadStop), "create download stop event");
        checkCuda(cudaMemset(m_impulses, 0, sizeof(AngLin) * m_bondCount), "clear impulses");
        checkCuda(cudaMemset(m_brokenCount, 0, sizeof(std::uint32_t)), "clear broken count");
        checkCuda(
            cudaMemset(m_islandConverged, 0, sizeof(std::uint32_t) * m_islandCapacity),
            "clear island converged flags");
        checkCuda(
            cudaMemset(m_islandSkip, 0, sizeof(std::uint32_t) * m_islandCapacity),
            "clear island skip mask");
        checkCuda(
            cudaMemset(m_input, 0, sizeof(ExtStressGpuImpulse) * m_nodeCount),
            "clear stress inputs");
        // Nothing has been solved yet, so nothing may be skipped against it.
        std::memset(m_hostInput, 0, sizeof(ExtStressGpuImpulse) * m_nodeCount);
    }

