// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#ifndef PX_DESTRUCTION_SCENE_H
#define PX_DESTRUCTION_SCENE_H
#define PX_DESTRUCTION_SCENE_VERSION 14
#include "foundation/PxTransform.h"
#include "PxDirectGPUAPI.h"
#include "PxDestructionTopologyTypes.h"

namespace physx {

// Experimental native destruction API. internalCorrectionLimit=1 enables the
// rigid MVP: GPU stress/material/connectivity, persistent collision ownership,
// and one internal full rigid resimulation. Zero retains diagnostic preparation.
// Configure only outside simulation. Geometry stays persistent through splits;
// private fragment bodies are scene-owned and destroyed by clear/reconfiguration.
// Resolved at configuration; negative tension/shear limits inherit compression.
struct PxDestructionCrushProperties {
    PxReal capPressure=0, cohesion=0, frictionSlope=0;
    PxReal crushEnergy=1, crushViscosity=1, strainRateExponent=0, referenceStrainRate=1;
    PxReal debrisMassFraction=0;
    PxU32 debrisFragmentCount=0;
};
struct PxDestructionMaterial {
    PxReal compressionElasticLimit=1, compressionFatalLimit=2;
    PxReal tensionElasticLimit=-1, tensionFatalLimit=-1;
    PxReal shearElasticLimit=-1, shearFatalLimit=-1;
    PxReal residualAreaFraction=0;
    PxDestructionCrushProperties crush;
};
struct PxDestructionBondVerdict {
    PxReal health, damage, stressNormal, stressShear, stressBend;
    PxU32 command, broken;
};
struct PxDestructionCrushState {
    PxReal damage, pressure, deviator, utilisation;
    PxU32 crushed;
};
struct PxDestructionStressChunk {
    PxVec3 position; // immutable cluster-local stress frame
    PxReal mass;    // zero denotes an authored support node
    PxReal inertia;
    PxU32 cluster;
    PxU32 contactIndex; // transform-cache identity, NOT PxShape::getGPUIndex()
    PxReal volume=0;
    PxU32 material=0;
};
struct PxDestructionStressBond {
    PxU32 chunk0, chunk1;
    PxVec3 centroid, normal;
    PxReal area, health, complianceScale;
    PxU32 material=0;
};
struct PxDestructionStressCluster {
    PxRigidDynamicGPUIndex body;
    PxVec3 centerOfMass; // cluster-local COM for centrifugal loading
};
struct PxDestructionStressDesc {
    const PxDestructionStressChunk* chunks = NULL;
    const PxDestructionStressBond* bonds = NULL;
    const PxDestructionStressCluster* clusters = NULL;
    PxU32 chunkCount = 0, bondCount = 0, clusterCount = 0;
    PxU32 maxIterations = 25; // stress iterations, independent of physics resimulation count
    PxReal tolerance = 0.001f;
    bool warmStart = true;
    const PxDestructionMaterial* materials = NULL;
    PxU32 materialCount = 0; // zero preserves stress-only operation
    PxReal damageRate = 2.0f, bendGainMax = 3.0f;
    bool fibreBending = true;
    // Optional full mass properties enable native candidate cluster creation.
    // Initial cluster bindings must match the bond graph's connected components.
    const PxDestructionChunkMassProperties* chunkMassProperties = NULL;
    // Experimental internal rigid correction. 0 retains diagnostic preparation;
    // 1 permits one intact trial plus one full supported-scene corrected solve.
    // Current support: rigid scenes with CPU-authored kinematic targets, no joints,
    // articulations, CCD, custom filter callbacks or deformables. Crushing/removal
    // and unapportioned force commands on fractured sources reject explicitly.
    // Native sleeping is supported with ordinary CPU actor access (Direct GPU
    // mode disabled); Direct GPU sleeping plus correction remains unsupported.
    PxU32 internalCorrectionLimit = 0;
    // Experimental pair-lifecycle reuse during the full rigid correction.
    // Retain unchanged owners' pair registrations, clear GPU manifold/friction
    // caches and regenerate collision/constraint data. False is the reference.
    bool preserveUnchangedContactPairs = false;
    // Use CUDA contact components for rigid island repair, including ordinary
    // sleeping scenes. Native sleep scheduling still needs its membership mirror.
    // Unsupported graph state retains the original traversal; false is the reference.
    bool gpuIslandRepair = false;
};
struct PxDestructionVectorPair {
    PxVec3 angular, linear;
    PX_CUDA_CALLABLE PxDestructionVectorPair() : angular(0.0f), linear(0.0f) {}
};
struct PxDestructionSurfaceLoad {
    PxVec3 force, torque;
    PxReal virial[6]; // xx, yy, zz, xy, xz, yz; same convention as Blast
    PX_CUDA_CALLABLE PxDestructionSurfaceLoad() : force(0.0f), torque(0.0f), virial{} {}
};
struct PxDestructionStageStatus {
    PxU64 frame;
    PxU32 error; // 1: contacts, 2: nonfinite, 4: runtime, 8: correction required,
                 // 16: unsupported articulation strain-rate input, 32: topology transaction,
                 // 64: resident stress topology update, 128: solver-body preparation,
                 // 256: native body allocation, 512: native GPU body initialization,
                 // 1024: persistent collision binding preparation; 2048: correction body preparation
                 // 4096: unconverged stress solve in enabled native correction mode
                 // 8192: GPU contact lifetime space exhausted (scene cannot continue)

    PxU32 normalContacts, frictionAnchors;
    PxU32 iterations, converged;
    PxU32 bondCommands, brokenBonds, crushedChunks;
    PxU32 correctionPasses;
    PxU32 stressPasses; // one trial evaluation plus one after corrected physics
    PxU32 postCorrectionBrokenBonds; // subset of brokenBonds from the second evaluation
};
struct PxDestructionStressTopologyStatus {
    PxU64 generation, solvedGeneration, rebuilds;
    PxU32 initialized, error, islandCount, activeBondCount, activeNodeCount;
};
struct PxDestructionDeviceView {
    const PxDestructionVectorPair* nodeAccelerations = NULL;
    const PxDestructionVectorPair* bondForces = NULL; // last trial solve; see stressTopology->solvedGeneration
    const PxDestructionSurfaceLoad* surfaceLoads = NULL;
    const PxDestructionStageStatus* status = NULL;
    const PxReal* bondHealth = NULL; // accepted material state
    const PxDestructionCrushState* chunkCrush = NULL;
    const PxDestructionBondVerdict* bondVerdicts = NULL; // trial decisions
    const PxDestructionCrushState* trialChunkCrush = NULL;
    const PxReal* strainRates = NULL;
    // Candidate arrays require topologyTransaction->prepared. These describe
    // topology/motion candidates. Cuts preserving every chunk's motion owner
    // commit directly; supported splits commit after the enabled internal resim.
    // Accepted motion is initialized by the first successful native step.
    PxDestructionTopologyDeviceView acceptedTopology{};
    PxDestructionTopologyDeviceView trialTopology{};
    const PxDestructionTopologyTransactionStatus* topologyTransaction = NULL;
    // Generated from this step's candidate topology, before any commit. Valid
    // only when bodyPreparation->valid; generation/count identify the batch.
    // No solver-body slots or collision ownership are changed by preparation.
    const PxDestructionClusterBodyState* trialBodies = NULL;
    const PxDestructionBodyPreparationStatus* bodyPreparation = NULL;
    // Reserved native nodes in candidate cluster order. Only use with valid
    // bodyAllocation; initialized == reserved permits physical GPU reads of
    // new slots. With diagnostic correction limit zero, these stay provisional.
    // Enabled correction restores inputs and makes accepted fragments scene-owned.
    const PxU32* trialBodyIndices = NULL;
    const PxDestructionBodyAllocationStatus* bodyAllocation = NULL;
    // GPU allocation state and the immutable native-index capacity grant. Only
    // committed entries are accepted motion owners. Pending entries are private;
    // entries beyond committed + pending have no body. Reacquire after advance
    // or capacity growth; clear invalidates this view.
    const PxDestructionMotionSlotStatus* motionSlots = NULL;
    const PxU32* motionSlotIndices = NULL;
    // GPU-prepared persistent shape edits for affected source clusters, in
    // authored chunk order. Only usable when collisionPreparation->valid;
    // preparation does not change collision, query or actor ownership.
    const PxDestructionCollisionBinding* trialCollisionBindings = NULL;
    const PxDestructionCollisionPreparationStatus* collisionPreparation = NULL;
    const PxDestructionCorrectionBody* correctionBodies = NULL;
    const PxDestructionCorrectionPreparationStatus* correctionPreparation = NULL;
    const PxDestructionStressTopologyStatus* stressTopology = NULL;
    const PxU32* stressNodeIslands = NULL; // minimum dynamic-node labels; support/isolated = invalid
    const PxU32* stressBondIslands = NULL;
    PxU32 chunkCount = 0, bondCount = 0;
    CUevent readyEvent = NULL;
};

// Without internal correction, membership-changing verdicts return error bit 8.
// With limit 1, supported splits are applied internally and the complete rigid
// scene is restored/resolved once before topology, material and motion acceptance.
// Unsupported correction returns an incomplete step; it must not be treated as
// accepted gameplay output. Cycle cuts preserving every owner commit directly.
// Scene-owned. The native task graph advances the GPU stage once per ordinary
// timestep; consumers never call a separate solve or replay function. CPU work
// includes asset setup, task submission, compatibility allocation and completion
// observation. Ordinary actor mode also maintains CPU poses, queries and sleep
// scheduling. Ownership transactions publish compact changed-cluster properties;
// contact loads, structural solving and mass calculations stay on the GPU.
class PxDestructionScene {
public:
    // Stable collision identity for an exclusive shape in this scene. Available
    // outside simulation without enabling the public Direct GPU API.
    virtual PxU32 getShapeContactIndex(const PxShape& shape) const = 0;
    // Optional device-to-device observation of ordinary or destruction bodies.
    // Call after a successful fetchResults. Uses current native GPU indices,
    // with the same index lifetime as PxRigidDynamic::getGPUIndex(). Neither
    // Direct GPU mode nor a CPU motion readback is required. The destination and
    // index buffers are caller-owned CUDA buffers; consumer completion must be
    // ordered before they are reused or the next simulation starts.
    virtual bool readRigidBodyData(void* data, const PxRigidDynamicGPUIndex* indices,
        PxRigidDynamicGPUAPIReadType::Enum type, PxU32 count,
        CUevent startEvent=NULL, CUevent finishEvent=NULL) const = 0;
    virtual bool configureStress(const PxDestructionStressDesc& desc) = 0;
    virtual bool clearStress() = 0;
    // Borrow until reconfiguration/scene release. Order device consumers before
    // the next simulate with setConsumerEvent; readyEvent orders observations.
    // Results are valid after the first completed step (status.frame > 0).
    virtual PxDestructionDeviceView getDeviceView() const = 0;
    virtual void setConsumerEvent(CUevent event) = 0;
    virtual PxDestructionStageStatus getLastStatus() const = 0;
protected:
    virtual ~PxDestructionScene() {}
};
}
#endif
