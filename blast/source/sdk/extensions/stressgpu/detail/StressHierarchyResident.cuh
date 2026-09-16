// Captured GPU hierarchy construction with disjoint shared terminal storage.
#pragma once
#include "StressHierarchyPackedLevel.cuh"
#include "StressHierarchyTerminalLevel.cuh"
#include "StressHierarchySmoother.cuh"
#include "StressHierarchyDemand.cuh"
#include <memory>
#include <vector>
namespace Nv { namespace Blast { namespace StressHierarchy {
__global__ void finalizeHierarchy(Input input,const Status* terminal,TerminalBuffers pool,unsigned level,Status* output){
    __shared__ unsigned work,error;
    if(!threadIdx.x){
        work=error=0;
        if(!input.accept || *input.accept){
            if(!usable(terminal) || !sourceCountsValid(input) || terminal->generation!=*input.generation){output->error=32;
                printf("[hierarchy-resident] rejected: usable=%d countsValid=%d termInit=%u termErr=%u termGen=%llu gen=%llu\n",int(usable(terminal)),int(sourceCountsValid(input)),terminal->initialized,terminal->error,(unsigned long long)terminal->generation,(unsigned long long)*input.generation);}
            else if(output->initialized && output->generation>terminal->generation)output->error=4;
            else if(!output->initialized || output->generation!=terminal->generation || output->error)work=1;
        }
    }
    __syncthreads();if(!work)return;
    for(unsigned i=threadIdx.x;i<*input.partition.count;i+=blockDim.x)
        if(pool.owner[input.partition.ids[i]]!=level)atomicOr(&error,256u);
    __syncthreads();
    if(!threadIdx.x){output->error=error;if(!error){output->generation=terminal->generation;output->initialized=1;++output->builds;}}
}
class ResidentHierarchy {
    TerminalPool mPool;Input mInput;cudaStream_t mStream;unsigned mDepth;Status* mStatus=nullptr;bool mAppended=false;
    std::vector<std::unique_ptr<Graph>> mGraphs;
    std::vector<std::unique_ptr<TerminalLevel>> mTerminals;
    std::vector<std::unique_ptr<RetiringPackedLevel>> mPacked;
    std::vector<Input> mInputs;
    std::vector<std::unique_ptr<LevelSmoother>> mSmoothers;
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident hierarchy: ")+cudaGetErrorString(e));}
public:
    ResidentHierarchy(Input input,unsigned depth,cudaStream_t stream):mPool(input.authoredNodes?input.authoredNodes:input.nodes,stream),mInput(input),mStream(stream),mDepth(depth){
        if(!depth || depth>32)throw std::runtime_error("Resident hierarchy requires between one and 32 allocated levels");
        mGraphs.reserve(depth);mTerminals.reserve(depth);mInputs.reserve(depth);mPacked.reserve(depth-1);mSmoothers.reserve(depth);
        check(cudaMalloc(&mStatus,sizeof(Status)));
        const auto result=cudaMemsetAsync(mStatus,0,sizeof(Status),stream);
        if(result!=cudaSuccess){cudaFree(mStatus);mStatus=nullptr;check(result);}
    }
    ~ResidentHierarchy(){cudaStreamSynchronize(mStream);cudaFree(mStatus);}
    ResidentHierarchy(const ResidentHierarchy&)=delete;ResidentHierarchy& operator=(const ResidentHierarchy&)=delete;
    void setFineDiagonalReuse(const unsigned* valid,const std::uint64_t* generation){
        if(mAppended)throw std::runtime_error("Cannot change captured fine-factor ownership");
        mInput.fineDiagonalValid=valid;mInput.fineDiagonalGeneration=generation;
    }
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        if(mAppended)throw std::runtime_error("Resident hierarchy already appended");
        Input input=mInput;cudaGraphNode_t tailCompletion=nullptr;
        for(unsigned level=0;level<mDepth;++level){
            mGraphs.emplace_back(new Graph(input.nodes,input.bonds,mStream,level!=0));
            input=mGraphs.back()->cachedInput(input);mInputs.push_back(input);
            prior=mGraphs.back()->append(graph,prior,input);
            mTerminals.emplace_back(new TerminalLevel(input,mGraphs.back()->status(),mPool,level,mStream));
            prior=mTerminals.back()->append(graph,prior);
            mSmoothers.emplace_back(new LevelSmoother(input,*mGraphs.back(),*mTerminals.back(),level,mStream));
            prior=mSmoothers.back()->append(graph,prior);
            if(level+1<mDepth){
                if(!level && input.componentSolverMaxNodes) {
                    // The fine producer and retirement remain unconditional:
                    // local inverse and nullspace consumers still need them.
                    // Only the recursive packing/coarse tail is demand-driven.
                    cudaGraphConditionalHandle handle;
                    check(cudaGraphConditionalHandleCreate(&handle,graph,0,cudaGraphCondAssignDefault));
                    const Status* fine=mSmoothers.back()->status();auto pool=mPool.buffers();
                    void* args[]={&input,&fine,&pool,&mStatus,&handle};
                    cudaKernelNodeParams p{};p.func=(void*)chooseHierarchyTail;
                    p.gridDim=dim3(1);p.blockDim=dim3(Threads);p.kernelParams=args;
                    cudaGraphNode_t choose;check(cudaGraphAddKernelNode(&choose,graph,&prior,1,&p));
                    cudaGraphNodeParams branch{};branch.type=cudaGraphNodeTypeConditional;
                    branch.conditional.handle=handle;branch.conditional.type=cudaGraphCondTypeIf;branch.conditional.size=1;
                    check(cudaGraphAddNode(&tailCompletion,graph,&choose,nullptr,1,&branch));
                    graph=branch.conditional.phGraph_out[0];prior=nullptr;
                }
                mPacked.emplace_back(new RetiringPackedLevel(input,*mGraphs.back(),mStream,TerminalRetirement{mPool.buffers().owner,level,mSmoothers.back()->status()}));
                prior=mPacked.back()->append(graph,prior);input=mPacked.back()->view();
            }
        }
        const Status* terminal=mSmoothers.back()->status();auto buffers=mPool.buffers();unsigned last=mDepth-1;
        void* args[]={&input,&terminal,&buffers,&last,&mStatus};cudaKernelNodeParams params{};
        params.func=(void*)finalizeHierarchy;params.gridDim=dim3(1);params.blockDim=dim3(Threads);params.kernelParams=args;
        cudaGraphNode_t final;check(cudaGraphAddKernelNode(&final,graph,&prior,1,&params));mAppended=true;return tailCompletion?tailCompletion:final;
    }
    const Status* status()const{return mStatus;}
    void invalidate(cudaStream_t stream){
        auto reset=[&](const Status* s){if(s)resetLevelStatus<<<1,1,0,stream>>>(const_cast<Status*>(s));};
        reset(mStatus);
        for(auto& g:mGraphs)reset(g->status());
        for(auto& t:mTerminals)reset(t->status());
        for(auto& s:mSmoothers)reset(s->status());
        for(auto& p:mPacked)reset(p->status());
        check(cudaGetLastError());
    }
    TerminalBuffers terminalBuffers()const{return mPool.buffers();}
    unsigned levels()const{return mDepth;}
    cudaStream_t stream()const{return mStream;}
    const LevelSmoother& smoother(unsigned level)const{return *mSmoothers.at(level);}
    Input input(unsigned level)const{return mInputs.at(level);}
    const Graph& topology(unsigned level)const{return *mGraphs.at(level);}
    const TerminalLevel& terminal(unsigned level)const{return *mTerminals.at(level);}
    const RetiringPackedLevel& packed(unsigned level)const{return *mPacked.at(level);}
};
}}}
