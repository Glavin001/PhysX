// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
#include "PxDestructionTopologyTypes.h"
#include "PxDirectGPUAPI.h"
namespace physx {
class PxShape;
// Physical rigid state supplement to the PhysX object collection. GPU-owned
// accepted values can differ from host mirrors. No numerical or allocator history.
struct PxvDestructionSnapshotBody {
    PxTransform bodyToWorld,bodyToActor;
    PxVec3 linearVelocity,angularVelocity,inverseInertia;
    PxVec4 limitsDamping,dynamicLimitsDamping;
    PxReal inverseMass,wakeCounter,maxPenBias,maxImpulse,contactThreshold,offsetSlop;
    PxReal sleepThreshold,freezeThreshold;
    PxU32 solverIterations,lockFlags,disableGravity,active;
};
// GPU-produced allocation metadata only. Mass, motion and graph arrays remain
// resident. A reservation is private/inactive until the correction transaction
// initializes its solver state and transfers persistent collision ownership.
struct PxvDestructionBodyRequest {
    PxU32 cluster, sourceBody, supported, needsBody, candidateSlot;
};
// Accepted CPU observation. Settings come from the current GPU owner, never
// from a provisional CPU ancestor which may not have been published yet.
struct PxvDestructionBodyProperties {
    PxDestructionCorrectionBody motion;
    // Plain scalars keep value-initialized unused observation entries defined.
    PxReal dynamicLimitsDamping[4];
    PxReal maxPenBias,maxContactImpulse,contactReportThreshold,offsetSlop;
    PxReal sleepThreshold,freezeThreshold;
    PxU16 lockFlags,disableGravity;
    PxU32 solverIterationCounts;
};
class PxvDestructionBodyAllocator {
public:
    virtual PxU32 getShapeContactIndex(const PxShape&) const { return ~PxU32(0); }
    virtual bool readRigidBodyData(void*,const PxRigidDynamicGPUIndex*,PxRigidDynamicGPUAPIReadType::Enum,
        PxU32,CUevent,CUevent) const { return false; }
    virtual bool needsHostProperties() const { return false; }
    // Between-step scheduler bridge for current GPU-selected command owners.
    // IDs only; force/mass/velocity work remains on the GPU. Validate the whole
    // batch and finish pending sleep writes before waking any dynamic owner.
    virtual bool wakeCommandOwners(const PxU32*,PxU32) { return false; }
    // Accepted physical observation only; never a prerequisite of GPU correction.
    virtual bool publishCorrectionProperties(const PxvDestructionBodyProperties*,PxU32) { return false; }
    virtual bool supportsGpuIslandRepair() const { return false; }

    virtual bool isValidSource(PxU32 body) const = 0;
    virtual bool stateExportAllowed() const { return false; }
    virtual bool exportNativeSnapshot(const PxU32*,PxU32,void*,PxU32) const { return false; }
    virtual bool importNativeSnapshot(const PxU32*,PxU32,const void*,PxU32) { return false; }
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
    // Final GPU-selected ownership union; simulation links already match these
    // owners. This changes only accepted actor/query observations.
    virtual bool publishShapeOwners(const PxDestructionCollisionBinding*,PxU32) { return false; }
    virtual void acceptReservations() {}
    virtual void discardReservations() { clear(); }
    virtual void clear() = 0;
protected:
    virtual ~PxvDestructionBodyAllocator() {}
};
}
