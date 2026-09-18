// Private Runtime members. Native registration may grow after physics, while
// the completed solver's snapshot/labels remain borrowed by accepted consumers.
// Grow those two lifetimes independently; spare registry rows stay inactive.
    void growNativeNodeStorage(PxU32 required,cudaStream_t stream) {
        if(required<=mPreRegistryCapacity)return;
        const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),
            std::max<PxU64>(required,2ull*mPreRegistryCapacity)));
        PxvPreSolveNode* fresh=nullptr;allocate(fresh,capacity);
        try {
            if(mPreRegistryCapacity)check(cudaMemcpyAsync(fresh,mPreNodes,
                size_t(mPreRegistryCapacity)*sizeof(*fresh),cudaMemcpyDeviceToDevice,stream));
            check(cudaMemsetAsync(fresh+mPreRegistryCapacity,0,
                size_t(capacity-mPreRegistryCapacity)*sizeof(*fresh),stream));
            check(cudaStreamSynchronize(stream));check(cudaFree(mPreNodes));
        }catch(...){cudaFree(fresh);throw;}
        mPreNodes=fresh;mPreRegistryCapacity=capacity;
    }
    void growPreSolveStorage(PxU32 required,cudaStream_t stream) {
        growNativeNodeStorage(required,stream);
        if(required<=mPreCapacity)return;
        const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),
            std::max<PxU64>(required,2ull*mPreCapacity)));
        if(mPrePreviousCount>mPreCapacity || (mPrePreviousCount && !mPrePrevious))
            throw std::runtime_error("invalid resident pre-solve storage extent");
        const auto aligned=[](size_t bytes){return (bytes+127u)&~size_t(127u);};
        const size_t nodeBytes=aligned(size_t(capacity)*sizeof(PxvPreSolveNode));
        const size_t countBytes=aligned(size_t(capacity)*sizeof(PxU32));
        void* fresh=nullptr;check(cudaMalloc(&fresh,nodeBytes+3*countBytes));
        auto* bytes=static_cast<PxU8*>(fresh);
        auto* previous=reinterpret_cast<PxvPreSolveNode*>(bytes);
        try {
            // Only a new solver phase can retire the previous phase storage.
            // Native births use growNativeNodeStorage and cannot move it.
            if(mPrePreviousCount)check(cudaMemcpyAsync(previous,mPrePrevious,
                size_t(mPrePreviousCount)*sizeof(*previous),cudaMemcpyDeviceToDevice,stream));
            check(cudaStreamSynchronize(stream));check(cudaFree(mPreNodeStorage));
        }catch(...){cudaFree(fresh);throw;}
        mPreNodeStorage=fresh;mPrePrevious=previous;
        mPreLabels=reinterpret_cast<PxU32*>(bytes+nodeBytes);
        mPreTouches=reinterpret_cast<PxU32*>(bytes+nodeBytes+countBytes);
        mPreSupport=reinterpret_cast<PxU32*>(bytes+nodeBytes+2*countBytes);
        mPreCapacity=capacity;
    }
