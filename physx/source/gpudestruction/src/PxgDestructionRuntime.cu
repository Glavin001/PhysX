#include <cstdlib>
#include <cstdio>
#include <thrust/iterator/counting_iterator.h>
// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgDestructionRuntime.h"
#include "PxgDestructionTopology.h"
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <cooperative_groups.h>
#include <cub/cub.cuh>
#include <cuda.h>
#include "PxgBodySim.h"
#include "PxgDestructionNativeSnapshot.h"
#include "PxgShapeSim.h"
#include "PxgContactManager.h"
#include "PxgDestructionContactGraph.cuh"
#include "PxgSolverIslandMetadata.cuh"
#include "PxgPreSolveIslands.cuh"
#include "PxShape.h"
#include "PxsRigidBody.h"
#include "PxgDestructionBody.cuh"
#include "NvBlastExtStressMaterialFormula.h"
#include <set>
#include <map>
#include <cstring>
#include "common/PxCollection.h"
#include "foundation/PxIO.h"
#include "PxRigidDynamic.h"
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
#include "PxgDestructionSnapshot.cuh"
#include "PxgRigidIterationLimits.cuh"
#include "PxgDestructionInputOwners.cuh"
#include "PxgDestructionCommandInputs.cuh"
#include "PxgDestructionMaterial.cuh"
#include "PxgDestructionCommittedChanges.cuh"
#include "PxgDestructionShapePublication.cuh"
// Rebind compact runtime cluster slots entirely on device after acceptance.
// Island-scoped correction: copy the trial snapshot back over the live state
// for the listed (parked) bodies.
__global__ void markParkedBodies(const unsigned* list,unsigned count,unsigned char* bitmap,unsigned capacity) {
    const unsigned k=blockIdx.x*blockDim.x+threadIdx.x;
    if(k<count && list[k]<capacity)bitmap[list[k]]=1;
}
// Every chunk whose cluster body is parked flags its component root (the
// topology's cluster root, the minimum member chunk, is the stress component id).
__global__ void markParkedRoots(PxDestructionTopologyDeviceView topology,const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    unsigned clusterCount,const unsigned char* bitmap,unsigned bodyCapacity,unsigned* rootFlags,unsigned chunkCount) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=chunkCount || i>=topology.chunkCount || !topology.activeChunks[i])return;
    const unsigned slot=chunks[i].cluster;
    if(slot>=clusterCount)return;
    const unsigned body=clusters[slot].body;
    const unsigned root=topology.chunkCluster[i];
    if(body<bodyCapacity && root<chunkCount && bitmap[body])rootFlags[root]=1u;
}
__global__ void reinstateTrialBodies(PxgBodySim* live,const PxgBodySim* trial,
    PxgBodySimVelocities* previous,const PxgBodySimVelocities* trialPrevious,
    PxgRigidBodyAcceleration* accelerations,const PxgRigidBodyAcceleration* trialAccelerations,
    const unsigned* list,unsigned count,unsigned capacity) {
    const unsigned k=blockIdx.x*blockDim.x+threadIdx.x;
    if(k>=count)return;
    const unsigned i=list[k];
    if(i>=capacity)return;
    live[i]=trial[i];
    if(previous)previous[i]=trialPrevious[i];
    if(accelerations)accelerations[i]=trialAccelerations[i];
}

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
    target.x=__fadd_rn(target.x,value.x);target.y=__fadd_rn(target.y,value.y);target.z=__fadd_rn(target.z,value.z);
}
__global__ void startFrame(PxDestructionStageStatus* status,const PxgContactGraphSequence* sequence,bool postCorrection) {
    const PxU64 frame=status->frame+(postCorrection?0:1); *status={}; status->frame=frame;
    if(sequence && sequence->error)status->error|=8192u;
}
__global__ void mergePostCorrectionStatus(PxDestructionStageStatus* status,PxDestructionStageStatus first) {
    status->postCorrectionBrokenBonds=status->brokenBonds;
    status->normalContacts+=first.normalContacts;status->frictionAnchors+=first.frictionAnchors;
    status->iterations=max(status->iterations,first.iterations);
    status->converged= status->converged && first.converged;
    status->bondCommands+=first.bondCommands;status->brokenBonds+=first.brokenBonds;
    status->crushedChunks+=first.crushedChunks;status->error|=first.error;
    status->correctionPasses=1;status->stressPasses=2;
}
__global__ void prepareNativeCorrectionAcceptance(PxDestructionStageStatus* status,
    const PxgContactGraphSequence* sequence,PxU32* accept) {
    if(sequence && sequence->error)status->error|=8192u;
    *accept=!(status->error & ~8u);
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
    v[0]=__fadd_rn(v[0],r.x*f.x);v[1]=__fadd_rn(v[1],r.y*f.y);v[2]=__fadd_rn(v[2],r.z*f.z);
    v[3]=__fadd_rn(v[3],0.5f*(r.x*f.y+r.y*f.x));
    v[4]=__fadd_rn(v[4],0.5f*(r.x*f.z+r.z*f.x));
    v[5]=__fadd_rn(v[5],0.5f*(r.y*f.z+r.z*f.y));
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
__device__ void routeContactSide(PxgDestructionSolvedContacts contacts, const Lookup* map, PxU32 maps, const PxDestructionStressChunk* chunks,
    const PxTransform* poses, float invDt, PxDestructionVectorPair* inputs,
    PxDestructionSurfaceLoad* surface, PxDestructionStageStatus* status,
    const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates,PxU32 i,PxU32 side) {
    if(i>=contacts.pairCount)return;
    const auto& output=contacts.outputs[i];
    if(!output.nbContacts || !contacts.responseEpoch ||
        output.nativeResponseEpoch!=contacts.responseEpoch)return;
    const auto& input=contacts.inputs[i];
    // Resolve a descriptor in registers; never export/store an adapter payload.
    PxGpuContactPair p{};
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
    const bool count=side==0 || a==PX_INVALID_U32;
    if(p.nbContacts && p.contactPatches && p.contactPoints && p.contactForces) {
        PxContactStreamIterator it(p.contactPatches,p.contactPoints,NULL,p.nbPatches,p.nbContacts);
        PxU32 point=0;
        while(it.hasNextPatch()) { it.nextPatch(); while(it.hasNextContact()) { it.nextContact();
            const PxVec3 impulse=it.getContactNormal()*p.contactForces[point++];
            if(side==0)contactLoad(a,chunks,poses,it.getContactPoint(),impulse,invDt,inputs,surface);
            else contactLoad(b,chunks,poses,it.getContactPoint(),-impulse,invDt,inputs,surface);
            if(count)contactRate(a,b,p,it.getContactPoint(),impulse,bodies,chunks,materials,rates,status);
            if(count)atomicAdd(&status->normalContacts,1u);
        }}
    }
    if(p.frictionPatches && p.contactPatches) {
        PxFrictionAnchorStreamIterator it(p.contactPatches,p.frictionPatches,p.nbPatches);
        while(it.hasNextPatch()) { it.nextPatch(); while(it.hasNextFrictionAnchor()) {it.nextFrictionAnchor();
            const auto impulse=it.getImpulse(); if(impulse.isZero())continue;
            if(side==0)contactLoad(a,chunks,poses,it.getPosition(),impulse,invDt,inputs,surface);
            else contactLoad(b,chunks,poses,it.getPosition(),-impulse,invDt,inputs,surface);
            if(count)contactRate(a,b,p,it.getPosition(),impulse,bodies,chunks,materials,rates,status);
            if(count)atomicAdd(&status->frictionAnchors,1u);
        }}
    }
}

// Stable per-chunk ownership: integer keys contain chunk, pair ordinal and side.
// Sorting removes scheduling-dependent floating-point atomic accumulation.
__global__ void contactRouteKeys(PxgDestructionSolvedContacts contacts,const Lookup* map,
    PxU32 maps,PxU64* keys) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=contacts.pairCount)return;
    keys[2*i]=keys[2*i+1]=~PxU64(0);
    const auto output=contacts.outputs[i];
    if(!output.nbContacts || !contacts.responseEpoch || output.nativeResponseEpoch!=contacts.responseEpoch)return;
    const auto input=contacts.inputs[i];
    const PxU32 a=findChunk(map,maps,input.transformCacheRef0),b=findChunk(map,maps,input.transformCacheRef1);
    if(a!=PX_INVALID_U32)keys[2*i]=(PxU64(a)<<32)|(2*i);
    if(b!=PX_INVALID_U32)keys[2*i+1]=(PxU64(b)<<32)|(2*i+1);
}
__global__ void routeSortedContacts(const PxU64* keys,PxU32 count,
    PxgDestructionSolvedContacts contacts,const Lookup* map,PxU32 maps,const PxDestructionStressChunk* chunks,
    const PxTransform* poses,float invDt,PxDestructionVectorPair* inputs,
    PxDestructionSurfaceLoad* surface,PxDestructionStageStatus* status,
    const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU64 key=keys[i];if(key==~PxU64(0))return;
    const PxU32 chunk=PxU32(key>>32);
    if(i && PxU32(keys[i-1]>>32)==chunk)return;
    for(PxU32 j=i;j<count && PxU32(keys[j]>>32)==chunk;++j) {
        const PxU32 pairSide=PxU32(keys[j]);
        routeContactSide(contacts,map,maps,chunks,poses,invDt,inputs,surface,status,bodies,materials,rates,pairSide/2,pairSide&1);
    }
}
struct StableContactRouting {
    PxU64 *keys=nullptr,*sorted=nullptr;PxU32 capacity=0;
    void* scratch=nullptr;size_t scratchBytes=0;
    void clear(){cudaFree(keys);cudaFree(sorted);cudaFree(scratch);keys=sorted=nullptr;scratch=nullptr;capacity=0;scratchBytes=0;}
    void route(PxgDestructionSolvedContacts contacts,const Lookup* map,PxU32 maps,
        const PxDestructionStressChunk* chunks,const PxTransform* poses,float invDt,
        PxDestructionVectorPair* inputs,PxDestructionSurfaceLoad* surface,PxDestructionStageStatus* status,
        const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates,cudaStream_t stream) {
        if(!contacts.pairCount)return;
        if(PxU64(contacts.pairCount)*2>PxU64(std::numeric_limits<int>::max()))throw std::runtime_error("contact routing capacity overflow");
        const PxU32 n=2*contacts.pairCount;
        if(n>capacity){
            check(cudaFree(keys));keys=nullptr;check(cudaFree(sorted));sorted=nullptr;
            allocate(keys,n);allocate(sorted,n);capacity=n;
        }
        size_t bytes=0;check(cub::DeviceRadixSort::SortKeys(nullptr,bytes,keys,sorted,int(n),0,64,stream));
        if(bytes>scratchBytes){check(cudaFree(scratch));scratch=nullptr;check(cudaMalloc(&scratch,bytes));scratchBytes=bytes;}
        contactRouteKeys<<<(contacts.pairCount+127)/128,128,0,stream>>>(contacts,map,maps,keys);
        check(cub::DeviceRadixSort::SortKeys(scratch,scratchBytes,keys,sorted,int(n),0,64,stream));
        routeSortedContacts<<<(n+127)/128,128,0,stream>>>(sorted,n,contacts,map,maps,chunks,poses,invDt,inputs,surface,status,bodies,materials,rates);
        check(cudaGetLastError());
    }
};
__global__ void finishStatus(const ExtStressGpuDeviceStatus* solve,PxDestructionStageStatus* status,
    const PxDestructionVectorPair* forces, PxU32 count) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!i) { status->stressPasses=1;status->iterations=solve?solve->iterations:0;status->converged=solve?solve->converged:1; }
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
    const PxU32 error=destructionBody::prepare(topology.clusters[root],topology.motions[topology.clusterSlots[root]],body);
    body.cluster=root;body.sourceBody=clusters[chunks[root].cluster].body;bodies[i]=body;
    const PxU32 needsBody=accepted.activeChunks[root] && accepted.chunkCluster[root]==root?0u:1u;
    requests[i]={root,body.sourceBody,body.supported,needsBody,i};
    bodyIndices[i]=needsBody?PX_INVALID_U32:body.sourceBody;
    if(needsBody)atomicAdd(&status->allocationRequests,1u);
    if(error)atomicOr(&status->error,error);
}
__global__ void finishBodyPreparation(const PxDestructionTopologyTransactionStatus* transaction,
    PxDestructionBodyPreparationStatus* status,PxDestructionStageStatus* stage) {
    status->valid=transaction->prepared && !transaction->error && !status->error;
    if(status->error)stage->error|=128u;
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
struct CorrectionCommandInputs {
    const PxU64* loadedGenerations=nullptr;
    const PxgDestructionCommandInputStatus* status=nullptr;
    PxU64 generation=0;
    PxU32 capacity=0;
};
struct NativePreparationInputs {
    CorrectionCommandInputs commands;

    PxgDestructionCollisionStorage collision;
    const PxgBodySim* checkpoint=nullptr;
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
    const PxDestructionStressCluster* clusters,const PxU32* affectedClusters,
    PxDestructionTopologyDeviceView topology,const PxU32* candidateSlots,const PxU32* candidateBodies,
    const PxgShapeSim* shapes,PxU32 shapeCapacity,const PxNodeIndex* shapeToBody,PxU32 remapCapacity,
    PxDestructionCollisionBinding* bindings,
    PxDestructionCollisionPreparationStatus* status,const PxDestructionBodyAllocationStatus* allocation,
    const NativePreparationInputs* inputs=nullptr) {
    if(inputs){shapes=inputs->collision.shapes;shapeCapacity=inputs->collision.shapeCapacity;
        shapeToBody=inputs->collision.shapeToBody;remapCapacity=inputs->collision.remapCapacity;}
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=chunkCount)return;
    bindings[i]={i,PX_INVALID_U32,PX_INVALID_U32,PX_INVALID_U32};
    // Overwrite every compaction sentinel even when initialization was rejected.
    // Candidate state cannot be consumed before the ordered device prerequisite.
    if(!initializedBodyAllocation(allocation))return;
    const auto chunk=chunks[i];if(!affectedClusters[chunk.cluster] || chunk.contactIndex==PX_INVALID_U32)return;
    const PxU32 shapeId=chunk.contactIndex,source=clusters[chunk.cluster].body;
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
    if(topology.activeChunks[i]) {
        const PxU32 root=topology.chunkCluster[i];
        if(root>=chunkCount) {atomicOr(&status->error,4u);return;}
        const PxU32 slot=candidateSlots[root];
        if(slot>=topology.status->clusterCount || topology.activeClusters[slot]!=root)
            {atomicOr(&status->error,4u);return;}
        target=candidateBodies[slot];
        if(target==PX_INVALID_U32) {atomicOr(&status->error,4u);return;}
    } else atomicAdd(&status->removed,1u);
    bindings[i]={i,shapeId,source,target};
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
        if(publicationEpochs) {publicationEpochs[b.chunk]=stage->frame;publicationTargets[b.chunk]=b.targetBody;}
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
#include "PxgDestructionAcceptedProperties.cuh"
#include "PxgDestructionMotionSlots.cuh"
#include "PxgDestructionPreparationGraph.cuh"
class Runtime final : public PxgDestructionRuntime {
    snapshot::Data mSnapshotAsset;
    bool mPreserveContactPairs=false;
    bool mPostCorrection=false;PxDestructionStageStatus mFirstPassStatus{};
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
            if(mProfiler)mProfiler->recordData(elapsed,names[mPostCorrection?1:0][i],mProfileContext);
        }
        mCorrectionTimingMask=0;
    }
    CUcontext mContext; void* mScene; bool(*mWriteAllowed)(void*);
    cudaStream_t mStream{}; cudaEvent_t mInput{},mReady{}; CUevent mConsumer{};
    ExtStressGpuSolver* mSolver{}; ExtStressGpuSolveParams mParams;
    PxDestructionStressChunk* mChunks{}; PxDestructionStressCluster* mClusters{};
    PxTransform* mPoses{}; PxVec3* mAngular{};
    Lookup* mMap{}; PxU32 mMapCount{},mN{},mM{},mC{};
    StableContactRouting mContactRouting;
    bool mOwnInputs=false;
    PxDestructionVectorPair* mInputs{}; PxDestructionSurfaceLoad* mSurface{};
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
    };
    static_assert(offsetof(Completion,propertyCount)==sizeof(PxDestructionStageStatus),"final status readback layout");
    Completion *mCompletion{},*mHostCompletion{};
    PxDestructionStageStatus* mStatus{}; PxDestructionStageStatus* mHostStatus{};
    PxDestructionMaterial* mMaterials{};PxDestructionStressBond* mBonds{};
    float *mHealth{},*mRates{};PxU32 *mNodeBegin{},*mNodeRefs{};
    PxVec3* mBondCentroids{};PxDestructionBondVerdict* mVerdicts{};float* mBondUtilization{};
    PxDestructionCrushState *mCrush{},*mTrialCrush{};
    float mDamageRate=2,mBendGain=3;bool mFibres=true;
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
    PxU32* mGrantedMotionIndices{};PxU64* mGrantedPlaceholders{};
    PxDestructionMotionSlotStatus* mMotionSlots{};
    PxU32 mMotionSlotCapacity{},mCommittedMotionSlots{}; // capacity accounting, not allocation decisions
    NativeMotionAllocation mMotionAllocation;
    NativeCorrectionPreparation mDevicePreparation;
    PxgDestructionCollisionStorage mCollisionStorage{};
    bool mPreparationObserved=false;
    PxgDestructionMotionStorage mMotionStorage{};
    PxgDestructionGrowMotionStorage mGrowMotionStorage{};void* mMotionStorageOwner{};
    CUstream mMotionProducerStream{};
    PxU32* mTrialBodyIndices{};
    PxvDestructionBodyRequest* mCorrectionOwnerRequests{};
    PxU32* mCorrectionOwnerTargets{};
    PxDestructionBodyAllocationStatus* mBodyAllocation{};
    PxDestructionBodyAllocationStatus mHostBodyAllocation{};
    PxDestructionBodyAllocationStatus* mBodyAllocationObservation{};
    cudaEvent_t mMotionAllocationEvents[2]{};bool mMotionTimingPending=false,mMotionTimingRetry=false;
    std::vector<PxU32> mHostReservedIndices;
    bool mCompatibilityPrepared=false;
    PxU32* mAffectedClusters{};PxU32* mCandidateSlots{};
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
    PxgBodySimVelocities* mCheckpointPrevious{};
    PxgRigidBodyAcceleration* mCheckpointAccelerations{};
    PxU32 mCheckpointCapacity{},mCheckpointCount{};
    PxU64 mCheckpointGeneration{};
    bool mCheckpointHasPrevious=false,mCheckpointHasAccelerations=false,mCheckpointValid=false;
    PxgDestructionCheckpointPurpose mCheckpointPurpose=PxgDestructionCheckpointPurpose::BeforeSolve;
    PxgDestructionRigidCheckpointView mInputCheckpoint{};
    PxgDestructionCommandInput* mCommandInputs{};
    PxgDestructionCommandInputStatus* mCommandInputStatus{};
    PxU32 mCommandInputCapacity{},mCommandInputCount{};
    PxU64 mCommandInputGeneration{};
    PxU64* mCommandLoadedGenerations{};PxU32 mCommandLoadedCapacity{};
    PxgDestructionInputOwner* mInputOwners{};
    PxgDestructionInputOwnership* mInputOwnership{};
    // Rotate storage on the corrected-motion refresh. Retaining the original
    // input needs a second reusable allocation, not another full-array copy.
    PxgBodySim* mInputSpareBodies{};
    PxgBodySimVelocities* mInputSparePrevious{};
    PxgRigidBodyAcceleration* mInputSpareAccelerations{};
    PxU32 mInputSpareCapacity{};
    bool mInputSpareHasPrevious=false,mInputSpareHasAccelerations=false;
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
    PxgDestructionContactGraphStatus* mGraphHostStatus{}; // pinned, for the asynchronous observation
    std::vector<PxU32> mGraphHostLast; // host scratch for member chains
    NativeRigidIterationLimits mRigidIterationLimits;
    bool mPending=false; bool mFailed=false;
    bool mCorrectionEnabled=false, mGpuIslandRepair=false;
    PxU32 *mGraphHostAccurate{}, *mGraphHostSpeculative{};
    PxU64 *mGraphKeys{}, *mGraphSortedKeys{}, *mGraphHostAccurateMembers{}, *mGraphHostSpeculativeMembers{};
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
        {
            // Destruction work gates the correction and the second stress pass;
            // give it the highest stream priority so it is not queued behind the
            // ordinary rigid solve when both are pending (env PHYSX_DESTRUCTION_STREAM_PRIORITY=0 disables).
            int lo=0,hi=0;check(cudaDeviceGetStreamPriorityRange(&lo,&hi));
            const char* raw=std::getenv("PHYSX_DESTRUCTION_STREAM_PRIORITY");
            const bool prioritized=!raw || std::string(raw)!="0";
            check(cudaStreamCreateWithPriority(&mStream,cudaStreamNonBlocking,prioritized?hi:0));
        }
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
            // Experiment (PHYSX_DESTRUCTION_PRESOLVE_SEED_SKIP=N, default 0): accept a
            // seed up to N generations older than the strict +1 rule. A pass builds
            // the contact graph twice; when the second build is not a same-pass
            // reuse the generation advances by two and the strict rule falls back
            // to CPU islands. The island audits decide whether skipping is sound.
            static const PxU64 seedSkip=[](){const char* raw=std::getenv("PHYSX_DESTRUCTION_PRESOLVE_SEED_SKIP");return raw?PxU64(std::max(0L,std::atol(raw))):0ull;}();
            bool usable=mPrePreviousCount && mGraphView.generation && mGraphView.nodeCapacity>=mPrePreviousCount
                && mPreSourceGraphGeneration!=~PxU64(0) && mGraphView.generation>=mPreSourceGraphGeneration+1
                && mGraphView.generation<=mPreSourceGraphGeneration+1+seedSkip;
            // Growth preserves both rosters and the previous graph certificate.
            // New handle holes are initialized below before applying deltas.
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
                check(cudaEventSynchronize(mPreReady));
                if(mGraphView.generation)check(cudaEventSynchronize(mGraphReady));
                if(count>mGraphPairCapacity) {
                    const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(count,2ull*mGraphPairCapacity)));
                    check(cudaFree(mGraphRetiredMask));mGraphRetiredMask=nullptr;
                    allocate(mGraphRetiredMask,(size_t(capacity)+31)/32);
                    mGraphPairCapacity=capacity;
                }
                if(nodeCapacity>mGraphNodeCapacity) {
                    // Keep ownership of successful allocations on later failure.
                    const PxU32 capacity=PxU32(std::min<PxU64>(~PxU32(0),std::max<PxU64>(nodeCapacity,2ull*mGraphNodeCapacity)));
                    check(cudaFree(mGraphAccurate));mGraphAccurate=nullptr;allocate(mGraphAccurate,capacity);
                    check(cudaFree(mGraphSpeculative));mGraphSpeculative=nullptr;allocate(mGraphSpeculative,capacity);
                    mGraphNodeCapacity=capacity;
                }
            }
            if(retiredCount) {
                // Upload only existing lifecycle deltas, never body motion or
                // a CPU-computed component graph. Retain pinned staging until
                // the ordered producer has consumed it.
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
                const PxU32 words=PxU32((size_t(retainedSlotCount)+31)/32);
                destructionContactGraph::connectRetainedSlots<<<(words+127)/128,128,0,cudaStream>>>(mGraphRetainedSlots,mGraphRetainedActive,retainedSlotCount,
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
            // Everything below is asynchronous on mStream and joined once. A
            // synchronous cudaMemcpy here would run on the legacy default stream
            // and implicitly join every blocking stream, including the rigid solver.
            check(cudaStreamWaitEvent(mStream,mGraphReady,0));
            const PxU32 n=mGraphView.nodeCapacity;if(!n)return false;
            if(!mGraphHostStatus)check(cudaMallocHost(&mGraphHostStatus,sizeof(PxgDestructionContactGraphStatus)));
            if(n>mGraphObservationCapacity) {
                const PxU32 capacity=mGraphNodeCapacity;
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
            check(cudaMemcpyAsync(mGraphHostStatus,mGraphStatus,sizeof(*mGraphHostStatus),cudaMemcpyDeviceToHost,mStream));
            if(needAccurate)check(cudaMemcpyAsync(mGraphHostAccurate,mGraphAccurate,size_t(n)*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
            if(needSpeculative)check(cudaMemcpyAsync(mGraphHostSpeculative,mGraphSpeculative,size_t(n)*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
            check(cudaStreamSynchronize(mStream));
            const PxgDestructionContactGraphStatus status=*mGraphHostStatus;
            ++mGraphObservationStats.observations;mGraphObservationStats.deviceToHostBytes+=sizeof(status);
            if(status.error || status.omittedPairs)return false;
            // Member chains on the host, in exactly the layout the former sorted
            // (label, node) keys produced: heads[label] = minimum member, then
            // successors by node in ascending order, PX_INVALID_NODE at the end.
            for(PxU32 graph=0;graph<2;++graph) {
                if(graph?!needSpeculative:!needAccurate)continue;
                const PxU32* labels=graph?mGraphHostSpeculative:mGraphHostAccurate;
                PxU32* members=reinterpret_cast<PxU32*>(graph?mGraphHostSpeculativeMembers:mGraphHostAccurateMembers);
                PxU32* heads=members;PxU32* next=members+n;
                mGraphHostLast.resize(n);
                for(PxU32 i=0;i<n;++i){heads[i]=PX_INVALID_NODE;next[i]=PX_INVALID_NODE;mGraphHostLast[i]=PX_INVALID_NODE;}
                for(PxU32 node=0;node<n;++node) {
                    const PxU32 label=labels[node];if(label>=n)continue;
                    if(heads[label]==PX_INVALID_NODE)heads[label]=node;else next[mGraphHostLast[label]]=node;
                    mGraphHostLast[label]=node;
                }
            }
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
        for(auto event:mStageEvents)if(event)cudaEventDestroy(event);
        for(auto event:mMotionAllocationEvents)if(event)cudaEventDestroy(event);
        for(auto event:mCorrectionEvents)if(event)cudaEventDestroy(event);
        mRigidIterationLimits.clear();
        cudaFree(mCompletion);cudaFreeHost(mHostCompletion);
        cudaEventDestroy(mPreReady);cudaEventDestroy(mGraphReady);cudaEventDestroy(mInput);cudaEventDestroy(mReady);cudaEventDestroy(mCheckpointReady);cudaStreamDestroy(mStream);
    }
    void clear() {
        cudaEventSynchronize(mPreReady);cudaEventSynchronize(mReady);
        mContactRouting.clear();
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
        cudaFreeHost(mGraphHostStatus);mGraphHostStatus=nullptr;
        cudaFreeHost(mGraphHostSpeculativeMembers);mGraphHostSpeculativeMembers=nullptr;
        mGraphObservationCapacity=0;mGpuIslandRepair=false;
        mHostCorrectionTargets.clear();mCorrectionEnabled=false;
        cudaFree(mCorrectionOwnerRequests);mCorrectionOwnerRequests=nullptr;
        cudaFree(mCorrectionOwnerTargets);mCorrectionOwnerTargets=nullptr;
        cudaFree(mPropertyEpochs);mPropertyEpochs=nullptr;mPropertyCount=nullptr;mPendingPropertyCapacity=0;
        cudaFree(mShapePublicationEpochs);cudaFree(mShapePublicationTargets);mShapePublicationEpochs=nullptr;mShapePublicationTargets=nullptr;mPendingShapeCapacity=0;
        cudaFree(mCorrectionBodies);mCorrectionBodies=nullptr;cudaFree(mCompactCorrectionBodies);mCompactCorrectionBodies=nullptr;
        mCorrectionPreparation=nullptr;cudaFree(mCorrectionScratch);mCorrectionScratch=nullptr;mCorrectionScratchBytes=0;
        if(mCheckpointValid)cudaEventSynchronize(mCheckpointReady);
        mInputCheckpoint={};
        cudaFree(mCommandInputs);mCommandInputs=nullptr;
        cudaFree(mCommandInputStatus);mCommandInputStatus=nullptr;
        mCommandInputCapacity=mCommandInputCount=0;mCommandInputGeneration=0;
        cudaFree(mCommandLoadedGenerations);mCommandLoadedGenerations=nullptr;mCommandLoadedCapacity=0;
        cudaFree(mInputOwners);mInputOwners=nullptr;cudaFree(mInputOwnership);mInputOwnership=nullptr;
        cudaFree(mInputSpareBodies);mInputSpareBodies=nullptr;
        cudaFree(mInputSparePrevious);mInputSparePrevious=nullptr;
        cudaFree(mInputSpareAccelerations);mInputSpareAccelerations=nullptr;
        mInputSpareCapacity=0;mInputSpareHasPrevious=mInputSpareHasAccelerations=false;
        mCheckpointValid=false;mCheckpointCount=0;mCheckpointCapacity=0;
        mCheckpointHasPrevious=mCheckpointHasAccelerations=false;
        cudaFree(mCheckpointBodies);mCheckpointBodies=nullptr;
        cudaFree(mCheckpointPrevious);mCheckpointPrevious=nullptr;
        cudaFree(mCheckpointAccelerations);mCheckpointAccelerations=nullptr;
        cudaFree(mTrialSnapBodies);cudaFree(mTrialSnapPrevious);cudaFree(mTrialSnapAccelerations);mTrialSnapBodies=nullptr;mTrialSnapPrevious=nullptr;mTrialSnapAccelerations=nullptr;
        mTrialSnapCapacity=mTrialSnapCount=0;mTrialSnapshotValid=false;cudaFree(mReinstateList);mReinstateList=nullptr;mReinstateCapacity=0;
        cudaFree(mParkedBodyBitmap);mParkedBodyBitmap=nullptr;mParkedBodyBitmapCapacity=0;cudaFree(mParkedRootFlags);mParkedRootFlags=nullptr;mParkedRootCapacity=0;mParkedFlagsArmed=false;
        mHostReservedIndices.clear();mCompatibilityPrepared=false;mHostCompletion->collision={};
        cudaFree(mAffectedClusters);mAffectedClusters=nullptr;cudaFree(mCandidateSlots);mCandidateSlots=nullptr;
        cudaFree(mCollisionBindings);mCollisionBindings=nullptr;cudaFree(mCompactCollisionBindings);mCompactCollisionBindings=nullptr;
        cudaFree(mMigratingCollisionBindings);mMigratingCollisionBindings=nullptr;
        cudaFree(mShapeOwnerGenerations);mShapeOwnerGenerations=nullptr;
        mShapeOwnerCapacity=0;mInstalledOwnerGeneration=0;
        mCollisionPreparation=nullptr;cudaFree(mCollisionScratch);mCollisionScratch=nullptr;mCollisionScratchBytes=0;
        if(mBodyAllocator)mBodyAllocator->clear();
        cudaFree(mCompactBodyRequests);mCompactBodyRequests=nullptr;
        cudaFree(mReturnedBodyIndices);mReturnedBodyIndices=nullptr;
        cudaFree(mGrantedMotionIndices);mGrantedMotionIndices=nullptr;cudaFree(mGrantedPlaceholders);mGrantedPlaceholders=nullptr;
        cudaFree(mMotionSlots);mMotionSlots=nullptr;mMotionSlotCapacity=mCommittedMotionSlots=0;
        mDevicePreparation.clear();mMotionAllocation.clear();
        cudaFree(mBodyRequests);mBodyRequests=nullptr;cudaFree(mTrialBodyIndices);mTrialBodyIndices=nullptr;
        mBodyAllocation=nullptr;mHostBodyPreparation=nullptr;
        mBodyAllocationObservation=nullptr;mMotionTimingPending=false;
        mChanges.clear();
        if(mTopology)mTopology->release();mTopology=nullptr;
        cudaFree(mProvisionalMotion);mProvisionalMotion=nullptr;
        cudaFree(mTrialBodies);mTrialBodies=nullptr;mBodyPreparation=nullptr;
        cudaFree(mTopologyEdits);mTopologyEdits=nullptr;cudaFree(mTopologyCount);mTopologyCount=nullptr;mEditCapacity=0;
        cudaFree(mTopologyAccept);mTopologyAccept=nullptr;
        if(mSolver)mSolver->release();mSolver=nullptr;
        cudaFree(mChunks);mChunks=nullptr;cudaFree(mClusters);mClusters=nullptr;
        cudaFree(mPoses);mPoses=nullptr;cudaFree(mAngular);mAngular=nullptr;
        cudaFree(mMap);mMap=nullptr;if(mOwnInputs)cudaFree(mInputs);mInputs=nullptr;mOwnInputs=false;cudaFree(mSurface);mSurface=nullptr;
        cudaFree(mMaterials);mMaterials=nullptr;cudaFree(mBonds);mBonds=nullptr;
        cudaFree(mHealth);mHealth=nullptr;cudaFree(mRates);mRates=nullptr;
        cudaFree(mNodeBegin);mNodeBegin=nullptr;cudaFree(mNodeRefs);mNodeRefs=nullptr;
        cudaFree(mBondCentroids);mBondCentroids=nullptr;cudaFree(mVerdicts);cudaFree(mBondUtilization);mBondUtilization=nullptr;mVerdicts=nullptr;
        cudaFree(mCrush);mCrush=nullptr;cudaFree(mTrialCrush);mTrialCrush=nullptr;
        mN=mM=mC=mMapCount=0;mSnapshotAsset={};
    }
    #include "PxgDestructionSnapshotAPI.inl"
    bool configureStress(const PxDestructionStressDesc& d) override {return configureStressImpl(d,nullptr);}
    bool configureStressImpl(const PxDestructionStressDesc& d,const snapshot::Data* restored) {
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
            nodes[i]={{c.position.x,c.position.y,c.position.z},c.mass,c.inertia};
            if(c.contactIndex!=PX_INVALID_U32)map.push_back({c.contactIndex,i});
        }
        std::sort(map.begin(),map.end(),[](const Lookup&a,const Lookup&b){return a.contact<b.contact;});
        for(size_t i=1;i<map.size();++i)if(map[i-1].contact==map[i].contact)return false;
        for(PxU32 i=0;i<d.bondCount;++i) {
            const auto b=d.bonds[i];
            if(b.chunk0>=d.chunkCount || b.chunk1>=d.chunkCount || b.chunk0==b.chunk1
                || ((!restored || restored->active[i]) && d.chunks[b.chunk0].cluster!=d.chunks[b.chunk1].cluster)
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
            for(PxU32 i=0;i<d.clusterCount;++i)if(!boundBodies.insert(d.clusters[i].body).second)return false;
            topologyBonds.resize(d.bondCount);
            std::vector<PxU32> parent(d.chunkCount),owner(d.chunkCount,PX_INVALID_U32),clusterRoot(d.clusterCount,PX_INVALID_U32);
            for(PxU32 i=0;i<d.chunkCount;++i)parent[i]=i;
            auto root=[&](PxU32 i){while(parent[i]!=i)i=parent[i];return i;};
            for(PxU32 i=0;i<d.bondCount;++i) {
                topologyBonds[i]={d.bonds[i].chunk0,d.bonds[i].chunk1};
                if(!restored || restored->active[i]){const PxU32 a=root(d.bonds[i].chunk0),b=root(d.bonds[i].chunk1);parent[std::max(a,b)]=std::min(a,b);}
            }
            for(PxU32 i=0;i<d.chunkCount;++i) {
                const PxU32 r=root(i),c=d.chunks[i].cluster;const auto& properties=d.chunkMassProperties[i];
                if(restored && restored->labels[i]!=r)return false;
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
            clear();mPending=false;mFailed=false;mCorrectionEnabled=d.internalCorrectionLimit==1;mPreserveContactPairs=d.preserveUnchangedContactPairs;mGpuIslandRepair=d.gpuIslandRepair;
            if(d.bondCount) {
                mSolver=ExtStressGpuSolver::create(nodes.data(),d.chunkCount,bonds.data(),d.bondCount,NULL,0,mContext);
                if(!mSolver || !mSolver->prepareDeviceSolve()){clear();return false;}
            }
            allocate(mChunks,d.chunkCount);allocate(mClusters,std::max(d.chunkCount,d.clusterCount));
            if(d.chunkMassProperties){allocate(mInputOwners,d.chunkCount);allocate(mInputOwnership,1);}
            allocate(mPoses,std::max(d.chunkCount,d.clusterCount));allocate(mAngular,std::max(d.chunkCount,d.clusterCount));allocate(mMap,map.size());
            if(mSolver) mInputs=reinterpret_cast<PxDestructionVectorPair*>(mSolver->deviceView().nodeInputs);
            else {allocate(mInputs,d.chunkCount);mOwnInputs=true;}
            if(!mInputs)throw std::runtime_error("missing resident destruction inputs");
            allocate(mSurface,d.chunkCount);
            check(cudaMemcpy(mChunks,d.chunks,sizeof(*mChunks)*d.chunkCount,cudaMemcpyHostToDevice));
            check(cudaMemcpy(mClusters,d.clusters,sizeof(*mClusters)*d.clusterCount,cudaMemcpyHostToDevice));
            if(!map.empty())check(cudaMemcpy(mMap,map.data(),sizeof(*mMap)*map.size(),cudaMemcpyHostToDevice));
            mN=d.chunkCount;mM=d.bondCount;mC=d.clusterCount;mMapCount=PxU32(map.size());
            if(d.materialCount) {
                allocate(mMaterials,d.materialCount);allocate(mBonds,d.bondCount);allocate(mHealth,d.bondCount);
                allocate(mRates,d.chunkCount);allocate(mNodeBegin,begin.size());allocate(mNodeRefs,refs.size());
                allocate(mBondCentroids,d.bondCount);allocate(mVerdicts,d.bondCount);allocate(mBondUtilization,d.bondCount);
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
                mTopology=PxgDestructionTopologyTransaction::create(d.chunkMassProperties,d.chunkCount,topologyBonds.data(),d.bondCount,restored?restored->active.data():nullptr);
                if(!mTopology || (mSolver && !mSolver->enableDeviceTopology())){clear();return false;}
                allocate(mTopologyAccept,1);
                allocate(mAffectedClusters,d.chunkCount);allocate(mCandidateSlots,d.chunkCount);
                allocate(mCollisionBindings,d.chunkCount);allocate(mCompactCollisionBindings,d.chunkCount);mCollisionPreparation=&mCompletion->collision;
                allocate(mMigratingCollisionBindings,d.chunkCount);
                check(cudaMemset(mCollisionPreparation,0,sizeof(*mCollisionPreparation)));
                check(cub::DeviceSelect::If(nullptr,mCollisionScratchBytes,mCollisionBindings,mCompactCollisionBindings,
                    &mCollisionPreparation->count,d.chunkCount,HasCollisionBinding{},mStream));
                size_t migratingScratchBytes=0;
                check(cub::DeviceSelect::If(nullptr,migratingScratchBytes,mCollisionBindings,mMigratingCollisionBindings,
                    &mCollisionPreparation->migrating,d.chunkCount,HasMigratingCollisionBinding{},mStream));
                mCollisionScratchBytes=std::max(mCollisionScratchBytes,migratingScratchBytes);
                check(cudaMalloc(&mCollisionScratch,mCollisionScratchBytes));
                allocate(mCorrectionOwnerRequests,d.chunkCount);allocate(mCorrectionOwnerTargets,d.chunkCount);
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
                    allocate(mShapePublicationEpochs,d.chunkCount);allocate(mShapePublicationTargets,d.chunkCount);
                    check(cudaMemsetAsync(mShapePublicationEpochs,0,d.chunkCount*sizeof(PxU64),mStream));
                    check(cudaMemsetAsync(mPropertyEpochs,0,d.chunkCount*sizeof(PxU64),mStream));
                    size_t propertyBytes=0;
                    check(cub::DeviceSelect::If(nullptr,propertyBytes,thrust::counting_iterator<PxU32>(0),
                        mCorrectionOwnerTargets,mPropertyCount,d.chunkCount,
                        HasChangedProperties{mTopology->accepted().activeClusters,mPropertyEpochs,mStatus},mStream));
                    mCorrectionScratchBytes=std::max(mCorrectionScratchBytes,propertyBytes);
                    size_t shapeBytes=0;
                    check(cub::DeviceSelect::If(nullptr,shapeBytes,thrust::counting_iterator<PxU32>(0),
                        mCorrectionOwnerTargets,&mCompletion->shapeCount,d.chunkCount,
                        HasPendingShapeOwner{mShapePublicationEpochs,mStatus},mStream));
                    mCorrectionScratchBytes=std::max(mCorrectionScratchBytes,shapeBytes);
                }
                check(cudaMalloc(&mCorrectionScratch,mCorrectionScratchBytes));
                allocate(mTrialBodies,d.chunkCount);mBodyPreparation=&mCompletion->body;
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
                    preparePersistentCollisionBindings<<<(mN+127)/128,128,0,mStream>>>(mChunks,mN,mClusters,mAffectedClusters,
                        trial,mCandidateSlots,mTrialBodyIndices,nullptr,0,nullptr,0,mCollisionBindings,mCollisionPreparation,mBodyAllocation,inputs);
                    check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mCompactCollisionBindings,
                        &mCollisionPreparation->count,mN,HasCollisionBinding{},mStream));
                    check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mMigratingCollisionBindings,
                        &mCollisionPreparation->migrating,mN,HasMigratingCollisionBinding{},mStream));
                    finishCollisionPreparation<<<1,1,0,mStream>>>(mCollisionPreparation,mBodyAllocation,mStatus);
                    check(cudaMemsetAsync(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation),mStream));
                    prepareCorrectionBodyInputs<<<(mN+127)/128,128,0,mStream>>>(mTrialBodies,mTrialBodyIndices,mN,trial,mChunks,
                        mAffectedClusters,nullptr,nullptr,0,0,mCollisionPreparation,mCorrectionBodies,mCorrectionPreparation,inputs);
                    inspectCorrectionSourceLoads<<<(mN+127)/128,128,0,mStream>>>(mClusters,mAffectedClusters,0,nullptr,0,
                        mCollisionPreparation,mCorrectionPreparation,{},inputs);
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
            mParams={};mParams.maxIterations=d.maxIterations;mParams.tolerance=d.tolerance;mParams.warmStart=d.warmStart;
            check(cudaMemset(mStatus,0,sizeof(*mStatus)));*mHostStatus={};
            mSnapshotAsset.authored(d);
            // Pre-created fragment body pool, CPU half: grant the node handles and
            // create their inactive placeholder bodies now, at configuration time,
            // so the first simulated tick only grows GPU motion storage (the CPU
            // creation of thousands of placeholders is setup cost, not tick cost).
            // Snapshot restores reach this point from importState, where the
            // scene-side allocator is not yet ready for grants; they reserve at
            // the first advance instead.
            if(!restored && mBodyAllocator && mTopology && !mInitialPoolReserved) {
                const PxU32 pool=initialBodyPool(mN);
                mBodyAllocator->setPlaceholderPool(pool>0);
                if(pool) {
                    PxProfileScoped setup(mProfiler,"GpuDestruction.setup.reserveBodyPool",false,mProfileContext);
                    const PxU32* granted=nullptr;
                    if(!mBodyAllocator->reserveNodeCapacity(pool,granted))throw std::runtime_error("native body pool reservation failed");
                }
            }
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
    bool wakeCommandOwners(const PxU32* indices,PxU32 count) override {
        if(!mWriteAllowed(mScene) || mFailed || !mBodyAllocator)return false;
        return mBodyAllocator->wakeCommandOwners(indices,count);
    }
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
    void setConsumerEvent(CUevent e) override {if(mWriteAllowed(mScene))mConsumer=e;}
    PxDestructionStageStatus getLastStatus() const override {return *mHostStatus;}
    bool prepareFrame(bool postCorrection=false) override {
        try {Context current(mContext);if(!configured() || mPending)return false;
            mPostCorrection=postCorrection;
            if(postCorrection) {
                if(mHostStatus->error || mHostStatus->correctionPasses!=1 || mHostStatus->stressPasses!=1)return false;
                mFirstPassStatus=*mHostStatus;
            }
            if(!postCorrection){mInstalledOwnerGeneration=0;mPendingPropertyCapacity=0;mPendingShapeCapacity=0;}
            if(mConsumer)check(cudaStreamWaitEvent(mStream,reinterpret_cast<cudaEvent_t>(mConsumer),0));
            startFrame<<<1,1,0,mStream>>>(mStatus,mContactSequence,postCorrection);
            if(mTopology && !postCorrection)mChanges.start(mTopology->accepted(),mStatus,mStream);
            if(mBodyAllocation)check(cudaMemsetAsync(mBodyAllocation,0,sizeof(*mBodyAllocation),mStream));
            mHostCompletion->correction={};mCorrectionBodyCapacity=0;
            mCollisionPreparationSubmitted=mCorrectionPreparationSubmitted=false;mPreparationObserved=false;
            if(mCorrectionPreparation)check(cudaMemsetAsync(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation),mStream));
            if(mCollisionPreparation) {
                check(cudaMemsetAsync(mCollisionPreparation,0,sizeof(*mCollisionPreparation),mStream));
                check(cudaMemsetAsync(mAffectedClusters,0,mC*sizeof(PxU32),mStream));
            }
            check(cudaEventRecord(mInput,mStream));return true;
        }catch(...){mFailed=true;return false;}
    }
    bool finishPostCorrection() override {
        if(!mPostCorrection || mFailed || mPending || mHostStatus->error)return false;
        try {Context current(mContext);
            mergePostCorrectionStatus<<<1,1,0,mStream>>>(mStatus,mFirstPassStatus);
            if(mTopology)mChanges.publish(mStream);
            const PxU32 capacity=std::min(mC,mPendingPropertyCapacity);
            std::vector<PxvDestructionBodyProperties> observations(capacity);PxU32 count=0;
            if(capacity) {
                const auto topology=mTopology->accepted();
                check(cub::DeviceSelect::If(mCorrectionScratch,mCorrectionScratchBytes,
                    thrust::counting_iterator<PxU32>(0),mCorrectionOwnerTargets,mPropertyCount,mC,
                    HasChangedProperties{topology.activeClusters,mPropertyEpochs,mStatus},mStream));
                gatherFinalProperties<<<(capacity+127)/128,128,0,mStream>>>(mCorrectionOwnerTargets,mPropertyCount,
                    capacity,mTrialBodies,mClusters,mMotionStorage.bodies,
                    reinterpret_cast<PxvDestructionBodyProperties*>(mCorrectionBodies),mStatus);
                check(cudaMemcpyAsync(observations.data(),mCorrectionBodies,capacity*sizeof(observations[0]),cudaMemcpyDeviceToHost,mStream));
            }
            const PxU32 shapeCapacity=std::min(mN,mPendingShapeCapacity);
            std::vector<PxDestructionCollisionBinding> shapeObservations(shapeCapacity);
            if(shapeCapacity) {
                // Reuse private preparation scratch. The compact trial batch
                // remains exposed by getDeviceView with its original count.
                check(cub::DeviceSelect::If(mCorrectionScratch,mCorrectionScratchBytes,
                    thrust::counting_iterator<PxU32>(0),mCorrectionOwnerTargets,&mCompletion->shapeCount,mN,
                    HasPendingShapeOwner{mShapePublicationEpochs,mStatus},mStream));
                gatherFinalShapeOwners<<<(shapeCapacity+127)/128,128,0,mStream>>>(mCorrectionOwnerTargets,
                    &mCompletion->shapeCount,shapeCapacity,mChunks,mShapePublicationTargets,mCollisionBindings,mStatus);
                check(cudaMemcpyAsync(shapeObservations.data(),mCollisionBindings,
                    shapeCapacity*sizeof(shapeObservations[0]),cudaMemcpyDeviceToHost,mStream));
            }
            check(cudaGetLastError());
            // Selected count shares the mandatory completion transfer. No
            // count-read/wait/resubmit boundary is needed to size the payload.
            check(cudaMemcpyAsync(mHostCompletion,mCompletion,sizeof(*mStatus)+((capacity||shapeCapacity)?2*sizeof(PxU32):0),cudaMemcpyDeviceToHost,mStream));
            check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            count=capacity?mHostCompletion->propertyCount:0;
            if(mHostStatus->error || count>capacity)return false;
            if(count && !mBodyAllocator->publishCorrectionProperties(observations.data(),count))return false;
            const PxU32 shapeCount=shapeCapacity?mHostCompletion->shapeCount:0;
            if(shapeCount>shapeCapacity || (shapeCount && !mBodyAllocator->publishShapeOwners(shapeObservations.data(),shapeCount)))return false;
            mPendingPropertyCapacity=0;mPendingShapeCapacity=0;mPostCorrection=false;return true;
        }catch(...){mFailed=true;return false;}
    }
    CUevent inputEvent() const override {return reinterpret_cast<CUevent>(mInput);}
    bool advance(PxReal dt,const PxVec3& gravity,const PxgDestructionMotionStorage& storage,CUstream producerStream,
        PxgDestructionGrowMotionStorage growStorage,void* storageOwner,const PxgDestructionSolvedContacts& contacts,const PxgDestructionCollisionStorage& collision) override {
        const auto* bodyStates=storage.bodies;
        try {Context current(mContext);
            mCollisionStorage=collision;mMotionStorage=storage;mGrowMotionStorage=growStorage;mMotionStorageOwner=storageOwner;mMotionProducerStream=producerStream;if(!configured() || dt<=0 || !bodyStates || !producerStream)return false;
            if(!mInitialPoolReserved && mTopology && mBodyAllocator) {
                mInitialPoolReserved=true;
                const PxU32 pool=initialBodyPool(mN);
                mBodyAllocator->setPlaceholderPool(pool>0);
                if(pool>mMotionSlotCapacity){PxProfileScoped setup(mProfiler,"GpuDestruction.setup.reserveBodyPool",false,mProfileContext);growMotionSlots(pool);}
                bodyStates=mMotionStorage.bodies; // growth may have moved the body storage
            }
            // Join borrowed NP streams and the native body's last writer before
            // reading either. Recording the existing input event on the body
            // producer preserves the previous API-gather ordering without
            // those kernels or a CPU completion wait.
            check(cudaStreamWaitEvent(producerStream,mInput,0));
            check(cudaEventRecord(mInput,producerStream));
            check(cudaStreamWaitEvent(mStream,mInput,0));
            if(mTopology) {
                // The first-advance pool reservation above may have grown the
                // motion storage; the caller's view predates that growth.
                check(mMotionAllocation.setStorage(mMotionStorage,mStream));
                check(mMotionAllocation.setNodes(mPreNodes,mPreRegistryCapacity,mStream));
                prepareDeviceInputs();
            }
            stageMarker(0);
            observeNativeClusters<<<(mC+127)/128,128,0,mStream>>>(mClusters,mC,bodyStates,mPoses,mAngular);
            prepareLoads<<<(mN+127)/128,128,0,mStream>>>(mChunks,mN,mClusters,mPoses,mAngular,gravity,mInputs,mSurface,mRates);
            mContactRouting.route(contacts,mMap,mMapCount,mChunks,mPoses,1.0f/dt,mInputs,mSurface,mStatus,bodyStates,mMaterials,mRates,mStream);
            check(cudaEventRecord(mReady,mStream));
            stageMarker(1);
            const PxDestructionVectorPair* forces=nullptr;
            const ExtStressGpuDeviceStatus* solveStatus=nullptr;
            if(mSolver) {
                // Island-scoped correction: the solve after a reinstatement is the
                // corrected pass; parked components republish their trial result.
                mSolver->setParkedComponentFlags(mParkedFlagsArmed?mParkedRootFlags:nullptr);
                mParkedFlagsArmed=false;
                if(!mSolver->solveDeviceAsync(reinterpret_cast<ExtStressGpuImpulse*>(mInputs),mN,mParams,mReady,mConsumer))
                    throw std::runtime_error("resident stress solve submission failed");
                const auto view=mSolver->deviceView();
                check(cudaStreamWaitEvent(mStream,reinterpret_cast<cudaEvent_t>(view.readyEvent),0));
                forces=reinterpret_cast<const PxDestructionVectorPair*>(view.bondImpulses);solveStatus=view.status;
            }
            stageMarker(2);
            // Detached chunks still receive contact loads and may crush; a
            // graph without bonds has no stiffness solve to allocate or run.
            finishStatus<<<std::max(1u,(mM+127)/128),128,0,mStream>>>(solveStatus,mStatus,forces,mM);
            if(mCorrectionEnabled)requireNativeConvergence<<<1,1,0,mStream>>>(mStatus);
            if(mMaterials) {
                if(mM)evaluateBondMaterials<<<(mM+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mHealth,forces,mM,
                    dt,mDamageRate,mBendGain,mFibres,mVerdicts,mBondCentroids,mStatus,mBondUtilization);
                evaluateChunkMaterials<<<(mN+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mNodeBegin,mNodeRefs,
                    mHealth,forces,mBondCentroids,mSurface,mRates,mCrush,mTrialCrush,mN,dt,mStatus);
                if(mM)finalizeMaterialVerdict<<<(mM+127)/128,128,0,mStream>>>(mBonds,mVerdicts,mTrialCrush,mHealth,mM,mStatus);
                requireFractureCorrection<<<1,1,0,mStream>>>(mStatus);
            }
            stageMarker(3);
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
                stageMarker(4);
                beginUnchangedMotionCommit<<<1,1,0,mStream>>>(mTopology->status(),mStatus,mTopologyAccept);
                checkUnchangedMotionCommit<<<(mN+127)/128,128,0,mStream>>>(mTopology->accepted(),mTopology->trial(),mTopology->status(),mTopologyAccept,mChunks,mAffectedClusters,mCollisionPreparation);
                acceptUnchangedMotionCommit<<<1,1,0,mStream>>>(mTopologyAccept,mStatus);
                mChanges.commit(mTopology->accepted(),mTopology->trial(),mTopology->status(),mTopologyAccept,mChunks,mAffectedClusters,mStream);
                check(cudaEventRecord(mReady,mStream));
                if(!mTopology->commit(mTopologyAccept,mReady))throw std::runtime_error("native topology commit submission failed");
                check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(mTopology->accepted().readyEvent),0));
                if(mSolver) {
                    const auto accepted=mTopology->accepted();
                    if(!mSolver->updateDeviceTopologyAsync(accepted.activeBonds,mM,&accepted.status->generation,nullptr,accepted.readyEvent,nullptr,mBondUtilization))
                        throw std::runtime_error("native stress topology update submission failed");
                    const auto stress=mSolver->deviceView();
                    check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(stress.readyEvent),0));
                    inspectStressTopology<<<1,1,0,mStream>>>(stress.topologyStatus,mStatus);
                }
                // Membership-changing verdicts remain incomplete until collision
                // rebinding and one internal motion correction are available.
                commitObservedTopologyMotion<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mProvisionalMotion,mStatus);
            }
            if(!mTopology)stageMarker(4);
            if(mMaterials)commitMaterialState<<<(std::max(mM,mN)+127)/128,128,0,mStream>>>(mVerdicts,mHealth,mM,mTrialCrush,mCrush,mN,mStatus);
            stageMarker(5);
            if(mTopology && !mPostCorrection)mChanges.publish(mStream);
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
    CorrectionCommandInputs correctionCommandInputs() const {
        if(!mCorrectionEnabled)return {};
        // Original command history remains authoritative across corrected refresh.
        if(!mCommandInputStatus || !mInputCheckpoint.generation || mCommandInputGeneration!=mInputCheckpoint.generation)
            throw std::runtime_error("missing original correction command history");
        return {mCommandLoadedGenerations,mCommandInputStatus,mCommandInputGeneration,mCommandLoadedCapacity};
    }
    void extendCorrectionCommandHistory(cudaStream_t stream) {
        // Corrected physics can introduce native body IDs beyond the original
        // command epoch's allocation. Those new slots had no original commands.
        // Preserve every old stamp; zero only the newly addressable suffix.
        if(!mCheckpointValid || mCheckpointCount<=mCommandLoadedCapacity)return;
        const PxU32 capacity=PxU32(std::max<PxU64>(mCheckpointCount,
            std::min<PxU64>(PX_INVALID_U32,std::max<PxU64>(256,PxU64(mCommandLoadedCapacity)*3/2))));
        PxU64* next=nullptr;allocate(next,capacity);
        try {
            if(mCommandLoadedCapacity)check(cudaMemcpyAsync(next,mCommandLoadedGenerations,
                size_t(mCommandLoadedCapacity)*sizeof(PxU64),cudaMemcpyDeviceToDevice,stream));
            check(cudaMemsetAsync(next+mCommandLoadedCapacity,0,
                size_t(capacity-mCommandLoadedCapacity)*sizeof(PxU64),stream));
        }catch(...){cudaFree(next);throw;}
        check(cudaFree(mCommandLoadedGenerations));mCommandLoadedGenerations=next;mCommandLoadedCapacity=capacity;
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
        extendCorrectionCommandHistory(mStream);
        NativePreparationInputs inputs{};inputs.collision=mCollisionStorage;inputs.commands=correctionCommandInputs();
        inputs.checkpoint=mCheckpointValid?mCheckpointBodies:nullptr;inputs.previous=mCheckpointPrevious;
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
    // Grant native motion/body capacity: island node handles (with their CPU
    // placeholder bodies when the pool is enabled), raw PhysX motion storage and
    // the device address list the GPU allocator consumes sequentially.
    void growMotionSlots(PxU32 capacity) {
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
        // Pooled placeholders: the GPU birth rule needs to know which granted
        // nodes already carry a CPU body (see assignNativeMotionOwners).
        std::vector<PxU64> placeholderLifetimes(capacity,0ull);PxU32 placeholderCount=0;
        for(PxU32 i=0;i<capacity;++i){placeholderLifetimes[i]=mBodyAllocator->placeholderLifetime(granted[i]);if(placeholderLifetimes[i])++placeholderCount;}
        PxU64* nextFlags=nullptr;
        if(placeholderCount) {
            allocate(nextFlags,capacity);
            try {check(cudaMemcpyAsync(nextFlags,placeholderLifetimes.data(),size_t(capacity)*sizeof(PxU64),cudaMemcpyHostToDevice,mStream));}
            catch(...){cudaFree(nextFlags);cudaFree(next);throw;}
        }
        check(cudaFree(mGrantedMotionIndices));mGrantedMotionIndices=next;mMotionSlotCapacity=capacity;
        check(cudaFree(mGrantedPlaceholders));mGrantedPlaceholders=nextFlags;
        check(mMotionAllocation.setResources(mGrantedMotionIndices,mMotionSlotCapacity,mMotionStorage,mStream,mGrantedPlaceholders));
    }
    static PxU32 initialBodyPool(PxU32 chunkCount) {
        // Opt-in (2026-09-15 measurement: neutral on every plan metric once the
        // direct stress solve is in place, so it stays off by default).
        // PHYSX_DESTRUCTION_BODY_POOL=N reserves N native bodies with CPU
        // placeholders at configuration; "auto" uses one body per eight chunks
        // clamped to [256, 16384]; unset or 0 disables the pool.
        const char* raw=std::getenv("PHYSX_DESTRUCTION_BODY_POOL");
        if(!raw)return 0u;
        if(std::string(raw)=="auto")return PxU32(std::min<PxU64>(16384,std::max<PxU64>(256,PxU64(chunkCount)/8)));
        return PxU32(std::max(0L,std::atol(raw)));
    }
    bool mInitialPoolReserved=false;
    void reserveBodySlots() {
        PxProfileScoped profile(mProfiler,"GpuDestruction.finishDetail.reserveBodies",false,mProfileContext);
        mHostReservedIndices.clear();mCompatibilityPrepared=false;
        if(!mTopology)return;
        mHostBodyAllocation=*mBodyAllocationObservation;
        if(std::getenv("PHYSX_DESTRUCTION_ALLOC_DIAG"))
            std::fprintf(stderr,"native allocation diag: valid=%u error=%u initializationError=%u count=%u reserved=%u initialized=%u stage=%u slots=%u\n",
                unsigned(mHostBodyAllocation.valid),unsigned(mHostBodyAllocation.error),unsigned(mHostBodyAllocation.initializationError),
                unsigned(mHostBodyAllocation.count),unsigned(mHostBodyAllocation.reserved),unsigned(mHostBodyAllocation.initialized),unsigned(mHostStatus->error),unsigned(mMotionSlotCapacity));
        auto& allocation=mHostBodyAllocation;
        if(mHostStatus->error!=8u || !mHostBodyPreparation->valid) {
            if(mBodyAllocator)mBodyAllocator->discardReservations();return;
        }
        const PxU32 count=mHostBodyPreparation->count,requested=mHostBodyPreparation->allocationRequests;
        if(PxU64(mCommittedMotionSlots)+requested>PX_INVALID_U32)throw std::runtime_error("native motion index capacity overflow");
        const PxU32 needed=mCommittedMotionSlots+requested;
        if(allocation.error==1u && needed>mMotionSlotCapacity) {
            PxProfileScoped growth(mProfiler,"GpuDestruction.finishDetail.growMotionSlots",false,mProfileContext);
            const PxU32 capacity=PxU32(std::min<PxU64>(PX_INVALID_U32,
                std::max<PxU64>(needed,std::max<PxU64>(256,PxU64(mMotionSlotCapacity)+mMotionSlotCapacity/2))));
            growMotionSlots(capacity);
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
        std::vector<PxvDestructionBodyRequest> requests(requested);mHostReservedIndices.resize(requested);
        auto& indices=mHostReservedIndices;
        {
            PxProfileScoped requestProfile(mProfiler,"GpuDestruction.compatibility.requestReadback",false,mProfileContext);
            if(requested) {
                // CPU compatibility construction consumes the allocation decision.
                // The resulting indices already exist in the native GPU mapping.
                check(cudaMemcpyAsync(requests.data(),mCompactBodyRequests,requested*sizeof(*mBodyRequests),cudaMemcpyDeviceToHost,mStream));
                check(cudaMemcpyAsync(indices.data(),mReturnedBodyIndices,requested*sizeof(PxU32),cudaMemcpyDeviceToHost,mStream));
                check(cudaStreamSynchronize(mStream));
            }
        }
        bool allocated=false;
        {
            PxProfileScoped records(mProfiler,"GpuDestruction.compatibility.allocateNativeBodies",false,mProfileContext);
            allocated=mBodyAllocator && mBodyAllocator->prepare(requests.data(),requested,indices.data());
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
        mCompatibilityPrepared=allocated;return allocated;
    }
    bool captureCommandInputs(const PxgBodySim* bodies,PxU32 bodyCount,const PxgBodySimVelocityUpdate* updates,
        PxU32 count,CUstream coreStream) override {
        if(!mTopology || !mCorrectionEnabled || mFailed || !coreStream || (count && (!bodies || !updates || !bodyCount)) ||
            mCheckpointGeneration==std::numeric_limits<PxU64>::max())return false;
        try {
            Context current(mContext);auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(mCheckpointValid)check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            // Consumers of prior history are ordered by the runtime completion.
            check(cudaStreamWaitEvent(stream,mReady,0));
            if(count>mCommandInputCapacity) {
                PxgDestructionCommandInput* fresh=nullptr;
                const PxU32 capacity=PxU32(std::max<PxU64>(count,std::max<PxU64>(256,
                    std::min<PxU64>(PxU64(mCommandInputCapacity)*3/2,std::numeric_limits<PxU32>::max()))));
                allocate(fresh,capacity);cudaFree(mCommandInputs);mCommandInputs=fresh;mCommandInputCapacity=capacity;
            }
            if(bodyCount>mCommandLoadedCapacity) {
                PxU64* fresh=nullptr;
                const PxU32 capacity=PxU32(std::max<PxU64>(bodyCount,std::max<PxU64>(256,
                    std::min<PxU64>(PxU64(mCommandLoadedCapacity)*3/2,std::numeric_limits<PxU32>::max()))));
                allocate(fresh,capacity);
                try {check(cudaMemsetAsync(fresh,0,size_t(capacity)*sizeof(PxU64),stream));}
                catch(...) {cudaFree(fresh);throw;}
                cudaFree(mCommandLoadedGenerations);mCommandLoadedGenerations=fresh;mCommandLoadedCapacity=capacity;
            }
            if(!mCommandInputStatus)allocate(mCommandInputStatus,1);
            const auto generation=mCheckpointGeneration+1;
            beginCommandInputs<<<1,1,0,stream>>>(mCommandInputStatus,generation,count);
            if(count)captureCommandInputsKernel<<<(count+127)/128,128,0,stream>>>(bodies,bodyCount,updates,count,mCommandInputs,mCommandInputStatus,mCommandLoadedGenerations);
            check(cudaGetLastError());mCommandInputCount=count;mCommandInputGeneration=generation;return true;
        }catch(...){mFailed=true;mCommandInputGeneration=0;return false;}
    }
    PxgDestructionCommandInputView commandInputHistory() const override {
        PxgDestructionCommandInputView view;
        if(!mFailed && mInputCheckpoint.generation && mCommandInputGeneration==mInputCheckpoint.generation) {
            view.records=mCommandInputs;view.status=mCommandInputStatus;view.count=mCommandInputCount;
            view.generation=mCommandInputGeneration;view.ready=mInputCheckpoint.ready;
        }
        return view;
    }
    bool captureRigidState(const PxgBodySim* bodies,const PxgBodySimVelocities* previous,
        const PxgRigidBodyAcceleration* accelerations,PxU32 count,CUstream coreStream,
        PxgDestructionCheckpointPurpose purpose) override {
        if(purpose!=PxgDestructionCheckpointPurpose::BeforeSolve && purpose!=PxgDestructionCheckpointPurpose::CorrectedMotion)return false;
        if(!mTopology)return purpose==PxgDestructionCheckpointPurpose::BeforeSolve;
        if(purpose==PxgDestructionCheckpointPurpose::CorrectedMotion &&
            (!mCheckpointValid || mCheckpointPurpose!=PxgDestructionCheckpointPurpose::BeforeSolve ||
             mInputCheckpoint.bodies!=mCheckpointBodies || !mInputCheckpoint.generation))return false;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(mFailed || !bodies || !count || !stream || mCheckpointGeneration==std::numeric_limits<PxU64>::max())
                throw std::runtime_error("invalid rigid checkpoint boundary");
            if(mCheckpointValid)check(cudaStreamWaitEvent(stream,mCheckpointReady,0));
            mCheckpointValid=false;mRestoredCheckpointGeneration=0;
            if(purpose==PxgDestructionCheckpointPurpose::BeforeSolve)mInputCheckpoint={};
            else {
                std::swap(mCheckpointBodies,mInputSpareBodies);
                std::swap(mCheckpointPrevious,mInputSparePrevious);
                std::swap(mCheckpointAccelerations,mInputSpareAccelerations);
                std::swap(mCheckpointCapacity,mInputSpareCapacity);
                std::swap(mCheckpointHasPrevious,mInputSpareHasPrevious);
                std::swap(mCheckpointHasAccelerations,mInputSpareHasAccelerations);
            }
            if(count>mCheckpointCapacity || bool(previous)!=mCheckpointHasPrevious || bool(accelerations)!=mCheckpointHasAccelerations) {
                // Grow only at an ordered checkpoint boundary. Allocation failure
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
            if(purpose==PxgDestructionCheckpointPurpose::BeforeSolve) {
                // The accepted authored mapping still belongs to this input
                // generation. Freeze it before either material verdict can split
                // clusters or recycle native slots. Correction retains this map.
                check(cudaStreamWaitEvent(stream,mReady,0));
                beginInputOwnership<<<1,1,0,stream>>>(mInputOwnership,mTopology->accepted(),mC,count,mCheckpointGeneration+1);
                captureInputOwners<<<(mN+127)/128,128,0,stream>>>(mTopology->accepted(),mChunks,mClusters,mC,
                    mCheckpointBodies,mInputOwners,mInputOwnership);
                finishInputOwnership<<<1,1,0,stream>>>(mInputOwnership);
                check(cudaGetLastError());
            }
            check(cudaEventRecord(mCheckpointReady,stream));
            mCheckpointCount=count;++mCheckpointGeneration;mCheckpointPurpose=purpose;mCheckpointValid=true;
            if(purpose==PxgDestructionCheckpointPurpose::BeforeSolve) {
                mInputCheckpoint=rigidCheckpoint();mInputCheckpoint.owners=mInputOwners;mInputCheckpoint.ownership=mInputOwnership;
            }
            return true;
        }catch(...) {mCheckpointValid=false;mFailed=true;return false;}
    }
    PxgDestructionRigidCheckpointView rigidCheckpoint() const override {
        PxgDestructionRigidCheckpointView result;
        if(mCheckpointValid) {
            result.bodies=mCheckpointBodies;result.previous=mCheckpointPrevious;result.accelerations=mCheckpointAccelerations;
            result.count=mCheckpointCount;result.generation=mCheckpointGeneration;result.ready=mCheckpointReady;
            result.purpose=mCheckpointPurpose;
        }
        return result;
    }
    PxgDestructionRigidCheckpointView inputRigidCheckpoint() const override {
        return mFailed?PxgDestructionRigidCheckpointView{}:mInputCheckpoint;
    }
    // Island-scoped correction: trial end-of-tick snapshot and the reinstatement list.
    PxgBodySim* mTrialSnapBodies=nullptr;PxgBodySimVelocities* mTrialSnapPrevious=nullptr;PxgRigidBodyAcceleration* mTrialSnapAccelerations=nullptr;
    PxU32 mTrialSnapCapacity=0,mTrialSnapCount=0;bool mTrialSnapshotRequested=false,mTrialSnapshotValid=false;
    unsigned* mReinstateList=nullptr;PxU32 mReinstateCapacity=0;
    unsigned char* mParkedBodyBitmap=nullptr;PxU32 mParkedBodyBitmapCapacity=0;
    unsigned* mParkedRootFlags=nullptr;PxU32 mParkedRootCapacity=0;bool mParkedFlagsArmed=false;
    void requestTrialSnapshot(bool enabled) override {mTrialSnapshotRequested=enabled;}
    bool reinstateTrialState(const PxU32* bodies,PxU32 count,PxgBodySim* live,PxgBodySimVelocities* previous,
        PxgRigidBodyAcceleration* accelerations,CUstream coreStream,bool reinstateBodies,bool skipStressComponents) override {
        if(!count)return true;
        if((reinstateBodies && !mTrialSnapshotValid) || !live || !coreStream)return false;
        try {
            Context current(mContext);const auto stream=reinterpret_cast<cudaStream_t>(coreStream);
            if(count>mReinstateCapacity){if(mReinstateList)check(cudaFree(mReinstateList));mReinstateList=nullptr;
                check(cudaMalloc(reinterpret_cast<void**>(&mReinstateList),sizeof(unsigned)*size_t(count)));mReinstateCapacity=count;}
            check(cudaMemcpyAsync(mReinstateList,bodies,sizeof(unsigned)*size_t(count),cudaMemcpyHostToDevice,stream));
            if(reinstateBodies)reinstateTrialBodies<<<(count+255u)/256u,256,0,stream>>>(live,mTrialSnapBodies,previous?previous:nullptr,mTrialSnapPrevious,
                accelerations?accelerations:nullptr,mTrialSnapAccelerations,mReinstateList,count,mTrialSnapCount);
            check(cudaGetLastError());
            const PxU32 bodyCapacity=mTrialSnapshotValid?mTrialSnapCount:mCheckpointCount;
            // Stress components of the parked bodies keep their trial result in the
            // corrected solve: body bitmap -> per-cluster-root flags (consumed once).
            if(skipStressComponents && mTopology && mChunks && mClusters && mN && bodyCapacity) {
                if(bodyCapacity>mParkedBodyBitmapCapacity){cudaFree(mParkedBodyBitmap);mParkedBodyBitmap=nullptr;
                    check(cudaMalloc(reinterpret_cast<void**>(&mParkedBodyBitmap),size_t(bodyCapacity)));mParkedBodyBitmapCapacity=bodyCapacity;}
                if(mN>mParkedRootCapacity){cudaFree(mParkedRootFlags);mParkedRootFlags=nullptr;
                    check(cudaMalloc(reinterpret_cast<void**>(&mParkedRootFlags),sizeof(unsigned)*size_t(mN)));mParkedRootCapacity=mN;}
                check(cudaMemsetAsync(mParkedBodyBitmap,0,size_t(bodyCapacity),stream));
                check(cudaMemsetAsync(mParkedRootFlags,0,sizeof(unsigned)*size_t(mN),stream));
                markParkedBodies<<<(count+255u)/256u,256,0,stream>>>(mReinstateList,count,mParkedBodyBitmap,bodyCapacity);
                markParkedRoots<<<(mN+255u)/256u,256,0,stream>>>(mTopology->trial(),mChunks,mClusters,mC,mParkedBodyBitmap,bodyCapacity,mParkedRootFlags,mN);
                check(cudaGetLastError());
                mParkedFlagsArmed=true;
            }
            check(cudaStreamSynchronize(stream)); // the host list is reused by the caller
            return true;
        }catch(...){return false;}
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
            mTrialSnapshotValid=false;
            if(mTrialSnapshotRequested) {
                // Island-scoped correction: keep the live (trial end-of-tick) state so
                // parked bodies can be reinstated once the affected set is known.
                if(mTrialSnapCapacity<mCheckpointCount) {
                    cudaFree(mTrialSnapBodies);cudaFree(mTrialSnapPrevious);cudaFree(mTrialSnapAccelerations);mTrialSnapBodies=nullptr;mTrialSnapPrevious=nullptr;mTrialSnapAccelerations=nullptr;
                    check(cudaMalloc(reinterpret_cast<void**>(&mTrialSnapBodies),sizeof(*bodies)*size_t(mCheckpointCount)));
                    check(cudaMalloc(reinterpret_cast<void**>(&mTrialSnapPrevious),sizeof(*previous)*size_t(mCheckpointCount)));
                    check(cudaMalloc(reinterpret_cast<void**>(&mTrialSnapAccelerations),sizeof(*accelerations)*size_t(mCheckpointCount)));
                    mTrialSnapCapacity=mCheckpointCount;
                }
                check(cudaMemcpyAsync(mTrialSnapBodies,bodies,size_t(mCheckpointCount)*sizeof(*bodies),cudaMemcpyDeviceToDevice,stream));
                if(previous)check(cudaMemcpyAsync(mTrialSnapPrevious,previous,size_t(mCheckpointCount)*sizeof(*previous),cudaMemcpyDeviceToDevice,stream));
                if(accelerations)check(cudaMemcpyAsync(mTrialSnapAccelerations,accelerations,size_t(mCheckpointCount)*sizeof(*accelerations),cudaMemcpyDeviceToDevice,stream));
                mTrialSnapCount=mCheckpointCount;mTrialSnapshotValid=true;
            }
            check(cudaMemcpyAsync(bodies,mCheckpointBodies,size_t(mCheckpointCount)*sizeof(*bodies),cudaMemcpyDeviceToDevice,stream));
            if(previous)check(cudaMemcpyAsync(previous,mCheckpointPrevious,size_t(mCheckpointCount)*sizeof(*previous),cudaMemcpyDeviceToDevice,stream));
            if(accelerations)check(cudaMemcpyAsync(accelerations,mCheckpointAccelerations,size_t(mCheckpointCount)*sizeof(*accelerations),cudaMemcpyDeviceToDevice,stream));
            correctionMarker(1,stream);
            check(cudaEventRecord(mCheckpointReady,stream));mRestoredCheckpointGeneration=generation;return true;
        }catch(...) {mCheckpointValid=false;mFailed=true;return false;}
    }
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
            preparePersistentCollisionBindings<<<(mN+127)/128,128,0,stream>>>(mChunks,mN,mClusters,mAffectedClusters,
                mTopology->trial(),mCandidateSlots,mTrialBodyIndices,shapes,shapeCapacity,shapeToBody,remapCapacity,mCollisionBindings,mCollisionPreparation,mBodyAllocation);
            check(cudaGetLastError());
            check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mCompactCollisionBindings,
                &mCollisionPreparation->count,mN,HasCollisionBinding{},stream));
            // Stable compaction keeps authored order at the CPU observation boundary.
            // The full GPU binding list still updates retained shapes, including
            // bounds, COM and contact-cache validity; only migrations rebuild pairs.
            check(cub::DeviceSelect::If(mCollisionScratch,mCollisionScratchBytes,mCollisionBindings,mMigratingCollisionBindings,
                &mCollisionPreparation->migrating,mN,HasMigratingCollisionBinding{},stream));
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
            extendCorrectionCommandHistory(stream);
            check(cudaMemsetAsync(mCorrectionPreparation,0,sizeof(*mCorrectionPreparation),stream));
            prepareCorrectionBodyInputs<<<(mN+127)/128,128,0,stream>>>(mTrialBodies,mTrialBodyIndices,mN,mTopology->trial(),mChunks,
                mAffectedClusters,mCheckpointBodies,mCheckpointPrevious,mCheckpointCount,bodyCapacity,mCollisionPreparation,mCorrectionBodies,mCorrectionPreparation);
            inspectCorrectionSourceLoads<<<(mC+127)/128,128,0,stream>>>(mClusters,mAffectedClusters,mC,mCheckpointBodies,mCheckpointCount,mCollisionPreparation,mCorrectionPreparation,correctionCommandInputs());
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
                mCheckpointPrevious,bodies,previous,accelerations);
            correctionMarker(3,stream);
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
    PxU32 correctionBodyCount() const override { return PxU32(mHostCorrectionTargets.size()); }
    const PxU32* correctionBodyIndices() const override { return mHostCorrectionTargets.data(); }
    bool applyCorrectionBindings() override {
        if(!mCorrectionEnabled || mFailed || mHostStatus->error!=8u || !mHostCompletion->collision.valid
            || !mHostCompletion->correction.valid || mHostCompletion->correction.loadedSources
            || mHostCompletion->collision.removed || !mBodyAllocator)return false;
        try {
            Context current(mContext);check(cudaEventSynchronize(mReady));
            std::vector<PxDestructionCollisionBinding> bindings(mHostCompletion->collision.migrating);
            // CUDA has already selected every retained/new owner whose source
            // changed. Unchanged clusters need neither CPU ownership updates nor
            // a physical-state readback. Full rigid checkpoint replay remains
            // unchanged and still corrects ordinary interaction participants.
            const PxU32 count=mHostCompletion->correction.count;
            std::vector<PxvDestructionBodyRequest> requests(count);
            mHostCorrectionTargets.resize(count);
            if(count) gatherCorrectionOwnerMetadata<<<(count+127)/128,128,0,mStream>>>(
                mCompactCorrectionBodies,count,mCandidateSlots,mBodyRequests,mCorrectionOwnerRequests,mCorrectionOwnerTargets);
            check(cudaGetLastError());
            if(!bindings.empty())check(cudaMemcpyAsync(bindings.data(),mMigratingCollisionBindings,bindings.size()*sizeof(bindings[0]),cudaMemcpyDeviceToHost,mStream));
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
                if(!mSolver->updateDeviceTopologyAsync(accepted.activeBonds,mM,&accepted.status->generation,nullptr,mReady,nullptr,mBondUtilization))
                    throw std::runtime_error("corrected stress topology update failed");
                const auto stress=mSolver->deviceView();check(cudaStreamWaitEvent(mStream,static_cast<cudaEvent_t>(stress.readyEvent),0));
                inspectStressTopology<<<1,1,0,mStream>>>(stress.topologyStatus,mStatus);
            }
            commitNativeMotionSlots<<<1,1,0,mStream>>>(mMotionSlots,mStatus);
            // A bound for final observation storage only, not a physical work
            // budget. CUDA selects the union of changed surviving owners once.
            if(mPropertyEpochs)mPendingPropertyCapacity=PxU32(std::min<PxU64>(mN,
                PxU64(mPendingPropertyCapacity)+mHostCompletion->correction.count));
            if(mShapePublicationEpochs)mPendingShapeCapacity=PxU32(std::min<PxU64>(mN,
                PxU64(mPendingShapeCapacity)+mHostCompletion->collision.migrating));
            check(cudaGetLastError());check(cudaMemcpyAsync(mHostStatus,mStatus,sizeof(*mStatus),cudaMemcpyDeviceToHost,mStream));
            check(cudaEventRecord(mReady,mStream));check(cudaEventSynchronize(mReady));
            collectCorrectionTimings();
            if(mHostStatus->error)return false;
            mCommittedMotionSlots+=mHostBodyAllocation.reserved;
            mBodyAllocator->acceptReservations();return true;
        }catch(...){mFailed=true;return false;}
    }
    bool finish() override {
        try {Context current(mContext);if(mPending){
                {PxProfileScoped waitProfile(mProfiler,"GpuDestruction.finishDetail.waitForGpu",false,mProfileContext);
                    check(cudaEventSynchronize(mReady));}
                collectStageTimings();collectMotionAllocationTiming();mPending=false;reserveBodySlots();mPreparationObserved=true;}
            if(mFailed)mHostStatus->error|=4u;
            return !mFailed && mHostStatus->error==0;
        }catch(...){mFailed=true;mHostStatus->error|=4u;
            mHostReservedIndices.clear();if(mBodyAllocator)mBodyAllocator->discardReservations();return false;}
    }
};
}}
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT physx::PxgDestructionRuntime*
PxCreateDestructionRuntimeV20(CUcontext c,void* scene,bool(*gate)(void*),physx::PxvDestructionBodyAllocator* allocator) {
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
