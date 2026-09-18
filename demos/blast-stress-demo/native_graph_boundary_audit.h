// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Heavy diagnostic consumer of a borrowed contact view at its valid boundary.
#pragma once
#include "tests/native_contact_graph_check.h"
#include "foundation/PxFoundation.h"
#include <atomic>
#include <cstring>
#include <mutex>
class NativeGraphBoundaryAudit final : public physx::PxProfilerCallback {
    physx::PxProfilerCallback* mParent{};
    physx::PxScene* mScene{};
    std::atomic<unsigned> mPasses{0};
    unsigned mObserved{};
    std::mutex mMutex;
    std::string mError;
    bool mEnabled;
public:
    // Declare before the scene so this callback outlives outstanding tasks.
    explicit NativeGraphBoundaryAudit(bool enabled):mEnabled(enabled) {
        if(enabled){mParent=PxGetProfilerCallback();PxSetProfilerCallback(this);}
    }
    ~NativeGraphBoundaryAudit() override {if(mEnabled)PxSetProfilerCallback(mParent);}
    void bind(physx::PxScene& scene){mScene=&scene;}
    void* zoneStart(const char* name,bool detached,uint64_t context) override {
        return mParent?mParent->zoneStart(name,detached,context):nullptr;
    }
    void zoneEnd(void* token,const char* name,bool detached,uint64_t context) override {
        if(mParent)mParent->zoneEnd(token,name,detached,context);
        if(!mScene || std::strcmp(name,"GpuDestruction.task.contactGraph"))return;
        // This boundary follows contact/island retirement and precedes the
        // destruction ownership transaction. After fetchResults the same shape
        // buffers and retirement lists may describe a later final split.
        try {
            nativeGraphTest::verify(*mScene,*mScene->getCudaContextManager());++mPasses;
        } catch(const std::exception& e) {
            std::lock_guard<std::mutex> lock(mMutex);if(mError.empty())mError=e.what();
        }
    }
    void recordData(float value,const char* name,uint64_t context) override {
        if(mParent)mParent->recordData(value,name,context);
    }
    void check() {
        if(!mEnabled)return;
        std::lock_guard<std::mutex> lock(mMutex);
        if(!mError.empty())throw std::runtime_error("Contact producer-boundary audit: "+mError);
        const unsigned count=mPasses;
        if(count<=mObserved)throw std::runtime_error("Contact producer-boundary audit did not run this step");
        mObserved=count;
    }
    unsigned passes()const{return mPasses;}
};
