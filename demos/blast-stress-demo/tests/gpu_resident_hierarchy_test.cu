// Independent connectivity and B^T P / Galerkin checks for GPU construction.
#include "StressHierarchyGraph.cuh"
#include "StressHierarchyOperator.cuh"
#include "StressHierarchyPackedLevel.cuh"
#include "StressHierarchyLevelOperator.cuh"
#include "StressHierarchyTransfers.cuh"
#include <memory>
#include <array>
#include <cstdio>
#include <vector>
#include <numeric>
#include <queue>
#include <cstring>
#include <limits>
using namespace Nv::Blast::StressHierarchy;
namespace {
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>struct Device {
    T* data=nullptr;size_t count;
    explicit Device(size_t n):count(n){check(cudaMalloc(&data,std::max(size_t(1),n)*sizeof(T)));}
    ~Device(){cudaFree(data);}
    void put(const std::vector<T>& v,cudaStream_t stream){require(v.size()==count,"upload size");if(count)check(cudaMemcpyAsync(data,v.data(),count*sizeof(T),cudaMemcpyHostToDevice,stream));check(cudaStreamSynchronize(stream));}
    std::vector<T> get(cudaStream_t stream){std::vector<T> v(count);if(count)check(cudaMemcpyAsync(v.data(),data,count*sizeof(T),cudaMemcpyDeviceToHost,stream));check(cudaStreamSynchronize(stream));return v;}
};
struct Fixture {
    bool omitUncoupled=false;
    std::vector<float4> positions,offset0,offset1;
    std::vector<float2> inverse;
    std::vector<unsigned> a,b,begin,refs,component;
    std::vector<float> health,scale;
    explicit Fixture(unsigned n):positions(n),inverse(n,make_float2(1,1)),begin(n+1),component(n){
        for(unsigned i=0;i<n;++i){positions[i]=make_float4(float(i%13),float(i/13),float(i%3),0);inverse[i]=make_float2(.5f+float(i%5)/8,1.f+float(i%7)/4);}
    }
    void edge(unsigned first,unsigned second){
        a.push_back(first);b.push_back(second);health.push_back(1);scale.push_back(.5f+float(a.size()%9)/8);
        const auto x=positions[first],y=positions[second];
        offset0.push_back(make_float4((y.x-x.x)/2,(y.y-x.y)/2,(y.z-x.z)/2,0));
        offset1.push_back(make_float4((x.x-y.x)/2,(x.y-y.y)/2,(x.z-y.z)/2,0));
    }
    void csr(){
        std::fill(begin.begin(),begin.end(),0);for(unsigned i=0;i<a.size();++i){++begin[a[i]+1];++begin[b[i]+1];}
        std::partial_sum(begin.begin(),begin.end(),begin.begin());refs.resize(a.size()*2);auto cursor=begin;
        for(unsigned i=0;i<a.size();++i){refs[cursor[a[i]]++]=i;refs[cursor[b[i]]++]=i|0x80000000u;}
    }
    void partition(){
        std::fill(component.begin(),component.end(),Invalid);
        for(unsigned seed=0;seed<positions.size();++seed){
            if(component[seed]!=Invalid || inverse[seed].x==0)continue;
            std::queue<unsigned> queue;queue.push(seed);component[seed]=seed;
            while(!queue.empty()){
                unsigned node=queue.front();queue.pop();
                for(unsigned j=begin[node];j<begin[node+1];++j){const auto ref=refs[j];if(ref==Invalid)continue;const auto edge=ref&0x7fffffffu;
                    if(health[edge]<=0)continue;const auto other=(ref>>31)?a[edge]:b[edge];
                    if(inverse[other].x && component[other]==Invalid){component[other]=seed;queue.push(other);}
                }
            }
        }
        if(omitUncoupled){
            std::vector<unsigned> live(component.size());
            for(unsigned e=0;e<a.size();++e)if(health[e]>0){live[a[e]]=1;live[b[e]]=1;}
            for(unsigned node=0;node<component.size();++node)if(!live[node])component[node]=Invalid;
        }
    }
};
using Six=std::array<double,6>;
using Three=std::array<double,3>;
Three cross(Three a,Three b){return {a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]};}
Six factor(Six x,float2 d,Three offset){
    Three angular{x[0]*d.x,x[1]*d.x,x[2]*d.x};const auto c=cross(offset,angular);
    return {angular[0],angular[1],angular[2],x[3]*d.y+c[0],x[4]*d.y+c[1],x[5]*d.y+c[2]};
}
void verifyFactor(const Fixture& f,const std::vector<unsigned>& leaders,const std::vector<CoarseBond>& coarse){
    // Sweep every scalar coarse basis column, not only random right-hand sides.
    // Equality of B^T P then proves equality of P^T B B^T P to the coarse
    // Gram operator, including full force/moment coupling and self-edges.
    double worst=0;
    for(unsigned root=0;root<leaders.size();++root)if(leaders[root]==root)for(unsigned col=0;col<6;++col){
        std::vector<Six> fine(leaders.size());
        for(unsigned node=0;node<leaders.size();++node)if(leaders[node]==root){
            Six v{};v[col]=1;const Three omega{v[0],v[1],v[2]};
            const auto p=f.positions[node],o=f.positions[root];const auto shift=cross({double(p.x)-o.x,double(p.y)-o.y,double(p.z)-o.z},omega);
            for(unsigned k=0;k<3;++k){fine[node][k]=v[k]/f.inverse[node].x;fine[node][k+3]=(v[k+3]+shift[k])/f.inverse[node].y;}
        }
        for(unsigned edge=0;edge<f.a.size();++edge){
            const auto r0=f.offset0[edge],r1=f.offset1[edge];
            auto x=factor(fine[f.a[edge]],f.inverse[f.a[edge]],{r0.x,r0.y,r0.z});
            auto y=factor(fine[f.b[edge]],f.inverse[f.b[edge]],{r1.x,r1.y,r1.z});
            const auto c=coarse[edge];Six u{},v{};if(c.a==root)u[col]=1;if(c.b==root)v[col]=1;
            u=factor(u,make_float2(1,1),{c.offset0.x,c.offset0.y,c.offset0.z});
            v=factor(v,make_float2(1,1),{c.offset1.x,c.offset1.y,c.offset1.z});
            for(unsigned k=0;k<6;++k){const double expected=f.health[edge]>0?f.scale[edge]*(x[k]-y[k]):0;
                const double actual=c.scale*(u[k]-v[k]);const double error=std::abs(actual-expected)/std::max(1.,std::abs(expected));
                require(std::isfinite(actual)&&error<2e-12,"GPU coarse factor disagrees with independent B^T P");worst=std::max(worst,error);}
        }
    }
    std::printf("coarse factor full-basis check: nodes=%zu bonds=%zu max scaled error=%.3g\n",f.positions.size(),f.a.size(),worst);
}
void verifyPartition(const Fixture& f,const std::vector<unsigned>& leaders,unsigned aggregateCount){
    unsigned count=0;std::vector<unsigned> members(leaders.size()),seen(leaders.size());
    for(unsigned i=0;i<leaders.size();++i){
        if(f.component[i]==Invalid){require(leaders[i]==Invalid,"static node joined aggregate");continue;}
        const auto root=leaders[i];require(root<=i && root<leaders.size() && leaders[root]==root,"invalid minimum-ID leader");
        require(f.component[root]==f.component[i],"aggregate crossed a component boundary");++members[root];if(root==i)++count;
    }
    require(count==aggregateCount,"aggregate count incorrect");
    for(unsigned root=0;root<leaders.size();++root)if(members[root]){
        std::queue<unsigned> queue;queue.push(root);seen[root]=1;unsigned reached=0;
        while(!queue.empty()){
            auto node=queue.front();queue.pop();++reached;
            for(unsigned j=f.begin[node];j<f.begin[node+1];++j){auto ref=f.refs[j];if(ref==Invalid)continue;auto edge=ref&0x7fffffffu;
                if(f.health[edge]<=0)continue;auto other=(ref>>31)?f.a[edge]:f.b[edge];
                if(leaders[other]==root && !seen[other]){seen[other]=1;queue.push(other);}
            }
        }
        require(reached==members[root],"aggregate is disconnected");
    }
}
#include "gpu_resident_hierarchy_operator_checks.cuh"
#include "gpu_resident_hierarchy_recursive_checks.cuh"
#include "gpu_resident_hierarchy_partition_checks.cuh"
void run(Fixture f,bool transitions,bool factorCheck,unsigned expectedInitial=Invalid){
    f.csr();f.partition();const auto n=f.positions.size(),m=f.a.size();
    std::printf("START GPU hierarchy: nodes=%zu bonds=%zu\n",n,m);std::fflush(stdout);cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    {
        Device<unsigned> begin(n+1),refs(2*m),a(m),b(m),component(n),accept(1),partNodes(n),partIds(n),partBegin(n),partEnd(n),partCounts(2);
        Device<float2> inertia(n);inertia.put(f.inverse,stream);
        Device<float> health(m),scale(m);Device<float4> position(n),offset0(m),offset1(m);Device<std::uint64_t> generation(1);
        Graph graph(n,m,stream);begin.put(f.begin,stream);refs.put(f.refs,stream);a.put(f.a,stream);b.put(f.b,stream);
        scale.put(f.scale,stream);position.put(f.positions,stream);offset0.put(f.offset0,stream);offset1.put(f.offset1,stream);
        Input input{unsigned(n),unsigned(m),begin.data,refs.data,a.data,b.data,component.data,health.data,scale.data,
            position.data,offset0.data,offset1.data,inertia.data,generation.data,accept.data};
        input.partition={partNodes.data,partIds.data,partBegin.data,partEnd.data,partCounts.data,partCounts.data+1};
        // Test-only oracle supplies the partition owned by native GPU topology
        // in production. No CPU partition construction is part of the solver.
        auto uploadPartition=[&](){
            std::vector<unsigned> nodes(n,Invalid),ids(n,Invalid),first(n),last(n);unsigned count=0,parts=0;
            for(unsigned i=0;i<n;++i)if(f.component[i]!=Invalid)nodes[count++]=i;
            std::sort(nodes.begin(),nodes.begin()+count,[&](unsigned a,unsigned b){return std::make_pair(f.component[a],a)<std::make_pair(f.component[b],b);});
            for(unsigned i=0;i<count;++i){const unsigned id=f.component[nodes[i]];if(!i || f.component[nodes[i-1]]!=id){ids[parts++]=id;first[id]=i;}last[id]=i+1;}
            partNodes.put(nodes,stream);partIds.put(ids,stream);partBegin.put(first,stream);partEnd.put(last,stream);partCounts.put({count,parts},stream);
        };
        cudaGraph_t captured=nullptr;cudaGraphExec_t executable=nullptr;
        check(cudaGraphCreate(&captured,0));auto priorNode=graph.append(captured,nullptr,input);
        RecursiveChain recursive;recursive.append(captured,priorNode,input,graph,stream,n>1000?8:3);
        check(cudaGraphInstantiate(&executable,captured,0));
        auto launch=[&](){check(cudaGraphLaunch(executable,stream));};
        std::vector<unsigned> prior,initial;Status old{};
        const auto originalHealth=f.health;
        for(unsigned step=0;step<(transitions?6u:2u);++step){
            f.health=originalHealth;
            if(step==2 || step==3)for(unsigned i=0;i<m;++i)if(i%3==0)f.health[i]=0;
            if(step==4)std::fill(f.health.begin(),f.health.end(),0);
            f.partition();health.put(f.health,stream);component.put(f.component,stream);uploadPartition();
            const std::uint64_t gen=step==1?0:step;generation.put({gen},stream);accept.put({1},stream);launch();
            Status status;std::vector<unsigned> leaders(n);std::vector<CoarseBond> coarse(m);
            check(cudaMemcpyAsync(&status,graph.status(),sizeof(status),cudaMemcpyDeviceToHost,stream));
            if(n)check(cudaMemcpyAsync(leaders.data(),graph.leaders(),n*sizeof(unsigned),cudaMemcpyDeviceToHost,stream));
            if(m)check(cudaMemcpyAsync(coarse.data(),graph.coarseBonds(),m*sizeof(CoarseBond),cudaMemcpyDeviceToHost,stream));
            check(cudaStreamSynchronize(stream));
            require(!status.error && status.initialized && status.generation==gen,"hierarchy did not commit");
            verifyPartition(f,leaders,status.aggregates);verifyOperators(f,leaders,graph,input,stream);
            verifyRecursive(f,recursive,leaders,coarse,gen,stream);if(step==0 && expectedInitial!=Invalid)require(status.aggregates==expectedInitial,"hub aggregation failed to coarsen");if(factorCheck)verifyFactor(f,leaders,coarse);
            if(step==0)initial=leaders;
            if(step==5)require(leaders==initial,"restored physical graph changed aggregate identities");
            if(step==1){require(status.builds==old.builds && status.rounds==old.rounds,"unchanged generation rebuilt");require(leaders==prior,"unchanged generation changed mapping");}
            if(step==3)require(leaders==prior,"identical graph produced different aggregates");
            if(step==5 && n){require(status.aggregates<=n,"restored graph aggregate overflow");}
            prior=leaders;old=status;
        }
        verifyPackingPartitionFailures(input,graph,stream);
        for(unsigned level=0;level<recursive.inputs.size();++level)verifyPackingPartitionFailures(recursive.inputs[level],*recursive.graphs[level],stream);
        verifyRecursiveFailures(recursive,stream);
        const auto acceptedRecursive=recursiveState(recursive,stream);
        // Rejected transaction must leave committed GPU outputs untouched.
        health.put(std::vector<float>(m,0),stream);
        accept.put({0},stream);generation.put({99},stream);launch();Status rejected;
        check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));check(cudaStreamSynchronize(stream));
        require(!std::memcmp(&old,&rejected,sizeof(old)),"rejected transaction changed status");
        const auto rejectedRecursive=recursiveState(recursive,stream);
        require(acceptedRecursive.size()==rejectedRecursive.size() && !std::memcmp(acceptedRecursive.data(),rejectedRecursive.data(),acceptedRecursive.size()*sizeof(Status)),"rejected command changed a recursive level");
        std::vector<unsigned> unchanged(n);
        if(n)check(cudaMemcpyAsync(unchanged.data(),graph.leaders(),n*sizeof(unsigned),cudaMemcpyDeviceToHost,stream));
        check(cudaStreamSynchronize(stream));require(unchanged==prior,"rejected topology overwrote committed aggregates");
        accept.put({1},stream);
        if(old.generation){generation.put({0},stream);launch();check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));check(cudaStreamSynchronize(stream));require(rejected.error==4 && rejected.generation==old.generation,"generation rewind not rejected");}
        // Invalid endpoint data must fail explicitly, not become missing work.
        if(m){auto bad=f.a;bad[0]=unsigned(n);a.put(bad,stream);health.put(originalHealth,stream);generation.put({100},stream);launch();
            check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));check(cudaStreamSynchronize(stream));require(rejected.error && rejected.generation!=100,"invalid endpoint committed");
            a.put(f.a,stream);auto badScale=f.scale;badScale[0]=std::numeric_limits<float>::quiet_NaN();scale.put(badScale,stream);
            generation.put({101},stream);launch();check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));
            check(cudaStreamSynchronize(stream));require(rejected.error==2 && rejected.generation!=101,"nonfinite coarse coefficient committed");
        }
        if(n){
            a.put(f.a,stream);scale.put(f.scale,stream);health.put(f.health,stream);component.put(f.component,stream);
            auto bad=f.inverse;bad[0].x=std::numeric_limits<float>::quiet_NaN();inertia.put(bad,stream);
            generation.put({102},stream);launch();check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));
            check(cudaStreamSynchronize(stream));require(rejected.error==8 && rejected.generation!=102,"invalid inertia committed");
            inertia.put(f.inverse,stream);generation.put({103},stream);launch();
            check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));
            check(cudaStreamSynchronize(stream));require(!rejected.error && rejected.generation==103,"failed construction did not recover");
            for(unsigned node=0;node<n;++node)if(f.component[node]!=Invalid){
                bool live=false;for(unsigned slot=f.begin[node];slot<f.begin[node+1];++slot){const auto ref=f.refs[slot];if(ref!=Invalid)live=live || f.health[ref&0x7fffffffu]>0;}
                if(!live)continue;
                auto missing=f.component;missing[node]=Invalid;component.put(missing,stream);generation.put({104},stream);launch();
                check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));
                check(cudaStreamSynchronize(stream));require((rejected.error&1) && rejected.generation!=104,"live stress row was silently omitted");
                component.put(f.component,stream);break;
            }
            if(n==2 && m==1){
                auto excessive=f.offset0;excessive[0]=make_float4(1e20f,0,0,0);offset0.put(excessive,stream);
                generation.put({105},stream);launch();check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));
                check(cudaStreamSynchronize(stream));require(rejected.error==16 && rejected.generation!=105,"unfactorable diagonal used a fallback or committed");
                offset0.put(f.offset0,stream);
            }
            generation.put({106},stream);launch();check(cudaMemcpyAsync(&rejected,graph.status(),sizeof(rejected),cudaMemcpyDeviceToHost,stream));
            check(cudaStreamSynchronize(stream));require(!rejected.error && rejected.generation==106,"construction did not recover after structural/numerical failure");
        }
        check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(captured));
        std::printf("GPU hierarchy: nodes=%zu bonds=%zu final aggregates=%u rounds=%u transitions=%u passed\n",n,m,old.aggregates,old.rounds,transitions?6:2);
    }
    check(cudaStreamDestroy(stream));
}
}
int main(){try{
    run(Fixture(0),false,true);run(Fixture(1),false,true);run(Fixture(256),false,false);
    Fixture small(24);small.inverse[0]=small.inverse[12]=make_float2(0,0);
    for(unsigned i=1;i<24;++i)if(i!=12)small.edge(i-1,i);
    for(unsigned i=2;i<12;++i)small.edge(i-2,i);
    // One static boundary may support otherwise disconnected components.
    small.edge(0,13);run(small,true,true);
    Fixture self(2);self.edge(0,1);self.offset1[0].x+=.03125f;run(self,true,true);
    Fixture parallel(6);for(unsigned i=1;i<6;++i){parallel.edge(0,i);parallel.edge(0,i);}
    run(parallel,true,true,1);
    Fixture omitted(24);omitted.omitUncoupled=true;for(unsigned i=1;i<12;++i)omitted.edge(i-1,i);
    run(omitted,true,true);
    Fixture star(257);for(unsigned i=1;i<257;++i)star.edge(0,i);run(star,false,false,1);
    Fixture fixed(4);for(auto& inv:fixed.inverse)inv=make_float2(0,0);for(unsigned i=1;i<4;++i)fixed.edge(i-1,i);run(fixed,true,true,0);
    Fixture mixed(129);for(unsigned i=1;i<129;++i)if(i%17)mixed.edge(i-1,i);run(mixed,true,false);
    Fixture large(100000);for(unsigned i=1;i<100000;++i){large.edge(i-1,i);if(i>1)large.edge(i-2,i);}run(large,true,false);
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"resident hierarchy: %s\n",e.what());return 1;}}
