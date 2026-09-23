// Persistent, GPU-controlled first-level construction for native multilevel stress.
#pragma once
#include "StressHierarchyKernels.cuh"
#include "StressHierarchySelfCache.cuh"
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <stdexcept>
#include <string>
namespace Nv { namespace Blast { namespace StressHierarchy {
class Graph {
    unsigned mNodes,mBonds,mBlocks=0;
    bool mRecursive;
    cudaStream_t mStream;
    Status* mStatus=nullptr;
    Work* mWork=nullptr;
    Buffers mBuffers{};
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident hierarchy: ")+cudaGetErrorString(e));}
    template<class T> static void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
    void release() noexcept{
        cudaFree(mStatus);cudaFree(mWork);cudaFree(mBuffers.owner);cudaFree(mBuffers.seed);cudaFree(mBuffers.coarseActive);
        cudaFree(mBuffers.minimum);cudaFree(mBuffers.leader);cudaFree(mBuffers.pending);cudaFree(mBuffers.memberBond);cudaFree(mBuffers.coarse);cudaFree(mBuffers.diagonal);
        cudaFree(mBuffers.nonSelfRefs);cudaFree(mBuffers.nonSelfEnd);cudaFree(mBuffers.selfMatrices);
    }
public:
    Graph(unsigned nodes,unsigned bonds,cudaStream_t stream,bool recursive=false):mNodes(nodes),mBonds(bonds),mRecursive(recursive),mStream(stream){
        if(nodes>0x7fffffffu || bonds>0x7fffffffu)throw std::runtime_error("Resident hierarchy exceeds 31-bit CSR representation");
        try {
            int device=0,sms=0,blocks=0,cooperative=0;
            check(cudaGetDevice(&device));check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));
            check(cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device));
            check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&blocks,construct,Threads,0));
            if(!cooperative || sms<=0 || blocks<=0)throw std::runtime_error("Resident hierarchy requires legal cooperative CUDA residency");
            mBlocks=std::min(std::max(1u,(nodes+Threads-1)/Threads),unsigned(sms*blocks));
            allocate(mStatus,1);allocate(mWork,1);allocate(mBuffers.owner,nodes);allocate(mBuffers.seed,nodes);allocate(mBuffers.coarseActive,nodes);
            allocate(mBuffers.minimum,nodes);allocate(mBuffers.leader,nodes);allocate(mBuffers.memberBond,nodes);
            if(!mRecursive)allocate(mBuffers.diagonal,size_t(nodes)*DiagonalEntries);
            else {allocate(mBuffers.nonSelfRefs,size_t(bonds)*2);allocate(mBuffers.nonSelfEnd,nodes);allocate(mBuffers.selfMatrices,size_t(SelfCacheNodes)*SelfCacheEntries);}
            allocate(mBuffers.pending,(nodes+Threads-1)/Threads);allocate(mBuffers.coarse,bonds);
            check(cudaMemsetAsync(mStatus,0,sizeof(Status),stream));
        } catch(...){release();throw;}
    }
    ~Graph(){cudaStreamSynchronize(mStream);release();}
    Graph(const Graph&)=delete;Graph& operator=(const Graph&)=delete;
    // Caller orders producers/consumers on this stream; graph capture is legal.
    // No status readback, CPU numerical work, allocation or recapture occurs
    // here. Consumers must reject an error status and await device completion.
    void validate(Input input)const{
        if((input.componentSolverMaxNodes && (!input.partition.begin || !input.partition.end))
            || input.nodes!=mNodes || input.bonds!=mBonds || !input.generation || bool(input.levelBonds)!=mRecursive
            || (mNodes && (!input.begin||!input.component||!input.position||(!input.levelBonds && !input.inertia)))
            || (input.levelBonds && (!input.identity || (mNodes && !input.authoredNodes)))
            || (mBonds && (!input.refs || (!input.levelBonds && (!input.node0||!input.node1||!input.health||!input.scale||!input.offset0||!input.offset1)))))
            throw std::runtime_error("Invalid resident hierarchy device view");
    }
    void enqueue(Input input){
        validate(input);void* args[]={&input,&mBuffers,&mStatus,&mWork};
#if NV_BLAST_SEPARATE_HIERARCHY_CONSTRUCT
        if(separate()){
            phases(input,[&](void* func,unsigned blocks,unsigned threads,void** a,bool cooperative){
                check(cooperative?cudaLaunchCooperativeKernel(func,dim3(blocks),dim3(threads),a,0,mStream)
                                 :cudaLaunchKernel(func,dim3(blocks),dim3(threads),a,0,mStream));
            });
            return;
        }
#endif
        check(cudaLaunchCooperativeKernel((void*)construct,dim3(mBlocks),dim3(Threads),args,0,mStream));
        if(mRecursive){buildSelfCache<<<mBlocks,Threads,0,mStream>>>(input,mBuffers,mStatus,mWork);check(cudaGetLastError());}
    }
#if NV_BLAST_SEPARATE_HIERARCHY_CONSTRUCT
    // Seed rounds unrolled into ordinary launches; any further rounds run in
    // the cooperative tail. Each unrolled round a construction does not need
    // is three launches that return at once.
    static constexpr unsigned SeparateSeedRounds=6;
    // Opt-in (BLAST_STRESS_SEPARATE_CONSTRUCT=1). The chain is replayed with
    // the rest of the stress graph on every full destruction frame, and on a
    // frame whose topology did not change every launch in it returns at once
    // -- but still costs a launch. Measured in vibe-land's city: fracture and
    // demolition p99 1-3 ms lower, every awake-debris tick 0.7 ms higher.
    bool separate()const{
        static const bool enabled=[]{const char* v=std::getenv("BLAST_STRESS_SEPARATE_CONSTRUCT");return v && v[0]=='1';}();
        return !mRecursive && enabled;
    }
    // construct() for the fine level as a chain of launches (see
    // NV_BLAST_SEPARATE_HIERARCHY_CONSTRUCT). The node grids cover the level's
    // capacity; blocks past the resolved count return.
    template<class Add> void phases(Input& input,Add add){
        auto grid=[](std::uint64_t items,unsigned per){return unsigned(std::max<std::uint64_t>(1,std::min<std::uint64_t>(4096,(items+per-1)/per)));};
        const unsigned nodes=grid(mNodes,Threads),bonds=grid(mBonds,Threads),diagonal=grid(mNodes,Threads/32);
        void* args[]={&input,&mBuffers,&mStatus,&mWork};
        void* statusArgs[]={&input,&mStatus,&mWork};
        void* checkpointArgs[]={&mStatus,&mWork};
        void* minimumArgs[]={&input,&mBuffers,&mWork};
        add((void*)beginConstruct,1,1,statusArgs,false);
        add((void*)initializeConstruct,nodes,Threads,args,false);
        add((void*)checkpointConstruct,1,1,checkpointArgs,false);
        for(unsigned round=0;round<SeparateSeedRounds;++round){
            add((void*)chooseSeedsRound,nodes,Threads,args,false);
            add((void*)assignSeedsRound,nodes,Threads,args,false);
            add((void*)finishSeedRound,1,Threads,args,false);
        }
        add((void*)finishSeedRounds,mBlocks,Threads,args,true);
        add((void*)minimumConstruct,nodes,Threads,minimumArgs,false);
        add((void*)publishConstruct,nodes,Threads,args,false);
        add((void*)coarseConstruct,bonds,Threads,args,false);
        add((void*)checkpointConstruct,1,1,checkpointArgs,false);
        add((void*)diagonalConstruct,diagonal,Threads,args,false);
        add((void*)commitConstruct,1,1,statusArgs,false);
    }
#endif
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior,Input input){
        validate(input);
#if NV_BLAST_SEPARATE_HIERARCHY_CONSTRUCT
        if(separate()){
            // Arguments are copied into each node, so one args array per shape serves every node.
            phases(input,[&](void* func,unsigned blocks,unsigned threads,void** args,bool cooperative){
                cudaKernelNodeParams p{};p.func=func;p.gridDim=dim3(blocks);p.blockDim=dim3(threads);p.kernelParams=args;
                cudaGraphNode_t node;check(cudaGraphAddKernelNode(&node,graph,prior?&prior:nullptr,prior?1:0,&p));
                if(cooperative){cudaKernelNodeAttrValue a{};a.cooperative=1;check(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeCooperative,&a));}
                prior=node;
            });
            return prior;
        }
#endif
        void* args[]={&input,&mBuffers,&mStatus,&mWork};
        cudaKernelNodeParams params{};params.func=(void*)construct;params.gridDim=dim3(mBlocks);
        params.blockDim=dim3(Threads);params.kernelParams=args;cudaGraphNode_t node;
        check(cudaGraphAddKernelNode(&node,graph,prior?&prior:nullptr,prior?1:0,&params));
        cudaKernelNodeAttrValue attribute{};attribute.cooperative=1;
        check(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeCooperative,&attribute));
        if(mRecursive){
            void* cacheArgs[]={&input,&mBuffers,&mStatus,&mWork};cudaKernelNodeParams cache{};
            cache.func=(void*)buildSelfCache;cache.gridDim=dim3(mBlocks);cache.blockDim=dim3(Threads);cache.kernelParams=cacheArgs;
            cudaGraphNode_t done;check(cudaGraphAddKernelNode(&done,graph,&node,1,&cache));return done;
        }
        return node;
    }
    Input cachedInput(Input input)const{
        input.nonSelfRefs=mBuffers.nonSelfRefs;input.nonSelfEnd=mBuffers.nonSelfEnd;input.selfMatrices=mBuffers.selfMatrices;return input;
    }
    Buffers buffers()const{return mBuffers;}
    const unsigned* leaders()const{return mBuffers.leader;}
    const CoarseBond* coarseBonds()const{return mBuffers.coarse;}
    const Status* status()const{return mStatus;}
};
}}}
