// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgDestructionElasticGraph.cuh"
#include "PxgDestructionElasticPartition.cuh"

namespace physx { namespace destructionElasticLoadJoin {
namespace E=Nv::Blast::Elastic;
namespace G=destructionElasticGraph;
namespace M=destructionElasticPartition;
namespace L=destructionElasticLoads;
struct State {
    L::Interval interval;
    E::SetupKey graph;
    uint32_t inputError,error,ready,reserved;
};
static_assert(sizeof(State)==sizeof(L::Interval)+sizeof(E::SetupKey)+16,"join receipt layout");
struct Source {
    const M::State* partition;
    M::Storage storage;
    L::Inputs loads;
    const L::Receipt* receipts;
    const E::Vector* effective; // compact, about loads.referencePositions
    const G::State* graph;
    PxDestructionTopologyDeviceView topology;
};
__global__ void begin(E::Graph graph,Source in,L::Interval expected,const uint32_t* priorError,State* state) {
    const auto& p=*in.partition;const auto& g=*in.graph;
    uint32_t error=*priorError || !g.ready || g.error || p.status!=M::Status::Ready || p.error ||
        !M::same(p.storage,in.storage) || p.sourceNodes!=graph.nodes || p.groups.nodes>graph.nodes ||
        p.groups.count>p.groups.nodes || p.identity.scene!=g.key.identity || p.identity.geometry!=g.key.geometry ||
        p.topology!=g.key.topology || p.topology!=in.topology.status->generation ||
        in.topology.status->invalidEdit || in.topology.status->slotError ||
        expected.stamp.ownershipGeneration!=g.key.topology || !expected.stamp.tick || !expected.stamp.inputGeneration ||
        expected.stamp.complete!=1 || expected.stamp.evaluation>1 || !isfinite(expected.seconds) || expected.seconds<=0 ||
        !L::same(in.loads.produced->stamp,expected.stamp) || in.loads.produced->seconds!=expected.seconds ||
        in.loads.referencePositions!=in.storage.positions || in.loads.chunks!=in.storage.chunks ||
        in.loads.mass!=in.storage.mass || graph.activeBonds!=in.topology.activeBonds ? E::InvalidGraph : 0;
    *state={expected,g.key,error,error,0,0};
}
__global__ void mapLoads(E::Graph graph,Source in,E::Vector* authored,State* state) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=graph.nodes)return;
    authored[i]={};
    if(state->inputError)return;
    const auto& p=*in.partition;const auto& s=in.storage;
    const auto j=s.authorToFine[i];
    if(!in.topology.activeChunks[i]) {
        if(j!=M::Invalid || !graph.prescribed[i])atomicOr(&state->error,uint32_t(E::InvalidGraph));
        return;
    }
    if(j>=p.groups.nodes || s.fineToAuthor[j]!=i) {atomicOr(&state->error,uint32_t(E::InvalidGraph));return;}
    const auto a=graph.positions[i],b=in.loads.referencePositions[j];
    const auto group=in.loads.chunks[j].cluster;
    if(a.x!=b.x || a.y!=b.y || a.z!=b.z || group>=p.groups.count ||
       graph.prescribed[i]!=in.loads.mass[j].supported) {atomicOr(&state->error,uint32_t(E::InvalidGraph));return;}
    const auto& receipt=in.receipts[group];
    if(receipt.status!=L::Status::Ready || !L::same(receipt.interval.stamp,state->interval.stamp) ||
       receipt.interval.seconds!=state->interval.seconds) {atomicOr(&state->error,uint32_t(E::InvalidValue));return;}
    const auto value=in.effective[j];
    for(auto v:value.v)if(!isfinite(v)){atomicOr(&state->error,uint32_t(E::InvalidValue));return;}
    authored[i]=value;
}
__global__ void motionClosure(E::Graph graph,Source in,State* state) {
    const auto id=blockIdx.x*blockDim.x+threadIdx.x;
    if(id>=graph.bonds || state->inputError || !E::live(graph,id))return;
    const auto& e=graph.interfaces[id];const auto& s=in.storage;const auto count=in.partition->groups.nodes;
    const auto a=s.authorToFine[e.first],b=s.authorToFine[e.second];
    if(a>=count || b>=count || s.chunks[a].cluster!=s.chunks[b].cluster)
        atomicOr(&state->error,uint32_t(E::InvalidGraph));
}
__global__ void finish(State* state) {state->ready=!state->error;}
// Order after native graph/motion/load preparation on the same stream. Source
// arrays stay immutable through fine solve/recovery; caller handles cross-stream
// events. Output must not overlap source vectors, maps or state. Check host errors
// and propagate state.error to RHS/solver; zeroed rejected rows are not acceptance.
inline cudaError_t build(E::Graph graph,Source in,L::Interval expected,const uint32_t* priorError,
                         E::Vector* authored,State* state,cudaStream_t stream=nullptr) {
    if(!state || !priorError || !in.partition || !in.graph || !in.topology.status || !in.loads.produced ||
       graph.nodes!=in.topology.chunkCount || graph.bonds!=in.topology.bondCount ||
       (graph.nodes && (!authored || authored==in.effective || !in.effective || !in.receipts ||
        !graph.positions || !graph.prescribed || !in.topology.activeChunks ||
        !in.storage.authorToFine || !in.storage.fineToAuthor || !in.loads.referencePositions ||
        !in.loads.chunks || !in.loads.mass)) || (graph.bonds && (!graph.interfaces || !in.topology.activeBonds)))
        return cudaErrorInvalidValue;
    begin<<<1,1,0,stream>>>(graph,in,expected,priorError,state);
    if(graph.nodes)mapLoads<<<uint32_t((uint64_t(graph.nodes)+127)/128),128,0,stream>>>(graph,in,authored,state);
    if(graph.bonds)motionClosure<<<uint32_t((uint64_t(graph.bonds)+127)/128),128,0,stream>>>(graph,in,state);
    finish<<<1,1,0,stream>>>(state);
    return cudaGetLastError();
}
}}
