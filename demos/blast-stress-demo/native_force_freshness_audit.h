// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// Included only by freshness diagnostics and focused tests. The normal demo
// and production runtime do not contain this counterfactual operation.
#include "PxgSolverCore.h"
#include <cstdio>
#include <stdexcept>
namespace blast_demo {
inline void poisonNormalForceWriteback(physx::PxScene& scene,physx::PxCudaContextManager& cuda,unsigned frame) {
    auto* context=static_cast<physx::PxgGpuContext*>(static_cast<physx::NpScene&>(scene).getScScene().getDynamicsContext());
    const auto& buffer=context->mGpuSolverCore->mForceBuffer;
    const auto pointer=buffer.getDevicePtr();const size_t bytes=size_t(buffer.getSize());
    physx::PxScopedCudaLock lock(cuda);
    if(!pointer || !bytes || bytes%4)
        throw std::runtime_error("freshness audit cannot identify force output storage");
    // This is normal-force/face-index OUTPUT storage. Narrow phase produces
    // required face indices; the rigid solver writes actual normal impulses.
    // It is not solver warm-start or cached-friction input storage.
    if(cuMemsetD32(pointer,0x7fc00000u,bytes/4)!=CUDA_SUCCESS)
        throw std::runtime_error("freshness audit poison failed");
    std::fprintf(stderr,"force freshness audit: poison before step %u, %zu output bytes\n",frame,bytes);
}
}
