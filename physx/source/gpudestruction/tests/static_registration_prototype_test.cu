// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include <cuda_runtime.h>
#include <cub/cub.cuh>
#include <algorithm>
#include <cstdio>
#include <random>
#include <stdexcept>
#include <vector>
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
void require(bool b,const char* why){if(!b)throw std::runtime_error(why);}
template<class T> void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max<size_t>(n,1)*sizeof(T)));}
#include "static_registration_prototype.cuh"
template<class T> struct Buffer {
    T* p{};size_t n;
    explicit Buffer(size_t size):n(size){allocate(p,n);check(cudaMemset(p,0xfd,std::max<size_t>(n,1)*sizeof(T)));}
    ~Buffer(){cudaFree(p);}
    void upload(const std::vector<T>& v){require(v.size()==n,"upload size");if(n)check(cudaMemcpy(p,v.data(),n*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> read(){std::vector<T> v(n);if(n)check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
struct Oracle {
    struct Owner {unsigned node=~0u,kind=0;};
    std::vector<Owner> owners;std::vector<std::vector<unsigned>> lists;
    void resize(unsigned edges,unsigned nodes){owners.resize(edges);lists.resize(size_t(nodes)*2);}
    void apply(StaticCommand c){
        auto& owner=owners.at(c.edge);auto& list=lists.at(size_t(c.node)*2+c.kind);
        if(c.add){require(owner.node==~0u,"oracle duplicate add");list.push_back(c.edge);owner={c.node,c.kind};}
        else{require(owner.node==c.node && owner.kind==c.kind,"oracle stale removal");auto it=std::find(list.begin(),list.end(),c.edge);require(it!=list.end(),"oracle missing edge");list.erase(it);owner.node=~0u;}
    }
    StaticStats stats(){StaticStats s{};for(size_t i=0;i<lists.size();++i){unsigned n=unsigned(lists[i].size());if(i&1){s.joints+=n;s.maxJoints=std::max(s.maxJoints,n);}else{s.contacts+=n;s.maxContacts=std::max(s.maxContacts,n);}}return s;}
};
void verify(StaticRegistry& gpu,Oracle& cpu,StaticStats actual,cudaStream_t stream,std::mt19937& rng){
    auto expected=cpu.stats();require(actual.contacts==expected.contacts && actual.joints==expected.joints && actual.maxContacts==expected.maxContacts && actual.maxJoints==expected.maxJoints && !actual.error,"GPU aggregate disagreement");
    std::vector<unsigned> active;for(unsigned i=0;i<cpu.lists.size()/2;++i)if(i%5!=3)active.push_back(i);
    std::shuffle(active.begin(),active.end(),rng);unsigned count=unsigned(active.size());active.insert(active.begin(),3,~0u);
    Buffer<unsigned> ids(active.size());ids.upload(active);
    Buffer<unsigned> contacts(size_t(actual.maxContacts)*count),joints(size_t(actual.maxJoints)*count),nc(count),nj(count);
    gpu.gather(ids.p,3,count,contacts.p,unsigned(contacts.n),joints.p,unsigned(joints.n),nc.p,nj.p,stream);check(cudaStreamSynchronize(stream));
    auto c=contacts.read(),j=joints.read(),cs=nc.read(),js=nj.read();
    for(unsigned i=0;i<count;++i){auto& cl=cpu.lists[size_t(active[i+3])*2];auto& jl=cpu.lists[size_t(active[i+3])*2+1];
        require(cs[i]==cl.size() && js[i]==jl.size(),"GPU active membership disagreement");
        for(unsigned k=0;k<cl.size();++k)require(c[size_t(k)*count+i]==cl[k],"contact insertion/removal order changed");
        for(unsigned k=0;k<jl.size();++k)require(j[size_t(k)*count+i]==jl[k],"joint insertion/removal order changed");
    }
    StaticStats status{};check(cudaMemcpy(&status,gpu.status,sizeof(status),cudaMemcpyDeviceToHost));require(!status.error,"gather rejected valid input");
}
void run(unsigned nodes,unsigned edges,unsigned batches){
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    {
        StaticRegistry gpu;Oracle cpu;std::mt19937 rng(1967);cpu.resize(1,1);
        verify(gpu,cpu,gpu.update(nullptr,0,1,1,stream),stream,rng);
        for(unsigned batch=0;batch<batches;++batch){
            unsigned e=batch<2?std::min(32u,edges):edges,n=batch<2?std::min(4u,nodes):nodes;cpu.resize(e,n);
            std::vector<StaticCommand> tape;
            for(unsigned k=0;k<std::min(2048u,e*4);++k){unsigned id=rng()%e;auto owner=cpu.owners[id];
                StaticCommand c=owner.node==~0u?StaticCommand{id,unsigned(rng()%n),unsigned(rng()%2),1}:StaticCommand{id,owner.node,owner.kind,0};
                tape.push_back(c);cpu.apply(c);
            }
            auto s=gpu.update(tape.data(),unsigned(tape.size()),e,n,stream);verify(gpu,cpu,s,stream,rng);
            // An unchanged update neither rebuilds membership nor changes order.
            verify(gpu,cpu,gpu.update(nullptr,0,e,n,stream),stream,rng);
        }
        std::vector<StaticCommand> retire;for(unsigned i=0;i<cpu.owners.size();++i){auto o=cpu.owners[i];if(o.node!=~0u){StaticCommand c{i,o.node,o.kind,0};retire.push_back(c);cpu.apply(c);}}
        verify(gpu,cpu,gpu.update(retire.data(),unsigned(retire.size()),edges,nodes,stream),stream,rng);
        std::printf("PASS static registration: %u node slots, %u edge slots, %u batches; exact active order, growth/reuse/retirement; no stress bonds\n",nodes,edges,batches);
    }
    check(cudaStreamDestroy(stream));
}
void highDegree(){
    StaticRegistry gpu;Oracle cpu;cpu.resize(4099,2);std::mt19937 rng(7);
    std::vector<StaticCommand> tape;
    for(unsigned edge=4099;edge;--edge){StaticCommand c{edge-1,0,0,1};tape.push_back(c);cpu.apply(c);}
    verify(gpu,cpu,gpu.update(tape.data(),unsigned(tape.size()),4099,2,0),0,rng);
    tape.clear();
    for(unsigned edge=0;edge<4099;edge+=2){
        StaticCommand remove{edge,0,0,0},add{edge,1,1,1};
        tape.push_back(remove);tape.push_back(add);cpu.apply(remove);cpu.apply(add);
    }
    verify(gpu,cpu,gpu.update(tape.data(),unsigned(tape.size()),4099,2,0),0,rng);
    std::puts("PASS 4099 contacts on one node; ordered partial removal, same-batch identity reuse and joint reclassification; no stress bonds");
}
void negative(){
    for(StaticCommand bad: {StaticCommand{0,0,0,0},StaticCommand{1,0,0,1},StaticCommand{0,1,0,1},StaticCommand{0,0,2,1}}){
        StaticRegistry gpu;bool rejected=false;try{gpu.update(&bad,1,1,1,0);}catch(const std::runtime_error&){rejected=true;}require(rejected,"invalid command accepted");
        rejected=false;try{gpu.update(nullptr,0,1,1,0);}catch(const std::runtime_error&){rejected=true;}require(rejected,"invalid scene failure not latched");
    }
    StaticRegistry gpu;StaticCommand duplicates[]={{0,0,0,1},{0,0,0,1}};bool rejected=false;
    try{gpu.update(duplicates,2,1,1,0);}catch(const std::runtime_error&){rejected=true;}require(rejected,"duplicate registration accepted");
    std::puts("PASS explicit invalid/stale/duplicate registration failures");
}
int main(){try{run(513,4099,24);run(113664,32768,4);highDegree();negative();return 0;}catch(const std::exception& e){std::fprintf(stderr,"FAIL %s\n",e.what());return 1;}}
