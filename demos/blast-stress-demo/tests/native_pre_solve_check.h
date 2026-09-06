// Independent comparison of CUDA-produced pre-solve components/static counts
// against the native snapshot captured at that same task boundary.
#pragma once
#include "PxgContext.h"
#include "PxgSolverCore.h"
#include "cudamanager/PxCudaContextManager.h"
#include <cuda.h>
#include <vector>
#include <map>
#include <stdexcept>
namespace nativePreSolveTest {
inline void verify(physx::PxgGpuContext& gpu,physx::PxCudaContextManager& cuda) {
    using namespace physx;auto* core=gpu.getGpuSolverCore();if(!core->mPreSolveIslandIds)return;
    const auto& expectedIds=gpu.getExpectedSolverIslandIds();const auto& expectedTouches=gpu.getExpectedSolverStaticTouches();
    std::vector<PxU32> labels(expectedIds.size()),touches(expectedIds.size());
    {PxScopedCudaLock lock(cuda);
        if(cuStreamSynchronize(core->getStream())!=CUDA_SUCCESS
            || cuMemcpyDtoH(labels.data(),core->mPreSolveIslandIds,labels.size()*sizeof(PxU32))!=CUDA_SUCCESS
            || cuMemcpyDtoH(touches.data(),core->mPreSolveStaticTouches,touches.size()*sizeof(PxU32))!=CUDA_SUCCESS)
            throw std::runtime_error("CUDA pre-solve producer readback failed");}
    std::map<PxU32,PxU32> nativeToGpu,gpuToNative;
    for(PxU32 i=0;i<labels.size();++i) {
        const PxU32 native=expectedIds[i],label=labels[i];
        if(native==~PxU32(0)) {if(label!=~PxU32(0))throw std::runtime_error("CUDA pre-solve producer included an inactive/prescribed node");continue;}
        if(label>=labels.size() || native>=expectedTouches.size())throw std::runtime_error("CUDA pre-solve producer omitted a live node");
        const auto a=nativeToGpu.emplace(native,label),b=gpuToNative.emplace(label,native);
        if((!a.second && a.first->second!=label) || (!b.second && b.first->second!=native))
            throw std::runtime_error("CUDA pre-solve partition differs from native pre-solve partition");
        if(touches[label]!=expectedTouches[native])throw std::runtime_error("CUDA pre-solve static count differs from native pre-solve count");
    }
}
}
