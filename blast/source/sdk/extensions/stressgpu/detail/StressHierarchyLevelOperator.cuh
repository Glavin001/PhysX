// Sparse application of the current level, using its own compact adjacency.
// Mathematical bodies are reusable inside a resident V-cycle.
#pragma once
#include "StressHierarchyOperator.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
__device__ __forceinline__ Vector scaledValue(Vector v,float2 d){return {mul(v.angular,d.x),mul(v.linear,d.y)};}
__device__ __forceinline__ Vector levelRowContribution(const Input& input,unsigned node,const Vector* x,unsigned lane=threadIdx.x&31u,unsigned width=32){
    const bool cached=cachedSelfRows(input);
    Vector out=cached && !lane?selfMatrixValue(input,node,x[node],false):Vector{};
    const unsigned end=cached?input.nonSelfEnd[node]:input.begin[node+1];
    for(unsigned slot=input.begin[node]+lane;slot<end;slot+=width){
        const unsigned ref=cached?input.nonSelfRefs[slot]:input.refs[slot];if(ref==Invalid)continue;
        const unsigned edge=ref&0x7fffffffu;if(sourceHealth(input,edge)<=0)continue;
        const unsigned first=sourceFirst(input,edge),second=sourceSecond(input,edge);
        Vector a{},b{};
        if(first!=Invalid && input.component[first]!=Invalid)a=couple(scaledValue(x[first],sourceInertia(input,first)),sourceOffset(input,edge,false));
        if(second!=Invalid && input.component[second]!=Invalid)b=couple(scaledValue(x[second],sourceInertia(input,second)),sourceOffset(input,edge,true));
        const double scale=sourceScale(input,edge);const bool back=ref>>31;
        const auto flux=mul(sub(a,b),scale*scale*(back?-1.:1.));
        out=add(out,scaledValue(transposeCouple(flux,sourceOffset(input,edge,back)),sourceInertia(input,node)));
    }
    return out;
}
__global__ void applyLevel(Input input,const Status* status,const Vector* x,Vector* result){
    input=resolvedInput(input);const unsigned node=(blockIdx.x*blockDim.x+threadIdx.x)/32;
    if(node>=input.nodes)return;Vector out{};
    if(usable(status) && input.component[node]!=Invalid)out=levelRowContribution(input,node,x);
    out=warpSum(out);if(!(threadIdx.x&31u))result[node]=out;
}
}}}
