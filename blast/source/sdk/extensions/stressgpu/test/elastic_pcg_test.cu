// SPDX-License-Identifier: BSD-3-Clause
#include "ElasticPcgTestFixture.h"
void supportedCase(double length, bool deletion, bool extended = false)
{
    Fixture f;
    if (deletion)
        f.bonds.back().live = 0;
    const auto b = referenceRhs(f);
    Solver s(f, { 0, 6 }, { length });
    Device<E::Vector> low(6),solutionLow(6);
    if(extended) {
        check(cudaMemset(low.p,0xff,6*sizeof(E::Vector)));check(cudaMemset(solutionLow.p,0xff,6*sizeof(E::Vector)));
        s.workspace.xLow=low.p;s.workspace.solutionLow=solutionLow.p;
    }
    auto result = s.run(b,true,extended)[0];
    require(result.status == E::SolveStatus::LinearConverged, "supported PCG convergence");
    require(result.iterations > 0, "supported iterations missing");
    const auto q = s.solution.get();
    residualCheck(f, b, q);
    const auto matrix = f.matrix();
    Dense a(30 * 30), load(30);
    for (unsigned i = 0; i < 30; ++i)
    {
        load[i] = b[1 + i / 6].v[i % 6];
        for (unsigned j = 0; j < 30; ++j)
            a[30 * i + j] = matrix[(6 + i) * 36 + 6 + j];
    }
    const auto ref = solve(a, load);
    for (unsigned i = 0; i < 30; ++i)
        require(std::abs(q[1 + i / 6].v[i % 6] - ref[i]) < 2e-8, "dense supported solution");
    s.initial.put(q);
    result = s.run(b,true,extended)[0];
    require(
        result.status == E::SolveStatus::LinearConverged && !result.iterations, "exact warm start does numerical work");
}
void freeCase(double length)
{
    Fixture f;
    f.fixed.assign(6, 0);
    std::vector<E::Vector> target(6), warm(6);
    for (unsigned i = 0; i < 6; ++i)
        for (unsigned k = 0; k < 6; ++k)
            target[i].v[k] = std::sin(6 * i + k + .3);
    const auto a = f.matrix();
    const auto b = denseProduct(f, a, target);
    Solver s(f, { 0, 6 }, { length });
    // Large arbitrary rigid warm start, including rotational lever arms.
    for (unsigned i = 0; i < 6; ++i)
    {
        const auto p = f.x[i];
        warm[i] = { { 1000 - 13 * p.y, -300 + 13 * p.x, 70, 0, 0, 13 } };
    }
    s.initial.put(warm);
    const auto result = s.run(b)[0];
    require(result.status == E::SolveStatus::LinearConverged, "projected free convergence");
    const auto q = s.solution.get();
    residualCheck(f, b, q);
    // Independent orthogonality check using the analytical S^-1 N, no GPU QR.
    double3 center{};
    for (auto p : f.x)
    {
        center.x += p.x / 6;
        center.y += p.y / 6;
        center.z += p.z / 6;
    }
    double translation[3]{}, rotation[3]{};
    for (unsigned i = 0; i < 6; ++i)
    {
        const auto p = f.x[i];
        const auto v = q[i];
        for (unsigned k = 0; k < 3; ++k)
        {
            translation[k] += v.v[k];
            rotation[k] += length * length * v.v[k + 3];
        }
        rotation[0] += (p.y - center.y) * v.v[2] - (p.z - center.z) * v.v[1];
        rotation[1] += (p.z - center.z) * v.v[0] - (p.x - center.x) * v.v[2];
        rotation[2] += (p.x - center.x) * v.v[1] - (p.y - center.y) * v.v[0];
    }
    for (unsigned k = 0; k < 3; ++k)
    {
        require(std::abs(translation[k]) < 1e-8, "free translational gauge");
        require(std::abs(rotation[k]) < 1e-8, "free rotational gauge");
    }
    for (const auto& bond : f.bonds)
    {
        const auto g = f.G(bond);
        for (unsigned row = 0; row < 6; ++row)
        {
            double delta = 0;
            for (unsigned i = 0; i < 36; ++i)
                delta += g[row * 36 + i] * (q[i / 6].v[i % 6] - target[i / 6].v[i % 6]);
            require(std::abs(delta) < 2e-8, "free interface response uniqueness");
        }
    }
    for (unsigned channel = 0; channel < 6; ++channel)
    {
        auto incompatible = b;
        incompatible[0].v[channel] += 1;
        require(s.run(incompatible)[0].status == E::SolveStatus::IncompatibleLoad,
                "incompatible force/torque projected away");
    }
}
void failuresAndTrivial()
{
    Fixture f;
    auto b = referenceRhs(f);
    Solver s(f, { 0, 6 }, { 1 });
    s.profile.maxIterations = 1;
    auto receipt = s.run(b)[0];
    require(receipt.status == E::SolveStatus::PendingIterationLimit && receipt.iterations == 1,
            "iteration limit falsely accepted");
    s.profile.maxIterations = 0;
    receipt = s.run(b)[0];
    require(receipt.status == E::SolveStatus::PendingIterationLimit && receipt.iterations == 0, "zero budget status");
    s.profile.maxIterations = 300;
    b[1].v[0] = NAN;
    require(s.run(b)[0].status == E::SolveStatus::InvalidInput, "NaN load accepted");
    b = referenceRhs(f);
    s.profile.relativeTolerance = NAN;
    require(s.run(b)[0].status == E::SolveStatus::InvalidInput, "NaN profile accepted");
    Solver scales(f, { 0, 6 }, { 0 });
    require(scales.run(b)[0].status == E::SolveStatus::InvalidInput, "zero length accepted");
    scales.length.put({ INFINITY });
    require(scales.run(b)[0].status == E::SolveStatus::InvalidInput, "infinite length accepted");
    Solver balance(f, { 0, 6 }, { 1 });
    balance.profile.relativeTolerance = 10;
    balance.profile.maxIterations = 1;
    require(balance.run(b)[0].status == E::SolveStatus::PendingIterationLimit,
            "loose global norm bypassed node force/torque gate");
    auto badInitial = std::vector<E::Vector>(6);
    badInitial[2].v[5] = INFINITY;
    balance.initial.put(badInitial);
    require(balance.run(b)[0].status == E::SolveStatus::InvalidInput, "infinite warm start accepted");
    Solver invalid(f, { 0, 6 }, { 1 });
    invalid.local.put({ 0, 0, 2, 3, 4, 5 });
    require(invalid.run(b)[0].status == E::SolveStatus::InvalidInput, "invalid permutation accepted");
    Solver permuted(f, { 0, 6 }, { 1 });
    permuted.nodes.put({ 4, 3, 0, 1, 5, 2 });
    permuted.local.put({ 2, 3, 5, 1, 0, 4 });
    require(permuted.run(b)[0].status == E::SolveStatus::LinearConverged, "valid permutation rejected");
    residualCheck(f, b, permuted.solution.get());
    auto enormous = b;
    enormous[1].v[0] = 1e308;
    require(permuted.run(enormous)[0].status == E::SolveStatus::Nonfinite, "overflowing reduction accepted");
    Solver split(f, { 0, 3, 6 }, { 1, 1 });
    for (auto r : split.run(b))
        require(r.status == E::SolveStatus::InvalidInput, "cross-component live edge accepted");
    f.fixed.assign(6, 1);
    Solver fixed(f, { 0, 6 }, { 1 });
    require(fixed.run(std::vector<E::Vector>(6))[0].status == E::SolveStatus::LinearConverged,
            "fully prescribed system rejected");
    f = Fixture{};
    for (auto& edge : f.bonds)
        edge.live = 0;
    f.fixed.assign(6, 0);
    Solver disconnected(f, { 0, 6 }, { 1 });
    require(disconnected.run(std::vector<E::Vector>(6))[0].status == E::SolveStatus::InvalidInput,
            "disconnected free graph accepted as one component");
    Solver isolated(f, { 0, 1, 2, 3, 4, 5, 6 }, { 1, 2, 3, 4, 5, 6 });
    const auto statuses = isolated.run(std::vector<E::Vector>(6));
    for (auto r : statuses)
        require(r.status == E::SolveStatus::LinearConverged && r.iterations == 0, "isolated zero-load node factored");
    auto loaded = std::vector<E::Vector>(6);
    loaded[3].v[4] = 1;
    const auto states = isolated.run(loaded);
    for (unsigned i = 0; i < 6; ++i)
        require(states[i].status == (i == 3 ? E::SolveStatus::IncompatibleLoad : E::SolveStatus::LinearConverged),
                "component error contaminated neighbors");
    f.x.resize(1);
    f.fixed = { 0 };
    f.bonds.clear();
    f.starts = { 0, 0 };
    f.refs.clear();
    Solver empty(f, { 0, 1 }, { 1 });
    require(empty.run(std::vector<E::Vector>(1))[0].status == E::SolveStatus::LinearConverged,
            "bondless free node rejected");
    empty.profile.absoluteTolerance = 0;
    std::vector<E::Vector> tinyLoad(1);
    tinyLoad[0].v[0] = 1e-13;
    require(empty.run(tinyLoad)[0].status == E::SolveStatus::IncompatibleLoad,
            "zero-dimensional residual failure reached a singular preconditioner");
}
void largeComponent(bool free)
{
    Fixture f;
    const auto prototype = f.bonds[0];
    f.x.clear();
    f.bonds.clear();
    f.fixed.assign(137, 0);
    if (!free)
        f.fixed[0] = 1;
    f.starts.clear();
    f.refs.clear();
    for (unsigned i = 0; i < 137; ++i)
        f.x.push_back({ .03 * i, std::sin(.13 * i), std::cos(.27 * i) });
    for (unsigned i = 1; i < 137; ++i)
    {
        auto bond = prototype;
        bond.first = 0;
        bond.second = i;
        bond.point[0] = .5 * (f.x[0].x + f.x[i].x);
        bond.point[1] = .5 * (f.x[0].y + f.x[i].y);
        bond.point[2] = .5 * (f.x[0].z + f.x[i].z);
        f.bonds.push_back(bond);
    }
    for (unsigned i = 0; i < 137; ++i)
    {
        f.starts.push_back(f.refs.size());
        for (unsigned e = 0; e < f.bonds.size(); ++e)
            if (f.bonds[e].first == i || f.bonds[e].second == i)
                f.refs.push_back(e);
    }
    f.starts.push_back(f.refs.size());
    std::vector<E::Vector> target(137);
    for (unsigned i = 0; i < 137; ++i)
        for (unsigned k = 0; k < 6; ++k)
            target[i].v[k] = std::sin(i * .2 + k);
    const auto b = sparseOracle(f, target);
    Solver s(f, { 0, 137 }, { 2 });
    const auto receipt = s.run(b)[0];
    require(receipt.status == E::SolveStatus::LinearConverged, "strided component convergence");
    const auto q = s.solution.get(), actual = sparseOracle(f, q);
    for (unsigned i = 0; i < 137; ++i)
        for (unsigned k = 0; k < 6; ++k)
            require(std::abs(actual[i].v[k] - b[i].v[k]) < 2e-8 * (1 + std::abs(b[i].v[k])),
                    "strided component original equation");
    if (!free)
        require(receipt.iterations == 1, "block-diagonal star not solved in one Jacobi step");
}
void batchCase()
{
    Fixture asset, batch;
    batch.x.clear();
    batch.bonds.clear();
    batch.fixed.clear();
    batch.starts.clear();
    batch.refs.clear();
    std::vector<E::Vector> rhs;
    std::vector<uint32_t> offsets{ 0 };
    std::vector<double> scales;
    std::vector<Fixture> fixtures;
    std::vector<std::vector<E::Vector>> loads;
    for (unsigned copy = 0; copy < 129; ++copy)
    {
        Fixture f;
        if (copy % 2)
            f.fixed.assign(6, 0);
        if (copy % 3 == 0)
            f.bonds.back().live = 0;
        const auto firstNode = batch.x.size(), firstBond = batch.bonds.size();
        std::vector<E::Vector> target(6);
        for (unsigned i = 0; i < 6; ++i)
            for (unsigned k = 0; k < 6; ++k)
                target[i].v[k] = copy % 7 ? std::sin(6 * i + k + copy) : 0;
        const auto load = denseProduct(f, f.matrix(), target);
        loads.push_back(load);
        fixtures.push_back(f);
        rhs.insert(rhs.end(), load.begin(), load.end());
        for (auto p : f.x)
        {
            p.x += 16 * copy;
            batch.x.push_back(p);
        }
        for (auto bond : f.bonds)
        {
            bond.first += firstNode;
            bond.second += firstNode;
            bond.point[0] += 16 * copy;
            batch.bonds.push_back(bond);
        }
        for (unsigned i = 0; i < 6; ++i)
        {
            batch.fixed.push_back(f.fixed[i]);
            batch.starts.push_back(batch.refs.size());
            for (unsigned j = f.starts[i]; j < f.starts[i + 1]; ++j)
                batch.refs.push_back(firstBond + f.refs[j]);
        }
        offsets.push_back(batch.x.size());
        scales.push_back(copy % 2 ? .25 : 4);
    }
    batch.starts.push_back(batch.refs.size());
    Solver s(batch, offsets, scales);
    const auto status = s.run(rhs);
    const auto q = s.solution.get();
    for (unsigned copy = 0; copy < 129; ++copy)
    {
        require(status[copy].status == E::SolveStatus::LinearConverged, "batch convergence");
        if (copy % 7 == 0)
            require(status[copy].iterations == 0, "idle component not retired");
        residualCheck(
            fixtures[copy], loads[copy], std::vector<E::Vector>(q.begin() + 6 * copy, q.begin() + 6 * copy + 6));
    }
    const auto repeated = s.run(rhs);
    const auto reused = s.solution.get();
    const auto setup = s.setup.get();
    for (unsigned copy = 0; copy < 129; ++copy)
    {
        require(repeated[copy].status == E::SolveStatus::LinearConverged &&
                    repeated[copy].iterations == status[copy].iterations,
                "cached batch changed recurrence");
        require(setup[copy].builds == 1, "cached batch rebuilt setup");
        for (unsigned i = 0; i < 6; ++i)
            for (unsigned k = 0; k < 6; ++k)
                near(reused[6 * copy + i].v[k], q[6 * copy + i].v[k], "cached batch solution");
    }
    uint32_t iterations = 0, maximum = 0, active = 0;
    for (auto r : status)
    {
        iterations += r.iterations;
        maximum = std::max(maximum, r.iterations);
        active += r.iterations != 0;
    }
    std::cout << "BATCH: 129 components, 774 nodes, 1032 bonds (989 live), " << active << " iterating components, "
              << iterations << " summed iterations, " << maximum << " maximum\n";
}
// Recorded native shell geometry and gravity scale, independent of capture files.
// The global norm threshold is looser than per-node balance here; residual
// replacement must keep improving the original equations after the norm passes.
void nativeBalanceRefresh()
{
    Fixture f;f.x.clear();f.fixed.clear();f.bonds.clear();f.starts.clear();f.refs.clear();
    std::vector<int> lookup(12*8*8,-1);
    const auto cell=[](unsigned x,unsigned y,unsigned z){return (y*8+z)*8+x;};
    for(unsigned y=0;y<12;++y)for(unsigned z=0;z<8;++z)for(unsigned x=0;x<8;++x)
        if(x==0 || x==7 || z==0 || z==7 || y%4==0) {
            lookup[cell(x,y,z)]=f.x.size();f.x.push_back({double(x)-3.5,double(y),double(z)-3.5});f.fixed.push_back(y==0);
        }
    std::vector<std::vector<uint32_t>> adjacency(f.x.size());
    for(unsigned y=0;y<12;++y)for(unsigned z=0;z<8;++z)for(unsigned x=0;x<8;++x) {
        const int first=lookup[cell(x,y,z)];if(first<0)continue;
        for(auto p:std::vector<std::array<unsigned,3>>{{x+1,y,z},{x,y+1,z},{x,y,z+1}}) {
            if(p[0]>=8 || p[1]>=12 || p[2]>=8)continue;const int second=lookup[cell(p[0],p[1],p[2])];if(second<0)continue;
            E::Bond b{};b.first=first;b.second=second;b.live=1;
            const auto a=f.x[first],c=f.x[second];b.point[0]=(a.x+c.x)/2;b.point[1]=(a.y+c.y)/2;b.point[2]=(a.z+c.z)/2;
            b.frame[0]=b.frame[4]=b.frame[8]=1;for(unsigned k=0;k<6;++k)b.stiffness.v[7*k]=k<3?1e6:1e4;
            adjacency[first].push_back(f.bonds.size());adjacency[second].push_back(f.bonds.size());f.bonds.push_back(b);
        }
    }
    for(const auto& list:adjacency){f.starts.push_back(f.refs.size());f.refs.insert(f.refs.end(),list.begin(),list.end());}f.starts.push_back(f.refs.size());
    require(f.x.size()==444 && f.bonds.size()==896,"native shell graph shape");
    f.external.assign(444,{});f.prescribed.assign(444,{});
    for(unsigned i=64;i<444;++i)f.external[i].v[1]=-884.7359619140625*9.8100004196166992;
    Solver s(f,{0,444},{1});s.profile.maxIterations=8192;
    std::vector<uint32_t> nodes(444),owner(444,E::Unowned),local(444,E::Unowned);
    for(unsigned i=64;i<444;++i){nodes[i-64]=i;owner[i]=0;local[i]=i-64;}
    s.starts.put({0,380});s.nodes.put(nodes);s.owner.put(owner);s.local.put(local);
    const auto result=s.run(f.external)[0];
    std::cout<<"native balance: status "<<unsigned(result.status)<<" iterations "<<result.iterations<<" restarts "<<result.restarts
        <<" force "<<result.maxForce<<" torque "<<result.maxTorque<<'\n';
    require(result.status==E::SolveStatus::LinearConverged,"native local balance stalled below global threshold");
    require(result.restarts>0,"native recurrence never refreshed");
    // Prescribed rows are intentionally absent from numerical output. Use
    // their authored zero values and read only the initialized unknown prefix.
    std::vector<E::Vector> q=f.prescribed;
    check(cudaMemcpy(q.data()+64,s.solution.p+64,380*sizeof(E::Vector),cudaMemcpyDeviceToHost));
    using V=std::array<long double,3>;std::vector<std::array<long double,6>> action(444);
    const auto cross=[](V a,V b){return V{a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]};};
    for(const auto& e:f.bonds) {
        const auto i=e.first,j=e.second;const auto a=f.x[i],b=f.x[j];
        V ra{(long double)e.point[0]-a.x,(long double)e.point[1]-a.y,(long double)e.point[2]-a.z},
          rb{(long double)e.point[0]-b.x,(long double)e.point[1]-b.y,(long double)e.point[2]-b.z};
        V ti{q[i].v[3],q[i].v[4],q[i].v[5]},tj{q[j].v[3],q[j].v[4],q[j].v[5]};
        const auto ca=cross(ti,ra),cb=cross(tj,rb);V force{},moment{};
        for(unsigned k=0;k<3;++k){force[k]=1e6L*((long double)q[j].v[k]-q[i].v[k]+cb[k]-ca[k]);moment[k]=1e4L*(tj[k]-ti[k]);}
        const auto ma=cross(ra,force),mb=cross(rb,force);
        for(unsigned k=0;k<3;++k){action[i][k]-=force[k];action[j][k]+=force[k];action[i][k+3]-=moment[k]+ma[k];action[j][k+3]+=moment[k]+mb[k];}
    }
    for(unsigned i=64;i<444;++i) {
        long double force=0,torque=0;
        for(unsigned k=0;k<6;++k){const auto r=action[i][k]-f.external[i].v[k];(k<3?force:torque)+=r*r;}
        require(sqrtl(force)<=s.profile.forceScale*s.profile.forceTolerance && sqrtl(torque)<=s.profile.torqueScale*s.profile.torqueTolerance,
                "independent extended-precision native balance");
    }
}
void extendedFailures() {
    Fixture f;Solver s(f,{0,6},{1});
    require(s.run(referenceRhs(f),true,true)[0].status==E::SolveStatus::InvalidInput,"missing low-word storage accepted");
    f.fixed.assign(6,0);Solver free(f,{0,6},{1});
    Device<E::Vector> low(6),solutionLow(6);free.workspace.xLow=low.p;free.workspace.solutionLow=solutionLow.p;
    require(free.run(std::vector<E::Vector>(6),true,true)[0].status==E::SolveStatus::ModelUnsupported,"unsupported two-word free projection accepted");
}
int main(int argc, char** argv)
{
    try
    {
        if (argc == 2 && std::string(argv[1]) == "--batch-only")
        {
            batchCase();
            check(cudaGetLastError());
            check(cudaDeviceSynchronize());
            return 0;
        }
        require(argc == 1, "usage: stress_elastic_pcg_test [--batch-only]");
        for (double length : { .25, 1., 4. })
        {
            supportedCase(length, false);
            supportedCase(length, true);
            supportedCase(length,false,true);
            supportedCase(length,true,true);
            freeCase(length);
        }
        extendedFailures();
        nativeBalanceRefresh();
        failuresAndTrivial();
        batchCase();
        largeComponent(false);
        largeComponent(true);
        check(cudaGetLastError());
        check(cudaDeviceSynchronize());
        std::cout
            << "PASS: GPU projected block-PCG, dense supported/free solutions, scaled six-mode gauge, original-row balance, warm/zero starts, deletion, 129 independent components, 137-node strided components, invalid inputs and incompatible loads, iteration-limit receipts\n";
    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << '\n';
        return 1;
    }
}
