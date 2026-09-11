#pragma once
#include <cudamanager/PxCudaContextManager.h>
#include <cuda.h>
#include <map>
#include <vector>
#include <mutex>
#include <cstdint>
// Owns reusable allocation capacity, never physical state or solver/contact data.
// One workspace per CUDA context. finish() must run before destroying that context.
class SnapshotPinnedPool final : public physx::PxPinnedHostAllocatorCallback {
    struct Block {void* pointer;size_t bytes;unsigned flags;};
    std::mutex mutex;std::vector<Block> cached;std::map<void*,Block> live;
    size_t retained=0;const size_t limit;bool enabled=true;
public:
    uint64_t allocations=0,reuses=0,retainedPeak=0;bool healthy=true;
    explicit SnapshotPinnedPool(size_t capacity=size_t(8)<<30):limit(capacity){}
    bool memAlloc(void** ptr,size_t size,physx::PxU32 flags) override {
        std::lock_guard<std::mutex> lock(mutex);*ptr=nullptr;
        if(enabled)for(size_t i=0;i<cached.size();++i)if(cached[i].bytes==size && cached[i].flags==flags){
            // Preserve cudaFree's completion boundary before recycling a lease.
            if(cuCtxSynchronize()!=CUDA_SUCCESS){healthy=false;return false;}
            const Block b=cached[i];cached.erase(cached.begin()+i);retained-=size;
            live.emplace(b.pointer,b);*ptr=b.pointer;++reuses;return true;
        }
        if(cuMemHostAlloc(ptr,size,flags)!=CUDA_SUCCESS){healthy=false;return false;}
        live.emplace(*ptr,Block{*ptr,size,flags});++allocations;return true;
    }
    bool memFree(void* ptr) override {
        if(!ptr)return true;std::lock_guard<std::mutex> lock(mutex);
        auto it=live.find(ptr);if(it==live.end()){healthy=false;return false;}
        const Block b=it->second;
        if(enabled && b.bytes<=limit-retained){cached.push_back(b);retained+=b.bytes;retainedPeak=retained>retainedPeak?retained:retainedPeak;}
        else if(cuMemFreeHost(ptr)!=CUDA_SUCCESS){healthy=false;return false;}
        live.erase(it);return true;
    }
    void finish(){std::lock_guard<std::mutex> lock(mutex);enabled=false;
        for(const auto& b:cached)if(cuMemFreeHost(b.pointer)!=CUDA_SUCCESS)healthy=false;
        cached.clear();retained=0;
    }
    ~SnapshotPinnedPool(){if(!cached.empty() || !live.empty())std::terminate();}
};
struct FinishSnapshotPool {SnapshotPinnedPool& pool;~FinishSnapshotPool(){pool.finish();}};
