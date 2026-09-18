// SPDX-License-Identifier: BSD-3-Clause
#include "ElasticPcgTestFixture.h"

#include <cstring>

void success(const std::vector<E::SolveReceipt>& receipts)
{
    for (auto receipt : receipts)
        require(receipt.status == E::SolveStatus::LinearConverged, "prepared solve failed");
}
void changedLoadAndOperator()
{
    Fixture f;
    Solver s(f, { 0, 6 }, { 1 });
    auto b = referenceRhs(f);
    require(s.run(b, false)[0].status == E::SolveStatus::NeedsSetup, "unprepared solve accepted");
    success(s.run(b));
    const auto original = s.factors.get();
    require(s.setup.get()[0].builds == 1, "initial setup count");
    for (auto& node : f.external)
        for (double& v : node.v)
            v *= 2;
    b = referenceRhs(f);
    success(s.run(b));
    residualCheck(f, b, s.solution.get());
    require(s.setup.get()[0].builds == 1, "load change rebuilt setup");
    const auto same = s.factors.get();
    require(!std::memcmp(original.data(), same.data(), same.size() * sizeof(E::Matrix)), "load changed cached factors");
    f.bonds[0].inelastic.v[1] += .01;
    s.graph.bonds.put(f.bonds);
    b = referenceRhs(f);
    success(s.run(b));
    residualCheck(f, b, s.solution.get());
    require(s.setup.get()[0].builds == 1, "history-only RHS change rebuilt setup");
    for (double& v : f.bonds[0].stiffness.v)
        v *= 1.7;
    s.graph.bonds.put(f.bonds);
    auto key = s.keys.get();
    ++key[0].stiffness;
    s.keys.put(key);
    b = referenceRhs(f);
    require(s.run(b, false)[0].status == E::SolveStatus::NeedsSetup, "stale coefficient factors accepted");
    success(s.run(b));
    residualCheck(f, b, s.solution.get());
    require(s.setup.get()[0].builds == 2, "coefficient setup not rebuilt");
    const auto changed = s.factors.get();
    require(std::memcmp(original.data(), changed.data(), changed.size() * sizeof(E::Matrix)) != 0,
            "changed stiffness kept old factors");
    f.bonds.back().live = 0;
    s.graph.bonds.put(f.bonds);
    ++key[0].topology;
    s.keys.put(key);
    b = referenceRhs(f);
    require(s.run(b, false)[0].status == E::SolveStatus::NeedsSetup, "stale topology accepted");
    success(s.run(b));
    residualCheck(f, b, s.solution.get());
    require(s.setup.get()[0].builds == 3, "deletion setup not rebuilt");
    f.fixed.assign(6, 0);
    s.graph.fixed.put(f.fixed);
    ++key[0].supports;
    s.keys.put(key);
    std::vector<E::Vector> q(6);
    for (unsigned i = 0; i < 6; ++i)
        for (unsigned k = 0; k < 6; ++k)
            q[i].v[k] = std::sin(6 * i + k);
    b = denseProduct(f, f.matrix(), q);
    success(s.run(b));
    residualCheck(f, b, s.solution.get());
    require(s.setup.get()[0].free == 1 && s.setup.get()[0].builds == 4, "support release did not rebuild modes");
    const auto basis = s.basis.get();
    success(s.run(b));
    const auto retained = s.basis.get();
    require(
        !std::memcmp(basis.data(), retained.data(), basis.size() * sizeof(E::Matrix)), "unchanged free basis rebuilt");
    for (auto& edge : f.bonds)
        edge.live = 0;
    s.graph.bonds.put(f.bonds);
    ++key[0].topology;
    s.keys.put(key);
    require(s.run(std::vector<E::Vector>(6))[0].status == E::SolveStatus::InvalidInput,
            "stale connected partition accepted after split");
}
void keyCoverage()
{
    Fixture f;
    Solver s(f, { 0, 6 }, { 1 });
    const auto b = referenceRhs(f);
    success(s.run(b));
    using Revision = uint64_t E::SetupKey::*;
    for (Revision member :
         { &E::SetupKey::identity, &E::SetupKey::generation, &E::SetupKey::topology, &E::SetupKey::geometry,
           &E::SetupKey::stiffness, &E::SetupKey::supports, &E::SetupKey::layout })
    {
        auto keys = s.keys.get();
        ++(keys[0].*member);
        s.keys.put(keys);
        require(s.run(b, false)[0].status == E::SolveStatus::NeedsSetup, "revision mismatch accepted");
        success(s.run(b));
    }
    require(s.setup.get()[0].builds == 8, "revision rebuild count");
    s.length.put({ 4 });
    require(s.run(b, false)[0].status == E::SolveStatus::NeedsSetup, "changed scaling accepted without setup");
    success(s.run(b));
    residualCheck(f, b, s.solution.get());
    using Setting = double E::SolveProfile::*;
    for (Setting member :
         { &E::SolveProfile::rankTolerance, &E::SolveProfile::nullspaceTolerance, &E::SolveProfile::pivotTolerance })
    {
        s.profile.*member *= .9;
        require(s.run(b, false)[0].status == E::SolveStatus::NeedsSetup, "changed setup tolerance accepted");
        success(s.run(b));
    }
    const auto builds = s.setup.get()[0].builds;
    s.profile.relativeTolerance *= .8;
    s.profile.checkInterval = 3;
    success(s.run(b));
    require(s.setup.get()[0].builds == builds, "stopping settings invalidated unchanged factors");
}
void selectiveRebuild()
{
    Fixture f, asset;
    const unsigned width = asset.x.size(), edges = asset.bonds.size();
    for (auto x : asset.x)
    {
        x.x += 16;
        f.x.push_back(x);
    }
    for (auto e : asset.bonds)
    {
        e.first += width;
        e.second += width;
        e.point[0] += 16;
        f.bonds.push_back(e);
    }
    f.starts.pop_back();
    for (unsigned i = 0; i < width; ++i)
    {
        f.fixed.push_back(asset.fixed[i]);
        f.starts.push_back(f.refs.size());
        for (unsigned j = asset.starts[i]; j < asset.starts[i + 1]; ++j)
            f.refs.push_back(edges + asset.refs[j]);
    }
    f.starts.push_back(f.refs.size());
    f.external.insert(f.external.end(), asset.external.begin(), asset.external.end());
    f.prescribed.insert(f.prescribed.end(), asset.prescribed.begin(), asset.prescribed.end());
    Solver s(f, { 0, 6, 12 }, { 1, 1 });
    const auto b = referenceRhs(f);
    success(s.run(b));
    auto key = s.keys.get();
    ++key[1].geometry;
    s.keys.put(key);
    const auto stale = s.run(b, false);
    require(stale[0].status == E::SolveStatus::LinearConverged && stale[1].status == E::SolveStatus::NeedsSetup,
            "stale component affected unchanged neighbor");
    success(s.run(b));
    const auto state = s.setup.get();
    require(state[0].builds == 1 && state[1].builds == 2, "unchanged neighbor rebuilt");
    residualCheck(f, b, s.solution.get());
}
Fixture nativeFreeChain()
{
    // Native ordinal 130, component 211: four free chunks and three live
    // interfaces. Ordinary FP64 K*N overestimated a rigid-mode defect by 2x.
    Fixture f;
    f.x = {{3.5, 1, -1.5}, {3.5, 1, -.5}, {3.5, 1, .5}, {3.5, 1, 1.5}};
    f.fixed.assign(4, 0);f.external.assign(4, {});f.prescribed.assign(4, {});
    f.bonds.clear();f.starts={0,1,3,5,6};f.refs={0,0,1,1,2,2};
    for (unsigned i=0;i<3;++i)
    {
        E::Bond e{};e.first=i;e.second=i+1;e.live=1;
        e.point[0]=3.5;e.point[1]=1;e.point[2]=double(i)-1;
        e.frame[0]=e.frame[4]=e.frame[8]=1;
        for(unsigned k=0;k<6;++k)e.stiffness.v[7*k]=k<3?1e6:1e4;
        f.bonds.push_back(e);
    }
    return f;
}
void nativeFragmentNullspace()
{
    auto f=nativeFreeChain();
    Solver s(f,{0,4},{1});
    success(s.run(std::vector<E::Vector>(4)));
    const auto basis=s.basis.get();
    // Independent full endpoint-matrix action in extended precision, on all
    // six exported modes. These exact dyadic fixture geometry matrices do not
    // import GPU endpoint/compensated helpers into the reference calculation.
    long double maximum=0;
    for(unsigned mode=0;mode<6;++mode)
    {
        std::vector<long double> action(f.size());
        for(const auto& e:f.bonds)
        {
            const auto g=f.G(e);long double delta[6]{},stress[6]{};
            for(unsigned r=0;r<6;++r)
                for(unsigned j=0;j<f.size();++j)
                    delta[r]+=static_cast<long double>(g[r*f.size()+j])*basis[j/6].v[6*(j%6)+mode];
            for(unsigned r=0;r<6;++r)
                for(unsigned c=0;c<6;++c)stress[r]+=static_cast<long double>(e.stiffness.v[6*r+c])*delta[c];
            for(unsigned j=0;j<f.size();++j)
                for(unsigned r=0;r<6;++r)action[j]+=static_cast<long double>(g[r*f.size()+j])*stress[r];
        }
        long double norm=0;for(auto value:action)norm+=value*value;
        norm=std::sqrt(norm);maximum=std::max(maximum,norm);
        require(std::isfinite(norm) && norm<=s.profile.nullspaceTolerance,"independent native rigid-mode defect");
    }
    std::cout<<"native fragment maximum independent nullspace defect "<<double(maximum)<<'\n';
    // A genuinely tighter request still rejects this FP64 basis. Accurate
    // evaluation is not permission to discard a failed nullspace condition.
    s.profile.nullspaceTolerance=1e-12;
    require(s.run(std::vector<E::Vector>(4))[0].status==E::SolveStatus::ModelUnsupported,
            "failed tighter nullspace tolerance silently accepted");
}
void isolatedNullspace()
{
    auto f=nativeFreeChain();
    for(auto& bond:f.bonds)bond.live=0;
    Solver s(f,{0,1,2,3,4},{.25,1,4,1e-6});
    success(s.run(std::vector<E::Vector>(4)));
    const auto basis=s.basis.get();const auto setup=s.setup.get();const auto factors=s.factors.get();
    for(unsigned i=0;i<4;++i)
    {
        require(setup[i].free && !setup[i].factorsValid,"isolated setup lost free-body semantics");
        for(unsigned r=0;r<6;++r)
            for(unsigned c=0;c<6;++c)
                require(basis[i].v[6*r+c]==double(r==c) && factors[i].v[6*r+c]==0,
                        "isolated nullspace is not the exact coordinate basis");
    }
    std::vector<E::Vector> loads(4);
    for(unsigned i=0;i<4;++i)loads[i].v[i%2?4:0]=1;
    for(const auto& receipt:s.run(loads))
        require(receipt.status==E::SolveStatus::IncompatibleLoad,"isolated nonzero force/moment accepted");
    // A live edge cannot be dismissed as an isolated zero operator.
    f.bonds[0].live=1;s.graph.bonds.put(f.bonds);
    auto keys=s.keys.get();for(auto& key:keys)++key.topology;s.keys.put(keys);
    for(const auto& receipt:s.run(std::vector<E::Vector>(4)))
        require(receipt.status==E::SolveStatus::InvalidInput,"unclosed singleton partition accepted");
}
int main()
{
    try
    {
        changedLoadAndOperator();
        keyCoverage();
        selectiveRebuild();
        nativeFragmentNullspace();
        isolatedNullspace();
        check(cudaGetLastError());
        check(cudaDeviceSynchronize());
        std::cout
            << "PASS: persistent setup, changed loads/history, stale revision rejection, coefficient/deletion/support rebuild, scaling/profile invalidation, selective component rebuild\n";
    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << '\n';
        return 1;
    }
}
