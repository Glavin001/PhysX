// One cooperative launch for a symmetric V-cycle, or its CGLS-required square.
#pragma once
#include "StressHierarchyResident.cuh"
#include "StressHierarchyTransfers.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
__device__ unsigned long long cycleStageClocks[5];
#endif
struct CycleLevel {
    Input input;Buffers topology,diagonal;PackingBuffers child{};
    const Vector* rhs=nullptr;Vector *x=nullptr,*residual=nullptr;
};
// Work ownership changes the schedule only; all sparse numerical operations
// below are shared by cooperative large-component and block-local execution.
template<bool Local> struct CycleWork {
    unsigned component;
    const unsigned* active=nullptr;
    __device__ bool enabled(const Input& a,unsigned node)const {return a.component[node]!=Invalid && (!active || active[a.component[node]]);}
    __device__ unsigned first()const {if constexpr(Local)return threadIdx.x/8;else return (blockIdx.x*blockDim.x+threadIdx.x)/8;}
    __device__ unsigned stride()const {if constexpr(Local)return blockDim.x/8;else return gridDim.x*(blockDim.x/8);}
    __device__ unsigned threadFirst()const {if constexpr(Local)return threadIdx.x;else return blockIdx.x*blockDim.x+threadIdx.x;}
    __device__ unsigned threadStride()const {if constexpr(Local)return blockDim.x;else return gridDim.x*blockDim.x;}
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
    for(unsigned index=work.threadFirst();index<work.count(d.input);index+=work.threadStride()){
        const unsigned node=work.node(d.input,index);
        if(!work.enabled(d.input,node)){d.x[node]={};continue;}
        if(!smoothedNode(d,pool,level,node))continue;
        d.x[node]=mul(solveFineDiagonalThread(d.diagonal,node,d.rhs[node]),.5);
    }
}
template<bool Local>
__device__ __forceinline__ void cycleResidual(CycleLevel d,TerminalBuffers pool,unsigned level,CycleWork<Local> work){
    const unsigned lane=threadIdx.x&7u;
    for(unsigned index=work.first();index<work.count(d.input);index+=work.stride()){
        const unsigned node=work.node(d.input,index);
        Vector a{},b{},c{},e{};if(work.enabled(d.input,node) && smoothedNode(d,pool,level,node)){
            a=levelRowContribution(d.input,node,d.x,lane);b=levelRowContribution(d.input,node,d.x,lane+8);
            c=levelRowContribution(d.input,node,d.x,lane+16);e=levelRowContribution(d.input,node,d.x,lane+24);}
        const auto value=sumVirtualWarp(a,b,c,e);if(!lane)d.residual[node]=work.enabled(d.input,node) && smoothedNode(d,pool,level,node)?sub(d.rhs[node],value):Vector{};
    }
}
template<bool Local>
__device__ __forceinline__ void cycleRestrict(CycleLevel parent,Vector* childRhs,CycleWork<Local> work){
    const unsigned lane=threadIdx.x&7u;
    for(unsigned index=work.first();index<work.childCount(parent.child);index+=work.stride()){
        const unsigned node=work.childNode(parent.child,index);
        Vector a{},b{},c{},e{};if(!work.active || work.active[parent.child.component[node]]){
            const unsigned root=parent.child.nodeSource[node];
            a=restrictPackedContribution(parent.input,parent.topology,root,parent.residual,lane);
            b=restrictPackedContribution(parent.input,parent.topology,root,parent.residual,lane+8);
            c=restrictPackedContribution(parent.input,parent.topology,root,parent.residual,lane+16);
            e=restrictPackedContribution(parent.input,parent.topology,root,parent.residual,lane+24);}
        const auto value=sumVirtualWarp(a,b,c,e);if(!lane)childRhs[node]=value;
    }
}
// B H^T e, where H=P^T B was retained during construction. Evaluating
// this directly avoids expanding Pe and then rediscovering its strain through
// L(Pe), which loses small differences between large fine coordinates.
__device__ __forceinline__ Vector cycleCoarseEffect(CycleLevel parent,unsigned node,const Vector* childX,unsigned lane=threadIdx.x&31u){
    Vector sum{};
    for(unsigned slot=parent.input.begin[node]+lane;slot<parent.input.begin[node+1];slot+=32){
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
    const unsigned lane=threadIdx.x&7u;
    for(unsigned index=work.first();index<work.count(d.input);index+=work.stride()){
        const unsigned node=work.node(d.input,index);
        if(!work.enabled(d.input,node) || !smoothedNode(d,pool,level,node))continue;
        const auto a=cycleCoarseEffect(d,node,childX,lane),b=cycleCoarseEffect(d,node,childX,lane+8);
        const auto c=cycleCoarseEffect(d,node,childX,lane+16),e=cycleCoarseEffect(d,node,childX,lane+24);
        const auto effect=sumVirtualWarp(a,b,c,e);
        // Finish the original warp reduction before handing independent
        // diagonal systems to individual threads. This residual is dead after
        // correction, so it is also the scratch for the producer/consumer handoff.
        if(!lane)d.residual[node]=sub(d.residual[node],effect);
    }
    work.sync();
    for(unsigned index=work.threadFirst();index<work.count(d.input);index+=work.threadStride()){
        const unsigned node=work.node(d.input,index);
        if(!work.enabled(d.input,node) || !smoothedNode(d,pool,level,node))continue;
        const auto post=mul(solveFineDiagonalThread(d.diagonal,node,d.residual[node]),.5);
        Vector correction{};const unsigned root=d.topology.leader[node];
        if(root!=Invalid && d.child.nodeMap[root]!=Invalid)correction=prolongValue(childX[d.child.nodeMap[root]],shift(d.input,node,root),sourceInertia(d.input,node));
        d.x[node]=add(add(d.x[node],post),correction);
    }
}
template<bool Local>
__device__ __forceinline__ void cyclePostsmooth(CycleLevel d,TerminalBuffers pool,unsigned level,CycleWork<Local> work){
    for(unsigned index=work.threadFirst();index<work.count(d.input);index+=work.threadStride()){
        const unsigned node=work.node(d.input,index);
        if(!work.enabled(d.input,node) || !smoothedNode(d,pool,level,node))continue;
        const auto correction=mul(solveFineDiagonalThread(d.diagonal,node,d.residual[node]),.5);
        d.x[node]=add(d.x[node],correction);
    }
}
template<bool Local=false>
__device__ __forceinline__ void cyclePass(const CycleLevel* levels,unsigned depth,TerminalBuffers pool,TerminalShared& shared,const Vector* rhs,Vector* output,unsigned component=Invalid,const unsigned* active=nullptr){
    CycleWork<Local> work{component,active};unsigned last=0;
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
    unsigned long long phaseStart=0;if(!threadIdx.x)phaseStart=clock64();
#define CYCLE_PROBE_END(index) work.sync();if(!threadIdx.x){atomicAdd(cycleStageClocks+index,clock64()-phaseStart);phaseStart=clock64();}work.sync();
#else
#define CYCLE_PROBE_END(index)
#endif
    for(unsigned level=0;level<depth;++level){
        auto d=cycleView(levels,level,rhs,output);last=level;
        cyclePresmooth(d,pool,level,work);
        CYCLE_PROBE_END(0)
        // Presmoothing skips terminal rows; these writes are disjoint and need
        // no global barrier between the two producer stages.
        if constexpr(Local)solveTerminalComponent(d.input,pool,shared,component,level,d.rhs,d.x);
        else for(unsigned i=blockIdx.x;i<*d.input.partition.count;i+=gridDim.x){
            const unsigned id=d.input.partition.ids[i];
            if(!active || active[id])solveTerminalComponent(d.input,pool,shared,id,level,d.rhs,d.x);__syncthreads();
        }
        work.sync();
        CYCLE_PROBE_END(1)
        if(level+1==depth || (Local?pool.owner[component]==level:!d.child.counts[0]))break;
        cycleResidual(d,pool,level,work);work.sync();
        CYCLE_PROBE_END(2)
        cycleRestrict(d,const_cast<Vector*>(levels[level+1].rhs),work);work.sync();
        CYCLE_PROBE_END(3)
    }
    for(int level=int(last);level>=0;--level){
        auto d=cycleView(levels,unsigned(level),rhs,output);
        if(unsigned(level)<last){cycleCorrectAndSmooth(d,pool,unsigned(level),levels[level+1].x,work);work.sync();}
        else {cycleResidual(d,pool,unsigned(level),work);work.sync();cyclePostsmooth(d,pool,unsigned(level),work);work.sync();}
        CYCLE_PROBE_END(4)
    }
#undef CYCLE_PROBE_END
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
struct CycleDeviceView {const CycleLevel* levels=nullptr;unsigned depth=0;TerminalBuffers pool{};const Status* status=nullptr;Vector* intermediate=nullptr;};
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
    CycleDeviceView deviceView()const{return {mDevice,mHierarchy.levels(),mHierarchy.terminalBuffers(),mHierarchy.status(),mIntermediate};}
    void apply(const Vector* rhs,Vector* result)const{launch<1>(rhs,result);}
    void applySquared(const Vector* rhs,Vector* result)const{launch<2>(rhs,result);}
    void applyComponents(const Vector* rhs,Vector* result)const{launchComponents<1>(rhs,result);}
    void applyComponentsSquared(const Vector* rhs,Vector* result)const{launchComponents<2>(rhs,result);}
};
}}}
