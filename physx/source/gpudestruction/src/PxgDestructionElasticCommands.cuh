// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgDestructionElasticPartition.cuh"

#include <math_constants.h>

namespace physx
{
namespace destructionElasticCommands
{
namespace P = destructionElasticPartition;
namespace L = destructionElasticLoads;
namespace E = Nv::Blast::Elastic;
enum class Units : uint32_t
{
    Force,
    Impulse
};
// A frozen world-space wrench: force/impulse at point, plus free couple.
// The caller owns time sampling; this evaluator does not assume a follower load
// or infer an application point from a body's six aggregate accelerations.
struct Command
{
    double3 point, force, couple;
    uint32_t chunk;
    Units units;
};
struct Batch
{
    uint64_t tick, inputGeneration, generation;
    double seconds; // explicit common loading interval, also for impulses
    uint32_t count, reserved;
};
struct Query
{
    uint64_t tick, inputGeneration, commandGeneration, ownershipGeneration;
    double seconds;
    uint32_t evaluation, reserved;
};
struct Resolved
{
    E::Vector chunkWrench;
    uint32_t node, reserved;
};
struct Receipt
{
    Query query;
    uint32_t count, nodes, groups, inputValid, error, ready, reserved[2];
};
struct Source
{
    const Batch* batch;
    const Command* commands;
    const P::State* partition;
    const L::Motion* motions;
    const double3* centers; // physical motion COMs, asset axes, packed group order
    P::Identity identity;
    uint32_t commandCapacity;
};
struct Storage
{
    E::Vector *chunks, *bodies; // asset/canonical node wrench; world/body-COM wrench
    Resolved* resolved;
    uint32_t nodes, groups, commands;
};
__device__ bool same(Query a, Query b)
{
    return a.tick == b.tick && a.inputGeneration == b.inputGeneration && a.commandGeneration == b.commandGeneration &&
           a.ownershipGeneration == b.ownershipGeneration && a.seconds == b.seconds && a.evaluation == b.evaluation;
}
__device__ bool finite(E::Vector v)
{
    for (unsigned k = 0; k < 6; ++k)
        if (!isfinite(v.v[k]))
            return false;
    return true;
}
__device__ E::Vector wrench(double3 force, double3 torque)
{
    return { { force.x, force.y, force.z, torque.x, torque.y, torque.z } };
}
// One stream: begin -> clear -> resolve -> scatter -> aggregate -> inspect -> finish -> gate.
// Inputs and all capacity-bearing arrays remain immutable for that sequence.
// This is a pure evaluation: it does not apply commands or advance material time.
__global__ void begin(Source in, Storage out, Query expected, Receipt* receipt)
{
    auto& r = *receipt;
    r = {};
    r.query = expected;
    if (!in.batch || !in.partition || !expected.tick || !expected.inputGeneration || !expected.commandGeneration ||
        expected.evaluation > 1 || !isfinite(expected.seconds) || expected.seconds <= 0)
    {
        r.error = 1;
        return;
    }
    const auto& b = *in.batch;
    const auto& p = *in.partition;
    if (b.tick != expected.tick || b.inputGeneration != expected.inputGeneration ||
        b.generation != expected.commandGeneration || b.seconds != expected.seconds ||
        p.topology != expected.ownershipGeneration || !P::same(p.identity, in.identity))
    {
        r.error = 2;
        return;
    }
    if (p.status != P::Status::Ready || p.error || b.count > in.commandCapacity || b.count > out.commands ||
        p.groups.nodes > out.nodes || p.groups.count > out.groups || (p.groups.nodes && !out.chunks) ||
        (p.groups.count && (!out.bodies || !in.motions || !in.centers)) || (b.count && (!in.commands || !out.resolved)))
    {
        r.error = 4;
        return;
    }
    r.count = b.count;
    r.nodes = p.groups.nodes;
    r.groups = p.groups.count;
    r.inputValid = 1;
}
__global__ void clear(Storage out, const Receipt* receipt)
{
    if (!receipt->inputValid)
        return;
    const auto i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < receipt->nodes)
        out.chunks[i] = {};
    if (i < receipt->groups)
        out.bodies[i] = {};
}
__global__ void resolve(Source in, Storage out, double quaternionTolerance, Receipt* receipt)
{
    const auto i = blockIdx.x * blockDim.x + threadIdx.x;
    if (!receipt->inputValid || i >= receipt->count)
        return;
    const auto c = in.commands[i];
    const auto& p = *in.partition;
    if (c.chunk >= p.sourceNodes || (c.units != Units::Force && c.units != Units::Impulse) || !L::finite(c.point) ||
        !L::finite(c.force) || !L::finite(c.couple))
    {
        atomicOr(&receipt->error, 8u);
        return;
    }
    const auto node = p.storage.authorToFine[c.chunk];
    if (node >= receipt->nodes || p.storage.fineToAuthor[node] != c.chunk)
    {
        atomicOr(&receipt->error, 16u);
        return;
    }
    const auto group = p.storage.chunks[node].cluster;
    if (group >= receipt->groups)
    {
        atomicOr(&receipt->error, 16u);
        return;
    }
    const auto& m = in.motions[group].state;
    const auto* q = m.orientation;
    const double qn = q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3];
    if (!isfinite(quaternionTolerance) || quaternionTolerance <= 0 || quaternionTolerance >= 1 || !isfinite(qn) ||
        fabs(qn - 1) > quaternionTolerance || !L::finite(L::vec(m.origin)) || !L::finite(in.centers[group]) ||
        !L::finite(p.storage.positions[node]))
    {
        atomicOr(&receipt->error, 32u);
        return;
    }
    const double scale = c.units == Units::Impulse ? 1 / receipt->query.seconds : 1;
    const auto force = L::inverseRotate(q, L::mul(c.force, scale));
    const auto couple = L::inverseRotate(q, L::mul(c.couple, scale));
    const auto point = L::inverseRotate(q, L::sub(c.point, L::vec(m.origin)));
    const auto nodeTorque = E::add(couple, E::cross(L::sub(point, p.storage.positions[node]), force));
    Resolved value{};
    value.node = node;
    value.chunkWrench = wrench(force, nodeTorque);
    if (!finite(value.chunkWrench))
    {
        atomicOr(&receipt->error, 64u);
        return;
    }
    out.resolved[i] = value;
}
__global__ void scatter(Storage out, const Receipt* receipt)
{
    const auto i = blockIdx.x * blockDim.x + threadIdx.x;
    if (receipt->error || !receipt->inputValid || i >= receipt->count)
        return;
    const auto value = out.resolved[i];
    for (unsigned k = 0; k < 6; ++k)
    {
        atomicAdd(&out.chunks[value.node].v[k], value.chunkWrench.v[k]);
    }
}
// One 128-thread block per motion group. Reduce chunk loads before one body
// write; do not serialize all commands for an intact building on body atomics.
__global__ void aggregate(Source in, Storage out, double quaternionTolerance, const Receipt* receipt)
{
    const auto group = blockIdx.x, lane = threadIdx.x;
    if (!receipt->inputValid || receipt->error || group >= receipt->groups || !receipt->count)
        return;
    const auto& p = *in.partition;
    const auto* q = in.motions[group].state.orientation;
    const double qn = q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3];
    if (!isfinite(qn) || fabs(qn - 1) > quaternionTolerance || !L::finite(in.centers[group]))
    {
        if (!lane)
            out.bodies[group].v[0] = CUDART_NAN;
        return;
    }
    E::Vector sum{};
    for (uint32_t j = p.groups.starts[group] + lane; j < p.groups.starts[group + 1]; j += 128)
    {
        const auto node = p.groups.indices[j];
        const auto value = out.chunks[node];
        const auto f = make_double3(value.v[0], value.v[1], value.v[2]);
        const auto t = E::add(make_double3(value.v[3], value.v[4], value.v[5]),
                              E::cross(L::sub(p.storage.positions[node], in.centers[group]), f));
        const auto v = wrench(f, t);
        for (unsigned k = 0; k < 6; ++k)
            sum.v[k] += v.v[k];
    }
    __shared__ E::Vector partial[128];
    partial[lane] = sum;
    __syncthreads();
    for (unsigned stride = 64; stride; stride /= 2)
    {
        if (lane < stride)
            for (unsigned k = 0; k < 6; ++k)
                partial[lane].v[k] += partial[lane + stride].v[k];
        __syncthreads();
    }
    if (!lane)
    {
        const double inverse[4] = { -q[0], -q[1], -q[2], q[3] };
        const auto v = partial[0];
        out.bodies[group] = wrench(L::inverseRotate(inverse, make_double3(v.v[0], v.v[1], v.v[2])),
                                   L::inverseRotate(inverse, make_double3(v.v[3], v.v[4], v.v[5])));
    }
}
__global__ void inspect(Storage out, Receipt* receipt)
{
    const auto i = blockIdx.x * blockDim.x + threadIdx.x;
    if (!receipt->inputValid)
        return;
    if ((i < receipt->nodes && !finite(out.chunks[i])) || (i < receipt->groups && !finite(out.bodies[i])))
        atomicOr(&receipt->error, 64u);
}
__global__ void finish(Receipt* receipt)
{
    receipt->ready = receipt->inputValid && !receipt->error;
}
__global__ void gate(const Receipt* receipt, Query expected, uint32_t* downstreamError)
{
    if (!receipt->ready || receipt->error || !same(receipt->query, expected))
        atomicOr(downstreamError, 1u);
}
}
} // namespace physx::destructionElasticCommands
