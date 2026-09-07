// Numerical stress probe using the demo's intact 444-chunk / 896-bond building
// and gravity input. No rigid-body physics, projectile, damage or correction.
#include "NvBlastExtStressGpu.cu"
#include <map>
#include <tuple>
using namespace Nv::Blast;
namespace ComponentPhaseProbe {
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
struct Release{void operator()(ExtStressGpuSolver* p)const{if(p)p->release();}};
void run(unsigned buildings){
    std::vector<ExtStressGpuNode> nodes;std::vector<ExtStressGpuBond> bonds;
    const float half=.48f,mass=1000*8*half*half*half,inertia=mass*(half*half+half*half)/3;
    for(unsigned building=0;building<buildings;++building){std::map<std::tuple<int,int,int>,unsigned> ids;
        for(int y=0;y<12;++y)for(int z=0;z<8;++z)for(int x=0;x<8;++x){
            if(x && x!=7 && z && z!=7 && y%4!=0)continue;
            const unsigned id=nodes.size();ids[{x,y,z}]=id;nodes.push_back({{float(x)-3.5f,float(y),float(z)-3.5f},y?mass:0,y?inertia:0});
            const int delta[3][3]={{-1,0,0},{0,-1,0},{0,0,-1}};
            for(const auto& d:delta){auto found=ids.find({x+d[0],y+d[1],z+d[2]});if(found==ids.end())continue;
                ExtStressGpuBond b{};b.node0=found->second;b.node1=id;b.area=4*half*half;
                for(unsigned k=0;k<3;++k){b.centroid[k]=(nodes[b.node0].position[k]+nodes[id].position[k])*.5f;b.normal[k]=nodes[id].position[k]-nodes[b.node0].position[k];}bonds.push_back(b);}
        }
    }
    if(nodes.size()!=444*buildings || bonds.size()!=896*buildings)throw std::runtime_error("building probe shape changed");
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),nodes.size(),bonds.data(),bonds.size()));
    if(!solver || !solver->enableDeviceTopology())throw std::runtime_error("probe initialization failed");
    std::vector<ExtStressGpuImpulse> inputs(nodes.size());for(unsigned i=0;i<nodes.size();++i)if(nodes[i].mass>0)inputs[i].linear.y=-9.81f;
    auto view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
    check(cudaMemcpy(view.nodeInputs,inputs.data(),inputs.size()*sizeof(inputs[0]),cudaMemcpyHostToDevice));check(cudaStreamSynchronize(nullptr));
    ExtStressGpuSolveParams params;params.maxIterations=8192;params.tolerance=1e-5f;params.warmStart=true;
    for(unsigned solve=0;solve<3;++solve){unsigned long long counters[9]{},subcounters[4]{};check(cudaMemcpyToSymbol(componentPreconditionClocks,subcounters,sizeof(subcounters)));check(cudaMemcpyToSymbol(componentPhaseClocks,counters,sizeof(counters)));check(cudaStreamSynchronize(nullptr));
        const auto start=std::chrono::steady_clock::now();
        if(!solver->solveDeviceAsync(view.nodeInputs,nodes.size(),params))throw std::runtime_error("probe solve rejected");
        view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        const double elapsed=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
        ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));check(cudaMemcpyFromSymbol(counters,componentPhaseClocks,sizeof(counters)));check(cudaMemcpyFromSymbol(subcounters,componentPreconditionClocks,sizeof(subcounters)));
        unsigned long long sum=0;for(unsigned k=0;k<8;++k)sum+=counters[k];if(sum!=counters[8])throw std::runtime_error("probe cycle partition does not close");
        std::printf("{\"buildings\":%u,\"chunks\":%zu,\"bonds\":%zu,\"solve\":%u,\"iterations\":%u,\"converged\":%u,\"stress_submission_and_completion_ms\":%.6f,\"summed_CTA_cycles\":[",buildings,nodes.size(),bonds.size(),solve,status.iterations,status.converged,elapsed);
        for(unsigned k=0;k<9;++k)std::printf("%s%llu",k?",":"",counters[k]);std::printf("],\"precondition_CTA_cycles\":[");for(unsigned k=0;k<4;++k)std::printf("%s%llu",k?",":"",subcounters[k]);std::printf("]}\n");std::fflush(stdout);
        if(!status.converged)throw std::runtime_error("probe stress did not converge");
    }
}
}
int main(int argc,char** argv){try{unsigned buildings=argc==2?std::stoul(argv[1]):1;if((buildings!=1 && buildings!=256)||argc>2)throw std::runtime_error("usage: gpu_resident_stress_phase_probe [1|256]");ComponentPhaseProbe::run(buildings);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
