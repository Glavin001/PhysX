// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxDestructionTopologyTypes.h"
#include "foundation/PxSimpleTypes.h"
#include <cfloat>
#include <cmath>
#if defined(PX_CUMETAL) && PX_CUMETAL
#include "PxgDestructionFloatPair.cuh"
#endif

namespace physx { namespace destructionBody {
// One thread per live cluster. Scale before symmetric Jacobi rotations, so
// large/small physical inertia uses the same convergence criterion. No inertia
// floors, axis locks, or iteration-budget-dependent approximate result.
__device__ inline bool principalFrame(const double* inertia, double* moments, double* q) {
    double a[3][3]={{inertia[0],inertia[3],inertia[4]},
        {inertia[3],inertia[1],inertia[5]},{inertia[4],inertia[5],inertia[2]}};
    double v[3][3]={{1,0,0},{0,1,0},{0,0,1}},scale=0;
    for(unsigned i=0;i<6;++i) {
        if(!isfinite(inertia[i]))return false;
        scale=fmax(scale,fabs(inertia[i]));
    }
    if(scale==0) {moments[0]=moments[1]=moments[2]=0;q[0]=q[1]=q[2]=0;q[3]=1;return true;}
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j)a[i][j]/=scale;
    for(unsigned iteration=0;iteration<32;++iteration) {
        unsigned p=0,r=1;
        if(fabs(a[0][2])>fabs(a[p][r])){p=0;r=2;}
        if(fabs(a[1][2])>fabs(a[p][r])){p=1;r=2;}
        if(fabs(a[p][r])<=8*DBL_EPSILON)break;
        const double tau=(a[r][r]-a[p][p])/(2*a[p][r]);
        const double t=copysign(1.0,tau)/(fabs(tau)+hypot(1.0,tau));
        const double c=1/sqrt(1+t*t),s=t*c,off=a[p][r];
        a[p][p]-=t*off;a[r][r]+=t*off;a[p][r]=a[r][p]=0;
        for(unsigned k=0;k<3;++k) {
            if(k!=p && k!=r) {
                const double x=a[k][p],y=a[k][r];
                a[k][p]=a[p][k]=c*x-s*y;a[k][r]=a[r][k]=s*x+c*y;
            }
            const double x=v[k][p],y=v[k][r];v[k][p]=c*x-s*y;v[k][r]=s*x+c*y;
        }
    }
    if(fmax(fabs(a[0][1]),fmax(fabs(a[0][2]),fabs(a[1][2])))>8*DBL_EPSILON)return false;
    // Stable principal moment order and a proper (right-handed) frame.
    for(unsigned i=0;i<2;++i)for(unsigned j=i+1;j<3;++j)if(a[j][j]<a[i][i]) {
        const double d=a[i][i];a[i][i]=a[j][j];a[j][j]=d;
        for(unsigned k=0;k<3;++k){const double x=v[k][i];v[k][i]=v[k][j];v[k][j]=x;}
    }
    const double det=v[0][0]*(v[1][1]*v[2][2]-v[1][2]*v[2][1])
        -v[0][1]*(v[1][0]*v[2][2]-v[1][2]*v[2][0])+v[0][2]*(v[1][0]*v[2][1]-v[1][1]*v[2][0]);
    if(det<0)for(unsigned k=0;k<3;++k)v[k][2]=-v[k][2];
    for(unsigned i=0;i<3;++i)moments[i]=a[i][i]*scale;
    const double trace=v[0][0]+v[1][1]+v[2][2];
    if(trace>0) {
        const double s=2*sqrt(1+trace);q[3]=s/4;
        q[0]=(v[2][1]-v[1][2])/s;q[1]=(v[0][2]-v[2][0])/s;q[2]=(v[1][0]-v[0][1])/s;
    } else {
        unsigned i=0;if(v[1][1]>v[i][i])i=1;if(v[2][2]>v[i][i])i=2;
        const unsigned j=(i+1)%3,k=(i+2)%3;const double s=2*sqrt(1+v[i][i]-v[j][j]-v[k][k]);
        q[i]=s/4;q[j]=(v[j][i]+v[i][j])/s;q[k]=(v[k][i]+v[i][k])/s;q[3]=(v[k][j]-v[j][k])/s;
    }
    const double length=sqrt(q[0]*q[0]+q[1]*q[1]+q[2]*q[2]+q[3]*q[3]);
    const double divisor=q[3]<0?-length:length;
    for(unsigned i=0;i<4;++i)q[i]/=divisor;
    return true;
}
#if defined(PX_CUMETAL) && PX_CUMETAL
// principalFrame above, operation for operation, in float pairs
// (PxgDestructionFloatPair.cuh). On Metal its double Jacobi rotations are a
// dependent chain of several hundred emulated operations per cluster: about
// 0.8 ms per fracturing pass in vibe-land's city (prepareCandidateBodies, one
// thread per new cluster). The pair version keeps the scaling, the rotation
// formulas, the 8*DBL_EPSILON convergence and failure tests (2^-49, exact as a
// float), the moment ordering, handedness and quaternion extraction. Off-
// diagonal entries only shrink relative to themselves, so the pairs' 48 bits
// reach the same threshold. Results agree with double to ~1e-13 relative;
// the body state stores them in float. In a repeated-moment subspace any
// orthonormal basis is a principal frame; which one is chosen may differ.
__device__ inline bool principalFramePairs(const double* inertia,destructionPair::Pair* moments,destructionPair::Pair* q) {
    using namespace destructionPair;
    double norm=0;
    for(unsigned i=0;i<6;++i) {
        if(!isfinite(inertia[i]))return false;
        norm=fmax(norm,fabs(inertia[i]));
    }
    if(norm==0) {for(unsigned i=0;i<3;++i){moments[i]=pair(0.0f);q[i]=pair(0.0f);}q[3]=pair(1.0f);return true;}
    const Pair s0=pair(norm);
    Pair e[6];for(unsigned i=0;i<6;++i)e[i]=div(pair(inertia[i]),s0);
    Pair a[3][3]={{e[0],e[3],e[4]},{e[3],e[1],e[5]},{e[4],e[5],e[2]}};
    const Pair zero=pair(0.0f),one=pair(1.0f);
    Pair v[3][3]={{one,zero,zero},{zero,one,zero},{zero,zero,one}};
    const Pair epsilon=pair(0x1p-49f); // 8*DBL_EPSILON
    for(unsigned iteration=0;iteration<32;++iteration) {
        unsigned p=0,r=1;
        if(less(abs(a[p][r]),abs(a[0][2]))){p=0;r=2;}
        if(less(abs(a[p][r]),abs(a[1][2]))){p=1;r=2;}
        if(!less(epsilon,abs(a[p][r])))break;
        const Pair numerator=sub(a[r][r],a[p][p]),denominator=scale(a[p][r],2.0f),tau=div(numerator,denominator);
        // copysign(1,tau) as double sees it: x-x is +0, so a zero tau takes the
        // denominator's sign (a pair sum would lose the sign of -0).
        const bool negative=numerator.hi==0?(__float_as_uint(denominator.hi)>>31)!=0:(__float_as_uint(tau.hi)>>31)!=0;
        const Pair t=div(pair(negative?-1.0f:1.0f),add(abs(tau),sqrt(add(one,mul(tau,tau)))));
        const Pair c=div(one,sqrt(add(one,mul(t,t)))),sn=mul(t,c),off=a[p][r];
        a[p][p]=sub(a[p][p],mul(t,off));a[r][r]=add(a[r][r],mul(t,off));a[p][r]=a[r][p]=zero;
        for(unsigned k=0;k<3;++k) {
            if(k!=p && k!=r) {
                const Pair x=a[k][p],y=a[k][r];
                a[k][p]=a[p][k]=sub(mul(c,x),mul(sn,y));a[k][r]=a[r][k]=add(mul(sn,x),mul(c,y));
            }
            const Pair x=v[k][p],y=v[k][r];v[k][p]=sub(mul(c,x),mul(sn,y));v[k][r]=add(mul(sn,x),mul(c,y));
        }
    }
    if(less(epsilon,abs(a[0][1])) || less(epsilon,abs(a[0][2])) || less(epsilon,abs(a[1][2])))return false;
    for(unsigned i=0;i<2;++i)for(unsigned j=i+1;j<3;++j)if(less(a[j][j],a[i][i])) {
        const Pair d=a[i][i];a[i][i]=a[j][j];a[j][j]=d;
        for(unsigned k=0;k<3;++k){const Pair x=v[k][i];v[k][i]=v[k][j];v[k][j]=x;}
    }
    const Pair det=add(sub(mul(v[0][0],sub(mul(v[1][1],v[2][2]),mul(v[1][2],v[2][1]))),
        mul(v[0][1],sub(mul(v[1][0],v[2][2]),mul(v[1][2],v[2][0])))),mul(v[0][2],sub(mul(v[1][0],v[2][1]),mul(v[1][1],v[2][0]))));
    if(less(det,zero))for(unsigned k=0;k<3;++k)v[k][2]=neg(v[k][2]);
    for(unsigned i=0;i<3;++i)moments[i]=mul(a[i][i],s0);
    Pair h[4];
    const Pair trace=add(add(v[0][0],v[1][1]),v[2][2]);
    if(less(zero,trace)) {
        const Pair sq=scale(sqrt(add(one,trace)),2.0f);h[3]=scale(sq,0.25f);
        h[0]=div(sub(v[2][1],v[1][2]),sq);h[1]=div(sub(v[0][2],v[2][0]),sq);h[2]=div(sub(v[1][0],v[0][1]),sq);
    } else {
        unsigned i=0;if(less(v[i][i],v[1][1]))i=1;if(less(v[i][i],v[2][2]))i=2;
        const unsigned j=(i+1)%3,k=(i+2)%3;const Pair sq=scale(sqrt(sub(sub(add(one,v[i][i]),v[j][j]),v[k][k])),2.0f);
        h[i]=scale(sq,0.25f);h[j]=div(add(v[j][i],v[i][j]),sq);h[k]=div(add(v[k][i],v[i][k]),sq);h[3]=div(sub(v[k][j],v[j][k]),sq);
    }
    const Pair length=sqrt(add(add(add(mul(h[0],h[0]),mul(h[1],h[1])),mul(h[2],h[2])),mul(h[3],h[3])));
    const Pair divisor=less(h[3],zero)?neg(length):length;
    for(unsigned i=0;i<4;++i)q[i]=div(h[i],divisor);
    return true;
}
// principalFramePairs without run-time array indices. The rotation plane
// (p,r) and the quaternion's leading component are chosen at run time;
// indexing the 3x3 pair arrays with them put the arrays in thread-local
// memory on Apple GPUs, a load and store per operand of every pair operation:
// ~650 us per launch of the frame for 600 clusters, and ~240 us per
// prepareCandidateBodies launch in vibe-land's meteor bench (latency is one
// new cluster's chain). Here the tensor is six scalars and the frame nine,
// the plane's entries are gathered and scattered with selects, and one
// rotation, written once, updates them. (Three constant-index copies of the
// rotation made Apple's shader compiler fail with an internal error.) The
// operations and their order are those of principalFramePairs, so the
// results are bit-identical.
namespace principalPairs {
using namespace destructionPair;
__device__ __forceinline__ Pair pick(bool c,Pair x,Pair y){return {c?x.hi:y.hi,c?x.lo:y.lo};}
__device__ inline bool frame(const double* inertia,Pair* moments,Pair* q) {
    // No return inside a loop (see structuredPairs below): the finite test
    // is accumulated and taken after it, with the same result.
    double norm=0;bool finiteInputs=true;
    for(unsigned i=0;i<6;++i) {
        finiteInputs=finiteInputs && isfinite(inertia[i]);
        norm=fmax(norm,fabs(inertia[i]));
    }
    if(!finiteInputs)return false;
    if(norm==0) {for(unsigned i=0;i<3;++i){moments[i]=pair(0.0f);q[i]=pair(0.0f);}q[3]=pair(1.0f);return true;}
    const Pair s0=pair(norm);
    // a: symmetric, a00 a11 a22 a01 a02 a12 (inertia order).
    Pair a00=div(pair(inertia[0]),s0),a11=div(pair(inertia[1]),s0),a22=div(pair(inertia[2]),s0),
        a01=div(pair(inertia[3]),s0),a02=div(pair(inertia[4]),s0),a12=div(pair(inertia[5]),s0);
    const Pair zero=pair(0.0f),one=pair(1.0f);
    Pair v00=one,v01=zero,v02=zero,v10=zero,v11=one,v12=zero,v20=zero,v21=zero,v22=one;
    const Pair epsilon=pair(0x1p-49f); // 8*DBL_EPSILON
    for(unsigned iteration=0;iteration<32;++iteration) {
        // The same choice as principalFramePairs: (0,1), then (0,2), then
        // (1,2) when strictly larger in magnitude.
        unsigned plane=0;Pair largest=abs(a01);
        if(less(largest,abs(a02))){plane=1;largest=abs(a02);}
        if(less(largest,abs(a12))){plane=2;largest=abs(a12);}
        if(!less(epsilon,largest))break;
        // Gather: p=(plane==2), r=(plane==0?1:2), q the third index.
        const bool s0p=plane==0,s1p=plane==1,s2p=plane==2;
        const Pair app=pick(s2p,a11,a00),arr=pick(s0p,a11,a22),apr=pick(s0p,a01,pick(s1p,a02,a12));
        // a[q][p] and a[q][r] (symmetric storage).
        const Pair aqp=pick(s2p,a01,pick(s1p,a01,a02)),aqr=pick(s2p,a02,a12);
        const Pair vp0=pick(s2p,v01,v00),vp1=pick(s2p,v11,v10),vp2=pick(s2p,v21,v20);
        const Pair vr0=pick(s0p,v01,v02),vr1=pick(s0p,v11,v12),vr2=pick(s0p,v21,v22);
        // The rotation of principalFramePairs.
        const Pair numerator=sub(arr,app),denominator=scale(apr,2.0f),tau=div(numerator,denominator);
        const bool negative=numerator.hi==0?(__float_as_uint(denominator.hi)>>31)!=0:(__float_as_uint(tau.hi)>>31)!=0;
        const Pair t=div(pair(negative?-1.0f:1.0f),add(abs(tau),sqrt(add(one,mul(tau,tau)))));
        const Pair c=div(one,sqrt(add(one,mul(t,t)))),sn=mul(t,c),off=apr;
        const Pair npp=sub(app,mul(t,off)),nrr=add(arr,mul(t,off));
        const Pair nqp=sub(mul(c,aqp),mul(sn,aqr)),nqr=add(mul(sn,aqp),mul(c,aqr));
        const Pair np0=sub(mul(c,vp0),mul(sn,vr0)),nr0=add(mul(sn,vp0),mul(c,vr0));
        const Pair np1=sub(mul(c,vp1),mul(sn,vr1)),nr1=add(mul(sn,vp1),mul(c,vr1));
        const Pair np2=sub(mul(c,vp2),mul(sn,vr2)),nr2=add(mul(sn,vp2),mul(c,vr2));
        // Scatter. plane 0: p=0 r=1 q=2; plane 1: p=0 r=2 q=1; plane 2: p=1 r=2 q=0.
        a00=pick(s2p,a00,npp);
        a11=pick(s0p,nrr,pick(s2p,npp,a11));
        a22=pick(s0p,a22,nrr);
        a01=pick(s0p,zero,pick(s1p,nqp,nqp));   // plane1: a[q=1][p=0]; plane2: a[q=0][p=1]
        a02=pick(s0p,nqp,pick(s1p,zero,nqr));   // plane0: a[q=2][p=0]; plane2: a[q=0][r=2]
        a12=pick(s0p,nqr,pick(s1p,nqr,zero));   // plane0: a[q=2][r=1]; plane1: a[q=1][r=2]
        v00=pick(s2p,v00,np0);v10=pick(s2p,v10,np1);v20=pick(s2p,v20,np2);
        v01=pick(s0p,nr0,pick(s2p,np0,v01));v11=pick(s0p,nr1,pick(s2p,np1,v11));v21=pick(s0p,nr2,pick(s2p,np2,v21));
        v02=pick(s0p,v02,nr0);v12=pick(s0p,v12,nr1);v22=pick(s0p,v22,nr2);
    }
    if(less(epsilon,abs(a01)) || less(epsilon,abs(a02)) || less(epsilon,abs(a12)))return false;
    // Stable principal moment order (the same compare-swaps) and a proper frame.
    Pair d0=a00,d1=a11,d2=a22;
    const auto swapColumns=[](Pair& x0,Pair& x1,Pair& x2,Pair& y0,Pair& y1,Pair& y2) {
        const Pair t0=x0,t1=x1,t2=x2;x0=y0;x1=y1;x2=y2;y0=t0;y1=t1;y2=t2;};
    if(less(d1,d0)){const Pair d=d0;d0=d1;d1=d;swapColumns(v00,v10,v20,v01,v11,v21);}
    if(less(d2,d0)){const Pair d=d0;d0=d2;d2=d;swapColumns(v00,v10,v20,v02,v12,v22);}
    if(less(d2,d1)){const Pair d=d1;d1=d2;d2=d;swapColumns(v01,v11,v21,v02,v12,v22);}
    const Pair det=add(sub(mul(v00,sub(mul(v11,v22),mul(v12,v21))),
        mul(v01,sub(mul(v10,v22),mul(v12,v20)))),mul(v02,sub(mul(v10,v21),mul(v11,v20))));
    if(less(det,zero)){v02=neg(v02);v12=neg(v12);v22=neg(v22);}
    moments[0]=mul(d0,s0);moments[1]=mul(d1,s0);moments[2]=mul(d2,s0);
    Pair h[4];
    const Pair trace=add(add(v00,v11),v22);
    if(less(zero,trace)) {
        const Pair sq=scale(sqrt(add(one,trace)),2.0f);h[3]=scale(sq,0.25f);
        h[0]=div(sub(v21,v12),sq);h[1]=div(sub(v02,v20),sq);h[2]=div(sub(v10,v01),sq);
    } else {
        unsigned i=0;if(less(v00,v11))i=1;if(less(i?v11:v00,v22))i=2;
        // i: the largest diagonal; (j,k)=(i+1,i+2) mod 3, selected by value.
        const bool i0=i==0,i1=i==1;
        const Pair vii=pick(i0,v00,pick(i1,v11,v22)),vjj=pick(i0,v11,pick(i1,v22,v00)),vkk=pick(i0,v22,pick(i1,v00,v11));
        const Pair vji=pick(i0,v10,pick(i1,v21,v02)),vij=pick(i0,v01,pick(i1,v12,v20));
        const Pair vki=pick(i0,v20,pick(i1,v01,v12)),vik=pick(i0,v02,pick(i1,v10,v21));
        const Pair vkj=pick(i0,v21,pick(i1,v02,v10)),vjk=pick(i0,v12,pick(i1,v20,v01));
        const Pair sq=scale(sqrt(sub(sub(add(one,vii),vjj),vkk)),2.0f);
        const Pair hi=scale(sq,0.25f),hj=div(add(vji,vij),sq),hk=div(add(vki,vik),sq);
        h[3]=div(sub(vkj,vjk),sq);
        h[0]=pick(i0,hi,pick(i1,hk,hj));h[1]=pick(i0,hj,pick(i1,hi,hk));h[2]=pick(i0,hk,pick(i1,hj,hi));
    }
    const Pair length=sqrt(add(add(add(mul(h[0],h[0]),mul(h[1],h[1])),mul(h[2],h[2])),mul(h[3],h[3])));
    const Pair divisor=less(h[3],zero)?neg(length):length;
    for(unsigned i=0;i<4;++i)q[i]=div(h[i],divisor);
    return true;
}
}
// The same frame as doubles, for validation against principalFrame.
__device__ inline bool principalFramePair(const double* inertia,double* moments,double* q) {
    destructionPair::Pair m[3],r[4];if(!principalFramePairs(inertia,m,r))return false;
    for(unsigned i=0;i<3;++i)moments[i]=destructionPair::value(m[i]);
    for(unsigned i=0;i<4;++i)q[i]=destructionPair::value(r[i]);
    return true;
}
#endif
// A cluster's principal frame depends only on its inertia tensor, and every
// cluster a fracture did not touch keeps its tensor bit for bit. The Jacobi
// rotations above are a dependent chain of emulated double operations on
// Metal, about a millisecond per thread, paid for every live cluster on each
// fracturing pass. The cache hands back exactly what principalFrame returned
// for a bitwise-equal tensor, failure included; one thread owns each root.
struct PrincipalFrameCache { unsigned long long inertia[6],moments[3],q[4]; PxU32 state; };
#if defined(PX_CUMETAL) && PX_CUMETAL
// The Metal cache holds the pair results (hi and lo bits in one 64-bit slot).
__device__ inline bool cachedPrincipalFrame(const double* inertia,destructionPair::Pair* moments,destructionPair::Pair* q,PrincipalFrameCache* cache) {
    const auto* bits=reinterpret_cast<const unsigned long long*>(inertia);
    const auto pack=[](destructionPair::Pair p){return (static_cast<unsigned long long>(__float_as_uint(p.hi))<<32)|__float_as_uint(p.lo);};
    const auto unpack=[](unsigned long long b){return destructionPair::Pair{__uint_as_float(unsigned(b>>32)),__uint_as_float(unsigned(b))};};
    if(cache && cache->state) {
        bool same=true;for(unsigned i=0;i<6;++i)same=same && bits[i]==cache->inertia[i];
        if(same) {
            if(cache->state==2)return false;
            for(unsigned i=0;i<3;++i)moments[i]=unpack(cache->moments[i]);
            for(unsigned i=0;i<4;++i)q[i]=unpack(cache->q[i]);
            return true;
        }
    }
    const bool ok=principalPairs::frame(inertia,moments,q);
    if(cache) {
        for(unsigned i=0;i<6;++i)cache->inertia[i]=bits[i];
        if(ok) {for(unsigned i=0;i<3;++i)cache->moments[i]=pack(moments[i]);for(unsigned i=0;i<4;++i)cache->q[i]=pack(q[i]);}
        cache->state=ok?1u:2u;
    }
    return ok;
}
#else
__device__ inline bool cachedPrincipalFrame(const double* inertia,double* moments,double* q,PrincipalFrameCache* cache) {
    const auto* bits=reinterpret_cast<const unsigned long long*>(inertia);
    if(cache && cache->state) {
        bool same=true;for(unsigned i=0;i<6;++i)same=same && bits[i]==cache->inertia[i];
        if(same) {
            if(cache->state==2)return false;
            for(unsigned i=0;i<3;++i)reinterpret_cast<unsigned long long*>(moments)[i]=cache->moments[i];
            for(unsigned i=0;i<4;++i)reinterpret_cast<unsigned long long*>(q)[i]=cache->q[i];
            return true;
        }
    }
    const bool ok=principalFrame(inertia,moments,q);
    if(cache) {
        for(unsigned i=0;i<6;++i)cache->inertia[i]=bits[i];
        if(ok) {
            for(unsigned i=0;i<3;++i)cache->moments[i]=reinterpret_cast<const unsigned long long*>(moments)[i];
            for(unsigned i=0;i<4;++i)cache->q[i]=reinterpret_cast<const unsigned long long*>(q)[i];
        }
        cache->state=ok?1u:2u;
    }
    return ok;
}
#endif
__device__ inline void rotate(const double* q,const double* p,double* out) {
    const double t[3]={2*(q[1]*p[2]-q[2]*p[1]),2*(q[2]*p[0]-q[0]*p[2]),2*(q[0]*p[1]-q[1]*p[0])};
    out[0]=p[0]+q[3]*t[0]+q[1]*t[2]-q[2]*t[1];
    out[1]=p[1]+q[3]*t[1]+q[2]*t[0]-q[0]*t[2];
    out[2]=p[2]+q[3]*t[2]+q[0]*t[1]-q[1]*t[0];
}
__device__ inline bool floatValue(double value,float& out) {
    if(!isfinite(value) || fabs(value)>FLT_MAX)return false;
    out=float(value);return value==0 || fabs(out)>=FLT_MIN;
}
// A vanishing motion component is valid float solver state. Unlike mass and
// inverse inertia, rounding it to a subnormal/zero cannot remove a motion DOF.
// Use normal IEEE conversion rather than rejecting contact-settled bodies.
__device__ inline bool motionValue(double value,float& out) {
    if(!isfinite(value) || fabs(value)>FLT_MAX)return false;
    out=float(value);return true;
}
__device__ inline unsigned prepareDouble(const PxDestructionClusterMassProperties& mass,
    const PxDestructionClusterMotion& motion,PxDestructionClusterBodyState& out,PrincipalFrameCache* cache=nullptr) {
    out={};out.supported=mass.supported!=0;
    if(!isfinite(mass.mass) || mass.mass<0 || (!mass.supported && mass.mass==0))return 1;
    double moments[3],principal[4];
#if defined(PX_CUMETAL) && PX_CUMETAL
    (void)cache; // the Metal cache holds pair frames; this is its out-of-range fallback
    if(!principalFrame(mass.inertia,moments,principal))return 2;
#else
    if(!cachedPrincipalFrame(mass.inertia,moments,principal,cache))return 2;
#endif
    for(unsigned i=0;i<3;++i)if(!isfinite(moments[i]) || moments[i]<0 || (!mass.supported && moments[i]==0))return 2;
    for(unsigned i=0;i<3;++i)
        if(!isfinite(mass.center[i]) || !isfinite(motion.origin[i]) || !isfinite(motion.linearVelocity[i]) || !isfinite(motion.angularVelocity[i]))return 4;
    double length=0;
    for(unsigned i=0;i<4;++i) {if(!isfinite(motion.orientation[i]))return 4;length+=motion.orientation[i]*motion.orientation[i];}
    if(fabs(length-1)>1e-5)return 4; // matches finite unit-quaternion solver input
    // Normalize the float solver observation in double before composing frames.
    double q[4];for(unsigned i=0;i<4;++i)q[i]=motion.orientation[i]/sqrt(length);
    double position[3],sourcePosition[3];rotate(q,mass.center,position);
    rotate(motion.orientation,mass.center,sourcePosition);
    for(unsigned i=0;i<3;++i){position[i]+=motion.origin[i];sourcePosition[i]+=motion.origin[i];}
    const double world[4]={q[3]*principal[0]+q[0]*principal[3]+q[1]*principal[2]-q[2]*principal[1],
        q[3]*principal[1]-q[0]*principal[2]+q[1]*principal[3]+q[2]*principal[0],
        q[3]*principal[2]+q[0]*principal[1]-q[1]*principal[0]+q[2]*principal[3],
        q[3]*principal[3]-q[0]*principal[0]-q[1]*principal[1]-q[2]*principal[2]};
    if(!floatValue(mass.mass,out.mass) || !floatValue(mass.supported?0:1/mass.mass,out.inverseMass))return 8;
    for(unsigned i=0;i<4;++i) {
        // Tiny quaternion components may round to zero without locking a DOF.
        out.bodyToWorldOrientation[i]=float(world[i]);out.bodyToActorOrientation[i]=float(principal[i]);
    }
    for(unsigned i=0;i<3;++i) {
        if(!floatValue(moments[i],out.principalInertia[i]) || !floatValue(mass.supported?0:1/moments[i],out.inverseInertia[i])
            || !motionValue(position[i],out.bodyToWorldPosition[i]) || !motionValue(mass.center[i],out.bodyToActorPosition[i])
            || !motionValue(motion.angularVelocity[i],out.angularVelocity[i]))return 8;
    }
    // Reconcile velocity with the COM actually stored by the float solver.
    // Include the change from normalizing an approximately unit source rotation.
    // Otherwise a large/offset asset silently changes its rigid velocity field.
    const double r[3]={double(out.bodyToWorldPosition[0])-sourcePosition[0],double(out.bodyToWorldPosition[1])-sourcePosition[1],double(out.bodyToWorldPosition[2])-sourcePosition[2]};
    const double* w=motion.angularVelocity;
    const double velocity[3]={motion.linearVelocity[0]+w[1]*r[2]-w[2]*r[1],
        motion.linearVelocity[1]+w[2]*r[0]-w[0]*r[2],motion.linearVelocity[2]+w[0]*r[1]-w[1]*r[0]};
    for(unsigned i=0;i<3;++i)if(!motionValue(velocity[i],out.linearVelocity[i]))return 8;
    return 0;
}
#if defined(PX_CUMETAL) && PX_CUMETAL
// prepareDouble above, operation for operation, in float pairs. Its double version is
// a dependent chain of roughly 150 emulated operations per new cluster after
// the principal frame (normalization, two rotations, a quaternion product,
// reciprocals, the COM velocity); the pair version keeps every validity test
// and error code, reads the double inputs through exact splits, and stores
// each float output as the pair's leading float, which is the double result
// rounded to float up to the pairs' ~2^-44 accuracy.
__device__ inline bool floatValue(destructionPair::Pair value,float& out) {
    if(!isfinite(value.hi))return false;
    out=value.hi;return (value.hi==0 && value.lo==0) || fabsf(out)>=FLT_MIN;
}
__device__ inline bool motionValue(destructionPair::Pair value,float& out) {
    if(!isfinite(value.hi))return false;
    out=value.hi;return true;
}
__device__ inline void rotate(const destructionPair::Pair* q,const destructionPair::Pair* p,destructionPair::Pair* out) {
    using namespace destructionPair;
    const Pair t[3]={scale(sub(mul(q[1],p[2]),mul(q[2],p[1])),2.0f),scale(sub(mul(q[2],p[0]),mul(q[0],p[2])),2.0f),
        scale(sub(mul(q[0],p[1]),mul(q[1],p[0])),2.0f)};
    out[0]=sub(add(add(p[0],mul(q[3],t[0])),mul(q[1],t[2])),mul(q[2],t[1]));
    out[1]=sub(add(add(p[1],mul(q[3],t[1])),mul(q[2],t[0])),mul(q[0],t[2]));
    out[2]=sub(add(add(p[2],mul(q[3],t[2])),mul(q[0],t[1])),mul(q[1],t[0]));
}
// The double path, out of line: inlined, its loops with early returns (and
// those of principalFrame) put the whole of prepare through CuMetal's per-lane
// CFG dispatcher, whose function-scope SSA storage made every pair operation
// several times slower. For the same reason the pair path below takes its
// validity tests after each loop instead of returning from inside it (CuMetal
// lowers a loop with more than one exit through that dispatcher). The tests,
// their order and their error codes are unchanged; outputs written before a
// failing code are discarded with the batch, as before.
__device__ __noinline__ unsigned prepareDoubleOutOfLine(const PxDestructionClusterMassProperties& mass,
    const PxDestructionClusterMotion& motion,PxDestructionClusterBodyState& out,PrincipalFrameCache* cache) {
    return prepareDouble(mass,motion,out,cache);
}
__device__ inline unsigned prepare(const PxDestructionClusterMassProperties& mass,
    const PxDestructionClusterMotion& motion,PxDestructionClusterBodyState& out,PrincipalFrameCache* cache=nullptr) {
    using namespace destructionPair;
    // Pairs are floats: tensors, diagonal moments or masses far outside
    // [2^-60, 2^60] (relative to the tensor's scale for the diagonal) would
    // underflow or overflow them where double does not. Those inputs, which
    // only unphysical or rejected clusters produce, keep the double path and
    // so its exact error codes.
    {
        double norm=0;for(unsigned i=0;i<6;++i)norm=fmax(norm,fabs(mass.inertia[i]));
        bool inRange=isfinite(norm) && (norm==0 || (norm>=0x1p-60 && norm<=0x1p60))
            && (mass.mass==0 || (fabs(mass.mass)>=0x1p-60 && fabs(mass.mass)<=0x1p60));
        for(unsigned i=0;i<3;++i)inRange=inRange && (mass.inertia[i]==0 || fabs(mass.inertia[i])>=norm*0x1p-60);
        // Nonzero positions and velocities below 2^-60 (contact-settled
        // bodies can carry subnormal motion) keep their exact float
        // conversion on the double path; float arithmetic may flush them.
        const auto tiny=[](double x){return x!=0 && !(fabs(x)>=0x1p-60);};
        for(unsigned i=0;i<3;++i)
            inRange=inRange && !tiny(mass.center[i]) && !tiny(motion.origin[i]) && !tiny(motion.linearVelocity[i]) && !tiny(motion.angularVelocity[i]);
        if(!inRange)return prepareDoubleOutOfLine(mass,motion,out,cache);
    }
    out={};out.supported=mass.supported!=0;
    if(!isfinite(mass.mass) || mass.mass<0 || (!mass.supported && mass.mass==0))return 1;
    Pair moments[3],principal[4];
    if(!cachedPrincipalFrame(mass.inertia,moments,principal,cache))return 2;
    const Pair zero=pair(0.0f),one=pair(1.0f);
    bool invalidMoments=false;
    for(unsigned i=0;i<3;++i)invalidMoments=invalidMoments || !finite(moments[i]) || less(moments[i],zero) || (!mass.supported && moments[i].hi==0);
    if(invalidMoments)return 2;
    bool invalidMotion=false;
    for(unsigned i=0;i<3;++i)
        invalidMotion=invalidMotion || !isfinite(mass.center[i]) || !isfinite(motion.origin[i]) || !isfinite(motion.linearVelocity[i]) || !isfinite(motion.angularVelocity[i]);
    if(invalidMotion)return 4;
    Pair orientation[4],length=zero;
    for(unsigned i=0;i<4;++i)invalidMotion=invalidMotion || !isfinite(motion.orientation[i]);
    if(invalidMotion)return 4;
    for(unsigned i=0;i<4;++i){orientation[i]=pair(motion.orientation[i]);length=add(length,mul(orientation[i],orientation[i]));}
    // fabs(length-1)>1e-5 with 1e-5 as the double constant (float pair).
    constexpr float toleranceHi=1e-5f;constexpr float toleranceLo=float(1e-5-double(toleranceHi));
    if(less(Pair{toleranceHi,toleranceLo},abs(sub(length,one))))return 4;
    // Normalize the float solver observation before composing frames.
    const Pair root=sqrt(length);Pair q[4];for(unsigned i=0;i<4;++i)q[i]=div(orientation[i],root);
    const Pair center[3]={pair(mass.center[0]),pair(mass.center[1]),pair(mass.center[2])};
    Pair position[3],sourcePosition[3];rotate(q,center,position);rotate(orientation,center,sourcePosition);
    for(unsigned i=0;i<3;++i){const Pair origin=pair(motion.origin[i]);position[i]=add(position[i],origin);sourcePosition[i]=add(sourcePosition[i],origin);}
    const Pair* r=principal;
    const Pair world[4]={sub(add(add(mul(q[3],r[0]),mul(q[0],r[3])),mul(q[1],r[2])),mul(q[2],r[1])),
        add(add(sub(mul(q[3],r[1]),mul(q[0],r[2])),mul(q[1],r[3])),mul(q[2],r[0])),
        add(sub(add(mul(q[3],r[2]),mul(q[0],r[1])),mul(q[1],r[0])),mul(q[2],r[3])),
        sub(sub(sub(mul(q[3],r[3]),mul(q[0],r[0])),mul(q[1],r[1])),mul(q[2],r[2]))};
    if(!floatValue(mass.mass,out.mass) || !floatValue(mass.supported?zero:div(one,pair(mass.mass)),out.inverseMass))return 8;
    for(unsigned i=0;i<4;++i) {
        // Tiny quaternion components may round to zero without locking a DOF.
        out.bodyToWorldOrientation[i]=world[i].hi;out.bodyToActorOrientation[i]=principal[i].hi;
    }
    bool unrepresentable=false;
    for(unsigned i=0;i<3;++i) {
        // Every conversion is attempted (each writes its output), as the
        // original's short-circuit order would up to the first failure.
        const bool momentOk=floatValue(moments[i],out.principalInertia[i]);
        const bool inverseOk=momentOk && floatValue(mass.supported?zero:div(one,moments[i]),out.inverseInertia[i]);
        const bool positionOk=inverseOk && motionValue(position[i],out.bodyToWorldPosition[i]);
        const bool actorOk=positionOk && motionValue(mass.center[i],out.bodyToActorPosition[i]);
        const bool spinOk=actorOk && motionValue(motion.angularVelocity[i],out.angularVelocity[i]);
        unrepresentable=unrepresentable || !spinOk;
    }
    if(unrepresentable)return 8;
    // Reconcile velocity with the COM actually stored by the float solver.
    // Include the change from normalizing an approximately unit source rotation.
    Pair w[3],offset[3];
    for(unsigned i=0;i<3;++i){w[i]=pair(motion.angularVelocity[i]);offset[i]=sub(pair(out.bodyToWorldPosition[i]),sourcePosition[i]);}
    for(unsigned i=0;i<3;++i) {
        const unsigned j=i==2?0:i+1,k=i==0?2:i-1;
        unrepresentable=unrepresentable || !motionValue(sub(add(pair(motion.linearVelocity[i]),mul(w[j],offset[k])),mul(w[k],offset[j])),out.linearVelocity[i]);
    }
    return unrepresentable?8:0;
}
#else
__device__ inline unsigned prepare(const PxDestructionClusterMassProperties& mass,
    const PxDestructionClusterMotion& motion,PxDestructionClusterBodyState& out,PrincipalFrameCache* cache=nullptr) {
    return prepareDouble(mass,motion,out,cache);
}
#endif
}} // namespace physx::destructionBody
