#pragma once
// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "ElasticTestFixture.h"
#include "PxgDestructionElasticPartition.cuh"

#include <numeric>
namespace P = physx::destructionElasticPartition;
namespace L = physx::destructionElasticLoads;
using namespace physx;
struct FixturePartition
{
    unsigned n, groups;
    std::vector<uint32_t> active, root, order, roots, rootSlot, slotRoot;
    std::vector<uint64_t> slotGeneration;
    std::vector<PxDestructionStressChunk> chunks;
    std::vector<PxDestructionChunkMassProperties> mass;
    std::vector<PxDestructionClusterMassProperties> clusterMass;
    std::vector<double3> positions;
    FixturePartition(unsigned nodes, unsigned count, bool sparse)
        : n(nodes),
          groups(count),
          active(n),
          root(n, P::Invalid),
          rootSlot(n, P::Invalid),
          slotRoot(n, P::Invalid),
          slotGeneration(n, 1),
          chunks(n),
          mass(n),
          clusterMass(n),
          positions(n)
    {
        std::vector<std::vector<uint32_t>> members(groups);
        for (unsigned i = 0; i < n; ++i)
        {
            active[i] = !sparse || i % 5 != 1;
            if (active[i])
                members[i % groups].push_back(i);
            positions[i] = make_double3(.1 * i, .2 * (i % 7), .3 * (i % 11));
            chunks[i].position = PxVec3(positions[i].x, positions[i].y, positions[i].z);
            chunks[i].mass = 1;
            chunks[i].inertia = 1;
            mass[i] = { { positions[i].x, positions[i].y, positions[i].z }, 1, { 1, 2, 3, .1, .2, .1 }, 0 };
        }
        for (unsigned g = 0; g < groups; ++g)
        {
            require(!members[g].empty(), "empty fixture group");
            const auto r = members[g][0];
            roots.push_back(r);
            rootSlot[r] = groups - 1 - g;
            slotRoot[groups - 1 - g] = r;
            clusterMass[r].chunkCount = members[g].size();
            for (auto i : members[g])
            {
                root[i] = r;
                chunks[i].cluster = g;
                order.push_back(i);
            }
        }
        for (unsigned i = 0; i < n; ++i)
            if (!active[i])
                order.push_back(i);
    }
};
struct Upload
{
    Device<uint32_t> active, root, order, roots, rootSlot, slotRoot, starts, indices, local, fineToAuthor, authorToFine,
        error;
    Device<uint64_t> slotGeneration;
    Device<PxDestructionStressChunk> chunks, compactChunks;
    Device<PxDestructionChunkMassProperties> mass, compactMass;
    Device<PxDestructionClusterMassProperties> clusterMass;
    Device<double3> positions, compactPositions;
    Device<PxDestructionTopologyStatus> topologyStatus;
    Device<P::State> state;
    Device<PxDestructionSurfaceLoad> surface, compactSurface;
    Device<E::Vector> extra, compactExtra, effective;
    Device<L::Motion> motions;
    Device<L::Interval> interval;
    Device<L::Receipt> receipts;
    PxDestructionTopologyDeviceView view{};
    P::Storage storage{};
    P::Source source{};
    P::Identity identity{ 1, 1, 1 };
    unsigned n;
    Upload(const FixturePartition& f)
        : active(f.n),
          root(f.n),
          order(f.n),
          roots(f.n),
          rootSlot(f.n),
          slotRoot(f.n),
          starts(f.n + 1),
          indices(f.n),
          local(f.n),
          fineToAuthor(f.n),
          authorToFine(f.n),
          error(1),
          slotGeneration(f.n),
          chunks(f.n),
          compactChunks(f.n),
          mass(f.n),
          compactMass(f.n),
          clusterMass(f.n),
          positions(f.n),
          compactPositions(f.n),
          topologyStatus(1),
          state(1),
          surface(f.n),
          compactSurface(f.n),
          extra(f.n),
          compactExtra(f.n),
          effective(f.n),
          motions(f.n),
          interval(1),
          receipts(f.n),
          n(f.n)
    {
        state.put({ {} });
        update(f, 0);
        error.put({ 0 });
        view.chunks = mass.p;
        view.activeChunks = active.p;
        view.chunkCluster = root.p;
        view.orderedChunks = order.p;
        view.activeClusters = roots.p;
        view.clusters = clusterMass.p;
        view.clusterSlots = rootSlot.p;
        view.slotRoots = slotRoot.p;
        view.slotGenerations = slotGeneration.p;
        view.slotCapacity = n;
        view.status = topologyStatus.p;
        view.chunkCount = n;
        storage = { n,
                    starts.p,
                    indices.p,
                    local.p,
                    fineToAuthor.p,
                    authorToFine.p,
                    compactChunks.p,
                    compactMass.p,
                    compactPositions.p };
        source = { view, chunks.p, positions.p };
        surface.put(std::vector<PxDestructionSurfaceLoad>(n));
        extra.put(std::vector<E::Vector>(n));
        std::vector<L::Motion> m(n);
        for (auto& v : m)
        {
            v.state.orientation[3] = 1;
            v.mode = L::MotionMode::CompleteFreeWrench;
        }
        motions.put(m);
    }
    void update(const FixturePartition& f, uint64_t generation)
    {
        require(f.n == n, "fixture capacity changed");
        active.put(f.active);
        root.put(f.root);
        order.put(f.order);
        rootSlot.put(f.rootSlot);
        slotRoot.put(f.slotRoot);
        slotGeneration.put(f.slotGeneration);
        chunks.put(f.chunks);
        mass.put(f.mass);
        positions.put(f.positions);
        clusterMass.put(f.clusterMass);
        auto r = f.roots;
        r.resize(n, P::Invalid);
        roots.put(r);
        topologyStatus.put({ { generation, f.groups, 0, 0, 0 } });
    }
    void prepare()
    {
        P::begin<<<1, 1>>>(source, storage, identity, state.p);
        P::clear<<<(n + 128) / 128, 128>>>(storage, state.p);
        P::pack<<<std::max(1u, (n + 127) / 128), 128>>>(source, storage, state.p);
        P::ranges<<<(n + 128) / 128, 128>>>(source, storage, state.p);
        P::validate<<<std::max(1u, (n + 127) / 128), 128>>>(source, storage, state.p);
        P::finish<<<1, 1>>>(state.p);
        check(cudaGetLastError());
    }
    void consume(L::Interval expected)
    {
        interval.put({ expected });
        error.put({ 0 });
        P::gate<<<1, 1>>>(state.p, identity, view, error.p);
        P::scatter<<<std::max(1u, (n + 127) / 128), 128>>>(
            state.p, storage, surface.p, extra.p, compactSurface.p, compactExtra.p, error.p);
        const L::Inputs input{ compactPositions.p, compactChunks.p, compactMass.p, compactSurface.p,
                               compactExtra.p,     motions.p,       interval.p,    { 0, 0, 0 } };
        const L::DeviceGroups groups{ &state.p->groups };
        const L::Profile profile{ 1e-6, 1e-14, 1e-11, 1e-11, 1e-11, 1e-11 };
        L::validate<<<std::max(1u, (n + 127) / 128), 128>>>(groups, input, profile, error.p);
        L::build<<<std::max(1u, n), 128>>>(groups, input, expected, profile, error.p, effective.p, receipts.p);
        L::gate<<<std::max(1u, (n + 127) / 128), 128>>>(groups, receipts.p, expected, error.p);
        check(cudaGetLastError());
    }
};
template <class T>
std::vector<T> prefix(const Device<T>& device, unsigned count)
{
    require(count <= device.n, "readback prefix exceeds allocation");
    std::vector<T> values(count);
    if (count)
        check(cudaMemcpy(values.data(), device.p, count * sizeof(T), cudaMemcpyDeviceToHost));
    return values;
}
