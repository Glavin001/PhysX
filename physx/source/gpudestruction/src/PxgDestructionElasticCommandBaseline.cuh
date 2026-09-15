// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgBodySim.h"
#include "PxgDestructionElasticPartition.cuh"
#include "PxgDestructionRuntime.h"
#include "PxsRigidBody.h"
namespace physx
{
namespace destructionElasticCommandBaseline
{
namespace P = destructionElasticPartition;
namespace L = destructionElasticLoads;
// Initialize index storage to zero once (also newly grown capacity). Epochs
// invalidate untouched entries without clearing the full native body domain.
struct Index
{
    unsigned long long generation;
    uint32_t record, reserved;
};
struct Receipt
{
    uint64_t inputGeneration, topologyGeneration;
    uint32_t groups, records, indexed, ready, error, reserved;
};
struct Source
{
    const PxgDestructionCommandInput* commands;
    const PxgDestructionCommandInputStatus* commandStatus;
    const PxgDestructionInputOwner* owners;
    const PxgDestructionInputOwnership* ownership;
    const PxgBodySim* originalBodies;
    const P::State* partition;
    const double3* childCenters; // world COMs at the rewound input pose
    P::Identity identity;
    uint32_t recordCapacity, bodyCapacity, ownerCapacity, groupCapacity;
};
struct Storage
{
    Index* index;
    PxgBodySimVelocities* velocities;
    uint32_t bodies, groups;
};
// Source/partition/poses stay immutable throughout this sequence. A receipt
// proves the ancestry/ordinary-delta join, not completeness of all commands.
__global__ void begin(Source in, Storage out, uint64_t input, uint64_t topology, Receipt* receipt)
{
    auto& r = *receipt;
    r = {};
    r.inputGeneration = input;
    r.topologyGeneration = topology;
    if (!input || !in.commandStatus || !in.ownership || !in.partition)
    {
        r.error = 1;
        return;
    }
    const auto c = *in.commandStatus;
    const auto o = *in.ownership;
    const auto p = *in.partition;
    if (c.generation != input || o.inputGeneration != input || p.topology != topology ||
        !P::same(p.identity, in.identity))
    {
        r.error = 2;
        return;
    }
    if (c.error || !o.valid || o.error || p.error || p.status != P::Status::Ready || c.count > in.recordCapacity ||
        o.chunkCount > in.ownerCapacity || o.bodyCount > in.bodyCapacity || o.bodyCount > out.bodies ||
        p.sourceNodes != o.chunkCount || p.groups.count > in.groupCapacity || p.groups.count > out.groups ||
        (c.count && !in.commands) || (o.bodyCount && (!in.originalBodies || !out.index)) ||
        (p.groups.count && (!in.owners || !in.childCenters || !out.velocities)))
    {
        r.error = 4;
        return;
    }
    r.groups = p.groups.count;
    r.records = c.count;
}
__global__ void clearSelected(Source in, Storage out, const Receipt* receipt)
{
    const uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= receipt->records)
        return;
    const auto c = in.commands[i];
    if (c.kind == 1 && c.body < in.ownership->bodyCount)
    {
        atomicExch(&out.index[c.body].generation, static_cast<unsigned long long>(receipt->inputGeneration));
        atomicExch(&out.index[c.body].record, P::Invalid);
    }
}
__global__ void indexCommands(Source in, Storage out, Receipt* receipt)
{
    const uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= receipt->records)
        return;
    const auto c = in.commands[i];
    if (!c.kind)
        return;
    if (c.kind != 1 || c.body >= in.ownership->bodyCount || !(c.flags & PxsRigidBody::eHOST_VELOCITY_DELTA_GPU))
    {
        atomicOr(&receipt->error, 8u);
        return;
    }
    for (unsigned k = 0; k < 3; ++k)
        if (!isfinite(c.linearBefore[k]) || !isfinite(c.angularBefore[k]) || !isfinite(c.linearDelta[k]) ||
            !isfinite(c.angularDelta[k]))
        {
            atomicOr(&receipt->error, 16u);
            return;
        }
    if (atomicCAS(&out.index[c.body].record, P::Invalid, i) != P::Invalid)
        atomicOr(&receipt->error, 32u);
}
__global__ void finishIndex(Receipt* receipt)
{
    receipt->indexed = !receipt->error;
}
__device__ bool sameOwner(PxgDestructionInputOwner a, PxgDestructionInputOwner b)
{
    return a.active && b.active && a.body == b.body && a.root == b.root && a.slot == b.slot &&
           a.slotGeneration == b.slotGeneration;
}
// Exactly 128 threads per group. Every surviving chunk must come from the same
// original rigid owner; native fracture splits but does not merge bodies.
__global__ void resolve(Source in, Storage out, Receipt* receipt)
{
    const uint32_t group = blockIdx.x, lane = threadIdx.x;
    if (!receipt->indexed || group >= receipt->groups)
        return;
    const auto& p = *in.partition;
    const uint32_t start = p.groups.starts[group], end = p.groups.starts[group + 1];
    if (start >= end || end > p.groups.nodes)
    {
        if (!lane)
            atomicOr(&receipt->error, 64u);
        return;
    }
    const auto first = p.groups.indices[start];
    if (first >= p.groups.nodes || p.storage.fineToAuthor[first] >= in.ownership->chunkCount)
    {
        if (!lane)
            atomicOr(&receipt->error, 64u);
        return;
    }
    const auto owner = in.owners[p.storage.fineToAuthor[first]];
    bool bad = !owner.active || !owner.slotGeneration || owner.body >= in.ownership->bodyCount ||
               owner.root >= in.ownership->chunkCount;
    for (uint32_t j = start + lane; j < end; j += 128)
    {
        const auto node = p.groups.indices[j];
        if (node >= p.groups.nodes)
        {
            bad = true;
            continue;
        }
        const auto author = p.storage.fineToAuthor[node];
        if (author >= in.ownership->chunkCount || p.storage.chunks[node].cluster != group)
        {
            bad = true;
            continue;
        }
        if (!sameOwner(owner, in.owners[author]))
            bad = true;
    }
    if (__syncthreads_or(bad))
    {
        if (!lane)
            atomicOr(&receipt->error, 64u);
        return;
    }
    if (lane)
        return;
    const auto& body = in.originalBodies[owner.body];
    if (__float_as_uint(body.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w) != owner.body)
    {
        atomicOr(&receipt->error, 128u);
        return;
    }
    float4 v = body.linearVelocityXYZ_inverseMassW, w = body.angularVelocityXYZ_maxPenBiasW;
    const auto entry = out.index[owner.body];
    if (entry.generation == receipt->inputGeneration)
    {
        if (entry.record >= receipt->records)
        {
            atomicOr(&receipt->error, 128u);
            return;
        }
        const auto c = in.commands[entry.record];
        if (c.kind != 1 || c.body != owner.body)
        {
            atomicOr(&receipt->error, 128u);
            return;
        }
        v = make_float4(c.linearBefore[0], c.linearBefore[1], c.linearBefore[2], 0);
        w = make_float4(c.angularBefore[0], c.angularBefore[1], c.angularBefore[2], 0);
    }
    const auto center = in.childCenters[group];
    const auto origin = body.body2World.p;
    const auto offset = make_double3(center.x - origin.x, center.y - origin.y, center.z - origin.z);
    const auto value = make_double3(v.x + double(w.y) * offset.z - double(w.z) * offset.y,
                                    v.y + double(w.z) * offset.x - double(w.x) * offset.z,
                                    v.z + double(w.x) * offset.y - double(w.y) * offset.x);
    PxgBodySimVelocities result{};
    result.linearVelocity = make_float4(float(value.x), float(value.y), float(value.z), 0);
    result.angularVelocity = make_float4(w.x, w.y, w.z, 0);
    if (!L::finite(center) || !L::finite(value) || !isfinite(result.linearVelocity.x) ||
        !isfinite(result.linearVelocity.y) || !isfinite(result.linearVelocity.z) || !isfinite(w.x) || !isfinite(w.y) ||
        !isfinite(w.z))
    {
        atomicOr(&receipt->error, 256u);
        return;
    }
    out.velocities[group] = result;
}
__global__ void finish(Receipt* receipt)
{
    receipt->ready = receipt->indexed && !receipt->error;
}
}
}
