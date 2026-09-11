#pragma once
#ifdef PHYSX_SNAPSHOT_PROFILE
#include <cudaProfiler.h>
#include <nvtx3/nvToolsExt.h>
// Only the isolated profiling probe defines PHYSX_SNAPSHOT_PROFILE. Normal
// benchmark binaries contain no profiler calls or NVTX range overhead.
struct SnapshotProfileTick {
    physx::PxCudaContextManager& context;
    bool active;
    SnapshotProfileTick(physx::PxScene& scene,bool selected):context(*scene.getCudaContextManager()),active(selected) {
        if(active){physx::PxScopedCudaLock lock(context);
            if(cuProfilerStart()!=CUDA_SUCCESS)throw std::runtime_error("profiler start failed");
            nvtxRangePushA("snapshot/full_tick");nvtxRangePushA("snapshot/commands");}
    }
    void stage(const char* name){if(active){nvtxRangePop();nvtxRangePushA(name);}}
    void finish(){if(active){nvtxRangePop();nvtxRangePop();physx::PxScopedCudaLock lock(context);
            active=false;if(cuProfilerStop()!=CUDA_SUCCESS)throw std::runtime_error("profiler stop failed");}}
};
#else
struct SnapshotProfileTick {
    SnapshotProfileTick(physx::PxScene&,bool){}
    void stage(const char*){}
    void finish(){}
};
#endif
