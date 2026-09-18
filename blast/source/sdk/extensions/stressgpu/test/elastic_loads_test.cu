// SPDX-License-Identifier: BSD-3-Clause
#include "ElasticPcgTestFixture.h"
#include "PxgDestructionElasticLoads.cuh"

#include <array>
namespace L = physx::destructionElasticLoads;
using V = std::array<double, 3>;
V add(V a, V b)
{
    for (unsigned k = 0; k < 3; ++k)
        a[k] += b[k];
    return a;
}
V sub(V a, V b)
{
    for (unsigned k = 0; k < 3; ++k)
        a[k] -= b[k];
    return a;
}
V mul(V a, double s)
{
    for (double& v : a)
        v *= s;
    return a;
}
V cross(V a, V b)
{
    return { a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0] };
}
V vector(double3 p)
{
    return { p.x, p.y, p.z };
}
V vector(const double* p)
{
    return { p[0], p[1], p[2] };
}
V vector(physx::PxVec3 p)
{
    return { p.x, p.y, p.z };
}
V inertia(const double* i, V v)
{
    return { i[0] * v[0] + i[3] * v[1] + i[4] * v[2], i[3] * v[0] + i[1] * v[1] + i[5] * v[2],
             i[4] * v[0] + i[5] * v[1] + i[2] * v[2] };
}
// Independent explicit rotation matrix, rather than the device cross formula.
V rotateInverse(const double* q, V v)
{
    double n = 0;
    for (unsigned k = 0; k < 4; ++k)
        n += q[k] * q[k];
    const double x = q[0] / sqrt(n), y = q[1] / sqrt(n), z = q[2] / sqrt(n), w = q[3] / sqrt(n);
    const double r[9] = { 1 - 2 * (y * y + z * z), 2 * (x * y - w * z),     2 * (x * z + w * y),
                          2 * (x * y + w * z),     1 - 2 * (x * x + z * z), 2 * (y * z - w * x),
                          2 * (x * z - w * y),     2 * (y * z + w * x),     1 - 2 * (x * x + y * y) };
    V out{};
    for (unsigned i = 0; i < 3; ++i)
        for (unsigned j = 0; j < 3; ++j)
            out[i] += r[3 * j + i] * v[j];
    return out;
}
struct Loads
{
    std::vector<double3> positions;
    std::vector<physx::PxDestructionStressChunk> chunks;
    std::vector<physx::PxDestructionChunkMassProperties> mass;
    std::vector<physx::PxDestructionSurfaceLoad> surface;
    std::vector<E::Vector> extra;
    L::Motion motion{};
    V gravity{ 0, -9.81, 0 };
    Loads(unsigned count = 6)
    {
        chunks.resize(count);
        positions.resize(count);
        mass.resize(count);
        surface.resize(count);
        extra.resize(count);
        for (unsigned i = 0; i < count; ++i)
        {
            chunks[i].position = physx::PxVec3(float(i % 3), float(i / 3), .1f * float(i));
            chunks[i].cluster = 0;
            positions[i] = { chunks[i].position.x + .001, chunks[i].position.y - .002, chunks[i].position.z + .003 };
            auto& m = mass[i];
            const auto p = vector(chunks[i].position);
            for (unsigned k = 0; k < 3; ++k)
                m.center[k] = p[k] + .03 * (k + 1);
            m.mass = 1 + .4 * i;
            const double values[6] = { .7 + .1 * i, .9 + .2 * i, 1.1 + .3 * i, .02, -.03, .04 };
            std::copy(values, values + 6, m.inertia);
            // Legacy scalar fields deliberately disagree with the physical data.
            chunks[i].mass = 0;
            chunks[i].inertia = 0;
        }
        motion.state.orientation[3] = 1;
        motion.mode = L::MotionMode::CompleteFreeWrench;
    }
};
struct UploadLoads
{
    Device<double3> positions;
    Device<physx::PxDestructionStressChunk> chunks;
    Device<physx::PxDestructionChunkMassProperties> mass;
    Device<physx::PxDestructionSurfaceLoad> surface;
    Device<E::Vector> extra, output;
    Device<L::Motion> motions;
    Device<L::Interval> produced;
    Device<L::Receipt> receipts;
    Device<uint32_t> starts, indices, local, error;
    L::Groups groups{};
    L::Inputs inputs{};
    L::Interval expected{ { 7, 11, 13, 0, 1 }, 1. / 60 };
    L::Profile profile{ 1e-6, 1e-14, 1e-11, 1e-11, 1e-11, 1e-11 };
    UploadLoads(const Loads& f, unsigned copies = 1)
        : positions(f.positions.size() * copies),
          chunks(f.chunks.size() * copies),
          mass(f.mass.size() * copies),
          surface(f.surface.size() * copies),
          extra(f.extra.size() * copies),
          output(f.extra.size() * copies),
          motions(copies),
          produced(1),
          receipts(copies),
          starts(copies + 1),
          indices(chunks.n),
          local(chunks.n),
          error(1)
    {
        std::vector<double3> positionsHost;
        std::vector<physx::PxDestructionStressChunk> c;
        std::vector<physx::PxDestructionChunkMassProperties> m;
        std::vector<physx::PxDestructionSurfaceLoad> s;
        std::vector<E::Vector> e;
        std::vector<uint32_t> offsets{ 0 }, order, locals;
        for (unsigned copy = 0; copy < copies; ++copy)
        {
            for (unsigned i = 0; i < f.chunks.size(); ++i)
            {
                auto node = f.chunks[i];
                node.cluster = copy;
                c.push_back(node);
                positionsHost.push_back(f.positions[i]);
                m.push_back(f.mass[i]);
                s.push_back(f.surface[i]);
                e.push_back(f.extra[i]);
                order.push_back(order.size());
                locals.push_back(i);
            }
            offsets.push_back(c.size());
        }
        positions.put(positionsHost);
        chunks.put(c);
        mass.put(m);
        surface.put(s);
        extra.put(e);
        motions.put(std::vector<L::Motion>(copies, f.motion));
        produced.put({ expected });
        starts.put(offsets);
        indices.put(order);
        local.put(locals);
        error.put({ 0 });
        groups = { copies, uint32_t(c.size()), starts.p, indices.p, local.p };
        inputs = { positions.p, chunks.p,  mass.p,     surface.p,
                   extra.p,     motions.p, produced.p, make_double3(f.gravity[0], f.gravity[1], f.gravity[2]) };
    }
    std::vector<L::Receipt> run()
    {
        error.put({ 0 });
        L::validate<<<(groups.nodes + 127) / 128, 128>>>(groups, inputs, profile, error.p);
        L::build<<<groups.count, 128>>>(groups, inputs, expected, profile, error.p, output.p, receipts.p);
        check(cudaGetLastError());
        return receipts.get();
    }
};
struct Reference
{
    std::vector<E::Vector> effective;
    V center, acceleration, alpha;
    double mass;
};
Reference reference(const Loads& f)
{
    Reference out{};
    out.effective.resize(f.mass.size());
    for (const auto& m : f.mass)
    {
        out.mass += m.mass;
        out.center = add(out.center, mul(vector(m.center), m.mass));
    }
    out.center = mul(out.center, 1 / out.mass);
    const auto* q = f.motion.state.orientation;
    const auto gravity = rotateInverse(q, f.gravity), omega = rotateInverse(q, vector(f.motion.state.angularVelocity));
    Dense aggregate(9);
    V totalForce{}, totalTorque{};
    for (unsigned i = 0; i < f.mass.size(); ++i)
    {
        const auto& m = f.mass[i];
        const auto node = vector(f.positions[i]), r = sub(vector(m.center), out.center);
        auto force = add(vector(f.surface[i].force), vector(f.extra[i].v)),
             torque = add(add(vector(f.surface[i].torque),
                              cross(sub(vector(f.chunks[i].position), node), vector(f.surface[i].force))),
                          vector(f.extra[i].v + 3));
        const auto weight = mul(gravity, m.mass);
        force = add(force, weight);
        torque = add(torque, cross(sub(vector(m.center), node), weight));
        for (unsigned k = 0; k < 3; ++k)
        {
            out.effective[i].v[k] = force[k];
            out.effective[i].v[k + 3] = torque[k];
        }
        totalForce = add(totalForce, force);
        totalTorque = add(totalTorque, add(torque, cross(sub(node, out.center), force)));
        const double own[9] = { m.inertia[0], m.inertia[3], m.inertia[4], m.inertia[3], m.inertia[1],
                                m.inertia[5], m.inertia[4], m.inertia[5], m.inertia[2] };
        const double radius = r[0] * r[0] + r[1] * r[1] + r[2] * r[2];
        for (unsigned row = 0; row < 3; ++row)
            for (unsigned col = 0; col < 3; ++col)
                aggregate[3 * row + col] += own[3 * row + col] + m.mass * ((row == col ? radius : 0) - r[row] * r[col]);
    }
    out.acceleration = rotateInverse(q, vector(f.motion.linearAcceleration));
    out.alpha = rotateInverse(q, vector(f.motion.angularAcceleration));
    if (f.motion.mode == L::MotionMode::CompleteFreeWrench)
    {
        out.acceleration = mul(totalForce, 1 / out.mass);
        V momentum{};
        for (unsigned i = 0; i < 3; ++i)
            for (unsigned j = 0; j < 3; ++j)
                momentum[i] += aggregate[3 * i + j] * omega[j];
        const auto torque = sub(totalTorque, cross(omega, momentum));
        const auto solution = solve(aggregate, { torque[0], torque[1], torque[2] });
        out.alpha = { solution[0], solution[1], solution[2] };
    }
    for (unsigned i = 0; i < f.mass.size(); ++i)
    {
        const auto& m = f.mass[i];
        const auto node = vector(f.positions[i]), r = sub(vector(m.center), out.center);
        const auto force = mul(add(out.acceleration, add(cross(out.alpha, r), cross(omega, cross(omega, r)))), m.mass);
        const auto torque = add(add(inertia(m.inertia, out.alpha), cross(omega, inertia(m.inertia, omega))),
                                cross(sub(vector(m.center), node), force));
        for (unsigned k = 0; k < 3; ++k)
        {
            out.effective[i].v[k] -= force[k];
            out.effective[i].v[k + 3] -= torque[k];
        }
    }
    return out;
}
void compare(const Loads& f, unsigned copies = 1)
{
    UploadLoads u(f, copies);
    const auto receipts = u.run();
    const auto actual = u.output.get();
    const auto expected = reference(f);
    for (unsigned copy = 0; copy < copies; ++copy)
    {
        const auto& r = receipts[copy];
        require(r.status == L::Status::Ready, "adapter rejected valid loads");
        near(r.mass, expected.mass, "physical aggregate mass");
        for (unsigned k = 0; k < 3; ++k)
        {
            near(r.center[k], expected.center[k], "physical COM");
            near(r.linearAcceleration[k], expected.acceleration[k], "aggregate acceleration");
            near(r.angularAcceleration[k], expected.alpha[k], "aggregate Euler acceleration");
        }
        for (unsigned i = 0; i < f.mass.size(); ++i)
            for (unsigned k = 0; k < 6; ++k)
                near(actual[copy * f.mass.size() + i].v[k], expected.effective[i].v[k],
                     "effective force/moment reference");
    }
}
void physicalCases()
{
    Loads f;
    compare(f);
    auto freefall = reference(f);
    for (auto v : freefall.effective)
        for (double x : v.v)
            near(x, 0, "uniform free-fall zero stress");
    f.motion.state.angularVelocity[0] = .7;
    f.motion.state.angularVelocity[1] = -.4;
    f.motion.state.angularVelocity[2] = 1.1;
    compare(f);
    f.surface[2].force = physx::PxVec3(7, -3, 5);
    f.surface[2].torque = physx::PxVec3(2, -4, 1);
    f.extra[4] = { { 1, 2, 3, -2, 1, .5 } };
    compare(f);
    UploadLoads original(f);
    require(original.run()[0].status == L::Status::Ready, "objectivity baseline");
    const auto baseline = original.output.get();
    Loads rotated = f;
    rotated.motion.state.orientation[2] = .6;
    rotated.motion.state.orientation[3] = .8;
    const double inverseQuaternion[4] = { 0, 0, -.6, .8 };
    rotated.gravity = rotateInverse(inverseQuaternion, f.gravity);
    const auto worldSpin = rotateInverse(inverseQuaternion, vector(f.motion.state.angularVelocity));
    std::copy(worldSpin.begin(), worldSpin.end(), rotated.motion.state.angularVelocity);
    UploadLoads transformed(rotated);
    require(transformed.run()[0].status == L::Status::Ready, "rotated load frame");
    const auto invariant = transformed.output.get();
    for (unsigned i = 0; i < 6; ++i)
        for (unsigned k = 0; k < 6; ++k)
            near(invariant[i].v[k], baseline[i].v[k], "common world rotation changed asset response");
    f.motion.state.orientation[2] = .6;
    f.motion.state.orientation[3] = .8;
    compare(f);
    compare(f, 129);
    Loads fixed;
    fixed.mass[0].supported = 1;
    fixed.motion.mode = L::MotionMode::EngineAcceleration;
    compare(fixed);
    fixed.motion.linearAcceleration[0] = .3;
    fixed.motion.angularAcceleration[2] = .2;
    fixed.motion.state.angularVelocity[0] = .8;
    compare(fixed);
    Loads large(137);
    large.surface[136].force = physx::PxVec3(3, -2, 1);
    compare(large);
}
void uniformGravityCancellation()
{
    // Native unsupported fragments exposed ~1.8e-12 N of fictitious load from
    // subtracting rounded weight and rounded translational inertia.
    Loads f(3);
    f.gravity={0,-9.8100004196166992,0};
    for(auto& m:f.mass)m.mass=884.7359619140625;
    UploadLoads falling(f);
    require(falling.run()[0].status==L::Status::Ready,"native-mass free fall rejected");
    for(const auto& value:falling.output.get())
        for(double x:value.v)require(x==0,"uniform free fall manufactured internal load");
    // Changing a uniform gravitational field cannot change the internal
    // response of a completely specified free aggregate. Retain tiny loads
    // and spin; this must not be implemented as a near-zero load cutoff.
    for(double spin:{0.,1e-6,.7})
    {
        f.motion.state.angularVelocity[0]=spin;
        f.motion.state.angularVelocity[1]=-.3*spin;
        f.extra[1].v[0]=1e-9;f.extra[2].v[4]=-2e-9;
        f.gravity={0,0,0};UploadLoads zero(f);
        require(zero.run()[0].status==L::Status::Ready,"zero-gravity control rejected");
        const auto baseline=zero.output.get();bool nonzero=false;
        for(auto v:baseline)for(double x:v.v)nonzero|=x!=0;
        require(nonzero,"small applied loads or spin were discarded");
        for(V gravity:std::vector<V>{{0,-9.8100004196166992,0},{3e8,-7e8,2e8}})
        {
            f.gravity=gravity;UploadLoads other(f);
            require(other.run()[0].status==L::Status::Ready,"uniform-gravity invariance rejected");
            const auto output=other.output.get();
            for(unsigned i=0;i<output.size();++i)
                for(unsigned k=0;k<6;++k)
                    require(output[i].v[k]==baseline[i].v[k],"uniform gravity changed free internal loads");
        }
    }
    Loads single(1);
    single.extra[0]={{1e-9,0,0,0,2e-9,0}};
    single.motion.state.angularVelocity[2]=.3;
    single.gravity={0,0,0};UploadLoads zero(single);
    const auto baseline=zero.run()[0];require(baseline.status==L::Status::Ready,"single-body gravity control");
    single.gravity={3e8,-7e8,2e8};UploadLoads other(single);
    const auto result=other.run()[0];require(result.status==L::Status::Ready,"single-body gravity invariance");
    for(unsigned k=0;k<3;++k)
        require(result.angularAcceleration[k]==baseline.angularAcceleration[k],"uniform gravity created a single-body couple");
}
void intervalAndFailures()
{
    Loads f;
    UploadLoads u(f);
    auto stamp = u.expected;
    stamp.stamp.evaluation = 1;
    u.produced.put({ stamp });
    require(u.run()[0].status == L::Status::StaleInput, "stale correction stamp accepted");
    stamp = u.expected;
    stamp.seconds *= 2;
    u.produced.put({ stamp });
    require(u.run()[0].status == L::Status::StaleInput, "wrong impulse interval accepted");
    using Field = uint64_t L::Stamp::*;
    for (Field field : { &L::Stamp::tick, &L::Stamp::inputGeneration, &L::Stamp::ownershipGeneration })
    {
        auto stale = u.expected;
        ++(stale.stamp.*field);
        u.produced.put({ stale });
        require(u.run()[0].status == L::Status::StaleInput, "stale load identity accepted");
    }
    u.produced.put({ u.expected });
    u.expected.seconds = 0;
    require(u.run()[0].status == L::Status::InvalidInput, "zero interval accepted");
    UploadLoads incomplete(f);
    incomplete.expected.stamp.complete = 0;
    require(incomplete.run()[0].status == L::Status::InvalidInput, "incomplete load ledger accepted");
    f.mass[0].supported = 1;
    UploadLoads supported(f);
    require(supported.run()[0].status == L::Status::UnsupportedMotion, "free relief applied to supports");
    f = Loads{};
    f.motion.mode = L::MotionMode::EngineAcceleration;
    UploadLoads missing(f);
    require(missing.run()[0].status == L::Status::UnbalancedInertia, "wrong engine acceleration hidden by projection");
    f.motion.linearAcceleration[1] = -9.81;
    compare(f);
    f = Loads{};
    f.mass[0].mass = 0;
    UploadLoads mass(f);
    require(mass.run()[0].status == L::Status::InvalidInput, "legacy zero mass used as physical mass");
    f = Loads{};
    f.mass[1].inertia[0] = -1;
    UploadLoads inertia(f);
    require(inertia.run()[0].status == L::Status::InvalidInput, "invalid inertia accepted");
    f = Loads{};
    f.extra[2].v[3] = NAN;
    UploadLoads nan(f);
    require(nan.run()[0].status == L::Status::Nonfinite, "NaN torque accepted");
    f = Loads{};
    UploadLoads partition(f);
    partition.local.put({ 0, 0, 2, 3, 4, 5 });
    require(partition.run()[0].status == L::Status::InvalidInput, "invalid ownership accepted");
    UploadLoads initialOwnership(Loads{});
    initialOwnership.expected.stamp.ownershipGeneration = 0;
    initialOwnership.produced.put({ initialOwnership.expected });
    require(initialOwnership.run()[0].status == L::Status::Ready, "native initial topology generation rejected");
    initialOwnership.expected.stamp.inputGeneration = 0;
    initialOwnership.produced.put({ initialOwnership.expected });
    require(initialOwnership.run()[0].status == L::Status::InvalidInput, "unpublished load generation accepted");
    // Known contact impulse at an offset point; producer divides by interval once.
    f = Loads{};
    f.gravity = { 0, 0, 0 };
    const V impulse{ .1, -.2, .3 }, arm{ .2, .1, -.1 };
    const auto angular = cross(arm, impulse);
    for (double dt : { 1. / 60, 1. / 120 })
    {
        const auto force = mul(impulse, 1 / dt), torque = mul(angular, 1 / dt);
        f.surface[1].force = physx::PxVec3(force[0], force[1], force[2]);
        f.surface[1].torque = physx::PxVec3(torque[0], torque[1], torque[2]);
        UploadLoads impact(f);
        impact.expected.seconds = dt;
        impact.produced.put({ impact.expected });
        require(impact.run()[0].status == L::Status::Ready, "impact interval rejected");
        const auto value = impact.output.get();
        const auto ref = reference(f);
        for (unsigned i = 0; i < 6; ++i)
            for (unsigned k = 0; k < 6; ++k)
                near(value[i].v[k], ref.effective[i].v[k], "contact impulse divided twice");
    }
}
void feedProjectedSolve()
{
    Loads loads;
    Fixture f;
    f.fixed.assign(6, 0);
    for (unsigned i = 0; i < 6; ++i)
        loads.chunks[i].position = physx::PxVec3(f.x[i].x, f.x[i].y, f.x[i].z);
    loads.positions = f.x;
    loads.surface[1].force = physx::PxVec3(3, -1, 2);
    loads.surface[1].torque = physx::PxVec3(.2, .3, -.4);
    Solver solver(f, { 0, 6 }, { 1 });
    UploadLoads adapter(loads);
    adapter.inputs.referencePositions = solver.graph.x.p;
    require(adapter.run()[0].status == L::Status::Ready, "integrated algebra load rejection");
    const auto effective = adapter.output.get();
    // A genuine device-to-device handoff of physical loads into the fine RHS.
    solver.error.put({ 0 });
    E::validateComponents<<<1, 128>>>(solver.graph.graph, solver.components, solver.graph.error.p, solver.error.p);
    L::gate<<<1, 128>>>(1, adapter.receipts.p, adapter.expected, solver.graph.error.p);
    Device<E::Vector> prescribed(6);
    prescribed.put(std::vector<E::Vector>(6));
    E::buildRhs<<<1, 128>>>(solver.graph.graph, adapter.output.p, prescribed.p, solver.rhs.p, solver.graph.error.p);
    E::prepareComponents<<<1, 128>>>(solver.graph.graph, solver.components, solver.workspace, solver.profile,
                                     solver.keys.p, solver.setup.p, solver.graph.error.p, solver.error.p);
    E::solveComponents<<<1, 128>>>(solver.graph.graph, solver.components, solver.rhs.p, solver.initial.p,
                                   solver.solution.p, solver.workspace, solver.profile, solver.keys.p, solver.setup.p,
                                   solver.graph.error.p, solver.error.p, solver.receipts.p);
    require(solver.receipts.get()[0].status == E::SolveStatus::LinearConverged,
            "physical adapter -> fine solver did not converge");
    f.external = effective;
    f.prescribed.assign(6, {});
    residualCheck(f, referenceRhs(f), solver.solution.get());
    // The last valid output still exists. A stale producer must not reuse it,
    // nor turn its rejection into an apparently converged zero-load solve.
    ++adapter.expected.stamp.inputGeneration;
    solver.graph.error.put({ 0 });
    L::gate<<<1, 128>>>(1, adapter.receipts.p, adapter.expected, solver.graph.error.p);
    E::buildRhs<<<1, 128>>>(solver.graph.graph, adapter.output.p, prescribed.p, solver.rhs.p, solver.graph.error.p);
    E::solveComponents<<<1, 128>>>(solver.graph.graph, solver.components, solver.rhs.p, solver.initial.p,
                                   solver.solution.p, solver.workspace, solver.profile, solver.keys.p, solver.setup.p,
                                   solver.graph.error.p, solver.error.p, solver.receipts.p);
    require(solver.receipts.get()[0].status == E::SolveStatus::InvalidInput, "rejected adapter output entered solver");
}
void singleFreeBody()
{
    Loads f;
    f.positions.resize(1);
    f.chunks.resize(1);
    f.mass.resize(1);
    f.surface.resize(1);
    f.extra.resize(1);
    f.motion.state.angularVelocity[0] = 37.7;
    f.surface[0].force = physx::PxVec3(3e7f, -5e6f, 7e6f);
    f.surface[0].torque = physx::PxVec3(2e6f, -4e6f, 1e6f);
    f.extra[0] = { { 1e5, 2e5, -3e5, 4e4, 5e4, -6e4 } };
    UploadLoads adapter(f, 129);
    const auto result = adapter.run();
    const auto expected = reference(f);
    for (const auto& r : result)
    {
        require(r.status == L::Status::Ready, "free one-node aggregate rejected");
        for (unsigned k = 0; k < 3; ++k)
        {
            near(r.linearAcceleration[k], expected.acceleration[k], "one-node acceleration");
            near(r.angularAcceleration[k], expected.alpha[k], "one-node Euler acceleration");
        }
    }
    for (const auto& value : adapter.output.get())
        for (double x : value.v)
            require(x == 0, "free rigid node acquired internal load");
    f.surface[0].torque.x = NAN;
    UploadLoads invalid(f);
    require(invalid.run()[0].status == L::Status::Nonfinite, "one-node fast path hid nonfinite load");
}
int main(int argc, char** argv)
{
    try
    {
        if (argc == 2 && std::string(argv[1]) == "--batch-only")
        {
            Loads f;
            f.motion.state.angularVelocity[0] = .7;
            f.motion.state.angularVelocity[1] = -.4;
            f.motion.state.angularVelocity[2] = 1.1;
            f.surface[2].force = physx::PxVec3(7, -3, 5);
            f.surface[2].torque = physx::PxVec3(2, -4, 1);
            f.extra[4] = { { 1, 2, 3, -2, 1, .5 } };
            compare(f, 129);
            check(cudaGetLastError());
            check(cudaDeviceSynchronize());
            std::cout
                << "PASS: counter fixture, 129 free motion aggregates, 774 chunks, physical mass/inertia, gravity/spin/contact/additional wrenches\n";
            return 0;
        }
        require(argc == 1, "usage: stress_elastic_loads_test [--batch-only]");
        physicalCases();
        uniformGravityCancellation();
        intervalAndFailures();
        feedProjectedSolve();
        singleFreeBody();
        check(cudaGetLastError());
        check(cudaDeviceSynchronize());
        std::cout
            << "PASS: PhysX physical mass/inertia and surface-load adapter, free fall/spin/impact/supports, stamp/interval validation, 129 motion aggregates, 137-node aggregate, device handoff to projected solver\n";
    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << '\n';
        return 1;
    }
}
