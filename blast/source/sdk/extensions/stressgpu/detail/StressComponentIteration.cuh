#include "StressComponentPhaseProbe.cuh"
#include "StressComponentWorkProbe.cuh"
#include "StressNativeDirectSolve.cuh"
// Private native specialization, included after the shared resident arguments.
#ifdef PHYSX_RESIDENT_DESTRUCTION
// Every warp produces one fully overwritten partial. No floating atomics
// or scratch-clearing pass is needed; all lanes participate, including zero
// contributions from out-of-range or already converged rows.
__device__ __forceinline__ float componentSquaredNorm(float value)
{
    __shared__ float warpSums[kBlockSize/32];
    for(unsigned offset=16;offset;offset>>=1)
        value+=__shfl_down_sync(0xffffffffu,value,offset);
    if((threadIdx.x&31u)==0)warpSums[threadIdx.x/32]=value;
    __syncthreads();
    float sum=0;
    if(threadIdx.x==0)for(unsigned warp=0;warp<kBlockSize/32;++warp)sum+=warpSums[warp];
    return sum;
}

// Each CTA owns all iterations of one component at a time. Stable sorted node
// ranges make every vector/scalar write exclusive to that component; static
// boundary rows are read-only. No grid rendezvous or global loop counter is
// involved. The operator, recurrence, norm and convergence functions are the
// same ones used by the cooperative large-component implementation.
// Build from this solve's validated live CSR before iteration. Components
// own disjoint dynamic rows; prescribed neighbors are represented explicitly.
// Rebuilding here avoids any new host count or cross-generation cache receipt.
__device__ __forceinline__ void cacheNativeOperatorNeighbors(const PersistentStressArgs& a,const unsigned* nodes,unsigned count){
    for(unsigned n=threadIdx.x;n<count;n+=blockDim.x){const unsigned node=nodes[n];
        for(unsigned i=a.m_nodeBondBegin[node];i<a.m_nodeBondBegin[node+1];++i){
            const unsigned ref=a.m_nodeBondRef[i];
            if(ref==kDeadBondRef || a.m_health[ref&0x7fffffffu]<=0){a.hierarchy.operatorOther[i]=kNoIsland;continue;}
            const unsigned edge=ref&0x7fffffffu,other=(ref>>31)?a.m_node0[edge]:a.m_node1[edge];
            const auto d=a.m_inertia[other];
            a.hierarchy.operatorOther[i]=(d.angular==0 && d.linear==0)?kNoIsland:other;
        }
    }
    __syncthreads();
}
// Sparse bond-gradient norm of the component's current residual: the same
// monitor the iteration uses, evaluated outside the loop for the direct step.
__device__ __forceinline__ float nativeComponentResidualNorm(const PersistentStressArgs& a,const unsigned* nodes,unsigned count,unsigned id,
    unsigned nodeBlocks,unsigned* counts,unsigned* iteration,float* reduceValue){
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const auto node=nodes[i];cacheNativeOperatorInput(a,node,a.m_residual[node]);}
    __syncthreads();
    float squared=0;
    for(unsigned block=0;block<nodeBlocks;++block){float contribution=0;
        nodeSpaceMatvecBody<true>(nullptr,a.m_residual,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,
            nullptr,a.m_nodeIsland,a.m_islandActive,true,nullptr,1u,nodes,counts,iteration,0u,block,&contribution,a.m_nsW,a.hierarchy.operatorOther);
        squared+=contribution;}
    const float numerator=componentSquaredNorm(squared);
    if(!threadIdx.x)*reduceValue=numerator;
    __syncthreads();
    return *reduceValue;
}
__global__ void componentStressSolve(PersistentStressArgs a, ResidentStressComponentView c)
{
    __shared__ unsigned counts[2], iteration, activeCount, slot, directApplied;
    __shared__ SolveStatus status;
    __shared__ float reduceValue;
    __shared__ float directX[6*kResidentComponentMaxNodes];
    COMPONENT_PROBE_BEGIN
    // Components have very different convergence costs after fracture. A CTA
    // claims its next independent component only when its previous one finishes;
    // fixed grid-stride ownership can strand expensive components on one SM.
    // Only integer dispatch order changes, never a component's numerical order.
    for(;;) {
        if(threadIdx.x==0)slot=atomicAdd(c.workCursor,1u);
        __syncthreads();
        if(slot>=*c.count)break;
        const unsigned id=c.ids[slot], begin=c.begin[id], count=c.end[id]-begin;
        // Every live component publishes a defined verification flag before
        // the subsequent cooperative kernel visits the shared active-node list.
        if(!threadIdx.x)a.hierarchy.verification[id]=0;
        if(count>kResidentComponentMaxNodes) {
            COMPONENT_WORK_UNMEASURED(id,count)
            // All readers must finish using the shared ticket before reuse.
            __syncthreads();continue;
        }
        if(!nativeHierarchyReady(a.hierarchy)){
            if(!threadIdx.x){c.results[id]={1u,a.maxIterations,0u};a.m_islandActive[id]=0;}__syncthreads();continue;
        }
        if(threadIdx.x==0) {
            a.hierarchy.previous[id]=0;a.hierarchy.failed[id]=0;
            counts[0]=0;counts[1]=count;iteration=0;activeCount=0;
            status={1u,a.maxIterations,0u};
        }
        __syncthreads();
        COMPONENT_WORK_BEGIN(a,c,id,begin,count)
        if(a.settledIslands && a.settledIslands[id]){
            if(!threadIdx.x){status={0u,0u,1u};COMPONENT_WORK_END(id,status) c.results[id]=status;}
            __syncthreads();continue;
        }
        cacheNativeOperatorNeighbors(a,c.nodes+begin,count);
        // Cache validity belongs to each built operator, independently of a
        // solve's success. Each node has one writer in this owning component.
        for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)buildNativeRigidInverse(a.hierarchy,c.nodes[begin+i]);
        __syncthreads();
        retireHomogeneousTreeComponent(a,c.nodes+begin,count,id);
        const unsigned nodeBlocks=(count+blockDim.x-1)/blockDim.x;
        if(!threadIdx.x)directApplied=0;
        __syncthreads();
        // Direct step: apply the cached factor to the current residual, add the
        // result to the accumulated solution and rebuild the true residual. At
        // most two refinement applications; the loop below still owns
        // acceptance through its unchanged monitor and verification.
        if(a.m_islandActive[id] && a.hierarchy.direct.enabled && count>=a.hierarchy.direct.minNodes){
            if(a.hierarchy.direct.counters && !threadIdx.x)atomicAdd(a.hierarchy.direct.counters,1u);
            for(unsigned attempt=0;attempt<2u;++attempt){
                // Free components solve on the null-space quotient: project the
                // residual exactly as the iteration does before measuring it.
                prepareNativeResidualComponent(a,c.nodes+begin,count,id,false);
                const float norm=nativeComponentResidualNorm(a,c.nodes+begin,count,id,nodeBlocks,counts,&iteration,&reduceValue);
                if(!(norm>a.m_deltaSquared[id]) || !isfinite(norm)){
                    if(attempt && a.hierarchy.direct.counters && !threadIdx.x)atomicAdd(a.hierarchy.direct.counters+2,1u);
                    break;
                }
                if(!directSolveNativeComponent(a,c.nodes+begin,count,id,directX))break;
                for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)rebuildNativeResidualNode(a,c.nodes[begin+i]);
                if(!threadIdx.x)directApplied=1;
                __syncthreads();
            }
        }
        do {
            const bool scheduledMonitor=(iteration%4u)==0u || iteration+1u>=a.maxIterations;
            if(a.m_islandActive[id])prepareNativeResidualComponent(a,c.nodes+begin,count,id,scheduledMonitor);
            COMPONENT_PROBE_END(0)
            float squared=0;
            // The sparse bond-gradient norm is an acceptance monitor, separate
            // from PCG's gamma and direction-energy reductions. Preserve the
            // initial/final-cap checks and react immediately to exact residual
            // extinction between periodic checks. The vote never accepts a
            // solution: the original norm and true-residual checks still do.
            bool monitor=scheduledMonitor;
            if(!monitor){
                bool nonzero=false;
                for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const auto v=a.m_residual[c.nodes[begin+i]];
                    nonzero|=v.angular.x!=0 || v.angular.y!=0 || v.angular.z!=0
                        || v.linear.x!=0 || v.linear.y!=0 || v.linear.z!=0;}
                monitor=!__syncthreads_or(nonzero);
            }
            if(monitor){
            if(!scheduledMonitor){for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const auto node=c.nodes[begin+i];cacheNativeOperatorInput(a,node,a.m_residual[node]);}__syncthreads();}
            COMPONENT_WORK_SWEEP(a,id,residualSweeps)
            for(unsigned block=0;block<nodeBlocks;++block) {
                float contribution=0;
                nodeSpaceMatvecBody<true>(nullptr,a.m_residual,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,
                    a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,
                    nullptr,a.m_nodeIsland,a.m_islandActive,true,nullptr,1u,c.nodes+begin,
                    counts,&iteration,0u,block,&contribution,a.m_nsW,a.hierarchy.operatorOther);
                squared+=contribution;
            }
            const float numerator=componentSquaredNorm(squared);
            if(threadIdx.x==0)reduceValue=numerator;
            __syncthreads();
            if((iteration || a.warmStart || directApplied) && a.m_islandActive[id] && a.m_deltaSquared[id]>0 && reduceValue<=a.m_deltaSquared[id]){
                for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)rebuildNativeResidualNode(a,c.nodes[begin+i]);
                if(!threadIdx.x)a.hierarchy.previous[id]=0;__syncthreads();
                prepareNativeResidualComponent(a,c.nodes+begin,count,id);
                COMPONENT_WORK_SWEEP(a,id,verificationSweeps)
                float verified=0;
                for(unsigned block=0;block<nodeBlocks;++block){float contribution=0;
                    nodeSpaceMatvecBody<true>(nullptr,a.m_residual,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,
                        nullptr,a.m_nodeIsland,a.m_islandActive,true,nullptr,1u,c.nodes+begin,counts,&iteration,0u,block,&contribution,a.m_nsW,a.hierarchy.operatorOther);
                    verified+=contribution;
                }
                const float norm=componentSquaredNorm(verified);if(!threadIdx.x)reduceValue=norm;__syncthreads();
            }
            COMPONENT_PROBE_END(1)
            finalizeAndCheckConvergenceBody(&reduceValue,a.m_gradientSquared,1u,
                a.m_islandActive,a.m_islandConverged,a.m_deltaSquared,&activeCount,1u,nullptr,0u,c.ids+slot,id);
            __syncthreads();
            COMPONENT_PROBE_END(2)
            }
            // Only a completed monitor can publish convergence for this
            // component; skipped monitors retain its preceding active verdict. Retire directly instead of executing inactive gamma,
            // direction, matrix-product and update stages plus their barriers.
            // Preserve the final scratch/status writes of finalizeAndRetireBody.
            if(!a.m_islandActive[id]){
                if(!threadIdx.x){
                    a.hierarchy.gamma[id]=0;a.m_projectedDirectionSquared[id]=0;
                    status.active=0;status.converged=1;status.iterations=iteration;++iteration;
                }
                __syncthreads();break;
            }
            COMPONENT_WORK_PRECONDITION(a,id,iteration)
            float localGamma=0;
            if(a.m_islandActive[id])localGamma=preconditionNativeComponent(a,c.nodes+begin,count,id,iteration COMPONENT_SUBPROBE_ARGUMENT);
            const float gamma=componentSquaredNorm(localGamma);
            if(!threadIdx.x){a.hierarchy.gamma[id]=gamma;if(a.m_islandActive[id] && (!(gamma>0) || !isfinite(gamma)))a.hierarchy.failed[id]=1;}
            __syncthreads();
            COMPONENT_PROBE_END(3)
            for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const auto node=c.nodes[begin+i];updateNativeDirection(a,node,id,iteration);cacheNativeOperatorInput(a,node,a.m_nsPi[node]);}
            __syncthreads();
            COMPONENT_PROBE_END(4)
            COMPONENT_WORK_SWEEP(a,id,directionSweeps)
            squared=0;
            for(unsigned block=0;block<nodeBlocks;++block) {
                float contribution=0;
                nodeSpaceMatvecBody<true>(a.m_nsQ,a.m_nsPi,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,a.m_node0,a.m_node1,
                    a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,nullptr,a.m_nodeIsland,a.m_islandActive,true,
                    nullptr,1u,c.nodes+begin,counts,&iteration,0u,block,&contribution,a.m_nsW,a.hierarchy.operatorOther);
                squared+=contribution;
            }
            const float denominator=componentSquaredNorm(squared);
            if(threadIdx.x==0)reduceValue=denominator;
            __syncthreads();
            COMPONENT_PROBE_END(5)
            finalizeAndRetireBody(&reduceValue,a.m_projectedDirectionSquared,1u,
                a.m_islandActive,a.hierarchy.previous,a.hierarchy.gamma,&status,&activeCount,1u,
                &iteration,1u,0,a.maxIterations,nullptr,0u,c.ids+slot,id);
            __syncthreads();
            for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)updateNativeStressSolution(a,c.nodes[begin+i],id,iteration);
            __syncthreads();
            COMPONENT_PROBE_END(6)
#ifdef BLAST_GPU_NATIVE_CYCLE_DIAGNOSTIC
            if(!threadIdx.x && count==1024 && (iteration&(iteration-1))==0)printf("native history id=%u iteration=%u residual2=%g gamma=%g direction_energy=%g g0=%g mu0=%g\n",id,iteration,a.m_gradientSquared[id],a.hierarchy.gamma[id],a.m_projectedDirectionSquared[id],a.hierarchy.g[c.nodes[begin]].linear.y,a.hierarchy.solution[c.nodes[begin]].linear.y);
#endif
        } while(status.active && iteration<a.maxIterations);
        if(threadIdx.x==0) {
            if(a.hierarchy.failed[id] || !a.m_islandConverged[id])status.converged=0;
#ifdef BLAST_GPU_NATIVE_CYCLE_DIAGNOSTIC
            if(!status.converged)printf("native component id=%u nodes=%u iterations=%u active=%u failed=%u residual2=%g tolerance2=%g gamma=%g direction_energy=%g\n",id,count,status.iterations,status.active,a.hierarchy.failed[id],a.m_gradientSquared[id],a.m_deltaSquared[id],a.hierarchy.gamma[id],a.m_projectedDirectionSquared[id]);
#endif
            COMPONENT_WORK_END(id,status)
            c.results[id]=status;
            a.hierarchy.settled.verifiedStoredOutput[id]=a.warmStart && status.converged && status.iterations==0 && !directApplied;
            // The cooperative stage must never update a small component,
            // including one that exhausted its iteration budget. Its failed
            // status survives separately and rejects the complete solve.
            a.m_islandActive[id]=0;
        }
        __syncthreads();
    }
    COMPONENT_PROBE_PUBLISH
}

#undef COMPONENT_PROBE_BEGIN
#undef COMPONENT_PROBE_END
#undef COMPONENT_PROBE_PUBLISH

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
        if(a.hierarchy.direct.diagnostics && a.hierarchy.direct.counters){const unsigned* k=a.hierarchy.direct.counters;
            unsigned* e=a.hierarchy.settled.counters;const unsigned elastic=e?e[0]:0u;if(e)e[0]=0u;
            printf("native direct: eligible=%u applied=%u accepted=%u noslot=%u invalid=%u pinnedfree=%u refactored=%u elasticSkips=%u maxIterations=%u\n",k[0],k[1],k[2],k[3],k[4],k[5],k[6],elastic,iterations[0]);}
        a.m_status->active+=active[0];
        a.m_status->iterations=max(a.m_status->iterations,iterations[0]);
        a.m_status->converged=a.m_status->converged && failed[0]==0;
        *a.m_iteration=min(a.maxIterations,a.m_status->iterations+1u);
    }
}
#endif
