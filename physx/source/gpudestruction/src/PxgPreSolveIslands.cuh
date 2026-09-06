// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxvIslandMetadata.h"
#include "PxgDestructionContactGraph.cuh"
namespace physx { namespace destructionPreSolve {
__global__ void updateNodes(const PxvPreSolveNodeUpdate* updates,PxU32 count,PxvPreSolveNode* nodes,PxU32 size) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto update=updates[i];
    if(update.index>=size || update.value.live>1 || (update.value.live && !update.value.lifetime)){__trap();return;}
    nodes[update.index]=update.value;
}

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
// New touching GPU pairs merge the phase-preserved components. Static and
// kinematic boundaries cannot connect independent dynamic components.
__global__ void connectContacts(PxgDestructionPreSolveContacts view,const PxU32* retired,
    const PxvPreSolveNode* nodes,PxU32 size,PxU32* parents,PxgDestructionContactGraphStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=view.pairCount)return;
    const auto edge=destructionContactGraph::decodeAt(i,view.inputs,view.identities,view.outputs,
        view.shapes,view.shapeCapacity,size,status,retired);
    if(!edge.touching || (edge.flags&(PxgDestructionContactFlags::eRETIRED|PxgDestructionContactFlags::eDISABLE_RESPONSE|PxgDestructionContactFlags::eKINEMATIC_PAIR)))return;
    if(edge.node0<size && edge.node1<size && nodes[edge.node0].live && nodes[edge.node1].live)
        join(parents,edge.node0,edge.node1);
}
__global__ void requireValidContacts(const PxgDestructionContactGraphStatus* status) {
    if(status->error)__trap();
}
__global__ void finish(const PxvPreSolveNode* nodes,PxU32 size,PxU32* parents,PxU32* labels,PxU32* counts) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=size)return;
    if(!nodes[i].live){labels[i]=~PxU32(0);return;}
    const PxU32 r=root(parents,i);if(r>=size){__trap();return;}labels[i]=r;
    if(nodes[i].staticTouches)atomicAdd(counts+r,nodes[i].staticTouches);
}
}}
