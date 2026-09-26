// Public native API regression: Blast stores angular coordinates with the
// opposite handed sign (PxgDestructionRuntime: inputs.angular = -torque/inertia).
// A free two-node bond carrying a known shear force F at its midpoint c must be
// recovered exactly from inputs in that convention, and not from un-negated
// Newton-Euler inputs. Found on 2026-09-26 when an oracle omitted the negation.
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <cmath>
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <vector>
using namespace Nv::Blast;
namespace {
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
void check(cudaError_t value){if(value!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(value));}
struct Release{void operator()(ExtStressGpuSolver* s)const{if(s)s->release();}};
void wait(ExtStressGpuSolver& s){check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(s.deviceView().readyEvent)));}
// Solve one frame from device-resident inputs; returns (converged, first bond impulse).
std::pair<bool,ExtStressGpuImpulse> solve(const std::vector<ExtStressGpuNode>& nodes,const std::vector<ExtStressGpuBond>& bonds,
    const std::vector<ExtStressGpuImpulse>& input){
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),nodes.size(),bonds.data(),bonds.size()));
    require(bool(solver) && solver->enableDeviceTopology(),"solver initialization failed");
    cudaStream_t producer=nullptr;cudaEvent_t ready=nullptr;
    check(cudaStreamCreateWithFlags(&producer,cudaStreamNonBlocking));check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    wait(*solver);auto view=solver->deviceView();
    check(cudaMemcpyAsync(view.nodeInputs,input.data(),input.size()*sizeof(input[0]),cudaMemcpyHostToDevice,producer));check(cudaEventRecord(ready,producer));
    ExtStressGpuSolveParams params;params.maxIterations=512;params.tolerance=1e-6f;params.warmStart=false;
    require(solver->solveDeviceAsync(view.nodeInputs,input.size(),params,ready),"solve submission rejected");wait(*solver);
    ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,solver->deviceView().status,sizeof(status),cudaMemcpyDeviceToHost));
    ExtStressGpuImpulse bond{};check(cudaMemcpy(&bond,solver->deviceView().bondImpulses,sizeof(bond),cudaMemcpyDeviceToHost));
    cudaEventDestroy(ready);cudaStreamDestroy(producer);
    return {status.converged!=0,bond};
}
}
int main(){std::setvbuf(stdout,nullptr,_IOLBF,0);
    try{
        const std::vector<ExtStressGpuNode> nodes={{{0,0,0},2,.5f},{{1,0,0},3,.8f}};
        ExtStressGpuBond edge{};edge.node0=0;edge.node1=1;edge.normal[1]=1;edge.health=.65f;edge.centroid[0]=.5f;
        const std::vector<ExtStressGpuBond> bonds={edge};
        const float F[3]={0,1,0},c[3]={.5f,0,0};
        for(int sign:{-1,1}){
            std::vector<ExtStressGpuImpulse> input(2);
            for(unsigned n=0;n<2;++n){const float s=n==0?1.f:-1.f,*x=nodes[n].position;
                const float r[3]={c[0]-x[0],c[1]-x[1],c[2]-x[2]},f[3]={s*F[0],s*F[1],s*F[2]};
                const float t[3]={r[1]*f[2]-r[2]*f[1],r[2]*f[0]-r[0]*f[2],r[0]*f[1]-r[1]*f[0]};
                input[n].linear={f[0]/nodes[n].mass,f[1]/nodes[n].mass,f[2]/nodes[n].mass};
                input[n].angular={sign*t[0]/nodes[n].inertia,sign*t[1]/nodes[n].inertia,sign*t[2]/nodes[n].inertia};}
            const auto [converged,b]=solve(nodes,bonds,input);
            const float error=std::abs(std::abs(b.linear.y)-1)+std::abs(b.linear.x)+std::abs(b.linear.z)+std::abs(b.angular.x)+std::abs(b.angular.y)+std::abs(b.angular.z);
            std::printf("angular input %s: converged=%d bond linear=(%g,%g,%g) angular=(%g,%g,%g)\n",sign<0?"in Blast convention":"un-negated (not Blast)",
                int(converged),b.linear.x,b.linear.y,b.linear.z,b.angular.x,b.angular.y,b.angular.z);
            if(sign<0)require(converged && error<1e-4f,"Blast-convention shear bond not recovered exactly");
            else require(error>.1f,"un-negated angular input unexpectedly recovered the shear bond");
        }
        return 0;
    }catch(const std::exception& e){std::fprintf(stderr,"angular convention: %s\n",e.what());return 1;}
}
