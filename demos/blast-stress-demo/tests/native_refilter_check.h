// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgAABBManager.h"
#include "PxgDestructionRuntime.h"
#include "NpScene.h"
#include <cuda.h>
#include <stdexcept>

namespace nativeRefilterTest {
class Audit {
    physx::PxgAABBManager& mBounds;
    physx::PxU64 mRequests, mWords;
    static void require(bool ok,const char* reason) {if(!ok)throw std::runtime_error(reason);}
public:
    explicit Audit(physx::PxScene& scene)
        :mBounds(static_cast<physx::PxgAABBManager&>(*static_cast<physx::NpScene&>(scene).getScScene().getAABBManager())),
         mRequests(mBounds.getHostRefilterRequests()),mWords(mBounds.getHostRefilterUploadWords()) {}

    void verify(physx::PxgDestructionRuntime& runtime,physx::PxCudaContextManager& cuda,
        physx::PxU32 affected,physx::PxU32 ordinary,bool reuse) {
        const auto view=runtime.collisionOwnershipView();
        const auto published=mBounds.getNativeOwnershipView();
        require(view.generation && view.shapeGenerations && affected<view.shapeCapacity && ordinary<view.shapeCapacity,
            "missing native GPU refilter generation");
        require(published.generation==view.generation && published.shapeGenerations==view.shapeGenerations
            && published.shapeCapacity==view.shapeCapacity,"broad phase did not borrow the installed GPU ownership view");
        physx::PxU64 stamps[2]{};
        {physx::PxScopedCudaLock lock(cuda);
            require(cuMemcpyDtoH(&stamps[0],reinterpret_cast<CUdeviceptr>(view.shapeGenerations+affected),sizeof(stamps[0]))==CUDA_SUCCESS
                && cuMemcpyDtoH(&stamps[1],reinterpret_cast<CUdeviceptr>(view.shapeGenerations+ordinary),sizeof(stamps[1]))==CUDA_SUCCESS,
                "native GPU refilter observation failed");}
        require(stamps[0]==view.generation,"affected persistent shape was not stamped by ownership installation");
        require(stamps[1]!=view.generation,"native refilter incorrectly selected an ordinary projectile");
        if(reuse)require(mBounds.getHostRefilterRequests()==mRequests && mBounds.getHostRefilterUploadWords()==mWords,
            "native fracture constructed or uploaded a CPU refilter bitmap");
    }
    void verifyOrdinaryPass() const {
        require(!mBounds.getNativeOwnershipView().generation,"a previous ownership generation leaked into an ordinary pass");
    }
};
}
