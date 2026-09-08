// Private exact coarse self-column contraction. A retained rounded self bond
// has no net linear force, but its offset difference contributes angular
// stiffness. Keep that contribution; never discard these columns as "small".
#pragma once
namespace Nv { namespace Blast { namespace StressHierarchy {
__device__ __forceinline__ double selfCoordinate(double3 v,unsigned i){return i==0?v.x:i==1?v.y:v.z;}
__global__ void buildSelfCache(Input a,Buffers b,const Status* status,const Work* work){
    if(!work->active || status->error)return;
    a=resolvedInput(a);if(!cachedSelfRows(a))return;
    const unsigned lane=threadIdx.x&31u,warp=threadIdx.x/32;
    for(unsigned node=blockIdx.x;node<a.nodes;node+=gridDim.x){
        for(unsigned entry=warp;entry<SelfCacheEntries;entry+=blockDim.x/32){
            const unsigned row=(entry%9)/3,col=entry%3;double sum=0;
            for(unsigned slot=a.begin[node]+lane;slot<a.begin[node+1];slot+=32){
                const unsigned ref=a.refs[slot];if(ref==Invalid || (ref>>31))continue;
                const unsigned edge=ref&0x7fffffffu;const auto e=a.levelBonds[edge];
                if(e.a!=e.b || e.a==Invalid || !(e.scale>0))continue;
                const double3 r=make_double3(e.offset0.x-e.offset1.x,e.offset0.y-e.offset1.y,e.offset0.z-e.offset1.z);
                double3 s=r;double scale=e.scale*e.scale;
                if(entry>=9){
                    const auto c=b.coarse[edge];if(!retainedColumn(c))continue;
                    s=make_double3(c.offset0.x-c.offset1.x,c.offset0.y-c.offset1.y,c.offset0.z-c.offset1.z);
                    scale=e.scale*c.scale;
                }
                // -[r]x [s]x = (r.s)I - s r^T; the two endpoint
                // contributions are contracted together before accumulation.
                const double dot=r.x*s.x+r.y*s.y+r.z*s.z;
                sum+=scale*((row==col?dot:0)-selfCoordinate(s,row)*selfCoordinate(r,col));
            }
            for(unsigned shift=16;shift;shift>>=1)sum+=__shfl_down_sync(0xffffffffu,sum,shift);
            if(!lane)b.selfMatrices[size_t(node)*SelfCacheEntries+entry]=sum;
        }
        __syncthreads();
    }
}
}}}
