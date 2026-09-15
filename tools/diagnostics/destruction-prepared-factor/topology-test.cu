// Compile against the actual isolated topology kernels (generated header).
#include <cuda_runtime.h>
#include <algorithm>
#include <cstdint>
#include <iostream>
#include <numeric>
#include <random>
#include <stdexcept>
#include <vector>
#include "NvBlastExtStressGpu.h"
using Nv::Blast::ExtStressGpuDeviceTopologyStatus;
constexpr unsigned kNoIsland=~0u;
constexpr unsigned kDeadBondRef=~0u;
struct Inertia { float angular,linear; };
#include "topology-kernels.cuh"
void ck(cudaError_t result) { if(result!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(result)); }
template<class T>struct Device {
    T* p;size_t n;
    Device(size_t count):n(count){ck(cudaMalloc(&p,n*sizeof(T)));ck(cudaMemset(p,0,n*sizeof(T)));}
    ~Device(){cudaFree(p);}
    void put(const std::vector<T>& v){if(v.size()!=n)throw std::runtime_error("upload size");ck(cudaMemcpy(p,v.data(),n*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get(){std::vector<T> v(n);ck(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
struct Expected { std::vector<unsigned> nodes,bonds,parent; };
Expected reference(const std::vector<Inertia>& weights,const std::vector<unsigned>& a,const std::vector<unsigned>& b,const std::vector<unsigned>& mask) {
    Expected result;result.parent.resize(weights.size());std::iota(result.parent.begin(),result.parent.end(),0u);
    auto root=[&](unsigned x){while(result.parent[x]!=x)x=result.parent[x];return x;};
    for(size_t i=0;i<a.size();++i)if(mask[i] && weights[a[i]].linear && weights[b[i]].linear) {
        unsigned x=root(a[i]),y=root(b[i]);result.parent[std::max(x,y)]=std::min(x,y);
    }
    for(size_t i=0;i<weights.size();++i)result.parent[i]=weights[i].linear?root(i):kNoIsland;
    result.bonds.resize(a.size(),kNoIsland);std::vector<bool> active(weights.size(),false);
    for(size_t i=0;i<a.size();++i)if(mask[i]) {
        unsigned x=weights[a[i]].linear?result.parent[a[i]]:result.parent[b[i]];
        result.bonds[i]=x;if(x!=kNoIsland)active[x]=true;
    }
    result.nodes=result.parent;
    for(auto& id:result.nodes)if(id!=kNoIsland && !active[id])id=kNoIsland;
    return result;
}
void run(const char* name,unsigned assets,unsigned nodesPerAsset,bool loops,unsigned rounds) {
    unsigned n=assets*nodesPerAsset;std::vector<Inertia> weights(n,{1,1});
    std::vector<unsigned> a,b;
    for(unsigned asset=0;asset<assets;++asset) {
        unsigned base=asset*nodesPerAsset;weights[base]={0,0};
        for(unsigned j=1;j<nodesPerAsset;++j){a.push_back(base+j-1);b.push_back(base+j);}
        if(loops)for(unsigned j=3;j<nodesPerAsset;j+=3){a.push_back(base+j-2);b.push_back(base+j);}
    }
    // Different dynamic components share a fixed anchor, which must not join them.
    if(assets>1){a.push_back(0);b.push_back(nodesPerAsset+1);}
    unsigned m=a.size(),nb=(n+255)/256,mb=(m+255)/256;
    Device<Inertia> inertia(n);inertia.put(weights);
    Device<unsigned> da(m),db(m),mask(m),parent(n),identity(std::max(n,m)),flags(n),forest(m),nodeLabels(n),bondLabels(m);
    Device<float> health(m);health.put(std::vector<float>(m,1));da.put(a);db.put(b);
    Device<DeviceStressTopologyBatch> batch(1);batch.put({{mask.p,nullptr,nullptr}});
    Device<ExtStressGpuDeviceTopologyStatus> state(1);
#ifdef EXPERIMENT_PREPARED_NEIGHBORS
    std::vector<std::vector<unsigned>> perNode(n);
    for(unsigned i=0;i<m;++i) { perNode[a[i]].push_back(i);perNode[b[i]].push_back(i|0x80000000u); }
    std::vector<unsigned> begins(1,0),references;
    for(auto& row:perNode) {
        references.insert(references.end(),row.begin(),row.end());
        references.push_back(kDeadBondRef); // validate explicit dead CSR slots too
        begins.push_back(unsigned(references.size()));
    }
    Device<unsigned> dbegin(begins.size()),dref(references.size()),neighbors(references.size());
    dbegin.put(begins);dref.put(references);
#endif
    std::vector<unsigned> live(m,1);std::mt19937 random(913);
    auto previous=reference(weights,a,b,live);std::vector<unsigned> previousForest;
    unsigned long long unchangedNodes=0,skippedLiveEdges=0;
    for(unsigned round=0;round<rounds;++round) {
        auto before=live;
        if(round==1 && nodesPerAsset>3)live[1]=0; // tree split or redundant cycle cut
        else if(round>2)for(unsigned j=0;j<1+round%7;++j)live[random()%m]=0;
        // round two deliberately changes no edges.
        std::vector<unsigned> dirty(n,0);
        if(round)for(unsigned i=0;i<m;++i)if(before[i]&&!live[i]&&previous.bonds[i]!=kNoIsland)dirty[previous.bonds[i]]=1;
        mask.put(live);ck(cudaMemset(flags.p,0,n*sizeof(unsigned)));
        markChangedStressComponents<<<mb,256>>>(batch.p,state.p,health.p,bondLabels.p,flags.p,m);
        if(flags.get()!=dirty)throw std::runtime_error("producer dirty set mismatch");
        auto oldParent=parent.get();
#ifdef EXPERIMENT_PREPARED_NEIGHBORS
        refreshDeviceStressOperatorNeighbors<<<nb,256>>>(batch.p,state.p,dbegin.p,dref.p,da.p,db.p,inertia.p,health.p,nodeLabels.p,flags.p,neighbors.p,n);
        initializeDeviceStressTopology<<<std::max(nb,mb),256>>>(batch.p,inertia.p,parent.p,identity.p,flags.p,health.p,n,m,forest.p);
        connectDeviceStressTopology<<<mb,256>>>(da.p,db.p,health.p,inertia.p,m,parent.p,forest.p);
        flattenDeviceStressTopology<<<nb,256>>>(parent.p,n);
#else
        initializeDeviceStressTopology<<<std::max(nb,mb),256>>>(batch.p,inertia.p,parent.p,identity.p,flags.p,health.p,n,m,forest.p,nodeLabels.p,bondLabels.p,flags.p,state.p);
        connectDeviceStressTopology<<<mb,256>>>(da.p,db.p,health.p,inertia.p,m,parent.p,forest.p,bondLabels.p,flags.p,state.p);
        flattenDeviceStressTopology<<<nb,256>>>(parent.p,n,nodeLabels.p,flags.p,state.p);
#endif
        ck(cudaMemset(flags.p,0,n*sizeof(unsigned)));
        labelDeviceStressBonds<<<mb,256>>>(da.p,db.p,health.p,inertia.p,parent.p,flags.p,bondLabels.p,m);
        labelDeviceStressNodes<<<nb,256>>>(parent.p,flags.p,nodeLabels.p,n,state.p);
        ck(cudaGetLastError());ck(cudaDeviceSynchronize());
        auto expected=reference(weights,a,b,live);
        auto actualParent=parent.get(),actualForest=forest.get();
        if(nodeLabels.get()!=expected.nodes || bondLabels.get()!=expected.bonds)throw std::runtime_error("independent membership mismatch");
#ifdef EXPERIMENT_PREPARED_NEIGHBORS
        auto cached=neighbors.get();
        for(unsigned node=0;node<n;++node)if(weights[node].linear) {
            for(unsigned slot=begins[node];slot<begins[node+1];++slot) {
                unsigned ref=references[slot],want=kNoIsland;
                if(ref!=kDeadBondRef && live[ref&0x7fffffffu]) {
                    unsigned other=(ref>>31)?a[ref&0x7fffffffu]:b[ref&0x7fffffffu];
                    if(weights[other].linear || weights[other].angular)want=other;
                }
                if(cached[slot]!=want)throw std::runtime_error("prepared neighbor mismatch");
            }
        }
#else
        if(round) {
            for(unsigned i=0;i<n;++i)if(previous.nodes[i]==kNoIsland||!dirty[previous.nodes[i]]) {
                ++unchangedNodes;if(actualParent[i]!=oldParent[i])throw std::runtime_error("unchanged parent overwritten");
            }
            for(unsigned i=0;i<m;++i)if(previous.bonds[i]==kNoIsland||!dirty[previous.bonds[i]]) {
                if(live[i])++skippedLiveEdges;
                if(actualForest[i]!=previousForest[i])throw std::runtime_error("unchanged spanning edge overwritten");
            }
        }
#endif
        // Spanning edges may differ from another legal union order, but must
        // span exactly the current dynamic membership and contain no dead edge.
        std::vector<unsigned> spanning(m,0);
        for(unsigned i=0;i<m;++i) {
            if(actualForest[i]&&!live[i])throw std::runtime_error("dead spanning edge");
            spanning[i]=actualForest[i] || (live[i]&&(!weights[a[i]].linear||!weights[b[i]].linear));
        }
        if(reference(weights,a,b,spanning).nodes!=expected.nodes)throw std::runtime_error("invalid spanning forest");
        previous=expected;previousForest=actualForest;
        auto status=state.get();status[0].initialized=1;state.put(status);
    }
    std::cout<<"{\"scenario\":\""<<name<<"\",\"nodes\":"<<n<<",\"bonds\":"<<m<<",\"transactions\":"<<rounds<<",\"unchanged_node_transactions\":"<<unchangedNodes<<",\"skipped_live_edge_transactions\":"<<skippedLiveEdges<<",\"status\":\"passed\"}\n";
}
int main(){try {
    run("anchored_chain",1,256,false,16);
    run("shared_support_cycles",4,32,true,24);
    run("many_small_islands",128,8,true,24);
    run("large_sparse_damage",250,400,true,16);
    return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
