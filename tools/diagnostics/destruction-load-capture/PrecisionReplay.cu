// SPDX-License-Identifier: BSD-3-Clause
// One captured anchored component. Diagnostic only; no material publication.
#include "ElasticPcgTestFixture.h"
#include <fstream>
#include <iomanip>
#include <unordered_map>
#include <string>
template<class T> std::vector<T> readFile(const std::string& path) {
    std::ifstream in(path,std::ios::binary|std::ios::ate);require(bool(in),"missing input");
    const auto bytes=in.tellg();require(bytes>=0 && size_t(bytes)%sizeof(T)==0,"input size");
    std::vector<T> result(size_t(bytes)/sizeof(T));in.seekg(0);in.read(reinterpret_cast<char*>(result.data()),bytes);
    require(bool(in),"input read");return result;
}
template<class T> void writeFile(const std::string& path,const std::vector<T>& values) {
    std::ofstream out(path,std::ios::binary);out.write(reinterpret_cast<const char*>(values.data()),values.size()*sizeof(T));
    require(bool(out),"output write");
}
__global__ void recoveryGate(const E::SolveReceipt* receipt,uint32_t* error) {
    if(receipt->status!=E::SolveStatus::LinearConverged)atomicOr(error,1u);
}
int main(int argc,char** argv) {
 try {
    require(argc==4 || argc==5,"usage: precision-replay fixture output-prefix standard|extended [length]");
    const std::string input=argv[1],output=argv[2],mode=argv[3];
    require(mode=="standard" || mode=="extended","invalid precision mode");
    const bool extended=mode=="extended";
    const auto native=readFile<uint32_t>(input+"/position-authored-ids.bin");
    const auto unknown=readFile<uint32_t>(input+"/unknown-authored-ids.bin");
    const auto supported=readFile<uint32_t>(input+"/prescribed-authored-ids.bin");
    const auto loads=readFile<E::Vector>(input+"/rhs.bin");
    Fixture f;f.x=readFile<double3>(input+"/positions.bin");f.bonds=readFile<E::Bond>(input+"/bonds.bin");
    require(f.x.size()==native.size() && unknown.size()==loads.size(),"fixture shapes");
    std::unordered_map<uint32_t,uint32_t> local;for(unsigned i=0;i<native.size();++i)require(local.emplace(native[i],i).second,"duplicate node");
    f.fixed.assign(native.size(),0);f.external.assign(native.size(),{});f.prescribed.assign(native.size(),{});
    for(auto id:supported)f.fixed.at(local.at(id))=1;
    for(unsigned i=0;i<unknown.size();++i){require(!f.fixed.at(local.at(unknown[i])),"fixed unknown");f.external.at(local.at(unknown[i]))=loads[i];}
    for(auto& bond:f.bonds){bond.first=local.at(bond.first);bond.second=local.at(bond.second);}
    f.starts.assign(native.size()+1,0);f.refs.clear();
    for(unsigned i=0;i<native.size();++i){f.starts[i]=f.refs.size();for(unsigned j=0;j<f.bonds.size();++j)
        if(f.bonds[j].first==i || f.bonds[j].second==i)f.refs.push_back(j);}
    f.starts.back()=f.refs.size();
    const double length=argc==5?std::stod(argv[4]):1;
    Solver s(f,{0,uint32_t(native.size())},{length});s.profile.maxIterations=8192;
    Device<E::Vector> low(native.size()),solutionLow(native.size());
    check(cudaMemset(low.p,0xff,low.n*sizeof(E::Vector)));check(cudaMemset(solutionLow.p,0xff,solutionLow.n*sizeof(E::Vector)));
    std::vector<E::SolveReceipt> receipts;
    if(extended) {
        s.workspace.xLow=low.p;s.workspace.solutionLow=solutionLow.p;s.rhs.put(f.external);
        E::validateComponents<<<(native.size()+127)/128,128>>>(s.graph.graph,s.components,s.graph.error.p,s.error.p);
        E::prepareComponents<<<1,128>>>(s.graph.graph,s.components,s.workspace,s.profile,s.keys.p,s.setup.p,s.graph.error.p,s.error.p);
        E::solveComponentsExtended<<<1,128>>>(s.graph.graph,s.components,s.rhs.p,s.initial.p,s.solution.p,s.workspace,s.profile,s.keys.p,s.setup.p,s.graph.error.p,s.error.p,s.receipts.p);
        check(cudaGetLastError());receipts=s.receipts.get();
    } else receipts=s.run(f.external);
    require(s.error.get()[0]==0,"component validation");
    Device<E::Vector> response(f.bonds.size());Device<double> energy(f.bonds.size());
    recoveryGate<<<1,1>>>(s.receipts.p,s.error.p);
    E::Accurate::recover<<<(f.bonds.size()+127)/128,128>>>(s.graph.graph,s.solution.p,s.initial.p,response.p,energy.p,s.error.p,extended?solutionLow.p:nullptr);
    check(cudaGetLastError());
    writeFile(output+".response.bin",response.get());writeFile(output+".energy.bin",energy.get());
    auto hi=s.solution.get();auto lo=extended?solutionLow.get():std::vector<E::Vector>(native.size());
    std::vector<E::Vector> orderedHi,orderedLo;
    for(auto id:unknown){orderedHi.push_back(hi.at(local.at(id)));orderedLo.push_back(lo.at(local.at(id)));}
    writeFile(output+".hi.bin",orderedHi);writeFile(output+".lo.bin",orderedLo);
    const auto r=receipts[0];std::ofstream report(output+".json");
    report<<std::setprecision(17)<<"{\"mode\":\""<<mode<<"\",\"status\":"<<unsigned(r.status)<<",\"iterations\":"<<r.iterations
      <<",\"checks\":"<<r.residualChecks<<",\"restarts\":"<<r.restarts<<",\"force\":"<<r.maxForce<<",\"torque\":"<<r.maxTorque
      <<",\"norm\":"<<r.residualNorm<<",\"unknowns\":"<<unknown.size()<<",\"bonds\":"<<f.bonds.size()<<"}\n";
    require(bool(report),"report write");std::cout<<mode<<" status="<<unsigned(r.status)<<" iterations="<<r.iterations<<" force="<<r.maxForce<<"\n";
    return r.status==E::SolveStatus::LinearConverged?0:1;
 } catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 2;}
}
