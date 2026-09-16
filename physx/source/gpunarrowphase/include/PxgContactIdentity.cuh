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
// Dense slot reservation: pop up to n recycled slots, then extend the high
// water. Only this kernel pops and only releaseSlots pushes; both run on the
// NP stream in order, so the CAS on freeCount is the only contention here.
struct SlotRange { PxU32 freeBase,freeTaken,highBase; };
__device__ inline SlotRange reserveSlots(PxgContactSlotAllocator* slots,PxU32 n,PxU32 capacity) {
    SlotRange r={0,0,0};
    if(!slots || !n)return r;
    PxU32 old=atomicAdd(&slots->freeCount,0u);
    for(;;) {
        const PxU32 take=min(n,old);
        const PxU32 seen=atomicCAS(&slots->freeCount,old,old-take);
        if(seen==old){r.freeBase=old-take;r.freeTaken=take;break;}
        old=seen;
    }
    const PxU32 rest=n-r.freeTaken;
    if(rest) {
        r.highBase=atomicAdd(&slots->highWater,rest);
        if(r.highBase+rest>capacity || r.highBase+rest<r.highBase)atomicOr(&slots->error,1u);
    }
    return r;
}
__device__ inline void initialize(PxgContactGraphIdentity* identities,const PxU32* edges,
    PxU32 count,PxgContactGraphSequence* sequence,PxgContactSlotAllocator* slots,const PxU32* freeList,PxU32 slotCapacity) {
    __shared__ PxU64 first;
    __shared__ SlotRange range;
    for(PxU64 start=PxU64(blockIdx.x)*blockDim.x;start<count;start+=PxU64(gridDim.x)*blockDim.x) {
        const PxU32 n=min(PxU32(blockDim.x),count-PxU32(start));
        if(!threadIdx.x){first=reserve(sequence,n);range=reserveSlots(slots,n,slotCapacity);}
        __syncthreads();
        if(threadIdx.x<n) {
            const PxU32 i=PxU32(start)+threadIdx.x;
            PxU32 slot=~PxU32(0);
            if(slots) {
                slot=threadIdx.x<range.freeTaken?freeList[range.freeBase+threadIdx.x]:range.highBase+(threadIdx.x-range.freeTaken);
                if(slot>=slotCapacity)slot=~PxU32(0);
            }
            // A failed reservation publishes invalid generations. The native
            // graph producer rejects these before accepting a destruction step.
            identities[i]={edges[i],slot,first?first+threadIdx.x:0};
        }
        __syncthreads(); // next reservation cannot overwrite first prematurely
    }
}
// Retired pairs return their slots before buffer compaction. Values, not
// row indices, are recycled, so later swaps do not invalidate the free list.
__device__ inline void releaseSlots(const PxgContactGraphIdentity* identities,const PxU32* rows,PxU32 count,
    PxgContactSlotAllocator* slots,PxU32* freeList,PxU32 slotCapacity) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=count)return;
    const auto id=identities[rows[i]];
    if(!id.generation || id.slot==~PxU32(0))return;
    const PxU32 pos=atomicAdd(&slots->freeCount,1u);
    if(pos>=slotCapacity){atomicOr(&slots->error,2u);return;}
    freeList[pos]=id.slot;
}
}}
