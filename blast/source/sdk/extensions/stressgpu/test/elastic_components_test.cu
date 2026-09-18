// SPDX-License-Identifier: BSD-3-Clause
#include "ElasticComponentsTestFixture.h"
void scans() {
    for(unsigned n:{0u,1u,31u,32u,33u,127u,128u,129u,255u,256u,257u,275u,1023u,16385u,113664u}) {
        Device<uint32_t> in(n),out(n);Device<char> scratch(P::scanBytes(n));
        std::vector<uint32_t> values(n),expected(n);
        for(unsigned i=0;i<n;++i)values[i]=(i*13+i/17)%8;
        std::partial_sum(values.begin(),values.end(),expected.begin());in.put(values);
        check(P::scan(in.p,out.p,n,reinterpret_cast<uint32_t*>(scratch.p),nullptr));
        require(out.get()==expected,"hierarchical scan differs from independent prefix sum");
    }
}
void changes() {
    auto f=sharedSupports();Partition p(f);p.rebuild(f);
    require(p.oracle(f)==2,"shared supports merged unknown components");
    const auto rhs=referenceRhs(f);p.run(f,rhs);
    // Independent dense constrained solve with nonzero prescribed transforms,
    // coupled bond stiffness and inelastic interface terms.
    const auto matrix=f.matrix();Dense a(36*36),b(36);
    for(unsigned i=0;i<36;++i){b[i]=rhs[1+i/6].v[i%6];for(unsigned j=0;j<36;++j)a[36*i+j]=matrix[(6+i)*48+6+j];}
    const auto ref=::solve(a,b);const auto q=p.solve.solution.get();
    for(unsigned i=0;i<36;++i)require(std::abs(q[1+i/6].v[i%6]-ref[i])<2e-8,"shared support dense solution");
    // Support release must JOIN the previously independent unknown systems.
    f.fixed[0]=f.fixed[7]=0;++p.key.supports;p.rebuild(f);require(p.oracle(f)==1,"released supports did not join components");
    std::vector<E::Vector> target(8);for(unsigned i=0;i<8;++i)for(unsigned k=0;k<6;++k)target[i].v[k]=sin(i*6+k);
    p.run(f,denseProduct(f,f.matrix(),target));require(p.solve.setup.get()[0].free,"released component has no free modes");
    // Re-impose supports, then cut a dynamic edge: one newly free fragment.
    f.fixed[0]=f.fixed[7]=1;f.bonds[4].live=0;++p.key.supports;++p.key.topology;p.rebuild(f);
    require(p.oracle(f)==3,"fracture did not split unknown graph");p.run(f,denseProduct(f,f.matrix(),target));
    auto state=p.solve.setup.get();require(state[2].free,"detached fragment not free");
    f.fixed.assign(8,1);++p.key.supports;p.rebuild(f);require(p.oracle(f)==0,"all-prescribed graph has iterative components");
    p.run(f,std::vector<E::Vector>(8));
    f.fixed.assign(8,0);for(auto& e:f.bonds)e.live=0;++p.key.supports;++p.key.topology;p.rebuild(f);
    require(p.oracle(f)==8,"isolated dynamic singleton missing");p.run(f,std::vector<E::Vector>(8));
    // Bad inverse entries must reject even with eliminated support holes.
    f=sharedSupports();++p.key.supports;++p.key.topology;p.rebuild(f);
    auto owner=p.solve.owner.get();owner[2]=E::Unowned;p.solve.owner.put(owner);
    for(auto r:p.solve.run(referenceRhs(f))) if(r.status!=E::SolveStatus::LinearConverged)
        require(r.status==E::SolveStatus::InvalidInput,"wrong invalid partition status");
    require(p.solve.error.get()[0],"missing unknown accepted");
    p.rebuild(f);owner=p.solve.owner.get();owner[0]=0;p.solve.owner.put(owner);
    p.solve.run(rhs);require(p.solve.error.get()[0],"unsupported prescribed ownership accepted");
    p.rebuild(f);p.solve.graph.error.put({E::InvalidGraph});
    check(P::build(p.solve.graph.graph,p.storage,p.state.p,p.solve.graph.error.p,1,p.key,p.scratch->p,p.scratch->n));
    const auto failed=p.state.get()[0];require(failed.error && !failed.ready && !failed.count && !failed.nodes,"bad graph exposed usable partition");
    Fixture empty;empty.x.clear();empty.fixed.clear();empty.bonds.clear();empty.external.clear();empty.prescribed.clear();adjacency(empty);
    Partition none(empty);none.rebuild(empty);require(none.oracle(empty)==0,"empty graph partition");
    std::cout<<"shared supports, release/join, fracture, isolated, empty and invalid mapping checks passed\n";
}
void cyclicComponent() {
    Fixture f;Partition p(f);p.rebuild(f);
    require(p.oracle(f)==1,"cyclic unknown component split");p.run(f,referenceRhs(f));
    f.bonds.back().live=0;++p.key.topology;p.rebuild(f);p.run(f,referenceRhs(f));
}
void wideComponents() {
    Fixture f;const auto model=f.bonds.front();const unsigned n=275;
    f.x.resize(n);f.fixed.assign(n,0);f.fixed[0]=1;f.bonds.clear();
    f.external.resize(n);f.prescribed.resize(n);
    for(unsigned i=0;i<n;++i)f.x[i]={.01*double(i%137),sin(.13*i),cos(.17*i)};
    for(unsigned center:{1u,138u}) {
        edge(f,0,center,model);
        for(unsigned i=center+1;i<center+137;++i)edge(f,center,i,model);
    }
    adjacency(f);Partition p(f);p.rebuild(f);require(p.oracle(f)==2,"wide shared support merged components");
    std::vector<E::Vector> target(n),sentinel(n);
    for(unsigned i=0;i<n;++i)for(unsigned k=0;k<6;++k)target[i].v[k]=sin(.2*i+k);
    sentinel[0].v[0]=NAN;p.solve.solution.put(sentinel);
    const auto rhs=sparseOracle(f,target);const auto receipts=p.solve.run(rhs);
    require(receipts.size()==2 && !p.solve.error.get()[0],"wide component validation");
    for(auto r:receipts)require(r.status==E::SolveStatus::LinearConverged,"wide component convergence");
    const auto q=p.solve.solution.get(),actual=sparseOracle(f,q);
    require(std::isnan(q[0].v[0]),"eliminated support output was traversed/written");
    for(unsigned i=0;i<n;++i)for(unsigned k=0;k<6;++k)
        require(std::abs(actual[i].v[k]-rhs[i].v[k])<2e-8*(1+std::abs(rhs[i].v[k])),"wide original equation");
    std::cout<<"two 137-unknown components sharing one prescribed support passed independent equations\n";
}
void large(const char* path) {
    Fixture f;const auto model=f.bonds.front();const unsigned n=113664;
    f.x.resize(n);f.fixed.assign(n,0);f.external.resize(n);f.prescribed.resize(n);f.bonds.clear();
    for(unsigned i=0;i<n;++i){f.x[i]={double(i%444),double(i/444),.1*double(i%7)};f.fixed[i]=i%444==0;}
    for(unsigned i=0;i<n;++i)if(i%444)edge(f,i-1,i,model);else if(i)edge(f,i-444,i,model);
    for(unsigned i=0;i<n;++i)if(i%444>=3)edge(f,i-2,i,model); // cyclic dynamic graphs, not only trees
    adjacency(f);Partition p(f);p.rebuild(f);require(p.oracle(f)==256,"large shared-support graph merged");
    p.solve.error.put({0});E::validateComponents<<<(n+127)/128,128>>>(p.solve.graph.graph,p.solve.components,p.solve.graph.error.p,p.solve.error.p);
    require(!p.solve.error.get()[0],"large partition validator");
    if(path){std::ofstream out(path,std::ios::binary);const auto state=p.state.get()[0];out.write(reinterpret_cast<const char*>(&state),sizeof(state));
        for(const auto& v:{p.solve.owner.get(),p.solve.local.get(),p.solve.nodes.get(),prefixRead(p.solve.starts,state.count+1)})out.write(reinterpret_cast<const char*>(v.data()),v.size()*sizeof(uint32_t));require(bool(out),"partition output write");}
    std::cout<<"large partition: "<<n<<" nodes, "<<f.bonds.size()<<" bonds, 256 components, 113408 unknowns; no physics steps\n";
}
int main(int argc,char** argv) {
    try {if(argc>1 && std::string(argv[1])=="--large")large(argc>2?argv[2]:nullptr);else {scans();changes();cyclicComponent();wideComponents();}return 0;}
    catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}
}
