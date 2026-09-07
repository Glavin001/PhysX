#include "StressNativeNullspace.cuh"
// Shared native CGLS/preconditioner boundary. Conversion is fused into the
// resident producer/consumer, not a separate export/copy/reimport operation.
__device__ __forceinline__ bool nativeHierarchyReady(const NativeStressCycleView& h){
    return h.cycle.status && h.topology && h.topology->initialized && !h.topology->error
        && StressHierarchy::usable(h.cycle.status) && h.cycle.status->generation==h.topology->generation;
}
__device__ __forceinline__ void nativeCycleRhs(const PersistentStressArgs& a,unsigned node){
    const auto w=a.m_nsW[node];a.hierarchy.rhs[node]={{w.angular.x,w.angular.y,w.angular.z},{w.linear.x,w.linear.y,w.linear.z}};
}
__device__ __forceinline__ float nativeCycleResult(const PersistentStressArgs& a,unsigned node,unsigned id){
    const auto v=a.hierarchy.result[node];
    const AngLin g{{float(v.angular.x),float(v.angular.y),float(v.angular.z),0},{float(v.linear.x),float(v.linear.y),float(v.linear.z),0}};
    const auto w=a.m_nsW[node];a.hierarchy.g[node]=g;
    const float gamma=w.angular.x*g.angular.x+w.angular.y*g.angular.y+w.angular.z*g.angular.z
        +w.linear.x*g.linear.x+w.linear.y*g.linear.y+w.linear.z*g.linear.z;
    if(!isfinite(gamma))atomicExch(a.hierarchy.failed+id,1u);
    return stressSquaredContribution(gamma);
}
__device__ __forceinline__ float preconditionNativeComponent(const PersistentStressArgs& a,
    const unsigned* nodes,unsigned count,unsigned id,StressHierarchy::TerminalShared& shared){
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)nativeCycleRhs(a,nodes[i]);
    __syncthreads();projectNativeTranslation(a,id,nodes,count,a.hierarchy.rhs);const auto v=a.hierarchy.cycle;
    StressHierarchy::cyclePass<true>(v.levels,v.depth,v.pool,shared,a.hierarchy.rhs,v.intermediate,id);
    projectNativeTranslation(a,id,nodes,count,v.intermediate);
    StressHierarchy::cyclePass<true>(v.levels,v.depth,v.pool,shared,v.intermediate,a.hierarchy.result,id);
    projectNativeTranslation(a,id,nodes,count,a.hierarchy.result);
    float gamma=0;for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)gamma+=nativeCycleResult(a,nodes[i],id);
    return gamma;
}
__device__ __forceinline__ void preconditionNativeGrid(const PersistentStressArgs& a,StressHierarchy::TerminalShared& shared){
    const auto grid=cooperative_groups::this_grid();const unsigned first=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const unsigned node=a.m_activeNodes[i],id=a.m_nodeIsland[node];if(a.m_islandActive[id])nativeCycleRhs(a,node);}
    grid.sync();projectNativeTranslationsGrid(a,a.hierarchy.rhs);const auto v=a.hierarchy.cycle;
    StressHierarchy::cyclePass(v.levels,v.depth,v.pool,shared,a.hierarchy.rhs,v.intermediate,StressHierarchy::Invalid,a.m_islandActive);
    projectNativeTranslationsGrid(a,v.intermediate);
    StressHierarchy::cyclePass(v.levels,v.depth,v.pool,shared,v.intermediate,a.hierarchy.result,StressHierarchy::Invalid,a.m_islandActive);
    projectNativeTranslationsGrid(a,a.hierarchy.result);
    const unsigned islands=*a.liveIslandCount;
    for(unsigned i=first;i<islands*a.slots;i+=stride)a.m_reduceSlots[a.islandIds[i/a.slots]*a.slots+i%a.slots]=0;
    grid.sync();
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const unsigned node=a.m_activeNodes[i],id=a.m_nodeIsland[node];
        if(a.m_islandActive[id])atomicAdd(a.m_reduceSlots+id*a.slots+(i&(a.slots-1)),nativeCycleResult(a,node,id));}
    grid.sync();
    for(unsigned i=first;i<islands;i+=stride){const unsigned id=a.islandIds[i];const float value=sumIslandPartials(a.m_reduceSlots,id,a.slots,nullptr);a.hierarchy.gamma[id]=value;
        if(a.m_islandActive[id] && (!(value>0) || !isfinite(value)))a.hierarchy.failed[id]=1;}
    grid.sync();
    for(unsigned block=blockIdx.x;block<a.nodeBlocks;block+=gridDim.x)
        nodeSpaceMatvecBody(a.hierarchy.lg,a.hierarchy.g,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,
            a.m_health,a.m_colScales,a.m_bondIsland,nullptr,a.m_nodeIsland,a.m_islandActive,true,nullptr,a.slots,a.m_activeNodes,a.m_activeCounts,a.m_iteration,0u,block);
    grid.sync();
}
