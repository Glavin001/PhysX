// One cooperative launch for a symmetric V-cycle, or its CGLS-required square.
#pragma once
#include "StressHierarchyResident.cuh"
#include "StressHierarchyTransfers.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
struct CycleLevel {
    Input input;Buffers topology,diagonal;PackingBuffers child{};
    const Vector* rhs=nullptr;Vector *x=nullptr,*residual=nullptr;
};
// Work ownership changes the schedule only; all sparse numerical operations
// below are shared by cooperative large-component and block-local execution.
template<bool Local> struct CycleWork {
    unsigned component;
    __device__ unsigned first()const {if constexpr(Local)return threadIdx.x/32;else return (blockIdx.x*blockDim.x+threadIdx.x)/32;}
    __device__ unsigned stride()const {if constexpr(Local)return blockDim.x/32;else return gridDim.x*(blockDim.x/32);}
    __device__ unsigned count(const Input& a)const {if constexpr(Local)return a.partition.end[component]-a.partition.begin[component];else return a.nodes;}
    __device__ unsigned node(const Input& a,unsigned i)const {if constexpr(Local)return orderedNode(a,a.partition.begin[component]+i);else return i;}
    __device__ unsigned childCount(const PackingBuffers& b)const {if constexpr(Local)return b.componentEnd[component]-b.componentBegin[component];else return b.counts[0];}
    __device__ unsigned childNode(const PackingBuffers& b,unsigned i)const {if constexpr(Local)return b.componentBegin[component]+i;else return i;}
    __device__ void sync()const {if constexpr(Local)__syncthreads();else cooperative_groups::this_grid().sync();}
};
__device__ __forceinline__ CycleLevel cycleView(const CycleLevel* levels,unsigned index,const Vector* rhs,Vector* output){
    CycleLevel level=levels[index];if(!index){level.rhs=rhs;level.x=output;}level.input=resolvedInput(level.input);return level;
}
__device__ __forceinline__ bool smoothedNode(const CycleLevel& d,TerminalBuffers pool,unsigned level,unsigned node){
    return d.input.component[node]!=Invalid && pool.owner[d.input.component[node]]!=level;
}
template<bool Local>
__device__ __forceinline__ void cyclePresmooth(CycleLevel d,TerminalBuffers pool,unsigned level,CycleWork<Local> work){
    const unsigned lane=threadIdx.x&31u;
    for(unsigned index=work.first();index<work.count(d.input);index+=work.stride()){
        const unsigned node=work.node(d.input,index);
        if(d.input.component[node]==Invalid){if(!lane)d.x[node]={};continue;}
        if(!smoothedNode(d,pool,level,node))continue;
        const auto value=mul(solveFineDiagonal(d.diagonal,node,d.rhs[node]),.5);if(!lane)d.x[node]=value;
    }
}
template<bool Local>
__device__ __forceinline__ void cycleResidual(CycleLevel d,TerminalBuffers pool,unsigned level,CycleWork<Local> work){
    const unsigned lane=threadIdx.x&31u;
    for(unsigned index=work.first();index<work.count(d.input);index+=work.stride()){
        const unsigned node=work.node(d.input,index);
        Vector value{};if(smoothedNode(d,pool,level,node))value=levelRowContribution(d.input,node,d.x);
        value=warpSum(value);if(!lane)d.residual[node]=smoothedNode(d,pool,level,node)?sub(d.rhs[node],value):Vector{};
    }
}
template<bool Local>
__device__ __forceinline__ void cycleRestrict(CycleLevel parent,Vector* childRhs,CycleWork<Local> work){
    const unsigned lane=threadIdx.x&31u;
    for(unsigned index=work.first();index<work.childCount(parent.child);index+=work.stride()){
        const unsigned node=work.childNode(parent.child,index);
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
template<bool Local>
__device__ __forceinline__ void cycleCorrectAndSmooth(CycleLevel d,TerminalBuffers pool,unsigned level,const Vector* childX,CycleWork<Local> work){
    const unsigned lane=threadIdx.x&31u;
    for(unsigned index=work.first();index<work.count(d.input);index+=work.stride()){
        const unsigned node=work.node(d.input,index);
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
template<bool Local>
__device__ __forceinline__ void cyclePostsmooth(CycleLevel d,TerminalBuffers pool,unsigned level,CycleWork<Local> work){
    const unsigned lane=threadIdx.x&31u;
    for(unsigned index=work.first();index<work.count(d.input);index+=work.stride()){
        const unsigned node=work.node(d.input,index);
        if(!smoothedNode(d,pool,level,node))continue;
        const auto correction=mul(solveFineDiagonal(d.diagonal,node,d.residual[node]),.5);
        if(!lane)d.x[node]=add(d.x[node],correction);
    }
}
template<bool Local=false>
__device__ __forceinline__ void cyclePass(const CycleLevel* levels,unsigned depth,TerminalBuffers pool,TerminalShared& shared,const Vector* rhs,Vector* output,unsigned component=Invalid){
    CycleWork<Local> work{component};unsigned last=0;
    for(unsigned level=0;level<depth;++level){
        auto d=cycleView(levels,level,rhs,output);last=level;
        cyclePresmooth(d,pool,level,work);
        // Presmoothing skips terminal rows; these writes are disjoint and need
        // no global barrier between the two producer stages.
        if constexpr(Local)solveTerminalComponent(d.input,pool,shared,component,level,d.rhs,d.x);
        else for(unsigned i=blockIdx.x;i<*d.input.partition.count;i+=gridDim.x){
            solveTerminalComponent(d.input,pool,shared,d.input.partition.ids[i],level,d.rhs,d.x);__syncthreads();
        }
        work.sync();
        if(level+1==depth || (Local?pool.owner[component]==level:!d.child.counts[0]))break;
        cycleResidual(d,pool,level,work);work.sync();
        cycleRestrict(d,const_cast<Vector*>(levels[level+1].rhs),work);work.sync();
    }
    for(int level=int(last);level>=0;--level){
        auto d=cycleView(levels,unsigned(level),rhs,output);
        if(unsigned(level)<last){cycleCorrectAndSmooth(d,pool,unsigned(level),levels[level+1].x,work);work.sync();}
        else {cycleResidual(d,pool,unsigned(level),work);work.sync();cyclePostsmooth(d,pool,unsigned(level),work);work.sync();}
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
// Qualification launch for the block-local body that native per-component
// CGLS can call inside its resident loop, without another kernel launch.
template<unsigned Passes>
__global__ void applyComponentCycles(const CycleLevel* levels,unsigned depth,TerminalBuffers pool,const Status* status,const Vector* rhs,Vector* output,Vector* intermediate){
    __shared__ TerminalShared shared;
    if(!usable(status) || status->generation!=*levels[0].input.generation)return;
    const auto input=levels[0].input;
    // Fixed boundaries are never read by the sparse operator. These disjoint
    // observation writes therefore need no cross-component barrier.
    for(unsigned i=blockIdx.x*blockDim.x+threadIdx.x;i<input.nodes;i+=gridDim.x*blockDim.x)
        if(input.component[i]==Invalid){output[i]={};if constexpr(Passes==2)intermediate[i]={};}
    for(unsigned slot=blockIdx.x;slot<*input.partition.count;slot+=gridDim.x){
        const unsigned id=input.partition.ids[slot];
        if constexpr(Passes==2){cyclePass<true>(levels,depth,pool,shared,rhs,intermediate,id);cyclePass<true>(levels,depth,pool,shared,intermediate,output,id);}
        else cyclePass<true>(levels,depth,pool,shared,rhs,output,id);
        __syncthreads();
    }
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
    template<unsigned Passes>void launchComponents(const Vector* rhs,Vector* result)const{
        if(!rhs || !result || rhs==result)throw std::runtime_error("Resident cycle requires distinct device input and output vectors");
        applyComponentCycles<Passes><<<mBlocks[Passes-1],Threads,0,mStream>>>(mDevice,mHierarchy.levels(),mHierarchy.terminalBuffers(),mHierarchy.status(),rhs,result,mIntermediate);
        check(cudaGetLastError());
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
    void applyComponents(const Vector* rhs,Vector* result)const{launchComponents<1>(rhs,result);}
    void applyComponentsSquared(const Vector* rhs,Vector* result)const{launchComponents<2>(rhs,result);}
};
}}}
