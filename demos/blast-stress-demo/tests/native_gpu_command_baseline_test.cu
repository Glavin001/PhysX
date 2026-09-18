// Independent rigid transfer and momentum oracle for the correction input join.
#include "ElasticPartitionTestFixture.h"
#include "PxgDestructionElasticCommandBaseline.cuh"
#include "PxgDestructionElasticCommandMotion.cuh"

#include <cstring>
#include <fstream>
#include <limits>
namespace B = physx::destructionElasticCommandBaseline;
namespace M = physx::destructionElasticCommandMotion;
namespace C = physx::destructionElasticCommands;
float bits(uint32_t id)
{
    float f;
    std::memcpy(&f, &id, 4);
    return f;
}
void close(double a, double b)
{
    require(std::isfinite(a) && std::abs(a - b) < 2e-6 * (1 + std::abs(b)), "baseline/momentum oracle");
}
struct BaselineFixture
{
    unsigned n, groups, parents, bodyCount;
    FixturePartition fixture;
    Upload u;
    Device<PxgDestructionCommandInput> commands;
    Device<PxgDestructionCommandInputStatus> commandStatus;
    Device<PxgDestructionInputOwner> owners;
    Device<PxgDestructionInputOwnership> ownership;
    Device<PxgBodySim> bodies;
    Device<double3> centers;
    Device<B::Index> index;
    Device<PxgBodySimVelocities> velocities;
    Device<B::Receipt> receipt;
    std::vector<PxgDestructionCommandInput> command;
    std::vector<PxgDestructionInputOwner> owner;
    std::vector<PxgBodySim> body;
    std::vector<double3> center;
    B::Source source{};
    B::Storage storage{};
    uint64_t generation = 7;
    BaselineFixture(unsigned count, unsigned clusterCount)
        : n(count),
          groups(clusterCount),
          parents(groups / 2),
          bodyCount(2 * parents + 1),
          fixture(n, groups, false),
          u(fixture),
          commands(parents),
          commandStatus(1),
          owners(n),
          ownership(1),
          bodies(bodyCount),
          centers(groups),
          index(bodyCount),
          velocities(groups),
          receipt(1),
          command(parents),
          owner(n),
          body(bodyCount),
          center(groups)
    {
        require(groups % 2 == 0, "paired fixture");
        u.update(fixture, 1);
        u.prepare();
        for (unsigned p = 0; p < parents; ++p)
        {
            const unsigned id = 2 * p + 1;
            auto& b = body[id];
            auto& c = command[p];
            b.linearVelocityXYZ_inverseMassW = { 1.25f, .5f, -.25f, .25f };
            b.angularVelocityXYZ_maxPenBiasW = { .2f, -.3f, .4f, 0 };
            b.body2World.p = make_float4(13 * p, -5, 3, 0);
            b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w = bits(id);
            if (p % 3 != 2)
            {
                c.body = id;
                c.kind = 1;
                c.flags = PxsRigidBody::eHOST_VELOCITY_DELTA_GPU;
                c.linearBefore[0] = 1.25f;
                c.linearBefore[1] = .5f;
                c.linearBefore[2] = -.25f;
                c.angularBefore[0] = .2f;
                c.angularBefore[1] = -.3f;
                c.angularBefore[2] = .4f;
                c.linearDelta[0] = 1e8f;
                c.linearDelta[1] = 2;
                c.linearDelta[2] = 3;
                c.angularDelta[0] = .5f;
                c.angularDelta[1] = .6f;
                c.angularDelta[2] = .7f;
                for (unsigned k = 0; k < 3; ++k)
                {
                    (&b.linearVelocityXYZ_inverseMassW.x)[k] = c.linearBefore[k] + c.linearDelta[k];
                    (&b.angularVelocityXYZ_maxPenBiasW.x)[k] = c.angularBefore[k] + c.angularDelta[k];
                }
            }
            for (unsigned side = 0; side < 2; ++side)
            {
                double sign = side ? 1 : -1;
                center[2 * p + side] = { 13. * p + sign * .5, -5 + sign * .25, 3 - sign * .1 };
            }
        }
        for (unsigned i = 0; i < n; ++i)
        {
            unsigned p = (i % groups) / 2;
            owner[i] = { uint64_t(100 + p), uint32_t(2 * p + 1), uint32_t(2 * p), uint32_t(p), 1 };
        }
        index.put(std::vector<B::Index>(bodyCount));
        commands.put(command);
        owners.put(owner);
        bodies.put(body);
        centers.put(center);
        publish();
        source = { commands.p, commandStatus.p, owners.p, ownership.p, bodies.p, u.state.p,
                   centers.p,  u.identity,      parents,  bodyCount,   n,        groups };
        storage = { index.p, velocities.p, bodyCount, groups };
    }
    void publish()
    {
        commandStatus.put({ { generation, parents, 0 } });
        ownership.put({ { generation, 0, n, bodyCount, 1, 0 } });
    }
    B::Receipt run()
    {
        B::begin<<<1, 1>>>(source, storage, generation, 1, receipt.p);
        B::clearSelected<<<(parents + 127) / 128, 128>>>(source, storage, receipt.p);
        B::indexCommands<<<(parents + 127) / 128, 128>>>(source, storage, receipt.p);
        B::finishIndex<<<1, 1>>>(receipt.p);
        B::resolve<<<groups, 128>>>(source, storage, receipt.p);
        B::finish<<<1, 1>>>(receipt.p);
        check(cudaGetLastError());
        check(cudaDeviceSynchronize());
        return receipt.get()[0];
    }
    void oracle()
    {
        auto values = velocities.get();
        for (unsigned p = 0; p < parents; ++p)
        {
            double totalP[3]{}, totalL[3]{};
            const double v[3] = { 1.25, .5, -.25 }, w[3] = { double(.2f), double(-.3f), double(.4f) };
            const double r[3] = { .5, .25, -.1 };
            double inertia[3][3]{};
            for (unsigned a = 0; a < 3; ++a)
                for (unsigned b = 0; b < 3; ++b)
                    inertia[a][b] = (a == b ? 2 + 4 * (r[0] * r[0] + r[1] * r[1] + r[2] * r[2]) : 0) - 4 * r[a] * r[b];
            for (unsigned side = 0; side < 2; ++side)
            {
                unsigned g = 2 * p + side;
                double x[3] = { center[g].x - 13. * p, center[g].y + 5, center[g].z - 3 };
                double expected[3] = { v[0] + w[1] * x[2] - w[2] * x[1], v[1] + w[2] * x[0] - w[0] * x[2],
                                       v[2] + w[0] * x[1] - w[1] * x[0] };
                for (unsigned k = 0; k < 3; ++k)
                {
                    close((&values[g].linearVelocity.x)[k], expected[k]);
                    close((&values[g].angularVelocity.x)[k], w[k]);
                    totalP[k] += 2 * (&values[g].linearVelocity.x)[k];
                    totalL[k] += (&values[g].angularVelocity.x)[k];
                }
                totalL[0] += 2 * (x[1] * values[g].linearVelocity.z - x[2] * values[g].linearVelocity.y);
                totalL[1] += 2 * (x[2] * values[g].linearVelocity.x - x[0] * values[g].linearVelocity.z);
                totalL[2] += 2 * (x[0] * values[g].linearVelocity.y - x[1] * values[g].linearVelocity.x);
            }
            for (unsigned k = 0; k < 3; ++k)
            {
                close(totalP[k], 4 * v[k]);
                double angular = 0;
                for (unsigned j = 0; j < 3; ++j)
                    angular += inertia[k][j] * w[j];
                close(totalL[k], angular);
            }
        }
    }
};
void failures()
{
    BaselineFixture f(258, 6);
    require(f.run().ready, "initial baseline");
    f.oracle();
    auto original = f.owner;
    f.owner[6].body = 3;
    f.owners.put(f.owner);
    require(f.run().error & 64, "mixed original ancestry accepted");
    f.owner = original;
    f.owners.put(original);
    f.owner[6].slotGeneration++;
    f.owners.put(f.owner);
    require(f.run().error & 64, "mixed original slot lifetime accepted");
    f.owners.put(original);
    auto c = f.command;
    f.command[1] = f.command[0];
    f.commands.put(f.command);
    require(f.run().error & 32, "duplicate original command accepted");
    f.command = c;
    f.commands.put(c);
    auto s = f.commandStatus.get();
    s[0].generation--;
    f.commandStatus.put(s);
    require(f.run().error & 2, "stale history accepted");
    f.publish();
    auto centers = f.center;
    f.center[0].x = std::numeric_limits<double>::quiet_NaN();
    f.centers.put(f.center);
    require(f.run().error & 256, "nonfinite center accepted");
    f.center = centers;
    f.centers.put(centers);
    // New input generation with an empty upload must not use a stale index.
    ++f.generation;
    f.publish();
    s = f.commandStatus.get();
    s[0].count = 0;
    f.commandStatus.put(s);
    require(f.run().ready, "empty refreshed history failed");
    auto result = f.velocities.get();
    require(result[0].linearVelocity.x > 1e7, "stale pre-command baseline survived a new generation");
}
void chain()
{
    BaselineFixture f(2, 2);
    // Align canonical geometry, chunk mass, aggregate COM and native child
    // properties for the complete device handoff (two mass-2 children).
    for (unsigned i = 0; i < 2; ++i)
    {
        const auto c = f.center[i];
        f.fixture.positions[i] = c;
        f.fixture.chunks[i].position = PxVec3(float(c.x), float(c.y), float(c.z));
        f.fixture.chunks[i].mass = 2;
        f.fixture.mass[i] = { { c.x, c.y, c.z }, 2, { 1, 1, 1, 0, 0, 0 }, 0 };
    }
    ++f.u.identity.geometry;
    ++f.u.identity.mass;
    f.u.update(f.fixture, 1);
    f.u.prepare();
    f.source.identity = f.u.identity;
    // Match the parent's trial impulse to the very same spatial force replayed
    // below. I_parent = 2 I + 4 (|r|² I - r rᵀ), r=(-.5,-.25,.1).
    // r×F is perpendicular to r, so its inverse-inertia factor is 1/3.29.
    auto& submitted = f.command[0];
    submitted.linearDelta[0] = .05f;
    submitted.linearDelta[1] = submitted.linearDelta[2] = 0;
    submitted.angularDelta[0] = 0;
    submitted.angularDelta[1] = float(1.2 / (3.29 * 60));
    submitted.angularDelta[2] = float(3 / (3.29 * 60));
    for (unsigned k = 0; k < 3; ++k)
    {
        (&f.body[1].linearVelocityXYZ_inverseMassW.x)[k] = submitted.linearBefore[k] + submitted.linearDelta[k];
        (&f.body[1].angularVelocityXYZ_maxPenBiasW.x)[k] = submitted.angularBefore[k] + submitted.angularDelta[k];
    }
    f.commands.put(f.command);
    f.bodies.put(f.body);
    require(f.run().ready, "baseline chain preparation");
    f.oracle();
    Device<C::Command> command(1);
    Device<C::Batch> batch(1);
    Device<C::Receipt> commandReceipt(1);
    Device<C::Resolved> resolved(1);
    Device<E::Vector> wrench(2);
    Device<L::Motion> motion(2);
    Device<double3> centers(2);
    std::vector<L::Motion> motions(2);
    for (auto& m : motions)
        m.state.orientation[3] = 1;
    motion.put(motions);
    centers.put(f.center);
    command.put({ { f.center[0], { 12, 0, 0 }, { 0, 0, 0 }, 0, C::Units::Force } });
    C::Query query{ 10, 7, 8, 1, 1. / 60, 1, 0 };
    batch.put({ { 10, 7, 8, 1. / 60, 1, 0 } });
    C::Source source{ batch.p, command.p, f.u.state.p, motion.p, centers.p, f.u.identity, 1 };
    C::Storage out{ f.u.compactExtra.p, wrench.p, resolved.p, 2, 2, 1 };
    C::begin<<<1, 1>>>(source, out, query, commandReceipt.p);
    C::clear<<<1, 128>>>(out, commandReceipt.p);
    C::resolve<<<1, 128>>>(source, out, 1e-5, commandReceipt.p);
    C::scatter<<<1, 128>>>(out, commandReceipt.p);
    C::aggregate<<<2, 128>>>(source, out, 1e-5, commandReceipt.p);
    C::inspect<<<1, 128>>>(out, commandReceipt.p);
    C::finish<<<1, 1>>>(commandReceipt.p);
    Device<PxgBodySim> bodies(2);
    Device<PxvPreSolveNode> nodes(2);
    Device<M::Binding> bindings(2);
    Device<M::Candidate> candidate(2);
    Device<uint32_t> claims(2);
    Device<M::History> history(1);
    Device<M::Receipt> receipt(1);
    std::vector<PxgBodySim> bs(2);
    for (unsigned i = 0; i < 2; ++i)
    {
        const auto v = f.body[1].linearVelocityXYZ_inverseMassW, w = f.body[1].angularVelocityXYZ_maxPenBiasW;
        const double x = f.center[i].x, y = f.center[i].y + 5, z = f.center[i].z - 3;
        bs[i].linearVelocityXYZ_inverseMassW = { float(v.x + w.y * z - w.z * y), float(v.y + w.z * x - w.x * z),
                                                 float(v.z + w.x * y - w.y * x), .5f };
        bs[i].angularVelocityXYZ_maxPenBiasW = { w.x, w.y, w.z, 19 };
        bs[i].inverseInertiaXYZ_contactReportThresholdW = { 1, 1, 1, 0 };
        bs[i].body2World.q = PxAlignedQuat(0, 0, 0, 1);
        bs[i].body2World.p = make_float4(float(f.center[i].x), float(f.center[i].y), float(f.center[i].z), 0);
        bs[i].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w = bits(i);
    }
    bodies.put(bs);
    nodes.put({ { 20, 0, 1 }, { 21, 0, 1 } });
    bindings.put({ { 20, 0, 0 }, { 21, 1, 0 } });
    auto trial = query;
    trial.evaluation = 0;
    history.put({ { trial, 1, 1, 0 } });
    M::Source input{ commandReceipt.p, wrench.p, bindings.p, nodes.p, bodies.p, 2, 2, f.receipt.p, f.velocities.p };
    M::Storage storage{ candidate.p, claims.p, 2 };
    auto apply = [&]
    {
        M::begin<<<1, 1>>>(input, storage, query, 2, history.p, receipt.p);
        M::clearClaims<<<1, 128>>>(input, storage, receipt.p);
        M::prepare<<<1, 128>>>(input, storage, receipt.p);
        M::seal<<<1, 1>>>(receipt.p);
        M::apply<<<1, 128>>>(input, storage, receipt.p);
        M::commit<<<1, 1>>>(receipt.p, history.p);
        check(cudaGetLastError());
        check(cudaDeviceSynchronize());
        return receipt.get()[0];
    };
    require(apply().ready, "device baseline/command/motion chain");
    auto result = bodies.get();
    auto base = f.velocities.get();
    for (unsigned i = 0; i < 2; ++i)
        for (unsigned k = 0; k < 3; ++k)
        {
            close((&result[i].linearVelocityXYZ_inverseMassW.x)[k],
                  (&base[i].linearVelocity.x)[k] + (i == 0 && k == 0 ? .1 : 0));
            close((&result[i].angularVelocityXYZ_maxPenBiasW.x)[k], (&base[i].angularVelocity.x)[k]);
        }
    // Total replay momentum change equals the parent's trial force impulse
    // and its moment about the original COM; no command is cloned to child 1.
    double dp[3]{}, dl[3]{};
    for (unsigned i = 0; i < 2; ++i)
    {
        double d[3];
        for (unsigned k = 0; k < 3; ++k)
        {
            d[k] = 2 * (double((&result[i].linearVelocityXYZ_inverseMassW.x)[k]) - (&base[i].linearVelocity.x)[k]);
            dp[k] += d[k];
        }
        const double x = f.center[i].x, y = f.center[i].y + 5, z = f.center[i].z - 3;
        dl[0] += y * d[2] - z * d[1];
        dl[1] += z * d[0] - x * d[2];
        dl[2] += x * d[1] - y * d[0];
    }
    close(dp[0], .2);
    close(dp[1], 0);
    close(dp[2], 0);
    close(dl[0], 0);
    close(dl[1], .02);
    close(dl[2], .05);
    require(apply().duplicate, "chain duplicate replay");
    auto bad = f.receipt.get();
    bad[0].inputGeneration--;
    f.receipt.put(bad);
    require(apply().error, "stale baseline accepted");
    auto unchanged = bodies.get();
    require(!std::memcmp(result.data(), unchanged.data(), result.size() * sizeof(result[0])),
            "stale baseline mutated motion");
}
int main(int argc, char** argv)
{
    try
    {
        if (argc == 1)
        {
            failures();
            chain();
        }
        BaselineFixture f(argc > 1 ? 113664 : 774, argc > 1 ? 512 : 6);
        require(f.run().ready, "baseline fixture failed");
        f.oracle();
        if (argc > 2)
        {
            auto v = f.velocities.get();
            std::ofstream out(argv[2], std::ios::binary);
            out.write(reinterpret_cast<const char*>(v.data()), v.size() * sizeof(v[0]));
            require(bool(out), "output");
        }
        std::printf(
            "command baseline: %u authored chunks, %u children, %u original parents; independent transfer/momentum passed; adversarial/device chain=%s\n",
            f.n, f.groups, f.parents, argc == 1 ? "passed" : "not run");
        return 0;
    }
    catch (const std::exception& e)
    {
        std::fprintf(stderr, "%s\n", e.what());
        return 1;
    }
}
