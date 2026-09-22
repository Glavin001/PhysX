// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxsContactManagerState.h"
#include "PxgSolverCoreDesc.h"
#include "PxgSolverConstraintDesc.h"
namespace physx {
// Called after actual normal/friction writeback. Retained geometry and post-step
// sleep flags cannot establish whether a response was produced this pass.
template<class Header>
__device__ inline void publishContactResponse(const PxgSolverCoreDesc& desc,
    const PxgBlockConstraintBatch& batch,const Header& header,PxU32 lane) {
    if(!header.numNormalConstr[lane] || header.forceWritebackOffset[lane]==0xffffffffu)return;
    const PxU32 cmIndex=desc.nativeContactWorkUnits[batch.mConstraintBatchIndex].mContactManagerOutputIndex[lane];
    // Patches of one manager may be written concurrently. The consumer joins
    // the complete writeback kernels; this stamp is not a readiness fence.
#if defined(PX_CUMETAL_SPLIT_RESPONSE_STAMP)
    // Every patch writer in this pass stores the SAME epoch. Readers and the
    // next pass must join all writeback kernels (see destruction advance()).
    // Two atomic words therefore produce the same final stamp without a wide
    // atomic lock. Neither word, nor the whole stamp, is a readiness signal.
    // This is deliberately local to this protocol, not a general atomicExch64.
#if __BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__
#error "Split response stamps require the little-endian CuMetal GPU layout"
#endif
    static_assert(sizeof(PxU64)==8 && sizeof(PxU32)==4,"response stamp layout");
    auto* words=reinterpret_cast<PxU32*>(&desc.contactManagerOutputBase[cmIndex].nativeResponseEpoch);
    atomicExch(words,static_cast<PxU32>(desc.nativeResponseEpoch));
    atomicExch(words+1,static_cast<PxU32>(desc.nativeResponseEpoch>>32));
#else
    atomicExch(reinterpret_cast<unsigned long long*>(
        &desc.contactManagerOutputBase[cmIndex].nativeResponseEpoch),
        static_cast<unsigned long long>(desc.nativeResponseEpoch));
#endif
}
}
