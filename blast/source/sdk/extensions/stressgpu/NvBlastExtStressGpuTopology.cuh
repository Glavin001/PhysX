// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included inside NvBlastExtStressGpu.cu after the shared solver kernels/types.
// Immutable endpoint/CSR storage is shared with the solver. Only connectivity,
// masks, scheduling and derived caches change after a committed fracture.
struct DeviceStressTopologyBatch
{
    const std::uint32_t* mask;
    const std::uint64_t* generation;
    const std::uint32_t* accept;
};
__global__ void setDeviceStressTopologyBatch(DeviceStressTopologyBatch* dst, DeviceStressTopologyBatch src)
{ *dst = src; }
__global__ void beginDeviceStressTopology(const DeviceStressTopologyBatch* batch,
    ExtStressGpuDeviceTopologyStatus* status, cudaGraphConditionalHandle work)
{
    status->error = 0;
    const auto generation = batch->generation ? *batch->generation : 0ull;
    if (batch->accept && !*batch->accept) { cudaGraphSetConditional(work, 0); return; }
    if (status->initialized && generation < status->generation) status->error = 4;
    cudaGraphSetConditional(work, !status->error && (!status->initialized || generation != status->generation));
}
__global__ void validateDeviceStressMask(const DeviceStressTopologyBatch* batch,
    const float* health, unsigned count, ExtStressGpuDeviceTopologyStatus* status)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count || !batch->mask) return; // configuration initializes from resident health
    const unsigned alive = batch->mask[i];
    if (alive > 1) atomicOr(&status->error, 1u);
    if (alive == 1 && health[i] <= 0) atomicOr(&status->error, 2u);
}
__global__ void chooseDeviceStressRebuild(const ExtStressGpuDeviceTopologyStatus* status,
    cudaGraphConditionalHandle rebuild)
{ cudaGraphSetConditional(rebuild, !status->error); }
__global__ void initializeDeviceStressTopology(const DeviceStressTopologyBatch* batch,
    const Inertia* inertia, unsigned* parent, unsigned* identity, unsigned* rootFlags,
    float* health, unsigned n, unsigned m, unsigned* forest)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < max(n, m)) identity[i] = i;
    if (i < n) { parent[i] = inertia[i].linear > 0 ? i : kNoIsland; rootFlags[i] = 0; }
    if (i < m) { if(forest)forest[i]=0; if(batch->mask && !batch->mask[i])health[i]=0; }
}
__device__ unsigned deviceStressRoot(unsigned* parents, unsigned node)
{
    unsigned p = atomicAdd(parents + node, 0u);
    while (p != node) { node = p; p = atomicAdd(parents + node, 0u); }
    return node;
}
__global__ void connectDeviceStressTopology(const unsigned* node0, const unsigned* node1,
    const float* health, const Inertia* inertia, unsigned m, unsigned* parent, unsigned* forest)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= m || health[i] <= 0) return;
    unsigned a = node0[i], b = node1[i];
    // A prescribed support is a boundary, never a bridge between stress islands.
    if (inertia[a].linear <= 0 || inertia[b].linear <= 0) return;
    for (;;) {
        a = deviceStressRoot(parent, a); b = deviceStressRoot(parent, b);
        if (a == b) return;
        const unsigned hi = max(a, b), lo = min(a, b);
        if (atomicCAS(parent + hi, hi, lo) == hi) {
            // The successful union's original bond is a spanning-tree edge.
            // This producer is the only writer of its flag. Consumers execute
            // after the connectivity kernel, so no extra atomic or wait is needed.
            if(forest)forest[i]=1;return;
        }
    }
}
__global__ void flattenDeviceStressTopology(unsigned* parent, unsigned n)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n && atomicAdd(parent + i, 0u) != kNoIsland)
        atomicExch(parent + i, deviceStressRoot(parent, i));
}
__global__ void labelDeviceStressBonds(const unsigned* node0, const unsigned* node1,
    const float* health, const Inertia* inertia, const unsigned* parent,
    unsigned* rootFlags, unsigned* islands, unsigned m)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= m) return;
    const unsigned a = node0[i], b = node1[i];
    unsigned root = kNoIsland;
    if (health[i] > 0) {
        if (inertia[a].linear > 0) root = parent[a];
        else if (inertia[b].linear > 0) root = parent[b];
    }
    islands[i] = root;
    if (root != kNoIsland) atomicExch(rootFlags + root, 1u);
}
__global__ void labelDeviceStressNodes(const unsigned* parent, const unsigned* flags,
    unsigned* islands, unsigned n, ExtStressGpuDeviceTopologyStatus* status)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n) return;
    const unsigned root = parent[i];
    islands[i] = root != kNoIsland && flags[root] ? root : kNoIsland;
    if (flags[i]) atomicAdd(&status->islandCount, 1u);
}
__global__ void flagDeviceStressRows(const unsigned* islands,unsigned count,unsigned* flags)
{
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<count)flags[i]=islands[i]!=kNoIsland;
}
#ifdef PHYSX_RESIDENT_DESTRUCTION
#include "detail/StressInverseTopology.cuh"
#endif
__global__ void beginDeviceStressRebuild(ExtStressGpuDeviceTopologyStatus* status)
{ status->islandCount = 0; }
__global__ void finishDeviceStressRebuild(const DeviceStressTopologyBatch* batch,
    ExtStressGpuDeviceTopologyStatus* status, const unsigned* activeCounts)
{
    status->generation = batch->generation ? *batch->generation : 0ull;
    status->initialized = 1; ++status->rebuilds;
    status->activeBondCount = activeCounts[0]; status->activeNodeCount = activeCounts[1];
}
__global__ void markDeviceStressSolved(ExtStressGpuDeviceTopologyStatus* status)
{ status->solvedGeneration = status->generation; }

// Build exactly the same ascending element order and 1,024-element tiles as
// the host deterministic reduction path, now from GPU-owned island labels.
__global__ void deviceStressReductionRanges(const unsigned* sortedKeys, unsigned count,
    unsigned* begin, unsigned* end)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count || sortedKeys[i] == kNoIsland) return;
    const unsigned root = sortedKeys[i];
    if (!i || sortedKeys[i - 1] != root) begin[root] = i;
    if (i + 1 == count || sortedKeys[i + 1] != root) end[root] = i + 1;
}
__global__ void deviceStressTileCounts(const unsigned* begin, const unsigned* end,
    unsigned* counts, unsigned islands)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i <= islands) counts[i] = i < islands ? (end[i] - begin[i] + kDeterministicTileSize - 1) / kDeterministicTileSize : 0;
}
__global__ void deviceStressTiles(const unsigned* keys, unsigned count, const unsigned* begin,
    const unsigned* end, const unsigned* partialBegin, uint2* tiles)
{
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count || keys[i] == kNoIsland) return;
    const unsigned root = keys[i], offset = i - begin[root];
    if (offset % kDeterministicTileSize == 0)
        tiles[partialBegin[root] + offset / kDeterministicTileSize] = make_uint2(i, min(end[root], i + kDeterministicTileSize));
}

// Workload specialization, not a device/backend fallback. Larger components
// retain cooperative iteration; small components synchronize within one CTA.
constexpr unsigned kResidentComponentMaxNodes = 1024u;
__global__ void flagLargeStressComponents(const unsigned* begin, const unsigned* end,
    unsigned* flags, unsigned count)
{
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<count)flags[i]=(end[i]-begin[i])>kResidentComponentMaxNodes;
}
struct ResidentStressComponentView
{
    const unsigned *ids, *count, *nodes, *begin, *end, *largeIds, *largeCount;
    SolveStatus* results;
    unsigned* workCursor; // reset by solve initialization, never observed by the host
};


#ifdef PHYSX_RESIDENT_DESTRUCTION
#include "detail/StressNativeDirect.cuh"
#endif
#include "detail/StressNativeHierarchy.cuh"
struct DeviceStressTopologyBuffers
{
    unsigned n, m;
    const unsigned *node0, *node1, *nodeBondBegin, *nodeBondRef;
    const Inertia* inertia;
    const Vec4 *offset0, *offset1;
    const float* colScales;
    float *health, *jacobi;
    AngLin *impulses, *rhs, *residual, *projectedDirection;
    unsigned *nodeIsland, *bondIsland, *activeNodes, *activeBonds, *activeCounts, *activeFlags;
    unsigned *islandConverged, *islandSkip;
    void* selectScratch;
    size_t selectBytes;
    IslandReductionOrder* orders;
    const float4* positions=nullptr;
#ifdef PHYSX_RESIDENT_DESTRUCTION
    NativeDirectView direct{};
#endif
};
#ifdef PHYSX_RESIDENT_DESTRUCTION
#include "detail/StressTopologyWarmStart.cuh"
#endif
class DeviceStressTopology
{
    DeviceStressTopologyBuffers b;
#ifdef PHYSX_RESIDENT_DESTRUCTION
    std::unique_ptr<NativeStressHierarchy> nativeHierarchy;
#endif
    unsigned *parent=nullptr, *rootFlags=nullptr, *identity=nullptr, *sortedKeys=nullptr, *forest=nullptr;
    unsigned *rangeBegin=nullptr, *rangeEnd=nullptr, *tileCounts=nullptr;
    unsigned* liveIslands=nullptr;
    unsigned *componentNodes=nullptr, *largeIslands=nullptr, *largeCount=nullptr;
    SolveStatus* componentResults=nullptr;
    unsigned* componentWorkCursor=nullptr;
    void *sortScratch=nullptr, *scanScratch=nullptr;
    size_t sortBytes=0, scanBytes=0;
    DeviceStressTopologyBatch* batch=nullptr;
    ExtStressGpuDeviceTopologyStatus* state=nullptr;
    cudaGraph_t graph=nullptr;
    cudaGraphExec_t exec=nullptr;
    cudaStream_t captureStream=nullptr;

    template<class T> void allocate(T*& p, size_t n)
    { checkCuda(cudaMalloc(&p, sizeof(T)*n), "allocate device stress topology"); }
    template<class... Args> void kernel(cudaGraph_t g, cudaGraphNode_t& prior,
        void* fn, unsigned blocks, unsigned threads, Args... args)
    {
        void* values[]={&args...};
        cudaKernelNodeParams p{}; p.func=fn; p.gridDim=dim3(blocks); p.blockDim=dim3(threads); p.kernelParams=values;
        cudaGraphNode_t next;
        checkCuda(cudaGraphAddKernelNode(&next,g,prior?&prior:nullptr,prior?1:0,&p), "add stress topology kernel");
        prior=next;
    }
    cudaGraph_t conditional(cudaGraph_t g, cudaGraphNode_t& prior, cudaGraphConditionalHandle handle)
    {
        cudaGraphNodeParams p{}; p.type=cudaGraphNodeTypeConditional;
        p.conditional.handle=handle; p.conditional.type=cudaGraphCondTypeIf; p.conditional.size=1;
        cudaGraphNode_t next;
        checkCuda(cudaGraphAddNode(&next,g,prior?&prior:nullptr,nullptr,prior?1:0,&p), "add stress topology condition");
        prior=next; return p.conditional.phGraph_out[0];
    }
    void reductionOrder(unsigned kind)
    {
        auto& o=b.orders[kind]; const unsigned count=kind?b.n:b.m;
        checkCuda(cudaMemsetAsync(rangeBegin,0,sizeof(unsigned)*b.n,captureStream), "clear stress reduction ranges");
        checkCuda(cudaMemsetAsync(rangeEnd,0,sizeof(unsigned)*b.n,captureStream), "clear stress reduction ranges");
        checkCuda(cub::DeviceRadixSort::SortPairs(sortScratch,sortBytes,
            kind?b.nodeIsland:b.bondIsland,sortedKeys,identity,o.deviceOrder,count,0,32,captureStream), "sort stress reduction order");
        deviceStressReductionRanges<<<(count+kBlockSize-1)/kBlockSize,kBlockSize,0,captureStream>>>(sortedKeys,count,rangeBegin,rangeEnd);
        deviceStressTileCounts<<<(b.n+1+kBlockSize-1)/kBlockSize,kBlockSize,0,captureStream>>>(rangeBegin,rangeEnd,tileCounts,b.n);
        checkCuda(cub::DeviceScan::ExclusiveSum(scanScratch,scanBytes,tileCounts,o.devicePartialBegin,b.n+1,captureStream), "scan stress reduction tiles");
        deviceStressTiles<<<(count+kBlockSize-1)/kBlockSize,kBlockSize,0,captureStream>>>(sortedKeys,count,rangeBegin,rangeEnd,o.devicePartialBegin,o.deviceTiles);
    }
    void componentOrder()
    {
        checkCuda(cudaMemsetAsync(rangeBegin,0,sizeof(unsigned)*b.n,captureStream), "clear component range starts");
        checkCuda(cudaMemsetAsync(rangeEnd,0,sizeof(unsigned)*b.n,captureStream), "clear component range ends");
        checkCuda(cub::DeviceRadixSort::SortPairs(sortScratch,sortBytes,b.nodeIsland,
            sortedKeys,identity,componentNodes,b.n,0,32,captureStream), "order resident component nodes");
        deviceStressReductionRanges<<<(b.n+kBlockSize-1)/kBlockSize,kBlockSize,0,captureStream>>>(
            sortedKeys,b.n,rangeBegin,rangeEnd);
        flagLargeStressComponents<<<(b.n+kBlockSize-1)/kBlockSize,kBlockSize,0,captureStream>>>(
            rangeBegin,rangeEnd,b.activeFlags,b.n);
        thrust::counting_iterator<unsigned> indices(0u);
        checkCuda(cub::DeviceSelect::Flagged(b.selectScratch,b.selectBytes,indices,
            b.activeFlags,largeIslands,largeCount,b.n,captureStream), "compact large stress components");
    }
    void build(cudaStream_t ownerStream)
    {
        const unsigned nodeBlocks=(b.n+kBlockSize-1)/kBlockSize, bondBlocks=(b.m+kBlockSize-1)/kBlockSize;
        cudaGraphConditionalHandle work=0, rebuild=0;
        checkCuda(cudaGraphCreate(&graph,0), "create stress topology graph");
        checkCuda(cudaGraphConditionalHandleCreate(&work,graph,0,cudaGraphCondAssignDefault), "create stress topology condition");
        checkCuda(cudaGraphConditionalHandleCreate(&rebuild,graph,0,cudaGraphCondAssignDefault), "create stress rebuild condition");
        cudaGraphNode_t prior=nullptr;
        kernel(graph,prior,(void*)beginDeviceStressTopology,1,1,batch,state,work);
        auto validation=conditional(graph,prior,work); cudaGraphNode_t rootTail=prior;prior=nullptr;
        kernel(validation,prior,(void*)validateDeviceStressMask,bondBlocks,kBlockSize,batch,b.health,b.m,state);
        kernel(validation,prior,(void*)chooseDeviceStressRebuild,1,1,state,rebuild);
        auto body=conditional(validation,prior,rebuild);
#ifdef PHYSX_RESIDENT_DESTRUCTION
        static_assert(sizeof(Inertia)==sizeof(float2) && sizeof(Vec4)==sizeof(float4),"native operator view layout");
        StressHierarchy::Input input{b.n,b.m,b.nodeBondBegin,b.nodeBondRef,b.node0,b.node1,b.nodeIsland,b.health,b.colScales,
            b.positions,reinterpret_cast<const float4*>(b.offset0),reinterpret_cast<const float4*>(b.offset1),reinterpret_cast<const float2*>(b.inertia),&state->generation,nullptr};
        input.partition={componentNodes,liveIslands,rangeBegin,rangeEnd,b.activeCounts+1,&state->islandCount};
        nativeHierarchy.reset(new NativeStressHierarchy(input,forest,state,ownerStream));
        nativeHierarchy->setDirect(b.direct);
#endif
        checkCuda(cudaStreamBeginCaptureToGraph(captureStream,body,nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal), "capture stress topology rebuild");
#ifdef PHYSX_RESIDENT_DESTRUCTION
        // The input operator is immutable except for the validated removal mask.
        // Preserve each unchanged local inverse even if its component splits.
        const auto inverse=nativeHierarchy->view();
        refreshNativeInverseValidity<<<nodeBlocks,kBlockSize,0,captureStream>>>(batch,state,
            b.nodeBondBegin,b.nodeBondRef,b.health,inverse.inverseValid,inverse.inverseGeneration,b.n);
        // Validation already accepted this transaction. Reuse existing flag
        // storage, and consume old component identities before relabeling.
        checkCuda(cudaMemsetAsync(rootFlags,0,sizeof(unsigned)*b.n,captureStream), "clear changed stress component flags");
        markChangedStressComponents<<<bondBlocks,kBlockSize,0,captureStream>>>(batch,state,b.health,b.bondIsland,rootFlags,b.m);
        refreshNativeSettledCertificates<<<nodeBlocks,kBlockSize,0,captureStream>>>(
            inverse.settled,components(),state,batch,rootFlags);
        // Direct factor slots follow the same changed-old-component rule.
        if(b.direct.enabled)refreshNativeDirectSlots<<<nodeBlocks,kBlockSize,0,captureStream>>>(b.direct,components(),state,batch,rootFlags);
        clearChangedStressWarmStart<<<bondBlocks,kBlockSize,0,captureStream>>>(state,b.bondIsland,rootFlags,b.impulses,b.m);
#endif
        beginDeviceStressRebuild<<<1,1,0,captureStream>>>(state);
        initializeDeviceStressTopology<<<std::max(nodeBlocks,bondBlocks),kBlockSize,0,captureStream>>>(batch,b.inertia,parent,identity,rootFlags,b.health,b.n,b.m,forest);
        connectDeviceStressTopology<<<bondBlocks,kBlockSize,0,captureStream>>>(b.node0,b.node1,b.health,b.inertia,b.m,parent,forest);
        flattenDeviceStressTopology<<<nodeBlocks,kBlockSize,0,captureStream>>>(parent,b.n);
        labelDeviceStressBonds<<<bondBlocks,kBlockSize,0,captureStream>>>(b.node0,b.node1,b.health,b.inertia,parent,rootFlags,b.bondIsland,b.m);
        labelDeviceStressNodes<<<nodeBlocks,kBlockSize,0,captureStream>>>(parent,rootFlags,b.nodeIsland,b.n,state);
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if(b.direct.enabled)releaseNativeDirectSlots<<<(b.direct.slots.slotCount+kBlockSize-1)/kBlockSize,kBlockSize,0,captureStream>>>(b.direct,b.nodeIsland,b.n);
#endif
        thrust::counting_iterator<unsigned> indices(0u);
#ifdef PHYSX_RESIDENT_DESTRUCTION
        // Stable minimum-node IDs remain the connectivity truth. Iteration
        // scheduling uses a compact ascending list, built only on topology
        // changes; scalar storage remains indexed by the persistent IDs.
        checkCuda(cub::DeviceSelect::Flagged(b.selectScratch,b.selectBytes,indices,
            rootFlags,liveIslands,&state->islandCount,b.n,captureStream), "compact resident stress components");
        componentOrder();
#endif
        flagDeviceStressRows<<<bondBlocks,kBlockSize,0,captureStream>>>(b.bondIsland,b.m,b.activeFlags);
        checkCuda(cub::DeviceSelect::Flagged(b.selectScratch,b.selectBytes,indices,b.activeFlags,b.activeBonds,b.activeCounts,b.m,captureStream), "compact device stress bonds");
        flagDeviceStressRows<<<nodeBlocks,kBlockSize,0,captureStream>>>(b.nodeIsland,b.n,b.activeFlags);
        checkCuda(cub::DeviceSelect::Flagged(b.selectScratch,b.selectBytes,indices,b.activeFlags,b.activeNodes,b.activeCounts+1,b.n,captureStream), "compact device stress nodes");
        // Reference cold-restarts globally. Native already cold-restarted each
        // affected old component before relabeling. All recurrence/convergence
        // scratch below is recomputed, even for preserved initial guesses.
#ifndef PHYSX_RESIDENT_DESTRUCTION
        checkCuda(cudaMemsetAsync(b.impulses,0,sizeof(AngLin)*b.m,captureStream), "invalidate stress warm start");
#endif
        // Static and newly isolated rows are absent from the active list.
        // Keep their boundary vectors zero rather than retaining old values
        // that a surviving neighbor's matvec could otherwise read.
        checkCuda(cudaMemsetAsync(b.rhs,0,sizeof(AngLin)*b.n,captureStream), "clear stress boundary rhs");
        checkCuda(cudaMemsetAsync(b.residual,0,sizeof(AngLin)*b.n,captureStream), "clear stress boundary residual");
        checkCuda(cudaMemsetAsync(b.projectedDirection,0,sizeof(AngLin)*b.n,captureStream), "clear stress boundary product");
        checkCuda(cudaMemsetAsync(b.islandConverged,0,sizeof(unsigned)*b.n,captureStream), "invalidate stress convergence");
        checkCuda(cudaMemsetAsync(b.islandSkip,0,sizeof(unsigned)*b.n,captureStream), "invalidate stress activity cache");
        if (nodeSpaceEnabled() && jacobiEnabled())
            nodeSpaceBuildJacobi<<<nodeBlocks,kBlockSize,0,captureStream>>>(b.jacobi,b.inertia,b.nodeBondBegin,b.nodeBondRef,b.node0,b.node1,b.offset0,b.offset1,b.health,b.colScales,b.n,b.m);
        if (deterministicReductionsEnabled()) { reductionOrder(0); reductionOrder(1); }
        finishDeviceStressRebuild<<<1,1,0,captureStream>>>(batch,state,b.activeCounts);
        cudaStreamCaptureStatus captureStatus;const cudaGraphNode_t* dependencies=nullptr;size_t dependencyCount=0;
        checkCuda(cudaStreamGetCaptureInfo(captureStream,&captureStatus,nullptr,nullptr,&dependencies,nullptr,&dependencyCount),"get stress topology completion dependency");
        if(dependencyCount!=1)throw std::runtime_error("Native topology requires a single committed completion dependency");
        cudaGraphNode_t completed=dependencies[0];cudaGraph_t captured=nullptr;
        checkCuda(cudaStreamEndCapture(captureStream,&captured), "finish stress topology capture");
#ifdef PHYSX_RESIDENT_DESTRUCTION
        nativeHierarchy->append(body,completed);
        // This status publication is outside the rebuild condition so a prior
        // failed hierarchy cannot appear healthy on an unchanged submission.
        kernel(graph,rootTail,(void*)publishNativeHierarchyStatus,1,1,nativeHierarchy->status(),nativeHierarchy->modeStatus(),state);
#endif
        checkCuda(cudaGraphInstantiate(&exec,graph,0), "instantiate stress topology graph");
    }
public:
    explicit DeviceStressTopology(DeviceStressTopologyBuffers buffers):b(buffers) {}
    ~DeviceStressTopology()
    {
        if (exec) cudaGraphExecDestroy(exec);
        if (graph) cudaGraphDestroy(graph);
#ifdef PHYSX_RESIDENT_DESTRUCTION
        nativeHierarchy.reset();
#endif
        if (captureStream) cudaStreamDestroy(captureStream);
        cudaFree(parent); cudaFree(forest); cudaFree(rootFlags); cudaFree(identity); cudaFree(sortedKeys);
        cudaFree(rangeBegin); cudaFree(rangeEnd); cudaFree(tileCounts); cudaFree(liveIslands);
        cudaFree(sortScratch); cudaFree(scanScratch); cudaFree(batch); cudaFree(state);
        cudaFree(componentNodes); cudaFree(largeIslands); cudaFree(largeCount); cudaFree(componentResults);
        cudaFree(componentWorkCursor);
    }
    void init(cudaStream_t stream)
    {
        allocate(parent,b.n); allocate(rootFlags,b.n); allocate(identity,std::max(b.n,b.m));
        allocate(batch,1); allocate(state,1);
#ifdef PHYSX_RESIDENT_DESTRUCTION
        allocate(forest,b.m); allocate(liveIslands,b.n); allocate(componentNodes,b.n);
        allocate(largeIslands,b.n); allocate(largeCount,1); allocate(componentResults,b.n);
        allocate(componentWorkCursor,1);
        allocate(sortedKeys,b.n); allocate(rangeBegin,b.n); allocate(rangeEnd,b.n);
        checkCuda(cub::DeviceRadixSort::SortPairs(nullptr,sortBytes,b.nodeIsland,sortedKeys,
            identity,componentNodes,b.n), "size resident component sorting");
        checkCuda(cudaMalloc(&sortScratch,sortBytes), "allocate resident component sort scratch");
#endif
        checkCuda(cudaMemsetAsync(state,0,sizeof(*state),stream), "initialize stress topology status");
        checkCuda(cudaMemsetAsync(&state->solvedGeneration,0xff,sizeof(state->solvedGeneration),stream), "invalidate stress solved generation");
        checkCuda(cudaStreamCreateWithFlags(&captureStream,cudaStreamNonBlocking), "create stress topology capture stream");
        if (deterministicReductionsEnabled()) {
            if(componentNodes)throw std::runtime_error("Integrated component solver requires native reductions");
            allocate(sortedKeys,std::max(b.n,b.m)); allocate(rangeBegin,b.n); allocate(rangeEnd,b.n); allocate(tileCounts,b.n+1);
            size_t nodeBytes=0,bondBytes=0;
            checkCuda(cub::DeviceRadixSort::SortPairs(nullptr,nodeBytes,b.nodeIsland,sortedKeys,identity,b.orders[1].deviceOrder,b.n), "size node island sorting");
            checkCuda(cub::DeviceRadixSort::SortPairs(nullptr,bondBytes,b.bondIsland,sortedKeys,identity,b.orders[0].deviceOrder,b.m), "size bond island sorting");
            sortBytes=std::max(nodeBytes,bondBytes); checkCuda(cudaMalloc(&sortScratch,sortBytes), "allocate stress island sort scratch");
            checkCuda(cub::DeviceScan::ExclusiveSum(nullptr,scanBytes,tileCounts,b.orders[0].devicePartialBegin,b.n+1), "size stress tile scan");
            checkCuda(cudaMalloc(&scanScratch,scanBytes), "allocate stress tile scan scratch");
        }
        build(stream); submit({nullptr,nullptr,nullptr},stream);
    }
    void submit(DeviceStressTopologyBatch input,cudaStream_t stream)
    {
        setDeviceStressTopologyBatch<<<1,1,0,stream>>>(batch,input);
        checkCuda(cudaGraphLaunch(exec,stream), "launch device stress topology transaction");
    }
    ExtStressGpuDeviceTopologyStatus* status() const { return state; }
    const unsigned* islandIds() const { return liveIslands; }
#ifdef PHYSX_RESIDENT_DESTRUCTION
    NativeStressCycleView cycleView()const{return nativeHierarchy->view();}
#endif
    ResidentStressComponentView components() const
    { return {liveIslands,&state->islandCount,componentNodes,rangeBegin,rangeEnd,largeIslands,largeCount,componentResults,componentWorkCursor}; }
};
