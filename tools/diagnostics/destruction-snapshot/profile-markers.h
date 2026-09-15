#pragma once
#ifdef PHYSX_SNAPSHOT_PROFILE
#include <cudaProfiler.h>
#include <nvtx3/nvToolsExt.h>
#include "native_phase_profiler.h"
// Reuse the engine's existing phase recorder. Only this diagnostic executable
// bridges its callbacks to NVTX; no runtime library or physics order changes.
class SnapshotProfileSession final : public physx::PxProfilerCallback {
    blast_demo::NativePhaseProfiler phases;
    struct Token {void* phase;nvtxRangeId_t range;};
    static SnapshotProfileSession*& current(){static SnapshotProfileSession* value=nullptr;return value;}
public:
    explicit SnapshotProfileSession(const char* directory):phases(std::string(directory)+"/native.phases.csv"){
        current()=this;PxSetProfilerCallback(this);
    }
    ~SnapshotProfileSession(){PxSetProfilerCallback(nullptr);current()=nullptr;}
    static void begin(){if(current())current()->phases.begin(0);}
    static void finish(){if(current()){current()->phases.acceptedFrame();current()->phases.begin(~0u);}}
    void* zoneStart(const char* name,bool detached,uint64_t context)override{
        void* p=phases.zoneStart(name,detached,context);if(!p)return nullptr;
        return new Token{p,nvtxRangeStartA(name)};
    }
    void zoneEnd(void* data,const char* name,bool detached,uint64_t context)override{
        if(!data)return;auto* t=static_cast<Token*>(data);nvtxRangeEnd(t->range);
        phases.zoneEnd(t->phase,name,detached,context);delete t;
    }
    void recordData(float value,const char* name,uint64_t context)override{phases.recordData(value,name,context);}
};
// Only the isolated profiling probe defines PHYSX_SNAPSHOT_PROFILE. Normal
// benchmark binaries contain no profiler calls or NVTX range overhead.
struct SnapshotProfileTick {
    physx::PxCudaContextManager& context;
    bool active;
    SnapshotProfileTick(physx::PxScene& scene,bool selected):context(*scene.getCudaContextManager()),active(selected) {
        if(active){physx::PxScopedCudaLock lock(context);
            if(cuProfilerStart()!=CUDA_SUCCESS)throw std::runtime_error("profiler start failed");
            SnapshotProfileSession::begin();nvtxRangePushA("snapshot/full_tick");nvtxRangePushA("snapshot/commands");}
    }
    void stage(const char* name){if(active){nvtxRangePop();nvtxRangePushA(name);}}
    void finish(){if(active){nvtxRangePop();nvtxRangePop();physx::PxScopedCudaLock lock(context);
            active=false;if(cuProfilerStop()!=CUDA_SUCCESS)throw std::runtime_error("profiler stop failed");SnapshotProfileSession::finish();}}
};
#else
struct SnapshotProfileSession {explicit SnapshotProfileSession(const char*){}};
struct SnapshotProfileTick {
    SnapshotProfileTick(physx::PxScene&,bool){}
    void stage(const char*){}
    void finish(){}
};
#endif
