// Called after the cooperative convergence barrier. Every lane observes the
// same complete integer tallies, so the branch is grid-uniform without adding
// a rendezvous to iterations that still contain physical work.
__device__ __forceinline__ bool retireConvergedStressGrid(
    const PersistentStressArgs& a,unsigned blockCount,unsigned islandCount)
{
    for(unsigned block=0;block<blockCount;++block)
        if(a.m_blockActiveCounts[block])return false;
    const auto grid=cooperative_groups::this_grid();
    const unsigned lane=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    // Preserve observable finalization writes of the inactive preconditioner,
    // direction reduction and finalizeAndRetireBody. No solution is changed.
    for(unsigned i=lane;i<islandCount;i+=stride){
        const unsigned id=a.islandIds[i];
        a.hierarchy.gamma[id]=0;a.hierarchy.normalizer[id]=0;
        a.m_projectedDirectionSquared[id]=0;
    }
    for(unsigned i=lane;i<islandCount*a.slots;i+=stride)
        a.m_reduceSlots[a.islandIds[i/a.slots]*a.slots+i%a.slots]=0;
    if(!lane){
        a.m_status->active=0;
        if(!a.m_status->converged){a.m_status->converged=1;a.m_status->iterations=*a.m_iteration;}
        ++*a.m_iteration;
    }
    grid.sync();return true;
}
