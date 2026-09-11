// SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "StressElasticOperator.cuh"
#include "StressElasticAccurate.cuh"

// Private executable baseline, one cooperative block per connected component.
// All vectors, reductions and stopping decisions remain on the GPU. This is a
// linear solve receipt, not permission to commit material/engine state.
namespace Nv
{
namespace Blast
{
namespace Elastic
{
enum class SolveStatus : uint32_t
{
    LinearConverged,
    PendingIterationLimit,
    InvalidInput,
    ModelUnsupported,
    IncompatibleLoad,
    Nonfinite,
    Breakdown,
    NeedsSetup
};
struct Components
{
    uint32_t count;
    const uint32_t* starts; // count+1, all unknowns; prescribed rows may be omitted
    const uint32_t* nodes; // unique owned rows; omitted prescribed rows are read-only
    const uint32_t* owner; // graph.nodes, inverse component index
    const uint32_t* local; // graph.nodes, inverse offset within component
    const double* length; // count; q = diag(1,1,1,1/L,1/L,1/L) x
    const uint32_t* activeCount = nullptr; // optional device count; count is allocation capacity
};
constexpr uint32_t Unowned = ~uint32_t(0);
__device__ uint32_t componentCount(Components c)
{
    return c.activeCount ? *c.activeCount : c.count;
}
struct SolveProfile
{
    double absoluteTolerance, relativeTolerance;
    double forceScale, torqueScale, forceTolerance, torqueTolerance;
    double compatibilityAbsolute, compatibilityRelative;
    double rankTolerance, nullspaceTolerance, pivotTolerance, driftTolerance;
    uint32_t checkInterval, maxIterations;
};
struct SetupKey
{
    uint64_t identity, generation, topology, geometry, stiffness, supports, layout;
};
enum class SetupStatus : uint32_t
{
    Unprepared,
    Ready,
    InvalidInput,
    ModelUnsupported
};
struct SetupState
{
    SetupKey key;
    double length, rankTolerance, nullspaceTolerance, pivotTolerance;
    SetupStatus status;
    uint32_t free, builds, factorsValid;
};
static_assert(sizeof(SetupState) == 7 * sizeof(uint64_t) + 4 * sizeof(double) + 4 * sizeof(uint32_t), "setup layout");
__device__ bool setupMatches(const SetupState& s, const SetupKey& k, double length, const SolveProfile& p)
{
    return s.status == SetupStatus::Ready && s.key.identity == k.identity && s.key.generation == k.generation &&
           s.key.topology == k.topology && s.key.geometry == k.geometry && s.key.stiffness == k.stiffness &&
           s.key.supports == k.supports && s.key.layout == k.layout && s.length == length &&
           s.rankTolerance == p.rankTolerance && s.nullspaceTolerance == p.nullspaceTolerance &&
           s.pivotTolerance == p.pivotTolerance;
}
struct SolveReceipt
{
    SolveStatus status;
    uint32_t iterations, restarts, residualChecks;
    double residualNorm, maxForce, maxTorque, compatibilityNorm;
};
// Every transferred byte has a named, initialized field (no padding to read).
static_assert(sizeof(SolveReceipt) == 4 * sizeof(uint32_t) + 4 * sizeof(double), "receipt layout");
struct SolveWorkspace
{
    Vector *x, *r, *p, *z, *v, *truth; // disjoint arrays of graph.nodes entries
    Matrix *basis, *factors;
    uint32_t *reached, *nextReached;
    // Required only by the explicit two-word, anchored-component route.
    Vector *xLow = nullptr, *solutionLow = nullptr;
};
// Stream after graph validators. The caller supplies actual pointer capacities.
// This inverse-map check establishes unique complete ownership without atomics
// on vector data. Connectedness is separately checked inside each solve block.
__global__ void validateComponents(Graph g, Components c, const uint32_t* graphError, uint32_t* error)
{
    const uint32_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= g.nodes || *graphError)
        return;
    const auto count = componentCount(c);
    if (count > c.count || c.starts[0] || c.starts[count] > g.nodes)
    {
        atomicOr(error, uint32_t(InvalidGraph));
        return;
    }
    // Check both directions: omitting prescribed rows must not permit holes,
    // duplicate packed entries or an unowned unknown.
    if (i < c.starts[count])
    {
        const auto node = c.nodes[i];
        if (node >= g.nodes || c.owner[node] >= count)
            atomicOr(error, uint32_t(InvalidGraph));
        else
        {
            const auto group = c.owner[node];
            if (c.starts[group] > i || i >= c.starts[group + 1] || c.local[node] != i - c.starts[group])
                atomicOr(error, uint32_t(InvalidGraph));
        }
    }
    const auto owner = c.owner[i];
    if (g.prescribed[i] && owner == Unowned)
    {
        if (c.local[i] != Unowned)
            atomicOr(error, uint32_t(InvalidGraph));
        return;
    }
    if (owner >= count)
    {
        atomicOr(error, uint32_t(InvalidGraph));
        return;
    }
    const auto begin = c.starts[owner], end = c.starts[owner + 1];
    if (begin >= end || end > c.starts[count] || c.local[i] >= end - begin || c.nodes[begin + c.local[i]] != i)
    {
        atomicOr(error, uint32_t(InvalidGraph));
        return;
    }
    for (uint32_t k = g.starts[i]; k < g.starts[i + 1]; ++k)
    {
        const auto& e = g.interfaces[g.references[k]];
        if (live(g, g.references[k]) && !g.prescribed[e.first] && !g.prescribed[e.second] && c.owner[e.first] != c.owner[e.second])
            atomicOr(error, uint32_t(InvalidGraph));
    }
}
__device__ double blockSum(double value, double* scratch)
{
    scratch[threadIdx.x] = value;
    __syncthreads();
    for (unsigned stride = 64; stride; stride >>= 1)
    {
        if (threadIdx.x < stride)
            scratch[threadIdx.x] += scratch[threadIdx.x + stride];
        __syncthreads();
    }
    const double result = scratch[0];
    __syncthreads();
    return result;
}
__device__ double blockMax(double value, double* scratch)
{
    scratch[threadIdx.x] = value;
    __syncthreads();
    for (unsigned stride = 64; stride; stride >>= 1)
    {
        if (threadIdx.x < stride)
            scratch[threadIdx.x] = fmax(scratch[threadIdx.x], scratch[threadIdx.x + stride]);
        __syncthreads();
    }
    const double result = scratch[0];
    __syncthreads();
    return result;
}
struct ComponentBlock
{
    Graph g;
    Components c;
    uint32_t begin, end;
    double length;
    double* scratch;
    __device__ uint32_t node(uint32_t slot) const
    {
        return c.nodes[slot];
    }
    __device__ double dot(const Vector* a, const Vector* b) const
    {
        double value = 0;
        for (uint32_t j = begin + threadIdx.x; j < end; j += 128)
        {
            const auto i = node(j);
            for (unsigned k = 0; k < 6; ++k)
                value += a[i].v[k] * b[i].v[k];
        }
        return blockSum(value, scratch);
    }
    __device__ Vector scaled(Vector a) const
    {
        for (unsigned k = 3; k < 6; ++k)
            a.v[k] /= length;
        return a;
    }
    __device__ void apply(const Vector* x, Vector* y) const
    {
        for (uint32_t j = begin + threadIdx.x; j < end; j += 128)
        {
            const auto i = node(j);
            Vector value{};
            if (!g.prescribed[i])
                for (uint32_t k = g.starts[i]; k < g.starts[i + 1]; ++k)
                {
                    const auto& e = g.interfaces[g.references[k]];
                    if (!live(g, g.references[k]))
                        continue;
                    auto d = endpoint(e, g.positions[e.first], g.prescribed[e.first] ? Vector{} : scaled(x[e.first]), -1);
                    accumulate(d, endpoint(e, g.positions[e.second],
                                           g.prescribed[e.second] ? Vector{} : scaled(x[e.second]), 1));
                    accumulate(
                        value, transposeEndpoint(e, g.positions[i], multiply(e.stiffness, d), e.first == i ? -1 : 1));
                }
            y[i] = scaled(value);
        }
        __syncthreads();
    }
    __device__ void project(Vector* x, const Matrix* basis, bool free) const
    {
        if (!free)
            return;
        // Two passes control loss of orthogonality when warm starts contain a
        // large rigid component. No incompatible load is hidden by this step.
        for (unsigned pass = 0; pass < 2; ++pass)
            for (unsigned mode = 0; mode < 6; ++mode)
            {
                double local = 0;
                for (uint32_t j = begin + threadIdx.x; j < end; j += 128)
                {
                    const auto i = node(j);
                    for (unsigned k = 0; k < 6; ++k)
                        local += basis[i].v[6 * k + mode] * x[i].v[k];
                }
                const double coefficient = blockSum(local, scratch);
                for (uint32_t j = begin + threadIdx.x; j < end; j += 128)
                {
                    const auto i = node(j);
                    for (unsigned k = 0; k < 6; ++k)
                        x[i].v[k] -= coefficient * basis[i].v[6 * k + mode];
                }
                __syncthreads();
            }
    }
    template<bool Extended = false>
    __device__ bool residual(
        const Vector* rhs, SolveWorkspace w, const SolveProfile& p, double rhsNorm, SolveReceipt& receipt) const
    {
        double force = 0, torque = 0;
        bool bad = false;
        for (uint32_t j = begin + threadIdx.x; j < end; j += 128)
        {
            const auto i = node(j);
            const auto applied = Accurate::row(g, i, w.x, length, Extended ? w.xLow : nullptr);
            double f = 0, t = 0;
            for (unsigned k = 0; k < 6; ++k)
            {
                const double value = Accurate::value(Accurate::add({rhs[i].v[k], 0}, Accurate::negate(applied.v[k])));
                w.truth[i].v[k] = k < 3 ? value : value / length;
                bad |= !isfinite(value);
                if (k < 3)
                    f += value * value;
                else
                    t += value * value;
            }
            bad |= !isfinite(f) || !isfinite(t);
            force = fmax(force, sqrt(f) / p.forceScale);
            torque = fmax(torque, sqrt(t) / p.torqueScale);
        }
        const bool nonfinite = __syncthreads_or(bad);
        const double norm = sqrt(dot(w.truth, w.truth)), maxForce = blockMax(force, scratch),
                     maxTorque = blockMax(torque, scratch);
        if (!threadIdx.x)
        {
            ++receipt.residualChecks;
            receipt.residualNorm = norm;
            receipt.maxForce = maxForce;
            receipt.maxTorque = maxTorque;
        }
        __syncthreads();
        if (nonfinite || !isfinite(norm) || !isfinite(maxForce) || !isfinite(maxTorque))
        {
            if (!threadIdx.x)
                receipt.status = SolveStatus::Nonfinite;
            __syncthreads();
            return false;
        }
        return norm <= p.absoluteTolerance + p.relativeTolerance * rhsNorm && maxForce <= p.forceTolerance &&
               maxTorque <= p.torqueTolerance;
    }
};
__device__ bool validProfile(const SolveProfile& p, double length)
{
    const double values[] = { p.absoluteTolerance,
                              p.relativeTolerance,
                              p.forceScale,
                              p.torqueScale,
                              p.forceTolerance,
                              p.torqueTolerance,
                              p.compatibilityAbsolute,
                              p.compatibilityRelative,
                              p.rankTolerance,
                              p.nullspaceTolerance,
                              p.pivotTolerance,
                              p.driftTolerance,
                              length };
    for (double v : values)
        if (!isfinite(v) || v < 0)
            return false;
    return length > 0 && p.forceScale > 0 && p.torqueScale > 0 && p.rankTolerance > 0 && p.rankTolerance < 1 &&
           p.pivotTolerance > 0 && p.pivotTolerance < 1 && p.nullspaceTolerance > 0 && p.driftTolerance > 0 &&
           (p.absoluteTolerance > 0 || p.relativeTolerance > 0) && p.checkInterval > 0;
}
}
}
} // Nv::Blast::Elastic
