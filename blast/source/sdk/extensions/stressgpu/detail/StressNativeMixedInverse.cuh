// Fixed rounded block-Jacobi coefficients with guarded application precision.
// Original equations, residual reconstruction and output precision stay intact.
__device__ __forceinline__ void buildNativeMixedInverse(const NativeStressCycleView& h,unsigned node)
{
    if(!h.mixedInverse)return; // Exact private fixtures may omit this workspace.
    const size_t stride=h.inverseStride;
    double p[10];bool eligible=true;
    for(unsigned i=0;i<10;++i){
        const double original=h.fineInverse[size_t(i)*stride+node];
        const float rounded=float(original);h.mixedInverse[size_t(i)*stride+node]=rounded;p[i]=rounded;
        const double magnitude=fabs(original);
        eligible &= isfinite(original) && magnitude<=0x1p10
            && (magnitude==0 || magnitude>=0x1p-40);
    }
    // Certify the represented Schur inverse, using conservative normalized LDL
    // pivots. Rejected rows retain their original, fixed FP64 block inverse.
    double scale=0;for(unsigned i=0;i<6;++i)scale=fmax(scale,fabs(p[i]));
    eligible &= scale>0 && p[9]>0;
    if(eligible){
        const double a=p[0]/scale,b=p[1]/scale,c=p[2]/scale;
        const double d=p[3]/scale,e=p[4]/scale,f=p[5]/scale;
        const double margin=0x1p-17;
        eligible=a>margin;
        if(eligible){const double second=c-b*b/a;
            eligible=second>margin;
            if(eligible){const double coupling=e-b*d/a;
                eligible=f-d*d/a-coupling*coupling/second>margin;}}
    }
    h.mixedEligible[node]=unsigned(eligible);
}
template<typename T> __device__ __forceinline__ T nativeMixedFma(T x,T y,T z)
{
    if constexpr(sizeof(T)==sizeof(float))return fmaf(x,y,z);
    else return fma(x,y,z);
}
template<typename T> __device__ __forceinline__ StressHierarchy::Vector applyNativeRoundedInverse(
    const NativeStressCycleView& h,unsigned node,StressHierarchy::Vector value)
{
    const size_t stride=h.inverseStride;const float* p=h.mixedInverse+node;
    const T kx=p[6*stride],ky=p[7*stride],kz=p[8*stride],inverse=p[9*stride];
    const T bx=value.linear.x,by=value.linear.y,bz=value.linear.z;
    const T rx=T(value.angular.x)+nativeMixedFma(ky,bz,-kz*by);
    const T ry=T(value.angular.y)+nativeMixedFma(kz,bx,-kx*bz);
    const T rz=T(value.angular.z)+nativeMixedFma(kx,by,-ky*bx);
    const T xx=nativeMixedFma(T(p[3*stride]),rz,nativeMixedFma(T(p[stride]),ry,T(p[0])*rx));
    const T xy=nativeMixedFma(T(p[4*stride]),rz,nativeMixedFma(T(p[2*stride]),ry,T(p[stride])*rx));
    const T xz=nativeMixedFma(T(p[5*stride]),rz,nativeMixedFma(T(p[4*stride]),ry,T(p[3*stride])*rx));
    const T yx=inverse*bx-nativeMixedFma(ky,xz,-kz*xy);
    const T yy=inverse*by-nativeMixedFma(kz,xx,-kx*xz);
    const T yz=inverse*bz-nativeMixedFma(kx,xy,-ky*xx);
    return {{double(xx),double(xy),double(xz)},{double(yx),double(yy),double(yz)}};
}
__device__ __forceinline__ bool nativeMixedFloatRange(StressHierarchy::Vector v)
{
    const double maximum=fmax(fmax(fabs(v.angular.x),fabs(v.angular.y)),
        fmax(fabs(v.angular.z),fmax(fabs(v.linear.x),fmax(fabs(v.linear.y),fabs(v.linear.z)))));
    return maximum>=0x1p-40 && maximum<=0x1p40;
}
__device__ __forceinline__ StressHierarchy::Vector applyNativeMixedInverse(
    const NativeStressCycleView& h,unsigned node,StressHierarchy::Vector value)
{
    if(!h.mixedEligible[node])return applyNativeRigidInverse(h,node,value);
    if(nativeMixedFloatRange(value))return applyNativeRoundedInverse<float>(h,node,value);
    // Arithmetic guard uses the SAME represented matrix. Switching back to the
    // original coefficients here would change the preconditioner during PCG.
    return applyNativeRoundedInverse<double>(h,node,value);
}
__device__ __forceinline__ StressHierarchy::Vector* preconditionNativeMixedBlock(
    const PersistentStressArgs& a,const unsigned* nodes,unsigned count)
{
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        a.hierarchy.result[node]=applyNativeMixedInverse(a.hierarchy,node,a.hierarchy.rhs[node]);}
    __syncthreads();return a.hierarchy.result;
}
