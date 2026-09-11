// A previous correction is a trial direction for the current load, never an
// accepted answer. Exact operator-generation ownership prevents stale topology.
__device__ __forceinline__ bool improveNativeInitialGuess(const PersistentStressArgs& a,
    const unsigned* nodes,unsigned count,unsigned id,const unsigned* counts,const unsigned* iteration)
{
    const auto h=a.hierarchy;
    if(!a.warmStart || !h.historyValid[id] || h.historyGeneration[id]!=h.topology->generation)return false;
    // The initial authoritative monitor already prepared this current RHS.
    bool invalid=false;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];const auto v=h.history[node];h.result[node]=v;
        invalid|=!isfinite(v.angular.x)||!isfinite(v.angular.y)||!isfinite(v.angular.z)
            ||!isfinite(v.linear.x)||!isfinite(v.linear.y)||!isfinite(v.linear.z);}
    if(__syncthreads_or(invalid))return false;
    projectNativeNullspace(a,id,nodes,count,h.result);
    double magnitude=0;for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)magnitude=fmax(magnitude,nativeCycleMagnitude(h.result[nodes[i]]));
    double inverse;magnitude=nativeComponentMaximum(magnitude,inverse);
    if(!(magnitude>0) || !isfinite(magnitude) || !isfinite(inverse))return false;
    float dot=0;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];const auto v=StressHierarchy::mul(h.result[node],inverse);
        const AngLin p{{float(v.angular.x),float(v.angular.y),float(v.angular.z),0},{float(v.linear.x),float(v.linear.y),float(v.linear.z),0}};
        a.m_nsPi[node]=p;cacheNativeOperatorInput(a,node,p);const auto r=a.m_residual[node];
        dot+=p.angular.x*r.angular.x+p.angular.y*r.angular.y+p.angular.z*r.angular.z
            +p.linear.x*r.linear.x+p.linear.y*r.linear.y+p.linear.z*r.linear.z;
    }
    __syncthreads();
    const float numerator=componentSquaredNorm(dot);
    __shared__ float totalDot,totalEnergy;
    if(!threadIdx.x)totalDot=numerator;__syncthreads();
    float energy=0;
    for(unsigned block=0;block<(count+blockDim.x-1)/blockDim.x;++block){float contribution=0;
        nodeSpaceMatvecBody<true>(a.m_nsQ,a.m_nsPi,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,a.m_node0,a.m_node1,
            a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,nullptr,a.m_nodeIsland,a.m_islandActive,true,
            nullptr,1u,nodes,counts,iteration,0u,block,&contribution,a.m_nsW,h.operatorOther);
        energy+=contribution;
    }
    const float denominator=componentSquaredNorm(energy);
    if(!threadIdx.x)totalEnergy=denominator;__syncthreads();
    const float alpha=totalDot/totalEnergy;
    if(!(totalEnergy>0) || !isfinite(totalEnergy) || !isfinite(alpha) || alpha==0)return false;
    // Optional guesses must not turn a representable current RHS into an
    // overflow. Reject the guess before any solution write if this occurs.
    invalid=false;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const auto q=a.m_nsQ[nodes[i]];
        invalid|=!isfinite(q.angular.x*alpha)||!isfinite(q.angular.y*alpha)||!isfinite(q.angular.z*alpha)
            ||!isfinite(q.linear.x*alpha)||!isfinite(q.linear.y*alpha)||!isfinite(q.linear.z*alpha);}
    if(__syncthreads_or(invalid))return false;
    if(!threadIdx.x){h.gamma[id]=totalDot;a.m_projectedDirectionSquared[id]=totalEnergy;}
    __syncthreads();
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)updateNativeStressSolution(a,nodes[i],id,0);
    __syncthreads();
    // Reconstruct from original current inputs and the proposed correction.
    // No recursive-residual estimate may accept this initial guess.
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)rebuildNativeResidualNode(a,nodes[i]);
    __syncthreads();return true;
}
__device__ __forceinline__ void saveNativeResponseHistory(const PersistentStressArgs& a,
    const unsigned* nodes,unsigned count,unsigned id,const SolveStatus& status)
{
    if(!status.converged){if(!threadIdx.x)a.hierarchy.historyValid[id]=0;__syncthreads();return;}
    if(!status.iterations)return;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];a.hierarchy.history[node]=a.hierarchy.solution[node];}
    __syncthreads();
    if(!threadIdx.x){a.hierarchy.historyGeneration[id]=a.hierarchy.topology->generation;a.hierarchy.historyValid[id]=1;}
    __syncthreads();
}
