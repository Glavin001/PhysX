// CPU adapter for validating native factor plans against saved equations.
#include "StressSharedFactorPlan.h"
#include <chrono>
#include <fstream>
#include <iostream>
using namespace NativeStressFactors;
struct SavedNode {float inertia[2],rhs[6],residual[6],threshold;std::uint32_t component;};
struct SavedBond {std::uint32_t first,second;float offset0[3],offset1[3],health,scale,warm[6];};
static_assert(sizeof(SavedNode)==64&&sizeof(SavedBond)==64,"capture schema");
template<class T>std::vector<T> read(const std::string& path) {
    std::ifstream f(path,std::ios::binary|std::ios::ate);require(bool(f),"missing capture");
    auto bytes=f.tellg();require(bytes>=0&&std::uint64_t(bytes)%sizeof(T)==0,"capture length");
    std::vector<T> v(std::size_t(bytes)/sizeof(T));f.seekg(0);
    f.read(reinterpret_cast<char*>(v.data()),bytes);require(bool(f),"capture read failed");return v;
}
template<class T>void write(const std::string& path,const std::vector<T>& v) {
    std::ofstream f(path,std::ios::binary);require(bool(f),"output open failed");
    f.write(reinterpret_cast<const char*>(v.data()),v.size()*sizeof(T));f.close();require(bool(f),"output write failed");
}
template<class Fn>void rejects(Fn f) {bool rejected=false;try{f();}catch(const std::runtime_error&){rejected=true;}require(rejected,"invalid input accepted");}
void selfTest() {
    std::vector<Node> n{{0,0,noComponent},{2,3,1},{0,0,noComponent},{2,3,3}};
    std::vector<Bond> b{{0,1,{0,0,0},{0,0,0},1,4},{2,3,{0,0,0},{0,0,0},.25f,4}};
    auto g=plan(n,b);require(g.size()==1&&g[0].members.size()==2&&g[0].anchored,"equal operators not shared");
    auto a=assemble(g[0]);require(a.rows==6&&a.values.size()==6,"single-anchor matrix structure");
    for(int i=0;i<6;++i)require(a.columns[i]==i&&a.values[i]==(i<3?64:144),"independent diagonal oracle failed");
    // Material health differs above; only changing liveness changes B.
    auto damaged=b;damaged[1].health=0;require(plan(n,damaged).size()==1&&plan(n,damaged)[0].members.size()==1,"dead bond retained");
    auto mass=n;mass[3].linearWeight=4;require(plan(mass,b).size()==2,"different mass weighting aliased");
    auto geometry=b;geometry[1].offset1[0]=1;require(plan(n,geometry).size()==2,"different lever arm aliased");
    auto scale=b;scale[1].scale=2;require(plan(n,scale).size()==2,"different coupling scale aliased");
    auto crossed=b;crossed[0].first=3;rejects([&]{plan(n,crossed);});
    auto bounds=b;bounds[0].first=99;rejects([&]{plan(n,bounds);});
    auto invalid=n;invalid[0].linearWeight=1;rejects([&]{plan(invalid,b);});
    auto nonfinite=b;nonfinite[0].scale=std::numeric_limits<float>::quiet_NaN();rejects([&]{plan(n,nonfinite);});
    std::vector<Node> freeNodes{{1,1,0},{1,1,0}};
    std::vector<Bond> freeBonds{{0,1,{0,0,0},{0,0,0},1,1}};
    auto free=plan(freeNodes,freeBonds);require(free.size()==1&&!free[0].anchored,"free component classified anchored");
    auto f=assemble(free[0]);require(f.rows==12&&f.values.size()==24,"free pair Laplacian structure");
    for(int row=0;row<12;++row){double sum=0;for(int k=f.begin[row];k<f.begin[row+1];++k)sum+=f.values[k];require(sum==0,"free translation nullspace lost");}
    std::cout<<"Native factor plan independent diagonal/nullspace and invalidation tests passed\n";
}
int main(int argc,char** argv){try{
    selfTest();if(argc==2&&std::string(argv[1])=="--self-test")return 0;
    require(argc==3,"capture-prefix output-directory");const std::string prefix=argv[1],out=argv[2];
    auto sn=read<SavedNode>(prefix+".nodes.bin");auto sb=read<SavedBond>(prefix+".bonds.bin");
    std::vector<Node> nodes;std::vector<Bond> bonds;
    for(const auto& n:sn)nodes.push_back({n.inertia[0],n.inertia[1],n.component});
    for(const auto& e:sb)bonds.push_back({e.first,e.second,{e.offset0[0],e.offset0[1],e.offset0[2]},{e.offset1[0],e.offset1[1],e.offset1[2]},e.health,e.scale});
    const auto start=std::chrono::steady_clock::now();auto groups=plan(nodes,bonds);
    const double planMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
    std::ofstream j(out+"/groups.json");require(bool(j),"cannot create manifest");j<<"{\"plan_host_ms\":"<<planMs<<",\"groups\":[";
    for(std::size_t i=0;i<groups.size();++i){
        const auto& g=groups[i];const auto begin=std::chrono::steady_clock::now();auto matrix=assemble(g);
        const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-begin).count();
        const auto base=out+"/group-"+std::to_string(i);
        write(base+".rows.i32",matrix.begin);write(base+".cols.i32",matrix.columns);write(base+".values.f64",matrix.values);
        if(i)j<<',';j<<"{\"index\":"<<i<<",\"rows\":"<<matrix.rows<<",\"nnz\":"<<matrix.values.size()<<",\"anchored\":"<<(g.anchored?"true":"false")<<",\"assembly_host_ms\":"<<ms<<",\"members\":[";
        for(std::size_t k=0;k<g.members.size();++k){const auto& m=g.members[k];if(k)j<<',';j<<"{\"id\":"<<m.component<<",\"nodes\":[";
            for(std::size_t v=0;v<m.nodes.size();++v){if(v)j<<',';j<<m.nodes[v];}j<<"],\"bonds\":[";
            for(std::size_t v=0;v<m.bonds.size();++v){if(v)j<<',';j<<m.bonds[v];}j<<"]}";}
        j<<"]}";
    }
    j<<"]}\n";j.close();require(bool(j),"manifest write failed");return 0;
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
