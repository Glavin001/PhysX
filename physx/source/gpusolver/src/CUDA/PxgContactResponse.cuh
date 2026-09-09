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
    atomicExch(reinterpret_cast<unsigned long long*>(
        &desc.contactManagerOutputBase[cmIndex].nativeResponseEpoch),
        static_cast<unsigned long long>(desc.nativeResponseEpoch));
}
}
