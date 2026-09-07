// Persistent workspace for one compact recursive level; no host work decisions.
#pragma once
#include "StressHierarchyGraph.cuh"
#include "StressHierarchyPacking.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
class PackedLevel {
    Input mInput;Buffers mParent;const Status* mParentStatus;cudaStream_t mStream;
    PackingBuffers mBuffers{};Status* mStatus=nullptr;PackingWork* mWork=nullptr;
    unsigned mTiles=0,mBlocks=0;bool mAppended=false;
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident packed level: ")+cudaGetErrorString(e));}
    template<class T>static void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
    void release()noexcept{
        cudaFree(mBuffers.nodeMap);cudaFree(mBuffers.bondMap);cudaFree(mBuffers.identity);cudaFree(mBuffers.component);cudaFree(mBuffers.bondIdentity);
        cudaFree(mBuffers.begin);cudaFree(mBuffers.refs);cudaFree(mBuffers.counts);cudaFree(mBuffers.partial);cudaFree(mBuffers.localBegin);
        cudaFree(mBuffers.keys);cudaFree(mBuffers.sorted);cudaFree(mBuffers.bonds);cudaFree(mStatus);cudaFree(mWork);
    }
public:
    PackedLevel(Input input,const Graph& parent,cudaStream_t stream):mInput(input),mParent(parent.buffers()),mParentStatus(parent.status()),mStream(stream){
        if(input.nodes>(1u<<29) || input.bonds>(1u<<29))throw std::runtime_error("Resident packed level exceeds scan index capacity");
        mTiles=(2*input.bonds+SortTile-1)/SortTile;
        try {
            int device=0,sms=0,blocks=0,cooperative=0;check(cudaGetDevice(&device));
            check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));check(cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device));
            check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&blocks,packLevel,Threads,0));
            if(!cooperative || sms<=0 || blocks<=0)throw std::runtime_error("Resident packing requires legal cooperative CUDA residency");
            // At least two blocks provide all 16 radix-prefix warps.
            const unsigned required=std::max(2u,(std::max(input.nodes,input.bonds)+Threads-1)/Threads);
            mBlocks=std::min(required,unsigned(sms*blocks));
            if(mBlocks<2)throw std::runtime_error("Resident packing requires at least two resident blocks");
            allocate(mBuffers.nodeMap,input.nodes);allocate(mBuffers.bondMap,input.bonds);
            allocate(mBuffers.identity,input.nodes);allocate(mBuffers.component,input.nodes);allocate(mBuffers.bondIdentity,input.bonds);
            allocate(mBuffers.begin,size_t(input.nodes)+1);allocate(mBuffers.refs,2*size_t(input.bonds));allocate(mBuffers.counts,2);
            allocate(mBuffers.keys,size_t(mTiles)*SortTile);allocate(mBuffers.sorted,size_t(mTiles)*SortTile);allocate(mBuffers.bonds,input.bonds);
            allocate(mBuffers.partial,std::max(size_t(RadixBins)*mTiles,size_t((std::max(input.nodes+1,input.bonds)+Threads-1)/Threads)));
            allocate(mBuffers.localBegin,size_t(RadixBins)*mTiles);allocate(mStatus,1);allocate(mWork,1);
            check(cudaMemsetAsync(mStatus,0,sizeof(Status),stream));check(cudaMemsetAsync(mBuffers.counts,0,2*sizeof(unsigned),stream));
        } catch(...){release();throw;}
    }
    ~PackedLevel(){cudaStreamSynchronize(mStream);release();}
    PackedLevel(const PackedLevel&)=delete;PackedLevel& operator=(const PackedLevel&)=delete;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        if(mAppended)throw std::runtime_error("Resident packed level already appended");
        void* args[]={&mInput,&mParent,&mParentStatus,&mStatus,&mBuffers,&mWork,&mTiles};
        cudaKernelNodeParams params{};params.func=(void*)packLevel;params.gridDim=dim3(mBlocks);params.blockDim=dim3(Threads);params.kernelParams=args;
        cudaGraphNode_t node;check(cudaGraphAddKernelNode(&node,graph,prior?&prior:nullptr,prior?1:0,&params));
        cudaKernelNodeAttrValue attribute{};attribute.cooperative=1;check(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeCooperative,&attribute));
        mAppended=true;return node;
    }
    Input view()const{
        Input next{};next.nodes=mInput.nodes;next.bonds=mInput.bonds;next.begin=mBuffers.begin;next.refs=mBuffers.refs;
        next.component=mBuffers.component;next.position=mInput.position;next.generation=mInput.generation;next.accept=mInput.accept;
        next.levelBonds=mBuffers.bonds;next.identity=mBuffers.identity;next.counts=mBuffers.counts;next.sourceStatus=mStatus;
        next.authoredNodes=mInput.authoredNodes?mInput.authoredNodes:mInput.nodes;next.bondIdentity=mBuffers.bondIdentity;return next;
    }
    PackingBuffers buffers()const{return mBuffers;}
    const Status* status()const{return mStatus;}
};
}}}
