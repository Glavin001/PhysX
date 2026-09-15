// SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "StressElasticSetup.cuh"

namespace Nv
{
namespace Blast
{
namespace Elastic
{
// Exactly 128 threads. Graph/partition validation statuses are immutable during
// this launch and both must be checked. Distinct components never share nodes.
template<bool Extended = false>
__device__ __forceinline__ void solveComponent(uint32_t component, double* scratch, Graph g,
                                                       Components c,
                                                       const Vector* rhs,
                                                       const Vector* initial,
                                                       Vector* solution,
                                                       SolveWorkspace w,
                                                       SolveProfile profile,
                                                       const SetupKey* keys,
                                                       const SetupState* states,
                                                       const uint32_t* graphError,
                                                       const uint32_t* partitionError,
                                                       SolveReceipt* receipts)
{
    if (component >= componentCount(c) || component >= c.count)
        return;
    auto& receipt = receipts[component];
    if (!threadIdx.x)
        receipt = { SolveStatus::InvalidInput, 0, 0, 0, 0, 0, 0, 0 };
    if (blockDim.x != 128 || blockDim.y != 1 || blockDim.z != 1 || *graphError || *partitionError)
        return;
    ComponentBlock b{ g, c, c.starts[component], c.starts[component + 1], c.length[component], scratch };
    if (b.begin >= b.end || b.end > g.nodes || !validProfile(profile, b.length))
        return;
    const auto& state = states[component];
    if (!setupMatches(state, keys[component], b.length, profile))
    {
        if (!threadIdx.x)
            receipt.status = state.status == SetupStatus::ModelUnsupported ? SolveStatus::ModelUnsupported :
                             state.status == SetupStatus::InvalidInput     ? SolveStatus::InvalidInput :
                                                                             SolveStatus::NeedsSetup;
        return;
    }
    const bool free = state.free;
    if constexpr (Extended) {
        // Free-component two-word gauge projection is not implemented yet.
        // Never silently discard the low word or accept an unsupported route.
        if (free || !w.xLow || !w.solutionLow) {
            if (!threadIdx.x) receipt.status = free ? SolveStatus::ModelUnsupported : SolveStatus::InvalidInput;
            return;
        }
    }
    bool bad = false;
    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
    {
        const auto i = b.node(j);
        solution[i] = {};
        w.x[i] = initial[i];
        if constexpr (Extended) {w.xLow[i] = {};w.solutionLow[i] = {};}
        for (unsigned k = 0; k < 6; ++k)
        {
            bad |= !isfinite(rhs[i].v[k]) || !isfinite(initial[i].v[k]);
            if (g.prescribed[i])
            {
                bad |= rhs[i].v[k] != 0;
                w.x[i].v[k] = 0;
            }
            else if (k >= 3)
            {
                if constexpr (Extended) {
                    const auto q=Accurate::multiply({w.x[i].v[k],0},b.length);
                    w.x[i].v[k]=q.hi;w.xLow[i].v[k]=q.lo;
                } else w.x[i].v[k] *= b.length;
            }
        }
    }
    if (__syncthreads_or(bad))
        return;
    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
    {
        const auto i = b.node(j);
        w.r[i] = b.scaled(rhs[i]);
    }
    __syncthreads();
    const double rhsNorm = sqrt(b.dot(w.r, w.r));
    if (!isfinite(rhsNorm))
    {
        if (!threadIdx.x)
            receipt.status = SolveStatus::Nonfinite;
        return;
    }
    // Recursive convergence and residual replacement must respect every
    // acceptance condition. A loose global relative limit must not hide drift
    // while stricter per-node force/moment balance still fails. This norm is
    // sufficient for all three tests; periodic true checks can accept earlier.
    const double recurrenceTarget = fmin(profile.absoluteTolerance + profile.relativeTolerance * rhsNorm,
        fmin(profile.forceScale * profile.forceTolerance,
             profile.torqueScale * profile.torqueTolerance / b.length));
    b.project(w.r, w.basis, free);
    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
    {
        const auto i = b.node(j);
        const auto value = b.scaled(rhs[i]);
        for (unsigned k = 0; k < 6; ++k)
            w.v[i].v[k] = value.v[k] - w.r[i].v[k];
    }
    __syncthreads();
    const double incompatibility = sqrt(b.dot(w.v, w.v));
    if (!threadIdx.x)
        receipt.compatibilityNorm = incompatibility;
    if (!isfinite(incompatibility) ||
        incompatibility > profile.compatibilityAbsolute + profile.compatibilityRelative * rhsNorm)
    {
        if (!threadIdx.x)
            receipt.status = SolveStatus::IncompatibleLoad;
        return;
    }
    b.project(w.x, w.basis, free);
    if (!threadIdx.x)
        receipt.status = SolveStatus::PendingIterationLimit;
    __syncthreads();
    bool accepted = b.residual<Extended>(rhs, w, profile, rhsNorm, receipt);
    // A single free node has no admissible deformation. If its original rows
    // fail the requested balance tolerance, no iteration or diagonal can fix it.
    if (!accepted && free && b.end - b.begin == 1 && receipt.status != SolveStatus::Nonfinite)
    {
        if (!threadIdx.x)
            receipt.status = SolveStatus::IncompatibleLoad;
        return;
    }
    if (!accepted && receipt.status != SolveStatus::Nonfinite && profile.maxIterations)
    {
        // Only require factors after the true-residual check. Trivial free
        // fragments and exact warm starts require no local preconditioner.
        if (!state.factorsValid)
        {
            if (!threadIdx.x)
                receipt.status = SolveStatus::ModelUnsupported;
            return;
        }
        for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
        {
            const auto i = b.node(j);
            w.r[i] = w.truth[i];
        }
        __syncthreads();
        b.project(w.r, w.basis, free);
        double rho = 0;
        bool restart = true;
        for (uint32_t iteration = 0; iteration < profile.maxIterations; ++iteration)
        {
            for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
            {
                const auto i = b.node(j);
                Vector z = w.r[i];
                const auto& l = w.factors[i];
                if (!g.prescribed[i])
                {
                    for (unsigned row = 0; row < 6; ++row)
                    {
                        for (unsigned k = 0; k < row; ++k)
                            z.v[row] -= l.v[6 * row + k] * z.v[k];
                        z.v[row] /= l.v[6 * row + row];
                    }
                    for (int row = 5; row >= 0; --row)
                    {
                        for (unsigned k = row + 1; k < 6; ++k)
                            z.v[row] -= l.v[6 * k + row] * z.v[k];
                        z.v[row] /= l.v[6 * row + row];
                    }
                }
                w.z[i] = z;
            }
            __syncthreads();
            b.project(w.z, w.basis, free);
            const double nextRho = b.dot(w.r, w.z);
            if (!isfinite(nextRho) || !(nextRho > 0))
            {
                accepted = b.residual<Extended>(rhs, w, profile, rhsNorm, receipt);
                if (!accepted && !threadIdx.x && receipt.status != SolveStatus::Nonfinite)
                    receipt.status = SolveStatus::Breakdown;
                break;
            }
            const double beta = restart ? 0 : nextRho / rho;
            rho = nextRho;
            for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
            {
                const auto i = b.node(j);
                for (unsigned k = 0; k < 6; ++k)
                    w.p[i].v[k] = w.z[i].v[k] + (restart ? 0 : beta * w.p[i].v[k]);
            }
            __syncthreads();
            b.project(w.p, w.basis, free);
            b.apply(w.p, w.v);
            b.project(w.v, w.basis, free);
            const double sigma = b.dot(w.p, w.v), alpha = rho / sigma;
            if (!isfinite(sigma) || !(sigma > 0) || !isfinite(alpha))
            {
                accepted = b.residual<Extended>(rhs, w, profile, rhsNorm, receipt);
                if (!accepted && !threadIdx.x && receipt.status != SolveStatus::Nonfinite)
                    receipt.status = SolveStatus::Breakdown;
                break;
            }
            for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
            {
                const auto i = b.node(j);
                for (unsigned k = 0; k < 6; ++k)
                {
                    if constexpr (Extended) {
                        const auto q=Accurate::add({w.x[i].v[k],w.xLow[i].v[k]},
                            Accurate::multiply({w.p[i].v[k],0},alpha));
                        w.x[i].v[k]=q.hi;w.xLow[i].v[k]=q.lo;
                    } else w.x[i].v[k] += alpha * w.p[i].v[k];
                    w.r[i].v[k] -= alpha * w.v[i].v[k];
                }
            }
            __syncthreads();
            b.project(w.x, w.basis, free);
            b.project(w.r, w.basis, free);
            const double norm = sqrt(b.dot(w.r, w.r));
            restart = false;
            if (!threadIdx.x)
                receipt.iterations = iteration + 1;
            __syncthreads();
            if ((iteration + 1) % profile.checkInterval == 0 || iteration + 1 == profile.maxIterations ||
                !isfinite(norm) || norm <= recurrenceTarget)
            {
                accepted = b.residual<Extended>(rhs, w, profile, rhsNorm, receipt);
                if (accepted || receipt.status == SolveStatus::Nonfinite)
                    break;
                b.project(w.truth, w.basis, free);
                for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
                {
                    const auto i = b.node(j);
                    for (unsigned k = 0; k < 6; ++k)
                        w.z[i].v[k] = w.truth[i].v[k] - w.r[i].v[k];
                }
                __syncthreads();
                const double drift = sqrt(b.dot(w.z, w.z)), truthNorm = sqrt(b.dot(w.truth, w.truth));
                restart = !isfinite(norm) ||
                          drift > profile.driftTolerance *
                                      fmax(truthNorm, recurrenceTarget);
                if (restart)
                {
                    for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
                    {
                        const auto i = b.node(j);
                        w.r[i] = w.truth[i];
                    }
                    if (!threadIdx.x)
                        ++receipt.restarts;
                    __syncthreads();
                }
            }
        }
    }
    if (accepted && !threadIdx.x)
        receipt.status = SolveStatus::LinearConverged;
    __syncthreads();
    if (receipt.status == SolveStatus::LinearConverged || receipt.status == SolveStatus::PendingIterationLimit)
        for (uint32_t j = b.begin + threadIdx.x; j < b.end; j += 128)
        {
            const auto i = b.node(j);
            if constexpr (Extended) {
                for(unsigned k=0;k<6;++k) {
                    auto q=Accurate::Scalar{w.x[i].v[k],w.xLow[i].v[k]};
                    if(k>=3)q=Accurate::divide(q,b.length);
                    solution[i].v[k]=q.hi;w.solutionLow[i].v[k]=q.lo;
                }
            } else solution[i] = b.scaled(w.x[i]);
        }
}
// A bounded caller-chosen grid walks the device count. Components retain
// independent convergence; no host count readback or capacity-sized grid is needed.
__global__ __launch_bounds__(128) void solveComponents(Graph g,
                                                       Components c,
                                                       const Vector* rhs,
                                                       const Vector* initial,
                                                       Vector* solution,
                                                       SolveWorkspace w,
                                                       SolveProfile profile,
                                                       const SetupKey* keys,
                                                       const SetupState* states,
                                                       const uint32_t* graphError,
                                                       const uint32_t* partitionError,
                                                       SolveReceipt* receipts)
{
    __shared__ double scratch[128];
    const auto count = min(componentCount(c), c.count);
    for (uint64_t component = blockIdx.x; component < count; component += gridDim.x)
    {
        solveComponent(uint32_t(component), scratch, g, c, rhs, initial, solution, w, profile, keys, states, graphError, partitionError, receipts);
        __syncthreads(); // all users finish shared scratch before the next component
    }
}

// Explicit precision route: FP64 Krylov/preconditioner, two-word accumulated
// solution and original-equation check. Currently anchored components only.
__global__ __launch_bounds__(128) void solveComponentsExtended(Graph g,
                                                       Components c,
                                                       const Vector* rhs,
                                                       const Vector* initial,
                                                       Vector* solution,
                                                       SolveWorkspace w,
                                                       SolveProfile profile,
                                                       const SetupKey* keys,
                                                       const SetupState* states,
                                                       const uint32_t* graphError,
                                                       const uint32_t* partitionError,
                                                       SolveReceipt* receipts)
{
    __shared__ double scratch[128];
    const auto count = min(componentCount(c), c.count);
    for (uint64_t component = blockIdx.x; component < count; component += gridDim.x)
    {
        solveComponent<true>(uint32_t(component), scratch, g, c, rhs, initial, solution, w, profile, keys, states, graphError, partitionError, receipts);
        __syncthreads(); // all users finish shared scratch before the next component
    }
}

}
}
} // Nv::Blast::Elastic
