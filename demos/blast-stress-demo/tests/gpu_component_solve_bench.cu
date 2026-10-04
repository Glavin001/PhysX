// Latency of the resident component stress solve (componentStressSolve), the
// kernel a destructible city spends its stress time in: one threadgroup per
// component, every iteration a chain of dependent phases. City components are
// small (cars ~262 chunks, buildings a few hundred), so a tick's solve time is
// the heaviest component's iterations x the latency of one iteration, plus a
// fixed cost per solve.
//
// Builds `count` copies of a component (a free car-sized lattice, or an
// anchored 444-chunk building), loads them with balanced non-zero forces so
// they iterate, and times solves at a fixed iteration count (unreachable
// tolerance). Reports, per iteration count, the median wall time of a solve
// (submission to completion), then the fitted per-iteration slope and fixed
// intercept. Production precision (float) unless built with FP64.
//
//   gpu_component_solve_bench [car|building|<capture prefix>] [components=1] [repeats=15] [city] [buildings=0]
//
// A capture prefix (e.g. docs/reports/vehicle-authored-impact-2026-09-26
// impact-equations: <dir>/derby.solve-30) replays a real car's graph from the
// native problem capture (StressProblemCapture.cuh): its bonds, and node
// positions rebuilt from the bond offsets.
//
// city: the city's settings instead of a fixed iteration count -- warm start,
// tolerance 1e-3, force tolerance 1e-3, cap 64, and inputs that change by a
// part in 1e4 between solves (a parked car's wheel loads). Reports the median
// solve and the iterations it took.
#define BLAST_COMPONENT_ABLATION 1
#include "NvBlastExtStressGpu.cu"
#include <algorithm>
#include <chrono>
#include <cstring>
#include <map>
#include <thread>
#include <tuple>
using namespace Nv::Blast;
namespace ComponentSolveBench {
// BENCH_PERIOD_MS: start each solve this long after the previous one started
// (16.7 = the server's tick), so the GPU idles between solves as it does in a
// game; Apple GPUs lower their clock when idle. 0: back to back.
const double periodMs=[]{const char* r=std::getenv("BENCH_PERIOD_MS");return r?std::atof(r):0.0;}();
std::chrono::steady_clock::time_point nextSolve=std::chrono::steady_clock::now();
void pace(){if(periodMs<=0)return;std::this_thread::sleep_until(nextSolve);
    nextSolve=std::chrono::steady_clock::now()+std::chrono::microseconds(long(periodMs*1000));}
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
struct Release{void operator()(ExtStressGpuSolver* p)const{if(p)p->release();}};
// A box lattice of chunks with a bond to each lower neighbour. fixedFloor:
// chunks at y=0 are static supports (an anchored building).
void lattice(std::vector<ExtStressGpuNode>& nodes,std::vector<ExtStressGpuBond>& bonds,int nx,int ny,int nz,float spacing,
    float offset,bool fixedFloor,bool hollow){
    const float half=spacing*.48f,mass=600*8*half*half*half,inertia=mass*(half*half+half*half)/3;
    std::map<std::tuple<int,int,int>,unsigned> ids;
    for(int y=0;y<ny;++y)for(int z=0;z<nz;++z)for(int x=0;x<nx;++x){
        if(hollow && x && x!=nx-1 && z && z!=nz-1 && y%4!=0)continue;
        const bool fixed=fixedFloor && y==0;const unsigned id=nodes.size();ids[{x,y,z}]=id;
        nodes.push_back({{offset+spacing*x,spacing*y,spacing*z},fixed?0:mass,fixed?0:inertia});
        const int delta[3][3]={{-1,0,0},{0,-1,0},{0,0,-1}};
        for(const auto& d:delta){auto found=ids.find({x+d[0],y+d[1],z+d[2]});if(found==ids.end())continue;
            ExtStressGpuBond b{};b.node0=found->second;b.node1=id;b.area=4*half*half;
            for(unsigned k=0;k<3;++k){b.centroid[k]=(nodes[b.node0].position[k]+nodes[id].position[k])*.5f;b.normal[k]=nodes[id].position[k]-nodes[b.node0].position[k];}
            bonds.push_back(b);}
    }
}
void city(ExtStressGpuSolver& solver,std::vector<ExtStressGpuImpulse> inputs,const std::vector<ExtStressGpuNode>& nodes,unsigned repeats,unsigned solvedNodes){
    auto view=solver.deviceView();std::vector<double> times;unsigned iterations=0,maxIterations=0;
    for(unsigned r=0;r<repeats+4;++r){
        // The solved components' loads move by a few percent (wheel loads);
        // the towers' never change.
        for(unsigned i=0;i<solvedNodes;++i)if(nodes[i].mass>0)inputs[i].linear.y*=1.f+3e-2f*float(int((r+i)%3)-1);
        check(cudaMemcpy(view.nodeInputs,inputs.data(),inputs.size()*sizeof(inputs[0]),cudaMemcpyHostToDevice));check(cudaDeviceSynchronize());
        ExtStressGpuSolveParams params;params.maxIterations=64;params.tolerance=1e-3f;params.forceTolerance=1e-3f;params.warmStart=true;
        pace();const auto start=std::chrono::steady_clock::now();
        if(!solver.solveDeviceAsync(view.nodeInputs,nodes.size(),params))throw std::runtime_error("bench solve rejected");
        view=solver.deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
        ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));
        if(r>=4){times.push_back(ms);iterations=status.iterations;maxIterations=std::max(maxIterations,status.iterations);}
    }
    std::sort(times.begin(),times.end());
    std::printf("{\"mode\":\"city\",\"median_ms\":%.4f,\"min_ms\":%.4f,\"last_iterations\":%u,\"max_iterations\":%u}\n",times[times.size()/2],times.front(),iterations,maxIterations);
}
// One captured component: bonds from <prefix>.bonds.bin (64-byte records:
// first, second, offset0[3], offset1[3], health, scale, warm[6]), positions
// from a breadth-first walk (position1 = position0 + offset0 - offset1).
void captured(std::vector<ExtStressGpuNode>& nodes,std::vector<ExtStressGpuBond>& bonds,const std::string& prefix,float shift){
    auto read=[](const std::string& path){FILE* f=std::fopen(path.c_str(),"rb");if(!f)throw std::runtime_error("cannot open "+path);
        std::vector<unsigned char> d;unsigned char buf[65536];size_t n;while((n=std::fread(buf,1,sizeof(buf),f))>0)d.insert(d.end(),buf,buf+n);std::fclose(f);return d;};
    const auto nb=read(prefix+".nodes.bin"),bb=read(prefix+".bonds.bin");
    struct B{unsigned first,second;float o0[3],o1[3],health,scale,warm[6];};static_assert(sizeof(B)==64,"capture bond");
    const unsigned n=nb.size()/64,m=bb.size()/64,base=nodes.size();std::vector<B> b(m);std::memcpy(b.data(),bb.data(),bb.size());
    std::vector<std::vector<std::pair<unsigned,unsigned>>> adj(n);for(unsigned e=0;e<m;++e){adj[b[e].first].push_back({e,0});adj[b[e].second].push_back({e,1});}
    std::vector<float> pos(3*n,0);std::vector<char> seen(n,0);
    for(unsigned root=0;root<n;++root)if(!seen[root]){seen[root]=1;std::vector<unsigned> q{root};
        for(size_t h=0;h<q.size();++h){const unsigned u=q[h];for(auto [e,side]:adj[u]){const unsigned v=side?b[e].first:b[e].second;if(seen[v])continue;seen[v]=1;
            for(unsigned k=0;k<3;++k)pos[3*v+k]=side?pos[3*u+k]+b[e].o1[k]-b[e].o0[k]:pos[3*u+k]+b[e].o0[k]-b[e].o1[k];q.push_back(v);}}}
    for(unsigned i=0;i<n;++i)nodes.push_back({{shift+pos[3*i],pos[3*i+1],pos[3*i+2]},40.f,40.f*.05f});
    // BENCH_MAX_DEGREE=<d>: drop bonds at nodes above degree d (a test of how
    // much the high-degree hubs cost; spanning bonds are kept by the BFS above
    // only for positions, so the graph may split).
    std::vector<unsigned> degree(n,0);for(unsigned e=0;e<m;++e){++degree[b[e].first];++degree[b[e].second];}
    const unsigned maxDegree=std::getenv("BENCH_MAX_DEGREE")?std::stoul(std::getenv("BENCH_MAX_DEGREE")):~0u;
    for(unsigned e=0;e<m;++e){if(!(b[e].health>0))continue;
        if(degree[b[e].first]>maxDegree || degree[b[e].second]>maxDegree)continue;ExtStressGpuBond x{};x.node0=base+b[e].first;x.node1=base+b[e].second;x.area=b[e].health;
        for(unsigned k=0;k<3;++k){x.centroid[k]=nodes[x.node0].position[k]+b[e].o0[k];x.normal[k]=nodes[x.node1].position[k]-nodes[x.node0].position[k];}
        bonds.push_back(x);}
}
void run(const std::string& shape,unsigned count,unsigned repeats,bool cityMode,unsigned buildings){
    const bool car=shape!="building";
    std::vector<ExtStressGpuNode> nodes;std::vector<ExtStressGpuBond> bonds;
    for(unsigned c=0;c<count;++c){
        if(shape!="car" && shape!="building"){captured(nodes,bonds,shape,c*40.f);continue;}
        // car: 9 x 4 x 7 = 252 chunks, free; building: the probe's 444-chunk tower.
        if(car)lattice(nodes,bonds,9,4,7,.5f,c*20.f,false,false);
        else lattice(nodes,bonds,8,12,8,1.f,c*20.f,true,true);
    }
    const unsigned perComponent=nodes.size()/count;
    // City composition: anchored towers under constant gravity beside the
    // solved components; after their first verified solve they are settled.
    const unsigned solvedNodes=nodes.size();
    for(unsigned b=0;b<buildings;++b)lattice(nodes,bonds,8,12,8,1.f,(count+b)*20.f,true,true);
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),nodes.size(),bonds.data(),bonds.size()));
    if(!solver || !solver->enableDeviceTopology())throw std::runtime_error("bench initialization failed");
    // Balanced loads: a free body's loads must have no net force or moment
    // (the projection removes it anyway); alternate signs over a pattern.
    std::vector<ExtStressGpuImpulse> inputs(nodes.size());
    for(unsigned i=0;i<nodes.size();++i)if(nodes[i].mass>0){
        const float s=((i*7919u)%13u)/6.f-1.f;const bool solved=i<solvedNodes;
        inputs[i].linear.y=-9.81f*(car && solved?s:1.f);inputs[i].linear.x=car && solved?.5f*s:0.f;}
    auto view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
    std::printf("{\"case\":\"%s\",\"components\":%u,\"chunks_per_component\":%u,\"bonds\":%zu,\"repeats\":%u}\n",shape.c_str(),count,perComponent,bonds.size(),repeats);
    if(cityMode){city(*solver,inputs,nodes,repeats,solvedNodes);return;}
    // Caps run round-robin, not one after another: Apple GPUs change clock
    // with load, and a sweep in increasing order measured the clock ramp
    // (160 us an iteration at the start, 24 us at the end) as well.
    const unsigned caps[]={1,2,8,32,64};constexpr unsigned capCount=5;
    std::vector<double> times[capCount];unsigned iterations[capCount]{};
    for(unsigned r=0;r<repeats+2;++r)for(unsigned k=0;k<capCount;++k){
        // Change the inputs every solve so no component is skipped as settled.
        for(unsigned i=0;i<nodes.size();++i)if(nodes[i].mass>0)inputs[i].linear.z=1e-3f*float((r*capCount+k+i)%5);
        check(cudaMemcpy(view.nodeInputs,inputs.data(),inputs.size()*sizeof(inputs[0]),cudaMemcpyHostToDevice));check(cudaDeviceSynchronize());
        ExtStressGpuSolveParams params;params.maxIterations=caps[k];params.tolerance=1e-12f;params.warmStart=false;
        pace();const auto start=std::chrono::steady_clock::now();
        if(!solver->solveDeviceAsync(view.nodeInputs,nodes.size(),params))throw std::runtime_error("bench solve rejected");
        view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
        ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));
        iterations[k]=status.iterations;
        if(r>=2)times[k].push_back(ms); // two warm-up rounds
    }
    std::vector<std::pair<double,double>> points;
    for(unsigned k=0;k<capCount;++k){auto& t=times[k];std::sort(t.begin(),t.end());const double median=t[t.size()/2];
        points.push_back({double(caps[k]),median});
        std::printf("{\"cap\":%u,\"iterations\":%u,\"median_ms\":%.4f,\"min_ms\":%.4f,\"max_ms\":%.4f}\n",caps[k],iterations[k],median,t.front(),t.back());}
    // Checksum of the bond impulses after one more 64-iteration solve: equal
    // checksums before and after an operator change show identical results.
    {for(unsigned i=0;i<nodes.size();++i)if(nodes[i].mass>0)inputs[i].linear.z=0;
        check(cudaMemcpy(view.nodeInputs,inputs.data(),inputs.size()*sizeof(inputs[0]),cudaMemcpyHostToDevice));check(cudaDeviceSynchronize());
        ExtStressGpuSolveParams params;params.maxIterations=64;params.tolerance=1e-12f;params.warmStart=false;
        if(!solver->solveDeviceAsync(view.nodeInputs,nodes.size(),params))throw std::runtime_error("bench solve rejected");
        view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        std::vector<ExtStressGpuImpulse> impulses(bonds.size());
        if(!solver->readbackImpulses(impulses.data(),impulses.size()))throw std::runtime_error("impulse readback failed");
        unsigned long long hash=1469598103934665603ull;const auto* bytes=reinterpret_cast<const unsigned char*>(impulses.data());
        for(size_t i=0;i<impulses.size()*sizeof(impulses[0]);++i)hash=(hash^bytes[i])*1099511628211ull;
        double norm=0;for(const auto& x:impulses)for(float v:{x.angular.x,x.angular.y,x.angular.z,x.linear.x,x.linear.y,x.linear.z})norm+=double(v)*v;
        std::printf("{\"impulse_checksum\":\"%016llx\",\"impulse_norm\":%.9e}\n",hash,std::sqrt(norm));
        // BENCH_DUMP=<path>: the impulses, for comparing two builds.
        if(const char* dump=std::getenv("BENCH_DUMP")){FILE* f=std::fopen(dump,"wb");if(f){std::fwrite(impulses.data(),sizeof(impulses[0]),impulses.size(),f);std::fclose(f);}}}
    double sx=0,sy=0,sxx=0,sxy=0;for(auto [x,y]:points){sx+=x;sy+=y;sxx+=x*x;sxy+=x*y;}
    const double n=points.size(),slope=(n*sxy-sx*sy)/(n*sxx-sx*sx),intercept=(sy-slope*sx)/n;
    {unsigned trace[4]{};check(cudaMemcpyFromSymbol(trace,componentBalanceTrace,sizeof(trace)));
        std::printf("{\"balanced_solves\":%u,\"unbalanced_solves\":%u,\"chunks\":%u,\"without_scratch\":%u}\n",trace[0],trace[1],trace[2],trace[3]);}
    std::printf("{\"per_iteration_ms\":%.4f,\"fixed_ms\":%.4f,\"at_64_ms\":%.3f}\n",slope,intercept,intercept+64*slope);
}
}
// spin <blocks> <seconds>: a background load for clock experiments -- each
// launch keeps <blocks> threadgroups busy for about a millisecond.
__global__ void benchSpin(unsigned* sink,unsigned rounds){
    unsigned x=threadIdx.x+blockIdx.x;for(unsigned i=0;i<rounds;++i)x=x*1664525u+1013904223u;
    if(x==0x12345678u)sink[0]=x;
}
int spin(unsigned blocks,double seconds){
    unsigned* sink;ComponentSolveBench::check(cudaMalloc(&sink,4));
    const auto end=std::chrono::steady_clock::now()+std::chrono::milliseconds(long(seconds*1000));unsigned launches=0;
    while(std::chrono::steady_clock::now()<end){benchSpin<<<blocks,64>>>(sink,200000);ComponentSolveBench::check(cudaDeviceSynchronize());++launches;}
    std::printf("{\"spin_launches\":%u}\n",launches);return 0;
}
int main(int argc,char** argv){try{
    // BENCH_ABLATE=<bitmask>: skip component-solve phases (StressComponentIteration.cuh,
    // COMPONENT_ABLATE): 1 residual operator, 2 residual projection, 4 preconditioner,
    // 8 direction update, 16 direction operator, 32 solution update.
    if(const char* ablate=std::getenv("BENCH_ABLATE")){const unsigned mask=std::strtoul(ablate,nullptr,0);
        ComponentSolveBench::check(cudaMemcpyToSymbol(componentAblation,&mask,sizeof(mask)));}
    if(argc==4 && !std::strcmp(argv[1],"spin"))return spin(std::stoul(argv[2]),std::atof(argv[3]));
    if(argc==2 && !std::strcmp(argv[1],"attributes")){
        // What the compiled pipelines report: a low thread limit means heavy
        // register use (and spills) on Apple GPUs.
        auto show=[](const char* name,const void* f){cudaFuncAttributes at{};const auto e=cudaFuncGetAttributes(&at,f);
            std::printf("{\"kernel\":\"%s\",\"ok\":%d,\"maxThreadsPerBlock\":%d,\"numRegs\":%d,\"localSizeBytes\":%zu,\"sharedSizeBytes\":%zu}\n",name,e==cudaSuccess,at.maxThreadsPerBlock,at.numRegs,at.localSizeBytes,at.sharedSizeBytes);};
        show("componentStressSolve",(const void*)componentStressSolve);
        show("persistentStressSolve<true>",(const void*)persistentStressSolve<true>);
        show("benchSpin",(const void*)benchSpin);
        return 0;}
    const std::string shape=argc<2?"car":argv[1];const unsigned count=argc>2?std::stoul(argv[2]):1,repeats=argc>3?std::stoul(argv[3]):15;
    ComponentSolveBench::run(shape,count,repeats,argc>4 && !std::strcmp(argv[4],"city"),argc>5?std::stoul(argv[5]):0);return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
