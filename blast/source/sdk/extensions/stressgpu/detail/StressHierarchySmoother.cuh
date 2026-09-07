// Exact coarse block diagonals for symmetric damped Jacobi smoothing.
#pragma once
#include "StressHierarchyTerminalLevel.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
__device__ __forceinline__ void buildSmootherRow(Input input,Buffers buffers,TerminalBuffers terminals,unsigned level,Status* status,unsigned node){
    const unsigned lane=threadIdx.x&31u,row=lane<1?0:lane<3?1:lane<6?2:lane<10?3:lane<15?4:5;
    const unsigned col=lane<DiagonalEntries?lane-row*(row+1)/2:0;
    if(input.component[node]==Invalid || terminals.owner[input.component[node]]==level)return;
    double coefficient=0;
    if(lane<DiagonalEntries)coefficient=terminalCoefficient(input,node,row,node,col);
    const bool coupled=__any_sync(0xffffffffu,coefficient!=0);
    if(coupled)for(unsigned k=0;k<6;++k){
        const double diagonal=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
        if(!(diagonal>0) || !isfinite(diagonal)){if(!lane)atomicOr(&status->error,16u);coefficient=0;break;}
        const double pivot=sqrt(diagonal);if(col==k && row>=k)coefficient/=pivot;
        const double left=__shfl_sync(0xffffffffu,coefficient,triangle(row,k<=row?k:row));
        const double right=__shfl_sync(0xffffffffu,coefficient,triangle(col,k<=col?k:col));
        if(lane<DiagonalEntries && col>k)coefficient-=left*right;
    }
    if(lane<DiagonalEntries)buffers.diagonal[size_t(node)*DiagonalEntries+lane]=coefficient;
}
__global__ void constructSmoother(Input input,const Status* source,Status* status,Work* work,Buffers buffers,TerminalBuffers terminals,unsigned level){
    const auto grid=cooperative_groups::this_grid();const unsigned lane=blockIdx.x*blockDim.x+threadIdx.x;
    if(!lane){
        work->active=0;
        if(!input.accept || *input.accept){
            if(!usable(source) || !sourceCountsValid(input) || source->generation!=*input.generation)status->error=32;
            else if(status->initialized && status->generation>source->generation)status->error=4;
            else if(!status->initialized || status->generation!=source->generation || status->error){status->error=0;work->active=1;}
        }
    }
    grid.sync();if(!work->active)return;input=resolvedInput(input);
    for(unsigned node=lane/32;node<input.nodes;node+=gridDim.x*(blockDim.x/32))buildSmootherRow(input,buffers,terminals,level,status,node);
    grid.sync();if(!lane && !status->error){status->generation=source->generation;status->initialized=1;++status->builds;}
}
class LevelSmoother {
    Input mInput;const Status* mSource;cudaStream_t mStream;Buffers mBuffers{};TerminalBuffers mTerminals;
    Status* mStatus=nullptr;Work* mWork=nullptr;unsigned mLevel,mBlocks=0;bool mOwned=false,mAppended=false;
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident smoother: ")+cudaGetErrorString(e));}
    void release()noexcept{if(mOwned)cudaFree(mBuffers.diagonal);cudaFree(mStatus);cudaFree(mWork);}
public:
    LevelSmoother(Input input,const Graph& graph,const TerminalLevel& terminal,unsigned level,cudaStream_t stream):mInput(input),mSource(terminal.status()),mStream(stream),mTerminals(terminal.buffers()),mLevel(level){
        if(!input.levelBonds){mBuffers.diagonal=graph.buffers().diagonal;return;} // Already produced by the fine operator construction.
        mOwned=true;
        try{
            int device=0,sms=0,blocks=0,cooperative=0;check(cudaGetDevice(&device));check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));
            check(cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device));check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&blocks,constructSmoother,Threads,0));
            if(!cooperative || sms<=0 || blocks<=0)throw std::runtime_error("Resident smoother requires legal cooperative CUDA residency");
            mBlocks=std::min(std::max(1u,(input.nodes+7)/8),unsigned(sms*blocks));
            check(cudaMalloc(&mBuffers.diagonal,std::max(size_t(1),size_t(input.nodes)*DiagonalEntries)*sizeof(double)));
            check(cudaMalloc(&mStatus,sizeof(Status)));check(cudaMalloc(&mWork,sizeof(Work)));check(cudaMemsetAsync(mStatus,0,sizeof(Status),stream));
        }catch(...){release();throw;}
    }
    ~LevelSmoother(){cudaStreamSynchronize(mStream);release();}
    LevelSmoother(const LevelSmoother&)=delete;LevelSmoother& operator=(const LevelSmoother&)=delete;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        if(mAppended)throw std::runtime_error("Resident smoother already appended");mAppended=true;if(!mOwned)return prior;
        void* args[]={&mInput,&mSource,&mStatus,&mWork,&mBuffers,&mTerminals,&mLevel};cudaKernelNodeParams params{};
        params.func=(void*)constructSmoother;params.gridDim=dim3(mBlocks);params.blockDim=dim3(Threads);params.kernelParams=args;
        cudaGraphNode_t node;check(cudaGraphAddKernelNode(&node,graph,&prior,1,&params));cudaKernelNodeAttrValue attribute{};attribute.cooperative=1;
        check(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeCooperative,&attribute));return node;
    }
    Buffers buffers()const{return mBuffers;}
    const Status* status()const{return mOwned?mStatus:mSource;}
};
}}}
