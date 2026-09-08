// Private Runtime member definition. Growth is exceptional resource management;
// the node roster and lifetime history remain device-owned across allocation.
// Output-only label/count arrays share the allocation but need no old contents.
    void growPreSolveStorage(PxU32 required,cudaStream_t stream) {
        if(required<=mPreCapacity)return;
        const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),
            std::max<PxU64>(required,2ull*mPreCapacity)));
        if(mPrePreviousCount>mPreCapacity || (mPrePreviousCount && (!mPreNodes || !mPrePrevious)))
            throw std::runtime_error("invalid resident pre-solve storage extent");
        const auto aligned=[](size_t bytes){return (bytes+127u)&~size_t(127u);};
        const size_t nodeBytes=aligned(size_t(capacity)*sizeof(PxvPreSolveNode));
        const size_t countBytes=aligned(size_t(capacity)*sizeof(PxU32));
        void* fresh=nullptr;check(cudaMalloc(&fresh,2*nodeBytes+3*countBytes));
        auto* bytes=static_cast<PxU8*>(fresh);
        auto* nodes=reinterpret_cast<PxvPreSolveNode*>(bytes);
        auto* previous=reinterpret_cast<PxvPreSolveNode*>(bytes+nodeBytes);
        try {
            // The caller ordered this stream after mPreReady and mGraphReady.
            // Keep all old handles, including inactive holes and lifetimes.
            if(mPrePreviousCount) {
                const size_t liveBytes=size_t(mPrePreviousCount)*sizeof(PxvPreSolveNode);
                check(cudaMemcpyAsync(nodes,mPreNodes,liveBytes,cudaMemcpyDeviceToDevice,stream));
                check(cudaMemcpyAsync(previous,mPrePrevious,liveBytes,cudaMemcpyDeviceToDevice,stream));
            }
            // Complete the storage move before releasing its source. This wait
            // occurs only on growth, is included in step timing, and makes no
            // simulation or connectivity decision on the host.
            check(cudaStreamSynchronize(stream));
            check(cudaFree(mPreNodeStorage));
        } catch(...) {cudaFree(fresh);throw;}
        mPreNodeStorage=fresh;mPreNodes=nodes;mPrePrevious=previous;
        mPreLabels=reinterpret_cast<PxU32*>(bytes+2*nodeBytes);
        mPreTouches=reinterpret_cast<PxU32*>(bytes+2*nodeBytes+countBytes);
        mPreSupport=reinterpret_cast<PxU32*>(bytes+2*nodeBytes+2*countBytes);
        mPreCapacity=capacity;
    }
