// Qualification candidate: FP32 preconditioning only. The physical operator,
// true-residual verification and final bond recovery keep their existing precision.
struct NativeFloatVector {float3 angular,linear;};
__device__ __forceinline__ float3 nativeFloatAdd(float3 a,float3 b){return {a.x+b.x,a.y+b.y,a.z+b.z};}
__device__ __forceinline__ float3 nativeFloatSub(float3 a,float3 b){return {a.x-b.x,a.y-b.y,a.z-b.z};}
__device__ __forceinline__ float3 nativeFloatMul(float3 a,float b){return {a.x*b,a.y*b,a.z*b};}
__device__ __forceinline__ float3 nativeFloatCross(float3 a,float3 b){return {a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x};}
__device__ __forceinline__ NativeFloatVector nativeFloatValue(StressHierarchy::Vector a){return {{float(a.angular.x),float(a.angular.y),float(a.angular.z)},{float(a.linear.x),float(a.linear.y),float(a.linear.z)}};}
__device__ __forceinline__ StressHierarchy::Vector nativeDoubleValue(NativeFloatVector a){return {{a.angular.x,a.angular.y,a.angular.z},{a.linear.x,a.linear.y,a.linear.z}};}
__device__ __forceinline__ StressHierarchy::Vector applyNativeFloatInverse(const NativeStressCycleView& h,unsigned node,StressHierarchy::Vector value){
    const auto v=nativeFloatValue(value);const double* p=h.fineInverse+node;const size_t stride=h.inverseStride;
    const float3 k={float(p[6*stride]),float(p[7*stride]),float(p[8*stride])};
    const auto rhs=nativeFloatAdd(v.angular,nativeFloatCross(k,v.linear));
    const float u00=p[0],u10=p[stride],u11=p[2*stride],u20=p[3*stride],u21=p[4*stride],u22=p[5*stride];
    float3 x={fmaf(u00,rhs.x,0.f),fmaf(u10,rhs.x,0.f),fmaf(u20,rhs.x,0.f)};
    x={fmaf(u10,rhs.y,x.x),fmaf(u11,rhs.y,x.y),fmaf(u21,rhs.y,x.z)};
    x={fmaf(u20,rhs.z,x.x),fmaf(u21,rhs.z,x.y),fmaf(u22,rhs.z,x.z)};
    return nativeDoubleValue({x,nativeFloatSub(nativeFloatMul(v.linear,float(p[9*stride])),nativeFloatCross(k,x))});
}
__device__ __forceinline__ StressHierarchy::Vector nativeFloatOffDiagonal(const StressHierarchy::Input& input,unsigned node,const StressHierarchy::Vector* x){
    NativeFloatVector value{};
    for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
        const unsigned ref=input.refs[slot];if(ref==StressHierarchy::Invalid)continue;
        const unsigned edge=ref&0x7fffffffu;if(input.health[edge]<=0)continue;
        const bool back=ref>>31;const unsigned other=back?input.node0[edge]:input.node1[edge];
        if(other==node || input.component[other]==StressHierarchy::Invalid)continue;
        const auto remote=nativeFloatValue(x[other]);const auto d=input.inertia[other];
        const auto ro=back?input.offset0[edge]:input.offset1[edge],lo=back?input.offset1[edge]:input.offset0[edge];
        const auto angular=nativeFloatMul(remote.angular,d.x);
        const auto linear=nativeFloatAdd(nativeFloatMul(remote.linear,d.y),nativeFloatCross({ro.x,ro.y,ro.z},angular));
        const float scale=input.scale[edge],weight=-scale*scale;
        const auto fa=nativeFloatMul(angular,weight),fl=nativeFloatMul(linear,weight);
        value.angular=nativeFloatAdd(value.angular,nativeFloatMul(nativeFloatSub(fa,nativeFloatCross({lo.x,lo.y,lo.z},fl)),input.inertia[node].x));
        value.linear=nativeFloatAdd(value.linear,nativeFloatMul(fl,input.inertia[node].y));
    }
    return nativeDoubleValue(value);
}
