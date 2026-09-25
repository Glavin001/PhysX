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
// here in float pairs (PxgDestructionFloatPair.cuh, about 48 significand
// bits), with the same operations in the same order as the double version.
// Two emulated double operations per component remain: splitting the centre
// into a pair, and rounding the pair result back to the double the public
// view stores. Everything else in the motion record is a
// float input copied exactly.
//
// Measured against the double kernel on random city-scale inputs: relative
// difference at most 6e-12 (on near-cancelling offsets), no difference after
// rounding to float, which is the precision every consumer (fragment bodies,
// rendering) finally uses. The CUDA build keeps native double.
// PxgDestructionFloatPair.cuh is included by PxgDestructionBody.cuh.
namespace destructionMotionPair {
using namespace destructionPair;
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
