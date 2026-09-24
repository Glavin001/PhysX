// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Provisional cluster motion without binary64 arithmetic, for Apple GPUs
// (PX_CUMETAL). Included inside the runtime's private namespace.
//
// Metal has no binary64 hardware. CuMetal emulates each double operation in a
// library call that costs microseconds of latency when the kernel runs between
// the rest of a physics step: provisionalTopologyMotion's 48 dependent double
// operations took 0.15-0.35 ms on every full destruction frame of vibe-land's
// city (M3 Max), for 164 clusters. The only arithmetic that needs more than
// float is the velocity at the topology COM, v + w x r, where r is the offset
// from the body's COM to the cluster's double-precision centre. It is carried
// here in float pairs (hi+lo, about 48 significand bits; Joldes, Muller and
// Popescu 2017, AccurateDWPlusDW and DWTimesFP3, relative errors of at most
// 3u^2 and 2u^2 with u=2^-24), with the same operations in the same order as
// the double version. Two emulated double operations per component remain:
// splitting the centre into a pair, and rounding the pair result back to the
// double the public view stores. Everything else in the motion record is a
// float input copied exactly.
//
// Measured against the double kernel on random city-scale inputs: relative
// difference at most 6e-12 (on near-cancelling offsets), no difference after
// rounding to float, which is the precision every consumer (fragment bodies,
// rendering) finally uses. The CUDA build keeps native double.
// Pair arithmetic requires round-to-nearest float operations that are not
// reassociated, which cumetalc's default (safe) math mode provides.
namespace destructionMotionPair {
struct Pair {float hi,lo;};
__device__ __forceinline__ void twoSum(float a,float b,float& s,float& e){s=a+b;const float v=s-a;e=(a-(s-v))+(b-v);}
__device__ __forceinline__ void fastTwoSum(float a,float b,float& s,float& e){s=a+b;e=b-(s-a);}
__device__ __forceinline__ Pair add(Pair a,Pair b){
    float sh,sl,th,tl,vh,vl,zh,zl;twoSum(a.hi,b.hi,sh,sl);twoSum(a.lo,b.lo,th,tl);
    fastTwoSum(sh,sl+th,vh,vl);fastTwoSum(vh,tl+vl,zh,zl);return {zh,zl};
}
__device__ __forceinline__ Pair sub(Pair a,Pair b){return add(a,{-b.hi,-b.lo});}
__device__ __forceinline__ Pair mul(Pair a,float b){
    const float ch=a.hi*b,cl=fmaf(a.hi,b,-ch);float zh,zl;fastTwoSum(ch,fmaf(a.lo,b,cl),zh,zl);return {zh,zl};
}
__device__ __forceinline__ Pair pair(float f){return {f,0.0f};}
__device__ __forceinline__ Pair pair(double d){const float hi=float(d);return {hi,float(d-double(hi))};}
__device__ __forceinline__ double value(Pair a){return double(a.hi)+double(a.lo);}
// The double kernel, term for term: t=2(q.xyz x d), r=p+d+w_q t+q.xyz x t-b,
// linear=v+w x r, with component k using (a,b)=(k+1,k+2) mod 3.
__device__ __forceinline__ void provisionalMotion(const PxTransform& pose,const float4& bodyPosition,
    const float4& linear,const float4& angular,const double* center,PxDestructionClusterMotion& out) {
    const float p[3]={pose.p.x,pose.p.y,pose.p.z},b[3]={bodyPosition.x,bodyPosition.y,bodyPosition.z};
    const float v[3]={linear.x,linear.y,linear.z},w[3]={angular.x,angular.y,angular.z};
    const float q[4]={pose.q.x,pose.q.y,pose.q.z,pose.q.w};
    for(PxU32 k=0;k<3;++k){out.origin[k]=p[k];out.angularVelocity[k]=w[k];}
    for(PxU32 k=0;k<4;++k)out.orientation[k]=q[k];
    const Pair d[3]={pair(center[0]),pair(center[1]),pair(center[2])};
    Pair t[3],r[3];
    for(PxU32 k=0;k<3;++k){const PxU32 i=k==2?0:k+1,j=k==0?2:k-1;
        const Pair x=sub(mul(d[j],q[i]),mul(d[i],q[j]));t[k]={2*x.hi,2*x.lo};}
    for(PxU32 k=0;k<3;++k){const PxU32 i=k==2?0:k+1,j=k==0?2:k-1;
        r[k]=sub(sub(add(add(add(pair(p[k]),d[k]),mul(t[k],q[3])),mul(t[j],q[i])),mul(t[i],q[j])),pair(b[k]));}
    for(PxU32 k=0;k<3;++k){const PxU32 i=k==2?0:k+1,j=k==0?2:k-1;
        out.linearVelocity[k]=value(sub(add(pair(v[k]),mul(r[j],w[i])),mul(r[i],w[j])));}
}
}
