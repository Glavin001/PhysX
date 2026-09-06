// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgDestructionContactGraph.h"
#include "PxgShapeSim.h"
#include "PxsContactManagerState.h"
namespace physx { namespace destructionContactGraph {
__global__ void initialize(PxU32* accurate,PxU32* speculative,PxU32 n,
    PxgDestructionContactGraphStatus* status,PxU32 omitted) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<n){accurate[i]=i;speculative[i]=i;}
    if(i==0)*status={omitted?PxgDestructionContactGraphStatus::eMISSING_PAIRS:0u,omitted};
}
__global__ void retire(const PxU32* indices,PxU32 count,PxU32 pairs,PxU32* retired,PxgDestructionContactGraphStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU32 index=indices[i];
    if(index>=pairs){atomicOr(&status->error,PxgDestructionContactGraphStatus::eINVALID_IDENTITY);return;}
    atomicOr(retired+(index>>5),1u<<(index&31));
}
__device__ inline PxgDestructionContactEdge decodeAt(PxU32 i,const PxgContactManagerInput* inputs,const PxgContactGraphIdentity* identities,
    const PxsContactManagerOutput* outputs,const PxgShapeSim* shapes,PxU32 shapeCapacity,
    PxU32 nodeCapacity,PxgDestructionContactGraphStatus* status,const PxU32* retired) {
    const auto id=identities[i];const auto input=inputs[i];const auto output=outputs[i];
    PxgDestructionContactEdge edge={id,PX_INVALID_NODE,PX_INVALID_NODE,output.flags,
        (output.statusFlag&PxsContactManagerStatusFlag::eHAS_TOUCH)?1u:0u};
    // Retired managers remain in NP buckets until next pass compaction. Their
    // geometry or CPU interaction may already be gone: do not dereference it.
    if(retired && (retired[i>>5]&(1u<<(i&31)))){edge.flags|=PxgDestructionContactFlags::eRETIRED;return edge;}
    if(!id.generation || id.edgeIndex==~PxU32(0) || input.transformCacheRef0>=shapeCapacity || input.transformCacheRef1>=shapeCapacity) {
        atomicOr(&status->error,PxgDestructionContactGraphStatus::eINVALID_IDENTITY);return edge;
    }
    const auto a=shapes[input.transformCacheRef0].mBodySimIndex,b=shapes[input.transformCacheRef1].mBodySimIndex;
    if(a.isArticulation() || b.isArticulation() || (output.flags&(PxgDestructionContactFlags::eARTICULATION|PxgDestructionContactFlags::eSOFT_BODY))) {
        atomicOr(&status->error,PxgDestructionContactGraphStatus::eUNSUPPORTED_ENDPOINT);return edge;
    }
    if((a.isValid() && a.index()>=nodeCapacity) || (b.isValid() && b.index()>=nodeCapacity)) {
        atomicOr(&status->error,PxgDestructionContactGraphStatus::eINVALID_IDENTITY);return edge;
    }
    edge.node0=a.index();edge.node1=b.index();return edge;
}
// Optional diagnostic materialization, exercised by kernel tests. Production
// connects directly from borrowed NP records without this per-edge allocation.
__global__ void decode(const PxgContactManagerInput* inputs,const PxgContactGraphIdentity* identities,
    const PxsContactManagerOutput* outputs,PxU32 count,const PxgShapeSim* shapes,PxU32 shapeCapacity,
    PxU32 nodeCapacity,PxgDestructionContactEdge* edges,PxgDestructionContactGraphStatus* status,const PxU32* retired) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i<count)
        edges[i]=decodeAt(i,inputs,identities,outputs,shapes,shapeCapacity,nodeCapacity,status,retired);
}
// Monotone concurrent union-find. Atomic loads avoid races with root hooks.
// Every successful hook lowers a parent; no cycle or iteration-budget shortcut
// is possible. The final compression kernel runs after all unions complete.
__device__ inline PxU32 root(PxU32* parents,PxU32 node) {
    for(;;){const PxU32 next=atomicAdd(parents+node,0u);if(next==node)return node;
        const PxU32 grand=atomicAdd(parents+next,0u);atomicCAS(parents+node,next,grand);node=next;}
}
__device__ inline void unite(PxU32* parents,PxU32 a,PxU32 b) {
    for(;;){a=root(parents,a);b=root(parents,b);if(a==b)return;
        const PxU32 high=a>b?a:b,low=a<b?a:b;
        if(atomicCAS(parents+high,high,low)==high)return;
    }
}
__global__ void connect(const PxgContactManagerInput* inputs,const PxgContactGraphIdentity* identities,
    const PxsContactManagerOutput* outputs,PxU32 count,const PxgShapeSim* shapes,PxU32 shapeCapacity,
    PxU32 nodeCapacity,PxgDestructionContactGraphStatus* status,const PxU32* retired,PxU32* accurate,PxU32* speculative) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto edge=decodeAt(i,inputs,identities,outputs,shapes,shapeCapacity,nodeCapacity,status,retired);
    if(edge.node0==PX_INVALID_NODE || edge.node1==PX_INVALID_NODE || (edge.flags&PxgDestructionContactFlags::eKINEMATIC_PAIR))return;
    // Speculative islands contain broadphase pairs before touch is established.
    unite(speculative,edge.node0,edge.node1);
    if(edge.touching && !(edge.flags&PxgDestructionContactFlags::eDISABLE_RESPONSE))unite(accurate,edge.node0,edge.node1);
}
__global__ void componentKeys(const PxU32* labels,PxU64* keys,PxU32 n) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<n)keys[i]=(PxU64(labels[i])<<32)|i;
}
__global__ void compress(PxU32* accurate,PxU32* speculative,PxU32 n) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    atomicExch(accurate+i,root(accurate,i));atomicExch(speculative+i,root(speculative,i));
}
}}
