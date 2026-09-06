// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include <cuda_runtime.h>
#include <cub/cub.cuh>
#include "../src/PxgDestructionContactGraph.cuh"
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <numeric>
#include <random>
#include <stdexcept>
#include <vector>
using namespace physx;
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
void check(cudaError_t r){if(r!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(r));}
template<class T> struct Device {
    T* p{};explicit Device(size_t n){check(cudaMalloc(&p,std::max<size_t>(n,1)*sizeof(T)));}
    ~Device(){cudaFree(p);}
    void put(const std::vector<T>& v){if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get(size_t n){std::vector<T> v(n);if(n)check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
struct Pair {PxU32 a,b;bool touch=true,kinematic=false,disabled=false;};
// Independent serial flood fill, rather than another union-find implementation.
std::vector<PxU32> reference(PxU32 n,const std::vector<Pair>& pairs,bool accurate) {
    std::vector<std::vector<PxU32>> adj(n);
    for(const auto& p:pairs)if(p.a<n && p.b<n && !p.kinematic && (!accurate || (p.touch && !p.disabled))) {
        adj[p.a].push_back(p.b);adj[p.b].push_back(p.a);
    }
    std::vector<PxU32> labels(n,PX_INVALID_NODE),queue;
    for(PxU32 root=0;root<n;++root)if(labels[root]==PX_INVALID_NODE) {
        queue.clear();queue.push_back(root);labels[root]=root;
        for(size_t i=0;i<queue.size();++i)for(PxU32 next:adj[queue[i]])if(labels[next]==PX_INVALID_NODE){labels[next]=root;queue.push_back(next);}
    }
    return labels;
}
void verifyMemberLinks(const PxU32* labels,const std::vector<PxU32>& expected) {
    const PxU32 n=PxU32(expected.size());if(!n)return;
    Device<PxU64> input(n),sorted(n);size_t bytes=0;
    check(cub::DeviceRadixSort::SortKeys(nullptr,bytes,input.p,sorted.p,n));Device<unsigned char> scratch(bytes);
    destructionContactGraph::componentKeys<<<(n+127)/128,128>>>(labels,input.p,n);
    check(cub::DeviceRadixSort::SortKeys(scratch.p,bytes,input.p,sorted.p,n));
    auto* members=reinterpret_cast<PxU32*>(input.p);check(cudaMemset(members,0xff,size_t(n)*sizeof(PxU32)));
    destructionContactGraph::componentMembers<<<(n+127)/128,128>>>(sorted.p,members,n);
    check(cudaGetLastError());std::vector<PxU32> actual(size_t(n)*2),wanted(size_t(n)*2,PX_INVALID_NODE),last(n,PX_INVALID_NODE);
    check(cudaMemcpy(actual.data(),members,actual.size()*sizeof(PxU32),cudaMemcpyDeviceToHost));
    for(PxU32 node=0;node<n;++node) {
        const PxU32 label=expected[node];if(last[label]==PX_INVALID_NODE)wanted[label]=node;
        else wanted[size_t(n)+last[label]]=node;last[label]=node;
    }
    require(actual==wanted,"GPU membership heads/successors differ from independent stable component grouping");
}
void run(PxU32 n,const std::vector<Pair>& pairs,unsigned invalid=0,PxU32 omitted=0,const std::vector<PxU32>& retired={},const std::vector<Pair>& retained={}) {
    const PxU32 count=PxU32(pairs.size());
    std::vector<PxgShapeSim> shapes(n+1);for(PxU32 i=0;i<n;++i)shapes[i].mBodySimIndex=PxNodeIndex(i);
    shapes[n].mBodySimIndex=PxNodeIndex();
    std::vector<PxgContactManagerInput> inputs(count);
    std::vector<PxgContactGraphIdentity> ids(count);
    std::vector<PxsContactManagerOutput> outputs(count);
    for(PxU32 i=0;i<count;++i){const auto& p=pairs[i];inputs[i]={0,0,p.a<n?p.a:n,p.b<n?p.b:n};ids[i]={i,0,PxU64(i)+1};
        outputs[i].statusFlag=p.touch?PxsContactManagerStatusFlag::eHAS_TOUCH:PxsContactManagerStatusFlag::eHAS_NO_TOUCH;
        outputs[i].flags=(p.kinematic?PxgDestructionContactFlags::eKINEMATIC_PAIR:0)|(p.disabled?PxgDestructionContactFlags::eDISABLE_RESPONSE:0);
    }
    if(invalid==1)ids[0].generation=0;
    if(invalid==2)inputs[0].transformCacheRef0=n+1;
    if(invalid==3)shapes[0].mBodySimIndex=PxNodeIndex(0u,0u);
    if(invalid==4)shapes[0].mBodySimIndex=PxNodeIndex(n+1);
    Device<PxgShapeSim> dShapes(shapes.size());dShapes.put(shapes);
    Device<PxgContactManagerInput> dInputs(count);dInputs.put(inputs);
    Device<PxgContactGraphIdentity> dIds(count);dIds.put(ids);
    Device<PxsContactManagerOutput> dOutputs(count);dOutputs.put(outputs);
    Device<PxgDestructionContactEdge> edges(count);Device<PxU32> accurate(n),speculative(n);
    Device<PxgDestructionContactGraphStatus> status(1);
    Device<PxU32> retiredIds(retired.size()),mask((size_t(count)+31)/32);retiredIds.put(retired);
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    destructionContactGraph::initialize<<<(std::max(n,1u)+127)/128,128,0,stream>>>(accurate.p,speculative.p,n,status.p,omitted);
    if(!retired.empty()) {
        check(cudaMemsetAsync(mask.p,0,((size_t(count)+31)/32)*sizeof(PxU32),stream));
        destructionContactGraph::retire<<<(retired.size()+127)/128,128,0,stream>>>(retiredIds.p,PxU32(retired.size()),count,mask.p,status.p);
    }
    if(count){
        destructionContactGraph::decode<<<(count+127)/128,128,0,stream>>>(dInputs.p,dIds.p,dOutputs.p,count,dShapes.p,n+1,n,edges.p,status.p,retired.empty()?nullptr:mask.p);
        destructionContactGraph::connect<<<(count+127)/128,128,0,stream>>>(dInputs.p,dIds.p,dOutputs.p,count,dShapes.p,n+1,n,status.p,retired.empty()?nullptr:mask.p,accurate.p,speculative.p);
    }
    std::vector<PxgDestructionRetainedEdge> retainedEdges;
    for(PxU32 i=0;i<retained.size();++i) {
        const auto& p=retained[i];retainedEdges.push_back({i,p.a,p.b,
            (p.touch && !p.disabled?PxgDestructionRetainedEdge::eACCURATE:0u)|(p.kinematic?PxgDestructionRetainedEdge::eKINEMATIC:0u)});
    }
    Device<PxgDestructionRetainedEdge> dRetained(retainedEdges.size());dRetained.put(retainedEdges);
    if(!retainedEdges.empty())destructionContactGraph::connectRetained<<<(retainedEdges.size()+127)/128,128,0,stream>>>(
        dRetained.p,PxU32(retainedEdges.size()),n,accurate.p,speculative.p,status.p);
    if(n)destructionContactGraph::compress<<<(n+127)/128,128,0,stream>>>(accurate.p,speculative.p,n);
    check(cudaGetLastError());check(cudaStreamSynchronize(stream));check(cudaStreamDestroy(stream));
    const auto result=status.get(1)[0];
    const bool invalidRetirement=std::any_of(retired.begin(),retired.end(),[&](PxU32 i){return i>=count;});
    const PxU32 expected=(invalidRetirement?PxgDestructionContactGraphStatus::eINVALID_IDENTITY:0u)|(omitted?PxgDestructionContactGraphStatus::eMISSING_PAIRS:0u)|
        (invalid?(invalid==3?PxgDestructionContactGraphStatus::eUNSUPPORTED_ENDPOINT:PxgDestructionContactGraphStatus::eINVALID_IDENTITY):0u);
    require(result.error==expected && result.omittedPairs==omitted,"graph availability status mismatch");
    if(invalid || invalidRetirement)return;
    std::vector<Pair> live;
    for(PxU32 i=0;i<count;++i)if(std::find(retired.begin(),retired.end(),i)==retired.end())live.push_back(pairs[i]);
    live.insert(live.end(),retained.begin(),retained.end());
    require(accurate.get(n)==reference(n,live,true),"accurate graph differs from flood fill");
    require(speculative.get(n)==reference(n,live,false),"speculative graph differs from flood fill");
    verifyMemberLinks(accurate.p,reference(n,live,true));verifyMemberLinks(speculative.p,reference(n,live,false));
    const auto decoded=edges.get(count);for(PxU32 i=0;i<count;++i){
        require(decoded[i].identity.generation==ids[i].generation && decoded[i].identity.edgeIndex==i,"GPU graph lost pair lifetime identity");
        if(std::find(retired.begin(),retired.end(),i)!=retired.end()) {
            require((decoded[i].flags&PxgDestructionContactFlags::eRETIRED) && decoded[i].node0==PX_INVALID_NODE && decoded[i].node1==PX_INVALID_NODE,"retired edge still connects nodes");continue;
        }
        require(decoded[i].node0==pairs[i].a && decoded[i].node1==pairs[i].b,"GPU graph resolved wrong node ownership");
    }
}
void retainedTransactions() {
    constexpr PxU32 n=8,capacity=97;
    Device<PxgDestructionRetainedEdge> slots(capacity),updates(128);
    Device<PxU32> active((capacity+31)/32),counts(3),accurate(n),speculative(n);
    Device<PxgDestructionContactGraphStatus> status(1);
    check(cudaMemset(slots.p,0,capacity*sizeof(PxgDestructionRetainedEdge)));
    check(cudaMemset(active.p,0,((capacity+31)/32)*sizeof(PxU32)));check(cudaMemset(counts.p,0,3*sizeof(PxU32)));
    std::map<PxU32,PxgDestructionRetainedEdge> expected;PxU32 peak=0;
    const auto transaction=[&](std::vector<PxgDestructionRetainedEdge> batch,bool valid=true) {
        updates.put(batch);
        const auto oldSlots=slots.get(capacity);const auto oldActive=active.get((capacity+31)/32);
        destructionContactGraph::initialize<<<1,128>>>(accurate.p,speculative.p,n,status.p,0);
        check(cudaMemset(counts.p+2,0,sizeof(PxU32)));
        if(!batch.empty()) {
            destructionContactGraph::validateRetainedUpdates<<<1,128>>>(updates.p,PxU32(batch.size()),capacity,counts.p,status.p);
            destructionContactGraph::applyRetainedUpdates<<<1,128>>>(updates.p,PxU32(batch.size()),slots.p,capacity,active.p,counts.p,status.p);
            destructionContactGraph::finishRetainedUpdates<<<1,1>>>(counts.p);
        }
        destructionContactGraph::connectRetainedSlots<<<1,128>>>(slots.p,active.p,capacity,n,accurate.p,speculative.p,status.p);
        destructionContactGraph::compress<<<1,128>>>(accurate.p,speculative.p,n);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto result=status.get(1)[0];
        require(result.error==(valid?0u:PxgDestructionContactGraphStatus::eINVALID_IDENTITY),"retained transaction error status mismatch");
        if(valid) {
            for(const auto& e:batch) {
                if(e.flags&PxgDestructionRetainedEdge::eREMOVED)expected.erase(e.edgeIndex);
                else expected[e.edgeIndex]=e;
            }
            peak=std::max(peak,PxU32(expected.size()));
        } else {
            const auto current=slots.get(capacity);
            require(!std::memcmp(oldSlots.data(),current.data(),capacity*sizeof(current[0]))
                && oldActive==active.get((capacity+31)/32),"invalid retained transaction partially changed resident state");
        }
        const auto c=counts.get(3);require(c[0]==expected.size() && c[1]==peak,"resident retained counts differ from complete transaction");
        std::vector<Pair> pairs;
        for(const auto& item:expected) {
            const auto& e=item.second;pairs.push_back({e.node0,e.node1,bool(e.flags&PxgDestructionRetainedEdge::eACCURATE),bool(e.flags&PxgDestructionRetainedEdge::eKINEMATIC)});
        }
        require(accurate.get(n)==reference(n,pairs,true) && speculative.get(n)==reference(n,pairs,false),"retained delta connectivity differs from independent snapshot flood fill");
    };
    transaction({{0,0,1,1},{31,1,2,0},{32,2,3,1},{64,4,5,1},{96,6,7,1}});
    transaction({}); // No upload/rebuild of the persistent edge data.
    transaction({{31,1,2,1},{32,2,3,3}}); // Accurate change and kinematic boundary.
    transaction({{0,0,0,8},{31,0,0,8},{96,0,0,8}});
    transaction({{0,0,7,1},{31,3,4,0},{96,7,PX_INVALID_NODE,1}}); // Reused native slots, new endpoints.
    transaction({{0,0,0,8},{31,0,0,8},{32,0,0,8},{64,0,0,8},{96,0,0,8}});
    transaction({{31,0,0,8}}); // Idempotent removal, no count underflow.
    transaction({{0,0,1,1},{96,6,7,1}});
    transaction({{0,0,0,8},{97,0,1,1}},false); // Entire batch rejected before a valid-prefix deletion.
    transaction({{0,0,0,8},{32,1,2,1},{0,0,4,1},{96,1,7,1}},false); // Nonadjacent duplicate/out-of-order key.
    transaction({{0,0,0,8},{96,0,0,8}}); // Valid transaction after rejection.
    std::puts("CUDA retained registry: persistence, bit boundaries, contact changes, removal/reuse, exact counts and atomic rejection passed");
}

int main(){try{
    retainedTransactions();
    run(0,{});run(100,{});
    // A native speculative edge can have no active narrowphase manager.
    // Retained touch, no-touch, disabled response and prescribed boundaries
    // must preserve their different accurate/speculative connectivity.
    const std::vector<Pair> retained={{1,2,false},{3,4,true},{4,5,true,false,true},{0,6,true,true},{5,6,true,true},{0,PX_INVALID_NODE}};
    run(8,{{0,1},{2,3},{5,7}},0,0,{},retained);
    run(8,{},0,0,{},retained);
    run(8,{{0,1},{2,3},{5,7}}); // removed snapshot cannot retain old links

    // Untouched broadphase bridge, disabled-response bridge, cycles, common
    // static/kinematic boundaries and isolated bodies have distinct semantics.
    const std::vector<Pair> small={{0,1},{1,2},{2,0},{2,3,false},{3,4,true,false,true},{4,5},
        {0,6,true,true},{4,6,true,true},{0,PX_INVALID_NODE},{4,PX_INVALID_NODE},{5,5}};
    run(8,small);run(8,small,0,7);run(8,small,0,0,{0,1,2,2});run(8,small,0,0,{999});
    for(unsigned i=1;i<=4;++i)run(8,small,i);
    std::vector<Pair> boundaryBits;for(PxU32 i=0;i<65;++i)boundaryBits.push_back({i,i+1});
    run(66,boundaryBits,0,0,{0,31,32,63,64,32});
    std::mt19937 rng(413);
    std::vector<Pair> pairs;
    for(PxU32 i=1;i<100000;++i)if(i!=50000)pairs.push_back({i-1,i,(i%5)!=0});
    for(PxU32 i=0;i<100000;++i){const PxU32 base=(i&1)?50000:0;pairs.push_back({base+PxU32(rng()%50000),base+PxU32(rng()%50000),(i%3)!=0,false,(i%11)==0});}
    for(PxU32 i=0;i<1000;++i){pairs.push_back({i,100000,true,true});pairs.push_back({50000+i,PX_INVALID_NODE});}
    for(unsigned trial=0;trial<3;++trial){std::shuffle(pairs.begin(),pairs.end(),rng);run(100001,pairs);}
    // Rebuild after deletions/splitting: stale roots cannot carry connectivity.
    pairs.erase(std::remove_if(pairs.begin(),pairs.end(),[](const Pair& p){return p.a<50000 && p.b>=25000 && p.b<50000;}),pairs.end());
    run(100001,pairs);
    std::puts("GPU contact graph: 100001 nodes, 201998 pairs, shuffled order, split rebuild, static/kinematic boundaries, touch/response, explicit invalid inputs: passed");
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
