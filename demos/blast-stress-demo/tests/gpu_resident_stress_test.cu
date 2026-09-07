// The exact production resident kernel, tested without linking the reference
// backend. Analytic columns exercise single-block, multi-block and virtual-grid
// iteration, event ordering, warm starts and quiet-to-loaded restarts.
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <vector>
using namespace Nv::Blast;
namespace {
void require(bool ok,const char* what){if(!ok)throw std::runtime_error(what);}
void check(cudaError_t result){if(result!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(result));}
struct Release{void operator()(ExtStressGpuSolver* p)const{if(p)p->release();}};
__global__ void produce(ExtStressGpuImpulse* inputs,unsigned n,unsigned revision){
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    // Alternate anchored/free columns. On free columns, equal end loads form
    // a self-equilibrated axial load: no support reaction or net acceleration.
    const bool free=(i/4)%2;const float a=revision ? float(1+(i/4)%7)*revision : 0;
    ExtStressGpuImpulse value{};
    value.linear.y=free ? (i%4==0?a:(i%4==3?-a:0)) : (i%4 ? -a:0);
    inputs[i]=value;
}
void columns(unsigned n, bool deviceTopology){
    std::vector<ExtStressGpuNode> nodes(n);std::vector<ExtStressGpuBond> bonds;
    for(unsigned i=0;i<n;++i){
        const bool fixed=i%4==0 && (i/4)%2==0;
        nodes[i]={{float(i/4)*4,float(i%4),0},fixed?0.f:1.f,fixed?0.f:.5f};
        if(i%4){ExtStressGpuBond b{};b.node0=i-1;b.node1=i;
            b.centroid[0]=nodes[i].position[0];b.centroid[1]=nodes[i].position[1]-.5f;b.normal[1]=1;bonds.push_back(b);}
    }
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),bonds.size()));
    require(bool(solver),"resident solver creation failed");
    require(solver->prepareDeviceSolve(),"resident preparation failed");
    if(deviceTopology)require(solver->enableDeviceTopology(),"GPU topology preparation failed");
    cudaStream_t producer;cudaEvent_t ready;
    check(cudaStreamCreateWithFlags(&producer,cudaStreamNonBlocking));check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    ExtStressGpuSolveParams params;params.maxIterations=128;params.tolerance=1e-5f;
    std::vector<ExtStressGpuImpulse> actual(bonds.size());float worst=0;
    for(unsigned revision : {0u,1u,1u,0u,0u,3u,2u}){
        auto view=solver->deviceView();require(view.nodeInputs!=nullptr,"resident input missing");
        // The producer cannot overwrite inputs still in use by the last solve.
        check(cudaStreamWaitEvent(producer,reinterpret_cast<cudaEvent_t>(view.readyEvent),0));
        produce<<<(n+127)/128,128,0,producer>>>(view.nodeInputs,n,revision);
        check(cudaGetLastError());check(cudaEventRecord(ready,producer));
        require(solver->solveDeviceAsync(view.nodeInputs,n,params,ready),"resident solve rejected");
        const auto stats=solver->telemetry();
        require(stats.hostToDeviceBytes==0 && stats.deviceToHostBytes==0 && stats.deviceToDeviceBytes==0,"resident solve copied inputs");
        view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        ExtStressGpuDeviceStatus status;check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));
        require(status.converged && status.iterations<=params.maxIterations,"analytic solve did not converge");
        check(cudaMemcpy(actual.data(),view.bondImpulses,actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));
        for(unsigned i=0;i<actual.size();++i){
            const unsigned group=i/3,edge=i%3;const float a=float(1+group%7)*revision;
            const float expected=a*(group%2?1:3-edge);const auto f=actual[i];
            for(float value:{f.linear.x,f.linear.y,f.linear.z,f.angular.x,f.angular.y,f.angular.z})
                require(std::isfinite(value),"nonfinite bond response");
            // Bond orientation may use either action/reaction convention;
            // magnitudes, zero transverse force and zero moments are invariant.
            const float error=std::max({std::abs(std::abs(f.linear.y)-expected),std::abs(f.linear.x),std::abs(f.linear.z),std::abs(f.angular.x),std::abs(f.angular.y),std::abs(f.angular.z)})/std::max(1.f,expected);
            require(std::isfinite(error),"nonfinite bond response");worst=std::max(worst,error);
            if(error>=2e-4f){std::fprintf(stderr,"nodes=%u revision=%u bond=%u expected=%g actual=%g error=%g\n",n,revision,i,expected,f.linear.y,error);throw std::runtime_error("analytic column equilibrium failed");}
        }
    }
    if(deviceTopology){
        // Remove every bond after nonzero solves. The cached component ranges
        // become empty: no stale partial may leak into an isolated chunk's
        // response. Repeating the same generation must not rebuild the layout.
        unsigned* mask=nullptr;std::uint64_t* generation=nullptr;
        check(cudaMalloc(&mask,bonds.size()*sizeof(*mask)));
        check(cudaMalloc(&generation,sizeof(*generation)));
        check(cudaStreamWaitEvent(producer,reinterpret_cast<cudaEvent_t>(solver->deviceView().readyEvent),0));
        check(cudaMemsetAsync(mask,0,bonds.size()*sizeof(*mask),producer));
        const std::uint64_t gen=1;
        check(cudaMemcpyAsync(generation,&gen,sizeof(gen),cudaMemcpyHostToDevice,producer));
        check(cudaEventRecord(ready,producer));
        unsigned rebuilds=0;
        for(unsigned repeat=0;repeat<2;++repeat){
            require(solver->updateDeviceTopologyAsync(mask,bonds.size(),generation,nullptr,ready),"GPU split failed");
            auto view=solver->deviceView();
            check(cudaStreamWaitEvent(producer,reinterpret_cast<cudaEvent_t>(view.readyEvent),0));
            produce<<<(n+127)/128,128,0,producer>>>(view.nodeInputs,n,3);
            check(cudaGetLastError());check(cudaEventRecord(ready,producer));
            require(solver->solveDeviceAsync(view.nodeInputs,n,params,ready),"isolated solve failed");
            view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
            ExtStressGpuDeviceTopologyStatus topology{};
            check(cudaMemcpy(&topology,view.topologyStatus,sizeof(topology),cudaMemcpyDeviceToHost));
            require(!topology.error && topology.generation==gen && topology.solvedGeneration==gen,"stale GPU topology");
            require(!topology.islandCount && !topology.activeNodeCount && !topology.activeBondCount,"removed component still scheduled");
            if(repeat)require(topology.rebuilds==rebuilds,"unchanged topology rebuilt");
            rebuilds=topology.rebuilds;
            check(cudaMemcpy(actual.data(),view.bondImpulses,actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));
            for(const auto& f:actual)
                for(float value:{f.linear.x,f.linear.y,f.linear.z,f.angular.x,f.angular.y,f.angular.z})
                    require(value==0,"removed bond retained force");
        }
        check(cudaFree(mask));check(cudaFree(generation));
    }
    check(cudaEventDestroy(ready));check(cudaStreamDestroy(producer));
    std::printf("resident columns: topology=%s nodes=%u bonds=%zu worst relative error=%g\n",deviceTopology?"GPU":"asset",n,bonds.size(),worst);
}
}
int main(){try{for(bool gpu:{false,true})for(unsigned n:{12u,1536u,131072u})columns(n,gpu);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
