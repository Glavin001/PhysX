// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
#include "PxDestructionTopologyTypes.h"
#include "PxDirectGPUAPI.h"
namespace physx {
class PxShape;
// GPU-produced allocation metadata only. Mass, motion and graph arrays remain
// resident. A reservation is private/inactive until the correction transaction
// initializes its solver state and transfers persistent collision ownership.
struct PxvDestructionBodyRequest {
    PxU32 cluster, sourceBody, supported, needsBody, candidateSlot;
};
class PxvDestructionBodyAllocator {
public:
    virtual PxU32 getShapeContactIndex(const PxShape&) const { return ~PxU32(0); }
    virtual bool readRigidBodyData(void*,const PxRigidDynamicGPUIndex*,PxRigidDynamicGPUAPIReadType::Enum,
        PxU32,CUevent,CUevent) const { return false; }
    virtual bool needsHostProperties() const { return false; }
    virtual bool publishCorrectionProperties(const PxDestructionCorrectionBody*,PxU32) { return false; }
    virtual bool supportsGpuIslandRepair() const { return false; }

    virtual bool isValidSource(PxU32 body) const = 0;
    // Exceptional capacity grant, containing indices only. No solver bodies are
    // created here. The returned immutable prefix survives until clear().
    virtual bool reserveNodeCapacity(PxU32 capacity,const PxU32*& indices) = 0;
    // Materialize compatibility records at indices already selected by CUDA.
    // This bridge cannot choose or replace a requested native index.
    virtual bool prepare(const PxvDestructionBodyRequest* requests,PxU32 count,const PxU32* indices) = 0;
    // Host metadata bridge only: all decisions and body mass/motion were computed
    // on device. Called at the internal post-solve barrier, never via public API.
    virtual bool applyBindings(const PxDestructionCollisionBinding*, PxU32,
        const PxvDestructionBodyRequest*, const PxU32*, PxU32) { return false; }
    virtual void acceptReservations() {}
    virtual void discardReservations() { clear(); }
    virtual void clear() = 0;
protected:
    virtual ~PxvDestructionBodyAllocator() {}
};
}
