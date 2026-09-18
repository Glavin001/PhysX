// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgContactManager.h"
namespace physx { namespace contactIdentity {
// One atomic range reservation per block, not one atomic per contact. Blocks
// may execute in any order; generations identify lifetimes, not solver order.
__device__ inline PxU64 reserve(PxgContactGraphSequence* sequence,PxU32 count) {
    if(atomicAdd(&sequence->error,0u))return 0;
    auto* next=reinterpret_cast<unsigned long long*>(&sequence->next);
    auto old=atomicAdd(next,0ull);
    for(;;) {
        if(!old || count>~0ull-old) {atomicOr(&sequence->error,1u);return 0;}
        const auto observed=atomicCAS(next,old,old+count);
        if(observed==old)return old;
        old=observed;
    }
}
__device__ inline void initialize(PxgContactGraphIdentity* identities,const PxU32* edges,const PxU32* slots,
    PxU32 count,PxgContactGraphSequence* sequence) {
    __shared__ PxU64 first;
    for(PxU64 start=PxU64(blockIdx.x)*blockDim.x;start<count;start+=PxU64(gridDim.x)*blockDim.x) {
        const PxU32 n=min(PxU32(blockDim.x),count-PxU32(start));
        if(!threadIdx.x)first=reserve(sequence,n);
        __syncthreads();
        if(threadIdx.x<n) {
            const PxU32 i=PxU32(start)+threadIdx.x;
            // A failed reservation publishes invalid generations. The native
            // graph producer rejects these before accepting a destruction step.
            identities[i]={edges[i],slots?slots[i]:~PxU32(0),first?first+threadIdx.x:0};
        }
        __syncthreads(); // next reservation cannot overwrite first prematurely
    }
}
}}
