// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
#include "PxDestructionTopologyTypes.h"
namespace physx {
// GPU-produced allocation metadata only. Mass, motion and graph arrays remain
// resident. A reservation is private/inactive until the correction transaction
// initializes its solver state and transfers persistent collision ownership.
struct PxvDestructionBodyRequest {
    PxU32 cluster, sourceBody, supported, needsBody, candidateSlot;
};
class PxvDestructionBodyAllocator {
public:
    virtual bool isValidSource(PxU32 body) const = 0;
    virtual bool prepare(const PxvDestructionBodyRequest* requests,PxU32 count,PxU32* indices) = 0;
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
