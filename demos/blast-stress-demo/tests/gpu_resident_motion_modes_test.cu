// Compile the actual native connectivity producer in this test translation
// unit; do not substitute a second union algorithm or add a public debug API.
#include "NvBlastExtStressGpu.cu"
// Retain the general dense cached-inverse reference and its original tests.
// It is not included or selected by the production runtime.
namespace Nv { namespace Blast { namespace {
#include "detail/StressNativeFineInverse.cuh"
}}}
#include <array>
#include <queue>
#include <cstdio>
#include <numeric>
using namespace Nv::Blast;
using namespace Nv::Blast::StressHierarchy;
namespace MotionModeTest {
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
void require(bool ok,const char* text){if(!ok)throw std::runtime_error(text);}
template<class T>struct Device {
    T* data=nullptr;size_t size;
    explicit Device(size_t n):size(n){check(cudaMalloc(&data,std::max(size_t(1),n)*sizeof(T)));check(cudaMemset(data,0,std::max(size_t(1),n)*sizeof(T)));check(cudaStreamSynchronize(nullptr));}
    ~Device(){cudaFree(data);}
    void put(const std::vector<T>& v){require(v.size()==size,"motion test upload size");if(size)check(cudaMemcpy(data,v.data(),size*sizeof(T),cudaMemcpyHostToDevice));
        // Pageable H2D staging may return before the default stream finishes.
        // The native producer uses a nonblocking stream, so order this test's
        // CPU-uploaded fixtures explicitly before launching that producer.
        check(cudaStreamSynchronize(nullptr));}
    std::vector<T> get(){std::vector<T> v(size);if(size)check(cudaMemcpy(v.data(),data,size*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
// Independently exercise the exact-zero certificate on the native forest.
__global__ void homogeneousCertificates(Input input,MotionModeView modes,const ExtStressGpuImpulse* loads,unsigned* out){
    PersistentStressArgs a{};a.input=loads;a.hierarchy.modes=modes;
    a.m_nodeBondBegin=const_cast<unsigned*>(input.begin);a.m_nodeBondRef=const_cast<unsigned*>(input.refs);a.m_health=const_cast<float*>(input.health);
    for(unsigned slot=blockIdx.x;slot<*input.partition.count;slot+=gridDim.x){const unsigned id=input.partition.ids[slot];bool reject=false;
        for(unsigned i=input.partition.begin[id]+threadIdx.x;i<input.partition.end[id];i+=blockDim.x)reject|=nonHomogeneousTreeNode(a,orderedNode(input,i));
        const bool any=__syncthreads_or(reject);if(!threadIdx.x)out[id]=!any;__syncthreads();}
}
using Three=std::array<long double,3>;using Six=std::array<long double,6>;
Three plus(Three a,Three b){for(unsigned k=0;k<3;++k)a[k]+=b[k];return a;}
Three minus(Three a,Three b){for(unsigned k=0;k<3;++k)a[k]-=b[k];return a;}
Three times(Three a,long double v){for(auto& x:a)x*=v;return a;}
Three product(Three a,Three b){return {a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]};}
Three coord(float4 p){return {p.x,p.y,p.z};}
bool nonzero(Three a){return a[0]!=0 || a[1]!=0 || a[2]!=0;}
Six unpack(Vector v){return {v.angular.x,v.angular.y,v.angular.z,v.linear.x,v.linear.y,v.linear.z};}
Vector pack(Six v){return {{double(v[0]),double(v[1]),double(v[2])},{double(v[3]),double(v[4]),double(v[5])}};}
struct Fixture {
    unsigned n;std::vector<unsigned> a,b,begin,refs;std::vector<float4> position,offset0,offset1;
    std::vector<float> health,scale;std::vector<Inertia> inertia;
    explicit Fixture(unsigned count):n(count),begin(n+1),position(n),inertia(n){
        for(unsigned i=0;i<n;++i){position[i]={float(i%13),float(i/13),float(i%3),0};inertia[i]={.5f+float(i%5)/8,1.f+float(i%7)/4};}
    }
    void edge(unsigned u,unsigned v){a.push_back(u);b.push_back(v);health.push_back(1);scale.push_back(1);
        const auto d=minus(coord(position[v]),coord(position[u]));offset0.push_back({float(d[0]/2),float(d[1]/2),float(d[2]/2),0});offset1.push_back({-float(d[0]/2),-float(d[1]/2),-float(d[2]/2),0});}
    void csr(){std::fill(begin.begin(),begin.end(),0);for(unsigned e=0;e<a.size();++e){++begin[a[e]+1];++begin[b[e]+1];}
        std::partial_sum(begin.begin(),begin.end(),begin.begin());refs.resize(a.size()*2);auto cursor=begin;
        for(unsigned e=0;e<a.size();++e){refs[cursor[a[e]]++]=e;refs[cursor[b[e]]++]=e|0x80000000u;}}
};
struct Oracle {
    struct Component{std::vector<unsigned> nodes;bool anchored=false;unsigned rotations=3;Three axis{},center{};};
    std::vector<Component> components;std::vector<unsigned> labels,ids,order,begin,end;std::vector<Three> position;
    Oracle(const Fixture& f):components(f.n),labels(f.n,Invalid),order(f.n,Invalid),begin(f.n),end(f.n),position(f.n){
        for(unsigned seed=0;seed<f.n;++seed){if(!f.inertia[seed].linear || labels[seed]!=Invalid)continue;
            bool live=false;for(unsigned j=f.begin[seed];j<f.begin[seed+1];++j)live=live || f.health[f.refs[j]&0x7fffffffu]>0;if(!live)continue;
            ids.push_back(seed);std::queue<unsigned> todo;todo.push(seed);labels[seed]=seed;auto& c=components[seed];
            while(!todo.empty()){const unsigned u=todo.front();todo.pop();c.nodes.push_back(u);
                for(unsigned j=f.begin[u];j<f.begin[u+1];++j){const auto ref=f.refs[j],e=ref&0x7fffffffu;if(f.health[e]<=0)continue;const unsigned v=(ref>>31)?f.a[e]:f.b[e];
                    if(!f.inertia[v].linear){c.anchored=true;continue;}if(labels[v]!=Invalid)continue;
                    auto delta=minus(coord(f.offset0[e]),coord(f.offset1[e]));if(ref>>31)delta=times(delta,-1);position[v]=plus(position[u],delta);labels[v]=seed;todo.push(v);}}
            std::sort(c.nodes.begin(),c.nodes.end());
        }
        for(unsigned e=0;e<f.a.size();++e){if(f.health[e]<=0)continue;const auto id=labels[f.a[e]];if(id==Invalid || labels[f.b[e]]!=id)continue;auto& c=components[id];
            const auto delta=minus(plus(position[f.a[e]],minus(coord(f.offset0[e]),coord(f.offset1[e]))),position[f.b[e]]);
            if(!nonzero(delta))continue;if(!nonzero(c.axis)){c.axis=delta;c.rotations=1;}else if(nonzero(product(c.axis,delta)))c.rotations=0;
        }
        unsigned count=0;for(auto id:ids){auto& c=components[id];begin[id]=count;long double mass=0;Three center{};
            for(auto node:c.nodes){order[count++]=node;const long double d=f.inertia[node].linear,w=1/(d*d);mass+=w;center=plus(center,times(position[node],w));}end[id]=count;c.center=times(center,1/mass);
            if(c.rotations==1){const auto norm=std::sqrt(c.axis[0]*c.axis[0]+c.axis[1]*c.axis[1]+c.axis[2]*c.axis[2]);c.axis=times(c.axis,1/norm);}
        }
    }
    Six basis(const Fixture& f,unsigned node,unsigned k)const{
        const auto& c=components[labels[node]];Three omega{},translation{};
        if(k<c.rotations){if(c.rotations==1)omega=c.axis;else omega[k]=1;}else translation[k-c.rotations]=1;
        translation=plus(translation,product(minus(position[node],c.center),omega));Six out{};
        for(unsigned j=0;j<3;++j){out[j]=omega[j]/f.inertia[node].angular;out[j+3]=translation[j]/f.inertia[node].linear;}return out;
    }
    std::vector<Vector> project(const Fixture& f,const std::vector<Vector>& input)const{
        auto output=input;for(auto id:ids){const auto& c=components[id];if(c.anchored)continue;const unsigned d=c.rotations+3;
            long double matrix[6][6]{},rhs[6]{},solution[6]{};
            for(auto node:c.nodes){Six columns[6];for(unsigned k=0;k<d;++k)columns[k]=basis(f,node,k);const auto v=unpack(input[node]);
                for(unsigned row=0;row<d;++row)for(unsigned k=0;k<6;++k){rhs[row]+=columns[row][k]*v[k];for(unsigned col=0;col<d;++col)matrix[row][col]+=columns[row][k]*columns[col][k];}}
            // Independent long-double Gaussian elimination, not the device's
            // equilibrated Cholesky implementation or its selected forest.
            for(unsigned k=0;k<d;++k){unsigned pivot=k;for(unsigned i=k+1;i<d;++i)if(std::abs(matrix[i][k])>std::abs(matrix[pivot][k]))pivot=i;
                require(matrix[pivot][k]!=0,"oracle singular rigid Gram");for(unsigned j=0;j<d;++j)std::swap(matrix[k][j],matrix[pivot][j]);std::swap(rhs[k],rhs[pivot]);
                for(unsigned i=k+1;i<d;++i){const auto factor=matrix[i][k]/matrix[k][k];for(unsigned j=k;j<d;++j)matrix[i][j]-=factor*matrix[k][j];rhs[i]-=factor*rhs[k];}}
            for(int i=int(d)-1;i>=0;--i){auto value=rhs[i];for(unsigned j=i+1;j<d;++j)value-=matrix[i][j]*solution[j];solution[i]=value/matrix[i][i];}
            for(auto node:c.nodes){auto v=unpack(input[node]);for(unsigned k=0;k<d;++k){const auto column=basis(f,node,k);for(unsigned j=0;j<6;++j)v[j]-=column[j]*solution[k];}output[node]=pack(v);}
        }return output;
    }
};
__global__ void projectObserved(Input a,MotionModeView modes,const Vector* input,Vector* output){
    if(!modes.status->initialized || modes.status->error || modes.status->generation!=*a.generation)return;
    for(unsigned node=blockIdx.x*blockDim.x+threadIdx.x;node<a.nodes;node+=gridDim.x*blockDim.x)if(a.component[node]==Invalid)output[node]=input[node];
    for(unsigned slot=blockIdx.x;slot<*a.partition.count;slot+=gridDim.x){const unsigned id=a.partition.ids[slot],begin=a.partition.begin[id],count=a.partition.end[id]-begin;
        for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const auto node=orderedNode(a,begin+i);output[node]=input[node];}__syncthreads();
        projectMotionComponent(a,modes,id,a.partition.nodes+begin,count,output);__syncthreads();}
}
__global__ void checkPredicates(unsigned* result){
    const double epsilon=0x1p-27;
    result[0]=!motionCollinear({1+epsilon,1,0},{1,1-epsilon,0});
    result[1]=motionCollinear({1+epsilon,1,0},{2+2*epsilon,2,0});
    result[2]=motionCollinear({0,0,0},{1,2,3});
}
void run(Fixture f,bool transitions){
    f.csr();const unsigned n=f.n,m=f.a.size();cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    {
        Device<unsigned> a(m),b(m),begin(n+1),refs(2*m),parent(n),identity(std::max(n,m)),flags(n),nodeIsland(n),bondIsland(m),forest(m);
        Device<unsigned> order(n),ids(n),first(n),last(n),counts(2),accept(1);Device<std::uint64_t> generation(1);
        Device<float4> position(n),offset0(m),offset1(m);Device<Inertia> inertia(n);Device<float> health(m),scale(m);
        Device<DeviceStressTopologyBatch> batch(1);Device<ExtStressGpuDeviceTopologyStatus> nativeStatus(1);
        a.put(f.a);b.put(f.b);begin.put(f.begin);refs.put(f.refs);position.put(f.position);offset0.put(f.offset0);offset1.put(f.offset1);inertia.put(f.inertia);scale.put(f.scale);batch.put({{nullptr,nullptr,nullptr}});accept.put({1});
        Input input{n,m,begin.data,refs.data,a.data,b.data,nodeIsland.data,health.data,scale.data,position.data,offset0.data,offset1.data,reinterpret_cast<const float2*>(inertia.data),generation.data,accept.data};
        input.partition={order.data,ids.data,first.data,last.data,counts.data,counts.data+1};
        ResidentMotionModes modes(input,forest.data,stream);cudaGraph_t graph;cudaGraphExec_t executable;check(cudaGraphCreate(&graph,0));modes.append(graph,nullptr);check(cudaGraphInstantiate(&executable,graph,0));
        Device<Vector> values(n),result(n);std::vector<Vector> loads(n);for(unsigned i=0;i<n;++i){Six v{};for(unsigned k=0;k<6;++k)v[k]=(int((i*17+k*7)%23)-11)/16.L;loads[i]=pack(v);}values.put(loads);
        Status prior{};const auto original=f.health;
        for(unsigned step=0;step<(transitions?4u:2u);++step){
            const unsigned gen=step==1?0:step;generation.put({gen});
            if(step!=1){f.health=original;if(step==2)for(unsigned e=0;e<m;++e)if(e%7==0 || !f.inertia[f.a[e]].linear || !f.inertia[f.b[e]].linear)f.health[e]=0;health.put(f.health);
                const unsigned nb=std::max(1u,(n+Threads-1)/Threads),eb=std::max(1u,(m+Threads-1)/Threads);
                beginDeviceStressRebuild<<<1,1,0,stream>>>(nativeStatus.data);
                initializeDeviceStressTopology<<<std::max(nb,eb),Threads,0,stream>>>(batch.data,inertia.data,parent.data,identity.data,flags.data,health.data,n,m,forest.data);
                connectDeviceStressTopology<<<eb,Threads,0,stream>>>(a.data,b.data,health.data,inertia.data,m,parent.data,forest.data);flattenDeviceStressTopology<<<nb,Threads,0,stream>>>(parent.data,n);
                labelDeviceStressBonds<<<eb,Threads,0,stream>>>(a.data,b.data,health.data,inertia.data,parent.data,flags.data,bondIsland.data,m);
                labelDeviceStressNodes<<<nb,Threads,0,stream>>>(parent.data,flags.data,nodeIsland.data,n,nativeStatus.data);check(cudaGetLastError());check(cudaStreamSynchronize(stream));
            }
            Oracle oracle(f);const auto nativeLabels=nodeIsland.get();
            if(nativeLabels!=oracle.labels){for(unsigned i=0;i<n;++i)if(nativeLabels[i]!=oracle.labels[i]){std::fprintf(stderr,"native label mismatch n=%u m=%u node=%u actual=%u expected=%u parent=%u health0=%g\n",n,m,i,nativeLabels[i],oracle.labels[i],parent.get()[i],health.get()[0]);break;}}
            require(nativeLabels==oracle.labels,"native connectivity changed with forest witnesses");
            require(nativeStatus.get()[0].islandCount==oracle.ids.size(),"native component count changed with forest witnesses");
            order.put(oracle.order);first.put(oracle.begin);last.put(oracle.end);auto live=oracle.ids;live.resize(n,Invalid);ids.put(live);unsigned active=0;for(auto id:oracle.ids)active+=oracle.components[id].nodes.size();counts.put({active,unsigned(oracle.ids.size())});
            check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));Status status{};check(cudaMemcpy(&status,modes.status(),sizeof(status),cudaMemcpyDeviceToHost));
            if(status.error)std::fprintf(stderr,"motion modes nodes=%u bonds=%u generation=%u error=%u\n",n,m,gen,status.error);
            require(status.initialized && !status.error && status.generation==gen,"motion-mode construction failed");if(step==1)require(status.builds==prior.builds,"unchanged mode generation rebuilt");prior=status;
            std::vector<MotionComponent> components(n);if(n)check(cudaMemcpy(components.data(),modes.view().components,n*sizeof(MotionComponent),cudaMemcpyDeviceToHost));
            unsigned dimensions[7]{};for(auto id:oracle.ids){const auto& c=oracle.components[id];const unsigned expected=c.anchored?0:c.rotations+3;
                require((components[id].anchored?0:components[id].rotations+3)==expected,"motion null-space dimension differs from independent bond closure rank");++dimensions[expected];}
            projectObserved<<<std::max(1u,std::min(128u,unsigned(oracle.ids.size()))),Threads,0,stream>>>(input,modes.view(),values.data,result.data);check(cudaGetLastError());check(cudaStreamSynchronize(stream));
            const auto actual=result.get(),expected=oracle.project(f,loads);double worst=0;
            for(unsigned i=0;i<n;++i){const auto a=unpack(actual[i]),e=unpack(expected[i]);for(unsigned k=0;k<6;++k){const double error=double(std::abs(a[k]-e[k])/std::max(1.L,std::abs(e[k])));worst=std::max(worst,error);require(std::isfinite(error)&&error<2e-12,"GPU projection differs from independent long-double oracle");}}
            projectObserved<<<std::max(1u,std::min(128u,unsigned(oracle.ids.size()))),Threads,0,stream>>>(input,modes.view(),result.data,result.data);check(cudaGetLastError());check(cudaStreamSynchronize(stream));const auto twice=result.get();
            for(unsigned i=0;i<n;++i){const auto x=unpack(actual[i]),y=unpack(twice[i]);for(unsigned k=0;k<6;++k)require(std::abs(x[k]-y[k])<2e-12L*std::max(1.L,std::abs(x[k])),"motion projection is not idempotent");}
            // Equal/opposite loads and subnormal inputs must not count as
            // unloaded merely because their sum or squared norm is zero.
            Device<ExtStressGpuImpulse> exactInputs(n);Device<unsigned> certificates(n);
            for(unsigned loadCase=0;loadCase<4;++loadCase){std::vector<ExtStressGpuImpulse> testLoads(n);
                for(auto id:oracle.ids)if(loadCase){const auto& members=oracle.components[id].nodes;
                    const float value=loadCase==1?.5f:(loadCase==2?1e-30f:1e-40f);
                    testLoads[members.front()].angular.x=value;if(members.size()>1)testLoads[members.back()].angular.x=-value;}
                exactInputs.put(testLoads);homogeneousCertificates<<<std::max(1u,std::min(128u,unsigned(oracle.ids.size()))),Threads,0,stream>>>(input,modes.view(),exactInputs.data,certificates.data);
                check(cudaGetLastError());check(cudaStreamSynchronize(stream));const auto certified=certificates.get();
                for(auto id:oracle.ids){unsigned edges=0;for(unsigned e=0;e<m;++e)if(f.health[e]>0 && (oracle.labels[f.a[e]]==id || oracle.labels[f.b[e]]==id))++edges;
                    const auto& c=oracle.components[id];const bool expected=!loadCase && !c.anchored && edges+1==c.nodes.size();
                    require(certified[id]==unsigned(expected),"homogeneous shortcut erased cyclic, supported, or nonzero-load work");}
            }
            std::printf("GPU motion modes nodes=%u bonds=%u generation=%u components=%zu dimensions[0,3,4,6]=%u,%u,%u,%u oracle_error=%.3g\n",n,m,gen,oracle.ids.size(),dimensions[0],dimensions[3],dimensions[4],dimensions[6],worst);std::fflush(stdout);
        }
        // A missing tree and an ambiguous arithmetic result must fail instead
        // of inventing modes. Neither rejected result may reach a consumer.
        if(m && n>1){
            const auto validForest=forest.get();auto bad=validForest;std::fill(bad.begin(),bad.end(),0u);forest.put(bad);generation.put({100});
            check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));Status broken{};check(cudaMemcpy(&broken,modes.status(),sizeof(broken),cudaMemcpyDeviceToHost));
            require(broken.error==2 && broken.generation==prior.generation,"missing spanning edges did not reject construction");
            forest.put(validForest);const unsigned numericalEdge=std::find(validForest.begin(),validForest.end(),1u)-validForest.begin();require(numericalEdge<m,"precision fixture requires a dynamic tree edge");
            auto large=f.offset0,small=f.offset1;large[numericalEdge].x=1e30f;small[numericalEdge].x=1e-30f;offset0.put(large);offset1.put(small);generation.put({101});
            check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));check(cudaMemcpy(&broken,modes.status(),sizeof(broken),cudaMemcpyDeviceToHost));
            require((broken.error&16) && broken.generation==prior.generation,"unrepresentable exact closure was silently rounded");
            result.put(loads);projectObserved<<<1,Threads,0,stream>>>(input,modes.view(),values.data,result.data);check(cudaGetLastError());check(cudaStreamSynchronize(stream));
            const auto untouched=result.get();require(!std::memcmp(untouched.data(),loads.data(),n*sizeof(Vector)),"failed mode construction reached projection consumer");
            offset0.put(f.offset0);offset1.put(f.offset1);generation.put({102});check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));check(cudaMemcpy(&prior,modes.status(),sizeof(prior),cudaMemcpyDeviceToHost));
            require(!prior.error && prior.initialized && prior.generation==102,"motion modes did not recover after rejected numerical construction");
            std::printf("GPU motion rejection/recovery nodes=%u bonds=%u missing-tree/precision/consumer gates passed\n",n,m);
        }
        // Rejected and stale submissions must not publish replacement modes.
        accept.put({0});generation.put({99});check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));Status rejected{};check(cudaMemcpy(&rejected,modes.status(),sizeof(rejected),cudaMemcpyDeviceToHost));require(!std::memcmp(&rejected,&prior,sizeof(prior)),"rejected mode transaction changed status");
        if(prior.generation){accept.put({1});generation.put({0});check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));check(cudaMemcpy(&rejected,modes.status(),sizeof(rejected),cudaMemcpyDeviceToHost));require(rejected.error==4 && rejected.generation==prior.generation,"mode generation rewind accepted");}
        check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
    }
    check(cudaStreamDestroy(stream));
}
}
#include "native_warm_range_test.cuh"
#include "native_fine_inverse_test.cuh"
#include "native_rigid_inverse_test.cuh"
#include "native_polynomial_test.cuh"
#include "native_direction_restart_test.cuh"
#include "native_topology_warm_test.cuh"
#include "native_inverse_topology_test.cuh"
using namespace MotionModeTest;
int main(int argc,char** argv){try{
    const bool small=argc==2 && std::string(argv[1])=="small";require(argc==1 || small,"usage: gpu_resident_motion_modes_test [small]");
    {Device<unsigned> result(3);checkPredicates<<<1,1>>>(result.data);check(cudaGetLastError());check(cudaDeviceSynchronize());for(auto value:result.get())require(value==1,"exact closure collinearity predicate failed");}
    fineInverseCache();
    rigidInverseCache();
    polynomialOperator();
    firstDirectionWithoutHistory();
    warmRangeLifecycle();
    topologyWarmInvalidation();
    inverseTopologyLifetime();
    run(Fixture(0),false);run(Fixture(1),false);
    for(unsigned kind=0;kind<5;++kind){Fixture f(24);for(unsigned i=1;i<f.n;++i)f.edge(i-1,i);
        if(kind==1)f.offset1[5].x+=.03125f; // Tree geometry differs from authoring, still six modes.
        if(kind==2 || kind==3){f.edge(23,0);f.offset1.back().x+=.03125f;}
        if(kind==3){f.edge(12,0);f.offset1.back().y+=.0625f;}
        if(kind==4)f.inertia[0]={0,0};run(f,true);}
    Fixture mixed(1028);for(unsigned i=0;i<mixed.n;++i){if(i%4)mixed.edge(i-1,i);else if((i/4)%2)mixed.inertia[i]={0,0};}run(mixed,true);
    if(!small){Fixture large(100000);for(unsigned i=1;i<large.n;++i){large.edge(i-1,i);if(i>1)large.edge(i-2,i);}run(large,true);}
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"resident motion modes: %s\n",e.what());return 1;}}
