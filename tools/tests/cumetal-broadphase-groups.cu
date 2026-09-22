// Actual shared broadphase group/ownership helper, with exact authored cases.
#include <cuda_runtime.h>
#include "PxgBroadPhaseGroups.h"
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <initializer_list>
#include <spawn.h>
#include <sys/wait.h>
extern char** environ;
using namespace physx;
#if !defined(PX_CUMETAL_BLOCK_VOTED_TRAPS) || !PX_CUMETAL_BLOCK_VOTED_TRAPS
#error "This qualification requires the explicit block-voted-trap source hint"
#endif
namespace {
constexpr unsigned Cases=16;
constexpr int Guard=0x5a5a5a5a;
// 0: different groups, same owner; 1: same group, different owner;
// 2: same articulation, different link; 3: two static owners;
// 4: static/dynamic; 5: kinematic/dynamic, same owner;
// 6: equal aggregate proxies; 7: different deformable proxies;
// 8: rigid/proxy; 9/10: no-owner equal/different fallback;
// 11: identical articulation link; 12: high 32-bit identity difference;
// 13/14: first/second handle outside capacity; 15: zero capacity.
const int Expected[Cases]={0,1,1,0,1,0,0,1,1,0,1,0,1,2,2,2};
__device__ __forceinline__ int evaluate(const PxgBroadPhaseDesc* descriptors,unsigned c,bool& invalid) {
    const unsigned a=c==13?1:0,b=c==13?0:1;
    const bool different=differentBroadPhaseGroupsChecked(descriptors+c,a,b,invalid);
    return int(different)+2*int(invalid);
}
__global__ void checkGroups(const PxgBroadPhaseDesc* descriptors,int* result,int* progress) {
    const unsigned index=blockIdx.x*blockDim.x+threadIdx.x;
    if(threadIdx.x<blockDim.x-5) {
        bool invalid=false;
        result[index]=evaluate(descriptors,blockIdx.x,invalid);
        progress[index]+=1;
    }
}
// Explicit audit: every block owns its output region; no inter-block waits or
// grid barriers. Inactive lanes still participate in the terminal error vote.
__global__ __attribute__((annotate("cumetal.block_local_terminal_traps")))
void votedGroups(const PxgBroadPhaseDesc* descriptors,int* result,int* progress,bool inject) {
    const unsigned t=threadIdx.x,index=blockIdx.x*blockDim.x+t;
    bool invalid=false;
    int resultValue=0;
    if(t<blockDim.x-5) {
        const unsigned c=inject && blockIdx.x==10 && t==blockDim.x-6?14:blockIdx.x%13;
        resultValue=evaluate(descriptors,c,invalid);
    }
    if(__syncthreads_or(invalid)) __trap();
    if(t<blockDim.x-5) {result[index]=resultValue;progress[index]+=1;}
}
#define CHECK(expr) do {const auto e=(expr);if(e!=cudaSuccess){std::fprintf(stderr,"line%d %s: %s\n",__LINE__,#expr,cudaGetErrorString(e));return 1;}}while(0)
int child(const char* mode,unsigned threads) {
    const bool checked=std::strcmp(mode,"checked")==0;
    const bool failure=std::strncmp(mode,"trap-",5)==0;
    const bool graph=std::strcmp(mode,"trap-direct")!=0;
    PxU32 hostGroups[2*Cases]{};
    PxNodeIndex hostOwners[2*Cases];
    PxgBroadPhaseDesc hostDescriptors[Cases]{};
    const PxU32 dynamicA=(1u<<BP_FILTERING_TYPE_SHIFT_BIT)|Bp::FilterType::DYNAMIC;
    const PxU32 dynamicB=(2u<<BP_FILTERING_TYPE_SHIFT_BIT)|Bp::FilterType::DYNAMIC;
    for(unsigned c=0;c<Cases;++c) {
        hostGroups[2*c]=dynamicA;hostGroups[2*c+1]=dynamicB;
        hostOwners[2*c]=PxNodeIndex(PxU32(42));hostOwners[2*c+1]=PxNodeIndex(PxU32(42));
        hostDescriptors[c].rigidOwnerCapacity=2;
    }
    hostGroups[2]=hostGroups[3]=dynamicA;hostOwners[3]=PxNodeIndex(PxU32(43));
    hostOwners[4]=PxNodeIndex(7,2);hostOwners[5]=PxNodeIndex(7,3);
    hostGroups[6]=hostGroups[7]=Bp::FilterType::STATIC;
    hostOwners[6]=hostOwners[7]=PxNodeIndex();
    hostGroups[8]=Bp::FilterType::STATIC;hostOwners[8]=PxNodeIndex();
    hostGroups[10]=(1u<<BP_FILTERING_TYPE_SHIFT_BIT)|Bp::FilterType::KINEMATIC;
    hostGroups[12]=hostGroups[13]=(8u<<BP_FILTERING_TYPE_SHIFT_BIT)|Bp::FilterType::AGGREGATE;
    hostGroups[14]=(8u<<BP_FILTERING_TYPE_SHIFT_BIT)|Bp::FilterType::DEFORMABLE_SURFACE;
    hostGroups[15]=(9u<<BP_FILTERING_TYPE_SHIFT_BIT)|Bp::FilterType::DEFORMABLE_VOLUME;
    hostGroups[17]=(8u<<BP_FILTERING_TYPE_SHIFT_BIT)|Bp::FilterType::PARTICLESYSTEM;
    // Proxy and fallback cases must not demand rigid ownership capacity.
    for(unsigned c=6;c<=10;++c)hostDescriptors[c].rigidOwnerCapacity=0;
    hostGroups[18]=hostGroups[19]=dynamicA;
    hostOwners[22]=hostOwners[23]=PxNodeIndex(9,4);
    hostOwners[24]=PxNodeIndex(PxU64(0x000000010000002aull));
    hostOwners[25]=PxNodeIndex(PxU64(0x000000020000002aull));
    hostDescriptors[13].rigidOwnerCapacity=hostDescriptors[14].rigidOwnerCapacity=1;
    hostDescriptors[15].rigidOwnerCapacity=0;
    // Deliberately distinct accessible owner sentinels for invalid cases. A
    // missed capacity check would return true instead of {false, invalid}.
    for(unsigned c=13;c<Cases;++c)hostOwners[2*c+1]=PxNodeIndex(PxU32(99));
    PxU32* groups=nullptr;PxNodeIndex* owners=nullptr;PxgBroadPhaseDesc* descriptors=nullptr;
    CHECK(cudaMalloc(&groups,sizeof(hostGroups)));CHECK(cudaMalloc(&owners,sizeof(hostOwners)));
    CHECK(cudaMalloc(&descriptors,sizeof(hostDescriptors)));
    for(unsigned c=0;c<Cases;++c) {
        hostDescriptors[c].updateData_groups=groups+2*c;
        hostDescriptors[c].rigidOwners=(c==9 || c==10)?nullptr:owners+2*c;
    }
    CHECK(cudaMemcpy(groups,hostGroups,sizeof(hostGroups),cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(owners,hostOwners,sizeof(hostOwners),cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(descriptors,hostDescriptors,sizeof(hostDescriptors),cudaMemcpyHostToDevice));
    const unsigned count=Cases*threads,total=2*(count+2);
    int *host=nullptr,*device=nullptr;
    CHECK(cudaHostAlloc(&host,total*sizeof(int),cudaHostAllocMapped));
    CHECK(cudaHostGetDevicePointer(&device,host,0));
    for(unsigned i=0;i<total;++i)host[i]=Guard;
    int* result=device+1;int* progress=device+count+3;
    for(unsigned i=0;i<count;++i)host[count+3+i]=0;
    cudaStream_t stream;CHECK(cudaStreamCreate(&stream));
    cudaGraph_t captured=nullptr;cudaGraphExec_t exec=nullptr;
    if(graph)CHECK(cudaStreamBeginCapture(stream,cudaStreamCaptureModeGlobal));
    if(checked)checkGroups<<<Cases,threads,0,stream>>>(descriptors,result,progress);
    else votedGroups<<<Cases,threads,0,stream>>>(descriptors,result,progress,failure);
    CHECK(cudaGetLastError());
    if(graph) {
        CHECK(cudaStreamEndCapture(stream,&captured));
        CHECK(cudaGraphInstantiate(&exec,captured,nullptr,nullptr,0));
        for(int i=0;i<(failure?1:3);++i)CHECK(cudaGraphLaunch(exec,stream));
    }
    const auto status=cudaStreamSynchronize(stream);
    if(failure) {
        if(status!=cudaErrorLaunchFailure || cudaStreamSynchronize(stream)!=cudaErrorLaunchFailure)return 2;
    } else if(status!=cudaSuccess)return 3;
    // Completion precedes mapped reads. Faulted children issue no subsequent
    // resource operations; sticky errors and unchanged publication are checked.
    for(unsigned b=0;b<Cases;++b)for(unsigned t=0;t<threads;++t) {
        const unsigned i=b*threads+t;
        const bool withheld=t>=threads-5 || (failure && b==10);
        const int expected=withheld?Guard:Expected[checked?b:b%13];
        const int expectedProgress=withheld?0:failure?1:3;
        if(host[1+i]!=expected || host[count+3+i]!=expectedProgress) {
            std::fprintf(stderr,"%s block%u lane%u result%d/%d progress%d/%d\n",mode,b,t,
                host[1+i],expected,host[count+3+i],expectedProgress);return 4;
        }
    }
    for(unsigned i : {0u,count+1,count+2,total-1})if(host[i]!=Guard)return 5;
    if(!failure) {
        PxU32 groupsAfter[2*Cases];PxNodeIndex ownersAfter[2*Cases];
        CHECK(cudaMemcpy(groupsAfter,groups,sizeof(groupsAfter),cudaMemcpyDeviceToHost));
        CHECK(cudaMemcpy(ownersAfter,owners,sizeof(ownersAfter),cudaMemcpyDeviceToHost));
        if(std::memcmp(groupsAfter,hostGroups,sizeof(hostGroups)) ||
            std::memcmp(ownersAfter,hostOwners,sizeof(hostOwners)))return 6;
        CHECK(cudaGraphExecDestroy(exec));CHECK(cudaGraphDestroy(captured));
        CHECK(cudaStreamDestroy(stream));CHECK(cudaFreeHost(host));
        CHECK(cudaFree(descriptors));CHECK(cudaFree(owners));CHECK(cudaFree(groups));
    }
    std::printf("PASS: production broadphase groups %s %u threads, sixteen blocks, exact identities/capacities/guards\n",mode,threads);
    return 0;
}
} // namespace
int main(int argc,char** argv) {
    if(argc==3) {
        const unsigned threads=unsigned(std::atoi(argv[2]));
        if(threads!=96 && threads!=256)return 64;
        if(std::strcmp(argv[1],"checked") && std::strcmp(argv[1],"healthy") &&
            std::strcmp(argv[1],"trap-direct") && std::strcmp(argv[1],"trap-graph"))return 64;
        return child(argv[1],threads);
    }
    if(argc!=1)return 64;
    for(const char* size : {"96","256"})for(const char* mode : {"checked","healthy","trap-direct","trap-graph"}) {
        char* args[]={argv[0],const_cast<char*>(mode),const_cast<char*>(size),nullptr};
        pid_t pid=0;if(posix_spawn(&pid,argv[0],nullptr,nullptr,args,environ))return 1;
        int status=0;pid_t got;
        do{got=waitpid(pid,&status,0);}while(got<0 && errno==EINTR);
        if(got!=pid || !WIFEXITED(status) || WEXITSTATUS(status))return 1;
    }
    std::puts("PASS: actual shared broadphase group helper and independent-block terminal vote");
}
