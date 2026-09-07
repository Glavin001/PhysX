// Private member definitions; included once inside ExtStressGpuSolverImpl.
// BEGIN UNCHANGED SOURCE
    /// Smallest power-of-two launch size covering `active`, with one bucket
    /// of headroom so a few more islands waking does not recapture the graph.
    /// Never below 1024 (recaptures at that scale cost more than the waste)
    /// and never above the raw array size.
    static std::uint32_t launchCapacity(std::uint32_t active, std::uint32_t full)
    {
        if (active >= full)
        {
            return full;
        }
        std::uint32_t cap = 1024u;
        while (cap < active)
        {
            cap <<= 1u;
        }
        cap <<= 1u;
        return std::min(cap, full);
    }

    /// The subset of graphMatches that changes the graph's NODE SET rather
    /// than its node parameters. When this holds, a changed solve can be
    /// patched into the existing exec instead of rebuilt. Deliberately excludes
    /// skipSettledIslands: it only selects whether the kernels receive
    /// m_islandSkip or nullptr, and a pointer arg is a parameter like any other.
    bool graphTopologyMatches(const ExtStressGpuSolveParams& params, bool warmStart) const
    {
        return m_graphExec != nullptr
            && m_graph != nullptr
            && (stableGraphEnabled() || m_graphWarmStart == warmStart)
            && m_graphParams.maxIterations == params.maxIterations
            && m_graphParams.applyDamage == params.applyDamage;
    }

    bool graphMatches(const ExtStressGpuSolveParams& params, bool warmStart) const
    {
        return m_graphExec
            && m_graphWarmStart == warmStart
            && m_graphParams.maxIterations == params.maxIterations
            && m_graphParams.tolerance == params.tolerance
            && m_graphParams.applyDamage == params.applyDamage
            // Capture-time: it selects whether the kernels are handed the skip
            // mask at all. The mask's CONTENTS change every frame and are read
            // from device memory, so a settling scene never recaptures.
            && m_graphParams.skipSettledIslands == params.skipSettledIslands
            // The active lists' CONTENTS are device-side and free to change;
            // the launch dimensions that must cover them are baked. Recapture
            // when the lists outgrow the baked caps (mandatory -- threads past
            // the cap simply do not exist) or shrank far below them (waste).
            && (fullLaunchCapacity()
                || (m_graphBondCap >= m_activeBondCount
                    && m_graphNodeCap >= m_activeNodeCount
                    && m_graphBondCap <= 4u * std::max(
                           launchCapacity(m_activeBondCount, m_bondCount), 1024u)
                    && m_graphNodeCap <= 4u * std::max(
                           launchCapacity(m_activeNodeCount, m_nodeCount), 1024u)));
    }

    void executeSolve(const ExtStressGpuSolveParams& params)
    {
        const bool warmStart = params.warmStart && m_hasWarmStart;
        if (kernelProfileEnabled())
        {
            // Eager launches, one event pair per kernel. The graph is bypassed
            // on purpose: comparing this total against the graph-replay total
            // prices the launch overhead the graph removes, which is the one
            // number source-reading cannot supply.
            m_kernelProfile.active = true;
            // The launch caps are normally computed in the capture branch
            // below; the eager path skips it, so they must be set here or
            // every grid is sized from a stale (or zero) cap.
            m_graphBondCap = fullLaunchCapacity()
                ? m_bondCount : launchCapacity(m_activeBondCount, m_bondCount);
            m_graphNodeCap = fullLaunchCapacity()
                ? m_nodeCount : launchCapacity(m_activeNodeCount, m_nodeCount);
            launchSolve(params);
            ++m_profiledSolves;
            return;
        }
        if (m_graphParamsDirty || !graphMatches(params, warmStart))
        {
            m_graphParamsDirty = false;
            m_graphBondCap = fullLaunchCapacity()
                ? m_bondCount : launchCapacity(m_activeBondCount, m_bondCount);
            m_graphNodeCap = fullLaunchCapacity()
                ? m_nodeCount : launchCapacity(m_activeNodeCount, m_nodeCount);
            if (graphUpdateEnabled() && graphTopologyMatches(params, warmStart))
            {
                const auto updateStart = std::chrono::steady_clock::now();
                cudaGraph_t fresh = nullptr;
                bool captured =
                    cudaStreamBeginCapture(m_stream, cudaStreamCaptureModeThreadLocal)
                    == cudaSuccess;
                if (captured)
                {
                    launchSolve(params);
                    captured = cudaStreamEndCapture(m_stream, &fresh) == cudaSuccess
                        && fresh != nullptr;
                }
                if (captured)
                {
                    cudaGraphExecUpdateResultInfo info{};
                    const cudaError_t rc = cudaGraphExecUpdate(m_graphExec, fresh, &info);
                    if (rc == cudaSuccess && info.result == cudaGraphExecUpdateSuccess)
                    {
                        cudaGraphDestroy(m_graph);
                        m_graph = fresh;
                        m_graphParams = params;
                        m_graphWarmStart = warmStart;
                        ++m_statGraphUpdates;
                        m_statUpdateMs += std::chrono::duration<double, std::milli>(
                                              std::chrono::steady_clock::now()
                                              - updateStart).count();
                        checkCuda(cudaGraphLaunch(m_graphExec, m_stream),
                                  "launch patched solver graph");
                        return;
                    }
                    cudaGraphDestroy(fresh);
                }
                // Do not let a failed attempt poison the fallback's error state.
                cudaGetLastError();
            }
            if (m_graphExec)
            {
                checkCuda(cudaGraphExecDestroy(m_graphExec), "destroy old solver graph exec");
                m_graphExec = nullptr;
            }
            if (m_graph)
            {
                checkCuda(cudaGraphDestroy(m_graph), "destroy old solver graph");
                m_graph = nullptr;
            }
            const auto recaptureStart = std::chrono::steady_clock::now();
            checkCuda(
                cudaStreamBeginCapture(m_stream, cudaStreamCaptureModeThreadLocal),
                "begin solver graph capture");
            launchSolve(params);
            checkCuda(
                cudaStreamEndCapture(m_stream, &m_graph),
                "end solver graph capture");
            const auto captureDone = std::chrono::steady_clock::now();
            checkCuda(
                (++m_statGraphRecaptures,
                 cudaGraphInstantiate(&m_graphExec, m_graph, 0)),
                "instantiate solver graph");
            m_statCaptureMs += std::chrono::duration<double, std::milli>(
                                   captureDone - recaptureStart).count();
            m_statInstantiateMs += std::chrono::duration<double, std::milli>(
                                       std::chrono::steady_clock::now() - captureDone).count();
            m_graphParams = params;
            m_graphWarmStart = warmStart;
        }
        checkCuda(cudaGraphLaunch(m_graphExec, m_stream), "launch solver graph");
    }

