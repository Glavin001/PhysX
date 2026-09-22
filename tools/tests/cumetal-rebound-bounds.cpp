// Links the actual updateBodiesAndShapes native object; no copied GPU kernel.
#include <cuda_runtime.h>
#include <cumetal_driver.h>
#include "PxgShapeSim.h"
#include "PxgBodySim.h"
#include "PxsCachedTransform.h"
#include "geometry/PxGeometry.h"
#include <algorithm>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <initializer_list>
#include <spawn.h>
#include <sys/wait.h>
#include <vector>
extern char** environ;
extern "C" void initSimulationControllerKernels0();
using namespace physx;
#define CUDA(call) do {const auto e=(call);if(e!=cudaSuccess){std::fprintf(stderr,"CUDA %d line%d\n",int(e),__LINE__);return 1;}}while(0)
#define DRIVER(call) do {const auto e=(call);if(e!=CUDA_SUCCESS){std::fprintf(stderr,"driver %d line%d\n",int(e),__LINE__);return 1;}}while(0)
namespace {
constexpr unsigned Threads=256, Blocks=3;
constexpr unsigned char Guard=0x5a;
bool guard(const void* p,size_t n) {
    const auto* bytes=static_cast<const unsigned char*>(p);
    for(size_t i=0;i<n;++i)if(bytes[i]!=Guard)return false;
    return true;
}
bool equal(const PxVec3& a,const PxVec3& b){return a.x==b.x && a.y==b.y && a.z==b.z;}
template<class T> struct Output {
    T *host=nullptr,*raw=nullptr,*snapshot[3]{};
    unsigned size=0;
    int allocate(unsigned count) {
        size=count+2;
        CUDA(cudaHostAlloc(&host,size*sizeof(T),cudaHostAllocMapped));
        CUDA(cudaHostGetDevicePointer(&raw,host,0));
        std::memset(host,Guard,size*sizeof(T));
        for(auto& p:snapshot)CUDA(cudaHostAlloc(&p,size*sizeof(T),cudaHostAllocDefault));
        return 0;
    }
    T* data(){return raw+1;}
    int capture(unsigned phase,cudaStream_t stream) {
        CUDA(cudaMemcpyAsync(snapshot[phase],raw,size*sizeof(T),cudaMemcpyDeviceToHost,stream));
        return 0;
    }
    int release() {
        for(auto* p:snapshot)if(p)CUDA(cudaFreeHost(p));
        CUDA(cudaFreeHost(host));return 0;
    }
};
int child(const char* mode,unsigned live) {
    const bool healthy=!std::strncmp(mode,"healthy",7);
    const bool sorted=std::strcmp(mode,"healthy-unsorted")!=0;
    const bool nullUpdated=!std::strcmp(mode,"null-updated");
    if(!healthy && live!=257)return 64;
    initSimulationControllerKernels0();
    DRIVER(cuInit(0));CUcontext context=nullptr;DRIVER(cuCtxCreate(&context,0,0));
    size_t moduleCount=0;DRIVER(cumetalGetNativeModules(nullptr,0,&moduleCount));
    std::vector<CuMetalModuleHandle> native(moduleCount);
    DRIVER(cumetalGetNativeModules(native.data(),native.size(),&moduleCount));
    CUmodule foundModule=nullptr;CUfunction kernel=nullptr;
    for(const auto handle:native) {
        CUmodule module=nullptr;DRIVER(cumetalImportNativeModule(&module,handle));
        CUfunction candidate=nullptr;
        const auto status=cuModuleGetFunction(&candidate,module,"refreshReboundShapeBounds");
        if(status==CUDA_SUCCESS) {if(kernel)return 2;kernel=candidate;foundModule=module;}
        else {if(status!=CUDA_ERROR_NOT_FOUND)return 3;DRIVER(cuModuleUnload(module));}
    }
    if(!kernel)return 4;
    const unsigned capacity=2*live+5;
    unsigned count=live+(sorted?3:0),updatedCapacity=capacity;
    std::vector<PxU32> indices(std::max(1u,count),PX_INVALID_U32);
    std::vector<PxNodeIndex> nodes(std::max(1u,count));
    std::vector<PxgShapeSim> shapes(capacity);
    std::vector<PxgBodySim> frames[3];
    for(unsigned phase=0;phase<3;++phase) {
        frames[phase].resize(std::max(1u,live));
        for(unsigned i=0;i<live;++i) {
            // Exact authored transforms: shape minus actor offset=(1,3,2),
            // followed by identity or a 180-degree Z rotation and translation.
            const PxQuat q=i&1?PxQuat(0,0,1,0):PxQuat(PxIdentity);
            frames[phase][i].body2World=PxAlignedTransform(PxTransform(PxVec3(float(i)*.5f+float(phase)*4,-2,4),q));
            frames[phase][i].body2Actor_maxImpulseW=PxAlignedTransform(PxTransform(PxVec3(.25f,-.5f,1)));
        }
    }
    for(unsigned i=0;i<live;++i) {
        const unsigned index=2*(live-i-1);indices[i]=index;nodes[i]=PxNodeIndex(PxU32(i));
        auto& s=shapes[index];s.mTransform=PxTransform(PxVec3(1.25f,2.5f,3));
        s.mBodySimIndex=PxNodeIndex(PxU32(i));s.mHullDataIndex=PX_INVALID_U32;
        s.mShapeType=PxU16(i%3==0?PxGeometryType::eSPHERE:i%3==1?PxGeometryType::eBOX:PxGeometryType::eCAPSULE);
        const PxVec3 extent=i%3==0?PxVec3(.5f):i%3==1?PxVec3(1,2,.5f):PxVec3(1.75f,.25f,.25f);
        s.mLocalBounds=PxBounds3(-extent,extent);s.mShapeFlags=0;
    }
    if(sorted) {nodes[live]=PxNodeIndex();nodes[live+1]=PxNodeIndex();nodes[live+2]=PxNodeIndex(0,0);}
    // Invalid lane is the only live lane in the second block. Its entire
    // iteration must withhold publication; the first block can complete.
    if(!healthy) {
        if(!std::strcmp(mode,"bad-index"))indices[256]=PX_INVALID_U32;
        else if(!std::strcmp(mode,"bad-capacity"))indices[256]=capacity;
        else if(!std::strcmp(mode,"bad-static"))shapes[0].mBodySimIndex=PxNodeIndex();
        else if(!std::strcmp(mode,"bad-articulation"))shapes[0].mBodySimIndex=PxNodeIndex(1,0);
        else if(!std::strcmp(mode,"bad-owner"))shapes[0].mBodySimIndex=PxNodeIndex(PxU32(0));
        else if(!nullUpdated)return 64;
    }
    PxU32* deviceIndices=nullptr;PxNodeIndex* deviceNodes=nullptr;
    PxgShapeSim* deviceShapes=nullptr;PxgBodySim* deviceBodies=nullptr;
    CUDA(cudaMalloc(&deviceIndices,indices.size()*sizeof(PxU32)));
    CUDA(cudaMalloc(&deviceShapes,shapes.size()*sizeof(PxgShapeSim)));
    CUDA(cudaMalloc(&deviceBodies,frames[0].size()*sizeof(PxgBodySim)));
    CUDA(cudaMemcpy(deviceIndices,indices.data(),indices.size()*sizeof(PxU32),cudaMemcpyHostToDevice));
    CUDA(cudaMemcpy(deviceShapes,shapes.data(),shapes.size()*sizeof(PxgShapeSim),cudaMemcpyHostToDevice));
    if(sorted) {
        CUDA(cudaMalloc(&deviceNodes,nodes.size()*sizeof(PxNodeIndex)));
        CUDA(cudaMemcpy(deviceNodes,nodes.data(),nodes.size()*sizeof(PxNodeIndex),cudaMemcpyHostToDevice));
    }
    Output<PxsCachedTransform> transforms;Output<PxBounds3> bounds;Output<PxU32> updated;
    if(transforms.allocate(capacity)||bounds.allocate(capacity)||updated.allocate(capacity))return 1;
    auto* transformData=transforms.data();auto* boundsData=bounds.data();
    auto* updatedData=nullUpdated?nullptr:updated.data();void* geometry=nullptr;
    void* args[]={&deviceIndices,&count,&deviceShapes,&deviceBodies,&transformData,&boundsData,
                  &geometry,&deviceNodes,&updatedData,&updatedCapacity};
    cudaStream_t stream=nullptr;CUDA(cudaStreamCreate(&stream));
    cudaGraph_t graph=nullptr;cudaGraphExec_t exec=nullptr;
    CUDA(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));
    DRIVER(cuLaunchKernel(kernel,Blocks,1,1,Threads,1,1,0,(CUstream)stream,args,nullptr));
    CUDA(cudaStreamEndCapture(stream,&graph));CUDA(cudaGraphInstantiate(&exec,graph,nullptr,nullptr,0));
    for(unsigned phase=0;phase<(healthy?3u:1u);++phase) {
        CUDA(cudaMemcpyAsync(deviceBodies,frames[phase].data(),frames[phase].size()*sizeof(PxgBodySim),cudaMemcpyHostToDevice,stream));
        CUDA(cudaGraphLaunch(exec,stream));
        if(healthy && (transforms.capture(phase,stream)||bounds.capture(phase,stream)||updated.capture(phase,stream)))return 1;
    }
    const auto completion=cudaStreamSynchronize(stream);
    if(healthy) {if(completion!=cudaSuccess)return 5;}
    else if(completion!=cudaErrorLaunchFailure || cudaStreamSynchronize(stream)!=cudaErrorLaunchFailure)return 6;
    for(unsigned phase=0;phase<(healthy?3u:1u);++phase) {
        const auto* t=healthy?transforms.snapshot[phase]:transforms.host;
        const auto* b=healthy?bounds.snapshot[phase]:bounds.host;
        const auto* u=healthy?updated.snapshot[phase]:updated.host;
        for(unsigned index=0;index<capacity+2;++index) {
            const bool payload=index>0 && index<=capacity;
            const unsigned shapeIndex=payload?index-1:capacity;
            const bool active=payload && !(shapeIndex&1) && shapeIndex<2*live;
            const unsigned i=active?live-1-shapeIndex/2:live;
            const bool written=active && (healthy || (!nullUpdated && i!=256));
            if(!written) {
                if(!guard(t+index,sizeof(*t))||!guard(b+index,sizeof(*b))||!guard(u+index,sizeof(*u))) {
                    std::fprintf(stderr,"%s altered guard/withheld shape%u phase%u\n",mode,shapeIndex,phase);return 7;
                }
                continue;
            }
            const bool flip=i&1;
            const PxVec3 position(float(i)*.5f+float(phase)*4+(flip?-1.f:1.f),flip?-5.f:1.f,6.f);
            const PxVec3 extent=i%3==0?PxVec3(.5f):i%3==1?PxVec3(1,2,.5f):PxVec3(1.75f,.25f,.25f);
            const auto& q=t[index].transform.q;
            if(!equal(t[index].transform.p,position)||q.x!=0||q.y!=0||q.z!=(flip?1.f:0.f)||q.w!=(flip?0.f:1.f)||
                t[index].flags!=0||!equal(b[index].minimum,position-extent)||!equal(b[index].maximum,position+extent)||u[index]!=1) {
                std::fprintf(stderr,"%s incorrect shape%u body%u phase%u\n",mode,shapeIndex,i,phase);return 8;
            }
        }
    }
    // No CUDA cleanup into a faulted child. Mapped outputs were inspected only
    // after failed command completion, with no post-failure memcpy operation.
    if(healthy) {
        CUDA(cudaGraphExecDestroy(exec));CUDA(cudaGraphDestroy(graph));CUDA(cudaStreamDestroy(stream));
        if(transforms.release()||bounds.release()||updated.release())return 1;
        CUDA(cudaFree(deviceIndices));CUDA(cudaFree(deviceShapes));CUDA(cudaFree(deviceBodies));
        if(deviceNodes)CUDA(cudaFree(deviceNodes));
        DRIVER(cuModuleUnload(foundModule));DRIVER(cuCtxDestroy(context));
    }
    std::printf("PASS: actual refreshReboundShapeBounds %s live%u, exact transforms/bounds/update flags and guards\n",mode,live);
    return 0;
}
int spawn(const char* program,const char* mode,const char* count) {
    char* args[]={const_cast<char*>(program),const_cast<char*>(mode),const_cast<char*>(count),nullptr};
    pid_t pid=0;if(posix_spawn(&pid,program,nullptr,nullptr,args,environ))return 1;
    int status=0;pid_t got;do{got=waitpid(pid,&status,0);}while(got<0 && errno==EINTR);
    return got!=pid||!WIFEXITED(status)||WEXITSTATUS(status)?1:0;
}
}
int main(int argc,char** argv) {
    if(argc==3)return child(argv[1],unsigned(std::strtoul(argv[2],nullptr,10)));
    if(argc!=1)return 64;
    for(const char* n : {"0","1","257","769"})for(const char* mode : {"healthy","healthy-unsorted"})
        if(spawn(argv[0],mode,n))return 1;
    for(const char* mode : {"bad-index","bad-capacity","bad-static","bad-articulation","bad-owner","null-updated"})
        if(spawn(argv[0],mode,"257"))return 1;
    std::puts("PASS: production rebound bounds multi-block captured correction component");
}
