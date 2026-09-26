// Non-virtual native extension. The scene must coordinate collision/mass updates
// separately; this transaction exclusively owns the stress operator geometry.
    const ExtStressGpuDeviceGeometryStatus* geometryStatus()const {
#ifdef PHYSX_RESIDENT_DESTRUCTION
        return m_geometryState?&m_geometryState->status:nullptr;
#else
        return nullptr;
#endif
    }
    bool updateGeometry(const ExtStressGpuGeometryNode* nodes,unsigned nodeCount,
        const ExtStressGpuGeometryBond* bonds,unsigned bondCount,const std::uint64_t* generation,
        const unsigned* accept,void* producerReady,void* consumerDone){
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if(!m_deviceTopology || m_deviceTopologyFailed || !m_geometryState || !nodes || !bonds || !generation
            || nodeCount!=m_nodeCount || bondCount!=m_bondCount)return false;
        try {
        ContextGuard context(m_cudaContext);
        m_geometryActive=true;
        if(consumerDone)checkCuda(cudaStreamWaitEvent(m_stream,reinterpret_cast<cudaEvent_t>(consumerDone),0),"wait geometry consumer");
        if(producerReady)checkCuda(cudaStreamWaitEvent(m_stream,reinterpret_cast<cudaEvent_t>(producerReady),0),"wait geometry producer");
        m_telemetry={};
        const DeviceStressGeometryBuffers b{m_positions,m_inertia,m_offset0,m_offset1,m_normals,m_nodeDistances,
            m_node0,m_node1,m_nodeCount,m_bondCount,m_lengthScale,m_massScale};
        beginStressGeometry<<<1,1,0,m_stream>>>(m_geometryState,generation,accept);
        validateStressGeometryNodes<<<(nodeCount+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(m_geometryState,nodes,b);
        validateStressGeometryBonds<<<(bondCount+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(m_geometryState,nodes,bonds,b);
        chooseStressGeometry<<<1,1,0,m_stream>>>(m_geometryState);
        applyStressGeometryNodes<<<(nodeCount+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(m_geometryState,nodes,b);
        applyStressGeometryBonds<<<(bondCount+kBlockSize-1)/kBlockSize,kBlockSize,0,m_stream>>>(m_geometryState,nodes,bonds,b);
        finishStressGeometry<<<1,1,0,m_stream>>>(m_geometryState,generation);
        auto* topology=m_deviceTopology->status();
        m_deviceTopology->submit({nullptr,&topology->generation,&m_geometryState->status.applied,&m_geometryState->status.applied},m_stream);
        guardStressGeometry<<<1,1,0,m_stream>>>(m_geometryState,topology);
        checkCuda(cudaGetLastError(),"update native stress geometry");
        checkCuda(cudaEventRecord(m_statusReady,m_stream),"record native geometry update");
        return true;
        } catch (...) {
            // A failed enqueue may have submitted a prefix of the transaction.
            // Never permit subsequent solves to consume that uncertain state.
            m_deviceTopologyFailed=true;
            return false;
        }
#else
        (void)nodes;(void)nodeCount;(void)bonds;(void)bondCount;(void)generation;(void)accept;(void)producerReady;(void)consumerDone;
        return false;
#endif
    }
