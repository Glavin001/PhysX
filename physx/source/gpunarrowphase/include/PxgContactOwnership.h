// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
namespace physx {
struct PxgContactGraphIdentity;
struct PxgContactManagerInput;
struct PxsContactManagerOutput;
struct PxsTorsionalFrictionData;
// Internal, stream-ordered transaction. Pair geometry and lifetime persist;
// only the motion edge, solver output and current contact properties change.
struct PxgDestructionContactOwnerUpdate {
    PxgContactGraphIdentity* identity;
    PxsContactManagerOutput* output;
    PxReal* rest;
    PxsTorsionalFrictionData* torsion;
    PxU32 oldEdge,newEdge;
    PxU16 flags,reserved;
    PxReal restDistance,torsionalRadius,minTorsionalRadius;
    PxgContactManagerInput* input;
    PxU32 transform0,transform1,baseStatus,manifoldBytes;
    PxU32* manifold;
    const PxU32* emptyManifold;
};
}
