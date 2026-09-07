// Transfer directly to/from compact level vectors: no sparse-vector copy pass.
#pragma once
#include "StressHierarchyOperator.cuh"
#include "StressHierarchyPacking.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
__device__ __forceinline__ Vector restrictPackedContribution(const Input& input,Buffers parent,
                                                            unsigned root,const Vector* fine){
    Vector out{};const unsigned seed=parent.owner[root],items=1+input.begin[seed+1]-input.begin[seed];
    for(unsigned item=threadIdx.x&31u;item<items;item+=32){
        const unsigned node=memberAt(input,parent,seed,item);if(node==Invalid)continue;
        out=add(out,restrictValue(fine[node],shift(input,node,root),sourceInertia(input,node)));
    }
    return out;
}
__global__ void restrictPacked(Input input,Buffers parent,PackingBuffers packed,const Status* status,
                               const Vector* fine,Vector* coarse){
    input=resolvedInput(input);const unsigned node=(blockIdx.x*blockDim.x+threadIdx.x)/32;
    if(node>=packed.counts[0])return;Vector out{};
    if(usable(status))out=restrictPackedContribution(input,parent,packed.nodeSource[node],fine);
    out=warpSum(out);if(!(threadIdx.x&31u))coarse[node]=out;
}
__global__ void prolongPacked(Input input,Buffers parent,PackingBuffers packed,const Status* status,
                              const Vector* coarse,Vector* fine){
    input=resolvedInput(input);const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;
    if(node>=input.nodes)return;Vector out{};
    if(usable(status)){
        const unsigned root=parent.leader[node];
        if(root!=Invalid && packed.nodeMap[root]!=Invalid)
            out=prolongValue(coarse[packed.nodeMap[root]],shift(input,node,root),sourceInertia(input,node));
    }
    fine[node]=out;
}
}}}
