// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#ifndef PX_DESTRUCTION_SCENE_H
#define PX_DESTRUCTION_SCENE_H
#define PX_DESTRUCTION_SCENE_VERSION 2
#include "foundation/PxTransform.h"
#include "PxDirectGPUAPI.h"

namespace physx {

// Initial native stress-stage API. Collision ownership, fracture commit and
// internal resimulation are still being migrated; configuring this graph does
// not yet cause PhysX to split its actors. Existing geometry must remain alive
// and attached until the graph is cleared/reconfigured, outside simulation.
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
    PxU32 maxIterations = 25;
    PxReal tolerance = 0.001f;
    bool warmStart = true;
    const PxDestructionMaterial* materials = NULL;
    PxU32 materialCount = 0; // zero preserves stress-only operation
    PxReal damageRate = 2.0f, bendGainMax = 3.0f;
    bool fibreBending = true;
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
                 // 16: unsupported articulation strain-rate input

    PxU32 normalContacts, frictionAnchors;
    PxU32 iterations, converged;
    PxU32 bondCommands, brokenBonds, crushedChunks;
};
struct PxDestructionDeviceView {
    const PxDestructionVectorPair* nodeAccelerations = NULL;
    const PxDestructionVectorPair* bondForces = NULL;
    const PxDestructionSurfaceLoad* surfaceLoads = NULL;
    const PxDestructionStageStatus* status = NULL;
    const PxReal* bondHealth = NULL; // accepted material state
    const PxDestructionCrushState* chunkCrush = NULL;
    const PxDestructionBondVerdict* bondVerdicts = NULL; // trial decisions
    const PxDestructionCrushState* trialChunkCrush = NULL;
    const PxReal* strainRates = NULL;
    PxU32 chunkCount = 0, bondCount = 0;
    CUevent readyEvent = NULL;
};

// Material verdicts requiring topology correction currently return an incomplete
// step (error bit 8). Their trial state is observable; accepted material state is
// unchanged until native topology/motion correction is implemented. No fracture
// is silently committed while collision ownership still describes intact bodies.
// Scene-owned. The native task graph advances the GPU stage once per ordinary
// timestep; consumers never call a separate solve or replay function. CPU work
// is asset setup, task submission, allocation growth and a small completion/error
// observation. Graphs, contact loads and solved bond forces stay on the GPU.
class PxDestructionScene {
public:
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
