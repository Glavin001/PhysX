// Private member definitions; included once inside ExtStressGpuSolverImpl.
// Solver lifetime; release every owned allocation.
    ExtStressGpuSolverImpl(
        const ExtStressGpuNode* nodes,
        std::uint32_t nodeCount,
        const ExtStressGpuBond* bonds,
        std::uint32_t bondCount,
        const ExtStressGpuMaterial* materials,
        std::uint32_t materialCount,
        CUcontext cudaContext)
        : m_nodeCount(nodeCount)
        , m_bondCount(bondCount)
        , m_cudaContext(cudaContext)
    {
        // A solver always has a material table; default = one entry with the
        // struct's defaults so limit-free callers keep historical behavior.
        if (materials && materialCount > 0)
        {
            m_hostMaterials.assign(materials, materials + materialCount);
        }
        else
        {
            m_hostMaterials.assign(1, ExtStressGpuMaterial());
        }
        m_materialCount = static_cast<std::uint32_t>(m_hostMaterials.size());
        ContextGuard context(m_cudaContext);
#ifdef PHYSX_RESIDENT_DESTRUCTION
        int device=0;cudaDeviceProp properties{};
        checkCuda(cudaGetDevice(&device), "query destruction device");
        checkCuda(cudaGetDeviceProperties(&properties, device), "query destruction capabilities");
        if(properties.major!=8 || properties.minor!=9 || std::string(properties.name)!="NVIDIA GeForce RTX 4090" || !properties.cooperativeLaunch)
            throw std::runtime_error("Integrated destruction is compatible only with RTX 4090 sm_89 and cooperative CUDA execution");
#endif
        prepare(nodes, bonds);
computeIslands();
        buildNodeBondCsr();
        groupBondsByIsland();
        allocate();
        uploadReductionOrders();
        uploadTopology();
uploadIslands();
        uploadNodeBondCsr();
        if (s_debug)
        {
            std::fprintf(
                stderr,
                "[blast-gpu-skip] CREATE nodes %u bonds %u islands %u\n",
                m_nodeCount,
                m_bondCount,
                m_islandCount);
        }
    }

    ~ExtStressGpuSolverImpl() override
    {
        ContextGuard context(m_cudaContext);
        cudaStreamSynchronize(m_stream);
        delete m_deviceTopology;
        if (m_graphExec)
        {
            cudaGraphExecDestroy(m_graphExec);
        }
        if (m_graph)
        {
            cudaGraphDestroy(m_graph);
        }
        cudaEventDestroy(m_uploadStart);
        cudaEventDestroy(m_uploadStop);
        cudaEventDestroy(m_solveStart);
        cudaEventDestroy(m_solveStop);
        cudaEventDestroy(m_statusReady);
        cudaEventDestroy(m_topoUploadDone);
        cudaEventDestroy(m_downloadStart);
        cudaEventDestroy(m_downloadStop);
        cudaStreamDestroy(m_stream);
        if (m_bodyStream) { cudaStreamDestroy(m_bodyStream); m_bodyStream = nullptr; }
        freeBondStress();
        cudaFreeHost(m_topoStaging);
        cudaFreeHost(m_hostStatus);
        cudaFreeHost(m_hostBrokenCount);
        cudaFreeHost(m_hostIslandConvergedPinned);
        cudaFreeHost(m_hostIslandSkip);
        cudaFreeHost(m_hostImpulses);
        cudaFree(m_devicePhysicalImpulses);
        cudaFreeHost(m_hostInput);
        cudaFreeHost(m_hostScatterIndices);
        cudaFreeHost(m_hostScatterValues);
        cudaFreeHost(m_hostGatherIndices);
        cudaFreeHost(m_hostActiveCounts);
        cudaFree(m_selectScratch);
        cudaFree(m_activeFlags);
        cudaFree(m_activeCounts);
        cudaFree(m_activeNodes);
        cudaFree(m_activeBonds);
        cudaFree(m_gatherOutput);
        cudaFree(m_gatherIndices);
        cudaFree(m_scatterValues);
        cudaFree(m_scatterIndices);
        cudaFree(m_islandConverged);
        cudaFree(m_islandSkip);
        cudaFree(m_deviceIslandDirty);
        cudaFree(m_status);
        cudaFree(m_previousGradientSquared);
        cudaFree(m_deltaSquared);
        cudaFree(m_islandActive);
        cudaFree(m_blockActiveCounts);
        cudaFree(m_nodeBondBegin);
        cudaFree(m_nodeBondRef);
        cudaFree(m_bondIsland);
        cudaFree(m_nodeIsland);
        cudaFree(m_projectedDirectionSquared);
        cudaFree(m_gradientSquared);
        cudaFree(m_reduceSlots);
        cudaFree(m_iteration);
        cudaFree(m_devDeltaSlots);
        cudaFree(m_devDeltaValues);
        cudaFree(m_nsPi);
        cudaFree(m_nsQ);
        cudaFree(m_nsW);
        cudaFree(m_nsMu);
        cudaFree(m_nsG);
        cudaFree(m_nsW2);
        cudaFree(m_nsJacobi);
        cudaFree(m_nsGamma);
        cudaFree(m_nsGammaPrev);
        cudaFree(m_devRefSlots);
        cudaFree(m_devRefValues);
        cudaFree(m_devNodeIslandSlots);
        cudaFree(m_devNodeIslandValues);
        cudaFree(m_reductionInput);
        cudaFree(m_deterministicPartials);
        for (auto& order : m_reductionOrder)
        {
            cudaFree(order.deviceOrder);
            cudaFree(order.devicePartialBegin);
            cudaFree(order.deviceTiles);
        }
        cudaFree(m_projectedDirection);
        cudaFree(m_residual);
        cudaFree(m_direction);
        cudaFree(m_gradient);
        cudaFree(m_rhs);
        cudaFree(m_impulses);
        cudaFree(m_input);
        cudaFree(m_brokenCount);
        cudaFree(m_brokenBonds);
        cudaFree(m_health);
        cudaFree(m_colScales);
        cudaFree(m_nodeDistances);
        cudaFree(m_materials);
        cudaFree(m_bondMaterials);
        cudaFree(m_areas);
        cudaFree(m_normals);
        cudaFree(m_inertia);
        cudaFree(m_offset1);
        cudaFree(m_offset0);
        cudaFree(m_node1);
        cudaFree(m_node0);
    }

    void release() override
    {
        if (m_kernelProfile.active && m_profiledSolves > 0)
        {
            m_kernelProfile.dump("eager launches, no CUDA graph", m_profiledSolves);
        }
        delete this;
    }

