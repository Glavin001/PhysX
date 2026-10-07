// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#ifndef PX_DESTRUCTION_SCENE_H
#define PX_DESTRUCTION_SCENE_H
#define PX_DESTRUCTION_SCENE_VERSION 24
// Feature (no layout change): enableChunkLoads with internalCorrectionLimit > 1.
// Every corrected pass that re-solves re-apportions each chunk's command to its
// owner, so destructible Vehicle2 cars work with the correction loop.
#define PX_DESTRUCTION_CHUNK_LOADS_CORRECTION_LOOP 1
// Feature (layout change, consumers rebuild with the SDK): PxDestructionStressDesc::
// sectionBending and ::bondSections (PxDestructionBondSection), opt-in bending
// and torsion from each bond's real cross-section; defaults keep the capped gain.
#define PX_DESTRUCTION_SECTION_BENDING 1
// Feature (no layout change): a chunk crushed under internalCorrectionLimit >= 1
// becomes a free body of its own (every bond it had breaks) instead of being
// removed from the topology, and the step completes through the ordinary split
// and corrected solve. Its accepted PxDestructionCrushState::crushed is set;
// debris vs dust (debrisMassFraction) is the consumer's to present.
#define PX_DESTRUCTION_CRUSH_CORRECTION 1
// Feature (layout change, consumers rebuild with the SDK): impact capacity
// (docs/destruction/IMPACT_CAPACITY_DESIGN.md "E"), opt-in with
// PxDestructionStressDesc::impactCapacity. Where the elastic solve has a bond
// past its fatal limit, the stage solves that island's tick as an impact of
// chunks joined by joints of finite capacity: whatever the joints cannot carry
// accelerates the chunks instead of reaching the anchors, brittle joints
// fracture as the tick's load builds, ductile ones
// (PxDestructionMaterial::ductileSlip) yield and break past their ultimate
// slip. PxDestructionMaterial::impactStiffness gives the joints' stiffness.
#define PX_DESTRUCTION_IMPACT_CAPACITY 1
#include "foundation/PxTransform.h"
#include "PxDirectGPUAPI.h"
#include "PxDestructionTopologyTypes.h"

namespace physx {

// Experimental native destruction API. internalCorrectionLimit>0 enables the
// rigid MVP: GPU stress/material/connectivity, persistent collision ownership,
// and up to that many internal full rigid resimulations per tick. Zero applies
// fracture verdicts without any resimulation, the cheapest setting.
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
    // Impact capacity (PX_DESTRUCTION_IMPACT_CAPACITY). ductileSlip: a joint
    // of this material at capacity yields and keeps carrying its capacity, and
    // breaks when its slip over a tick passes this (m); 0, brittle: it fractures
    // at capacity. impactStiffness: the stiffness (N/m) of a bond of this
    // material whose complianceScale is 1 -- the modulus that makes the stress
    // solve's weights stiffnesses (k = impactStiffness complianceScale^2 on
    // forces, times the solve's length scale squared on moments). Required
    // (positive) for every material when impactCapacity is on.
    PxReal ductileSlip=0, impactStiffness=0;
    // Impact-pressure crush (PxDestructionStressDesc::impactCrush): the
    // material's acoustic impedance rho c (Pa s/m). For an impactor whose own
    // structure gives way first (a vehicle's front), the effective impedance of
    // that crush (EN 1991-1-7 Annex C: v sqrt(k m) over the front's area, per
    // m/s). 0: unknown; a contact with an unknown side crushes nothing.
    PxReal impactImpedance=0;
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
// Extra convex/primitive hulls belong to one authored stress chunk. They do not
// add mass, stress nodes or bonds. Contacts on every hull load that same chunk.
struct PxDestructionStressShape {
    PxU32 chunk, contactIndex;
};
struct PxDestructionStressBond {
    PxU32 chunk0, chunk1;
    PxVec3 centroid, normal;
    PxReal area, health, complianceScale;
    PxU32 material=0;
};
// A bond's real cross-section (PX_DESTRUCTION_SECTION_BENDING, PxDestructionStressDesc::bondSections):
// the contact patch's elastic section moduli at the bond's authored area, in
// the same frame as the bond's normal. `axis` is a unit principal axis of the
// patch in the bond plane; the other is normal x axis.
//   bendModulus0  I/c for bending about `axis` (m^3): sigma = M_axis / S0
//   bendModulus1  I/c for bending about normal x axis (m^3)
//   twistModulus  I_p/r_max for twist about the normal (m^3): tau = T / Zt,
//                 the elastic interface (weld/fastener group) torsion stress
// A rectangle b (along axis) x h: S0 = b h^2/6, S1 = h b^2/6,
// Zt = b h (b^2 + h^2) / (6 sqrt(b^2 + h^2)). Zero moduli mean no shape data:
// the bond is treated as a square patch of its area.
struct PxDestructionBondSection {
    PxVec3 axis{1.0f,0.0f,0.0f};
    PxReal bendModulus0=0, bendModulus1=0, twistModulus=0;
};
struct PxDestructionStressCluster {
    PxRigidDynamicGPUIndex body;
    PxVec3 centerOfMass; // cluster-local COM for centrifugal loading
};
// World-space external force (N) and torque (N m) about this chunk's COM.
// These describe commands already submitted to the cluster's rigid body, not
// an additional application. Gravity belongs here only when actor gravity is
// disabled (as in Vehicle2). Contact/constraint impulses are separate inputs.
struct PxDestructionChunkLoad {
    PxVec3 force{0.0f}, torque{0.0f};
    // Ordinary actor force/impulse commands become velocity deltas before the
    // GPU solve. Describe those as world-space impulses (N s and N m s),
    // separately from the Direct GPU force accumulators above.
    PxVec3 impulse{0.0f}, angularImpulse{0.0f};
};
class PxConstraint;
// A world-attached constraint applies its actual solved wrench to one chunk.
// The constraint must outlive this registration. Fracture is supported only
// for explicitly declared fixed world rows and a required carrier chunk.
struct PxDestructionStressConstraint {
    PxConstraint* constraint;
    PxU32 chunk;
    // Vehicle2's shader reports about the actor COM (zero body0WorldOffset).
    // Standard joints instead report about their actor-0 constraint frame.
    // That origin must be declared explicitly in the immutable actor frame.
    bool torqueAboutBodyCOM = true;
    PxVec3 torqueOrigin{0.0f};
    // Opt-in for Vehicle2-style CPU shaders whose world Jacobians and errors
    // are immutable for the entire simulate(), including its corrected solve.
    // They report torque about COM, use zero anchor offsets and no body1.
    // Both chunks must remain connected for this constraint to remain active.
    bool replayWorldRows = false;
    PxU32 carrierChunk = ~PxU32(0);
};
struct PxDestructionStressDesc {
    const PxDestructionStressChunk* chunks = NULL;
    const PxDestructionStressBond* bonds = NULL;
    const PxDestructionStressCluster* clusters = NULL;
    PxU32 chunkCount = 0, bondCount = 0, clusterCount = 0;
    PxU32 maxIterations = 25; // stress iterations, independent of physics resimulation count
    PxReal tolerance = 0.001f;
    // Force convergence (v24). Zero (the default) keeps the residual test
    // alone. Positive: a component also converges when its last
    // preconditioned step changed the bond forces by at most this fraction of
    // their size. The residual test weights force errors by the stiffest
    // bonds, so on stiff, mass-contrasted structures it reports solves whose
    // forces are within this fraction as far from tolerance; 1e-3 leaves at
    // most ~0.4% force error (measured on captured vehicle solves).
    PxReal forceTolerance = 0.0f;
    bool warmStart = true;
    const PxDestructionMaterial* materials = NULL;
    PxU32 materialCount = 0; // zero preserves stress-only operation
    PxReal damageRate = 2.0f, bendGainMax = 3.0f;
    bool fibreBending = true;
    // Bending and torsion stress from each bond's real cross-section
    // (PX_DESTRUCTION_SECTION_BENDING).
    // false (default): bend = M/A * min(6/sqrt(A), bendGainMax), twist likewise
    // with 4.81/sqrt(A) -- below A = 4 m^2 that is a 2 m deep section for every
    // bond. true: sigma = |M0|/S0 + |M1|/S1 (the corner fibre under biaxial
    // bending) and tau = |T|/Zt from bondSections, with no gain cap; the moment
    // is taken about the bond's centroid (the solver reports it about the
    // chunks' midpoint), and the moduli shrink with the bond's remaining area.
    // Bonds without a section (NULL array or zero moduli) use the square patch
    // of their remaining area: 6/sqrt(A) for bending, 3 sqrt(2)/sqrt(A) twist.
    bool sectionBending = false;
    const PxDestructionBondSection* bondSections = NULL; // bondCount entries, or NULL
    // Optional full mass properties enable native candidate cluster creation.
    // Initial cluster bindings must match the bond graph's connected components.
    const PxDestructionChunkMassProperties* chunkMassProperties = NULL;
    // Internal rigid correction budget per tick, a cost/realism dial.
    // 0: no corrections. One solve, one stress evaluation; verdicts split
    //    bodies without re-solving. Cheapest; impulses cross no fresh cut.
    // 1: one intact trial plus one full corrected solve after rewinding to the
    //    start of the tick. An impact breaks one bond layer per tick.
    // N: up to N corrected solves; each evaluation that still changes membership
    //    rewinds and re-solves, so an impact can break N layers deep within one
    //    tick. Exits at the first evaluation that changes nothing and is bounded
    //    by the bond count (accepted topology only shrinks). Every extra pass is
    //    a full collide+solve of the scene on fracturing frames only; frames
    //    without fracture cost the same at any limit. At least 1 for realism.
    // Current support: rigid scenes with CPU-authored kinematic targets and
    // constraints on bodies the stage does not own (a door hinge). A constraint
    // on a cluster parent or fragment is supported only when registered in
    // `constraints` as a managed world constraint (replayWorldRows with a
    // carrierChunk, e.g. Vehicle2 suspension rows); it follows its carrier
    // chunk on every corrected pass and is disabled once its chunk leaves the
    // carrier. Any other such constraint blocks correction
    // (eCONSTRAINT_ON_DESTRUCTION_BODY). No articulations, CCD, custom filter
    // callbacks or deformables. A crushed chunk splits off as its own body
    // (PX_DESTRUCTION_CRUSH_CORRECTION); unapportioned force commands on
    // fractured sources reject explicitly.
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
    bool gpuIslandRepair = true;
    // Depenetration velocity cap installed on every free fragment the stage
    // creates (metres per second; zero inherits the parent's clamp, which is
    // PhysX's unbounded default). Supported remnants keep the parent's value,
    // so projectile-versus-structure trial impulses -- the loads that decide
    // fracture -- are unchanged; only detached debris is capped. Bounded
    // push-out is what lets a deeply interpenetrating debris stack (fast
    // debris tunnels thin decks and lands inside other pieces) resolve
    // monotonically instead of settling into a PGS fixed point or a two-step
    // cycle that never sleeps.
    PxReal fragmentMaxDepenetrationVelocity = 0.0f;
    // Free fragments normally inherit every physical setting of the body they
    // split from, including PxActorFlag::eDISABLE_GRAVITY. A source that is
    // weightless because something else integrates its gravity -- a Vehicle2
    // carrier -- then sheds weightless debris. When set, free fragments get
    // ordinary scene gravity; supported remnants, and the source's own body
    // (re-installed by a corrected split), keep the inherited flag. With
    // enableChunkLoads, a fragment re-solved on its split tick receives its
    // share of the commands, which already carry its weight for that tick:
    // its scene gravity starts when that tick completes.
    bool fragmentGravity = false;
    // Contact-graph storage (pairs, island nodes, retained slots) allocated at
    // configure time. Grown on demand instead, the first large split waits for
    // all in-flight GPU work and reallocates at its busiest moment (78 ms
    // measured on a meteor strike); zero keeps growing on demand.
    PxU32 reservedContactPairs = 0;
    // Primary hulls remain in chunks[].contactIndex. Additional identities must
    // be unique across both lists and use the same cluster-local actor frame.
    const PxDestructionStressShape* additionalShapes = NULL;
    PxU32 additionalShapeCount = 0;
    // Enables per-step apportioned command inputs. Their aggregate must match
    // the native pre-solve acceleration accumulators; mismatches reject the
    // step. A corrected split reapplies each command only to its owning piece,
    // on every corrected pass that re-solves: with internalCorrectionLimit N,
    // pass p < N reapplies each chunk's command exactly once to the body that
    // owns the chunk after that pass's split, and audits it (status 16384).
    // The split at the limit is applied at end-of-tick motion, without another
    // solve, and reapplies nothing. Requires material state and a limit >= 1.
    bool enableChunkLoads = false;
    const PxDestructionStressConstraint* constraints = NULL;
    PxU32 constraintCount = 0;
    // Impact capacity (PX_DESTRUCTION_IMPACT_CAPACITY), opt-in. Requires
    // materials with impactStiffness, fibreBending, bendGainMax > 0 and the
    // capped-gain bending (sectionBending false). Off: the stage is unchanged.
    // On: islands with no bond past capacity are unchanged bit for bit.
    bool impactCapacity = false;
    // Impact-pressure crush ("Ci", PX_DESTRUCTION_IMPACT_CAPACITY), opt-in.
    // A crushable chunk's crush law is evaluated at the 1-D elastic impact
    // stress of each destructible contact, Z1 Z2 / (Z1 + Z2) v_n (v_n the
    // closing speed at the start of the tick; Z the materials'
    // impactImpedance, or a body's setImpactorImpedance), as a uniaxial
    // compression, instead of at the virial of the solve's forces. A chunk
    // crushed so leaves the impact-capacity solve. Requires internalCorrectionLimit >= 1.
    bool impactCrush = false;
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
                 // 4096: native stress did not converge within this timestep;
                 //       material/topology transactions are rejected. Diagnostic
                 //       mode (internalCorrectionLimit=0) reports converged only.
                 // 8192: GPU contact lifetime space exhausted (scene cannot continue)
                 // 16384: chunk commands do not match rigid-body commands

    PxU32 normalContacts, frictionAnchors;
    PxU32 iterations, converged;
    PxU32 bondCommands, brokenBonds, crushedChunks;
    PxU32 correctionPasses; // corrected physics solves this tick, <= internalCorrectionLimit
    PxU32 stressPasses; // 1 + correctionPasses: the trial evaluation plus one per corrected solve
    PxU32 postCorrectionBrokenBonds; // subset of brokenBonds from evaluations after the first
    // Why the scene could not run a correction this step, as
    // PxDestructionCorrectionBlocker bits; zero when correction was permitted.
    // Set whenever error bit 8 is, and also on steps that needed no correction,
    // so a consumer can check its scene before the first fracture.
    PxU32 correctionBlockers;
};
// Why a stress component's last solve stopped (getStressSolveReport).
struct PxDestructionStressStopReason {
    enum Enum {
        eUNREPORTED = 0,    // not visited by the component solve
        eCONVERGED = 1,     // residual within tolerance
        eITERATION_CAP = 2, // still improving when the iteration cap was reached
        eSTAGNATED = 3,     // best residual did not improve 1% in 512 iterations
        eDEGENERATE = 4,    // search direction lost energy
        eFAILED = 5,        // preconditioner breakdown (non-positive or non-finite)
        eSETTLED = 6,       // skipped: settled and unchanged since a verified solve
        eNOT_READY = 7,     // the native hierarchy was not ready
        eCOOPERATIVE = 8    // solved by the large-component path; no per-component record
    };
};
struct PxDestructionStressComponentReport {
    PxU32 component;     // minimum dynamic chunk index
    PxU32 chunkCount;
    PxU32 anchored;      // nonzero: touches a static chunk
    PxU32 reason;        // PxDestructionStressStopReason
    PxU32 iterations;
    PxU32 bestIteration;
    PxReal tolerance2, best2, final2;
    PxReal history[16];  // residual^2 at iteration 0 and 2^k (k = 0..14); NaN where not reached
};
// Scene state that the native rigid correction cannot yet roll back. Any bit
// set makes the stage refuse a fracture step with status error 8.
struct PxDestructionCorrectionBlocker {
    enum Enum {
        eCCD = 1,                              // PxSceneFlag::eENABLE_CCD
        eDIRECT_GPU_SLEEPING = 2,              // PxSceneFlag::eENABLE_DIRECT_GPU_SLEEPING
        eARTICULATION = 4,                     // any articulation in the scene
        eCONSTRAINT_ON_DESTRUCTION_BODY = 8,   // a PxConstraint attached to a cluster parent or fragment
        eFILTER_CALLBACK = 16,                 // a custom PxSimulationFilterCallback
        eDEFORMABLE = 32,                      // deformable surfaces or volumes
        ePARTICLE_SYSTEM = 64,
        eSPECULATIVE_CCD_BODY = 128,           // a rigid body with eENABLE_SPECULATIVE_CCD
        eDIRECT_GPU_KINEMATIC_TARGET = 256     // Direct GPU kinematic targets are not captured
    };
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
    // Valid only after successful fetchResults; readyEvent orders all rows.
    // First frame is a full snapshot; later frames contain only committed
    // changes from BOTH fracture evaluations. Consume every tick or request a
    // full acceptedTopology observation after a missed tick. Clear invalidates.
    PxDestructionCommittedChangesView committedChanges{};
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
    // Outside simulation, after configureStress with enableChunkLoads. Exactly
    // chunkCount entries, including zero entries. Consumed for one complete
    // timestep including its correction; omission next step means zero loads.
    // Does not call addForce/addTorque. Forces remain ordinary PhysX commands.
    virtual bool setChunkLoads(const PxDestructionChunkLoad* loads, PxU32 count) = 0;
    // Version 23, diagnostics: the stress solve report. Enabled, every later
    // solve records for each stress component why it stopped and its residual
    // history, and for each chunk its share of its component's remaining
    // residual. Off by default (one store per chunk per iteration while on).
    // `passes` selects which solves of a step record (bit p: correction pass
    // p, bit 0 the trial solve that decides what breaks; bit 31 also covers
    // later passes); the last selected pass of a step is what is read. 0: off.
    virtual bool setStressSolveReport(PxU32 passes) = 0;
    // Outside simulation. Up to `capacity` component records; `count` is how
    // many exist. `chunkResidual2` / `chunkComponent` (optional, chunkCapacity
    // >= chunkCount): each chunk's share of its component's final residual
    // and its component id (minimum dynamic chunk index; PX_INVALID_U32 for
    // static or isolated chunks). Residuals are the solver's squared
    // convergence norm; a component converged when final2 <= tolerance2.
    // `chunkInputs` (optional, 3*chunkCapacity): each chunk's stress input
    // (the nodeAccelerations the solve consumed) after each source in turn --
    // [0,n) prepared loads (gravity, rotation, chunk loads), [n,2n) plus
    // constraint loads, [2n,3n) plus contact loads -- so differences attribute
    // the load to its source.
    virtual bool getStressSolveReport(PxDestructionStressComponentReport* components, PxU32 capacity, PxU32& count,
        PxReal* chunkResidual2, PxU32* chunkComponent, PxU32 chunkCapacity, PxDestructionVectorPair* chunkInputs) = 0;
protected:
    // Impact-pressure crush: the acoustic impedance (Pa s/m) of bodies that are
    // not destructible chunks (a cannonball, a meteor), by GPU index; replaces
    // the whole table. 0 or absent: unknown.
    virtual bool setImpactorImpedance(const PxRigidDynamicGPUIndex* bodies, const PxReal* impedances, PxU32 count)
    { (void)bodies; (void)impedances; (void)count; return false; }
    virtual ~PxDestructionScene() {}
};
}
#endif
