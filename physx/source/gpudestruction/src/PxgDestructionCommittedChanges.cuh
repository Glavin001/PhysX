// GPU-owned publication of committed topology changes. Included in runtime's
// private namespace; no independent simulation or CPU topology reconstruction.
namespace committedChanges {
__global__ void reset(unsigned char* chunks,unsigned char* bonds,PxU32 n,PxU32 m,
    PxDestructionTopologyDeviceView topology,const PxDestructionStageStatus* stage) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<n)chunks[i]=stage->frame==1;
    if(i<m)bonds[i]=stage->frame==1 && !topology.activeBonds[i];
}
__global__ void record(unsigned char* chunks,unsigned char* bonds,
    PxDestructionTopologyDeviceView before,PxDestructionTopologyDeviceView after,
    const PxDestructionTopologyTransactionStatus* transaction,const PxU32* accept,
    const PxDestructionStressChunk* inputs,const PxU32* affected) {
    if(!*accept || !transaction->prepared || transaction->error)return;
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    // This is the existing collision producer's source-cluster set. Mark ALL
    // source members before accepted ownership changes, not just migrants.
    // Unique row writers union both passes without atomic lists or duplicates.
    if(i<before.chunkCount && affected[inputs[i].cluster])chunks[i]=1;
    if(i<before.bondCount && before.activeBonds[i] && !after.activeBonds[i])bonds[i]=1;
}
__global__ void begin(PxDestructionCommittedChangesStatus* out,
    const PxDestructionStageStatus* stage,PxDestructionTopologyDeviceView topology,
    const ExtStressGpuDeviceTopologyStatus* stress,cudaGraphConditionalHandle work) {
    *out={stage->frame,topology.status->generation,0,0,topology.status->clusterCount,
        stress?stress->islandCount:0,stage->error,PxU32(stage->frame==1)};
    cudaGraphSetConditional(work,!stage->error && (stage->frame==1 || stage->brokenBonds || stage->crushedChunks));
}
__global__ void pack(const PxU32* indices,PxDestructionChangedChunk* rows,
    PxDestructionCommittedChangesStatus* out,PxDestructionTopologyDeviceView topology) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=out->chunkCount)return;
    const PxU32 chunk=indices[i],active=topology.activeChunks[chunk];
    const PxU32 root=active?topology.chunkCluster[chunk]:~PxU32(0);
    if(active && (root>=topology.chunkCount || topology.clusterSlots[root]>=topology.slotCapacity)) {
        atomicOr(&out->error,32u);return;
    }
    const PxU32 slot=active?topology.clusterSlots[root]:~PxU32(0);
    rows[i]={active?topology.slotGenerations[slot]:0,chunk,root,slot,active};
}
class Publication {
    unsigned char *mChunks=nullptr,*mBonds=nullptr;
    PxU32* mIndices=nullptr;
    PxDestructionChangedChunk* mRows=nullptr;
    PxU32* mBroken=nullptr;
    PxDestructionCommittedChangesStatus* mStatus=nullptr;
    void* mScratch=nullptr;size_t mBytes=0;
    cudaGraph_t mGraph=nullptr;cudaGraphExec_t mExec=nullptr;
    PxU32 mN=0,mM=0;
public:
    void clear() {
        if(mExec)cudaGraphExecDestroy(mExec);if(mGraph)cudaGraphDestroy(mGraph);
        cudaFree(mChunks);cudaFree(mBonds);cudaFree(mIndices);cudaFree(mRows);cudaFree(mBroken);cudaFree(mStatus);cudaFree(mScratch);
        mChunks=mBonds=nullptr;mIndices=mBroken=nullptr;mRows=nullptr;mStatus=nullptr;mScratch=nullptr;
        mGraph=nullptr;mExec=nullptr;mN=mM=0;mBytes=0;
    }
    void initialize(PxDestructionTopologyDeviceView topology,
        const PxDestructionStageStatus* stage,const ExtStressGpuDeviceTopologyStatus* stress,cudaStream_t stream) {
        mN=topology.chunkCount;mM=topology.bondCount;
        if(mN>unsigned(INT_MAX) || mM>unsigned(INT_MAX))throw std::runtime_error("destruction publication capacity exceeds CUDA selection limit");
        allocate(mChunks,mN);allocate(mBonds,mM);allocate(mIndices,mN);allocate(mRows,mN);allocate(mBroken,mM);allocate(mStatus,1);
        check(cudaMemsetAsync(mStatus,0,sizeof(*mStatus),stream));
        thrust::counting_iterator<PxU32> ids(0);size_t chunkBytes=0,bondBytes=0;
        check(cub::DeviceSelect::Flagged(nullptr,chunkBytes,ids,mChunks,mIndices,&mStatus->chunkCount,mN,stream));
        if(mM)check(cub::DeviceSelect::Flagged(nullptr,bondBytes,ids,mBonds,mBroken,&mStatus->bondCount,mM,stream));
        mBytes=std::max(chunkBytes,bondBytes);check(cudaMalloc(&mScratch,std::max(size_t(1),mBytes)));
        check(cudaGraphCreate(&mGraph,0));cudaGraphConditionalHandle work=0;
        check(cudaGraphConditionalHandleCreate(&work,mGraph,0,cudaGraphCondAssignDefault));
        void* values[]={&mStatus,&stage,&topology,&stress,&work};cudaKernelNodeParams kernel{};
        kernel.func=(void*)begin;kernel.gridDim=dim3(1);kernel.blockDim=dim3(1);kernel.kernelParams=values;
        cudaGraphNode_t start=nullptr;check(cudaGraphAddKernelNode(&start,mGraph,nullptr,0,&kernel));
        cudaGraphNodeParams conditional{};conditional.type=cudaGraphNodeTypeConditional;
        conditional.conditional.handle=work;conditional.conditional.type=cudaGraphCondTypeIf;conditional.conditional.size=1;
        cudaGraphNode_t node=nullptr;check(cudaGraphAddNode(&node,mGraph,&start,nullptr,1,&conditional));
        const auto body=conditional.conditional.phGraph_out[0];
        check(cudaStreamBeginCaptureToGraph(stream,body,nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal));
        check(cub::DeviceSelect::Flagged(mScratch,mBytes,ids,mChunks,mIndices,&mStatus->chunkCount,mN,stream));
        if(mM)check(cub::DeviceSelect::Flagged(mScratch,mBytes,ids,mBonds,mBroken,&mStatus->bondCount,mM,stream));
        pack<<<(mN+127)/128,128,0,stream>>>(mIndices,mRows,mStatus,topology);
        cudaGraph_t captured=nullptr;check(cudaStreamEndCapture(stream,&captured));
        check(cudaGraphInstantiate(&mExec,mGraph,0));
    }
    void start(PxDestructionTopologyDeviceView topology,const PxDestructionStageStatus* stage,cudaStream_t stream) {
        reset<<<(std::max(mN,mM)+127)/128,128,0,stream>>>(mChunks,mBonds,mN,mM,topology,stage);
    }
    void commit(PxDestructionTopologyDeviceView before,PxDestructionTopologyDeviceView after,
        const PxDestructionTopologyTransactionStatus* transaction,const PxU32* accept,
        const PxDestructionStressChunk* chunks,const PxU32* affected,cudaStream_t stream) {
        record<<<(std::max(mN,mM)+127)/128,128,0,stream>>>(mChunks,mBonds,before,after,transaction,accept,chunks,affected);
    }
    void publish(cudaStream_t stream){check(cudaGraphLaunch(mExec,stream));}
    PxDestructionCommittedChangesView view()const{return {mRows,mBroken,mStatus,mN,mM};}
};
}
