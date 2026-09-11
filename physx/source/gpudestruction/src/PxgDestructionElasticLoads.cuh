// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxDestructionScene.h"
#include "StressElasticOperator.cuh"

namespace physx
{
namespace destructionElasticLoads
{
namespace E = Nv::Blast::Elastic;
// Numerical groups are complete physical motion aggregates, not stress islands.
// They use the packed cluster indices in PxDestructionStressChunk::cluster.
struct Groups
{
    uint32_t count, nodes;
    const uint32_t *starts, *indices, *local;
};
// Live topology publishes counts on device. Capacity-sized launches consume
// this view without a count readback; the caller propagates producer errors.
struct DeviceGroups
{
    const Groups* value;
};
__device__ Groups resolve(Groups groups)
{
    return groups;
}
__device__ Groups resolve(DeviceGroups groups)
{
    return *groups.value;
}
__device__ uint32_t groupCount(uint32_t count)
{
    return count;
}
__device__ uint32_t groupCount(DeviceGroups groups)
{
    return groups.value->count;
}
struct Stamp
{
    uint64_t tick, inputGeneration, ownershipGeneration;
    uint32_t evaluation, complete; // evaluation is 0 (trial) or 1 (correction)
};
struct Interval
{
    Stamp stamp;
    double seconds;
};
enum class MotionMode : uint32_t
{
    CompleteFreeWrench,
    EngineAcceleration
};
struct Motion
{
    PxDestructionClusterMotion state; // angular velocity/world orientation from engine
    double linearAcceleration[3],
        angularAcceleration[3]; // world frame, linear at aggregate COM
    MotionMode mode;
    uint32_t reserved;
};
enum class Status : uint32_t
{
    Ready,
    InvalidInput,
    StaleInput,
    UnsupportedMotion,
    Nonfinite,
    UnbalancedInertia
};
struct Receipt
{
    Interval interval;
    Status status;
    uint32_t supported;
    double mass, center[3], linearAcceleration[3],
        angularAcceleration[3]; // asset frame
    double forceDefect, torqueDefect;
};
static_assert(sizeof(Receipt) == sizeof(Interval) + 2 * sizeof(uint32_t) + 12 * sizeof(double), "load receipt layout");
struct Profile
{
    double quaternionTolerance, pivotTolerance, forceAbsolute, forceRelative, torqueAbsolute, torqueRelative;
};
struct Inputs
{
    const double3* referencePositions; // canonical fine-operator moment origins
    const PxDestructionStressChunk* chunks;
    const PxDestructionChunkMassProperties* mass;
    const PxDestructionSurfaceLoad* surface; // physical force/torque about chunk.position, asset frame
    const E::Vector* additional; // other applied physical wrenches about
                                 // referencePositions, asset frame; excludes gravity
    const Motion* motion;
    const Interval* produced; // producer-owned, written only after all frozen load channels
    double3 gravity; // world frame
};
__device__ double3 vec(const double* x)
{
    return make_double3(x[0], x[1], x[2]);
}
__device__ double3 vec(PxVec3 x)
{
    return make_double3(x.x, x.y, x.z);
}
__device__ double3 sub(double3 a, double3 b)
{
    return make_double3(a.x - b.x, a.y - b.y, a.z - b.z);
}
__device__ double3 mul(double3 a, double s)
{
    return make_double3(a.x * s, a.y * s, a.z * s);
}
__device__ double norm(double3 a)
{
    return sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
}
__device__ bool finite(double3 a)
{
    return isfinite(a.x) && isfinite(a.y) && isfinite(a.z);
}
__device__ double3 inertia(const double* a, double3 x)
{
    return make_double3(a[0] * x.x + a[3] * x.y + a[4] * x.z, a[3] * x.x + a[1] * x.y + a[5] * x.z,
                        a[4] * x.x + a[5] * x.y + a[2] * x.z);
}
__device__ double3 inverseRotate(const double* q, double3 v)
{
    // Normalize an already validated near-unit engine quaternion in FP64.
    const double inverse = 1 / sqrt(q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3]);
    const auto axis = make_double3(-q[0] * inverse, -q[1] * inverse, -q[2] * inverse);
    const auto t = mul(E::cross(axis, v), 2);
    return E::add(v, E::add(mul(t, q[3] * inverse), E::cross(axis, t)));
}
__device__ bool factor(const double* a, double* l, double pivot)
{
    const double scale = fmax(a[0], fmax(a[1], a[2]));
    if (!(scale > 0) || !isfinite(scale))
        return false;
    const double full[9] = { a[0], a[3], a[4], a[3], a[1], a[5], a[4], a[5], a[2] };
    for (unsigned i = 0; i < 9; ++i)
        l[i] = 0;
    for (unsigned i = 0; i < 3; ++i)
        for (unsigned j = 0; j <= i; ++j)
        {
            double value = full[3 * i + j];
            for (unsigned k = 0; k < j; ++k)
                value -= l[3 * i + k] * l[3 * j + k];
            if (i == j)
            {
                if (!isfinite(value) || !(value > pivot * scale))
                    return false;
                l[3 * i + j] = sqrt(value);
            }
            else
            {
                l[3 * i + j] = value / l[3 * j + j];
                if (!isfinite(l[3 * i + j]))
                    return false;
            }
        }
    return true;
}
__device__ double3 solve(const double* l, double3 rhs)
{
    double x[3] = { rhs.x, rhs.y, rhs.z };
    for (unsigned i = 0; i < 3; ++i)
    {
        for (unsigned j = 0; j < i; ++j)
            x[i] -= l[3 * i + j] * x[j];
        x[i] /= l[3 * i + i];
    }
    for (int i = 2; i >= 0; --i)
    {
        for (unsigned j = i + 1; j < 3; ++j)
            x[i] -= l[3 * j + i] * x[j];
        x[i] /= l[3 * i + i];
    }
    return make_double3(x[0], x[1], x[2]);
}
__device__ double sum(double value, double* work)
{
    work[threadIdx.x] = value;
    __syncthreads();
    for (unsigned stride = 64; stride; stride >>= 1)
    {
        if (threadIdx.x < stride)
            work[threadIdx.x] += work[threadIdx.x + stride];
        __syncthreads();
    }
    const double result = work[0];
    __syncthreads();
    return result;
}
__device__ bool same(Stamp a, Stamp b)
{
    return a.tick == b.tick && a.inputGeneration == b.inputGeneration &&
           a.ownershipGeneration == b.ownershipGeneration && a.evaluation == b.evaluation && a.complete == b.complete;
}
__device__ bool valid(Profile p, Interval interval)
{
    const double values[] = { p.quaternionTolerance, p.pivotTolerance, p.forceAbsolute, p.forceRelative,
                              p.torqueAbsolute,      p.torqueRelative, interval.seconds };
    for (double v : values)
        if (!isfinite(v) || v < 0)
            return false;
    return p.quaternionTolerance > 0 && p.quaternionTolerance < 1 && p.pivotTolerance > 0 && p.pivotTolerance < 1 &&
           // Native topology starts at generation zero. Completeness and the
           // nonzero load generation distinguish a published initial input.
           interval.seconds > 0 && interval.stamp.inputGeneration && interval.stamp.complete == 1 &&
           interval.stamp.evaluation <= 1;
}
// Input pointers/capacities and stream lifetimes belong to the caller. Clear
// error, validate once after membership/mass changes, then treat it as
// immutable.
template <class Source>
__global__ void validate(Source source, Inputs in, Profile p, uint32_t* error)
{
    const auto g = resolve(source);
    const uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= g.nodes)
        return;
    const auto group = in.chunks[i].cluster;
    if (!g.count || group >= g.count || g.starts[0] || g.starts[g.count] != g.nodes)
    {
        atomicOr(error, 1u);
        return;
    }
    const auto begin = g.starts[group], end = g.starts[group + 1];
    if (begin >= end || end > g.nodes || g.local[i] >= end - begin || g.indices[begin + g.local[i]] != i)
    {
        atomicOr(error, 1u);
        return;
    }
    const auto& mass = in.mass[i];
    double lower[9];
    bool bad = !isfinite(mass.mass) || !(mass.mass > 0) || mass.supported > 1 || !finite(vec(mass.center)) ||
               !finite(vec(in.chunks[i].position)) || !finite(in.referencePositions[i]);
    for (double v : mass.inertia)
        bad |= !isfinite(v);
    if (bad || !factor(mass.inertia, lower, p.pivotTolerance))
        atomicOr(error, 2u);
}
// This consumes force-valued surface loads, already divided by their producer's
// impulse interval. Never divide them again, or reuse legacy nodeAccelerations.
// One output write per node; no force/torque atomics. Failed receipts
// invalidate every associated output. No fracture, accepted state or material
// time changes.
// A complete unconstrained one-node aggregate has only rigid DOFs. Its internal
// RHS is identically zero, including with spin and offset wrench origins. Solve
// its physical acceleration for the receipt, without subtracting two rounded
// copies of a large external wrench or doing block-wide aggregate reductions.
__device__ void freeSingle(uint32_t i, Inputs in, Interval interval, Profile p, E::Vector* effective, Receipt& receipt)
{
    const auto& m = in.mass[i];
    const auto& motion = in.motion[in.chunks[i].cluster];
    const auto* q = motion.state.orientation;
    const auto center = vec(m.center), node = in.referencePositions[i];
    const auto omega = inverseRotate(q, vec(motion.state.angularVelocity));
    const auto gravity = inverseRotate(q, in.gravity);
    auto force = vec(in.surface[i].force);
    auto torque = E::add(vec(in.surface[i].torque), E::cross(sub(vec(in.chunks[i].position), node), force));
    if (in.additional)
    {
        const auto extra = in.additional[i];
        force = E::add(force, make_double3(extra.v[0], extra.v[1], extra.v[2]));
        torque = E::add(torque, make_double3(extra.v[3], extra.v[4], extra.v[5]));
    }
    // Uniform gravity accelerates the COM and creates no torque about it.
    // Keep it out of moment transport to avoid a rounded gravity couple.
    const auto moment = E::add(torque, E::cross(sub(node, center), force));
    double lower[9];
    if (!finite(force) || !finite(torque) || !finite(moment) || !factor(m.inertia, lower, p.pivotTolerance))
    {
        receipt.status = Status::Nonfinite;
        return;
    }
    const auto acceleration = E::add(gravity, mul(force, 1 / m.mass));
    const auto alpha = solve(lower, sub(moment, E::cross(omega, inertia(m.inertia, omega))));
    if (!finite(acceleration) || !finite(alpha))
    {
        receipt.status = Status::Nonfinite;
        return;
    }
    effective[i] = {};
    receipt = { interval,
                Status::Ready,
                0,
                m.mass,
                { center.x, center.y, center.z },
                { acceleration.x, acceleration.y, acceleration.z },
                { alpha.x, alpha.y, alpha.z },
                0,
                0 };
}
template <class Source>
__global__ __launch_bounds__(128) void build(Source source,
                                             Inputs in,
                                             Interval interval,
                                             Profile p,
                                             const uint32_t* validationError,
                                             E::Vector* effective,
                                             Receipt* receipts)
{
    const auto g = resolve(source);
    const uint32_t group = blockIdx.x;
    if (group >= g.count)
        return;
    auto& receipt = receipts[group];
    if (!threadIdx.x)
        receipt = { interval, Status::InvalidInput, 0, 0, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, 0, 0 };
    if (blockDim.x != 128 || blockDim.y != 1 || blockDim.z != 1 || *validationError || !valid(p, interval))
        return;
    if (!same(in.produced->stamp, interval.stamp) || in.produced->seconds != interval.seconds)
    {
        if (!threadIdx.x)
            receipt.status = Status::StaleInput;
        return;
    }
    const auto begin = g.starts[group], end = g.starts[group + 1];
    if (begin >= end || end > g.nodes)
        return;
    const auto& motion = in.motion[group];
    const auto* q = motion.state.orientation;
    bool bad = false;
    double qnorm = 0;
    for (unsigned k = 0; k < 4; ++k)
    {
        bad |= !isfinite(q[k]);
        qnorm += q[k] * q[k];
    }
    bad |= !isfinite(qnorm) || fabs(qnorm - 1) > p.quaternionTolerance || !finite(in.gravity) ||
           !finite(vec(motion.state.angularVelocity));
    bad |= !finite(vec(motion.linearAcceleration)) || !finite(vec(motion.angularAcceleration)) ||
           !finite(vec(motion.state.origin)) || !finite(vec(motion.state.linearVelocity));
    if (bad || uint32_t(motion.mode) > uint32_t(MotionMode::EngineAcceleration))
        return;
    if (end == begin + 1 && !in.mass[g.indices[begin]].supported && motion.mode == MotionMode::CompleteFreeWrench)
    {
        if (!threadIdx.x)
            freeSingle(g.indices[begin], in, interval, p, effective, receipt);
        return;
    }
    __shared__ double work[128];
    double values[5]{};
    const auto origin = vec(in.mass[g.indices[begin]].center);
    for (uint32_t j = begin + threadIdx.x; j < end; j += 128)
    {
        const auto i = g.indices[j];
        const auto& m = in.mass[i];
        const auto offset = sub(vec(m.center), origin);
        values[0] += m.mass;
        values[1] += m.mass * offset.x;
        values[2] += m.mass * offset.y;
        values[3] += m.mass * offset.z;
        values[4] += m.supported;
    }
    for (double& value : values)
        value = sum(value, work);
    const double mass = values[0];
    const auto center = E::add(origin, make_double3(values[1] / mass, values[2] / mass, values[3] / mass));
    const bool supported = values[4] != 0;
    if (!(mass > 0) || !isfinite(mass) || !finite(center))
    {
        if (!threadIdx.x)
            receipt.status = Status::Nonfinite;
        return;
    }
    if (supported && motion.mode == MotionMode::CompleteFreeWrench)
    {
        if (!threadIdx.x)
            receipt.status = Status::UnsupportedMotion;
        return;
    }
    const auto gravity = inverseRotate(q, in.gravity), omega = inverseRotate(q, vec(motion.state.angularVelocity));
    const bool freeWrench = motion.mode == MotionMode::CompleteFreeWrench;
    // Packed aggregate inertia, total external force/moment and magnitude scales.
    double totals[14]{};
    bad = false;
    for (uint32_t j = begin + threadIdx.x; j < end; j += 128)
    {
        const auto i = g.indices[j];
        const auto& m = in.mass[i];
        const auto node = in.referencePositions[i];
        const auto r = sub(vec(m.center), center);
        auto force = vec(in.surface[i].force);
        auto torque = E::add(vec(in.surface[i].torque), E::cross(sub(vec(in.chunks[i].position), node), force));
        if (in.additional)
        {
            const auto extra = in.additional[i];
            force = E::add(force, make_double3(extra.v[0], extra.v[1], extra.v[2]));
            torque = E::add(torque, make_double3(extra.v[3], extra.v[4], extra.v[5]));
        }
        if (!freeWrench)
        {
            const auto weight = mul(gravity, m.mass);
            force = E::add(force, weight);
            torque = E::add(torque, E::cross(sub(vec(m.center), node), weight));
        }
        // For a complete free aggregate, gravity cancels its translational
        // inertia exactly. Accumulate only the remaining applied wrench;
        // this also avoids a fictitious gravity torque from rounded COM sums.
        bad |= !finite(force) || !finite(torque);
        effective[i] = { { force.x, force.y, force.z, torque.x, torque.y, torque.z } };
        const auto moment = E::add(torque, E::cross(sub(node, center), force));
        totals[0] += m.inertia[0] + m.mass * (r.y * r.y + r.z * r.z);
        totals[1] += m.inertia[1] + m.mass * (r.x * r.x + r.z * r.z);
        totals[2] += m.inertia[2] + m.mass * (r.x * r.x + r.y * r.y);
        totals[3] += m.inertia[3] - m.mass * r.x * r.y;
        totals[4] += m.inertia[4] - m.mass * r.x * r.z;
        totals[5] += m.inertia[5] - m.mass * r.y * r.z;
        totals[6] += force.x;
        totals[7] += force.y;
        totals[8] += force.z;
        totals[9] += moment.x;
        totals[10] += moment.y;
        totals[11] += moment.z;
        // Preserve the existing physical-wrench magnitude scales used by
        // the balance acceptance policy. Only internal-load arithmetic is
        // gravity-relative; removing gravity from these scales changes policy.
        const auto weight = freeWrench ? mul(gravity, m.mass) : make_double3(0, 0, 0);
        totals[12] += norm(E::add(force, weight));
        totals[13] += norm(E::add(moment, E::cross(r, weight)));
    }
    if (__syncthreads_or(bad))
    {
        if (!threadIdx.x)
            receipt.status = Status::Nonfinite;
        return;
    }
    for (double& value : totals)
        value = sum(value, work);
    for (double value : totals)
        bad |= !isfinite(value);
    double lower[9];
    if (bad || !factor(totals, lower, p.pivotTolerance))
    {
        if (!threadIdx.x)
            receipt.status = Status::Nonfinite;
        return;
    }
    auto acceleration = inverseRotate(q, vec(motion.linearAcceleration)),
         alpha = inverseRotate(q, vec(motion.angularAcceleration));
    auto inertialAcceleration = acceleration;
    if (freeWrench)
    {
        inertialAcceleration = mul(vec(totals + 6), 1 / mass);
        acceleration = E::add(gravity, inertialAcceleration); // physical receipt still includes gravity
        alpha = solve(lower, sub(vec(totals + 9), E::cross(omega, inertia(totals, omega))));
    }
    double defects[8]{};
    bad = !finite(acceleration) || !finite(inertialAcceleration) || !finite(alpha);
    for (uint32_t j = begin + threadIdx.x; j < end; j += 128)
    {
        const auto i = g.indices[j];
        const auto& m = in.mass[i];
        const auto node = in.referencePositions[i], r = sub(vec(m.center), center);
        const auto force =
            mul(E::add(inertialAcceleration, E::add(E::cross(alpha, r), E::cross(omega, E::cross(omega, r)))), m.mass);
        const auto torque = E::add(E::add(inertia(m.inertia, alpha), E::cross(omega, inertia(m.inertia, omega))),
                                   E::cross(sub(vec(m.center), node), force));
        auto value = effective[i];
        value.v[0] -= force.x;
        value.v[1] -= force.y;
        value.v[2] -= force.z;
        value.v[3] -= torque.x;
        value.v[4] -= torque.y;
        value.v[5] -= torque.z;
        for (double v : value.v)
            bad |= !isfinite(v);
        effective[i] = value;
        const auto f = make_double3(value.v[0], value.v[1], value.v[2]),
                   t = E::add(make_double3(value.v[3], value.v[4], value.v[5]), E::cross(sub(node, center), f));
        defects[0] += f.x;
        defects[1] += f.y;
        defects[2] += f.z;
        defects[3] += t.x;
        defects[4] += t.y;
        defects[5] += t.z;
        const auto weight = freeWrench ? mul(gravity, m.mass) : make_double3(0, 0, 0);
        defects[6] += norm(E::add(force, weight));
        defects[7] += norm(E::add(E::add(torque, E::cross(sub(node, center), force)), E::cross(r, weight)));
    }
    if (__syncthreads_or(bad))
    {
        if (!threadIdx.x)
            receipt.status = Status::Nonfinite;
        return;
    }
    for (double& value : defects)
        value = sum(value, work);
    const double forceDefect = norm(vec(defects)), torqueDefect = norm(vec(defects + 3));
    Status status = Status::Ready;
    if (!isfinite(forceDefect) || !isfinite(torqueDefect) || !isfinite(defects[6]) || !isfinite(defects[7]))
        status = Status::Nonfinite;
    else if (!supported && (forceDefect > p.forceAbsolute + p.forceRelative * fmax(totals[12], defects[6]) ||
                            torqueDefect > p.torqueAbsolute + p.torqueRelative * fmax(totals[13], defects[7])))
        status = Status::UnbalancedInertia;
    if (!threadIdx.x)
        receipt = { interval,
                    status,
                    uint32_t(supported),
                    mass,
                    { center.x, center.y, center.z },
                    { acceleration.x, acceleration.y, acceleration.z },
                    { alpha.x, alpha.y, alpha.z },
                    forceDefect,
                    torqueDefect };
}
// Clear the downstream error before validation. Join this gate before any
// numerical consumer; it must not turn a rejected load into a zero-load solve.
template <class Source>
__global__ void gate(Source source, const Receipt* receipts, Interval expected, uint32_t* downstreamError)
{
    const auto count = groupCount(source);
    const auto i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < count && (receipts[i].status != Status::Ready || !same(receipts[i].interval.stamp, expected.stamp) ||
                      receipts[i].interval.seconds != expected.seconds))
        atomicOr(downstreamError, 1u);
}
} // namespace destructionElasticLoads
} // namespace physx
