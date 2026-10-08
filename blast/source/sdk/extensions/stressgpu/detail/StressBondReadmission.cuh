// Private implementation fragment; included once inside the owning .cu namespace
// (NvBlastExtStressGpuTopology.cuh, native builds only).
//
// Bond readmission (ExtStressGpuEnableBondReadmission): unilateral contacts.
//
// The solve is min |S^-1 lambda|^2 over bond impulses in equilibrium; its
// answer is lambda = B^T y, y a node vector -- the structure's displacement in
// the solver's scaled units (each bond's force is its stiffness S^2 times the
// relative displacement C^T D y across it). The native solve adds B^T mu to a
// warm start each tick, so y is kept here as a resident sum of the mu it
// applied, cleared wherever the impulses are cleared and copied wherever they
// are copied. Two things follow without an extra solve:
//   - a removed bond's would-be force under the current displacement, B^T y
//     at its row (ExtStressGpuProbeBondForcesAsync): its sign says whether its
//     two chunks press together (a lifted contact that would close) or part;
//   - a readmitted bond starts at that force, so the warm start stays B^T y,
//     in range(B^T), and the CGLS correction converges to the minimum-norm
//     answer of the new operator without a cold restart of its component.
// A bond removed this way keeps its component's warm start for the same
// reason: the rest of lambda is still B^T y on the smaller operator.

// The would-be scaled impulse of `edge` under displacement y (the same
// arithmetic as applyNativeStressSolution's delta).
__device__ __forceinline__ StressHierarchy::Vector readmissionImpulse(const StressHierarchy::Vector* y,
    const Inertia* inertia,const unsigned* node0,const unsigned* node1,const Vec4* offset0,const Vec4* offset1,
    const float* scale,const float* angularScale,unsigned edge)
{
    const unsigned a=node0[edge],b=node1[edge];const auto r0=offset0[edge],r1=offset1[edge];
    const auto x=StressHierarchy::scaledValue(y[a],make_float2(inertia[a].angular,inertia[a].linear));
    const auto z=StressHierarchy::scaledValue(y[b],make_float2(inertia[b].angular,inertia[b].linear));
    return bondScaled(angularScale,edge,StressHierarchy::sub(
        StressHierarchy::couple(x,makeStressReal3(r0.x,r0.y,r0.z)),StressHierarchy::couple(z,makeStressReal3(r1.x,r1.y,r1.z))),StressReal(scale[edge]));
}
__device__ __forceinline__ AngLin readmissionAngLin(const StressHierarchy::Vector& v)
{
    return {{float(v.angular.x),float(v.angular.y),float(v.angular.z),0},{float(v.linear.x),float(v.linear.y),float(v.linear.z),0}};
}
// A readmitted bond joins the components of both its endpoints: their caches
// are stale (2: without clearing their impulses, see above).
__global__ void markReadmittedStressComponents(const DeviceStressTopologyBatch* batch,
    const ExtStressGpuDeviceTopologyStatus* state,const float* health,const unsigned* node0,const unsigned* node1,
    const unsigned* oldNodeIsland,unsigned* changed,unsigned bonds)
{
    const unsigned edge=blockIdx.x*blockDim.x+threadIdx.x;
    if(edge>=bonds || !state->initialized || !batch->mask || !batch->readmit)return;
    if(health[edge]<=0 && batch->mask[edge] && batch->readmit[edge]) {
        const unsigned a=oldNodeIsland[node0[edge]],b=oldNodeIsland[node1[edge]];
        if(a!=kNoIsland)atomicOr(changed+a,2u);
        if(b!=kNoIsland)atomicOr(changed+b,2u);
    }
}
// The displacement follows the impulses: zero where clearChangedStressWarmStart
// zeroed them (old labels).
__global__ void clearChangedStressDisplacement(const DeviceStressTopologyBatch* batch,
    const ExtStressGpuDeviceTopologyStatus* state,const unsigned* oldNodeIsland,const unsigned* changed,unsigned nodes)
{
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;
    if(node>=nodes || !batch->displacement)return;
    auto* y=static_cast<StressHierarchy::Vector*>(batch->displacement);
    if(!state->initialized){y[node]={};return;}
    const unsigned id=oldNodeIsland[node];
    if(id==kNoIsland || (changed[id]&1u))y[node]={};
}
__global__ void readmitStressBonds(const DeviceStressTopologyBatch* batch,float* health,AngLin* impulses,
    const Inertia* inertia,const unsigned* node0,const unsigned* node1,const Vec4* offset0,const Vec4* offset1,
    const float* scale,unsigned bonds)
{
    const unsigned edge=blockIdx.x*blockDim.x+threadIdx.x;
    if(edge>=bonds || !batch->mask || !batch->readmit || !batch->restHealth || !batch->displacement)return;
    if(!batch->readmit[edge])return;
    // A removed contact carries nothing (its component keeps its warm start, so
    // clearChangedStressWarmStart left its impulse; consumers read it).
    if(health[edge]>0 && !batch->mask[edge]){impulses[edge]={};return;}
    if(!(health[edge]<=0 && batch->mask[edge]))return;
    health[edge]=batch->restHealth[edge];
    impulses[edge]=readmissionAngLin(readmissionImpulse(static_cast<const StressHierarchy::Vector*>(batch->displacement),
        inertia,node0,node1,offset0,offset1,scale,batch->angularScale,edge));
}
// After a restored warm start: every live readmissible bond's impulse is set
// from the restored displacement (a bond readmitted after the snapshot held no
// impulse in it). For a bond live at the snapshot this is the value it held.
__global__ void refreshReadmittedImpulses(const std::uint32_t* readmit,const float* health,AngLin* impulses,
    const StressHierarchy::Vector* y,const Inertia* inertia,const unsigned* node0,const unsigned* node1,
    const Vec4* offset0,const Vec4* offset1,const float* scale,const float* angularScale,unsigned bonds)
{
    const unsigned edge=blockIdx.x*blockDim.x+threadIdx.x;
    if(edge>=bonds || !readmit[edge] || !(health[edge]>0))return;
    impulses[edge]=readmissionAngLin(readmissionImpulse(y,inertia,node0,node1,offset0,offset1,scale,angularScale,edge));
}
// y += mu: the correction this solve applied (applyNativeStressSolution).
__global__ void accumulateNativeDisplacement(StressHierarchy::Vector* y,const StressHierarchy::Vector* mu,unsigned nodes)
{
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;if(node>=nodes)return;
    const auto d=mu[node];auto& v=y[node];
    v.angular.x+=d.angular.x;v.angular.y+=d.angular.y;v.angular.z+=d.angular.z;
    v.linear.x+=d.linear.x;v.linear.y+=d.linear.y;v.linear.z+=d.linear.z;
}
// Physical would-be wrench of each selected bond (exportPhysicalImpulses' units).
template<bool Rotation>
__global__ void probeReadmissionForces(const std::uint32_t* select,const StressHierarchy::Vector* y,const Inertia* inertia,
    const unsigned* node0,const unsigned* node1,const Vec4* offset0,const Vec4* offset1,const float* scale,
    const float* angularScale,ExtStressGpuImpulse* out,unsigned bonds,float angularUnit,float linearUnit)
{
    if constexpr(!Rotation)angularScale=nullptr;
    const unsigned edge=blockIdx.x*blockDim.x+threadIdx.x;
    if(edge>=bonds || !select[edge])return;
    auto v=readmissionAngLin(readmissionImpulse(y,inertia,node0,node1,offset0,offset1,scale,angularScale,edge));
    if(angularScale)v.angular=bondRotationApply(angularScale+6*size_t(edge),v.angular);
    const float a=angularUnit*scale[edge],l=linearUnit*scale[edge];
    out[edge]={{v.angular.x*a,v.angular.y*a,v.angular.z*a},{v.linear.x*l,v.linear.y*l,v.linear.z*l}};
}
