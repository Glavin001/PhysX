// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgDestructionElasticLoads.cuh"

namespace physx
{
namespace destructionElasticPartition
{
namespace L = destructionElasticLoads;
constexpr uint32_t Invalid = ~uint32_t(0);
struct Identity
{
    uint64_t scene, geometry, mass;
};
enum class Status : uint32_t
{
    Empty,
    Building,
    Ready,
    InvalidInput
};
struct Storage
{
    uint32_t capacity;
    uint32_t *starts, *indices, *local, *fineToAuthor, *authorToFine;
    PxDestructionStressChunk* chunks;
    PxDestructionChunkMassProperties* mass;
    double3* positions;
};
struct State
{
    Identity identity;
    Storage storage;
    uint64_t topology;
    L::Groups groups;
    Status status;
    uint32_t rebuild, builds, error, sourceNodes;
};
struct Source
{
    PxDestructionTopologyDeviceView topology;
    const PxDestructionStressChunk* chunks;
    const double3* positions; // same authored canonical origins as the fine model
};
__device__ bool same(Identity a, Identity b)
{
    return a.scene == b.scene && a.geometry == b.geometry && a.mass == b.mass;
}
__device__ bool same(Storage a, Storage b)
{
    return a.capacity == b.capacity && a.starts == b.starts && a.indices == b.indices && a.local == b.local &&
           a.fineToAuthor == b.fineToAuthor && a.authorToFine == b.authorToFine && a.chunks == b.chunks &&
           a.mass == b.mass && a.positions == b.positions;
}
__device__ bool ready(const State& s, Identity identity, const PxDestructionTopologyDeviceView& t)
{
    return s.status == Status::Ready && !s.error && same(s.identity, identity) && s.topology == t.status->generation &&
           s.sourceNodes == t.chunkCount && s.groups.count == t.status->clusterCount && !t.status->invalidEdit &&
           !t.status->slotError;
}
// All pointers have caller-owned capacities: starts capacity+1; every other
// output capacity. Source arrays obey the native topology-view capacities.
// Order begin -> clear -> pack -> ranges -> validate -> finish on one stream.
// Identities are producer revisions, not sampled content hashes. A configuration
// replacement changes scene; authored geometry/mass updates change their keys.
__global__ void begin(Source in, Storage out, Identity identity, State* state)
{
    auto& s = *state;
    const auto& t = in.topology;
    if (ready(s, identity, t) && same(s.storage, out) && out.capacity >= t.chunkCount)
    {
        s.rebuild = 0;
        return;
    }
    s.rebuild = 1;
    s.error = 0;
    s.identity = identity;
    s.storage = out;
    s.topology = t.status->generation;
    s.sourceNodes = t.chunkCount;
    s.groups = { t.status->clusterCount, 0, out.starts, out.indices, out.local };
    s.status = Status::Building;
    if (!identity.scene || !identity.geometry || !identity.mass || out.capacity < t.chunkCount ||
        t.status->clusterCount > t.chunkCount || t.status->invalidEdit || t.status->slotError)
    {
        s.error = 1;
        s.status = Status::InvalidInput;
        s.groups.count = s.groups.nodes = 0;
    }
}
__global__ void clear(Storage out, State* state)
{
    if (!state->rebuild || state->status != Status::Building)
        return;
    const auto i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < state->sourceNodes)
        out.authorToFine[i] = Invalid;
    if (i <= state->groups.count)
        out.starts[i] = Invalid;
}
__global__ void pack(Source in, Storage out, State* state)
{
    if (!state->rebuild || state->status != Status::Building)
        return;
    const auto j = blockIdx.x * blockDim.x + threadIdx.x;
    const auto& t = in.topology;
    if (j >= t.chunkCount)
        return;
    const auto i = t.orderedChunks[j];
    if (i >= t.chunkCount)
    {
        atomicOr(&state->error, 2u);
        return;
    }
    if (!t.activeChunks[i])
        return;
    const auto group = in.chunks[i].cluster, root = t.chunkCluster[i];
    if (t.activeChunks[i] != 1 || group >= state->groups.count || root >= t.chunkCount || t.activeClusters[group] != root)
    {
        atomicOr(&state->error, 4u);
        return;
    }
    const auto slot = t.clusterSlots[root];
    if (slot >= t.slotCapacity || t.slotRoots[slot] != root || !t.slotGenerations[slot])
    {
        atomicOr(&state->error, 4u);
        return;
    }
    uint32_t previousGroup = Invalid;
    if (j)
    {
        const auto previous = t.orderedChunks[j - 1];
        if (previous >= t.chunkCount || !t.activeChunks[previous])
        {
            atomicOr(&state->error, 2u);
            return;
        }
        previousGroup = in.chunks[previous].cluster;
        if (group < previousGroup)
        {
            atomicOr(&state->error, 2u);
            return;
        }
    }
    bool last = j + 1 == t.chunkCount;
    if (!last)
    {
        const auto next = t.orderedChunks[j + 1];
        if (next >= t.chunkCount)
        {
            atomicOr(&state->error, 2u);
            return;
        }
        last = !t.activeChunks[next];
    }
    if (atomicCAS(out.authorToFine + i, Invalid, j) != Invalid)
    {
        atomicOr(&state->error, 2u);
        return;
    }
    if (!j || previousGroup != group)
    {
        if (atomicCAS(out.starts + group, Invalid, j) != Invalid)
            atomicOr(&state->error, 2u);
    }
    if (last)
        atomicMax(&state->groups.nodes, j + 1);
    out.fineToAuthor[j] = i;
    out.indices[j] = j;
    out.chunks[j] = in.chunks[i];
    out.mass[j] = t.chunks[i];
    out.positions[j] = in.positions[i];
}
__global__ void ranges(Source in, Storage out, State* state)
{
    if (!state->rebuild || state->status != Status::Building)
        return;
    const auto group = blockIdx.x * blockDim.x + threadIdx.x;
    if (group == state->groups.count)
        out.starts[group] = state->groups.nodes;
    if (group >= state->groups.count)
        return;
    // The last boundary uses the count directly: do not read a concurrent
    // write to starts[count] from another block.
    const auto first = out.starts[group],
               end = group + 1 == state->groups.count ? state->groups.nodes : out.starts[group + 1];
    const auto root = in.topology.activeClusters[group];
    if (root >= state->sourceNodes || first == Invalid || end == Invalid || first >= end || end > state->groups.nodes ||
        (!group && first) || end - first != in.topology.clusters[root].chunkCount)
        atomicOr(&state->error, 8u);
}
__global__ void validate(Source in, Storage out, State* state)
{
    if (!state->rebuild || state->status != Status::Building)
        return;
    const auto i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= state->sourceNodes)
        return;
    const auto j = out.authorToFine[i];
    if (!in.topology.activeChunks[i])
    {
        if (j != Invalid)
            atomicOr(&state->error, 2u);
        return;
    }
    if (j >= state->groups.nodes || out.fineToAuthor[j] != i)
    {
        atomicOr(&state->error, 2u);
        return;
    }
    const auto group = in.chunks[i].cluster;
    if (group >= state->groups.count || out.starts[group] > j || out.starts[group + 1] <= j)
    {
        atomicOr(&state->error, 8u);
        return;
    }
    out.local[j] = j - out.starts[group];
}
__global__ void finish(State* state)
{
    auto& s = *state;
    if (!s.rebuild)
        return;
    if (s.status != Status::Building || s.error || (!s.groups.count && s.groups.nodes))
    {
        s.status = Status::InvalidInput;
        s.error |= 1;
        s.groups.count = s.groups.nodes = 0;
        return;
    }
    if (s.builds == Invalid)
    {
        s.status = Status::InvalidInput;
        s.error |= 16;
        s.groups.count = s.groups.nodes = 0;
        return;
    }
    s.status = Status::Ready;
    ++s.builds;
}
// Publication errors must propagate into the load/RHS/solver error chain, even
// for zero active nodes. Empty launches alone cannot certify an empty result.
__global__ void gate(const State* state, Identity identity, PxDestructionTopologyDeviceView topology, uint32_t* error)
{
    if (!ready(*state, identity, topology))
        atomicOr(error, 1u);
}
// Scatter only currently active load channels. Missing/deleted authored nodes
// retain no compact entry. Channel completeness and interval publication belong
// to the live load producer, not to the topology revision receipt.
__global__ void scatter(const State* state,
                        Storage out,
                        const PxDestructionSurfaceLoad* authoredSurface,
                        const L::E::Vector* authoredAdditional,
                        PxDestructionSurfaceLoad* surface,
                        L::E::Vector* additional,
                        const uint32_t* error)
{
    const auto j = blockIdx.x * blockDim.x + threadIdx.x;
    if (state->status != Status::Ready || *error || j >= state->groups.nodes)
        return;
    const auto i = out.fineToAuthor[j];
    surface[j] = authoredSurface[i];
    additional[j] = authoredAdditional ? authoredAdditional[i] : L::E::Vector{};
}
}
}
