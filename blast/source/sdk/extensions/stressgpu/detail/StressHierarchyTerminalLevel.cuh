// Persistent terminal-factor workspace and captured device construction.
#pragma once
#include "StressHierarchyGraph.cuh"
#include "StressHierarchyTerminal.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
// One pool serves disjoint terminal components across every hierarchy level.
class TerminalPool {
    TerminalBuffers mBuffers{};unsigned mCapacity;cudaStream_t mStream;
    template<class T>static void allocate(T*& p,size_t n){const auto e=cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T));if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident terminal pool: ")+cudaGetErrorString(e));}
    void release()noexcept{cudaFree(mBuffers.storage);cudaFree(mBuffers.lift);cudaFree(mBuffers.kind);cudaFree(mBuffers.owner);}
public:
    TerminalPool(unsigned capacity,cudaStream_t stream):mCapacity(capacity),mStream(stream){
        try{allocate(mBuffers.storage,size_t(capacity)*TerminalNodeSlots);allocate(mBuffers.lift,size_t(capacity)*6);allocate(mBuffers.kind,capacity);allocate(mBuffers.owner,capacity);
            const auto e=cudaMemsetAsync(mBuffers.owner,0xff,size_t(capacity)*sizeof(unsigned),stream);if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));
        }catch(...){release();throw;}
    }
    ~TerminalPool(){cudaStreamSynchronize(mStream);release();}
    TerminalPool(const TerminalPool&)=delete;TerminalPool& operator=(const TerminalPool&)=delete;
    TerminalBuffers buffers()const{return mBuffers;}
    unsigned capacity()const{return mCapacity;}
    cudaStream_t stream()const{return mStream;}
};
class TerminalLevel {
    Input mInput;const Status* mSource;cudaStream_t mStream;TerminalBuffers mBuffers{};
    Status* mStatus=nullptr;Work* mWork=nullptr;unsigned mBlocks=0,mLevel;bool mAppended=false;
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident terminal level: ")+cudaGetErrorString(e));}
    template<class T>static void allocate(T*& p,size_t count){check(cudaMalloc(&p,std::max(size_t(1),count)*sizeof(T)));}
    void release()noexcept{cudaFree(mStatus);cudaFree(mWork);}
public:
    TerminalLevel(Input input,const Status* source,TerminalPool& pool,unsigned level,cudaStream_t stream):mInput(input),mSource(source),mStream(stream),mBuffers(pool.buffers()),mLevel(level){
        if(pool.capacity()<(input.authoredNodes?input.authoredNodes:input.nodes) || pool.stream()!=stream || level==Invalid)throw std::runtime_error("Resident terminal pool capacity, stream or level mismatch");
        const auto p=input.partition;
        if(!source || !p.ids || !p.begin || !p.end || !p.nodeCount || !p.count || (!input.levelBonds && !p.nodes))
            throw std::runtime_error("Resident terminal level requires the native GPU component partition");
        try {
            int device=0,sms=0,blocks=0,cooperative=0;check(cudaGetDevice(&device));
            check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));check(cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device));
            check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&blocks,constructTerminals,Threads,0));
            if(!cooperative || sms<=0 || blocks<=0)throw std::runtime_error("Resident terminal construction requires legal cooperative CUDA residency");
            mBlocks=std::min(std::max(1u,input.nodes),unsigned(sms*blocks));
            allocate(mStatus,1);allocate(mWork,1);check(cudaMemsetAsync(mStatus,0,sizeof(Status),stream));
        }catch(...){release();throw;}
    }
    ~TerminalLevel(){cudaStreamSynchronize(mStream);release();}
    TerminalLevel(const TerminalLevel&)=delete;TerminalLevel& operator=(const TerminalLevel&)=delete;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        if(mAppended)throw std::runtime_error("Resident terminal construction already appended");
        void* args[]={&mInput,&mSource,&mStatus,&mWork,&mBuffers,&mLevel};
        cudaKernelNodeParams params{};params.func=(void*)constructTerminals;params.gridDim=dim3(mBlocks);params.blockDim=dim3(Threads);params.kernelParams=args;
        cudaGraphNode_t node;check(cudaGraphAddKernelNode(&node,graph,prior?&prior:nullptr,prior?1:0,&params));
        cudaKernelNodeAttrValue attribute{};attribute.cooperative=1;check(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeCooperative,&attribute));
        mAppended=true;return node;
    }
    void apply(const Vector* rhs,Vector* result)const{
        // Only application can take the block-voted terminal error. The
        // component grid-stride loop still visits every terminal component.
#if defined(PX_CUMETAL_BLOCK_VOTED_TRAPS) && PX_CUMETAL_BLOCK_VOTED_TRAPS
        const unsigned blocks=1;
#else
        const unsigned blocks=mBlocks;
#endif
        applyTerminals<<<blocks,Threads,0,mStream>>>(mInput,mStatus,mBuffers,mLevel,rhs,result);check(cudaGetLastError());
    }
    TerminalBuffers buffers()const{return mBuffers;}
    TerminalRetirement retirement()const{return {mBuffers.owner,mLevel,mStatus};}
    const Status* status()const{return mStatus;}
};
}}}
