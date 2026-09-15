// SPDX-License-Identifier: BSD-3-Clause
#include "../detail/StressElasticPcg.cuh"
#include "ElasticTestFixture.h"

#include <numeric>
#pragma once

struct Solver
{
    Uploaded graph;
    Device<uint32_t> starts, nodes, owner, local, error, reached, nextReached;
    Device<double> length;
    Device<E::Vector> rhs, initial, solution, x, r, p, z, v, truth;
    Device<E::Matrix> basis, factors;
    Device<E::SolveReceipt> receipts;
    Device<E::SetupKey> keys;
    Device<E::SetupState> setup;
    E::Components components{};
    E::SolveWorkspace workspace{};
    E::SolveProfile profile{ 1e-12, 1e-10, 1, 1, 1e-9, 1e-9, 1e-12, 1e-11, 1e-12, 1e-10, 1e-14, .1, 7, 300 };
    Solver(const Fixture& f, const std::vector<uint32_t>& offsets, const std::vector<double>& scales)
        : graph(f),
          starts(offsets.size()),
          nodes(f.x.size()),
          owner(f.x.size()),
          local(f.x.size()),
          error(1),
          reached(f.x.size()),
          nextReached(f.x.size()),
          length(scales.size()),
          rhs(f.x.size()),
          initial(f.x.size()),
          solution(f.x.size()),
          x(f.x.size()),
          r(f.x.size()),
          p(f.x.size()),
          z(f.x.size()),
          v(f.x.size()),
          truth(f.x.size()),
          basis(f.x.size()),
          factors(f.x.size()),
          receipts(scales.size()),
          keys(scales.size()),
          setup(scales.size())
    {
        require(offsets.size() == scales.size() + 1, "partition shape");
        require(!graph.validate(), "solver graph validation");
        starts.put(offsets);
        length.put(scales);
        std::vector<uint32_t> indices(f.x.size()), owners(f.x.size()), locals(f.x.size());
        std::iota(indices.begin(), indices.end(), 0);
        for (unsigned c = 0; c < scales.size(); ++c)
            for (unsigned j = offsets[c]; j < offsets[c + 1]; ++j)
            {
                owners[j] = c;
                locals[j] = j - offsets[c];
            }
        nodes.put(indices);
        owner.put(owners);
        local.put(locals);
        error.put({ 0 });
        components = { uint32_t(scales.size()), starts.p, nodes.p, owner.p, local.p, length.p };
        workspace = { x.p, r.p, p.p, z.p, v.p, truth.p, basis.p, factors.p, reached.p, nextReached.p };
        initial.put(std::vector<E::Vector>(f.x.size()));
        std::vector<E::SetupKey> versions(scales.size());
        for (unsigned c = 0; c < scales.size(); ++c)
            versions[c] = { c + 1, 1, 1, 1, 1, 1, 1 };
        keys.put(versions);
        setup.put(std::vector<E::SetupState>(scales.size()));
        // Poison workspace: no result may depend on allocator contents.
        for (auto buffer : { x.p, r.p, p.p, z.p, v.p, truth.p })
            check(cudaMemset(buffer, 0xff, f.x.size() * sizeof(E::Vector)));
        check(cudaMemset(factors.p, 0xff, f.x.size() * sizeof(E::Matrix)));
    }
    std::vector<E::SolveReceipt> run(const std::vector<E::Vector>& b, bool prepare = true, bool extended = false)
    {
        rhs.put(b);
        error.put({ 0 });
        E::validateComponents<<<(graph.graph.nodes + 127) / 128, 128>>>(graph.graph, components, graph.error.p, error.p);
        // Two blocks deliberately exercise scratch reuse across device-count
        // components in the producer tests. Existing fixed-count tests stay unchanged.
        const auto blocks = components.activeCount ? std::min(components.count, 2u) : components.count;
        if (prepare)
            E::prepareComponents<<<blocks, 128>>>(
                graph.graph, components, workspace, profile, keys.p, setup.p, graph.error.p, error.p);
        if(extended)
            E::solveComponentsExtended<<<blocks, 128>>>(graph.graph, components, rhs.p, initial.p, solution.p, workspace,
                                                      profile, keys.p, setup.p, graph.error.p, error.p, receipts.p);
        else
            E::solveComponents<<<blocks, 128>>>(graph.graph, components, rhs.p, initial.p, solution.p, workspace,
                                                      profile, keys.p, setup.p, graph.error.p, error.p, receipts.p);
        check(cudaGetLastError());
        if (components.activeCount)
        {
            uint32_t count = 0;
            check(cudaMemcpy(&count, components.activeCount, sizeof(count), cudaMemcpyDeviceToHost));
            require(count <= receipts.n, "device component count exceeds receipt capacity");
            std::vector<E::SolveReceipt> result(count);
            if (count)
                check(cudaMemcpy(result.data(), receipts.p, count * sizeof(E::SolveReceipt), cudaMemcpyDeviceToHost));
            return result; // never read unused allocation tail; count did not drive dispatch
        }
        return receipts.get();
    }
};
std::vector<E::Vector> denseProduct(const Fixture& f, const Dense& a, const std::vector<E::Vector>& q)
{
    std::vector<E::Vector> b(f.x.size());
    const auto n = f.size();
    for (unsigned i = 0; i < n; ++i)
        if (!f.fixed[i / 6])
            for (unsigned j = 0; j < n; ++j)
                if (!f.fixed[j / 6])
                    b[i / 6].v[i % 6] += a[i * n + j] * q[j / 6].v[j % 6];
    return b;
}
void residualCheck(const Fixture& f,
                   const std::vector<E::Vector>& b,
                   const std::vector<E::Vector>& q,
                   double tolerance = 2e-8)
{
    const auto value = denseProduct(f, f.matrix(), q);
    for (unsigned i = 0; i < f.x.size(); ++i)
        for (unsigned k = 0; k < 6; ++k)
            require(std::isfinite(q[i].v[k]) &&
                        std::abs(value[i].v[k] - b[i].v[k]) <= tolerance * (1 + std::abs(b[i].v[k])),
                    "independent original-row residual");
}
std::vector<E::Vector> referenceRhs(const Fixture& f)
{
    const auto a = f.matrix();
    const auto n = f.size();
    auto b = f.external;
    for (unsigned i = 0; i < n; ++i)
    {
        if (f.fixed[i / 6])
        {
            b[i / 6].v[i % 6] = 0;
            continue;
        }
        for (unsigned j = 0; j < n; ++j)
            if (f.fixed[j / 6])
                b[i / 6].v[i % 6] -= a[i * n + j] * f.prescribed[j / 6].v[j % 6];
        for (const auto& bond : f.bonds)
            if (bond.live)
            {
                const auto g = f.G(bond);
                for (unsigned u = 0; u < 6; ++u)
                    for (unsigned v = 0; v < 6; ++v)
                        b[i / 6].v[i % 6] += g[u * n + i] * bond.stiffness.v[6 * u + v] * bond.inelastic.v[v];
            }
    }
    return b;
}

std::vector<E::Vector> sparseOracle(const Fixture& f, const std::vector<E::Vector>& q)
{
    std::vector<E::Vector> output(f.x.size());
    const unsigned n = f.size();
    for (const auto& e : f.bonds)
        if (e.live)
        {
            const auto g = f.G(e);
            double d[6]{}, s[6]{};
            for (unsigned u = 0; u < 6; ++u)
                for (unsigned j = 0; j < n; ++j)
                    if (!f.fixed[j / 6])
                        d[u] += g[u * n + j] * q[j / 6].v[j % 6];
            for (unsigned u = 0; u < 6; ++u)
                for (unsigned v = 0; v < 6; ++v)
                    s[u] += e.stiffness.v[6 * u + v] * d[v];
            for (unsigned i = 0; i < n; ++i)
                if (!f.fixed[i / 6])
                    for (unsigned u = 0; u < 6; ++u)
                        output[i / 6].v[i % 6] += g[u * n + i] * s[u];
        }
    return output;
}
