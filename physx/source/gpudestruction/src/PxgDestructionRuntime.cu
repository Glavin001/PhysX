#include <cstdlib>
// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include <chrono>
#include "PxgDestructionRuntime.h"
#include "PxgDestructionTopology.h"
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <cooperative_groups.h>
#include <cub/cub.cuh>
#include <cuda.h>
#include "PxgBodySim.h"
#include "PxgShapeSim.h"
#include "PxgContactManager.h"
#include "PxgDestructionContactGraph.cuh"
#include "PxgSolverIslandMetadata.cuh"
#include "PxgPreSolveIslands.cuh"
#include "PxShape.h"
#include "PxgConstraintWriteBack.h"
#include "PxsRigidBody.h"
#include "PxgDestructionBody.cuh"
#include "NvBlastExtStressMaterialFormula.h"
#include <set>
#include <algorithm>
#include <cstring>
#include <cmath>
#include <limits>
#include <stdexcept>
#include <vector>
#include <cstdio>
#include <type_traits>

namespace physx { namespace {
using namespace Nv::Blast;
static_assert(sizeof(PxDestructionVectorPair)==sizeof(ExtStressGpuImpulse), "stress vector ABI");
static_assert(sizeof(PxVec3)==sizeof(ExtStressGpuVec3), "stress vector ABI");
struct Context {
    explicit Context(CUcontext c) { if(cuCtxPushCurrent(c)!=CUDA_SUCCESS) throw std::runtime_error("destruction CUDA context"); }
    ~Context() { CUcontext previous; cuCtxPopCurrent(&previous); }
};
void check(cudaError_t e) { if(e!=cudaSuccess) throw std::runtime_error(cudaGetErrorString(e)); }
template<class T> void allocate(T*& p, size_t n) { check(cudaMalloc(&p, sizeof(T)*std::max<size_t>(n,1))); }
#include "PxgRigidIterationLimits.cuh"
#include "PxgDestructionImpact.cuh"
#include "PxgDestructionMaterial.cuh"
#include "PxgDestructionCommittedChanges.cuh"
#include "PxgDestructionShapePublication.cuh"
// Rebind compact runtime cluster slots entirely on device after acceptance.
__global__ void acceptClusterBindings(PxDestructionTopologyDeviceView topology,
    const PxU32* targets,PxDestructionStressCluster* clusters,const PxDestructionStageStatus* status) {
    if(status->error & ~8u)return;
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=topology.status->clusterCount)return;
    const auto mass=topology.clusters[topology.activeClusters[i]];
    clusters[i]={targets[i],PxVec3(float(mass.center[0]),float(mass.center[1]),float(mass.center[2]))};
}
__global__ void acceptChunkBindings(PxDestructionTopologyDeviceView topology,
    const PxU32* slots,PxDestructionStressChunk* chunks,const PxDestructionStageStatus* status,
    const PxU32* affected,PxU64* propertyEpochs) {
    if(status->error & ~8u)return;
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<topology.chunkCount && topology.activeChunks[i]) {
        const PxU32 oldCluster=chunks[i].cluster,root=topology.chunkCluster[i];
        chunks[i].cluster=slots[root];
        // One writer per surviving root, unioned across both fracture passes.
        // Epochs avoid clearing an observation bitmap on every idle tick.
        if(propertyEpochs && i==root && affected[oldCluster])propertyEpochs[root]=status->frame;
    }
}
__global__ void observeNativeClusters(const PxDestructionStressCluster* clusters,PxU32 count,
    const PxgBodySim* bodies,PxTransform* poses,PxVec3* angular,const PxDestructionStageStatus* status=nullptr) {
    if(status && (status->error & ~8u))return;
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto b=bodies[clusters[i].body];poses[i]=b.body2World.getTransform()*b.body2Actor_maxImpulseW.getTransform().getInverse();
    angular[i]=PxVec3(b.angularVelocityXYZ_maxPenBiasW.x,b.angularVelocityXYZ_maxPenBiasW.y,b.angularVelocityXYZ_maxPenBiasW.z);
}
__global__ void finishNativeCorrection(PxDestructionStageStatus* status) {status->error&=~8u;status->correctionPasses=1;}
// The descriptor's pair identities are persistent transform-cache/shape IDs.
// Geometry registration is resolved on device, independently of cluster motion.
__global__ void buildNativeContactInputs(PxgContactManagerInput* inputs,PxU32 count,
    const PxgShapeSim* shapes,PxU32 capacity) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    auto input=inputs[i];
    if(input.transformCacheRef0>=capacity || input.transformCacheRef1>=capacity) {
        // An internal identity invariant failed. Stop this CUDA context rather
        // than silently dropping a required pair or launching NP with bad IDs.
        asm volatile("trap;");return;
    }
    input.shapeRef0=shapes[input.transformCacheRef0].mHullDataIndex;
    input.shapeRef1=shapes[input.transformCacheRef1].mHullDataIndex;
    if(input.shapeRef0==PX_INVALID_U32 || input.shapeRef1==PX_INVALID_U32) {
        asm volatile("trap;");return;
    }
    inputs[i]=input;
}
struct Lookup { PxU32 contact, chunk; };
static_assert(sizeof(Lookup)==2*sizeof(PxU32),"Lookup is the anchored-contact view's uint2 map (PxgAnchoredContactBound.h)");
struct ConstraintLookup { PxU32 constraint, chunk, torqueAboutBodyCOM; PxVec3 torqueOrigin;
    PxU32 carrier,body,enabled; };
__global__ void prepareConstraintBindings(ConstraintLookup* map,PxU32 count,
    PxDestructionTopologyDeviceView trial,const PxU32* slots,const PxU32* bodies,
    PxvDestructionConstraintBinding* output) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    auto& c=map[i];
    const bool carrierAlive=trial.activeChunks[c.carrier]!=0;
    const PxU32 carrierRoot=carrierAlive?trial.chunkCluster[c.carrier]:PX_INVALID_U32;
    if(carrierAlive)c.body=bodies[slots[carrierRoot]];
    c.enabled=c.enabled && carrierAlive && trial.activeChunks[c.chunk]
        && trial.chunkCluster[c.chunk]==carrierRoot;
    output[i]={c.body,c.enabled};
}

__device__ PxU32 findChunk(const Lookup* map, PxU32 count, PxU32 contact) {
    PxU32 a=0,b=count;
    while(a<b) { PxU32 m=a+(b-a)/2; if(map[m].contact<contact)a=m+1;else b=m; }
    return a<count && map[a].contact==contact ? map[a].chunk : PX_INVALID_U32;
}
// Every pass starts from an empty per-pass status; only the trial advances
// the frame. Prior passes are merged back in by mergePostCorrectionStatus.
__global__ void startFrame(PxDestructionStageStatus* status,const PxgContactGraphSequence* sequence,bool correctedPass,
    PxU32* idleObservation=nullptr) {
    const PxU64 frame=status->frame+(correctedPass?0:1); *status={}; status->frame=frame;
    if(idleObservation)*idleObservation=0;
    if(sequence && sequence->error)status->error|=8192u;
}
// prior: host-accumulated sum of every earlier evaluation this frame.
// passes: corrected physics passes that ran; one more stress evaluation than that.
__global__ void mergePostCorrectionStatus(PxDestructionStageStatus* status,PxDestructionStageStatus prior,
    PxU32 passes,PxU32 firstPassBrokenBonds) {
    status->postCorrectionBrokenBonds=status->brokenBonds+prior.brokenBonds-firstPassBrokenBonds;
    status->normalContacts+=prior.normalContacts;status->frictionAnchors+=prior.frictionAnchors;
    status->iterations=max(status->iterations,prior.iterations);
    status->converged= status->converged && prior.converged;
    status->bondCommands+=prior.bondCommands;status->brokenBonds+=prior.brokenBonds;
    status->crushedChunks+=prior.crushedChunks;status->error|=prior.error;
    status->impactIslands+=prior.impactIslands;status->impactSolves+=prior.impactSolves;status->impactSteps+=prior.impactSteps;
    status->impactCapped+=prior.impactCapped;status->impactCappedFallback+=prior.impactCappedFallback;status->impactHeldOverCapacity+=prior.impactHeldOverCapacity;status->anchoredGhosts+=prior.anchoredGhosts;status->crushEnergyCreated+=prior.crushEnergyCreated;status->impactDiverged+=prior.impactDiverged;status->impactInfeasible+=prior.impactInfeasible;
    if(!status->impactWorstBond)status->impactWorstBond=prior.impactWorstBond;
    status->impactLongestDispatchMs=fmaxf(status->impactLongestDispatchMs,prior.impactLongestDispatchMs);
    status->correctionPasses=passes;status->stressPasses=passes+1;
}
__global__ void prepareNativeCorrectionAcceptance(PxDestructionStageStatus* status,
    const PxgContactGraphSequence* sequence,PxU32* accept) {
    if(sequence && sequence->error)status->error|=8192u;
    *accept=!(status->error & ~8u);
}
__global__ void prepareLoads(const PxDestructionStressChunk* chunks, PxU32 n,
    const PxDestructionStressCluster* clusters, const PxTransform* poses,
    const PxVec3* angular, PxVec3 gravity, PxDestructionVectorPair* inputs,
    PxDestructionSurfaceLoad* surfaces, float* rates,
    const PxDestructionChunkLoad* loads,const PxgBodySim* bodies,PxReal inverseDt) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=n)return;
    surfaces[i]={}; inputs[i]={};if(rates)rates[i]=0;
    const auto c=chunks[i]; if(c.mass<=0)return;
    const auto pose=poses[c.cluster];
    const PxVec3 w=pose.q.rotateInv(angular[c.cluster]);
    // The reference uses acceleration as the stress solver's velocity input,
    // so its output is interpreted as force. Angular solver input remains zero;
    // actual contact torque and external virial are retained separately below.
    const PxVec3 r=c.position-clusters[c.cluster].centerOfMass;
    const PxVec3 acceleration=(loads && bodies[clusters[c.cluster].body].disableGravity)?PxVec3(0):gravity;
    inputs[i].linear=pose.q.rotateInv(acceleration)-w.cross(w.cross(r));
    if(loads) {
        const auto load=loads[i];
        surfaces[i].force=pose.q.rotateInv(load.force+load.impulse*inverseDt);surfaces[i].torque=pose.q.rotateInv(load.torque+load.angularImpulse*inverseDt);
        inputs[i].linear+=surfaces[i].force/c.mass;
        // Blast stores angular coordinates with the opposite handed sign:
        // its rigid null mode is linear = r cross angular.
        inputs[i].angular=-surfaces[i].torque/c.inertia;
    }
}
// One pair's contact loads on one of its chunks, summed in registers and
// published with a single set of atomics per pair instead of per contact
// point: routed contacts share chunks (a pile bears on the chunk below it),
// and fifteen float atomics per point per side serialized on those rows.
// Float addition order was already nondeterministic across pairs; only the
// grouping within a pair changes.
struct ContactLoadSum {
    PxVec3 force{0.0f},torque{0.0f};float virial[6]={};
    __device__ void add(const PxDestructionStressChunk& c,const PxTransform& pose,
        const PxVec3& point,const PxVec3& impulse,float invDt) {
        const PxVec3 f=pose.q.rotateInv(impulse)*invDt;
        const PxVec3 r=pose.transformInv(point)-c.position;
        force+=f;torque+=r.cross(f);
        virial[0]+=r.x*f.x;virial[1]+=r.y*f.y;virial[2]+=r.z*f.z;
        virial[3]+=0.5f*(r.x*f.y+r.y*f.x);
        virial[4]+=0.5f*(r.x*f.z+r.z*f.x);
        virial[5]+=0.5f*(r.y*f.z+r.z*f.y);
    }
    __device__ void publish(PxU32 i,const PxDestructionStressChunk& c,
        PxDestructionVectorPair* inputs,PxDestructionSurfaceLoad* surface) const {
        add3(surface[i].force,force);add3(surface[i].torque,torque);
        float* v=surface[i].virial;for(PxU32 k=0;k<6;++k)atomicAdd(v+k,virial[k]);
        if(c.mass>0)add3(inputs[i].linear,force/c.mass);
    }
    __device__ static void add3(PxVec3& target,const PxVec3& value) {
        atomicAdd(&target.x,value.x); atomicAdd(&target.y,value.y); atomicAdd(&target.z,value.z);
    }
};
// Consume native device writeback in this pass, with no CPU force readback.
__global__ void routeConstraintLoads(const ConstraintLookup* map,PxU32 count,
    const PxgConstraintWriteback* solved,PxU32 capacity,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    const PxTransform* poses,const PxgBodySim* bodies,PxReal inverseDt,
    PxDestructionVectorPair* inputs,PxDestructionSurfaceLoad* surfaces,PxDestructionStageStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto binding=map[i];if(!binding.enabled)return;
    if(!solved || binding.constraint>=capacity) {atomicOr(&status->error,32768u);return;}
    const auto writeback=solved[binding.constraint];
    const PxVec3 impulse(writeback.linearImpulse_broken.x,writeback.linearImpulse_broken.y,writeback.linearImpulse_broken.z);
    const PxVec3 angular(writeback.angularImpulse.x,writeback.angularImpulse.y,writeback.angularImpulse.z);
    if(!impulse.isFinite() || !angular.isFinite()) {atomicOr(&status->error,32768u);return;}
    const auto chunk=chunks[binding.chunk];const auto pose=poses[chunk.cluster];
    const auto body=bodies[clusters[chunk.cluster].body];
    const PxVec3 center(body.body2World.p.x,body.body2World.p.y,body.body2World.p.z);
    const PxVec3 force=pose.q.rotateInv(impulse)*inverseDt;
    const PxVec3 origin=binding.torqueAboutBodyCOM?center:pose.transform(binding.torqueOrigin);
    const PxVec3 torque=pose.q.rotateInv(angular+(origin-pose.transform(chunk.position)).cross(impulse))*inverseDt;
    ContactLoadSum::add3(surfaces[binding.chunk].force,force);
    ContactLoadSum::add3(surfaces[binding.chunk].torque,torque);
    if(chunk.mass>0) {
        ContactLoadSum::add3(inputs[binding.chunk].linear,force/chunk.mass);
        ContactLoadSum::add3(inputs[binding.chunk].angular,-torque/chunk.inertia);
    }
}
__device__ PxVec3 bodyPointVelocity(PxNodeIndex index,const PxgBodySim* bodies,const PxVec3& point)
{
    if(index.isStaticBody())return PxVec3(0);
    const auto b=bodies[index.index()];
    const PxVec3 linear(b.linearVelocityXYZ_inverseMassW.x,b.linearVelocityXYZ_inverseMassW.y,b.linearVelocityXYZ_inverseMassW.z);
    const PxVec3 angular(b.angularVelocityXYZ_maxPenBiasW.x,b.angularVelocityXYZ_maxPenBiasW.y,b.angularVelocityXYZ_maxPenBiasW.z);
    const PxVec3 center(b.body2World.p.x,b.body2World.p.y,b.body2World.p.z);
    return linear+angular.cross(point-center);
}
__device__ void contactRate(PxU32 a,PxU32 b,const PxGpuContactPair& pair,const PxVec3& point,const PxVec3& impulse,
    const PxgBodySim* bodies,const PxDestructionStressChunk* chunks,const PxDestructionMaterial* materials,
    float* rates,PxDestructionStageStatus* status)
{
    if(!rates || impulse.isZero())return;
    const bool ca=a!=PX_INVALID_U32 && materials[chunks[a].material].crush.capPressure>0;
    const bool cb=b!=PX_INVALID_U32 && materials[chunks[b].material].crush.capPressure>0;
    if(!ca && !cb)return;
    if(pair.nodeIndex0.isArticulation() || pair.nodeIndex1.isArticulation()) {atomicOr(&status->error,16u);return;}
    const PxVec3 relative=bodyPointVelocity(pair.nodeIndex1,bodies,point)-bodyPointVelocity(pair.nodeIndex0,bodies,point);
    const float closing=relative.dot(impulse/impulse.magnitude());
    if(closing>0) {
        if(ca && chunks[a].volume>0)atomicMax(reinterpret_cast<unsigned*>(rates+a),__float_as_uint(closing/cbrtf(chunks[a].volume)));
        if(cb && chunks[b].volume>0)atomicMax(reinterpret_cast<unsigned*>(rates+b),__float_as_uint(closing/cbrtf(chunks[b].volume)));
    }
}
// Impact-pressure crush (Ci): the impact stress Z1 Z2 / (Z1 + Z2) v_n of each
// normal contact on a crushable chunk, at the closing speed of the start of
// the tick (the rigid checkpoint; the solve has already stopped the impactor).
struct ImpactorImpedance { PxU32 body; float impedance; };
struct ImpactContact {
    const ImpactorImpedance* impactors; PxU32 impactorCount;
    const PxgBodySim* before; PxU32 beforeCount;
    float *stress,*rate;
    PxU32* impactor; // per chunk: the impactor-table row of the body that struck it hardest (or invalid)
    PxU32* striker;  // per chunk: that body's index, any dynamic body (PX_DESTRUCTION_CRUSH_ENERGY_BOUND), or invalid
    // The impact solve's coupled contact: a row per (pair, struck chunk of an
    // anchored -- kinematic -- cluster) whose other body is movable.
    impact::ContactRow* rows; PxU32* rowCount; PxU32 rowCapacity;
    float separating; // m/s: only a pair closing faster than this along its push is coupled (an impact)
    const PxDestructionStressCluster* clusters;
    // The contact routing (impact::Settings::route): |g|, so a pair that is not
    // closing but loads the structure past what its body can exchange is a row.
    bool route; float gravity;
    // The anchored-chunk contact bound (PX_DESTRUCTION_ANCHORED_CONTACT_BOUND):
    // each chunk's {capacity * dt, mass} as the rigid solver's contact prep read
    // it, and per chunk a flag: a contact on it was cut at that bound this pass.
    PxgAnchoredContactBoundView anchored; PxU32* saturated;
};
// One side of a pair as a coupled-contact row (impact::ContactRow): the struck
// chunk `chunk` (its cluster kinematic), the other body `other` dynamic. Sums
// the pair's normal and friction impulses on the chunk; frames: the struck
// cluster's (the chunk's own coordinates).
__device__ void coupleRow(PxU32 chunk,PxNodeIndex own,PxNodeIndex other,float side,const PxGpuContactPair& p,
    const PxDestructionStressChunk* chunks,const PxTransform* poses,const PxgBodySim* bodies,float invDt,const ImpactContact& ci)
{
    if(!ci.rows || chunk==PX_INVALID_U32 || other.isStaticBody() || other.isArticulation() || own.isArticulation())return;
    const auto c=chunks[chunk];if(!(c.mass>0.0f))return;
    const PxU32 clusterBody=ci.clusters[c.cluster].body;
    if(!(bodies[clusterBody].linearVelocityXYZ_inverseMassW.w==0.0f))return; // the struck cluster moves: the rigid solve has the exchange
    const auto& b=bodies[other.index()];const float im=b.linearVelocityXYZ_inverseMassW.w;
    if(!(im>0.0f) || other.index()==clusterBody)return;
    const bool early=ci.before && other.index()<ci.beforeCount && clusterBody<ci.beforeCount;
    const PxgBodySim& before=early?ci.before[other.index()]:b;
    const PxgBodySim& clusterBefore=early?ci.before[clusterBody]:bodies[clusterBody];
    const PxTransform pose=poses[c.cluster];
    PxVec3 force(0.0f),point(0.0f),normal(0.0f),torque(0.0f);float weight=0.0f,friction=0.0f;PxU32 points=0;
    const PxVec3 com(before.body2World.p.x,before.body2World.p.y,before.body2World.p.z);
    if(p.nbContacts && p.contactPatches && p.contactPoints && p.contactForces) {
        PxContactStreamIterator it(p.contactPatches,p.contactPoints,NULL,p.nbPatches,p.nbContacts);PxU32 k=0;
        while(it.hasNextPatch()){it.nextPatch();friction=fmaxf(friction,it.getDynamicFriction());while(it.hasNextContact()){it.nextContact();
            const float f=p.contactForces[k++];if(!(f>0.0f))continue;
            const PxVec3 impulse=it.getContactNormal()*(f*side);
            force+=impulse;point+=it.getContactPoint()*f;normal+=impulse;weight+=f;++points;
            torque+=(it.getContactPoint()-com).cross(-impulse);
        }}
    }
    if(!(weight>0.0f))return;
    // A contact pushes the struck chunk away from the impactor: the
    // impactor's velocity relative to the chunk's cluster, at the start of the
    // tick, along that push is not a separation. One that is -- an impactor
    // deep in a thin chunk whose depenetration pushes the chunk back onto it
    // (a 0.11 m brick against 0.36 m of travel a tick) -- is no contact the
    // impact solve can carry (unilateral along the wrong side), and its
    // impulse is the rigid solver's position correction, not an exchange of
    // momentum (a receding body against a still kinematic surface takes no
    // velocity impulse; the reported impulse accumulates the penetration bias:
    // gpusolver contactConstraintBlockPrep.cuh biasedErr = unbiasedErr -
    // scaledBias, solver.cuh appliedForce += deltaF, solverBlock.cuh
    // writeBackContactBlock). Its row is released (points 0): the impact
    // solve takes its impulse off the chunk's load and does not couple it.
    // (The high-profile cannonball: 3.2e7 N, 2.4e5 g, on a 14 kg stud.)
    bool released=false,resting=false;
    {
        const PxVec3 cw(clusterBefore.angularVelocityXYZ_maxPenBiasW.x,clusterBefore.angularVelocityXYZ_maxPenBiasW.y,clusterBefore.angularVelocityXYZ_maxPenBiasW.z);
        const PxVec3 cv(clusterBefore.linearVelocityXYZ_inverseMassW.x,clusterBefore.linearVelocityXYZ_inverseMassW.y,clusterBefore.linearVelocityXYZ_inverseMassW.z);
        const PxVec3 cp(clusterBefore.body2World.p.x,clusterBefore.body2World.p.y,clusterBefore.body2World.p.z);
        const PxVec3 x=point*(1.0f/weight);
        const PxVec3 vi(before.linearVelocityXYZ_inverseMassW.x,before.linearVelocityXYZ_inverseMassW.y,before.linearVelocityXYZ_inverseMassW.z);
        const PxVec3 wi(before.angularVelocityXYZ_maxPenBiasW.x,before.angularVelocityXYZ_maxPenBiasW.y,before.angularVelocityXYZ_maxPenBiasW.z);
        const PxVec3 rel=vi+wi.cross(x-com)-cv-cw.cross(x-cp);
        // Only an impact: a pair closing faster than the solve's motion
        // tolerance a tick. A resting contact (debris on a floor) closes at
        // nothing; the trial's kinematic support is exact for it and needs no
        // coupling (coupling every piece of rubble cost a capped solve a tick).
        const float closing=rel.dot(normal.getNormalized());
        if(closing<-ci.separating)released=true;
        else if(!(closing>ci.separating)) {
            // Not closing. A resting pair's load is a static support, up to what
            // its body can exert (Newton: its momentum change over the tick, its
            // weight, and what its own contacts' friction can add, m (|dv|/dt +
            // (1 + mu) g)). Past that it is the rigid solver's position
            // correction (a body wedged between two of the structure's chunks
            // loads both with opposing impulses its momentum never sees; the
            // high-profile truck: 4.5e5 g on a 2 kg brick), not an exchange of
            // momentum. Such a pair is a resting row: the routing takes its
            // body's self-cancelling share out of the static solve.
            if(!ci.route)return;
            const PxVec3 v1e(b.linearVelocityXYZ_inverseMassW.x,b.linearVelocityXYZ_inverseMassW.y,b.linearVelocityXYZ_inverseMassW.z);
            const PxVec3 dvb=v1e-vi;const float exertable=(dvb.magnitude()*invDt+(1.0f+friction)*ci.gravity)/im;
            if(!(force.magnitude()*invDt>exertable))return;
            resting=true;   // a row for the routing to judge (impact::routeRows), never coupled
        }
    }
    if(p.frictionPatches && p.contactPatches) {
        PxFrictionAnchorStreamIterator it(p.contactPatches,p.frictionPatches,p.nbPatches);
        while(it.hasNextPatch()){it.nextPatch();while(it.hasNextFrictionAnchor()){it.nextFrictionAnchor();
            const PxVec3 impulse=it.getImpulse()*side;if(impulse.isZero())continue;
            force+=impulse;torque+=(it.getPosition()-com).cross(-impulse);
        }}
    }
    const PxU32 slot=atomicAdd(ci.rowCount,1u);if(slot>=ci.rowCapacity)return;
    impact::ContactRow row{};row.chunk=chunk;row.body=other.index();row.points=released?0u:points;row.friction=friction;row.resting=resting?1u:0u;
    auto put=[](float* d,const PxVec3& v){d[0]=v.x;d[1]=v.y;d[2]=v.z;};
    put(row.point,pose.transformInv(point*(1.0f/weight)));put(row.normal,pose.q.rotateInv(normal.getNormalized()));
    put(row.load,pose.q.rotateInv(force*invDt));put(row.torque,pose.q.rotateInv(torque*invDt));put(row.com,pose.transformInv(com));
    // Velocities relative to the struck cluster (its motion at the start of the tick).
    const PxVec3 cw(clusterBefore.angularVelocityXYZ_maxPenBiasW.x,clusterBefore.angularVelocityXYZ_maxPenBiasW.y,clusterBefore.angularVelocityXYZ_maxPenBiasW.z);
    const PxVec3 cv(clusterBefore.linearVelocityXYZ_inverseMassW.x,clusterBefore.linearVelocityXYZ_inverseMassW.y,clusterBefore.linearVelocityXYZ_inverseMassW.z);
    const PxVec3 cp(clusterBefore.body2World.p.x,clusterBefore.body2World.p.y,clusterBefore.body2World.p.z);
    const PxVec3 v0(before.linearVelocityXYZ_inverseMassW.x,before.linearVelocityXYZ_inverseMassW.y,before.linearVelocityXYZ_inverseMassW.z);
    const PxVec3 w0(before.angularVelocityXYZ_maxPenBiasW.x,before.angularVelocityXYZ_maxPenBiasW.y,before.angularVelocityXYZ_maxPenBiasW.z);
    const PxVec3 v1(b.linearVelocityXYZ_inverseMassW.x,b.linearVelocityXYZ_inverseMassW.y,b.linearVelocityXYZ_inverseMassW.z);
    const PxVec3 w1(b.angularVelocityXYZ_maxPenBiasW.x,b.angularVelocityXYZ_maxPenBiasW.y,b.angularVelocityXYZ_maxPenBiasW.z);
    put(row.velocity,pose.q.rotateInv(v0-cv-cw.cross(com-cp)));put(row.spin,pose.q.rotateInv(w0-cw));
    put(row.dv,pose.q.rotateInv(v1-v0));put(row.dw,pose.q.rotateInv(w1-w0));
    row.im=im;
    // Inverse inertia in the struck cluster's frame: R diag(1/I) R^T, R the
    // body's principal frame (body2World) seen from the cluster.
    const PxQuat q=pose.q.getConjugate()*PxQuat(before.body2World.q.q.x,before.body2World.q.q.y,before.body2World.q.q.z,before.body2World.q.q.w);
    const PxMat33 R(q);const PxVec3 d(before.inverseInertiaXYZ_contactReportThresholdW.x,before.inverseInertiaXYZ_contactReportThresholdW.y,before.inverseInertiaXYZ_contactReportThresholdW.z);
    const PxMat33 S=R*PxMat33::createDiagonal(d)*R.getTranspose();
    row.ii[0]=S(0,0);row.ii[1]=S(1,1);row.ii[2]=S(2,2);row.ii[3]=S(0,1);row.ii[4]=S(0,2);row.ii[5]=S(1,2);
    ci.rows[slot]=row;
}
__device__ float impedanceOf(PxU32 chunk,PxNodeIndex node,const PxDestructionStressChunk* chunks,
    const PxDestructionMaterial* materials,const ImpactContact& ci,PxU32& row)
{
    row=PX_INVALID_U32;
    if(chunk!=PX_INVALID_U32)return materials[chunks[chunk].material].impactImpedance;
    if(node.isStaticBody() || node.isArticulation())return 0.0f;
    for(PxU32 i=0;i<ci.impactorCount;++i)if(ci.impactors[i].body==node.index()){row=i;return ci.impactors[i].impedance;}
    return 0.0f;
}
__device__ void impactContact(PxU32 a,PxU32 b,const PxGpuContactPair& pair,const PxVec3& point,const PxVec3& impulse,
    const PxgBodySim* bodies,const PxDestructionStressChunk* chunks,const PxDestructionMaterial* materials,const ImpactContact& ci)
{
    if(!ci.stress || impulse.isZero())return;
    if(pair.nodeIndex0.isArticulation() || pair.nodeIndex1.isArticulation())return;
    const bool early1=ci.before && !pair.nodeIndex1.isStaticBody() && pair.nodeIndex1.index()<ci.beforeCount;
    const bool early0=ci.before && !pair.nodeIndex0.isStaticBody() && pair.nodeIndex0.index()<ci.beforeCount;
    const PxVec3 v1=bodyPointVelocity(pair.nodeIndex1,early1?ci.before:bodies,point);
    const PxVec3 v0=bodyPointVelocity(pair.nodeIndex0,early0?ci.before:bodies,point);
    const float closing=(v1-v0).dot(impulse/impulse.magnitude());
    if(!(closing>0.0f))return;
    for(int side=0;side<2;++side) {
        const PxU32 target=side?b:a,other=side?a:b;
        if(target==PX_INVALID_U32 || !(materials[chunks[target].material].crush.capPressure>0) || chunks[target].volume<=0)continue;
        PxU32 row;const float z=impedanceOf(other,side?pair.nodeIndex0:pair.nodeIndex1,chunks,materials,ci,row);
        const float sigma=impact::impactStress(z,materials[chunks[target].material].impactImpedance,closing);
        if(!(sigma>0.0f))continue;
        const unsigned prior=atomicMax(reinterpret_cast<unsigned*>(ci.stress+target),__float_as_uint(sigma));
        if(__float_as_uint(sigma)>=prior) {
            ci.impactor[target]=row;
            if(ci.striker){const PxNodeIndex o=side?pair.nodeIndex0:pair.nodeIndex1;ci.striker[target]=(o.isStaticBody() || o.isArticulation())?PX_INVALID_U32:o.index();}
        }
        atomicMax(reinterpret_cast<unsigned*>(ci.rate+target),__float_as_uint(closing/cbrtf(chunks[target].volume)));
    }
}
// A pair's contact on an anchored chunk cut at its bound (the rigid solver's
// prep: PxgAnchoredContactBound.h, the same function on the same start-of-pass
// velocities): the chunk is flagged for the ghost check (anchoredGhostCheck).
__device__ void anchoredSaturation(PxU32 a,PxU32 b,const PxGpuContactPair& p,const PxgBodySim* bodies,const ImpactContact& ci)
{
    if(!ci.anchored.chunks || !ci.saturated || !p.contactForces)return;
    const PxNodeIndex n[2]={p.nodeIndex0,p.nodeIndex1};const PxU32 c[2]={a,b};
    bool kin[2];PxVec3 v[2];
    for(int k=0;k<2;++k) {
        kin[k]=false;v[k]=PxVec3(0.0f);
        if(n[k].isStaticBody() || n[k].isArticulation())continue;
        const PxU32 i=n[k].index();const bool early=ci.before && i<ci.beforeCount;
        const float4 l=(early?ci.before:bodies)[i].linearVelocityXYZ_inverseMassW;
        v[k]=PxVec3(l.x,l.y,l.z);kin[k]=l.w==0.0f;
    }
    if(kin[0]==kin[1])return;
    const PxU32 chunk=kin[0]?c[0]:c[1];if(chunk==PX_INVALID_U32)return;
    if(ci.anchored.chunks[4*chunk+2]>0.0f)return;   // the step's chunk: its verdict is the step's
    PxContactStreamIterator it(p.contactPatches,p.contactPoints,NULL,p.nbPatches,p.nbContacts);PxU32 point=0;
    while(it.hasNextPatch()){it.nextPatch();while(it.hasNextContact()){it.nextContact();
        const float f=p.contactForces[point++];
        const PxVec3 normal=it.getContactNormal();
        const float bonds=anchoredChunkImpulse(ci.anchored,chunk,kin[0]?normal:-normal),closing=PxAbs((v[1]-v[0]).dot(normal));
        const float bound=anchoredContactImpulse(bonds,ci.anchored.chunks[4*chunk+1],closing)/float(p.nbContacts);
        // At the bound, to float's resolution of the solver's accumulation.
        if(f>=bound*(1.0f-8.0f*FLT_EPSILON)){
            atomicOr(ci.saturated+chunk,1u);
            {   // (the impact log, past the chunks' flags: [0] count, then 8 records of 8 words --
                // chunk, other body, impulse, bound, the bonds' part, mass, closing speed, points
                // (float bits); no kernel argument of its own: routeContacts' has no room)
                PxU32* log=ci.saturated+ci.anchored.chunkCount;const PxU32 k=atomicAdd(log,1u);
                if(k<8u){PxU32* o=log+1+8*k;
                    o[0]=chunk;o[1]=n[kin[0]?1:0].isStaticBody()?0xffffffffu:n[kin[0]?1:0].index();o[2]=__float_as_uint(f);o[3]=__float_as_uint(bound);
                    o[4]=__float_as_uint(bonds);o[5]=__float_as_uint(ci.anchored.chunks[4*chunk+1]);
                    o[6]=__float_as_uint(closing);o[7]=p.nbContacts;}
            }
            return;
        }
    }}
}
__global__ void routeContacts(PxgDestructionSolvedContacts contacts, const Lookup* map, PxU32 maps, const PxDestructionStressChunk* chunks,
    const PxTransform* poses, float invDt, PxDestructionVectorPair* inputs,
    PxDestructionSurfaceLoad* surface, PxDestructionStageStatus* status,
    const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates,ImpactContact ci=ImpactContact{}) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=contacts.pairCount)return;
    const auto& output=contacts.outputs[i];
    if(!output.nbContacts || !contacts.responseEpoch ||
        output.nativeResponseEpoch!=contacts.responseEpoch)return;
    const auto& input=contacts.inputs[i];
    // Resolve a descriptor in registers; never export/store an adapter payload.
    // PxNodeIndex has an explicit default constructor; initialize its members
    // directly while preserving the zero/null values of the contact descriptor.
    PxGpuContactPair p{nullptr, nullptr, nullptr, nullptr, 0, 0,
        PxNodeIndex(), PxNodeIndex(), nullptr, nullptr, 0, 0};
    p.transformCacheRef0=input.transformCacheRef0;p.transformCacheRef1=input.transformCacheRef1;
    p.nodeIndex0=contacts.shapeToRigid[p.transformCacheRef0];
    p.nodeIndex1=contacts.shapeToRigid[p.transformCacheRef1];
    const size_t patchOffset=reinterpret_cast<size_t>(output.contactPatches)-reinterpret_cast<size_t>(contacts.cpuPatches);
    const size_t pointOffset=reinterpret_cast<size_t>(output.contactPoints)-reinterpret_cast<size_t>(contacts.cpuPoints);
    p.contactPatches=const_cast<PxU8*>(contacts.patches+patchOffset);
    p.contactPoints=const_cast<PxU8*>(contacts.points+pointOffset);
    if(output.contactForces) {
        const size_t forceOffset=reinterpret_cast<size_t>(output.contactForces)-reinterpret_cast<size_t>(contacts.cpuForces);
        p.contactForces=reinterpret_cast<PxReal*>(const_cast<PxU8*>(reinterpret_cast<const PxU8*>(contacts.forces)+forceOffset));
    }
    p.frictionPatches=const_cast<PxU8*>(contacts.friction+patchOffset/sizeof(PxContactPatch)*sizeof(PxFrictionPatch));
    p.nbPatches=output.nbPatches;p.nbContacts=output.nbContacts;
    const PxU32 a=findChunk(map,maps,p.transformCacheRef0), b=findChunk(map,maps,p.transformCacheRef1);
    if(a==PX_INVALID_U32 && b==PX_INVALID_U32)return;
    // Loads, contact and anchor counts are summed per pair and published once.
    PxU32 normals=0,anchors=0;
    PxDestructionStressChunk chunkA{},chunkB{};PxTransform poseA(PxIdentity),poseB(PxIdentity);
    if(a!=PX_INVALID_U32){chunkA=chunks[a];poseA=poses[chunkA.cluster];}
    if(b!=PX_INVALID_U32){chunkB=chunks[b];poseB=poses[chunkB.cluster];}
    ContactLoadSum loadA,loadB;
    if(p.nbContacts && p.contactPatches && p.contactPoints && p.contactForces) {
        PxContactStreamIterator it(p.contactPatches,p.contactPoints,NULL,p.nbPatches,p.nbContacts);
        PxU32 point=0;
        while(it.hasNextPatch()) { it.nextPatch(); while(it.hasNextContact()) { it.nextContact();
            const PxVec3 impulse=it.getContactNormal()*p.contactForces[point++];
            if(a!=PX_INVALID_U32)loadA.add(chunkA,poseA,it.getContactPoint(),impulse,invDt);
            if(b!=PX_INVALID_U32)loadB.add(chunkB,poseB,it.getContactPoint(),-impulse,invDt);
            contactRate(a,b,p,it.getContactPoint(),impulse,bodies,chunks,materials,rates,status);
            impactContact(a,b,p,it.getContactPoint(),impulse,bodies,chunks,materials,ci);
            ++normals;
        }}
    }
    if(p.frictionPatches && p.contactPatches) {
        PxFrictionAnchorStreamIterator it(p.contactPatches,p.frictionPatches,p.nbPatches);
        while(it.hasNextPatch()) { it.nextPatch(); while(it.hasNextFrictionAnchor()) {it.nextFrictionAnchor();
            const auto impulse=it.getImpulse(); if(impulse.isZero())continue;
            if(a!=PX_INVALID_U32)loadA.add(chunkA,poseA,it.getPosition(),impulse,invDt);
            if(b!=PX_INVALID_U32)loadB.add(chunkB,poseB,it.getPosition(),-impulse,invDt);
            contactRate(a,b,p,it.getPosition(),impulse,bodies,chunks,materials,rates,status);
            ++anchors;
        }}
    }
    if(normals)anchoredSaturation(a,b,p,bodies,ci);
    if(normals && ci.rows) {
        coupleRow(a,p.nodeIndex0,p.nodeIndex1,1.0f,p,chunks,poses,bodies,invDt,ci);
        coupleRow(b,p.nodeIndex1,p.nodeIndex0,-1.0f,p,chunks,poses,bodies,invDt,ci);
    }
    if(normals || anchors) {
        if(a!=PX_INVALID_U32)loadA.publish(a,chunkA,inputs,surface);
        if(b!=PX_INVALID_U32)loadB.publish(b,chunkB,inputs,surface);
    }
    if(normals)atomicAdd(&status->normalContacts,normals);
    if(anchors)atomicAdd(&status->frictionAnchors,anchors);
}
// Ci: each crushable chunk's crush law at its impact stress (uniaxial), in
// place of evaluateChunkMaterials' virial.
__global__ void impactCrushStep(const PxDestructionStressChunk* chunks,const PxDestructionMaterial* materials,
    const float* stress,const float* rate,const PxDestructionCrushState* accepted,PxDestructionCrushState* trial,
    PxU32 count,float dt,PxDestructionStageStatus* status)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    if(status->error & 4096u){trial[i]=accepted[i];return;}
    const auto c=chunks[i];const auto a=accepted[i];
    const ExtStressCrushState before{a.damage,a.pressure,a.deviator,a.utilisation,a.crushed!=0};
    const auto next=impact::crushByImpact(stress[i],c.volume,c.mass,rate[i],dt,materials[c.material].crush,before);
    trial[i]={next.damage,next.pressure,next.deviator,next.utilisation,next.crushed?1u:0u};
    if(!a.crushed && next.crushed)atomicAdd(&status->crushedChunks,1u);
}
// Contact crush: the impactor pays the comminution energy of what it crushed,
// crushEnergy times the chunk's volume (the stage removes the whole chunk),
// out of its kinetic energy at the start of the tick -- the state the
// corrected pass re-simulates from (its rigid checkpoint).
__global__ void crushEnergy(const PxDestructionStressChunk* chunks,const PxDestructionMaterial* materials,
    const PxDestructionCrushState* accepted,const PxDestructionCrushState* trial,const PxU32* impactor,
    float* energy,PxU32 count,PxDestructionStageStatus* status=nullptr,bool unpaid=false)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    if(accepted[i].crushed || !trial[i].crushed)return;
    const float E=materials[chunks[i].material].crush.crushEnergy*chunks[i].volume;
    if(impactor[i]==PX_INVALID_U32 || unpaid){if(status)atomicAdd(&status->crushEnergyCreated,E);return;}
    atomicAdd(energy+impactor[i],E);
}
// Energy-bounded crushing (PX_DESTRUCTION_CRUSH_ENERGY_BOUND). A crush erases
// its chunk's comminution energy, crushEnergy * volume, all of it (the stage
// removes whole chunks); the body that struck it hardest pays it out of its
// kinetic energy, or the chunk is not crushed: a 100 kg ball at 60 m/s (180 kJ)
// crushed a 0.073 m^3 brick chunk (256 kJ) and stopped dead paying it, a wall
// no 100 kg ball can meet. Every crush is paid, in the pass that finds it.
__device__ __forceinline__ void uncrush(PxDestructionCrushState& t,PxDestructionStageStatus* status)
{
    // The damage stays just short of crushing: it crushes once a payer can.
    t.crushed=0u;t.damage=fminf(t.damage,1.0f-FLT_EPSILON);atomicSub(&status->crushedChunks,1u);
}
__global__ void crushDemand(const PxDestructionStressChunk* chunks,const PxDestructionMaterial* materials,
    const PxDestructionCrushState* accepted,PxDestructionCrushState* trial,const PxU32* striker,PxU32 count,
    float* demand,PxU32 bodies,PxDestructionStageStatus* status,float* audit)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    if(accepted[i].crushed || !trial[i].crushed)return;
    const float E=materials[chunks[i].material].crush.crushEnergy*chunks[i].volume;
    const PxU32 p=striker[i];
    if(p>=bodies){uncrush(trial[i],status);if(audit){atomicAdd(audit+0,1.0f);atomicAdd(audit+1,E);}return;}
    atomicAdd(demand+p,E);
}
// A payer's kinetic energy (its own frame against the structure at rest).
__device__ __forceinline__ float payerEnergy(const PxgBodySim& b)
{
    const float4 v=b.linearVelocityXYZ_inverseMassW;
    return v.w>0.0f?0.5f*(v.x*v.x+v.y*v.y+v.z*v.z)/v.w:0.0f;
}
__global__ void crushSettle(const PxDestructionStressChunk* chunks,const PxDestructionMaterial* materials,
    const PxDestructionCrushState* accepted,PxDestructionCrushState* trial,const PxU32* striker,PxU32 count,
    const float* demand,float* kept,const PxgBodySim* payers,PxU32 bodies,PxDestructionStageStatus* status,float* audit)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    if(accepted[i].crushed || !trial[i].crushed)return;
    const PxU32 p=striker[i];
    if(p>=bodies){atomicAdd(&status->crushEnergyCreated,materials[chunks[i].material].crush.crushEnergy*chunks[i].volume);return;}   // kept with no payer: a bug
    const float E=materials[chunks[i].material].crush.crushEnergy*chunks[i].volume;
    if(!(demand[p]<=payerEnergy(payers[p]))){uncrush(trial[i],status);if(audit){atomicAdd(audit+2,1.0f);atomicAdd(audit+3,E);}}
    else{atomicAdd(kept+p,E);if(audit){atomicAdd(audit+4,1.0f);atomicAdd(audit+5,E);}}
}
// 1/2 m v'^2 = 1/2 m v^2 - D: v' = v sqrt(1 - D / KE), only where all of it is payable.
__global__ void crushPay(float* demand,float* kept,PxgBodySim* payers,PxU32 bodies,PxDestructionStageStatus* status)
{
    const PxU32 p=blockIdx.x*blockDim.x+threadIdx.x;if(p>=bodies)return;
    const float D=demand[p],K=kept[p];demand[p]=0.0f;kept[p]=0.0f;
    const float ke=payerEnergy(payers[p]);
    // The crushes kept past what their payer has: energy created (by construction none).
    if(K>ke)atomicAdd(&status->crushEnergyCreated,K-ke);
    if(!(D>0.0f) || !(D<=ke) || !(ke>0.0f))return;
    float4& v=payers[p].linearVelocityXYZ_inverseMassW;const float k=sqrtf(fmaxf(1.0f-D/ke,0.0f));
    v.x*=k;v.y*=k;v.z*=k;
}
__global__ void payCrushEnergy(const ImpactorImpedance* impactors,PxU32 count,const float* energy,
    PxgBodySim* checkpoint,PxU32 checkpointCount,const PxDestructionStageStatus* status)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count || !(energy[i]>0.0f))return;
    if(status->error & ~8u)return;
    const PxU32 body=impactors[i].body;if(body>=checkpointCount)return;
    float4& v=checkpoint[body].linearVelocityXYZ_inverseMassW;
    const float speed2=v.x*v.x+v.y*v.y+v.z*v.z;if(!(speed2>0.0f) || !(v.w>0.0f))return;
    // 1/2 m v'^2 = 1/2 m v^2 - E: v' = v sqrt(1 - 2 E (1/m) / v^2).
    const float ke=0.5f*speed2/v.w;
    if(energy[i]>ke)atomicAdd(&const_cast<PxDestructionStageStatus*>(status)->crushEnergyCreated,energy[i]-ke);
    const float k=sqrtf(fmaxf(1.0f-2.0f*energy[i]*v.w/speed2,0.0f));
    v.x*=k;v.y*=k;v.z*=k;
}
// The anchored-chunk contact bound's inputs (PX_DESTRUCTION_ANCHORED_CONTACT_BOUND;
// gpusolver PxgAnchoredContactBound.h): per chunk its mass, per bond its axis
// (chunk0 -> chunk1, as impact::prepareBond orients it) and its fatal
// capacities, compression, tension and shear, at its live area, times dt;
// none for a bond worn out or with a crushed end. Whether a chunk is anchored
// the prep reads from its body (kinematic).
__global__ void anchoredChunkBounds(const PxDestructionStressChunk* chunks,PxU32 n,float4* out)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    out[i]=make_float4(0.0f,fmaxf(chunks[i].mass,0.0f),0.0f,0.0f);
}
__global__ void anchoredBondBounds(const PxDestructionStressChunk* chunks,const PxDestructionStressBond* bonds,const PxDestructionMaterial* materials,
    const float* health,const PxDestructionCrushState* crushed,float dt,PxU32 m,float4* out)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=m)return;
    const PxDestructionStressBond& b=bonds[i];const float area=health[i];
    out[2*i]=make_float4(0.0f,0.0f,0.0f,__uint_as_float(b.chunk0));out[2*i+1]=make_float4(0.0f,0.0f,0.0f,0.0f);
    if(!(area>8.0f*FLT_EPSILON*b.area && area<0.5f*FLT_MAX))return;   // impact::bondMember's floor
    if(crushed && (crushed[b.chunk0].crushed || crushed[b.chunk1].crushed))return;
    const PxVec3 d=chunks[b.chunk1].position-chunks[b.chunk0].position;
    PxVec3 axis=b.normal*copysignf(1.0f,b.normal.dot(d));const float l=axis.magnitude();axis=l>0.0f?axis*(1.0f/l):PxVec3(1.0f,0.0f,0.0f);
    const auto& mat=materials[b.material];
    out[2*i]=make_float4(axis.x,axis.y,axis.z,__uint_as_float(b.chunk0));
    out[2*i+1]=make_float4(mat.compressionFatalLimit*area*dt,mat.tensionFatalLimit*area*dt,mat.shearFatalLimit*area*dt,0.0f);
}
// Chunks of rows routed to the impact step this pass (anchoredGhostCheck's bit 2).
__global__ void anchoredStepChunks(const impact::ContactRow* rows,const PxU32* count,PxU32 capacity,const PxU32* routed,PxU32 n,PxU32* flags)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=min(*count,capacity) || !routed[i])return;
    const PxU32 c=rows[i].chunk;if(c<n)atomicOr(flags+c,2u);
}
// The ghost check: a chunk whose contact was cut at its bound this pass and
// whose bonds this pass's verdict left all intact (with any left) -- the
// impactor went past a chunk that stays put. Must be 0: the bound is at
// least what the bonds carry, so a load at it breaks one.
__global__ void anchoredGhostCheck(PxU32* saturated,const PxU32* nodeBegin,const PxU32* nodeRefs,const float* health,
    const PxDestructionBondVerdict* verdicts,const PxDestructionStressBond* bonds,const PxDestructionCrushState* crushed,
    PxU32 n,PxDestructionStageStatus* status,PxU32* ghosts)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n || !saturated[i])return;
    const PxU32 flags=saturated[i];saturated[i]=0u;
    // Bit 2: a routed row's chunk this pass, its verdict the impact step's (the
    // trial's rigid motion there is the step's to correct).
    if(!(flags&1u) || (flags&2u))return;
    if(ghosts)atomicAdd(ghosts+9,1u);   // (the log: chunks whose contact met its bound this pass)
    // Live: what anchoredChunkBounds counted (a bond to a crushed chunk holds nothing).
    bool live=false,broke=false;
    for(PxU32 slot=nodeBegin[i];slot<nodeBegin[i+1];++slot) {
        const PxU32 j=nodeRefs[slot];
        if(verdicts[j].broken)broke=true;
        else if(health[j]>8.0f*FLT_EPSILON*bonds[j].area && health[j]<0.5f*FLT_MAX && !(crushed && (crushed[bonds[j].chunk0].crushed || crushed[bonds[j].chunk1].crushed)))live=true;
    }
    if(live && !broke){atomicAdd(&status->anchoredGhosts,1u);if(ghosts){const PxU32 k=atomicAdd(ghosts,1u);if(k<8u)ghosts[1+k]=i;}}
}
// The corrected pass's contact bounds: per anchored cluster body, the
// largest per-point bound of the rows on its chunks (a body's max contact
// impulse applies to all its contacts: the bound of its pair at capacity).
// With perImpactor (Settings::boundImpactor): per impactor body instead, the
// largest of its own rows' -- the pair the impact model solved, nothing else
// the struck cluster touches. A body's max impulse still applies to all its
// contacts -- debris it pushes, the ground, contacts new in the corrected
// pass -- none of which the step evaluated: with pairwise
// (Settings::boundPairwise) the bound holds only between an impactor and the
// clusters its rows struck (gpusolver constraintPrepShared.cuh
// contactPairMaxImpulse), and every other pair is an ordinary rigid contact.
__global__ void collectImpactBounds(const impact::ContactRow* rows,const PxU32* count,PxU32 capacity,const float* rowBound,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,float* bound,PxU32 bodies,bool perImpactor=false,bool pairwise=false,
    float4* chunkStep=nullptr,PxU32 chunkCount=0,PxU32* requested=nullptr)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=min(*count,capacity))return;
    const float b=rowBound[i];if(!(b>0.0f))return;
    // With the anchored-chunk bound: per struck chunk, read by the corrected
    // pass's contact prep (PxgAnchoredContactBound.h), no body's bound.
    if(chunkStep) {
        const PxU32 c=rows[i].chunk;if(c<chunkCount)atomicMax(reinterpret_cast<unsigned*>(&chunkStep[c].z),__float_as_uint(b));
        if(requested)*requested=1u;
        return;
    }
    const PxU32 body=perImpactor?rows[i].body:clusters[chunks[rows[i].chunk].cluster].body;if(body>=bodies)return;
    atomicMax(reinterpret_cast<unsigned*>(bound+body),__float_as_uint(b));
    // Pairwise: the struck cluster is marked (+inf, above every bound): the
    // impactor's bound holds against it and nothing else (contactPairMaxImpulse).
    if(pairwise && perImpactor) {
        const PxU32 struck=clusters[chunks[rows[i].chunk].cluster].body;
        if(struck<bodies && struck!=body)atomicMax(reinterpret_cast<unsigned*>(bound+struck),__float_as_uint(INFINITY));
    }
}
// Into the rigid checkpoint the corrected pass restores; the correction is
// requested (*requested): the topology transaction prepares an empty edit set
// for it, and keepBoundCorrection sets the stage's correction bit after the
// (unchanged) commit.
__global__ void applyImpactBounds(float* bound,float* saved,PxU32* bounded,PxgBodySim* checkpoint,PxU32 checkpointCount,PxU32 bodies,
    PxDestructionStageStatus* status,PxU32* requested,bool pairwise=false)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=bodies)return;
    const float b=bound[i];bound[i]=0.0f;
    if(!(b>0.0f) || i>=checkpointCount || (status->error & ~8u))return;
    float& m=checkpoint[i].body2Actor_maxImpulseW.p.w;
    if(!bounded[i]){saved[i]=m;bounded[i]=1u;}
    // Pairwise (collectImpactBounds): a struck cluster (+inf) is marked
    // -PX_MAX_F32, an impactor's bound b is -b; an ordinary bound otherwise.
    // (A body with its own finite max contact impulse keeps it, ordinary.)
    // (1e32: PxsBodyCore's default, no bound of the body's own.)
    const bool own=saved[i]<1e32f;
    if(isinf(b))m=own?saved[i]:-PX_MAX_F32;
    else m=pairwise && !own?-b:fminf(saved[i],b);
    *requested=1u;
}
// An unchanged topology commits at once (and clears the correction bit);
// the contact bounds still need their corrected pass.
__global__ void keepBoundCorrection(const PxU32* requested,PxDestructionStageStatus* status)
{
    if(*requested && !(status->error & ~8u))status->error|=8u;
}
__global__ void restoreImpactBoundsKernel(const float* saved,PxU32* bounded,PxgBodySim* bodies,PxU32 count)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count || !bounded[i])return;
    bodies[i].body2Actor_maxImpulseW.p.w=saved[i];bounded[i]=0u;
}
__global__ void finishStatus(const ExtStressGpuDeviceStatus* solve,PxDestructionStageStatus* status,
    const PxDestructionVectorPair* forces, PxU32 count,bool requireConvergence=false) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!i) {
        status->stressPasses=1;status->iterations=solve?solve->iterations:0;status->converged=solve?solve->converged:1;
        // A native material transaction requires a converged solve in this
        // timestep. Do not commit speculative damage or refine across ticks.
        if(requireConvergence && !status->converged)atomicOr(&status->error,4096u);
    }
    if(i<count && (!forces[i].linear.isFinite() || !forces[i].angular.isFinite())) atomicOr(&status->error,2u);
}

// Idle gate. An evaluation that changed no state (no solver iterations, no
// verdict, no damage or crush evolution, no destructible contact) is a fixed
// point: the same inputs reproduce it exactly. A later frame may then skip the
// pipeline, provided its inputs are bitwise the same. These kernels observe
// that on device; the host reads the bits with the mandatory completion copy.
enum IdleObservation : PxU32 { eIDLE_INPUTS_CHANGED=1u, eIDLE_STATE_CHANGED=2u };
struct IdleBody { float4 linear,angular,rotation,position,actorRotation,actorPosition; };
__device__ inline bool sameBits(const float4& a,const float4& b) {
    return __float_as_uint(a.x)==__float_as_uint(b.x) && __float_as_uint(a.y)==__float_as_uint(b.y)
        && __float_as_uint(a.z)==__float_as_uint(b.z) && __float_as_uint(a.w)==__float_as_uint(b.w);
}
// Every input the pipeline derives from a cluster body: pose (body and actor
// frame) and both velocities. Records the frame's values for the next compare.
__global__ void watchClusterBodies(const PxDestructionStressCluster* clusters,PxU32 count,
    const PxgBodySim* bodies,IdleBody* seen,PxU32* observation) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto& b=bodies[clusters[i].body];
    const auto& t=b.body2World;const auto& a=b.body2Actor_maxImpulseW;
    const IdleBody now{b.linearVelocityXYZ_inverseMassW,b.angularVelocityXYZ_maxPenBiasW,
        t.q.q,t.p,a.q.q,a.p};
    const IdleBody before=seen[i];
    if(sameBits(now.linear,before.linear) && sameBits(now.angular,before.angular) && sameBits(now.rotation,before.rotation)
        && sameBits(now.position,before.position) && sameBits(now.actorRotation,before.actorRotation)
        && sameBits(now.actorPosition,before.actorPosition))return;
    seen[i]=now;atomicOr(observation,eIDLE_INPUTS_CHANGED);
}
// Any solved pair touching a destructible chunk is a load routeContacts would
// apply. Conservative: a pair with contacts counts even if its forces are zero.
__global__ void watchDestructibleContacts(PxgDestructionSolvedContacts contacts,const Lookup* map,PxU32 maps,
    PxU32* observation,PxU32 flag) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=contacts.pairCount)return;
    const auto& output=contacts.outputs[i];
    if(!output.nbContacts || !contacts.responseEpoch || output.nativeResponseEpoch!=contacts.responseEpoch)return;
    const auto& input=contacts.inputs[i];
    if(findChunk(map,maps,input.transformCacheRef0)!=PX_INVALID_U32 || findChunk(map,maps,input.transformCacheRef1)!=PX_INVALID_U32)
        atomicOr(observation,flag);
}
#if defined(PX_CUMETAL) && PX_CUMETAL
#include "PxgDestructionMotionPair.cuh"
#endif
__global__ void provisionalTopologyMotion(PxDestructionTopologyDeviceView topology,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    const PxTransform* poses,const PxgBodySim* bodies,PxDestructionClusterMotion* motion) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=topology.status->clusterCount)return;
    const PxU32 root=topology.activeClusters[i],cluster=chunks[root].cluster;
#if defined(PX_CUMETAL) && PX_CUMETAL
    // This runs on every full evaluation; its only binary64 arithmetic is the
    // velocity at the topology COM. Emulated double costs microseconds per
    // dependent operation on Apple GPUs (0.15-0.35 ms for this chain). Float
    // pairs (about 48 bits) carry it instead; see PxgDestructionMotionPair.cuh.
    const PxTransform pose=poses[cluster];const PxgBodySim& body=bodies[clusters[cluster].body];
    PxDestructionClusterMotion out;
    destructionMotionPair::provisionalMotion(pose,body.body2World.p,body.linearVelocityXYZ_inverseMassW,
        body.angularVelocityXYZ_maxPenBiasW,topology.clusters[root].center,out);
    motion[i]=out;
#else
    const auto pose=poses[cluster];const auto body=bodies[clusters[cluster].body];
    PxDestructionClusterMotion out{};
    for(PxU32 k=0;k<3;++k)out.origin[k]=pose.p[k];
    out.orientation[0]=pose.q.x;out.orientation[1]=pose.q.y;out.orientation[2]=pose.q.z;out.orientation[3]=pose.q.w;
    const auto* d=topology.clusters[root].center;const auto* q=out.orientation;
    const double t[3]={2*(q[1]*d[2]-q[2]*d[1]),2*(q[2]*d[0]-q[0]*d[2]),2*(q[0]*d[1]-q[1]*d[0])};
    const double r[3]={pose.p.x+d[0]+q[3]*t[0]+q[1]*t[2]-q[2]*t[1]-body.body2World.p.x,
        pose.p.y+d[1]+q[3]*t[1]+q[2]*t[0]-q[0]*t[2]-body.body2World.p.y,
        pose.p.z+d[2]+q[3]*t[2]+q[0]*t[1]-q[1]*t[0]-body.body2World.p.z};
    const auto v=body.linearVelocityXYZ_inverseMassW,w=body.angularVelocityXYZ_maxPenBiasW;
    out.angularVelocity[0]=w.x;out.angularVelocity[1]=w.y;out.angularVelocity[2]=w.z;
    out.linearVelocity[0]=v.x+w.y*r[2]-w.z*r[1];
    out.linearVelocity[1]=v.y+w.z*r[0]-w.x*r[2];
    out.linearVelocity[2]=v.z+w.x*r[1]-w.y*r[0];
    motion[i]=out;
#endif
}
// A crushed chunk is not removed from the topology. finalizeMaterialVerdict has
// already broken every live bond it has, so it becomes a cluster of its own: a
// free body with its own hull, through the same split, rewind and corrected
// solve as any detached chunk, so the corrected pass meets it as a moving body
// of its own mass and not as part of an anchored structure. Its accepted crush
// state marks it; what it becomes after its tick (debris that keeps colliding,
// or dust the application retires) is the consumer's, by debrisMassFraction.
// Removing its shape inside the correction (DestroyChunk) has no supported
// owner transaction: the stage refused every such step and the scene froze.
__global__ void emitTopologyEdits(const PxDestructionBondVerdict* bonds,PxU32 nb,
    const PxDestructionCrushState* trial,const PxDestructionCrushState* accepted,PxU32 nc,
    PxgDestructionEdit* edits,PxU32* count) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<nb && bonds[i].broken)edits[atomicAdd(count,1u)]={PxgDestructionEditKind::BreakBond,i};
    (void)trial;(void)accepted;(void)nc;
}
// A bond cut on a cycle can change internal stress without changing any
// chunk's collision ownership, cluster mass or motion degrees of freedom.
// Only that exact case can commit before native body rebinding/correction lands.
__global__ void checkUnchangedMotionCommit(PxDestructionTopologyDeviceView accepted,
    PxDestructionTopologyDeviceView trial,const PxDestructionTopologyTransactionStatus* transaction,PxU32* accept,
    const PxDestructionStressChunk* chunks,PxU32* affectedClusters,PxDestructionCollisionPreparationStatus* collision) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!transaction->prepared || transaction->error || i>=accepted.chunkCount)return;
    if(accepted.activeChunks[i]!=trial.activeChunks[i] || accepted.chunkCluster[i]!=trial.chunkCluster[i]) {
        atomicExch(accept,0u);
        if(!atomicExch(affectedClusters+chunks[i].cluster,1u))atomicAdd(&collision->affectedClusters,1u);
    }
}
__global__ void inspectStressTopology(const ExtStressGpuDeviceTopologyStatus* topology,PxDestructionStageStatus* status) {
    if(topology->error)status->error|=64u;
}

__global__ void prepareCandidateBodies(PxDestructionTopologyDeviceView topology,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    PxDestructionClusterBodyState* bodies,PxDestructionBodyPreparationStatus* status,
    PxDestructionTopologyDeviceView accepted,PxvDestructionBodyRequest* requests,PxU32* bodyIndices,
    destructionBody::PrincipalFrameCache* frames) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=status->count)return;
    const PxU32 root=topology.activeClusters[i];PxDestructionClusterBodyState body;
    const PxU32 error=destructionBody::prepare(topology.clusters[root],topology.motions[topology.clusterSlots[root]],body,
        frames?frames+root:nullptr);
    body.cluster=root;body.sourceBody=clusters[chunks[root].cluster].body;bodies[i]=body;
    const PxU32 needsBody=accepted.activeChunks[root] && accepted.chunkCluster[root]==root?0u:1u;
    requests[i]={root,body.sourceBody,body.supported,needsBody,i};
    bodyIndices[i]=needsBody?PX_INVALID_U32:body.sourceBody;
    if(needsBody)atomicAdd(&status->allocationRequests,1u);
    if(error)atomicOr(&status->error,error);
}

// Fused single-thread steps of one full evaluation, in their original order.
// Each replaces consecutive one-thread launches; no other kernel runs between
// the steps they combine, so every read sees the same values as before.
// requireFractureCorrection's bit 8 is excluded by the topology transaction's
// abort mask (~8u) and read by no kernel before this one, so it may be set here.
__global__ void inspectTopologyAndBeginBodyPreparation(const PxDestructionTopologyTransactionStatus* transaction,
    PxDestructionTopologyDeviceView topology,PxDestructionBodyPreparationStatus* body,
    PxDestructionStageStatus* stage,bool requireCorrection) {
    if(requireCorrection && (stage->brokenBonds || stage->crushedChunks))stage->error|=8u;
    if(transaction->error)stage->error|=32u;
    *body={};
    if(transaction->prepared && !transaction->error) {body->generation=topology.status->generation;body->count=topology.status->clusterCount;}
}
__global__ void finishBodyPreparationAndBeginCommit(const PxDestructionTopologyTransactionStatus* transaction,
    PxDestructionBodyPreparationStatus* body,PxDestructionStageStatus* stage,PxU32* accept) {
    body->valid=transaction->prepared && !transaction->error && !body->error;
    if(body->error)stage->error|=128u;
    *accept=transaction->prepared && !transaction->error && !(stage->error & ~8u);
}
// inspectStressTopology fused into the motion commit. Every thread applies the
// stress-topology error to its own predicate, so the order of thread 0's
// status write and the other threads' reads cannot change a result.
__global__ void inspectStressAndCommitObservedMotion(PxDestructionTopologyDeviceView topology,
    const PxDestructionClusterMotion* motion,PxDestructionStageStatus* status,
    const ExtStressGpuDeviceTopologyStatus* stress) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    const PxU32 stressError=stress && stress->error?64u:0u;
    if(!i && stressError)atomicOr(&status->error,stressError);
    if(!(status->error|stressError) && i<topology.status->clusterCount)
        topology.motions[topology.clusterSlots[topology.activeClusters[i]]]=motion[i];
}
__global__ void commitObservedTopologyMotion(PxDestructionTopologyDeviceView topology,
    const PxDestructionClusterMotion* motion,const PxDestructionStageStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!status->error && i<topology.status->clusterCount)topology.motions[topology.clusterSlots[topology.activeClusters[i]]]=motion[i];
}

#include "PxgDestructionMotionState.cuh"
__device__ bool initializedBodyAllocation(const PxDestructionBodyAllocationStatus* allocation) {
    return allocation->valid && !allocation->error && !allocation->initializationError
        && allocation->initialized==allocation->reserved;
}
struct NativePreparationInputs {
    PxgDestructionCollisionStorage collision;
    const PxgBodySim* checkpoint=nullptr;
    const PxgBodySimVelocities* commands=nullptr;
    const PxDestructionChunkLoad* chunkLoads=nullptr;
    const float* commandScales=nullptr; // chunkCommandSumsMatch rounding bound
    const PxgBodySimVelocities* previous=nullptr;
    PxU32 checkpointCount=0,bodyCapacity=0,clusterCount=0;
    PxU64 checkpointGeneration=0;
};
// Rigid membership is determined by the GPU bond graph. This batch identifies
// native shape edits without traversing chunk/shape ownership on the CPU.
__global__ void indexCandidateRoots(PxDestructionTopologyDeviceView topology,PxU32* slots) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<topology.status->clusterCount)slots[topology.activeClusters[i]]=i;
}
__global__ void preparePersistentCollisionBindings(const PxDestructionStressChunk* chunks,PxU32 chunkCount,
    const PxDestructionStressShape* hulls,PxU32 hullCount,
    const PxDestructionStressCluster* clusters,const PxU32* affectedClusters,
    PxDestructionTopologyDeviceView topology,const PxU32* candidateSlots,const PxU32* candidateBodies,
    const PxgShapeSim* shapes,PxU32 shapeCapacity,const PxNodeIndex* shapeToBody,PxU32 remapCapacity,
    PxDestructionCollisionBinding* bindings,
    PxDestructionCollisionPreparationStatus* status,const PxDestructionBodyAllocationStatus* allocation,
    const NativePreparationInputs* inputs=nullptr) {
    if(inputs){shapes=inputs->collision.shapes;shapeCapacity=inputs->collision.shapeCapacity;
        shapeToBody=inputs->collision.shapeToBody;remapCapacity=inputs->collision.remapCapacity;}
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=hullCount)return;
    const auto hull=hulls[i];
    bindings[i]={hull.chunk,PX_INVALID_U32,PX_INVALID_U32,PX_INVALID_U32,i};
    // Overwrite every compaction sentinel even when initialization was rejected.
    // Candidate state cannot be consumed before the ordered device prerequisite.
    if(!initializedBodyAllocation(allocation))return;
    const auto chunk=chunks[hull.chunk];if(!affectedClusters[chunk.cluster] || hull.contactIndex==PX_INVALID_U32)return;
    const PxU32 shapeId=hull.contactIndex,source=clusters[chunk.cluster].body;
    if(shapeId>=shapeCapacity || !shapes) {atomicOr(&status->error,1u);return;}
    const auto shape=shapes[shapeId];
    if(shape.mBodySimIndex.isStaticBody() || shape.mBodySimIndex.isArticulation() || shape.mBodySimIndex.index()!=source)
        {atomicOr(&status->error,2u);return;}
    if(!shapeToBody || shapeId>=remapCapacity) {atomicOr(&status->error,32u);return;}
    const auto mapped=shapeToBody[shapeId];
    if(mapped.isStaticBody() || mapped.isArticulation() || mapped.index()!=source)
        {atomicOr(&status->error,32u);return;}
    const PxU32 kind=shape.mShapeType;
    if(!(shape.mShapeFlags&PxShapeFlag::eSIMULATION_SHAPE) || (shape.mShapeFlags&PxShapeFlag::eTRIGGER_SHAPE)
        || (kind!=PxGeometryType::eBOX && kind!=PxGeometryType::eSPHERE && kind!=PxGeometryType::eCAPSULE && kind!=PxGeometryType::eCONVEXMESH)
        || !shape.mTransform.isValid() || shape.mHullDataIndex==PX_INVALID_U32)
        {atomicOr(&status->error,8u);return;}
    PxU32 target=PX_INVALID_U32;
    if(topology.activeChunks[hull.chunk]) {
        const PxU32 root=topology.chunkCluster[hull.chunk];
        if(root>=chunkCount) {atomicOr(&status->error,4u);return;}
        const PxU32 slot=candidateSlots[root];
        if(slot>=topology.status->clusterCount || topology.activeClusters[slot]!=root)
            {atomicOr(&status->error,4u);return;}
        target=candidateBodies[slot];
        if(target==PX_INVALID_U32) {atomicOr(&status->error,4u);return;}
    } else atomicAdd(&status->removed,1u);
    bindings[i]={hull.chunk,shapeId,source,target,i};
}
// The native transaction preserves authored shape-to-actor coordinates. Only
// the motion owner changes; geometry, local bounds and registration stay resident.
__global__ void installNativeCollisionOwners(const PxDestructionCollisionBinding* bindings,
    PxU32 count,PxgShapeSim* shapes,PxU32 capacity,PxNodeIndex* shapeToBody,PxU32 remapCapacity,
    PxU64* ownerGenerations,PxU64 generation,PxU64* publicationEpochs,PxU32* publicationTargets,
    const PxDestructionStageStatus* stage) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto b=bindings[i];
    if(b.shape>=capacity || b.shape>=remapCapacity || b.targetBody==PX_INVALID_U32) {asm volatile("trap;");return;}
    auto& shape=shapes[b.shape];
    if(shape.mBodySimIndex.isStaticBody() || shape.mBodySimIndex.isArticulation()
        || shape.mBodySimIndex.index()!=b.sourceBody) {asm volatile("trap;");return;}
    const auto previous=shapeToBody[b.shape];
    if(previous.isStaticBody() || previous.isArticulation() || previous.index()!=b.sourceBody)
        {asm volatile("trap;");return;}
    shape.mBodySimIndex=PxNodeIndex(b.targetBody);
    shapeToBody[b.shape]=shape.mBodySimIndex;
    // Broad phase's NEW flag assumes old pair managers were removed. Only
    // migrating shapes require that lifecycle; retained owners keep their
    // existing pairs while the correction resets their solver/contact caches.
    if(b.sourceBody!=b.targetBody) {
        ownerGenerations[b.shape]=generation;
        if(publicationEpochs) {publicationEpochs[b.shapeSlot]=stage->frame;publicationTargets[b.shapeSlot]=b.targetBody;}
    }
}
struct HasMigratingCollisionBinding {
    __host__ __device__ bool operator()(const PxDestructionCollisionBinding& b) const {
        return b.shape!=PX_INVALID_U32 && b.targetBody!=PX_INVALID_U32 && b.sourceBody!=b.targetBody;
    }
};
struct HasCollisionBinding {
    __host__ __device__ bool operator()(const PxDestructionCollisionBinding& b) const {return b.shape!=PX_INVALID_U32;}
};
__global__ void finishCollisionPreparation(PxDestructionCollisionPreparationStatus* collision,
    const PxDestructionBodyAllocationStatus* allocation,PxDestructionStageStatus* stage) {
    collision->generation=allocation->generation;
    if(!initializedBodyAllocation(allocation))collision->error|=64u;
    collision->valid=!collision->error;
    if(collision->error)stage->error|=1024u;
}
#include "PxgDestructionCorrection.cuh"
#include "PxgDestructionImpactCapture.cuh"
#include "PxgDestructionAcceptedProperties.cuh"
#include "PxgDestructionMotionSlots.cuh"
#include "PxgDestructionPreparationGraph.cuh"
class Runtime final : public PxgDestructionRuntime {
    bool mPreserveContactPairs=false;
    // Pass 0 is the trial evaluation; pass p>0 evaluates the p-th corrected
    // solve. mPriorPasses sums every earlier pass of the current frame.
    PxU32 mPass=0,mCorrectionLimit=0,mFirstPassBrokenBonds=0;PxDestructionStageStatus mPriorPasses{};
    PxProfilerCallback* mProfiler=nullptr;PxU64 mProfileContext=0;
    cudaEvent_t mStageEvents[6]{};bool mStageTimingPending=false;
    void stageMarker(PxU32 stage) {
        if(!mProfiler)return;
        for(auto& event:mStageEvents)if(!event)check(cudaEventCreate(&event));
        check(cudaEventRecord(mStageEvents[stage],mStream));
        if(stage==5)mStageTimingPending=true;
    }
    void collectStageTimings() {
        if(!mStageTimingPending)return;
        // finish already waited for mReady, which follows all six markers.
        // Reading elapsed times introduces no additional synchronization.
        static const char* names[]={"GpuDestruction.cuda.contactLoads", "GpuDestruction.cuda.stress",
            "GpuDestruction.cuda.materials", "GpuDestruction.cuda.topologyAndCandidates",
            "GpuDestruction.cuda.commitAndStressTopology"};
        for(PxU32 i=0;i<5;++i) {
            float elapsed=0;check(cudaEventElapsedTime(&elapsed,mStageEvents[i],mStageEvents[i+1]));
            if(mProfiler)mProfiler->recordData(elapsed,names[i],mProfileContext);
        }
        mStageTimingPending=false;
    }
    cudaEvent_t mCorrectionEvents[6]{};PxU32 mCorrectionTimingMask=0;
    void correctionMarker(PxU32 marker,cudaStream_t stream) {
        if(!mProfiler)return;
        for(auto& event:mCorrectionEvents)if(!event)check(cudaEventCreate(&event));
        check(cudaEventRecord(mCorrectionEvents[marker],stream));
        if(marker&1)mCorrectionTimingMask|=1u<<(marker/2);
    }
    void collectCorrectionTimings() {
        // Acceptance already joins the scene stream and waits for mReady.
        // No additional synchronization or event wait is introduced here.
        static const char* names[2][3]={
            {"GpuDestruction.cuda.rewindState","GpuDestruction.cuda.installFragments","GpuDestruction.cuda.installOwners"},
            {"GpuDestruction.cuda.finalSplitState","GpuDestruction.cuda.finalSplitFragments","GpuDestruction.cuda.finalSplitOwners"}};
        for(PxU32 i=0;i<3;++i)if(mCorrectionTimingMask&(1u<<i)) {
            float elapsed=0;check(cudaEventElapsedTime(&elapsed,mCorrectionEvents[2*i],mCorrectionEvents[2*i+1]));
            if(mProfiler)mProfiler->recordData(elapsed,names[mPass==mCorrectionLimit?1:0][i],mProfileContext);
        }
        mCorrectionTimingMask=0;
    }
    CUcontext mContext; void* mScene; bool(*mWriteAllowed)(void*);
    cudaStream_t mStream{}; cudaEvent_t mInput{},mReady{}; CUevent mConsumer{};
    ExtStressGpuSolver* mSolver{}; ExtStressGpuSolveParams mParams;
    PxDestructionStressChunk* mChunks{}; PxDestructionStressCluster* mClusters{};
    PxTransform* mPoses{}; PxVec3* mAngular{};
    ConstraintLookup* mConstraintMap{};
    PxvDestructionConstraintBinding* mConstraintBindings{};
    std::set<PxU32> mManagedConstraintIds;
    PxU32 mConstraintCount=0;
    PxDestructionChunkLoad* mChunkLoads{};
    // Per-cluster sums of the chunk commands, four vectors a cluster (validateChunkCommands).
    PxVec3* mChunkCommandSums{};
    // The same, per correction candidate (sumCorrectionCommands), keyed by root chunk.
    PxVec3* mCorrectionCommandSums{};
    // The command share each correction candidate received, keyed by root
    // chunk (prepareCorrectionBodyInputs), and whether the next checkpoint is
    // a corrected start-of-tick one that must carry them (carryCorrectionCommands).
    PxgBodySimVelocities* mCorrectionCommandDeltas{};
    // Per-cluster command magnitudes for the command audit's rounding bound (chunkCommandSumsMatch).
    float* mChunkCommandScales{};
    bool mCarryCorrectionCommands=false;
    // fragmentGravity with chunk commands: fragments installed weightless by a
    // pass that re-solves (their command share carries their weight), given
    // scene gravity when the tick completes. Count at mDeferredGravity[mN].
    PxU32* mDeferredGravity{};
    std::vector<PxDestructionChunkLoad> mHostChunkLoads;
    bool mChunkLoadsFresh=false;
    // Chunk commands are this pass's inputs on every pass that may still
    // re-solve: the trial and each corrected pass below the limit. The pass at
    // the limit applies its split at end-of-tick motion, without another
    // solve, so it reapplies no command (limit 1: the trial only, as before).
    const PxDestructionChunkLoad* passChunkLoads() const {return mPass<mCorrectionLimit?mChunkLoads:nullptr;}
    // Idle gate (see watchClusterBodies). mIdleCertified: the last full
    // evaluation was a fixed point and its inputs equalled the frame before
    // (so moving bodies never certify), so a frame with bitwise-equal inputs
    // may skip it. A skipped frame keeps its arguments: if the device finds its
    // inputs differ after all, finish() evaluates the same frame in full.
    struct IdleFrame {
        PxReal dt; PxVec3 gravity; PxgDestructionMotionStorage storage; CUstream producer;
        PxgDestructionGrowMotionStorage grow; void* owner; PxgDestructionSolvedContacts contacts;
        PxgDestructionCollisionStorage collision;
    };
    IdleBody* mIdleBodies{};
    IdleFrame mIdleFrame{};
    PxReal mIdleDt=0; PxVec3 mIdleGravity{0.0f};
    bool mIdleGate=true, mIdleCertified=false, mIdleSkipped=false, mIdleFull=false;
    Lookup* mMap{}; PxU32 mMapCount{},mN{},mM{},mC{};
    bool mOwnInputs=false;
    PxDestructionVectorPair* mInputs{}; PxDestructionSurfaceLoad* mSurface{};
    // Solve report: the stress inputs after each source (3*mN: prepared loads,
    // + constraint loads, + contact loads), copied only while the report is on.
    PxDestructionVectorPair* mReportInputs{}; bool mReport=false;
    // Which passes record (bit p: pass p; bit 31 also covers passes >= 31);
    // the solver's own report follows the pass about to be solved.
    PxU32 mReportPasses=0; bool mSolverReporting=false;
    // Producers write canonical completion records in one allocation. Their
    // public device addresses stay distinct; mandatory CPU observation is one
    // pinned transfer, not a status-copy chain between device stages.
    struct Completion {
        PxDestructionStageStatus stage;
        PxU32 propertyCount, shapeCount;
        PxDestructionBodyPreparationStatus body;
        PxDestructionBodyAllocationStatus allocation;
        PxDestructionCollisionPreparationStatus collision;
        PxDestructionCorrectionPreparationStatus correction;
        PxU32 idle; // IdleObservation bits for this frame
    };
    static_assert(offsetof(Completion,propertyCount)==sizeof(PxDestructionStageStatus),"final status readback layout");
    Completion *mCompletion{},*mHostCompletion{};
    PxDestructionStageStatus* mStatus{}; PxDestructionStageStatus* mHostStatus{};
    PxDestructionMaterial* mMaterials{};PxDestructionStressBond* mBonds{};
    float *mHealth{},*mRates{};PxU32 *mNodeBegin{},*mNodeRefs{};
    PxVec3* mBondCentroids{};PxDestructionBondVerdict* mVerdicts{};
    PxDestructionCrushState *mCrush{},*mTrialCrush{};
    float mDamageRate=2,mBendGain=3;bool mFibres=true;
    PxDestructionBondSection* mSections{};bool mSectionBending=false,mSectionRotation=false; // opt-in real sections (PX_DESTRUCTION_SECTION_BENDING)
    // Impact capacity (PX_DESTRUCTION_IMPACT_CAPACITY, PxgDestructionImpact.cuh):
    // the island solve, the ramp's start (the forces before this tick's trial
    // solve), per-material ductile slip and stiffness.
    impact::Stage mImpact;impact::Settings mImpactSettings;bool mImpactEnabled=false;
    // mImpactBase: the elastic forces before this tick; mImpactState: the forces
    // the last evaluation settled on (E's where it solved), mImpactStart: those
    // at the start of this tick (kept for its corrected pass).
    PxDestructionVectorPair *mImpactBase{},*mImpactState{},*mImpactStart{};float *mImpactSlip{},*mImpactStiffness{};
    // The impact step's rest state: each bond's elastic forces from the last
    // tick its island had no impact patch (the step's J0; an impact's own
    // tick-long contact loads are no preload for the next tick's step).
    PxDestructionVectorPair* mImpactRest{};
    // The plastic state the impact solve leaves: which bonds' forces are its
    // (mImpactCarried) and each bond's accumulated plastic slip; *Start: at
    // the start of this tick (the corrected pass starts there too).
    PxU32 *mImpactCarried{},*mImpactCarriedStart{};float *mImpactSlipState{},*mImpactSlipStart{};
    impact::Status* mImpactHostStatus{};
    // Impact-pressure crush (Ci): per-chunk impact stress and strain rate of
    // this pass's contacts, and the non-destructible impactors' impedance.
    bool mImpactCrush=false;float *mImpactStress{},*mImpactRate{},*mImpactEnergy{};PxU32* mImpactImpactor{};
    bool mCrushEnergyBound=false;PxU32* mImpactStriker{};float* mCrushDemand{};PxU32 mCrushDemandCapacity=0;float* mCrushBoundAudit{};
    bool mAnchoredBound=false,mAnchoredReady=false;float4* mAnchoredChunks{};float4* mAnchoredBonds{};PxU32 *mAnchoredSaturated{},*mAnchoredGhosts{};
    ImpactorImpedance* mImpactors{};PxU32 mImpactorCount=0,mImpactorCapacity=0;
    // The impact solve's coupled contact: this pass's rows, their count, and
    // each impactor's velocity change (applied when the pass is the tick's last).
    impact::ContactRow* mImpactRows{};PxU32* mImpactRowCount{};float *mImpactRowDelta{},*mImpactRowForce{},*mImpactRowBound{};
    PxU32* mImpactRowRouted{};   // per row: routed to the impact model (Settings::route)
    // Per rigid body (motion storage capacity): the corrected pass's bound on
    // its contacts (max impulse per point; bits of a float), its own max
    // impulse before (to restore), and whether it is bounded.
    float *mImpactBound{},*mImpactSaved{};PxU32 *mImpactBounded{},*mImpactBoundRequested{};PxU32 mImpactBoundCapacity=0;
    // PX_DESTRUCTION_IMPACT_LOG=1: print E's counters after every evaluation
    // that solved an island (synchronises the stream: diagnostics only).
    const bool mImpactLog=[]{const char* v=std::getenv("PX_DESTRUCTION_IMPACT_LOG");return v && v[0]=='1';}();
    // PX_DESTRUCTION_IMPACT_CAPTURE=DIR: write the inputs of evaluations that
    // take longer than PX_DESTRUCTION_IMPACT_CAPTURE_MS (default 1000) to
    // DIR/impact-<frame>-<pass>.impc, at most PX_DESTRUCTION_IMPACT_CAPTURE_COUNT
    // (default 4) -- for tests/impact_capture_replay (implies the log's sync).
    const char* mImpactCaptureDir=std::getenv("PX_DESTRUCTION_IMPACT_CAPTURE");
    // The corrected pass's elastic solve warm-started from the tick's start (opt-in).
    const bool mCorrectedWarmStart=[]{const char* v=std::getenv("PX_DESTRUCTION_CORRECTED_WARM_START");return v && v[0]=='1';}();
    PxU32 mImpactCaptures=0,mImpactMaterialCount=0;PxU64 mImpactEvaluations=0;impact::SolveRecord* mImpactRecords{};
    // PX_DESTRUCTION_IMPACT_CAPTURE_STATIC=N (with the capture directory and
    // the log): capture a pass whose static verdict breaks N or more bonds,
    // and the evaluation before it (diagnostics; 0 off).
    const PxU32 mImpactStaticCapture=[this]{const char* v=std::getenv("PX_DESTRUCTION_IMPACT_CAPTURE_STATIC");
        return (v && mImpactCaptureDir)?PxU32(std::max(0,std::atoi(v))):0u;}();
    float mFragmentMaxPenBias=-1e32f; // negative PhysX clamp; -1e32 leaves inheritance alone
    PxgDestructionTopologyTransaction* mTopology{};
    committedChanges::Publication mChanges;
    PxDestructionClusterMotion* mProvisionalMotion{};
    PxDestructionClusterBodyState* mTrialBodies{};
    PxDestructionBodyPreparationStatus* mBodyPreparation{};
    PxDestructionBodyPreparationStatus* mHostBodyPreparation{};
    PxvDestructionBodyAllocator* mBodyAllocator{};
    PxvDestructionBodyRequest* mBodyRequests{};
    PxvDestructionBodyRequest* mCompactBodyRequests{};
    PxU32* mReturnedBodyIndices{}; // GPU-selected; CPU consumes a compatibility observation
    PxU32* mGrantedMotionIndices{};
    PxDestructionMotionSlotStatus* mMotionSlots{};
    PxU32 mMotionSlotCapacity{},mCommittedMotionSlots{}; // capacity accounting, not allocation decisions
    NativeMotionAllocation mMotionAllocation;
    NativeCorrectionPreparation mDevicePreparation;
    PxgDestructionCollisionStorage mCollisionStorage{};
    bool mPreparationObserved=false;
    // Pinned staging for the correction path's host observations (chunkCount
    // records each). Copies into pageable vectors are synchronous in CUDA and
    // CuMetal alike, one host wait each; into these they stay on the stream,
    // and one synchronization observes them together.
    template<class T> struct Pinned {
        T* p=nullptr;
        void allocate(size_t n){check(cudaMallocHost(&p,sizeof(T)*std::max<size_t>(n,1)));}
        void release(){if(p)cudaFreeHost(p);p=nullptr;}
    };
    Pinned<PxvDestructionBodyRequest> mPinnedBodyRequests,mPinnedOwnerRequests;
    Pinned<PxU32> mPinnedReservedIndices,mPinnedOwnerTargets;
    Pinned<PxvDestructionConstraintBinding> mPinnedConstraintBindings;
    Pinned<PxDestructionCollisionBinding> mPinnedMigrating,mPinnedShapeOwners;
    Pinned<PxvDestructionBodyProperties> mPinnedProperties;
    // applyCorrectionBindings' readback, taken with prepareBodyCompatibility's.
    bool mOwnerMetadataPrefetched=false;
    // The final pass's acceptance is observed by finishPostCorrection, which
    // the controller always calls next, in its one synchronization.
    bool mTailAcceptancePending=false;
    PxgDestructionMotionStorage mMotionStorage{};
    PxgDestructionGrowMotionStorage mGrowMotionStorage{};void* mMotionStorageOwner{};
    CUstream mMotionProducerStream{};
    PxU32* mTrialBodyIndices{};
    // Principal frames by cluster root, reused while a tensor is unchanged
    // (destructionBody::cachedPrincipalFrame). CuMetal only: native double
    // makes the recomputation cheap on CUDA.
    destructionBody::PrincipalFrameCache* mPrincipalFrames{};
    PxvDestructionBodyRequest* mCorrectionOwnerRequests{};
    PxU32* mCorrectionOwnerTargets{};
    PxDestructionBodyAllocationStatus* mBodyAllocation{};
    PxDestructionBodyAllocationStatus mHostBodyAllocation{};
    PxDestructionBodyAllocationStatus* mBodyAllocationObservation{};
    cudaEvent_t mMotionAllocationEvents[2]{};bool mMotionTimingPending=false,mMotionTimingRetry=false;
    std::vector<PxU32> mHostReservedIndices;
    // Host mirror of stage-owned body indices: cluster parents at configure,
    // accepted fragments as they are committed. Read by ownsBody() only.
    std::set<PxU32> mHostOwnedBodies;
    // Bodies reserved during the current tick (bornThisTick).
    std::set<PxU32> mTickBodies;
    PxU32 mCorrectionBlockers=0;
    bool mCompatibilityPrepared=false;
    PxU32* mAffectedClusters{};PxU32* mCandidateSlots{};
    PxDestructionStressShape* mHullBindings{};PxU32 mHullCount=0;
    PxDestructionCollisionBinding *mCollisionBindings{},*mCompactCollisionBindings{};
    // Compact observation for the remaining CPU ownership mirror. Retained
    // shapes stay exclusively in the complete GPU collision transaction.
    PxDestructionCollisionBinding* mMigratingCollisionBindings{};
    PxU64* mShapeOwnerGenerations{};
    PxU32 mShapeOwnerCapacity{};
    PxU64 mInstalledOwnerGeneration{};
    PxDestructionCollisionPreparationStatus* mCollisionPreparation{};
    void* mCollisionScratch{};size_t mCollisionScratchBytes{};
    PxgDestructionEdit* mTopologyEdits{};PxU32* mTopologyCount{};PxU32* mTopologyAccept{};PxU32 mEditCapacity{};
    PxDestructionCorrectionBody *mCorrectionBodies{},*mCompactCorrectionBodies{};
    PxDestructionCorrectionPreparationStatus* mCorrectionPreparation{};
    void* mCorrectionScratch{};size_t mCorrectionScratchBytes{};
    PxU64* mPropertyEpochs{};PxU32* mPropertyCount{};PxU32 mPendingPropertyCapacity=0;
    PxU64* mShapePublicationEpochs{};PxU32* mShapePublicationTargets{};PxU32 mPendingShapeCapacity=0;
    PxU32 mCorrectionBodyCapacity{};
    bool mCollisionPreparationSubmitted=false,mCorrectionPreparationSubmitted=false;
    PxU64 mRestoredCheckpointGeneration{};
    PxgBodySim* mCheckpointBodies{};
    PxgBodySimVelocities* mCheckpointCommands{};
    PxgBodySimVelocities* mCheckpointPrevious{};
    PxgRigidBodyAcceleration* mCheckpointAccelerations{};
    PxU32 mCheckpointCapacity{},mCheckpointCount{};
    PxU64 mCheckpointGeneration{};
    bool mCheckpointHasPrevious=false,mCheckpointHasAccelerations=false,mCheckpointValid=false;
    cudaEvent_t mCheckpointReady{};
    PxU32* mGraphRetiredMask{};
    PxU32 *mGraphRetired{},*mGraphHostRetired{};
    PxU32 mGraphRetiredCapacity{};
    PxU32 *mGraphAccurate{},*mGraphSpeculative{};
    PxgDestructionContactGraphStatus* mGraphStatus{};
    PxU32 mGraphPairCapacity{},mGraphNodeCapacity{};
    PxgDestructionContactGraphView mGraphView{};
    const PxgContactGraphSequence* mContactSequence{}; // borrowed scene-lifetime device allocator
    PxU64 mGraphGeneration{};
    void* mPreNodeStorage=nullptr;
    PxvPreSolveNode *mPreNodes{},*mPrePrevious{};
    PxU32 mPreRegistryCapacity{};
    PxvPreSolveNodeUpdate* mPreUpdates{};
    PxU32 mPreUpdateCapacity{};
    PxU32 *mPreRetired{},*mPreRetiredMask{};
    PxU32 mPreRetiredCapacity{},mPrePairCapacity{};
    PxgDestructionContactGraphStatus* mPreContactStatus{};
    bool mPreRosterValid=false;
    PxvPreSolveEdge* mPreMerges{};
    PxU32 *mPreParents{},*mPreLabels{},*mPreTouches{},*mPreSupport{};
    PxU32 mPreCapacity{},mPrePreviousCount{},mPreMergeCapacity{},mPreParentCapacity{};
    cudaEvent_t mPreReady{};
    PxU64 mPreSourceGraphGeneration{};

    cudaEvent_t mGraphReady{};
    NativeRigidIterationLimits mRigidIterationLimits;
    bool mPending=false; bool mFailed=false;
    bool mWarmImported=false, mEverDamaged=false;
    bool mCorrectionEnabled=false, mGpuIslandRepair=false;
    // Opt-in (PX_DESTRUCTION_ALLOW_UNCONVERGED=1): publish a step whose stress
    // solve did not converge instead of rejecting it (pre-6938aa7d behaviour).
    // Material verdicts then use the unconverged forces. Development only.
    const bool mAllowUnconverged=[]{const char* v=std::getenv("PX_DESTRUCTION_ALLOW_UNCONVERGED");return v && v[0]=='1';}();
    PxU32 *mGraphHostAccurate{}, *mGraphHostSpeculative{};
    PxU64 *mGraphKeys{}, *mGraphSortedKeys{}, *mGraphHostAccurateMembers{}, *mGraphHostSpeculativeMembers{};
    PxgDestructionContactGraphStatus* mGraphHostStatus{}; // pinned: observation status readback
    PxgDestructionRetainedEdge *mGraphRetainedEdges{},*mGraphHostRetainedEdges{};
    PxU32 mGraphRetainedEdgeCapacity{};
    PxgDestructionRetainedEdge* mGraphRetainedSlots{};
    PxU32 *mGraphRetainedActive{},*mGraphRetainedCounts{};
    PxU32 mGraphRetainedSlotCapacity{};
    PxU32 mGraphObservationCapacity{};
    PxgDestructionContactGraphObservationStats mGraphObservationStats{};
    void* mGraphSortScratch{};
    size_t mGraphSortScratchBytes{};
    std::vector<PxU32> mHostCorrectionTargets;
public:
    Runtime(CUcontext c,void* scene,bool(*gate)(void*),PxvDestructionBodyAllocator* allocator) : mContext(c),mScene(scene),mWriteAllowed(gate),mBodyAllocator(allocator) {
        Context current(c);
        mRigidIterationLimits.initialize();
        {const char* raw=::getenv("PX_DESTRUCTION_IDLE_GATE");mIdleGate=!(raw && raw[0]=='0');}
        check(cudaStreamCreateWithFlags(&mStream,cudaStreamNonBlocking));
        check(cudaEventCreateWithFlags(&mInput,cudaEventDisableTiming));
        check(cudaEventCreateWithFlags(&mReady,cudaEventDisableTiming));
        check(cudaEventCreateWithFlags(&mCheckpointReady,cudaEventDisableTiming));
        check(cudaEventCreateWithFlags(&mGraphReady,cudaEventDisableTiming));
        check(cudaEventCreateWithFlags(&mPreReady,cudaEventDisableTiming));
        check(cudaEventRecord(mPreReady,mStream));
        allocate(mCompletion,1);
        check(cudaMallocHost(&mHostCompletion,sizeof(*mHostCompletion)));
        std::memset(mHostCompletion,0,sizeof(*mHostCompletion));
        check(cudaMemset(mCompletion,0,sizeof(*mCompletion)));
        mStatus=&mCompletion->stage;mHostStatus=&mHostCompletion->stage;
        check(cudaEventRecord(mReady,mStream));
    }
    PxgAnchoredContactBoundView anchoredContactBoundView() const override {
        PxgAnchoredContactBoundView v{};
        if(!mAnchoredBound || !mAnchoredReady || !mMap || !mN)return v;
        v.map=reinterpret_cast<const PxU32*>(mMap);v.mapCount=mMapCount;v.chunkCount=mN;v.chunks=reinterpret_cast<const PxReal*>(mAnchoredChunks);
    v.nodeBegin=mNodeBegin;v.nodeRefs=mNodeRefs;v.bonds=reinterpret_cast<const PxReal*>(mAnchoredBonds);
        return v;
    }
    bool prepareRigidIterationLimits(const PxgBodySim* bodies,PxU32 capacity,const PxNodeIndex* active,PxU32 offset,PxU32 count,CUstream stream) override {
        if(mFailed)return false;
        try {Context current(mContext);mRigidIterationLimits.prepare(bodies,capacity,active,offset,count,reinterpret_cast<cudaStream_t>(stream));return true;}
        catch(...){mFailed=true;return false;}
    }
    bool readRigidIterationLimits(PxU32& position,PxU32& velocity) override {
        if(mFailed)return false;
        try {Context current(mContext);mRigidIterationLimits.read(position,velocity);return true;}
        catch(...){mFailed=true;return false;}
    }
    void setProfiler(PxProfilerCallback* callback,PxU64 context) override {mProfiler=callback;mProfileContext=context;}
    bool buildContactInputs(PxgContactManagerInput* inputs,PxU32 count,
        const PxgShapeSim* shapes,PxU32 shapeCapacity,CUstream stream) override {
        if(mFailed || !mCorrectionEnabled || !stream || (count && (!inputs || !shapes || !shapeCapacity)))return false;
        try {
            Context current(mContext);
            if(count)buildNativeContactInputs<<<(count+127)/128,128,0,reinterpret_cast<cudaStream_t>(stream)>>>(inputs,count,shapes,shapeCapacity);
            check(cudaGetLastError());return true;
        }catch(...){mFailed=true;return false;}
    }
    PxU32 getShapeContactIndex(const PxShape& shape) const override {
        return mBodyAllocator && mWriteAllowed(mScene)?mBodyAllocator->getShapeContactIndex(shape):PX_INVALID_U32;
    }
    bool readRigidBodyData(void* data,const PxRigidDynamicGPUIndex* indices,PxRigidDynamicGPUAPIReadType::Enum type,
        PxU32 count,CUevent start,CUevent finish) const override {
        return !mFailed && mWriteAllowed(mScene) && mBodyAllocator
            && mBodyAllocator->readRigidBodyData(data,indices,type,count,start,finish);
    }
    bool canBuildPreSolveIslands() const override { return mBodyAllocator && mBodyAllocator->supportsGpuIslandRepair(); }
    const PxvPreSolveNode* preSolveNodeView() const override { return mPrePrevious; }
    const PxvPreSolveNode* nativeNodeView() const override { return mPreNodes; }
    const PxU32* preSolveSupportView() const override { return mPreSupport; }
    bool preSolveNodeSnapshotRequired(PxU32) const override { return !mPreRosterValid; }
#include "PxgPreSolveStorage.inl"
    bool buildPreSolveIslands(const PxvPreSolveNodeUpdate* updates,PxU32 updateCount,PxU32 count,bool fullSnapshot,
        const PxvPreSolveEdge* merges,PxU32 mergeCount,CUstream stream,
        const PxU32*& labels,const PxU32*& staticTouches,const PxgDestructionPreSolveContacts* contacts=nullptr) override {
        labels=nullptr;staticTouches=nullptr;
        if(mFailed || !stream || (updateCount && !updates) || (mergeCount && !merges))return false;
        if(contacts) {
            if((contacts->pairCount && (!contacts->inputs || !contacts->identities || !contacts->outputs || !contacts->shapes))
                || (contacts->retiredCount && !contacts->retired))return false;
            for(PxU32 i=0;i<contacts->retiredCount;++i)if(contacts->retired[i]>=contacts->pairCount)return false;
        }
        if((preSolveNodeSnapshotRequired(count) && !fullSnapshot) || (fullSnapshot && updateCount!=count))return false;
        for(PxU32 i=0;i<updateCount;++i)
            if(updates[i].index>=count || (i && updates[i-1].index>=updates[i].index)
                || updates[i].value.live>1 || (updates[i].value.live && !updates[i].value.lifetime)
                || (fullSnapshot && updates[i].index!=i))return false;
        try {
            Context current(mContext);const auto cudaStream=reinterpret_cast<cudaStream_t>(stream);
            check(cudaStreamWaitEvent(cudaStream,mPreReady,0));
            // Native births are produced by allocation, independently of the
            // CPU materializer. Order the roster consumer after that producer.
            check(cudaStreamWaitEvent(cudaStream,mReady,0));
            if(mGraphView.generation)check(cudaStreamWaitEvent(cudaStream,mGraphReady,0));
            bool usable=mPrePreviousCount && mGraphView.generation && mGraphView.nodeCapacity>=mPrePreviousCount
                && mPreSourceGraphGeneration!=~PxU64(0) && mGraphView.generation==mPreSourceGraphGeneration+1;
            // Growth preserves both rosters and the previous graph certificate.
            // New handle holes are initialized below before applying deltas.
            // The registry and the phase storage double independently, so the
            // phase storage can outgrow the registry, and a count between the
            // two then indexed and copied past the registry's end (CuMetal
            // refused the copy; CUDA read and wrote out of bounds). Grow the
            // registry for every count, not only when the phase storage grows.
            growNativeNodeStorage(count,cudaStream);
            if(count>mPreCapacity)growPreSolveStorage(count,cudaStream);
            if(updateCount>mPreUpdateCapacity) {
                check(cudaEventSynchronize(mPreReady));cudaFree(mPreUpdates);mPreUpdates=nullptr;
                const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(updateCount,2ull*mPreUpdateCapacity)));
                allocate(mPreUpdates,capacity);mPreUpdateCapacity=capacity;
            }
            if(mergeCount>mPreMergeCapacity) {
                check(cudaEventSynchronize(mPreReady));cudaFree(mPreMerges);mPreMerges=nullptr;
                const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(mergeCount,2ull*mPreMergeCapacity)));
                allocate(mPreMerges,capacity);mPreMergeCapacity=capacity;
            }
            const PxU64 parentCount=PxU64(count)+mGraphView.nodeCapacity;
            if(parentCount>~PxU32(0))throw std::runtime_error("pre-solve island domain overflow");
            if(parentCount>mPreParentCapacity){
                check(cudaEventSynchronize(mPreReady));cudaFree(mPreParents);mPreParents=nullptr;
                const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(parentCount,2ull*mPreParentCapacity)));
                allocate(mPreParents,capacity);mPreParentCapacity=capacity;
            }
            if(contacts) {
                if(contacts->retiredCount>mPreRetiredCapacity) {
                    check(cudaEventSynchronize(mPreReady));cudaFree(mPreRetired);mPreRetired=nullptr;
                    const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(contacts->retiredCount,2ull*mPreRetiredCapacity)));
                    allocate(mPreRetired,capacity);mPreRetiredCapacity=capacity;
                }
                if(contacts->pairCount>mPrePairCapacity) {
                    check(cudaEventSynchronize(mPreReady));cudaFree(mPreRetiredMask);mPreRetiredMask=nullptr;
                    const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(contacts->pairCount,2ull*mPrePairCapacity)));
                    allocate(mPreRetiredMask,(size_t(capacity)+31)/32);mPrePairCapacity=capacity;
                }
                if(!mPreContactStatus)allocate(mPreContactStatus,1);
            }
            // Native node domains can grow across unused handle holes. Those
            // holes must start inactive even when the allocation already fits.
            if(count>mPrePreviousCount)clearNewNativeNodeRange<<<(PxU64(count-mPrePreviousCount)+127)/128,128,0,cudaStream>>>(
                mPreNodes,mPrePreviousCount,count,mMotionAllocation.addressView(),mMotionSlots);
            if(updateCount) {
                check(cudaMemcpyAsync(mPreUpdates,updates,size_t(updateCount)*sizeof(*updates),cudaMemcpyHostToDevice,cudaStream));
                destructionPreSolve::updateNodes<<<(updateCount+127)/128,128,0,cudaStream>>>(mPreUpdates,updateCount,mPreNodes,count);
            }
            const bool deriveSupport=contacts && contacts->deriveStaticSupport;
            if(usable && count) {
                if(deriveSupport)check(cudaMemsetAsync(mPreSupport,0,size_t(count)*sizeof(PxU32),cudaStream));
                if(mergeCount)check(cudaMemcpyAsync(mPreMerges,merges,size_t(mergeCount)*sizeof(*merges),cudaMemcpyHostToDevice,cudaStream));
                destructionPreSolve::initialize<<<(parentCount+127)/128,128,0,cudaStream>>>(mPreParents,PxU32(parentCount),mPreTouches,count);
                destructionPreSolve::seed<<<(count+127)/128,128,0,cudaStream>>>(mPreNodes,count,mPrePrevious,mPrePreviousCount,
                    mGraphView.accurateLabels,mGraphView.nodeCapacity,mPreParents,&mGraphView.status->error);
                if(mergeCount) {
                    if(deriveSupport)destructionPreSolve::connectSupportBridges<<<(mergeCount+127)/128,128,0,cudaStream>>>(mPreMerges,mergeCount,mPreNodes,count,mPreParents,mPreSupport);
                    else destructionPreSolve::connect<<<(mergeCount+127)/128,128,0,cudaStream>>>(mPreMerges,mergeCount,mPreNodes,count,mPreParents);
                }
                if(contacts) {
                    check(cudaMemsetAsync(mPreContactStatus,0,sizeof(*mPreContactStatus),cudaStream));
                    if(contacts->retiredCount) {
                        check(cudaMemsetAsync(mPreRetiredMask,0,((size_t(contacts->pairCount)+31)/32)*sizeof(PxU32),cudaStream));
                        check(cudaMemcpyAsync(mPreRetired,contacts->retired,size_t(contacts->retiredCount)*sizeof(PxU32),cudaMemcpyHostToDevice,cudaStream));
                        destructionContactGraph::retire<<<(contacts->retiredCount+127)/128,128,0,cudaStream>>>(mPreRetired,contacts->retiredCount,contacts->pairCount,mPreRetiredMask,mPreContactStatus);
                    }
                    if(contacts->pairCount)destructionPreSolve::connectContacts<<<(contacts->pairCount+127)/128,128,0,cudaStream>>>(*contacts,
                        contacts->retiredCount?mPreRetiredMask:nullptr,mPreNodes,count,mPreParents,mPreContactStatus,deriveSupport?mPreSupport:nullptr);
                    destructionPreSolve::requireValidContacts<<<1,1,0,cudaStream>>>(mPreContactStatus);
                }
                destructionPreSolve::finish<<<(count+127)/128,128,0,cudaStream>>>(mPreNodes,count,mPreParents,mPreLabels,mPreTouches,deriveSupport?mPreSupport:nullptr);
                labels=mPreLabels;staticTouches=mPreTouches;
            }
            if(count)check(cudaMemcpyAsync(mPrePrevious,mPreNodes,size_t(count)*sizeof(PxvPreSolveNode),cudaMemcpyDeviceToDevice,cudaStream));
            check(cudaGetLastError());check(cudaEventRecord(mPreReady,cudaStream));mPrePreviousCount=count;mPreSourceGraphGeneration=mGraphView.generation;mPreRosterValid=true;
            return true;
        }catch(...){mFailed=true;labels=nullptr;staticTouches=nullptr;return false;}
    }
    bool buildContactGraph(const PxgContactManagerInput* inputs,const PxgContactGraphIdentity* identities,
        const PxsContactManagerOutput* outputs,PxU32 count,PxU32 omitted,const PxgShapeSim* shapes,
        PxU32 shapeCapacity,PxU32 nodeCapacity,const PxU32* retired,PxU32 retiredCount,CUstream stream,
        const PxgDestructionRetainedEdge* retainedEdges,PxU32 retainedEdgeCount,PxU32 retainedSlotCount,const PxgContactGraphSequence* sequence) override {
        if(mFailed || !mCorrectionEnabled || !stream || mGraphGeneration==~PxU64(0))return false;
        if((count && (!inputs || !identities || !outputs || !shapes)) || (retiredCount && !retired) || (retainedEdgeCount && !retainedEdges))return false;
        try {
            // Validate host command framing before acknowledging the producer's
            // delta log. Endpoint/graph computation remains on CUDA.
            for(PxU32 i=0;i<retainedEdgeCount;++i)
                if(retainedEdges[i].edgeIndex>=retainedSlotCount || (i && retainedEdges[i-1].edgeIndex>=retainedEdges[i].edgeIndex))
                    throw std::runtime_error("Invalid retained-contact lifecycle transaction");
            Context current(mContext);
            check(cudaStreamWaitEvent(reinterpret_cast<cudaStream_t>(stream),mPreReady,0));
            // Storage grows explicitly, never truncates. Prior producer work
            // must finish before reallocating a published snapshot's buffers.
            if(count>mGraphPairCapacity || nodeCapacity>mGraphNodeCapacity) {
                PxProfileScoped zone_growPairsNodes(mProfiler,"GpuDestruction.graph.growPairsNodes",false,mProfileContext);
                if(std::getenv("PX_DESTRUCTION_LOG_GRAPH_GROWTH"))
                    std::fprintf(stderr,"[destruction] contact graph grows: pairs %u > %u or nodes %u > %u\n",count,mGraphPairCapacity,nodeCapacity,mGraphNodeCapacity);
                check(cudaEventSynchronize(mPreReady));
                if(mGraphView.generation)check(cudaEventSynchronize(mGraphReady));
                if(count>mGraphPairCapacity) {
                    // Headroom: growing to exactly the count regrew the next tick
                    // (21974 then 23790 pairs after a split), waiting on a busy GPU.
                    const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(PxU64(count)+count/2,2ull*mGraphPairCapacity)));
                    check(cudaFree(mGraphRetiredMask));mGraphRetiredMask=nullptr;
                    allocate(mGraphRetiredMask,(size_t(capacity)+31)/32);
                    mGraphPairCapacity=capacity;
                }
                if(nodeCapacity>mGraphNodeCapacity) {
                    // Keep ownership of successful allocations on later failure.
                    const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(PxU64(nodeCapacity)+nodeCapacity/2,2ull*mGraphNodeCapacity)));
                    check(cudaFree(mGraphAccurate));mGraphAccurate=nullptr;allocate(mGraphAccurate,capacity);
                    check(cudaFree(mGraphSpeculative));mGraphSpeculative=nullptr;allocate(mGraphSpeculative,capacity);
                    mGraphNodeCapacity=capacity;
                }
            }
            if(retiredCount) {
                // Upload only existing lifecycle deltas, never body motion or
                // a CPU-computed component graph. Retain pinned staging until
                // the ordered producer has consumed it.
                PxProfileScoped zone_retiredWait(mProfiler,"GpuDestruction.graph.retiredWait",false,mProfileContext);
                if(mGraphView.generation)check(cudaEventSynchronize(mGraphReady));
                if(retiredCount>mGraphRetiredCapacity) {
                    const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(retiredCount,2ull*mGraphRetiredCapacity)));
                    check(cudaFree(mGraphRetired));mGraphRetired=nullptr;allocate(mGraphRetired,capacity);
                    check(cudaFreeHost(mGraphHostRetired));mGraphHostRetired=nullptr;
                    check(cudaMallocHost(&mGraphHostRetired,size_t(capacity)*sizeof(PxU32)));mGraphRetiredCapacity=capacity;
                }
                std::copy(retired,retired+retiredCount,mGraphHostRetired);
            }
            if(retainedSlotCount>mGraphRetainedSlotCapacity) {
                PxProfileScoped zone_growRetainedSlots(mProfiler,"GpuDestruction.graph.growRetainedSlots",false,mProfileContext);
                if(std::getenv("PX_DESTRUCTION_LOG_GRAPH_GROWTH"))
                    std::fprintf(stderr,"[destruction] retained contact slots grow: %u > %u\n",retainedSlotCount,mGraphRetainedSlotCapacity);
                if(mGraphView.generation)check(cudaEventSynchronize(mGraphReady));
                const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(retainedSlotCount,2ull*mGraphRetainedSlotCapacity)));
                PxgDestructionRetainedEdge* nextSlots=nullptr;PxU32* nextActive=nullptr;
                try {
                    allocate(nextSlots,capacity);allocate(nextActive,(size_t(capacity)+31)/32);
                    check(cudaMemset(nextActive,0,((size_t(capacity)+31)/32)*sizeof(PxU32)));
                    if(mGraphRetainedSlotCapacity) {
                        check(cudaMemcpy(nextSlots,mGraphRetainedSlots,size_t(mGraphRetainedSlotCapacity)*sizeof(*nextSlots),cudaMemcpyDeviceToDevice));
                        check(cudaMemcpy(nextActive,mGraphRetainedActive,((size_t(mGraphRetainedSlotCapacity)+31)/32)*sizeof(PxU32),cudaMemcpyDeviceToDevice));
                    }
                } catch(...) {cudaFree(nextSlots);cudaFree(nextActive);throw;}
                auto* oldSlots=mGraphRetainedSlots;auto* oldActive=mGraphRetainedActive;
                mGraphRetainedSlots=nextSlots;mGraphRetainedActive=nextActive;mGraphRetainedSlotCapacity=capacity;
                check(cudaFree(oldSlots));check(cudaFree(oldActive));
                mGraphObservationStats.retainedSlotCapacity=capacity;
            }
            if(!mGraphRetainedCounts) {
                allocate(mGraphRetainedCounts,3);check(cudaMemset(mGraphRetainedCounts,0,3*sizeof(PxU32)));
            }
            if(retainedEdgeCount) {
                PxProfileScoped zone_retainedEdgesWait(mProfiler,"GpuDestruction.graph.retainedEdgesWait",false,mProfileContext);
                if(mGraphView.generation)check(cudaEventSynchronize(mGraphReady));
                if(retainedEdgeCount>mGraphRetainedEdgeCapacity) {
                    const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(retainedEdgeCount,2ull*mGraphRetainedEdgeCapacity)));
                    check(cudaFree(mGraphRetainedEdges));mGraphRetainedEdges=nullptr;allocate(mGraphRetainedEdges,capacity);
                    check(cudaFreeHost(mGraphHostRetainedEdges));mGraphHostRetainedEdges=nullptr;
                    check(cudaMallocHost(&mGraphHostRetainedEdges,size_t(capacity)*sizeof(PxgDestructionRetainedEdge)));
                    mGraphRetainedEdgeCapacity=capacity;
                }
                std::copy(retainedEdges,retainedEdges+retainedEdgeCount,mGraphHostRetainedEdges);
            }
            if(!mGraphStatus)allocate(mGraphStatus,1);
            const auto cudaStream=reinterpret_cast<cudaStream_t>(stream);
            destructionContactGraph::initialize<<<(std::max(nodeCapacity,1u)+127)/128,128,0,cudaStream>>>(mGraphAccurate,mGraphSpeculative,nodeCapacity,mGraphStatus,omitted,sequence);
            if(retiredCount) {
                if(count)check(cudaMemsetAsync(mGraphRetiredMask,0,((size_t(count)+31)/32)*sizeof(PxU32),cudaStream));
                check(cudaMemcpyAsync(mGraphRetired,mGraphHostRetired,size_t(retiredCount)*sizeof(PxU32),cudaMemcpyHostToDevice,cudaStream));
                destructionContactGraph::retire<<<(retiredCount+127)/128,128,0,cudaStream>>>(mGraphRetired,retiredCount,count,mGraphRetiredMask,mGraphStatus);
            }
            if(count) {
                destructionContactGraph::connect<<<(count+127)/128,128,0,cudaStream>>>(inputs,identities,outputs,count,shapes,shapeCapacity,nodeCapacity,mGraphStatus,retiredCount?mGraphRetiredMask:nullptr,mGraphAccurate,mGraphSpeculative);
            }
            if(retainedEdgeCount) {
                check(cudaMemcpyAsync(mGraphRetainedEdges,mGraphHostRetainedEdges,size_t(retainedEdgeCount)*sizeof(PxgDestructionRetainedEdge),cudaMemcpyHostToDevice,cudaStream));
                mGraphObservationStats.retainedDeltaUpdates+=retainedEdgeCount;
                for(PxU32 i=0;i<retainedEdgeCount;++i)
                    mGraphObservationStats.retainedEdgesUploaded+=!(retainedEdges[i].flags&PxgDestructionRetainedEdge::eREMOVED);
                mGraphObservationStats.retainedHostToDeviceBytes+=PxU64(retainedEdgeCount)*sizeof(PxgDestructionRetainedEdge);
                check(cudaMemsetAsync(mGraphRetainedCounts+2,0,sizeof(PxU32),cudaStream));
                destructionContactGraph::validateRetainedUpdates<<<(retainedEdgeCount+127)/128,128,0,cudaStream>>>(mGraphRetainedEdges,retainedEdgeCount,
                    retainedSlotCount,mGraphRetainedCounts,mGraphStatus);
                destructionContactGraph::applyRetainedUpdates<<<(retainedEdgeCount+127)/128,128,0,cudaStream>>>(mGraphRetainedEdges,retainedEdgeCount,
                    mGraphRetainedSlots,retainedSlotCount,mGraphRetainedActive,mGraphRetainedCounts,mGraphStatus);
                destructionContactGraph::finishRetainedUpdates<<<1,1,0,cudaStream>>>(mGraphRetainedCounts);
            }
            if(retainedSlotCount) {
                const PxU32 slots=PxU32(((size_t(retainedSlotCount)+31)/32)*32);
                destructionContactGraph::connectRetainedSlots<<<(slots+127)/128,128,0,cudaStream>>>(mGraphRetainedSlots,mGraphRetainedActive,retainedSlotCount,
                    nodeCapacity,mGraphAccurate,mGraphSpeculative,mGraphStatus);
            }
            if(nodeCapacity)destructionContactGraph::compress<<<(nodeCapacity+127)/128,128,0,cudaStream>>>(mGraphAccurate,mGraphSpeculative,nodeCapacity);
            check(cudaGetLastError());check(cudaEventRecord(mGraphReady,cudaStream));
            // Stress completion/acceptance gates subsequent ownership changes
            // and the next NP pass. Include graph reads in that dependency,
            // rather than relying on this small kernel usually finishing first.
            check(cudaStreamWaitEvent(mStream,mGraphReady,0));
            mContactSequence=sequence;
            mGraphView={inputs,identities,outputs,shapes,retiredCount?mGraphRetiredMask:nullptr,mGraphAccurate,mGraphSpeculative,mGraphStatus,count,shapeCapacity,nodeCapacity,++mGraphGeneration,mGraphReady,mGraphRetainedSlots,mGraphRetainedActive,retainedSlotCount};
            return true;
        }catch(...){mFailed=true;mGraphView={};return false;}
    }
    PxgDestructionContactGraphView getContactGraphView() const override { return mGraphView; }
    bool gpuIslandRepairEnabled() const override { return mGpuIslandRepair; }
    PxgDestructionContactGraphObservationStats getContactGraphObservationStats() const override {
        auto stats=mGraphObservationStats;
        // Explicit diagnostic observation, outside the simulation loop. Keep
        // peak counts exact without a per-step count readback or CPU registry.
        if(mGraphRetainedCounts) {
            Context current(mContext);check(cudaEventSynchronize(mGraphReady));
            PxU32 counts[2];check(cudaMemcpy(counts,mGraphRetainedCounts,sizeof(counts),cudaMemcpyDeviceToHost));
            stats.peakRetainedEdges=std::max(stats.peakRetainedEdges,counts[1]);
        }
        return stats;
    }
    bool observeContactComponents(const PxU32*& accurate,const PxU32*& speculative,
        const PxU32*& accurateMembers,const PxU32*& speculativeMembers,PxU32& count,
        bool needAccurate,bool needSpeculative) override {
        accurate=speculative=nullptr;accurateMembers=speculativeMembers=nullptr;count=0;
        if(mFailed || !mGraphView.generation)return false;
        if(!needAccurate && !needSpeculative)return true;
        try {
            Context current(mContext);
            // mStream already waits for mGraphReady (buildContactGraph). The
            // status travels with the labels and members, so one stream
            // synchronization observes all of it: a synchronous status copy
            // first would wait for every stream, then again for the sort.
            if(!mGraphHostStatus)check(cudaMallocHost(&mGraphHostStatus,sizeof(*mGraphHostStatus)));
            check(cudaMemcpyAsync(mGraphHostStatus,mGraphStatus,sizeof(*mGraphHostStatus),cudaMemcpyDeviceToHost,mStream));
            ++mGraphObservationStats.observations;mGraphObservationStats.deviceToHostBytes+=sizeof(*mGraphHostStatus);
            const PxU32 n=mGraphView.nodeCapacity;
            if(!n) {
                check(cudaStreamSynchronize(mStream));
                return false;
            }
            if(n>mGraphObservationCapacity) {
                const PxU32 capacity=mGraphNodeCapacity;
                check(cudaFree(mGraphKeys));mGraphKeys=nullptr;allocate(mGraphKeys,capacity);
                check(cudaFree(mGraphSortedKeys));mGraphSortedKeys=nullptr;allocate(mGraphSortedKeys,capacity);
                check(cudaFreeHost(mGraphHostAccurate));mGraphHostAccurate=nullptr;
                check(cudaFreeHost(mGraphHostSpeculative));mGraphHostSpeculative=nullptr;
                check(cudaFreeHost(mGraphHostAccurateMembers));mGraphHostAccurateMembers=nullptr;
                check(cudaFreeHost(mGraphHostSpeculativeMembers));mGraphHostSpeculativeMembers=nullptr;
                check(cudaMallocHost(&mGraphHostAccurate,size_t(capacity)*sizeof(PxU32)));
                check(cudaMallocHost(&mGraphHostSpeculative,size_t(capacity)*sizeof(PxU32)));
                check(cudaMallocHost(&mGraphHostAccurateMembers,size_t(capacity)*sizeof(PxU64)));
                check(cudaMallocHost(&mGraphHostSpeculativeMembers,size_t(capacity)*sizeof(PxU64)));
                mGraphObservationCapacity=capacity;
            }
            // Keys use 2*bits significant bits; sorting only those is exact.
            const PxU32 bits=destructionContactGraph::componentKeyBits(n),endBit=2*bits;
            size_t bytes=0;check(cub::DeviceRadixSort::SortKeys(nullptr,bytes,mGraphKeys,mGraphSortedKeys,n,0,int(endBit),mStream));
            if(bytes>mGraphSortScratchBytes) {
                check(cudaFree(mGraphSortScratch));mGraphSortScratch=nullptr;
                check(cudaMalloc(&mGraphSortScratch,bytes));mGraphSortScratchBytes=bytes;
            }
            for(PxU32 graph=0;graph<2;++graph) {
                if(graph?!needSpeculative:!needAccurate)continue;
                const auto* labels=graph?mGraphSpeculative:mGraphAccurate;
                auto* hostLabels=graph?mGraphHostSpeculative:mGraphHostAccurate;
                auto* hostMembers=graph?mGraphHostSpeculativeMembers:mGraphHostAccurateMembers;
                destructionContactGraph::componentKeys<<<(n+127)/128,128,0,mStream>>>(labels,mGraphKeys,n,bits);
                check(cub::DeviceRadixSort::SortKeys(mGraphSortScratch,mGraphSortScratchBytes,mGraphKeys,mGraphSortedKeys,n,0,int(endBit),mStream));
                // Sorting has consumed the input keys. Reuse their 8*n-byte
                // allocation for heads/successors instead of another buffer.
                auto* members=reinterpret_cast<PxU32*>(mGraphKeys);
                check(cudaMemsetAsync(members,0xff,size_t(n)*sizeof(PxU32),mStream));
                destructionContactGraph::componentMembers<<<(n+127)/128,128,0,mStream>>>(mGraphSortedKeys,members,n,bits);
                check(cudaGetLastError());
                check(cudaMemcpyAsync(hostLabels,labels,size_t(n)*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
                check(cudaMemcpyAsync(hostMembers,members,size_t(n)*2*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
            }
            check(cudaStreamSynchronize(mStream));
            const PxgDestructionContactGraphStatus status=*mGraphHostStatus;
            if(status.error || status.omittedPairs)return false;
            const PxU32 graphs=PxU32(needAccurate)+PxU32(needSpeculative);
            mGraphObservationStats.sortedGraphs+=graphs;
            mGraphObservationStats.deviceToHostBytes+=PxU64(graphs)*n*(sizeof(PxU32)+sizeof(PxU64));
            accurate=needAccurate?mGraphHostAccurate:nullptr;speculative=needSpeculative?mGraphHostSpeculative:nullptr;
            accurateMembers=needAccurate?reinterpret_cast<PxU32*>(mGraphHostAccurateMembers):nullptr;speculativeMembers=needSpeculative?reinterpret_cast<PxU32*>(mGraphHostSpeculativeMembers):nullptr;count=n;return true;
        }catch(...){mFailed=true;return false;}
    }
    void release() override { delete this; }
    ~Runtime() override {
        Context current(mContext); cudaStreamSynchronize(mStream);clear();
        cudaFree(mImpactors);mImpactors=nullptr;cudaFree(mImpactEnergy);mImpactEnergy=nullptr;mImpactorCount=mImpactorCapacity=0;
        for(auto event:mStageEvents)if(event)cudaEventDestroy(event);
        for(auto event:mMotionAllocationEvents)if(event)cudaEventDestroy(event);
        for(auto event:mCorrectionEvents)if(event)cudaEventDestroy(event);
        mRigidIterationLimits.clear();
        cudaFree(mCompletion);cudaFreeHost(mHostCompletion);
        cudaEventDestroy(mPreReady);cudaEventDestroy(mGraphReady);cudaEventDestroy(mInput);cudaEventDestroy(mReady);cudaEventDestroy(mCheckpointReady);cudaStreamDestroy(mStream);
    }
    void clear() {
        mHostOwnedBodies.clear();
        cudaEventSynchronize(mPreReady);cudaEventSynchronize(mReady);
        cudaFree(mPreNodeStorage);cudaFree(mPreNodes);mPreNodeStorage=nullptr;mPreNodes=nullptr;mPrePrevious=nullptr;mPreRegistryCapacity=0;
        cudaFree(mPreUpdates);mPreUpdates=nullptr;mPreUpdateCapacity=0;mPreRosterValid=false;
        cudaFree(mPreRetired);mPreRetired=nullptr;cudaFree(mPreRetiredMask);mPreRetiredMask=nullptr;
        cudaFree(mPreContactStatus);mPreContactStatus=nullptr;mPreRetiredCapacity=mPrePairCapacity=0;
        cudaFree(mPreMerges);mPreMerges=nullptr;cudaFree(mPreParents);mPreParents=nullptr;
        mPreLabels=nullptr;mPreTouches=nullptr;mPreSupport=nullptr;
        mPreCapacity=mPrePreviousCount=mPreMergeCapacity=mPreParentCapacity=0;mPreSourceGraphGeneration=0;
        cudaEventSynchronize(mReady); // also orders private installation on the scene stream
        if(mGraphView.generation)cudaEventSynchronize(mGraphReady);
        cudaFree(mGraphRetiredMask);mGraphRetiredMask=nullptr;cudaFree(mGraphRetired);mGraphRetired=nullptr;
        cudaFreeHost(mGraphHostRetired);mGraphHostRetired=nullptr;mGraphRetiredCapacity=0;
        cudaFree(mGraphAccurate);mGraphAccurate=nullptr;
        cudaFree(mGraphSpeculative);mGraphSpeculative=nullptr;cudaFree(mGraphStatus);mGraphStatus=nullptr;
        mGraphView={};mGraphPairCapacity=0;mGraphNodeCapacity=0;
        mHostCompletion->correction={};mCorrectionBodyCapacity=0;
        mCollisionPreparationSubmitted=mCorrectionPreparationSubmitted=false;mRestoredCheckpointGeneration=0;
        if(mGraphRetainedCounts) {
            PxU32 counts[2];
            if(cudaMemcpy(counts,mGraphRetainedCounts,sizeof(counts),cudaMemcpyDeviceToHost)==cudaSuccess)
                mGraphObservationStats.peakRetainedEdges=std::max(mGraphObservationStats.peakRetainedEdges,counts[1]);
        }
        mGraphObservationStats.retainedSlotCapacity=0;
        cudaFree(mGraphRetainedSlots);mGraphRetainedSlots=nullptr;
        cudaFree(mGraphRetainedActive);mGraphRetainedActive=nullptr;
        cudaFree(mGraphRetainedCounts);mGraphRetainedCounts=nullptr;mGraphRetainedSlotCapacity=0;
        cudaFree(mGraphRetainedEdges);mGraphRetainedEdges=nullptr;
        cudaFreeHost(mGraphHostRetainedEdges);mGraphHostRetainedEdges=nullptr;mGraphRetainedEdgeCapacity=0;
        cudaFree(mGraphKeys);mGraphKeys=nullptr;cudaFree(mGraphSortedKeys);mGraphSortedKeys=nullptr;
        cudaFree(mGraphSortScratch);mGraphSortScratch=nullptr;mGraphSortScratchBytes=0;
        cudaFreeHost(mGraphHostAccurate);mGraphHostAccurate=nullptr;
        cudaFreeHost(mGraphHostSpeculative);mGraphHostSpeculative=nullptr;
        cudaFreeHost(mGraphHostAccurateMembers);mGraphHostAccurateMembers=nullptr;
        cudaFreeHost(mGraphHostSpeculativeMembers);mGraphHostSpeculativeMembers=nullptr;
        cudaFreeHost(mGraphHostStatus);mGraphHostStatus=nullptr;
        mGraphObservationCapacity=0;mGpuIslandRepair=false;
        mHostCorrectionTargets.clear();mCorrectionEnabled=false;mCorrectionLimit=0;
        mPass=0;mFirstPassBrokenBonds=0;mPriorPasses={};
        cudaFree(mCorrectionOwnerRequests);mCorrectionOwnerRequests=nullptr;
        cudaFree(mCorrectionOwnerTargets);mCorrectionOwnerTargets=nullptr;
        cudaFree(mPropertyEpochs);mPropertyEpochs=nullptr;mPropertyCount=nullptr;mPendingPropertyCapacity=0;
        cudaFree(mShapePublicationEpochs);cudaFree(mShapePublicationTargets);mShapePublicationEpochs=nullptr;mShapePublicationTargets=nullptr;mPendingShapeCapacity=0;
        cudaFree(mCorrectionBodies);mCorrectionBodies=nullptr;cudaFree(mCompactCorrectionBodies);mCompactCorrectionBodies=nullptr;
        mCorrectionPreparation=nullptr;cudaFree(mCorrectionScratch);mCorrectionScratch=nullptr;mCorrectionScratchBytes=0;
        if(mCheckpointValid)cudaEventSynchronize(mCheckpointReady);
        mCheckpointValid=false;mCheckpointCount=0;mCheckpointCapacity=0;
        mCheckpointHasPrevious=mCheckpointHasAccelerations=false;
        cudaFree(mCheckpointBodies);mCheckpointBodies=nullptr;
        cudaFree(mCheckpointCommands);mCheckpointCommands=nullptr;
        cudaFree(mCheckpointPrevious);mCheckpointPrevious=nullptr;
        cudaFree(mCheckpointAccelerations);mCheckpointAccelerations=nullptr;
        mHostReservedIndices.clear();mCompatibilityPrepared=false;mHostCompletion->collision={};
        cudaFree(mAffectedClusters);mAffectedClusters=nullptr;cudaFree(mCandidateSlots);mCandidateSlots=nullptr;
        cudaFree(mHullBindings);mHullBindings=nullptr;mHullCount=0;
        cudaFree(mCollisionBindings);mCollisionBindings=nullptr;cudaFree(mCompactCollisionBindings);mCompactCollisionBindings=nullptr;
        cudaFree(mMigratingCollisionBindings);mMigratingCollisionBindings=nullptr;
        cudaFree(mShapeOwnerGenerations);mShapeOwnerGenerations=nullptr;
        mShapeOwnerCapacity=0;mInstalledOwnerGeneration=0;
        mCollisionPreparation=nullptr;cudaFree(mCollisionScratch);mCollisionScratch=nullptr;mCollisionScratchBytes=0;
        if(mBodyAllocator)mBodyAllocator->clear();
        cudaFree(mCompactBodyRequests);mCompactBodyRequests=nullptr;
        cudaFree(mReturnedBodyIndices);mReturnedBodyIndices=nullptr;
        cudaFree(mGrantedMotionIndices);mGrantedMotionIndices=nullptr;
        cudaFree(mMotionSlots);mMotionSlots=nullptr;mMotionSlotCapacity=mCommittedMotionSlots=0;
        mDevicePreparation.clear();mMotionAllocation.clear();
        cudaFree(mBodyRequests);mBodyRequests=nullptr;cudaFree(mTrialBodyIndices);mTrialBodyIndices=nullptr;
        mBodyAllocation=nullptr;mHostBodyPreparation=nullptr;
        mBodyAllocationObservation=nullptr;mMotionTimingPending=false;
        mChanges.clear();
        if(mTopology)mTopology->release();mTopology=nullptr;
        cudaFree(mProvisionalMotion);mProvisionalMotion=nullptr;
        cudaFree(mTrialBodies);mTrialBodies=nullptr;mBodyPreparation=nullptr;
        mPinnedBodyRequests.release();mPinnedOwnerRequests.release();mPinnedReservedIndices.release();mPinnedOwnerTargets.release();
        mPinnedMigrating.release();mPinnedShapeOwners.release();mPinnedProperties.release();mOwnerMetadataPrefetched=false;mTailAcceptancePending=false;
        cudaFree(mPrincipalFrames);mPrincipalFrames=nullptr;
        cudaFree(mTopologyEdits);mTopologyEdits=nullptr;cudaFree(mTopologyCount);mTopologyCount=nullptr;mEditCapacity=0;
        cudaFree(mTopologyAccept);mTopologyAccept=nullptr;
        if(mSolver)mSolver->release();mSolver=nullptr;
        cudaFree(mConstraintMap);mConstraintMap=nullptr;mConstraintCount=0;
        cudaFree(mConstraintBindings);mConstraintBindings=nullptr;mPinnedConstraintBindings.release();mManagedConstraintIds.clear();
        cudaFree(mChunkLoads);mChunkLoads=nullptr;mHostChunkLoads.clear();mChunkLoadsFresh=false;
        cudaFree(mCorrectionCommandDeltas);mCorrectionCommandDeltas=nullptr;mCarryCorrectionCommands=false;
        cudaFree(mChunkCommandScales);mChunkCommandScales=nullptr;
        cudaFree(mDeferredGravity);mDeferredGravity=nullptr;
        cudaFree(mChunkCommandSums);mChunkCommandSums=nullptr;
        cudaFree(mCorrectionCommandSums);mCorrectionCommandSums=nullptr;
        cudaFree(mChunks);mChunks=nullptr;cudaFree(mClusters);mClusters=nullptr;
        cudaFree(mPoses);mPoses=nullptr;cudaFree(mAngular);mAngular=nullptr;
        cudaFree(mIdleBodies);mIdleBodies=nullptr;mIdleCertified=mIdleSkipped=mIdleFull=false;
        cudaFree(mMap);mMap=nullptr;if(mOwnInputs)cudaFree(mInputs);mInputs=nullptr;mOwnInputs=false;cudaFree(mSurface);mSurface=nullptr;cudaFree(mReportInputs);mReportInputs=nullptr;mReport=false;mReportPasses=0;mSolverReporting=false;
        cudaFree(mMaterials);mMaterials=nullptr;cudaFree(mBonds);mBonds=nullptr;
        cudaFree(mHealth);mHealth=nullptr;cudaFree(mRates);mRates=nullptr;
        cudaFree(mNodeBegin);mNodeBegin=nullptr;cudaFree(mNodeRefs);mNodeRefs=nullptr;
        cudaFree(mBondCentroids);mBondCentroids=nullptr;cudaFree(mVerdicts);mVerdicts=nullptr;
        cudaFree(mSections);mSections=nullptr;mSectionBending=false;mSectionRotation=false;
        mImpact.release();mImpactEnabled=false;cudaFree(mImpactRecords);mImpactRecords=nullptr;cudaFree(mImpactBase);mImpactBase=nullptr;cudaFree(mImpactRest);mImpactRest=nullptr;
        cudaFree(mImpactState);mImpactState=nullptr;cudaFree(mImpactStart);mImpactStart=nullptr;
        cudaFree(mImpactCarried);mImpactCarried=nullptr;cudaFree(mImpactCarriedStart);mImpactCarriedStart=nullptr;
        cudaFree(mImpactSlipState);mImpactSlipState=nullptr;cudaFree(mImpactSlipStart);mImpactSlipStart=nullptr;
        cudaFree(mImpactSlip);mImpactSlip=nullptr;cudaFree(mImpactStiffness);mImpactStiffness=nullptr;
        cudaFreeHost(mImpactHostStatus);mImpactHostStatus=nullptr;
        mImpactCrush=false;cudaFree(mImpactStress);mImpactStress=nullptr;cudaFree(mImpactRate);mImpactRate=nullptr;
        cudaFree(mImpactImpactor);mImpactImpactor=nullptr;cudaFree(mImpactStriker);mImpactStriker=nullptr;cudaFree(mCrushDemand);mCrushDemand=nullptr;mCrushDemandCapacity=0;cudaFree(mCrushBoundAudit);mCrushBoundAudit=nullptr;mCrushEnergyBound=false;cudaFree(mAnchoredChunks);mAnchoredChunks=nullptr;cudaFree(mAnchoredBonds);mAnchoredBonds=nullptr;cudaFree(mAnchoredSaturated);mAnchoredSaturated=nullptr;cudaFree(mAnchoredGhosts);mAnchoredGhosts=nullptr;mAnchoredBound=mAnchoredReady=false;
        cudaFree(mImpactRows);mImpactRows=nullptr;cudaFree(mImpactRowCount);mImpactRowCount=nullptr;
        cudaFree(mImpactRowDelta);mImpactRowDelta=nullptr;cudaFree(mImpactRowForce);mImpactRowForce=nullptr;cudaFree(mImpactRowBound);mImpactRowBound=nullptr;cudaFree(mImpactRowRouted);mImpactRowRouted=nullptr;
        cudaFree(mImpactBound);mImpactBound=nullptr;cudaFree(mImpactSaved);mImpactSaved=nullptr;cudaFree(mImpactBounded);mImpactBounded=nullptr;cudaFree(mImpactBoundRequested);mImpactBoundRequested=nullptr;mImpactBoundCapacity=0;
        cudaFree(mCrush);mCrush=nullptr;cudaFree(mTrialCrush);mTrialCrush=nullptr;
        mN=mM=mC=mMapCount=0;
    }
    bool configureStress(const PxDestructionStressDesc& d) override {
        if(!mWriteAllowed(mScene) || !d.chunks || (d.bondCount && !d.bonds) || !d.clusters
            || !d.chunkCount || !d.clusterCount || !d.maxIterations
            || (d.internalCorrectionLimit && !d.chunkMassProperties)
            || (d.enableChunkLoads && (!d.internalCorrectionLimit || !d.materialCount))
            || !std::isfinite(d.tolerance) || d.tolerance<=0 || !std::isfinite(d.forceTolerance) || d.forceTolerance<0)return false;
        // Section radii of gyration: finite and non-negative, all three or none.
        if(d.bondSections)for(PxU32 i=0;i<d.bondCount;++i) {
            const auto& s=d.bondSections[i];
            if(!std::isfinite(s.gyration0) || !std::isfinite(s.gyration1) || !std::isfinite(s.polarGyration)
                || s.gyration0<0 || s.gyration1<0 || s.polarGyration<0)return false;
            const bool any=s.gyration0>0 || s.gyration1>0 || s.polarGyration>0;
            if(any && !(s.gyration0>0 && s.gyration1>0 && s.polarGyration>0))return false;
            if(any && (!s.axis.isFinite() || std::abs(s.axis.magnitude()-1.0f)>1e-3f))return false;
        }
        try {
        std::vector<PxDestructionMaterial> materials;
        if(d.materialCount) {
            if(!d.materials || !std::isfinite(d.damageRate) || d.damageRate<=0 || !std::isfinite(d.bendGainMax))return false;
            // Sections: finite non-negative moduli; where any is positive all
            // must be, with a unit axis in the bond plane. Zero moduli = none.
            if(d.bondSections)for(PxU32 i=0;i<d.bondCount;++i) {
                const auto& s=d.bondSections[i];
                if(!std::isfinite(s.bendModulus0) || !std::isfinite(s.bendModulus1) || !std::isfinite(s.twistModulus)
                    || s.bendModulus0<0 || s.bendModulus1<0 || s.twistModulus<0)return false;
                // A bearing joint's half-depths: finite, non-negative, both or neither, on a section.
                if(!std::isfinite(s.bearingDepth0) || !std::isfinite(s.bearingDepth1) || s.bearingDepth0<0 || s.bearingDepth1<0
                    || ((s.bearingDepth0>0)!=(s.bearingDepth1>0)))return false;
                if(s.bearingDepth0>0 && !(s.bendModulus0>0))return false;
                if(s.bendModulus0==0 && s.bendModulus1==0 && s.twistModulus==0)continue;
                if(!(s.bendModulus0>0 && s.bendModulus1>0 && s.twistModulus>0) || !s.axis.isFinite()
                    || std::abs(s.axis.magnitude()-1.0f)>1e-3f)return false;
                const PxVec3 n=d.bonds[i].normal;const float m=n.magnitude();
                if(m>0 && std::abs(s.axis.dot(n))>1e-3f*m)return false;
            }
            if(!std::isfinite(d.fragmentMaxDepenetrationVelocity) || d.fragmentMaxDepenetrationVelocity<0)return false;
            // Impact capacity's cones are the capped-gain fibre formula.
            // Impact capacity reads the stage's own verdict: fibre bending, with
            // the capped gain or the section model (PxgDestructionImpact.cuh).
            if(d.impactCapacity && (!d.fibreBending || (!(d.bendGainMax>0) && !d.sectionBending && !d.sectionRotationalStiffness)))return false;
            if(d.impactCrush && !d.internalCorrectionLimit)return false;
            if(d.impactStep && !d.impactCapacity)return false;
            for(PxU32 i=0;d.impactCrush && i<d.materialCount;++i)
                if(!std::isfinite(d.materials[i].impactImpedance) || d.materials[i].impactImpedance<0)return false;
            for(PxU32 i=0;d.impactCapacity && i<d.materialCount;++i) {
                const auto& m=d.materials[i];
                if(!std::isfinite(m.ductileSlip) || m.ductileSlip<0 || !std::isfinite(m.impactStiffness) || !(m.impactStiffness>0))return false;
            }
            materials.assign(d.materials,d.materials+d.materialCount);
            for(auto& m:materials) {
                if(m.tensionElasticLimit<0)m.tensionElasticLimit=m.compressionElasticLimit;
                if(m.tensionFatalLimit<0)m.tensionFatalLimit=m.compressionFatalLimit;
                if(m.shearElasticLimit<0)m.shearElasticLimit=m.compressionElasticLimit;
                if(m.shearFatalLimit<0)m.shearFatalLimit=m.compressionFatalLimit;
                const float values[]={m.compressionElasticLimit,m.compressionFatalLimit,m.tensionElasticLimit,m.tensionFatalLimit,
                    m.shearElasticLimit,m.shearFatalLimit,m.residualAreaFraction,m.crush.capPressure,m.crush.cohesion,m.crush.frictionSlope,
                    m.crush.crushEnergy,m.crush.crushViscosity,m.crush.strainRateExponent,m.crush.referenceStrainRate,m.crush.debrisMassFraction};
                for(float f:values)if(!std::isfinite(f))return false;
                if(m.compressionElasticLimit<0 || m.tensionElasticLimit<0 || m.shearElasticLimit<0
                    || m.residualAreaFraction<0 || m.residualAreaFraction>1 || m.crush.debrisMassFraction<0 || m.crush.debrisMassFraction>1)return false;
            }
        }
        // Physical splits require the explicit world-row ownership contract.
        if(d.constraintCount && !d.constraints)return false;
        if(d.constraintCount && d.materialCount && (!d.internalCorrectionLimit || !d.chunkMassProperties))return false;
        std::vector<PxConstraint*> managedConstraints;
        std::vector<PxU32> constraintSources;
        std::vector<ConstraintLookup> constraintMap;
        std::set<PxU32> constraintIds;
        for(PxU32 i=0;i<d.constraintCount;++i) {
            const auto binding=d.constraints[i];
            if(!binding.constraint || binding.chunk>=d.chunkCount || !binding.torqueOrigin.isFinite() || !mBodyAllocator)return false;
            const auto chunk=d.chunks[binding.chunk];
            if(chunk.cluster>=d.clusterCount)return false;
            const PxU32 id=mBodyAllocator->getConstraintIndex(*binding.constraint,d.clusters[chunk.cluster].body);
            if(id==PX_INVALID_U32 || !constraintIds.insert(id).second)return false;
            if(d.materialCount) {
                if(!binding.replayWorldRows || !binding.torqueAboutBodyCOM || binding.carrierChunk>=d.chunkCount
                    || d.chunks[binding.carrierChunk].cluster!=chunk.cluster)return false;
                managedConstraints.push_back(binding.constraint);constraintSources.push_back(d.clusters[chunk.cluster].body);
            } else if(binding.replayWorldRows || d.internalCorrectionLimit)return false;
            constraintMap.push_back({id,binding.chunk,PxU32(binding.torqueAboutBodyCOM),binding.torqueOrigin,
                binding.carrierChunk,d.clusters[chunk.cluster].body,1});
        }
        if(d.additionalShapeCount && !d.additionalShapes)return false;
        if(size_t(d.chunkCount)+d.additionalShapeCount>size_t(std::numeric_limits<int>::max()))return false;
        std::vector<PxDestructionStressShape> hulls;
        hulls.reserve(size_t(d.chunkCount)+d.additionalShapeCount);
        std::vector<PxU32> begin(d.chunkCount+1,0),refs(2*size_t(d.bondCount));
        std::vector<float> health(d.bondCount);
        std::vector<ExtStressGpuNode> nodes(d.chunkCount);
        std::vector<ExtStressGpuBond> bonds(d.bondCount);std::vector<Lookup> map;
        for(PxU32 i=0;i<d.clusterCount;++i) {
            if(d.clusters[i].body==PX_INVALID_U32 || !d.clusters[i].centerOfMass.isFinite()
                || !mBodyAllocator || !mBodyAllocator->isValidSource(d.clusters[i].body))return false;
        }
        for(PxU32 i=0;i<d.chunkCount;++i) {
            const auto c=d.chunks[i];
            if(c.cluster>=d.clusterCount || !c.position.isFinite() || !std::isfinite(c.mass)
                || c.mass<0 || !std::isfinite(c.inertia) || c.inertia<0 || (c.mass>0 && c.inertia<=0))return false;
            if(d.materialCount && (c.material>=d.materialCount || !std::isfinite(c.volume) || c.volume<0
                || (materials[c.material].crush.capPressure>0 && c.mass>0 && c.volume<=0)))return false;
            hulls.push_back({i,c.contactIndex});
            nodes[i]={{c.position.x,c.position.y,c.position.z},c.mass,c.inertia};
            if(c.contactIndex!=PX_INVALID_U32)map.push_back({c.contactIndex,i});
        }
        for(PxU32 i=0;i<d.additionalShapeCount;++i) {
            const auto hull=d.additionalShapes[i];
            if(hull.chunk>=d.chunkCount || hull.contactIndex==PX_INVALID_U32)return false;
            hulls.push_back(hull);map.push_back({hull.contactIndex,hull.chunk});
        }
        std::sort(map.begin(),map.end(),[](const Lookup&a,const Lookup&b){return a.contact<b.contact;});
        for(size_t i=1;i<map.size();++i)if(map[i-1].contact==map[i].contact)return false;
        for(PxU32 i=0;i<d.bondCount;++i) {
            const auto b=d.bonds[i];
            if(b.chunk0>=d.chunkCount || b.chunk1>=d.chunkCount || b.chunk0==b.chunk1
                || d.chunks[b.chunk0].cluster!=d.chunks[b.chunk1].cluster
                || !b.centroid.isFinite() || !b.normal.isFinite() || !std::isfinite(b.area) || b.area<=0
                || !std::isfinite(b.health) || b.health<=0 || !std::isfinite(b.complianceScale) || b.complianceScale<=0)return false;
            // Distinct authored interfaces may join the same two simplified
            // collision groups. Each keeps its own centroid, material and bond
            // identity; connectivity ends only after the last path fails.
            if(d.materialCount && (b.material>=d.materialCount || b.chunk0>=b.chunk1))return false;
            ++begin[b.chunk0+1];++begin[b.chunk1+1];health[i]=b.health;
            bonds[i]={};bonds[i].node0=b.chunk0;bonds[i].node1=b.chunk1;
            for(PxU32 k=0;k<3;++k){bonds[i].centroid[k]=b.centroid[k];bonds[i].normal[k]=b.normal[k];}
            bonds[i].area=b.area;bonds[i].health=b.health;bonds[i].colScale=b.complianceScale;
        }
        std::vector<PxgDestructionBond> topologyBonds;
        if(d.chunkMassProperties) {
            if(size_t(d.chunkCount)+d.bondCount>size_t(std::numeric_limits<int>::max()))return false;
            std::set<PxU32> boundBodies;
            for(PxU32 i=0;i<d.clusterCount;++i)if(!boundBodies.insert(d.clusters[i].body).second)return false;
            topologyBonds.resize(d.bondCount);
            std::vector<PxU32> parent(d.chunkCount),owner(d.chunkCount,PX_INVALID_U32),clusterRoot(d.clusterCount,PX_INVALID_U32);
            for(PxU32 i=0;i<d.chunkCount;++i)parent[i]=i;
            auto root=[&](PxU32 i){while(parent[i]!=i)i=parent[i];return i;};
            for(PxU32 i=0;i<d.bondCount;++i) {
                topologyBonds[i]={d.bonds[i].chunk0,d.bonds[i].chunk1};
                const PxU32 a=root(d.bonds[i].chunk0),b=root(d.bonds[i].chunk1);parent[std::max(a,b)]=std::min(a,b);
            }
            for(PxU32 i=0;i<d.chunkCount;++i) {
                const PxU32 r=root(i),c=d.chunks[i].cluster;const auto& properties=d.chunkMassProperties[i];
                if((owner[r]!=PX_INVALID_U32 && owner[r]!=c) || (clusterRoot[c]!=PX_INVALID_U32 && clusterRoot[c]!=r))return false;
                owner[r]=c;clusterRoot[c]=r;
                for(PxU32 k=0;k<3;++k)if(float(properties.center[k])!=d.chunks[i].position[k])return false;
                if(bool(properties.supported)!=(d.chunks[i].mass==0))return false;
                if(d.chunks[i].mass>0 && std::abs(properties.mass-d.chunks[i].mass)>1e-6*std::max(1.0,properties.mass))return false;
            }
            for(PxU32 r:clusterRoot)if(r==PX_INVALID_U32)return false;
        }
            for(PxU32 i=0;i<d.chunkCount;++i)begin[i+1]+=begin[i];
            auto cursor=begin;
            for(PxU32 i=0;i<d.bondCount;++i){refs[cursor[d.bonds[i].chunk0]++]=i;refs[cursor[d.bonds[i].chunk1]++]=i;}
            Context current(mContext);
            // Reconfiguration is an explicit recovery boundary. Drain queued
            // work before releasing buffers even if the last stage failed.
            check(cudaEventSynchronize(mInput));check(cudaStreamSynchronize(mStream));
            if(mConsumer)check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(mConsumer)));
            clear();mPending=false;mFailed=false;mWarmImported=false;mEverDamaged=false;mCorrectionEnabled=d.internalCorrectionLimit>0;mCorrectionLimit=d.internalCorrectionLimit;mPreserveContactPairs=d.preserveUnchangedContactPairs;mGpuIslandRepair=d.gpuIslandRepair;
            if(d.bondCount) {
                mSolver=ExtStressGpuSolver::create(nodes.data(),d.chunkCount,bonds.data(),d.bondCount,NULL,0,mContext);
                if(!mSolver){clear();return false;}
                if(d.sectionRotationalStiffness) {
                    // Each bond's radii of gyration (its section's, or the
                    // square patch of its authored area), on its principal axes.
                    std::vector<ExtStressGpuBondRotation> rows(d.bondCount);
                    for(PxU32 i=0;i<d.bondCount;++i) {
                        const PxVec3 n=d.bonds[i].normal.getNormalized();
                        const PxDestructionBondSection s=d.bondSections?d.bondSections[i]:PxDestructionBondSection{};
                        PxVec3 axis=s.axis;float r0=s.gyration0,r1=s.gyration1,rp=s.polarGyration;
                        if(!(r0>0)) {
                            const float side=std::sqrt(d.bonds[i].area/12.0f);r0=r1=side;rp=side*std::sqrt(2.0f);
                            axis=n.cross(std::abs(n.x)<0.9f?PxVec3(1,0,0):PxVec3(0,1,0)).getNormalized();
                        }
                        axis=(axis-n*axis.dot(n)).getNormalized();
                        rows[i]={{axis.x,axis.y,axis.z},r0,r1,rp};
                    }
                    if(!ExtStressGpuSetBondRotationalStiffness(mSolver,rows.data(),d.bondCount)){clear();return false;}
                }
                if(!mSolver->prepareDeviceSolve()){clear();return false;}
            }
            allocate(mChunks,d.chunkCount);allocate(mClusters,std::max(d.chunkCount,d.clusterCount));
            allocate(mPoses,std::max(d.chunkCount,d.clusterCount));allocate(mAngular,std::max(d.chunkCount,d.clusterCount));allocate(mMap,map.size());
            // All-ones bits match no body state: the first observation always differs.
            allocate(mIdleBodies,std::max(d.chunkCount,d.clusterCount));
            check(cudaMemset(mIdleBodies,0xff,sizeof(*mIdleBodies)*std::max(d.chunkCount,d.clusterCount)));
            if(mSolver) mInputs=reinterpret_cast<PxDestructionVectorPair*>(mSolver->deviceView().nodeInputs);
            else {allocate(mInputs,d.chunkCount);mOwnInputs=true;}
            if(!mInputs)throw std::runtime_error("missing resident destruction inputs");
            allocate(mSurface,d.chunkCount);
            if(d.enableChunkLoads) {
                allocate(mChunkLoads,d.chunkCount);mHostChunkLoads.resize(d.chunkCount);
                allocate(mChunkCommandSums,4*size_t(d.chunkCount));
                allocate(mCorrectionCommandSums,4*size_t(d.chunkCount));
                allocate(mCorrectionCommandDeltas,d.chunkCount);allocate(mChunkCommandScales,2*size_t(d.chunkCount));
                if(d.fragmentGravity) {
                    allocate(mDeferredGravity,size_t(d.chunkCount)+1);
                    check(cudaMemset(mDeferredGravity+d.chunkCount,0,sizeof(PxU32)));
                }
                check(cudaMemset(mChunkLoads,0,sizeof(*mChunkLoads)*d.chunkCount));
            }
            check(cudaMemcpy(mChunks,d.chunks,sizeof(*mChunks)*d.chunkCount,cudaMemcpyHostToDevice));
            check(cudaMemcpy(mClusters,d.clusters,sizeof(*mClusters)*d.clusterCount,cudaMemcpyHostToDevice));
            if(!map.empty())check(cudaMemcpy(mMap,map.data(),sizeof(*mMap)*map.size(),cudaMemcpyHostToDevice));
            mHullCount=PxU32(hulls.size());allocate(mHullBindings,mHullCount);
            check(cudaMemcpy(mHullBindings,hulls.data(),sizeof(*mHullBindings)*mHullCount,cudaMemcpyHostToDevice));
            mN=d.chunkCount;mM=d.bondCount;mC=d.clusterCount;mMapCount=PxU32(map.size());
            mConstraintCount=PxU32(constraintMap.size());
            if(mConstraintCount) {
                allocate(mConstraintMap,mConstraintCount);
                check(cudaMemcpy(mConstraintMap,constraintMap.data(),mConstraintCount*sizeof(*mConstraintMap),cudaMemcpyHostToDevice));
                if(!managedConstraints.empty()) {
                    allocate(mConstraintBindings,mConstraintCount);mPinnedConstraintBindings.allocate(mConstraintCount);
                    if(!mBodyAllocator->registerWorldConstraints(managedConstraints.data(),constraintSources.data(),mConstraintCount))
                        throw std::runtime_error("world constraint registration failed");
                    mManagedConstraintIds=constraintIds;
                }
            }

            for(PxU32 i=0;i<d.clusterCount;++i)mHostOwnedBodies.insert(d.clusters[i].body);
            if(d.materialCount) {
                allocate(mMaterials,d.materialCount);allocate(mBonds,d.bondCount);allocate(mHealth,d.bondCount);
                allocate(mRates,d.chunkCount);allocate(mNodeBegin,begin.size());allocate(mNodeRefs,refs.size());
                allocate(mBondCentroids,d.bondCount);allocate(mVerdicts,d.bondCount);
                allocate(mCrush,d.chunkCount);allocate(mTrialCrush,d.chunkCount);
                check(cudaMemcpy(mMaterials,materials.data(),sizeof(*mMaterials)*d.materialCount,cudaMemcpyHostToDevice));
                if(d.bondCount) {
                    check(cudaMemcpy(mBonds,d.bonds,sizeof(*mBonds)*d.bondCount,cudaMemcpyHostToDevice));
                    check(cudaMemcpy(mHealth,health.data(),sizeof(float)*d.bondCount,cudaMemcpyHostToDevice));
                }
                check(cudaMemcpy(mNodeBegin,begin.data(),sizeof(PxU32)*begin.size(),cudaMemcpyHostToDevice));
                if(!refs.empty())check(cudaMemcpy(mNodeRefs,refs.data(),sizeof(PxU32)*refs.size(),cudaMemcpyHostToDevice));
                check(cudaMemset(mCrush,0,sizeof(*mCrush)*d.chunkCount));
                mDamageRate=d.damageRate;mBendGain=d.bendGainMax;mFibres=d.fibreBending;
                mSectionBending=d.sectionBending || d.sectionRotationalStiffness;mSectionRotation=d.sectionRotationalStiffness;
                if(mSectionBending && d.bondSections && d.bondCount) {
                    allocate(mSections,d.bondCount);
                    check(cudaMemcpy(mSections,d.bondSections,sizeof(*mSections)*d.bondCount,cudaMemcpyHostToDevice));
                }
                if(d.impactCapacity && d.bondCount && mSolver) {
                    // The stress solve's length scale (NvBlastExtStressGpu bond
                    // setup): the mean distance from a dynamic chunk to its bonds'
                    // application points (the midpoint, or the centroid at a support).
                    double length=0;size_t count=0;
                    for(PxU32 i=0;i<d.bondCount;++i) {
                        const auto& b=d.bonds[i];const auto& c0=d.chunks[b.chunk0];const auto& c1=d.chunks[b.chunk1];
                        if(c0.mass<=0){if(c1.mass>0){length+=(b.centroid-c1.position).magnitude();++count;}}
                        else if(c1.mass<=0){length+=(b.centroid-c0.position).magnitude();++count;}
                        else{length+=2.0*((c1.position-c0.position)*0.5f).magnitude();count+=2;}
                    }
                    mImpactSettings=impact::Settings{};
                    mImpactSettings.lengthScale=count && length>0?float(length/count):1.0f;
                    mImpactSettings.bendGainMax=d.bendGainMax;
                    // With rotational stiffness the elastic solve's wrench (and
                    // so the forces E reads and publishes) acts at every bond's
                    // centroid (ExtStressGpuSetBondRotationalStiffness).
                    mImpactSettings.solverAtCentroid=mSectionRotation;
                    mImpactSettings.sectionBending=mSectionBending;mImpactSettings.sectionRotation=mSectionRotation;
                    // Diagnostics and A/B (not the opt-in): PX_DESTRUCTION_IMPACT_*.
                    auto env=[](const char* name,float fallback){const char* v=std::getenv(name);return v && *v?float(std::atof(v)):fallback;};
                    mImpactSettings.stiffnessScale=env("PX_DESTRUCTION_IMPACT_STIFFNESS_SCALE",mImpactSettings.stiffnessScale);
                    mImpactSettings.tolerance=env("PX_DESTRUCTION_IMPACT_TOLERANCE",mImpactSettings.tolerance);
                    mImpactSettings.iterations=PxU32(env("PX_DESTRUCTION_IMPACT_ITERATIONS",float(mImpactSettings.iterations)));
                    mImpactSettings.evaluationIterations=PxU32(env("PX_DESTRUCTION_IMPACT_EVAL_ITERATIONS",float(mImpactSettings.evaluationIterations)));
                    mImpactSettings.rampLevels=PxU32(env("PX_DESTRUCTION_IMPACT_RAMP_LEVELS",float(mImpactSettings.rampLevels)));
                    mImpactSettings.cappedElastic=env("PX_DESTRUCTION_IMPACT_CAPPED_ELASTIC",0.0f)!=0.0f;
                    // PX_DESTRUCTION_IMPACT_EXPLICIT=1: the impact step is the explicit one
                    // (method 2, PxgDestructionImpactExplicit.cuh) instead of the event ramp.
                    mImpactSettings.method=d.impactStep?(env("PX_DESTRUCTION_IMPACT_EXPLICIT",0.0f)!=0.0f?2u:1u):0u;
                    mImpactSettings.stepDuration=env("PX_DESTRUCTION_IMPACT_STEP_DURATION",mImpactSettings.stepDuration);
                    mImpactSettings.stepRadius=env("PX_DESTRUCTION_IMPACT_STEP_RADIUS",mImpactSettings.stepRadius);
                    // The handoff to the corrected pass (opt-in; the high profile's):
                    // contact bounds per impactor body, not per struck cluster.
                    mImpactSettings.boundImpactor=env("PX_DESTRUCTION_IMPACT_BOUND_IMPACTOR",0.0f)!=0.0f;
                    // Those bounds pairwise: an impactor's holds only against the
                    // clusters its rows struck (with BOUND_IMPACTOR).
                    mImpactSettings.boundPairwise=env("PX_DESTRUCTION_IMPACT_BOUND_PAIRWISE",0.0f)!=0.0f;
                    mImpactSettings.anchoredBound=env("PX_DESTRUCTION_ANCHORED_CONTACT_BOUND",0.0f)!=0.0f;
                    // and the contact routing by peak force against capacity.
                    mImpactSettings.route=env("PX_DESTRUCTION_IMPACT_ROUTE",0.0f)!=0.0f;
                    mImpactSettings.explicitWindow=PxU32(env("PX_DESTRUCTION_IMPACT_EXPLICIT_WINDOW",0.0f));
                    std::vector<float> slip(d.materialCount),stiffness(d.materialCount);
                    for(PxU32 i=0;i<d.materialCount;++i){slip[i]=d.materials[i].ductileSlip;stiffness[i]=d.materials[i].impactStiffness;}
                    allocate(mImpactSlip,d.materialCount);allocate(mImpactStiffness,d.materialCount);
                    check(cudaMemcpy(mImpactSlip,slip.data(),sizeof(float)*slip.size(),cudaMemcpyHostToDevice));
                    check(cudaMemcpy(mImpactStiffness,stiffness.data(),sizeof(float)*stiffness.size(),cudaMemcpyHostToDevice));
                    allocate(mImpactBase,d.bondCount);check(cudaMemset(mImpactBase,0,sizeof(*mImpactBase)*d.bondCount));
                    allocate(mImpactRest,d.bondCount);check(cudaMemset(mImpactRest,0,sizeof(*mImpactRest)*d.bondCount));
                    allocate(mImpactState,d.bondCount);check(cudaMemset(mImpactState,0,sizeof(*mImpactState)*d.bondCount));
                    allocate(mImpactStart,d.bondCount);
                    allocate(mImpactCarried,d.bondCount);check(cudaMemset(mImpactCarried,0,sizeof(PxU32)*d.bondCount));allocate(mImpactCarriedStart,d.bondCount);
                    allocate(mImpactSlipState,d.bondCount);check(cudaMemset(mImpactSlipState,0,sizeof(float)*d.bondCount));allocate(mImpactSlipStart,d.bondCount);
                    check(cudaMallocHost(&mImpactHostStatus,sizeof(*mImpactHostStatus)));
                    mImpact.allocate(d.chunkCount,d.bondCount);mImpactEnabled=true;mImpactMaterialCount=d.materialCount;
                    if(mImpactLog || mImpactCaptureDir){allocate(mImpactRecords,impact::kLogCapacity);mImpact.w.log=mImpactRecords;}
                    mImpactSettings.coupledContact=env("PX_DESTRUCTION_IMPACT_COUPLED",1.0f)!=0.0f;
                    if(mImpactSettings.coupledContact) {
                        allocate(mImpactRows,impact::kContactCapacity);allocate(mImpactRowCount,1);
                        allocate(mImpactRowDelta,6*size_t(impact::kContactCapacity));allocate(mImpactRowForce,3*size_t(impact::kContactCapacity));
                        allocate(mImpactRowBound,size_t(impact::kContactCapacity));
                        allocate(mImpactRowRouted,size_t(impact::kContactCapacity));
                    }
                }
                if(d.impactCrush) {
                    allocate(mImpactStress,d.chunkCount);allocate(mImpactRate,d.chunkCount);allocate(mImpactImpactor,d.chunkCount);mImpactCrush=true;
                    // Energy-bounded crushing (opt-in; the high profile's): crushDemand.
                    if(std::getenv("PX_DESTRUCTION_CRUSH_ENERGY_BOUND") && std::atoi(std::getenv("PX_DESTRUCTION_CRUSH_ENERGY_BOUND"))!=0) {
                        allocate(mImpactStriker,d.chunkCount);allocate(mCrushBoundAudit,6);mCrushEnergyBound=true;
                    }
                }
                // The anchored-chunk contact bound (opt-in; the high profile's): every
                // rigid contact on a chunk of a kinematic cluster, every pass, at most
                // what the chunk's bonds and inertia take (gpusolver PxgAnchoredContactBound.h).
                if(std::getenv("PX_DESTRUCTION_ANCHORED_CONTACT_BOUND") && std::atoi(std::getenv("PX_DESTRUCTION_ANCHORED_CONTACT_BOUND"))!=0) {
                    allocate(mAnchoredChunks,std::max<PxU32>(d.chunkCount,1));allocate(mAnchoredBonds,2*size_t(std::max<PxU32>(d.bondCount,1)));allocate(mAnchoredSaturated,std::max<PxU32>(d.chunkCount,1)+65);allocate(mAnchoredGhosts,10);
                    check(cudaMemsetAsync(mAnchoredSaturated,0,sizeof(PxU32)*(std::max<PxU32>(d.chunkCount,1)+65),mStream));
                    mAnchoredBound=true;mAnchoredReady=false;
                }
                mFragmentMaxPenBias=d.fragmentMaxDepenetrationVelocity>0?-d.fragmentMaxDepenetrationVelocity:-1e32f;
                check(cudaMemcpyToSymbol(gNativeFragmentMaxPenBias,&mFragmentMaxPenBias,sizeof(float)));
                const bool fragmentGravity=d.fragmentGravity;
                check(cudaMemcpyToSymbol(gNativeFragmentGravity,&fragmentGravity,sizeof(bool)));
            }
            if(d.reservedContactPairs>mGraphPairCapacity) {
                // Before any graph snapshot exists: nothing in flight to wait for.
                const PxU32 capacity=d.reservedContactPairs;
                check(cudaFree(mGraphRetiredMask));mGraphRetiredMask=nullptr;allocate(mGraphRetiredMask,(size_t(capacity)+31)/32);
                mGraphPairCapacity=capacity;
                if(capacity>mGraphNodeCapacity) {
                    check(cudaFree(mGraphAccurate));mGraphAccurate=nullptr;allocate(mGraphAccurate,capacity);
                    check(cudaFree(mGraphSpeculative));mGraphSpeculative=nullptr;allocate(mGraphSpeculative,capacity);
                    mGraphNodeCapacity=capacity;
                }
                if(capacity>mGraphRetainedSlotCapacity && !mGraphRetainedSlotCapacity) {
                    allocate(mGraphRetainedSlots,capacity);allocate(mGraphRetainedActive,(size_t(capacity)+31)/32);
                    check(cudaMemset(mGraphRetainedActive,0,((size_t(capacity)+31)/32)*sizeof(PxU32)));
                    mGraphRetainedSlotCapacity=capacity;mGraphObservationStats.retainedSlotCapacity=capacity;
                }
            }
            if(d.chunkMassProperties) {
                mTopology=PxgDestructionTopologyTransaction::create(d.chunkMassProperties,d.chunkCount,topologyBonds.data(),d.bondCount);
                if(!mTopology || (mSolver && !mSolver->enableDeviceTopology())){clear();return false;}
                allocate(mTopologyAccept,1);
                allocate(mAffectedClusters,d.chunkCount);allocate(mCandidateSlots,d.chunkCount);
                allocate(mCollisionBindings,mHullCount);allocate(mCompactCollisionBindings,mHullCount);mCollisionPreparation=&mCompletion->collision;
                allocate(mMigratingCollisionBindings,mHullCount);
                check(cudaMemset(mCollisionPreparation,0,sizeof(*mCollisionPreparation)));
                check(cub::DeviceSelect::If(nullptr,mCollisionScratchBytes,mCollisionBindings,mCompactCollisionBindings,
                    &mCollisionPreparation->count,mHullCount,HasCollisionBinding{},mStream));
                size_t migratingScratchBytes=0;
                check(cub::DeviceSelect::If(nullptr,migratingScratchBytes,mCollisionBindings,mMigratingCollisionBindings,
                    &mCollisionPreparation->migrating,mHullCount,HasMigratingCollisionBinding{},mStream));
                mCollisionScratchBytes=std::max(mCollisionScratchBytes,migratingScratchBytes);
                check(cudaMalloc(&mCollisionScratch,mCollisionScratchBytes));
                allocate(mCorrectionOwnerRequests,d.chunkCount);allocate(mCorrectionOwnerTargets,mHullCount);
                // Private raw preparation scratch becomes the larger accepted observation
                // only after all correction consumers finish. Compact public views
                // retain their separate storage and original record layout.
                check(cudaMalloc(&mCorrectionBodies,size_t(d.chunkCount)*sizeof(PxvDestructionBodyProperties)));
                allocate(mCompactCorrectionBodies,d.chunkCount);mCorrectionPreparation=&mCompletion->correction;
                check(cudaMemset(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation)));
                check(cub::DeviceSelect::If(nullptr,mCorrectionScratchBytes,mCorrectionBodies,mCompactCorrectionBodies,
                    &mCorrectionPreparation->count,d.chunkCount,HasCorrectionBody{},mStream));
                if(mBodyAllocator->needsHostProperties()) {
                    allocate(mPropertyEpochs,d.chunkCount);mPropertyCount=&mCompletion->propertyCount;
                    allocate(mShapePublicationEpochs,mHullCount);allocate(mShapePublicationTargets,mHullCount);
                    check(cudaMemsetAsync(mShapePublicationEpochs,0,mHullCount*sizeof(PxU64),mStream));
                    check(cudaMemsetAsync(mPropertyEpochs,0,d.chunkCount*sizeof(PxU64),mStream));
                    size_t propertyBytes=0;
                    check(cub::DeviceSelect::If(nullptr,propertyBytes,cub::CountingInputIterator<PxU32>(0),
                        mCorrectionOwnerTargets,mPropertyCount,d.chunkCount,
                        HasChangedProperties{mTopology->accepted().activeClusters,mPropertyEpochs,mStatus},mStream));
                    mCorrectionScratchBytes=std::max(mCorrectionScratchBytes,propertyBytes);
                    size_t shapeBytes=0;
                    check(cub::DeviceSelect::If(nullptr,shapeBytes,cub::CountingInputIterator<PxU32>(0),
                        mCorrectionOwnerTargets,&mCompletion->shapeCount,mHullCount,
                        HasPendingShapeOwner{mShapePublicationEpochs,mStatus},mStream));
                    mCorrectionScratchBytes=std::max(mCorrectionScratchBytes,shapeBytes);
                }
                check(cudaMalloc(&mCorrectionScratch,mCorrectionScratchBytes));
                allocate(mTrialBodies,d.chunkCount);mBodyPreparation=&mCompletion->body;
                mPinnedBodyRequests.allocate(d.chunkCount);mPinnedOwnerRequests.allocate(d.chunkCount);
                mPinnedReservedIndices.allocate(d.chunkCount);mPinnedOwnerTargets.allocate(d.chunkCount);
                mPinnedMigrating.allocate(mHullCount);mPinnedShapeOwners.allocate(mHullCount);
                mPinnedProperties.allocate(d.chunkCount);
#if PX_CUMETAL
                allocate(mPrincipalFrames,d.chunkCount);
                check(cudaMemset(mPrincipalFrames,0,sizeof(*mPrincipalFrames)*std::max<size_t>(d.chunkCount,1)));
#endif
                check(cudaMemset(mBodyPreparation,0,sizeof(*mBodyPreparation)));
                mHostBodyPreparation=&mHostCompletion->body;*mHostBodyPreparation={};
                mBodyAllocationObservation=&mHostCompletion->allocation;*mBodyAllocationObservation={};
                allocate(mBodyRequests,d.chunkCount);allocate(mTrialBodyIndices,d.chunkCount);mBodyAllocation=&mCompletion->allocation;
                check(cudaMemset(mBodyAllocation,0,sizeof(*mBodyAllocation)));
                allocate(mCompactBodyRequests,d.chunkCount);allocate(mReturnedBodyIndices,d.chunkCount);
                allocate(mMotionSlots,1);check(cudaMemset(mMotionSlots,0,sizeof(*mMotionSlots)));
                cudaGraph_t preparationGraph{};
                check(mMotionAllocation.initialize({mMotionSlots,nullptr,mBodyPreparation,mBodyRequests,
                    mCompactBodyRequests,mReturnedBodyIndices,mTrialBodyIndices,nullptr,mBodyAllocation,mStatus,mN,0,mTrialBodies},mStream,&preparationGraph));
                mDevicePreparation.initialize(preparationGraph,mStream,[&](const NativePreparationInputs* inputs) {
                    const auto trial=mTopology->trial();
                    check(cudaMemsetAsync(mCandidateSlots,0xff,mN*sizeof(PxU32),mStream));
                    indexCandidateRoots<<<(mN+127)/128,128,0,mStream>>>(trial,mCandidateSlots);
                    preparePersistentCollisionBindings<<<(mHullCount+127)/128,128,0,mStream>>>(mChunks,mN,mHullBindings,mHullCount,mClusters,mAffectedClusters,
                        trial,mCandidateSlots,mTrialBodyIndices,nullptr,0,nullptr,0,mCollisionBindings,mCollisionPreparation,mBodyAllocation,inputs);
                    check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mCompactCollisionBindings,
                        &mCollisionPreparation->count,mHullCount,HasCollisionBinding{},mStream));
                    check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mMigratingCollisionBindings,
                        &mCollisionPreparation->migrating,mHullCount,HasMigratingCollisionBinding{},mStream));
                    finishCollisionPreparation<<<1,1,0,mStream>>>(mCollisionPreparation,mBodyAllocation,mStatus);
                    check(cudaMemsetAsync(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation),mStream));
                    if(mCorrectionCommandSums) {
                        check(cudaMemsetAsync(mCorrectionCommandSums,0,4*sizeof(PxVec3)*mN,mStream));
                        sumCorrectionCommands<<<(mN+127)/128,128,0,mStream>>>(mChunks,mN,mClusters,trial.chunkCluster,mAffectedClusters,
                            nullptr,0,mChunkLoads,mCorrectionCommandSums,inputs);
                    }
                    prepareCorrectionBodyInputs<<<(mN+127)/128,128,0,mStream>>>(mTrialBodies,mTrialBodyIndices,mN,trial,mChunks,
                        mAffectedClusters,nullptr,nullptr,0,0,mCollisionPreparation,mCorrectionBodies,mCorrectionPreparation,mChunkLoads,mCheckpointCommands,
                        mCorrectionCommandSums,mCorrectionCommandDeltas,inputs);
                    inspectCorrectionSourceLoads<<<(mN+127)/128,128,0,mStream>>>(mClusters,mAffectedClusters,0,nullptr,0,
                        mCollisionPreparation,mCorrectionPreparation,mChunkCommandSums,mChunkLoads,mCheckpointCommands,nullptr,inputs);
                    check(cub::DeviceSelect::If(mCorrectionScratch,mCorrectionScratchBytes,mCorrectionBodies,mCompactCorrectionBodies,
                        &mCorrectionPreparation->count,mN,HasCorrectionBody{},mStream));
                    finishCorrectionPreparation<<<1,1,0,mStream>>>(mCorrectionPreparation,mCollisionPreparation,0,mStatus,inputs);
                    check(cudaGetLastError());
                });
                check(mMotionAllocation.instantiate(mStream));
                mEditCapacity=d.chunkCount+d.bondCount;
                allocate(mProvisionalMotion,d.chunkCount);allocate(mTopologyEdits,mEditCapacity);allocate(mTopologyCount,1);
            }
            if(mTopology)mChanges.initialize(mTopology->accepted(),mStatus,
                mSolver?mSolver->deviceView().topologyStatus:nullptr,mStream);
            mParams={};mParams.maxIterations=d.maxIterations;mParams.tolerance=d.tolerance;mParams.forceTolerance=d.forceTolerance;mParams.warmStart=d.warmStart;
            // Solving only the islands whose inputs moved is the obvious win
            // here -- a city of 336 islands with 86 active solves all 336 --
            // but the resident device path this stage uses does not support
            // it: ExtStressGpuSolverImpl::solveDeviceAsync refuses any call
            // with skipSettledIslands set, so turning it on fails the solve
            // submission outright (stage error bit 4, from the first frame).
            // Island scoping for the resident path is an engine feature that
            // does not exist yet. Left here, off, so the next person finds the
            // answer rather than the idea.
            static const bool skipSettled=[]{const char* raw=::getenv("PHYSX_DESTRUCTION_SKIP_SETTLED");
                return raw && raw[0]=='1';}();
            mParams.skipSettledIslands=skipSettled;
            check(cudaMemset(mStatus,0,sizeof(*mStatus)));*mHostStatus={};
            check(cudaEventRecord(mReady,mStream));return true;
        }catch(...){mFailed=true;return false;}
    }
    bool clearStress() override {
        if(!mWriteAllowed(mScene))return false;
        try {Context current(mContext);
            check(cudaEventSynchronize(mInput));check(cudaStreamSynchronize(mStream));
            if(mConsumer)check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(mConsumer)));
            clear();mConsumer=nullptr;mPending=false;mFailed=false;
            check(cudaMemsetAsync(mStatus,0,sizeof(*mStatus),mStream));*mHostStatus={};
            check(cudaEventRecord(mReady,mStream));return true;
        }catch(...){mFailed=true;return false;}
    }
    bool configured() const override {return mN && !mFailed;}
    PxDestructionDeviceView getDeviceView() const override {
        PxDestructionDeviceView v;v.nodeAccelerations=mInputs;v.surfaceLoads=mSurface;v.status=mStatus;
        v.bondForces=mSolver?reinterpret_cast<const PxDestructionVectorPair*>(mSolver->deviceView().bondImpulses):nullptr;
        v.bondHealth=mHealth;v.chunkCrush=mCrush;v.bondVerdicts=mVerdicts;v.trialChunkCrush=mTrialCrush;v.strainRates=mRates;
        if(mSolver && mSolver->deviceView().topologyStatus) {
            static_assert(sizeof(PxDestructionStressTopologyStatus)==sizeof(ExtStressGpuDeviceTopologyStatus),"stress topology status ABI");
            const auto stress=mSolver->deviceView();
            v.stressTopology=reinterpret_cast<const PxDestructionStressTopologyStatus*>(stress.topologyStatus);
            v.stressNodeIslands=stress.nodeIslands;v.stressBondIslands=stress.bondIslands;
        }
        if(mTopology) {
            v.committedChanges=mChanges.view();
            v.trialBodies=mTrialBodies;v.bodyPreparation=mBodyPreparation;
            v.trialBodyIndices=mTrialBodyIndices;v.bodyAllocation=mBodyAllocation;v.motionSlots=mMotionSlots;v.motionSlotIndices=mGrantedMotionIndices;
            v.trialCollisionBindings=mCompactCollisionBindings;v.collisionPreparation=mCollisionPreparation;
            v.correctionBodies=mCompactCorrectionBodies;v.correctionPreparation=mCorrectionPreparation;
            v.acceptedTopology=mTopology->accepted();v.trialTopology=mTopology->trial();v.topologyTransaction=mTopology->status();
            v.acceptedTopology.readyEvent=v.trialTopology.readyEvent=mReady;
        }
        v.chunkCount=mN;v.bondCount=mM;v.readyEvent=reinterpret_cast<CUevent>(mReady);return v;
    }
    bool setImpactorImpedance(const PxRigidDynamicGPUIndex* bodies,const PxReal* impedances,PxU32 count) override {
        if(!mWriteAllowed(mScene) || mPending || (count && (!bodies || !impedances)))return false;
        std::vector<ImpactorImpedance> table;
        for(PxU32 i=0;i<count;++i){if(!std::isfinite(impedances[i]) || impedances[i]<0)return false;table.push_back({bodies[i],impedances[i]});}
        try {Context current(mContext);
            check(cudaStreamSynchronize(mStream));
            if(count>mImpactorCapacity){cudaFree(mImpactors);mImpactors=nullptr;cudaFree(mImpactEnergy);mImpactEnergy=nullptr;
                allocate(mImpactors,count);allocate(mImpactEnergy,count);mImpactorCapacity=count;}
            if(count)check(cudaMemcpy(mImpactors,table.data(),sizeof(table[0])*count,cudaMemcpyHostToDevice));
            mImpactorCount=count;return true;
        }catch(...){return false;}
    }
    bool setChunkLoads(const PxDestructionChunkLoad* loads,PxU32 count) override {
        if(!mWriteAllowed(mScene) || !configured() || !mChunkLoads || !loads || count!=mN || mPending || mFailed)return false;
        for(PxU32 i=0;i<count;++i)if(!loads[i].force.isFinite() || !loads[i].torque.isFinite() || !loads[i].impulse.isFinite() || !loads[i].angularImpulse.isFinite())return false;
        try {Context current(mContext);
            if(mChunkLoadsFresh)check(cudaEventSynchronize(mInput)); // repeated setter: staging memory is still borrowed
            std::copy(loads,loads+count,mHostChunkLoads.begin());
            check(cudaMemcpyAsync(mChunkLoads,mHostChunkLoads.data(),count*sizeof(*loads),cudaMemcpyHostToDevice,mStream));
            check(cudaEventRecord(mInput,mStream));mChunkLoadsFresh=true;mIdleCertified=false;return true;
        }catch(...){mFailed=true;return false;}
    }
    void setConsumerEvent(CUevent e) override {if(mWriteAllowed(mScene))mConsumer=e;}
    PxDestructionStageStatus getLastStatus() const override {
        PxDestructionStageStatus status=*mHostStatus;status.correctionBlockers=mCorrectionBlockers;return status;
    }
    void setCorrectionBlockers(PxU32 blockers) override {mCorrectionBlockers=blockers;}
    bool setStressSolveReport(PxU32 passes) override {
        try {Context current(mContext);
            if(!mSolver || !mSolver->enableSolveReport(passes!=0))return false;
            if(passes && !mReportInputs)allocate(mReportInputs,3*mN);
            mReportPasses=passes;mReport=passes!=0;mSolverReporting=passes!=0;return true;
        }catch(...){return false;}
    }
    bool getStressSolveReport(PxDestructionStressComponentReport* components, PxU32 capacity, PxU32& count,
        PxReal* chunkResidual2, PxU32* chunkComponent, PxU32 chunkCapacity, PxDestructionVectorPair* chunkInputs) override {
        static_assert(sizeof(PxDestructionStressComponentReport)==sizeof(ExtStressGpuComponentReport),"solve report layout");
        count=0;
        if(!mSolver || mPending)return false;
        try {Context current(mContext);
            std::vector<ExtStressGpuComponentReport> records(capacity);
            std::uint32_t n=0;
            if(!mSolver->readSolveReport(records.data(),capacity,n,chunkResidual2,chunkComponent,chunkCapacity))return false;
            if(chunkInputs && mReportInputs && chunkCapacity>=mN)
                check(cudaMemcpy(chunkInputs,mReportInputs,sizeof(*chunkInputs)*3*mN,cudaMemcpyDeviceToHost));
            count=n;
            if(n)std::memcpy(components,records.data(),sizeof(*components)*std::min<PxU32>(n,capacity));
            return true;
        }catch(...){return false;}
    }
    bool prepareFrame(PxU32 pass=0) override {
        try {Context current(mContext);if(!configured() || mPending || pass>mCorrectionLimit || (pass && pass!=mPass+1))return false;
            mPass=pass;if(!pass){mCarryCorrectionCommands=false;mTickBodies.clear();}
            if(!pass && mDeferredGravity)check(cudaMemsetAsync(mDeferredGravity+mN,0,sizeof(PxU32),mStream));
            if(!pass && mChunkLoads) {
                if(!mChunkLoadsFresh)check(cudaMemsetAsync(mChunkLoads,0,mN*sizeof(*mChunkLoads),mStream));
                mChunkLoadsFresh=false;mIdleCertified=false;
            }
            if(pass) {
                // The previous pass was accepted: its per-pass status carries
                // exactly one corrected solve and one evaluation. Fold it into
                // the frame total before this evaluation overwrites the device row.
                if(mHostStatus->error || mHostStatus->correctionPasses!=1 || mHostStatus->stressPasses!=1)return false;
                const auto& previous=*mHostStatus;
                if(pass==1){mPriorPasses=previous;mFirstPassBrokenBonds=previous.brokenBonds;}
                else {
                    auto& prior=mPriorPasses;
                    prior.normalContacts+=previous.normalContacts;prior.frictionAnchors+=previous.frictionAnchors;
                    prior.iterations=std::max(prior.iterations,previous.iterations);
                    prior.converged=prior.converged && previous.converged;
                    prior.bondCommands+=previous.bondCommands;prior.brokenBonds+=previous.brokenBonds;
                    prior.crushedChunks+=previous.crushedChunks;prior.error|=previous.error;
                }
            }
            // This evaluation follows an ordinary or corrected collision solve,
            // which has consumed the previous installed ownership generation.
            // Only a new split below may publish work for the next traversal;
            // keeping an already consumed generation would refilter it twice.
            mInstalledOwnerGeneration=0;
            if(!pass){mPendingPropertyCapacity=0;mPendingShapeCapacity=0;}
            if(mConsumer)check(cudaStreamWaitEvent(mStream,reinterpret_cast<cudaEvent_t>(mConsumer),0));
            startFrame<<<1,1,0,mStream>>>(mStatus,mContactSequence,pass>0,pass?nullptr:&mCompletion->idle);
            if(mTopology && !pass)mChanges.start(mTopology->accepted(),mStatus,mStream);
            if(mBodyAllocation)check(cudaMemsetAsync(mBodyAllocation,0,sizeof(*mBodyAllocation),mStream));
            mHostCompletion->correction={};mCorrectionBodyCapacity=0;
            mCollisionPreparationSubmitted=mCorrectionPreparationSubmitted=false;mPreparationObserved=false;mOwnerMetadataPrefetched=false;mTailAcceptancePending=false;
            if(mCorrectionPreparation)check(cudaMemsetAsync(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation),mStream));
            if(mCollisionPreparation) {
                check(cudaMemsetAsync(mCollisionPreparation,0,sizeof(*mCollisionPreparation),mStream));
                check(cudaMemsetAsync(mAffectedClusters,0,mC*sizeof(PxU32),mStream));
            }
            check(cudaEventRecord(mInput,mStream));return true;
        }catch(...){mFailed=true;return false;}
    }
    bool finishPostCorrection() override {
        // A pending final acceptance has not been observed yet: the host
        // status still holds the final pass's correction request (8).
        if(!mPass || mFailed || mPending || (!mTailAcceptancePending && mHostStatus->error)){mTailAcceptancePending=false;return false;}
        try {Context current(mContext);
            mergePostCorrectionStatus<<<1,1,0,mStream>>>(mStatus,mPriorPasses,mPass,mFirstPassBrokenBonds);
            // Ordered after the final solve (advance joined the core stream)
            // and any final split (acceptCorrection joined it again).
            if(mDeferredGravity && mMotionStorage.bodies)clearDeferredGravity<<<(mN+127)/128,128,0,mStream>>>(
                mDeferredGravity,mDeferredGravity+mN,mN,mMotionStorage.bodies,mMotionStorage.capacity);
            if(mTopology)mChanges.publish(mStream);
            const PxU32 capacity=std::min(mC,mPendingPropertyCapacity);
            PxvDestructionBodyProperties* observations=mPinnedProperties.p;PxU32 count=0;
            if(capacity) {
                const auto topology=mTopology->accepted();
                check(cub::DeviceSelect::If(mCorrectionScratch,mCorrectionScratchBytes,
                    cub::CountingInputIterator<PxU32>(0),mCorrectionOwnerTargets,mPropertyCount,mC,
                    HasChangedProperties{topology.activeClusters,mPropertyEpochs,mStatus},mStream));
                gatherFinalProperties<<<(capacity+127)/128,128,0,mStream>>>(mCorrectionOwnerTargets,mPropertyCount,
                    capacity,mTrialBodies,mClusters,mMotionStorage.bodies,
                    reinterpret_cast<PxvDestructionBodyProperties*>(mCorrectionBodies),mStatus);
                check(cudaMemcpyAsync(observations,mCorrectionBodies,capacity*sizeof(observations[0]),cudaMemcpyDeviceToHost,mStream));
            }
            const PxU32 shapeCapacity=std::min(mHullCount,mPendingShapeCapacity);
            PxDestructionCollisionBinding* shapeObservations=mPinnedShapeOwners.p;
            if(shapeCapacity) {
                // Reuse private preparation scratch. The compact trial batch
                // remains exposed by getDeviceView with its original count.
                check(cub::DeviceSelect::If(mCorrectionScratch,mCorrectionScratchBytes,
                    cub::CountingInputIterator<PxU32>(0),mCorrectionOwnerTargets,&mCompletion->shapeCount,mHullCount,
                    HasPendingShapeOwner{mShapePublicationEpochs,mStatus},mStream));
                gatherFinalShapeOwners<<<(shapeCapacity+127)/128,128,0,mStream>>>(mCorrectionOwnerTargets,
                    &mCompletion->shapeCount,shapeCapacity,mHullBindings,mShapePublicationTargets,mCollisionBindings,mStatus);
                check(cudaMemcpyAsync(shapeObservations,mCollisionBindings,
                    shapeCapacity*sizeof(shapeObservations[0]),cudaMemcpyDeviceToHost,mStream));
            }
            check(cudaGetLastError());
            // Selected count shares the mandatory completion transfer. No
            // count-read/wait/resubmit boundary is needed to size the payload.
            check(cudaMemcpyAsync(mHostCompletion,mCompletion,sizeof(*mStatus)+((capacity||shapeCapacity)?2*sizeof(PxU32):0),cudaMemcpyDeviceToHost,mStream));
            check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            if(mTailAcceptancePending) {
                // The merged status carries every acceptance error bit.
                mTailAcceptancePending=false;
                if(mHostStatus->error){collectCorrectionTimings();return false;}
                acceptedCorrection();
            }
            count=capacity?mHostCompletion->propertyCount:0;
            if(mHostStatus->error || count>capacity)return false;
            if(count && !mBodyAllocator->publishCorrectionProperties(observations,count))return false;
            const PxU32 shapeCount=shapeCapacity?mHostCompletion->shapeCount:0;
            if(shapeCount>shapeCapacity || (shapeCount && !mBodyAllocator->publishShapeOwners(shapeObservations,shapeCount)))return false;
            mPendingPropertyCapacity=0;mPendingShapeCapacity=0;mPass=0;return true;
        }catch(...){mFailed=true;return false;}
    }
    CUevent inputEvent() const override {return reinterpret_cast<CUevent>(mInput);}
    bool advance(PxReal dt,const PxVec3& gravity,const PxgDestructionMotionStorage& storage,CUstream producerStream,
        PxgDestructionGrowMotionStorage growStorage,void* storageOwner,const PxgDestructionSolvedContacts& contacts,const PxgDestructionCollisionStorage& collision) override {
        mIdleSkipped=mIdleFull=false;
        if(!mConstraintCount && mIdleGate && mIdleCertified && !mPass && !mFailed && configured() && dt>0 && storage.bodies && producerStream
            && dt==mIdleDt && gravity==mIdleGravity)
            return advanceIdle(dt,gravity,storage,producerStream,growStorage,storageOwner,contacts,collision);
        mIdleCertified=false;mIdleFull=!mPass;mIdleDt=dt;mIdleGravity=gravity;
        return advanceFull(dt,gravity,storage,producerStream,growStorage,storageOwner,contacts,collision);
    }
    // The certified fixed point stands: observe this frame's inputs and publish
    // the same zero-change result a full evaluation would. No solve, material,
    // topology or motion work is enqueued.
    bool advanceIdle(PxReal dt,const PxVec3& gravity,const PxgDestructionMotionStorage& storage,CUstream producerStream,
        PxgDestructionGrowMotionStorage growStorage,void* storageOwner,const PxgDestructionSolvedContacts& contacts,const PxgDestructionCollisionStorage& collision) {
        try {Context current(mContext);
            mCollisionStorage=collision;mMotionStorage=storage;mGrowMotionStorage=growStorage;mMotionStorageOwner=storageOwner;mMotionProducerStream=producerStream;
            mIdleFrame={dt,gravity,storage,producerStream,growStorage,storageOwner,contacts,collision};
            check(cudaStreamWaitEvent(producerStream,mInput,0));
            check(cudaEventRecord(mInput,producerStream));
            check(cudaStreamWaitEvent(mStream,mInput,0));
            watchClusterBodies<<<(mC+127)/128,128,0,mStream>>>(mClusters,mC,storage.bodies,mIdleBodies,&mCompletion->idle);
            if(contacts.pairCount)watchDestructibleContacts<<<(contacts.pairCount+127)/128,128,0,mStream>>>(
                contacts,mMap,mMapCount,&mCompletion->idle,eIDLE_INPUTS_CHANGED);
            finishStatus<<<1,1,0,mStream>>>(nullptr,mStatus,nullptr,0);
            if(mTopology)mChanges.publish(mStream);
            check(cudaGetLastError());
            observeCompletion();
            check(cudaEventRecord(mReady,mStream));mPending=true;mIdleSkipped=true;return true;
        }catch(...){mFailed=true;return false;}
    }
    bool advanceFull(PxReal dt,const PxVec3& gravity,const PxgDestructionMotionStorage& storage,CUstream producerStream,
        PxgDestructionGrowMotionStorage growStorage,void* storageOwner,const PxgDestructionSolvedContacts& contacts,const PxgDestructionCollisionStorage& collision) {
        const auto* bodyStates=storage.bodies;
        try {Context current(mContext);
            mCollisionStorage=collision;mMotionStorage=storage;mGrowMotionStorage=growStorage;mMotionStorageOwner=storageOwner;mMotionProducerStream=producerStream;if(!configured() || dt<=0 || !bodyStates || !producerStream)return false;
            // Join borrowed NP streams and the native body's last writer before
            // reading either. Recording the existing input event on the body
            // producer preserves the previous API-gather ordering without
            // those kernels or a CPU completion wait.
            check(cudaStreamWaitEvent(producerStream,mInput,0));
            check(cudaEventRecord(mInput,producerStream));
            check(cudaStreamWaitEvent(mStream,mInput,0));
            // The last corrected pass's contact bounds end with it.
            restoreImpactBounds(bodyStates);
            if(mTopology) {
                check(mMotionAllocation.setStorage(storage,mStream));
                check(mMotionAllocation.setNodes(mPreNodes,mPreRegistryCapacity,mStream));
                prepareDeviceInputs();
            }
            stageMarker(0);
            if(!mPass) {
                // Keep the idle observation current; a destructible contact rules out certification.
                watchClusterBodies<<<(mC+127)/128,128,0,mStream>>>(mClusters,mC,bodyStates,mIdleBodies,&mCompletion->idle);
                if(contacts.pairCount)watchDestructibleContacts<<<(contacts.pairCount+127)/128,128,0,mStream>>>(
                    contacts,mMap,mMapCount,&mCompletion->idle,eIDLE_STATE_CHANGED);
            }
            observeNativeClusters<<<(mC+127)/128,128,0,mStream>>>(mClusters,mC,bodyStates,mPoses,mAngular);
            // Record only the selected passes: on a fracturing step the trial
            // pass decides what breaks and the corrected pass re-solves after.
            mReport=mReportPasses && (mReportPasses & (1u<<std::min<PxU32>(mPass,31)));
            if(mSolver && mReportPasses && mReport!=mSolverReporting){mSolver->enableSolveReport(mReport);mSolverReporting=mReport;}
            prepareLoads<<<(mN+127)/128,128,0,mStream>>>(mChunks,mN,mClusters,mPoses,mAngular,gravity,mInputs,mSurface,mRates,mChunkLoads,bodyStates,1.0f/dt);
            if(mReport)check(cudaMemcpyAsync(mReportInputs,mInputs,sizeof(*mInputs)*mN,cudaMemcpyDeviceToDevice,mStream));
            if(mConstraintCount)routeConstraintLoads<<<(mConstraintCount+127)/128,128,0,mStream>>>(
                mConstraintMap,mConstraintCount,collision.constraintWritebacks,collision.constraintCapacity,
                mChunks,mClusters,mPoses,bodyStates,1.0f/dt,mInputs,mSurface,mStatus);
            if(mReport)check(cudaMemcpyAsync(mReportInputs+mN,mInputs,sizeof(*mInputs)*mN,cudaMemcpyDeviceToDevice,mStream));
            if(passChunkLoads()) {
                // Every pass that may re-solve audits its own checkpoint: on a
                // corrected pass, the start of the tick plus the fragments
                // installed so far, against the current membership.
                check(cudaMemsetAsync(mChunkCommandSums,0,4*sizeof(PxVec3)*mC,mStream));
                float* scales=mChunkCommandScales;
                check(cudaMemsetAsync(scales,0,2*sizeof(float)*mC,mStream));
                sumChunkCommandsByCluster<<<(mN+127)/128,128,0,mStream>>>(
                    mChunks,mN,mClusters,mC,mChunkLoads,mCheckpointBodies,mCheckpointCount,mChunkCommandSums,scales);
                validateChunkCommands<<<(mC+127)/128,128,0,mStream>>>(
                    mClusters,mC,mChunkCommandSums,mCheckpointBodies,mCheckpointCount,mCheckpointCommands,mStatus,scales);
            }
            ImpactContact impactContacts{};
            if(mImpactCrush) {
                check(cudaMemsetAsync(mImpactStress,0,sizeof(float)*mN,mStream));check(cudaMemsetAsync(mImpactRate,0,sizeof(float)*mN,mStream));
                check(cudaMemsetAsync(mImpactImpactor,0xff,sizeof(PxU32)*mN,mStream));
                if(mImpactStriker){check(cudaMemsetAsync(mImpactStriker,0xff,sizeof(PxU32)*mN,mStream));impactContacts.striker=mImpactStriker;}
                impactContacts.impactors=mImpactors;impactContacts.impactorCount=mImpactorCount;
                impactContacts.stress=mImpactStress;impactContacts.rate=mImpactRate;impactContacts.impactor=mImpactImpactor;
            }
            if(mAnchoredBound && mAnchoredReady){impactContacts.anchored=anchoredContactBoundView();impactContacts.saturated=mAnchoredSaturated;
                check(cudaMemsetAsync(mAnchoredSaturated+mN,0,sizeof(PxU32),mStream));}
            if(mImpactRows) {
                check(cudaMemsetAsync(mImpactRowCount,0,sizeof(PxU32),mStream));
                impactContacts.rows=mImpactRows;impactContacts.rowCount=mImpactRowCount;impactContacts.rowCapacity=impact::kContactCapacity;
                impactContacts.clusters=mClusters;
                // The impact solve's motion tolerance over the tick, as a speed.
                impactContacts.separating=mImpactSettings.tolerance/dt;
                impactContacts.route=mImpactSettings.route;impactContacts.gravity=gravity.magnitude();
            }
            if(mImpactCrush || mImpactRows) {
                if(mCheckpointValid)check(cudaStreamWaitEvent(mStream,mCheckpointReady,0));
                impactContacts.before=mCheckpointValid?mCheckpointBodies:nullptr;impactContacts.beforeCount=mCheckpointValid?mCheckpointCount:0u;
            }
            if(contacts.pairCount)routeContacts<<<(contacts.pairCount+127)/128,128,0,mStream>>>(contacts,mMap,mMapCount,mChunks,mPoses,1.0f/dt,mInputs,mSurface,mStatus,bodyStates,mMaterials,mRates,impactContacts);
            // The contact routing (Settings::route): rows past their struck chunk's
            // capacity are the impact model's; their trial loads leave the static
            // solve's inputs, every pass they are in contact.
            if(mImpactEnabled && mImpactRows && mImpactRowRouted && mImpactSettings.route && mMaterials && mM) {
                impact::Inputs rin{};
                rin.chunks=mChunks;rin.chunkCount=mN;rin.bonds=mBonds;rin.bondCount=mM;rin.materials=mMaterials;
                rin.ductileSlip=mImpactSlip;rin.stiffness=mImpactStiffness;rin.health=mHealth;
                rin.nodeBegin=mNodeBegin;rin.nodeRefs=mNodeRefs;rin.sections=mSectionBending?mSections:nullptr;
                rin.rows=mImpactRows;rin.rowCount=impact::kContactCapacity;rin.rowCounter=mImpactRowCount;
                impact::Settings rs=mImpactSettings;rs.dt=dt;
                impact::routeRows<<<(impact::kContactCapacity+127)/128,128,0,mStream>>>(rin,rs,mImpactRowRouted,mInputs);
                if(mAnchoredBound && mAnchoredReady && mN)anchoredStepChunks<<<(impact::kContactCapacity+127)/128,128,0,mStream>>>(mImpactRows,mImpactRowCount,impact::kContactCapacity,mImpactRowRouted,mN,mAnchoredSaturated);
            }
            if(mReport)check(cudaMemcpyAsync(mReportInputs+2*mN,mInputs,sizeof(*mInputs)*mN,cudaMemcpyDeviceToDevice,mStream));
            check(cudaEventRecord(mReady,mStream));
            stageMarker(1);
            const PxDestructionVectorPair* forces=nullptr;
            const ExtStressGpuDeviceStatus* solveStatus=nullptr;
            // Impact capacity's ramp starts from the state before this tick: the
            // forces of the last evaluation (the solve's resident output, still
            // unchanged). Kept for the corrected pass of the same tick.
            // The solve waits on mReady: record it after the copy.
            if(mImpactEnabled && !mPass) {
                check(cudaMemcpyAsync(mImpactBase,mSolver->deviceView().bondImpulses,sizeof(*mImpactBase)*mM,cudaMemcpyDeviceToDevice,mStream));
                check(cudaMemcpyAsync(mImpactStart,mImpactState,sizeof(*mImpactStart)*mM,cudaMemcpyDeviceToDevice,mStream));
                check(cudaMemcpyAsync(mImpactCarriedStart,mImpactCarried,sizeof(PxU32)*mM,cudaMemcpyDeviceToDevice,mStream));
                check(cudaMemcpyAsync(mImpactSlipStart,mImpactSlipState,sizeof(float)*mM,cudaMemcpyDeviceToDevice,mStream));
                check(cudaEventRecord(mReady,mStream));
            }
            if(mSolver) {
                // PX_DESTRUCTION_CORRECTED_WARM_START=1: a corrected pass re-simulates the
                // tick from its start, so its elastic solve starts from the state the
                // tick began with, not from the trial's solution (computed under loads
                // the corrected pass no longer has; with the iteration cap its verdict
                // judged that iterate: tests destruction_gpu_impact_static_handoff_*).
                if(mCorrectedWarmStart){if(!mPass)Nv::Blast::ExtStressGpuSnapshotWarmStart(mSolver);else Nv::Blast::ExtStressGpuRestoreWarmStart(mSolver);}
                if(!mSolver->solveDeviceAsync(reinterpret_cast<ExtStressGpuImpulse*>(mInputs),mN,mParams,mReady,mConsumer))
                    throw std::runtime_error("resident stress solve submission failed");
                const auto view=mSolver->deviceView();
                check(cudaStreamWaitEvent(mStream,reinterpret_cast<cudaEvent_t>(view.readyEvent),0));
                forces=reinterpret_cast<const PxDestructionVectorPair*>(view.bondImpulses);solveStatus=view.status;
            }
            stageMarker(2);
            // Detached chunks still receive contact loads and may crush; a
            // graph without bonds has no stiffness solve to allocate or run.
            finishStatus<<<std::max(1u,(mM+127)/128),128,0,mStream>>>(solveStatus,mStatus,forces,mM,mCorrectionEnabled && !mAllowUnconverged);
            // Ci: the crush law at each chunk's impact stress, before E (a chunk
            // crushed so leaves E's solve); in place of the virial evaluation.
            if(mImpactCrush && mMaterials) {
                impactCrushStep<<<(mN+127)/128,128,0,mStream>>>(mChunks,mMaterials,mImpactStress,mImpactRate,mCrush,mTrialCrush,mN,dt,mStatus);
                // The trial's crushes are paid from the impactor's start-of-tick
                // speed, which the corrected pass re-simulates from. (A crush
                // first found in the corrected pass is not paid: no later pass.)
                if(mCrushEnergyBound) {
                    // Every pass's crushes, paid by their strikers: the trial's from the
                    // start of the tick (the checkpoint its corrected pass restores), a
                    // corrected pass's from the end of its own (the next tick's start).
                    const bool start=!mPass && mCheckpointValid;
                    PxgBodySim* payers=start?mCheckpointBodies:const_cast<PxgBodySim*>(bodyStates);
                    const PxU32 bodies=start?mCheckpointCount:mMotionStorage.capacity;
                    if(bodies>mCrushDemandCapacity){check(cudaStreamSynchronize(mStream));cudaFree(mCrushDemand);mCrushDemand=nullptr;allocate(mCrushDemand,2*size_t(bodies));
                        check(cudaMemsetAsync(mCrushDemand,0,2*sizeof(float)*bodies,mStream));mCrushDemandCapacity=bodies;}
                    float* kept=mCrushDemand+mCrushDemandCapacity;
                    if(start)check(cudaStreamWaitEvent(mStream,mCheckpointReady,0));
                    if(mImpactLog)check(cudaMemsetAsync(mCrushBoundAudit,0,sizeof(float)*6,mStream));
                    float* audit=mImpactLog?mCrushBoundAudit:nullptr;
                    crushDemand<<<(mN+127)/128,128,0,mStream>>>(mChunks,mMaterials,mCrush,mTrialCrush,mImpactStriker,mN,mCrushDemand,bodies,mStatus,audit);
                    if(bodies) {
                        crushSettle<<<(mN+127)/128,128,0,mStream>>>(mChunks,mMaterials,mCrush,mTrialCrush,mImpactStriker,mN,mCrushDemand,kept,payers,bodies,mStatus,audit);
                        crushPay<<<(bodies+127)/128,128,0,mStream>>>(mCrushDemand,kept,payers,bodies,mStatus);
                    }
                    if(start)check(cudaEventRecord(mCheckpointReady,mStream)); // the restore waits on it
                    if(audit) {
                        float a[6];check(cudaMemcpyAsync(a,audit,sizeof a,cudaMemcpyDeviceToHost,mStream));check(cudaStreamSynchronize(mStream));
                        if(a[0]+a[2]+a[4]>0.0f)std::fprintf(stderr,"[impact] crush pass %u: paid %.0f (%.4g J); not crushed: %.0f by no body that can pay (%.4g J), %.0f past their striker's kinetic energy (%.4g J)\n",
                            mPass,a[4],a[5],a[0],a[1],a[2],a[3]);
                    }
                }
                else if(!mPass && mImpactorCount && mCheckpointValid) {
                    check(cudaStreamWaitEvent(mStream,mCheckpointReady,0)); // after the capture
                    check(cudaMemsetAsync(mImpactEnergy,0,sizeof(float)*mImpactorCount,mStream));
                    crushEnergy<<<(mN+127)/128,128,0,mStream>>>(mChunks,mMaterials,mCrush,mTrialCrush,mImpactImpactor,mImpactEnergy,mN,mStatus);
                    payCrushEnergy<<<(mImpactorCount+127)/128,128,0,mStream>>>(mImpactors,mImpactorCount,mImpactEnergy,mCheckpointBodies,mCheckpointCount,mStatus);
                    check(cudaEventRecord(mCheckpointReady,mStream)); // the restore waits on it
                }
                else if(mImpactorCount)   // a corrected pass's crushes: no later pass pays them
                    crushEnergy<<<(mN+127)/128,128,0,mStream>>>(mChunks,mMaterials,mCrush,mTrialCrush,mImpactImpactor,mImpactEnergy,mN,mStatus,true);
                if(mImpactLog) {
                    float created=0.0f;
                    check(cudaMemcpyAsync(&created,reinterpret_cast<const char*>(mStatus)+offsetof(PxDestructionStageStatus,crushEnergyCreated),sizeof created,cudaMemcpyDeviceToHost,mStream));
                    check(cudaStreamSynchronize(mStream));
                    if(created>0.0f)std::fprintf(stderr,"[impact] CRUSH ENERGY CREATED: %.4g J in pass %u (crushes no body paid; a bug signal)\n",created,mPass);
                }
            }
            impact::View impactView{};impact::Inputs impactIn{};impact::Settings impactSettings{};bool impactRan=false;
            if(mImpactEnabled && mMaterials && mM && forces) {
                const auto stress=mSolver->deviceView();
                if(stress.nodeIslands && stress.bondIslands) {
                    impact::Inputs in{};
                    in.chunks=mChunks;in.chunkCount=mN;in.bonds=mBonds;in.bondCount=mM;in.materials=mMaterials;
                    in.ductileSlip=mImpactSlip;in.stiffness=mImpactStiffness;in.health=mHealth;
                    in.nodeBegin=mNodeBegin;in.nodeRefs=mNodeRefs;in.nodeIslands=stress.nodeIslands;in.bondIslands=stress.bondIslands;
                    in.accelerations=mInputs;in.elastic=forces;in.base=mImpactSettings.method>=1u?mImpactRest:mImpactStart;
                    // (The steps' J0 is the rest state: the elastic forces of the last
                    // tick their island had no patch. This pass's elastic solve, routed,
                    // carries no impact load, but after a topology change its 64
                    // iterations start cold in the changed components: as J0 its
                    // unconverged forces put joints at capacity at rest and the
                    // explicit arm's cannonball broke 2,242 joints, against 785-976.)
                    in.elasticBase=mImpactBase;in.stage=mStatus;
                    in.carried=mImpactCarriedStart;in.slipBefore=mImpactSlipStart;
                    in.crushed=mImpactCrush?mTrialCrush:nullptr;in.sections=mSectionBending?mSections:nullptr;
                    if(mImpactRows) {
                        in.rows=mImpactRows;in.rowCount=impact::kContactCapacity;in.rowCounter=mImpactRowCount;
                        in.rowDelta=mImpactRowDelta;in.rowForce=mImpactRowForce;in.rowBound=mImpactRowBound;
                        in.rowRouted=mImpactSettings.route?mImpactRowRouted:nullptr;
                        check(cudaMemsetAsync(mImpactRowDelta,0,sizeof(float)*6*size_t(impact::kContactCapacity),mStream));
                        check(cudaMemsetAsync(mImpactRowBound,0,sizeof(float)*size_t(impact::kContactCapacity),mStream));
                    }
                    impact::Settings settings=mImpactSettings;settings.dt=dt;
                    const bool timed=mImpactLog || mImpactCaptureDir;++mImpactEvaluations;
                    std::chrono::steady_clock::time_point t0;
                    if(timed){check(cudaStreamSynchronize(mStream));t0=std::chrono::steady_clock::now();}
                    mImpact.stepLog=mImpactLog;mImpact.submit(in,settings,mStream);impactIn=in;impactSettings=settings;impactRan=true;
                    impact::reportConvergence<<<1,1,0,mStream>>>(mImpact.w.status,mStatus,mCorrectionEnabled && !mAllowUnconverged,float(mImpact.longestDispatch));
                    // Machine safety: Apple GPUs do not preempt compute well; a dispatch
                    // past 100 ms starves the display (Settings::dispatchWork bounds it).
                    if(mImpact.longestDispatch>100.0)std::fprintf(stderr,"[impact] warning: a dispatch took %.0f ms (over 100 ms)\n",mImpact.longestDispatch);
                    impactView={mImpact.w.islandFlag,stress.bondIslands,mImpact.w.forces,mImpact.w.verdict};
                    // The impact step carries no plastic state: the next tick starts from the elastic forces;
                    // its rest state follows the islands it did not solve.
                    if(settings.method>=1u)impact::recordRest<<<(mM+127)/128,128,0,mStream>>>(mImpact.w.islandFlag,stress.bondIslands,forces,mImpactRest,mM);
                    impact::recordState<<<(mM+127)/128,128,0,mStream>>>(settings.method>=1u?nullptr:mImpact.w.islandFlag,stress.bondIslands,mImpact.w.forces,forces,mImpactState,mM,
                        mImpactCarried,mImpact.w.slip,mImpactSlipStart,mImpactSlipState);
                    if(timed) {
                        check(cudaMemcpyAsync(mImpactHostStatus,mImpact.w.status,sizeof(*mImpactHostStatus),cudaMemcpyDeviceToHost,mStream));
                        check(cudaStreamSynchronize(mStream));
                        const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
                        const auto& e=*mImpactHostStatus;
                        if(e.triggered && mImpactLog) {
                            std::fprintf(stderr,"[impact] evaluation %llu pass %u: %.1f ms in %u dispatches (longest %.1f ms)\n",(unsigned long long)mImpactEvaluations,mPass,ms,mImpact.dispatches,mImpact.longestDispatch);
                            std::vector<impact::SolveRecord> rec(impact::kLogCapacity);
                            check(cudaMemcpy(rec.data(),mImpactRecords,sizeof(rec[0])*rec.size(),cudaMemcpyDeviceToHost));
                            for(PxU32 i=0;i<std::min(e.solves,impact::kLogCapacity);++i)
                                std::fprintf(stderr,"[impact]   solve %u: island %u (%u links, %u nodes) level %u lambda %.3g clipped %u broken %u: %u iterations%s, residual %.2e\n",
                                    i,rec[i].island,rec[i].links,rec[i].nodes,rec[i].level,rec[i].lambda,rec[i].clipped,rec[i].broken,rec[i].iterations,rec[i].capped?" (capped)":"",rec[i].change);
                        }
                        if(e.triggered && mImpactLog && mImpactRows && e.contacts) {
                            PxU32 rows=0;check(cudaMemcpy(&rows,mImpactRowCount,sizeof rows,cudaMemcpyDeviceToHost));rows=std::min(rows,impact::kContactCapacity);
                            std::vector<impact::ContactRow> r(rows);std::vector<float> d(6*size_t(rows)),f(3*size_t(rows));
                            if(rows){check(cudaMemcpy(r.data(),mImpactRows,sizeof(r[0])*rows,cudaMemcpyDeviceToHost));
                                check(cudaMemcpy(d.data(),mImpactRowDelta,sizeof(float)*d.size(),cudaMemcpyDeviceToHost));
                                check(cudaMemcpy(f.data(),mImpactRowForce,sizeof(float)*f.size(),cudaMemcpyDeviceToHost));}
                            for(PxU32 i=0;i<rows && i<16;++i) {
                                float cu[6]={0,0,0,0,0,0};check(cudaMemcpy(cu,mImpact.w.u+6*size_t(r[i].chunk),sizeof cu,cudaMemcpyDeviceToHost));
                                const float closing=r[i].velocity[0]*r[i].normal[0]+r[i].velocity[1]*r[i].normal[1]+r[i].velocity[2]*r[i].normal[2];
                                std::fprintf(stderr,"[impact]   row %u: closing %.2f m/s along the force; chunk %u body %u (1/m %.3g) v (%.2f %.2f %.2f) dv (%.2f %.2f %.2f) trial load (%.3g %.3g %.3g) N; solved force (%.3g %.3g %.3g) N; delta v (%.2f %.2f %.2f); chunk's end velocity (%.2f %.2f %.2f)\n",
                                i,closing,r[i].chunk,r[i].body,r[i].im,r[i].velocity[0],r[i].velocity[1],r[i].velocity[2],r[i].dv[0],r[i].dv[1],r[i].dv[2],
                                r[i].load[0],r[i].load[1],r[i].load[2],f[3*i],f[3*i+1],f[3*i+2],d[6*i],d[6*i+1],d[6*i+2],cu[0]*dt,cu[1]*dt,cu[2]*dt);
                            }
                        }
                        if(mImpactCaptureDir && e.triggered && mImpactCaptures<PxU32(std::max(0,std::atoi(std::getenv("PX_DESTRUCTION_IMPACT_CAPTURE_COUNT")?std::getenv("PX_DESTRUCTION_IMPACT_CAPTURE_COUNT"):"4")))
                            && (ms>std::atof(std::getenv("PX_DESTRUCTION_IMPACT_CAPTURE_MS")?std::getenv("PX_DESTRUCTION_IMPACT_CAPTURE_MS"):"1000")
                                || ((e.diverged || e.infeasible || e.nonfinite || e.energyGain) && std::getenv("PX_DESTRUCTION_IMPACT_CAPTURE_SIGNALS")))) {
                            char path[1024];std::snprintf(path,sizeof path,"%s/impact-%llu-%u.impc",mImpactCaptureDir,(unsigned long long)mImpactEvaluations,mPass);
                            if(impact::writeCapture(path,in,settings,mImpactMaterialCount)){++mImpactCaptures;std::fprintf(stderr,"[impact] captured %s (%.1f ms)\n",path,ms);}
                        }
                        if(e.triggered)std::fprintf(stderr,"[impact] pass %u: %u islands, %u solves, %u iterations (%u capped, %u diverged), %u rounds, broke %u, yielded %u, %u contacts from %u impactors (%u rolled back, %u energy gains), %u capped fallback, %u infeasible projections, error %u\n",
                            mPass,e.triggered,e.solves,e.iterations,e.capped,e.diverged,e.rounds,e.broken,e.yielded,e.contacts,e.impactors,e.rolledBack,e.energyGain,e.cappedFallback,e.infeasible,e.error);
                        if(e.diverged)std::fprintf(stderr,"[impact] DIVERGED: %u solves (a bug signal); worst split at bond %u\n",e.diverged,e.worstBond-1u);
                        if(e.nonfinite)std::fprintf(stderr,"[impact] NON-FINITE: %u solves stopped on a non-finite residual (a bug signal); at bond %u\n",e.nonfinite,e.worstBond-1u);
                        if(e.infeasible)std::fprintf(stderr,"[impact] INFEASIBLE PROJECTIONS: %u (a bug signal)\n",e.infeasible);
                        if(e.energyDeficit)std::fprintf(stderr,"[impact] ENERGY DEFICIT: %u explicit patches dissipated more than their impactors and joints held (a bug signal)\n",e.energyDeficit);
                    }
                }
            }
            if(mMaterials) {
                if(mM)evaluateBondMaterials<<<(mM+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mHealth,forces,mM,
                    dt,mDamageRate,mBendGain,mFibres,mVerdicts,mBondCentroids,mStatus,mSectionBending,mSections,mSectionRotation,impactView);
                if(!mImpactCrush)evaluateChunkMaterials<<<(mN+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mNodeBegin,mNodeRefs,
                    mHealth,forces,mBondCentroids,mSurface,mRates,mCrush,mTrialCrush,mN,dt,mStatus,impactView);
                if(mM)finalizeMaterialVerdict<<<(mM+127)/128,128,0,mStream>>>(mBonds,mVerdicts,mTrialCrush,mHealth,mM,mStatus);
                if(mAnchoredBound && mN) {
                    if(mAnchoredReady) {
                        if(mImpactLog){check(cudaMemsetAsync(mAnchoredGhosts,0,sizeof(PxU32),mStream));check(cudaMemsetAsync(mAnchoredGhosts+9,0,sizeof(PxU32),mStream));}
                        anchoredGhostCheck<<<(mN+127)/128,128,0,mStream>>>(mAnchoredSaturated,mNodeBegin,mNodeRefs,mHealth,mVerdicts,mBonds,mImpactCrush?mTrialCrush:nullptr,mN,mStatus,mImpactLog?mAnchoredGhosts:nullptr);
                        if(mImpactLog) {
                            PxU32 g[10];check(cudaMemcpyAsync(g,mAnchoredGhosts,sizeof g,cudaMemcpyDeviceToHost,mStream));check(cudaStreamSynchronize(mStream));
                            if(g[9])std::fprintf(stderr,"[impact] anchored contacts at their bound: %u chunks in pass %u\n",g[9],mPass);
                            if(g[0])std::fprintf(stderr,"[impact] ANCHORED GHOSTS: %u chunks cut at their contact bound kept every bond (a bug signal); first %u %u %u %u\n",g[0],g[1],g[0]>1?g[2]:0u,g[0]>2?g[3]:0u,g[0]>3?g[4]:0u);
                            if(g[0]) {
                                PxU32 r[65];check(cudaMemcpy(r,mAnchoredSaturated+mN,sizeof r,cudaMemcpyDeviceToHost));
                                auto F=[](PxU32 x){float f;std::memcpy(&f,&x,4);return f;};
                                for(PxU32 k=0;k<std::min(r[0],8u);++k){const PxU32* o=r+1+8*k;
                                    std::fprintf(stderr,"[impact]   at the bound: chunk %u, body %u; impulse %.4g >= bound %.4g N s per point (bonds %.4g N s, mass %.4g kg, closing %.3g m/s, %u points)\n",
                                        o[0],o[1],F(o[2]),F(o[3]),F(o[4]),F(o[5]),F(o[6]),o[7]);}
                            }
                        }
                    }
                    // For the next pass's contact prep: this pass's live bonds.
                    anchoredChunkBounds<<<(mN+127)/128,128,0,mStream>>>(mChunks,mN,mAnchoredChunks);
                    if(mM)anchoredBondBounds<<<(mM+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mHealth,mImpactCrush?mTrialCrush:nullptr,dt,mM,mAnchoredBonds);
                    mAnchoredReady=true;
                }
                if(impactRan && mImpactLog && mImpactHostStatus) {
                    check(cudaMemsetAsync(mImpact.w.counters+6,0,sizeof(PxU32)*2,mStream));
                    impact::breaksBySource<<<(mM+127)/128,128,0,mStream>>>(mVerdicts,mImpact.w.islandFlag,impactIn.bondIslands,mM,mImpact.w.counters+6);
                    PxU32 by[2]={0,0};check(cudaMemcpyAsync(by,mImpact.w.counters+6,sizeof by,cudaMemcpyDeviceToHost,mStream));check(cudaStreamSynchronize(mStream));
                    if(by[0] || by[1])std::fprintf(stderr,"[impact] evaluation %llu pass %u breaks: %u on islands the impact %s decided, %u by the static verdict\n",
                        (unsigned long long)mImpactEvaluations,mPass,by[0],impactSettings.method>=1u?"step":"solve",by[1]);
                    // Diagnostics: a pass whose static verdict breaks at least
                    // PX_DESTRUCTION_IMPACT_CAPTURE_STATIC bonds is captured (with the
                    // evaluation before it, kept in a two-slot ring) beside the elastic
                    // solve's status.
                    if(mImpactStaticCapture) {
                        const unsigned long long ev=(unsigned long long)mImpactEvaluations;
                        char ring[1024],prior[1024];
                        std::snprintf(ring,sizeof ring,"%s/ring-%llu.impc",mImpactCaptureDir,ev&1ull);
                        std::snprintf(prior,sizeof prior,"%s/ring-%llu.impc",mImpactCaptureDir,(ev+1ull)&1ull);
                        if(by[1]>=mImpactStaticCapture) {
                            PxDestructionStageStatus st{};check(cudaMemcpy(&st,mStatus,sizeof st,cudaMemcpyDeviceToHost));
                            std::fprintf(stderr,"[impact] static collapse: evaluation %llu pass %u, the elastic solve %u iterations, converged %u\n",ev,mPass,st.iterations,st.converged);
                            char path[1024];std::snprintf(path,sizeof path,"%s/impact-%llu-%u-static.impc",mImpactCaptureDir,ev,mPass);
                            if(impact::writeCapture(path,impactIn,impactSettings,mImpactMaterialCount))std::fprintf(stderr,"[impact] captured %s\n",path);
                            std::snprintf(path,sizeof path,"%s/impact-%llu-prior.impc",mImpactCaptureDir,ev-1ull);
                            if(!std::rename(prior,path))std::fprintf(stderr,"[impact] captured %s (the evaluation before)\n",path);
                        }
                        impact::writeCapture(ring,impactIn,impactSettings,mImpactMaterialCount);
                    }
                }
                // The invariant where a corrected pass follows (the trial's stop).
                if(impactRan && impactIn.rows && !mPass) {
                    impact::heldOverCapacity<<<(impact::kContactCapacity+127)/128,128,0,mStream>>>(impactIn,impactSettings,mVerdicts,mImpact.w.status,mStatus);
                    if(mImpactLog && mImpactHostStatus) {
                        check(cudaMemcpyAsync(mImpactHostStatus,mImpact.w.status,sizeof(*mImpactHostStatus),cudaMemcpyDeviceToHost,mStream));
                        check(cudaStreamSynchronize(mStream));
                        if(mImpactHostStatus->heldOverCapacity)std::fprintf(stderr,"[impact] HELD OVER CAPACITY: %u contacts stopped rigidly by a struck chunk past capacity with nothing broken (a bug signal)\n",mImpactHostStatus->heldOverCapacity);
                    }
                }
                // With a topology the fused body-preparation kernel sets the bit.
                if(!mTopology){requireFractureCorrection<<<1,1,0,mStream>>>(mStatus);boundImpactContacts();}
            }
            stageMarker(3);
            // The impact solve's contact bounds request the corrected pass
            // before the topology transaction reads the request.
            if(mTopology)boundImpactContacts();
            if(mTopology) {
                check(cudaMemsetAsync(mTopologyCount,0,sizeof(*mTopologyCount),mStream));
                if(mMaterials)emitTopologyEdits<<<(std::max(mM,mN)+127)/128,128,0,mStream>>>(mVerdicts,mM,mTrialCrush,mCrush,mN,mTopologyEdits,mTopologyCount);
                provisionalTopologyMotion<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mChunks,mClusters,mPoses,bodyStates,mProvisionalMotion);
                check(cudaEventRecord(mReady,mStream));
                if(!mTopology->prepare(mTopologyEdits,mTopologyCount,mEditCapacity,&mStatus->error,~8u,mReady,nullptr,mProvisionalMotion,
                    mImpactBoundRequested && !mPass?mImpactBoundRequested:nullptr))
                    throw std::runtime_error("native topology transaction submission failed");
                check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(mTopology->trial().readyEvent),0));
                inspectTopologyAndBeginBodyPreparation<<<1,1,0,mStream>>>(mTopology->status(),mTopology->trial(),mBodyPreparation,mStatus,mMaterials!=nullptr);
                prepareCandidateBodies<<<(mN+127)/128,128,0,mStream>>>(mTopology->trial(),mChunks,mClusters,mTrialBodies,mBodyPreparation,mTopology->accepted(),mBodyRequests,mTrialBodyIndices,mPrincipalFrames);
                finishBodyPreparationAndBeginCommit<<<1,1,0,mStream>>>(mTopology->status(),mBodyPreparation,mStatus,mTopologyAccept);
                stageMarker(4);
                checkUnchangedMotionCommit<<<(mN+127)/128,128,0,mStream>>>(mTopology->accepted(),mTopology->trial(),mTopology->status(),mTopologyAccept,mChunks,mAffectedClusters,mCollisionPreparation);
                // The change record's first thread clears the correction bit when accepted.
                mChanges.commit(mTopology->accepted(),mTopology->trial(),mTopology->status(),mTopologyAccept,mChunks,mAffectedClusters,mStream,mStatus);
                if(mImpactBoundRequested && !mPass)keepBoundCorrection<<<1,1,0,mStream>>>(mImpactBoundRequested,mStatus);
                check(cudaEventRecord(mReady,mStream));
                if(!mTopology->commit(mTopologyAccept,mReady))throw std::runtime_error("native topology commit submission failed");
                check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(mTopology->accepted().readyEvent),0));
                if(mSolver) {
                    const auto accepted=mTopology->accepted();
                    if(!mSolver->updateDeviceTopologyAsync(accepted.activeBonds,mM,&accepted.status->generation,nullptr,accepted.readyEvent))
                        throw std::runtime_error("native stress topology update submission failed");
                    const auto stress=mSolver->deviceView();
                    check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(stress.readyEvent),0));
                }
                // Membership-changing verdicts remain incomplete until collision
                // rebinding and one internal motion correction are available.
                inspectStressAndCommitObservedMotion<<<std::max(1u,(mC+127)/128),128,0,mStream>>>(mTopology->accepted(),mProvisionalMotion,mStatus,
                    mSolver?mSolver->deviceView().topologyStatus:nullptr);
            }
            if(!mTopology)stageMarker(4);
            if(mMaterials)commitMaterialState<<<(std::max(mM,mN)+127)/128,128,0,mStream>>>(mVerdicts,mHealth,mM,mTrialCrush,mCrush,mN,mStatus,
                mPass?nullptr:&mCompletion->idle,eIDLE_STATE_CHANGED);
            stageMarker(5);
            if(mTopology && !mPass)mChanges.publish(mStream);
            check(cudaGetLastError());
            if(mBodyPreparation) {
                // The GPU producer consumes its own count. CPU compatibility
                // observes a completed assignment, never selects its work size.
                submitMotionAllocation();
            }
            observeCompletion();
            check(cudaEventRecord(mReady,mStream));mPending=true;return true;
        }catch(...){mFailed=true;return false;}
    }
    // The coupled contact's answer, enforced by the corrected pass: where the
    // impact solve bounded a pair (rowBound: a struck chunk that stays on at
    // capacity), the anchored cluster's contacts are bounded per point by it
    // in the corrected re-simulation (its max contact impulse, from the
    // rigid checkpoint the pass restores), and the pass is requested. The
    // impactor's motion is the rigid simulation's own: momentum is exchanged
    // only through contacts, never set.
    void boundImpactContacts() {
        // A request is this pass's only: cleared whether or not bounds follow.
        if(mImpactBoundRequested && !mPass)check(cudaMemsetAsync(mImpactBoundRequested,0,sizeof(PxU32),mStream));
        if(!mImpactRows || !mImpactEnabled || mPass || !mCorrectionEnabled || !mCheckpointValid) {
            if(mImpactLog && mImpactRows && !mPass)std::fprintf(stderr,"[impact] contact bounds off: correction %d checkpoint %d\n",int(mCorrectionEnabled),int(mCheckpointValid));
            return;
        }
        if(mMotionStorage.capacity>mImpactBoundCapacity) {
            check(cudaStreamSynchronize(mStream));
            for(float** a:{&mImpactBound,&mImpactSaved}){cudaFree(*a);*a=nullptr;allocate(*a,mMotionStorage.capacity);}
            cudaFree(mImpactBounded);mImpactBounded=nullptr;allocate(mImpactBounded,mMotionStorage.capacity);
            if(!mImpactBoundRequested){allocate(mImpactBoundRequested,1);check(cudaMemsetAsync(mImpactBoundRequested,0,sizeof(PxU32),mStream));}
            check(cudaMemsetAsync(mImpactBound,0,sizeof(float)*mMotionStorage.capacity,mStream));
            check(cudaMemsetAsync(mImpactBounded,0,sizeof(PxU32)*mMotionStorage.capacity,mStream));
            mImpactBoundCapacity=mMotionStorage.capacity;
        }
        check(cudaStreamWaitEvent(mStream,mCheckpointReady,0));
        check(cudaMemsetAsync(mImpactBoundRequested,0,sizeof(PxU32),mStream));
        collectImpactBounds<<<(impact::kContactCapacity+127)/128,128,0,mStream>>>(mImpactRows,mImpactRowCount,impact::kContactCapacity,
            mImpactRowBound,mChunks,mClusters,mImpactBound,mImpactBoundCapacity,mImpactSettings.boundImpactor,mImpactSettings.boundPairwise,
            (mAnchoredBound && mAnchoredReady)?mAnchoredChunks:nullptr,mN,mImpactBoundRequested);
        applyImpactBounds<<<(mImpactBoundCapacity+127)/128,128,0,mStream>>>(mImpactBound,mImpactSaved,mImpactBounded,mCheckpointBodies,
            mCheckpointCount,mImpactBoundCapacity,mStatus,mImpactBoundRequested,mImpactSettings.boundImpactor && mImpactSettings.boundPairwise);
        check(cudaEventRecord(mCheckpointReady,mStream));
        if(mImpactLog) {
            PxDestructionStageStatus st{};PxU32 rows=0;check(cudaMemcpyAsync(&st,mStatus,sizeof st,cudaMemcpyDeviceToHost,mStream));
            check(cudaMemcpyAsync(&rows,mImpactRowCount,sizeof rows,cudaMemcpyDeviceToHost,mStream));check(cudaStreamSynchronize(mStream));
            std::vector<float> b(std::min(rows,impact::kContactCapacity));if(!b.empty())check(cudaMemcpy(b.data(),mImpactRowBound,sizeof(float)*b.size(),cudaMemcpyDeviceToHost));
            PxU32 bounded=0;for(float x:b)bounded+=x>0.0f;
            std::fprintf(stderr,"[impact] contact bounds: %u of %u rows bounded; stage error %u (8: correction requested)\n",bounded,rows,st.error);
        }
    }
    // Bodies bounded for the last corrected pass take their own max impulse back.
    void restoreImpactBounds(const PxgBodySim* bodies) {
        if(!mImpactBoundCapacity)return;
        restoreImpactBoundsKernel<<<(mImpactBoundCapacity+127)/128,128,0,mStream>>>(mImpactSaved,mImpactBounded,const_cast<PxgBodySim*>(bodies),
            std::min(mImpactBoundCapacity,mMotionStorage.capacity));
    }
    void prepareDeviceInputs() {
        // Pointer/capacity refresh is ordinary submission metadata. No fracture
        // count or verdict crosses to the host to decide which stages execute.
        if(mCollisionStorage.shapeCapacity>mShapeOwnerCapacity) {
            const PxU32 capacity=PxU32(std::max<PxU64>(mCollisionStorage.shapeCapacity,
                std::min<PxU64>(PX_INVALID_U32,std::max<PxU64>(256,PxU64(mShapeOwnerCapacity)+mShapeOwnerCapacity/2))));
            PxU64* next=nullptr;allocate(next,capacity);
            try {check(cudaMemsetAsync(next,0,size_t(capacity)*sizeof(PxU64),mStream));}
            catch(...){cudaFree(next);throw;}
            check(cudaFree(mShapeOwnerGenerations));mShapeOwnerGenerations=next;mShapeOwnerCapacity=capacity;
        }
        check(cudaStreamWaitEvent(mStream,mCheckpointReady,0));
        NativePreparationInputs inputs{};inputs.collision=mCollisionStorage;
        inputs.checkpoint=mCheckpointValid?mCheckpointBodies:nullptr;inputs.previous=mCheckpointPrevious;
        inputs.commands=mCheckpointCommands;inputs.chunkLoads=passChunkLoads();
        inputs.commandScales=inputs.chunkLoads?mChunkCommandScales:nullptr;
        inputs.checkpointCount=mCheckpointValid?mCheckpointCount:0;inputs.checkpointGeneration=mCheckpointGeneration;
        inputs.bodyCapacity=mMotionStorage.capacity;inputs.clusterCount=mC;
        mDevicePreparation.setInputs(inputs,mStream);mCorrectionBodyCapacity=mMotionStorage.capacity;
    }
    void observeCompletion() {
        check(cudaMemcpyAsync(mHostCompletion,mCompletion,sizeof(*mCompletion),cudaMemcpyDeviceToHost,mStream));
    }
    void submitMotionAllocation(bool retry=false) {
        if(mProfiler) {
            for(auto& event:mMotionAllocationEvents)if(!event)check(cudaEventCreate(&event));
            check(cudaEventRecord(mMotionAllocationEvents[0],mStream));
        }
        check(mMotionAllocation.launch(mStream));
        mCollisionPreparationSubmitted=mCorrectionPreparationSubmitted=true;
        if(mProfiler) {
            check(cudaEventRecord(mMotionAllocationEvents[1],mStream));mMotionTimingPending=true;mMotionTimingRetry=retry;
        }
    }
    void collectMotionAllocationTiming() {
        if(!mMotionTimingPending)return;
        // Called after an existing completion wait; no new synchronization.
        float elapsed=0;check(cudaEventElapsedTime(&elapsed,mMotionAllocationEvents[0],mMotionAllocationEvents[1]));
        if(mProfiler)mProfiler->recordData(elapsed,mMotionTimingRetry
            ? "GpuDestruction.cuda.allocationAndPreparationRetry" : "GpuDestruction.cuda.allocationAndPreparation",mProfileContext);
        mMotionTimingPending=false;
    }
    void reserveBodySlots() {
        PxProfileScoped profile(mProfiler,"GpuDestruction.finishDetail.reserveBodies",false,mProfileContext);
        mHostReservedIndices.clear();mCompatibilityPrepared=false;
        if(!mTopology)return;
        mHostBodyAllocation=*mBodyAllocationObservation;
        auto& allocation=mHostBodyAllocation;
        if(mHostStatus->error!=8u || !mHostBodyPreparation->valid) {
            if(mBodyAllocator)mBodyAllocator->discardReservations();return;
        }
        const PxU32 count=mHostBodyPreparation->count,requested=mHostBodyPreparation->allocationRequests;
        if(PxU64(mCommittedMotionSlots)+requested>PX_INVALID_U32)throw std::runtime_error("native motion index capacity overflow");
        const PxU32 needed=mCommittedMotionSlots+requested;
        if(allocation.error==1u && needed>mMotionSlotCapacity) {
            PxProfileScoped growth(mProfiler,"GpuDestruction.finishDetail.growMotionSlots",false,mProfileContext);
            if(std::getenv("PX_DESTRUCTION_LOG_GRAPH_GROWTH"))
                std::fprintf(stderr,"[destruction] motion slots grow: %u needed > %u\n",needed,mMotionSlotCapacity);
            const PxU32 capacity=PxU32(std::min<PxU64>(PX_INVALID_U32,
                std::max<PxU64>(needed,std::max<PxU64>(256,PxU64(mMotionSlotCapacity)+mMotionSlotCapacity/2))));
            const PxU32* granted=nullptr;
            if(!mBodyAllocator || !mBodyAllocator->reserveNodeCapacity(capacity,granted))
                throw std::runtime_error("native motion index capacity grant failed");
            // Grow raw PhysX motion storage before any compatibility body exists.
            // This is an exceptional resource grant, not a CPU fragment decision.
            PxU32 storageCount=mMotionStorage.capacity;
            for(PxU32 i=0;i<capacity;++i) {
                if(granted[i]==PX_INVALID_U32)throw std::runtime_error("invalid native motion storage address");
                storageCount=std::max(storageCount,granted[i]+1);
            }
            if(!mGrowMotionStorage || !mGrowMotionStorage(mMotionStorageOwner,storageCount,mMotionStorage)
                || mMotionStorage.capacity<storageCount || !mMotionStorage.bodies)
                throw std::runtime_error("native motion storage capacity grant failed");
            check(cudaEventRecord(mInput,reinterpret_cast<cudaStream_t>(mMotionProducerStream)));
            check(cudaStreamWaitEvent(mStream,mInput,0));
            check(cudaStreamWaitEvent(mStream,mPreReady,0));
            if(mGraphView.generation)check(cudaStreamWaitEvent(mStream,mGraphReady,0));
            growNativeNodeStorage(mMotionStorage.capacity,mStream);
            check(mMotionAllocation.setNodes(mPreNodes,mPreRegistryCapacity,mStream));
            PxU32* next=nullptr;allocate(next,capacity);
            try {check(cudaMemcpyAsync(next,granted,size_t(capacity)*sizeof(PxU32),cudaMemcpyHostToDevice,mStream));}
            catch(...){cudaFree(next);throw;}
            check(cudaFree(mGrantedMotionIndices));mGrantedMotionIndices=next;mMotionSlotCapacity=capacity;
            check(mMotionAllocation.setResources(mGrantedMotionIndices,mMotionSlotCapacity,mMotionStorage,mStream));
            // Retry allocation/preparation only. The intact response, fracture verdict and
            // material evolution have already run and must not run again.
            prepareDeviceInputs();submitMotionAllocation(true);observeCompletion();
            check(cudaStreamSynchronize(mStream));
            allocation=*mBodyAllocationObservation;collectMotionAllocationTiming();
        }
        if(!allocation.valid || allocation.error || allocation.initialized!=requested || allocation.reserved!=requested
            || allocation.count!=count || allocation.generation!=mHostBodyPreparation->generation
            || (mHostStatus->error&~(8u|1024u|2048u)))throw std::runtime_error("native GPU motion allocation rejected");
    }
    bool prepareBodyCompatibility() {
        if(mCompatibilityPrepared)return true;
        // GPU collision and corrected-motion preparation are prerequisites for
        // CPU compatibility construction, never its consumers. The selected
        // motion addresses and complete preparation already exist on device.
        if(mHostStatus->error!=8u || !mHostCompletion->collision.valid || !mHostCompletion->correction.valid)return false;
        auto& allocation=mHostBodyAllocation;
        const PxU32 requested=allocation.reserved;
        PxvDestructionBodyRequest* requests=mPinnedBodyRequests.p;
        mOwnerMetadataPrefetched=false;
        // applyCorrectionBindings, which the controller calls next, reads only
        // device results complete here (selected owners and migrating shape
        // bindings). Take its readback in this synchronization, not another.
        const bool prefetch=mCorrectionEnabled && !mHostCompletion->correction.loadedSources
            && !mHostCompletion->collision.removed && mBodyAllocator;
        {
            PxProfileScoped requestProfile(mProfiler,"GpuDestruction.compatibility.requestReadback",false,mProfileContext);
            if(requested) {
                // CPU compatibility construction consumes the allocation decision.
                // The resulting indices already exist in the native GPU mapping.
                check(cudaMemcpyAsync(requests,mCompactBodyRequests,requested*sizeof(*mBodyRequests),cudaMemcpyDeviceToHost,mStream));
                check(cudaMemcpyAsync(mPinnedReservedIndices.p,mReturnedBodyIndices,requested*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
            }
            if(prefetch)readCorrectionOwnerMetadata();
            if(requested || prefetch)check(cudaStreamSynchronize(mStream));
            mOwnerMetadataPrefetched=prefetch;
            mHostReservedIndices.assign(mPinnedReservedIndices.p,mPinnedReservedIndices.p+requested);
        }
        auto& indices=mHostReservedIndices;
        bool allocated=false;
        {
            PxProfileScoped records(mProfiler,"GpuDestruction.compatibility.allocateNativeBodies",false,mProfileContext);
            allocated=mBodyAllocator && mBodyAllocator->prepare(requests,requested,indices.data());
        }
        if(!allocated) {allocation.error|=8u;allocation.valid=0;mHostStatus->error|=256u;
            mHostReservedIndices.clear();if(mBodyAllocator)mBodyAllocator->discardReservations();}
        PxProfileScoped publish(mProfiler,"GpuDestruction.compatibility.publishReservation",false,mProfileContext);
        // Merge only compatibility construction failure. Never overwrite a GPU
        // allocation error or upload CPU-selected indices/status over device work.
        if(!allocated) {
            finishNativeBodyShadowRegistration<<<1,1,0,mStream>>>(false,mBodyAllocation,mStatus);
            check(cudaGetLastError());check(cudaEventRecord(mReady,mStream));
        }
        if(allocated)mTickBodies.insert(indices.begin(),indices.end());
        mCompatibilityPrepared=allocated;return allocated;
    }
    bool captureRigidState(const PxgBodySim* bodies,const PxgBodySimVelocities* previous,
        const PxgRigidBodyAcceleration* accelerations,PxU32 count,CUstream coreStream,
        const PxgBodySimVelocityUpdate* commands,PxU32 commandCount) override {
        if(!mTopology)return true;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(mFailed || !bodies || !count || !stream || mCheckpointGeneration==std::numeric_limits<PxU64>::max())
                throw std::runtime_error("invalid rigid checkpoint boundary");
            if(mCheckpointValid)check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            // A corrected start-of-tick checkpoint keeps the command deltas of
            // the checkpoint it replaces (its rows are those bodies, restored).
            const bool carry=mCarryCorrectionCommands && mCheckpointCommands && mCheckpointValid && !commandCount;
            const PxU32 carried=carry?std::min(mCheckpointCount,count):0;
            mCarryCorrectionCommands=false;
            mCheckpointValid=false;mRestoredCheckpointGeneration=0;
            if(count>mCheckpointCapacity || bool(previous)!=mCheckpointHasPrevious || bool(accelerations)!=mCheckpointHasAccelerations) {
                // Growth happens at an ordered boundary: pre-solve, or right after
                // a pass installed fragments that read the old checkpoint on this
                // stream. Drain those readers before their source is released.
                // Allocation failure cannot truncate the checkpoint or mutate
                // accepted body state.
                PxgBodySim* freshBodies=nullptr;PxgBodySimVelocities* freshPrevious=nullptr;PxgBodySimVelocities* freshCommands=nullptr;
                PxgRigidBodyAcceleration* freshAccelerations=nullptr;
                const PxU64 grown=std::max<PxU64>(256,PxU64(mCheckpointCapacity)+mCheckpointCapacity/2);
                const PxU32 capacity=PxU32(std::max<PxU64>(count,std::min<PxU64>(grown,std::numeric_limits<PxU32>::max())));
                try {
                    allocate(freshBodies,capacity);if(mChunkLoads)allocate(freshCommands,capacity);
                    if(previous)allocate(freshPrevious,capacity);
                    if(accelerations)allocate(freshAccelerations,capacity);
                }catch(...) {cudaFree(freshBodies);cudaFree(freshCommands);cudaFree(freshPrevious);cudaFree(freshAccelerations);throw;}
                if(carried)check(cudaMemcpyAsync(freshCommands,mCheckpointCommands,size_t(carried)*sizeof(*mCheckpointCommands),cudaMemcpyDeviceToDevice,stream));
                check(cudaEventRecord(mCheckpointReady,stream));check(cudaEventSynchronize(mCheckpointReady));
                cudaFree(mCheckpointBodies);cudaFree(mCheckpointCommands);cudaFree(mCheckpointPrevious);cudaFree(mCheckpointAccelerations);
                mCheckpointBodies=freshBodies;mCheckpointCommands=freshCommands;mCheckpointPrevious=freshPrevious;mCheckpointAccelerations=freshAccelerations;
                mCheckpointCapacity=capacity;
                mCheckpointHasPrevious=previous!=nullptr;mCheckpointHasAccelerations=accelerations!=nullptr;
            }
            check(cudaMemcpyAsync(mCheckpointBodies,bodies,size_t(count)*sizeof(*bodies),cudaMemcpyDeviceToDevice,stream));
            if(carry) {
                if(count>carried)check(cudaMemsetAsync(mCheckpointCommands+carried,0,size_t(count-carried)*sizeof(*mCheckpointCommands),stream));
                const PxU32 installed=mHostCompletion->correction.count;
                check(cudaStreamWaitEvent(stream,mReady,0));
                if(installed)carryCorrectionCommands<<<(installed+127)/128,128,0,stream>>>(mCompactCorrectionBodies,installed,
                    mCorrectionCommandDeltas,mCheckpointCommands,count);
                check(cudaGetLastError());
            } else if(mCheckpointCommands) {
                check(cudaMemsetAsync(mCheckpointCommands,0,size_t(count)*sizeof(*mCheckpointCommands),stream));
                if(commandCount)captureHostCommandDeltas<<<(commandCount+127)/128,128,0,stream>>>(commands,commandCount,mCheckpointCommands,count);
            }
            if(previous)check(cudaMemcpyAsync(mCheckpointPrevious,previous,size_t(count)*sizeof(*previous),cudaMemcpyDeviceToDevice,stream));
            if(accelerations)check(cudaMemcpyAsync(mCheckpointAccelerations,accelerations,size_t(count)*sizeof(*accelerations),cudaMemcpyDeviceToDevice,stream));
            check(cudaEventRecord(mCheckpointReady,stream));
            mCheckpointCount=count;++mCheckpointGeneration;mCheckpointValid=true;return true;
        }catch(...) {mCheckpointValid=false;mFailed=true;return false;}
    }
    PxgDestructionRigidCheckpointView rigidCheckpoint() const override {
        PxgDestructionRigidCheckpointView result;
        if(mCheckpointValid) {
            result.bodies=mCheckpointBodies;result.previous=mCheckpointPrevious;result.accelerations=mCheckpointAccelerations;
            result.count=mCheckpointCount;result.generation=mCheckpointGeneration;result.ready=mCheckpointReady;
        }
        return result;
    }
    bool restoreRigidState(PxgBodySim* bodies,PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations,PxU32 capacity,PxU64 generation,CUstream coreStream) override {
        // Reject the whole operation before any device write. A generation is
        // never recycled by clear/reconfiguration, so stale views cannot rewind
        // a newly instantiated structure or a later timestep.
        if(mFailed || !mCheckpointValid || generation!=mCheckpointGeneration || capacity<mCheckpointCount || !bodies || !coreStream
            || bool(previous)!=mCheckpointHasPrevious || bool(accelerations)!=mCheckpointHasAccelerations)return false;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            correctionMarker(0,stream);
            check(cudaMemcpyAsync(bodies,mCheckpointBodies,size_t(mCheckpointCount)*sizeof(*bodies),cudaMemcpyDeviceToDevice,stream));
            if(previous)check(cudaMemcpyAsync(previous,mCheckpointPrevious,size_t(mCheckpointCount)*sizeof(*previous),cudaMemcpyDeviceToDevice,stream));
            if(accelerations)check(cudaMemcpyAsync(accelerations,mCheckpointAccelerations,size_t(mCheckpointCount)*sizeof(*accelerations),cudaMemcpyDeviceToDevice,stream));
            correctionMarker(1,stream);
            check(cudaEventRecord(mCheckpointReady,stream));mRestoredCheckpointGeneration=generation;return true;
        }catch(...) {mCheckpointValid=false;mFailed=true;return false;}
    }
    bool ownsBody(PxU32 gpuIndex) const override {return mHostOwnedBodies.count(gpuIndex)!=0;}
    bool bornThisTick(PxU32 gpuIndex) const override {return mTickBodies.count(gpuIndex)!=0;}
    bool ownsWorldConstraint(PxU32 index) const override {return mManagedConstraintIds.count(index)!=0;}
    PxU32 reservedBodyCount() const override {return PxU32(mHostReservedIndices.size());}
    const PxU32* reservedBodyIndices() const override {return mHostReservedIndices.data();}
    bool initializeReservedBodies(PxgBodySim* bodies,PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations,PxU32 capacity,CUstream coreStream) override {
        mPreparationObserved=false;mCollisionPreparationSubmitted=mCorrectionPreparationSubmitted=false;
        mHostCompletion->collision={};mHostCompletion->correction={};
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            const PxU32 count=reservedBodyCount();
            if(!count)return true;
            if(!bodies || !stream || !mHostBodyAllocation.valid || mHostStatus->error!=8u)
                throw std::runtime_error("invalid native body initialization boundary");
            // Storage growth is enqueued on this same PhysX stream. The ready
            // event orders candidate construction and returned native IDs.
            check(cudaStreamWaitEvent(stream,mReady,0));
            validateReservedBodies<<<(count+127)/128,128,0,stream>>>(mCompactBodyRequests,mReturnedBodyIndices,
                count,mTrialBodies,mHostBodyAllocation.count,capacity,mBodyAllocation);
            initializeReservedBodiesKernel<<<(count+127)/128,128,0,stream>>>(mCompactBodyRequests,mReturnedBodyIndices,
                count,mTrialBodies,bodies,previous,accelerations,mBodyAllocation);
            finishBodyInitialization<<<1,1,0,stream>>>(mBodyAllocation,mStatus);
            check(cudaGetLastError());
            check(cudaEventRecord(mReady,stream));
            // Submission only. Collision and corrected-motion preparation consume
            // initialization validity on device before their combined observation.
            return true;
        }catch(...) {
            mHostStatus->error|=512u;mHostBodyAllocation.initializationError|=2u;mHostBodyAllocation.initialized=0;
            try {Context current(mContext);
                // Exceptional submission failure must not race an earlier writer.
                if(coreStream)check(cudaStreamSynchronize(reinterpret_cast<cudaStream_t>(coreStream)));
                check(cudaMemcpyAsync(mBodyAllocation,&mHostBodyAllocation,sizeof(mHostBodyAllocation),cudaMemcpyHostToDevice,mStream));
                check(cudaMemcpyAsync(mStatus,mHostStatus,sizeof(*mStatus),cudaMemcpyHostToDevice,mStream));
                check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            }catch(...){mFailed=true;}
            return false;
        }
    }
    bool prepareCollisionBindings(const PxgShapeSim* shapes,PxU32 shapeCapacity,const PxNodeIndex* shapeToBody,PxU32 remapCapacity,CUstream coreStream) override {
        if(!mTopology || mHostStatus->error!=8u || !mHostBodyAllocation.valid)return true;
        mPreparationObserved=false;mCollisionPreparationSubmitted=mCorrectionPreparationSubmitted=false;
        mHostCompletion->collision={};mHostCompletion->correction={};
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(!stream)throw std::runtime_error("collision preparation requires a producer stream");
            check(cudaStreamWaitEvent(stream,mReady,0));
            if(shapeCapacity>mShapeOwnerCapacity) {
                // Exceptional capacity growth is inside the complete-step timer.
                // No previous-generation contents are needed by this correction.
                PxU64* next=nullptr;allocate(next,shapeCapacity);
                try {check(cudaMemsetAsync(next,0,size_t(shapeCapacity)*sizeof(PxU64),stream));}
                catch(...) {cudaFree(next);throw;}
                check(cudaFree(mShapeOwnerGenerations));mShapeOwnerGenerations=next;
                mShapeOwnerCapacity=shapeCapacity;
            }
            check(cudaMemsetAsync(mCandidateSlots,0xff,mN*sizeof(PxU32),stream));
            indexCandidateRoots<<<std::max(1u,(mHostBodyAllocation.count+127)/128),128,0,stream>>>(mTopology->trial(),mCandidateSlots);
            preparePersistentCollisionBindings<<<(mHullCount+127)/128,128,0,stream>>>(mChunks,mN,mHullBindings,mHullCount,mClusters,mAffectedClusters,
                mTopology->trial(),mCandidateSlots,mTrialBodyIndices,shapes,shapeCapacity,shapeToBody,remapCapacity,mCollisionBindings,mCollisionPreparation,mBodyAllocation);
            check(cudaGetLastError());
            check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mCompactCollisionBindings,
                &mCollisionPreparation->count,mHullCount,HasCollisionBinding{},stream));
            // Stable compaction keeps authored order at the CPU observation boundary.
            // The full GPU binding list still updates retained shapes, including
            // bounds, COM and contact-cache validity; only migrations rebuild pairs.
            check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mMigratingCollisionBindings,
                &mCollisionPreparation->migrating,mHullCount,HasMigratingCollisionBinding{},stream));
            finishCollisionPreparation<<<1,1,0,stream>>>(mCollisionPreparation,mBodyAllocation,mStatus);
            check(cudaGetLastError());
            check(cudaEventRecord(mReady,stream));mCollisionPreparationSubmitted=true;
            return true; // Submission only; the next stage consumes device validity.
        }catch(...) {
            mHostStatus->error|=1024u;mHostCompletion->collision.valid=0;mHostCompletion->collision.error|=16u;
            try {Context current(mContext);
                // Exceptional launch failure: drain submitted writers before publishing rejection.
                if(coreStream)check(cudaStreamSynchronize(reinterpret_cast<cudaStream_t>(coreStream)));
                check(cudaMemcpyAsync(mCollisionPreparation,&mHostCompletion->collision,sizeof(mHostCompletion->collision),cudaMemcpyHostToDevice,mStream));
                check(cudaMemcpyAsync(mStatus,mHostStatus,sizeof(*mStatus),cudaMemcpyHostToDevice,mStream));
                check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            }catch(...){mFailed=true;}
            return false;
        }
    }
    bool prepareCorrectionBodies(PxU32 bodyCapacity,CUstream coreStream) override {
        if(!mTopology || mHostStatus->error!=8u)return true;
        if(!mCollisionPreparationSubmitted)return false;
        mPreparationObserved=false;mCorrectionPreparationSubmitted=false;mHostCompletion->correction={};
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(!mCheckpointValid || !stream)throw std::runtime_error("missing correction input checkpoint");
            check(cudaStreamWaitEvent(stream,mReady,0));check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            check(cudaMemsetAsync(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation),stream));
            const auto loads=passChunkLoads();
            if(loads) {
                check(cudaMemsetAsync(mCorrectionCommandSums,0,4*sizeof(PxVec3)*mN,stream));
                sumCorrectionCommands<<<(mN+127)/128,128,0,stream>>>(mChunks,mN,mClusters,mTopology->trial().chunkCluster,mAffectedClusters,
                    mCheckpointBodies,mCheckpointCount,loads,mCorrectionCommandSums);
            }
            prepareCorrectionBodyInputs<<<(mN+127)/128,128,0,stream>>>(mTrialBodies,mTrialBodyIndices,mN,mTopology->trial(),mChunks,
                mAffectedClusters,mCheckpointBodies,mCheckpointPrevious,mCheckpointCount,bodyCapacity,mCollisionPreparation,mCorrectionBodies,mCorrectionPreparation,loads,mCheckpointCommands,
                mCorrectionCommandSums,mCorrectionCommandDeltas);
            inspectCorrectionSourceLoads<<<(mC+127)/128,128,0,stream>>>(mClusters,mAffectedClusters,mC,mCheckpointBodies,mCheckpointCount,mCollisionPreparation,mCorrectionPreparation,mChunkCommandSums,loads,mCheckpointCommands,
                loads?mChunkCommandScales:nullptr);
            check(cudaGetLastError());
            check(cub::DeviceSelect::If(mCorrectionScratch,mCorrectionScratchBytes,mCorrectionBodies,mCompactCorrectionBodies,
                &mCorrectionPreparation->count,mN,HasCorrectionBody{},stream));
            finishCorrectionPreparation<<<1,1,0,stream>>>(mCorrectionPreparation,mCollisionPreparation,mCheckpointGeneration,mStatus);
            check(cudaGetLastError());
            check(cudaEventRecord(mReady,stream));mCorrectionBodyCapacity=bodyCapacity;
            mCorrectionPreparationSubmitted=true;return true;
        }catch(...) {
            mHostStatus->error|=2048u;mHostCompletion->correction.valid=0;mHostCompletion->correction.error|=16u;
            try {Context current(mContext);
                // Exceptional launch failure: drain submitted writers before publishing rejection.
                if(coreStream)check(cudaStreamSynchronize(reinterpret_cast<cudaStream_t>(coreStream)));
                check(cudaMemcpyAsync(mCorrectionPreparation,&mHostCompletion->correction,sizeof(mHostCompletion->correction),cudaMemcpyHostToDevice,mStream));
                check(cudaMemcpyAsync(mStatus,mHostStatus,sizeof(*mStatus),cudaMemcpyHostToDevice,mStream));
                check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            }catch(...){mFailed=true;}
            return false;
        }
    }
    bool observeCorrectionPreparation() override {
        if(!mTopology || mHostStatus->error!=8u)return !mFailed && mHostStatus->error==0;
        if(mFailed || !mCollisionPreparationSubmitted || !mCorrectionPreparationSubmitted)return false;
        try {
            // The remaining CPU ownership bridge needs these compact verdicts.
            // Neither GPU preparation stage reads a host verdict or waits for one.
            Context current(mContext);
            // Normal submission already observed the complete device sequence at
            // finish. Explicit validation fixtures may resubmit a preparation;
            // only that diagnostic use needs a fresh observation here.
            if(!mPreparationObserved) {
                check(cudaStreamWaitEvent(mStream,mReady,0));observeCompletion();
                check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));mPreparationObserved=true;
            }
            return mHostStatus->error==8u && mHostCompletion->collision.valid && mHostCompletion->correction.valid;
        }catch(...){mFailed=true;return false;}
    }
    bool completeCorrectionPreparation() override {
        if(!observeCorrectionPreparation())return false;
        if(mHostStatus->error!=8u)return true;
        try {
            // Validation's context guard has ended. Construction performs CUDA
            // observations too, and must not initialize/use a worker's default
            // context. Order observations after the installed native owners.
            Context current(mContext);
            check(cudaStreamWaitEvent(mStream,mReady,0));
            return prepareBodyCompatibility();
        }catch(...){mFailed=true;return false;}
    }
    bool installCorrectionBodies(PxgBodySim* bodies,PxgBodySimVelocities* previous,PxgRigidBodyAcceleration* accelerations,
        PxU32 capacity,PxU64 checkpointGeneration,CUstream coreStream) override {
        if(mFailed || !mCheckpointValid || !mHostCompletion->correction.valid || mHostCompletion->correction.loadedSources
            || mHostStatus->error!=8u || !bodies || !coreStream || capacity<mCorrectionBodyCapacity
            || checkpointGeneration!=mCheckpointGeneration || checkpointGeneration!=mHostCompletion->correction.checkpointGeneration
            || mRestoredCheckpointGeneration!=checkpointGeneration
            || bool(previous)!=mCheckpointHasPrevious || bool(accelerations)!=mCheckpointHasAccelerations)return false;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            check(cudaStreamWaitEvent(stream,mReady,0));check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            const PxU32 count=mHostCompletion->correction.count;
            correctionMarker(2,stream);
            if(count)installCorrectionBodyInputs<<<(count+127)/128,128,0,stream>>>(mCompactCorrectionBodies,count,mCheckpointBodies,
                mCheckpointPrevious,bodies,previous,accelerations,
                passChunkLoads()?mDeferredGravity:nullptr,mDeferredGravity?mDeferredGravity+mN:nullptr,mN);
            correctionMarker(3,stream);
            // Another corrected pass below the limit follows: the controller
            // checkpoints this start-of-tick state, which must carry the shares.
            mCarryCorrectionCommands=passChunkLoads() && mPass+1<mCorrectionLimit;
            check(cudaGetLastError());check(cudaEventRecord(mReady,stream));return true;
        }catch(...) {mFailed=true;return false;}
    }
    bool installCollisionOwners(PxgShapeSim* shapes,PxU32 capacity,PxNodeIndex* shapeToBody,PxU32 remapCapacity,CUstream coreStream) override {
        if(mFailed || !mCorrectionEnabled || mHostStatus->error!=8u || !mHostCompletion->collision.valid
            || mHostCompletion->collision.removed || !mHostCompletion->correction.valid || !coreStream
            || (mHostCompletion->collision.count && (!shapes || !capacity || !shapeToBody || remapCapacity<capacity
                || !mShapeOwnerGenerations || mShapeOwnerCapacity<capacity || !mCheckpointGeneration)))return false;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            check(cudaStreamWaitEvent(stream,mReady,0));
            const PxU32 count=mHostCompletion->collision.count;
            correctionMarker(4,stream);
            if(count)installNativeCollisionOwners<<<(count+127)/128,128,0,stream>>>(mCompactCollisionBindings,count,shapes,capacity,shapeToBody,remapCapacity,
                mShapeOwnerGenerations,mCheckpointGeneration,mShapePublicationEpochs,mShapePublicationTargets,mStatus);
            correctionMarker(5,stream);
            check(cudaGetLastError());check(cudaEventRecord(mReady,stream));
            mInstalledOwnerGeneration=count?mCheckpointGeneration:0;return true;
        }catch(...){mFailed=true;return false;}
    }
    PxgDestructionOwnershipView collisionOwnershipView() const override {
        return {mShapeOwnerGenerations,mInstalledOwnerGeneration,mShapeOwnerCapacity};
    }
    bool preserveUnchangedContactPairs() const override { return mPreserveContactPairs; }
    bool correctionEnabled() const override { return mCorrectionEnabled; }
    PxU32 correctionLimit() const override { return mCorrectionLimit; }
    PxU32 correctionBodyCount() const override { return PxU32(mHostCorrectionTargets.size()); }
    const PxU32* correctionBodyIndices() const override { return mHostCorrectionTargets.data(); }
    bool applyCorrectionBindings() override {
        if(!mCorrectionEnabled || mFailed || mHostStatus->error!=8u || !mHostCompletion->collision.valid
            || !mHostCompletion->correction.valid || mHostCompletion->correction.loadedSources
            || mHostCompletion->collision.removed || !mBodyAllocator)return false;
        try {
            Context current(mContext);
            if(!mOwnerMetadataPrefetched) {
                check(cudaEventSynchronize(mReady));
                readCorrectionOwnerMetadata();
                check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            }
            mOwnerMetadataPrefetched=false;
            // CUDA has already selected every retained/new owner whose source
            // changed. Unchanged clusters need neither CPU ownership updates nor
            // a physical-state readback. Full rigid checkpoint replay remains
            // unchanged and still corrects ordinary interaction participants.
            const PxU32 count=mHostCompletion->correction.count;
            mHostCorrectionTargets.assign(mPinnedOwnerTargets.p,mPinnedOwnerTargets.p+count);
            if(!mBodyAllocator->applyBindings(mPinnedMigrating.p,mHostCompletion->collision.migrating,
                mPinnedOwnerRequests.p,mHostCorrectionTargets.data(),count))return false;
            return !mConstraintBindings || mBodyAllocator->applyConstraintBindings(mPinnedConstraintBindings.p,mConstraintCount);
        }catch(...){mFailed=true;return false;}
    }
    // Enqueue applyCorrectionBindings' observation on mStream: the selected
    // owners' metadata and the migrating shape bindings, into pinned staging.
    void readCorrectionOwnerMetadata() {
        const PxU32 count=mHostCompletion->correction.count,migrating=mHostCompletion->collision.migrating;
        if(mConstraintBindings) {
            prepareConstraintBindings<<<(mConstraintCount+127)/128,128,0,mStream>>>(mConstraintMap,mConstraintCount,
                mTopology->trial(),mCandidateSlots,mTrialBodyIndices,mConstraintBindings);
            check(cudaMemcpyAsync(mPinnedConstraintBindings.p,mConstraintBindings,mConstraintCount*sizeof(*mConstraintBindings),cudaMemcpyDeviceToHost,mStream));
        }
        if(count)gatherCorrectionOwnerMetadata<<<(count+127)/128,128,0,mStream>>>(
            mCompactCorrectionBodies,count,mCandidateSlots,mBodyRequests,mCorrectionOwnerRequests,mCorrectionOwnerTargets);
        check(cudaGetLastError());
        if(migrating)check(cudaMemcpyAsync(mPinnedMigrating.p,mMigratingCollisionBindings,migrating*sizeof(*mPinnedMigrating.p),cudaMemcpyDeviceToHost,mStream));
        if(count) {
            check(cudaMemcpyAsync(mPinnedOwnerRequests.p,mCorrectionOwnerRequests,count*sizeof(*mPinnedOwnerRequests.p),cudaMemcpyDeviceToHost,mStream));
            check(cudaMemcpyAsync(mPinnedOwnerTargets.p,mCorrectionOwnerTargets,count*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
        }
    }
    bool acceptCorrection(const PxgBodySim* bodies,CUstream coreStream) override {
        if(mFailed || !mCorrectionEnabled || !bodies || !coreStream || mHostStatus->error!=8u)return false;
        try {
            Context current(mContext);
            check(cudaEventRecord(mInput,reinterpret_cast<cudaStream_t>(coreStream)));
            check(cudaStreamWaitEvent(mStream,mInput,0));
            prepareNativeCorrectionAcceptance<<<1,1,0,mStream>>>(mStatus,mContactSequence,mTopologyAccept);
            mChanges.commit(mTopology->accepted(),mTopology->trial(),mTopology->status(),mTopologyAccept,mChunks,mAffectedClusters,mStream);
            check(cudaEventRecord(mReady,mStream));
            if(!mTopology->commit(mTopologyAccept,mReady))throw std::runtime_error("corrected topology commit failed");
            check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(mTopology->accepted().readyEvent),0));
            mC=mHostBodyPreparation->count;
            acceptClusterBindings<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mTrialBodyIndices,mClusters,mStatus);
            acceptChunkBindings<<<(mN+127)/128,128,0,mStream>>>(mTopology->accepted(),mCandidateSlots,mChunks,mStatus,mAffectedClusters,mPropertyEpochs);
            observeNativeClusters<<<(mC+127)/128,128,0,mStream>>>(mClusters,mC,bodies,mPoses,mAngular,mStatus);
            finishNativeCorrection<<<1,1,0,mStream>>>(mStatus);
            provisionalTopologyMotion<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mChunks,mClusters,mPoses,bodies,mProvisionalMotion);
            commitObservedTopologyMotion<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mProvisionalMotion,mStatus);
            if(mMaterials)commitMaterialState<<<(std::max(mM,mN)+127)/128,128,0,mStream>>>(mVerdicts,mHealth,mM,mTrialCrush,mCrush,mN,mStatus);
            check(cudaEventRecord(mReady,mStream));
            if(mSolver) {
                const auto accepted=mTopology->accepted();
                if(!mSolver->updateDeviceTopologyAsync(accepted.activeBonds,mM,&accepted.status->generation,nullptr,mReady))
                    throw std::runtime_error("corrected stress topology update failed");
                const auto stress=mSolver->deviceView();check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(stress.readyEvent),0));
                inspectStressTopology<<<1,1,0,mStream>>>(stress.topologyStatus,mStatus);
            }
            commitNativeMotionSlots<<<1,1,0,mStream>>>(mMotionSlots,mStatus);
            // A bound for final observation storage only, not a physical work
            // budget. CUDA selects the union of changed surviving owners once.
            if(mPropertyEpochs)mPendingPropertyCapacity=PxU32(std::min<PxU64>(mN,
                PxU64(mPendingPropertyCapacity)+mHostCompletion->correction.count));
            if(mShapePublicationEpochs)mPendingShapeCapacity=PxU32(std::min<PxU64>(mHullCount,
                PxU64(mPendingShapeCapacity)+mHostCompletion->collision.migrating));
            check(cudaGetLastError());
            if(mPass && mPass==mCorrectionLimit) {
                // The final pass: finishPostCorrection follows at once and
                // synchronizes anyway; it checks this acceptance's status and
                // completes it (acceptedCorrection) after that one wait.
                check(cudaEventRecord(mReady,mStream));
                mTailAcceptancePending=true;return true;
            }
            check(cudaMemcpyAsync(mHostStatus,mStatus,sizeof(*mStatus),cudaMemcpyDeviceToHost,mStream));
            check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            if(mHostStatus->error){collectCorrectionTimings();return false;}
            acceptedCorrection();return true;
        }catch(...){mFailed=true;return false;}
    }
    // Host bookkeeping of an accepted correction, once its status is observed.
    void acceptedCorrection() {
        collectCorrectionTimings();
        mCommittedMotionSlots+=mHostBodyAllocation.reserved;
        mHostOwnedBodies.insert(mHostReservedIndices.begin(),mHostReservedIndices.end());
        mBodyAllocator->acceptReservations();
    }
    bool exportWarmStart(float* values, PxU32 count) {
        if (!values || !mSolver || size_t(count)!=size_t(mM)*6 || mPending || mFailed
            || !mWriteAllowed(mScene) || !mHostStatus->frame || !mHostStatus->converged
            || mHostStatus->error || mEverDamaged || mHostStatus->brokenBonds || mHostStatus->crushedChunks) return false;
        try {
            Context current(mContext);
            check(cudaEventSynchronize(mReady));
            std::vector<ExtStressGpuImpulse> impulses(mM);
            if (!mSolver->readbackImpulses(impulses.data(), mM)) return false;
            for (PxU32 i=0;i<mM;++i) {
                const auto& v=impulses[i];
                const float f[]={v.angular.x,v.angular.y,v.angular.z,v.linear.x,v.linear.y,v.linear.z};
                for (PxU32 j=0;j<6;++j) {if(!std::isfinite(f[j]))return false;values[6*size_t(i)+j]=f[j];}
            }
            return true;
        } catch (...) {return false;}
    }
    bool importWarmStart(const float* values, PxU32 count) {
        if (!values || !mSolver || size_t(count)!=size_t(mM)*6 || mPending || mFailed
            || !mWriteAllowed(mScene) || mHostStatus->frame || mWarmImported || !mParams.warmStart) return false;
        try {
            Context current(mContext);
            check(cudaEventSynchronize(mReady));
            std::vector<ExtStressGpuImpulse> impulses(mM);
            for (PxU32 i=0;i<mM;++i) {
                const float* f=values+6*size_t(i);
                for(PxU32 j=0;j<6;++j)if(!std::isfinite(f[j]))return false;
                impulses[i].angular={f[0],f[1],f[2]};impulses[i].linear={f[3],f[4],f[5]};
            }
            if(!ExtStressGpuImportWarmStart(mSolver,impulses.data(),mM))return false;
            mWarmImported=true;
            return true;
        } catch (...) {return false;}
    }
    void logCommandMismatch() {
        static unsigned logged=0;if(logged>=16)return;++logged;
        std::vector<PxDestructionStressCluster> clusters(mC);std::vector<PxVec3> sums(4*size_t(mC));
        check(cudaMemcpy(clusters.data(),mClusters,mC*sizeof(clusters[0]),cudaMemcpyDeviceToHost));
        check(cudaMemcpy(sums.data(),mChunkCommandSums,sums.size()*sizeof(sums[0]),cudaMemcpyDeviceToHost));
        std::fprintf(stderr,"[PxDestruction] frame %llu pass %u/%u: chunk commands do not match rigid inputs (%u clusters)\n",
            static_cast<unsigned long long>(mHostStatus->frame),mPass,mCorrectionLimit,mC);
        const auto near=[](const PxVec3& a,const PxVec3& b){return a.isFinite() && b.isFinite() && (a-b).magnitude()<=1e-4f*(1+b.magnitude());};
        unsigned shown=0;
        for(PxU32 c=0;c<mC && shown<6;++c) {
            const PxU32 id=clusters[c].body;if(id>=mCheckpointCount)continue;
            PxgBodySim b{};PxgBodySimVelocities v{};
            check(cudaMemcpy(&b,mCheckpointBodies+id,sizeof(b),cudaMemcpyDeviceToHost));
            check(cudaMemcpy(&v,mCheckpointCommands+id,sizeof(v),cudaMemcpyDeviceToHost));
            const float im=b.linearVelocityXYZ_inverseMassW.w;
            const PxQuat q=b.body2World.getTransform().q;
            const PxVec3 inertia(b.inverseInertiaXYZ_contactReportThresholdW.x,b.inverseInertiaXYZ_contactReportThresholdW.y,b.inverseInertiaXYZ_contactReportThresholdW.z);
            const auto angular=[&](const PxVec3& t){return q.rotate(q.rotateInv(t).multiply(inertia));};
            const PxVec3 values[4][2]={
                {PxVec3(b.externalLinearAcceleration.x,b.externalLinearAcceleration.y,b.externalLinearAcceleration.z),sums[4*c]*im},
                {PxVec3(b.externalAngularAcceleration.x,b.externalAngularAcceleration.y,b.externalAngularAcceleration.z),angular(sums[4*c+1])},
                {PxVec3(v.linearVelocity.x,v.linearVelocity.y,v.linearVelocity.z),sums[4*c+2]*im},
                {PxVec3(v.angularVelocity.x,v.angularVelocity.y,v.angularVelocity.z),angular(sums[4*c+3])}};
            static const char* names[4]={"accel","angular accel","dv","dw"};
            bool bad=false;for(const auto& pair:values)bad|=!near(pair[0],pair[1]);
            if(!bad)continue;
            ++shown;
            std::fprintf(stderr,"  cluster %u body %u gravity %s invMass %g invInertia (%g %g %g):\n",c,id,b.disableGravity?"off":"on",im,inertia.x,inertia.y,inertia.z);
            for(PxU32 k=0;k<4;++k)if(!near(values[k][0],values[k][1]))std::fprintf(stderr,"    %s body (%g %g %g) vs commands (%g %g %g)\n",
                names[k],values[k][0].x,values[k][0].y,values[k][0].z,values[k][1].x,values[k][1].y,values[k][1].z);
        }
    }
    bool finish() override {
        try {Context current(mContext);if(mPending){
                {PxProfileScoped waitProfile(mProfiler,"GpuDestruction.finishDetail.waitForGpu",false,mProfileContext);
                    check(cudaEventSynchronize(mReady));}
                collectStageTimings();collectMotionAllocationTiming();mPending=false;
                if(mIdleSkipped) {
                    mIdleSkipped=false;
                    if(mHostCompletion->idle & eIDLE_INPUTS_CHANGED) {
                        // The inputs moved after all: evaluate this same frame in full,
                        // from a fresh status, before anything observes it.
                        PxProfileScoped reevaluation(mProfiler,"GpuDestruction.finishDetail.idleReevaluation",false,mProfileContext);
                        mIdleCertified=false;mIdleFull=true;
                        startFrame<<<1,1,0,mStream>>>(mStatus,mContactSequence,true,&mCompletion->idle);
                        if(mTopology)mChanges.start(mTopology->accepted(),mStatus,mStream);
                        const IdleFrame f=mIdleFrame;
                        if(advanceFull(f.dt,f.gravity,f.storage,f.producer,f.grow,f.owner,f.contacts,f.collision)) {
                            check(cudaEventSynchronize(mReady));
                            collectStageTimings();collectMotionAllocationTiming();mPending=false;
                        }
                    }
                }
                reserveBodySlots();mPreparationObserved=true;
                if(mIdleFull) {
                    mIdleFull=false;const auto& s=*mHostStatus;
                    mIdleCertified=mIdleGate && !mFailed && !s.error && !s.iterations && s.converged && !s.normalContacts
                        && !s.frictionAnchors && !s.bondCommands && !s.brokenBonds && !s.crushedChunks
                        && !(mHostCompletion->idle & (eIDLE_STATE_CHANGED|eIDLE_INPUTS_CHANGED));
                }}
            if(mHostStatus->brokenBonds || mHostStatus->crushedChunks)mEverDamaged=true;
            // PX_DESTRUCTION_LOG_TOPOLOGY_ERROR=1: say which stress topology check
            // raised error bit 64. The stage status carries only the bit.
            if((mHostStatus->error&64u) && mSolver && std::getenv("PX_DESTRUCTION_LOG_TOPOLOGY_ERROR")) {
                static unsigned logged=0;
                const auto stress=mSolver->deviceView();
                if(stress.topologyStatus && logged<8) {
                    ++logged;
                    std::remove_const_t<std::remove_pointer_t<decltype(stress.topologyStatus)>> t{};
                    check(cudaMemcpy(&t,stress.topologyStatus,sizeof(t),cudaMemcpyDeviceToHost));
                    std::fprintf(stderr,"[PxDestruction] frame %llu stress topology error 0x%08x (low 0x%02x, hierarchy %u, motion %u, bits24+ 0x%x) "
                        "initialized=%u generation=%llu solved=%llu rebuilds=%llu islands=%u bonds=%u nodes=%u\n",
                        static_cast<unsigned long long>(mHostStatus->frame),t.error,t.error&0xffu,(t.error>>8)&0xffu,(t.error>>16)&0xffu,t.error>>24,
                        t.initialized,static_cast<unsigned long long>(t.generation),static_cast<unsigned long long>(t.solvedGeneration),
                        static_cast<unsigned long long>(t.rebuilds),t.islandCount,t.activeBondCount,t.activeNodeCount);
                }
            }
            // PX_DESTRUCTION_LOG_COMMAND_MISMATCH=1: say which pass and which
            // clusters raised error bit 16384 (chunk commands do not match the
            // bodies' rigid inputs), with both sides of the comparison.
            if((mHostStatus->error&16384u) && mChunkLoads && mCheckpointValid && std::getenv("PX_DESTRUCTION_LOG_COMMAND_MISMATCH"))
                logCommandMismatch();
            if(mFailed)mHostStatus->error|=4u;
            return !mFailed && mHostStatus->error==0;
        }catch(...){mFailed=true;mHostStatus->error|=4u;
            mHostReservedIndices.clear();if(mBodyAllocator)mBodyAllocator->discardReservations();return false;}
    }
};
}}
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT physx::PxgDestructionRuntime*
PxCreateDestructionRuntimeV15(CUcontext c,void* scene,bool(*gate)(void*),physx::PxvDestructionBodyAllocator* allocator) {
    try {return new physx::Runtime(c,scene,gate,allocator);}catch(...){return nullptr;}
}

extern "C" PX_DESTRUCTION_RUNTIME_EXPORT bool
PxApplyDestructionSolverIslandMetadata(const physx::PxvIslandMetadataPage* pages,physx::PxU32 count,
    physx::PxU32* islandIds,physx::PxU32 nodes,physx::PxU32* staticTouches,physx::PxU32 islands,CUstream stream) {
    if(!count)return true;
    if(!stream || !pages || (nodes && !islandIds) || (islands && !staticTouches))return false;
    physx::destructionSolverMetadata::applyPages<<<count,128,0,reinterpret_cast<cudaStream_t>(stream)>>>(pages,count,islandIds,nodes,staticTouches,islands);
    return cudaGetLastError()==cudaSuccess;
}

// Additive entry points: no virtual table or existing factory ABI change.
// The scene pointer must come from this runtime's PxCreateDestructionRuntimeV15.
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT bool
PxDestructionExportWarmStartV1(physx::PxDestructionScene* scene, float* values, physx::PxU32 count) {
    return scene && static_cast<physx::Runtime*>(scene)->exportWarmStart(values,count);
}
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT bool
PxDestructionImportWarmStartV1(physx::PxDestructionScene* scene, const float* values, physx::PxU32 count) {
    return scene && static_cast<physx::Runtime*>(scene)->importWarmStart(values,count);
}
