// Private member definitions; included once inside ExtStressGpuSolverImpl.
// BEGIN UNCHANGED SOURCE
    bool prepareDeviceSolve() override
    {
        if (m_deviceTopology || m_deviceTopologyFailed) return false;
        ContextGuard context(m_cudaContext);
        if (m_topologyDirty) applyTopologyChange();
        if (!m_bondCount) return false;
        refreshActiveLists(false);
        // Preparation is the asset/topology boundary, never the simulation path.
        checkCuda(cudaStreamSynchronize(m_stream), "prepare resident stress solve");
        m_activeBondCount = m_hostActiveCounts[0];
        m_activeNodeCount = m_hostActiveCounts[1];
        return true;
    }

    const unsigned* m_parkedNodeFlags = nullptr;
    void setParkedComponentFlags(const unsigned* deviceNodeFlags) override { m_parkedNodeFlags = deviceNodeFlags; }
    bool solveDeviceAsync(const ExtStressGpuImpulse* inputs, std::uint32_t count,
        const ExtStressGpuSolveParams& params, void* producerReady, void* consumerDone) override
    {
        if (!inputs || count != m_nodeCount || !m_bondCount || !params.maxIterations
            || !std::isfinite(params.tolerance) || params.tolerance <= 0
            || params.skipSettledIslands || params.skipStableUnconverged || params.applyDamage
            || m_topologyDirty || m_activeListsDirty || m_prevListsSkipping || m_deviceTopologyFailed)
            return false;
        ContextGuard context(m_cudaContext);
        joinFactorStream();
        if (consumerDone) checkCuda(cudaStreamWaitEvent(m_stream,
            reinterpret_cast<cudaEvent_t>(consumerDone), 0), "wait stress consumer");
        if (producerReady) checkCuda(cudaStreamWaitEvent(m_stream,
            reinterpret_cast<cudaEvent_t>(producerReady), 0), "wait stress producer");
        m_telemetry = {};
        // The exact live island count is a device observation in this mode.
        m_telemetry.islandCount = m_deviceTopology ? 0 : m_islandCount;
        m_telemetry.deviceToDeviceBytes = inputs == m_input ? 0 : sizeof(*inputs) * std::uint64_t(count);
        m_bendGainMax = params.bendGainMax;
        m_skipStableUnconverged = false;
        m_hostInputValid = false;
        m_settledBaselineValid = false;
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if(inputs != m_input) throw std::runtime_error("Integrated destruction requires the shared resident input view");
#else
        if(inputs != m_input) checkCuda(cudaMemcpyAsync(m_input, inputs, sizeof(*inputs)*count,
            cudaMemcpyDeviceToDevice, m_stream), "copy reference stress inputs");
#endif
#ifdef BLAST_GPU_COMPONENT_WORK_CAPTURE
        if(!m_workCapture)throw std::runtime_error("component diagnostic requires native topology");
        m_workCapture->begin(m_stream);
#endif
#ifdef PHYSX_RESIDENT_DESTRUCTION
        // Refresh the captured graph's parked-flag input outside the capture.
        static const bool parkedAudit = []() { const char* raw = std::getenv("BLAST_GPU_NATIVE_PARKED_AUDIT"); return raw && raw[0] == '1'; }();
        if (m_deviceTopology && m_parkedFlags) {
            if (m_parkedNodeFlags && !parkedAudit)
                checkCuda(cudaMemcpyAsync(m_parkedFlags, m_parkedNodeFlags, sizeof(std::uint32_t) * m_nodeCount,
                    cudaMemcpyDeviceToDevice, m_stream), "copy parked component flags");
            else
                checkCuda(cudaMemsetAsync(m_parkedFlags, 0, sizeof(std::uint32_t) * m_nodeCount, m_stream),
                    "clear parked component flags");
            if (parkedAudit) {
                // Audit only: flags are never applied; the corrected solve's node
                // inputs are compared against the preceding (trial) solve's.
                if (!m_auditInput) {
                    checkCuda(cudaMalloc(reinterpret_cast<void**>(&m_auditInput), sizeof(ExtStressGpuImpulse) * m_nodeCount), "allocate audit inputs");
                    checkCuda(cudaMalloc(reinterpret_cast<void**>(&m_auditCounters), sizeof(std::uint32_t) * 10), "allocate audit counters");
                }
                if (!m_parkedNodeFlags) {
                    checkCuda(cudaMemcpyAsync(m_auditInput, m_input, sizeof(ExtStressGpuImpulse) * m_nodeCount,
                        cudaMemcpyDeviceToDevice, m_stream), "copy audit inputs");
                } else {
                    checkCuda(cudaMemsetAsync(m_auditCounters, 0, sizeof(std::uint32_t) * 10, m_stream), "clear audit counters");
                    auditParkedNativeInputs<<<256, kBlockSize, 0, m_stream>>>(m_input, m_auditInput, m_parkedNodeFlags,
                        m_deviceTopology->components(), m_auditCounters);
                    std::uint32_t h[10] = {};
                    checkCuda(cudaMemcpyAsync(h, m_auditCounters, sizeof(h), cudaMemcpyDeviceToHost, m_stream), "read audit counters");
                    checkCuda(cudaStreamSynchronize(m_stream), "sync audit counters");
                    std::printf("[parked-audit] parked=%u parkedChanged=%u parkedRel6=%u parkedRel3=%u parkedRel1=%u live=%u liveChanged=%u liveRel6=%u liveRel3=%u liveRel1=%u\n",
                        h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8], h[9]);
                }
            }
        }
#endif
        executeSolve(params);
        exportPhysicalImpulses<<<(m_bondCount+kBlockSize-1)/kBlockSize, kBlockSize, 0, m_stream>>>(
            m_impulses, m_colScales, m_devicePhysicalImpulses, m_bondCount,
            m_lengthScale*m_lengthScale*m_massScale, m_lengthScale*m_massScale);
        if (m_deviceTopology) markDeviceStressSolved<<<1,1,0,m_stream>>>(m_deviceTopology->status());
        checkCuda(cudaGetLastError(), "export resident bond forces");
        checkCuda(cudaEventRecord(m_statusReady, m_stream), "record resident stress completion");
#ifdef BLAST_GPU_COMPONENT_WORK_CAPTURE
        m_workCapture->finish(m_stream);
#endif
#ifdef PHYSX_RESIDENT_DESTRUCTION
        // Deferred refactorization: consumers already have the completion event,
        // so the changed components' factors rebuild while the tick continues.
        if (m_direct.enabled && m_direct.deferred && m_deviceTopology) launchNativeDirectFactor();
#endif
        m_hasWarmStart = true;
        return true;
    }

    ExtStressGpuDeviceView deviceView() const override
    {
        return {m_devicePhysicalImpulses, m_status, m_bondCount, m_statusReady,
            m_deviceTopology ? m_deviceTopology->status() : nullptr,
            m_deviceTopology ? m_nodeIsland : nullptr, m_deviceTopology ? m_bondIsland : nullptr, m_input,
#ifdef PHYSX_RESIDENT_DESTRUCTION
            m_deviceTopology ? m_islandSkip : nullptr
#else
            nullptr
#endif
        };
    }

    bool enableDeviceTopology() override
    {
        if (m_deviceTopologyFailed) return false;
        if (m_deviceTopology) return true;
        if (!prepareDeviceSolve()) return false;
        ContextGuard context(m_cudaContext);
        try {
            DeviceStressTopologyBuffers buffers{m_nodeCount,m_bondCount,
                m_node0,m_node1,m_nodeBondBegin,m_nodeBondRef,m_inertia,m_offset0,m_offset1,
                m_colScales,m_health,m_nsJacobi,m_impulses,m_rhs,m_residual,m_projectedDirection,m_nodeIsland,m_bondIsland,
                m_activeNodes,m_activeBonds,m_activeCounts,m_activeFlags,m_islandConverged,m_islandSkip,
                m_selectScratch,m_selectScratchBytes,m_reductionOrder};
#ifdef PHYSX_RESIDENT_DESTRUCTION
            buffers.positions=m_positions;
            prepareNativeDirect();
            buffers.direct=m_direct;
#endif
            m_deviceTopology = new DeviceStressTopology(buffers);
            m_deviceTopology->init(m_stream);
            checkCuda(cudaStreamSynchronize(m_stream), "prepare device-owned stress topology");
            // Sparse minimum-node island IDs need capacity-sized scalar launches.
            // Active lists and deterministic tile counts remain device-sized.
            m_islandCount = m_islandCapacity;
            m_activeBondCount = m_bondCount; m_activeNodeCount = m_nodeCount;
            m_graphParamsDirty = true;
            m_hasWarmStart = false; m_settledBaselineValid = false; m_hostInputValid = false;
#ifdef PHYSX_RESIDENT_DESTRUCTION
            // Factor every initial component now, at the asset/topology boundary,
            // so the first simulated tick does not pay the whole-city burst.
            prefactorNativeDirect();
#endif
            m_jacobiBuilt = true; // topology rebuild maintains it on the device
            checkCuda(cudaEventRecord(m_statusReady,m_stream), "record device topology preparation");
#ifdef BLAST_GPU_COMPONENT_WORK_CAPTURE
            m_workCapture=std::make_unique<ComponentWorkCapture>(m_nodeCount,m_bondCount);
#endif
            return true;
        } catch (...) { m_deviceTopologyFailed=true; return false; }
    }

    bool updateDeviceTopologyAsync(const std::uint32_t* mask, std::uint32_t count,
        const std::uint64_t* generation, const std::uint32_t* accept,
        void* producerReady, void* consumerDone, const float* bondUtilization) override
    {
        if (!m_deviceTopology || m_deviceTopologyFailed || !mask || !generation || count!=m_bondCount) return false;
        ContextGuard context(m_cudaContext);
        if (consumerDone) checkCuda(cudaStreamWaitEvent(m_stream,reinterpret_cast<cudaEvent_t>(consumerDone),0), "wait stress topology consumer");
        if (producerReady) checkCuda(cudaStreamWaitEvent(m_stream,reinterpret_cast<cudaEvent_t>(producerReady),0), "wait stress topology producer");
        m_telemetry = {};
        joinFactorStream();
        m_deviceTopology->submit({mask,generation,accept,bondUtilization},m_stream);
        checkCuda(cudaEventRecord(m_statusReady,m_stream), "record stress topology update");
#ifdef PHYSX_RESIDENT_DESTRUCTION
        // Eager refactorization: the changed components' factors only depend on
        // the topology just committed, so rebuild them now, after the consumers'
        // ready event, and overlap the CPU work that precedes the next solve
        // (fragment registration between the trial and corrected passes, the
        // impact tick's burst in particular). The solve's own factor launch then
        // finds every slot valid. On the factor stream (BLAST_GPU_NATIVE_FACTOR_STREAM=0
        // restores the solver stream) the consumers' status readback, which
        // shares the solver stream, no longer waits behind the burst.
        if (m_direct.enabled && !m_direct.deferred && nativeDirectEager()) {
            if (nativeFactorStream() && m_factorStream) {
                // Deferred to flushEagerFactor(): the consumer decides when the
                // burst may start (after its own readbacks).
                checkCuda(cudaEventRecord(m_topologyReady, m_stream), "record topology ready for factor");
                m_eagerFactorRequested = true;
            } else launchNativeDirectFactor();
        }
#endif
        return true;
    }

    void invalidateDeviceTopology(const std::uint32_t* aliveBonds, const float* aliveHealth, const std::uint64_t* targetGeneration) override
    {
#ifndef PHYSX_RESIDENT_DESTRUCTION
        (void)aliveBonds; (void)aliveHealth; (void)targetGeneration; return;
#else
        if (!m_deviceTopology) return;
        ContextGuard context(m_cudaContext);
        joinFactorStream();
        resetDeviceStressGeneration<<<1,1,0,m_stream>>>(m_deviceTopology->status(), targetGeneration);
        m_deviceTopology->invalidateNativeHierarchy(m_stream);
        if (aliveBonds && m_bondCount)
            restoreDeviceStressHealth<<<(m_bondCount+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(aliveBonds, aliveHealth, m_health, m_bondCount);
        checkCuda(cudaGetLastError(), "reset device stress generation");
#endif
    }

    void debugPrintDeviceTopologyStatus(const char* tag) override
    {
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if (!m_deviceTopology) return;
        ContextGuard context(m_cudaContext);
        checkCuda(cudaStreamSynchronize(m_stream), "debug status sync");
        ExtStressGpuDeviceTopologyStatus t{}; StressHierarchy::Status h{}, m{};
        checkCuda(cudaMemcpy(&t, m_deviceTopology->status(), sizeof(t), cudaMemcpyDeviceToHost), "debug status copy");
        if (m_deviceTopology->nativeHierarchyStatus()) checkCuda(cudaMemcpy(&h, m_deviceTopology->nativeHierarchyStatus(), sizeof(h), cudaMemcpyDeviceToHost), "debug hierarchy copy");
        if (m_deviceTopology->nativeModeStatus()) checkCuda(cudaMemcpy(&m, m_deviceTopology->nativeModeStatus(), sizeof(m), cudaMemcpyDeviceToHost), "debug modes copy");
        std::printf("[stress-status %s] topology gen=%llu init=%u err=%u rebuilds=%llu islands=%u | hierarchy gen=%llu init=%u err=%u builds=%u | modes gen=%llu init=%u err=%u builds=%u\n", tag,
            (unsigned long long)t.generation, t.initialized, t.error, (unsigned long long)t.rebuilds, t.islandCount,
            (unsigned long long)h.generation, h.initialized, h.error, h.builds, (unsigned long long)m.generation, m.initialized, m.error, m.builds);
#else
        (void)tag;
#endif
    }

    void flushEagerFactor() override
    {
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if (!m_eagerFactorRequested || !m_factorStream) return;
        ContextGuard context(m_cudaContext);
        m_eagerFactorRequested = false;
        checkCuda(cudaStreamWaitEvent(m_factorStream, m_topologyReady, 0), "factor stream waits for topology");
        launchNativeDirectFactor(m_factorStream, nativeEagerFactorBlocksPerSm());
        checkCuda(cudaEventRecord(m_factorDone, m_factorStream), "record factor done");
        m_factorPending = true;
#endif
    }
