// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgDestructionRuntime.h"
#include "PxgDestructionTopology.h"
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <cub/cub.cuh>
#include <cuda.h>
#include "PxgBodySim.h"
#include "PxgShapeSim.h"
#include "PxgContactManager.h"
#include "PxShape.h"
#include "PxsRigidBody.h"
#include "PxgDestructionBody.cuh"
#include "NvBlastExtStressMaterialFormula.h"
#include <set>
#include <algorithm>
#include <cmath>
#include <limits>
#include <stdexcept>
#include <vector>

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
#include "PxgDestructionMaterial.cuh"
// Rebind compact runtime cluster slots entirely on device after acceptance.
__global__ void acceptClusterBindings(PxDestructionTopologyDeviceView topology,
    const PxU32* targets,PxDestructionStressCluster* clusters,PxU32* bodies) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=topology.status->clusterCount)return;
    const auto mass=topology.clusters[topology.activeClusters[i]];
    clusters[i]={targets[i],PxVec3(float(mass.center[0]),float(mass.center[1]),float(mass.center[2]))};bodies[i]=targets[i];
}
__global__ void acceptChunkBindings(PxDestructionTopologyDeviceView topology,
    const PxU32* slots,PxDestructionStressChunk* chunks) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i<topology.chunkCount && topology.activeChunks[i])chunks[i].cluster=slots[topology.chunkCluster[i]];
}
__global__ void observeNativeClusters(const PxDestructionStressCluster* clusters,PxU32 count,
    const PxgBodySim* bodies,PxTransform* poses,PxVec3* angular) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto b=bodies[clusters[i].body];poses[i]=b.body2World.getTransform()*b.body2Actor_maxImpulseW.getTransform().getInverse();
    angular[i]=PxVec3(b.angularVelocityXYZ_maxPenBiasW.x,b.angularVelocityXYZ_maxPenBiasW.y,b.angularVelocityXYZ_maxPenBiasW.z);
}
__global__ void requireNativeConvergence(PxDestructionStageStatus* status) {
    if(!status->converged)status->error|=4096u;
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
__device__ PxU32 findChunk(const Lookup* map, PxU32 count, PxU32 contact) {
    PxU32 a=0,b=count;
    while(a<b) { PxU32 m=a+(b-a)/2; if(map[m].contact<contact)a=m+1;else b=m; }
    return a<count && map[a].contact==contact ? map[a].chunk : PX_INVALID_U32;
}
__device__ void add(PxVec3& target,const PxVec3& value) {
    atomicAdd(&target.x,value.x); atomicAdd(&target.y,value.y); atomicAdd(&target.z,value.z);
}
__global__ void startFrame(PxDestructionStageStatus* status) {
    const PxU64 frame=status->frame+1; *status={}; status->frame=frame;
}
__global__ void prepareLoads(const PxDestructionStressChunk* chunks, PxU32 n,
    const PxDestructionStressCluster* clusters, const PxTransform* poses,
    const PxVec3* angular, PxVec3 gravity, PxDestructionVectorPair* inputs,
    PxDestructionSurfaceLoad* surfaces, float* rates) {
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
    inputs[i].linear=pose.q.rotateInv(gravity)-w.cross(w.cross(r));
}
__device__ void contactLoad(PxU32 i,const PxDestructionStressChunk* chunks,
    const PxTransform* poses, const PxVec3& point, const PxVec3& impulse, float invDt,
    PxDestructionVectorPair* inputs, PxDestructionSurfaceLoad* surface) {
    if(i==PX_INVALID_U32)return;
    const auto c=chunks[i];
    const auto pose=poses[c.cluster];
    const PxVec3 f=pose.q.rotateInv(impulse)*invDt;
    const PxVec3 r=pose.transformInv(point)-c.position;
    add(surface[i].force,f); add(surface[i].torque,r.cross(f));
    float* v=surface[i].virial;
    atomicAdd(v+0,r.x*f.x);atomicAdd(v+1,r.y*f.y);atomicAdd(v+2,r.z*f.z);
    atomicAdd(v+3,0.5f*(r.x*f.y+r.y*f.x));
    atomicAdd(v+4,0.5f*(r.x*f.z+r.z*f.x));
    atomicAdd(v+5,0.5f*(r.y*f.z+r.z*f.y));
    if(c.mass>0)add(inputs[i].linear,f/c.mass);
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
__global__ void routeContacts(const PxGpuContactPair* pairs, const PxU32* count,
    PxU32 capacity, const Lookup* map, PxU32 maps, const PxDestructionStressChunk* chunks,
    const PxTransform* poses, float invDt, PxDestructionVectorPair* inputs,
    PxDestructionSurfaceLoad* surface, PxDestructionStageStatus* status,
    const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i==0 && *count>capacity)atomicOr(&status->error,1u);
    if(i>=*count || i>=capacity)return;
    const auto p=pairs[i];
    const PxU32 a=findChunk(map,maps,p.transformCacheRef0), b=findChunk(map,maps,p.transformCacheRef1);
    if(a==PX_INVALID_U32 && b==PX_INVALID_U32)return;
    if(p.nbContacts && p.contactPatches && p.contactPoints && p.contactForces) {
        PxContactStreamIterator it(p.contactPatches,p.contactPoints,NULL,p.nbPatches,p.nbContacts);
        PxU32 point=0;
        while(it.hasNextPatch()) { it.nextPatch(); while(it.hasNextContact()) { it.nextContact();
            const PxVec3 impulse=it.getContactNormal()*p.contactForces[point++];
            contactLoad(a,chunks,poses,it.getContactPoint(),impulse,invDt,inputs,surface);
            contactLoad(b,chunks,poses,it.getContactPoint(),-impulse,invDt,inputs,surface);
            contactRate(a,b,p,it.getContactPoint(),impulse,bodies,chunks,materials,rates,status);
            atomicAdd(&status->normalContacts,1u);
        }}
    }
    if(p.frictionPatches && p.contactPatches) {
        PxFrictionAnchorStreamIterator it(p.contactPatches,p.frictionPatches,p.nbPatches);
        while(it.hasNextPatch()) { it.nextPatch(); while(it.hasNextFrictionAnchor()) {it.nextFrictionAnchor();
            const auto impulse=it.getImpulse(); if(impulse.isZero())continue;
            contactLoad(a,chunks,poses,it.getPosition(),impulse,invDt,inputs,surface);
            contactLoad(b,chunks,poses,it.getPosition(),-impulse,invDt,inputs,surface);
            contactRate(a,b,p,it.getPosition(),impulse,bodies,chunks,materials,rates,status);
            atomicAdd(&status->frictionAnchors,1u);
        }}
    }
}
__global__ void finishStatus(const ExtStressGpuDeviceStatus* solve,PxDestructionStageStatus* status,
    const PxDestructionVectorPair* forces, PxU32 count) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!i) { status->iterations=solve?solve->iterations:0;status->converged=solve?solve->converged:1; }
    if(i<count && (!forces[i].linear.isFinite() || !forces[i].angular.isFinite())) atomicOr(&status->error,2u);
}

__global__ void provisionalTopologyMotion(PxDestructionTopologyDeviceView topology,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    const PxTransform* poses,const PxgBodySim* bodies,PxDestructionClusterMotion* motion) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=topology.status->clusterCount)return;
    const PxU32 root=topology.activeClusters[i],cluster=chunks[root].cluster;
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
}
__global__ void emitTopologyEdits(const PxDestructionBondVerdict* bonds,PxU32 nb,
    const PxDestructionCrushState* trial,const PxDestructionCrushState* accepted,PxU32 nc,
    PxgDestructionEdit* edits,PxU32* count) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<nb && bonds[i].broken)edits[atomicAdd(count,1u)]={PxgDestructionEditKind::BreakBond,i};
    if(i<nc && trial[i].crushed && !accepted[i].crushed)
        edits[atomicAdd(count,1u)]={PxgDestructionEditKind::DestroyChunk,i};
}
__global__ void inspectTopologyTransaction(const PxDestructionTopologyTransactionStatus* topology,PxDestructionStageStatus* status) {
    if(topology->error)status->error|=32u;
}
// A bond cut on a cycle can change internal stress without changing any
// chunk's collision ownership, cluster mass or motion degrees of freedom.
// Only that exact case can commit before native body rebinding/correction lands.
__global__ void beginUnchangedMotionCommit(const PxDestructionTopologyTransactionStatus* transaction,
    const PxDestructionStageStatus* status,PxU32* accept) {
    *accept=transaction->prepared && !transaction->error && !(status->error & ~8u);
}
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
__global__ void acceptUnchangedMotionCommit(const PxU32* accept,PxDestructionStageStatus* status) {
    if(*accept)status->error &= ~8u;
}
__global__ void inspectStressTopology(const ExtStressGpuDeviceTopologyStatus* topology,PxDestructionStageStatus* status) {
    if(topology->error)status->error|=64u;
}

__global__ void beginBodyPreparation(const PxDestructionTopologyTransactionStatus* transaction,
    PxDestructionTopologyDeviceView topology,PxDestructionBodyPreparationStatus* status) {
    *status={};
    if(transaction->prepared && !transaction->error) {status->generation=topology.status->generation;status->count=topology.status->clusterCount;}
}
__global__ void prepareCandidateBodies(PxDestructionTopologyDeviceView topology,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    PxDestructionClusterBodyState* bodies,PxDestructionBodyPreparationStatus* status,
    PxDestructionTopologyDeviceView accepted,PxvDestructionBodyRequest* requests,PxU32* bodyIndices) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=status->count)return;
    const PxU32 root=topology.activeClusters[i];PxDestructionClusterBodyState body;
    const PxU32 error=destructionBody::prepare(topology.clusters[root],topology.motions[i],body);
    body.cluster=root;body.sourceBody=clusters[chunks[root].cluster].body;bodies[i]=body;
    const PxU32 needsBody=accepted.activeChunks[root] && accepted.chunkCluster[root]==root?0u:1u;
    requests[i]={root,body.sourceBody,body.supported,needsBody,i};
    bodyIndices[i]=needsBody?PX_INVALID_U32:body.sourceBody;
    if(needsBody)atomicAdd(&status->allocationRequests,1u);
    if(error)atomicOr(&status->error,error);
}
struct NeedsBody {
    __host__ __device__ bool operator()(const PxvDestructionBodyRequest& request) const {return request.needsBody!=0;}
};
__global__ void bindReservedBodySlots(const PxvDestructionBodyRequest* requests,const PxU32* newIndices,PxU32 count,PxU32* indices) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i<count)indices[requests[i].candidateSlot]=newIndices[i];
}
__global__ void finishBodyPreparation(const PxDestructionTopologyTransactionStatus* transaction,
    PxDestructionBodyPreparationStatus* status,PxDestructionStageStatus* stage) {
    status->valid=transaction->prepared && !transaction->error && !status->error;
    if(status->error)stage->error|=128u;
}

__global__ void commitObservedTopologyMotion(PxDestructionTopologyDeviceView topology,
    const PxDestructionClusterMotion* motion,const PxDestructionStageStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!status->error && i<topology.status->clusterCount)topology.motions[i]=motion[i];
}

// Validate the complete reservation mapping before writing any native slot.
__global__ void validateReservedBodies(const PxvDestructionBodyRequest* requests,const PxU32* indices,
    PxU32 count,const PxDestructionClusterBodyState* candidates,PxU32 candidateCount,PxU32 capacity,
    PxDestructionBodyAllocationStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto r=requests[i];
    if(r.candidateSlot>=candidateCount || indices[i]>=capacity || r.sourceBody>=capacity
        || !r.needsBody || indices[i]==r.sourceBody) {atomicOr(&status->initializationError,1u);return;}
    const auto b=candidates[r.candidateSlot];
    if(b.cluster!=r.cluster || b.sourceBody!=r.sourceBody || b.supported!=r.supported)
        atomicOr(&status->initializationError,1u);
}
__device__ PxgBodySim nativeCandidateState(const PxDestructionClusterBodyState& candidate,const PxgBodySim& source,PxU32 id) {
    auto b=source;
    // Inherit physical settings from the authoritative GPU source, not the CPU
    // allocation placeholder. No velocity/mass/inertia clamps or extra locks.
    if(!candidate.supported)b.maxLinearVelocitySqX_maxAngularVelocitySqY_linearDampingZ_angularDampingW=b.dynamicLimitsDamping;
    b.linearVelocityXYZ_inverseMassW=make_float4(candidate.linearVelocity[0],candidate.linearVelocity[1],candidate.linearVelocity[2],candidate.inverseMass);
    b.angularVelocityXYZ_maxPenBiasW.x=candidate.angularVelocity[0];
    b.angularVelocityXYZ_maxPenBiasW.y=candidate.angularVelocity[1];
    b.angularVelocityXYZ_maxPenBiasW.z=candidate.angularVelocity[2];
    b.inverseInertiaXYZ_contactReportThresholdW.x=candidate.inverseInertia[0];
    b.inverseInertiaXYZ_contactReportThresholdW.y=candidate.inverseInertia[1];
    b.inverseInertiaXYZ_contactReportThresholdW.z=candidate.inverseInertia[2];
    b.body2World=PxAlignedTransform(candidate.bodyToWorldPosition[0],candidate.bodyToWorldPosition[1],candidate.bodyToWorldPosition[2],
        PxAlignedQuat(candidate.bodyToWorldOrientation[0],candidate.bodyToWorldOrientation[1],candidate.bodyToWorldOrientation[2],candidate.bodyToWorldOrientation[3]));
    const float maxImpulse=b.body2Actor_maxImpulseW.p.w;
    b.body2Actor_maxImpulseW=PxAlignedTransform(candidate.bodyToActorPosition[0],candidate.bodyToActorPosition[1],candidate.bodyToActorPosition[2],
        PxAlignedQuat(candidate.bodyToActorOrientation[0],candidate.bodyToActorOrientation[1],candidate.bodyToActorOrientation[2],candidate.bodyToActorOrientation[3]));
    b.body2Actor_maxImpulseW.p.w=maxImpulse;
    b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w=__uint_as_float(id);
    b.sleepLinVelAccXYZ_freezeCountW=make_float4(0,0,0,0);
    b.sleepAngVelAccXYZ_accelScaleW=make_float4(0,0,0,1);
    b.internalFlags &= PxsRigidBody::eSPECULATIVE_CCD_GPU | PxsRigidBody::eENABLE_GYROSCOPIC_GPU | PxsRigidBody::eRETAIN_ACCELERATION_GPU;
    // Trial commands already contributed to provisional motion. The later
    // rewind transaction must restore/distribute commands exactly once; cloning
    // the parent's acceleration accumulator here would duplicate them.
    b.externalLinearAcceleration=make_float4(0,0,0,0);
    b.externalAngularAcceleration=make_float4(0,0,0,0);
    return b;
}
__global__ void initializeReservedBodiesKernel(const PxvDestructionBodyRequest* requests,const PxU32* indices,
    PxU32 count,const PxDestructionClusterBodyState* candidates,PxgBodySim* bodies,
    PxgBodySimVelocities* previous,PxgRigidBodyAcceleration* accelerations,PxDestructionBodyAllocationStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count || status->initializationError)return;
    const auto candidate=candidates[requests[i].candidateSlot];const PxU32 id=indices[i];
    const auto b=nativeCandidateState(candidate,bodies[candidate.sourceBody],id);
    bodies[id]=b;
    if(previous) {previous[id].linearVelocity=b.linearVelocityXYZ_inverseMassW;previous[id].angularVelocity=b.angularVelocityXYZ_maxPenBiasW;}
    if(accelerations)accelerations[id]={};
}
__global__ void finishBodyInitialization(PxDestructionBodyAllocationStatus* allocation,PxDestructionStageStatus* status) {
    if(allocation->initializationError)status->error|=512u;
    else allocation->initialized=allocation->reserved;
}
// Rigid membership is determined by the GPU bond graph. This batch identifies
// native shape edits without traversing chunk/shape ownership on the CPU.
__global__ void indexCandidateRoots(PxDestructionTopologyDeviceView topology,PxU32* slots) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<topology.status->clusterCount)slots[topology.activeClusters[i]]=i;
}
__global__ void preparePersistentCollisionBindings(const PxDestructionStressChunk* chunks,PxU32 chunkCount,
    const PxDestructionStressCluster* clusters,const PxU32* affectedClusters,
    PxDestructionTopologyDeviceView topology,const PxU32* candidateSlots,const PxU32* candidateBodies,
    const PxgShapeSim* shapes,PxU32 shapeCapacity,PxDestructionCollisionBinding* bindings,
    PxDestructionCollisionPreparationStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=chunkCount)return;
    bindings[i]={i,PX_INVALID_U32,PX_INVALID_U32,PX_INVALID_U32};
    const auto chunk=chunks[i];if(!affectedClusters[chunk.cluster] || chunk.contactIndex==PX_INVALID_U32)return;
    const PxU32 shapeId=chunk.contactIndex,source=clusters[chunk.cluster].body;
    if(shapeId>=shapeCapacity || !shapes) {atomicOr(&status->error,1u);return;}
    const auto shape=shapes[shapeId];
    if(shape.mBodySimIndex.isStaticBody() || shape.mBodySimIndex.isArticulation() || shape.mBodySimIndex.index()!=source)
        {atomicOr(&status->error,2u);return;}
    const PxU32 kind=shape.mShapeType;
    if(!(shape.mShapeFlags&PxShapeFlag::eSIMULATION_SHAPE) || (shape.mShapeFlags&PxShapeFlag::eTRIGGER_SHAPE)
        || (kind!=PxGeometryType::eBOX && kind!=PxGeometryType::eSPHERE && kind!=PxGeometryType::eCAPSULE && kind!=PxGeometryType::eCONVEXMESH)
        || !shape.mTransform.isValid() || shape.mHullDataIndex==PX_INVALID_U32)
        {atomicOr(&status->error,8u);return;}
    PxU32 target=PX_INVALID_U32;
    if(topology.activeChunks[i]) {
        const PxU32 root=topology.chunkCluster[i];
        if(root>=chunkCount) {atomicOr(&status->error,4u);return;}
        const PxU32 slot=candidateSlots[root];
        if(slot>=topology.status->clusterCount || topology.activeClusters[slot]!=root)
            {atomicOr(&status->error,4u);return;}
        target=candidateBodies[slot];
        if(target==PX_INVALID_U32) {atomicOr(&status->error,4u);return;}
        if(target!=source)atomicAdd(&status->migrating,1u);
    } else atomicAdd(&status->removed,1u);
    bindings[i]={i,shapeId,source,target};
}
struct HasCollisionBinding {
    __host__ __device__ bool operator()(const PxDestructionCollisionBinding& b) const {return b.shape!=PX_INVALID_U32;}
};
__global__ void finishCollisionPreparation(PxDestructionCollisionPreparationStatus* collision,
    const PxDestructionBodyAllocationStatus* allocation,PxDestructionStageStatus* stage) {
    collision->generation=allocation->generation;
    collision->valid=!collision->error;
    if(collision->error)stage->error|=1024u;
}
#include "PxgDestructionCorrection.cuh"
class Runtime final : public PxgDestructionRuntime {
    CUcontext mContext; void* mScene; bool(*mWriteAllowed)(void*);
    cudaStream_t mStream{}; cudaEvent_t mInput{},mReady{}; CUevent mConsumer{};
    ExtStressGpuSolver* mSolver{}; ExtStressGpuSolveParams mParams;
    PxDestructionStressChunk* mChunks{}; PxDestructionStressCluster* mClusters{};
    PxRigidDynamicGPUIndex* mBodies{}; PxTransform* mPoses{}; PxVec3* mAngular{};
    Lookup* mMap{}; PxU32 mMapCount{},mN{},mM{},mC{},mCapacity{};
    PxGpuContactPair* mPairs{}; PxU32* mCount{};
    PxDestructionVectorPair* mInputs{}; PxDestructionSurfaceLoad* mSurface{};
    PxDestructionStageStatus* mStatus{}; PxDestructionStageStatus* mHostStatus{};
    PxDestructionMaterial* mMaterials{};PxDestructionStressBond* mBonds{};
    float *mHealth{},*mRates{};PxU32 *mNodeBegin{},*mNodeRefs{};
    PxVec3* mBondCentroids{};PxDestructionBondVerdict* mVerdicts{};
    PxDestructionCrushState *mCrush{},*mTrialCrush{};
    float mDamageRate=2,mBendGain=3;bool mFibres=true;
    PxgDestructionTopologyTransaction* mTopology{};
    PxDestructionClusterMotion* mProvisionalMotion{};
    PxDestructionClusterBodyState* mTrialBodies{};
    PxDestructionBodyPreparationStatus* mBodyPreparation{};
    PxDestructionBodyPreparationStatus* mHostBodyPreparation{};
    PxvDestructionBodyAllocator* mBodyAllocator{};
    PxvDestructionBodyRequest* mBodyRequests{};
    PxvDestructionBodyRequest* mCompactBodyRequests{};
    PxU32* mReturnedBodyIndices{};
    void* mBodyRequestScratch{};size_t mBodyRequestScratchBytes{};
    PxU32* mTrialBodyIndices{};
    PxvDestructionBodyRequest* mCorrectionOwnerRequests{};
    PxU32* mCorrectionOwnerTargets{};
    PxDestructionBodyAllocationStatus* mBodyAllocation{};
    PxDestructionBodyAllocationStatus mHostBodyAllocation{};
    std::vector<PxU32> mHostReservedIndices;
    PxU32* mAffectedClusters{};PxU32* mCandidateSlots{};
    PxDestructionCollisionBinding *mCollisionBindings{},*mCompactCollisionBindings{};
    PxDestructionCollisionPreparationStatus* mCollisionPreparation{};
    PxDestructionCollisionPreparationStatus mHostCollisionPreparation{};
    void* mCollisionScratch{};size_t mCollisionScratchBytes{};
    PxgDestructionEdit* mTopologyEdits{};PxU32* mTopologyCount{};PxU32* mTopologyAccept{};PxU32 mEditCapacity{};
    PxDestructionCorrectionBody *mCorrectionBodies{},*mCompactCorrectionBodies{};
    PxDestructionCorrectionPreparationStatus* mCorrectionPreparation{};
    PxDestructionCorrectionPreparationStatus mHostCorrectionPreparation{};
    void* mCorrectionScratch{};size_t mCorrectionScratchBytes{};
    PxU32 mCorrectionBodyCapacity{};
    PxU64 mRestoredCheckpointGeneration{};
    PxgBodySim* mCheckpointBodies{};
    PxgBodySimVelocities* mCheckpointPrevious{};
    PxgRigidBodyAcceleration* mCheckpointAccelerations{};
    PxU32 mCheckpointCapacity{},mCheckpointCount{};
    PxU64 mCheckpointGeneration{};
    bool mCheckpointHasPrevious=false,mCheckpointHasAccelerations=false,mCheckpointValid=false;
    cudaEvent_t mCheckpointReady{};
    bool mPending=false; bool mFailed=false;
    bool mCorrectionEnabled=false;
    std::vector<PxU32> mHostCorrectionTargets;
public:
    Runtime(CUcontext c,void* scene,bool(*gate)(void*),PxvDestructionBodyAllocator* allocator) : mContext(c),mScene(scene),mWriteAllowed(gate),mBodyAllocator(allocator) {
        Context current(c);
        check(cudaStreamCreateWithFlags(&mStream,cudaStreamNonBlocking));
        check(cudaEventCreateWithFlags(&mInput,cudaEventDisableTiming));
        check(cudaEventCreateWithFlags(&mReady,cudaEventDisableTiming));
        check(cudaEventCreateWithFlags(&mCheckpointReady,cudaEventDisableTiming));
        allocate(mCount,1); allocate(mStatus,1);
        check(cudaMallocHost(&mHostStatus,sizeof(*mHostStatus)));*mHostStatus={};
        check(cudaMemset(mStatus,0,sizeof(*mStatus)));
        check(cudaEventRecord(mReady,mStream));
    }
    bool buildContactInputs(PxgContactManagerInput* inputs,PxU32 count,
        const PxgShapeSim* shapes,PxU32 shapeCapacity,CUstream stream) override {
        if(mFailed || !mCorrectionEnabled || !stream || (count && (!inputs || !shapes || !shapeCapacity)))return false;
        try {
            Context current(mContext);
            if(count)buildNativeContactInputs<<<(count+127)/128,128,0,reinterpret_cast<cudaStream_t>(stream)>>>(inputs,count,shapes,shapeCapacity);
            check(cudaGetLastError());return true;
        }catch(...){mFailed=true;return false;}
    }
    void release() override { delete this; }
    ~Runtime() override {
        Context current(mContext); cudaStreamSynchronize(mStream);clear();
        cudaFree(mCount);cudaFree(mStatus);cudaFree(mPairs);cudaFreeHost(mHostStatus);
        cudaEventDestroy(mInput);cudaEventDestroy(mReady);cudaEventDestroy(mCheckpointReady);cudaStreamDestroy(mStream);
    }
    void clear() {
        cudaEventSynchronize(mReady); // also orders private installation on the scene stream
        mHostCorrectionPreparation={};mCorrectionBodyCapacity=0;mRestoredCheckpointGeneration=0;
        mHostCorrectionTargets.clear();mCorrectionEnabled=false;
        cudaFree(mCorrectionOwnerRequests);mCorrectionOwnerRequests=nullptr;
        cudaFree(mCorrectionOwnerTargets);mCorrectionOwnerTargets=nullptr;
        cudaFree(mCorrectionBodies);mCorrectionBodies=nullptr;cudaFree(mCompactCorrectionBodies);mCompactCorrectionBodies=nullptr;
        cudaFree(mCorrectionPreparation);mCorrectionPreparation=nullptr;cudaFree(mCorrectionScratch);mCorrectionScratch=nullptr;mCorrectionScratchBytes=0;
        if(mCheckpointValid)cudaEventSynchronize(mCheckpointReady);
        mCheckpointValid=false;mCheckpointCount=0;mCheckpointCapacity=0;
        mCheckpointHasPrevious=mCheckpointHasAccelerations=false;
        cudaFree(mCheckpointBodies);mCheckpointBodies=nullptr;
        cudaFree(mCheckpointPrevious);mCheckpointPrevious=nullptr;
        cudaFree(mCheckpointAccelerations);mCheckpointAccelerations=nullptr;
        mHostReservedIndices.clear();mHostBodyAllocation={};mHostCollisionPreparation={};
        cudaFree(mAffectedClusters);mAffectedClusters=nullptr;cudaFree(mCandidateSlots);mCandidateSlots=nullptr;
        cudaFree(mCollisionBindings);mCollisionBindings=nullptr;cudaFree(mCompactCollisionBindings);mCompactCollisionBindings=nullptr;
        cudaFree(mCollisionPreparation);mCollisionPreparation=nullptr;cudaFree(mCollisionScratch);mCollisionScratch=nullptr;mCollisionScratchBytes=0;
        if(mBodyAllocator)mBodyAllocator->clear();
        cudaFree(mCompactBodyRequests);mCompactBodyRequests=nullptr;
        cudaFree(mReturnedBodyIndices);mReturnedBodyIndices=nullptr;
        cudaFree(mBodyRequestScratch);mBodyRequestScratch=nullptr;mBodyRequestScratchBytes=0;
        cudaFree(mBodyRequests);mBodyRequests=nullptr;cudaFree(mTrialBodyIndices);mTrialBodyIndices=nullptr;
        cudaFree(mBodyAllocation);mBodyAllocation=nullptr;cudaFreeHost(mHostBodyPreparation);mHostBodyPreparation=nullptr;
        if(mTopology)mTopology->release();mTopology=nullptr;
        cudaFree(mProvisionalMotion);mProvisionalMotion=nullptr;
        cudaFree(mTrialBodies);mTrialBodies=nullptr;cudaFree(mBodyPreparation);mBodyPreparation=nullptr;
        cudaFree(mTopologyEdits);mTopologyEdits=nullptr;cudaFree(mTopologyCount);mTopologyCount=nullptr;mEditCapacity=0;
        cudaFree(mTopologyAccept);mTopologyAccept=nullptr;
        if(mSolver)mSolver->release();mSolver=nullptr;
        cudaFree(mChunks);mChunks=nullptr;cudaFree(mClusters);mClusters=nullptr;
        cudaFree(mBodies);mBodies=nullptr;cudaFree(mPoses);mPoses=nullptr;cudaFree(mAngular);mAngular=nullptr;
        cudaFree(mMap);mMap=nullptr;cudaFree(mInputs);mInputs=nullptr;cudaFree(mSurface);mSurface=nullptr;
        cudaFree(mMaterials);mMaterials=nullptr;cudaFree(mBonds);mBonds=nullptr;
        cudaFree(mHealth);mHealth=nullptr;cudaFree(mRates);mRates=nullptr;
        cudaFree(mNodeBegin);mNodeBegin=nullptr;cudaFree(mNodeRefs);mNodeRefs=nullptr;
        cudaFree(mBondCentroids);mBondCentroids=nullptr;cudaFree(mVerdicts);mVerdicts=nullptr;
        cudaFree(mCrush);mCrush=nullptr;cudaFree(mTrialCrush);mTrialCrush=nullptr;
        mN=mM=mC=mMapCount=0;
    }
    bool configureStress(const PxDestructionStressDesc& d) override {
        if(!mWriteAllowed(mScene) || !d.chunks || (d.bondCount && !d.bonds) || !d.clusters
            || !d.chunkCount || !d.clusterCount || !d.maxIterations
            || d.internalCorrectionLimit>1 || (d.internalCorrectionLimit && !d.chunkMassProperties)
            || !std::isfinite(d.tolerance) || d.tolerance<=0)return false;
        try {
        std::vector<PxDestructionMaterial> materials;
        if(d.materialCount) {
            if(!d.materials || !std::isfinite(d.damageRate) || d.damageRate<=0 || !std::isfinite(d.bendGainMax))return false;
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
        std::set<std::pair<PxU32,PxU32>> pairs;
        std::vector<PxU32> begin(d.chunkCount+1,0),refs(2*size_t(d.bondCount));
        std::vector<float> health(d.bondCount);
        std::vector<ExtStressGpuNode> nodes(d.chunkCount);
        std::vector<ExtStressGpuBond> bonds(d.bondCount);std::vector<Lookup> map;
        std::vector<PxRigidDynamicGPUIndex> bodies(d.clusterCount);
        for(PxU32 i=0;i<d.clusterCount;++i) {
            if(d.clusters[i].body==PX_INVALID_U32 || !d.clusters[i].centerOfMass.isFinite()
                || !mBodyAllocator || !mBodyAllocator->isValidSource(d.clusters[i].body))return false;
            bodies[i]=d.clusters[i].body;
        }
        for(PxU32 i=0;i<d.chunkCount;++i) {
            const auto c=d.chunks[i];
            if(c.cluster>=d.clusterCount || !c.position.isFinite() || !std::isfinite(c.mass)
                || c.mass<0 || !std::isfinite(c.inertia) || c.inertia<0 || (c.mass>0 && c.inertia<=0))return false;
            if(d.materialCount && (c.material>=d.materialCount || !std::isfinite(c.volume) || c.volume<0
                || (materials[c.material].crush.capPressure>0 && c.mass>0 && c.volume<=0)))return false;
            nodes[i]={{c.position.x,c.position.y,c.position.z},c.mass,c.inertia};
            if(c.contactIndex!=PX_INVALID_U32)map.push_back({c.contactIndex,i});
        }
        std::sort(map.begin(),map.end(),[](const Lookup&a,const Lookup&b){return a.contact<b.contact;});
        for(size_t i=1;i<map.size();++i)if(map[i-1].contact==map[i].contact)return false;
        for(PxU32 i=0;i<d.bondCount;++i) {
            const auto b=d.bonds[i];
            if(b.chunk0>=d.chunkCount || b.chunk1>=d.chunkCount || b.chunk0==b.chunk1
                || d.chunks[b.chunk0].cluster!=d.chunks[b.chunk1].cluster
                || !b.centroid.isFinite() || !b.normal.isFinite() || !std::isfinite(b.area) || b.area<=0
                || !std::isfinite(b.health) || b.health<=0 || !std::isfinite(b.complianceScale) || b.complianceScale<=0)return false;
            if(d.materialCount && (b.material>=d.materialCount || b.chunk0>=b.chunk1
                || !pairs.insert({b.chunk0,b.chunk1}).second))return false;
            ++begin[b.chunk0+1];++begin[b.chunk1+1];health[i]=b.health;
            bonds[i]={};bonds[i].node0=b.chunk0;bonds[i].node1=b.chunk1;
            for(PxU32 k=0;k<3;++k){bonds[i].centroid[k]=b.centroid[k];bonds[i].normal[k]=b.normal[k];}
            bonds[i].area=b.area;bonds[i].health=b.health;bonds[i].colScale=b.complianceScale;
        }
        std::vector<PxgDestructionBond> topologyBonds;
        if(d.chunkMassProperties) {
            if(size_t(d.chunkCount)+d.bondCount>size_t(std::numeric_limits<int>::max()))return false;
            std::set<PxU32> boundBodies;
            for(PxU32 body:bodies)if(!boundBodies.insert(body).second)return false;
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
            clear();mPending=false;mFailed=false;mCorrectionEnabled=d.internalCorrectionLimit==1;
            if(d.bondCount) {
                mSolver=ExtStressGpuSolver::create(nodes.data(),d.chunkCount,bonds.data(),d.bondCount,NULL,0,mContext);
                if(!mSolver || !mSolver->prepareDeviceSolve()){clear();return false;}
            }
            allocate(mChunks,d.chunkCount);allocate(mClusters,std::max(d.chunkCount,d.clusterCount));allocate(mBodies,std::max(d.chunkCount,d.clusterCount));
            allocate(mPoses,std::max(d.chunkCount,d.clusterCount));allocate(mAngular,std::max(d.chunkCount,d.clusterCount));allocate(mMap,map.size());
            allocate(mInputs,d.chunkCount);allocate(mSurface,d.chunkCount);
            check(cudaMemcpy(mChunks,d.chunks,sizeof(*mChunks)*d.chunkCount,cudaMemcpyHostToDevice));
            check(cudaMemcpy(mClusters,d.clusters,sizeof(*mClusters)*d.clusterCount,cudaMemcpyHostToDevice));
            check(cudaMemcpy(mBodies,bodies.data(),sizeof(*mBodies)*d.clusterCount,cudaMemcpyHostToDevice));
            if(!map.empty())check(cudaMemcpy(mMap,map.data(),sizeof(*mMap)*map.size(),cudaMemcpyHostToDevice));
            mN=d.chunkCount;mM=d.bondCount;mC=d.clusterCount;mMapCount=PxU32(map.size());
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
            }
            if(d.chunkMassProperties) {
                mTopology=PxgDestructionTopologyTransaction::create(d.chunkMassProperties,d.chunkCount,topologyBonds.data(),d.bondCount);
                if(!mTopology || (mSolver && !mSolver->enableDeviceTopology())){clear();return false;}
                allocate(mTopologyAccept,1);
                allocate(mAffectedClusters,d.chunkCount);allocate(mCandidateSlots,d.chunkCount);
                allocate(mCollisionBindings,d.chunkCount);allocate(mCompactCollisionBindings,d.chunkCount);allocate(mCollisionPreparation,1);
                check(cudaMemset(mCollisionPreparation,0,sizeof(*mCollisionPreparation)));
                check(cub::DeviceSelect::If(nullptr,mCollisionScratchBytes,mCollisionBindings,mCompactCollisionBindings,
                    &mCollisionPreparation->count,d.chunkCount,HasCollisionBinding{},mStream));
                check(cudaMalloc(&mCollisionScratch,mCollisionScratchBytes));
                allocate(mCorrectionOwnerRequests,d.chunkCount);allocate(mCorrectionOwnerTargets,d.chunkCount);
                allocate(mCorrectionBodies,d.chunkCount);allocate(mCompactCorrectionBodies,d.chunkCount);allocate(mCorrectionPreparation,1);
                check(cudaMemset(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation)));
                check(cub::DeviceSelect::If(nullptr,mCorrectionScratchBytes,mCorrectionBodies,mCompactCorrectionBodies,
                    &mCorrectionPreparation->count,d.chunkCount,HasCorrectionBody{},mStream));
                check(cudaMalloc(&mCorrectionScratch,mCorrectionScratchBytes));
                allocate(mTrialBodies,d.chunkCount);allocate(mBodyPreparation,1);
                check(cudaMemset(mBodyPreparation,0,sizeof(*mBodyPreparation)));
                check(cudaMallocHost(&mHostBodyPreparation,sizeof(*mHostBodyPreparation)));*mHostBodyPreparation={};
                allocate(mBodyRequests,d.chunkCount);allocate(mTrialBodyIndices,d.chunkCount);allocate(mBodyAllocation,1);
                check(cudaMemset(mBodyAllocation,0,sizeof(*mBodyAllocation)));
                allocate(mCompactBodyRequests,d.chunkCount);allocate(mReturnedBodyIndices,d.chunkCount);
                check(cub::DeviceSelect::If(nullptr,mBodyRequestScratchBytes,mBodyRequests,mCompactBodyRequests,
                    &mBodyPreparation->allocationRequests,d.chunkCount,NeedsBody{},mStream));
                check(cudaMalloc(&mBodyRequestScratch,mBodyRequestScratchBytes));
                mEditCapacity=d.chunkCount+d.bondCount;
                allocate(mProvisionalMotion,d.chunkCount);allocate(mTopologyEdits,mEditCapacity);allocate(mTopologyCount,1);
            }
            mParams={};mParams.maxIterations=d.maxIterations;mParams.tolerance=d.tolerance;mParams.warmStart=d.warmStart;
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
            v.trialBodies=mTrialBodies;v.bodyPreparation=mBodyPreparation;
            v.trialBodyIndices=mTrialBodyIndices;v.bodyAllocation=mBodyAllocation;
            v.trialCollisionBindings=mCompactCollisionBindings;v.collisionPreparation=mCollisionPreparation;
            v.correctionBodies=mCompactCorrectionBodies;v.correctionPreparation=mCorrectionPreparation;
            v.acceptedTopology=mTopology->accepted();v.trialTopology=mTopology->trial();v.topologyTransaction=mTopology->status();
            v.acceptedTopology.readyEvent=v.trialTopology.readyEvent=mReady;
        }
        v.chunkCount=mN;v.bondCount=mM;v.readyEvent=reinterpret_cast<CUevent>(mReady);return v;
    }
    void setConsumerEvent(CUevent e) override {if(mWriteAllowed(mScene))mConsumer=e;}
    PxDestructionStageStatus getLastStatus() const override {return *mHostStatus;}
    bool prepareFrame(PxU32 n) override {
        try {Context current(mContext);if(!configured() || mPending)return false;
            if(mConsumer)check(cudaStreamWaitEvent(mStream,reinterpret_cast<cudaEvent_t>(mConsumer),0));
            if(n>mCapacity) {check(cudaStreamSynchronize(mStream));PxGpuContactPair* fresh=nullptr;
                allocate(fresh,n);cudaFree(mPairs);mPairs=fresh;mCapacity=n;}
            check(cudaMemsetAsync(mCount,0,sizeof(*mCount),mStream));
            startFrame<<<1,1,0,mStream>>>(mStatus);
            if(mBodyAllocation)check(cudaMemsetAsync(mBodyAllocation,0,sizeof(*mBodyAllocation),mStream));
            mHostCorrectionPreparation={};mCorrectionBodyCapacity=0;
            if(mCorrectionPreparation)check(cudaMemsetAsync(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation),mStream));
            if(mCollisionPreparation) {
                check(cudaMemsetAsync(mCollisionPreparation,0,sizeof(*mCollisionPreparation),mStream));
                check(cudaMemsetAsync(mAffectedClusters,0,mC*sizeof(PxU32),mStream));
            }
            check(cudaEventRecord(mInput,mStream));return true;
        }catch(...){mFailed=true;return false;}
    }
    PxGpuContactPair* contactPairs() const override {return mPairs;}
    PxU32* contactCount() const override {return mCount;}
    CUevent inputEvent() const override {return reinterpret_cast<CUevent>(mInput);}
    PxTransform* poses() const override {return mPoses;}
    PxVec3* angularVelocities() const override {return mAngular;}
    const PxRigidDynamicGPUIndex* bodyIndices() const override {return mBodies;}
    PxU32 clusterCount() const override {return mC;}
    bool advance(PxReal dt,const PxVec3& gravity,const PxgBodySim* bodyStates) override {
        try {Context current(mContext);if(!configured() || dt<=0)return false;
            check(cudaStreamWaitEvent(mStream,mInput,0));
            prepareLoads<<<(mN+127)/128,128,0,mStream>>>(mChunks,mN,mClusters,mPoses,mAngular,gravity,mInputs,mSurface,mRates);
            if(mCapacity)routeContacts<<<(mCapacity+127)/128,128,0,mStream>>>(mPairs,mCount,mCapacity,mMap,mMapCount,mChunks,mPoses,1.0f/dt,mInputs,mSurface,mStatus,bodyStates,mMaterials,mRates);
            check(cudaEventRecord(mReady,mStream));
            const PxDestructionVectorPair* forces=nullptr;
            const ExtStressGpuDeviceStatus* solveStatus=nullptr;
            if(mSolver) {
                if(!mSolver->solveDeviceAsync(reinterpret_cast<ExtStressGpuImpulse*>(mInputs),mN,mParams,mReady,mConsumer))
                    throw std::runtime_error("resident stress solve submission failed");
                const auto view=mSolver->deviceView();
                check(cudaStreamWaitEvent(mStream,reinterpret_cast<cudaEvent_t>(view.readyEvent),0));
                forces=reinterpret_cast<const PxDestructionVectorPair*>(view.bondImpulses);solveStatus=view.status;
            }
            // Detached chunks still receive contact loads and may crush; a
            // graph without bonds has no stiffness solve to allocate or run.
            finishStatus<<<std::max(1u,(mM+127)/128),128,0,mStream>>>(solveStatus,mStatus,forces,mM);
            if(mCorrectionEnabled)requireNativeConvergence<<<1,1,0,mStream>>>(mStatus);
            if(mMaterials) {
                if(mM)evaluateBondMaterials<<<(mM+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mHealth,forces,mM,
                    dt,mDamageRate,mBendGain,mFibres,mVerdicts,mBondCentroids,mStatus);
                evaluateChunkMaterials<<<(mN+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mNodeBegin,mNodeRefs,
                    mHealth,forces,mBondCentroids,mSurface,mRates,mCrush,mTrialCrush,mN,dt,mStatus);
                if(mM)finalizeMaterialVerdict<<<(mM+127)/128,128,0,mStream>>>(mBonds,mVerdicts,mTrialCrush,mHealth,mM,mStatus);
                requireFractureCorrection<<<1,1,0,mStream>>>(mStatus);
            }
            if(mTopology) {
                check(cudaMemsetAsync(mTopologyCount,0,sizeof(*mTopologyCount),mStream));
                if(mMaterials)emitTopologyEdits<<<(std::max(mM,mN)+127)/128,128,0,mStream>>>(mVerdicts,mM,mTrialCrush,mCrush,mN,mTopologyEdits,mTopologyCount);
                provisionalTopologyMotion<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mChunks,mClusters,mPoses,bodyStates,mProvisionalMotion);
                check(cudaEventRecord(mReady,mStream));
                if(!mTopology->prepare(mTopologyEdits,mTopologyCount,mEditCapacity,&mStatus->error,~8u,mReady,nullptr,mProvisionalMotion))
                    throw std::runtime_error("native topology transaction submission failed");
                check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(mTopology->trial().readyEvent),0));
                inspectTopologyTransaction<<<1,1,0,mStream>>>(mTopology->status(),mStatus);
                beginBodyPreparation<<<1,1,0,mStream>>>(mTopology->status(),mTopology->trial(),mBodyPreparation);
                prepareCandidateBodies<<<(mN+127)/128,128,0,mStream>>>(mTopology->trial(),mChunks,mClusters,mTrialBodies,mBodyPreparation,mTopology->accepted(),mBodyRequests,mTrialBodyIndices);
                finishBodyPreparation<<<1,1,0,mStream>>>(mTopology->status(),mBodyPreparation,mStatus);
                beginUnchangedMotionCommit<<<1,1,0,mStream>>>(mTopology->status(),mStatus,mTopologyAccept);
                checkUnchangedMotionCommit<<<(mN+127)/128,128,0,mStream>>>(mTopology->accepted(),mTopology->trial(),mTopology->status(),mTopologyAccept,mChunks,mAffectedClusters,mCollisionPreparation);
                acceptUnchangedMotionCommit<<<1,1,0,mStream>>>(mTopologyAccept,mStatus);
                check(cudaEventRecord(mReady,mStream));
                if(!mTopology->commit(mTopologyAccept,mReady))throw std::runtime_error("native topology commit submission failed");
                check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(mTopology->accepted().readyEvent),0));
                if(mSolver) {
                    const auto accepted=mTopology->accepted();
                    if(!mSolver->updateDeviceTopologyAsync(accepted.activeBonds,mM,&accepted.status->generation,nullptr,accepted.readyEvent))
                        throw std::runtime_error("native stress topology update submission failed");
                    const auto stress=mSolver->deviceView();
                    check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(stress.readyEvent),0));
                    inspectStressTopology<<<1,1,0,mStream>>>(stress.topologyStatus,mStatus);
                }
                // Membership-changing verdicts remain incomplete until collision
                // rebinding and one internal motion correction are available.
                commitObservedTopologyMotion<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mProvisionalMotion,mStatus);
            }
            if(mMaterials)commitMaterialState<<<(std::max(mM,mN)+127)/128,128,0,mStream>>>(mVerdicts,mHealth,mM,mTrialCrush,mCrush,mN,mStatus);
            check(cudaGetLastError());
            if(mBodyPreparation)check(cudaMemcpyAsync(mHostBodyPreparation,mBodyPreparation,sizeof(*mBodyPreparation),cudaMemcpyDeviceToHost,mStream));
            check(cudaMemcpyAsync(mHostStatus,mStatus,sizeof(*mStatus),cudaMemcpyDeviceToHost,mStream));
            check(cudaEventRecord(mReady,mStream));mPending=true;return true;
        }catch(...){mFailed=true;return false;}
    }
    void reserveBodySlots() {
        mHostReservedIndices.clear();mHostBodyAllocation={};
        if(!mTopology)return;
        auto& allocation=mHostBodyAllocation;
        if(mHostStatus->error==8u && mHostBodyPreparation->valid) {
            const PxU32 count=mHostBodyPreparation->count,requested=mHostBodyPreparation->allocationRequests;
            std::vector<PxvDestructionBodyRequest> requests(requested);mHostReservedIndices.resize(requested);
            auto& indices=mHostReservedIndices;
            if(requested) {
                // Stable device compaction: only NEW cluster allocation records
                // cross to CPU, not unchanged cluster ownership or body states.
                check(cub::DeviceSelect::If(mBodyRequestScratch,mBodyRequestScratchBytes,mBodyRequests,mCompactBodyRequests,
                    &mBodyPreparation->allocationRequests,count,NeedsBody{},mStream));
                check(cudaMemcpyAsync(requests.data(),mCompactBodyRequests,requested*sizeof(*mBodyRequests),cudaMemcpyDeviceToHost,mStream));
                check(cudaStreamSynchronize(mStream));
            }
            allocation.count=count;allocation.generation=mHostBodyPreparation->generation;
            if(mBodyAllocator && mBodyAllocator->prepare(requests.data(),requested,indices.data())) {
                allocation.valid=1;allocation.reserved=requested;
                if(requested) {
                    check(cudaMemcpyAsync(mReturnedBodyIndices,indices.data(),requested*sizeof(PxU32),cudaMemcpyHostToDevice,mStream));
                    bindReservedBodySlots<<<(requested+127)/128,128,0,mStream>>>(mCompactBodyRequests,mReturnedBodyIndices,requested,mTrialBodyIndices);
                    // The local host index vector must outlive its upload.
                    check(cudaStreamSynchronize(mStream));
                }
            } else {allocation.error=1;mHostStatus->error|=256u;mHostReservedIndices.clear();if(mBodyAllocator)mBodyAllocator->discardReservations();}
        } else {if(mBodyAllocator)mBodyAllocator->discardReservations();return;}
        check(cudaMemcpyAsync(mBodyAllocation,&allocation,sizeof(allocation),cudaMemcpyHostToDevice,mStream));
        check(cudaMemcpyAsync(mStatus,mHostStatus,sizeof(*mStatus),cudaMemcpyHostToDevice,mStream));
        check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
    }
    bool captureRigidState(const PxgBodySim* bodies,const PxgBodySimVelocities* previous,
        const PxgRigidBodyAcceleration* accelerations,PxU32 count,CUstream coreStream) override {
        if(!mTopology)return true;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(mFailed || !bodies || !count || !stream || mCheckpointGeneration==std::numeric_limits<PxU64>::max())
                throw std::runtime_error("invalid rigid checkpoint boundary");
            if(mCheckpointValid)check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            mCheckpointValid=false;mRestoredCheckpointGeneration=0;
            if(count>mCheckpointCapacity || bool(previous)!=mCheckpointHasPrevious || bool(accelerations)!=mCheckpointHasAccelerations) {
                // Grow only at the ordered pre-solve boundary. Allocation failure
                // cannot truncate the checkpoint or mutate accepted body state.
                PxgBodySim* freshBodies=nullptr;PxgBodySimVelocities* freshPrevious=nullptr;
                PxgRigidBodyAcceleration* freshAccelerations=nullptr;
                const PxU64 grown=std::max<PxU64>(256,PxU64(mCheckpointCapacity)+mCheckpointCapacity/2);
                const PxU32 capacity=PxU32(std::max<PxU64>(count,std::min<PxU64>(grown,std::numeric_limits<PxU32>::max())));
                try {
                    allocate(freshBodies,capacity);
                    if(previous)allocate(freshPrevious,capacity);
                    if(accelerations)allocate(freshAccelerations,capacity);
                }catch(...) {cudaFree(freshBodies);cudaFree(freshPrevious);cudaFree(freshAccelerations);throw;}
                cudaFree(mCheckpointBodies);cudaFree(mCheckpointPrevious);cudaFree(mCheckpointAccelerations);
                mCheckpointBodies=freshBodies;mCheckpointPrevious=freshPrevious;mCheckpointAccelerations=freshAccelerations;
                mCheckpointCapacity=capacity;
                mCheckpointHasPrevious=previous!=nullptr;mCheckpointHasAccelerations=accelerations!=nullptr;
            }
            check(cudaMemcpyAsync(mCheckpointBodies,bodies,size_t(count)*sizeof(*bodies),cudaMemcpyDeviceToDevice,stream));
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
            check(cudaMemcpyAsync(bodies,mCheckpointBodies,size_t(mCheckpointCount)*sizeof(*bodies),cudaMemcpyDeviceToDevice,stream));
            if(previous)check(cudaMemcpyAsync(previous,mCheckpointPrevious,size_t(mCheckpointCount)*sizeof(*previous),cudaMemcpyDeviceToDevice,stream));
            if(accelerations)check(cudaMemcpyAsync(accelerations,mCheckpointAccelerations,size_t(mCheckpointCount)*sizeof(*accelerations),cudaMemcpyDeviceToDevice,stream));
            check(cudaEventRecord(mCheckpointReady,stream));mRestoredCheckpointGeneration=generation;return true;
        }catch(...) {mCheckpointValid=false;mFailed=true;return false;}
    }
    PxU32 reservedBodyCount() const override {return PxU32(mHostReservedIndices.size());}
    const PxU32* reservedBodyIndices() const override {return mHostReservedIndices.data();}
    bool initializeReservedBodies(PxgBodySim* bodies,PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations,PxU32 capacity,CUstream coreStream) override {
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
            check(cudaMemcpyAsync(&mHostBodyAllocation,mBodyAllocation,sizeof(mHostBodyAllocation),cudaMemcpyDeviceToHost,stream));
            check(cudaMemcpyAsync(mHostStatus,mStatus,sizeof(*mStatus),cudaMemcpyDeviceToHost,stream));
            check(cudaEventRecord(mReady,stream));check(cudaEventSynchronize(mReady));
            return !mHostBodyAllocation.initializationError && mHostBodyAllocation.initialized==count;
        }catch(...) {
            mHostStatus->error|=512u;mHostBodyAllocation.initializationError|=2u;mHostBodyAllocation.initialized=0;
            try {Context current(mContext);
                check(cudaMemcpyAsync(mBodyAllocation,&mHostBodyAllocation,sizeof(mHostBodyAllocation),cudaMemcpyHostToDevice,mStream));
                check(cudaMemcpyAsync(mStatus,mHostStatus,sizeof(*mStatus),cudaMemcpyHostToDevice,mStream));
                check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            }catch(...){mFailed=true;}
            return false;
        }
    }
    bool prepareCollisionBindings(const PxgShapeSim* shapes,PxU32 shapeCapacity,CUstream coreStream) override {
        if(!mTopology || mHostStatus->error!=8u || !mHostBodyAllocation.valid)return true;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(!stream || mHostBodyAllocation.initializationError || mHostBodyAllocation.initialized!=mHostBodyAllocation.reserved)
                throw std::runtime_error("collision preparation requires initialized candidate bodies");
            check(cudaStreamWaitEvent(stream,mReady,0));
            check(cudaMemsetAsync(mCandidateSlots,0xff,mN*sizeof(PxU32),stream));
            indexCandidateRoots<<<std::max(1u,(mHostBodyAllocation.count+127)/128),128,0,stream>>>(mTopology->trial(),mCandidateSlots);
            preparePersistentCollisionBindings<<<(mN+127)/128,128,0,stream>>>(mChunks,mN,mClusters,mAffectedClusters,
                mTopology->trial(),mCandidateSlots,mTrialBodyIndices,shapes,shapeCapacity,mCollisionBindings,mCollisionPreparation);
            check(cudaGetLastError());
            check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mCompactCollisionBindings,
                &mCollisionPreparation->count,mN,HasCollisionBinding{},stream));
            finishCollisionPreparation<<<1,1,0,stream>>>(mCollisionPreparation,mBodyAllocation,mStatus);
            check(cudaGetLastError());
            check(cudaMemcpyAsync(&mHostCollisionPreparation,mCollisionPreparation,sizeof(mHostCollisionPreparation),cudaMemcpyDeviceToHost,stream));
            check(cudaMemcpyAsync(mHostStatus,mStatus,sizeof(*mStatus),cudaMemcpyDeviceToHost,stream));
            check(cudaEventRecord(mReady,stream));check(cudaEventSynchronize(mReady));
            return mHostCollisionPreparation.valid!=0;
        }catch(...) {
            mHostStatus->error|=1024u;mHostCollisionPreparation.valid=0;mHostCollisionPreparation.error|=16u;
            try {Context current(mContext);
                check(cudaMemcpyAsync(mCollisionPreparation,&mHostCollisionPreparation,sizeof(mHostCollisionPreparation),cudaMemcpyHostToDevice,mStream));
                check(cudaMemcpyAsync(mStatus,mHostStatus,sizeof(*mStatus),cudaMemcpyHostToDevice,mStream));
                check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            }catch(...){mFailed=true;}
            return false;
        }
    }
    bool prepareCorrectionBodies(PxU32 bodyCapacity,CUstream coreStream) override {
        if(!mTopology || mHostStatus->error!=8u || !mHostCollisionPreparation.valid)return true;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(!mCheckpointValid || !stream)throw std::runtime_error("missing correction input checkpoint");
            check(cudaStreamWaitEvent(stream,mReady,0));check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            check(cudaMemsetAsync(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation),stream));
            prepareCorrectionBodyInputs<<<(mN+127)/128,128,0,stream>>>(mTrialBodies,mTrialBodyIndices,mN,mTopology->trial(),mChunks,
                mAffectedClusters,mCheckpointBodies,mCheckpointPrevious,mCheckpointCount,bodyCapacity,mCorrectionBodies,mCorrectionPreparation);
            inspectCorrectionSourceLoads<<<(mC+127)/128,128,0,stream>>>(mClusters,mAffectedClusters,mC,mCheckpointBodies,mCheckpointCount,mCorrectionPreparation);
            check(cudaGetLastError());
            check(cub::DeviceSelect::If(mCorrectionScratch,mCorrectionScratchBytes,mCorrectionBodies,mCompactCorrectionBodies,
                &mCorrectionPreparation->count,mN,HasCorrectionBody{},stream));
            finishCorrectionPreparation<<<1,1,0,stream>>>(mCorrectionPreparation,mCollisionPreparation,mCheckpointGeneration,mStatus);
            check(cudaGetLastError());
            check(cudaMemcpyAsync(&mHostCorrectionPreparation,mCorrectionPreparation,sizeof(mHostCorrectionPreparation),cudaMemcpyDeviceToHost,stream));
            check(cudaMemcpyAsync(mHostStatus,mStatus,sizeof(*mStatus),cudaMemcpyDeviceToHost,stream));
            check(cudaEventRecord(mReady,stream));check(cudaEventSynchronize(mReady));mCorrectionBodyCapacity=bodyCapacity;
            return mHostCorrectionPreparation.valid!=0;
        }catch(...) {
            mHostStatus->error|=2048u;mHostCorrectionPreparation.valid=0;mHostCorrectionPreparation.error|=16u;
            try {Context current(mContext);
                check(cudaMemcpyAsync(mCorrectionPreparation,&mHostCorrectionPreparation,sizeof(mHostCorrectionPreparation),cudaMemcpyHostToDevice,mStream));
                check(cudaMemcpyAsync(mStatus,mHostStatus,sizeof(*mStatus),cudaMemcpyHostToDevice,mStream));
                check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            }catch(...){mFailed=true;}
            return false;
        }
    }
    bool installCorrectionBodies(PxgBodySim* bodies,PxgBodySimVelocities* previous,PxgRigidBodyAcceleration* accelerations,
        PxU32 capacity,PxU64 checkpointGeneration,CUstream coreStream) override {
        if(mFailed || !mCheckpointValid || !mHostCorrectionPreparation.valid || mHostCorrectionPreparation.loadedSources
            || mHostStatus->error!=8u || !bodies || !coreStream || capacity<mCorrectionBodyCapacity
            || checkpointGeneration!=mCheckpointGeneration || checkpointGeneration!=mHostCorrectionPreparation.checkpointGeneration
            || mRestoredCheckpointGeneration!=checkpointGeneration
            || bool(previous)!=mCheckpointHasPrevious || bool(accelerations)!=mCheckpointHasAccelerations)return false;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            check(cudaStreamWaitEvent(stream,mReady,0));check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            const PxU32 count=mHostCorrectionPreparation.count;
            if(count)installCorrectionBodyInputs<<<(count+127)/128,128,0,stream>>>(mCompactCorrectionBodies,count,mCheckpointBodies,
                mCheckpointPrevious,bodies,previous,accelerations);
            check(cudaGetLastError());check(cudaEventRecord(mReady,stream));return true;
        }catch(...) {mFailed=true;return false;}
    }
    bool correctionEnabled() const override { return mCorrectionEnabled; }
    PxU32 correctionBodyCount() const override { return PxU32(mHostCorrectionTargets.size()); }
    const PxU32* correctionBodyIndices() const override { return mHostCorrectionTargets.data(); }
    bool applyCorrectionBindings() override {
        if(!mCorrectionEnabled || mFailed || mHostStatus->error!=8u || !mHostCollisionPreparation.valid
            || !mHostCorrectionPreparation.valid || mHostCorrectionPreparation.loadedSources
            || mHostCollisionPreparation.removed || !mBodyAllocator)return false;
        try {
            Context current(mContext);check(cudaEventSynchronize(mReady));
            std::vector<PxDestructionCollisionBinding> bindings(mHostCollisionPreparation.count);
            // CUDA has already selected every retained/new owner whose source
            // changed. Unchanged clusters need neither CPU ownership updates nor
            // a physical-state readback. Full rigid checkpoint replay remains
            // unchanged and still corrects ordinary interaction participants.
            const PxU32 count=mHostCorrectionPreparation.count;
            std::vector<PxvDestructionBodyRequest> requests(count);
            mHostCorrectionTargets.resize(count);
            if(count) gatherCorrectionOwnerMetadata<<<(count+127)/128,128,0,mStream>>>(
                mCompactCorrectionBodies,count,mCandidateSlots,mBodyRequests,mCorrectionOwnerRequests,mCorrectionOwnerTargets);
            check(cudaGetLastError());
            if(!bindings.empty())check(cudaMemcpyAsync(bindings.data(),mCompactCollisionBindings,bindings.size()*sizeof(bindings[0]),cudaMemcpyDeviceToHost,mStream));
            if(count) {
                check(cudaMemcpyAsync(requests.data(),mCorrectionOwnerRequests,count*sizeof(requests[0]),cudaMemcpyDeviceToHost,mStream));
                check(cudaMemcpyAsync(mHostCorrectionTargets.data(),mCorrectionOwnerTargets,count*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
            }
            check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            return mBodyAllocator->applyBindings(bindings.data(),PxU32(bindings.size()),requests.data(),mHostCorrectionTargets.data(),PxU32(requests.size()));
        }catch(...){mFailed=true;return false;}
    }
    bool acceptCorrection(const PxgBodySim* bodies,CUstream coreStream) override {
        if(mFailed || !mCorrectionEnabled || !bodies || !coreStream || mHostStatus->error!=8u)return false;
        try {
            Context current(mContext);
            check(cudaEventRecord(mInput,reinterpret_cast<cudaStream_t>(coreStream)));
            check(cudaStreamWaitEvent(mStream,mInput,0));
            const PxU32 accept=1;check(cudaMemcpyAsync(mTopologyAccept,&accept,sizeof(accept),cudaMemcpyHostToDevice,mStream));
            check(cudaEventRecord(mReady,mStream));
            if(!mTopology->commit(mTopologyAccept,mReady))throw std::runtime_error("corrected topology commit failed");
            check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(mTopology->accepted().readyEvent),0));
            mC=mHostBodyPreparation->count;
            acceptClusterBindings<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mTrialBodyIndices,mClusters,mBodies);
            acceptChunkBindings<<<(mN+127)/128,128,0,mStream>>>(mTopology->accepted(),mCandidateSlots,mChunks);
            observeNativeClusters<<<(mC+127)/128,128,0,mStream>>>(mClusters,mC,bodies,mPoses,mAngular);
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
            check(cudaGetLastError());check(cudaMemcpyAsync(mHostStatus,mStatus,sizeof(*mStatus),cudaMemcpyDeviceToHost,mStream));
            check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            if(mHostStatus->error)return false;
            mBodyAllocator->acceptReservations();return true;
        }catch(...){mFailed=true;return false;}
    }
    bool finish() override {
        try {Context current(mContext);if(mPending){check(cudaEventSynchronize(mReady));mPending=false;reserveBodySlots();}
            if(mFailed)mHostStatus->error|=4u;
            return !mFailed && mHostStatus->error==0;
        }catch(...){mFailed=true;mHostStatus->error|=4u;
            mHostReservedIndices.clear();if(mBodyAllocator)mBodyAllocator->discardReservations();return false;}
    }
};
}}
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT physx::PxgDestructionRuntime*
PxCreateDestructionRuntime(CUcontext c,void* scene,bool(*gate)(void*),physx::PxvDestructionBodyAllocator* allocator) {
    try {return new physx::Runtime(c,scene,gate,allocator);}catch(...){return nullptr;}
}
