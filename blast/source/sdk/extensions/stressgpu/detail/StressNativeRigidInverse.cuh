// The physical fine block is D = [A,-K; K,cI], with K skew symmetric.
// Its Schur complement is S=A+K*K/c. Apply the same inverse as
// x=S^-1*(a+(K/c)*b), y=b/c-(K/c)*x. This is not zero dropping or a
// preconditioner approximation: all physical coupling remains present.
// Coarse/general blocks keep their existing independently qualified solvers.
// Keep the out-of-line factor builder's ABI narrow. The owning component
// tests cache validity before calling: steady solves need no descriptor copy.
__device__ __noinline__ void buildNativeRigidInverseCoefficients(const double* factors,double* inverse,unsigned stride,unsigned node){
    using namespace StressHierarchy;
    Buffers diagonal{};diagonal.diagonal=const_cast<double*>(factors);
    // Reuse the qualified triangular factor for S^-1, which is the upper-left
    // block of D^-1. Only three inverse columns are needed instead of six.
    for(unsigned column=0;column<3;++column){
        const Vector basis{{double(column==0),double(column==1),double(column==2)},{0,0,0}};
        const auto solved=solveFineDiagonalThread(diagonal,node,basis);
        const double value[3]={solved.angular.x,solved.angular.y,solved.angular.z};
        for(unsigned row=column;row<3;++row)inverse[size_t(triangle(row,column))*stride+node]=value[row];
    }
    // Reconstruct the needed entries of D=L*L^T. Fine factors are already
    // resident and validated. No additional bond traversal or matrix upload.
    const double* l=diagonal.diagonal+size_t(node)*DiagonalEntries;
    double c=0;for(unsigned j=0;j<=3;++j)c=fma(l[triangle(3,j)],l[triangle(3,j)],c);
    const double kx=fma(l[triangle(5,0)],l[triangle(1,0)],l[triangle(5,1)]*l[triangle(1,1)]);
    double ky=0;for(unsigned j=0;j<=2;++j)ky=fma(l[triangle(3,j)],l[triangle(2,j)],ky);
    const double kz=l[triangle(4,0)]*l[triangle(0,0)];
    inverse[size_t(6)*stride+node]=kx/c;
    inverse[size_t(7)*stride+node]=ky/c;
    inverse[size_t(8)*stride+node]=kz/c;
    inverse[size_t(9)*stride+node]=1/c;
}
__device__ __forceinline__ void buildNativeMixedInverse(const NativeStressCycleView& h,unsigned node);
__device__ __forceinline__ void buildNativeRigidInverse(const NativeStressCycleView& h,unsigned node){
    const auto generation=h.topology->generation;
    if(h.inverseValid[node] && h.inverseGeneration[node]==generation)return;
    buildNativeRigidInverseCoefficients(h.cycle.levels[0].diagonal.diagonal,h.fineInverse,h.inverseStride,node);
    buildNativeMixedInverse(h,node);
    h.inverseGeneration[node]=generation;h.inverseValid[node]=1;
}
__device__ __forceinline__ StressHierarchy::Vector applyNativeRigidInverse(NativeStressCycleView h,unsigned node,StressHierarchy::Vector value){
    using namespace StressHierarchy;
    const double* p=h.fineInverse+node;const size_t stride=h.inverseStride;
    const double3 k={p[6*stride],p[7*stride],p[8*stride]};
    const double3 rhs=StressHierarchy::add(value.angular,StressHierarchy::cross(k,value.linear));
    const double u00=p[0],u10=p[stride],u11=p[2*stride],u20=p[3*stride],u21=p[4*stride],u22=p[5*stride];
    double3 x={fma(u00,rhs.x,0.),fma(u10,rhs.x,0.),fma(u20,rhs.x,0.)};
    x={fma(u10,rhs.y,x.x),fma(u11,rhs.y,x.y),fma(u21,rhs.y,x.z)};
    x={fma(u20,rhs.z,x.x),fma(u21,rhs.z,x.y),fma(u22,rhs.z,x.z)};
    return {x,StressHierarchy::sub(StressHierarchy::mul(value.linear,p[9*stride]),StressHierarchy::cross(k,x))};
}

#include "StressNativeMixedInverse.cuh"
