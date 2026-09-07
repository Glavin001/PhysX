// Persistent, GPU-controlled first-level construction for native multilevel stress.
#pragma once
#include "StressHierarchyKernels.cuh"
#include <algorithm>
#include <stdexcept>
#include <string>
namespace Nv { namespace Blast { namespace StressHierarchy {
class Graph {
    unsigned mNodes,mBonds,mBlocks=0;
    cudaStream_t mStream;
    Status* mStatus=nullptr;
    Work* mWork=nullptr;
    Buffers mBuffers{};
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident hierarchy: ")+cudaGetErrorString(e));}
    template<class T> static void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
    void release() noexcept{
        cudaFree(mStatus);cudaFree(mWork);cudaFree(mBuffers.owner);cudaFree(mBuffers.seed);
        cudaFree(mBuffers.minimum);cudaFree(mBuffers.leader);cudaFree(mBuffers.pending);cudaFree(mBuffers.memberBond);cudaFree(mBuffers.coarse);cudaFree(mBuffers.diagonal);
    }
public:
    Graph(unsigned nodes,unsigned bonds,cudaStream_t stream):mNodes(nodes),mBonds(bonds),mStream(stream){
        if(nodes>0x7fffffffu || bonds>0x7fffffffu)throw std::runtime_error("Resident hierarchy exceeds 31-bit CSR representation");
        try {
            int device=0,sms=0,blocks=0,cooperative=0;
            check(cudaGetDevice(&device));check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));
            check(cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device));
            check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&blocks,construct,Threads,0));
            if(!cooperative || sms<=0 || blocks<=0)throw std::runtime_error("Resident hierarchy requires legal cooperative CUDA residency");
            mBlocks=std::min(std::max(1u,(nodes+Threads-1)/Threads),unsigned(sms*blocks));
            allocate(mStatus,1);allocate(mWork,1);allocate(mBuffers.owner,nodes);allocate(mBuffers.seed,nodes);
            allocate(mBuffers.minimum,nodes);allocate(mBuffers.leader,nodes);allocate(mBuffers.memberBond,nodes);
            allocate(mBuffers.diagonal,size_t(nodes)*DiagonalEntries);
            allocate(mBuffers.pending,(nodes+Threads-1)/Threads);allocate(mBuffers.coarse,bonds);
            check(cudaMemsetAsync(mStatus,0,sizeof(Status),stream));
        } catch(...){release();throw;}
    }
    ~Graph(){cudaStreamSynchronize(mStream);release();}
    Graph(const Graph&)=delete;Graph& operator=(const Graph&)=delete;
    // Caller orders producers/consumers on this stream; graph capture is legal.
    // No status readback, CPU numerical work, allocation or recapture occurs
    // here. Consumers must reject an error status and await device completion.
    void enqueue(Input input){
        if(input.nodes!=mNodes || input.bonds!=mBonds || !input.generation
            || (mNodes && (!input.begin||!input.component||!input.position||!input.inertia))
            || (mBonds && (!input.refs||!input.node0||!input.node1||!input.health||!input.scale||!input.offset0||!input.offset1)))
            throw std::runtime_error("Invalid resident hierarchy device view");
        void* args[]={&input,&mBuffers,&mStatus,&mWork};
        check(cudaLaunchCooperativeKernel((void*)construct,dim3(mBlocks),dim3(Threads),args,0,mStream));
    }
    Buffers buffers()const{return mBuffers;}
    const unsigned* leaders()const{return mBuffers.leader;}
    const CoarseBond* coarseBonds()const{return mBuffers.coarse;}
    const Status* status()const{return mStatus;}
};
}}}
