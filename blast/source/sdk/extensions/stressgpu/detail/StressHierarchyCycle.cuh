// One cooperative launch for a symmetric V-cycle, or its CGLS-required square.
#pragma once
#include "StressHierarchyResident.cuh"
#include "StressHierarchyTransfers.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
struct CycleLevel {
    Input input;Buffers topology,diagonal;PackingBuffers child{};
    const Vector* rhs=nullptr;Vector *x=nullptr,*residual=nullptr;
};
__device__ __forceinline__ CycleLevel cycleView(const CycleLevel* levels,unsigned index,const Vector* rhs,Vector* output){
    CycleLevel level=levels[index];if(!index){level.rhs=rhs;level.x=output;}level.input=resolvedInput(level.input);return level;
}
__device__ __forceinline__ bool smoothedNode(const CycleLevel& d,TerminalBuffers pool,unsigned level,unsigned node){
    return d.input.component[node]!=Invalid && pool.owner[d.input.component[node]]!=level;
}
__device__ __forceinline__ void cyclePresmooth(CycleLevel d,TerminalBuffers pool,unsigned level){
    const unsigned lane=threadIdx.x&31u,first=(blockIdx.x*blockDim.x+threadIdx.x)/32,stride=gridDim.x*(blockDim.x/32);
    for(unsigned node=first;node<d.input.nodes;node+=stride){
        if(d.input.component[node]==Invalid){if(!lane)d.x[node]={};continue;}
        if(!smoothedNode(d,pool,level,node))continue;
        const auto value=mul(solveFineDiagonal(d.diagonal,node,d.rhs[node]),.5);if(!lane)d.x[node]=value;
    }
}
__device__ __forceinline__ void cycleResidual(CycleLevel d,TerminalBuffers pool,unsigned level){
    const unsigned lane=threadIdx.x&31u,first=(blockIdx.x*blockDim.x+threadIdx.x)/32,stride=gridDim.x*(blockDim.x/32);
    for(unsigned node=first;node<d.input.nodes;node+=stride){
        Vector value{};if(smoothedNode(d,pool,level,node))value=levelRowContribution(d.input,node,d.x);
        value=warpSum(value);if(!lane)d.residual[node]=smoothedNode(d,pool,level,node)?sub(d.rhs[node],value):Vector{};
    }
}
__device__ __forceinline__ void cycleRestrict(CycleLevel parent,Vector* childRhs){
    const unsigned lane=threadIdx.x&31u,first=(blockIdx.x*blockDim.x+threadIdx.x)/32,stride=gridDim.x*(blockDim.x/32);
    for(unsigned node=first;node<parent.child.counts[0];node+=stride){
        auto value=restrictPackedContribution(parent.input,parent.topology,parent.child.nodeSource[node],parent.residual);
        value=warpSum(value);if(!lane)childRhs[node]=value;
    }
}
// B H^T e, where H=P^T B was retained during construction. Evaluating
// this directly avoids expanding Pe and then rediscovering its strain through
// L(Pe), which loses small differences between large fine coordinates.
__device__ __forceinline__ Vector cycleCoarseEffect(CycleLevel parent,unsigned node,const Vector* childX){
    Vector sum{};
    for(unsigned slot=parent.input.begin[node]+(threadIdx.x&31u);slot<parent.input.begin[node+1];slot+=32){
        const unsigned ref=parent.input.refs[slot];if(ref==Invalid)continue;const unsigned edge=ref&0x7fffffffu;
        const auto e=parent.topology.coarse[edge];if(!retainedColumn(e))continue;
        Vector a{},b{},difference{};
        if(e.a!=Invalid && parent.child.nodeMap[e.a]!=Invalid)a=childX[parent.child.nodeMap[e.a]];
        if(e.b!=Invalid && parent.child.nodeMap[e.b]!=Invalid)b=childX[parent.child.nodeMap[e.b]];
        if(e.a==e.b)difference={make_double3(0,0,0),cross(sub(e.offset0,e.offset1),a.angular)};
        else difference=sub(couple(a,e.offset0),couple(b,e.offset1));
        const bool back=ref>>31;const auto flux=mul(difference,e.scale*sourceScale(parent.input,edge)*(back?-1.:1.));
        sum=add(sum,scaledValue(transposeCouple(flux,sourceOffset(parent.input,edge,back)),sourceInertia(parent.input,node)));
    }
    return sum;
}
__device__ __forceinline__ void cycleCorrectAndSmooth(CycleLevel d,TerminalBuffers pool,unsigned level,const Vector* childX){
    const unsigned lane=threadIdx.x&31u,first=(blockIdx.x*blockDim.x+threadIdx.x)/32,stride=gridDim.x*(blockDim.x/32);
    for(unsigned node=first;node<d.input.nodes;node+=stride){
        if(!smoothedNode(d,pool,level,node))continue;
        auto effect=warpSum(cycleCoarseEffect(d,node,childX));
        // warpSum's complete result lives in lane zero. The diagonal solver
        // consumes a different coordinate in each lane, so broadcast first.
        effect={{__shfl_sync(0xffffffffu,effect.angular.x,0),__shfl_sync(0xffffffffu,effect.angular.y,0),__shfl_sync(0xffffffffu,effect.angular.z,0)},
                {__shfl_sync(0xffffffffu,effect.linear.x,0),__shfl_sync(0xffffffffu,effect.linear.y,0),__shfl_sync(0xffffffffu,effect.linear.z,0)}};
        const auto post=mul(solveFineDiagonal(d.diagonal,node,sub(d.residual[node],effect)),.5);
        if(!lane){Vector correction{};const unsigned root=d.topology.leader[node];
            if(root!=Invalid && d.child.nodeMap[root]!=Invalid)correction=prolongValue(childX[d.child.nodeMap[root]],shift(d.input,node,root),sourceInertia(d.input,node));
            d.x[node]=add(add(d.x[node],post),correction);
        }
    }
}
__device__ __forceinline__ void cyclePostsmooth(CycleLevel d,TerminalBuffers pool,unsigned level){
    const unsigned lane=threadIdx.x&31u,first=(blockIdx.x*blockDim.x+threadIdx.x)/32,stride=gridDim.x*(blockDim.x/32);
    for(unsigned node=first;node<d.input.nodes;node+=stride){
        if(!smoothedNode(d,pool,level,node))continue;
        const auto correction=mul(solveFineDiagonal(d.diagonal,node,d.residual[node]),.5);
        if(!lane)d.x[node]=add(d.x[node],correction);
    }
}
__device__ __forceinline__ void cyclePass(const CycleLevel* levels,unsigned depth,TerminalBuffers pool,TerminalShared& shared,const Vector* rhs,Vector* output){
    const auto grid=cooperative_groups::this_grid();unsigned last=0;
    for(unsigned level=0;level<depth;++level){
        auto d=cycleView(levels,level,rhs,output);last=level;
        cyclePresmooth(d,pool,level);
        // Presmoothing skips terminal rows; these writes are disjoint and need
        // no global barrier between the two producer stages.
        for(unsigned i=blockIdx.x;i<*d.input.partition.count;i+=gridDim.x){
            solveTerminalComponent(d.input,pool,shared,d.input.partition.ids[i],level,d.rhs,d.x);__syncthreads();
        }
        grid.sync();
        if(level+1==depth || !d.child.counts[0])break;
        cycleResidual(d,pool,level);grid.sync();
        cycleRestrict(d,const_cast<Vector*>(levels[level+1].rhs));grid.sync();
    }
    for(int level=int(last);level>=0;--level){
        auto d=cycleView(levels,unsigned(level),rhs,output);
        if(unsigned(level)<last){cycleCorrectAndSmooth(d,pool,unsigned(level),levels[level+1].x);grid.sync();}
        else {cycleResidual(d,pool,unsigned(level));grid.sync();cyclePostsmooth(d,pool,unsigned(level));grid.sync();}
    }
}
template<unsigned Passes>
__global__ void applyCycle(const CycleLevel* levels,unsigned depth,TerminalBuffers pool,const Status* status,const Vector* rhs,Vector* output,Vector* intermediate){
    static_assert(Passes==1 || Passes==2,"CGLS uses the square of the symmetric cycle");
    __shared__ TerminalShared shared;
    if(!usable(status) || status->generation!=*levels[0].input.generation)return;
    if constexpr(Passes==2){cyclePass(levels,depth,pool,shared,rhs,intermediate);cyclePass(levels,depth,pool,shared,intermediate,output);}
    else cyclePass(levels,depth,pool,shared,rhs,output);
}
class ResidentCycle {
    const ResidentHierarchy& mHierarchy;cudaStream_t mStream;std::vector<CycleLevel> mHost;
    CycleLevel* mDevice=nullptr;Vector* mIntermediate=nullptr;unsigned mBlocks[2]{};
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident cycle: ")+cudaGetErrorString(e));}
    static Vector* allocate(unsigned count){Vector* p=nullptr;check(cudaMalloc(&p,std::max(size_t(1),size_t(count))*sizeof(Vector)));return p;}
    void release()noexcept{for(auto& d:mHost){cudaFree(const_cast<Vector*>(d.rhs));cudaFree(d.x);cudaFree(d.residual);}cudaFree(mIntermediate);cudaFree(mDevice);}
    template<unsigned Passes>unsigned blocks()const{
        int device=0,sms=0,resident=0,cooperative=0;check(cudaGetDevice(&device));check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));
        check(cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device));check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&resident,applyCycle<Passes>,Threads,0));
        if(!cooperative || sms<=0 || resident<=0)throw std::runtime_error("Resident cycle requires legal cooperative CUDA residency");
        return std::min(std::max(1u,(mHierarchy.input(0).nodes+7)/8),unsigned(sms*resident));
    }
    template<unsigned Passes>void launch(const Vector* rhs,Vector* result)const{
        if(!rhs || !result || rhs==result)throw std::runtime_error("Resident cycle requires distinct device input and output vectors");
        auto* descriptors=mDevice;auto pool=mHierarchy.terminalBuffers();auto* status=mHierarchy.status();auto* intermediate=mIntermediate;unsigned depth=mHierarchy.levels();
        void* args[]={&descriptors,&depth,&pool,&status,&rhs,&result,&intermediate};
        check(cudaLaunchCooperativeKernel((void*)applyCycle<Passes>,dim3(mBlocks[Passes-1]),dim3(Threads),args,0,mStream));
    }
public:
    explicit ResidentCycle(const ResidentHierarchy& hierarchy):mHierarchy(hierarchy),mStream(hierarchy.stream()){
        mHost.resize(hierarchy.levels());
        try{
            for(unsigned i=0;i<hierarchy.levels();++i){auto& d=mHost[i];d.input=hierarchy.input(i);d.topology=hierarchy.topology(i).buffers();d.diagonal=hierarchy.smoother(i).buffers();
                if(i+1<hierarchy.levels())d.child=hierarchy.packed(i).buffers();
                if(i){d.rhs=allocate(d.input.nodes);d.x=allocate(d.input.nodes);}d.residual=allocate(d.input.nodes);
            }
            mIntermediate=allocate(hierarchy.input(0).nodes);check(cudaMalloc(&mDevice,mHost.size()*sizeof(CycleLevel)));
            check(cudaMemcpyAsync(mDevice,mHost.data(),mHost.size()*sizeof(CycleLevel),cudaMemcpyHostToDevice,mStream));mBlocks[0]=blocks<1>();mBlocks[1]=blocks<2>();
        }catch(...){release();throw;}
    }
    ~ResidentCycle(){cudaStreamSynchronize(mStream);release();}
    ResidentCycle(const ResidentCycle&)=delete;ResidentCycle& operator=(const ResidentCycle&)=delete;
    void apply(const Vector* rhs,Vector* result)const{launch<1>(rhs,result);}
    void applySquared(const Vector* rhs,Vector* result)const{launch<2>(rhs,result);}
};
}}}
