// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgContactOwnership.h"
#include "PxgContactManager.h"
#include "PxsContactManagerState.h"
namespace physx { namespace destructionContactOwnership {
__global__ void validate(const PxgDestructionContactOwnerUpdate* updates,PxU32 count,
    PxgContactGraphSequence* sequence) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=count)return;
    const auto u=updates[i];
    bool valid=u.identity && u.output && u.rest && u.torsion && u.input
        && (!u.manifoldBytes || (u.manifold && u.emptyManifold && !(u.manifoldBytes%sizeof(PxU32)))) && u.identity->generation
        && u.identity->edgeIndex==u.oldEdge && u.newEdge!=~PxU32(0) && !u.reserved;
    if(valid) {
        const auto input=*u.input;
        valid=(input.transformCacheRef0==u.transform0 && input.transformCacheRef1==u.transform1)
            || (input.transformCacheRef0==u.transform1 && input.transformCacheRef1==u.transform0);
    }
    if(!valid)atomicOr(&sequence->error,2u);
}
__global__ void apply(const PxgDestructionContactOwnerUpdate* updates,PxU32 count,
    const PxgContactGraphSequence* sequence) {
    // One block owns a pair: orientation invalidation copies PCM cooperatively.
    // Validation precedes every commit, so a bad batch cannot commit a prefix.
    const PxU32 i=blockIdx.x;
    if(i>=count || sequence->error)return;
    const auto u=updates[i];
    __shared__ bool reverse;
    if(threadIdx.x==0)reverse=u.input->transformCacheRef0!=u.transform0;
    __syncthreads();
    if(reverse)for(PxU32 j=threadIdx.x;j<u.manifoldBytes/sizeof(PxU32);j+=blockDim.x)
        u.manifold[j]=u.emptyManifold[j];
    if(threadIdx.x)return;
    if(reverse) {
        const auto old=*u.input;
        *u.input={old.shapeRef1,old.shapeRef0,old.transformCacheRef1,old.transformCacheRef0};
    }
    *u.output={};
    u.output->statusFlag=PxU8(u.baseStatus|PxsContactManagerStatusFlag::eDIRTY_MANAGER);
    u.output->flags=u.flags;
    *u.rest=u.restDistance;
    u.torsion->mTorsionalPatchRadius=u.torsionalRadius;
    u.torsion->mMinTorsionalRadius=u.minTorsionalRadius;
    u.identity->edgeIndex=u.newEdge;
}
}}
