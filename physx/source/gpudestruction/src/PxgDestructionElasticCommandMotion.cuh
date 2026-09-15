// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgBodySim.h"
#include "PxgDestructionElasticCommandBaseline.cuh"
#include "PxgDestructionElasticCommands.cuh"
#include "PxvIslandMetadata.h"

namespace physx
{
namespace destructionElasticCommandMotion
{
namespace C = destructionElasticCommands;
namespace L = destructionElasticLoads;
namespace E = Nv::Blast::Elastic;
// This epoch belongs to the native input-state producer, not to the command
// evaluator. It advances after fresh input upload or a completed rigid rewind.
struct Binding
{
    uint64_t lifetime;
    uint32_t body, supported;
};
struct History
{
    C::Query query;
    uint64_t nativeEpoch;
    uint32_t applied, reserved;
};
struct Receipt
{
    C::Query query;
    uint64_t nativeEpoch;
    uint32_t groups, ready, error, duplicate;
};
struct Candidate
{
    float4 linear, angular;
    uint32_t body, reserved[3];
};
struct Source
{
    const C::Receipt* commands;
    const E::Vector* wrenches; // world force/couple about native physical COM
    const Binding* bindings; // packed group -> current native ID/lifetime
    const PxvPreSolveNode* nodes;
    PxgBodySim* bodies;
    uint32_t groupCapacity, bodyCapacity;
    const destructionElasticCommandBaseline::Receipt* baselineReceipt = nullptr;
    const PxgBodySimVelocities* baseline = nullptr; // optional verified corrected input
};
struct Storage
{
    Candidate* candidates;
    uint32_t* claims; // bodyCapacity, touched only for selected IDs; no full clear
    uint32_t capacity;
};
// One exclusive native stream: begin -> clearClaims -> prepare -> seal ->
// apply -> commit. Source/storage stay immutable, including native body state,
// until commit. No scene/solver consumer may run between these kernels.
// Correction input MUST be command-free: the existing post-command checkpoint
// alone is insufficient. History validates sequencing, not the physical rewind.
// query.seconds is this application's physical interval, also used by the
// upstream evaluator to normalize impulses; the native producer must match it.
__global__ void begin(Source in, Storage out, C::Query expected, uint64_t epoch, const History* history, Receipt* receipt)
{
    auto& r = *receipt;
    r = {};
    r.query = expected;
    r.nativeEpoch = epoch;
    if (!in.commands || !epoch || !expected.tick || !expected.inputGeneration || !expected.commandGeneration ||
        expected.evaluation > 1 || !isfinite(expected.seconds) || expected.seconds <= 0)
    {
        r.error = 1;
        return;
    }
    const auto& c = *in.commands;
    if (!c.ready || c.error || !C::same(c.query, expected) || c.groups > in.groupCapacity || c.groups > out.capacity ||
        (c.groups && (!in.wrenches || !in.bindings || !in.nodes || !in.bodies || !out.candidates || !out.claims)))
    {
        r.error = 2;
        return;
    }
    if (in.baselineReceipt || in.baseline)
    {
        if (!in.baselineReceipt || !in.baseline || expected.evaluation != 1)
        {
            r.error = 2;
            return;
        }
        const auto b = *in.baselineReceipt;
        if (!b.ready || b.error || b.inputGeneration != expected.inputGeneration ||
            b.topologyGeneration != expected.ownershipGeneration || b.groups != c.groups)
        {
            r.error = 2;
            return;
        }
    }
    const auto& h = *history;
    if (h.applied)
    {
        if (epoch == h.nativeEpoch && C::same(expected, h.query))
        {
            r.duplicate = 1;
            return;
        }
        const bool correction = expected.tick == h.query.tick && expected.evaluation == 1 && h.query.evaluation == 0 &&
                                expected.inputGeneration == h.query.inputGeneration &&
                                expected.commandGeneration == h.query.commandGeneration &&
                                expected.seconds == h.query.seconds;
        const bool next = expected.tick > h.query.tick && expected.evaluation == 0 &&
                          expected.inputGeneration > h.query.inputGeneration &&
                          expected.commandGeneration > h.query.commandGeneration;
        if (epoch <= h.nativeEpoch || !(correction || next))
        {
            r.error = 4;
            return;
        }
    }
    else if (expected.evaluation)
    {
        r.error = 4;
        return;
    }
    // An expired/empty command batch has no native motion work.
    r.groups = c.count ? c.groups : 0;
}
__global__ void clearClaims(Source in, Storage out, const Receipt* receipt)
{
    const uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (receipt->error || receipt->duplicate || i >= receipt->groups)
        return;
    const auto id = in.bindings[i].body;
    if (id < in.bodyCapacity)
        atomicExch(out.claims + id, ~uint32_t(0));
}
__device__ bool finite3(float4 a)
{
    return isfinite(a.x) && isfinite(a.y) && isfinite(a.z);
}
__device__ bool velocity(double3 delta, float4 previous, float4& output)
{
    const float x = float(delta.x), y = float(delta.y), z = float(delta.z);
    output = make_float4(previous.x + x, previous.y + y, previous.z + z, previous.w);
    return isfinite(x) && isfinite(y) && isfinite(z) && finite3(output);
}
__global__ void prepare(Source in, Storage out, Receipt* receipt)
{
    const uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    // Do not read concurrently accumulated error here. Every row validates;
    // seal gates the whole batch after this kernel completes.
    if (receipt->duplicate || i >= receipt->groups)
        return;
    const auto b = in.bindings[i];
    if (b.body >= in.bodyCapacity || !b.lifetime)
    {
        atomicOr(&receipt->error, 8u);
        return;
    }
    const auto node = in.nodes[b.body];
    if (!node.live || node.lifetime != b.lifetime || atomicCAS(out.claims + b.body, ~uint32_t(0), i) != ~uint32_t(0))
    {
        atomicOr(&receipt->error, 8u);
        return;
    }
    const auto body = in.bodies[b.body];
    const auto load = in.wrenches[i];
    auto v = body.linearVelocityXYZ_inverseMassW, w = body.angularVelocityXYZ_maxPenBiasW;
    if (in.baseline)
    {
        const auto base = in.baseline[i];
        v.x = base.linearVelocity.x;
        v.y = base.linearVelocity.y;
        v.z = base.linearVelocity.z;
        w.x = base.angularVelocity.x;
        w.y = base.angularVelocity.y;
        w.z = base.angularVelocity.z;
    }
    const auto inertia = body.inverseInertiaXYZ_contactReportThresholdW;
    if (__float_as_uint(body.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w) != b.body ||
        !C::finite(load) || !finite3(v) || !finite3(w) || !isfinite(v.w) || v.w < 0 || !finite3(inertia) ||
        inertia.x < 0 || inertia.y < 0 || inertia.z < 0 || b.supported > 1 ||
        (b.supported && (v.w != 0 || inertia.x != 0 || inertia.y != 0 || inertia.z != 0)))
    {
        atomicOr(&receipt->error, 16u);
        return;
    }
    Candidate candidate{};
    candidate.body = b.body;
    candidate.linear = v;
    candidate.angular = w;
    // Kinematic supports retain the applied structural wrench but no dynamic
    // velocity response. Zero inverse axes likewise remain locked/infinite.
    if (!b.supported)
    {
        const auto q = body.body2World.q.q;
        const double rotation[4] = { q.x, q.y, q.z, q.w };
        const double norm = double(q.x) * q.x + double(q.y) * q.y + double(q.z) * q.z + double(q.w) * q.w;
        if (!isfinite(norm) || fabs(norm - 1) > 1e-5)
        {
            atomicOr(&receipt->error, 16u);
            return;
        }
        const auto local = L::inverseRotate(rotation, make_double3(load.v[3], load.v[4], load.v[5]));
        const double inverse[4] = { -q.x, -q.y, -q.z, q.w };
        const auto angular =
            L::inverseRotate(inverse, make_double3(local.x * inertia.x, local.y * inertia.y, local.z * inertia.z));
        const double dt = receipt->query.seconds;
        if (!velocity(
                make_double3(load.v[0] * v.w * dt, load.v[1] * v.w * dt, load.v[2] * v.w * dt), v, candidate.linear) ||
            !velocity(L::mul(angular, dt), w, candidate.angular))
        {
            atomicOr(&receipt->error, 32u);
            return;
        }
    }
    out.candidates[i] = candidate;
}
__global__ void seal(Receipt* receipt)
{
    receipt->ready = !receipt->error && !receipt->duplicate;
}
__global__ void apply(Source in, Storage out, const Receipt* receipt)
{
    const uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (!receipt->ready || receipt->error || i >= receipt->groups)
        return;
    const auto c = out.candidates[i];
    in.bodies[c.body].linearVelocityXYZ_inverseMassW = c.linear;
    in.bodies[c.body].angularVelocityXYZ_maxPenBiasW = c.angular;
}
__global__ void commit(const Receipt* receipt, History* history)
{
    if (receipt->ready && !receipt->error)
        *history = { receipt->query, receipt->nativeEpoch, 1, 0 };
}
}
}
