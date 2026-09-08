#include "StressNativeNullspace.cuh"
#include "StressNativeFineInverse.cuh"
#include "StressNativePolynomial.cuh"
// Shared projected-CG/preconditioner boundary. Conversion is fused into the
// resident producer/consumer, not a separate export/copy/reimport operation.
__device__ __forceinline__ bool nativeHierarchyReady(const NativeStressCycleView& h){
    return h.cycle.status && h.modes.status && h.topology && StressHierarchy::usable(h.modes.status) && h.modes.status->generation==h.topology->generation && h.topology->initialized && !h.topology->error
        && StressHierarchy::usable(h.cycle.status) && h.cycle.status->generation==h.topology->generation;
}
__device__ __forceinline__ void nativeCycleRhs(const PersistentStressArgs& a,unsigned node){
    const auto w=a.m_residual[node];a.hierarchy.rhs[node]={{w.angular.x,w.angular.y,w.angular.z},{w.linear.x,w.linear.y,w.linear.z}};
}
__device__ __forceinline__ void storeNativeProjectedResidual(const PersistentStressArgs& a,unsigned node){
    const auto v=a.hierarchy.rhs[node];const AngLin r{{float(v.angular.x),float(v.angular.y),float(v.angular.z),0},{float(v.linear.x),float(v.linear.y),float(v.linear.z),0}};
    a.m_residual[node]=r;a.hierarchy.rhs[node]={{r.angular.x,r.angular.y,r.angular.z},{r.linear.x,r.linear.y,r.linear.z}};
}
// Keep the iterative residual on the same quotient as the directions. This
// removes only null motion, not a stress load; otherwise roundoff-sized null
// components can prevent a warm-started zero load from converging exactly.
__device__ __forceinline__ void prepareNativeResidualComponent(const PersistentStressArgs& a,const unsigned* nodes,unsigned count,unsigned id){
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)nativeCycleRhs(a,nodes[i]);__syncthreads();
    // A fully anchored component has no null motion to project. Its RHS is
    // already the exact FP64 promotion of the FP32 residual. Rewriting both
    // through FP32 would reproduce the same values, so omit that round trip
    // and its trailing barrier. Free components retain the full projection.
    // The mode certificate belongs to the current validated topology above.
    if(!StressHierarchy::motionDimension(a.hierarchy.modes.components[id]))return;
    projectNativeNullspace(a,id,nodes,count,a.hierarchy.rhs);
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)storeNativeProjectedResidual(a,nodes[i]);__syncthreads();
}
__device__ __forceinline__ void prepareNativeResidualGrid(const PersistentStressArgs& a,const unsigned* selected=nullptr){
    const auto grid=cooperative_groups::this_grid();const unsigned first=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const auto node=a.m_activeNodes[i];if(a.m_islandActive[a.m_nodeIsland[node]] && (!selected || selected[a.m_nodeIsland[node]]))nativeCycleRhs(a,node);}
    grid.sync();projectNativeNullspacesGrid(a,a.hierarchy.rhs,selected);
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const auto node=a.m_activeNodes[i];if(a.m_islandActive[a.m_nodeIsland[node]] && (!selected || selected[a.m_nodeIsland[node]]))storeNativeProjectedResidual(a,node);}grid.sync();
}
__device__ __forceinline__ double nativeCycleMagnitude(StressHierarchy::Vector v){
    return fmax(fmax(fabs(v.angular.x),fabs(v.angular.y)),fmax(fabs(v.angular.z),fmax(fabs(v.linear.x),fmax(fabs(v.linear.y),fabs(v.linear.z)))));
}
__device__ __forceinline__ double nativeComponentMaximum(double value){
    __shared__ double partial[kBlockSize/32];for(unsigned step=16;step;step>>=1)value=fmax(value,__shfl_down_sync(0xffffffffu,value,step));
    if(!(threadIdx.x&31u))partial[threadIdx.x/32]=value;__syncthreads();
    if(!threadIdx.x){double maximum=0;for(unsigned i=0;i<kBlockSize/32;++i)maximum=fmax(maximum,partial[i]);partial[0]=maximum;}
    __syncthreads();value=partial[0];__syncthreads();return value;
}
__device__ __forceinline__ float nativeCycleResult(const PersistentStressArgs& a,unsigned node,unsigned id,double magnitude,const StressHierarchy::Vector* result){
    if(!(magnitude>0) || !isfinite(magnitude)){atomicExch(a.hierarchy.failed+id,1u);return 0;}
    const auto v=StressHierarchy::mul(result[node],1/magnitude);
    const AngLin g{{float(v.angular.x),float(v.angular.y),float(v.angular.z),0},{float(v.linear.x),float(v.linear.y),float(v.linear.z),0}};
    const auto w=a.hierarchy.rhs[node];a.hierarchy.g[node]=g;
    const float gamma=w.angular.x*g.angular.x+w.angular.y*g.angular.y+w.angular.z*g.angular.z
        +w.linear.x*g.linear.x+w.linear.y*g.linear.y+w.linear.z*g.linear.z;
    if(!isfinite(gamma))atomicExch(a.hierarchy.failed+id,1u);
    return stressSquaredContribution(gamma);
}
__device__ __forceinline__ float preconditionNativeComponent(const PersistentStressArgs& a,
    const unsigned* nodes,unsigned count,unsigned id,unsigned iteration COMPONENT_SUBPROBE_PARAMETER){
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
    unsigned long long subStart=0;if(!threadIdx.x)subStart=clock64();
#define SUBPROBE_END(index) __syncthreads();if(!threadIdx.x){subProbe[index]+=clock64()-subStart;subStart=clock64();}__syncthreads();
#else
#define SUBPROBE_END(index)
#endif
    // Begin with a projected steepest-descent step. It is exact for a single
    // mode and costs no hierarchy traversal. If further work is needed, restart
    // PCG with the fixed block preconditioner on iteration one; never mix preconditioners
    // in the conjugacy recurrence.
    auto* result=a.hierarchy.result;
    if(!iteration){for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)a.hierarchy.result[nodes[i]]=a.hierarchy.rhs[nodes[i]];__syncthreads();}
    else {
        // Apply the fixed polynomial using cached local inverses.
        // Large components retain their cooperative multilevel schedule.
        result=preconditionNativePolynomial(a,nodes,count);
    }
    SUBPROBE_END(0)
    projectNativeNullspace(a,id,nodes,count,result);
    SUBPROBE_END(1)
    double magnitude=0;for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)magnitude=fmax(magnitude,nativeCycleMagnitude(result[nodes[i]]));
    magnitude=nativeComponentMaximum(magnitude);
    SUBPROBE_END(2)
    // A positive per-component scaling of g cancels in PCG's beta/alpha.
    // Normalize before conversion to float so a tiny residual does not flush
    // gamma or direction energy while the original convergence norm is live.
    float gamma=0;for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)gamma+=nativeCycleResult(a,nodes[i],id,magnitude,result);
    SUBPROBE_END(3)
#undef SUBPROBE_END
    return gamma;
}
// PCG keeps directions in node space. q is then evaluated directly as L*p;
// its energy comes from the same bond gather, avoiding a drifting q recurrence
// and a second operator product of the preconditioned vector.
__device__ __forceinline__ void updateNativeDirection(const PersistentStressArgs& a,unsigned node,unsigned id,unsigned iteration){
    if(!a.m_islandActive[id])return;
    const float previous=a.hierarchy.previous[id],beta=iteration>1 && previous>0?a.hierarchy.gamma[id]/previous:0;
    a.m_nsPi[node].angular=add(a.hierarchy.g[node].angular,mul(a.m_nsPi[node].angular,beta));
    a.m_nsPi[node].linear=add(a.hierarchy.g[node].linear,mul(a.m_nsPi[node].linear,beta));
}
__device__ __forceinline__ void preconditionNativeGrid(const PersistentStressArgs& a,StressHierarchy::TerminalShared& shared){
    const auto grid=cooperative_groups::this_grid();const unsigned first=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    const auto v=a.hierarchy.cycle;
    if(!*a.m_iteration){
        for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const unsigned node=a.m_activeNodes[i];if(a.m_islandActive[a.m_nodeIsland[node]])a.hierarchy.result[node]=a.hierarchy.rhs[node];}grid.sync();
    }else StressHierarchy::cyclePass(v.levels,v.depth,v.pool,shared,a.hierarchy.rhs,a.hierarchy.result,StressHierarchy::Invalid,a.m_islandActive);
    projectNativeNullspacesGrid(a,a.hierarchy.result);
    const unsigned islands=*a.liveIslandCount;
    for(unsigned i=first;i<islands;i+=stride)a.hierarchy.normalizer[a.islandIds[i]]=0;
    grid.sync();
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const auto node=a.m_activeNodes[i],id=a.m_nodeIsland[node];if(a.m_islandActive[id]){
        const double magnitude=nativeCycleMagnitude(a.hierarchy.result[node]);
        if(!isfinite(magnitude))atomicExch(a.hierarchy.failed+id,1u);
        else atomicMax(reinterpret_cast<unsigned long long*>(a.hierarchy.normalizer)+id,__double_as_longlong(magnitude));}}
    grid.sync();
    for(unsigned i=first;i<islands*a.slots;i+=stride)a.m_reduceSlots[a.islandIds[i/a.slots]*a.slots+i%a.slots]=0;
    grid.sync();
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const unsigned node=a.m_activeNodes[i],id=a.m_nodeIsland[node];
        if(a.m_islandActive[id])atomicAdd(a.m_reduceSlots+id*a.slots+(i&(a.slots-1)),nativeCycleResult(a,node,id,a.hierarchy.normalizer[id],a.hierarchy.result));}
    grid.sync();
    for(unsigned i=first;i<islands;i+=stride){const unsigned id=a.islandIds[i];const float value=sumIslandPartials(a.m_reduceSlots,id,a.slots,nullptr);a.hierarchy.gamma[id]=value;
        if(a.m_islandActive[id] && (!(value>0) || !isfinite(value)))a.hierarchy.failed[id]=1;}
    grid.sync();
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const unsigned node=a.m_activeNodes[i],id=a.m_nodeIsland[node];updateNativeDirection(a,node,id,*a.m_iteration);}
    grid.sync();
}
