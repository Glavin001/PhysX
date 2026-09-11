// Focused producer failure tests, using the same private kernels as the runtime.
#include "PxgDestructionRuntime.h"
#include "PxgBodySim.h"
#include <cuda_runtime.h>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <vector>
namespace physx { namespace {
#include "PxgDestructionInputOwners.cuh"
}}
using namespace physx;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
float bodyBits(PxU32 id){float value;std::memcpy(&value,&id,sizeof(value));return value;}
void require(bool v){if(!v)throw std::runtime_error("input owner regression");}
template<class T> struct Buffer {
    T* p{};size_t n;
    explicit Buffer(size_t count):n(count){check(cudaMalloc(&p,n*sizeof(T)));}
    ~Buffer(){cudaFree(p);}
    void set(std::vector<T> v){require(v.size()==n);check(cudaMemcpy(p,v.data(),n*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get(){std::vector<T> v(n);check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
int main(){try {
    Buffer<PxU32> active(5),roots(5),activeRoots(2),slots(5),slotRoots(2);
    Buffer<PxU64> generations(2);
    Buffer<PxDestructionTopologyStatus> topoStatus(1);
    Buffer<PxDestructionStressChunk> chunks(5);
    Buffer<PxDestructionStressCluster> clusters(2);
    Buffer<PxgBodySim> bodies(3);
    Buffer<PxgDestructionInputOwner> owners(5);
    Buffer<PxgDestructionInputOwnership> status(1);
    active.set({1,1,0,1,1});roots.set({0,0,PX_INVALID_U32,3,3});activeRoots.set({0,3});
    slots.set({0,PX_INVALID_U32,PX_INVALID_U32,1,PX_INVALID_U32});slotRoots.set({0,3});generations.set({7,8});
    PxDestructionTopologyStatus ts{};ts.generation=12;ts.clusterCount=2;topoStatus.set({ts});
    std::vector<PxDestructionStressChunk> cs(5);cs[0].cluster=cs[1].cluster=0;
    cs[2].cluster=PX_INVALID_U32;cs[3].cluster=cs[4].cluster=1;chunks.set(cs);
    std::vector<PxDestructionStressCluster> ms(2);ms[0].body=0;ms[1].body=2;clusters.set(ms);
    std::vector<PxgBodySim> bs(3);for(PxU32 i=0;i<3;++i)bs[i].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w=bodyBits(i);
    bodies.set(bs);
    PxDestructionTopologyDeviceView t{};t.chunkCount=5;t.slotCapacity=2;t.status=topoStatus.p;
    t.activeChunks=active.p;t.chunkCluster=roots.p;t.activeClusters=activeRoots.p;
    t.clusterSlots=slots.p;t.slotRoots=slotRoots.p;t.slotGenerations=generations.p;
    auto run=[&](PxU64 generation=20,PxU32 clusterCount=2) {
        beginInputOwnership<<<1,1>>>(status.p,t,clusterCount,3,generation);
        captureInputOwners<<<1,128>>>(t,chunks.p,clusters.p,clusterCount,bodies.p,owners.p,status.p);
        finishInputOwnership<<<1,1>>>(status.p);check(cudaGetLastError());check(cudaDeviceSynchronize());
        return status.get()[0];
    };
    auto s=run();require(s.valid && !s.error && s.inputGeneration==20 && s.topologyGeneration==12);
    auto o=owners.get();require(o[0].body==0 && o[1].slotGeneration==7 && o[3].body==2 && o[4].slotGeneration==8);
    require(!o[2].active && o[2].body==PX_INVALID_U32 && o[2].root==PX_INVALID_U32 && o[2].slot==PX_INVALID_U32);
    // Retired/reused slot, missing body, broken packed mapping and invalid input
    // generation fail as receipts, without trusting partially written entries.
    slotRoots.set({0,PX_INVALID_U32});s=run();require(!s.valid && (s.error&4));slotRoots.set({0,3});
    ms[1].body=3;clusters.set(ms);s=run();require(!s.valid && (s.error&4));ms[1].body=2;clusters.set(ms);
    bs[2].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w=bodyBits(1);bodies.set(bs);
    s=run();require(!s.valid && (s.error&8));bs[2].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w=bodyBits(2);bodies.set(bs);
    cs[3].cluster=2;chunks.set(cs);s=run();require(!s.valid && (s.error&2));cs[3].cluster=1;chunks.set(cs);
    s=run(0);require(!s.valid && (s.error&1));s=run(21);require(s.valid && !s.error && s.inputGeneration==21);
    // An active mask cannot accidentally turn inactive storage into an owner.
    active.set({1,1,2,1,1});s=run();require(!s.valid && (s.error&2));
    active.set({0,0,0,0,0});ts.clusterCount=0;topoStatus.set({ts});s=run(22,0);require(s.valid);
    for(const auto& owner:owners.get())require(!owner.active && owner.body==PX_INVALID_U32);
    std::puts("input owners: sparse/empty, source identity, slots, mappings, generation and recovery passed");
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
