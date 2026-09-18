// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the topology CUDA namespace. The pool stores capacity, not one
// independently active body per chunk. Only active roots receive motion slots.
__global__ void retainMotionSlots(unsigned* slotRoots,const unsigned* alive,
    const unsigned* labels,unsigned* freeFlags,unsigned n) {
    const unsigned slot=blockIdx.x*blockDim.x+threadIdx.x;if(slot>=n)return;
    const unsigned r=slotRoots[slot];
    const bool keep=r<n && alive[r] && labels[r]==r;
    if(!keep)slotRoots[slot]=INVALID;
    freeFlags[slot]=keep?0u:1u;
}
__global__ void requestMotionSlots(const unsigned* alive,const unsigned* labels,
    unsigned* rootSlots,const unsigned* slotRoots,unsigned* requests,unsigned n) {
    const unsigned r=blockIdx.x*blockDim.x+threadIdx.x;if(r>=n)return;
    const unsigned slot=rootSlots[r];
    const bool root=alive[r] && labels[r]==r;
    const bool retained=root && slot<n && slotRoots[slot]==r;
    requests[r]=root && !retained?1u:0u;
    if(!retained)rootSlots[r]=INVALID;
}
__global__ void compactFreeMotionSlots(const unsigned* freeFlags,const unsigned* ranks,
    unsigned* slots,unsigned n) {
    const unsigned slot=blockIdx.x*blockDim.x+threadIdx.x;
    if(slot<n && freeFlags[slot])slots[ranks[slot]]=slot;
}
__global__ void allocateMotionSlots(const unsigned* requests,const unsigned* ranks,
    const unsigned* freeSlots,const unsigned* freeRanks,const unsigned* freeFlags,
    unsigned* rootSlots,unsigned* slotRoots,std::uint64_t* generations,
    PxgDestructionTopologyStatus* status,unsigned n) {
    const unsigned r=blockIdx.x*blockDim.x+threadIdx.x;if(r>=n || !requests[r])return;
    const unsigned available=freeRanks[n-1]+freeFlags[n-1];
    if(ranks[r]>=available){atomicOr(&status->slotError,1u);return;}
    const unsigned slot=freeSlots[ranks[r]];
    if(generations[slot]==~std::uint64_t(0)){atomicOr(&status->slotError,2u);return;}
    // Stable scans pair ascending new roots with ascending free slots. No
    // per-fragment host allocation, linked lists or contended free-list head.
    ++generations[slot];rootSlots[r]=slot;slotRoots[slot]=r;
}
