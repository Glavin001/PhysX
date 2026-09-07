// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgBroadPhaseDesc.h"
#include "BpFiltering.h"
#include "foundation/PxAssert.h"

namespace physx {
// A native scene shares NP's authoritative shape-to-motion map. Rigid group
// equality is motion identity, including full articulation-link node IDs.
// Static shapes share the static node. Aggregate/deformable proxies retain
// their upstream group namespace; no temporary native group IDs are allocated.
PX_CUDA_CALLABLE PX_FORCE_INLINE bool differentBroadPhaseGroups(
    const PxgBroadPhaseDesc* desc, PxU32 a, PxU32 b)
{
    const PxU32 groupA=desc->updateData_groups[a],groupB=desc->updateData_groups[b];
    const PxU32 typeA=groupA&BP_FILTERING_TYPE_MASK,typeB=groupB&BP_FILTERING_TYPE_MASK;
    if(desc->rigidOwners && typeA<=Bp::FilterType::DYNAMIC && typeB<=Bp::FilterType::DYNAMIC) {
        if(a>=desc->rigidOwnerCapacity || b>=desc->rigidOwnerCapacity) {
#if defined(__CUDA_ARCH__)
            asm volatile("trap;");
#else
            PX_ASSERT(false && "Broad-phase rigid ownership view is incomplete");
#endif
            return false;
        }
        return desc->rigidOwners[a].getInd()!=desc->rigidOwners[b].getInd();
    }
    return groupA!=groupB;
}
}
