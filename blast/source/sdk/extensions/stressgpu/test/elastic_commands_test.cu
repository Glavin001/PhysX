// SPDX-License-Identifier: BSD-3-Clause
#include "ElasticPartitionTestFixture.h"
#include "PxgDestructionElasticCommands.cuh"

#include <fstream>
#include <limits>
namespace C = physx::destructionElasticCommands;
using V = std::array<double, 3>;
V add(V a, V b)
{
    return { a[0] + b[0], a[1] + b[1], a[2] + b[2] };
}
V sub(V a, V b)
{
    return { a[0] - b[0], a[1] - b[1], a[2] - b[2] };
}
V mul(V a, double s)
{
    return { a[0] * s, a[1] * s, a[2] * s };
}
V cross(V a, V b)
{
    return { a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0] };
}
V vec(double3 a)
{
    return { a.x, a.y, a.z };
}
V vec(const double* a)
{
    return { a[0], a[1], a[2] };
}
double3 point(V a)
{
    return { a[0], a[1], a[2] };
}
// Independent explicit rotation matrix, not the device quaternion formula.
V rotate(const double* q, V a, bool transpose = false)
{
    const double n = q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3];
    const double x = q[0] / sqrt(n), y = q[1] / sqrt(n), z = q[2] / sqrt(n), w = q[3] / sqrt(n);
    const double r[9] = { 1 - 2 * (y * y + z * z), 2 * (x * y - z * w),     2 * (x * z + y * w),
                          2 * (x * y + z * w),     1 - 2 * (x * x + z * z), 2 * (y * z - x * w),
                          2 * (x * z - y * w),     2 * (y * z + x * w),     1 - 2 * (x * x + y * y) };
    V out{};
    for (unsigned i = 0; i < 3; ++i)
        for (unsigned j = 0; j < 3; ++j)
            out[i] += r[transpose ? 3 * j + i : 3 * i + j] * a[j];
    return out;
}
struct Commands
{
    FixturePartition fixture;
    Upload u;
    Device<C::Command> commands;
    Device<C::Batch> batch;
    Device<C::Receipt> receipt;
    Device<C::Resolved> resolved;
    Device<E::Vector> body;
    Device<double3> centers;
    std::vector<L::Motion> motion;
    std::vector<double3> center;
    std::vector<C::Command> rows;
    C::Query query{ 9, 20, 30, 1, .02, 0, 0 };
    C::Source source{};
    C::Storage output{};
    Commands(unsigned n, unsigned groups, bool sparse)
        : fixture(n, groups, sparse),
          u(fixture),
          commands(3 * n),
          batch(1),
          receipt(1),
          resolved(3 * n),
          body(n),
          centers(n),
          motion(n),
          center(n)
    {
        u.update(fixture, 1);
        u.prepare();
        for (unsigned g = 0; g < groups; ++g)
        {
            auto& m = motion[g];
            m.state.orientation[0] = sin(.07 * g);
            m.state.orientation[3] = cos(.07 * g);
            m.state.origin[0] = g * 31;
            m.state.origin[1] = g * 13;
            m.state.origin[2] = -7;
            m.mode = L::MotionMode::CompleteFreeWrench;
        }
        updateCenters();
        source = { batch.p, commands.p, u.state.p, u.motions.p, centers.p, u.identity, unsigned(commands.n) };
        output = { u.compactExtra.p, body.p, resolved.p, n, n, unsigned(commands.n) };
    }
    void updateCenters()
    {
        std::fill(center.begin(), center.end(), double3{});
        std::vector<unsigned> count(fixture.n);
        for (unsigned i = 0; i < fixture.n; ++i)
            if (fixture.active[i])
            {
                auto g = fixture.chunks[i].cluster;
                center[g] = point(add(vec(center[g]), vec(fixture.positions[i])));
                ++count[g];
            }
        for (unsigned g = 0; g < fixture.groups; ++g)
            center[g] = point(mul(vec(center[g]), 1. / count[g]));
        centers.put(center);
        u.motions.put(motion);
    }
    void upload()
    {
        auto all = rows;
        all.resize(commands.n);
        commands.put(all);
        batch.put(
            { { query.tick, query.inputGeneration, query.commandGeneration, query.seconds, unsigned(rows.size()), 0 } });
    }
    void launch()
    {
        C::begin<<<1, 1>>>(source, output, query, receipt.p);
        C::clear<<<(fixture.n + 127) / 128, 128>>>(output, receipt.p);
        C::resolve<<<(commands.n + 127) / 128, 128>>>(source, output, 1e-6, receipt.p);
        C::scatter<<<(commands.n + 127) / 128, 128>>>(output, receipt.p);
        C::aggregate<<<fixture.groups, 128>>>(source, output, 1e-6, receipt.p);
        C::inspect<<<(fixture.n + 127) / 128, 128>>>(output, receipt.p);
        C::finish<<<1, 1>>>(receipt.p);
        check(cudaGetLastError());
    }
    void gate(C::Query expected, bool success)
    {
        u.error.put({ 0 });
        C::gate<<<1, 1>>>(receipt.p, expected, u.error.p);
        require((u.error.get()[0] == 0) == success, "command consumer gate");
    }
    void verify()
    {
        std::cerr.precision(17);
        auto r = receipt.get()[0];
        require(r.ready && !r.error, "command evaluation rejected");
        gate(query, true);
        auto map = u.authorToFine.get();
        std::vector<E::Vector> node(r.nodes);
        std::vector<std::array<long double, 6>> aggregate(fixture.groups);
        for (const auto& c : rows)
        {
            unsigned g = fixture.chunks[c.chunk].cluster;
            const auto& m = motion[g].state;
            double scale = c.units == C::Units::Impulse ? 1 / query.seconds : 1;
            V f = mul(vec(c.force), scale), t = mul(vec(c.couple), scale);
            V x = add(vec(m.origin), rotate(m.orientation, vec(fixture.positions[c.chunk])));
            V fn = rotate(m.orientation, f, true),
              tn = rotate(m.orientation, add(t, cross(sub(vec(c.point), x), f)), true);
            // Wide independent oracle avoids cancellation in the reference
            // when a long aggregate's opposing large moments nearly cancel.
            const auto* q = m.orientation;
            const long double qx = q[0], qy = q[1], qz = q[2], qw = q[3];
            const long double norm = qx * qx + qy * qy + qz * qz + qw * qw;
            const long double rotation[9] = { 1 - 2 * (qy * qy + qz * qz) / norm, 2 * (qx * qy - qz * qw) / norm,
                                              2 * (qx * qz + qy * qw) / norm,     2 * (qx * qy + qz * qw) / norm,
                                              1 - 2 * (qx * qx + qz * qz) / norm, 2 * (qy * qz - qx * qw) / norm,
                                              2 * (qx * qz - qy * qw) / norm,     2 * (qy * qz + qx * qw) / norm,
                                              1 - 2 * (qx * qx + qy * qy) / norm };
            const auto ctr = vec(center[g]), worldPoint = vec(c.point), worldForce = vec(c.force),
                       worldCouple = vec(c.couple);
            const long double exactScale = c.units == C::Units::Impulse ? 1.L / query.seconds : 1.L;
            long double arm[3]{}, wf[3]{}, wt[3]{};
            for (unsigned k = 0; k < 3; ++k)
            {
                arm[k] = static_cast<long double>(worldPoint[k]) - m.origin[k];
                for (unsigned j = 0; j < 3; ++j)
                    arm[k] -= rotation[3 * k + j] * ctr[j];
                wf[k] = worldForce[k] * exactScale;
                wt[k] = worldCouple[k] * exactScale;
            }
            for (unsigned k = 0; k < 3; ++k)
            {
                node[map[c.chunk]].v[k] += fn[k];
                node[map[c.chunk]].v[k + 3] += tn[k];
                aggregate[g][k] += wf[k];
                aggregate[g][k + 3] += wt[k] + arm[(k + 1) % 3] * wf[(k + 2) % 3] - arm[(k + 2) % 3] * wf[(k + 1) % 3];
            }
        }
        auto actual = prefix(u.compactExtra, r.nodes), b = prefix(body, fixture.groups);
        for (unsigned i = 0; i < r.nodes; ++i)
            for (unsigned k = 0; k < 6; ++k)
                near(actual[i].v[k], node[i].v[k], "chunk wrench oracle");
        for (unsigned g = 0; g < fixture.groups; ++g)
            for (unsigned k = 0; k < 6; ++k)
            {
                try
                {
                    near(b[g].v[k], double(aggregate[g][k]), "body wrench oracle");
                }
                catch (...)
                {
                    std::cerr << "group " << g << " channel " << k << '\n';
                    throw;
                }
            }
    }
    void adapter()
    {
        const L::Interval interval{ { query.tick, query.inputGeneration, query.ownershipGeneration, query.evaluation, 1 },
                                    query.seconds };
        u.interval.put({ interval });
        u.error.put({ 0 });
        C::gate<<<1, 1>>>(receipt.p, query, u.error.p);
        // Completeness here is only the fixture's declared command-only/free
        // body model. It is not a certification of a native scene ledger.
        check(cudaMemset(u.compactSurface.p, 0, fixture.n * sizeof(PxDestructionSurfaceLoad)));
        const L::Inputs in{ u.compactPositions.p, u.compactChunks.p, u.compactMass.p, u.compactSurface.p,
                            u.compactExtra.p,     u.motions.p,       u.interval.p,    { 0, 0, 0 } };
        const L::DeviceGroups groups{ &u.state.p->groups };
        const L::Profile profile{ 1e-6, 1e-14, 1e-11, 1e-11, 1e-11, 1e-11 };
        L::validate<<<(fixture.n + 127) / 128, 128>>>(groups, in, profile, u.error.p);
        L::build<<<fixture.groups, 128>>>(groups, in, interval, profile, u.error.p, u.effective.p, u.receipts.p);
        L::gate<<<(fixture.groups + 127) / 128, 128>>>(groups, u.receipts.p, interval, u.error.p);
        require(!u.error.get()[0], "command-to-load-adapter handoff");
    }
};
void large(const std::string& destination)
{
    Commands c(113664, 256, false);
    for (unsigned i = 0; i < c.fixture.n; ++i)
    {
        const auto& m = c.motion[c.fixture.chunks[i].cluster].state;
        auto p = add(vec(m.origin), rotate(m.orientation, add(vec(c.fixture.positions[i]), V{ .3, -.2, .1 })));
        c.rows.push_back(
            { point(p), { .01 * (i % 13), -.03, .07 }, { .02, .01, -.03 }, i, i % 2 ? C::Units::Force : C::Units::Impulse });
    }
    c.upload();
    c.launch();
    c.verify();
    const auto r = c.receipt.get()[0];
    auto save = [&](const std::string& suffix, const Device<E::Vector>& data, unsigned count)
    {
        auto values = prefix(data, count);
        std::ofstream stream(destination + suffix, std::ios::binary);
        stream.write(reinterpret_cast<const char*>(values.data()), values.size() * sizeof(E::Vector));
        require(bool(stream), "command output write");
    };
    save(".chunks.bin", c.u.compactExtra, r.nodes);
    save(".bodies.bin", c.body, r.groups);
    std::cout
        << "synthetic command batch: 113664 active chunks, 256 motion groups, 113664 commands; independent oracles passed\n";
}
int main(int argc, char** argv)
{
    try
    {
        if (argc > 1)
        {
            require(argc == 3 && std::string(argv[1]) == "--large", "expected --large output-prefix");
            large(argv[2]);
            return 0;
        }
        Commands c(137, 7, true);
        for (unsigned i = 0; i < c.fixture.n; ++i)
            if (c.fixture.active[i])
            {
                auto g = c.fixture.chunks[i].cluster;
                const auto& m = c.motion[g].state;
                auto p = add(vec(m.origin), rotate(m.orientation, add(vec(c.fixture.positions[i]), V{ .3, -.2, .1 })));
                c.rows.push_back({ point(p), { .01 * i, -.03, .07 }, { .02, .01, -.03 }, i, C::Units::Force });
                c.rows.push_back({ point(p), { -.001, .002, .003 }, { .001, -.002, .003 }, i, C::Units::Impulse });
            }
        c.upload();
        c.launch();
        c.verify();
        c.adapter();
        c.launch();
        c.verify(); // pure replay, no duplication
        auto old = c.query;
        auto bad = old;
        bad.commandGeneration++;
        c.gate(bad, false);
        c.query = bad;
        c.launch();
        require(!c.receipt.get()[0].ready, "stale batch admitted");
        c.query = old;
        c.query.ownershipGeneration++;
        c.launch();
        require(!c.receipt.get()[0].ready, "stale partition admitted");
        c.query = old;
        // Split each group into two children; the same authored command tape follows
        // current ownership without duplicating a parent's aggregate wrench.
        c.fixture = FixturePartition(137, 14, true);
        c.u.update(c.fixture, 2);
        c.u.prepare();
        for (unsigned g = 7; g < 14; ++g)
            c.motion[g] = c.motion[g - 7];
        c.updateCenters();
        c.query.ownershipGeneration = 2;
        c.query.evaluation = 1;
        c.launch();
        c.verify();
        c.adapter();
        auto saved = c.rows;
        auto reject = [&]
        {
            c.upload();
            c.launch();
            require(!c.receipt.get()[0].ready && c.receipt.get()[0].error, "invalid command admitted");
            c.gate(c.query, false);
            c.rows = saved;
        };
        c.rows[0].chunk = 1;
        reject(); // inactive authored chunk
        c.rows[0].chunk = 137;
        reject();
        c.rows[0].units = C::Units(99);
        reject();
        c.rows[0].force.x = std::numeric_limits<double>::quiet_NaN();
        reject();
        c.upload();
        c.output.commands = 1;
        c.launch();
        require(!c.receipt.get()[0].ready, "undersized command storage admitted");
        c.output.commands = c.commands.n;
        auto m = c.motion;
        c.motion[0].state.orientation[3] = 4;
        c.u.motions.put(c.motion);
        c.launch();
        require(!c.receipt.get()[0].ready, "invalid frame admitted");
        c.motion = m;
        c.u.motions.put(m);
        c.rows.clear();
        c.upload();
        c.launch();
        c.verify(); // explicit expiration/removal
        // Equal/opposite axial loads have zero aggregate wrench but nonzero internal
        // load. Recovering only the body's net acceleration would lose this case.
        Commands axial(2, 1, false);
        V direction = sub(vec(axial.fixture.positions[1]), vec(axial.fixture.positions[0]));
        for (unsigned i = 0; i < 2; ++i)
        {
            auto p = add(vec(axial.motion[0].state.origin), vec(axial.fixture.positions[i]));
            axial.rows.push_back({ point(p), point(mul(direction, i ? -1 : 1)), {}, i, C::Units::Force });
        }
        axial.upload();
        axial.launch();
        axial.verify();
        axial.adapter();
        auto b = prefix(axial.body, 1);
        for (double x : b[0].v)
            near(x, 0, "axial body net wrench");
        auto effective = prefix(axial.u.effective, 2);
        near(effective[0].v[0], direction[0], "zero-net load lost internal force");
        // Finite individual commands can overflow when summed: do not publish them.
        axial.rows[0].force = { 1e308, 0, 0 };
        axial.rows[1] = axial.rows[0];
        axial.upload();
        axial.launch();
        require(!axial.receipt.get()[0].ready, "accumulation overflow admitted");
        std::cout
            << "commands: independent wrench oracles, split replay, zero-net stress, expiration, stale/invalid inputs and adapter handoff passed\n";
        return 0;
    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << '\n';
        return 1;
    }
}
