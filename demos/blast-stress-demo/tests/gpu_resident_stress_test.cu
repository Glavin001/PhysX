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
        // Keep only the final column: its minimum-node ID is near capacity,
        // while its compact scheduling index is zero. This catches accidental
        // scalar addressing by compact index and stale component-list tails.
        unsigned* mask=nullptr;std::uint64_t* generation=nullptr;
        check(cudaMalloc(&mask,bonds.size()*sizeof(*mask)));
        check(cudaMalloc(&generation,sizeof(*generation)));
        check(cudaStreamWaitEvent(producer,reinterpret_cast<cudaEvent_t>(solver->deviceView().readyEvent),0));
        std::vector<unsigned> alive(bonds.size(),0u);
        std::fill(alive.end()-3,alive.end(),1u);
        check(cudaMemcpyAsync(mask,alive.data(),alive.size()*sizeof(*mask),cudaMemcpyHostToDevice,producer));
        const std::uint64_t partialGen=1;
        check(cudaMemcpyAsync(generation,&partialGen,sizeof(partialGen),cudaMemcpyHostToDevice,producer));
        check(cudaEventRecord(ready,producer));
        require(solver->updateDeviceTopologyAsync(mask,bonds.size(),generation,nullptr,ready),"partial GPU split failed");
        auto partialView=solver->deviceView();
        check(cudaStreamWaitEvent(producer,reinterpret_cast<cudaEvent_t>(partialView.readyEvent),0));
        produce<<<(n+127)/128,128,0,producer>>>(partialView.nodeInputs,n,3);
        check(cudaGetLastError());check(cudaEventRecord(ready,producer));
        require(solver->solveDeviceAsync(partialView.nodeInputs,n,params,ready),"sparse component solve failed");
        partialView=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(partialView.readyEvent)));
        ExtStressGpuDeviceTopologyStatus partialTopology{};
        ExtStressGpuDeviceStatus partialStatus{};
        check(cudaMemcpy(&partialTopology,partialView.topologyStatus,sizeof(partialTopology),cudaMemcpyDeviceToHost));
        check(cudaMemcpy(&partialStatus,partialView.status,sizeof(partialStatus),cudaMemcpyDeviceToHost));
        require(!partialTopology.error && partialTopology.islandCount==1 && partialTopology.activeBondCount==3,"sparse component count incorrect");
        require(partialStatus.converged && partialStatus.iterations<=params.maxIterations,"sparse component failed convergence");
        check(cudaMemcpy(actual.data(),partialView.bondImpulses,actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));
        for(unsigned i=0;i<actual.size();++i){
            const unsigned group=i/3,edge=i%3;
            const float expected=alive[i]?float(1+group%7)*3*(group%2?1:3-edge):0;
            const auto f=actual[i];
            for(float value:{f.linear.x,f.linear.y,f.linear.z,f.angular.x,f.angular.y,f.angular.z})
                require(std::isfinite(value),"nonfinite sparse component response");
            const float error=std::max({std::abs(std::abs(f.linear.y)-expected),std::abs(f.linear.x),std::abs(f.linear.z),std::abs(f.angular.x),std::abs(f.angular.y),std::abs(f.angular.z)})/std::max(1.f,expected);
            require(error<2e-4f,"sparse component analytic equilibrium failed");
        }
        // Split that final column into two components. Both new roots have
        // high, sparse IDs, and the compact list must grow from one to two.
        alive[alive.size()-2]=0;
        check(cudaMemcpyAsync(mask,alive.data(),alive.size()*sizeof(*mask),cudaMemcpyHostToDevice,producer));
        const std::uint64_t splitGen=2;
        check(cudaMemcpyAsync(generation,&splitGen,sizeof(splitGen),cudaMemcpyHostToDevice,producer));
        check(cudaEventRecord(ready,producer));
        require(solver->updateDeviceTopologyAsync(mask,bonds.size(),generation,nullptr,ready),"component split rejected");
        auto splitView=solver->deviceView();
        require(solver->solveDeviceAsync(splitView.nodeInputs,n,params),"split component solve failed");
        splitView=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(splitView.readyEvent)));
        ExtStressGpuDeviceTopologyStatus splitTopology{};
        ExtStressGpuDeviceStatus splitStatus{};
        check(cudaMemcpy(&splitTopology,splitView.topologyStatus,sizeof(splitTopology),cudaMemcpyDeviceToHost));
        check(cudaMemcpy(&splitStatus,splitView.status,sizeof(splitStatus),cudaMemcpyDeviceToHost));
        require(!splitTopology.error && splitTopology.islandCount==2 && splitTopology.activeBondCount==2,"component list failed to grow after split");
        require(splitStatus.converged,"split component solve did not converge");
        check(cudaMemcpy(actual.data(),splitView.bondImpulses,actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));
        for(unsigned i=0;i<actual.size();++i){
            const unsigned group=i/3,edge=i%3;const float a=float(1+group%7)*3;
            // Each free pair accelerates under its net load. Only half the
            // end-load difference is transmitted across its remaining bond.
            const float expected=alive[i]?(group%2?a*.5f:(edge==0?a:0)):0;
            const auto f=actual[i];
            for(float value:{f.linear.x,f.linear.y,f.linear.z,f.angular.x,f.angular.y,f.angular.z})
                require(std::isfinite(value),"nonfinite split component response");
            const float error=std::max({std::abs(std::abs(f.linear.y)-expected),std::abs(f.linear.x),std::abs(f.linear.z),std::abs(f.angular.x),std::abs(f.angular.y),std::abs(f.angular.z)})/std::max(1.f,expected);
            require(error<2e-4f,"split pair analytic equilibrium failed");
        }
        // Then remove every bond. The empty list must publish convergence;
        // repeating the generation must not rebuild the layout.
        check(cudaMemsetAsync(mask,0,bonds.size()*sizeof(*mask),producer));
        const std::uint64_t gen=3;
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
void mixedComponentSizes(bool interleaved)
{
    // The middle component fits one block's specialization; the last one
    // crosses its size boundary and must use cooperative iteration.
    const unsigned sizes[]={12u,1024u,1028u};
    const unsigned starts[]={0u,12u,1036u};
    const unsigned n=2064u;
    // 5 and 2064 are coprime: this is a bijection that interleaves authored
    // IDs without changing geometry, bond order, material or physical loads.
    auto nodeId=[&](unsigned i){return interleaved?(i*5u)%n:i;};
    std::vector<ExtStressGpuNode> nodes(n);
    std::vector<ExtStressGpuBond> bonds;
    std::vector<ExtStressGpuImpulse> loads(n);
    for(unsigned component=0;component<3;++component) {
        const unsigned start=starts[component],count=sizes[component];
        for(unsigned j=0;j<count;++j) {
            const unsigned i=nodeId(start+j);
            nodes[i]={{float(component)*4,float(j),0},1.f,.5f};
            // Exact eigenvector of the free path Laplacian, eigenvalue two.
            // Its prefix sums give bond forces 1,0,-1,0,... analytically.
            loads[i].linear.y=(j%4==0 || j%4==3)?1.f:-1.f;
            if(j) { ExtStressGpuBond b{};b.node0=nodeId(start+j-1);b.node1=i;
                b.centroid[0]=nodes[i].position[0];b.centroid[1]=float(j)-.5f;
                b.normal[1]=1;bonds.push_back(b); }
        }
    }
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),bonds.size()));
    require(bool(solver) && solver->enableDeviceTopology(),"mixed component initialization failed");
    ExtStressGpuSolveParams params;params.maxIterations=128;params.tolerance=1e-5f;params.warmStart=false;
    auto solve=[&]() {
        auto view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        check(cudaMemcpy(view.nodeInputs,loads.data(),n*sizeof(loads[0]),cudaMemcpyHostToDevice));
        require(solver->solveDeviceAsync(view.nodeInputs,n,params),"mixed component solve rejected");
        view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));
        return status;
    };
    require(solve().converged,"mixed component solve did not converge");
    std::vector<ExtStressGpuImpulse> actual(bonds.size());
    check(cudaMemcpy(actual.data(),solver->deviceView().bondImpulses,actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));
    unsigned bond=0;
    for(unsigned component=0;component<3;++component)for(unsigned j=0;j+1<sizes[component];++j,++bond) {
        const auto f=actual[bond];const float expected=j%2?0.f:1.f;
        for(float value:{f.linear.x,f.linear.y,f.linear.z,f.angular.x,f.angular.y,f.angular.z})
            require(std::isfinite(value),"nonfinite mixed component response");
        require(std::max({std::abs(std::abs(f.linear.y)-expected),std::abs(f.linear.x),std::abs(f.linear.z),std::abs(f.angular.x),std::abs(f.angular.y),std::abs(f.angular.z)})<2e-4f,"mixed component analytic force failed");
    }
    // A nonconverged result from EITHER specialization must reject the whole
    // solve, even when every component handled by the other one converges.
    params.maxIterations=2;
    for(unsigned component:{0u,2u}) {
        const unsigned first=nodeId(starts[component]),last=nodeId(starts[component]+sizes[component]-1);
        loads[first].linear.y+=2;loads[last].linear.y-=2;
        const auto status=solve();
        require(!status.converged && status.active && status.iterations==2,"component failure was hidden by merged status");
        loads[first].linear.y-=2;loads[last].linear.y+=2;
    }
    // These squared contributions are individually subnormal. Global float
    // atomics flush each one before adding; a shared accumulator must not
    // accidentally collect them into a normal value and change convergence.
    for(auto& load:loads)load.linear.y*=1e-20f;
    params.maxIterations=128;
    const auto tiny=solve();
    require(tiny.converged && tiny.iterations==0,"subnormal reduction changed global-atomic convergence semantics");
    check(cudaMemcpy(actual.data(),solver->deviceView().bondImpulses,actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));
    for(const auto& f:actual)for(float value:{f.linear.x,f.linear.y,f.linear.z,f.angular.x,f.angular.y,f.angular.z})
        require(value==0,"subnormal reduction changed global-atomic force response");
    std::printf("resident mixed components: nodes=%u bonds=%zu sizes=12,1024,1028 interleaved=%u analytic forces and iteration-cap rejection passed\n",n,bonds.size(),unsigned(interleaved));
}

}
int main(){try{for(bool gpu:{false,true})for(unsigned n:{12u,1536u,131072u})columns(n,gpu);mixedComponentSizes(false);mixedComponentSizes(true);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
