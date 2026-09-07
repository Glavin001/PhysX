// Private resident transfer and sparse Galerkin operator. No assembly, atomics,
// temporary bond vectors or duplicate membership CSR are needed to apply it.
#pragma once
#include "StressHierarchyKernels.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
struct Vector {double3 angular,linear;};
__device__ __forceinline__ double3 add(double3 a,double3 b){return make_double3(a.x+b.x,a.y+b.y,a.z+b.z);}
__device__ __forceinline__ double3 sub(double3 a,double3 b){return make_double3(a.x-b.x,a.y-b.y,a.z-b.z);}
__device__ __forceinline__ double3 mul(double3 a,double b){return make_double3(a.x*b,a.y*b,a.z*b);}
__device__ __forceinline__ double3 cross(double3 a,double3 b){return make_double3(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x);}
__device__ __forceinline__ Vector add(Vector a,Vector b){return {add(a.angular,b.angular),add(a.linear,b.linear)};}
__device__ __forceinline__ Vector sub(Vector a,Vector b){return {sub(a.angular,b.angular),sub(a.linear,b.linear)};}
__device__ __forceinline__ Vector mul(Vector a,double b){return {mul(a.angular,b),mul(a.linear,b)};}
__device__ __forceinline__ double3 shift(const Input& input,unsigned node,unsigned root){
    const auto a=sourcePosition(input,node),b=sourcePosition(input,root);
    return make_double3(double(a.x)-b.x,double(a.y)-b.y,double(a.z)-b.z);
}
// D^-1 [omega; v + (p_i-p_root) x omega]. Inertia is the same
// angular/linear square-root inverse used by the authoritative fine operator.
__device__ __forceinline__ Vector prolongValue(Vector v,double3 r,float2 d){
    return {mul(v.angular,1./d.x),mul(add(v.linear,cross(r,v.angular)),1./d.y)};
}
__device__ __forceinline__ Vector restrictValue(Vector v,double3 r,float2 d){
    const auto linear=mul(v.linear,1./d.y);
    return {sub(mul(v.angular,1./d.x),cross(r,linear)),linear};
}
__device__ __forceinline__ Vector couple(Vector v,double3 offset){
    return {v.angular,add(v.linear,cross(offset,v.angular))};
}
__device__ __forceinline__ Vector transposeCouple(Vector v,double3 offset){
    return {sub(v.angular,cross(offset,v.linear)),v.linear};
}
__device__ __forceinline__ bool usable(const Status* status){return status->initialized && !status->error;}
// Each aggregate is a seed and its directly attached neighbours. memberBond
// picks exactly one edge to that seed, so parallel bonds cannot duplicate a
// member. Seed CSR order is immutable and therefore gives deterministic sums.
// Over all seeds, enumeration visits at most the original CSR length.
__device__ __forceinline__ unsigned memberAt(const Input& input,Buffers b,unsigned seed,unsigned item){
    if(!item)return seed;
    const unsigned ref=input.refs[input.begin[seed]+item-1];
    if(ref==Invalid)return Invalid;
    const unsigned bond=ref&0x7fffffffu;
    const unsigned other=(ref>>31)?sourceFirst(input,bond):sourceSecond(input,bond);
    return other!=Invalid && b.owner[other]==seed && b.memberBond[other]==bond ? other : Invalid;
}
__device__ __forceinline__ double warpSum(double v){
    for(unsigned offset=16;offset;offset>>=1)v+=__shfl_down_sync(0xffffffffu,v,offset);
    return v;
}
__device__ __forceinline__ Vector warpSum(Vector v){
    return {{warpSum(v.angular.x),warpSum(v.angular.y),warpSum(v.angular.z)},
            {warpSum(v.linear.x),warpSum(v.linear.y),warpSum(v.linear.z)}};
}
__global__ void prolongate(Input input,Buffers b,const Status* status,
                           const Vector* coarse,Vector* fine){
    input=resolvedInput(input);
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;if(node>=input.nodes)return;
    Vector out{};
    if(usable(status)){
        const unsigned root=b.leader[node];
        if(root!=Invalid){
            out=prolongValue(coarse[root],shift(input,node,root),sourceInertia(input,node));
        }
    }
    fine[node]=out;
}
// One warp per aggregate. Nonleaders overwrite their output with zero; no
// separate clearing launch and no atomic floating-point reduction are needed.
__global__ void restrictResidual(Input input,Buffers b,const Status* status,
                                const Vector* fine,Vector* coarse){
    input=resolvedInput(input);
    const unsigned lane=threadIdx.x&31u,root=(blockIdx.x*blockDim.x+threadIdx.x)/32;
    if(root>=input.nodes)return;
    Vector out{};
    if(usable(status) && b.leader[root]==root){
        const unsigned seed=b.owner[root],items=1+input.begin[seed+1]-input.begin[seed];
        for(unsigned item=lane;item<items;item+=32){
            const unsigned node=memberAt(input,b,seed,item);if(node==Invalid)continue;
            out=add(out,restrictValue(fine[node],shift(input,node,root),sourceInertia(input,node)));
        }
    }
    out=warpSum(out);if(!lane)coarse[root]=out;
}
// Evaluate H H^T without materializing H or the dense coarse matrix, where
// H=P^T B. Gathering both endpoints is deliberate for coarse self-edges: their
// force cancels while their rounded moment coupling may remain nonzero.
__device__ __forceinline__ Vector coarseNodeValue(const Input& input,Buffers b,
                                                 unsigned node,const Vector* coarse){
    Vector out{};
    for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
        const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
        const auto edge=b.coarse[ref&0x7fffffffu];
        Vector a{},c{};
        if(edge.a!=Invalid)a=couple(coarse[edge.a],edge.offset0);
        if(edge.b!=Invalid)c=couple(coarse[edge.b],edge.offset1);
        const auto difference=mul(sub(a,c),edge.scale*edge.scale);
        const bool second=ref>>31;
        const auto response=transposeCouple(difference,second?edge.offset1:edge.offset0);
        out=add(out,mul(response,second?-1.:1.));
    }
    return out;
}
__global__ void applyCoarse(Input input,Buffers b,const Status* status,const Vector* coarse,Vector* result){
    input=resolvedInput(input);
    const unsigned lane=threadIdx.x&31u,root=(blockIdx.x*blockDim.x+threadIdx.x)/32;
    if(root>=input.nodes)return;
    Vector out{};
    if(usable(status) && b.leader[root]==root){
        const unsigned seed=b.owner[root],items=1+input.begin[seed+1]-input.begin[seed];
        for(unsigned item=lane;item<items;item+=32){
            const unsigned node=memberAt(input,b,seed,item);if(node!=Invalid)out=add(out,coarseNodeValue(input,b,node,coarse));
        }
    }
    out=warpSum(out);if(!lane)result[root]=out;
}
// Apply the Cholesky factors cooperatively within a warp. The same body can
// be fused into a resident V-cycle; this launch is its standalone qualifier.
__device__ __forceinline__ Vector solveFineDiagonal(Buffers b,unsigned node,Vector value){
    const unsigned lane=threadIdx.x&31u;
    const double coefficient=lane<DiagonalEntries?b.diagonal[size_t(node)*DiagonalEntries+lane]:0;
    double rhs=lane==0?value.angular.x:lane==1?value.angular.y:lane==2?value.angular.z:
               lane==3?value.linear.x:lane==4?value.linear.y:lane==5?value.linear.z:0;
    const double first=__shfl_sync(0xffffffffu,coefficient,0);
    if(first==0)rhs=0;
    else {
        for(unsigned k=0;k<6;++k){
            const double pivot=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
            const double solved=__shfl_sync(0xffffffffu,rhs,k)/pivot;
            const unsigned row=lane<6?lane:0;
            const double lower=__shfl_sync(0xffffffffu,coefficient,triangle(row,k<=row?k:row));
            if(lane==k)rhs=solved;
            else if(lane<6 && lane>k)rhs-=lower*solved;
        }
        for(int k=5;k>=0;--k){
            const double pivot=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
            const double solved=__shfl_sync(0xffffffffu,rhs,k)/pivot;
            const unsigned col=lane<unsigned(k)?lane:unsigned(k);
            const double upper=__shfl_sync(0xffffffffu,coefficient,triangle(k,col));
            if(lane==unsigned(k))rhs=solved;
            else if(lane<unsigned(k))rhs-=upper*solved;
        }
    }
    return {{__shfl_sync(0xffffffffu,rhs,0),__shfl_sync(0xffffffffu,rhs,1),__shfl_sync(0xffffffffu,rhs,2)},
            {__shfl_sync(0xffffffffu,rhs,3),__shfl_sync(0xffffffffu,rhs,4),__shfl_sync(0xffffffffu,rhs,5)}};
}
__global__ void applyFineDiagonal(Input input,Buffers b,const Status* status,const Vector* residual,Vector* result){
    input=resolvedInput(input);
    const unsigned node=(blockIdx.x*blockDim.x+threadIdx.x)/32;if(node>=input.nodes)return;
    if(input.levelBonds){__trap();return;} // Fine-only factor misuse is an explicit device error.
    Vector out{};if(usable(status))out=solveFineDiagonal(b,node,residual[node]);
    if(!(threadIdx.x&31u))result[node]=out;
}
}}}
