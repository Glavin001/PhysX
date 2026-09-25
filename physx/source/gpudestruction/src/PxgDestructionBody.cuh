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
    const bool ok=principalFramePairs(inertia,moments,q);
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
        for(unsigned i=0;i<3 && inRange;++i)inRange=mass.inertia[i]==0 || fabs(mass.inertia[i])>=norm*0x1p-60;
        // Nonzero positions and velocities below 2^-60 (contact-settled
        // bodies can carry subnormal motion) keep their exact float
        // conversion on the double path; float arithmetic may flush them.
        const auto tiny=[](double x){return x!=0 && !(fabs(x)>=0x1p-60);};
        for(unsigned i=0;i<3 && inRange;++i)
            inRange=!tiny(mass.center[i]) && !tiny(motion.origin[i]) && !tiny(motion.linearVelocity[i]) && !tiny(motion.angularVelocity[i]);
        if(!inRange)return prepareDouble(mass,motion,out,cache);
    }
    out={};out.supported=mass.supported!=0;
    if(!isfinite(mass.mass) || mass.mass<0 || (!mass.supported && mass.mass==0))return 1;
    Pair moments[3],principal[4];
    if(!cachedPrincipalFrame(mass.inertia,moments,principal,cache))return 2;
    const Pair zero=pair(0.0f),one=pair(1.0f);
    for(unsigned i=0;i<3;++i)if(!finite(moments[i]) || less(moments[i],zero) || (!mass.supported && moments[i].hi==0))return 2;
    for(unsigned i=0;i<3;++i)
        if(!isfinite(mass.center[i]) || !isfinite(motion.origin[i]) || !isfinite(motion.linearVelocity[i]) || !isfinite(motion.angularVelocity[i]))return 4;
    Pair orientation[4],length=zero;
    for(unsigned i=0;i<4;++i) {if(!isfinite(motion.orientation[i]))return 4;orientation[i]=pair(motion.orientation[i]);length=add(length,mul(orientation[i],orientation[i]));}
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
    for(unsigned i=0;i<3;++i) {
        if(!floatValue(moments[i],out.principalInertia[i]) || !floatValue(mass.supported?zero:div(one,moments[i]),out.inverseInertia[i])
            || !motionValue(position[i],out.bodyToWorldPosition[i]) || !motionValue(mass.center[i],out.bodyToActorPosition[i])
            || !motionValue(motion.angularVelocity[i],out.angularVelocity[i]))return 8;
    }
    // Reconcile velocity with the COM actually stored by the float solver.
    // Include the change from normalizing an approximately unit source rotation.
    Pair w[3],offset[3];
    for(unsigned i=0;i<3;++i){w[i]=pair(motion.angularVelocity[i]);offset[i]=sub(pair(out.bodyToWorldPosition[i]),sourcePosition[i]);}
    for(unsigned i=0;i<3;++i) {
        const unsigned j=i==2?0:i+1,k=i==0?2:i-1;
        if(!motionValue(sub(add(pair(motion.linearVelocity[i]),mul(w[j],offset[k])),mul(w[k],offset[j])),out.linearVelocity[i]))return 8;
    }
    return 0;
}
#else
__device__ inline unsigned prepare(const PxDestructionClusterMassProperties& mass,
    const PxDestructionClusterMotion& motion,PxDestructionClusterBodyState& out,PrincipalFrameCache* cache=nullptr) {
    return prepareDouble(mass,motion,out,cache);
}
#endif
}} // namespace physx::destructionBody
