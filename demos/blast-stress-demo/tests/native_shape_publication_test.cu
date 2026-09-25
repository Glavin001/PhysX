// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include <PxDestructionScene.h>
#include <common/PxPhysXCommonConfig.h>
#include <cuda_runtime.h>
#include <cub/cub.cuh>
#include <cstdio>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
#include "PxgDestructionShapePublication.cuh"
void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}
void check(cudaError_t error){if(error!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(error));}
template<class T> struct Storage {
    T* data=nullptr;
    std::vector<T> host;
    // CuMetal raw device addresses are not host-dereferenceable. Explicit
    // transfer also exercises the same device-only buffers used in production.
    explicit Storage(unsigned count):host(count){check(cudaMalloc(&data,(count?count:1)*sizeof(T)));}
    ~Storage(){cudaFree(data);}
    T& operator[](unsigned index){return host[index];}
    void upload(){check(cudaMemcpy(data,host.data(),host.size()*sizeof(T),cudaMemcpyHostToDevice));}
    void download(){check(cudaMemcpy(host.data(),data,host.size()*sizeof(T),cudaMemcpyDeviceToHost));}
};
void run() {
    Storage<PxU64> epochs(4);Storage<PxU32> targets(4),indices(4),count(1);
    Storage<PxDestructionStressShape> chunks(4);
    Storage<PxDestructionCollisionBinding> output(4);
    Storage<PxDestructionStageStatus> stage(1);stage[0]={};stage[0].frame=9;
    for(unsigned i=0;i<4;++i){epochs[i]=0;targets[i]=PX_INVALID_U32;chunks[i]={i/2,100+i};}
    // First pass moves chunk 2; the second moves it again and also moves chunk 0.
    epochs[2]=9;targets[2]=20;epochs[2]=9;targets[2]=30;
    epochs[0]=9;targets[0]=40;epochs[1]=8;targets[1]=99;
    size_t bytes=0;
    check(cub::DeviceSelect::If(nullptr,bytes,cub::CountingInputIterator<PxU32>(0),indices.data,count.data,4,
        HasPendingShapeOwner{epochs.data,stage.data}));
    Storage<unsigned char> scratch{unsigned(bytes)};
    auto gather=[&](unsigned capacity) {
        epochs.upload();targets.upload();chunks.upload();stage.upload();output.upload();
        check(cub::DeviceSelect::If(scratch.data,bytes,cub::CountingInputIterator<PxU32>(0),indices.data,count.data,4,
            HasPendingShapeOwner{epochs.data,stage.data}));
        gatherFinalShapeOwners<<<1,32>>>(indices.data,count.data,capacity,chunks.data,targets.data,output.data,stage.data);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        count.download();output.download();stage.download();
    };
    gather(4);
    require(count[0]==2 && !stage[0].error,"publication did not select the two-pass union");
    require(output[0].chunk==0 && output[0].shape==100 && output[0].targetBody==40
        && output[1].chunk==1 && output[1].shape==102 && output[1].targetBody==30,
        "publication lost final ownership or stable chunk order");
    require(output[0].sourceBody==PX_INVALID_U32 && output[1].sourceBody==PX_INVALID_U32,
        "publication incorrectly identifies the intermediate owner as the accepted source");
    for(unsigned i=2;i<4;++i)require(!output[i].chunk && !output[i].shape && !output[i].sourceBody && !output[i].targetBody,
        "bounded publication tail was not initialized");
    // Both hulls of the same part must publish independently.
    epochs[1]=9;targets[1]=40;gather(4);
    require(count[0]==3 && output[0].chunk==0 && output[1].chunk==0
        && output[0].shape==100 && output[1].shape==101
        && output[0].shapeSlot==0 && output[1].shapeSlot==1
        && output[0].targetBody==40 && output[1].targetBody==40,
        "multiple hulls of one authored part lost ownership");
    output[1]={71,72,73,74};gather(1);
    require(stage[0].error==1024 && count[0]==3,"publication overflow did not report collision ownership failure");
    require(output[1].chunk==71 && output[1].targetBody==74,"publication wrote beyond capacity");
    stage[0].frame=10;stage[0].error=0;gather(4);
    require(count[0]==0 && !stage[0].error,"previous tick's owner changes leaked into publication");
    for(unsigned i=0;i<4;++i)require(!output[i].chunk && !output[i].shape && !output[i].sourceBody && !output[i].targetBody,
        "empty publication retained stale records");
    std::puts("4 hull records: two-pass union, repeated migration, shared chunks, stable order, stale epochs and explicit overflow passed");
}
}
int main(){try{run();return 0;}catch(const std::exception& error){std::fprintf(stderr,"%s\n",error.what());return 1;}}
