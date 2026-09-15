// SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include <cuda_runtime.h>
#include <cstdint>
#include <cmath>

// Private fine-equation implementation for the six-channel interface model.
// Included by its owning CUDA translation unit; not an alternate engine backend.
namespace Nv { namespace Blast { namespace Elastic {
struct Vector { double v[6]; }; // translation/force first, rotation/moment second
struct Matrix { double v[36]; }; // row-major, including full symmetric coupling
struct Bond {
    uint32_t first,second,live;
    double point[3],frame[9]; // one common interface point; frame maps local -> component
    Matrix stiffness;
    Vector inelastic;
};
struct Graph {
    uint32_t nodes,bonds;
    const double3* positions;
    const Bond* interfaces;
    const uint32_t* starts; // nodes+1; all bonds appear at both endpoints, even deleted
    const uint32_t* references; // 2*bonds; numerical indices, not stable physical IDs
    const uint32_t* prescribed; // whole-node constraints only, 0 or 1
    const uint32_t* activeBonds = nullptr; // optional frozen native deletion mask, authored bond order
};
__device__ __forceinline__ bool live(Graph g,uint32_t id) {
    return g.interfaces[id].live && (!g.activeBonds || g.activeBonds[id]);
}
enum Error : uint32_t { InvalidGraph=1, InvalidFrame=2, InvalidStiffness=4,
    InvalidValue=8, SingularDiagonal=16 };
struct Validation { double frameTolerance,symmetryTolerance,relativePivotTolerance; };
__device__ __forceinline__ double3 cross(double3 a,double3 b) {
    return make_double3(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x);
}
__device__ __forceinline__ double3 add(double3 a,double3 b) {return make_double3(a.x+b.x,a.y+b.y,a.z+b.z);}
__device__ __forceinline__ double3 offset(const Bond& e,double3 position) {
    return make_double3(e.point[0]-position.x,e.point[1]-position.y,e.point[2]-position.z);
}
__device__ __forceinline__ double3 rotate(const double* r,double3 v,bool transpose) {
    if(transpose)return make_double3(r[0]*v.x+r[3]*v.y+r[6]*v.z,r[1]*v.x+r[4]*v.y+r[7]*v.z,r[2]*v.x+r[5]*v.y+r[8]*v.z);
    return make_double3(r[0]*v.x+r[1]*v.y+r[2]*v.z,r[3]*v.x+r[4]*v.y+r[5]*v.z,r[6]*v.x+r[7]*v.y+r[8]*v.z);
}
__device__ __forceinline__ Vector endpoint(const Bond& e,double3 position,Vector q,double sign) {
    const auto theta=make_double3(q.v[3],q.v[4],q.v[5]);
    const auto motion=add(make_double3(q.v[0],q.v[1],q.v[2]),cross(theta,offset(e,position)));
    const auto u=rotate(e.frame,motion,true),r=rotate(e.frame,theta,true);
    return {{sign*u.x,sign*u.y,sign*u.z,sign*r.x,sign*r.y,sign*r.z}};
}
__device__ __forceinline__ Vector transposeEndpoint(const Bond& e,double3 position,Vector s,double sign) {
    const auto force=rotate(e.frame,make_double3(s.v[0],s.v[1],s.v[2]),false);
    const auto moment=add(rotate(e.frame,make_double3(s.v[3],s.v[4],s.v[5]),false),cross(offset(e,position),force));
    return {{sign*force.x,sign*force.y,sign*force.z,sign*moment.x,sign*moment.y,sign*moment.z}};
}
__device__ __forceinline__ Vector multiply(const Matrix& a,Vector x) {
    Vector y{};for(unsigned i=0;i<6;++i)for(unsigned j=0;j<6;++j)y.v[i]+=a.v[6*i+j]*x.v[j];return y;
}
__device__ __forceinline__ void accumulate(Vector& a,Vector b) {for(unsigned k=0;k<6;++k)a.v[k]+=b.v[k];}
__device__ bool cholesky(Matrix a,Matrix& lower,double relativePivotTolerance) {
    double scale=0;for(unsigned i=0;i<6;++i)scale=fmax(scale,fabs(a.v[6*i+i]));
    if(!isfinite(scale) || !(scale>0))return false;
    lower={};
    for(unsigned i=0;i<6;++i)for(unsigned j=0;j<=i;++j) {
        double v=a.v[6*i+j];for(unsigned k=0;k<j;++k)v-=lower.v[6*i+k]*lower.v[6*j+k];
        if(i==j) {if(!isfinite(v) || !(v>relativePivotTolerance*scale))return false;lower.v[6*i+j]=sqrt(v);}
        else {lower.v[6*i+j]=v/lower.v[6*j+j];if(!isfinite(lower.v[6*i+j]))return false;}
    }
    return true;
}
// Caller owns capacities and pointer lifetimes. Clear error before validation;
// stream-order consumers after both validators. No clamping or physical padding.
__global__ void validateBonds(Graph g,Validation limits,uint32_t* error) {
    const uint32_t id=blockIdx.x*blockDim.x+threadIdx.x;if(id>=g.bonds)return;
    const auto& e=g.interfaces[id];
    if(e.first>=g.nodes || e.second>=g.nodes || e.first==e.second || e.live>1 || (g.activeBonds && g.activeBonds[id]>1)){atomicOr(error,uint32_t(InvalidGraph));return;}
    if(!live(g,id))return;
    double scale=0;bool finite=true;
    for(unsigned k=0;k<36;++k){finite=finite && isfinite(e.stiffness.v[k]);scale=fmax(scale,fabs(e.stiffness.v[k]));}
    for(unsigned k=0;k<6;++k)finite=finite && isfinite(e.inelastic.v[k]);
    for(unsigned k=0;k<3;++k)finite=finite && isfinite(e.point[k]);
    for(unsigned k=0;k<9;++k)finite=finite && isfinite(e.frame[k]);
    if(!finite){atomicOr(error,uint32_t(InvalidValue));return;}
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j) {
        double v=0;for(unsigned k=0;k<3;++k)v+=e.frame[3*k+i]*e.frame[3*k+j];
        if(fabs(v-double(i==j))>limits.frameTolerance)atomicOr(error,uint32_t(InvalidFrame));
    }
    const double determinant=e.frame[0]*(e.frame[4]*e.frame[8]-e.frame[5]*e.frame[7])
        -e.frame[1]*(e.frame[3]*e.frame[8]-e.frame[5]*e.frame[6])+e.frame[2]*(e.frame[3]*e.frame[7]-e.frame[4]*e.frame[6]);
    if(fabs(determinant-1)>limits.frameTolerance)atomicOr(error,uint32_t(InvalidFrame));
    for(unsigned i=0;i<6;++i)for(unsigned j=0;j<6;++j)
        if(fabs(e.stiffness.v[6*i+j]-e.stiffness.v[6*j+i])>limits.symmetryTolerance*scale)atomicOr(error,uint32_t(InvalidStiffness));
    Matrix factor{};if(!cholesky(e.stiffness,factor,limits.relativePivotTolerance))atomicOr(error,uint32_t(InvalidStiffness));
}
__global__ void validateRows(Graph g,uint32_t* error) {
    const uint32_t i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=g.nodes)return;
    const auto x=g.positions[i];
    if(!isfinite(x.x) || !isfinite(x.y) || !isfinite(x.z))atomicOr(error,uint32_t(InvalidValue));
    if(g.bonds>UINT32_MAX/2 || g.starts[0] || g.starts[g.nodes]!=2*g.bonds || g.prescribed[i]>1
        || g.starts[i]>g.starts[i+1] || g.starts[i+1]>2*g.bonds){atomicOr(error,uint32_t(InvalidGraph));return;}
    for(uint32_t k=g.starts[i];k<g.starts[i+1];++k) {
        const auto id=g.references[k];if(id>=g.bonds){atomicOr(error,uint32_t(InvalidGraph));continue;}
        const auto& e=g.interfaces[id];if(e.first!=i && e.second!=i)atomicOr(error,uint32_t(InvalidGraph));
        for(uint32_t j=g.starts[i];j<k;++j)if(g.references[j]==id)atomicOr(error,uint32_t(InvalidGraph));
    }
}
__device__ Vector deformation(Graph g,const Bond& e,const Vector* x,bool supportOnly) {
    const auto a=g.prescribed[e.first]==uint32_t(supportOnly)?x[e.first]:Vector{};
    const auto b=g.prescribed[e.second]==uint32_t(supportOnly)?x[e.second]:Vector{};
    auto d=endpoint(e,g.positions[e.first],a,-1);accumulate(d,endpoint(e,g.positions[e.second],b,1));return d;
}
__global__ void apply(Graph g,const Vector* x,Vector* y,const uint32_t* error) {
    const uint32_t i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=g.nodes)return;
    Vector result{};
    if(!*error && !g.prescribed[i])for(uint32_t k=g.starts[i];k<g.starts[i+1];++k) {
        const auto& e=g.interfaces[g.references[k]];if(!live(g,g.references[k]))continue;
        const auto s=multiply(e.stiffness,deformation(g,e,x,false));
        accumulate(result,transposeEndpoint(e,g.positions[i],s,e.first==i?-1:1));
    }
    y[i]=result;
}
// b_d = external_d + sum G_d^T D z - K_ds q_s. Loads and prescribed values
// must be frozen/validated by the caller; this kernel does not advance history.
__global__ void buildRhs(Graph g,const Vector* external,const Vector* prescribed,Vector* rhs,const uint32_t* error) {
    const uint32_t i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=g.nodes)return;
    Vector result{};
    if(!*error && !g.prescribed[i]) {
        result=external[i];
        for(uint32_t k=g.starts[i];k<g.starts[i+1];++k) {
            const auto& e=g.interfaces[g.references[k]];if(!live(g,g.references[k]))continue;
            auto d=deformation(g,e,prescribed,true);for(unsigned j=0;j<6;++j)d.v[j]=e.inelastic.v[j]-d.v[j];
            accumulate(result,transposeEndpoint(e,g.positions[i],multiply(e.stiffness,d),e.first==i?-1:1));
        }
    }
    rhs[i]=result;
}
__global__ void buildDiagonal(Graph g,Matrix* diagonal,Matrix* factors,Validation limits,const uint32_t* validationError,uint32_t* error) {
    const uint32_t i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=g.nodes)return;
    Matrix a{};
    // These status allocations must be distinct: validation is immutable while
    // this kernel can publish SingularDiagonal from any row.
    if(*validationError){diagonal[i]={};factors[i]={};return;}
    if(!g.prescribed[i])for(uint32_t k=g.starts[i];k<g.starts[i+1];++k) {
        const auto& e=g.interfaces[g.references[k]];if(!live(g,g.references[k]))continue;
        for(unsigned column=0;column<6;++column) {
            Vector unit{};unit.v[column]=1;
            const double sign=e.first==i?-1:1;
            const auto v=transposeEndpoint(e,g.positions[i],multiply(e.stiffness,endpoint(e,g.positions[i],unit,sign)),sign);
            for(unsigned row=0;row<6;++row)a.v[6*row+column]+=v.v[row];
        }
    }
    Matrix lower{};if(!g.prescribed[i] && !cholesky(a,lower,limits.relativePivotTolerance))atomicOr(error,uint32_t(SingularDiagonal));
    diagonal[i]=a;factors[i]=lower;
}
__global__ void applyDiagonal(Graph g,const Matrix* factors,const Vector* rhs,Vector* output,const uint32_t* error) {
    const uint32_t i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=g.nodes)return;
    Vector x{};
    if(!*error && !g.prescribed[i]) {
        x=rhs[i];const auto& l=factors[i];
        for(unsigned row=0;row<6;++row){for(unsigned j=0;j<row;++j)x.v[row]-=l.v[6*row+j]*x.v[j];x.v[row]/=l.v[6*row+row];}
        for(int row=5;row>=0;--row){for(unsigned j=row+1;j<6;++j)x.v[row]-=l.v[6*j+row]*x.v[j];x.v[row]/=l.v[6*row+row];}
    }
    output[i]=x;
}
__global__ void recover(Graph g,const Vector* dynamic,const Vector* prescribed,Vector* response,double* energy,const uint32_t* error) {
    const uint32_t id=blockIdx.x*blockDim.x+threadIdx.x;if(id>=g.bonds)return;
    Vector s{};double value=0;const auto& e=g.interfaces[id];
    if(!*error && live(g,id)) {
        auto d=deformation(g,e,dynamic,false);accumulate(d,deformation(g,e,prescribed,true));
        for(unsigned j=0;j<6;++j)d.v[j]-=e.inelastic.v[j];
        s=multiply(e.stiffness,d);for(unsigned j=0;j<6;++j)value+=.5*d.v[j]*s.v[j];
    }
    response[id]=s;energy[id]=value;
}
}}} // Nv::Blast::Elastic
