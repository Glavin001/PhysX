// Optional host-wall phase capture; never synchronizes a CUDA stream.
#pragma once
#include <foundation/PxFoundation.h>
#include <foundation/PxProfiler.h>
#include <atomic>
#include <chrono>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <mutex>
#include <new>
#include <stdexcept>
#include <string>
#include <vector>
namespace blast_demo {
class NativePhaseProfiler final : public physx::PxProfilerCallback {
    using Clock=std::chrono::steady_clock;
    struct Token {Clock::time_point start;const char* name;uint64_t context;unsigned step;bool detached;};
    struct Row {std::string name;uint64_t context;unsigned step;bool detached;double ms;};
    std::ofstream mFile;
    std::atomic<unsigned> mStep{~0u};
    std::atomic<bool> mFailed{false};
    std::mutex mMutex;
    std::vector<Row> mRows;
    bool mEnabled=false;
public:
    // Declare before the scene/context: the callback must outlive tasks and
    // incomplete-correction teardown. Registration itself needs no foundation.
    explicit NativePhaseProfiler(const std::string& path) {
        if(path.empty())return;
        if(PxGetProfilerCallback())throw std::runtime_error("phase capture requires an unused profiler callback");
        mFile.open(path);if(!mFile)throw std::runtime_error("cannot open phase capture");
        mFile<<"step,phase,context,detached,host_wall_ms,accepted_step\n"<<std::setprecision(10);
        mRows.reserve(32);mEnabled=true;PxSetProfilerCallback(this);
    }
    ~NativePhaseProfiler() override {
        if(mEnabled){PxSetProfilerCallback(nullptr);writeRows(false);}
    }
    void begin(unsigned step){mStep=step;}
    void* zoneStart(const char* name,bool detached,uint64_t context) override {
        if(std::strncmp(name,"GpuDestruction.",15)!=0 || mStep==~0u)return nullptr;
        auto* token=new(std::nothrow) Token{Clock::now(),name,context,mStep.load(),detached};
        if(!token)mFailed=true;
        return token;
    }
    void zoneEnd(void* data,const char* name,bool detached,uint64_t context) override {
        if(!data)return;
        auto* token=static_cast<Token*>(data);
        const double elapsed=std::chrono::duration<double,std::milli>(Clock::now()-token->start).count();
        if(token->name!=name || token->context!=context || token->detached!=detached)mFailed=true;
        try {std::lock_guard<std::mutex> lock(mMutex);mRows.push_back({token->name,context,token->step,detached,elapsed});}
        catch(...){mFailed=true;}
        delete token;
    }
    void acceptedFrame() {
        if(!mEnabled)return;
        writeRows(true);
        if(mFailed || !mFile)throw std::runtime_error("native phase capture incomplete");
    }
private:
    void writeRows(bool accepted) {
        std::lock_guard<std::mutex> lock(mMutex);
        for(const auto& row:mRows)mFile<<row.step<<','<<row.name<<','<<row.context<<','<<row.detached<<','<<row.ms<<','<<accepted<<'\n';
        mRows.clear();mFile.flush();
    }
};
}
