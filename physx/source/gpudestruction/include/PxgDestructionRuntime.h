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
struct PxgBodySimVelocityUpdate;
class PxNodeIndex;
struct PxgShapeSim;
struct PxgContactManagerInput;
struct PxsContactManagerOutput;
struct PxgBodySimVelocities;
struct PxgRigidBodyAcceleration;
enum class PxgDestructionCheckpointPurpose : PxU32 { BeforeSolve, CorrectedMotion };
// Authored chunk -> original native body and motion handle. Inactive entries
// have active=0 and invalid body/root/slot. A reused current slot is not this
// original handle; resolve descendants through the authored chunk index.
struct PxgDestructionInputOwner {
    PxU64 slotGeneration;
    PxU32 body, root, slot, active;
};
struct PxgDestructionInputOwnership {
    PxU64 inputGeneration, topologyGeneration;
    PxU32 chunkCount, bodyCount, valid, error;
};
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
    PxgDestructionCheckpointPurpose purpose = PxgDestructionCheckpointPurpose::BeforeSolve;
    // Only the inputRigidCheckpoint view supplies this original ownership.
    // Wait for ready, then require device ownership.valid and matching input
    // generation before reading owners. No CPU observation is required.
    const PxgDestructionInputOwner* owners = NULL;
    const PxgDestructionInputOwnership* ownership = NULL;
};
// Sparse ordinary command history, captured before native GPU delta addition.
// kind: 0 no velocity-delta command, 1 valid command, 2 invalid source. This is
// body-level input history, not a spatial per-chunk load distribution.
struct PxgDestructionCommandInput {
    float linearBefore[3], angularBefore[3], linearDelta[3], angularDelta[3];
    PxU32 body, flags, kind, reserved;
};
struct PxgDestructionCommandInputStatus { PxU64 generation; PxU32 count,error; };
struct PxgDestructionCommandInputView {
    const PxgDestructionCommandInput* records=nullptr;
    const PxgDestructionCommandInputStatus* status=nullptr;
    PxU32 count=0;
    PxU64 generation=0;
    CUevent ready=nullptr;
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
    // Current native owner IDs from the GPU command producer, observed only for
    // ordinary CPU scheduler compatibility. Between accepted steps only; no
    // command values or numerical state cross this bridge. Not an apply API.
    virtual bool wakeCommandOwners(const PxU32* indices,PxU32 count) = 0;
    virtual bool captureCommandInputs(const PxgBodySim*,PxU32 bodyCount,const PxgBodySimVelocityUpdate*,PxU32 count,CUstream) = 0;
    // Shares original checkpoint readiness/generation; correction refresh retains
    // records. Only correction-enabled ordinary/host-delta uploads are captured.
    virtual PxgDestructionCommandInputView commandInputHistory() const = 0;
    virtual bool prepareRigidIterationLimits(const PxgBodySim*,PxU32,const PxNodeIndex*,PxU32,PxU32,CUstream) = 0;
    virtual bool readRigidIterationLimits(PxU32& position,PxU32& velocity) = 0;
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
        const PxgRigidBodyAcceleration* accelerations, PxU32 count, CUstream stream,
        PxgDestructionCheckpointPurpose purpose = PxgDestructionCheckpointPurpose::BeforeSolve) = 0;
    virtual PxgDestructionRigidCheckpointView rigidCheckpoint() const = 0;
    // Original post-command/pre-solve arrays survive the corrected-motion
    // refresh. Read-only until the next BeforeSolve capture or clear; join
    // consumers before that boundary. This is raw input history, not a complete
    // chunk-targeted load ledger or permission to restore an older checkpoint.
    virtual PxgDestructionRigidCheckpointView inputRigidCheckpoint() const = 0;
    // Copies only the captured rigid arrays, never CPU/island/contact state.
    // Candidate bodies must be applied after this restore, including new slots
    // that reused pre-existing holes. The future correction task owns that order.
    // R2 core: device sleep verdicts. From the solver's per-body sleep data and
    // the accurate contact-graph labels, mark every node whose device component
    // holds a body that is not ready to sleep; the island sims deactivate an
    // island from the flag of its root node instead of walking its nodes.
    // Device sleep verdicts (R2 item 1). Enqueued on the solver stream right after
    // integration of a pass, from that pass's pre-solve node labels and solver
    // sleep data; nodes absent from the solver list are not ready. The pending
    // verdict becomes the published one when the next tick's trial pass asks for
    // it, so both the trial and the corrected third island pass of a tick read
    // the verdict of the previous tick's final pass, exactly like the CPU's
    // sticky readiness flags (restored before a corrected pass).
    virtual bool enqueueComponentSleepVerdicts(const struct PxgSolverBodySleepData* sleep, const PxNodeIndex* nodes, PxU32 count, CUstream solverStream) = 0;
    virtual const PxU8* publishComponentSleepVerdicts(PxU32& capacity) = 0; // waits for the pending readback, publishes it, returns it
    virtual const PxU8* componentSleepVerdicts(PxU32& capacity) = 0; // the published verdict; NULL when unavailable
    // Corrected pass: the CPU restores readiness for bodies that were active
    // before the trial, but bodies born in the trial keep the trial's post-solve
    // flags. Returns the published verdict with the trial's pending verdict
    // merged in for the given born node indices.
    virtual const PxU8* componentSleepVerdictsForCorrection(const PxU32* bornNodes, PxU32 bornCount, PxU32& capacity) = 0;
    // Half-step: CPU-owned per-node readiness (1 = not ready) reduced per device
    // component from this pass's pre-solve labels. Synchronous: uploads, reduces,
    // reads back and returns the per-node verdict (NULL when unavailable).
    virtual const PxU8* reduceCpuReadiness(const PxU8* hostNotReady, PxU32 count, bool speculative, CUstream stream, PxU32& capacity) = 0;
    // Device mirror of the readiness flag, per island sim, maintained by deltas
    // (node << 1 | ready). initReadinessMirror seeds it from a full CPU snapshot;
    // applyReadinessDeltas replays the tick's changes; reduceMirroredReadiness
    // reduces the mirror over the repair graph labels and returns the verdict;
    // readinessMirror reads the mirror back for audits (NULL when unavailable).
    virtual bool initReadinessMirror(const PxU8* hostNotReady, PxU32 count, bool speculative) = 0;
    virtual bool applyReadinessDeltas(const PxU32* deltas, PxU32 count, bool speculative) = 0;
    virtual const PxU8* reduceMirroredReadiness(bool speculative, PxU32& capacity) = 0;
    virtual const PxU8* readinessMirror(bool speculative, PxU32& capacity) = 0;
    // Island-scoped correction. requestTrialSnapshot makes the next
    // restoreRigidState keep a copy of the live (trial end-of-tick) state before
    // rewinding; reinstateTrialState copies that snapshot back for the listed
    // bodies once the affected set is known (after the correction bindings).
    virtual void requestTrialSnapshot(bool enabled) = 0;
    virtual bool reinstateTrialState(const PxU32* bodies, PxU32 count, PxgBodySim* live, PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations, CUstream coreStream, bool reinstateBodies, bool skipStressComponents) = 0;
    virtual bool restoreRigidState(PxgBodySim* bodies, PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations, PxU32 capacity, PxU64 generation, CUstream stream) = 0;
    /// Frozen corrected pass: gather the listed bodies back to the restored
    /// checkpoint (candidates that a new touch merged into an affected island).
    virtual bool markStressParkedComplement(const PxU32*,PxU32,PxU32,CUstream) { return false; }
    virtual bool restoreCheckpointBodies(const PxU32*, PxU32, PxgBodySim*, PxgBodySimVelocities*,
        PxgRigidBodyAcceleration*, CUstream) { return false; }
    virtual bool prepareFrame(bool postCorrection = false) = 0;
    // Merge the two evaluations into one tick receipt, after final ownership commit.
    virtual bool finishPostCorrection() = 0;
    // Flushes device work the runtime deferred past a scene stage (the eager refactor burst of a large
    // fracture, held until the corrected broad phase has run). No-op when nothing is deferred.
    virtual void flushDeferredWork() {}
    /// The correction this step required will not run: restore the accepted
    /// stress topology that a speculative update replaced (no-op otherwise).
    virtual void discardSpeculativeTopology() {}
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
    // Last solver phase snapshot is immutable until the next pre-solve build.
    virtual const PxvPreSolveNode* preSolveNodeView() const = 0;
    // Current registry may additionally contain post-solve GPU fragment births.
    virtual const PxvPreSolveNode* nativeNodeView() const = 0;
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
    virtual PxU32 reservedContactPairs() const = 0;
};
}
#if defined(_WIN32)
#define PX_DESTRUCTION_RUNTIME_EXPORT __declspec(dllexport)
#else
#define PX_DESTRUCTION_RUNTIME_EXPORT __attribute__((visibility("default")))
#endif
// Private producer ABI v16 adds destruction snapshot export/import.
// Version the symbol so mixed GPU/runtime binaries fail resolution rather than
// violating lifecycle ordering. Public scene ABI is intact.
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT physx::PxgDestructionRuntime*
PxCreateDestructionRuntimeV20(CUcontext context, void* scene, bool (*writeAllowed)(void*), physx::PxvDestructionBodyAllocator* allocator);

extern "C" PX_DESTRUCTION_RUNTIME_EXPORT bool
PxApplyDestructionSolverIslandMetadata(const physx::PxvIslandMetadataPage* pages,physx::PxU32 count,
    physx::PxU32* islandIds,physx::PxU32 nodes,physx::PxU32* staticTouches,physx::PxU32 islands,CUstream stream);
