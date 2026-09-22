// Direct production fine-diagonal qualification; compile in IEEE64 mode with
// PX_CUMETAL_BLOCK_VOTED_TRAPS=1 and the native one-block contract enabled.
#include "StressHierarchyOperator.cuh"
using namespace Nv::Blast::StressHierarchy;
#include "../../demos/blast-stress-demo/tests/gpu_resident_diagonal_reference.cuh"
#include <algorithm>
#include <array>
#include <cerrno>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <spawn.h>
#include <stdexcept>
#include <sys/wait.h>
#include <vector>
extern char** environ;
#if !defined(PX_CUMETAL_BLOCK_VOTED_TRAPS) || !PX_CUMETAL_BLOCK_VOTED_TRAPS
#error "this qualification requires the explicit block-voted source hint"
#endif
namespace {
constexpr unsigned Capacity=19, Guard=3, Total=Capacity+2*Guard;
using Six=std::array<double,6>;
void check(cudaError_t value){if(value!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(value));}
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
Vector unpack(const Six& v){return {{v[0],v[1],v[2]},{v[3],v[4],v[5]}};}
Six pack(Vector v){return {v.angular.x,v.angular.y,v.angular.z,v.linear.x,v.linear.y,v.linear.z};}
Vector sentinel(){return {{-701.25,702.5,-703.75},{704.25,-705.5,706.75}};}
unsigned slot(unsigned row,unsigned column){return row*(row+1)/2+column;}
bool zero_factor(unsigned node){return node%5==4;}
Six solution(unsigned node,unsigned replay){
    Six value{};for(unsigned k=0;k<6;++k)value[k]=(int((node*11+k*7+replay*13)%29)-14)/8.;
    return value;
}
// Independent dense L*L^T action, rather than a second triangular solver.
// All authored inputs are dyadic, so construction does not lose precision.
Six action(const std::vector<double>& factors,unsigned node,const Six& value){
    double matrix[6][6]{};Six result{};
    for(unsigned row=0;row<6;++row)for(unsigned column=0;column<6;++column)
        for(unsigned k=0;k<=std::min(row,column);++k)
            matrix[row][column]+=factors[node*DiagonalEntries+slot(row,k)]*
                                 factors[node*DiagonalEntries+slot(column,k)];
    for(unsigned row=0;row<6;++row)for(unsigned column=0;column<6;++column)
        result[row]+=matrix[row][column]*value[column];
    return result;
}
void verify(const Vector* actual,const Vector* reference,unsigned nodes,unsigned replay){
    for(unsigned i=0;i<Total;++i){
        if(i<Guard || i>=Guard+nodes){
            const Vector guard=sentinel();
            require(!std::memcmp(actual+i,&guard,sizeof(Vector)),"production output guard/tail changed");
            require(!std::memcmp(reference+i,&guard,sizeof(Vector)),"reference output guard/tail changed");
            continue;
        }
        require(!std::memcmp(actual+i,reference+i,sizeof(Vector)),"production solve changed all-lane reference bits");
        const unsigned node=i-Guard;const Six got=pack(actual[i]);
        const Six expected=zero_factor(node)?Six{}:solution(node,replay);
        for(unsigned k=0;k<6;++k)
            require(std::isfinite(got[k]) && std::abs(got[k]-expected[k])<2e-12*std::max(1.,std::abs(expected[k])),
                    "GPU inverse differs from independent dense-system solution");
    }
}
int healthy(){
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    double* factors=nullptr;Vector *rhs=nullptr,*out=nullptr,*reference=nullptr;Status* status=nullptr;
    check(cudaMalloc(&factors,Capacity*DiagonalEntries*sizeof(double)));
    check(cudaMalloc(&rhs,Capacity*sizeof(Vector)));check(cudaMalloc(&out,Total*sizeof(Vector)));
    check(cudaMalloc(&reference,Total*sizeof(Vector)));check(cudaMalloc(&status,sizeof(Status)));
    std::vector<double> authored(Capacity*DiagonalEntries);
    for(unsigned n=0;n<Capacity;++n)for(unsigned row=0;row<6;++row)for(unsigned column=0;column<=row;++column)
        authored[n*DiagonalEntries+slot(row,column)]=row==column?2.+double((n+row)%4)/4.:
            double(int((n+row*3+column*5)%9)-4)/32.;
    for(unsigned n=0;n<Capacity;++n)if(zero_factor(n))authored[n*DiagonalEntries]=0.;
    std::array<std::vector<Vector>,2> inputs;
    for(unsigned replay=0;replay<2;++replay){
        inputs[replay].resize(Capacity);
        for(unsigned n=0;n<Capacity;++n)inputs[replay][n]=unpack(action(authored,n,solution(n,replay)));
    }
    std::vector<Vector> cleared(Total,sentinel());
    Status ready{};ready.initialized=1;
    check(cudaMemcpyAsync(factors,authored.data(),authored.size()*sizeof(double),cudaMemcpyHostToDevice,stream));
    check(cudaMemcpyAsync(status,&ready,sizeof(ready),cudaMemcpyHostToDevice,stream));
    Vector* snapshots[2][2]{};
    for(auto& replay:snapshots)for(auto& snapshot:replay)check(cudaHostAlloc(&snapshot,Total*sizeof(Vector),cudaHostAllocDefault));
    Buffers buffers{};buffers.diagonal=factors;
    for(unsigned nodes:{0u,1u,7u,8u,9u,17u}){
        Input input{};input.nodes=nodes;
        cudaGraph_t graph;cudaGraphExec_t executable;
        check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));
        applyFineDiagonal<<<1,256,0,stream>>>(input,buffers,status,rhs,out+Guard);
        // The existing reference maps one node per warp; cover >8 nodes with
        // its original multi-block mapping, not a modified reference body.
        applyReferenceDiagonal<<<std::max(1u,(nodes+7)/8),256,0,stream>>>(input,buffers,status,rhs,reference+Guard);
        check(cudaStreamEndCapture(stream,&graph));
        check(cudaGraphInstantiate(&executable,graph,0));
        // Two different RHS uploads, graph replays, and readbacks are queued
        // before a single completion boundary. Each snapshot must be distinct.
        for(unsigned replay=0;replay<2;++replay){
            check(cudaMemcpyAsync(rhs,inputs[replay].data(),Capacity*sizeof(Vector),cudaMemcpyHostToDevice,stream));
            check(cudaMemcpyAsync(out,cleared.data(),Total*sizeof(Vector),cudaMemcpyHostToDevice,stream));
            check(cudaMemcpyAsync(reference,cleared.data(),Total*sizeof(Vector),cudaMemcpyHostToDevice,stream));
            check(cudaGraphLaunch(executable,stream));
            check(cudaMemcpyAsync(snapshots[replay][0],out,Total*sizeof(Vector),cudaMemcpyDeviceToHost,stream));
            check(cudaMemcpyAsync(snapshots[replay][1],reference,Total*sizeof(Vector),cudaMemcpyDeviceToHost,stream));
        }
        check(cudaStreamSynchronize(stream));
        for(unsigned replay=0;replay<2;++replay)verify(snapshots[replay][0],snapshots[replay][1],nodes,replay);
        check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
    }
    for(auto& replay:snapshots)for(auto snapshot:replay)check(cudaFreeHost(snapshot));
    check(cudaFree(factors));check(cudaFree(rhs));check(cudaFree(out));check(cudaFree(reference));check(cudaFree(status));
    check(cudaStreamDestroy(stream));std::puts("PASS: production fine-diagonal IEEE64, exact reference, tails, warp strides, guards and two queued graph snapshots");
    return 0;
}
int misuse(unsigned nodes,bool capture){
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    Vector *host=nullptr,*device=nullptr;CoarseBond *bondHost=nullptr,*bondDevice=nullptr;
    check(cudaHostAlloc(&host,Total*sizeof(Vector),cudaHostAllocMapped));
    check(cudaHostGetDevicePointer(&device,host,0));
    check(cudaHostAlloc(&bondHost,sizeof(CoarseBond),cudaHostAllocMapped));
    check(cudaHostGetDevicePointer(&bondDevice,bondHost,0));
    for(unsigned i=0;i<Total;++i)host[i]=sentinel();
    Input input{};input.levelBonds=bondDevice;Buffers buffers{};
    // No active nodes: non-null levelBonds is never used, and no null data
    // pointer below may be dereferenced. This must not produce a sticky error.
    applyFineDiagonal<<<1,256,0,stream>>>(input,buffers,nullptr,nullptr,device+Guard);
    check(cudaStreamSynchronize(stream));
    for(unsigned i=0;i<Total;++i){const Vector guard=sentinel();require(!std::memcmp(host+i,&guard,sizeof(Vector)),"empty input wrote output");}
    input.nodes=nodes;
    if(capture){cudaGraph_t graph;cudaGraphExec_t executable;
        check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));
        applyFineDiagonal<<<1,256,0,stream>>>(input,buffers,nullptr,nullptr,device+Guard);
        check(cudaStreamEndCapture(stream,&graph));check(cudaGraphInstantiate(&executable,graph,0));
        check(cudaGraphLaunch(executable,stream));
    }else applyFineDiagonal<<<1,256,0,stream>>>(input,buffers,nullptr,nullptr,device+Guard);
    require(cudaStreamSynchronize(stream)==cudaErrorLaunchFailure,"misuse did not report launch failure");
    require(cudaStreamSynchronize(stream)==cudaErrorLaunchFailure,"misuse error was not sticky");
    // Completion was observed above. Read mapped host bytes directly, with no
    // post-error CUDA copies or resource calls. The child owns cleanup on exit.
    for(unsigned i=0;i<Total;++i){const Vector guard=sentinel();require(!std::memcmp(host+i,&guard,sizeof(Vector)),"misuse published output or changed guards");}
    std::printf("PASS: fine-diagonal misuse nodes=%u capture=%u, empty input, sticky failure and withheld writes\n",nodes,unsigned(capture));
    return 0;
}
}
int main(int argc,char** argv){
    try{
        if(argc==2 && !std::strcmp(argv[1],"healthy"))return healthy();
        if(argc==3 && (!std::strcmp(argv[1],"trap-direct") || !std::strcmp(argv[1],"trap-graph"))){
            const unsigned nodes=unsigned(std::atoi(argv[2]));if(nodes!=1 && nodes!=9 && nodes!=17)return 2;
            return misuse(nodes,!std::strcmp(argv[1],"trap-graph"));
        }
        if(argc!=1)return 2;
        for(const char* mode:{"healthy","trap-direct","trap-graph"})for(const char* count:{"1","9","17"}){
            if(!std::strcmp(mode,"healthy") && std::strcmp(count,"1"))continue;
            char* args[]={argv[0],const_cast<char*>(mode),std::strcmp(mode,"healthy")?const_cast<char*>(count):nullptr,nullptr};
            pid_t child;const int error=posix_spawn(&child,argv[0],nullptr,nullptr,args,environ);
            if(error)throw std::runtime_error(std::strerror(error));
            int status;pid_t waited;do{waited=waitpid(child,&status,0);}while(waited<0 && errno==EINTR);
            require(waited==child && WIFEXITED(status) && WEXITSTATUS(status)==0,"fine-diagonal child failed");
        }
        return 0;
    }catch(const std::exception& error){std::fprintf(stderr,"FAIL: %s\n",error.what());return 1;}
}
