// GPU command-motion transaction: real native storage, independent CPU oracle.
// Standalone kernel validation, not scene-level command/correction qualification.
#include "ElasticPartitionTestFixture.h"
#include "PxgDestructionElasticCommandMotion.cuh"

#include <cstring>
#include <fstream>
#include <limits>
namespace M = physx::destructionElasticCommandMotion;
namespace C = physx::destructionElasticCommands;
using namespace physx;
float bits(uint32_t v)
{
    float f;
    std::memcpy(&f, &v, 4);
    return f;
}
template <class T>
bool identical(const std::vector<T>& a, const std::vector<T>& b)
{
    return a.size() == b.size() && !std::memcmp(a.data(), b.data(), a.size() * sizeof(T));
}
void nativeNear(double a, double b)
{
    require(std::isfinite(a) && std::abs(a - b) < 2e-6 * (1 + std::abs(b)), "native velocity oracle");
}
struct MotionFixture
{
    unsigned n, capacity;
    Device<PxgBodySim> bodies;
    Device<PxvPreSolveNode> nodes;
    Device<M::Binding> bindings;
    Device<E::Vector> loads;
    Device<M::Candidate> candidates;
    Device<uint32_t> claims;
    Device<C::Receipt> commands;
    Device<M::Receipt> receipt;
    Device<M::History> history;
    std::vector<PxgBodySim> original;
    std::vector<PxvPreSolveNode> owners;
    std::vector<M::Binding> mapping;
    std::vector<E::Vector> forces;
    C::Query query{ 9, 20, 30, 1, 1.0 / 60, 0, 0 };
    M::Source in{};
    M::Storage out{};
    MotionFixture(unsigned count)
        : n(count),
          capacity(2 * count + 3),
          bodies(capacity),
          nodes(capacity),
          bindings(n),
          loads(n),
          candidates(n),
          claims(capacity),
          commands(1),
          receipt(1),
          history(1),
          original(capacity),
          owners(capacity),
          mapping(n),
          forces(n)
    {
        for (unsigned i = 0; i < capacity; ++i)
        {
            auto& b = original[i];
            b.linearVelocityXYZ_inverseMassW = { .1f, -.2f, .3f, .5f };
            b.angularVelocityXYZ_maxPenBiasW = { -.3f, .2f, .1f, 17 };
            b.inverseInertiaXYZ_contactReportThresholdW = { .3f, .4f, .5f, 19 };
            b.externalLinearAcceleration = { 4, 5, 6, 0 };
            b.externalAngularAcceleration = { 7, 8, 9, 0 };
            b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w = bits(i);
            const float a = sinf(.013f * i) / sqrtf(14.f);
            b.body2World.q = PxAlignedQuat(a, 2 * a, 3 * a, cosf(.013f * i));
            b.body2World.p = make_float4(float(i), 7, 9, 0);
            owners[i] = { uint64_t(100 + i), 0, 1 };
        }
        for (unsigned g = 0; g < n; ++g)
        {
            unsigned id = 2 * g + 1;
            mapping[g] = { owners[id].lifetime, id, 0 };
            if (g % 17 == 0)
            {
                mapping[g].supported = 1;
                original[id].linearVelocityXYZ_inverseMassW.w = 0;
                original[id].inverseInertiaXYZ_contactReportThresholdW = { 0, 0, 0, 19 };
            }
            if (g == 1)
                original[id].linearVelocityXYZ_inverseMassW.w = 0; // infinite translation mass, finite rotational
                                                                   // inertia
            for (unsigned k = 0; k < 6; ++k)
                forces[g].v[k] = .07 * (g + 1) * (k + 1) * (k % 2 ? -1 : 1);
        }
        bodies.put(original);
        nodes.put(owners);
        bindings.put(mapping);
        loads.put(forces);
        history.put({ {} });
        in = { commands.p, loads.p, bindings.p, nodes.p, bodies.p, n, capacity };
        out = { candidates.p, claims.p, n };
        publish();
    }
    void publish()
    {
        C::Receipt c{};
        c.query = query;
        c.groups = n;
        c.count = n;
        c.nodes = n;
        c.inputValid = c.ready = 1;
        commands.put({ c });
    }
    M::Receipt run(uint64_t epoch)
    {
        M::begin<<<1, 1>>>(in, out, query, epoch, history.p, receipt.p);
        M::clearClaims<<<(n + 127) / 128, 128>>>(in, out, receipt.p);
        M::prepare<<<(n + 127) / 128, 128>>>(in, out, receipt.p);
        M::seal<<<1, 1>>>(receipt.p);
        M::apply<<<(n + 127) / 128, 128>>>(in, out, receipt.p);
        M::commit<<<1, 1>>>(receipt.p, history.p);
        check(cudaGetLastError());
        check(cudaDeviceSynchronize());
        return receipt.get()[0];
    }
    void oracle(const std::vector<PxgBodySim>& base, const std::vector<E::Vector>& f)
    {
        auto actual = bodies.get(), expected = base;
        for (unsigned g = 0; g < n; ++g)
        {
            auto id = mapping[g].body;
            const auto& b = base[id];
            const auto q = b.body2World.q.q;
            double norm = double(q.x) * q.x + double(q.y) * q.y + double(q.z) * q.z + double(q.w) * q.w;
            double x = q.x / sqrt(norm), y = q.y / sqrt(norm), z = q.z / sqrt(norm), w = q.w / sqrt(norm);
            double r[9] = { 1 - 2 * (y * y + z * z), 2 * (x * y - z * w),     2 * (x * z + y * w),
                            2 * (x * y + z * w),     1 - 2 * (x * x + z * z), 2 * (y * z - x * w),
                            2 * (x * z - y * w),     2 * (y * z + x * w),     1 - 2 * (x * x + y * y) };
            double inv[3] = { b.inverseInertiaXYZ_contactReportThresholdW.x,
                              b.inverseInertiaXYZ_contactReportThresholdW.y,
                              b.inverseInertiaXYZ_contactReportThresholdW.z };
            double angular[3]{};
            for (unsigned a = 0; a < 3; ++a)
                for (unsigned k = 0; k < 3; ++k)
                    for (unsigned j = 0; j < 3; ++j)
                        angular[a] += r[3 * a + k] * inv[k] * r[3 * j + k] * f[g].v[3 + j];
            const float* beforeV = &b.linearVelocityXYZ_inverseMassW.x;
            const float* beforeW = &b.angularVelocityXYZ_maxPenBiasW.x;
            for (unsigned k = 0; k < 3; ++k)
            {
                const double v =
                    beforeV[k] +
                    (!mapping[g].supported ? float(f[g].v[k] * b.linearVelocityXYZ_inverseMassW.w * query.seconds) : 0);
                const double spin = beforeW[k] + (!mapping[g].supported ? float(angular[k] * query.seconds) : 0);
                nativeNear((&actual[id].linearVelocityXYZ_inverseMassW.x)[k], v);
                nativeNear((&actual[id].angularVelocityXYZ_maxPenBiasW.x)[k], spin);
            }
            expected[id].linearVelocityXYZ_inverseMassW = actual[id].linearVelocityXYZ_inverseMassW;
            expected[id].angularVelocityXYZ_maxPenBiasW = actual[id].angularVelocityXYZ_maxPenBiasW;
        }
        require(identical(expected, actual), "command modified unrelated native state/slot");
    }
};
void rejectCases()
{
    MotionFixture f(9);
    const auto reject = [&]
    {
        auto before = f.bodies.get();
        auto history = f.history.get();
        auto r = f.run(1);
        require(r.error && !r.ready, "bad motion transaction accepted");
        require(identical(before, f.bodies.get()) && identical(history, f.history.get()),
                "rejection partially mutated native state/history");
    };
    f.mapping[8] = f.mapping[0];
    f.bindings.put(f.mapping);
    reject();
    f.mapping[8] = { f.owners[17].lifetime, 17, 0 };
    f.mapping[8].lifetime++;
    f.bindings.put(f.mapping);
    reject();
    f.mapping[8].lifetime--;
    auto valid = f.mapping[8];
    f.mapping[8].body = f.capacity;
    f.bindings.put(f.mapping);
    reject();
    f.mapping[8] = valid;
    f.bindings.put(f.mapping);
    auto forces = f.forces;
    f.forces[8].v[0] = std::numeric_limits<double>::infinity();
    f.loads.put(f.forces);
    reject();
    f.forces = forces;
    f.forces[8].v[0] = 1e300;
    f.loads.put(f.forces);
    reject();
    f.forces = forces;
    f.loads.put(f.forces);
    auto original = f.original;
    f.original[17].body2World.q.q.w = 2;
    f.bodies.put(f.original);
    reject();
    f.original = original;
    f.bodies.put(original);
    f.owners[17].live = 0;
    f.nodes.put(f.owners);
    reject();
    f.owners[17].live = 1;
    f.nodes.put(f.owners);
    f.query.evaluation = 1;
    f.publish();
    reject();
    f.query.evaluation = 0;
    f.publish();
    auto c = f.commands.get();
    c[0].ready = 0;
    f.commands.put(c);
    reject();
    f.publish();
    require(f.run(1).ready, "recovery from rejected input failed");
    f.oracle(f.original, f.forces);
    auto saved = f.bodies.get();
    auto h = f.history.get();
    auto r = f.run(1);
    require(r.duplicate && !r.error && !r.ready, "duplicate application not rejected as no-op");
    require(identical(saved, f.bodies.get()), "duplicate changed velocity");
    r = f.run(2);
    require(r.error && !r.ready && identical(saved, f.bodies.get()), "same evaluation reapplied on a new epoch");
    // A corrected evaluation consumes explicitly rewound/current child state,
    // not the velocities already modified by the first application.
    f.bodies.put(f.original);
    f.query.evaluation = 1;
    f.query.ownershipGeneration++;
    f.publish();
    require(f.run(2).ready, "corrected input epoch rejected");
    f.oracle(f.original, f.forces);
    saved = f.bodies.get();
    require(f.run(2).duplicate && identical(saved, f.bodies.get()), "correction reapplied");
    f.query.tick++;
    f.query.inputGeneration++;
    f.query.commandGeneration++;
    f.query.evaluation = 0;
    f.publish();
    require(f.run(2).error, "next tick used old native epoch");
    require(f.run(3).ready, "fresh tick rejected");
    f.oracle(saved, f.forces);
    f.query.tick--;
    f.publish();
    require(f.run(4).error, "stale tick accepted");
    f.query.tick += 2;
    f.query.inputGeneration++;
    f.query.commandGeneration++;
    f.publish();
    c = f.commands.get();
    // Keep the full partition group count: empty commands still carry it.
    c[0].count = 0;
    f.commands.put(c);
    saved = f.bodies.get();
    require(f.run(4).ready && identical(saved, f.bodies.get()), "empty transaction changed motion");
}
void splitReplay()
{
    MotionFixture f(2);
    for (unsigned g = 0; g < 2; ++g)
    {
        f.mapping[g].supported = 0;
        auto& b = f.original[f.mapping[g].body];
        b.linearVelocityXYZ_inverseMassW = { 0, 0, 0, .5f };
        b.angularVelocityXYZ_maxPenBiasW = { 0, 0, 0, 17 };
        b.inverseInertiaXYZ_contactReportThresholdW = { 1, 1, 1, 19 };
        b.body2World.q = PxAlignedQuat(0, 0, 0, 1);
    }
    f.bindings.put(f.mapping);
    auto parent = f.original;
    parent[1].linearVelocityXYZ_inverseMassW.w = .25f;
    f.bodies.put(parent);
    f.forces = { { { 12, 0, 0, 0, 0, 0 } }, { { 0, 0, 0, 0, 0, 0 } } };
    f.loads.put(f.forces);
    auto c = f.commands.get();
    c[0].groups = 1;
    f.commands.put(c);
    require(f.run(1).ready, "parent command failed");
    nativeNear(f.bodies.get()[1].linearVelocityXYZ_inverseMassW.x, .05);
    // Rewind producer provides command-free child velocities. Only the child
    // carrying the commanded chunk receives its impulse after the split.
    f.bodies.put(f.original);
    f.query.evaluation = 1;
    f.query.ownershipGeneration++;
    f.publish();
    require(f.run(2).ready, "split command replay failed");
    auto result = f.bodies.get();
    nativeNear(result[1].linearVelocityXYZ_inverseMassW.x, .1);
    nativeNear(result[3].linearVelocityXYZ_inverseMassW.x, 0);
    require(f.run(2).duplicate && identical(result, f.bodies.get()), "split replay duplicated command");
}
void deviceHandoff()
{
    FixturePartition fixture(2, 1, false);
    // Two unit masses with symmetric COMs and matching aggregate principal
    // inertia: diag(1/.3, 1/.4, 1/.5). Native and structural frames agree.
    for (unsigned i = 0; i < 2; ++i)
    {
        const double x = i ? .1 : -.1;
        fixture.positions[i] = make_double3(x, 0, 0);
        fixture.chunks[i].position = PxVec3(float(x), 0, 0);
        fixture.mass[i] = { { x, 0, 0 }, 1, { 1 / .6, 1.24, .99, 0, 0, 0 }, 0 };
    }
    Upload u(fixture);
    u.update(fixture, 1);
    u.prepare();
    Device<C::Command> commands(2);
    Device<C::Batch> batch(1);
    Device<C::Receipt> receipt(1);
    Device<C::Resolved> resolved(2);
    Device<E::Vector> wrench(2);
    Device<double3> centers(2);
    MotionFixture native(1);
    native.mapping[0].supported = 0;
    native.bindings.put(native.mapping);
    native.original[1].inverseInertiaXYZ_contactReportThresholdW = { .3f, .4f, .5f, 19 };
    native.original[1].linearVelocityXYZ_inverseMassW.w = .5f;
    native.original[1].body2World.q = PxAlignedQuat(0, 0, 0, 1);
    native.original[1].body2World.p = make_float4(0, 0, 0, 0); // same COM as command aggregation
    native.bodies.put(native.original);
    std::vector<L::Motion> motion(2);
    motion[0].state.orientation[3] = 1;
    u.motions.put(motion);
    centers.put({ { 0, 0, 0 }, { 0, 0, 0 } });
    commands.put({ { { 0, 1, 0 }, { 12, 0, 0 }, { 0, 0, 6 }, 0, C::Units::Force },
                   { { 0, 0, 0 }, { 0, .3, 0 }, { .2, 0, 0 }, 1, C::Units::Impulse } });
    batch.put({ { native.query.tick, native.query.inputGeneration, native.query.commandGeneration, native.query.seconds,
                  2, 0 } });
    C::Source source{ batch.p, commands.p, u.state.p, u.motions.p, centers.p, u.identity, 2 };
    C::Storage out{ u.compactExtra.p, wrench.p, resolved.p, 2, 2, 2 };
    C::begin<<<1, 1>>>(source, out, native.query, receipt.p);
    C::clear<<<1, 128>>>(out, receipt.p);
    C::resolve<<<1, 128>>>(source, out, 1e-5, receipt.p);
    C::scatter<<<1, 128>>>(out, receipt.p);
    C::aggregate<<<1, 128>>>(source, out, 1e-5, receipt.p);
    C::inspect<<<1, 128>>>(out, receipt.p);
    C::finish<<<1, 1>>>(receipt.p);
    native.in.commands = receipt.p;
    native.in.wrenches = wrench.p;
    require(native.run(1).ready, "device evaluator-to-native motion handoff failed");
    // Force point contributes -12 about z, free couple adds +6. The impulse
    // contributes +18 y force and +12 x torque over the 1/60 loading interval.
    native.oracle(native.original, { { { 12, 18, 0, 12, 0, -6 } } });
}
int main(int argc, char** argv)
{
    try
    {
        if (argc == 1)
        {
            rejectCases();
            splitReplay();
            deviceHandoff();
        }
        else
            require(std::strcmp(argv[1], "--large") == 0, "expected --large");
        MotionFixture f(argc > 1 ? 113664 : 769);
        require(f.run(1).ready, "motion batch failed");
        f.oracle(f.original, f.forces);
        if (argc > 2)
        {
            auto data = f.bodies.get();
            std::ofstream out(argv[2], std::ios::binary);
            out.write(reinterpret_cast<const char*>(data.data()), data.size() * sizeof(data[0]));
            require(bool(out), "output failed");
        }
        std::printf(
            "command motion: %u groups, %u native slots; sparse native motion oracle passed; adversarial/device-handoff suite=%s\n",
            f.n, f.capacity, argc == 1 ? "passed" : "not run in large capture");
        return 0;
    }
    catch (const std::exception& e)
    {
        std::fprintf(stderr, "%s\n", e.what());
        return 1;
    }
}
