// Independent CPU stress oracle against the actual device-topology native path.
// CPU copies here are test observations, not part of production execution.
#include "NvBlastExtStressGpu.h"
#include "stress_solver/stress.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <vector>
using namespace Nv::Blast;
namespace {
void require(bool ok,const char* text){if(!ok)throw std::runtime_error(text);}
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
struct Release {void operator()(ExtStressGpuSolver* p)const{if(p)p->release();}};
struct Producer {
    cudaStream_t stream=nullptr;cudaEvent_t ready=nullptr;
    Producer(){check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
        try{check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));}catch(...){cudaStreamDestroy(stream);throw;}}
    ~Producer(){cudaStreamSynchronize(stream);cudaEventDestroy(ready);cudaStreamDestroy(stream);}
};
void run(bool supported,unsigned extent){
    const unsigned n=extent*extent*2;
    std::vector<ExtStressGpuNode> nodes(n);std::vector<SolverNodeS> cpuNodes(n);
    auto id=[=](unsigned x,unsigned y,unsigned z){return x+extent*y+extent*extent*z;};
    for(unsigned z=0;z<2;++z)for(unsigned y=0;y<extent;++y)for(unsigned x=0;x<extent;++x){
        const unsigned i=id(x,y,z);const float mass=supported && !i?0:1+float(i%3)*.25f,inertia=mass*.5f;
        nodes[i]={{float(x),float(y),float(z)},mass,inertia};cpuNodes[i].CoM={float(x),float(y),float(z)};cpuNodes[i].mass=mass;cpuNodes[i].inertia=inertia;
    }
    std::vector<ExtStressGpuBond> bonds;std::vector<SolverBond> cpuBonds;
    auto edge=[&](unsigned a,unsigned b){ExtStressGpuBond e{};SolverBond c{};e.node0=c.nodes[0]=a;e.node1=c.nodes[1]=b;
        for(unsigned k=0;k<3;++k)e.centroid[k]=(nodes[a].position[k]+nodes[b].position[k])*.5f;
        c.centroid={e.centroid[0],e.centroid[1],e.centroid[2]};bonds.push_back(e);cpuBonds.push_back(c);};
    for(unsigned z=0;z<2;++z)for(unsigned y=0;y<extent;++y)for(unsigned x=0;x<extent;++x){
        if(x+1<extent)edge(id(x,y,z),id(x+1,y,z));if(y+1<extent)edge(id(x,y,z),id(x,y+1,z));if(z<1)edge(id(x,y,z),id(x,y,z+1));}
    StressProcessor cpu;StressProcessor::DataParams preparation;preparation.equalizeMasses=true;preparation.centerBonds=true;
    cpu.prepare(cpuNodes.data(),n,cpuBonds.data(),cpuBonds.size(),preparation);
    std::unique_ptr<ExtStressGpuSolver,Release> gpu(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),bonds.size()));
    require(gpu && gpu->enableDeviceTopology(),"3D native topology initialization failed");
    Producer resources;const auto producer=resources.stream;const auto ready=resources.ready;
    std::vector<AngLin6> cpuLoads(n),expected(bonds.size());std::vector<ExtStressGpuImpulse> loads(n),actual(bonds.size());
    StressProcessor::SolverParams cpuParams;cpuParams.maxIter=4000;cpuParams.tolerance=1e-7f;
    ExtStressGpuSolveParams params;params.maxIterations=256;params.tolerance=1e-5f;
    for(float amplitude:{.5f,1.f,0.f,-.75f}){
        for(unsigned i=0;i<n;++i){const float a=supported && !i?0:amplitude;
            // Nonzero net force and torque deliberately exercise free-body
            // projection, alongside spatially varying force and bending loads.
            loads[i].angular={a*.0625f*float(int(i%3)-1),a*.125f,a*.03125f*float(int(i%5)-2)};
            loads[i].linear={a*.125f*float(int(i%4)-2),-a,a*.25f*float(int(i%3)-1)};
            cpuLoads[i].ang={loads[i].angular.x,loads[i].angular.y,loads[i].angular.z};cpuLoads[i].lin={loads[i].linear.x,loads[i].linear.y,loads[i].linear.z};}
        const int iterations=cpu.solve(expected.data(),cpuLoads.data(),cpuParams);require(iterations>=0,"3D independent CPU oracle did not converge");
        auto v=gpu->deviceView();check(cudaStreamWaitEvent(producer,reinterpret_cast<cudaEvent_t>(v.readyEvent),0));
        check(cudaMemcpyAsync(v.nodeInputs,loads.data(),n*sizeof(loads[0]),cudaMemcpyHostToDevice,producer));check(cudaEventRecord(ready,producer));
        require(gpu->solveDeviceAsync(v.nodeInputs,n,params,ready),"3D native solve rejected");v=gpu->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(v.readyEvent)));
        ExtStressGpuDeviceStatus status{};ExtStressGpuDeviceTopologyStatus topology{};
        check(cudaMemcpy(&status,v.status,sizeof(status),cudaMemcpyDeviceToHost));check(cudaMemcpy(&topology,v.topologyStatus,sizeof(topology),cudaMemcpyDeviceToHost));
        std::printf("native 3D nodes=%u bonds=%zu supported=%u amplitude=%g iterations=%u converged=%u topology_error=%u CPU_iterations=%d\n",n,bonds.size(),supported,amplitude,status.iterations,status.converged,topology.error,iterations);std::fflush(stdout);
        require(!topology.error && status.converged && status.iterations<=params.maxIterations,"3D native solve did not converge");
        check(cudaMemcpy(actual.data(),v.bondImpulses,actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));double maximum=0;
        for(unsigned i=0;i<bonds.size();++i){const auto e=expected[i];const auto a=actual[i];
            const std::array<float,6> reference{e.ang.x,e.ang.y,e.ang.z,e.lin.x,e.lin.y,e.lin.z},candidate{a.angular.x,a.angular.y,a.angular.z,a.linear.x,a.linear.y,a.linear.z};
            for(unsigned k=0;k<6;++k){const double error=std::abs(double(reference[k])-candidate[k])/std::max(1.,std::abs(double(reference[k])));maximum=std::max(maximum,error);require(std::isfinite(error),"3D nonfinite bond force");}}
        std::printf("native 3D all-force/moment maximum_relative_error=%.9g\n",maximum);std::fflush(stdout);require(maximum<2e-4,"3D native bond forces differ from independent CPU oracle");
        // Solve the oracle independently from zero for each input.
        params.warmStart=true;
    }
}
}
int main(){unsigned failures=0;
    for(unsigned extent:{3u,23u})for(bool supported:{false,true})try{run(supported,extent);}
    catch(const std::exception& e){++failures;std::fprintf(stderr,"3D fixture extent=%u supported=%u failed: %s\n",extent,supported,e.what());}
    return failures?1:0;
}
