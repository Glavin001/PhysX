// destructionBody::prepare (pairs, PX_CUMETAL) timing and a host-double check of the principal frame.
#include "common/PxPhysXCommonConfig.h"
#include "PxDestructionTopologyTypes.h"
#include "PxgDestructionBody.cuh"
#include <cuda_runtime.h>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <random>
#include <vector>
#include <chrono>
#include <algorithm>
using namespace physx;
namespace physx{namespace destructionBody{
namespace countedPairs {
using namespace destructionPair;
__device__ __forceinline__ Pair pick(bool c,Pair x,Pair y){return {c?x.hi:y.hi,c?x.lo:y.lo};}
__device__ inline bool frame(const double* inertia,Pair* moments,Pair* q,unsigned* its) {
    double norm=0;
    for(unsigned i=0;i<6;++i) {
        if(!isfinite(inertia[i]))return false;
        norm=fmax(norm,fabs(inertia[i]));
    }
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
        ++*its;
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
}}
namespace physx{namespace destructionBody{
namespace stagePairs {
using namespace destructionPair;
__device__ __forceinline__ Pair pick(bool c,Pair x,Pair y){return {c?x.hi:y.hi,c?x.lo:y.lo};}
template<int Stage> __device__ inline bool frame(const double* inertia,Pair* moments,Pair* q) {
    double norm=0;
    for(unsigned i=0;i<6;++i) {
        if(!isfinite(inertia[i]))return false;
        norm=fmax(norm,fabs(inertia[i]));
    }
    if(norm==0) {for(unsigned i=0;i<3;++i){moments[i]=pair(0.0f);q[i]=pair(0.0f);}q[3]=pair(1.0f);return true;}
    const Pair s0=pair(norm);
    // a: symmetric, a00 a11 a22 a01 a02 a12 (inertia order).
    Pair a00=div(pair(inertia[0]),s0),a11=div(pair(inertia[1]),s0),a22=div(pair(inertia[2]),s0),
        a01=div(pair(inertia[3]),s0),a02=div(pair(inertia[4]),s0),a12=div(pair(inertia[5]),s0);
    if(Stage==0){moments[0]=add(add(a00,a11),add(a22,a01));moments[1]=add(a02,a12);return true;}
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
    if(Stage==1){moments[0]=add(add(a00,a11),add(a22,a01));moments[1]=add(add(v00,v11),add(v22,v01));moments[2]=add(add(v02,v12),add(v10,v20));q[0]=v21;return true;}
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
}}
template<int S> __global__ void kStage(const PxDestructionClusterMassProperties* m,float* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;destructionPair::Pair a[3]={},b[4]={};destructionBody::stagePairs::frame<S>(m[i].inertia,a,b);out[i]=a[0].hi+a[1].hi+a[2].hi+b[0].hi+b[1].hi+b[2].hi+b[3].hi;}
namespace physx{namespace destructionBody{
namespace floatInPairs {
using namespace destructionPair;
__device__ __forceinline__ Pair pick(bool c,Pair x,Pair y){return {c?x.hi:y.hi,c?x.lo:y.lo};}
__device__ inline bool frame(const Pair* e,Pair s0,Pair* moments,Pair* q) {
    // a: symmetric, a00 a11 a22 a01 a02 a12 (inertia order).
    Pair a00=e[0],a11=e[1],a22=e[2],a01=e[3],a02=e[4],a12=e[5];
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
}}
__global__ void kNoDouble(const destructionPair::Pair* e,float* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;destructionPair::Pair a[3]={},b[4]={};destructionBody::floatInPairs::frame(e+6*i,destructionPair::pair(1.0f),a,b);out[i]=a[0].hi+a[1].hi+a[2].hi+b[0].hi+b[1].hi+b[2].hi+b[3].hi;}
// A: inputs pre-split pairs, outputs rounded to double with value() (emulated add).
__global__ void kA(const destructionPair::Pair* e,double* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;destructionPair::Pair a[3]={},b[4]={};destructionBody::floatInPairs::frame(e+6*i,destructionPair::pair(1.0f),a,b);
  for(int k=0;k<3;++k)out[7*i+k]=destructionPair::value(a[k]);for(int k=0;k<4;++k)out[7*i+3+k]=destructionPair::value(b[k]);}
// B: inputs from doubles via pair(double) (emulated subtraction), outputs float.
__global__ void kB(const double* inertia,float* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;destructionPair::Pair e[6];for(int k=0;k<6;++k)e[k]=destructionPair::pair(inertia[6*i+k]);
  destructionPair::Pair a[3]={},b[4]={};destructionBody::floatInPairs::frame(e,destructionPair::pair(1.0f),a,b);out[i]=a[0].hi+a[1].hi+a[2].hi+b[0].hi+b[1].hi+b[2].hi+b[3].hi;}
// C: inputs split from the double's bits with integer operations only.
__device__ __forceinline__ destructionPair::Pair splitBits(unsigned long long b){
  // hi: round-to-nearest-even float of the double; lo: float of the remainder (exact for normal ranges).
  const unsigned sign=unsigned(b>>63);const int e=int((b>>52)&0x7ff);unsigned long long m=b&0xfffffffffffffull;
  if(e==0)return {0.0f,0.0f};
  m|=1ull<<52;                               // 53-bit significand
  unsigned long long top=m>>29;               // 24 bits
  const unsigned long long rest=m&((1ull<<29)-1);
  // round half to even
  if(rest>(1ull<<28) || (rest==(1ull<<28) && (top&1)))++top;
  // hi = top * 2^(e-1023-23)
  const int ee=e-1023;
  float hi=__uint_as_float(sign<<31|unsigned((ee+127)<<23))*float(top)*0x1p-23f;
  // remainder r = m - top<<29 (signed), in units of 2^(ee-52)
  const long long r=(long long)m-(long long)(top<<29);
  float lo=float(r)*__uint_as_float(unsigned((ee-52+127)<<23));
  if(sign)lo=-lo;
  return {hi,lo};}
__global__ void kC(const unsigned long long* inertia,float* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;destructionPair::Pair e[6];for(int k=0;k<6;++k)e[k]=splitBits(inertia[6*i+k]);
  destructionPair::Pair a[3]={},b[4]={};destructionBody::floatInPairs::frame(e,destructionPair::pair(1.0f),a,b);out[i]=a[0].hi+a[1].hi+a[2].hi+b[0].hi+b[1].hi+b[2].hi+b[3].hi;}
// D: the real prologue semantics (finite check, max-magnitude scale, scaled tensor) with integer splits only.
__global__ void kD(const unsigned long long* inertia,float* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  using namespace physx::destructionPair;Pair e[6];Pair norm=pair(0.0f);
  for(int k=0;k<6;++k){const unsigned long long b=inertia[6*i+k];if(((b>>52)&0x7ff)==0x7ff){out[i]=-1;return;}e[k]=splitBits(b);if(less(norm,abs(e[k])))norm=abs(e[k]);}
  if(norm.hi==0){out[i]=0;return;}
  for(int k=0;k<6;++k)e[k]=div(e[k],norm);
  destructionPair::Pair a[3]={},b[4]={};destructionBody::floatInPairs::frame(e,norm,a,b);out[i]=a[0].hi+a[1].hi+a[2].hi+b[0].hi+b[1].hi+b[2].hi+b[3].hi;}
// E: like D but the scale division folded after a noinline boundary.
__device__ __noinline__ void frameCall(const physx::destructionPair::Pair* e,physx::destructionPair::Pair s,physx::destructionPair::Pair* a,physx::destructionPair::Pair* b){destructionBody::floatInPairs::frame(e,s,a,b);}
__global__ void kE(const unsigned long long* inertia,float* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  using namespace physx::destructionPair;Pair e[6];Pair norm=pair(0.0f);
  for(int k=0;k<6;++k){const unsigned long long b=inertia[6*i+k];if(((b>>52)&0x7ff)==0x7ff){out[i]=-1;return;}e[k]=splitBits(b);if(less(norm,abs(e[k])))norm=abs(e[k]);}
  if(norm.hi==0){out[i]=0;return;}
  for(int k=0;k<6;++k)e[k]=div(e[k],norm);
  Pair a[3]={},b[4]={};frameCall(e,norm,a,b);out[i]=a[0].hi+a[1].hi+a[2].hi+b[0].hi+b[1].hi+b[2].hi+b[3].hi;}
// F: D without the early returns (flags instead).
__global__ void kF(const unsigned long long* inertia,float* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  using namespace physx::destructionPair;Pair e[6];Pair norm=pair(0.0f);unsigned bad=0;
  for(int k=0;k<6;++k){const unsigned long long b=inertia[6*i+k];bad|=((b>>52)&0x7ff)==0x7ff;e[k]=splitBits(b);if(less(norm,abs(e[k])))norm=abs(e[k]);}
  if(norm.hi==0)norm=pair(1.0f);
  for(int k=0;k<6;++k)e[k]=div(e[k],norm);
  Pair a[3]={},b[4]={};destructionBody::floatInPairs::frame(e,norm,a,b);out[i]=bad?-1.0f:a[0].hi+a[1].hi+a[2].hi+b[0].hi+b[1].hi+b[2].hi+b[3].hi;}
namespace physx{namespace destructionBody{
__device__ inline unsigned prepareNoFallback(const PxDestructionClusterMassProperties& mass,
    const PxDestructionClusterMotion& motion,PxDestructionClusterBodyState& out,PrincipalFrameCache* cache) {
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
        if(!inRange)return 16;
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
}}
__global__ void kPrepNF(const PxDestructionClusterMassProperties* m,const PxDestructionClusterMotion* mo,PxDestructionClusterBodyState* out,unsigned* err,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;err[i]=destructionBody::prepareNoFallback(m[i],mo[i],out[i],nullptr);}
__global__ void kCount(const PxDestructionClusterMassProperties* m,unsigned* its,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;destructionPair::Pair a[3],b[4];its[i]=0;destructionBody::countedPairs::frame(m[i].inertia,a,b,its+i);}

__global__ void kPrepare(const PxDestructionClusterMassProperties* m,const PxDestructionClusterMotion* mo,PxDestructionClusterBodyState* out,unsigned* err,unsigned n){
  unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;err[i]=destructionBody::prepare(m[i],mo[i],out[i],nullptr);}
__global__ void kFrame(const PxDestructionClusterMassProperties* m,double* mom,double* q,unsigned n){
  unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;destructionBody::principalFramePair(m[i].inertia,mom+3*i,q+4*i);}
__global__ void kFrameNew(const PxDestructionClusterMassProperties* m,double* mom,double* q,unsigned n){
  unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;destructionPair::Pair a[3],b[4];
  if(!destructionBody::principalPairs::frame(m[i].inertia,a,b)){for(int k=0;k<3;++k)mom[3*i+k]=-1;return;}
  for(int k=0;k<3;++k)mom[3*i+k]=destructionPair::value(a[k]);for(int k=0;k<4;++k)q[4*i+k]=destructionPair::value(b[k]);}
int main(int argc,char**argv){
  const unsigned n=argc>1?atoi(argv[1]):64;std::mt19937 rng(3);std::uniform_real_distribution<double> u(-1,1);
  std::vector<PxDestructionClusterMassProperties> m(n);std::vector<PxDestructionClusterMotion> mo(n);
  for(unsigned i=0;i<n;++i){auto& c=m[i];memset(&c,0,sizeof(c));c.mass=std::pow(10.0,1+3*std::abs(u(rng)));
    // random rotated diagonal tensor
    double d[3]={c.mass*(1+std::abs(u(rng))),c.mass*(1+std::abs(u(rng))),c.mass*(1+std::abs(u(rng)))};
    double a=u(rng)*3,b=u(rng)*3,g=u(rng)*3;double ca=cos(a),sa=sin(a),cb=cos(b),sb=sin(b),cg=cos(g),sg=sin(g);
    double R[3][3]={{ca*cb,ca*sb*sg-sa*cg,ca*sb*cg+sa*sg},{sa*cb,sa*sb*sg+ca*cg,sa*sb*cg-ca*sg},{-sb,cb*sg,cb*cg}};
    double I[3][3]={};for(int r=0;r<3;++r)for(int s=0;s<3;++s)for(int k=0;k<3;++k)I[r][s]+=R[r][k]*d[k]*R[s][k];
    c.inertia[0]=I[0][0];c.inertia[1]=I[1][1];c.inertia[2]=I[2][2];c.inertia[3]=I[0][1];c.inertia[4]=I[0][2];c.inertia[5]=I[1][2];
    for(int k=0;k<3;++k)c.center[k]=5*u(rng);
    double q[4],l=0;for(int k=0;k<4;++k){q[k]=u(rng);l+=q[k]*q[k];}for(int k=0;k<4;++k)mo[i].orientation[k]=float(q[k]/std::sqrt(l));
    for(int k=0;k<3;++k){mo[i].origin[k]=400*u(rng);mo[i].linearVelocity[k]=5*u(rng);mo[i].angularVelocity[k]=2*u(rng);}}
  PxDestructionClusterMassProperties* dm;PxDestructionClusterMotion* dmo;PxDestructionClusterBodyState* dout;unsigned* derr;double *dmom,*dq;
  cudaMalloc(&dm,n*sizeof(m[0]));cudaMalloc(&dmo,n*sizeof(mo[0]));cudaMalloc(&dout,n*sizeof(PxDestructionClusterBodyState));cudaMalloc(&derr,n*4);cudaMalloc(&dmom,n*24);cudaMalloc(&dq,n*32);
  cudaMemcpy(dm,m.data(),n*sizeof(m[0]),cudaMemcpyHostToDevice);cudaMemcpy(dmo,mo.data(),n*sizeof(mo[0]),cudaMemcpyHostToDevice);
  auto time=[&](auto f){double best=1e9;for(int r=0;r<5;++r){cudaDeviceSynchronize();auto t0=std::chrono::steady_clock::now();for(int k=0;k<30;++k)f();
    auto e=cudaDeviceSynchronize();if(e)printf("err %s\n",cudaGetErrorString(e));best=std::min(best,std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-t0).count()/30);}return best;};
  const double tp=time([&]{kPrepare<<<(n+127)/128,128>>>(dm,dmo,dout,derr,n);});
  const double tf=time([&]{kFrame<<<(n+127)/128,128>>>(dm,dmom,dq,n);});
  std::vector<double> mom(3*n),q(4*n);cudaMemcpy(mom.data(),dmom,n*24,cudaMemcpyDeviceToHost);cudaMemcpy(q.data(),dq,n*32,cudaMemcpyDeviceToHost);
  std::vector<unsigned> err(n);cudaMemcpy(err.data(),derr,n*4,cudaMemcpyDeviceToHost);
  // host: eigenvalues via characteristic check: reconstruct R diag(mom) R^T and compare with the tensor
  double worst=0;unsigned errors=0;
  for(unsigned i=0;i<n;++i){errors+=err[i]!=0;const double* qq=&q[4*i];double x=qq[0],y=qq[1],z=qq[2],w=qq[3];
    double R[3][3]={{1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)},{2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)},{2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)}};
    double I[3][3]={};for(int r=0;r<3;++r)for(int s=0;s<3;++s)for(int k=0;k<3;++k)I[r][s]+=R[r][k]*mom[3*i+k]*R[s][k];
    const auto& c=m[i].inertia;double T[3][3]={{c[0],c[3],c[4]},{c[3],c[1],c[5]},{c[4],c[5],c[2]}};double sc=0;for(int k=0;k<6;++k)sc=std::max(sc,std::fabs(c[k]));
    for(int r=0;r<3;++r)for(int s=0;s<3;++s)worst=std::max(worst,std::fabs(I[r][s]-T[r][s])/sc);}
  double *dmom2,*dq2;cudaMalloc(&dmom2,n*24);cudaMalloc(&dq2,n*32);
  const double tn=time([&]{kFrameNew<<<(n+127)/128,128>>>(dm,dmom2,dq2,n);});
  std::vector<double> mom2(3*n),q2(4*n);cudaMemcpy(mom2.data(),dmom2,n*24,cudaMemcpyDeviceToHost);cudaMemcpy(q2.data(),dq2,n*32,cudaMemcpyDeviceToHost);
  printf("new frame %.1f us/launch, bitwise equal moments %d quats %d\n",tn,int(!memcmp(mom.data(),mom2.data(),n*24)),int(!memcmp(q.data(),q2.data(),n*32)));
  {unsigned* dit;cudaMalloc(&dit,n*4);kCount<<<(n+127)/128,128>>>(dm,dit,n);std::vector<unsigned> it(n);cudaMemcpy(it.data(),dit,n*4,cudaMemcpyDeviceToHost);unsigned mx=0;double sum=0;for(auto x:it){mx=std::max(mx,x);sum+=x;}printf("iterations mean %.1f max %u\n",sum/n,mx);}
  {float* fo;cudaMalloc(&fo,n*4);printf("stage0 (prologue) %.1f stage1 (+loop) %.1f stage2 (full) %.1f\n",time([&]{kStage<0><<<(n+127)/128,128>>>(dm,fo,n);}),time([&]{kStage<1><<<(n+127)/128,128>>>(dm,fo,n);}),time([&]{kStage<2><<<(n+127)/128,128>>>(dm,fo,n);}));}
  {std::vector<destructionPair::Pair> e(6*n);for(unsigned i=0;i<n;++i){double sc=0;for(int k=0;k<6;++k)sc=std::max(sc,std::fabs(m[i].inertia[k]));for(int k=0;k<6;++k){double d=m[i].inertia[k]/sc;float hi=float(d);e[6*i+k]={hi,float(d-double(hi))};}}
   destructionPair::Pair* de;cudaMalloc(&de,e.size()*8);cudaMemcpy(de,e.data(),e.size()*8,cudaMemcpyHostToDevice);float* fo;cudaMalloc(&fo,n*4);
   printf("no-double frame %.1f us/launch\n",time([&]{kNoDouble<<<(n+127)/128,128>>>(de,fo,n);}));
   double* dd;cudaMalloc(&dd,n*7*8);std::vector<double> scaled(6*n);for(unsigned i=0;i<n;++i){double sc=0;for(int k=0;k<6;++k)sc=std::max(sc,std::fabs(m[i].inertia[k]));for(int k=0;k<6;++k)scaled[6*i+k]=m[i].inertia[k]/sc;}
   std::vector<double> raw(6*n);for(unsigned i=0;i<n;++i)for(int k=0;k<6;++k)raw[6*i+k]=m[i].inertia[k];double* dsraw;cudaMalloc(&dsraw,raw.size()*8);cudaMemcpy(dsraw,raw.data(),raw.size()*8,cudaMemcpyHostToDevice);
   double* ds;cudaMalloc(&ds,scaled.size()*8);cudaMemcpy(ds,scaled.data(),scaled.size()*8,cudaMemcpyHostToDevice);
   printf("A value() out %.1f | B pair(double) in %.1f | C integer split in %.1f | D integer prologue %.1f | E noinline %.1f | F no early return %.1f us/launch\n",time([&]{kA<<<(n+127)/128,128>>>(de,dd,n);}),time([&]{kB<<<(n+127)/128,128>>>(ds,fo,n);}),time([&]{kC<<<(n+127)/128,128>>>((const unsigned long long*)ds,fo,n);}),time([&]{kD<<<(n+127)/128,128>>>((const unsigned long long*)dsraw,fo,n);}),time([&]{kE<<<(n+127)/128,128>>>((const unsigned long long*)dsraw,fo,n);}),time([&]{kF<<<(n+127)/128,128>>>((const unsigned long long*)dsraw,fo,n);}));
   // check integer split == pair(double) host split
   int bad=0;for(unsigned i=0;i<6*n;++i){double d=scaled[i];float hi=float(d);float lo=float(d-double(hi));(void)lo;} (void)bad;}
  printf("prepare without fallback %.1f us/launch\n",time([&]{kPrepNF<<<(n+127)/128,128>>>(dm,dmo,dout,derr,n);}));
  printf("n=%u prepare %.1f us/launch, principalFramePair %.1f us/launch | reconstruction rel err %.3g | prepare errors %u\n",n,tp,tf,worst,errors);
}
