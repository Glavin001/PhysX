// Execute aggregate.cu itself. CPU bounds comparisons are a test oracle only.
#include <cuda_runtime.h>
#include <cumetal_driver.h>
#include "foundation/PxBounds3.h"
#include "PxgBroadPhaseDesc.h"
#include "PxgBroadPhasePairReport.h"
#include "PxgAggregateDesc.h"
#include "PxgAggregate.h"
#include "PxgSapBox1D.h"
#include "PxAggregate.h"
#include "PxgIntegerAABB.h"
#include "BpVolumeData.h"
#include <algorithm>
#include <cstdio>
#include <vector>
#include <cstdlib>
#include <cstring>
#include <spawn.h>
#include <sys/wait.h>
extern char** environ;
using namespace physx;
#define CUDA(call) do { auto e = (call); if (e != cudaSuccess) { std::fprintf(stderr, "CUDA %d line %d\n", int(e), __LINE__); return 1; } } while (0)
#define DRIVER(call) do { auto e = (call); if (e != CUDA_SUCCESS) { std::fprintf(stderr, "driver %d line %d\n", int(e), __LINE__); return 1; } } while (0)
// Trapping cases run in isolated processes and inspect mapped memory only.
static bool failedContext = false;
template<class T> struct Buffer {
    T* pointer = nullptr;
    T* mapped = nullptr;
    ~Buffer() { if (!failedContext) { if (mapped) cudaFreeHost(mapped); else if (pointer) cudaFree(pointer); } }
    cudaError_t allocate(size_t count, bool hostMapped = false) {
        if (!hostMapped) return cudaMalloc(&pointer, count * sizeof(T));
        const auto error = cudaHostAlloc(&mapped, count * sizeof(T), cudaHostAllocMapped);
        return error == cudaSuccess ? cudaHostGetDevicePointer(&pointer, mapped, 0) : error;
    }
    cudaError_t upload(const T* data, size_t count, cudaStream_t stream) { return cudaMemcpyAsync(pointer, data, count * sizeof(T), cudaMemcpyHostToDevice, stream); }
    cudaError_t download(T* data, size_t count, cudaStream_t stream) { return cudaMemcpyAsync(data, pointer, count * sizeof(T), cudaMemcpyDeviceToHost, stream); }
};
static PxU64 key(const PxgBroadPhasePair& p) { return (PxU64(p.mVolA) << 32) | p.mVolB; }
static int runCase(bool selfCollision, bool invalidOwner, bool captured) {
    DRIVER(cuInit(0)); CUcontext context; DRIVER(cuCtxCreate(&context, 0, 0));
    size_t count = 0; DRIVER(cumetalGetNativeModules(nullptr, 0, &count));
    if (count != 1) return 2;
    CuMetalModuleHandle native; DRIVER(cumetalGetNativeModules(&native, 1, &count));
    CUmodule module; DRIVER(cumetalImportNativeModule(&module, native));
    CUfunction kernel; DRIVER(cuModuleGetFunction(&kernel, module, selfCollision ? "doSelfCollision" : "doAggPairCollisions"));
    cudaStream_t stream; CUDA(cudaStreamCreate(&stream));
    {
        constexpr unsigned Proxies = 6, MaxChildren = 35, Bounds = 6 + Proxies * MaxChildren, Pairs = 3, Capacity = 1600;
        constexpr unsigned Slots = Proxies * 2, MaskWords = (2 * MaxChildren + 31) / 32;
        const bool aggregate[Proxies] = {true, true, true, false, false, true};
        Buffer<PxgBroadPhaseDesc> bp; Buffer<PxgAggregateDesc> ad;
        Buffer<PxgIntegerAABB> bounds[2]; Buffer<Bp::VolumeData> volumes;
        Buffer<PxNodeIndex> owners; Buffer<PxgAggregate> aggs; Buffer<PxgAggregatePair> pairs;
        Buffer<PxU32> groups, removed, bitmap, pairCount, indices, projections, handles, masks, comparisons;
        Buffer<PxgSapBox1D> sap;
        Buffer<PxgBroadPhasePair> reports[2];
        CUDA(bp.allocate(1)); CUDA(ad.allocate(1, invalidOwner)); CUDA(volumes.allocate(Bounds));
        CUDA(owners.allocate(Bounds)); CUDA(aggs.allocate(Proxies)); CUDA(pairs.allocate(Pairs));
        CUDA(groups.allocate(Bounds)); CUDA(removed.allocate(1)); CUDA(bitmap.allocate(Pairs)); CUDA(pairCount.allocate(1));
        CUDA(indices.allocate(Slots * MaxChildren)); CUDA(projections.allocate(Slots * 2 * MaxChildren));
        CUDA(handles.allocate(Slots * 2 * MaxChildren)); CUDA(masks.allocate(Slots * MaskWords));
        CUDA(sap.allocate(Slots * MaxChildren)); CUDA(comparisons.allocate(Slots * MaxChildren));
        for (int t = 0; t < 2; ++t) { CUDA(bounds[t].allocate(Bounds)); CUDA(reports[t].allocate(Capacity + 2, invalidOwner)); }
        CUDA(cudaStreamBeginCapture(stream, cudaStreamCaptureModeThreadLocal));
        void* pairArgs[] = {&bp.pointer, &ad.pointer
#if defined(PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT) && PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT
            , &aggs.pointer
#endif
        };
        void* selfArgs[] = {&bp.pointer, &ad.pointer};
        void** args = selfCollision ? selfArgs : pairArgs;
        DRIVER(cuLaunchKernel(kernel, 2, 1, 1, 32, 2, 1, 0, (CUstream)stream, args, nullptr));
        cudaGraph_t graph; cudaGraphExec_t executable;
        CUDA(cudaStreamEndCapture(stream, &graph)); CUDA(cudaGraphInstantiate(&executable, graph, nullptr, nullptr, 0));
        for (const unsigned childCount : {2u, 17u, 35u})
        for (int phase = 0; phase < 10; ++phase) for (int replay = 0; replay < 2; ++replay) {
            if ((selfCollision || invalidOwner) && (childCount != 35 || phase != 9 || (invalidOwner && replay != 0))) continue;
            PxNodeIndex ownerData[Bounds];
            PxgIntegerAABB boxes[2][Bounds]; Bp::VolumeData volumeData[Bounds]{};
            PxU32 groupData[Bounds], indexData[Slots * MaxChildren]{}, projectionData[Slots * 2 * MaxChildren]{}, handleData[Slots * 2 * MaxChildren]{}, maskData[Slots * MaskWords]{};
            PxgAggregate aggregateData[Proxies]; PxgAggregatePair pairData[Pairs]{};
            PxgSapBox1D sapData[Slots * MaxChildren]; PxU32 comparisonData[Slots * MaxChildren]{};
            std::vector<PxU32> children[Proxies];
            for (unsigned i = 0; i < Bounds; ++i) { groupData[i] = phase == 5 ? 0 : (phase == 9 ? 2 : ((i + 1) << 3) | 2); ownerData[i] = PxNodeIndex(PxU32(phase == 8 ? 123 : i + 123)); volumeData[i].reset(); }
            for (unsigned proxy = 0; proxy < Proxies; ++proxy) {
                volumeData[proxy].setUserData(reinterpret_cast<void*>(size_t(4)));
                if (aggregate[proxy]) {
                    volumeData[proxy].setAggregate(proxy);
                    const unsigned localCount = selfCollision && proxy < 3 ? (proxy == 0 ? 2u : proxy == 1 ? 17u : 35u) : childCount;
                    for (unsigned j = 0; j < localCount; ++j) children[proxy].push_back(6 + proxy * MaxChildren + j);
                }
                else { volumeData[proxy].setSingleActor(); children[proxy] = {proxy}; }
                for (int t = 0; t < 2; ++t) {
                    const bool separated = (phase == 2 && t == 0) || (phase != 1 && phase != 2 && t == 1);
                    const float shift = float(proxy / 2) * 100.0f + (proxy % 2 ? (separated ? 20.0f : 0.5f) : 0.0f);
                    boxes[t][proxy].encode(PxBounds3(PxVec3(shift, 0, 0), PxVec3(shift + 3, 3, 3)));
                    for (unsigned j = 0; j < MaxChildren; ++j) {
                        const float x = shift + float(j) * (selfCollision && t == 1 ? 4.0f : 0.02f);
                        boxes[t][6 + proxy * MaxChildren + j].encode(PxBounds3(PxVec3(x, 0, 0), PxVec3(x + 2, 2, 2)));
                    }
                    const unsigned slot = proxy * 2 + t;
                    std::vector<std::pair<PxU32, PxU32>> endpoints;
                    for (unsigned j = 0; j < children[proxy].size(); ++j) {
                        indexData[slot * MaxChildren + j] = children[proxy][j];
                        const auto& box = boxes[t][children[proxy][j]];
                        endpoints.emplace_back(box.mMinMax[0], createHandle(j, true, false));
                        endpoints.emplace_back(box.mMinMax[3], createHandle(j, false, false));
                    }
                    std::sort(endpoints.begin(), endpoints.end());
                    for (unsigned j = 0; j < endpoints.size(); ++j) {
                        projectionData[slot * 2 * MaxChildren + j] = endpoints[j].first;
                        handleData[slot * 2 * MaxChildren + j] = endpoints[j].second;
                        sapData[slot * MaxChildren + getHandle(endpoints[j].second)].mMinMax[isStartProjection(endpoints[j].second) ? 0 : 1] = j;
                        if (isStartProjection(endpoints[j].second)) maskData[slot * MaskWords + j / 32] |= 1u << (j % 32);
                    }
                    aggregateData[proxy].boundIndices[t] = indices.pointer + slot * MaxChildren;
                    aggregateData[proxy].sortedProjections[t] = projections.pointer + slot * 2 * MaxChildren;
                    aggregateData[proxy].sortedHandles[t] = handles.pointer + slot * 2 * MaxChildren;
                    aggregateData[proxy].startMasks[t] = masks.pointer + slot * MaskWords;
                    aggregateData[proxy].sapBox1D[t] = sap.pointer + slot * MaxChildren;
                    aggregateData[proxy].comparisons[t] = comparisons.pointer + slot * MaxChildren;
                }
                aggregateData[proxy].size = aggregateData[proxy].prevSize = PxU32(children[proxy].size());
                aggregateData[proxy].mIndex = proxy;
                if (selfCollision) aggregateData[proxy].filterHint = PxGetAggregateFilterHint(PxAggregateType::eGENERIC, true);
            }
            std::vector<PxU64> expected[2];
            for (unsigned p = 0; p < Pairs; ++p) {
                pairData[p] = {p * 2, p * 2 + 1, phase == 0, phase == 4, 0};
                if (phase == 3 || phase == 4 || phase == 5 || phase == 8) continue;
                for (auto a : children[p * 2]) for (auto b : children[p * 2 + 1]) {
                    const bool now = boxes[0][a].intersects(boxes[0][b]);
                    const bool before = boxes[1][a].intersects(boxes[1][b]);
                    if (now != before) expected[now ? 0 : 1].push_back((PxU64(std::min(a, b)) << 32) | std::max(a, b));
                }
            }
            if (selfCollision) {
                // Current children mutually overlap; old children are separated.
                // 2/17/35 children yield exactly 1 + 136 + 595 = 732 new pairs.
                expected[0].clear(); expected[1].clear();
                for (unsigned proxy = 0; proxy < 3; ++proxy)
                    for (unsigned a = 0; a < children[proxy].size(); ++a)
                        for (unsigned b = a + 1; b < children[proxy].size(); ++b) {
                            const unsigned ia = children[proxy][a], ib = children[proxy][b];
                            if (boxes[0][ia].intersects(boxes[0][ib]) && !boxes[1][ia].intersects(boxes[1][ib]))
                                expected[0].push_back((PxU64(ia) << 32) | ib);
                        }
            }
            PxgBroadPhaseDesc descriptor{}; descriptor.newIntegerBounds = bounds[0].pointer; descriptor.oldIntegerBounds = bounds[1].pointer;
            if (phase >= 8) { descriptor.rigidOwners = owners.pointer; descriptor.rigidOwnerCapacity = invalidOwner ? 1u : Bounds; }
            descriptor.aabbMngr_volumeData = volumes.pointer; descriptor.aabbMngr_removedHandleMap = removed.pointer; descriptor.updateData_groups = groups.pointer;
            PxgAggregateDesc aggregateDescriptor{}; aggregateDescriptor.aggregates = aggs.pointer;
            aggregateDescriptor.numAgregates = selfCollision ? 3u : Proxies;
            aggregateDescriptor.aggPairs = pairs.pointer; aggregateDescriptor.aggPairCount = pairCount.pointer;
            aggregateDescriptor.removeBitmap = bitmap.pointer; aggregateDescriptor.max_agg_pairs = Pairs;
            const unsigned limit = phase == 7 ? 1 : Capacity;
            aggregateDescriptor.max_found_lost_pairs = limit;
            aggregateDescriptor.foundPairReport = reports[0].pointer + 1; aggregateDescriptor.lostPairReport = reports[1].pointer + 1;
            const PxU32 removedBits = phase == 3 ? 0x15u : 0, pairTotal = Pairs;
            PxU32 resultBitmap[Pairs] = {99, 99, 99};
            std::vector<PxgBroadPhasePair> output[2];
            for (int t = 0; t < 2; ++t) {
                output[t].assign(Capacity + 2, PxgBroadPhasePair(0xfedcba98u, 0xffffffffu));
                CUDA(bounds[t].upload(boxes[t], Bounds, stream)); CUDA(reports[t].upload(output[t].data(), output[t].size(), stream));
            }
            CUDA(owners.upload(ownerData, Bounds, stream)); CUDA(volumes.upload(volumeData, Bounds, stream)); CUDA(groups.upload(groupData, Bounds, stream));
            CUDA(sap.upload(sapData, Slots * MaxChildren, stream)); CUDA(comparisons.upload(comparisonData, Slots * MaxChildren, stream));
            CUDA(indices.upload(indexData, Slots * MaxChildren, stream)); CUDA(projections.upload(projectionData, Slots * 2 * MaxChildren, stream));
            CUDA(handles.upload(handleData, Slots * 2 * MaxChildren, stream)); CUDA(masks.upload(maskData, Slots * MaskWords, stream));
            CUDA(aggs.upload(aggregateData, Proxies, stream)); CUDA(pairs.upload(pairData, Pairs, stream));
            CUDA(removed.upload(&removedBits, 1, stream)); CUDA(pairCount.upload(&pairTotal, 1, stream)); CUDA(bitmap.upload(resultBitmap, Pairs, stream));
            CUDA(bp.upload(&descriptor, 1, stream)); CUDA(ad.upload(&aggregateDescriptor, 1, stream));
            if (captured) CUDA(cudaGraphLaunch(executable, stream));
            else DRIVER(cuLaunchKernel(kernel, 2, 1, 1, 32, 2, 1, 0, (CUstream)stream, args, nullptr));
            if (invalidOwner) {
                const auto completion = cudaStreamSynchronize(stream);
                failedContext = true;
                if (completion != cudaErrorLaunchFailure || cudaStreamSynchronize(stream) != cudaErrorLaunchFailure) {
                    std::fprintf(stderr, "%s %s expected sticky719, got %d\n", selfCollision ? "self" : "pair", captured ? "graph" : "direct", int(completion)); return 8;
                }
                // No copies or device reads after failure. Tail reporting may
                // preserve prior bookkeeping; it must never report invalid pairs.
                if (ad.mapped->sharedFoundPairIndex != 0 || ad.mapped->sharedLostPairIndex != 0) return 9;
                for (int t = 0; t < 2; ++t) for (unsigned i = 0; i < Capacity + 2; ++i)
                    if (key(reports[t].mapped[i]) != 0xfedcba98ffffffffull) {
                        std::fprintf(stderr, "invalid-owner report or guard changed: axis %d slot %u\n", t, i); return 10;
                    }
                std::printf("PASS: production %s %s invalid ownership: sticky719, no invalid pair reports, mapped guards, 2 blocks / uneven and idle warps\n", selfCollision ? "doSelfCollision" : "doAggPairCollisions", captured ? "graph" : "direct");
                return 0; // Isolated process owns the failed context until exit.
            }
            CUDA(ad.download(&aggregateDescriptor, 1, stream)); CUDA(bitmap.download(resultBitmap, Pairs, stream)); CUDA(pairs.download(pairData, Pairs, stream));
            for (int t = 0; t < 2; ++t) CUDA(reports[t].download(output[t].data(), output[t].size(), stream));
            CUDA(cudaStreamSynchronize(stream));
            for (int t = 0; t < 2; ++t) {
                const unsigned reported = t ? aggregateDescriptor.sharedLostPairIndex : aggregateDescriptor.sharedFoundPairIndex;
                if (reported != expected[t].size()) { std::fprintf(stderr, "phase %d replay %d axis %d count %u expected %zu\n", phase, replay, t, reported, expected[t].size()); return 3; }
                const unsigned written = std::min(reported, limit);
                std::vector<PxU64> actual;
                for (unsigned i = 0; i < written; ++i) actual.push_back(key(output[t][i + 1]));
                std::sort(actual.begin(), actual.end()); std::sort(expected[t].begin(), expected[t].end());
                if (limit == Capacity && actual != expected[t]) { std::fprintf(stderr, "phase %d axis %d pair mismatch\n", phase, t); return 4; }
                if (limit != Capacity && !std::includes(expected[t].begin(), expected[t].end(), actual.begin(), actual.end())) return 5;
                for (unsigned i = 0; i < output[t].size(); ++i) if (i == 0 || i > written)
                    if (key(output[t][i]) != 0xfedcba98ffffffffull) { std::fprintf(stderr, "report guard changed %u\n", i); return 6; }
            }
            for (unsigned p = 0; !selfCollision && p < Pairs; ++p) {
                const PxU32 expectedRemoved = phase == 2 || phase == 3 ? 1 : 0;
                if (resultBitmap[p] != expectedRemoved || (phase != 4 && pairData[p].isNew)) { std::fprintf(stderr, "phase %d pair %u removal/publication mismatch\n", phase, p); return 7; }
            }
        }
        CUDA(cudaGraphExecDestroy(executable)); CUDA(cudaGraphDestroy(graph));
    }
    CUDA(cudaStreamDestroy(stream)); DRIVER(cuModuleUnload(module)); DRIVER(cuCtxDestroy(context));
    if (selfCollision) { std::puts("PASS: production doSelfCollision, 2/17/35-child uneven workloads, idle warp, two blocks, exact CPU overlap oracle and guarded graph replay"); return 0; }
    std::puts("PASS: production aggregate/aggregate and aggregate/single collisions, found/lost/persistent/removed/dead/filtered pairs, authoritative ownership, bounded reports, graph replay, multi-warp dispatch and 2/17/35-child aggregates");
    return 0;
}

int main(int argc, char** argv) {
    if (argc == 2) {
        if (!std::strcmp(argv[1], "--pairs")) return runCase(false, false, true);
        if (!std::strcmp(argv[1], "--self")) return runCase(true, false, true);
#if defined(PX_CUMETAL_BLOCK_VOTED_TRAPS) && PX_CUMETAL_BLOCK_VOTED_TRAPS
        if (!std::strcmp(argv[1], "--pair-trap-direct")) return runCase(false, true, false);
        if (!std::strcmp(argv[1], "--pair-trap-graph")) return runCase(false, true, true);
        if (!std::strcmp(argv[1], "--self-trap-direct")) return runCase(true, true, false);
        if (!std::strcmp(argv[1], "--self-trap-graph")) return runCase(true, true, true);
#endif
        std::fprintf(stderr, "unknown or disabled mode: %s\n", argv[1]); return 2;
    }
    if (argc != 1) return 2;
    const char* modes[] = {"--pairs", "--self"
#if defined(PX_CUMETAL_BLOCK_VOTED_TRAPS) && PX_CUMETAL_BLOCK_VOTED_TRAPS
        , "--pair-trap-direct", "--pair-trap-graph", "--self-trap-direct", "--self-trap-graph"
#endif
    };
    for (const char* mode : modes) {
        char* args[] = {argv[0], const_cast<char*>(mode), nullptr};
        pid_t child = 0; const int spawned = posix_spawn(&child, argv[0], nullptr, nullptr, args, environ);
        if (spawned) { std::fprintf(stderr, "spawn %s failed: %d\n", mode, spawned); return 11; }
        int status = 0;
        if (waitpid(child, &status, 0) != child || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
            std::fprintf(stderr, "isolated %s failed: status %d\n", mode, status); return 12;
        }
    }
    return 0;
}
