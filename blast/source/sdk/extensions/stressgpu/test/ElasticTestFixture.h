// SPDX-License-Identifier: BSD-3-Clause
// Independent CPU oracle and upload helpers shared by standalone CUDA tests.
#pragma once
#include "../detail/StressElasticOperator.cuh"

#include <algorithm>
#include <array>
#include <cmath>
#include <iostream>
#include <stdexcept>
#include <vector>
namespace E = Nv::Blast::Elastic;
void check(cudaError_t e)
{
    if (e != cudaSuccess)
        throw std::runtime_error(cudaGetErrorString(e));
}
void require(bool v, const char* message)
{
    if (!v)
        throw std::runtime_error(message);
}
void near(double actual, double expected, const char* message)
{
    if (!std::isfinite(actual) || std::abs(actual - expected) > 2e-11 * (1 + std::abs(expected)))
    {
        std::cerr << message << ": " << actual << " != " << expected << '\n';
        throw std::runtime_error(message);
    }
}
template <class T>
struct Device
{
    T* p = nullptr;
    size_t n;
    explicit Device(size_t size) : n(size)
    {
        if (n)
            check(cudaMalloc(&p, n * sizeof(T)));
    }
    ~Device()
    {
        cudaFree(p);
    }
    void put(const std::vector<T>& x)
    {
        require(x.size() == n, "upload size");
        if (n)
            check(cudaMemcpy(p, x.data(), n * sizeof(T), cudaMemcpyHostToDevice));
    }
    std::vector<T> get() const
    {
        std::vector<T> x(n);
        if (n)
            check(cudaMemcpy(x.data(), p, n * sizeof(T), cudaMemcpyDeviceToHost));
        return x;
    }
};
using Dense = std::vector<double>;
struct Fixture
{
    std::vector<double3> x{ { 0, 0, 0 }, { 1, 0, .2 }, { 2, 0, 0 }, { 0, 1, .1 }, { 1, 1, .4 }, { 2, 1, .3 } };
    std::vector<E::Bond> bonds;
    std::vector<uint32_t> fixed{ 1, 0, 0, 0, 0, 0 }, starts, refs;
    std::vector<E::Vector> external, prescribed;
    Fixture()
    {
        for (auto pair : std::vector<std::pair<unsigned, unsigned>>{
                 { 0, 1 }, { 1, 2 }, { 3, 4 }, { 4, 5 }, { 0, 3 }, { 1, 4 }, { 2, 5 }, { 0, 4 } })
        {
            E::Bond b{};
            b.first = pair.first;
            b.second = pair.second;
            b.live = 1;
            const auto a = x[b.first], v = x[b.second];
            b.point[0] = (a.x + v.x) / 2 + .07;
            b.point[1] = (a.y + v.y) / 2 - .03;
            b.point[2] = (a.z + v.z) / 2 + .05;
            const double c = std::cos(.37), s = std::sin(.37);
            const double rotation[9] = { 0, -s, c, 0, c, s, -1, 0, 0 };
            std::copy(rotation, rotation + 9, b.frame);
            double lower[36]{};
            for (unsigned i = 0; i < 6; ++i)
                for (unsigned j = 0; j <= i; ++j)
                    lower[6 * i + j] = i == j ? 1 + .3 * i : .025 * (i + j + 1) * (i % 2 ? -1 : 1);
            for (unsigned i = 0; i < 6; ++i)
                for (unsigned j = 0; j < 6; ++j)
                    for (unsigned k = 0; k < 6; ++k)
                        b.stiffness.v[6 * i + j] += lower[6 * i + k] * lower[6 * j + k];
            for (unsigned k = 0; k < 6; ++k)
                b.inelastic.v[k] = .013 * std::sin(k + bonds.size());
            bonds.push_back(b);
        }
        for (unsigned i = 0; i < x.size(); ++i)
        {
            starts.push_back(refs.size());
            for (unsigned e = 0; e < bonds.size(); ++e)
                if (bonds[e].first == i || bonds[e].second == i)
                    refs.push_back(e);
        }
        starts.push_back(refs.size());
        external.resize(x.size());
        prescribed.resize(x.size());
        for (unsigned i = 0; i < x.size(); ++i)
            for (unsigned k = 0; k < 6; ++k)
            {
                external[i].v[k] = std::sin(6 * i + k + .2);
                prescribed[i].v[k] = std::cos(6 * i + k + .7) * .04;
            }
    }
    unsigned size() const
    {
        return 6 * x.size();
    }
    // Explicit endpoint matrices from specification section 3.1.
    Dense G(const E::Bond& b) const
    {
        const unsigned n = size();
        Dense g(6 * n);
        for (unsigned side = 0; side < 2; ++side)
        {
            const auto id = side ? b.second : b.first;
            const auto p = x[id];
            const double r[3] = { b.point[0] - p.x, b.point[1] - p.y, b.point[2] - p.z };
            const double skew[9] = { 0, -r[2], r[1], r[2], 0, -r[0], -r[1], r[0], 0 };
            const double sign = side ? 1 : -1;
            for (unsigned i = 0; i < 3; ++i)
                for (unsigned j = 0; j < 3; ++j)
                {
                    g[i * n + 6 * id + j] = sign * b.frame[3 * j + i];
                    g[(i + 3) * n + 6 * id + j + 3] = sign * b.frame[3 * j + i];
                    for (unsigned k = 0; k < 3; ++k)
                        g[i * n + 6 * id + j + 3] -= sign * b.frame[3 * k + i] * skew[3 * k + j];
                }
        }
        return g;
    }
    Dense matrix() const
    {
        const unsigned n = size();
        Dense a(n * n);
        for (const auto& b : bonds)
            if (b.live)
            {
                const auto g = G(b);
                for (unsigned i = 0; i < n; ++i)
                    for (unsigned j = 0; j < n; ++j)
                        for (unsigned u = 0; u < 6; ++u)
                            for (unsigned v = 0; v < 6; ++v)
                                a[i * n + j] += g[u * n + i] * b.stiffness.v[6 * u + v] * g[v * n + j];
            }
        return a;
    }
};
struct Uploaded
{
    Device<double3> x;
    Device<E::Bond> bonds;
    Device<uint32_t> fixed, starts, refs, error, numerical;
    E::Graph graph{};
    E::Validation limits{ 1e-12, 1e-12, 1e-14 };
    explicit Uploaded(const Fixture& f)
        : x(f.x.size()),
          bonds(f.bonds.size()),
          fixed(f.fixed.size()),
          starts(f.starts.size()),
          refs(f.refs.size()),
          error(1),
          numerical(1)
    {
        x.put(f.x);
        bonds.put(f.bonds);
        fixed.put(f.fixed);
        starts.put(f.starts);
        refs.put(f.refs);
        error.put({ 0 });
        numerical.put({ 0 });
        graph = { uint32_t(f.x.size()), uint32_t(f.bonds.size()), x.p, bonds.p, starts.p, refs.p, fixed.p };
    }
    uint32_t validate()
    {
        error.put({ 0 });
        if (graph.bonds)
            E::validateBonds<<<(graph.bonds + 127) / 128, 128>>>(graph, limits, error.p);
        if (graph.nodes)
            E::validateRows<<<(graph.nodes + 127) / 128, 128>>>(graph, error.p);
        check(cudaGetLastError());
        return error.get()[0];
    }
};
Dense solve(Dense a, Dense b)
{
    const unsigned n = b.size();
    for (unsigned k = 0; k < n; ++k)
    {
        unsigned pivot = k;
        for (unsigned j = k + 1; j < n; ++j)
            if (std::abs(a[j * n + k]) > std::abs(a[pivot * n + k]))
                pivot = j;
        require(std::abs(a[pivot * n + k]) > 1e-12, "singular reference system");
        for (unsigned j = 0; j < n; ++j)
            std::swap(a[k * n + j], a[pivot * n + j]);
        std::swap(b[k], b[pivot]);
        for (unsigned i = k + 1; i < n; ++i)
        {
            const double r = a[i * n + k] / a[k * n + k];
            for (unsigned j = k; j < n; ++j)
                a[i * n + j] -= r * a[k * n + j];
            b[i] -= r * b[k];
        }
    }
    for (int i = n - 1; i >= 0; --i)
    {
        for (unsigned j = i + 1; j < n; ++j)
            b[i] -= a[i * n + j] * b[j];
        b[i] /= a[i * n + i];
    }
    return b;
}
