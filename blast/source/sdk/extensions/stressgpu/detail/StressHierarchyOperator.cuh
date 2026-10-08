// Private resident transfer and sparse Galerkin operator. No assembly, atomics,
// temporary bond vectors or duplicate membership CSR are needed to apply it.
#pragma once
#include "StressHierarchyKernels.cuh"
#include "StressHierarchySelfCache.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
struct Vector {StressReal3 angular,linear;};
__device__ __forceinline__ Vector selfMatrixValue(const Input& a,unsigned node,Vector x,bool correction){
    const StressReal* m=a.selfMatrices+size_t(node)*SelfCacheEntries+(correction?9:0);
    return {{m[0]*x.angular.x+m[1]*x.angular.y+m[2]*x.angular.z,
             m[3]*x.angular.x+m[4]*x.angular.y+m[5]*x.angular.z,
             m[6]*x.angular.x+m[7]*x.angular.y+m[8]*x.angular.z},{0,0,0}};
}

__device__ __forceinline__ StressReal3 add(StressReal3 a,StressReal3 b){return makeStressReal3(a.x+b.x,a.y+b.y,a.z+b.z);}
__device__ __forceinline__ StressReal3 sub(StressReal3 a,StressReal3 b){return makeStressReal3(a.x-b.x,a.y-b.y,a.z-b.z);}
__device__ __forceinline__ StressReal3 mul(StressReal3 a,StressReal b){return makeStressReal3(a.x*b,a.y*b,a.z*b);}
__device__ __forceinline__ StressReal3 cross(StressReal3 a,StressReal3 b){return makeStressReal3(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x);}
#if !(defined(BLAST_STRESS_GPU_FP64) && BLAST_STRESS_GPU_FP64)
// The motion forest keeps exact double arithmetic in either precision (CUDA).
__device__ __forceinline__ double3 add(double3 a,double3 b){return make_double3(a.x+b.x,a.y+b.y,a.z+b.z);}
__device__ __forceinline__ double3 sub(double3 a,double3 b){return make_double3(a.x-b.x,a.y-b.y,a.z-b.z);}
__device__ __forceinline__ double3 mul(double3 a,double b){return make_double3(a.x*b,a.y*b,a.z*b);}
__device__ __forceinline__ double3 cross(double3 a,double3 b){return make_double3(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x);}
#endif
__device__ __forceinline__ Vector add(Vector a,Vector b){return {add(a.angular,b.angular),add(a.linear,b.linear)};}
__device__ __forceinline__ Vector sub(Vector a,Vector b){return {sub(a.angular,b.angular),sub(a.linear,b.linear)};}
__device__ __forceinline__ Vector mul(Vector a,StressReal b){return {mul(a.angular,b),mul(a.linear,b)};}
// Shear: per-bond shear stiffness (ExtStressGpuSetBondShearStiffness). Then
// every bond's row of the per-bond arrays (Input::angularWeight, the angular
// scales) is twelve floats, the angular block's six and the linear block's six
// (packed symmetric, xx yy zz xy xz yz): a bond's linear stiffness is s^2 Wl,
// Wl = n n^T + gamma (I - n n^T), instead of s^2 I. A compile-time choice like
// Rotation: without it (Shear false) every helper is the code it was.
template<bool Shear>
__device__ __forceinline__ constexpr unsigned bondRowStride(){return Shear?12u:6u;}
// A bond's rotational weight W (Input::angularWeight), or null: the uniform
// length scale, whose arithmetic every caller then reproduces exactly.
template<bool Shear=false>
__device__ __forceinline__ const float* sourceRotation(const Input& a,unsigned bond){
    if(!a.angularWeight)return nullptr;
    if constexpr(Shear)return a.angularWeight+12*size_t(a.levelBonds?a.bondIdentity[bond]:bond);
    else return a.angularWeight+6*size_t(a.levelBonds?a.bondIdentity[bond]:bond);
}
// Packed symmetric 3x3 (xx yy zz xy xz yz) times a vector.
__device__ __forceinline__ StressReal3 symmetricApply(const float* m,StressReal3 v){
    return makeStressReal3(StressReal(m[0])*v.x+StressReal(m[3])*v.y+StressReal(m[4])*v.z,
                           StressReal(m[3])*v.x+StressReal(m[1])*v.y+StressReal(m[5])*v.z,
                           StressReal(m[4])*v.x+StressReal(m[5])*v.y+StressReal(m[2])*v.z);
}
// A bond's stiffness times its relative motion d: factor * diag(W, I) d, or
// exactly mul(d, factor) for a bond with the uniform length scale. factor
// carries s^2 and the endpoint's sign. Shear: factor * diag(W, Wl) d.
template<bool Shear=false>
__device__ __forceinline__ Vector bondFlux(const Input& a,unsigned bond,Vector d,StressReal factor){
    const float* w=sourceRotation<Shear>(a,bond);
    if(!w)return mul(d,factor);
    if constexpr(Shear)return {mul(symmetricApply(w,d.angular),factor),mul(symmetricApply(w+6,d.linear),factor)};
    else return {mul(symmetricApply(w,d.angular),factor),mul(d.linear,factor)};
}
__device__ __forceinline__ StressReal3 shift(const Input& input,unsigned node,unsigned root){
    const auto a=sourcePosition(input,node),b=sourcePosition(input,root);
    return makeStressReal3(StressReal(a.x)-b.x,StressReal(a.y)-b.y,StressReal(a.z)-b.z);
}
// D^-1 [omega; v + (p_i-p_root) x omega]. Inertia is the same
// angular/linear square-root inverse used by the authoritative fine operator.
__device__ __forceinline__ Vector prolongValue(Vector v,StressReal3 r,float2 d){
    return {mul(v.angular,StressReal(1)/d.x),mul(add(v.linear,cross(r,v.angular)),StressReal(1)/d.y)};
}
__device__ __forceinline__ Vector restrictValue(Vector v,StressReal3 r,float2 d){
    const auto linear=mul(v.linear,StressReal(1)/d.y);
    return {sub(mul(v.angular,StressReal(1)/d.x),cross(r,linear)),linear};
}
__device__ __forceinline__ Vector couple(Vector v,StressReal3 offset){
    return {v.angular,add(v.linear,cross(offset,v.angular))};
}
__device__ __forceinline__ Vector transposeCouple(Vector v,StressReal3 offset){
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
// Scalar in either width: the motion forest reduces doubles through this too.
template<class T>
__device__ __forceinline__ T warpSum(T v){
    for(unsigned offset=16;offset;offset>>=1)v+=__shfl_down_sync(0xffffffffu,v,offset);
    return v;
}
__device__ __forceinline__ Vector warpSum(Vector v){
    return {{warpSum(v.angular.x),warpSum(v.angular.y),warpSum(v.angular.z)},
            {warpSum(v.linear.x),warpSum(v.linear.y),warpSum(v.linear.z)}};
}
// Four virtual lanes per physical lane preserve the original 32-lane tree.
// Eight physical lanes own a row, allowing four independent rows in a warp.
template<class T>
__device__ __forceinline__ T eightLaneSum(T value){
    const unsigned mask=0xffu<<(threadIdx.x&24u);
    for(unsigned offset=4;offset;offset>>=1)value+=__shfl_down_sync(mask,value,offset,8);
    return value;
}
__device__ __forceinline__ Vector sumVirtualWarp(Vector a,Vector b,Vector c,Vector d){
    const auto v=add(add(a,c),add(b,d));
    return {{eightLaneSum(v.angular.x),eightLaneSum(v.angular.y),eightLaneSum(v.angular.z)},
            {eightLaneSum(v.linear.x),eightLaneSum(v.linear.y),eightLaneSum(v.linear.z)}};
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
        const auto difference=bondFlux(input,ref&0x7fffffffu,sub(a,c),edge.scale*edge.scale);
        const bool second=ref>>31;
        const auto response=transposeCouple(difference,second?edge.offset1:edge.offset0);
        out=add(out,mul(response,second?StressReal(-1):StressReal(1)));
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
    StressReal coefficient=lane<DiagonalEntries?b.diagonal[size_t(node)*DiagonalEntries+lane]:0;
    StressReal rhs=lane==0?value.angular.x:lane==1?value.angular.y:lane==2?value.angular.z:
               lane==3?value.linear.x:lane==4?value.linear.y:lane==5?value.linear.z:0;
    StressReal first=__shfl_sync(0xffffffffu,coefficient,0);
    // A negative first entry: the factor is in linear-first order
    // (buildFineDiagonalParallelAxis). Solve the permuted system.
    const bool linearFirst=first<0;
    if(linearFirst){
        const StressReal swapped=__shfl_sync(0xffffffffu,rhs,lane<3?lane+3:lane<6?lane-3:lane);
        rhs=lane<6?swapped:rhs;
        coefficient=lane==0?-coefficient:coefficient;first=-first;
    }
    if(first==0)rhs=0;
    else {
        for(unsigned k=0;k<6;++k){
            const StressReal pivot=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
            // The pivot equation is one scalar. Computing its division in
            // every lane repeats identical FP64 work 32 times on sm_89.
            StressReal solved=lane==unsigned(k)?rhs/pivot:0;
            solved=__shfl_sync(0xffffffffu,solved,k);
            const unsigned row=lane<6?lane:0;
            const StressReal lower=__shfl_sync(0xffffffffu,coefficient,triangle(row,k<=row?k:row));
            if(lane==k)rhs=solved;
            else if(lane<6 && lane>k)rhs-=lower*solved;
        }
        for(int k=5;k>=0;--k){
            const StressReal pivot=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
            // The pivot equation is one scalar. Computing its division in
            // every lane repeats identical FP64 work 32 times on sm_89.
            StressReal solved=lane==unsigned(k)?rhs/pivot:0;
            solved=__shfl_sync(0xffffffffu,solved,k);
            const unsigned col=lane<unsigned(k)?lane:unsigned(k);
            const StressReal upper=__shfl_sync(0xffffffffu,coefficient,triangle(k,col));
            if(lane==unsigned(k))rhs=solved;
            else if(lane<unsigned(k))rhs-=upper*solved;
        }
    }
    const unsigned a=linearFirst?3:0,l=linearFirst?0:3;
    return {{__shfl_sync(0xffffffffu,rhs,a),__shfl_sync(0xffffffffu,rhs,a+1),__shfl_sync(0xffffffffu,rhs,a+2)},
            {__shfl_sync(0xffffffffu,rhs,l),__shfl_sync(0xffffffffu,rhs,l+1),__shfl_sync(0xffffffffu,rhs,l+2)}};
}
// A six-variable factor fits in a thread's registers. Independent nodes then
// occupy independent lanes instead of serializing a component through eight
// warp-owned solves. Keep the exact triangular update order and FP64 divisions.
__device__ __forceinline__ Vector solveFineDiagonalThread(Buffers b,unsigned node,Vector value){
    StressReal factor[DiagonalEntries];
#pragma unroll
    for(unsigned k=0;k<DiagonalEntries;++k)factor[k]=b.diagonal[size_t(node)*DiagonalEntries+k];
    if(factor[0]==0)return {};
    // A negative first entry: linear-first order (buildFineDiagonalParallelAxis).
    const bool linearFirst=factor[0]<0;
    if(linearFirst)factor[0]=-factor[0];
    StressReal rhs[6]={value.angular.x,value.angular.y,value.angular.z,value.linear.x,value.linear.y,value.linear.z};
    if(linearFirst){
#pragma unroll
        for(unsigned k=0;k<3;++k){const StressReal t=rhs[k];rhs[k]=rhs[k+3];rhs[k+3]=t;}
    }
#pragma unroll
    for(unsigned k=0;k<6;++k){
        const StressReal solved=rhs[k]/factor[triangle(k,k)];rhs[k]=solved;
#pragma unroll
        for(unsigned row=k+1;row<6;++row)rhs[row]-=factor[triangle(row,k)]*solved;
    }
#pragma unroll
    for(int k=5;k>=0;--k){
        const StressReal solved=rhs[k]/factor[triangle(k,k)];rhs[k]=solved;
#pragma unroll
        for(unsigned row=0;row<unsigned(k);++row)rhs[row]-=factor[triangle(k,row)]*solved;
    }
    if(linearFirst)return {{rhs[3],rhs[4],rhs[5]},{rhs[0],rhs[1],rhs[2]}};
    return {{rhs[0],rhs[1],rhs[2]},{rhs[3],rhs[4],rhs[5]}};
}
__global__ void applyFineDiagonal(Input input,Buffers b,const Status* status,const Vector* residual,Vector* result){
    input=resolvedInput(input);
#if defined(PX_CUMETAL_BLOCK_VOTED_TRAPS) && PX_CUMETAL_BLOCK_VOTED_TRAPS
    // Vote before any node-tail exit, including lanes whose warp has no work.
    // The hint's caller and native registration enforce a single block. Empty
    // inputs keep the original no-work/no-error behavior even with levelBonds.
    const unsigned first=(blockIdx.x*blockDim.x+threadIdx.x)/32;
    if(__syncthreads_or(first<input.nodes && input.levelBonds)){__trap();return;}
    // Like the original full-mask warp solve, callers must use a 1D block
    // containing complete warps (the supported qualifier uses 256 threads).
    const unsigned stride=gridDim.x*(blockDim.x/32);
    for(unsigned node=first;node<input.nodes;){
        Vector out{};if(usable(status))out=solveFineDiagonal(b,node,residual[node]);
        if(!(threadIdx.x&31u))result[node]=out;
        // All lanes in this warp share node/count. Stop before the unsigned
        // increment could wrap, without skipping the final complete solve.
        if(input.nodes-node<=stride)break;
        node+=stride;
    }
#else
    const unsigned node=(blockIdx.x*blockDim.x+threadIdx.x)/32;if(node>=input.nodes)return;
    if(input.levelBonds){__trap();return;} // Fine-only factor misuse is an explicit device error.
    Vector out{};if(usable(status))out=solveFineDiagonal(b,node,residual[node]);
    if(!(threadIdx.x&31u))result[node]=out;
#endif
}
}}}
