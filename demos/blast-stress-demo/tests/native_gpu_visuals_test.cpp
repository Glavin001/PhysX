// Analytic GPU consumer checks. No PhysX CPU shape/actor/query mirror supplies
// transforms; deliberately permuted slots make packed-root addressing fail.
#include "../native_gpu_visuals.h"
#include <cuda.h>
#include <cmath>
#include <cstdio>
#include <stdexcept>
#include <vector>
using namespace physx;using namespace blast_demo;
namespace {
void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}
void check(CUresult r){require(r==CUDA_SUCCESS,"CUDA consumer test failed");}
void near(float a,float b){require(std::isfinite(a)&&std::abs(a-b)<1e-4f,"analytic transform mismatch");}
struct Memory {
    std::vector<CUdeviceptr> allocations;
    ~Memory(){for(auto p:allocations)cuMemFree(p);}
    template<class T>T* data(const std::vector<T>& values){CUdeviceptr p;check(cuMemAlloc(&p,values.size()*sizeof(T)));allocations.push_back(p);check(cuMemcpyHtoD(p,values.data(),values.size()*sizeof(T)));return reinterpret_cast<T*>(p);}
    template<class T>T* one(T value){return data(std::vector<T>{value});}
};
void run(){
    CUstream producer,consumer;CUevent ready,done;check(cuStreamCreate(&producer,CU_STREAM_NON_BLOCKING));check(cuStreamCreate(&consumer,CU_STREAM_NON_BLOCKING));check(cuEventCreate(&ready,CU_EVENT_DISABLE_TIMING));check(cuEventCreate(&done,CU_EVENT_DISABLE_TIMING));
    {
    Memory memory;PxDestructionDeviceView view;view.chunkCount=4;
    PxDestructionStageStatus stage{};stage.frame=1;view.status=memory.one(stage);
    auto& t=view.acceptedTopology;t.chunkCount=4;t.slotCapacity=3;
    t.status=memory.one(PxDestructionTopologyStatus{7,2,0,0,0});
    t.activeChunks=memory.data<PxU32>({1,0,1,1});t.chunkCluster=memory.data<PxU32>({0,0,2,2});
    t.clusterSlots=memory.data<PxU32>({2,UINT32_MAX,0,UINT32_MAX});
    t.slotRoots=memory.data<PxU32>({2,UINT32_MAX,0});t.slotGenerations=memory.data<PxU64>({5,0,17});
    std::vector<PxDestructionClusterMotion> motions(3);for(auto& m:motions)m.orientation[3]=1;
    motions[0].origin[0]=-3;motions[0].origin[1]=2;
    motions[2].origin[0]=10;motions[2].origin[1]=20;motions[2].orientation[2]=std::sqrt(.5);motions[2].orientation[3]=std::sqrt(.5);
    t.motions=memory.data(motions);
    auto* visuals=memory.data<NativeGpuVisual>({{PxVec3(2,0,0),PxVec3(.5f),1},{PxVec3(0),PxVec3(.5f),0},{PxVec3(1,0,0),PxVec3(.5f),2},{PxVec3(0,2,0),PxVec3(.5f),3}});
    auto* shots=memory.data<PxTransform>({PxTransform(PxVec3(50,8,0))});
    auto* output=memory.data(std::vector<NativeGpuInstance>(5));auto* status=memory.one(NativeGpuVisualStatus{});auto* height=memory.one(0.f);
    std::vector<NativeGpuInstance> observed(5);
    auto draw=[&](bool colorByCluster=false){
        check(cuEventRecord(ready,producer));check(cuStreamWaitEvent(consumer,ready,0));
        writeNativeGpuInstances(view,visuals,shots,1,output,status,consumer,colorByCluster);check(cuEventRecord(done,consumer));
        check(cuStreamWaitEvent(producer,done,0));check(cuEventSynchronize(done));check(cuMemcpyDtoH(observed.data(),CUdeviceptr(output),observed.size()*sizeof(*output)));
        NativeGpuVisualStatus stats;check(cuMemcpyDtoH(&stats,CUdeviceptr(status),sizeof(stats)));return stats;
    };
    auto stats=draw();require(!stats.errors && stats.visible==4,"live/deleted chunk visibility mismatch");
    near(observed[0].position[0],10);near(observed[0].position[1],22);near(observed[0].orientation[2],std::sqrt(.5f));
    near(observed[1].position[3],0);near(observed[2].position[0],-2);near(observed[3].position[1],4);near(observed[4].position[0],50);near(observed[4].scale[0],.75f);
    queryNativeGpuLaunch(view,visuals,shots,1,PxVec3(10,21,0),.75f,height,consumer);check(cuStreamSynchronize(consumer));float clearance;check(cuMemcpyDtoH(&clearance,CUdeviceptr(height),sizeof(clearance)));
    near(clearance,22+std::sqrt(.75f)+.75f+.01f);
    queryNativeGpuLaunch(view,visuals,shots,1,PxVec3(50,8,0),.75f,height,consumer);check(cuStreamSynchronize(consumer));check(cuMemcpyDtoH(&clearance,CUdeviceptr(height),sizeof(clearance)));near(clearance,9.51f);
    stats=draw(true);require(!stats.errors,"cluster colors produced an invalid view");
    const auto colored=observed;
    float different=0;
    for(unsigned j=0;j<3;++j) {
        near(observed[2].color[j],observed[3].color[j]);
        different+=std::abs(observed[0].color[j]-observed[2].color[j]);
    }
    require(different>.1f,"distinct test clusters have indistinguishable colors");
    near(observed[0].position[0],10);near(observed[4].color[0],.95f);near(observed[4].color[1],.95f);near(observed[4].color[2],.95f);
    // Stable slot reuse changes its generation; the unchanged other root must
    // retain its transform. This is not packed activeClusters indexing.
    const PxU32 slots[]={1,UINT32_MAX,0,UINT32_MAX},roots[]={2,0,UINT32_MAX};const PxU64 generations[]={5,9,17};
    motions[1]=motions[2];motions[1].origin[0]=30;
    check(cuMemcpyHtoD(CUdeviceptr(t.clusterSlots),slots,sizeof(slots)));check(cuMemcpyHtoD(CUdeviceptr(t.slotRoots),roots,sizeof(roots)));check(cuMemcpyHtoD(CUdeviceptr(t.slotGenerations),generations,sizeof(generations)));check(cuMemcpyHtoD(CUdeviceptr(t.motions),motions.data(),motions.size()*sizeof(motions[0])));
    stats=draw();require(!stats.errors,"valid reused slot rejected");near(observed[0].position[0],30);near(observed[2].position[0],-2);
    stats=draw(true);require(!stats.errors,"cluster colors failed on slot reuse");
    float changed=0;for(unsigned j=0;j<3;++j) {
        near(observed[2].color[j],colored[2].color[j]);
        changed+=std::abs(observed[0].color[j]-colored[0].color[j]);
    }
    require(changed>.1f,"recycled cluster generation retained its old color");
    // A stale ownership edge is an explicit sticky consumer error, never an
    // out-of-bounds motion read or an invented pose. Later good frames retain it.
    const PxU32 invalid=UINT32_MAX;check(cuMemcpyHtoD(CUdeviceptr(t.clusterSlots),&invalid,sizeof(invalid)));
    stats=draw();require(stats.errors && !observed[0].position[3],"stale slot was rendered");
    check(cuMemcpyHtoD(CUdeviceptr(t.clusterSlots),slots,sizeof(slots)));stats=draw();require(stats.errors,"later frame erased consumer failure");
    }
    check(cuEventDestroy(ready));check(cuEventDestroy(done));check(cuStreamDestroy(producer));check(cuStreamDestroy(consumer));
    std::puts("GPU consumer: rotated/offset chunks, sparse stable slots, removed chunks, slot reuse, projectile poses, clearance queries, event ordering and sticky invalid-view rejection passed");
}
}
int main(){CUcontext context=nullptr;try{check(cuInit(0));CUdevice device;check(cuDeviceGet(&device,0));check(cuCtxCreate(&context,nullptr,0,device));run();check(cuCtxDestroy(context));return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());if(context)cuCtxDestroy(context);return 1;}}
