// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxvIslandMetadata.h"
#include "foundation/PxProfiler.h"
#include "PxDestructionScene.h"
#include "PxContact.h"
#include "PxgDestructionContactGraph.h"
#include "PxgDestructionOwnership.h"
#include "PxgDestructionMotionStorage.h"
#include "PxvDestructionBodyAllocator.h"
namespace physx {
struct PxgBodySim;
class PxNodeIndex;
struct PxgShapeSim;
struct PxgContactManagerInput;
struct PxsContactManagerOutput;
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
// Borrowed producer storage; immutable geometry identities remain independent
// from motion. Ordered by the same producer stream supplied to advance.
struct PxgDestructionCollisionStorage {
    const PxgShapeSim* shapes = nullptr;
    const PxNodeIndex* shapeToBody = nullptr;
    PxU32 shapeCapacity = 0, remapCapacity = 0;
};
// Private bridge between PhysX's kernel-wrangler module and the runtime CUDA
// stress module. Both share the scene's CUDA context; no physics API replay.
class PxgDestructionRuntime : public PxDestructionScene {
public:
    // Optional diagnostics supplied by the scene module: do not resolve a second
    // foundation singleton from the CUDA runtime shared library.
    virtual void setProfiler(PxProfilerCallback* callback, PxU64 context) = 0;
    virtual bool configured() const = 0;
    virtual bool correctionEnabled() const = 0;
    virtual bool gpuIslandRepairEnabled() const = 0;
    // Ordered host observation for the existing CPU island registry. Membership packs n heads followed by n successors, in node-ID order;
    // connectivity and membership links are computed on CUDA.
    virtual bool observeContactComponents(const PxU32*& accurate, const PxU32*& speculative,
        const PxU32*& accurateMembers, const PxU32*& speculativeMembers, PxU32& count,
        bool needAccurate, bool needSpeculative) = 0;
    virtual PxgDestructionContactGraphObservationStats getContactGraphObservationStats() const = 0;
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
    virtual bool prepareFrame(bool postCorrection = false) = 0;
    // Merge the two evaluations into one tick receipt, after final ownership commit.
    virtual bool finishPostCorrection() = 0;
    virtual CUevent inputEvent() const = 0;
    // The producer stream owns the native body pool. Runtime orders its reads
    // after this stream and borrowed NP streams; no Direct GPU API gather or
    // second body-index binding is needed inside the simulation.
    virtual bool advance(PxReal dt, const PxVec3& gravity, const PxgDestructionMotionStorage& storage, CUstream producerStream,
        PxgDestructionGrowMotionStorage growStorage, void* storageOwner, const PxgDestructionSolvedContacts& contacts, const PxgDestructionCollisionStorage& collision) = 0;
    // Observes device allocation/preparation; only raw-capacity exhaustion
    // requires a host growth/retry. No CPU fragment objects precede preparation.
    virtual bool finish() = 0;
    // Compact compatibility IDs become available after completeCorrectionPreparation;
    // no physical state readback. Slots remain private until correction commits.
    virtual PxU32 reservedBodyCount() const = 0;
    virtual const PxU32* reservedBodyIndices() const = 0;
    // Asynchronous submission; success does not observe GPU validation. Collision
    // preparation consumes the device prerequisite; combined completion publishes
    // initialization/collision/correction failures before any ownership mutation.
    virtual bool initializeReservedBodies(PxgBodySim* bodies, PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations, PxU32 capacity, CUstream stream) = 0;
    // Asynchronous submission. GPU verdicts are available through readyEvent;
    // invalid collision preparation gates corrected-motion preparation on device.
    virtual bool prepareCollisionBindings(const PxgShapeSim* shapes, PxU32 shapeCapacity, const PxNodeIndex* shapeToBody, PxU32 remapCapacity, CUstream stream) = 0;
    virtual bool prepareCorrectionBodies(PxU32 bodyCapacity, CUstream stream) = 0;
    // Validate GPU preparation without constructing CPU compatibility objects.
    virtual bool observeCorrectionPreparation() = 0;
    // Normal scenes construct compatibility after native GPU ownership is
    // installed. Manual validation fixtures may construct explicitly.
    virtual bool completeCorrectionPreparation() = 0;
    // Body installation after rigid restore. Island/collision ownership and
    // accepted events remain separate. Unresolved source commands reject before
    // mutation; they must never be cloned indiscriminately onto fragments.
    virtual bool installCorrectionBodies(PxgBodySim* bodies, PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations, PxU32 capacity, PxU64 checkpointGeneration, CUstream stream) = 0;

    virtual void release() = 0;
    // Resolve persistent shape IDs into GPU narrowphase descriptors on the
    // caller's ordered NP stream. Pair allocation/filtering is still separate.
    virtual bool buildContactInputs(PxgContactManagerInput* inputs, PxU32 count,
        const PxgShapeSim* shapes, PxU32 shapeCapacity, CUstream stream) = 0;

    virtual bool buildContactGraph(const PxgContactManagerInput* inputs,const PxgContactGraphIdentity* identities,
        const PxsContactManagerOutput* outputs,PxU32 count,PxU32 omitted,const PxgShapeSim* shapes,
        PxU32 shapeCapacity,PxU32 nodeCapacity,const PxU32* retired,PxU32 retiredCount,CUstream stream,
        const PxgDestructionRetainedEdge* retainedUpdates,PxU32 retainedUpdateCount,PxU32 retainedSlotCount,const PxgContactGraphSequence* sequence=NULL) = 0;
    virtual PxgDestructionContactGraphView getContactGraphView() const = 0;
    // Pre-solve components retain previous connectivity and merge new native
    // edges. Outputs are ordered on the supplied solver stream.
    virtual bool canBuildPreSolveIslands() const = 0;
    virtual const PxvPreSolveNode* preSolveNodeView() const = 0;
    virtual const PxU32* preSolveSupportView() const = 0;
    virtual bool preSolveNodeSnapshotRequired(PxU32 count) const = 0;
    virtual bool buildPreSolveIslands(const PxvPreSolveNodeUpdate* updates,PxU32 updateCount,PxU32 count,bool fullSnapshot,
        const PxvPreSolveEdge* merges,PxU32 mergeCount,CUstream stream,
        const PxU32*& labels,const PxU32*& staticTouches,
        const PxgDestructionPreSolveContacts* contacts=NULL) = 0;


    // Install GPU-selected cluster ownership without re-uploading immutable geometry.
    virtual bool installCollisionOwners(PxgShapeSim* shapes, PxU32 capacity, PxNodeIndex* shapeToBody, PxU32 remapCapacity, CUstream stream) = 0;
    // readyEvent orders this borrowed view after GPU ownership installation.
    virtual PxgDestructionOwnershipView collisionOwnershipView() const = 0;
    virtual bool preserveUnchangedContactPairs() const = 0;
};
}
#if defined(_WIN32)
#define PX_DESTRUCTION_RUNTIME_EXPORT __declspec(dllexport)
#else
#define PX_DESTRUCTION_RUNTIME_EXPORT __attribute__((visibility("default")))
#endif
// Private producer ABI v4 supplies borrowed collision storage for device-controlled preparation.
// Version the symbol so mixed GPU/runtime binaries fail resolution rather than
// violating lifecycle ordering. Public scene ABI is intact.
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT physx::PxgDestructionRuntime*
PxCreateDestructionRuntimeV7(CUcontext context, void* scene, bool (*writeAllowed)(void*), physx::PxvDestructionBodyAllocator* allocator);

extern "C" PX_DESTRUCTION_RUNTIME_EXPORT bool
PxApplyDestructionSolverIslandMetadata(const physx::PxvIslandMetadataPage* pages,physx::PxU32 count,
    physx::PxU32* islandIds,physx::PxU32 nodes,physx::PxU32* staticTouches,physx::PxU32 islands,CUstream stream);
