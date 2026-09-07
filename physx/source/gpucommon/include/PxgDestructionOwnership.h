// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"

namespace physx {
// Borrowed by broad phase for one ordered correction. The ownership-install
// kernel stamps migrating persistent shapes. Retained motion owners keep their
// pair identities: mass/COM-dependent caches are reset separately, and corrected
// bounds are refreshed for all live shapes. No bitmap construction/copy/clear.
// Zero disables the view; old generations cannot affect later simulation.
struct PxgDestructionOwnershipView {
    const PxU64* shapeGenerations = NULL;
    PxU64 generation = 0;
    PxU32 shapeCapacity = 0;

    PX_CUDA_CALLABLE PX_FORCE_INLINE bool contains(PxU32 shape) const {
        return generation && shapeGenerations && shape < shapeCapacity
            && shapeGenerations[shape] == generation;
    }
};
}
