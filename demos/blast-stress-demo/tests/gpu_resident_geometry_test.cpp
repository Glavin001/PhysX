// Public native API regression: changing geometry must match a fresh solver,
// preserve fracture history and fail closed without partially applying bad data.
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <utility>
#include <limits>
#include <memory>
#include <stdexcept>
#include <vector>
using namespace Nv::Blast;
namespace {
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
void check(cudaError_t value){if(value!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(value));}
template<class T>struct Device {
    T* p=nullptr;unsigned count;
    explicit Device(unsigned n):count(n){check(cudaMalloc(&p,n*sizeof(T)));}
    ~Device(){cudaFree(p);}
    void put(const std::vector<T>& v){require(v.size()==count,"upload size mismatch");check(cudaMemcpy(p,v.data(),count*sizeof(T),cudaMemcpyHostToDevice));check(cudaStreamSynchronize(nullptr));}
};
struct Release{void operator()(ExtStressGpuSolver* s)const{if(s)s->release();}};
struct Asset {
    std::vector<ExtStressGpuNode> nodes;
    std::vector<ExtStressGpuBond> bonds;
    void edge(unsigned a,unsigned b){ExtStressGpuBond e{};e.node0=a;e.node1=b;e.normal[1]=1;e.health=.65f;
        for(unsigned k=0;k<3;++k)e.centroid[k]=(nodes[a].position[k]+nodes[b].position[k])*.5f;
        bonds.push_back(e);}
    std::vector<ExtStressGpuGeometryNode> geometryNodes()const{std::vector<ExtStressGpuGeometryNode> out(nodes.size());
        for(unsigned i=0;i<nodes.size();++i){for(unsigned k=0;k<3;++k)out[i].position[k]=nodes[i].position[k];out[i].inertia=nodes[i].inertia;}return out;}
    std::vector<ExtStressGpuGeometryBond> geometryBonds()const{std::vector<ExtStressGpuGeometryBond> out(bonds.size());
        for(unsigned i=0;i<bonds.size();++i)for(unsigned k=0;k<3;++k){out[i].centroid[k]=bonds[i].centroid[k];out[i].normal[k]=bonds[i].normal[k];}return out;}
};
struct Harness {
    Asset asset;std::unique_ptr<ExtStressGpuSolver,Release> solver;
    Device<ExtStressGpuGeometryNode> nodes;Device<ExtStressGpuGeometryBond> bonds;
    Device<std::uint64_t> revision{1};Device<unsigned> accept{1},mask;
    cudaStream_t producer=nullptr;cudaEvent_t ready=nullptr;
    explicit Harness(Asset source):asset(std::move(source)),nodes(asset.nodes.size()),bonds(asset.bonds.size()),mask(asset.bonds.size()){
        solver.reset(ExtStressGpuSolver::create(asset.nodes.data(),asset.nodes.size(),asset.bonds.data(),asset.bonds.size()));
        require(bool(solver) && solver->enableDeviceTopology(),"geometry solver initialization failed");
        check(cudaStreamCreateWithFlags(&producer,cudaStreamNonBlocking));check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
        accept.put({1});
    }
    ~Harness(){cudaEventDestroy(ready);cudaStreamDestroy(producer);}
    void wait(){check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(solver->deviceView().readyEvent)));}
    template<class T>T read(const T* pointer){wait();T value{};check(cudaMemcpy(&value,pointer,sizeof(T),cudaMemcpyDeviceToHost));return value;}
    ExtStressGpuDeviceTopologyStatus topology(){return read(solver->deviceView().topologyStatus);}
    ExtStressGpuDeviceGeometryStatus geometryStatus(){return read(ExtStressGpuGetDeviceGeometryStatus(solver.get()));}
    void geometry(const Asset& next,std::uint64_t gen,unsigned accepted=1){
        wait();const auto n=next.geometryNodes();const auto b=next.geometryBonds();
        check(cudaMemcpyAsync(nodes.p,n.data(),n.size()*sizeof(n[0]),cudaMemcpyHostToDevice,producer));
        check(cudaMemcpyAsync(bonds.p,b.data(),b.size()*sizeof(b[0]),cudaMemcpyHostToDevice,producer));
        check(cudaMemcpyAsync(revision.p,&gen,sizeof(gen),cudaMemcpyHostToDevice,producer));
        check(cudaMemcpyAsync(accept.p,&accepted,sizeof(accepted),cudaMemcpyHostToDevice,producer));
        check(cudaEventRecord(ready,producer));
        require(ExtStressGpuUpdateDeviceGeometry(solver.get(),nodes.p,nodes.count,bonds.p,bonds.count,revision.p,accept.p,ready),"geometry submission rejected");
        wait(); // Staging vectors and producer scalars remain alive through readyEvent.
    }
    void cut(unsigned edge,std::uint64_t gen){wait();std::vector<unsigned> live(asset.bonds.size(),edge==~0u?0:1);if(edge!=~0u)live[edge]=0;
        mask.put(live);revision.put({gen});require(solver->updateDeviceTopologyAsync(mask.p,mask.count,revision.p),"cut submission rejected");wait();}
    std::pair<bool,std::vector<ExtStressGpuImpulse>> solveInputs(const std::vector<ExtStressGpuImpulse>& input){
        wait();auto view=solver->deviceView();check(cudaMemcpyAsync(view.nodeInputs,input.data(),input.size()*sizeof(input[0]),cudaMemcpyHostToDevice,producer));check(cudaEventRecord(ready,producer));
        ExtStressGpuSolveParams params;params.maxIterations=512;params.tolerance=1e-6f;params.warmStart=false;
        require(solver->solveDeviceAsync(view.nodeInputs,input.size(),params,ready),"diagnostic solve rejected");wait();
        const bool converged=read(solver->deviceView().status).converged;
        std::vector<ExtStressGpuImpulse> result(asset.bonds.size());check(cudaMemcpy(result.data(),solver->deviceView().bondImpulses,result.size()*sizeof(result[0]),cudaMemcpyDeviceToHost));return {converged,result};
    }
    std::vector<ExtStressGpuImpulse> solve(bool expectedConvergence=true){
        wait();std::vector<ExtStressGpuImpulse> input(asset.nodes.size());
        for(unsigned i=0;i<input.size();++i)if(asset.nodes[i].mass>0){input[i].linear.x=.5f+float(i)*.25f;input[i].linear.z=-.2f*float(i);input[i].angular.y=.17f*float(i+1);}
        auto view=solver->deviceView();check(cudaMemcpyAsync(view.nodeInputs,input.data(),input.size()*sizeof(input[0]),cudaMemcpyHostToDevice,producer));check(cudaEventRecord(ready,producer));
        ExtStressGpuSolveParams params;params.maxIterations=512;params.tolerance=1e-5f;params.warmStart=true;
        require(solver->solveDeviceAsync(view.nodeInputs,input.size(),params,ready),"geometry solve submission rejected");wait();
        const auto status=read(solver->deviceView().status);
        require(bool(status.converged)==expectedConvergence,"geometry solve convergence differs from expected acceptance");
        std::vector<ExtStressGpuImpulse> result(asset.bonds.size());check(cudaMemcpy(result.data(),solver->deviceView().bondImpulses,result.size()*sizeof(result[0]),cudaMemcpyDeviceToHost));return result;
    }
};
float compare(const std::vector<ExtStressGpuImpulse>& a,const std::vector<ExtStressGpuImpulse>& b){
    require(a.size()==b.size(),"force comparison size mismatch");float worst=0;
    for(unsigned i=0;i<a.size();++i){const float av[]={a[i].angular.x,a[i].angular.y,a[i].angular.z,a[i].linear.x,a[i].linear.y,a[i].linear.z};
        const float bv[]={b[i].angular.x,b[i].angular.y,b[i].angular.z,b[i].linear.x,b[i].linear.y,b[i].linear.z};
        for(unsigned k=0;k<6;++k){const float error=std::abs(av[k]-bv[k])/std::max(1.f,std::abs(bv[k]));
            require(std::isfinite(error),"geometry produced nonfinite forces");worst=std::max(worst,error);}}
    if(worst>=3e-4f)std::fprintf(stderr,"geometry fresh-solver mismatch: %g\n",worst);
    require(worst<3e-4f,"updated geometry differs from fresh physical solver");return worst;
}
Asset freeAsset(){Asset a;a.nodes={{{0,0,0},2,.7f},{{1,0,0},3,.8f},{{0,1,0},4,1.1f},{{0,0,1},5,1.2f}};
    for(unsigned i=0;i<4;++i)for(unsigned j=i+1;j<4;++j)a.edge(i,j);return a;}
Asset deform(Asset a){for(auto& n:a.nodes){const float x=n.position[0],y=n.position[1],z=n.position[2];
        n.position[0]=2*x+.3f*y+.4f;n.position[1]=.7f*y+.2f*z-.6f;n.position[2]=1.3f*z+.1f*x;n.inertia*=1.4f;}
    for(auto& b:a.bonds){for(unsigned k=0;k<3;++k)b.centroid[k]=.5f*(a.nodes[b.node0].position[k]+a.nodes[b.node1].position[k]);b.normal[0]=.4f;b.normal[1]=-.6f;b.normal[2]=.2f;}return a;}
// A rigid motion keeps the solver's frozen length/mass normalization equal to
// a fresh solver's, so even this statically indeterminate graph (whose
// minimum-norm impulses depend on that metric) must match a fresh solve.
Asset rigid(Asset a){const float c=std::cos(.7f),s=std::sin(.7f),axis[3]={1.f/3,2.f/3,2.f/3};
    auto turn=[&](const float* v,float* out){const float d=axis[0]*v[0]+axis[1]*v[1]+axis[2]*v[2];
        const float x[3]={axis[1]*v[2]-axis[2]*v[1],axis[2]*v[0]-axis[0]*v[2],axis[0]*v[1]-axis[1]*v[0]};
        for(unsigned k=0;k<3;++k)out[k]=v[k]*c+x[k]*s+axis[k]*d*(1-c);};
    for(auto& n:a.nodes){float p[3];turn(n.position,p);n.position[0]=p[0]+.4f;n.position[1]=p[1]-.6f;n.position[2]=p[2]+.25f;n.inertia*=1.4f;}
    for(auto& b:a.bonds){float nrm[3];turn(b.normal,nrm);for(unsigned k=0;k<3;++k){b.normal[k]=nrm[k];b.centroid[k]=.5f*(a.nodes[b.node0].position[k]+a.nodes[b.node1].position[k]);}}return a;}
void movingFreeGraph(){
    const Asset initial=freeAsset();Harness h(initial);h.solve();
    {   // Diagnostic only: stretching changes the fresh solver's metric.
        const Asset stretched=deform(initial);Harness diagnostic(initial),fresh(stretched);diagnostic.geometry(stretched,1);
        const auto a=diagnostic.solve(),b=fresh.solve();float worst=0;
        for(unsigned i=0;i<a.size();++i){const float av[]={a[i].linear.x,a[i].linear.y,a[i].linear.z},bv[]={b[i].linear.x,b[i].linear.y,b[i].linear.z};
            for(unsigned k=0;k<3;++k)worst=std::max(worst,std::abs(av[k]-bv[k])/std::max(1.f,std::abs(bv[k])));}
        std::printf("indeterminate graph, stretched (metric differs, not asserted): frozen-vs-fresh linear gap %g\n",worst);
    }
    Asset moved=rigid(initial);Harness oracle(moved);const auto expected=oracle.solve();
    h.geometry(moved,5);auto status=h.geometryStatus();auto topology=h.topology();
    require(status.initialized && status.generation==5 && status.applied && !status.error,"geometry not accepted");
    require(topology.generation==0 && topology.rebuilds==2 && topology.activeBondCount==6 && !topology.error,"geometry changed fracture generation or failed operator rebuild");
    const float worst=compare(h.solve(),expected);
    h.geometry(moved,5);require(!h.geometryStatus().applied && h.topology().rebuilds==2,"equal geometry revision rebuilt operator");compare(h.solve(),expected);
    require(!ExtStressGpuUpdateDeviceGeometry(h.solver.get(),h.nodes.p,3,h.bonds.p,6,h.revision.p),"wrong node count accepted");
    require(!ExtStressGpuUpdateDeviceGeometry(h.solver.get(),h.nodes.p,4,h.bonds.p,5,h.revision.p),"wrong bond count accepted");
    require(!ExtStressGpuUpdateDeviceGeometry(h.solver.get(),nullptr,4,h.bonds.p,6,h.revision.p),"null geometry accepted");
    for(unsigned invalid=0;invalid<6;++invalid){
        Asset bad=moved;bad.nodes[0].position[0]+=4; // Valid row must not partially commit.
        if(invalid==0)bad.nodes[3].position[1]=std::numeric_limits<float>::quiet_NaN();
        if(invalid==1)bad.nodes[3].inertia=-1;
        if(invalid==2)bad.nodes[3].inertia=0;
        if(invalid==3)bad.bonds[4].centroid[2]=std::numeric_limits<float>::infinity();
        if(invalid==4)bad.bonds[4].normal[0]=std::numeric_limits<float>::max();
        if(invalid==5)bad.nodes[3].position[1]=std::numeric_limits<float>::max();
        h.geometry(bad,6);status=h.geometryStatus();topology=h.topology();
        require(status.error && !status.applied && status.generation==5 && topology.rebuilds==2 && (topology.error&(1u<<6)),"invalid geometry committed or failed to block solver");
        h.solve(false);
        h.geometry(moved,5);require(!h.geometryStatus().error && !h.geometryStatus().applied && h.topology().rebuilds==2,"accepted revision did not recover without mutating geometry");
        compare(h.solve(),expected); // Detects any partial write from the invalid batch.
    }
    h.cut(2,17);moved.bonds[2].health=0;Asset movedAgain=rigid(moved);Harness cutOracle(movedAgain);
    const auto cutExpected=cutOracle.solve();h.geometry(movedAgain,7);status=h.geometryStatus();topology=h.topology();
    require(!status.error && status.applied && status.generation==7 && topology.generation==17 && topology.rebuilds==4 && topology.activeBondCount==5,"geometry restored a removed bond or changed connectivity");
    const auto actual=h.solve();compare(actual,cutExpected);
    const auto removed=actual[2];require(removed.angular.x==0 && removed.angular.y==0 && removed.angular.z==0 && removed.linear.x==0 && removed.linear.y==0 && removed.linear.z==0,"removed bond regained force");
    h.geometry(moved,6);require(h.geometryStatus().error==1 && h.topology().rebuilds==4,"stale geometry revision accepted");h.solve(false);
    Asset rejected=movedAgain;rejected.nodes[0].position[0]=std::numeric_limits<float>::quiet_NaN();
    h.geometry(rejected,999,0);require(h.geometryStatus().error==1 && h.geometryStatus().generation==7,"rejected batch cleared previous error or read invalid inputs");
    h.geometry(movedAgain,7);compare(h.solve(),cutExpected);
    h.geometry(rejected,999,0);require(!h.geometryStatus().error && !h.geometryStatus().applied && h.geometryStatus().generation==7 && h.topology().rebuilds==4,"rejected batch mutated valid state");compare(h.solve(),cutExpected);
    h.cut(~0u,18);h.geometry(movedAgain,8);
    require(h.topology().activeBondCount==0 && h.topology().generation==18,"empty graph resurrected constraints");
    const std::vector<ExtStressGpuImpulse> zero(initial.bonds.size());
    compare(h.solve(),zero);
    h.geometry(rejected,9);require(h.geometryStatus().error,"empty graph accepted invalid geometry");
    h.solve(false);
    h.geometry(movedAgain,8);require(!h.geometryStatus().error,"empty graph could not recover");compare(h.solve(),zero);
    std::printf("GPU moving geometry: 4 dynamic nodes / 6 bonds, rigid motion+inertia, six atomic rejections, stale/rejected/repeated revisions and cut preservation passed; fresh-solver error %g\n",worst);
}
// Independent static equilibrium: applied force is mass times acceleration;
// joint moment balances COM torque plus the force lever arm about the centroid.
// The physical angular acceleration is the negated Blast angular input.
// The SDK is free to report either endpoint's action/reaction convention.
// A supported tree is statically determinate: each bond carries its subtree's
// load, so any normalization gives the same impulses and a non-rigid stretch
// must match a fresh solver exactly.
void movingDeterminateTree(){
    Asset a;a.nodes={{{0,0,0},0,0},{{1,0,0},3,.8f},{{1,1,0},4,1.1f},{{1,1,1},5,1.2f}};a.edge(0,1);a.edge(1,2);a.edge(2,3);
    Harness h(a);h.solve();const Asset stretched=deform(a);Harness oracle(stretched);const auto expected=oracle.solve();
    h.geometry(stretched,1);require(h.geometryStatus().applied,"tree geometry not accepted");
    const float worst=compare(h.solve(),expected);
    std::printf("GPU moving determinate tree: stretched support chain matches a fresh solver; error %g\n",worst);
}
// Blast stores angular coordinates with the opposite handed sign (see
// PxgDestructionRuntime: inputs.angular = -torque / inertia). A free two-node
// bond carrying a known shear F at its midpoint c must be recovered exactly
// from inputs in that convention, and not from un-negated Newton-Euler ones.
void leverConvention(){
    Asset a;a.nodes={{{0,0,0},2,.5f},{{1,0,0},3,.8f}};a.edge(0,1);
    const float F[3]={0,1,0},c[3]={.5f,0,0};
    for(int sign:{-1,1}){
        Harness h(a);std::vector<ExtStressGpuImpulse> input(2);
        for(unsigned n=0;n<2;++n){const float s=n==0?1.f:-1.f,*x=a.nodes[n].position;const float r[3]={c[0]-x[0],c[1]-x[1],c[2]-x[2]},f[3]={s*F[0],s*F[1],s*F[2]};
            const float t[3]={r[1]*f[2]-r[2]*f[1],r[2]*f[0]-r[0]*f[2],r[0]*f[1]-r[1]*f[0]};
            input[n].linear={f[0]/a.nodes[n].mass,f[1]/a.nodes[n].mass,f[2]/a.nodes[n].mass};
            input[n].angular={sign*t[0]/a.nodes[n].inertia,sign*t[1]/a.nodes[n].inertia,sign*t[2]/a.nodes[n].inertia};}
        const auto [converged,out]=h.solveInputs(input);const auto& b=out[0];
        const float error=std::abs(std::abs(b.linear.y)-1)+std::abs(b.linear.x)+std::abs(b.linear.z)+std::abs(b.angular.x)+std::abs(b.angular.y)+std::abs(b.angular.z);
        std::printf("angular input %s: converged=%d bond linear=(%g,%g,%g) angular=(%g,%g,%g)\n",sign<0?"in Blast convention":"un-negated (not Blast)",
            int(converged),b.linear.x,b.linear.y,b.linear.z,b.angular.x,b.angular.y,b.angular.z);
        if(sign<0)require(converged && error<1e-4f,"Blast-convention shear bond not recovered exactly");
        else require(error>.1f,"un-negated angular input unexpectedly recovered the shear bond");
    }
}
void checkSupportedEquilibrium(const Asset& a,const ExtStressGpuImpulse& force){
    const auto& n=a.nodes[1];const auto& b=a.bonds[0];
    const float applied[]={n.mass*.75f,0.f,n.mass*-.2f};
    const float r[]={n.position[0]-b.centroid[0],n.position[1]-b.centroid[1],n.position[2]-b.centroid[2]};
    const float moment[]={r[1]*applied[2]-r[2]*applied[1],-n.inertia*.34f+r[2]*applied[0]-r[0]*applied[2],r[0]*applied[1]-r[1]*applied[0]};
    const float actual[]={force.linear.x,force.linear.y,force.linear.z,force.angular.x,force.angular.y,force.angular.z};
    for(unsigned k=0;k<6;++k){const float expected=k<3?applied[k]:moment[k-3];
        const float error=std::abs(std::abs(actual[k])-std::abs(expected))/std::max(1.f,std::abs(expected));
        if(!(error<3e-4f))std::fprintf(stderr,"supported geometry equilibrium component %u: actual %g expected magnitude %g\n",k,actual[k],std::abs(expected));
        require(error<3e-4f,"moving support violates independent force/moment equilibrium");}
}
void movingSupport(){
    Asset a;a.nodes={{{0,0,0},0,0},{{0,2,0},2,.7f}};a.edge(0,1);Harness h(a);h.solve();
    a.nodes[1].position[1]=4;a.bonds[0].centroid[1]=1; // Support uses authored bond centroid, not midpoint.
    Harness oracle(a);const auto expected=oracle.solve();h.geometry(a,1);const auto supported=h.solve();compare(supported,expected);checkSupportedEquilibrium(a,supported[0]);
    Asset bad=a;bad.nodes[0].inertia=1;h.geometry(bad,2);require(h.geometryStatus().error&4,"fixed rotation classification changed");h.solve(false);
    h.geometry(a,1);compare(h.solve(),expected);
    // Reversed endpoint support must use the opposite centroid offset branch.
    std::swap(a.bonds[0].node0,a.bonds[0].node1);Harness reversed(a);a.nodes[1].position[0]=1;a.bonds[0].centroid[0]=.25f;
    Harness reversedOracle(a);reversed.geometry(a,1);const auto reverseForce=reversed.solve();compare(reverseForce,reversedOracle.solve());checkSupportedEquilibrium(a,reverseForce[0]);
    std::printf("GPU moving support: both endpoint orders preserve centroid moments and fixed classification\n");
}
}
int main(){std::setvbuf(stdout,nullptr,_IOLBF,0);try{leverConvention();movingFreeGraph();movingDeterminateTree();movingSupport();return 0;}
catch(const std::exception& e){std::fprintf(stderr,"resident geometry: %s\n",e.what());return 1;}}
