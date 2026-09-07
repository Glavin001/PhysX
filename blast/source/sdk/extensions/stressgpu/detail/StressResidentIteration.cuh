// Private implementation fragment; included once inside the owning .cu namespace.
// BEGIN UNCHANGED SOURCE
#ifdef PHYSX_RESIDENT_DESTRUCTION
// The iteration's mathematical stages are shared with the reference kernels.
// One cooperative launch owns all iterations; virtual block ranges cover any
// scene size without requiring the entire data set to be resident at once.
struct PersistentStressArgs {
    AngLin* m_nsW;
    AngLin* m_residual;
    Inertia* m_inertia;
    std::uint32_t* m_nodeBondBegin;
    std::uint32_t* m_nodeBondRef;
    std::uint32_t* m_node0;
    std::uint32_t* m_node1;
    Vec4* m_offset0;
    Vec4* m_offset1;
    float* m_health;
    float* m_colScales;
    std::uint32_t* m_bondIsland;
    std::uint32_t* m_nodeIsland;
    std::uint32_t* m_islandActive;
    float* m_reduceSlots;
    std::uint32_t slots;
    std::uint32_t* m_activeNodes;
    std::uint32_t* m_activeCounts;
    std::uint32_t* m_iteration;
    float* m_gradientSquared;
    std::uint32_t* m_islandConverged;
    float* m_deltaSquared;
    std::uint32_t* m_blockActiveCounts;
    std::uint32_t m_islandCount;
    AngLin* m_nsPi;
    AngLin* m_nsQ;
    float* m_previousGradientSquared;
    float* m_projectedDirectionSquared;
    SolveStatus* m_status;
    std::uint32_t islandBlocks;
    std::uint32_t maxIterations;
    AngLin* m_nsMu;
    unsigned nodeBlocks;
    const std::uint32_t* islandIds;
    const std::uint32_t* liveIslandCount;
    bool largeComponentsOnly;
    NativeStressCycleView hierarchy{};
};
#include "StressNativePreconditioner.cuh"
template<bool Preconditioned>
__global__ void persistentStressSolve(PersistentStressArgs a) {
    __shared__ StressHierarchy::TerminalShared cycleShared;
    const auto grid=cooperative_groups::this_grid();
    const unsigned lane=blockIdx.x*blockDim.x+threadIdx.x;
    const unsigned stride=gridDim.x*blockDim.x;
    const unsigned islandCount=a.liveIslandCount ? *a.liveIslandCount : a.m_islandCount;
    if constexpr(Preconditioned)if(!nativeHierarchyReady(a.hierarchy)){
        if(!lane){*a.m_status={1u,a.maxIterations,0u};*a.m_iteration=a.maxIterations;}return;
    }
    if(a.largeComponentsOnly && islandCount==0) {
        if(lane==0) { *a.m_status={0u,0u,1u}; *a.m_iteration=0; }
        return;
    }
    // One empty block still publishes the converged status when no bonds
    // remain. No CPU observation is needed to choose the work size.
    const unsigned islandBlocks=max(1u,(islandCount+blockDim.x-1)/blockDim.x);
    if constexpr(Preconditioned){
        for(unsigned i=lane;i<islandCount;i+=stride){const unsigned id=a.islandIds[i];a.hierarchy.previous[id]=0;a.hierarchy.failed[id]=0;}
        grid.sync();
    }
    const AngLin* direction=Preconditioned?a.hierarchy.g:a.m_residual;
    const AngLin* product=Preconditioned?a.hierarchy.lg:a.m_nsW;
    const float* numerator=Preconditioned?a.hierarchy.gamma:a.m_gradientSquared;
    float* previous=Preconditioned?a.hierarchy.previous:a.m_previousGradientSquared;
    do {
        for(unsigned i=lane;i<islandCount*a.slots;i+=stride) {
            const unsigned id=a.islandIds ? a.islandIds[i/a.slots] : i/a.slots;
            a.m_reduceSlots[id*a.slots+i%a.slots]=0;
        }
        if(gridDim.x==1)__syncthreads();else grid.sync();
        for(unsigned block=blockIdx.x;block<a.nodeBlocks;block+=gridDim.x)
            nodeSpaceMatvecBody(a.m_nsW,a.m_residual,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,nullptr,a.m_nodeIsland,a.m_islandActive,true,a.m_reduceSlots,a.slots,a.m_activeNodes,a.m_activeCounts,a.m_iteration,0u,block);
        if(gridDim.x==1)__syncthreads();else grid.sync();
        for(unsigned block=blockIdx.x;block<islandBlocks;block+=gridDim.x)
            finalizeAndCheckConvergenceBody(a.m_reduceSlots,a.m_gradientSquared,a.slots,a.m_islandActive,a.m_islandConverged,a.m_deltaSquared,a.m_blockActiveCounts,islandCount,nullptr,block,a.islandIds);
        if(gridDim.x==1)__syncthreads();else grid.sync();
        if constexpr(Preconditioned)preconditionNativeGrid(a,cycleShared);
        for(unsigned i=lane;i<islandCount*a.slots;i+=stride) {
            const unsigned id=a.islandIds ? a.islandIds[i/a.slots] : i/a.slots;
            a.m_reduceSlots[id*a.slots+i%a.slots]=0;
        }
        if(gridDim.x==1)__syncthreads();else grid.sync();
        for(unsigned block=blockIdx.x;block<a.nodeBlocks;block+=gridDim.x)
            nodeSpaceUpdateDirectionBody(a.m_nsPi,a.m_nsQ,direction,product,numerator,previous,a.m_nodeIsland,a.m_islandActive,a.m_reduceSlots,a.slots,a.m_activeNodes,a.m_activeCounts,a.m_iteration,block);
        if(gridDim.x==1)__syncthreads();else grid.sync();
        for(unsigned block=blockIdx.x;block<islandBlocks;block+=gridDim.x)
            finalizeAndRetireBody(a.m_reduceSlots,a.m_projectedDirectionSquared,a.slots,a.m_islandActive,previous,numerator,a.m_status,a.m_blockActiveCounts,islandBlocks,a.m_iteration,islandCount,0,a.maxIterations,nullptr,block,a.islandIds);
        if(gridDim.x==1)__syncthreads();else grid.sync();
        for(unsigned block=blockIdx.x;block<a.nodeBlocks;block+=gridDim.x)
            nodeSpaceUpdateSolutionBody(a.m_iteration,a.maxIterations,a.m_nsMu,a.m_residual,a.m_nsPi,a.m_nsQ,numerator,a.m_projectedDirectionSquared,a.m_nodeIsland,a.m_islandActive,a.m_activeNodes,a.m_activeCounts,block);
        if(gridDim.x==1)__syncthreads();else grid.sync();
    } while(a.m_status->active && *a.m_iteration<a.maxIterations);
    if constexpr(Preconditioned){
        // The recurrence may retire a degenerate direction; that is never
        // evidence of convergence. Reconcile against the authoritative flags.
        if(!lane)for(unsigned i=0;i<islandCount;++i){const unsigned id=a.islandIds[i];if(a.hierarchy.failed[id] || !a.m_islandConverged[id]){
            a.m_status->converged=0;
#ifdef BLAST_GPU_NATIVE_CYCLE_DIAGNOSTIC
            printf("native cooperative id=%u iterations=%u active=%u failed=%u residual2=%g tolerance2=%g gamma=%g q2=%g\n",id,*a.m_iteration,a.m_status->active,a.hierarchy.failed[id],a.m_gradientSquared[id],a.m_deltaSquared[id],a.hierarchy.gamma[id],a.m_projectedDirectionSquared[id]);
#endif
        }}
    }
}
#endif

