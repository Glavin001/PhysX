// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgDestructionRuntime.h"
#include "PxgDestructionTopology.h"
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <cuda.h>
#include "PxgBodySim.h"
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
__global__ void commitObservedTopologyMotion(PxDestructionTopologyDeviceView topology,
    const PxDestructionClusterMotion* motion,const PxDestructionStageStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!status->error && i<topology.status->clusterCount)topology.motions[i]=motion[i];
}

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
    PxgDestructionEdit* mTopologyEdits{};PxU32* mTopologyCount{};PxU32 mEditCapacity{};
    bool mPending=false; bool mFailed=false;
public:
    Runtime(CUcontext c,void* scene,bool(*gate)(void*)) : mContext(c),mScene(scene),mWriteAllowed(gate) {
        Context current(c);
        check(cudaStreamCreateWithFlags(&mStream,cudaStreamNonBlocking));
        check(cudaEventCreateWithFlags(&mInput,cudaEventDisableTiming));
        check(cudaEventCreateWithFlags(&mReady,cudaEventDisableTiming));
        allocate(mCount,1); allocate(mStatus,1);
        check(cudaMallocHost(&mHostStatus,sizeof(*mHostStatus)));*mHostStatus={};
        check(cudaMemset(mStatus,0,sizeof(*mStatus)));
        check(cudaEventRecord(mReady,mStream));
    }
    void release() override { delete this; }
    ~Runtime() override {
        Context current(mContext); cudaStreamSynchronize(mStream);clear();
        cudaFree(mCount);cudaFree(mStatus);cudaFree(mPairs);cudaFreeHost(mHostStatus);
        cudaEventDestroy(mInput);cudaEventDestroy(mReady);cudaStreamDestroy(mStream);
    }
    void clear() {
        if(mTopology)mTopology->release();mTopology=nullptr;
        cudaFree(mProvisionalMotion);mProvisionalMotion=nullptr;
        cudaFree(mTopologyEdits);mTopologyEdits=nullptr;cudaFree(mTopologyCount);mTopologyCount=nullptr;mEditCapacity=0;
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
            if(d.clusters[i].body==PX_INVALID_U32 || !d.clusters[i].centerOfMass.isFinite())return false;
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
            clear();mPending=false;mFailed=false;
            if(d.bondCount) {
                mSolver=ExtStressGpuSolver::create(nodes.data(),d.chunkCount,bonds.data(),d.bondCount,NULL,0,mContext);
                if(!mSolver || !mSolver->prepareDeviceSolve()){clear();return false;}
            }
            allocate(mChunks,d.chunkCount);allocate(mClusters,d.clusterCount);allocate(mBodies,d.clusterCount);
            allocate(mPoses,d.clusterCount);allocate(mAngular,d.clusterCount);allocate(mMap,map.size());
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
                if(!mTopology){clear();return false;}
                mEditCapacity=d.chunkCount+d.bondCount;
                allocate(mProvisionalMotion,d.clusterCount);allocate(mTopologyEdits,mEditCapacity);allocate(mTopologyCount,1);
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
        if(mTopology) {
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
            if(mMaterials) {
                if(mM)evaluateBondMaterials<<<(mM+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mHealth,forces,mM,
                    dt,mDamageRate,mBendGain,mFibres,mVerdicts,mBondCentroids,mStatus);
                evaluateChunkMaterials<<<(mN+127)/128,128,0,mStream>>>(mChunks,mBonds,mMaterials,mNodeBegin,mNodeRefs,
                    mHealth,forces,mBondCentroids,mSurface,mRates,mCrush,mTrialCrush,mN,dt,mStatus);
                if(mM)finalizeMaterialVerdict<<<(mM+127)/128,128,0,mStream>>>(mBonds,mVerdicts,mTrialCrush,mM,mStatus);
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
                // Collision rebinding and resimulation will gate topology commit.
                // Until then an incomplete step retains accepted topology/motion.
                commitObservedTopologyMotion<<<(mC+127)/128,128,0,mStream>>>(mTopology->accepted(),mProvisionalMotion,mStatus);
            }
            if(mMaterials)commitMaterialState<<<(std::max(mM,mN)+127)/128,128,0,mStream>>>(mVerdicts,mHealth,mM,mTrialCrush,mCrush,mN,mStatus);
            check(cudaGetLastError());
            check(cudaMemcpyAsync(mHostStatus,mStatus,sizeof(*mStatus),cudaMemcpyDeviceToHost,mStream));
            check(cudaEventRecord(mReady,mStream));mPending=true;return true;
        }catch(...){mFailed=true;return false;}
    }
    bool finish() override {
        try {Context current(mContext);if(mPending){check(cudaEventSynchronize(mReady));mPending=false;}
            if(mFailed)mHostStatus->error|=4u;
            return !mFailed && mHostStatus->error==0;
        }catch(...){mFailed=true;mHostStatus->error|=4u;return false;}
    }
};
}}
extern "C" PX_DESTRUCTION_RUNTIME_EXPORT physx::PxgDestructionRuntime*
PxCreateDestructionRuntime(CUcontext c,void* scene,bool(*gate)(void*)) {
    try {return new physx::Runtime(c,scene,gate);}catch(...){return nullptr;}
}
