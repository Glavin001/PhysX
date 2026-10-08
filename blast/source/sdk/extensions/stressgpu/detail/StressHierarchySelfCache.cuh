// Private exact coarse self-column contraction. A retained rounded self bond
// has no net linear force, but its offset difference contributes angular
// stiffness. Keep that contribution; never discard these columns as "small".
#pragma once
namespace Nv { namespace Blast { namespace StressHierarchy {
__device__ __forceinline__ StressReal selfCoordinate(StressReal3 v,unsigned i){return i==0?v.x:i==1?v.y:v.z;}
__global__ void buildSelfCache(Input a,Buffers b,const Status* status,const Work* work){
    if(!work->active || status->error)return;
    a=resolvedInput(a);if(!cachedSelfRows(a))return;
    const unsigned lane=threadIdx.x&31u,warp=threadIdx.x/32;
    for(unsigned node=blockIdx.x;node<a.nodes;node+=gridDim.x){
        for(unsigned entry=warp;entry<SelfCacheEntries;entry+=blockDim.x/32){
            const unsigned row=(entry%9)/3,col=entry%3;StressReal sum=0;
            for(unsigned slot=a.begin[node]+lane;slot<a.begin[node+1];slot+=32){
                const unsigned ref=a.refs[slot];if(ref==Invalid || (ref>>31))continue;
                const unsigned edge=ref&0x7fffffffu;const auto e=a.levelBonds[edge];
                if(e.a!=e.b || e.a==Invalid || !(e.scale>0))continue;
                const StressReal3 r=makeStressReal3(e.offset0.x-e.offset1.x,e.offset0.y-e.offset1.y,e.offset0.z-e.offset1.z);
                StressReal3 s=r;StressReal scale=e.scale*e.scale;
                if(entry>=9){
                    const auto c=b.coarse[edge];if(!retainedColumn(c))continue;
                    s=makeStressReal3(c.offset0.x-c.offset1.x,c.offset0.y-c.offset1.y,c.offset0.z-c.offset1.z);
                    scale=e.scale*c.scale;
                }
                // -[r]x [s]x = (r.s)I - s r^T; the two endpoint
                // contributions are contracted together before accumulation.
                const StressReal dot=r.x*s.x+r.y*s.y+r.z*s.z;
                sum+=scale*((row==col?dot:0)-selfCoordinate(s,row)*selfCoordinate(r,col));
            }
            for(unsigned shift=16;shift;shift>>=1)sum+=__shfl_down_sync(0xffffffffu,sum,shift);
            if(!lane)b.selfMatrices[size_t(node)*SelfCacheEntries+entry]=sum;
        }
        __syncthreads();
    }
}
// [v]x entry (i, k): (v x u)_i = sum_k [v]x(i,k) u_k.
__device__ __forceinline__ StressReal crossEntry(StressReal3 v,unsigned i,unsigned k){
    if(i==k)return 0;
    const unsigned l=3-i-k;const StressReal value=selfCoordinate(v,l);
    return ((i+1)%3==k)?-value:value;
}
// Packed symmetric (xx yy zz xy xz yz) entry (k, l).
__device__ __forceinline__ StressReal packedEntry(const float* w,unsigned k,unsigned l){
    return StressReal(w[k==l?k:(k+l==1?3u:k+l==2?4u:5u)]);
}
// -[r]x Wl [s]x, row i column j: the self coupling of a bond whose linear
// stiffness is Wl (ExtStressGpuSetBondShearStiffness); Wl = I gives the
// (r.s)I - s r^T below.
__device__ __forceinline__ StressReal selfShearEntry(const float* w,StressReal3 r,StressReal3 s,unsigned i,unsigned j){
    StressReal sum=0;
    for(unsigned k=0;k<3;++k)for(unsigned l=0;l<3;++l)sum+=crossEntry(r,i,k)*packedEntry(w,k,l)*crossEntry(s,l,j);
    return -sum;
}
// With per-bond shear stiffness (twelve-float weight rows; ExtStressGpuSetBondShearStiffness):
// a self bond's coupling is -[r]x Wl [s]x. The isotropic kernel above is kept verbatim.
__global__ void buildSelfCacheShear(Input a,Buffers b,const Status* status,const Work* work){
    if(!work->active || status->error)return;
    a=resolvedInput(a);if(!cachedSelfRows(a))return;
    const unsigned lane=threadIdx.x&31u,warp=threadIdx.x/32;
    for(unsigned node=blockIdx.x;node<a.nodes;node+=gridDim.x){
        for(unsigned entry=warp;entry<SelfCacheEntries;entry+=blockDim.x/32){
            const unsigned row=(entry%9)/3,col=entry%3;StressReal sum=0;
            for(unsigned slot=a.begin[node]+lane;slot<a.begin[node+1];slot+=32){
                const unsigned ref=a.refs[slot];if(ref==Invalid || (ref>>31))continue;
                const unsigned edge=ref&0x7fffffffu;const auto e=a.levelBonds[edge];
                if(e.a!=e.b || e.a==Invalid || !(e.scale>0))continue;
                const StressReal3 r=makeStressReal3(e.offset0.x-e.offset1.x,e.offset0.y-e.offset1.y,e.offset0.z-e.offset1.z);
                StressReal3 s=r;StressReal scale=e.scale*e.scale;
                if(entry>=9){
                    const auto c=b.coarse[edge];if(!retainedColumn(c))continue;
                    s=makeStressReal3(c.offset0.x-c.offset1.x,c.offset0.y-c.offset1.y,c.offset0.z-c.offset1.z);
                    scale=e.scale*c.scale;
                }
                // -[r]x [s]x = (r.s)I - s r^T; the two endpoint
                // contributions are contracted together before accumulation.
                {const float* w=a.angularWeight?a.angularWeight+12*size_t(a.levelBonds?a.bondIdentity[edge]:edge):nullptr;   // sourceRotation<true>
                 if(w){sum+=scale*selfShearEntry(w+6,r,s,row,col);continue;}}
                const StressReal dot=r.x*s.x+r.y*s.y+r.z*s.z;
                sum+=scale*((row==col?dot:0)-selfCoordinate(s,row)*selfCoordinate(r,col));
            }
            for(unsigned shift=16;shift;shift>>=1)sum+=__shfl_down_sync(0xffffffffu,sum,shift);
            if(!lane)b.selfMatrices[size_t(node)*SelfCacheEntries+entry]=sum;
        }
        __syncthreads();
    }
}
}}}
