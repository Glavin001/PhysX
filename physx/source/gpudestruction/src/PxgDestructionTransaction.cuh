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
    PxDestructionTopologyTransactionStatus* status, cudaGraphConditionalHandle handle) {
    status->prepared=0;status->error=0;status->changed=0;
    status->editCount=*batch->count;
    if(status->editCount>batch->capacity)status->error|=2u;
    if(batch->abort && (*batch->abort & batch->abortMask))status->error|=4u;
    cudaGraphSetConditional(handle,!status->error && status->editCount?1:0);
}
__global__ void validateTransaction(const TransactionBatch* batch,
    const unsigned* activeChunks, const unsigned* activeBonds, unsigned n, unsigned m,
    PxDestructionTopologyTransactionStatus* status) {
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
    cudaGraphConditionalHandle handle) {
    cudaGraphSetConditional(handle,!status->error && status->changed?1:0);
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
    const PxDestructionTopologyTransactionStatus* status,cudaGraphConditionalHandle handle) {
    cudaGraphSetConditional(handle,status->prepared && !status->error && *batch->accept?1:0);
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

    template<class... Args> bool kernel(cudaGraph_t graph,cudaGraphNode_t& previous,
        void* function,unsigned grid,unsigned block,Args... args) {
        void* values[]={&args...};
        cudaKernelNodeParams parameters{};parameters.func=function;
        parameters.gridDim=dim3(grid);parameters.blockDim=dim3(block);parameters.kernelParams=values;
        cudaGraphNode_t next=nullptr;
        if(cudaGraphAddKernelNode(&next,graph,previous?&previous:nullptr,previous?1:0,&parameters)!=cudaSuccess)return false;
        previous=next;return true;
    }
    bool conditional(cudaGraph_t graph,cudaGraphNode_t& previous,
        cudaGraphConditionalHandle handle,cudaGraph_t& body) {
        cudaGraphNodeParams parameters{};parameters.type=cudaGraphNodeTypeConditional;
        parameters.conditional.handle=handle;parameters.conditional.type=cudaGraphCondTypeIf;parameters.conditional.size=1;
        cudaGraphNode_t next=nullptr;
        if(cudaGraphAddNode(&next,graph,previous?&previous:nullptr,nullptr,previous?1:0,&parameters)!=cudaSuccess)return false;
        previous=next;body=parameters.conditional.phGraph_out[0];return true;
    }
    template<class Function> bool capture(cudaGraph_t graph,Function function) {
        if(cudaStreamBeginCaptureToGraph(mTrial->mStream,graph,nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal)!=cudaSuccess)return false;
        const bool ok=function();cudaGraph_t captured=nullptr;
        const auto ended=cudaStreamEndCapture(mTrial->mStream,&captured);
        return ok && ended==cudaSuccess;
    }
    template<class T> bool copy(T* destination,const T* source,size_t count) {
        return !count || cudaMemcpyAsync(destination,source,count*sizeof(T),cudaMemcpyDeviceToDevice,mTrial->mStream)==cudaSuccess;
    }
    bool buildPrepare() {
        cudaGraphConditionalHandle work=0,rebuild=0;
        if(cudaGraphCreate(&mPrepareGraph,0)!=cudaSuccess
            || cudaGraphConditionalHandleCreate(&work,mPrepareGraph,0,cudaGraphCondAssignDefault)!=cudaSuccess
            || cudaGraphConditionalHandleCreate(&rebuild,mPrepareGraph,0,cudaGraphCondAssignDefault)!=cudaSuccess)return false;
        cudaGraphNode_t previous=nullptr;cudaGraph_t validation=nullptr,body=nullptr;
        if(!kernel(mPrepareGraph,previous,(void*)beginTransaction,1,1,mBatch,mStatus,work)
            || !conditional(mPrepareGraph,previous,work,validation))return false;
        previous=nullptr;
        const unsigned blocks=std::min(2560u,(std::max(mAccepted->mN,mAccepted->mM)+BLOCK-1)/BLOCK);
        if(!kernel(validation,previous,(void*)validateTransaction,blocks,BLOCK,mBatch,
            mAccepted->mActiveChunks,mAccepted->mActiveBonds,mAccepted->mN,mAccepted->mM,mStatus)
            || !kernel(validation,previous,(void*)chooseRebuild,1,1,mStatus,rebuild)
            || !conditional(validation,previous,rebuild,body))return false;
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
        return cudaGraphInstantiate(&mPrepareExec,mPrepareGraph,0)==cudaSuccess;
    }
    bool buildCommit() {
        cudaGraphConditionalHandle accept=0;
        if(cudaGraphCreate(&mCommitGraph,0)!=cudaSuccess
            || cudaGraphConditionalHandleCreate(&accept,mCommitGraph,0,cudaGraphCondAssignDefault)!=cudaSuccess)return false;
        cudaGraphNode_t previous=nullptr;cudaGraph_t body=nullptr;
        if(!kernel(mCommitGraph,previous,(void*)chooseCommit,1,1,mBatch,mStatus,accept)
            || !conditional(mCommitGraph,previous,accept,body))return false;
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
        return cudaGraphInstantiate(&mCommitExec,mCommitGraph,0)==cudaSuccess;
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
        cudaFree(mBatch);cudaFree(mStatus);
        if(mReady)cudaEventDestroy(mReady);if(mStream)cudaStreamDestroy(mStream);
    }
};
