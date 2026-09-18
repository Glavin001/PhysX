// SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "StressElasticOperator.cuh"

// Compensated fine-row evaluation for true residuals. Iteration/operator and
// preconditioner work remain FP64. The final balance test must not accept the
// cancellation error of that cheaper operator as physical equilibrium.
namespace Nv { namespace Blast { namespace Elastic { namespace Accurate {
struct Scalar { double hi,lo; };
struct Vector { Scalar v[6]; };
__device__ __forceinline__ Scalar sum(double a,double b) {
    const double hi=a+b,part=hi-a;
    return {hi,(a-(hi-part))+(b-part)};
}
__device__ __forceinline__ Scalar add(Scalar a,Scalar b) {
    const auto hi=sum(a.hi,b.hi),lo=sum(a.lo,b.lo);
    const auto mid=sum(hi.lo,lo.hi),result=sum(hi.hi,mid.hi);
    return sum(result.hi,result.lo+mid.lo+lo.lo);
}
__device__ __forceinline__ Scalar negate(Scalar a) {return {-a.hi,-a.lo};}
__device__ __forceinline__ Scalar multiply(Scalar a,Scalar b) {
    const double hi=a.hi*b.hi;
    return sum(hi,fma(a.hi,b.hi,-hi)+a.hi*b.lo+a.lo*b.hi+a.lo*b.lo);
}
__device__ __forceinline__ Scalar multiply(Scalar a,double b) {return multiply(a,{b,0});}
__device__ __forceinline__ Scalar divide(Scalar a,double b) {
    const double q=a.hi/b;
    return add({q,0},multiply(add(a,negate(multiply({q,0},b))),1.0/b));
}
__device__ __forceinline__ double value(Scalar a) {return a.hi+a.lo;}
__device__ __forceinline__ void rotate(const double* frame,const Scalar* in,Scalar* out,bool transpose) {
    for(unsigned i=0;i<3;++i) {
        out[i]={};for(unsigned j=0;j<3;++j)out[i]=add(out[i],multiply(in[j],frame[transpose?3*j+i:3*i+j]));
    }
}
__device__ __forceinline__ void offset(const Bond& e,double3 position,Scalar* r) {
    r[0]=sum(e.point[0],-position.x);r[1]=sum(e.point[1],-position.y);r[2]=sum(e.point[2],-position.z);
}
__device__ __forceinline__ void cross(const Scalar* a,const Scalar* b,Scalar* out) {
    for(unsigned i=0;i<3;++i) {
        const auto j=(i+1)%3,k=(i+2)%3;
        out[i]=add(multiply(a[j],b[k]),negate(multiply(a[k],b[j])));
    }
}
__device__ Vector endpoint(const Bond& e,double3 position,Vector q,double sign) {
    Scalar r[3],theta[3],motion[3],translation[3];offset(e,position,r);
    for(unsigned k=0;k<3;++k)theta[k]=q.v[3+k];cross(theta,r,motion);
    for(unsigned k=0;k<3;++k)translation[k]=add(q.v[k],motion[k]);
    Vector result{};rotate(e.frame,translation,result.v,true);rotate(e.frame,theta,result.v+3,true);
    if(sign<0)for(auto& v:result.v)v=negate(v);
    return result;
}
__device__ Vector endpoint(const Bond& e,double3 position,Elastic::Vector q,double sign) {
    Vector pair{};for(unsigned k=0;k<6;++k)pair.v[k]={q.v[k],0};
    return endpoint(e,position,pair,sign);
}
__device__ Vector transposeEndpoint(const Bond& e,double3 position,Vector s,double sign) {
    Scalar r[3],force[3],moment[3],arm[3];offset(e,position,r);
    rotate(e.frame,s.v,force,false);rotate(e.frame,s.v+3,moment,false);cross(r,force,arm);
    Vector result{};
    for(unsigned k=0;k<3;++k){result.v[k]=force[k];result.v[k+3]=add(moment[k],arm[k]);}
    if(sign<0)for(auto& v:result.v)v=negate(v);
    return result;
}
__device__ Vector row(Graph g,uint32_t i,const Elastic::Vector* x,double length,const Elastic::Vector* low=nullptr) {
    Vector result{};if(g.prescribed[i])return result;
    for(uint32_t k=g.starts[i];k<g.starts[i+1];++k) {
        const auto id=g.references[k];if(!live(g,id))continue;
        const auto& e=g.interfaces[id];
        Vector a{},b{};
        for(unsigned j=0;j<6;++j) {
            if(!g.prescribed[e.first])a.v[j]={x[e.first].v[j],low?low[e.first].v[j]:0};
            if(!g.prescribed[e.second])b.v[j]={x[e.second].v[j],low?low[e.second].v[j]:0};
            // Standard route preserves its physical FP64 export. Extended route
            // retains the two-word representation through physical scaling.
            if(j>=3) {
                a.v[j]=low?divide(a.v[j],length):Scalar{a.v[j].hi/length,0};
                b.v[j]=low?divide(b.v[j],length):Scalar{b.v[j].hi/length,0};
            }
        }
        auto d=Accurate::endpoint(e,g.positions[e.first],a,-1);const auto second=Accurate::endpoint(e,g.positions[e.second],b,1);
        for(unsigned j=0;j<6;++j)d.v[j]=add(d.v[j],second.v[j]);
        Vector stress{};
        for(unsigned r=0;r<6;++r)for(unsigned c=0;c<6;++c)stress.v[r]=add(stress.v[r],multiply(d.v[c],e.stiffness.v[6*r+c]));
        const auto force=transposeEndpoint(e,g.positions[i],stress,e.first==i?-1:1);
        for(unsigned j=0;j<6;++j)result.v[j]=add(result.v[j],force.v[j]);
    }
    return result;
}
// Recover with the same arithmetic as the accepted original-equation residual.
// Otherwise cancellation in a nearly zero channel can reappear at publication.
__global__ void recover(Graph g,const Elastic::Vector* dynamic,const Elastic::Vector* prescribed,
                        Elastic::Vector* response,double* energy,const uint32_t* error,const Elastic::Vector* dynamicLow=nullptr) {
    const auto id=blockIdx.x*blockDim.x+threadIdx.x;if(id>=g.bonds)return;
    Elastic::Vector output{};Scalar work{};
    if(!*error && live(g,id)) {
        const auto& e=g.interfaces[id];
        Vector a{},b{};
        for(unsigned k=0;k<6;++k) {
            a.v[k]=g.prescribed[e.first]?Scalar{prescribed[e.first].v[k],0}:
                Scalar{dynamic[e.first].v[k],dynamicLow?dynamicLow[e.first].v[k]:0};
            b.v[k]=g.prescribed[e.second]?Scalar{prescribed[e.second].v[k],0}:
                Scalar{dynamic[e.second].v[k],dynamicLow?dynamicLow[e.second].v[k]:0};
        }
        auto d=Accurate::endpoint(e,g.positions[e.first],a,-1);
        const auto other=Accurate::endpoint(e,g.positions[e.second],b,1);
        for(unsigned k=0;k<6;++k)d.v[k]=add(add(d.v[k],other.v[k]),{-e.inelastic.v[k],0});
        Vector stress{};
        for(unsigned r=0;r<6;++r)for(unsigned c=0;c<6;++c)stress.v[r]=add(stress.v[r],multiply(d.v[c],e.stiffness.v[6*r+c]));
        for(unsigned k=0;k<6;++k){output.v[k]=value(stress.v[k]);work=add(work,multiply(d.v[k],stress.v[k]));}
    }
    response[id]=output;energy[id]=.5*value(work);
}
}}}}
