// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the runtime implementation namespace. Addresses are a CPU resource
// grant; request counts, stable selection and assignment belong to the GPU.
// Reverse address ownership is produced only when the resource grant/storage
// grows. Ordinary allocation reads it; spare addresses are not simulated bodies.
struct NativeMotionAddresses {
    const PxU32* indices;PxU32 capacity;PxgDestructionMotionStorage storage;
    PxU32* ordinals;PxU32* error;
    PxvPreSolveNode* nodes;PxU32 nodeCapacity;
};
__global__ void registerNativeMotionAddresses(NativeMotionAddresses v) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=v.capacity)return;
    if(!v.indices || !v.ordinals){atomicOr(v.error,16u);return;}
    const PxU32 id=v.indices[i];
    if(id>=v.storage.capacity){atomicOr(v.error,16u);return;}
    if(atomicCAS(v.ordinals+id,~PxU32(0),i)!=~PxU32(0))atomicOr(v.error,4u);
}
struct NativeNodeBirthTransaction {
    PxU64 generation;PxU32 first,count,initialize;
};
// Preserve device-created nodes when the CPU-observed address domain catches
// up. Unbound holes remain inactive; no capacity slot becomes a solver body.
__global__ void clearNewNativeNodeRange(PxvPreSolveNode* nodes,PxU32 first,PxU32 end,
    const NativeMotionAddresses* addresses,const PxDestructionMotionSlotStatus* pool) {
    const PxU64 index=PxU64(first)+blockIdx.x*blockDim.x+threadIdx.x;if(index>=end)return;
    if(addresses && pool && index<addresses->storage.capacity && addresses->ordinals) {
        const PxU32 ordinal=addresses->ordinals[index];
        if(ordinal!=~PxU32(0) && PxU64(ordinal)<PxU64(pool->committed)+pool->pending)return;
    }
    nodes[index]={};
}
struct NativeMotionAllocationView {
    PxDestructionMotionSlotStatus* pool;
    const NativeMotionAddresses* addresses;
    const PxDestructionBodyPreparationStatus* preparation;
    const PxvDestructionBodyRequest* requests;
    PxvDestructionBodyRequest* compact;
    PxU32 *selected,*candidateIndices,*blockOffsets;
    PxDestructionBodyAllocationStatus* allocation;
    PxDestructionStageStatus* stage;
    PxU32 requestCapacity,blocks;
    const PxDestructionClusterBodyState* candidates;
    cudaGraphConditionalHandle continuation{};
    NativeNodeBirthTransaction* births{};
};
__global__ void beginNativeMotionAllocation(NativeMotionAllocationView v,cudaGraphConditionalHandle work) {
    const auto p=*v.preparation;const auto addresses=*v.addresses;
    *v.allocation={};v.allocation->generation=p.generation;v.allocation->count=p.count;
    v.pool->capacity=addresses.capacity;v.pool->pending=0;v.pool->error=0;
    cudaGraphSetConditional(work,0);
    if(v.continuation)cudaGraphSetConditional(v.continuation,0);
    if(v.stage->error!=8u)return;
    if(!p.valid || p.count>v.requestCapacity || p.allocationRequests>p.count) {
        v.allocation->error=v.pool->error=2u;v.stage->error|=256u;return;
    }
    if(v.pool->committed>addresses.capacity || p.allocationRequests>addresses.capacity-v.pool->committed
        || (p.allocationRequests && !addresses.indices)) {
        // Retry only this graph after capacity growth. No physical/material work
        // or canonical owner has changed and no allocation has been committed.
        v.allocation->error=v.pool->error=1u;return;
    }
    // Invalid resource grants must fail before any body/owner writes. In
    // particular, a duplicate address would otherwise race two fragment writes.
    const PxU32 addressError=*addresses.error;
    if(addressError) {
        v.allocation->error=v.pool->error=addressError;v.stage->error|=256u;
        if(addressError&16u){v.allocation->initializationError=1;v.stage->error|=512u;}
        return;
    }
    if(!p.allocationRequests){v.allocation->valid=1;if(v.continuation)cudaGraphSetConditional(v.continuation,1);return;}
    cudaGraphSetConditional(work,1);
}
__device__ void nativeMotionTileRange(NativeMotionAllocationView v,PxU32& first,PxU32& last) {
    const PxU32 count=v.preparation->count,tiles=count/128+(count%128!=0);
    first=PxU32(PxU64(tiles)*blockIdx.x/v.blocks);
    last=PxU32(PxU64(tiles)*(blockIdx.x+1)/v.blocks);
}
__device__ void countNativeMotionRequests(NativeMotionAllocationView v) {
    PxU32 first,last;nativeMotionTileRange(v,first,last);
    PxU32 sum=0;
    for(PxU32 tile=first;tile<last;++tile) {
        const PxU32 i=tile*128+threadIdx.x;
        if(i<v.preparation->count) {
            const auto r=v.requests[i];
            if(r.needsBody>1 || r.supported>1 || r.candidateSlot!=i
                || r.cluster>=v.requestCapacity || r.sourceBody==~PxU32(0))atomicOr(&v.allocation->error,2u);
            sum+=r.needsBody==1;
        }
    }
    using Reduce=cub::BlockReduce<PxU32,128>;
    __shared__ typename Reduce::TempStorage storage;
    const PxU32 total=Reduce(storage).Sum(sum);
    if(!threadIdx.x)v.blockOffsets[blockIdx.x]=total;
}
__device__ void prefixNativeMotionRequests(NativeMotionAllocationView v) {
    PxU32 count=0;
    for(PxU32 i=0;i<v.blocks;++i) {
        const PxU32 n=v.blockOffsets[i];v.blockOffsets[i]=count;count+=n;
    }
    if(count!=v.preparation->allocationRequests)v.allocation->error|=2u;
    v.pool->error=v.allocation->error; // immutable guard during parallel compaction
    v.births->initialize=v.births->generation!=v.preparation->generation
        || v.births->first!=v.pool->committed || v.births->count!=count;
}
__device__ void compactNativeMotionRequests(NativeMotionAllocationView v) {
    if(v.pool->error)return;
    PxU32 first,last;nativeMotionTileRange(v,first,last);
    PxU32 offset=v.blockOffsets[blockIdx.x];
    using Scan=cub::BlockScan<PxU32,128>;
    __shared__ typename Scan::TempStorage storage;
    for(PxU32 tile=first;tile<last;++tile) {
        const PxU32 i=tile*128+threadIdx.x;
        const bool needed=i<v.preparation->count && v.requests[i].needsBody;
        PxU32 rank=0,total=0;
        Scan(storage).ExclusiveSum(PxU32(needed),rank,total);
        if(needed) {
            const auto request=v.requests[i];const PxU32 slot=offset+rank;
            const PxU32 id=v.addresses->indices[v.pool->committed+slot];
            v.compact[slot]=request;v.selected[slot]=id;
            const auto storage=v.addresses->storage;
            if(id==~PxU32(0) || id==request.sourceBody)atomicOr(&v.allocation->error,4u);
            if(!storage.bodies || id>=storage.capacity || request.sourceBody>=storage.capacity)
                atomicOr(&v.allocation->error,16u);
            else {
                // Resolve against registered immutable ownership. A corrupted
                // grant cannot redirect a write into an ordinary/foreign body.
                if(v.addresses->ordinals[id]!=v.pool->committed+slot)
                    atomicOr(&v.allocation->error,4u);
                const PxU32 sourceOrdinal=v.addresses->ordinals[request.sourceBody];
                // Parents can be ordinary bodies or committed native fragments,
                // never pending/unallocated storage (including another target).
                if(sourceOrdinal!=~PxU32(0) && sourceOrdinal>=v.pool->committed)
                    atomicOr(&v.allocation->error,4u);
            }
            if(!v.addresses->nodes || id>=v.addresses->nodeCapacity
                || (v.births->initialize && v.addresses->nodes[id].lifetime==~PxU64(0)))
                atomicOr(&v.allocation->error,16u);
            const auto candidate=v.candidates[request.candidateSlot];
            if(candidate.cluster!=request.cluster || candidate.sourceBody!=request.sourceBody || candidate.supported!=request.supported)
                atomicOr(&v.allocation->error,16u);
        }
        offset+=total;__syncthreads();
    }
}
__device__ void assignNativeMotionOwners(NativeMotionAllocationView v) {
    // Previous graph nodes validated the complete batch. Errors leave every
    // canonical owner untouched, although disposable selection scratch changed.
    if(!v.allocation->error) {
        const PxU64 stride=PxU64(blockDim.x)*gridDim.x;
        for(PxU64 i=PxU64(blockIdx.x)*blockDim.x+threadIdx.x;i<v.preparation->allocationRequests;i+=stride)
        {
            const auto request=v.compact[i];const PxU32 id=v.selected[i];
            const auto storage=v.addresses->storage;
            const auto b=nativeCandidateState(v.candidates[request.candidateSlot],storage.bodies[request.sourceBody],id);
            storage.bodies[id]=b;
            if(v.births->initialize) {
                auto& node=v.addresses->nodes[id];
                node={node.lifetime+1,0,PxU32(!request.supported)};
            }
            if(storage.previous){storage.previous[id].linearVelocity=b.linearVelocityXYZ_inverseMassW;
                storage.previous[id].angularVelocity=b.angularVelocityXYZ_maxPenBiasW;}
            if(storage.accelerations)storage.accelerations[id]={};
            v.candidateIndices[request.candidateSlot]=id;
        }
    }
    if(!blockIdx.x && !threadIdx.x) {
        v.pool->error=v.allocation->error;
        if(v.allocation->error) {
            v.stage->error|=256u;
            if(v.allocation->error&16u){v.allocation->initializationError=1u;v.stage->error|=512u;}
        }
        else {
            // Only the transaction identity changes here. Parallel writers
            // read the separate initialize flag, never these receipt fields.
            v.births->generation=v.preparation->generation;
            v.births->first=v.pool->committed;v.births->count=v.preparation->allocationRequests;
            v.pool->pending=v.preparation->allocationRequests;
            v.allocation->reserved=v.pool->pending;v.allocation->initialized=v.pool->pending;v.allocation->valid=1;
            if(v.continuation)cudaGraphSetConditional(v.continuation,1);
        }
    }
}

__global__ void allocateNativeMotionRequests(NativeMotionAllocationView v) {
    const auto grid=cooperative_groups::this_grid();
    countNativeMotionRequests(v);grid.sync();
    if(!grid.thread_rank())prefixNativeMotionRequests(v);
    grid.sync();
    compactNativeMotionRequests(v);grid.sync();
    assignNativeMotionOwners(v);
}

// One graph instantiated at scene setup. Growth updates one address descriptor;
// it does not recapture graphs or introduce a host-count execution path.
class NativeMotionAllocation {
    NativeMotionAddresses* mAddresses{};
    NativeMotionAddresses mHostAddresses{}; // remains alive until the ordered copy completes
    PxU32* mOffsets{};
    cudaGraph_t mGraph{};
    cudaGraphExec_t mExecutable{};
    PxU32 mOrdinalCapacity{};
    NativeNodeBirthTransaction* mBirths{};
    cudaError_t registerAddresses(cudaStream_t stream) {
        auto& v=mHostAddresses;
        if(v.capacity && v.storage.capacity!=mOrdinalCapacity) {
            // Exceptional growth is ordered outside graph execution. No body
            // slots become active and no per-step registry clearing is needed.
            const auto e=cudaFree(v.ordinals);if(e!=cudaSuccess)return e;
            v.ordinals=nullptr;mOrdinalCapacity=0;
            if(v.storage.capacity) {
                const auto e=cudaMalloc(&v.ordinals,size_t(v.storage.capacity)*sizeof(PxU32));
                if(e!=cudaSuccess)return e;
                mOrdinalCapacity=v.storage.capacity;
            }
        }
        auto e=cudaMemsetAsync(v.error,0,sizeof(PxU32),stream);if(e!=cudaSuccess)return e;
        if(v.capacity && mOrdinalCapacity) {
            e=cudaMemsetAsync(v.ordinals,0xff,size_t(mOrdinalCapacity)*sizeof(PxU32),stream);
            if(e!=cudaSuccess)return e;
        }
        if(v.capacity) {
            registerNativeMotionAddresses<<<(PxU64(v.capacity)+127)/128,128,0,stream>>>(v);
            e=cudaGetLastError();if(e!=cudaSuccess)return e;
        }
        return cudaMemcpyAsync(mAddresses,&v,sizeof(v),cudaMemcpyHostToDevice,stream);
    }
    template<class Kernel,class... Args>
    cudaError_t add(cudaGraph_t graph,cudaGraphNode_t& prior,Kernel kernel,PxU32 blocks,PxU32 threads,Args... args) {
        void* parameters[]={&args...};cudaKernelNodeParams p{};
        p.func=reinterpret_cast<void*>(kernel);p.gridDim=dim3(blocks);p.blockDim=dim3(threads);p.kernelParams=parameters;
        cudaGraphNode_t node{};const auto e=cudaGraphAddKernelNode(&node,graph,prior?&prior:nullptr,prior?1:0,&p);
        if(e==cudaSuccess)prior=node;return e;
    }
public:
    void clear() {
        if(mExecutable)cudaGraphExecDestroy(mExecutable);if(mGraph)cudaGraphDestroy(mGraph);
        cudaFree(mHostAddresses.ordinals);cudaFree(mHostAddresses.error);cudaFree(mBirths);mBirths=nullptr;
        mHostAddresses={};mOrdinalCapacity=0;
        cudaFree(mAddresses);cudaFree(mOffsets);mExecutable=nullptr;mGraph=nullptr;mAddresses=nullptr;mOffsets=nullptr;
    }
    const NativeMotionAddresses* addressView() const {return mAddresses;}
    cudaError_t setNodes(PxvPreSolveNode* nodes,PxU32 capacity,cudaStream_t stream) {
        if(mHostAddresses.nodes==nodes && mHostAddresses.nodeCapacity==capacity)return cudaSuccess;
        mHostAddresses.nodes=nodes;mHostAddresses.nodeCapacity=capacity;
        return cudaMemcpyAsync(mAddresses,&mHostAddresses,sizeof(mHostAddresses),cudaMemcpyHostToDevice,stream);
    }
    cudaError_t setCapacity(const PxU32* indices,PxU32 capacity,cudaStream_t stream) {
        mHostAddresses.indices=indices;mHostAddresses.capacity=capacity;
        return registerAddresses(stream);
    }
    cudaError_t setResources(const PxU32* indices,PxU32 capacity,
        const PxgDestructionMotionStorage& storage,cudaStream_t stream) {
        // Combined exceptional growth: build the new index once, after both
        // the immutable address prefix and borrowed body storage are ready.
        mHostAddresses.indices=indices;mHostAddresses.capacity=capacity;
        mHostAddresses.storage=storage;return registerAddresses(stream);
    }
    cudaError_t setStorage(const PxgDestructionMotionStorage& storage,cudaStream_t stream) {
        const auto& old=mHostAddresses.storage;
        if(old.bodies==storage.bodies && old.previous==storage.previous
            && old.accelerations==storage.accelerations && old.capacity==storage.capacity)return cudaSuccess;
        const bool capacityChanged=old.capacity!=storage.capacity;
        mHostAddresses.storage=storage;
        if(capacityChanged)return registerAddresses(stream);
        return cudaMemcpyAsync(mAddresses,&mHostAddresses,sizeof(mHostAddresses),cudaMemcpyHostToDevice,stream);
    }
    cudaError_t initialize(NativeMotionAllocationView v,cudaStream_t stream,cudaGraph_t* continuation=nullptr) {
        int device=0,major=0,minor=0;
        cudaError_t e=cudaGetDevice(&device);if(e!=cudaSuccess)return e;
        e=cudaDeviceGetAttribute(&major,cudaDevAttrComputeCapabilityMajor,device);if(e!=cudaSuccess)return e;
        e=cudaDeviceGetAttribute(&minor,cudaDevAttrComputeCapabilityMinor,device);if(e!=cudaSuccess)return e;
        if(!((major==8 && minor==9) || (major==12 && minor==0)))return cudaErrorNotSupported;
        int cooperative=0,sms=0,resident=0;
        e=cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device);if(e!=cudaSuccess)return e;
        e=cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device);if(e!=cudaSuccess)return e;
        e=cudaOccupancyMaxActiveBlocksPerMultiprocessor(&resident,allocateNativeMotionRequests,128,0);if(e!=cudaSuccess)return e;
        if(!cooperative || !resident)return cudaErrorNotSupported;
        v.blocks=std::min(PxU32(sms*resident),std::min(128u,std::max(1u,v.requestCapacity/128+(v.requestCapacity%128!=0))));
        e=cudaMalloc(&mAddresses,sizeof(*mAddresses));if(e!=cudaSuccess)return e;
        e=cudaMalloc(&mHostAddresses.error,sizeof(PxU32));if(e!=cudaSuccess)return e;
        e=cudaMalloc(&mOffsets,v.blocks*sizeof(*mOffsets));if(e!=cudaSuccess)return e;
        e=cudaMalloc(&mBirths,sizeof(*mBirths));if(e!=cudaSuccess)return e;
        e=cudaMemsetAsync(mBirths,0,sizeof(*mBirths),stream);if(e!=cudaSuccess)return e;
        v.addresses=mAddresses;v.blockOffsets=mOffsets;v.births=mBirths;
        e=setCapacity(nullptr,0,stream);if(e!=cudaSuccess)return e;
        e=cudaGraphCreate(&mGraph,0);if(e!=cudaSuccess)return e;
        if(continuation){e=cudaGraphConditionalHandleCreate(&v.continuation,mGraph,0,cudaGraphCondAssignDefault);if(e!=cudaSuccess)return e;}
        cudaGraphConditionalHandle work{};
        e=cudaGraphConditionalHandleCreate(&work,mGraph,0,cudaGraphCondAssignDefault);if(e!=cudaSuccess)return e;
        cudaGraphNode_t prior{};
        e=add(mGraph,prior,beginNativeMotionAllocation,1,1,v,work);if(e!=cudaSuccess)return e;
        cudaGraphNodeParams condition{};condition.type=cudaGraphNodeTypeConditional;
        condition.conditional.handle=work;condition.conditional.type=cudaGraphCondTypeIf;condition.conditional.size=1;
        cudaGraphNode_t branch{};e=cudaGraphAddNode(&branch,mGraph,&prior,nullptr,1,&condition);if(e!=cudaSuccess)return e;
        const auto body=condition.conditional.phGraph_out[0];prior=nullptr;
        e=add(body,prior,allocateNativeMotionRequests,v.blocks,128,v);if(e!=cudaSuccess)return e;
        cudaKernelNodeAttrValue attribute{};attribute.cooperative=1;
        e=cudaGraphKernelNodeSetAttribute(prior,cudaKernelNodeAttributeCooperative,&attribute);if(e!=cudaSuccess)return e;
        if(continuation) {
            cudaGraphNodeParams next{};next.type=cudaGraphNodeTypeConditional;
            next.conditional.handle=v.continuation;next.conditional.type=cudaGraphCondTypeIf;next.conditional.size=1;
            cudaGraphNode_t node{};e=cudaGraphAddNode(&node,mGraph,&branch,nullptr,1,&next);if(e!=cudaSuccess)return e;
            *continuation=next.conditional.phGraph_out[0];return cudaSuccess;
        }
        return instantiate(stream);
    }
    // The standalone allocation oracle needs no continuation. Production fills
    // the same graph's preparation branch before this single instantiation.
    cudaError_t instantiate(cudaStream_t stream) {
        const auto e=cudaGraphInstantiate(&mExecutable,mGraph,0);if(e!=cudaSuccess)return e;
        return cudaGraphUpload(mExecutable,stream);
    }
    cudaError_t launch(cudaStream_t stream) {return cudaGraphLaunch(mExecutable,stream);}
};
__global__ void finishNativeBodyShadowRegistration(bool valid,PxDestructionBodyAllocationStatus* allocation,
    PxDestructionStageStatus* stage) {
    if(!valid){allocation->error|=8u;allocation->valid=0;stage->error|=256u;}
}
__global__ void commitNativeMotionSlots(PxDestructionMotionSlotStatus* pool,const PxDestructionStageStatus* stage) {
    if(stage->error)return;
    pool->committed+=pool->pending;pool->pending=0;
}
