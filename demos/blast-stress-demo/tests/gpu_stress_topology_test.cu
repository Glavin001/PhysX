#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <memory>
#include <numeric>
#include <stdexcept>
#include <vector>
using namespace Nv::Blast;
namespace {
void require(bool ok,const char* message) { if(!ok)throw std::runtime_error(message); }
void check(cudaError_t r) { if(r!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(r)); }
struct Release { void operator()(ExtStressGpuSolver* s)const { if(s)s->release(); } };
using Solver=std::unique_ptr<ExtStressGpuSolver,Release>;
template<class T> std::vector<T> read(const T* p,unsigned n) {
    std::vector<T> out(n); if(n)check(cudaMemcpy(out.data(),p,sizeof(T)*n,cudaMemcpyDeviceToHost)); return out;
}
struct Producer {
    unsigned *mask=nullptr,*accept=nullptr; std::uint64_t* generation=nullptr;
    ExtStressGpuImpulse* inputs=nullptr;
    cudaStream_t stream=nullptr; cudaEvent_t ready=nullptr;
    Producer(unsigned n,unsigned m) {
        check(cudaMalloc(&mask,sizeof(unsigned)*m));check(cudaMalloc(&accept,sizeof(unsigned)));
        check(cudaMalloc(&generation,sizeof(*generation)));check(cudaMalloc(&inputs,sizeof(*inputs)*n));
        check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
        check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    }
    ~Producer() { cudaStreamSynchronize(stream);cudaFree(mask);cudaFree(accept);cudaFree(generation);cudaFree(inputs);cudaEventDestroy(ready);cudaStreamDestroy(stream); }
};
__global__ void setRevision(std::uint64_t* gen,unsigned* accept,std::uint64_t revision,unsigned allowed)
{ *gen=revision;*accept=allowed; }
__global__ void makeMask(unsigned* mask,unsigned n,unsigned first,unsigned second,unsigned value,bool reset)
{
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    if(reset)mask[i]=1;
    if(i==first || i==second)mask[i]=value;
}
__global__ void setLoad(ExtStressGpuImpulse* values,unsigned n,unsigned change)
{
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    values[i]={{0.125f*float(i%3),0,0.25f},{0.5f+float(change),-2.0f*float(i%4),0.25f}};
}
ExtStressGpuBond bond(const std::vector<ExtStressGpuNode>& nodes,unsigned a,unsigned b) {
    ExtStressGpuBond out{};out.node0=a;out.node1=b;
    for(unsigned k=0;k<3;++k) { out.centroid[k]=(nodes[a].position[k]+nodes[b].position[k])*0.5f;out.normal[k]=nodes[b].position[k]-nodes[a].position[k]; }
    return out;
}
void checkGraph(ExtStressGpuSolver& solver,const std::vector<ExtStressGpuNode>& nodes,
    const std::vector<ExtStressGpuBond>& bonds,const std::vector<unsigned>& alive,std::uint64_t generation,unsigned error=0)
{
    const auto view=solver.deviceView();check(cudaEventSynchronize(static_cast<cudaEvent_t>(view.readyEvent)));
    const auto status=read(view.topologyStatus,1)[0];
    require(status.generation==generation && status.error==error,"topology transaction status mismatch");
    const auto nl=read(view.nodeIslands,nodes.size()),bl=read(view.bondIslands,bonds.size());
    std::vector<unsigned> parent(nodes.size()),flags(nodes.size());std::iota(parent.begin(),parent.end(),0u);
    auto root=[&](unsigned a){while(parent[a]!=a)a=parent[a];return a;};
    for(unsigned i=0;i<bonds.size();++i)if(alive[i] && nodes[bonds[i].node0].mass>0 && nodes[bonds[i].node1].mass>0) {
        const auto a=root(bonds[i].node0),b=root(bonds[i].node1);parent[std::max(a,b)]=std::min(a,b);
    }
    unsigned activeBonds=0,activeNodes=0,islands=0;
    for(unsigned i=0;i<bonds.size();++i) {
        unsigned expected=~0u;const auto b=bonds[i];
        if(alive[i]) {
            if(nodes[b.node0].mass>0)expected=root(b.node0);
            else if(nodes[b.node1].mass>0)expected=root(b.node1);
        }
        if(expected!=~0u) { flags[expected]=1;++activeBonds; }
        require(bl[i]==expected,"GPU bond component differs from independent CPU connectivity");
    }
    for(unsigned i=0;i<nodes.size();++i) {
        const auto r=root(i);const auto expected=nodes[i].mass>0 && flags[r]?r:~0u;
        if(expected!=~0u)++activeNodes;if(flags[i])++islands;
        require(nl[i]==expected,"GPU node component joined through support or lost connectivity");
    }
    if(status.activeBondCount!=activeBonds || status.activeNodeCount!=activeNodes || status.islandCount!=islands)
        std::fprintf(stderr,"counts: GPU bonds=%u nodes=%u islands=%u; CPU bonds=%u nodes=%u islands=%u\n",
            status.activeBondCount,status.activeNodeCount,status.islandCount,activeBonds,activeNodes,islands);
    require(status.activeBondCount==activeBonds && status.activeNodeCount==activeNodes && status.islandCount==islands,"GPU active counts differ from graph truth");
}
void small() {
    std::vector<ExtStressGpuNode> nodes(12);
    for(unsigned i=0;i<nodes.size();++i)nodes[i]={{float(i/4)*10,float(i%4),0},i==0 || i==4?0.0f:1.0f,i==0 || i==4?0.0f:0.5f};
    std::vector<ExtStressGpuBond> bonds;
    for(unsigned i=0;i<nodes.size();++i)if(i%4)bonds.push_back(bond(nodes,i-1,i));
    bonds.push_back(bond(nodes,1,3)); // cycle among dynamic nodes
    bonds.push_back(bond(nodes,0,3)); // shared support must not bridge a later split
    std::vector<unsigned> alive(bonds.size(),1),slots(bonds.size());std::iota(slots.begin(),slots.end(),0u);
    Solver reference(ExtStressGpuSolver::create(nodes.data(),nodes.size(),bonds.data(),bonds.size()));
    Solver resident(ExtStressGpuSolver::create(nodes.data(),nodes.size(),bonds.data(),bonds.size()));
    require(reference && resident,"stress topology solver creation failed");
    require(resident->enableDeviceTopology(),"device topology configuration failed");
    Producer p(nodes.size(),bonds.size());
    makeMask<<<1,32,0,p.stream>>>(p.mask,bonds.size(),~0u,~0u,0,true);
    ExtStressGpuSolveParams params;params.maxIterations=128;params.tolerance=1e-5f;
    auto solve=[&](unsigned revision) {
        setLoad<<<1,32,0,p.stream>>>(p.inputs,nodes.size(),revision);
        check(cudaEventRecord(p.ready,p.stream));
        require(resident->solveDeviceAsync(p.inputs,nodes.size(),params,p.ready),"device topology solve submission failed");
        require(resident->telemetry().hostToDeviceBytes==0 && resident->telemetry().deviceToHostBytes==0,"resident solve transferred host data");
        check(cudaEventSynchronize(p.ready)); // test observer, not solver scheduling
        const auto inputs=read(p.inputs,nodes.size());
        if(!slots.empty())require(reference->solve(inputs.data(),params),"host topology reference solve failed");
        std::vector<ExtStressGpuImpulse> expected(slots.size());
        if(!slots.empty())require(reference->readbackImpulses(expected.data(),expected.size()),"reference force observation failed");
        auto view=resident->deviceView();check(cudaEventSynchronize(static_cast<cudaEvent_t>(view.readyEvent)));
        const auto actual=read(view.bondImpulses,bonds.size());const auto state=read(view.topologyStatus,1)[0];
        require(state.solvedGeneration==state.generation,"stress output generation not updated");
        float worst=0;
        for(unsigned i=0;i<bonds.size();++i) {
            ExtStressGpuImpulse e{};auto slot=std::find(slots.begin(),slots.end(),i);
            if(slot!=slots.end())e=expected[slot-slots.begin()];
            const float a[]={actual[i].angular.x,actual[i].angular.y,actual[i].angular.z,actual[i].linear.x,actual[i].linear.y,actual[i].linear.z};
            const float v[]={e.angular.x,e.angular.y,e.angular.z,e.linear.x,e.linear.y,e.linear.z};
            for(unsigned k=0;k<6;++k){require(std::isfinite(a[k]),"nonfinite post-break force");worst=std::max(worst,std::abs(a[k]-v[k])/std::max(1.0f,std::abs(v[k])));}
            if(!alive[i])for(float value:a)require(value==0,"dead bond retained force");
        }
        std::printf("generation %llu force relative error %g\n",static_cast<unsigned long long>(state.generation),worst);
        require(worst<2e-4f,"device topology changes failed force parity");
    };
    auto update=[&](std::uint64_t gen,unsigned accept=1) {
        setRevision<<<1,1,0,p.stream>>>(p.generation,p.accept,gen,accept);
        check(cudaEventRecord(p.ready,p.stream));
        require(resident->updateDeviceTopologyAsync(p.mask,bonds.size(),p.generation,p.accept,p.ready),"GPU topology update submission failed");
        require(resident->telemetry().hostToDeviceBytes==0 && resident->telemetry().deviceToHostBytes==0,"GPU topology update transferred host data");
    };
    auto remove=[&](unsigned id) {
        alive[id]=0;auto it=std::find(slots.begin(),slots.end(),id);require(it!=slots.end(),"invalid reference removal");
        require(reference->removeBond(it-slots.begin()),"reference removal failed");*it=slots.back();slots.pop_back();
    };
    checkGraph(*resident,nodes,bonds,alive,0);solve(0);
    // Break the chain edge while its alternate dynamic path remains alive.
    makeMask<<<1,32,0,p.stream>>>(p.mask,bonds.size(),1,~0u,0,false);update(1);remove(1);
    checkGraph(*resident,nodes,bonds,alive,1);solve(1);
    auto state=read(resident->deviceView().topologyStatus,1)[0];update(1);
    checkGraph(*resident,nodes,bonds,alive,1);
    require(read(resident->deviceView().topologyStatus,1)[0].rebuilds==state.rebuilds,"unchanged generation rebuilt topology");
    // This cut disconnects the dynamic graph even though both components touch support 0.
    makeMask<<<1,32,0,p.stream>>>(p.mask,bonds.size(),9,~0u,0,false);update(2);remove(9);
    checkGraph(*resident,nodes,bonds,alive,2);solve(0);solve(2);
    resident->resetWarmStart();reference->resetWarmStart();solve(2);
    update(3,0);checkGraph(*resident,nodes,bonds,alive,2);
    makeMask<<<1,32,0,p.stream>>>(p.mask,bonds.size(),0,~0u,2,false);update(3);
    checkGraph(*resident,nodes,bonds,alive,2,1);
    makeMask<<<1,32,0,p.stream>>>(p.mask,bonds.size(),0,~0u,1,false);
    makeMask<<<1,32,0,p.stream>>>(p.mask,bonds.size(),1,~0u,1,false);update(3);
    checkGraph(*resident,nodes,bonds,alive,2,2);
    makeMask<<<1,32,0,p.stream>>>(p.mask,bonds.size(),1,~0u,0,false);update(1);
    checkGraph(*resident,nodes,bonds,alive,2,4);update(2);solve(1);
    for(unsigned i=0;i<bonds.size();++i)if(alive[i])remove(i);
    check(cudaMemsetAsync(p.mask,0,sizeof(unsigned)*bonds.size(),p.stream));update(3);
    checkGraph(*resident,nodes,bonds,alive,3);solve(0);
    require(!resident->removeBond(0) && !resident->solveDevice(p.inputs,nodes.size(),params),"mixed host topology mutation was accepted");
}
__global__ void partitionLarge(unsigned* mask,unsigned n) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=2*n)return;
    const unsigned a=i%n,b=(a+(i<n?1u:997u))%n;
    mask[i]=a/1000==b/1000;
}
void large() {
    constexpr unsigned n=100000,m=200000;
    std::vector<ExtStressGpuNode> nodes(n);std::vector<ExtStressGpuBond> bonds(m);std::vector<unsigned> alive(m,1);
    for(unsigned i=0;i<n;++i)nodes[i]={{float(i%100),float(i/100),0},i?1.0f:0.0f,i?0.5f:0.0f};
    for(unsigned i=0;i<m;++i)bonds[i]=bond(nodes,i%n,((i%n)+(i<n?1u:997u))%n);
    Solver resident(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),m));
    require(resident && resident->enableDeviceTopology(),"large resident topology configuration failed");
    checkGraph(*resident,nodes,bonds,alive,0);
    Producer p(n,m);partitionLarge<<<(m+255)/256,256,0,p.stream>>>(p.mask,n);
    setRevision<<<1,1,0,p.stream>>>(p.generation,p.accept,1,1);check(cudaEventRecord(p.ready,p.stream));
    require(resident->updateDeviceTopologyAsync(p.mask,m,p.generation,p.accept,p.ready),"large device topology split failed");
    for(unsigned i=0;i<m;++i)alive[i]=bonds[i].node0/1000==bonds[i].node1/1000;
    checkGraph(*resident,nodes,bonds,alive,1);
    require(read(resident->deviceView().topologyStatus,1)[0].islandCount==100,"large split did not produce 100 stress components");
    check(cudaMemsetAsync(p.mask,0,sizeof(unsigned)*m,p.stream));
    check(cudaMemsetAsync(p.inputs,0,sizeof(ExtStressGpuImpulse)*n,p.stream));
    setRevision<<<1,1,0,p.stream>>>(p.generation,p.accept,2,1);check(cudaEventRecord(p.ready,p.stream));
    require(resident->updateDeviceTopologyAsync(p.mask,m,p.generation,p.accept,p.ready),"large all-bond removal failed");
    std::fill(alive.begin(),alive.end(),0u);checkGraph(*resident,nodes,bonds,alive,2);
    ExtStressGpuSolveParams params;require(resident->solveDeviceAsync(p.inputs,n,params,p.ready),"bondless resident solve failed");
    const auto view=resident->deviceView();check(cudaEventSynchronize(static_cast<cudaEvent_t>(view.readyEvent)));
    for(const auto& f:read(view.bondImpulses,m))
        require(f.angular.x==0 && f.angular.y==0 && f.angular.z==0 && f.linear.x==0 && f.linear.y==0 && f.linear.z==0,"removed large graph retained stress");
    require(read(view.status,1)[0].converged,"empty stress graph did not converge");
    std::puts("100000-node / 200000-bond device stress connectivity and removal passed");
}
}
int main(){try{small();large();std::puts("resident GPU stress topology passed");return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
