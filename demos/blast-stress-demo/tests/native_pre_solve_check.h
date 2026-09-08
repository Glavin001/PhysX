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
#include <string>
namespace nativePreSolveTest {
inline void verify(physx::PxgGpuContext& gpu,physx::PxCudaContextManager& cuda) {
    using namespace physx;auto* core=gpu.getGpuSolverCore();
    if(gpu.getPreSolveNodeDevicePointer()) {
        const auto& expected=gpu.getExpectedPreSolveNodes();std::vector<PxvPreSolveNode> actual(expected.size());
        {PxScopedCudaLock lock(cuda);
            if(cuStreamSynchronize(core->getStream())!=CUDA_SUCCESS || (!actual.empty()
                && cuMemcpyDtoH(actual.data(),gpu.getPreSolveNodeDevicePointer(),actual.size()*sizeof(actual[0]))!=CUDA_SUCCESS))
                throw std::runtime_error("CUDA pre-solve node audit readback failed");}
        for(PxU32 i=0;i<actual.size();++i)if(actual[i].lifetime!=expected[i].lifetime || actual[i].live!=expected[i].live
            || actual[i].staticTouches!=(gpu.preSolveNodesUseNativeSupport()?expected[i].staticTouches:0u))
            throw std::runtime_error("persistent CUDA node record differs from full native pre-solve snapshot");
    }
    if(gpu.getPreSolveSupportDevicePointer()) {
        const auto& expected=gpu.getExpectedPreSolveNodes();std::vector<PxU32> support(expected.size());
        {PxScopedCudaLock lock(cuda);if(cuMemcpyDtoH(support.data(),gpu.getPreSolveSupportDevicePointer(),support.size()*sizeof(PxU32))!=CUDA_SUCCESS)
            throw std::runtime_error("GPU-derived static-support audit readback failed");}
        for(PxU32 i=0;i<expected.size();++i)if(expected[i].live && support[i]!=expected[i].staticTouches)
            throw std::runtime_error("GPU static support differs at node "+std::to_string(i)+": actual "+std::to_string(support[i])+", expected "+std::to_string(expected[i].staticTouches));
    }
    if(!core->mPreSolveIslandIds)return;
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
            throw std::runtime_error("CUDA pre-solve partition differs at node "+std::to_string(i)+", GPU label "+std::to_string(label)+", native label "+std::to_string(native)+", prior GPU label "+std::to_string(a.first->second)+", prior native label "+std::to_string(b.first->second));
        if(touches[label]!=expectedTouches[native])throw std::runtime_error("CUDA pre-solve static count differs at node "+std::to_string(i)+", GPU component "+std::to_string(label)+", native island "+std::to_string(native)+": actual "+std::to_string(touches[label])+", expected "+std::to_string(expectedTouches[native]));
    }
}
}
