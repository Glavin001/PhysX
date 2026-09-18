// SPDX-License-Identifier: BSD-3-Clause
#include "ElasticComponentsTestFixture.h"
#include "PxgDestructionElasticGraph.cuh"
namespace N=physx::destructionElasticGraph;
using namespace physx;

struct Native {
    Partition numerical;
    Device<PxDestructionChunkMassProperties> mass;
    Device<PxDestructionBondEndpoints> endpoints;
    Device<uint32_t> activeNodes,activeBonds;
    Device<PxDestructionTopologyStatus> status;
    Device<N::State> state;
    Device<E::SetupKey> expected;
    PxDestructionTopologyDeviceView topology{};
    PxDestructionTopologyStatus hostStatus{};
    E::SetupKey revisions{7,1,0,1,1,1,1};
    explicit Native(const Fixture& f):numerical(f),mass(f.x.size()),endpoints(f.bonds.size()),
        activeNodes(f.x.size()),activeBonds(f.bonds.size()),status(1),state(1),expected(1) {
        std::vector<PxDestructionBondEndpoints> e;
        for(const auto& bond:f.bonds)e.push_back({bond.first,bond.second});endpoints.put(e);
        topology.chunks=mass.p;topology.bonds=endpoints.p;topology.activeChunks=activeNodes.p;
        topology.activeBonds=activeBonds.p;topology.status=status.p;
        topology.chunkCount=f.x.size();topology.bondCount=f.bonds.size();
    }
    void upload(const Fixture& f,const std::vector<uint32_t>& active) {
        std::vector<PxDestructionChunkMassProperties> m(f.x.size());std::vector<uint32_t> bonds;
        for(unsigned i=0;i<f.x.size();++i)m[i].supported=f.fixed[i];
        for(const auto& e:f.bonds)bonds.push_back(e.live);
        mass.put(m);activeNodes.put(active);activeBonds.put(bonds);status.put({hostStatus});
    }
    void build() {
        auto& p=numerical;auto& graph=p.solve.graph;
        check(N::build(graph.graph,topology,graph.fixed.p,revisions,graph.limits,state.p));
        graph.graph=N::view(graph.graph,topology,graph.fixed.p);
        expected.put({revisions});graph.error.put({0});
        N::gate<<<1,1>>>(state.p,topology,expected.p,graph.error.p);
        check(P::build(graph.graph,p.storage,p.state.p,graph.error.p,1,{},p.scratch->p,p.scratch->n,nullptr,&state.p->key));
    }
};
void compareOperations(Native& native,const Fixture& effective) {
    auto& p=native.numerical;auto& g=p.solve.graph;
    require(!g.error.get()[0] && native.state.get()[0].ready,"native graph rejected");
    p.oracle(effective);
    const auto count=p.state.get()[0].count;
    for(auto key:prefixRead(p.solve.keys,count))require(key.identity==7 && key.topology==native.hostStatus.generation &&
        key.supports==native.revisions.supports && key.layout==native.revisions.layout,"device setup identity lost");
    Uploaded reference(effective);require(!reference.validate(),"reference invalid");
    Device<E::Vector> external(effective.x.size()),prescribed(effective.x.size()),rhs(effective.x.size()),
        action(effective.x.size()),response(effective.bonds.size()),referenceResponse(effective.bonds.size());
    Device<double> energy(effective.bonds.size()),referenceEnergy(effective.bonds.size());
    Device<E::Matrix> diagonal(effective.x.size()),factors(effective.x.size()),referenceDiagonal(effective.x.size()),referenceFactors(effective.x.size());
    external.put(effective.external);prescribed.put(effective.prescribed);
    E::buildRhs<<<1,128>>>(g.graph,external.p,prescribed.p,rhs.p,g.error.p);
    const auto expectedRhs=referenceRhs(effective),actualRhs=rhs.get();
    for(unsigned i=0;i<actualRhs.size();++i)for(unsigned k=0;k<6;++k)near(actualRhs[i].v[k],expectedRhs[i].v[k],"masked RHS");
    p.run(effective,actualRhs);
    E::apply<<<1,128>>>(g.graph,p.solve.solution.p,action.p,g.error.p);
    const auto expectedAction=sparseOracle(effective,p.solve.solution.get()),actualAction=action.get();
    for(unsigned i=0;i<actualAction.size();++i)for(unsigned k=0;k<6;++k)near(actualAction[i].v[k],expectedAction[i].v[k],"masked action");
    g.numerical.put({0});reference.numerical.put({0});
    E::buildDiagonal<<<1,128>>>(g.graph,diagonal.p,factors.p,g.limits,g.error.p,g.numerical.p);
    E::buildDiagonal<<<1,128>>>(reference.graph,referenceDiagonal.p,referenceFactors.p,reference.limits,reference.error.p,reference.numerical.p);
    const auto a=diagonal.get(),b=referenceDiagonal.get();
    for(unsigned i=0;i<a.size();++i)for(unsigned k=0;k<36;++k)near(a[i].v[k],b[i].v[k],"masked diagonal");
    E::recover<<<1,128>>>(g.graph,p.solve.solution.p,prescribed.p,response.p,energy.p,g.error.p);
    E::recover<<<1,128>>>(reference.graph,p.solve.solution.p,prescribed.p,referenceResponse.p,referenceEnergy.p,reference.error.p);
    const auto r=response.get(),rr=referenceResponse.get();const auto v=energy.get(),vr=referenceEnergy.get();
    for(unsigned i=0;i<r.size();++i) {
        near(v[i],vr[i],"masked energy");for(unsigned k=0;k<6;++k)near(r[i].v[k],rr[i].v[k],"masked response");
        if(!effective.bonds[i].live){near(v[i],0,"deleted energy");for(auto value:r[i].v)near(value,0,"deleted response");}
    }
}
void small() {
    auto f=sharedSupports();Native n(f);std::vector<uint32_t> active(f.x.size(),1);
    n.upload(f,active);n.build();compareOperations(n,f);
    f.bonds[1].live=0;f.bonds[4].live=0;++n.hostStatus.generation;++n.revisions.layout;
    // Free components need compatible loads. Independent manufactured equations
    // also include the original inelastic/prescribed RHS terms in other checks.
    for(auto& e:f.bonds)e.inelastic={};
    auto authored=f;for(auto& e:authored.bonds)e.live=1;n.numerical.solve.graph.bonds.put(authored.bonds);
    for(auto& v:f.prescribed)v={};
    f.external=sparseOracle(f,f.external);
    n.upload(f,active);n.build();compareOperations(n,f);
    // Removing a chunk must remove all incident bonds and exclude its unknowns.
    active[2]=0;f.bonds[2].live=0;f.fixed[2]=1;f.external[2]={};
    f.external=sparseOracle(f,f.external);++n.hostStatus.generation;++n.revisions.layout;
    n.upload(f,active);n.build();compareOperations(n,f);
    // A previously prepared graph cannot publish after a native generation edit.
    ++n.hostStatus.generation;n.status.put({n.hostStatus});n.numerical.solve.graph.error.put({0});
    N::gate<<<1,1>>>(n.state.p,n.topology,n.expected.p,n.numerical.solve.graph.error.p);
    require(n.numerical.solve.graph.error.get()[0],"stale native generation accepted");
    // Support release joins intact arms through their now-unknown supports.
    f=sharedSupports();for(auto& e:f.bonds)e.inelastic={};for(auto& v:f.prescribed)v={};
    authored=f;n.numerical.solve.graph.bonds.put(authored.bonds);
    f.fixed.assign(8,0);f.external=sparseOracle(f,f.external);active.assign(8,1);
    ++n.revisions.supports;++n.revisions.layout;n.upload(f,active);n.build();compareOperations(n,f);
    require(n.numerical.state.get()[0].count==1,"native support release did not join");
    // Invalid native masks, endpoint identity, revisions and active-dead edges.
    for(unsigned failure=0;failure<6;++failure) {
        n.upload(f,active);n.hostStatus.invalidEdit=0;n.status.put({n.hostStatus});
        auto endpoints=n.endpoints.get();const auto saved=endpoints;
        if(failure==0){auto mask=active;mask[3]=2;n.activeNodes.put(mask);}
        if(failure==1){auto mask=std::vector<uint32_t>(f.bonds.size(),1);mask[0]=2;n.activeBonds.put(mask);}
        if(failure==2){std::swap(endpoints[0].chunk0,endpoints[0].chunk1);n.endpoints.put(endpoints);}
        if(failure==3){auto mask=active;mask[3]=0;n.activeNodes.put(mask);}
        if(failure==4){n.hostStatus.invalidEdit=1;n.status.put({n.hostStatus});}
        if(failure==5)n.revisions.supports=0;
        n.build();const auto s=n.numerical.state.get()[0];
        require(!s.ready && s.error && !s.count,"invalid native graph exposed components");
        n.endpoints.put(saved);n.revisions.supports=2;
    }
    n.hostStatus.invalidEdit=0;n.upload(f,active);n.build();
    auto wrong=n.revisions;++wrong.supports;n.expected.put({wrong});n.numerical.solve.graph.error.put({0});
    N::gate<<<1,1>>>(n.state.p,n.topology,n.expected.p,n.numerical.solve.graph.error.p);
    require(n.numerical.solve.graph.error.get()[0],"stale support revision accepted");
    auto invalid=n.numerical.solve.graph.graph;++invalid.nodes;
    require(N::build(invalid,n.topology,n.numerical.solve.graph.fixed.p,n.revisions,n.numerical.solve.graph.limits,n.state.p)==cudaErrorInvalidValue,"capacity mismatch accepted");
    Fixture empty;empty.x.clear();empty.fixed.clear();empty.bonds.clear();empty.external.clear();empty.prescribed.clear();adjacency(empty);
    Native none(empty);none.upload(empty,{});none.build();require(none.state.get()[0].ready && !none.numerical.state.get()[0].count,"empty native graph");
    none.numerical.solve.graph.starts.put({1});none.build();require(!none.state.get()[0].ready,"invalid empty row accepted");
    std::cout<<"PASS native graph deletion/support/lifetime, operator/RHS/recovery and GPU solver handoff\n";
}
template<class T> std::vector<T> read(const std::string& path) {
    std::ifstream in(path,std::ios::binary|std::ios::ate);require(bool(in),"capture missing");const auto bytes=in.tellg();
    require(bytes>=0 && size_t(bytes)%sizeof(T)==0,"capture ABI");std::vector<T> result(size_t(bytes)/sizeof(T));
    in.seekg(0);in.read(reinterpret_cast<char*>(result.data()),size_t(bytes));require(bool(in),"capture read");return result;
}
void captured(const char* directory,uint64_t generation,const char* output) {
    const std::string dir=directory;const auto mass=read<PxDestructionChunkMassProperties>(dir+"/mass.bin");
    const auto endpoints=read<PxDestructionBondEndpoints>(dir+"/bond_endpoints.bin");
    const auto nodes=read<uint32_t>(dir+"/active_chunks.bin"),bonds=read<uint32_t>(dir+"/active_bonds.bin");
    Fixture authored;const auto model=authored.bonds.front();authored.x.resize(mass.size());authored.fixed.resize(mass.size());
    authored.external.resize(mass.size());authored.prescribed.resize(mass.size());authored.bonds.clear();
    require(nodes.size()==mass.size() && bonds.size()==endpoints.size(),"capture sizes");
    for(unsigned i=0;i<mass.size();++i){authored.x[i]={mass[i].center[0],mass[i].center[1],mass[i].center[2]};authored.fixed[i]=mass[i].supported;}
    for(auto e:endpoints){require(e.chunk0<mass.size() && e.chunk1<mass.size(),"capture endpoint");edge(authored,e.chunk0,e.chunk1,model);}
    adjacency(authored);Native n(authored);auto effective=authored;
    for(unsigned i=0;i<bonds.size();++i)effective.bonds[i].live=bonds[i];
    n.hostStatus.generation=generation;n.upload(effective,nodes);n.mass.put(mass);n.build();
    for(unsigned i=0;i<nodes.size();++i)if(!nodes[i])effective.fixed[i]=1;
    const auto count=n.numerical.oracle(effective);const auto state=n.numerical.state.get()[0];
    require(n.state.get()[0].ready,"native capture graph rejected");
    std::ofstream out(output,std::ios::binary);out.write(reinterpret_cast<const char*>(&state),sizeof(state));
    for(const auto& v:{n.numerical.solve.owner.get(),n.numerical.solve.local.get(),prefixRead(n.numerical.solve.nodes,state.nodes),prefixRead(n.numerical.solve.starts,count+1)})
        out.write(reinterpret_cast<const char*>(v.data()),v.size()*sizeof(uint32_t));
    require(bool(out),"capture output");
    std::cout<<"PASS captured topology: "<<nodes.size()<<" chunks, "<<bonds.size()<<" bonds, "<<std::count(bonds.begin(),bonds.end(),1u)
        <<" live bonds, "<<count<<" unknown components, "<<state.nodes<<" unknowns; supplied algebra coefficients, no material verdict/physics steps\n";
}
int main(int argc,char** argv) {
    try {if(argc==5 && std::string(argv[1])=="--capture")captured(argv[2],std::stoull(argv[3]),argv[4]);
        else {require(argc==1,"usage: --capture directory topology-generation output");small();}return 0;}
    catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}
}
