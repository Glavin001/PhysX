// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgContactManager.h"
namespace physx { namespace contactIdentity {
// PX_CUMETAL_SERIAL_CONTACT_IDS selects one GPU block, with launches sharing
// a sequence ordered on one stream or through explicit event dependencies.
// Production initialization uses the narrowphase stream. This is a scheduling
// choice, not a narrowed counter or a generic replacement for 64-bit atomics.
// One atomic range reservation per block, not one atomic per contact. Blocks
// may execute in any order; generations identify lifetimes, not solver order.
__device__ inline PxU64 reserve(PxgContactGraphSequence* sequence,PxU32 count) {
    if(atomicAdd(&sequence->error,0u))return 0;
#if defined(PX_CUMETAL_SERIAL_CONTACT_IDS)
    const PxU64 old=sequence->next;
    if(!old || count>~PxU64(0)-old) {atomicOr(&sequence->error,1u);return 0;}
    sequence->next=old+count;
    return old;
#else
    auto* next=reinterpret_cast<unsigned long long*>(&sequence->next);
    auto old=atomicAdd(next,0ull);
    for(;;) {
        if(!old || count>~0ull-old) {atomicOr(&sequence->error,1u);return 0;}
        const auto observed=atomicCAS(next,old,old+count);
        if(observed==old)return old;
        old=observed;
    }
#endif
}
__device__ inline void initialize(PxgContactGraphIdentity* identities,const PxU32* edges,
    PxU32 count,PxgContactGraphSequence* sequence) {
#if defined(PX_CUMETAL_SERIAL_CONTACT_IDS)
    // Uniform rejection happens before any barriers or identity/counter writes.
    // Error mask 4 marks an invalid scheduling contract; downstream validation rejects
    // every nonzero sequence error before accepting a destruction step.
    if(gridDim.x!=1 || gridDim.y!=1 || gridDim.z!=1 || blockDim.y!=1 || blockDim.z!=1) {
        if(!threadIdx.x && !threadIdx.y && !threadIdx.z)atomicOr(&sequence->error,4u);
        return;
    }
#endif
    __shared__ PxU64 first;
    for(PxU64 start=PxU64(blockIdx.x)*blockDim.x;start<count;start+=PxU64(gridDim.x)*blockDim.x) {
        const PxU32 n=min(PxU32(blockDim.x),count-PxU32(start));
        if(!threadIdx.x)first=reserve(sequence,n);
        __syncthreads();
        if(threadIdx.x<n) {
            const PxU32 i=PxU32(start)+threadIdx.x;
            // A failed reservation publishes invalid generations. The native
            // graph producer rejects these before accepting a destruction step.
            identities[i]={edges[i],0,first?first+threadIdx.x:0};
        }
        __syncthreads(); // next reservation cannot overwrite first prematurely
    }
}
}}
