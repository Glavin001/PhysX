// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxDestructionTopologyTypes.h"
#include "StressElasticPcgBlock.cuh"

namespace physx { namespace destructionElasticGraph {
namespace E = Nv::Blast::Elastic;
struct State {
    E::SetupKey key;
    uint32_t error, inputError, ready, reserved;
};
// Authored numerical geometry/material arrays stay in authored order. Native
// topology supplies the deletion mask directly: no per-fracture matrix copy.
// The caller owns/fixes every allocation until graph consumers finish.
inline E::Graph view(E::Graph authored, PxDestructionTopologyDeviceView topology, uint32_t* prescribed) {
    authored.prescribed=prescribed;
    authored.activeBonds=topology.activeBonds;
    return authored;
}
__global__ void begin(PxDestructionTopologyDeviceView topology,E::SetupKey revisions,State* state) {
    revisions.topology=topology.status->generation; // native generation zero is valid
    const uint32_t error=topology.status->invalidEdit || topology.status->slotError ||
        !revisions.identity || !revisions.generation || !revisions.geometry ||
        !revisions.stiffness || !revisions.supports || !revisions.layout ? E::InvalidGraph : 0;
    *state={revisions,error,error,0,0};
}
__global__ void bindNodes(PxDestructionTopologyDeviceView topology,uint32_t* prescribed,State* state) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=topology.chunkCount)return;
    // Inactive chunks have no live incident bond (checked below), so removing
    // them from the unknown set introduces no artificial support/reaction.
    prescribed[i]=!topology.activeChunks[i] || topology.chunks[i].supported;
    if(topology.activeChunks[i]>1 || topology.chunks[i].supported>1)
        atomicOr(&state->error,uint32_t(E::InvalidGraph));
}
__global__ void bindBonds(E::Graph graph,PxDestructionTopologyDeviceView topology,State* state) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=graph.bonds || state->inputError)return;
    const auto native=topology.bonds[i];const auto& bond=graph.interfaces[i];
    // Ordered endpoint identity preserves the signs of local force/moment and
    // inelastic history. Native liveness is authoritative, never reinterpreted.
    if(native.chunk0>=graph.nodes || native.chunk1>=graph.nodes ||
       bond.first!=native.chunk0 || bond.second!=native.chunk1 || bond.live!=1 ||
       topology.activeBonds[i]>1) {
        atomicOr(&state->error,uint32_t(E::InvalidGraph));return;
    }
    if(topology.activeBonds[i] && (!topology.activeChunks[native.chunk0] || !topology.activeChunks[native.chunk1]))
        atomicOr(&state->error,uint32_t(E::InvalidGraph));
}
__global__ void finish(State* state) { state->ready=!state->error; }
__global__ void emptyRows(const uint32_t* starts,State* state) {
    if(starts[0])atomicOr(&state->error,uint32_t(E::InvalidGraph));
}
__global__ void gate(const State* state,PxDestructionTopologyDeviceView topology,const E::SetupKey* expected,uint32_t* error) {
    const auto& a=state->key;const auto& b=*expected;
    if(!state->ready || state->error || topology.status->invalidEdit || topology.status->slotError ||
       a.topology!=topology.status->generation || a.identity!=b.identity || a.generation!=b.generation ||
       a.geometry!=b.geometry || a.stiffness!=b.stiffness || a.supports!=b.supports || a.layout!=b.layout)
        atomicOr(error,uint32_t(E::InvalidGraph));
}
// Call explicitly at the producer's topology/support/material edit boundary.
// No idle scans or host count reads are needed. Caller advances revisions before
// editing inputs; this module does not discover unreported edits by hashing.
inline cudaError_t build(E::Graph authored,PxDestructionTopologyDeviceView topology,uint32_t* prescribed,
                         E::SetupKey revisions,E::Validation limits,State* state,cudaStream_t stream=nullptr) {
    if(!state || !topology.status || authored.nodes!=topology.chunkCount || authored.bonds!=topology.bondCount ||
       (!authored.nodes && authored.bonds) || authored.bonds>UINT32_MAX/2 ||
       !std::isfinite(limits.frameTolerance) || limits.frameTolerance<0 ||
       !std::isfinite(limits.symmetryTolerance) || limits.symmetryTolerance<0 ||
       !std::isfinite(limits.relativePivotTolerance) || limits.relativePivotTolerance<0 ||
       !authored.starts || (authored.nodes && (!prescribed || !authored.positions || !topology.chunks || !topology.activeChunks)) ||
       (authored.bonds && (!authored.interfaces || !authored.references || !topology.bonds || !topology.activeBonds)))
        return cudaErrorInvalidValue;
    const auto graph=view(authored,topology,prescribed);
    begin<<<1,1,0,stream>>>(topology,revisions,state);
    if(graph.nodes) {
        bindNodes<<<uint32_t((uint64_t(graph.nodes)+127)/128),128,0,stream>>>(topology,prescribed,state);
        E::validateRows<<<uint32_t((uint64_t(graph.nodes)+127)/128),128,0,stream>>>(graph,&state->error);
    }
    else emptyRows<<<1,1,0,stream>>>(graph.starts,state);
    if(graph.bonds) {
        bindBonds<<<uint32_t((uint64_t(graph.bonds)+127)/128),128,0,stream>>>(graph,topology,state);
        E::validateBonds<<<uint32_t((uint64_t(graph.bonds)+127)/128),128,0,stream>>>(graph,limits,&state->error);
    }
    finish<<<1,1,0,stream>>>(state);
    return cudaGetLastError();
}
}}
