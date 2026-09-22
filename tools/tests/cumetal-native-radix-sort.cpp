// Numerical gate for the ACTUAL radixSortImpl.cu WithCount kernel pair.
// No test kernels or substituted sorting implementation execute on the GPU.
#include <cuda_runtime.h>
#include <cumetal_driver.h>
#include "PxgRadixSortDesc.h"
#include "PxgRadixSortKernelIndices.h"
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cerrno>
#include <limits>
#include <memory>
#include <utility>
#include <vector>
using namespace physx;
#define CUDA(call) do { const auto e = (call); if (e != cudaSuccess) { std::fprintf(stderr, "%s: CUDA %d at %d\n", #call, int(e), __LINE__); return 1; } } while (0)
#define DRIVER(call) do { const auto e = (call); if (e != CUDA_SUCCESS) { std::fprintf(stderr, "%s: driver %d at %d\n", #call, int(e), __LINE__); return 1; } } while (0)
namespace {
constexpr unsigned Axes = 3, Replays = 3, Guard = 16, Radices = 16;
constexpr PxU32 Sentinel = 0xd3adc0deu;
constexpr unsigned Blocks = PxgRadixSortKernelGridDim::RADIX_SORT;
constexpr unsigned Threads = PxgRadixSortKernelBlockDim::RADIX_SORT;
static_assert(Blocks == 32, "production scanRadixes requires exactly 32 blocks");
template<class T> struct Buffer {
    T* pointer = nullptr;
    ~Buffer() { if (pointer) cudaFree(pointer); }
    cudaError_t allocate(size_t n) { return cudaMalloc(&pointer, n * sizeof(T)); }
    cudaError_t upload(const T* values, size_t n, cudaStream_t stream) { return cudaMemcpyAsync(pointer, values, n * sizeof(T), cudaMemcpyHostToDevice, stream); }
    cudaError_t download(T* values, size_t n, cudaStream_t stream) { return cudaMemcpyAsync(values, pointer, n * sizeof(T), cudaMemcpyDeviceToHost, stream); }
};
struct Case {
    unsigned count = 0, storage = 0, passes = 8;
    Buffer<PxU32> keys[Axes][2], ranks[Axes][2], histogram[Axes];
    Buffer<PxgRadixSortDesc> descriptors[2];
    PxgRadixSortDesc hostDescriptors[2][Axes]{};
    cudaGraph_t graph = nullptr;
    cudaGraphExec_t executable = nullptr;
    std::vector<PxU32> blank, blankHistogram;
    std::vector<PxU32> inputKeys[Replays][Axes], inputRanks[Replays][Axes];
    std::vector<PxU32> outputKeys[Replays][Axes][2], outputRanks[Replays][Axes][2], outputHistogram[Replays][Axes];
    ~Case() { if (executable) cudaGraphExecDestroy(executable); if (graph) cudaGraphDestroy(graph); }
};
static PxU32 keyFor(unsigned index, unsigned axis, unsigned replay) {
    const PxU32 boundary[] = {0u, 0xffffffffu, 0x80000000u, 0x7fffffffu, 0x01010101u, 0xf0f0f0f0u, 0xaaaaaaaau, 0x55555555u};
    if ((index % 11) < 8) return boundary[(index + axis * 3 + replay) % 8];
    PxU32 value = PxU32(index) * 747796405u + PxU32(axis + replay * 13) * 2891336453u;
    value = ((value >> ((value >> 28u) + 4u)) ^ value) * 277803737u;
    return (value >> 22u) ^ value;
}
static CUresult launchPasses(CUfunction histogram, CUfunction scatter, Case& test, cudaStream_t stream) {
    PxU32 count = test.count;
    for (PxU32 bit = 0; bit < test.passes * 4; bit += 4) {
        PxgRadixSortDesc* descriptor = test.descriptors[(bit / 4) & 1].pointer;
        void* args[] = {&descriptor, &count, &bit};
        auto result = cuLaunchKernel(histogram, Blocks, Axes, 1, Threads, 1, 1, 0, (CUstream)stream, args, nullptr);
        if (result != CUDA_SUCCESS) return result;
        result = cuLaunchKernel(scatter, Blocks, Axes, 1, Threads, 1, 1, 0, (CUstream)stream, args, nullptr);
        if (result != CUDA_SUCCESS) return result;
    }
    return CUDA_SUCCESS;
}
static void diagnostic(const Case& test, unsigned replay, unsigned axis) {
    std::fprintf(stderr, "INPUT n=%u passes=%u replay=%u axis=%u\n", test.count, test.passes, replay, axis);
    const unsigned shown = std::min(test.count + 4, 20u);
    for (unsigned i = 0; i < shown; ++i)
        std::fprintf(stderr, "  i=%u input=%08x/%08x ping0=%08x/%08x ping1=%08x/%08x\n", i,
            test.inputKeys[replay][axis][Guard+i], test.inputRanks[replay][axis][Guard+i],
            test.outputKeys[replay][axis][0][Guard+i], test.outputRanks[replay][axis][0][Guard+i],
            test.outputKeys[replay][axis][1][Guard+i], test.outputRanks[replay][axis][1][Guard+i]);
    const auto& histogram = test.outputHistogram[replay][axis];
    for (unsigned radix = 0; radix < Radices; ++radix) {
        std::fprintf(stderr, "  histogram radix%u nonzero blocks:", radix);
        for (unsigned block = 0; block < Blocks; ++block) {
            const PxU32 value = histogram[Guard + radix * Blocks + block];
            if (value) std::fprintf(stderr, " b%u=%u(0x%08x)", block, value, value);
        }
        std::fputc('\n', stderr);
    }
}
static bool argument(const char* text, unsigned& result) {
    if (!text[0] || text[0] == '-') return false;
    errno = 0; char* end = nullptr;
    const unsigned long value = std::strtoul(text, &end, 10);
    if (errno || !end || *end || value > std::numeric_limits<unsigned>::max()) return false;
    result = unsigned(value); return true;
}
}
int main(int argc, char** argv) {
    unsigned passes = 8, selectedCount = 0; bool singleCount = false;
    for (int i = 1; i < argc; ++i) {
        if (!std::strcmp(argv[i], "--help")) { std::puts("cumetal-native-radix-sort [--count N] [--passes 1..8]"); return 0; }
        if (i + 1 >= argc) { std::fprintf(stderr, "missing option value\n"); return 2; }
        if (!std::strcmp(argv[i], "--count")) { singleCount = argument(argv[++i], selectedCount); if (!singleCount || selectedCount > 1048576) return 2; }
        else if (!std::strcmp(argv[i], "--passes")) { if (!argument(argv[++i], passes) || passes < 1 || passes > 8) return 2; }
        else { std::fprintf(stderr, "unknown option %s\n", argv[i]); return 2; }
    }
    DRIVER(cuInit(0)); CUcontext context = nullptr; DRIVER(cuCtxCreate(&context, 0, 0));
    size_t moduleCount = 0; DRIVER(cumetalGetNativeModules(nullptr, 0, &moduleCount));
    if (moduleCount != 1) { std::fprintf(stderr, "link exactly the production radixSortImpl object; registered modules=%zu\n", moduleCount); return 2; }
    CuMetalModuleHandle native; DRIVER(cumetalGetNativeModules(&native, 1, &moduleCount));
    CUmodule module = nullptr; DRIVER(cumetalImportNativeModule(&module, native));
    CUfunction histogram = nullptr, scatter = nullptr;
    DRIVER(cuModuleGetFunction(&histogram, module, "radixSortMultiBlockLaunchWithCount"));
    DRIVER(cuModuleGetFunction(&scatter, module, "radixSortMultiCalculateRanksLaunchWithCount"));
    cudaStream_t stream = nullptr; CUDA(cudaStreamCreateWithFlags(&stream, cudaStreamNonBlocking));
    {
        // The last case requires two uint4 iterations per block, including an
        // uneven final iteration. The penultimate case spans multiple blocks.
        std::vector<unsigned> counts = {0, 1, 31, 33, 1023, 1025, 4 * Threads + 17, 4 * Threads * Blocks + 37};
        if (singleCount) counts = {selectedCount};
        std::vector<std::unique_ptr<Case>> cases;
        for (unsigned count : counts) {
            cases.emplace_back(new Case()); Case& test = *cases.back();
            test.count = count; test.passes = passes; test.storage = ((count + 3) & ~3u) + 2 * Guard;
            test.blank.assign(test.storage, Sentinel);
            test.blankHistogram.assign(Radices * Blocks + 2 * Guard, Sentinel);
            for (unsigned axis = 0; axis < Axes; ++axis) {
                CUDA(test.histogram[axis].allocate(test.blankHistogram.size()));
                for (unsigned side = 0; side < 2; ++side) {
                    CUDA(test.keys[axis][side].allocate(test.storage));
                    CUDA(test.ranks[axis][side].allocate(test.storage));
                }
                for (unsigned side = 0; side < 2; ++side) {
                    auto& d = test.hostDescriptors[side][axis];
                    d.inputKeys = test.keys[axis][side].pointer + Guard;
                    d.inputRanks = test.ranks[axis][side].pointer + Guard;
                    d.outputKeys = test.keys[axis][side ^ 1].pointer + Guard;
                    d.outputRanks = test.ranks[axis][side ^ 1].pointer + Guard;
                    d.radixBlockCounts = test.histogram[axis].pointer + Guard; d.count = count;
                }
            }
            for (unsigned side = 0; side < 2; ++side) {
                CUDA(test.descriptors[side].allocate(Axes));
                CUDA(test.descriptors[side].upload(test.hostDescriptors[side], Axes, stream));
            }
            CUDA(cudaStreamBeginCapture(stream, cudaStreamCaptureModeThreadLocal));
            DRIVER(launchPasses(histogram, scatter, test, stream));
            CUDA(cudaStreamEndCapture(stream, &test.graph));
            CUDA(cudaGraphInstantiate(&test.executable, test.graph, nullptr, nullptr, 0));
            // Keep every async-copy source/destination alive until the ONE sync
            // below. Each replay changes all three axes before replaying the
            // same captured 16-kernel chain; no per-kernel synchronization.
            for (unsigned replay = 0; replay < Replays; ++replay) {
                for (unsigned axis = 0; axis < Axes; ++axis) {
                    auto& keys = test.inputKeys[replay][axis]; auto& ranks = test.inputRanks[replay][axis];
                    keys = test.blank; ranks = test.blank;
                    for (unsigned i = 0; i < count; ++i) {
                        keys[Guard + i] = keyFor(i, axis, replay);
                        ranks[Guard + i] = 0xa0000000u + axis * 0x100000u + count - i;
                    }
                    CUDA(test.keys[axis][0].upload(keys.data(), test.storage, stream));
                    CUDA(test.ranks[axis][0].upload(ranks.data(), test.storage, stream));
                    CUDA(test.keys[axis][1].upload(test.blank.data(), test.storage, stream));
                    CUDA(test.ranks[axis][1].upload(test.blank.data(), test.storage, stream));
                    CUDA(test.histogram[axis].upload(test.blankHistogram.data(), test.blankHistogram.size(), stream));
                }
                if (replay == 0) DRIVER(launchPasses(histogram, scatter, test, stream));
                else CUDA(cudaGraphLaunch(test.executable, stream));
                for (unsigned axis = 0; axis < Axes; ++axis) {
                    for (unsigned side = 0; side < 2; ++side) {
                        auto& keys = test.outputKeys[replay][axis][side]; auto& ranks = test.outputRanks[replay][axis][side];
                        keys.resize(test.storage); ranks.resize(test.storage);
                        CUDA(test.keys[axis][side].download(keys.data(), test.storage, stream));
                        CUDA(test.ranks[axis][side].download(ranks.data(), test.storage, stream));
                    }
                    auto& values = test.outputHistogram[replay][axis]; values.resize(test.blankHistogram.size());
                    CUDA(test.histogram[axis].download(values.data(), values.size(), stream));
                }
            }
        }
        CUDA(cudaStreamSynchronize(stream));
        for (const auto& owned : cases) {
            const Case& test = *owned;
            for (unsigned replay = 0; replay < Replays; ++replay) for (unsigned axis = 0; axis < Axes; ++axis) {
                for (unsigned side = 0; side < 2; ++side) {
                    // Each side is compared to its most recent pass. With the
                    // normal eight passes, ping0 is all32 bits and ping1 low28.
                    // At one pass, ping0 remains the original unsorted input.
                    const unsigned sidePasses = side == (passes & 1u) ? passes : passes - 1;
                    const PxU32 mask = sidePasses == 8 ? 0xffffffffu : ((PxU32(1) << (sidePasses * 4)) - 1);
                    std::vector<std::pair<PxU32, PxU32>> expected;
                    for (unsigned i = 0; i < test.count; ++i)
                        expected.emplace_back(test.inputKeys[replay][axis][Guard + i], test.inputRanks[replay][axis][Guard + i]);
                    std::stable_sort(expected.begin(), expected.end(), [mask](const auto& a, const auto& b) { return (a.first & mask) < (b.first & mask); });
                    for (unsigned i = 0; i < test.storage; ++i) {
                        const bool active = i >= Guard && i < Guard + test.count;
                        const PxU32 key = active ? expected[i - Guard].first : Sentinel;
                        const PxU32 rank = active ? expected[i - Guard].second : Sentinel;
                        if (test.outputKeys[replay][axis][side][i] != key || test.outputRanks[replay][axis][side][i] != rank) {
                            std::fprintf(stderr, "radix mismatch n=%u replay=%u axis=%u side=%u slot=%u key=%08x expected=%08x rank=%08x expected=%08x\n", test.count, replay, axis, side, i, test.outputKeys[replay][axis][side][i], key, test.outputRanks[replay][axis][side][i], rank);
                            diagnostic(test, replay, axis); return 3;
                        }
                    }
                }
                const auto& values = test.outputHistogram[replay][axis];
                for (unsigned i = 0; i < values.size(); ++i)
                    if ((i < Guard || i >= Guard + Radices * Blocks) && values[i] != Sentinel) {
                        std::fprintf(stderr, "radix histogram guard n=%u replay=%u axis=%u slot=%u\n", test.count, replay, axis, i); diagnostic(test, replay, axis); return 4;
                    }
            }
            std::printf("PASS production WithCount radix n=%u axes=3 threads=%u grid=32x3 passes=%u direct+2queued graph replays exact stable keys/ranks+guards\n", test.count, Threads, passes);
        }
    }
    CUDA(cudaStreamDestroy(stream)); DRIVER(cuModuleUnload(module)); DRIVER(cuCtxDestroy(context));
    return 0;
}
