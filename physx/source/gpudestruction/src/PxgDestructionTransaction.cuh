// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included inside the topology implementation namespace.
struct TransactionBatch {
    const PxgDestructionEdit* edits;
    const unsigned* count;
    const unsigned* abort;
    const unsigned* accept;
    const PxgDestructionClusterMotion* sourceMotion;
    unsigned capacity, abortMask;
};
__global__ void setTransactionBatch(TransactionBatch* out, TransactionBatch batch) {*out=batch;}
__global__ void setTransactionAccept(TransactionBatch* out, const unsigned* accept) {out->accept=accept;}
__global__ void beginTransaction(const TransactionBatch* batch,
    PxDestructionTopologyTransactionStatus* status) {
    status->prepared=0;status->error=0;status->changed=0;
    status->editCount=*batch->count;
    if(status->editCount>batch->capacity)status->error|=2u;
    if(batch->abort && (*batch->abort & batch->abortMask))status->error|=4u;
}
__global__ void validateTransaction(const TransactionBatch* batch,
    const unsigned* activeChunks, const unsigned* activeBonds, unsigned n, unsigned m,
    PxDestructionTopologyTransactionStatus* status) {
    if(status->editCount>batch->capacity || (batch->abort && (*batch->abort & batch->abortMask)))return;
    for(unsigned i=blockIdx.x*blockDim.x+threadIdx.x;i<status->editCount;i+=blockDim.x*gridDim.x) {
        const auto e=batch->edits[i];
        if(e.kind==PxgDestructionEditKind::BreakBond && e.index<m) {
            if(activeBonds[e.index])atomicExch(&status->changed,1u);
        }else if(e.kind==PxgDestructionEditKind::DestroyChunk && e.index<n) {
            if(activeChunks[e.index])atomicExch(&status->changed,1u);
        }else atomicOr(&status->error,1u);
    }
}
__global__ void chooseRebuild(const PxDestructionTopologyTransactionStatus* status,
    const cudaGraphDeviceNode_t* nodes,unsigned count) {
    const bool enabled=!status->error && status->changed;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)
        if(cudaGraphKernelNodeSetEnabled(nodes[i],enabled)!=cudaSuccess)asm("trap;");
}
__global__ void transactionFill(unsigned char* destination,size_t width,size_t height,size_t pitch,unsigned value,unsigned elementSize) {
    const size_t rowBytes=width*elementSize;
    for(size_t i=size_t(blockIdx.x)*blockDim.x+threadIdx.x;i<rowBytes*height;i+=size_t(blockDim.x)*gridDim.x)
        destination[(i/rowBytes)*pitch+i%rowBytes]=static_cast<unsigned char>(value>>(8*(i%elementSize)));
}
__global__ void transactionCopy(unsigned char* destination,const unsigned char* source,size_t bytes) {
    for(size_t i=size_t(blockIdx.x)*blockDim.x+threadIdx.x;i<bytes;i+=size_t(blockDim.x)*gridDim.x)
        destination[i]=source[i];
}
__global__ void editTransaction(const TransactionBatch* batch,
    const PxDestructionTopologyTransactionStatus* status, unsigned* chunks,unsigned* bonds) {
    for(unsigned i=blockIdx.x*blockDim.x+threadIdx.x;i<status->editCount;i+=blockDim.x*gridDim.x) {
        const auto e=batch->edits[i];
        atomicExch((e.kind==PxgDestructionEditKind::BreakBond?bonds:chunks)+e.index,0u);
    }
}
__global__ void startCandidate(const PxgDestructionTopologyStatus* accepted, PxgDestructionTopologyStatus* trial) {
    *trial={accepted->generation,0,0,1};
}
__global__ void finishCandidate(PxDestructionTopologyTransactionStatus* status,const PxgDestructionTopologyStatus* trial) {
    if(trial->slotError)status->error|=8u;
    status->prepared=!status->error;++status->rebuilds;
}
__global__ void chooseCommit(const TransactionBatch* batch,
    const PxDestructionTopologyTransactionStatus* status,const cudaGraphDeviceNode_t* nodes,unsigned count) {
    const bool enabled=status->prepared && !status->error && *batch->accept;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)
        if(cudaGraphKernelNodeSetEnabled(nodes[i],enabled)!=cudaSuccess)asm("trap;");
}
__global__ void finishCommit(PxDestructionTopologyTransactionStatus* status,
    unsigned* acceptedRoots, const unsigned* trialRoots,
    PxgDestructionClusterMotion* acceptedMotion, const PxgDestructionClusterMotion* trialMotion,
    const unsigned* trialSlots, const PxgDestructionTopologyStatus* topology) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    // CUB produces only clusterCount roots; only occupied motion slots have
    // defined values. Copy these valid entries on device rather than transferring
    // uninitialized unused capacity. Root order and slot generations are unchanged.
    for(unsigned c=i;c<topology->clusterCount;c+=blockDim.x*gridDim.x) {
        const unsigned root=trialRoots[c],slot=trialSlots[root];
        acceptedRoots[c]=root;acceptedMotion[slot]=trialMotion[slot];
    }
    // Consumers wait on the transaction event, after all threads finish.
    if(!i){status->prepared=0;++status->commits;}
}
__global__ void discardTransaction(PxDestructionTopologyTransactionStatus* status) {
    status->prepared=status->error=status->changed=status->editCount=0;
}

class Transaction final : public PxgDestructionTopologyTransaction {
    Topology* mAccepted=nullptr;
    Topology* mTrial=nullptr;
    TransactionBatch* mBatch=nullptr;
    PxDestructionTopologyTransactionStatus* mStatus=nullptr;
    cudaStream_t mStream=nullptr;
    cudaEvent_t mReady=nullptr;
    cudaGraph_t mPrepareGraph=nullptr,mCommitGraph=nullptr;
    cudaGraphExec_t mPrepareExec=nullptr,mCommitExec=nullptr;
    cudaGraphDeviceNode_t *mPrepareNodes=nullptr,*mCommitNodes=nullptr;
    unsigned mPrepareNodeCount=0,mCommitNodeCount=0;

    template<class... Args> bool kernel(cudaGraph_t graph,cudaGraphNode_t& previous,
        void* function,unsigned grid,unsigned block,Args... args) {
        void* values[]={&args...};
        cudaKernelNodeParams parameters{};parameters.func=function;
        parameters.gridDim=dim3(grid);parameters.blockDim=dim3(block);parameters.kernelParams=values;
        cudaGraphNode_t next=nullptr;
        if(cudaGraphAddKernelNode(&next,graph,previous?&previous:nullptr,previous?1:0,&parameters)!=cudaSuccess)return false;
        previous=next;return true;
    }
    bool enableBody(cudaGraph_t graph,cudaGraphDeviceNode_t*& deviceNodes,unsigned& count,
        std::vector<cudaGraphNode_t>& roots) {
        size_t n=0;if(cudaGraphGetNodes(graph,nullptr,&n)!=cudaSuccess)return false;
        std::vector<cudaGraphNode_t> nodes(n);
        if(cudaGraphGetNodes(graph,nodes.data(),&n)!=cudaSuccess)return false;
        std::vector<cudaGraphDeviceNode_t> handles;handles.reserve(n);
        for(auto node:nodes) {
            cudaGraphNodeType type;if(cudaGraphNodeGetType(node,&type)!=cudaSuccess)return false;
            if(type==cudaGraphNodeTypeMemset) {
                cudaMemsetParams fill{};
                if(cudaGraphMemsetNodeGetParams(node,&fill)!=cudaSuccess)return false;
                if(fill.elementSize!=1 && fill.elementSize!=2 && fill.elementSize!=4)return false;
                size_t dependenciesCount=0,dependentsCount=0;
                if(cudaGraphNodeGetDependencies(node,nullptr,nullptr,&dependenciesCount)!=cudaSuccess
                    || cudaGraphNodeGetDependentNodes(node,nullptr,nullptr,&dependentsCount)!=cudaSuccess)return false;
                std::vector<cudaGraphNode_t> dependencies(dependenciesCount),dependents(dependentsCount);
                if(cudaGraphNodeGetDependencies(node,dependencies.data(),nullptr,&dependenciesCount)!=cudaSuccess
                    || cudaGraphNodeGetDependentNodes(node,dependents.data(),nullptr,&dependentsCount)!=cudaSuccess)return false;
                cudaKernelNodeParams params{};params.func=(void*)transactionFill;params.blockDim=dim3(BLOCK);
                params.gridDim=dim3(unsigned(std::min<size_t>(2560,(fill.width*fill.height*fill.elementSize+BLOCK-1)/BLOCK)));
                size_t pitch=fill.height==1?fill.width*fill.elementSize:fill.pitch;
                void* args[]={&fill.dst,&fill.width,&fill.height,&pitch,&fill.value,&fill.elementSize};params.kernelParams=args;
                cudaGraphNode_t replacement=nullptr;
                if(cudaGraphAddKernelNode(&replacement,graph,dependencies.data(),dependencies.size(),&params)!=cudaSuccess)return false;
                for(auto dependent:dependents)
                    if(cudaGraphAddDependencies(graph,&replacement,&dependent,nullptr,1)!=cudaSuccess)return false;
                if(cudaGraphDestroyNode(node)!=cudaSuccess)return false;
                node=replacement;type=cudaGraphNodeTypeKernel;
            }
            if(type!=cudaGraphNodeTypeKernel){fprintf(stderr,"Unsupported transaction graph node %d\n",int(type));return false;}
            cudaKernelNodeAttrValue attr{};attr.deviceUpdatableKernelNode.deviceUpdatable=1;
            if(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeDeviceUpdatableKernelNode,&attr)!=cudaSuccess
                || cudaGraphKernelNodeGetAttribute(node,cudaKernelNodeAttributeDeviceUpdatableKernelNode,&attr)!=cudaSuccess)return false;
            handles.push_back(attr.deviceUpdatableKernelNode.devNode);
        }
        count=unsigned(n);
        if(cudaMalloc(&deviceNodes,n*sizeof(cudaGraphDeviceNode_t))!=cudaSuccess
            || cudaMemcpy(deviceNodes,handles.data(),n*sizeof(cudaGraphDeviceNode_t),cudaMemcpyHostToDevice)!=cudaSuccess)return false;
        size_t r=0;if(cudaGraphGetRootNodes(graph,nullptr,&r)!=cudaSuccess)return false;
        roots.resize(r);return cudaGraphGetRootNodes(graph,roots.data(),&r)==cudaSuccess;
    }
    bool connectBody(cudaGraph_t graph,cudaGraphNode_t selector,const std::vector<cudaGraphNode_t>& roots) {
        for(auto root:roots)if(cudaGraphAddDependencies(graph,&selector,&root,nullptr,1)!=cudaSuccess)return false;
        return true;
    }
    template<class Function> bool capture(cudaGraph_t graph,Function function) {
        if(cudaStreamBeginCaptureToGraph(mTrial->mStream,graph,nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal)!=cudaSuccess)return false;
        const bool ok=function();cudaGraph_t captured=nullptr;
        const auto ended=cudaStreamEndCapture(mTrial->mStream,&captured);
        return ok && ended==cudaSuccess;
    }
    template<class T> bool copy(T* destination,const T* source,size_t count) {
        if(count)transactionCopy<<<unsigned(std::min<size_t>(2560,(count*sizeof(T)+BLOCK-1)/BLOCK)),BLOCK,0,mTrial->mStream>>>(
            reinterpret_cast<unsigned char*>(destination),reinterpret_cast<const unsigned char*>(source),count*sizeof(T));
        return cudaGetLastError()==cudaSuccess;
    }
    bool buildPrepare() {
        if(cudaGraphCreate(&mPrepareGraph,0)!=cudaSuccess)return false;
        cudaGraph_t body=mPrepareGraph;
        const unsigned blocks=std::min(2560u,(std::max(mAccepted->mN,mAccepted->mM)+BLOCK-1)/BLOCK);
        if(!capture(body,[&] {
            const unsigned n=mTrial->mN,m=mTrial->mM;
            if(!copy(mTrial->mActiveChunks,mAccepted->mActiveChunks,n)
                || !copy(mTrial->mActiveBonds,mAccepted->mActiveBonds,m)
                || !copy(mTrial->mPreviousLabels,mAccepted->mLabels,n)
                || !copy(mTrial->mClusterSlots,mAccepted->mClusterSlots,n)
                || !copy(mTrial->mSlotRoots,mAccepted->mSlotRoots,n)
                || !copy(mTrial->mSlotGenerations,mAccepted->mSlotGenerations,n))return false;
            captureClusterMotion<<<(n+BLOCK-1)/BLOCK,BLOCK,0,mTrial->mStream>>>(mAccepted->mRoots,mAccepted->mClusterSlots,mAccepted->mClusters,
                mAccepted->mMotions,mTrial->mPreviousMotions,mTrial->mPreviousCenters,mTrial->mPreviousSlots,mAccepted->mStatus,&mBatch->sourceMotion);
            startCandidate<<<1,1,0,mTrial->mStream>>>(mAccepted->mStatus,mTrial->mStatus);
            editTransaction<<<blocks,BLOCK,0,mTrial->mStream>>>(mBatch,mStatus,mTrial->mActiveChunks,mTrial->mActiveBonds);
            if(!mTrial->rebuild(true,false))return false;
            finishCandidate<<<1,1,0,mTrial->mStream>>>(mStatus,mTrial->mStatus);
            return cudaGetLastError()==cudaSuccess;
        }))return false;
        std::vector<cudaGraphNode_t> roots;
        if(!enableBody(mPrepareGraph,mPrepareNodes,mPrepareNodeCount,roots))return false;
        cudaGraphNode_t previous=nullptr;
        if(!kernel(mPrepareGraph,previous,(void*)beginTransaction,1,1,mBatch,mStatus)
            || !kernel(mPrepareGraph,previous,(void*)validateTransaction,blocks,BLOCK,mBatch,
                mAccepted->mActiveChunks,mAccepted->mActiveBonds,mAccepted->mN,mAccepted->mM,mStatus)
            || !kernel(mPrepareGraph,previous,(void*)chooseRebuild,1,32,mStatus,mPrepareNodes,mPrepareNodeCount)
            || !connectBody(mPrepareGraph,previous,roots))return false;
        return cudaGraphInstantiate(&mPrepareExec,mPrepareGraph,0)==cudaSuccess
            && cudaGraphUpload(mPrepareExec,mStream)==cudaSuccess;
    }
    bool buildCommit() {
        if(cudaGraphCreate(&mCommitGraph,0)!=cudaSuccess)return false;
        cudaGraph_t body=mCommitGraph;
        if(!capture(body,[&] {
            const unsigned n=mAccepted->mN,m=mAccepted->mM;
            if(!copy(mAccepted->mActiveChunks,mTrial->mActiveChunks,n)
                || !copy(mAccepted->mActiveBonds,mTrial->mActiveBonds,m)
                || !copy(mAccepted->mLabels,mTrial->mLabels,n)
                || !copy(mAccepted->mOrder,mTrial->mOrder,n)
                || !copy(mAccepted->mClusters,mTrial->mClusters,n)
                || !copy(mAccepted->mClusterSlots,mTrial->mClusterSlots,n)
                || !copy(mAccepted->mSlotRoots,mTrial->mSlotRoots,n)
                || !copy(mAccepted->mSlotGenerations,mTrial->mSlotGenerations,n)
                || !copy(mAccepted->mStatus,mTrial->mStatus,1))return false;
            finishCommit<<<std::min((n+BLOCK-1)/BLOCK,128u),BLOCK,0,mTrial->mStream>>>(mStatus,
                mAccepted->mRoots,mTrial->mRoots,mAccepted->mMotions,mTrial->mMotions,
                mTrial->mClusterSlots,mTrial->mStatus);
            return cudaGetLastError()==cudaSuccess;
        }))return false;
        std::vector<cudaGraphNode_t> roots;
        if(!enableBody(mCommitGraph,mCommitNodes,mCommitNodeCount,roots))return false;
        cudaGraphNode_t previous=nullptr;
        if(!kernel(mCommitGraph,previous,(void*)chooseCommit,1,32,mBatch,mStatus,mCommitNodes,mCommitNodeCount)
            || !connectBody(mCommitGraph,previous,roots))return false;
        return cudaGraphInstantiate(&mCommitExec,mCommitGraph,0)==cudaSuccess
            && cudaGraphUpload(mCommitExec,mStream)==cudaSuccess;
    }
    bool order(void* ready,void* done) {
        return (!ready || cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(ready),0)==cudaSuccess)
            && (!done || cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(done),0)==cudaSuccess);
    }
    bool signal() {return cudaGetLastError()==cudaSuccess && cudaEventRecord(mReady,mStream)==cudaSuccess;}
public:
    explicit Transaction(Topology* accepted):mAccepted(accepted){}
    bool init(const PxgDestructionChunk* chunks,unsigned n,const PxgDestructionBond* bonds,unsigned m) {
        mTrial=new(std::nothrow) Topology;
        if(!mTrial || !mTrial->init(chunks,n,bonds,m,mAccepted))return false;
        if(cudaStreamCreateWithFlags(&mStream,cudaStreamNonBlocking)!=cudaSuccess
            || cudaEventCreateWithFlags(&mReady,cudaEventDisableTiming)!=cudaSuccess
            || cudaMalloc(&mBatch,sizeof(*mBatch))!=cudaSuccess
            || cudaMalloc(&mStatus,sizeof(*mStatus))!=cudaSuccess
            || cudaMemset(mStatus,0,sizeof(*mStatus))!=cudaSuccess)return false;
        return buildPrepare() && buildCommit() && signal();
    }
    bool prepare(const PxgDestructionEdit* edits,const unsigned* count,unsigned capacity,
        const unsigned* abort,unsigned abortMask,void* ready,void* done,const PxgDestructionClusterMotion* sourceMotion) override {
        if(!count || (capacity && !edits) || capacity>unsigned(std::numeric_limits<int>::max()) || !order(ready,done))return false;
        const TransactionBatch batch={edits,count,abort,nullptr,sourceMotion,capacity,abortMask};
        setTransactionBatch<<<1,1,0,mStream>>>(mBatch,batch);
        return cudaGraphLaunch(mPrepareExec,mStream)==cudaSuccess && signal();
    }
    bool commit(const unsigned* accept,void* ready,void* done) override {
        if(!accept || !order(ready,done))return false;
        setTransactionAccept<<<1,1,0,mStream>>>(mBatch,accept);
        return cudaGraphLaunch(mCommitExec,mStream)==cudaSuccess && signal();
    }
    bool discard(void* ready,void* done) override {
        if(!order(ready,done))return false;
        discardTransaction<<<1,1,0,mStream>>>(mStatus);return signal();
    }
    PxgDestructionTopologyView accepted() const override {auto v=mAccepted->view();v.readyEvent=mReady;return v;}
    PxgDestructionTopologyView trial() const override {auto v=mTrial->view();v.readyEvent=mReady;return v;}
    const PxDestructionTopologyTransactionStatus* status() const override {return mStatus;}
    void release() override {delete this;}
    ~Transaction() override {
        if(mStream)cudaStreamSynchronize(mStream);
        if(mPrepareExec)cudaGraphExecDestroy(mPrepareExec);if(mCommitExec)cudaGraphExecDestroy(mCommitExec);
        if(mPrepareGraph)cudaGraphDestroy(mPrepareGraph);if(mCommitGraph)cudaGraphDestroy(mCommitGraph);
        if(mTrial)mTrial->release();if(mAccepted)mAccepted->release();
        cudaFree(mBatch);cudaFree(mStatus);cudaFree(mPrepareNodes);cudaFree(mCommitNodes);
        if(mReady)cudaEventDestroy(mReady);if(mStream)cudaStreamDestroy(mStream);
    }
};
