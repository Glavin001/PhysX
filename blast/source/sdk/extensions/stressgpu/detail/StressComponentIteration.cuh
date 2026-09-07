// Private native specialization, included after the shared resident arguments.
#ifdef PHYSX_RESIDENT_DESTRUCTION
// Each CTA owns all iterations of one component at a time. Stable sorted node
// ranges make every vector/scalar write exclusive to that component; static
// boundary rows are read-only. No grid rendezvous or global loop counter is
// involved. The operator, recurrence, norm and convergence functions are the
// same ones used by the cooperative large-component implementation.
__global__ void componentStressSolve(PersistentStressArgs a, ResidentStressComponentView c)
{
    __shared__ unsigned counts[2], iteration, activeCount;
    __shared__ SolveStatus status;
    for(unsigned slot=blockIdx.x;slot<*c.count;slot+=gridDim.x) {
        const unsigned id=c.ids[slot], begin=c.begin[id], count=c.end[id]-begin;
        if(count>kResidentComponentMaxNodes)continue;
        if(threadIdx.x==0) {
            counts[0]=0;counts[1]=count;iteration=0;activeCount=0;
            status={1u,a.maxIterations,0u};
        }
        __syncthreads();
        const unsigned nodeBlocks=(count+blockDim.x-1)/blockDim.x;
        do {
            for(unsigned i=threadIdx.x;i<a.slots;i+=blockDim.x)
                a.m_reduceSlots[id*a.slots+i]=0;
            __syncthreads();
            for(unsigned block=0;block<nodeBlocks;++block)
                nodeSpaceMatvecBody(a.m_nsW,a.m_residual,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,
                    a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,
                    nullptr,a.m_nodeIsland,a.m_islandActive,true,a.m_reduceSlots,a.slots,c.nodes+begin,
                    counts,&iteration,0u,block);
            __syncthreads();
            finalizeAndCheckConvergenceBody(a.m_reduceSlots,a.m_gradientSquared,a.slots,
                a.m_islandActive,a.m_islandConverged,a.m_deltaSquared,&activeCount,1u,nullptr,0u,c.ids+slot);
            __syncthreads();
            for(unsigned i=threadIdx.x;i<a.slots;i+=blockDim.x)
                a.m_reduceSlots[id*a.slots+i]=0;
            __syncthreads();
            for(unsigned block=0;block<nodeBlocks;++block)
                nodeSpaceUpdateDirectionBody(a.m_nsPi,a.m_nsQ,a.m_residual,a.m_nsW,
                    a.m_gradientSquared,a.m_previousGradientSquared,a.m_nodeIsland,a.m_islandActive,
                    a.m_reduceSlots,a.slots,c.nodes+begin,counts,&iteration,block);
            __syncthreads();
            finalizeAndRetireBody(a.m_reduceSlots,a.m_projectedDirectionSquared,a.slots,
                a.m_islandActive,a.m_previousGradientSquared,a.m_gradientSquared,&status,&activeCount,1u,
                &iteration,1u,0,a.maxIterations,nullptr,0u,c.ids+slot);
            __syncthreads();
            for(unsigned block=0;block<nodeBlocks;++block)
                nodeSpaceUpdateSolutionBody(&iteration,a.maxIterations,a.m_nsMu,a.m_residual,a.m_nsPi,
                    a.m_nsQ,a.m_gradientSquared,a.m_projectedDirectionSquared,a.m_nodeIsland,
                    a.m_islandActive,c.nodes+begin,counts,block);
            __syncthreads();
        } while(status.active && iteration<a.maxIterations);
        if(threadIdx.x==0) {
            c.results[id]=status;
            // The cooperative stage must never update a small component,
            // including one that exhausted its iteration budget. Its failed
            // status survives separately and rejects the complete solve.
            a.m_islandActive[id]=0;
        }
        __syncthreads();
    }
}

// Merge per-component convergence only after both workload specializations
// finish. A small component reaching the cap cannot be hidden by a successful
// large component (or an empty large-component list).
__global__ void finishComponentStress(PersistentStressArgs a, ResidentStressComponentView c)
{
    __shared__ unsigned iterations[kBlockSize], active[kBlockSize], failed[kBlockSize];
    unsigned maxIterations=0,activeComponents=0,notConverged=0;
    for(unsigned slot=threadIdx.x;slot<*c.count;slot+=blockDim.x) {
        const unsigned id=c.ids[slot];
        if(c.end[id]-c.begin[id]>kResidentComponentMaxNodes)continue;
        const auto status=c.results[id];
        maxIterations=max(maxIterations,status.iterations);
        activeComponents+=status.active;notConverged+=!status.converged;
    }
    iterations[threadIdx.x]=maxIterations;active[threadIdx.x]=activeComponents;failed[threadIdx.x]=notConverged;
    __syncthreads();
    for(unsigned stride=blockDim.x/2;stride;stride>>=1) {
        if(threadIdx.x<stride) {
            iterations[threadIdx.x]=max(iterations[threadIdx.x],iterations[threadIdx.x+stride]);
            active[threadIdx.x]+=active[threadIdx.x+stride];failed[threadIdx.x]+=failed[threadIdx.x+stride];
        }
        __syncthreads();
    }
    if(threadIdx.x==0) {
        a.m_status->active+=active[0];
        a.m_status->iterations=max(a.m_status->iterations,iterations[0]);
        a.m_status->converged=a.m_status->converged && failed[0]==0;
        *a.m_iteration=min(a.maxIterations,a.m_status->iterations+1u);
    }
}
#endif
