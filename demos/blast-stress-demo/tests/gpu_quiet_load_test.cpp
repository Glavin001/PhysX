// A newly applied load must restart the Krylov recurrence even after the
// previous frame's squared gradient has decayed to a subnormal value.
#include "NvBlastExtStressGpu.h"
#include <cmath>
#include <cstdio>
#include <memory>
#include <stdexcept>
using namespace Nv::Blast;
namespace {
void require(bool condition,const char* message) {if(!condition)throw std::runtime_error(message);}
struct Release {void operator()(ExtStressGpuSolver* s) const {if(s)s->release();}};
}
int main() {
    try {
        ExtStressGpuNode nodes[2]={{{0,-1,0},0,0},{{0,0,0},2,1}};
        ExtStressGpuBond bond{};bond.node0=0;bond.node1=1;bond.centroid[1]=-0.5f;
        std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes,2,&bond,1));
        require(bool(solver),"GPU solver creation failed");
        ExtStressGpuSolveParams params;params.maxIterations=128;params.tolerance=1e-5f;
        float worst=0;
        for(unsigned tick=0;tick<34;++tick) {
            ExtStressGpuImpulse loads[2]{},force;
            if(tick==6)loads[1].linear={100,10,20};
            if(tick==33)loads[1].linear={-3.36383f,-9.21525f,0};
            require(solver->solve(loads,params),"quiet-load solve failed");
            require(solver->readbackImpulses(&force,1),"quiet-load force readback failed");
            const float applied[]={loads[1].linear.x*2,loads[1].linear.y*2,loads[1].linear.z*2};
            const float actual[]={force.linear.x,force.linear.y,force.linear.z};
            float plus=0,minus=0,scale=0;
            for(unsigned k=0;k<3;++k) {
                require(std::isfinite(actual[k]),"nonfinite bond force");
                plus+=(actual[k]-applied[k])*(actual[k]-applied[k]);
                minus+=(actual[k]+applied[k])*(actual[k]+applied[k]);
                scale+=applied[k]*applied[k];
            }
            const float error=std::sqrt(std::fmin(plus,minus))/std::fmax(1.0f,std::sqrt(scale));
            worst=std::fmax(worst,error);
            require(error<2e-4f,"supported bond did not balance the new applied load");
        }
        std::printf("GPU quiet-to-loaded recurrence passed: worst relative force error %g\n",worst);
        return 0;
    }catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}
}
