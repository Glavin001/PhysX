// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxvIslandMetadata.h"
namespace physx { namespace destructionPreSolve {
__device__ PxU32 root(PxU32* parents,PxU32 i) {
    PxU32 p=atomicAdd(parents+i,0u);
    while(p!=i){const PxU32 next=atomicAdd(parents+p,0u);atomicMin(parents+i,next);i=p;p=next;}
    return i;
}
__device__ void join(PxU32* parents,PxU32 a,PxU32 b) {
    for(;;){a=root(parents,a);b=root(parents,b);if(a==b)return;
        const PxU32 hi=a>b?a:b,lo=a>b?b:a;if(atomicCAS(parents+hi,hi,lo)==hi)return;}
}
__global__ void initialize(PxU32* parents,PxU32 size,PxU32* counts,PxU32 nodes) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i<size)parents[i]=i;if(i<nodes)counts[i]=0;
}
// Virtual hubs preserve the previous phase's components without confusing a
// reused body index with its former lifetime. Removed edges do not split this
// pre-solve state; the ordinary post-retirement graph performs those splits.
__global__ void seed(const PxvPreSolveNode* now,PxU32 nodes,const PxvPreSolveNode* before,PxU32 previousNodes,
    const PxU32* previousLabels,PxU32 previousDomain,PxU32* parents,const PxU32* previousError) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=nodes || !now[i].live)return;
    if(previousError && *previousError){__trap();return;}
    if(!now[i].lifetime){__trap();return;}
    if(i<previousNodes && i<previousDomain && before[i].live && before[i].lifetime==now[i].lifetime){
        const PxU32 label=previousLabels[i];if(label>=previousDomain){__trap();return;}
        join(parents,i,nodes+label);
    }
}
__global__ void connect(const PxvPreSolveEdge* edges,PxU32 count,const PxvPreSolveNode* nodes,PxU32 size,PxU32* parents) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;const auto e=edges[i];
    if(e.a>=size || e.b>=size){__trap();return;}
    // A node can have been deleted or prescribed after the merge was recorded.
    if(nodes[e.a].live && nodes[e.b].live)join(parents,e.a,e.b);
}
__global__ void finish(const PxvPreSolveNode* nodes,PxU32 size,PxU32* parents,PxU32* labels,PxU32* counts) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=size)return;
    if(!nodes[i].live){labels[i]=~PxU32(0);return;}
    const PxU32 r=root(parents,i);if(r>=size){__trap();return;}labels[i]=r;
    if(nodes[i].staticTouches)atomicAdd(counts+r,nodes[i].staticTouches);
}
}}
