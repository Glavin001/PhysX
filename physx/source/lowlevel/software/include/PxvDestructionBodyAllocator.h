// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
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
    virtual void clear() = 0;
protected:
    virtual ~PxvDestructionBodyAllocator() {}
};
}
