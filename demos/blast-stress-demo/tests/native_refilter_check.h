// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgAABBManager.h"
#include "PxgCudaBroadPhaseSap.h"
#include "PxgBroadPhaseGroups.h"
#include "PxgDestructionRuntime.h"
#include "NpScene.h"
#include <cuda.h>
#include <stdexcept>

namespace nativeRefilterTest {
class Audit {
    physx::PxgAABBManager& mBounds;
    physx::PxU64 mRequests, mWords, mGroupBytes;
    static void require(bool ok,const char* reason) {if(!ok)throw std::runtime_error(reason);}
    static void verifyGroupIdentity() {
        using namespace physx;
        // CPU IDs deliberately alias different motion owners and disagree for
        // shapes on one owner. Full link identity must also remain distinct.
        PxU32 groups[]={10,10,18,10,10,0,0,11};
        PxNodeIndex owners[]={PxNodeIndex(7u),PxNodeIndex(8u),PxNodeIndex(7u),
            PxNodeIndex(7,0),PxNodeIndex(7,1),PxNodeIndex(),PxNodeIndex(),PxNodeIndex()};
        PxgBroadPhaseDesc desc{};desc.updateData_groups=groups;desc.rigidOwners=owners;desc.rigidOwnerCapacity=8;
        require(differentBroadPhaseGroups(&desc,0,1),"split bodies inherited one CPU group and lost collision eligibility");
        require(!differentBroadPhaseGroups(&desc,0,2),"one GPU motion owner acquired self collisions");
        require(differentBroadPhaseGroups(&desc,3,4),"articulation-link identities collapsed to a body index");
        require(!differentBroadPhaseGroups(&desc,5,6) && differentBroadPhaseGroups(&desc,0,5),"static filtering changed");
        require(differentBroadPhaseGroups(&desc,0,7),"aggregate proxy group namespace changed");
        desc.rigidOwners=nullptr;
        require(!differentBroadPhaseGroups(&desc,0,1) && differentBroadPhaseGroups(&desc,0,2),"ordinary PhysX grouping changed");
    }
public:
    explicit Audit(physx::PxScene& scene)
        :mBounds(static_cast<physx::PxgAABBManager&>(*static_cast<physx::NpScene&>(scene).getScScene().getAABBManager())),
         mRequests(mBounds.getHostRefilterRequests()),mWords(mBounds.getHostRefilterUploadWords()),
         mGroupBytes(static_cast<physx::PxgCudaBroadPhaseSap*>(mBounds.getBroadPhase())->getHostGroupUploadBytes()) {verifyGroupIdentity();}

    void verify(physx::PxgDestructionRuntime& runtime,physx::PxCudaContextManager& cuda,
        physx::PxU32 affected,physx::PxU32 ordinary,bool reuse) {
        const auto view=runtime.collisionOwnershipView();
        const auto published=mBounds.getNativeOwnershipView();
        require(mBounds.getRigidOwners() && mBounds.getRigidOwnerCapacity()>affected,"broad phase lost GPU motion ownership");
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
        if(reuse)require(mBounds.getHostRefilterRequests()==mRequests && mBounds.getHostRefilterUploadWords()==mWords
            && static_cast<physx::PxgCudaBroadPhaseSap*>(mBounds.getBroadPhase())->getHostGroupUploadBytes()==mGroupBytes,
            "native fracture reconstructed/uploaded CPU filtering metadata");
    }
    void verifyOrdinaryPass() const {
        require(!mBounds.getNativeOwnershipView().generation,"a previous ownership generation leaked into an ordinary pass");
    }
};
}
