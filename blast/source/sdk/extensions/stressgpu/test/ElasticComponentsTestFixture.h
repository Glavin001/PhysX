#pragma once
// SPDX-License-Identifier: BSD-3-Clause
#include "ElasticPcgTestFixture.h"
#include "../detail/StressElasticComponents.cuh"
#include <fstream>
#include <memory>
#include <queue>
namespace P=E::Partition;
template<class T> std::vector<T> prefixRead(const Device<T>& buffer,size_t count) {
    require(count<=buffer.n,"readback prefix exceeds capacity");std::vector<T> result(count);
    if(count)check(cudaMemcpy(result.data(),buffer.p,count*sizeof(T),cudaMemcpyDeviceToHost));
    return result;
}
std::vector<uint32_t> offsets(unsigned n) {
    std::vector<uint32_t> v(n+1);std::iota(v.begin(),v.end(),0);return v;
}
void adjacency(Fixture& f) {
    std::vector<std::vector<uint32_t>> edges(f.x.size());
    for(unsigned e=0;e<f.bonds.size();++e) {edges[f.bonds[e].first].push_back(e);edges[f.bonds[e].second].push_back(e);}
    f.starts.clear();f.refs.clear();
    for(const auto& list:edges) {f.starts.push_back(f.refs.size());f.refs.insert(f.refs.end(),list.begin(),list.end());}
    f.starts.push_back(f.refs.size());
}
void edge(Fixture& f,unsigned a,unsigned b,const E::Bond& model) {
    auto e=model;e.first=a;e.second=b;
    e.point[0]=(f.x[a].x+f.x[b].x)/2;e.point[1]=(f.x[a].y+f.x[b].y)/2;e.point[2]=(f.x[a].z+f.x[b].z)/2;
    f.bonds.push_back(e);
}
Fixture sharedSupports() {
    Fixture f;const auto model=f.bonds.front();
    f.x={{0,0,0},{1,0,.2},{2,0,.3},{3,0,0},{1,2,.1},{2,2,.5},{3,2,0},{0,2,0}};
    f.fixed={1,0,0,0,0,0,0,1};f.bonds.clear();
    for(auto pair:std::vector<std::pair<unsigned,unsigned>>{{0,1},{1,2},{2,3},{7,4},{4,5},{5,6},{0,7}})
        edge(f,pair.first,pair.second,model);
    f.external.resize(8);f.prescribed.resize(8);
    for(unsigned i=0;i<8;++i)for(unsigned k=0;k<6;++k) {
        f.external[i].v[k]=sin(6*i+k+.2);f.prescribed[i].v[k]=.04*cos(6*i+k+.7);
    }
    adjacency(f);return f;
}
struct Partition {
    Solver solve;
    Device<uint32_t> parents,roots,ids,sortedRoots,flags,prefix;
    Device<P::State> state;
    P::Storage storage{};
    std::unique_ptr<Device<char>> scratch;
    E::SetupKey key{1,1,1,1,1,1,1};
    explicit Partition(const Fixture& f):solve(f,offsets(f.x.size()),std::vector<double>(f.x.size(),1)),
        parents(f.x.size()),roots(f.x.size()),ids(f.x.size()),sortedRoots(f.x.size()),flags(f.x.size()),prefix(f.x.size()),state(1) {
        const auto n=unsigned(f.x.size());
        storage={n,parents.p,roots.p,ids.p,sortedRoots.p,solve.nodes.p,flags.p,prefix.p,solve.starts.p,solve.owner.p,solve.local.p,solve.length.p,solve.keys.p};
        size_t bytes=0;check(P::scratchBytes(solve.graph.graph,storage,bytes));scratch.reset(new Device<char>(bytes));
        solve.components=P::view(storage,state.p);
        solve.solution.put(std::vector<E::Vector>(n));
    }
    void rebuild(const Fixture& f) {
        solve.graph.fixed.put(f.fixed);solve.graph.bonds.put(f.bonds);
        require(!solve.graph.validate(),"edited graph invalid");
        ++key.layout;
        check(P::build(solve.graph.graph,storage,state.p,solve.graph.error.p,1,key,scratch->p,scratch->n));
        check(cudaDeviceSynchronize());
    }
    unsigned oracle(const Fixture& f) {
        auto s=state.get()[0];require(s.ready && !s.error,"partition not ready");
        std::vector<uint32_t> expected(f.x.size(),E::Unowned),order;
        unsigned groups=0;
        // Independent serial graph traversal, excluding every prescribed node.
        for(unsigned seed=0;seed<f.x.size();++seed)if(!f.fixed[seed] && expected[seed]==E::Unowned) {
            std::queue<unsigned> queue;queue.push(seed);expected[seed]=groups;
            while(!queue.empty()) {
                const auto i=queue.front();queue.pop();
                for(auto k=f.starts[i];k<f.starts[i+1];++k) {
                    const auto& e=f.bonds[f.refs[k]];const auto j=e.first==i?e.second:e.first;
                    if(e.live && !f.fixed[j] && expected[j]==E::Unowned){expected[j]=groups;queue.push(j);}
                }
            }
            ++groups;
        }
        require(groups==s.count,"component count disagrees with traversal");
        const auto owners=solve.owner.get(),nodes=solve.nodes.get(),starts=prefixRead(solve.starts,s.count+1),local=solve.local.get();
        require(owners==expected,"unknown owner disagrees with traversal");
        std::vector<uint32_t> counts(groups),expectedStarts(groups+1),expectedNodes(s.nodes),cursor(groups);
        for(auto group:expected)if(group!=E::Unowned)++counts[group];
        std::partial_sum(counts.begin(),counts.end(),expectedStarts.begin()+1);
        require(expectedStarts==starts,"component start/count");
        for(unsigned i=0;i<f.x.size();++i)if(expected[i]!=E::Unowned) {
            const auto group=expected[i],offset=cursor[group]++;
            expectedNodes[expectedStarts[group]+offset]=i;
            require(local[i]==offset,"local order");
        }
        require(std::equal(expectedNodes.begin(),expectedNodes.end(),nodes.begin()),"unstable sorted node order");
        for(unsigned i=0;i<f.x.size();++i)if(f.fixed[i])require(local[i]==E::Unowned,"prescribed local ownership");
        return groups;
    }
    void run(const Fixture& f,const std::vector<E::Vector>& rhs) {
        const auto count=oracle(f);
        // No host read of count participates in dispatch: Solver launches its
        // allocation capacity and every kernel reads the device active count.
        const auto result=solve.run(rhs);
        require(!solve.error.get()[0],"component inverse validation failed");
        for(unsigned i=0;i<count;++i) require(result[i].status==E::SolveStatus::LinearConverged,"partitioned solve failed");
        auto q=solve.solution.get();
        for(unsigned i=0;i<f.x.size();++i)if(f.fixed[i])q[i]={};
        residualCheck(f,rhs,q);
    }
};
