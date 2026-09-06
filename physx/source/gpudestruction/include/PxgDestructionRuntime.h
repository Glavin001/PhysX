// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxDestructionScene.h"
#include "PxContact.h"
#include "PxvDestructionBodyAllocator.h"
namespace physx {
struct PxgBodySim;
struct PxgShapeSim;
struct PxgBodySimVelocities;
struct PxgRigidBodyAcceleration;
// Internal rigid-state portion of the correction checkpoint, captured after
// command upload and before solving. This is not a complete scene checkpoint:
// island/contact/constraint and articulation state require separate accounting.
struct PxgDestructionRigidCheckpointView {
    const PxgBodySim* bodies = NULL;
    const PxgBodySimVelocities* previous = NULL;
    const PxgRigidBodyAcceleration* accelerations = NULL;
    PxU32 count = 0;
    PxU64 generation = 0;
    CUevent ready = NULL;
};
// Private bridge between PhysX's kernel-wrangler module and the runtime CUDA
// stress module. Both share the scene's CUDA context; no physics API replay.
class PxgDestructionRuntime : public PxDestructionScene {
public:
    virtual bool configured() const = 0;
    virtual bool correctionEnabled() const = 0;
    virtual bool applyCorrectionBindings() = 0;
    // GPU-selected affected owners mirrored for CPU metadata updates. This is
    // not the complete set of rigid bodies restored/re-solved during correction.
    virtual PxU32 correctionBodyCount() const = 0;
    virtual const PxU32* correctionBodyIndices() const = 0;
    virtual bool acceptCorrection(const PxgBodySim* bodies, CUstream stream) = 0;
    virtual bool captureRigidState(const PxgBodySim* bodies, const PxgBodySimVelocities* previous,
        const PxgRigidBodyAcceleration* accelerations, PxU32 count, CUstream stream) = 0;
    virtual PxgDestructionRigidCheckpointView rigidCheckpoint() const = 0;
    // Copies only the captured rigid arrays, never CPU/island/contact state.
    // Candidate bodies must be applied after this restore, including new slots
    // that reused pre-existing holes. The future correction task owns that order.
    virtual bool restoreRigidState(PxgBodySim* bodies, PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations, PxU32 capacity, PxU64 generation, CUstream stream) = 0;
    virtual bool prepareFrame(PxU32 contactCapacity) = 0;
    virtual PxGpuContactPair* contactPairs() const = 0;
    virtual PxU32* contactCount() const = 0;
    virtual CUevent inputEvent() const = 0;
    virtual PxTransform* poses() const = 0;
    virtual PxVec3* angularVelocities() const = 0;
    virtual const PxRigidDynamicGPUIndex* bodyIndices() const = 0;
    virtual PxU32 clusterCount() const = 0;
    virtual bool advance(PxReal dt, const PxVec3& gravity, const PxgBodySim* bodyStates) = 0;
    virtual bool finish() = 0;
    // Compact CPU allocation IDs only; no physical state readback. Slots remain
    // private/inactive until the correction transaction commits.
    virtual PxU32 reservedBodyCount() const = 0;
    virtual const PxU32* reservedBodyIndices() const = 0;
    virtual bool initializeReservedBodies(PxgBodySim* bodies, PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations, PxU32 capacity, CUstream stream) = 0;
    virtual bool prepareCollisionBindings(const PxgShapeSim* shapes, PxU32 shapeCapacity, CUstream stream) = 0;
    virtual bool prepareCorrectionBodies(PxU32 bodyCapacity, CUstream stream) = 0;
    // Body installation after rigid restore. Island/collision ownership and
    // accepted events remain separate. Unresolved source commands reject before
    // mutation; they must never be cloned indiscriminately onto fragments.
    virtual bool installCorrectionBodies(PxgBodySim* bodies, PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations, PxU32 capacity, PxU64 checkpointGeneration, CUstream stream) = 0;

    virtual void release() = 0;
};
}
#if defined(_WIN32)
#define PX_DESTRUCTION_RUNTIME_EXPORT __declspec(dllexport)
#else
#define PX_DESTRUCTION_RUNTIME_EXPORT __attribute__((visibility("default")))
#endif
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT physx::PxgDestructionRuntime*
PxCreateDestructionRuntime(CUcontext context, void* scene, bool (*writeAllowed)(void*), physx::PxvDestructionBodyAllocator* allocator);
