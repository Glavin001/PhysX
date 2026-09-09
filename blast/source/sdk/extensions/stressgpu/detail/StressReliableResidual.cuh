// Rebuild the residual from the original load and accumulated solution. The
// recursive FP32 update alone can drift while a poorly conditioned component
// accumulates a large displacement potential. This changes no physical load,
// bond equation, requested tolerance or iteration cap.
__device__ __forceinline__ StressHierarchy::Vector nativeWarmBondSolution(const PersistentStressArgs& a,unsigned edge){
    const auto warm=a.impulses[edge];
    return {{warm.angular.x,warm.angular.y,warm.angular.z},{warm.linear.x,warm.linear.y,warm.linear.z}};
}
__device__ __forceinline__ StressHierarchy::Vector nativeBondSolution(const PersistentStressArgs& a,unsigned edge){
    using namespace StressHierarchy;
    const unsigned first=a.m_node0[edge],second=a.m_node1[edge];
    const auto x=scaledValue(a.hierarchy.solution[first],make_float2(a.m_inertia[first].angular,a.m_inertia[first].linear));
    const auto y=scaledValue(a.hierarchy.solution[second],make_float2(a.m_inertia[second].angular,a.m_inertia[second].linear));
    const auto u=a.m_offset0[edge],v=a.m_offset1[edge];
    const auto delta=mul(sub(couple(x,make_double3(u.x,u.y,u.z)),couple(y,make_double3(v.x,v.y,v.z))),double(a.m_colScales[edge]));
    return add(nativeWarmBondSolution(a,edge),delta);
}
template<bool Accumulated=true>
__device__ __forceinline__ void rebuildNativeResidualNode(const PersistentStressArgs& a,unsigned node){
    using namespace StressHierarchy;
    Vector response{};
    for(unsigned slot=a.m_nodeBondBegin[node];slot<a.m_nodeBondBegin[node+1];++slot){
        const unsigned ref=a.m_nodeBondRef[slot];if(ref==kDeadBondRef)continue;
        const unsigned edge=ref&0x7fffffffu;if(a.m_health[edge]<=0)continue;
        const bool second=ref>>31;const auto offset=second?a.m_offset1[edge]:a.m_offset0[edge];
        Vector impulse;
        if constexpr(Accumulated)impulse=nativeBondSolution(a,edge);
        else impulse=nativeWarmBondSolution(a,edge);
        const auto force=mul(impulse,double(a.m_colScales[edge])*(second?-1.:1.));
        response=add(response,transposeCouple(force,make_double3(offset.x,offset.y,offset.z)));
    }
    const auto d=a.m_inertia[node];response=scaledValue(response,make_float2(d.angular,d.linear));
    const auto b=a.originalRhs[node];
    a.m_residual[node]={{float(double(b.angular.x)-response.angular.x),float(double(b.angular.y)-response.angular.y),float(double(b.angular.z)-response.angular.z),0},
                       {float(double(b.linear.x)-response.linear.x),float(double(b.linear.y)-response.linear.y),float(double(b.linear.z)-response.linear.z),0}};
}
// Initialize from the same physical residual used for final verification.
// No accumulated node correction exists yet, so its zero products and loads
// are absent. Cold starts already have their exact RHS from initializeSolve.
__global__ void initializeNativeWarmResidual(PersistentStressArgs a){
    if(!a.warmStart)return;
    const unsigned slot=blockIdx.x*blockDim.x+threadIdx.x;
    if(slot<a.m_activeCounts[1]){const unsigned node=a.m_activeNodes[slot];
        if(!nodeSettled(a.settledIslands,a.m_nodeIsland[node]))rebuildNativeResidualNode<false>(a,node);}

}
