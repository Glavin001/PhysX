// Persistent terminal-factor workspace and captured device construction.
#pragma once
#include "StressHierarchyGraph.cuh"
#include "StressHierarchyTerminal.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
class TerminalLevel {
    Input mInput;const Status* mSource;cudaStream_t mStream;TerminalBuffers mBuffers{};
    Status* mStatus=nullptr;Work* mWork=nullptr;unsigned mBlocks=0;bool mAppended=false;
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident terminal level: ")+cudaGetErrorString(e));}
    template<class T>static void allocate(T*& p,size_t count){check(cudaMalloc(&p,std::max(size_t(1),count)*sizeof(T)));}
    void release()noexcept{cudaFree(mBuffers.storage);cudaFree(mBuffers.lift);cudaFree(mBuffers.kind);cudaFree(mStatus);cudaFree(mWork);}
public:
    TerminalLevel(Input input,const Status* source,cudaStream_t stream):mInput(input),mSource(source),mStream(stream){
        const auto p=input.partition;
        if(!source || !p.ids || !p.begin || !p.end || !p.nodeCount || !p.count || (!input.levelBonds && !p.nodes))
            throw std::runtime_error("Resident terminal level requires the native GPU component partition");
        try {
            int device=0,sms=0,blocks=0,cooperative=0;check(cudaGetDevice(&device));
            check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));check(cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device));
            check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&blocks,constructTerminals,Threads,0));
            if(!cooperative || sms<=0 || blocks<=0)throw std::runtime_error("Resident terminal construction requires legal cooperative CUDA residency");
            mBlocks=std::min(std::max(1u,input.nodes),unsigned(sms*blocks));
            const size_t capacity=input.authoredNodes?input.authoredNodes:input.nodes;
            allocate(mBuffers.storage,capacity*TerminalNodeSlots);allocate(mBuffers.lift,capacity*6);allocate(mBuffers.kind,capacity);
            allocate(mStatus,1);allocate(mWork,1);check(cudaMemsetAsync(mStatus,0,sizeof(Status),stream));
        }catch(...){release();throw;}
    }
    ~TerminalLevel(){cudaStreamSynchronize(mStream);release();}
    TerminalLevel(const TerminalLevel&)=delete;TerminalLevel& operator=(const TerminalLevel&)=delete;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        if(mAppended)throw std::runtime_error("Resident terminal construction already appended");
        void* args[]={&mInput,&mSource,&mStatus,&mWork,&mBuffers};
        cudaKernelNodeParams params{};params.func=(void*)constructTerminals;params.gridDim=dim3(mBlocks);params.blockDim=dim3(Threads);params.kernelParams=args;
        cudaGraphNode_t node;check(cudaGraphAddKernelNode(&node,graph,prior?&prior:nullptr,prior?1:0,&params));
        cudaKernelNodeAttrValue attribute{};attribute.cooperative=1;check(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeCooperative,&attribute));
        mAppended=true;return node;
    }
    void apply(const Vector* rhs,Vector* result)const{
        applyTerminals<<<mBlocks,Threads,0,mStream>>>(mInput,mStatus,mBuffers,rhs,result);check(cudaGetLastError());
    }
    TerminalBuffers buffers()const{return mBuffers;}
    const Status* status()const{return mStatus;}
};
}}}
