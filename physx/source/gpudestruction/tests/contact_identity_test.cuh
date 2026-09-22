// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include <cuda_runtime.h>
#include "PxgContactIdentity.cuh"
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <numeric>
#include <set>
#include <stdexcept>
#include <vector>
using namespace physx;
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
void check(cudaError_t r){if(r!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(r));}
template<class T> struct Device {
    T* p{};explicit Device(size_t n){check(cudaMalloc(&p,std::max<size_t>(n,1)*sizeof(T)));}
    ~Device(){cudaFree(p);}
    void put(const std::vector<T>& v){if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get(size_t n){std::vector<T> v(n);if(n)check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
__global__ void initializeContactIdentities(PxgContactGraphIdentity* ids,const PxU32* edges,
    PxU32 count,PxgContactGraphSequence* sequence) {
    contactIdentity::initialize(ids,edges,count,sequence);
}
PxgContactGraphSequence contactLifetimeAllocation() {
    // Non-multiple tails and a deliberately small grid exercise block-stride
    // allocation. Streams share one scene allocator, not counters. The serial
    // CuMetal variant uses event-ordered streams, matching NP's ordered stream.
    constexpr PxU32 n=131073,second=1027;
    const PxgContactGraphIdentity guard={0xfedcba98,17,0x123456789ull};
    std::vector<PxU32> edges(n);std::iota(edges.begin(),edges.end(),31u);
    Device<PxU32> dEdges(n);dEdges.put(edges);
    Device<PxgContactGraphIdentity> a(n+2),b(second+2);
    a.put(std::vector<PxgContactGraphIdentity>(n+2,guard));b.put(std::vector<PxgContactGraphIdentity>(second+2,guard));
    Device<PxgContactGraphSequence> sequence(1);sequence.put({{1,0,0}});
    cudaStream_t left,right;check(cudaStreamCreateWithFlags(&left,cudaStreamNonBlocking));check(cudaStreamCreateWithFlags(&right,cudaStreamNonBlocking));
    cudaEvent_t ready;check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    check(cudaEventRecord(ready));check(cudaStreamWaitEvent(left,ready));check(cudaStreamWaitEvent(right,ready));
#if defined(PX_CUMETAL_SERIAL_CONTACT_IDS)
    constexpr unsigned leftBlocks=1,rightBlocks=1,exhaustedBlocks=1;
#else
    constexpr unsigned leftBlocks=7,rightBlocks=5,exhaustedBlocks=2;
#endif
    initializeContactIdentities<<<leftBlocks,128,0,left>>>(a.p+1,dEdges.p,n,sequence.p);
#if defined(PX_CUMETAL_SERIAL_CONTACT_IDS)
    check(cudaEventRecord(ready,left));check(cudaStreamWaitEvent(right,ready));
#endif
    initializeContactIdentities<<<rightBlocks,128,0,right>>>(b.p+1,dEdges.p,second,sequence.p);
    check(cudaGetLastError());check(cudaDeviceSynchronize());
    auto first=a.get(n+2),other=b.get(second+2);std::set<PxU64> live;
    auto inspect=[&](const std::vector<PxgContactGraphIdentity>& values,PxU32 count) {
        require(!std::memcmp(&values.front(),&guard,sizeof(guard)) && !std::memcmp(&values.back(),&guard,sizeof(guard)),"contact lifetime initialization overwrote guards");
        for(PxU32 i=0;i<count;++i) {
            const auto id=values[i+1];require(id.edgeIndex==edges[i] && !id.reserved,"contact identity lost its edge mapping");
            require(id.generation && live.insert(id.generation).second,"contact lifetime reused across streams/blocks");
        }
    };
    inspect(first,n);inspect(other,second);
    auto status=sequence.get(1)[0];require(!status.error && status.next==1ull+n+second,"contact range allocation leaked or duplicated identities");
    initializeContactIdentities<<<rightBlocks,128>>>(b.p+1,dEdges.p,second,sequence.p);check(cudaGetLastError());check(cudaDeviceSynchronize());
    inspect(b.get(second+2),second); // recycled storage must obtain fresh lifetimes
    require(!std::memcmp(first.data(),a.get(n+2).data(),first.size()*sizeof(first[0])),"unrelated pair initialization changed retained identities");
    // Cross the low-word boundary without losing any high bits or identities.
    const PxU64 rollover=(PxU64(1)<<32)-17;
    sequence.put({{rollover,0,0}});
    initializeContactIdentities<<<1,128>>>(b.p+1,dEdges.p,second,sequence.p);check(cudaDeviceSynchronize());
    const auto rolled=b.get(second+2);std::set<PxU64> rolloverIds;
    for(PxU32 i=1;i<=second;++i)rolloverIds.insert(rolled[i].generation);
    require(rolloverIds.size()==second && *rolloverIds.begin()==rollover && *rolloverIds.rbegin()==rollover+second-1,
        "contact generation lost the low-word carry");
    require(sequence.get(1)[0].next==rollover+second,"contact counter lost the low-word carry");
    // Capture preserves the live allocator, not the generation observed at
    // capture time. Queue three replays before observing completion.
    sequence.put({{rollover,0,0}});
    cudaGraph_t graph;cudaGraphExec_t executable;
    check(cudaStreamBeginCapture(left,cudaStreamCaptureModeGlobal));
    initializeContactIdentities<<<leftBlocks,128,0,left>>>(b.p+1,dEdges.p,second,sequence.p);
    check(cudaStreamEndCapture(left,&graph));check(cudaGraphInstantiate(&executable,graph,nullptr,nullptr,0));
    for(unsigned replay=0;replay<3;++replay)check(cudaGraphLaunch(executable,left));
    check(cudaStreamSynchronize(left));
    const auto replayed=b.get(second+2);std::set<PxU64> replayIds;
    for(PxU32 i=1;i<=second;++i)replayIds.insert(replayed[i].generation);
    require(replayIds.size()==second && *replayIds.begin()==rollover+2*second && *replayIds.rbegin()==rollover+3*second-1,
        "contact graph replay reused or skipped lifetime ranges");
    require(sequence.get(1)[0].next==rollover+3*second,"contact graph replay did not advance the live counter exactly");
    check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
    // An empty initialization cannot reserve, overwrite or clear prior errors.
    sequence.put({{77,2,0}});b.put(std::vector<PxgContactGraphIdentity>(second+2,guard));
    initializeContactIdentities<<<1,128>>>(b.p+1,dEdges.p,0,sequence.p);check(cudaDeviceSynchronize());
    const auto empty=b.get(second+2);const auto emptyStatus=sequence.get(1)[0];
    require(emptyStatus.next==77 && emptyStatus.error==2,"empty initialization changed sequence state");
    for(const auto& id:empty)require(!std::memcmp(&id,&guard,sizeof(guard)),"empty initialization changed identities");
#if defined(PX_CUMETAL_SERIAL_CONTACT_IDS)
    // Misconfigured dimensions must fail before modifying the counter or IDs.
    for(unsigned bad=0;bad<5;++bad) {
        sequence.put({{77,0,0}});b.put(std::vector<PxgContactGraphIdentity>(second+2,guard));
        const dim3 grid=bad==0?dim3(2,1,1):(bad==1?dim3(1,2,1):(bad==2?dim3(1,1,2):dim3(1,1,1)));
        const dim3 block=bad==3?dim3(64,2,1):(bad==4?dim3(64,1,2):dim3(128,1,1));
        initializeContactIdentities<<<grid,block>>>(b.p+1,dEdges.p,second,sequence.p);check(cudaDeviceSynchronize());
        const auto rejected=b.get(second+2);const auto failure=sequence.get(1)[0];
        require(failure.error==4 && failure.next==77,"invalid contact-ID launch did not reject before reservation");
        for(const auto& id:rejected)require(!std::memcmp(&id,&guard,sizeof(guard)),"invalid contact-ID launch changed identities");
    }
#endif
    // Exhaustion must latch, leave the counter unwrapped and publish invalid
    // identities. Existing graph validation rejects generation zero explicitly.
    const PxU64 maximum=~PxU64(0);sequence.put({{maximum-3,0,0}});
    initializeContactIdentities<<<1,128>>>(b.p+1,dEdges.p,3,sequence.p);check(cudaDeviceSynchronize());
    auto last=b.get(5);require(last[1].generation==maximum-3 && last[3].generation==maximum-1,"last legal lifetime range was not allocated exactly");
    initializeContactIdentities<<<1,128>>>(b.p+1,dEdges.p,1,sequence.p);check(cudaDeviceSynchronize());
    status=sequence.get(1)[0];require(status.next==maximum && status.error==1 && b.get(2)[1].generation==0,"contact lifetime exhaustion silently wrapped");
    initializeContactIdentities<<<exhaustedBlocks,128>>>(b.p+1,dEdges.p,129,sequence.p);check(cudaDeviceSynchronize());
    auto failed=b.get(130);for(PxU32 i=1;i<failed.size();++i)require(!failed[i].generation,"exhausted contact allocator resumed");
    check(cudaStreamDestroy(left));check(cudaStreamDestroy(right));check(cudaEventDestroy(ready));
#if defined(PX_CUMETAL_SERIAL_CONTACT_IDS)
    std::puts("GPU contact lifetimes: ordered single-block allocation, tails, retained storage, reuse, graph replay, empty work, 64-bit carry, exhaustion and invalid launches passed");
#else
    std::puts("GPU contact lifetimes: concurrent block allocation, tails, retained storage, reuse, graph replay, empty work, 64-bit carry and exhaustion passed");
#endif
    return sequence.get(1)[0];
}
