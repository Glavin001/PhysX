// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include <PxPhysicsAPI.h>
#include "PxgShapeManager.h"
#include <cuda.h>
#include <vector>
#include <stdexcept>
namespace nativeOwnerTest {
using namespace physx;
inline void require(bool value,const char* reason){if(!value)throw std::runtime_error(reason);}
inline void check(CUresult result){require(result==CUDA_SUCCESS,"native owner observation CUDA failure");}
// Explicit observation verifies native mapping and CPU actor identities together.
// The simulation must not depend on refreshing the old GPU actor-pointer table.
inline unsigned observe(PxScene& scene,PxCudaContextManager& cuda,PxU32 identity,PxRigidDynamic* owner,PxgShapeManager& shapes) {
    CUdeviceptr pairs=0,countDevice=0,gate=0;CUevent ready=nullptr,start=nullptr;
    CUstream deferred=nullptr,control=nullptr;
    {PxScopedCudaLock lock(cuda);check(cuMemAlloc(&pairs,4096*sizeof(PxGpuContactPair)));
        check(cuMemAlloc(&countDevice,sizeof(PxU32)));check(cuMemsetD32(countDevice,0,1));
        check(cuMemAlloc(&gate,sizeof(PxU32)));check(cuMemsetD32(gate,0,1));
        check(cuEventCreate(&ready,CU_EVENT_DISABLE_TIMING));check(cuEventCreate(&start,CU_EVENT_DISABLE_TIMING));
        check(cuStreamCreate(&deferred,CU_STREAM_NON_BLOCKING));check(cuStreamCreate(&control,CU_STREAM_NON_BLOCKING));}
    // Warm explicit-observer storage before delaying a subsequent request.
    require(scene.getDirectGPUAPI().copyContactData(reinterpret_cast<PxGpuContactPair*>(pairs),
        reinterpret_cast<PxU32*>(countDevice),4096),"native contact observer warmup failed");
    {PxScopedCudaLock lock(cuda);
        check(cuStreamWaitValue32(deferred,gate,1,CU_STREAM_WAIT_VALUE_EQ));check(cuEventRecord(start,deferred));}
    const bool submitted=scene.getDirectGPUAPI().copyContactData(reinterpret_cast<PxGpuContactPair*>(pairs),
        reinterpret_cast<PxU32*>(countDevice),4096,start,ready);
    auto& source=shapes.mHostTransformCacheIdToActorTableMapped[identity];
    PxActor* saved=source;source=nullptr;
    {PxScopedCudaLock lock(cuda);check(cuStreamWriteValue32(control,gate,1,0));check(cuStreamSynchronize(control));
        check(cuEventSynchronize(ready));}
    source=saved;
    require(submitted,"native contact observation submission failed");
    unsigned observed=0;
    {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(ready));PxU32 count=0;
        check(cuMemcpyDtoH(&count,countDevice,sizeof(count)));require(count<=4096,"native contact observation overflow");
        std::vector<PxGpuContactPair> contacts(count);if(count)check(cuMemcpyDtoH(contacts.data(),pairs,count*sizeof(contacts[0])));
        for(const auto& pair:contacts) {
            if(pair.transformCacheRef0==identity) {
                require(pair.actor0==owner && pair.nodeIndex0.index()==owner->getGPUIndex(),"native contact export retained old first owner");
                observed+=pair.nbContacts;
            }
            if(pair.transformCacheRef1==identity) {
                require(pair.actor1==owner && pair.nodeIndex1.index()==owner->getGPUIndex(),"native contact export retained old second owner");
                observed+=pair.nbContacts;
            }
        }
        check(cuEventDestroy(ready));check(cuEventDestroy(start));
        check(cuStreamDestroy(deferred));check(cuStreamDestroy(control));
        check(cuMemFree(gate));check(cuMemFree(countDevice));check(cuMemFree(pairs));
    }
    return observed;
}
}
