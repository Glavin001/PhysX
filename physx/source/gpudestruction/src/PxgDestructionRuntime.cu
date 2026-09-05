// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgDestructionRuntime.h"
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <cuda.h>
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
    PxDestructionSurfaceLoad* surfaces) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=n)return;
    surfaces[i]={}; inputs[i]={};
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
__global__ void routeContacts(const PxGpuContactPair* pairs, const PxU32* count,
    PxU32 capacity, const Lookup* map, PxU32 maps, const PxDestructionStressChunk* chunks,
    const PxTransform* poses, float invDt, PxDestructionVectorPair* inputs,
    PxDestructionSurfaceLoad* surface, PxDestructionStageStatus* status) {
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
            atomicAdd(&status->normalContacts,1u);
        }}
    }
    if(p.frictionPatches && p.contactPatches) {
        PxFrictionAnchorStreamIterator it(p.contactPatches,p.frictionPatches,p.nbPatches);
        while(it.hasNextPatch()) { it.nextPatch(); while(it.hasNextFrictionAnchor()) {it.nextFrictionAnchor();
            const auto impulse=it.getImpulse(); if(impulse.isZero())continue;
            contactLoad(a,chunks,poses,it.getPosition(),impulse,invDt,inputs,surface);
            contactLoad(b,chunks,poses,it.getPosition(),-impulse,invDt,inputs,surface);
            atomicAdd(&status->frictionAnchors,1u);
        }}
    }
}
__global__ void finishStatus(const ExtStressGpuDeviceStatus* solve,PxDestructionStageStatus* status,
    const PxDestructionVectorPair* forces, PxU32 count) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!i) { status->iterations=solve->iterations;status->converged=solve->converged; }
    if(i<count && (!forces[i].linear.isFinite() || !forces[i].angular.isFinite())) atomicOr(&status->error,2u);
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
        if(mSolver)mSolver->release();mSolver=nullptr;
        cudaFree(mChunks);mChunks=nullptr;cudaFree(mClusters);mClusters=nullptr;
        cudaFree(mBodies);mBodies=nullptr;cudaFree(mPoses);mPoses=nullptr;cudaFree(mAngular);mAngular=nullptr;
        cudaFree(mMap);mMap=nullptr;cudaFree(mInputs);mInputs=nullptr;cudaFree(mSurface);mSurface=nullptr;
        mN=mM=mC=mMapCount=0;
    }
    bool configureStress(const PxDestructionStressDesc& d) override {
        if(!mWriteAllowed(mScene) || !d.chunks || !d.bonds || !d.clusters
            || !d.chunkCount || !d.bondCount || !d.clusterCount || !d.maxIterations
            || !std::isfinite(d.tolerance) || d.tolerance<=0)return false;
        try {
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
            bonds[i]={};bonds[i].node0=b.chunk0;bonds[i].node1=b.chunk1;
            for(PxU32 k=0;k<3;++k){bonds[i].centroid[k]=b.centroid[k];bonds[i].normal[k]=b.normal[k];}
            bonds[i].area=b.area;bonds[i].health=b.health;bonds[i].colScale=b.complianceScale;
        }
            Context current(mContext);
            // Reconfiguration is an explicit recovery boundary. Drain queued
            // work before releasing buffers even if the last stage failed.
            check(cudaEventSynchronize(mInput));check(cudaStreamSynchronize(mStream));
            if(mConsumer)check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(mConsumer)));
            clear();mPending=false;mFailed=false;
            mSolver=ExtStressGpuSolver::create(nodes.data(),d.chunkCount,bonds.data(),d.bondCount,NULL,0,mContext);
            if(!mSolver || !mSolver->prepareDeviceSolve()){clear();return false;}
            allocate(mChunks,d.chunkCount);allocate(mClusters,d.clusterCount);allocate(mBodies,d.clusterCount);
            allocate(mPoses,d.clusterCount);allocate(mAngular,d.clusterCount);allocate(mMap,map.size());
            allocate(mInputs,d.chunkCount);allocate(mSurface,d.chunkCount);
            check(cudaMemcpy(mChunks,d.chunks,sizeof(*mChunks)*d.chunkCount,cudaMemcpyHostToDevice));
            check(cudaMemcpy(mClusters,d.clusters,sizeof(*mClusters)*d.clusterCount,cudaMemcpyHostToDevice));
            check(cudaMemcpy(mBodies,bodies.data(),sizeof(*mBodies)*d.clusterCount,cudaMemcpyHostToDevice));
            if(!map.empty())check(cudaMemcpy(mMap,map.data(),sizeof(*mMap)*map.size(),cudaMemcpyHostToDevice));
            mN=d.chunkCount;mM=d.bondCount;mC=d.clusterCount;mMapCount=PxU32(map.size());
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
    bool configured() const override {return mSolver && mN && !mFailed;}
    PxDestructionDeviceView getDeviceView() const override {
        PxDestructionDeviceView v;v.nodeAccelerations=mInputs;v.surfaceLoads=mSurface;v.status=mStatus;
        v.bondForces=mSolver?reinterpret_cast<const PxDestructionVectorPair*>(mSolver->deviceView().bondImpulses):nullptr;
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
    bool advance(PxReal dt,const PxVec3& gravity) override {
        try {Context current(mContext);if(!configured() || dt<=0)return false;
            check(cudaStreamWaitEvent(mStream,mInput,0));
            prepareLoads<<<(mN+127)/128,128,0,mStream>>>(mChunks,mN,mClusters,mPoses,mAngular,gravity,mInputs,mSurface);
            if(mCapacity)routeContacts<<<(mCapacity+127)/128,128,0,mStream>>>(mPairs,mCount,mCapacity,mMap,mMapCount,mChunks,mPoses,1.0f/dt,mInputs,mSurface,mStatus);
            check(cudaEventRecord(mReady,mStream));
            if(!mSolver->solveDeviceAsync(reinterpret_cast<ExtStressGpuImpulse*>(mInputs),mN,mParams,mReady,mConsumer))
                throw std::runtime_error("resident stress solve submission failed");
            const auto view=mSolver->deviceView();
            check(cudaStreamWaitEvent(mStream,reinterpret_cast<cudaEvent_t>(view.readyEvent),0));
            finishStatus<<<(mM+127)/128,128,0,mStream>>>(view.status,mStatus,reinterpret_cast<const PxDestructionVectorPair*>(view.bondImpulses),mM);
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
