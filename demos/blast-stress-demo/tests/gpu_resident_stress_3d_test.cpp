// Independent CPU stress oracle against the actual device-topology native path.
// CPU copies here are test observations, not part of production execution.
#include "NvBlastExtStressGpu.h"
#include "stress_solver/stress.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdio>
#include <fstream>
#include <iomanip>
#include <string>
#include <memory>
#include <stdexcept>
#include <vector>
using namespace Nv::Blast;
namespace {
std::string auditPrefix;
void require(bool ok,const char* text){if(!ok)throw std::runtime_error(text);}
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
struct Release {void operator()(ExtStressGpuSolver* p)const{if(p)p->release();}};
struct Producer {
    cudaStream_t stream=nullptr;cudaEvent_t ready=nullptr;
    Producer(){check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
        try{check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));}catch(...){cudaStreamDestroy(stream);throw;}}
    ~Producer(){cudaStreamSynchronize(stream);cudaEventDestroy(ready);cudaStreamDestroy(stream);}
};
// Audit the published physical bond forces with independent long-double
// sparse arithmetic. This reads the CPU oracle's prepared coefficients; it
// does not reuse the native solver's recursive residual or convergence flag.
class ResidualAudit : public StressProcessor {
    using Triple=std::array<long double,3>;
    using Six=std::array<long double,6>;
    static Triple cross(Triple a,Triple b){return {a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]};}
public:
    // Test-only cold CGLS in long double. Independent of the CUDA operator,
    // preconditioner and recursive convergence state. Keep the original CPU
    // iteration cap/tolerance; explicitly verify B^T(rhs-B*lambda) on exit.
    std::vector<AngLin6> preciseReference(unsigned maxIterations,long double tolerance)const{
        const unsigned n=getNodeCount(),m=getBondCount();
        auto forward=[&](const std::vector<Six>& x){
            std::vector<Six> out(n);
            for(unsigned e=0;e<m;++e){const auto& c=m_couplings[e];const long double scale=getColumnScale(e);
                for(unsigned side=0;side<2;++side){const unsigned node=side?c.node1:c.node0;const auto o=side?c.offset1:c.offset0;
                    const auto d=m_recip_sqrt_I[node];const long double sign=side?-scale:scale;
                    const auto moment=cross({o.x,o.y,o.z},{x[e][3],x[e][4],x[e][5]});
                    for(unsigned k=0;k<3;++k){out[node][k]+=sign*d.I*(x[e][k]-moment[k]);out[node][k+3]+=sign*d.m*x[e][k+3];}}}
            return out;
        };
        auto transpose=[&](const std::vector<Six>& x){
            std::vector<Six> out(m);
            for(unsigned e=0;e<m;++e){const auto& c=m_couplings[e];const long double scale=getColumnScale(e);
                for(unsigned side=0;side<2;++side){const unsigned node=side?c.node1:c.node0;const auto o=side?c.offset1:c.offset0;
                    const auto d=m_recip_sqrt_I[node];const long double sign=side?-scale:scale;
                    const auto lever=cross({o.x,o.y,o.z},{d.I*x[node][0],d.I*x[node][1],d.I*x[node][2]});
                    for(unsigned k=0;k<3;++k){out[e][k]+=sign*d.I*x[node][k];out[e][k+3]+=sign*(d.m*x[node][k+3]+lever[k]);}}}
            return out;
        };
        auto norm=[](const std::vector<Six>& x){long double v=0;for(const auto& row:x)for(auto value:row)v+=value*value;return v;};
        std::vector<Six> rhs(n),lambda(m);
        for(unsigned i=0;i<n;++i){const auto b=m_rhs[i];rhs[i]={b.ang.x,b.ang.y,b.ang.z,b.lin.x,b.lin.y,b.lin.z};}
        auto residual=rhs,gradient=transpose(rhs),direction=gradient;long double gamma=norm(gradient);
        const long double threshold=norm(rhs)*tolerance*tolerance;unsigned iterations=0;
        for(;;){
            if(gamma<=threshold){
                const auto product=forward(lambda);for(unsigned i=0;i<n;++i)for(unsigned k=0;k<6;++k)residual[i][k]=rhs[i][k]-product[i][k];
                gradient=transpose(residual);gamma=norm(gradient);if(gamma<=threshold)break;direction=gradient;
            }
            require(iterations<maxIterations,"independent high-precision CGLS oracle did not converge");
            const auto product=forward(direction);const auto denominator=norm(product);
            require(denominator>0 && std::isfinite(denominator),"independent CGLS invalid direction");
            const long double alpha=gamma/denominator;
            for(unsigned e=0;e<m;++e)for(unsigned k=0;k<6;++k)lambda[e][k]+=alpha*direction[e][k];
            for(unsigned i=0;i<n;++i)for(unsigned k=0;k<6;++k)residual[i][k]-=alpha*product[i][k];
            gradient=transpose(residual);const auto next=norm(gradient);const auto beta=next/gamma;
            for(unsigned e=0;e<m;++e)for(unsigned k=0;k<6;++k)direction[e][k]=gradient[e][k]+beta*direction[e][k];
            gamma=next;++iterations;
        }
        std::vector<AngLin6> out(m);const long double linearScale=(long double)m_length_scale*m_mass_scale;
        for(unsigned e=0;e<m;++e){const long double linear=linearScale*getColumnScale(e),angular=linear*m_length_scale;
            out[e].ang={float(lambda[e][0]*angular),float(lambda[e][1]*angular),float(lambda[e][2]*angular)};
            out[e].lin={float(lambda[e][3]*linear),float(lambda[e][4]*linear),float(lambda[e][5]*linear)};}
        std::printf("independent cold CGLS iterations=%u true_gradient2=%.12Lg threshold2=%.12Lg\n",iterations,gamma,threshold);
        return out;
    }
    void dump(const std::string& path,const std::vector<AngLin6>& cpu,const std::vector<AngLin6>& native,const std::vector<AngLin6>& precise,bool converged)const{
        std::ofstream out(path);require(bool(out),"cannot open residual audit output");out<<std::setprecision(17);
        auto six=[&](const AngLin6& v){out<<v.ang.x<<","<<v.ang.y<<","<<v.ang.z<<","<<v.lin.x<<","<<v.lin.y<<","<<v.lin.z;};
        out<<"{\"length_scale\":"<<m_length_scale<<",\"mass_scale\":"<<m_mass_scale<<",\"native_converged\":"<<converged<<",\"nodes\":[";
        for(unsigned i=0;i<getNodeCount();++i){if(i)out<<",";out<<"["<<m_recip_sqrt_I[i].I<<","<<m_recip_sqrt_I[i].m<<",";six(m_rhs[i]);out<<"]";}out<<"],\"bonds\":[";
        for(unsigned i=0;i<getBondCount();++i){if(i)out<<",";const auto& c=m_couplings[i];
            out<<"["<<c.node0<<","<<c.node1<<","<<c.offset0.x<<","<<c.offset0.y<<","<<c.offset0.z<<","<<c.offset1.x<<","<<c.offset1.y<<","<<c.offset1.z<<","<<getColumnScale(i)<<",";six(cpu[i]);out<<",";six(native[i]);out<<"]";}
        out<<"],\"precise\":[";for(unsigned e=0;e<precise.size();++e){if(e)out<<",";out<<"[";six(precise[e]);out<<"]";}out<<"]}\n";require(bool(out),"failed to write residual audit output");
    }
    bool audit(const char* label,const std::vector<AngLin6>& forces,float tolerance)const{
        std::vector<Six> residual(getNodeCount());long double rhs2=0,residual2=0,gradient2=0;
        std::vector<Six> roundoff(getNodeCount());long double roundoff2=0;
        auto ulp=[](float x){return std::max(std::abs((long double)std::nextafter(x,INFINITY)-x),std::abs((long double)x-std::nextafter(x,-INFINITY)));};
        auto absCross=[](Triple o,Triple e){return Triple{std::abs(o[1])*e[2]+std::abs(o[2])*e[1],std::abs(o[2])*e[0]+std::abs(o[0])*e[2],std::abs(o[0])*e[1]+std::abs(o[1])*e[0]};};
        const long double linearScale=(long double)m_length_scale*m_mass_scale,angularScale=m_length_scale*linearScale;
        for(unsigned e=0;e<getBondCount();++e){const auto& c=m_couplings[e];const auto& f=forces[e];
            const Triple angular{f.ang.x/angularScale,f.ang.y/angularScale,f.ang.z/angularScale};
            const Triple linear{f.lin.x/linearScale,f.lin.y/linearScale,f.lin.z/linearScale};
            const Triple angularError{ulp(f.ang.x)/angularScale,ulp(f.ang.y)/angularScale,ulp(f.ang.z)/angularScale};
            const Triple linearError{ulp(f.lin.x)/linearScale,ulp(f.lin.y)/linearScale,ulp(f.lin.z)/linearScale};
            for(unsigned side=0;side<2;++side){const unsigned node=side?c.node1:c.node0;const auto o=side?c.offset1:c.offset0;
                const auto moment=cross({o.x,o.y,o.z},linear);const long double sign=side?-1:1;
                const auto momentError=absCross({o.x,o.y,o.z},linearError);
                for(unsigned k=0;k<3;++k){roundoff[node][k]+=angularError[k]+momentError[k];roundoff[node][k+3]+=linearError[k];}
                for(unsigned k=0;k<3;++k){residual[node][k]+=sign*(angular[k]-moment[k]);residual[node][k+3]+=sign*linear[k];}}
        }
        for(unsigned i=0;i<getNodeCount();++i){const auto& b=m_rhs[i];const auto d=m_recip_sqrt_I[i];const Six rhs{b.ang.x,b.ang.y,b.ang.z,b.lin.x,b.lin.y,b.lin.z};
            for(unsigned k=0;k<6;++k){rhs2+=rhs[k]*rhs[k];residual[i][k]=rhs[k]-(k<3?d.I:d.m)*residual[i][k];residual2+=residual[i][k]*residual[i][k];residual[i][k]*=k<3?d.I:d.m;roundoff[i][k]*=(k<3?d.I:d.m)*(k<3?d.I:d.m);}}
        for(unsigned e=0;e<getBondCount();++e){const auto& c=m_couplings[e];const auto a=residual[c.node0],b=residual[c.node1];
            const auto u=cross({c.offset0.x,c.offset0.y,c.offset0.z},{a[0],a[1],a[2]});
            const auto v=cross({c.offset1.x,c.offset1.y,c.offset1.z},{b[0],b[1],b[2]});const long double scale=getColumnScale(e);
            const auto ra=roundoff[c.node0],rb=roundoff[c.node1];
            const auto ua=absCross({c.offset0.x,c.offset0.y,c.offset0.z},{ra[0],ra[1],ra[2]});
            const auto ub=absCross({c.offset1.x,c.offset1.y,c.offset1.z},{rb[0],rb[1],rb[2]});
            for(unsigned k=0;k<3;++k){const auto aError=(ra[k]+rb[k])*scale,bError=(ra[k+3]+rb[k+3]+ua[k]+ub[k])*scale;roundoff2+=aError*aError+bError*bError;}
            for(unsigned k=0;k<3;++k){const long double angular=(a[k]-b[k])*scale,linear=(a[k+3]-b[k+3]+u[k]-v[k])*scale;gradient2+=angular*angular+linear*linear;}}
        std::printf("published residual label=%s rhs2=%.12Lg residual2=%.12Lg gradient2=%.12Lg threshold2=%.12Lg\n",label,rhs2,residual2,gradient2,rhs2*tolerance*tolerance);std::fflush(stdout);
        // Triangle inequality: one FP32 output ULP propagated through |B^T||B|.
        // This bounds export quantization only; it is not a fitted tolerance or
        // an allowance for an unconverged solver, missing terms or self-stress.
        const auto limit=std::sqrt(rhs2)*tolerance+std::sqrt(roundoff2);
        std::printf("independent gradient label=%s norm=%.12Lg tolerance=%.12Lg export_roundoff_bound=%.12Lg\n",label,std::sqrt(gradient2),std::sqrt(rhs2)*tolerance,std::sqrt(roundoff2));
        return std::isfinite(gradient2)&&std::isfinite(limit)&&std::sqrt(gradient2)<=limit;
    }
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
    ResidualAudit cpu;StressProcessor::DataParams preparation;preparation.equalizeMasses=true;preparation.centerBonds=true;
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
        const auto precise=cpu.preciseReference(cpuParams.maxIter,cpuParams.tolerance);
        auto v=gpu->deviceView();check(cudaStreamWaitEvent(producer,reinterpret_cast<cudaEvent_t>(v.readyEvent),0));
        check(cudaMemcpyAsync(v.nodeInputs,loads.data(),n*sizeof(loads[0]),cudaMemcpyHostToDevice,producer));check(cudaEventRecord(ready,producer));
        require(gpu->solveDeviceAsync(v.nodeInputs,n,params,ready),"3D native solve rejected");v=gpu->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(v.readyEvent)));
        ExtStressGpuDeviceStatus status{};ExtStressGpuDeviceTopologyStatus topology{};
        check(cudaMemcpy(&status,v.status,sizeof(status),cudaMemcpyDeviceToHost));check(cudaMemcpy(&topology,v.topologyStatus,sizeof(topology),cudaMemcpyDeviceToHost));
        std::printf("native 3D nodes=%u bonds=%zu supported=%u amplitude=%g iterations=%u converged=%u topology_error=%u CPU_iterations=%d\n",n,bonds.size(),supported,amplitude,status.iterations,status.converged,topology.error,iterations);std::fflush(stdout);
        check(cudaMemcpy(actual.data(),v.bondImpulses,actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));double maximum=0;
        for(unsigned i=0;i<bonds.size();++i){const auto e=precise[i];const auto a=actual[i];
            const std::array<float,6> reference{e.ang.x,e.ang.y,e.ang.z,e.lin.x,e.lin.y,e.lin.z},candidate{a.angular.x,a.angular.y,a.angular.z,a.linear.x,a.linear.y,a.linear.z};
            for(unsigned k=0;k<6;++k){const double error=std::abs(double(reference[k])-candidate[k])/std::max(1.,std::abs(double(reference[k])));maximum=std::max(maximum,error);require(std::isfinite(error),"3D nonfinite bond force");}}
        std::vector<AngLin6> published(actual.size());for(unsigned i=0;i<actual.size();++i){published[i].ang={actual[i].angular.x,actual[i].angular.y,actual[i].angular.z};published[i].lin={actual[i].linear.x,actual[i].linear.y,actual[i].linear.z};}
        cpu.audit("legacy CPU",expected,params.tolerance);
        require(cpu.audit("precise CPU",precise,params.tolerance),"independent reference fails published equilibrium gate");
        require(cpu.audit("native",published,params.tolerance),"native published forces fail independently recomputed equilibrium");
        if(amplitude==.5f){auto corrupted=published;corrupted[0].lin.x+=1;
            require(!cpu.audit("deliberate force corruption",corrupted,params.tolerance),"independent equilibrium gate missed force corruption");}
        if(!auditPrefix.empty())cpu.dump(auditPrefix+"-"+std::to_string(n)+"-"+std::to_string(supported)+"-"+std::to_string(amplitude)+".json",expected,published,precise,status.converged);
        require(!topology.error && status.converged && status.iterations<=params.maxIterations,"3D native solve did not converge");
        std::printf("native 3D all-force/moment maximum_relative_error=%.9g\n",maximum);std::fflush(stdout);require(maximum<2e-4,"3D native bond forces differ from independent CPU oracle");
        // Solve the oracle independently from zero for each input.
        params.warmStart=true;
    }
}
}
int main(int argc,char** argv){
    if(argc>2){std::fprintf(stderr,"usage: gpu_resident_stress_3d_test [audit-file-prefix]\n");return 2;}
    if(argc==2)auditPrefix=argv[1];
    unsigned failures=0;
    for(unsigned extent:{3u,23u})for(bool supported:{false,true})try{run(supported,extent);}
    catch(const std::exception& e){++failures;std::fprintf(stderr,"3D fixture extent=%u supported=%u failed: %s\n",extent,supported,e.what());}
    return failures?1:0;
}
