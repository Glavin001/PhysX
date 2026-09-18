// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxDestructionTopologyTypes.h"
#include <cfloat>
#include <cmath>

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
__device__ inline unsigned prepare(const PxDestructionClusterMassProperties& mass,
    const PxDestructionClusterMotion& motion,PxDestructionClusterBodyState& out) {
    out={};out.supported=mass.supported!=0;
    if(!isfinite(mass.mass) || mass.mass<0 || (!mass.supported && mass.mass==0))return 1;
    double moments[3],principal[4];
    if(!principalFrame(mass.inertia,moments,principal))return 2;
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
}} // namespace physx::destructionBody
