// Numerical qualification only: actual resident hierarchy and candidate outer
// iteration, with independent host bond equations and known physical answers.
#include "StressHierarchyKrylov.cuh"
#include <array>
#include <algorithm>
#include <cstdio>
#include <numeric>
#include <vector>
using namespace Nv::Blast::StressHierarchy;
namespace {
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
void require(bool yes,const char* why){if(!yes)throw std::runtime_error(why);}
template<class T>struct Device {
    T* data=nullptr;size_t size;
    Device(size_t count):size(count){check(cudaMalloc(&data,std::max(size_t(1),count)*sizeof(T)));check(cudaMemset(data,0,std::max(size_t(1),count)*sizeof(T)));}
    ~Device(){cudaFree(data);}
    void put(const std::vector<T>& v){require(v.size()==size,"test upload size");if(size)check(cudaMemcpy(data,v.data(),size*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get(){std::vector<T> v(size);if(size)check(cudaMemcpy(v.data(),data,size*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
using Six=std::array<double,6>;
Six unpack(Vector v){return {v.angular.x,v.angular.y,v.angular.z,v.linear.x,v.linear.y,v.linear.z};}
Vector pack(Six a){return {{a[0],a[1],a[2]},{a[3],a[4],a[5]}};}
Six coupled(Six a,float4 p){return {a[0],a[1],a[2],a[3]+p.y*a[2]-p.z*a[1],a[4]+p.z*a[0]-p.x*a[2],a[5]+p.x*a[1]-p.y*a[0]};}
Six transpose(Six a,float4 p){return {a[0]-p.y*a[5]+p.z*a[4],a[1]-p.z*a[3]+p.x*a[5],a[2]-p.x*a[4]+p.y*a[3],a[3],a[4],a[5]};}
struct Fixture {
    unsigned n;bool anchored,axial,incompatible,closed;
    std::vector<unsigned> a,b,begin,refs,labels,order,first,last;
    std::vector<float4> position,offset0,offset1;
    std::vector<Six> exact,bond,rhs;
    Fixture(unsigned count,bool fixed,bool pure,bool extra,bool loop):n(count),anchored(fixed),axial(pure),incompatible(extra),closed(loop),begin(n+1),labels(n),order(n),first(n),last(n),position(n),exact(n),rhs(n){
        for(unsigned i=0;i<n;++i){position[i]=make_float4(0,float(2*i),0,0);
            if(axial)exact[i][4]=(i%4==0||i%4==3)?.5:-.5;
            else for(unsigned k=0;k<6;++k)exact[i][k]=double(int((i*17+k*7)%23)-11)/16.;}
        if(anchored){exact[0]={};labels[0]=Invalid;}
        for(unsigned i=1;i<n;++i)edge(i-1,i);
        if(closed){edge(n-1,0);offset1.back().x+=.03125f;}
        for(unsigned e=0;e<a.size();++e){auto x=coupled(exact[a[e]],offset0[e]),y=coupled(exact[b[e]],offset1[e]);Six f{};
            for(unsigned k=0;k<6;++k)f[k]=x[k]-y[k];bond.push_back(f);const auto p=transpose(f,offset0[e]),q=transpose(f,offset1[e]);
            for(unsigned k=0;k<6;++k){rhs[a[e]][k]+=p[k];rhs[b[e]][k]-=q[k];}++begin[a[e]+1];++begin[b[e]+1];}
        if(incompatible)for(unsigned i=0;i<n;++i){
            // Translation is exact even in the frustrated closed-loop case.
            rhs[i][3]+=.25;rhs[i][4]-=.125;rhs[i][5]+=.5;
            if(!closed){const Six rigid{{.25,-.125,.5,.375,-.25,.125}};const auto r=coupled(rigid,position[i]);for(unsigned k=0;k<6;++k)rhs[i][k]+=r[k];}
        }
        if(anchored)rhs[0]={};std::partial_sum(begin.begin(),begin.end(),begin.begin());refs.resize(2*a.size());auto cursor=begin;
        for(unsigned e=0;e<a.size();++e){refs[cursor[a[e]]++]=e;refs[cursor[b[e]]++]=e|0x80000000u;}
        std::iota(order.begin(),order.end(),0);if(anchored)std::rotate(order.begin(),order.begin()+1,order.end());last[0]=n-unsigned(anchored);
    }
    void edge(unsigned x,unsigned y){a.push_back(x);b.push_back(y);const auto p=position[x],q=position[y];
        offset0.push_back(make_float4((q.x-p.x)/2,(q.y-p.y)/2,(q.z-p.z)/2,0));offset1.push_back(make_float4((p.x-q.x)/2,(p.y-q.y)/2,(p.z-q.z)/2,0));}
};
bool run(Fixture f){
    bool passed=true;
    const unsigned n=f.n,m=f.a.size();cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    {
        Device<unsigned> begin(n+1),refs(m*2),a(m),b(m),labels(n),order(n),ids(1),first(n),last(n),counts(2);
        Device<float4> position(n),offset0(m),offset1(m);Device<float2> inverse(n);Device<float> health(m),scale(m);Device<std::uint64_t> generation(1);
        begin.put(f.begin);refs.put(f.refs);a.put(f.a);b.put(f.b);labels.put(f.labels);order.put(f.order);ids.put({0});first.put(f.first);last.put(f.last);counts.put({n-unsigned(f.anchored),1});
        position.put(f.position);offset0.put(f.offset0);offset1.put(f.offset1);std::vector<float2> d(n,make_float2(1,1));if(f.anchored)d[0]=make_float2(0,0);inverse.put(d);
        health.put(std::vector<float>(m,1));scale.put(std::vector<float>(m,1));generation.put({0});
        Input input{n,m,begin.data,refs.data,a.data,b.data,labels.data,health.data,scale.data,position.data,offset0.data,offset1.data,inverse.data,generation.data,nullptr};
        input.partition={order.data,ids.data,first.data,last.data,counts.data,counts.data+1};
        ResidentHierarchy hierarchy(input,16,stream);cudaGraph_t graph;cudaGraphExec_t executable;check(cudaGraphCreate(&graph,0));hierarchy.append(graph,nullptr);
        check(cudaGraphInstantiate(&executable,graph,0));check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));Status status{};
        check(cudaMemcpy(&status,hierarchy.status(),sizeof(status),cudaMemcpyDeviceToHost));require(status.initialized && !status.error,"candidate hierarchy failed");
        ResidentCycle cycle(hierarchy);Device<Vector> rhs(n),x(n),r(n),v(size_t(n)*(KrylovRestart+1)),z(size_t(n)*KrylovRestart);
        Device<KrylovState> result(1),cooperative(1);Device<double> partial(1024);
        std::vector<Vector> hostRhs;for(auto row:f.rhs)hostRhs.push_back(pack(row));rhs.put(hostRhs);
        KrylovView view{cycle.deviceView(),rhs.data,x.data,r.data,v.data,z.data,result.data,cooperative.data,partial.data,128,1e-5};
        for(bool local:{true,false}){
            if(local)residentKrylov<true><<<1,Threads,0,stream>>>(view);
            else {int resident=0,sms=0,device=0;check(cudaGetDevice(&device));check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));
                check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&resident,residentKrylov<false>,Threads,0));require(resident>0,"candidate cooperative residency");
                const unsigned blocks=std::min((n+7)/8,unsigned(resident*sms));void* args[]={&view};check(cudaLaunchCooperativeKernel((void*)residentKrylov<false>,dim3(blocks),dim3(Threads),args,0,stream));}
            check(cudaGetLastError());check(cudaStreamSynchronize(stream));const auto state=result.get()[0];const auto answer=x.get();
            double worst=0;for(unsigned e=0;e<m;++e){const auto p=coupled(unpack(answer[f.a[e]]),f.offset0[e]),q=coupled(unpack(answer[f.b[e]]),f.offset1[e]);
                for(unsigned k=0;k<6;++k)worst=std::max(worst,std::abs(p[k]-q[k]-f.bond[e][k])/std::max(1.,std::abs(f.bond[e][k])));}
            std::printf("resident right-FGMRES candidate nodes=%u bonds=%u anchored=%u axial=%u incompatible=%u closed=%u local=%u iterations=%u converged=%u error=%u gradient2=%.9g threshold2=%.9g bond_error=%.9g\n",n,m,f.anchored,f.axial,f.incompatible,f.closed,local,state.iterations,state.converged,state.error,state.gradient,state.threshold,worst);std::fflush(stdout);
            // Retain all cases, including a rejected candidate's later cases.
            // The executable still fails if any convergence or physical check fails.
            passed=passed && !state.error && state.converged && state.iterations<=view.maxIterations && std::isfinite(worst) && worst<2e-4;
        }
        check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
    }
    check(cudaStreamDestroy(stream));return passed;
}
}
int main(int argc,char** argv){try{
    const bool axial=argc==2 && std::string(argv[1])=="axial";require(argc==1 || axial,"usage: gpu_resident_krylov_test [axial]");
    bool passed=true;for(unsigned n:{12u,1024u,1028u})passed=run(Fixture(n,false,true,false,false)) && passed;
    if(!axial){for(const auto f:{Fixture(24,true,false,false,false),Fixture(24,false,false,false,false),Fixture(24,false,false,true,false),Fixture(24,false,false,true,true),Fixture(128,false,false,true,false)})passed=run(f) && passed;}
    require(passed,"candidate convergence or physical bond response failed");return 0;
}catch(const std::exception& e){std::fprintf(stderr,"resident Krylov candidate: %s\n",e.what());return 1;}}
