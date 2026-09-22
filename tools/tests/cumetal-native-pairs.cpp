// Execute the production broadphase.cu kernels, linked as one native object.
// This qualifies pair canonicalization only, not an entire broadphase scene.
#include <cuda_runtime.h>
#include <cumetal_driver.h>
#include "foundation/PxBounds3.h"
#include "PxgBroadPhaseDesc.h"
#include "PxgBroadPhasePairReport.h"
#include <algorithm>
#include <cstdio>
#include <vector>

using namespace physx;
constexpr PxU32 Capacity = 5000, Tile = 1024, Threads = 128;
#define CHECK_CUDA(call) do { const auto error = (call); if (error != cudaSuccess) { \
    std::fprintf(stderr, "CUDA error %d at line %d\n", int(error), __LINE__); return 1; } } while (0)
#define CHECK_DRIVER(call) do { const auto error = (call); if (error != CUDA_SUCCESS) { \
    std::fprintf(stderr, "driver error %d at line %d\n", int(error), __LINE__); return 1; } } while (0)

int main() {
    CHECK_DRIVER(cuInit(0));
    CUcontext context;
    CHECK_DRIVER(cuCtxCreate(&context, 0, 0));
    size_t count = 0;
    CHECK_DRIVER(cumetalGetNativeModules(nullptr, 0, &count));
    if (count != 1) return 2;
    CuMetalModuleHandle native;
    CHECK_DRIVER(cumetalGetNativeModules(&native, 1, &count));
    CUmodule module;
    CHECK_DRIVER(cumetalImportNativeModule(&module, native));
    const char* names[] = {"nativePairSortTiles", "nativePairMerge", "nativePairUniqueCounts",
                           "nativePairUniquePrefix", "nativePairUniqueScatter"};
    CUfunction kernels[5];
    for (int i = 0; i < 5; ++i) CHECK_DRIVER(cuModuleGetFunction(&kernels[i], module, names[i]));
    PxgBroadPhaseDesc descriptor{}, *device = nullptr;
    PxgBroadPhasePair* buffers[4];
    CHECK_CUDA(cudaMalloc(&device, sizeof(descriptor)));
    for (auto& buffer : buffers) CHECK_CUDA(cudaMalloc(&buffer, Capacity * sizeof(*buffer)));
    PxU32* offsets;
    CHECK_CUDA(cudaMalloc(&offsets, 2 * ((Capacity + Tile - 1) / Tile) * sizeof(PxU32)));
    cudaStream_t stream;
    CHECK_CUDA(cudaStreamCreate(&stream));
    CHECK_CUDA(cudaStreamBeginCapture(stream, cudaStreamCaptureModeThreadLocal));
    void* arguments[] = {&device};
    CHECK_DRIVER(cuLaunchKernel(kernels[0], 2, 2, 1, Threads, 1, 1, 0, (CUstream)stream, arguments, nullptr));
    for (PxU32 width = Tile; width < Capacity; width *= 2) {
        void* merge[] = {&device, &width};
        CHECK_DRIVER(cuLaunchKernel(kernels[1], 2, 2, 1, Threads, 1, 1, 0, (CUstream)stream, merge, nullptr));
    }
    for (int i = 2; i < 5; ++i)
        CHECK_DRIVER(cuLaunchKernel(kernels[i], i == 3 ? 1 : 2, 2, 1, Threads, 1, 1, 0, (CUstream)stream, arguments, nullptr));
    cudaGraph_t graph;
    cudaGraphExec_t executable;
    CHECK_CUDA(cudaStreamEndCapture(stream, &graph));
    CHECK_CUDA(cudaGraphInstantiate(&executable, graph, nullptr, nullptr, 0));

    const PxU32 cases[][2] = {{0, 1}, {1023, 1025}, {3207, 2048}};
    for (int scenario = 0; scenario < 6; ++scenario) {
        const PxU32* sizes = cases[scenario < 3 ? scenario : 2];
        std::vector<PxgBroadPhasePair> inputs[2];
        std::vector<PxU64> expected[2];
        for (unsigned axis = 0; axis < 2; ++axis) {
            for (PxU32 i = 0; i < sizes[axis]; ++i) {
                const PxU32 a = ((i / 3) * 53) % 2048 + (i % 7 == 0 ? 0x80000000u : 0);
                inputs[axis].emplace_back(a, a + 1 + ((i / 3) % 89));
                expected[axis].push_back((PxU64(inputs[axis].back().mVolA) << 32) | inputs[axis].back().mVolB);
            }
            std::sort(expected[axis].begin(), expected[axis].end(), std::greater<PxU64>());
            expected[axis].erase(std::unique(expected[axis].begin(), expected[axis].end()), expected[axis].end());
        }
        if (scenario == 3) inputs[0][0].mVolB = inputs[0][0].mVolA; // invalid pair
        for (int replay = 0; replay < 2; ++replay) {
            descriptor = {};
            descriptor.max_found_lost_pairs = Capacity;
            descriptor.sharedFoundPairIndex = sizes[0] + 7;
            descriptor.sharedFoundAggPairIndex = 7;
            descriptor.sharedLostPairIndex = sizes[1] + 3;
            descriptor.sharedLostAggPairIndex = 3;
            descriptor.foundActorPairReport = buffers[0]; descriptor.lostActorPairReport = buffers[1];
            descriptor.foundPairReport = buffers[2]; descriptor.lostPairReport = buffers[3];
            descriptor.nativePairTileOffsets = offsets;
            if (scenario == 4) descriptor.sharedFoundPairIndex = Capacity + 1; // overflow
            if (scenario == 5) descriptor.sharedFoundAggPairIndex = descriptor.sharedFoundPairIndex + 1;
            for (int axis = 0; axis < 2; ++axis)
                if (!inputs[axis].empty()) CHECK_CUDA(cudaMemcpyAsync(buffers[axis], inputs[axis].data(),
                    inputs[axis].size() * sizeof(PxgBroadPhasePair), cudaMemcpyHostToDevice, stream));
            CHECK_CUDA(cudaMemcpyAsync(device, &descriptor, sizeof(descriptor), cudaMemcpyHostToDevice, stream));
            CHECK_CUDA(cudaGraphLaunch(executable, stream));
            CHECK_CUDA(cudaMemcpyAsync(&descriptor, device, sizeof(descriptor), cudaMemcpyDeviceToHost, stream));
            CHECK_CUDA(cudaStreamSynchronize(stream));
            if (scenario >= 3) {
                if (descriptor.nativePairError != (scenario == 3 ? 2u : 1u) ||
                    descriptor.nativePairCounts[0] || descriptor.nativePairCounts[1]) return 3;
                continue;
            }
            if (descriptor.nativePairError) {
                std::fprintf(stderr, "pair error case %d replay %d: %u, counts %u/%u, raw %u/%u, aggregate %u/%u, capacity %u\n",
                    scenario, replay, descriptor.nativePairError, descriptor.nativePairCounts[0], descriptor.nativePairCounts[1],
                    descriptor.sharedFoundPairIndex, descriptor.sharedLostPairIndex,
                    descriptor.sharedFoundAggPairIndex, descriptor.sharedLostAggPairIndex, descriptor.max_found_lost_pairs);
                return 4;
            }
            for (int axis = 0; axis < 2; ++axis) {
                if (descriptor.nativePairCounts[axis] != expected[axis].size()) {
                    std::fprintf(stderr, "pair count case %d axis %d: %u expected %zu\n", scenario, axis,
                                 descriptor.nativePairCounts[axis], expected[axis].size()); return 5;
                }
                std::vector<PxgBroadPhasePair> output(expected[axis].size());
                if (!output.empty()) CHECK_CUDA(cudaMemcpyAsync(output.data(), descriptor.nativePairReports[axis],
                    output.size() * sizeof(PxgBroadPhasePair), cudaMemcpyDeviceToHost, stream));
                CHECK_CUDA(cudaStreamSynchronize(stream));
                for (size_t i = 0; i < output.size(); ++i)
                    if (((PxU64(output[i].mVolA) << 32) | output[i].mVolB) != expected[axis][i]) {
                        std::fprintf(stderr, "pair mismatch case %d axis %d index %zu\n", scenario, axis, i); return 6;
                    }
            }
        }
    }
    CHECK_CUDA(cudaGraphExecDestroy(executable)); CHECK_CUDA(cudaGraphDestroy(graph));
    CHECK_CUDA(cudaStreamDestroy(stream)); CHECK_CUDA(cudaFree(device)); CHECK_CUDA(cudaFree(offsets));
    for (auto buffer : buffers) CHECK_CUDA(cudaFree(buffer));
    CHECK_DRIVER(cuModuleUnload(module)); CHECK_DRIVER(cuCtxDestroy(context));
    std::puts("PASS: production native pair sort/merge/unique/scan/scatter, nested descriptor, graph replay and error publication");
    return 0;
}
