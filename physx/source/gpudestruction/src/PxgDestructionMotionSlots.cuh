// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the runtime implementation namespace. The CPU grants address
// capacity; these kernels make and commit the per-cluster allocation decision.
__global__ void beginNativeMotionSlots(PxDestructionMotionSlotStatus* pool,PxU32 capacity,
    const PxDestructionBodyPreparationStatus* preparation,PxU32 requested,
    PxDestructionBodyAllocationStatus* allocation) {
    pool->capacity=capacity;pool->pending=0;pool->error=0;
    *allocation={};allocation->generation=preparation->generation;allocation->count=preparation->count;
    if(!preparation->valid || requested!=preparation->allocationRequests || requested>preparation->count)
        pool->error|=2u;
    if(pool->committed>capacity || requested>capacity-pool->committed)pool->error|=1u;
    allocation->error=pool->error;
    if(!pool->error){pool->pending=requested;allocation->reserved=requested;}
}
__global__ void assignNativeMotionSlots(const PxDestructionMotionSlotStatus* pool,const PxU32* granted,
    const PxvDestructionBodyRequest* requests,PxU32 count,PxU32* selected,PxU32* candidateIndices,
    PxDestructionBodyAllocationStatus* allocation) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    selected[i]=PX_INVALID_U32;
    if(pool->error)return;
    const auto request=requests[i];const PxU32 index=granted[pool->committed+i];
    if(!request.needsBody || request.candidateSlot>=allocation->count || index==PX_INVALID_U32 || index==request.sourceBody) {
        atomicOr(&allocation->error,4u);return;
    }
    selected[i]=index;candidateIndices[request.candidateSlot]=index;
}
__global__ void finishNativeMotionSlots(PxDestructionBodyAllocationStatus* allocation,PxDestructionStageStatus* stage) {
    allocation->valid=!allocation->error;
    if(!allocation->valid)stage->error|=256u;
}
__global__ void finishNativeBodyShadowRegistration(bool valid,PxDestructionBodyAllocationStatus* allocation,
    PxDestructionStageStatus* stage) {
    if(!valid){allocation->error|=8u;allocation->valid=0;stage->error|=256u;}
}
__global__ void commitNativeMotionSlots(PxDestructionMotionSlotStatus* pool,const PxDestructionStageStatus* stage) {
    if(stage->error)return;
    pool->committed+=pool->pending;pool->pending=0;
}
