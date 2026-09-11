originalTransaction=(src/'PxgDestructionTransaction.cuh').read_text();t=originalTransaction
t=t.replace('PxDestructionTopologyTransactionStatus* status, cudaGraphConditionalHandle handle) {','PxDestructionTopologyTransactionStatus* status) {',1)
t=t.replace('    cudaGraphSetConditional(handle,!status->error && status->editCount?1:0);\n','')
t=t.replace('    for(unsigned i=blockIdx.x*blockDim.x+threadIdx.x;i<status->editCount;i+=blockDim.x*gridDim.x) {','    if(status->editCount>batch->capacity || (batch->abort && (*batch->abort & batch->abortMask)))return;\n    for(unsigned i=blockIdx.x*blockDim.x+threadIdx.x;i<status->editCount;i+=blockDim.x*gridDim.x) {',1)
a=t.index('__global__ void chooseRebuild(');b=t.index('__global__ void editTransaction(',a)
t=t[:a]+r'''__global__ void chooseRebuild(const PxDestructionTopologyTransactionStatus* status,
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
'''+t[b:]
a=t.index('__global__ void chooseCommit(');b=t.index('__global__ void finishCommit(',a)
t=t[:a]+r'''__global__ void chooseCommit(const TransactionBatch* batch,
    const PxDestructionTopologyTransactionStatus* status,const cudaGraphDeviceNode_t* nodes,unsigned count) {
    const bool enabled=status->prepared && !status->error && *batch->accept;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)
        if(cudaGraphKernelNodeSetEnabled(nodes[i],enabled)!=cudaSuccess)asm("trap;");
}
'''+t[b:]
t=t.replace('    cudaGraphExec_t mPrepareExec=nullptr,mCommitExec=nullptr;','    cudaGraphExec_t mPrepareExec=nullptr,mCommitExec=nullptr;\n    cudaGraphDeviceNode_t *mPrepareNodes=nullptr,*mCommitNodes=nullptr;\n    unsigned mPrepareNodeCount=0,mCommitNodeCount=0;')
a=t.index('    bool conditional(');b=t.index('    template<class Function>',a)
t=t[:a]+r'''    bool enableBody(cudaGraph_t graph,cudaGraphDeviceNode_t*& deviceNodes,unsigned& count,
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
'''+t[b:]
t=t.replace('        return !count || cudaMemcpyAsync(destination,source,count*sizeof(T),cudaMemcpyDeviceToDevice,mTrial->mStream)==cudaSuccess;',r'''        if(count)transactionCopy<<<unsigned(std::min<size_t>(2560,(count*sizeof(T)+BLOCK-1)/BLOCK)),BLOCK,0,mTrial->mStream>>>(
            reinterpret_cast<unsigned char*>(destination),reinterpret_cast<const unsigned char*>(source),count*sizeof(T));
        return cudaGetLastError()==cudaSuccess;''')
a=t.index('        cudaGraphConditionalHandle work=0,rebuild=0;');b=t.index('        if(!capture(body,',a)
t=t[:a]+r'''        if(cudaGraphCreate(&mPrepareGraph,0)!=cudaSuccess)return false;
        cudaGraph_t body=mPrepareGraph;
        const unsigned blocks=std::min(2560u,(std::max(mAccepted->mN,mAccepted->mM)+BLOCK-1)/BLOCK);
'''+t[b:]
t=t.replace('        return cudaGraphInstantiate(&mPrepareExec,mPrepareGraph,0)==cudaSuccess;',r'''        std::vector<cudaGraphNode_t> roots;
        if(!enableBody(mPrepareGraph,mPrepareNodes,mPrepareNodeCount,roots))return false;
        cudaGraphNode_t previous=nullptr;
        if(!kernel(mPrepareGraph,previous,(void*)beginTransaction,1,1,mBatch,mStatus)
            || !kernel(mPrepareGraph,previous,(void*)validateTransaction,blocks,BLOCK,mBatch,
                mAccepted->mActiveChunks,mAccepted->mActiveBonds,mAccepted->mN,mAccepted->mM,mStatus)
            || !kernel(mPrepareGraph,previous,(void*)chooseRebuild,1,32,mStatus,mPrepareNodes,mPrepareNodeCount)
            || !connectBody(mPrepareGraph,previous,roots))return false;
        return cudaGraphInstantiate(&mPrepareExec,mPrepareGraph,0)==cudaSuccess
            && cudaGraphUpload(mPrepareExec,mStream)==cudaSuccess;''')
a=t.index('        cudaGraphConditionalHandle accept=0;');b=t.index('        if(!capture(body,',a)
t=t[:a]+r'''        if(cudaGraphCreate(&mCommitGraph,0)!=cudaSuccess)return false;
        cudaGraph_t body=mCommitGraph;
'''+t[b:]
t=t.replace('        return cudaGraphInstantiate(&mCommitExec,mCommitGraph,0)==cudaSuccess;',r'''        std::vector<cudaGraphNode_t> roots;
        if(!enableBody(mCommitGraph,mCommitNodes,mCommitNodeCount,roots))return false;
        cudaGraphNode_t previous=nullptr;
        if(!kernel(mCommitGraph,previous,(void*)chooseCommit,1,32,mBatch,mStatus,mCommitNodes,mCommitNodeCount)
            || !connectBody(mCommitGraph,previous,roots))return false;
        return cudaGraphInstantiate(&mCommitExec,mCommitGraph,0)==cudaSuccess
            && cudaGraphUpload(mCommitExec,mStream)==cudaSuccess;''')
t=t.replace('        cudaFree(mBatch);cudaFree(mStatus);','        cudaFree(mBatch);cudaFree(mStatus);cudaFree(mPrepareNodes);cudaFree(mCommitNodes);')
assert 'cudaGraphConditionalHandle' not in t
(out/'PxgDestructionTransaction.cuh').write_text(t)
(out/'transaction.patch').write_text(''.join(difflib.unified_diff(originalTransaction.splitlines(True),t.splitlines(True),fromfile='production/PxgDestructionTransaction.cuh',tofile='candidate/PxgDestructionTransaction.cuh')))
