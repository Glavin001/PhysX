// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxDestructionScene.h"
#include "PxvDestructionBodyAllocator.h"
#include "PxvIslandMetadata.h"
#include "PxgDestructionMotionStorage.h"
#include "PxgBodySim.h"
#include "PxsRigidBody.h"
#include <cuda_runtime.h>
#include <cooperative_groups.h>
#include <cub/cub.cuh>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <random>
#include <algorithm>
#include <cstring>
namespace physx { namespace {
#include "../src/PxgDestructionMotionState.cuh"
#include "../src/PxgDestructionMotionSlots.cuh"
}}
using namespace physx;
#define CHECK(x) do { if(!(x)){std::fprintf(stderr,"FAIL %s:%d: %s\n",__FILE__,__LINE__,#x);std::exit(1);} } while(0)
#define CUDA(x) do {auto e=(x);if(e!=cudaSuccess){std::fprintf(stderr,"CUDA %s: %s\n",#x,cudaGetErrorString(e));std::exit(1);}}while(0)
template<class T> T* make(unsigned n=1){T* p=nullptr;CUDA(cudaMalloc(&p,sizeof(T)*std::max(n,1u)));return p;}
template<class T> void put(T* p,const T& v){CUDA(cudaMemcpy(p,&v,sizeof(T),cudaMemcpyHostToDevice));}
template<class T> T get(const T* p){T v;CUDA(cudaMemcpy(&v,p,sizeof(T),cudaMemcpyDeviceToHost));return v;}
struct Fixture {
    unsigned size;NativeMotionAllocation graph;
    PxDestructionMotionSlotStatus* pool=make<PxDestructionMotionSlotStatus>();
    PxDestructionBodyPreparationStatus* prep=make<PxDestructionBodyPreparationStatus>();
    PxDestructionBodyAllocationStatus* allocation=make<PxDestructionBodyAllocationStatus>();
    PxDestructionStageStatus* stage=make<PxDestructionStageStatus>();
    PxvDestructionBodyRequest *input,*compact;
    PxU32 *granted,*selected,*owners;
    PxDestructionClusterBodyState* candidates;
    PxgBodySim* bodies;PxgBodySimVelocities* previous;PxgRigidBodyAcceleration* accelerations;
    PxU32 storageCapacity;PxU64 generation=16;
    PxvPreSolveNode* nodes;
    std::vector<PxvDestructionBodyRequest> requests;
    std::vector<PxU32> addresses;
    explicit Fixture(unsigned n):size(n),requests(n),addresses(n+32) {
        input=make<PxvDestructionBodyRequest>(n);compact=make<PxvDestructionBodyRequest>(n);
        granted=make<PxU32>(n+32);selected=make<PxU32>(n);owners=make<PxU32>(n);
        storageCapacity=128+3*(n+32);bodies=make<PxgBodySim>(storageCapacity);
        previous=make<PxgBodySimVelocities>(storageCapacity);accelerations=make<PxgRigidBodyAcceleration>(storageCapacity);
        candidates=make<PxDestructionClusterBodyState>(n);nodes=make<PxvPreSolveNode>(storageCapacity);
        CUDA(graph.initialize({pool,nullptr,prep,input,compact,selected,owners,nullptr,allocation,stage,size,0,candidates},0));
        for(unsigned i=0;i<n+32;++i)addresses[i]=64+3*i;
        CUDA(graph.setStorage({bodies,previous,accelerations,storageCapacity},0));
        CUDA(graph.setNodes(nodes,storageCapacity,0));
        CUDA(cudaMemcpy(granted,addresses.data(),addresses.size()*sizeof(PxU32),cudaMemcpyHostToDevice));
    }
    ~Fixture(){graph.clear();for(void* p:{(void*)pool,(void*)prep,(void*)allocation,(void*)stage,(void*)input,(void*)compact,
        (void*)granted,(void*)selected,(void*)owners,(void*)candidates,(void*)bodies,(void*)previous,(void*)accelerations,(void*)nodes})CUDA(cudaFree(p));}
    void reset(unsigned count,unsigned requested,unsigned committed=0,unsigned stageError=8) {
        put(pool,PxDestructionMotionSlotStatus{0,committed,7,55});
        put(prep,PxDestructionBodyPreparationStatus{++generation,count,1,0,requested});
        PxDestructionStageStatus s{};s.error=stageError;put(stage,s);
        CUDA(cudaMemset(owners,0xff,size*sizeof(PxU32)));
        CUDA(cudaMemset(nodes,0,storageCapacity*sizeof(*nodes)));
        CUDA(cudaMemset(compact,0xcc,size*sizeof(PxvDestructionBodyRequest)));
        CUDA(cudaMemset(selected,0xcc,size*sizeof(PxU32)));
        CUDA(cudaMemcpy(input,requests.data(),size*sizeof(PxvDestructionBodyRequest),cudaMemcpyHostToDevice));
        std::vector<PxDestructionClusterBodyState> states(size);
        for(unsigned i=0;i<size;++i) {
            auto& v=states[i];v.cluster=requests[i].cluster;v.sourceBody=requests[i].sourceBody;v.supported=requests[i].supported;
            v.inverseMass=.25f;v.linearVelocity[0]=float(i)+.5f;v.angularVelocity[2]=-2;
            v.bodyToWorldOrientation[3]=v.bodyToActorOrientation[3]=1;
            v.bodyToWorldPosition[0]=float(i);v.bodyToActorPosition[1]=3;
            v.inverseInertia[0]=1;v.inverseInertia[1]=2;v.inverseInertia[2]=3;
        }
        CUDA(cudaMemcpy(candidates,states.data(),size*sizeof(states[0]),cudaMemcpyHostToDevice));
        CUDA(cudaMemset(bodies,0,storageCapacity*sizeof(*bodies)));
        CUDA(cudaMemset(previous,0x7f,storageCapacity*sizeof(*previous)));
        CUDA(cudaMemset(accelerations,0x7f,storageCapacity*sizeof(*accelerations)));
        PxgBodySim source{};source.dynamicLimitsDamping=make_float4(100,200,.01f,.02f);
        source.body2Actor_maxImpulseW.p.w=500;
        source.externalLinearAcceleration=make_float4(1,2,3,4);
        put(bodies+7,source);
    }
    void run(unsigned capacity) {
        CUDA(graph.setCapacity(granted,capacity,0));CUDA(graph.launch(0));
        CUDA(cudaDeviceSynchronize());
    }
    void unchanged() {
        std::vector<PxU32> result(size);CUDA(cudaMemcpy(result.data(),owners,size*sizeof(PxU32),cudaMemcpyDeviceToHost));
        CHECK(std::all_of(result.begin(),result.end(),[](PxU32 x){return x==(~PxU32(0));}));
    }
    void check(unsigned count,unsigned committed) {
        const auto a=get(allocation);const auto p=get(pool);
        CHECK(a.valid && !a.error && a.count==count && a.generation==generation && p.committed==committed);
        std::vector<PxU32> result(size),chosen(size);std::vector<PxvDestructionBodyRequest> output(size);
        CUDA(cudaMemcpy(result.data(),owners,size*sizeof(PxU32),cudaMemcpyDeviceToHost));
        CUDA(cudaMemcpy(chosen.data(),selected,size*sizeof(PxU32),cudaMemcpyDeviceToHost));
        CUDA(cudaMemcpy(output.data(),compact,size*sizeof(PxvDestructionBodyRequest),cudaMemcpyDeviceToHost));
        std::vector<PxvPreSolveNode> nodeState(storageCapacity);
        CUDA(cudaMemcpy(nodeState.data(),nodes,nodeState.size()*sizeof(*nodes),cudaMemcpyDeviceToHost));
        unsigned selectedCount=0;
        for(unsigned i=0;i<size;++i) {
            if(i<count && requests[i].needsBody) {
                CHECK(result[i]==addresses[committed+selectedCount]);
                CHECK(chosen[selectedCount]==result[i]);
                const auto r=output[selectedCount];CHECK(r.cluster==requests[i].cluster && r.sourceBody==requests[i].sourceBody);
                CHECK(r.supported==requests[i].supported && r.needsBody==1 && r.candidateSlot==i);
                const auto node=nodeState[result[i]];
                CHECK(node.lifetime==1 && node.live==PxU32(!r.supported) && !node.staticTouches);
                ++selectedCount;
            } else CHECK(result[i]==(~PxU32(0)));
        }
        // Independent physical checks on representative allocated slots. Allocation
        // has initialized them without any CPU body object or initialization call.
        for(unsigned i: {0u,count/2,count?count-1:0u})if(i<count && requests[i].needsBody) {
            const auto body=get(bodies+result[i]);const auto prior=get(previous+result[i]);
            CHECK(body.linearVelocityXYZ_inverseMassW.x==float(i)+.5f && body.linearVelocityXYZ_inverseMassW.w==.25f);
            CHECK(body.angularVelocityXYZ_maxPenBiasW.z==-2 && body.body2World.p.x==float(i));
            CHECK(body.body2Actor_maxImpulseW.p.y==3 && body.body2Actor_maxImpulseW.p.w==500);
            CHECK(body.externalLinearAcceleration.x==0 && body.externalLinearAcceleration.y==0);
            CHECK(prior.linearVelocity.x==float(i)+.5f && prior.angularVelocity.z==-2);
        }
        CHECK(a.initialized==selectedCount && !a.initializationError);
        CHECK(selectedCount==a.reserved && p.pending==selectedCount && !p.error && get(stage).error==8);
    }
};
void addressIsolation() {
    Fixture f(444);
    for(unsigned i=0;i<f.size;++i)f.requests[i]={i,7,0,1,i};
    const auto unchangedBodies=[&]() {
        f.unchanged();
        CHECK(!get(f.allocation).valid && !get(f.pool).pending);
        for(unsigned i=0;i<f.size;++i)
            CHECK(get(f.bodies+f.addresses[i]).linearVelocityXYZ_inverseMassW.x==0);
        CHECK(get(f.bodies+7).dynamicLimitsDamping.x==100);
    };
    // An aliased grant must fail before two writers can target the same body.
    f.reset(444,444);put(f.granted+220,f.addresses[0]);f.run(476);
    CHECK(get(f.allocation).error&4);unchangedBodies();
    put(f.granted+220,f.addresses[220]);
    // One request must never overwrite another request's input body. This is
    // a different hazard from targeting its own parent, including unused grants.
    for(unsigned sourceOrdinal:{1u,450u}) {
        f.requests[0].sourceBody=f.addresses[sourceOrdinal];
        f.reset(444,444);f.run(476);
        CHECK(get(f.allocation).error&4);unchangedBodies();
    }
    f.requests[0].sourceBody=7;
    // Poison the immutable grant after registration: selection must resolve
    // against the GPU reverse index, not blindly trust the changed payload.
    f.reset(444,444);CUDA(f.graph.setCapacity(f.granted,476,0));
    put(f.granted+220,PxU32(7));CUDA(f.graph.launch(0));CUDA(cudaDeviceSynchronize());
    CHECK(get(f.allocation).error&4);unchangedBodies();
    put(f.granted+220,f.addresses[220]);
    // A previously committed fragment is a valid parent of a later split.
    f.requests[0].sourceBody=f.addresses[0];f.reset(444,444,1);
    auto parent=get(f.bodies+7);put(f.bodies+f.addresses[0],parent);
    f.run(476);f.check(444,1);
    put(f.nodes+7,PxvPreSolveNode{9,3,1});
    clearNewNativeNodeRange<<<(f.storageCapacity+127)/128,128>>>(f.nodes,0,f.storageCapacity,f.graph.addressView(),f.pool);
    CUDA(cudaDeviceSynchronize());f.check(444,1);
    CHECK(!get(f.nodes+7).live && !get(f.nodes+f.addresses[475]).lifetime);
    std::puts("GPU grant uniqueness, source/target isolation, immutable lookup and committed-parent split: PASS");
}
// A captured launch keeps the descriptor allocation, not a frozen copy of its
// nested pointers. Rebind node storage between replays and require exact owners,
// body values and node births while the descriptor bytes remain read-only during
// each launch. This also runs with the original CUDA/default signature.
void descriptorStability() {
    Fixture f(129);
    const auto* descriptor=f.graph.addressView();
    PxvPreSolveNode* originalNodes=f.nodes;
    for(unsigned pass=0;pass<2;++pass) {
        if(pass) {
            f.nodes=make<PxvPreSolveNode>(f.storageCapacity);
            CHECK(f.nodes!=originalNodes);
            CUDA(f.graph.setNodes(f.nodes,f.storageCapacity,0));
        }
        unsigned needed=0;
        for(unsigned i=0;i<f.size;++i) {
            const unsigned selected=pass?(i%2==0):1u;needed+=selected;
            f.requests[i]={i,7,i%2,selected,i};
        }
        f.reset(f.size,needed);
        CUDA(f.graph.setCapacity(f.granted,f.size+32,0));
        CHECK(f.graph.addressView()==descriptor);
        std::vector<unsigned char> before(sizeof(NativeMotionAddresses)),after(before.size());
        CUDA(cudaMemcpy(before.data(),descriptor,before.size(),cudaMemcpyDeviceToHost));
        CUDA(f.graph.launch(0));CUDA(cudaDeviceSynchronize());
        CUDA(cudaMemcpy(after.data(),descriptor,after.size(),cudaMemcpyDeviceToHost));
        CHECK(before==after);
        f.check(f.size,0);
        if(pass) {
            // The prior allocation is still alive: stale descriptor reads must
            // fail numerically rather than relying on freed-memory behavior.
            std::vector<PxvPreSolveNode> old(f.storageCapacity);
            CUDA(cudaMemcpy(old.data(),originalNodes,old.size()*sizeof(old[0]),cudaMemcpyDeviceToHost));
            for(unsigned i=0;i<f.size;++i)CHECK(old[f.addresses[i]].lifetime==1);
        }
    }
    CUDA(cudaFree(originalNodes));
    std::puts("captured motion descriptor read-only bytes and ordered node-storage rebind: PASS");
}
int main(int argc,char** argv) {
#if defined(PX_CUMETAL) && PX_CUMETAL
    cudaDeviceProp capabilities{};
    CHECK(!nativeMotionCuMetalDeviceSupported(capabilities));
    std::strcpy(capabilities.name,"Apple test device");
    capabilities.warpSize=32;capabilities.maxThreadsPerBlock=128;capabilities.cooperativeLaunch=1;
    CHECK(nativeMotionCuMetalDeviceSupported(capabilities));
    capabilities.warpSize=64;CHECK(!nativeMotionCuMetalDeviceSupported(capabilities));capabilities.warpSize=32;
    capabilities.maxThreadsPerBlock=127;CHECK(!nativeMotionCuMetalDeviceSupported(capabilities));capabilities.maxThreadsPerBlock=128;
    capabilities.cooperativeLaunch=0;CHECK(!nativeMotionCuMetalDeviceSupported(capabilities));capabilities.cooperativeLaunch=1;
    std::strcpy(capabilities.name,"NVIDIA test device");CHECK(!nativeMotionCuMetalDeviceSupported(capabilities));
#endif
    if(argc==2 && std::strcmp(argv[1],"--descriptor-stability")==0){descriptorStability();return 0;}
    if(argc==2 && std::strcmp(argv[1],"--address-isolation")==0){addressIsolation();return 0;}
    descriptorStability();
    addressIsolation();
    std::mt19937 random(1709);
    for(unsigned size:{1u,127u,128u,129u,444u,4099u,113664u}) {
        Fixture f(size);
        for(unsigned pass=0;pass<8;++pass) {
            const unsigned count=pass==7?size:unsigned(random()%(size+1));unsigned needed=0;
            for(unsigned i=0;i<size;++i) {
                const unsigned selected=unsigned(random()%3==0);needed+=i<count?selected:0;
                f.requests[i]={i,7,unsigned(i%2),selected,i};
                // Poison unused capacity: the GPU must not traverse it.
                if(i>=count)f.requests[i]={(~PxU32(0)),(~PxU32(0)),99,99,(~PxU32(0))};
            }
            f.reset(count,needed,11);f.run(size+32);f.check(count,11);
            f.run(size+32);f.check(count,11); // retry a valid pending assignment, without consuming twice
            // Failed acceptance must not consume slots; success consumes once.
            commitNativeMotionSlots<<<1,1>>>(f.pool,f.stage);CUDA(cudaDeviceSynchronize());CHECK(get(f.pool).committed==11);
            auto stage=get(f.stage);stage.error=0;put(f.stage,stage);
            commitNativeMotionSlots<<<1,1>>>(f.pool,f.stage);CUDA(cudaDeviceSynchronize());CHECK(get(f.pool).committed==11+needed);
            commitNativeMotionSlots<<<1,1>>>(f.pool,f.stage);CUDA(cudaDeviceSynchronize());CHECK(get(f.pool).committed==11+needed);
            if(needed) {
                f.reset(count,needed,11);f.run(11+needed-1);f.unchanged();
                CHECK(get(f.allocation).error==1 && !get(f.allocation).valid && get(f.pool).pending==0 && get(f.stage).error==8);
                // Retry identical producer output after capacity growth.
                f.run(size+32);f.check(count,11);
            }
        }
        std::printf("stable device-count compaction, allocation, growth retry, commit: capacity=%u PASS\n",size);
    }
    Fixture f(444);
    for(unsigned i=0;i<f.size;++i)f.requests[i]={i,7,0,1,i};
    f.reset(444,443);f.run(476);f.unchanged();CHECK(get(f.allocation).error&2);
    f.requests[220].candidateSlot=0;f.reset(444,444);f.run(476);f.unchanged();CHECK(get(f.allocation).error&2);
    f.requests[220].candidateSlot=220;f.requests[220].sourceBody=f.addresses[220];
    f.reset(444,444);f.run(476);f.unchanged();CHECK(get(f.allocation).error&4);
    f.requests[220].sourceBody=7;f.reset(445,444);f.run(476);f.unchanged();CHECK(get(f.allocation).error&2);
    f.reset(444,444,0,0);f.run(476);f.unchanged();CHECK(!get(f.pool).pending && !get(f.allocation).reserved);
    f.reset(444,444,0,4096);f.run(476);f.unchanged();CHECK(get(f.stage).error==4096 && !get(f.pool).pending);
    f.reset(444,444,500);f.run(476);f.unchanged();CHECK(get(f.allocation).error==1 && get(f.pool).committed==500);
    f.reset(444,444);
    auto mismatched=get(f.candidates+220);mismatched.cluster=3;put(f.candidates+220,mismatched);
    f.run(476);f.unchanged();CHECK(get(f.allocation).error&16);
    CHECK(get(f.bodies+f.addresses[0]).linearVelocityXYZ_inverseMassW.x==0);
    f.reset(444,444);CUDA(f.graph.setStorage({f.bodies,f.previous,f.accelerations,7},0));
    f.run(476);f.unchanged();CHECK(get(f.allocation).error&16);
    CUDA(f.graph.setStorage({f.bodies,f.previous,f.accelerations,f.storageCapacity},0));
    f.reset(444,444);f.run(476);f.check(444,0);
    finishNativeBodyShadowRegistration<<<1,1>>>(false,f.allocation,f.stage);
    commitNativeMotionSlots<<<1,1>>>(f.pool,f.stage);CUDA(cudaDeviceSynchronize());
    CHECK((get(f.allocation).error&8) && !get(f.allocation).valid && get(f.pool).committed==0);
    f.reset(444,444);
    put(f.nodes+f.addresses[220],PxvPreSolveNode{~PxU64(0),0,0});
    f.run(476);f.unchanged();CHECK(get(f.allocation).error&16);
    CHECK(get(f.nodes+f.addresses[0]).lifetime==0 && get(f.bodies+f.addresses[0]).linearVelocityXYZ_inverseMassW.x==0);
    // Retained owners carry real pre-existing IDs, not just sentinel values.
    for(unsigned i=0;i<f.size;++i)f.requests[i].needsBody=i==3 || i==130;
    f.reset(444,2);std::vector<PxU32> retained(444,7);
    CUDA(cudaMemcpy(f.owners,retained.data(),retained.size()*sizeof(PxU32),cudaMemcpyHostToDevice));
    f.run(476);CUDA(cudaMemcpy(retained.data(),f.owners,retained.size()*sizeof(PxU32),cudaMemcpyDeviceToHost));
    for(unsigned i=0;i<444;++i)CHECK(retained[i]==(i==3?f.addresses[0]:i==130?f.addresses[1]:7));
    std::puts("invalid counts/owners, retained mappings, registration rejection and no partial canonical assignment: PASS");
}
