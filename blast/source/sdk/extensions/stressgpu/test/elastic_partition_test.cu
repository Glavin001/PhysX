#include "ElasticPartitionTestFixture.h"

void verify(Upload& u, const FixturePartition& f)
{
    const auto s = u.state.get()[0];
    require(s.status == P::Status::Ready && !s.error, "partition not ready");
    const unsigned live = std::count(f.active.begin(), f.active.end(), 1u);
    require(s.groups.nodes == live && s.groups.count == f.groups, "wrong GPU counts");
    const auto forward = prefix(u.fineToAuthor, live), inverse = u.authorToFine.get(),
               starts = prefix(u.starts, f.groups + 1), local = prefix(u.local, live);
    const auto positions = prefix(u.compactPositions, live);
    const auto chunks = prefix(u.compactChunks, live);
    const auto mass = prefix(u.compactMass, live);
    for (unsigned i = 0; i < f.n; ++i)
    {
        if (!f.active[i])
        {
            require(inverse[i] == P::Invalid, "inactive chunk retained");
            continue;
        }
        const auto j = inverse[i], g = f.chunks[i].cluster;
        require(j < live && forward[j] == i && f.order[j] == i, "mapping not bijective");
        require(starts[g] + local[j] == j && j < starts[g + 1], "wrong group range");
        require(positions[j].x == f.positions[i].x && positions[j].y == f.positions[i].y &&
                    positions[j].z == f.positions[i].z,
                "canonical position changed");
        require(chunks[j].cluster == g && mass[j].mass == f.mass[i].mass, "physical data mismatch");
    }
}
int main()
{
    try
    {
        for (auto n : { 137u, 521u })
        {
            FixturePartition f(n, 7, true);
            Upload u(f);
            u.prepare();
            verify(u, f);
            require(u.state.get()[0].builds == 1, "initial build count");
            u.prepare();
            verify(u, f);
            require(!u.state.get()[0].rebuild && u.state.get()[0].builds == 1, "idle rebuilt partition");
            const L::Interval load{ { 1, 1, 0, 0, 1 }, 1. / 60 };
            u.consume(load);
            require(!u.error.get()[0], "GPU-count adapter rejected sparse partition");
            const auto values = prefix(u.effective, u.state.get()[0].groups.nodes);
            for (unsigned j = 0; j < u.state.get()[0].groups.nodes; ++j)
                for (double x : values[j].v)
                    require(x == 0, "zero-load replay changed");
            std::vector<PxDestructionSurfaceLoad> channels(n);
            std::vector<E::Vector> extra(n);
            for (unsigned i = 0; i < n; ++i)
            {
                channels[i].force.x = float(i + 1);
                extra[i].v[4] = i + .5;
            }
            u.surface.put(channels);
            u.extra.put(extra);
            u.error.put({ 0 });
            P::scatter<<<(n + 127) / 128, 128>>>(
                u.state.p, u.storage, u.surface.p, u.extra.p, u.compactSurface.p, u.compactExtra.p, u.error.p);
            const auto copied = prefix(u.compactSurface, u.state.get()[0].groups.nodes);
            const auto applied = prefix(u.compactExtra, u.state.get()[0].groups.nodes);
            const auto s = u.state.get()[0];
            for (unsigned j = 0; j < s.groups.nodes; ++j)
            {
                require(copied[j].force.x == channels[f.order[j]].force.x, "surface mapped to wrong chunk");
                require(applied[j].v[4] == extra[f.order[j]].v[4], "command mapped to wrong chunk");
            }
            f.positions[0].x += .125;
            u.positions.put(f.positions);
            ++u.identity.geometry;
            u.prepare();
            verify(u, f);
            require(u.state.get()[0].builds == 2, "geometry revision not rebuilt");
            // Replacing any retained output allocation invalidates reuse too.
            Device<double3> replacement(n);
            u.storage.positions = replacement.p;
            u.prepare();
            require(u.state.get()[0].builds == 3, "output storage replacement reused old data");
            u.storage.positions = u.compactPositions.p;
            u.prepare();
            verify(u, f);
            FixturePartition split(n, 11, true);
            u.update(split, 1);
            u.prepare();
            verify(u, split);
            auto wrong = split.order;
            wrong[1] = wrong[0];
            u.order.put(wrong);
            auto status = u.topologyStatus.get();
            ++status[0].generation;
            u.topologyStatus.put(status);
            u.prepare();
            require(u.state.get()[0].status == P::Status::InvalidInput, "duplicate membership accepted");
            u.consume(load);
            require(u.error.get()[0], "failed partition became accepted loads");
            u.update(split, 3);
            u.prepare();
            verify(u, split);
            status = u.topologyStatus.get();
            ++status[0].generation;
            u.topologyStatus.put(status);
            u.consume(load);
            require(u.error.get()[0], "stale topology consumed");
            u.prepare();
            verify(u, split);
            u.storage.capacity = n - 1;
            u.prepare();
            require(u.state.get()[0].status == P::Status::InvalidInput, "truncated storage accepted");
        }
        FixturePartition removed(137, 7, true);
        removed.groups = 0;
        removed.roots.clear();
        removed.active.assign(137, 0);
        removed.root.assign(137, P::Invalid);
        Upload noActive(removed);
        noActive.prepare();
        verify(noActive, removed);
        noActive.consume({ { 1, 1, 0, 0, 1 }, 1. / 60 });
        require(!noActive.error.get()[0], "all-deleted active layout rejected");
        FixturePartition reused(137, 7, true);
        Upload slotCheck(reused);
        slotCheck.prepare();
        reused.slotGeneration[reused.rootSlot[reused.roots[0]]] = 0;
        slotCheck.update(reused, 1);
        slotCheck.prepare();
        require(slotCheck.state.get()[0].status == P::Status::InvalidInput, "invalid live slot generation accepted");
        reused.slotGeneration[reused.rootSlot[reused.roots[0]]] = 2;
        slotCheck.update(reused, 2);
        slotCheck.prepare();
        verify(slotCheck, reused);
        auto invalidTopology = slotCheck.topologyStatus.get();
        invalidTopology[0].slotError = 1;
        slotCheck.topologyStatus.put(invalidTopology);
        slotCheck.prepare();
        require(slotCheck.state.get()[0].status == P::Status::InvalidInput, "topology producer error hidden by cache");
        invalidTopology[0].slotError = 0;
        invalidTopology[0].clusterCount = reused.n + 1;
        slotCheck.topologyStatus.put(invalidTopology);
        slotCheck.prepare();
        slotCheck.consume({ { 1, 1, 2, 0, 1 }, 1. / 60 });
        require(slotCheck.error.get()[0] && slotCheck.state.get()[0].groups.count == 0,
                "invalid topology count exposed out-of-capacity entries");
        FixturePartition empty(0, 0, false);
        Upload zero(empty);
        zero.prepare();
        verify(zero, empty);
        zero.consume({ { 1, 1, 0, 0, 1 }, 1. / 60 });
        require(!zero.error.get()[0], "empty scene rejected");
        zero.identity.scene = 0;
        zero.prepare();
        zero.consume({ { 1, 1, 0, 0, 1 }, 1. / 60 });
        require(zero.error.get()[0], "empty invalid producer escaped gate");
        check(cudaDeviceSynchronize());
        std::cout
            << "PASS GPU topology partition: sparse/empty layouts, canonical data, retained reuse, splits, stale/invalid mapping rejection, device-count load handoff\n";
    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << '\n';
        return 1;
    }
}
