// Optional diagnostic tracing. No simulation kernels, stream waits or device reads.
#pragma once
#include <cstdint>
#include <memory>
#include <string>
namespace blast_demo {
uint64_t nativeProfileTimestamp();
uint64_t nativeThreadCpuNs();
uint64_t nativeProcessCpuNs();
uint32_t nativeThreadId();
class NativeGpuActivity {
    struct Impl;
    std::unique_ptr<Impl> m;
public:
    explicit NativeGpuActivity(const std::string& directory, uint64_t graphBufferBytes=512ull*1024*1024);
    ~NativeGpuActivity();
    void finish();
};
}
