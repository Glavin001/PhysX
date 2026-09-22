// Accumulate the node correction without losing small increments beside a
// large warm-start cancellation. The physical operator and output stay the
// established scaled bond formulation; convert once after lambda0 + B^T*mu.
__global__ void resetNativeStressSolution(NativeStressCycleView h,AngLin* pi,AngLin* q,unsigned nodes,bool warm){
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;
    if(!node){
        // Native bond outputs are read-only to consumers. A cold start has no
        // bond-space null stress, and every update is B^T times a node vector.
        // Preserve that provenance only while the operator generation matches.
        const bool same=*h.warmRangeKnown && *h.warmRangeGeneration==h.topology->generation;
        *h.warmRangeKnown=h.topology->initialized && !h.topology->error && (!warm || same);*h.warmRangeGeneration=h.topology->generation;
    }
    if(node<nodes){h.solution[node]={};pi[node]={};q[node]={};}
}
__device__ __forceinline__ void updateNativeStressSolution(const PersistentStressArgs& a,unsigned node,unsigned id,unsigned iteration){
    if(iteration>a.maxIterations || !a.m_islandActive[id])return;
    const float denominator=a.m_projectedDirectionSquared[id];if(!(denominator>0) || !isfinite(denominator))return;
    const float alpha=a.hierarchy.gamma[id]/denominator;const auto p=a.m_nsPi[node],q=a.m_nsQ[node];auto& u=a.hierarchy.solution[node];
    u.angular.x=fma(StressReal(alpha),StressReal(p.angular.x),u.angular.x);u.angular.y=fma(StressReal(alpha),StressReal(p.angular.y),u.angular.y);u.angular.z=fma(StressReal(alpha),StressReal(p.angular.z),u.angular.z);
    u.linear.x=fma(StressReal(alpha),StressReal(p.linear.x),u.linear.x);u.linear.y=fma(StressReal(alpha),StressReal(p.linear.y),u.linear.y);u.linear.z=fma(StressReal(alpha),StressReal(p.linear.z),u.linear.z);
    a.m_residual[node].angular=sub(a.m_residual[node].angular,mul(q.angular,alpha));
    a.m_residual[node].linear=sub(a.m_residual[node].linear,mul(q.linear,alpha));
}
__global__ void applyNativeStressSolution(AngLin* impulses,const StressHierarchy::Vector* solution,const Inertia* inertia,
    const unsigned* node0,const unsigned* node1,const Vec4* offset0,const Vec4* offset1,const float* health,const float* scale,
    const unsigned* bondIsland,const unsigned* islandSkip,const unsigned* activeBonds,const unsigned* activeCounts){
    const unsigned slot=blockIdx.x*blockDim.x+threadIdx.x;if(slot>=activeCounts[0])return;const unsigned edge=activeBonds[slot];
    if(bondSettled(islandSkip,bondIsland[edge]))return;if(health[edge]<=0){impulses[edge]={};return;}
    const unsigned a=node0[edge],b=node1[edge];const auto r0=offset0[edge],r1=offset1[edge];
    const auto x=StressHierarchy::scaledValue(solution[a],make_float2(inertia[a].angular,inertia[a].linear));
    const auto y=StressHierarchy::scaledValue(solution[b],make_float2(inertia[b].angular,inertia[b].linear));
    const auto delta=StressHierarchy::mul(StressHierarchy::sub(
        StressHierarchy::couple(x,makeStressReal3(r0.x,r0.y,r0.z)),StressHierarchy::couple(y,makeStressReal3(r1.x,r1.y,r1.z))),StressReal(scale[edge]));
    auto& f=impulses[edge];
    f.angular={float(StressReal(f.angular.x)+delta.angular.x),float(StressReal(f.angular.y)+delta.angular.y),float(StressReal(f.angular.z)+delta.angular.z),0};
    f.linear={float(StressReal(f.linear.x)+delta.linear.x),float(StressReal(f.linear.y)+delta.linear.y),float(StressReal(f.linear.z)+delta.linear.z),0};
}
