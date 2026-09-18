// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
namespace physx {
struct PxgBodySim;
struct PxgBodySimVelocities;
struct PxgRigidBodyAcceleration;
// Borrowed storage, not a list of active/registered bodies. The producer orders
// relocation before returning this view; consumers must refresh it each advance.
struct PxgDestructionMotionStorage {
    PxgBodySim* bodies = nullptr;
    PxgBodySimVelocities* previous = nullptr;
    PxgRigidBodyAcceleration* accelerations = nullptr;
    PxU32 capacity = 0;
};
using PxgDestructionGrowMotionStorage = bool (*)(void*, PxU32, PxgDestructionMotionStorage&);
}
