// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxDestructionScene.h"
#include "PxContact.h"
namespace physx {
struct PxgBodySim;
// Private bridge between PhysX's kernel-wrangler module and the runtime CUDA
// stress module. Both share the scene's CUDA context; no physics API replay.
class PxgDestructionRuntime : public PxDestructionScene {
public:
    virtual bool configured() const = 0;
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
    virtual void release() = 0;
};
}
#if defined(_WIN32)
#define PX_DESTRUCTION_RUNTIME_EXPORT __declspec(dllexport)
#else
#define PX_DESTRUCTION_RUNTIME_EXPORT __attribute__((visibility("default")))
#endif
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT physx::PxgDestructionRuntime*
PxCreateDestructionRuntime(CUcontext context, void* scene, bool (*writeAllowed)(void*));
