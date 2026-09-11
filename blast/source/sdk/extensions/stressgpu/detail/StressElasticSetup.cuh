// SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "StressElasticPcgBlock.cuh"
namespace Nv
{
namespace Blast
{
namespace Elastic
{
// Producer revisions must advance before mutating corresponding device inputs.
// Initialize states once; phase-order edits, validation, setup and solve.
__device__ __forceinline__ void prepareComponent(uint32_t component, double* scratch, Graph g,
                                                         Components c,
                                                         SolveWorkspace w,
                                                         SolveProfile profile,
                                                         const SetupKey* keys,
                                                         SetupState* states,
                                                         const uint32_t* graphError,
                                                         const uint32_t* partitionError)
{
    if (component >= componentCount(c) || component >= c.count)
        return;
    auto& state = states[component];
    if (blockDim.x != 128 || blockDim.y != 1 || blockDim.z != 1 || *graphError || *partitionError)
    {
        if (!threadIdx.x)
            state.status = SetupStatus::InvalidInput;
        return;
    }
    ComponentBlock b{ g, c, c.starts[component], c.starts[component + 1], c.length[component], scratch };
    if (b.begin >= b.end || b.end > g.nodes || !validProfile(profile, b.length))
    {
        if (!threadIdx.x)
            state.status = SetupStatus::InvalidInput;
        return;
    }
    const bool cached = __syncthreads_and(setupMatches(state, keys[component], b.length, profile));
    if (cached)
        return;
    if (!threadIdx.x)
    {
        const uint32_t builds = state.builds + 1;
        state = { keys[component],
                  b.length,
                  profile.rankTolerance,
                  profile.nullspaceTolerance,
                  profile.pivotTolerance,
                  SetupStatus::InvalidInput,
                  0,
                  builds,
                  0 };
    }
    __syncthreads();
    double supports = 0;
    bool bad = false;
    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
    {
        const auto i = b.node(j);
        supports += g.prescribed[i];
        // An eliminated support still anchors every incident unknown component.
        for (uint32_t k = g.starts[i]; k < g.starts[i + 1]; ++k)
        {
            const auto& e = g.interfaces[g.references[k]];
            const auto other = e.first == i ? e.second : e.first;
            supports += live(g, g.references[k]) && g.prescribed[other];
        }
        w.reached[i] = uint32_t(j == b.begin);
    }
    __syncthreads();
    const bool free = blockSum(supports, scratch) == 0;
    if (free && b.end - b.begin == 1)
    {
        // An isolated free chunk has K=0 and six exact coordinate null modes.
        // Verify the zero operator instead of traversing connectivity and
        // orthogonalizing/checking six modes through the general bond path.
        if (!threadIdx.x)
        {
            const auto i = b.node(b.begin);
            bool isolated = true;
            for (uint32_t k = g.starts[i]; k < g.starts[i + 1]; ++k)
                isolated &= !live(g, g.references[k]);
            if (isolated)
            {
                Matrix identity{};
                for (unsigned k = 0; k < 6; ++k)
                    identity.v[7 * k] = 1;
                w.basis[i] = identity;
                w.factors[i] = {};
                // Retain the same final tested mode and exact zero action.
                w.p[i] = {};
                w.p[i].v[5] = 1;
                w.v[i] = {};
                state.free = 1;
                state.factorsValid = 0;
                state.status = SetupStatus::Ready;
            }
            // A live interface in a free singleton contradicts the supplied
            // closed component partition; retain InvalidInput in that case.
        }
        return;
    }
    // Verify connectedness of owned rows only. Shared, eliminated supports
    // never connect independent unknown components. Temporary baseline check; persistent topology will supply this
    // proof at its producer boundary during engine integration.
    for (uint32_t pass = 0; pass < b.end - b.begin; ++pass)
    {
        bool changed = false;
        for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
        {
            const auto i = b.node(j);
            uint32_t seen = w.reached[i];
            for (uint32_t k = g.starts[i]; k < g.starts[i + 1]; ++k)
            {
                const auto& e = g.interfaces[g.references[k]];
                const auto other = e.first == i ? e.second : e.first;
                if (live(g, g.references[k]) && c.owner[other] == component)
                    seen |= w.reached[other];
            }
            w.nextReached[i] = seen;
            changed |= seen != w.reached[i];
        }
        const bool any = __syncthreads_or(changed);
        for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
        {
            const auto i = b.node(j);
            w.reached[i] = w.nextReached[i];
        }
        __syncthreads();
        if (!any)
            break;
    }
    bad = false;
    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
        bad |= !w.reached[b.node(j)];
    if (__syncthreads_or(bad))
        return;
    if (free)
    {
        const auto origin = g.positions[b.node(b.begin)];
        double center[3]{};
        for (unsigned axis = 0; axis < 3; ++axis)
        {
            double local = 0;
            for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
            {
                const auto x = g.positions[b.node(j)];
                local += axis == 0 ? x.x - origin.x : axis == 1 ? x.y - origin.y : x.z - origin.z;
            }
            center[axis] = blockSum(local, scratch) / (b.end - b.begin);
        }
        for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
        {
            const auto i = b.node(j);
            const auto x = g.positions[i];
            const double r[3] = { x.x - origin.x - center[0], x.y - origin.y - center[1], x.z - origin.z - center[2] };
            Matrix n{};
            for (unsigned k = 0; k < 3; ++k)
            {
                n.v[6 * k + k] = 1;
                n.v[6 * (k + 3) + k + 3] = b.length;
            }
            n.v[4] = r[2];
            n.v[5] = -r[1];
            n.v[9] = -r[2];
            n.v[11] = r[0];
            n.v[15] = r[1];
            n.v[16] = -r[0];
            w.basis[i] = n;
        }
        __syncthreads();
        // Twice-modified Gram-Schmidt of analytical scaled six-variable modes.
        for (unsigned mode = 0; mode < 6; ++mode)
        {
            double original = 0;
            for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
            {
                const auto i = b.node(j);
                for (unsigned k = 0; k < 6; ++k)
                {
                    const double v = w.basis[i].v[6 * k + mode];
                    original += v * v;
                }
            }
            original = blockSum(original, scratch);
            for (unsigned pass = 0; pass < 2; ++pass)
                for (unsigned previous = 0; previous < mode; ++previous)
                {
                    double local = 0;
                    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
                    {
                        const auto i = b.node(j);
                        for (unsigned k = 0; k < 6; ++k)
                            local += w.basis[i].v[6 * k + previous] * w.basis[i].v[6 * k + mode];
                    }
                    const double coefficient = blockSum(local, scratch);
                    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
                    {
                        const auto i = b.node(j);
                        for (unsigned k = 0; k < 6; ++k)
                            w.basis[i].v[6 * k + mode] -= coefficient * w.basis[i].v[6 * k + previous];
                    }
                    __syncthreads();
                }
            double norm = 0;
            for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
            {
                const auto i = b.node(j);
                for (unsigned k = 0; k < 6; ++k)
                {
                    const double v = w.basis[i].v[6 * k + mode];
                    norm += v * v;
                }
            }
            norm = blockSum(norm, scratch);
            if (!isfinite(norm) || !isfinite(original) ||
                !(norm > profile.rankTolerance * profile.rankTolerance * original))
            {
                if (!threadIdx.x)
                    state.status = SetupStatus::ModelUnsupported;
                return;
            }
            for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
            {
                const auto i = b.node(j);
                for (unsigned k = 0; k < 6; ++k)
                    w.p[i].v[k] = w.basis[i].v[6 * k + mode] /= sqrt(norm);
            }
            __syncthreads();
            // Judge the represented mode against the original fine equations.
            // Ordinary iteration arithmetic can overstate a nearly cancelling
            // rigid-mode defect (native free fragments expose this at D=1e6).
            // Preserve the configured limit and rotational coordinate scaling.
            for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
            {
                const auto i = b.node(j);
                const auto action = Accurate::row(g, i, w.p, b.length);
                for (unsigned k = 0; k < 6; ++k)
                    w.v[i].v[k] = Accurate::value(action.v[k]) / (k < 3 ? 1 : b.length);
            }
            __syncthreads();
            const double defect = sqrt(b.dot(w.v, w.v));
            if (!isfinite(defect) || defect > profile.nullspaceTolerance)
            {
                if (!threadIdx.x)
                    state.status = SetupStatus::ModelUnsupported;
                return;
            }
        }
    }
    bool singular = false;
    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
    {
        const auto i = b.node(j);
        Matrix a{}, l{};
        if (!g.prescribed[i] && !(free && b.end - b.begin == 1))
        {
            for (uint32_t k = g.starts[i]; k < g.starts[i + 1]; ++k)
            {
                const auto& e = g.interfaces[g.references[k]];
                if (!live(g, g.references[k]))
                    continue;
                for (unsigned column = 0; column < 6; ++column)
                {
                    Vector unit{};
                    unit.v[column] = column < 3 ? 1 : 1 / b.length;
                    const double sign = e.first == i ? -1 : 1;
                    const auto v = b.scaled(transposeEndpoint(
                        e, g.positions[i], multiply(e.stiffness, endpoint(e, g.positions[i], unit, sign)), sign));
                    for (unsigned row = 0; row < 6; ++row)
                        a.v[6 * row + column] += v.v[row];
                }
            }
            singular |= !cholesky(a, l, profile.pivotTolerance);
        }
        w.factors[i] = l;
    }

    const bool anySingular = __syncthreads_or(singular);
    if (!threadIdx.x)
    {
        state.free = free;
        state.factorsValid = !anySingular && !(free && b.end - b.begin == 1);
        state.status = SetupStatus::Ready;
    }
}
// A bounded caller-chosen grid walks the device count. Components retain
// independent convergence; no host count readback or capacity-sized grid is needed.
__global__ __launch_bounds__(128) void prepareComponents(Graph g,
                                                         Components c,
                                                         SolveWorkspace w,
                                                         SolveProfile profile,
                                                         const SetupKey* keys,
                                                         SetupState* states,
                                                         const uint32_t* graphError,
                                                         const uint32_t* partitionError)
{
    __shared__ double scratch[128];
    const auto count = min(componentCount(c), c.count);
    for (uint64_t component = blockIdx.x; component < count; component += gridDim.x)
    {
        prepareComponent(uint32_t(component), scratch, g, c, w, profile, keys, states, graphError, partitionError);
        __syncthreads(); // all users finish shared scratch before the next component
    }
}

}
}
}
