// The native cold-start provenance additionally proves the minimum-energy
// zero result for cyclic and supported graphs with exactly zero current input.
// This removes accumulated numerical null stress, not authored pre-stress.
// Generation changes invalidate the proof; unverified warm states still need
// the independent free-tree certificate or the complete numerical solve.
// Exact homogeneous solve for unanchored trees. Each live bond supplies six
// independent force/moment unknowns. Removing a leaf proves recursively that
// B has full column rank; therefore B^T B lambda=0 implies lambda=0, even with
// arbitrary warm-start values. Cycles and fixed boundaries do NOT have this
// certificate. Never use a residual tolerance to infer absent external loads.
__device__ __forceinline__ bool nonzeroNativeInput(const PersistentStressArgs& a,unsigned node){
    const auto v=a.input[node];return v.angular.x!=0 || v.angular.y!=0 || v.angular.z!=0 || v.linear.x!=0 || v.linear.y!=0 || v.linear.z!=0;
}
__device__ __forceinline__ bool nativeWarmRangeKnown(const PersistentStressArgs& a){
    return a.hierarchy.topology->initialized && !a.hierarchy.topology->error && *a.hierarchy.warmRangeKnown && *a.hierarchy.warmRangeGeneration==a.hierarchy.topology->generation;
}
__device__ __forceinline__ bool nonHomogeneousTreeNode(const PersistentStressArgs& a,unsigned node){
    if(nonzeroNativeInput(a,node))return true;
    for(unsigned i=a.m_nodeBondBegin[node];i<a.m_nodeBondBegin[node+1];++i){
        const unsigned ref=a.m_nodeBondRef[i];if(ref==kDeadBondRef)continue;const unsigned edge=ref&0x7fffffffu;
        if(a.m_health[edge]>0 && !a.hierarchy.modes.forest[edge])return true;
    }
    return false;
}
__device__ __forceinline__ void clearHomogeneousTreeNode(const PersistentStressArgs& a,unsigned node){
    a.m_residual[node]={};
    for(unsigned i=a.m_nodeBondBegin[node];i<a.m_nodeBondBegin[node+1];++i){
        const unsigned ref=a.m_nodeBondRef[i];if(ref==kDeadBondRef)continue;
        const unsigned edge=ref&0x7fffffffu;
        // A fixed first endpoint has no active-node writer. Its dynamic second
        // endpoint owns this clear; all other bonds are written by their first.
        if((ref>>31) && a.m_nodeIsland[a.m_node0[edge]]!=kNoIsland)continue;
        if(a.m_health[edge]>0)a.impulses[edge]={};
    }
}
__device__ void retireHomogeneousTreeComponent(const PersistentStressArgs& a,const unsigned* nodes,unsigned count,unsigned id){
    if(a.m_deltaSquared[id]!=0 || !a.m_islandActive[id])return;
    const bool knownRange=nativeWarmRangeKnown(a);
    bool nonzero=false;for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)
        nonzero|=knownRange?nonzeroNativeInput(a,nodes[i]):nonHomogeneousTreeNode(a,nodes[i]);
    if(!__syncthreads_or(nonzero))for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)clearHomogeneousTreeNode(a,nodes[i]);
    __syncthreads();
}
__device__ void retireHomogeneousTreesGrid(const PersistentStressArgs& a){
    const auto grid=cooperative_groups::this_grid();const unsigned first=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    // Reuse the freshly zeroed per-component failure workspace before the
    // solver starts. Every active node writes only its component's certificate.
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const unsigned node=a.m_activeNodes[i],id=a.m_nodeIsland[node];
        if(id!=kNoIsland && a.m_islandActive[id] && a.m_deltaSquared[id]==0 && (nativeWarmRangeKnown(a)?nonzeroNativeInput(a,node):nonHomogeneousTreeNode(a,node)))atomicOr(a.hierarchy.failed+id,1u);}
    grid.sync();
    for(unsigned i=first;i<a.m_activeCounts[1];i+=stride){const unsigned node=a.m_activeNodes[i],id=a.m_nodeIsland[node];
        if(id!=kNoIsland && a.m_islandActive[id] && a.m_deltaSquared[id]==0 && !a.hierarchy.failed[id])clearHomogeneousTreeNode(a,node);}
    grid.sync();
    for(unsigned i=first;i<*a.liveIslandCount;i+=stride)a.hierarchy.failed[a.islandIds[i]]=0;
    grid.sync();
}
