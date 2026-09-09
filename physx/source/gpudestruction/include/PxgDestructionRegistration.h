// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
namespace physx {
// Geometry lifetime and solver-registration lifetime are deliberately separate.
// slot orders activation; generation validates ownership after slot reuse.
struct PxgDestructionRegistrationHandle {
    PxU32 slot, generation;
};
struct PxgDestructionRegistrationEntry {
    PxU32 generation, live;
    PxU64 claimEpoch; // scratch for duplicate-release detection; not a CPU mirror
};
struct PxgDestructionRegistrationState {
    PxU32 allocated, freeCount, liveCount, error;
    PxU64 epoch, requiredCapacity;
};
struct PxgDestructionRegistrationBatch {
    PxU32 oldAllocated, oldFree, takeFree, newAllocated, newFree, newLive;
};
struct PxgDestructionRegistrationView {
    PxgDestructionRegistrationEntry* entries;
    PxU32* freeSlots;
    PxgDestructionRegistrationState* state;
    PxgDestructionRegistrationBatch* batch;
    PxU32 capacity, pageSize;
};
enum PxgDestructionRegistrationError : PxU32 {
    eREGISTRATION_CAPACITY = 1,
    eREGISTRATION_STALE_HANDLE = 2,
    eREGISTRATION_DUPLICATE_RELEASE = 4,
    eREGISTRATION_GENERATION_EXHAUSTED = 8,
    eREGISTRATION_INVALID_STATE = 16
};
}
