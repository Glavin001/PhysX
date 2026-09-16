// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgDestructionTopology.h"
#include <cuda_runtime.h>
#include <vector>
#include <cstdio>
#include <cub/device/device_radix_sort.cuh>
#include <cub/device/device_select.cuh>
#include <cub/device/device_scan.cuh>
#include <algorithm>
#include <cmath>
#include <limits>
#include <new>

namespace physx {
namespace {
constexpr unsigned INVALID = 0xffffffffu;
constexpr unsigned BLOCK = 256;
#include "PxgDestructionSlots.cuh"

__global__ void initialize(unsigned* activeChunks, unsigned n, unsigned* activeBonds,
    unsigned m, PxgDestructionTopologyStatus* status) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) activeChunks[i] = 1;
    if (i < m) activeBonds[i] = 1;
    if (!i) *status = {0, 0, 0, 0};
}

__global__ void startBatch(PxgDestructionTopologyStatus* status) {
    status->invalidEdit = 0;
    status->changed = 0;
    status->clusterCount = 0;
    status->slotError = 0;
}

__global__ void validate(const PxgDestructionEdit* edits, unsigned count,
    unsigned n, unsigned m, PxgDestructionTopologyStatus* status) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count) return;
    const auto edit = edits[i];
    const bool valid = (edit.kind == PxgDestructionEditKind::BreakBond && edit.index < m)
        || (edit.kind == PxgDestructionEditKind::DestroyChunk && edit.index < n);
    if (!valid) atomicExch(&status->invalidEdit, 1u);
}

__global__ void editGraph(const PxgDestructionEdit* edits, unsigned count,
    unsigned* activeChunks, unsigned* activeBonds, PxgDestructionTopologyStatus* status) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= count || status->invalidEdit) return;
    const auto edit = edits[i];
    unsigned* slot = edit.kind == PxgDestructionEditKind::BreakBond
        ? activeBonds + edit.index : activeChunks + edit.index;
    if (atomicExch(slot, 0u)) atomicExch(&status->changed, 1u);
}

__global__ void resetLabels(const unsigned* alive, unsigned* labels, unsigned* indices,
    PxgDestructionCluster* clusters, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        labels[i] = alive[i] ? i : INVALID;
        indices[i] = i;
        // Cluster records persist: a cluster whose member set did not change
        // keeps its root (the minimum member index) and its record.
        (void)clusters;
    }
}
// Roots whose member set changed since the previous labels: every chunk whose
// label differs marks both its old and its new root.
__global__ void markChangedClusters(const unsigned* labels, const unsigned* previous, unsigned* changed, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n) return;
    const unsigned now = labels[i], was = previous[i];
    if (now == was) return;
    if (now != INVALID) changed[now] = 1u;
    if (was != INVALID) changed[was] = 1u;
}

__device__ unsigned root(unsigned* labels, unsigned i) {
    unsigned p = atomicAdd(labels + i, 0u);
    while (p != i) { i = p; p = atomicAdd(labels + i, 0u); }
    return i;
}

// Every successful union points a larger root at a smaller root. CAS retries
// resolve concurrent unions without cycles; labels are independent of edge order.
__global__ void connect(const PxgDestructionBond* bonds, unsigned m, unsigned* activeBonds,
    const unsigned* alive, unsigned* labels) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= m || !activeBonds[i]) return;
    const auto b = bonds[i];
    if (!alive[b.chunk0] || !alive[b.chunk1]) { activeBonds[i] = 0; return; }
    unsigned a = b.chunk0, c = b.chunk1;
    for (;;) {
        a = root(labels, a); c = root(labels, c);
        if (a == c) return;
        const unsigned hi = max(a, c), lo = min(a, c);
        if (atomicCAS(labels + hi, hi, lo) == hi) return;
    }
}

__global__ void flatten(unsigned* labels, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n && atomicAdd(labels + i, 0u) != INVALID) {
        const unsigned r = root(labels, i);
        atomicExch(labels + i, r);
    }
}

__global__ void ranges(const unsigned* keys, const unsigned* labels, const unsigned* alive,
    unsigned n, unsigned* begins, unsigned* ends, unsigned* rootFlags) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n) return;
    rootFlags[i] = alive[i] && labels[i] == i;
    if (keys[i] == INVALID) return;
    const unsigned r = keys[i];
    if (!i || keys[i - 1] != r) begins[r] = i;
    if (i + 1 == n || keys[i + 1] != r) ends[r] = i + 1;
}

__global__ void finishGeneration(PxgDestructionTopologyStatus* status) {
    if (status->changed) ++status->generation;
}

__global__ void massProperties(const PxgDestructionChunk* chunks, const unsigned* labels,
    const unsigned* alive, const unsigned* order, const unsigned* begins,
    const unsigned* ends, PxgDestructionCluster* clusters, const unsigned* roots,
    const PxgDestructionTopologyStatus* status, const unsigned* changed) {
    __shared__ double sums[10][BLOCK];
    __shared__ unsigned supports[BLOCK];
    for (unsigned cidx = blockIdx.x; cidx < status->clusterCount; cidx += gridDim.x) {
    const unsigned r = roots[cidx];
    // Incremental: an unchanged member set has the same root and the same
    // record (chunk properties are immutable), so it is not recomputed.
    if (changed && !changed[r]) continue;
    double v[10] = {};
    unsigned support = 0;
    for (unsigned j = begins[r] + threadIdx.x; j < ends[r]; j += BLOCK) {
        const auto c = chunks[order[j]];
        // Accumulate around a nearby immutable chunk, not the world origin.
        // Subtracting two O(worldPosition^2) moments loses small-body inertia.
        const double x = c.center[0] - chunks[r].center[0];
        const double y = c.center[1] - chunks[r].center[1];
        const double z = c.center[2] - chunks[r].center[2], m = c.mass;
        v[0] += m; v[1] += m*x; v[2] += m*y; v[3] += m*z;
        v[4] += c.inertia[0] + m*(y*y + z*z);
        v[5] += c.inertia[1] + m*(x*x + z*z);
        v[6] += c.inertia[2] + m*(x*x + y*y);
        v[7] += c.inertia[3] - m*x*y;
        v[8] += c.inertia[4] - m*x*z;
        v[9] += c.inertia[5] - m*y*z;
        support |= c.supported;
    }
    for (unsigned k = 0; k < 10; ++k) sums[k][threadIdx.x] = v[k];
    supports[threadIdx.x] = support;
    __syncthreads();
    for (unsigned stride = BLOCK/2; stride; stride >>= 1) {
        if (threadIdx.x < stride) {
            for (unsigned k = 0; k < 10; ++k)
                sums[k][threadIdx.x] += sums[k][threadIdx.x + stride];
            supports[threadIdx.x] |= supports[threadIdx.x + stride];
        }
        __syncthreads();
    }
    if (!threadIdx.x) {
        PxgDestructionCluster out{};
        const double m = sums[0][0];
        out.mass = m;
        double offset[3] = {};
        for (unsigned k = 0; k < 3; ++k) {
            offset[k] = m > 0 ? sums[k+1][0]/m : 0;
            out.center[k] = chunks[r].center[k] + offset[k];
        }
        const double x = offset[0], y = offset[1], z = offset[2];
        out.inertia[0] = sums[4][0] - m*(y*y+z*z);
        out.inertia[1] = sums[5][0] - m*(x*x+z*z);
        out.inertia[2] = sums[6][0] - m*(x*x+y*y);
        out.inertia[3] = sums[7][0] + m*x*y;
        out.inertia[4] = sums[8][0] + m*x*z;
        out.inertia[5] = sums[9][0] + m*y*z;
        out.chunkCount = ends[r] - begins[r];
        out.supported = supports[0];
        clusters[r] = out;
    }
    __syncthreads();
    }
}

__global__ void initializeMotion(PxgDestructionClusterMotion* motions,
    const unsigned* roots,const unsigned* slots,const PxgDestructionTopologyStatus* status) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<status->clusterCount && !status->slotError) {
        PxgDestructionClusterMotion motion{};
        motion.orientation[3]=1;
        motions[slots[roots[i]]]=motion;
    }
}

__global__ void captureClusterMotion(const unsigned* roots,const unsigned* slots,
    const PxgDestructionCluster* clusters, const PxgDestructionClusterMotion* motion,
    PxgDestructionClusterMotion* previousMotion, double* previousCenters,
    unsigned* previousSlots, const PxgDestructionTopologyStatus* status,
    const PxgDestructionClusterMotion* const* sourceMotion = nullptr) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<status->clusterCount) {
        const unsigned r=roots[i],slot=slots[r];
        previousSlots[r]=slot;
        previousMotion[slot]=sourceMotion && *sourceMotion ? (*sourceMotion)[i] : motion[slot];
        for(unsigned k=0;k<3;++k)previousCenters[3*slot+k]=clusters[r].center[k];
    }
}

__global__ void transferClusterMotion(const unsigned* roots,const unsigned* slots,
    const PxgDestructionCluster* clusters, const unsigned* previousLabels,
    const unsigned* previousSlots, const double* previousCenters,
    const PxgDestructionClusterMotion* previousMotion,
    PxgDestructionClusterMotion* motion, const PxgDestructionTopologyStatus* status) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=status->clusterCount || status->slotError)return;
    const unsigned r=roots[i], parent=previousSlots[previousLabels[r]];
    auto out=previousMotion[parent];
    double d[3];
    for(unsigned k=0;k<3;++k)d[k]=clusters[r].center[k]-previousCenters[3*parent+k];
    // Rotate the COM displacement from asset space into world space.
    const auto* q=out.orientation;
    const double t[3]={2*(q[1]*d[2]-q[2]*d[1]),2*(q[2]*d[0]-q[0]*d[2]),2*(q[0]*d[1]-q[1]*d[0])};
    const double world[3]={d[0]+q[3]*t[0]+q[1]*t[2]-q[2]*t[1],
        d[1]+q[3]*t[1]+q[2]*t[0]-q[0]*t[2],d[2]+q[3]*t[2]+q[0]*t[1]-q[1]*t[0]};
    const auto* w=out.angularVelocity;
    out.linearVelocity[0]+=w[1]*world[2]-w[2]*world[1];
    out.linearVelocity[1]+=w[2]*world[0]-w[0]*world[2];
    out.linearVelocity[2]+=w[0]*world[1]-w[1]*world[0];
    motion[slots[r]]=out;
}

__global__ void emptyBatch(PxgDestructionTopologyStatus* status) {
    status->invalidEdit=0;
    status->changed=0;
}

class Transaction;
class Topology final : public PxgDestructionTopology {
    friend class Transaction;
    bool mOwnAssets = true;
    PxgDestructionChunk* mChunks = nullptr;
    PxgDestructionBond* mBonds = nullptr;
    unsigned *mActiveChunks = nullptr, *mActiveBonds = nullptr, *mLabels = nullptr;
    unsigned *mIndices = nullptr, *mKeys = nullptr, *mOrder = nullptr;
    unsigned *mBegins = nullptr, *mEnds = nullptr, *mRoots = nullptr, *mRootFlags = nullptr;
    PxgDestructionCluster* mClusters = nullptr;
    unsigned* mMassChanged = nullptr; // per root: member set changed since the previous labels
    unsigned *mClusterSlots=nullptr,*mSlotRoots=nullptr;
    std::uint64_t* mSlotGenerations=nullptr;
    unsigned *mFreeFlags=nullptr,*mFreeRanks=nullptr,*mFreeSlots=nullptr,*mRequestRanks=nullptr;
    PxgDestructionClusterMotion *mMotions = nullptr, *mPreviousMotions = nullptr;
    unsigned *mPreviousLabels = nullptr, *mPreviousSlots = nullptr;
    double* mPreviousCenters = nullptr;
    PxgDestructionTopologyStatus* mStatus = nullptr;
    unsigned mN = 0, mM = 0;
    void* mTemp = nullptr;
    size_t mTempBytes = 0;
    cudaStream_t mStream = nullptr;
    cudaEvent_t mReady = nullptr;

    template<class T> bool alloc(T*& ptr, size_t count) {
        return !count || cudaMalloc(reinterpret_cast<void**>(&ptr), sizeof(T)*count) == cudaSuccess;
    }
    bool rebuild(bool transfer = false, bool signal = true) {
        const unsigned grid = (mN + BLOCK - 1)/BLOCK;
        resetLabels<<<grid, BLOCK, 0, mStream>>>(mActiveChunks, mLabels, mIndices, mClusters, mN);
        if (mM) connect<<<(mM+BLOCK-1)/BLOCK, BLOCK, 0, mStream>>>(mBonds, mM, mActiveBonds, mActiveChunks, mLabels);
        flatten<<<grid, BLOCK, 0, mStream>>>(mLabels, mN);
        if (cub::DeviceRadixSort::SortPairs(mTemp, mTempBytes, mLabels, mKeys,
            mIndices, mOrder, mN, 0, 32, mStream) != cudaSuccess) return false;
        ranges<<<grid, BLOCK, 0, mStream>>>(mKeys, mLabels, mActiveChunks, mN, mBegins, mEnds, mRootFlags);
        if (cub::DeviceSelect::Flagged(mTemp, mTempBytes, mIndices, mRootFlags,
            mRoots, &mStatus->clusterCount, mN, mStream) != cudaSuccess) return false;
        finishGeneration<<<1,1,0,mStream>>>(mStatus);
        const unsigned* changed = nullptr;
        if (transfer && mMassChanged) {
            // mPreviousLabels holds the labels of the previous generation (apply()).
            if (cudaMemsetAsync(mMassChanged, 0, sizeof(unsigned)*mN, mStream) != cudaSuccess) return false;
            markChangedClusters<<<grid, BLOCK, 0, mStream>>>(mLabels, mPreviousLabels, mMassChanged, mN);
            changed = mMassChanged;
        }
        massProperties<<<std::min(mN,2560u), BLOCK, 0, mStream>>>(mChunks, mLabels, mActiveChunks,
            mOrder, mBegins, mEnds, mClusters, mRoots, mStatus, changed);
        retainMotionSlots<<<grid,BLOCK,0,mStream>>>(mSlotRoots,mActiveChunks,mLabels,mFreeFlags,mN);
        requestMotionSlots<<<grid,BLOCK,0,mStream>>>(mActiveChunks,mLabels,mClusterSlots,mSlotRoots,mRootFlags,mN);
        if(cub::DeviceScan::ExclusiveSum(mTemp,mTempBytes,mFreeFlags,mFreeRanks,mN,mStream)!=cudaSuccess
            || cub::DeviceScan::ExclusiveSum(mTemp,mTempBytes,mRootFlags,mRequestRanks,mN,mStream)!=cudaSuccess)return false;
        compactFreeMotionSlots<<<grid,BLOCK,0,mStream>>>(mFreeFlags,mFreeRanks,mFreeSlots,mN);
        allocateMotionSlots<<<grid,BLOCK,0,mStream>>>(mRootFlags,mRequestRanks,mFreeSlots,mFreeRanks,mFreeFlags,
            mClusterSlots,mSlotRoots,mSlotGenerations,mStatus,mN);
        if(transfer)
            transferClusterMotion<<<grid,BLOCK,0,mStream>>>(mRoots,mClusterSlots,mClusters,mPreviousLabels,
                mPreviousSlots,mPreviousCenters,mPreviousMotions,mMotions,mStatus);
        else
            initializeMotion<<<grid,BLOCK,0,mStream>>>(mMotions,mRoots,mClusterSlots,mStatus);
        return cudaGetLastError() == cudaSuccess && (!signal || cudaEventRecord(mReady, mStream) == cudaSuccess);
    }
public:
    bool init(const PxgDestructionChunk* chunks, unsigned n,
        const PxgDestructionBond* bonds, unsigned m, const Topology* shared = nullptr, const unsigned* initialActiveBonds = nullptr) {
        mN = n; mM = m;
        if(shared){mChunks=shared->mChunks;mBonds=shared->mBonds;mOwnAssets=false;}
        if (cudaStreamCreateWithFlags(&mStream, cudaStreamNonBlocking) != cudaSuccess
            || cudaEventCreateWithFlags(&mReady, cudaEventDisableTiming) != cudaSuccess) return false;
        if ((mOwnAssets && (!alloc(mChunks,n) || !alloc(mBonds,m))) || !alloc(mActiveChunks,n)
            || !alloc(mActiveBonds,m) || !alloc(mLabels,n) || !alloc(mIndices,n)
            || !alloc(mKeys,n) || !alloc(mOrder,n) || !alloc(mBegins,n)
            || !alloc(mEnds,n) || !alloc(mRoots,n) || !alloc(mRootFlags,n) || !alloc(mClusters,n) || !alloc(mStatus,1)
            || !alloc(mMassChanged,n)
            || !alloc(mMotions,n) || !alloc(mPreviousMotions,n) || !alloc(mPreviousLabels,n)
            || !alloc(mPreviousSlots,n) || !alloc(mPreviousCenters,size_t(n)*3)
            || !alloc(mClusterSlots,n) || !alloc(mSlotRoots,n) || !alloc(mSlotGenerations,n)
            || !alloc(mFreeFlags,n) || !alloc(mFreeRanks,n) || !alloc(mFreeSlots,n) || !alloc(mRequestRanks,n)) return false;
        if (mOwnAssets && (cudaMemcpyAsync(mChunks,chunks,sizeof(*chunks)*n,cudaMemcpyHostToDevice,mStream) != cudaSuccess
            || (m && cudaMemcpyAsync(mBonds,bonds,sizeof(*bonds)*m,cudaMemcpyHostToDevice,mStream) != cudaSuccess))) return false;
        size_t sortBytes = 0, selectBytes = 0, scanBytes=0;
        if (cub::DeviceRadixSort::SortPairs(nullptr,sortBytes,mLabels,mKeys,mIndices,mOrder,n,0,32,mStream) != cudaSuccess
            || cub::DeviceSelect::Flagged(nullptr,selectBytes,mIndices,mRootFlags,mRoots,
                &mStatus->clusterCount,n,mStream) != cudaSuccess
            || cub::DeviceScan::ExclusiveSum(nullptr,scanBytes,mFreeFlags,mFreeRanks,n,mStream)!=cudaSuccess) return false;
        mTempBytes = std::max({sortBytes,selectBytes,scanBytes});
        if (cudaMalloc(&mTemp,mTempBytes) != cudaSuccess) return false;
        if(cudaMemsetAsync(mClusterSlots,0xff,n*sizeof(unsigned),mStream)!=cudaSuccess
            || cudaMemsetAsync(mSlotRoots,0xff,n*sizeof(unsigned),mStream)!=cudaSuccess
            || cudaMemsetAsync(mSlotGenerations,0,n*sizeof(std::uint64_t),mStream)!=cudaSuccess)return false;
        initialize<<<(std::max(n,m)+BLOCK-1)/BLOCK,BLOCK,0,mStream>>>(mActiveChunks,n,mActiveBonds,m,mStatus);
        if(initialActiveBonds && m && cudaMemcpyAsync(mActiveBonds,initialActiveBonds,
            sizeof(unsigned)*m,cudaMemcpyHostToDevice,mStream)!=cudaSuccess)return false;
        return rebuild() && cudaStreamSynchronize(mStream) == cudaSuccess;
    }
    bool apply(const PxgDestructionEdit* edits, unsigned count, void* ready, void* done) override {
        if ((count && !edits) || count > unsigned(std::numeric_limits<int>::max())) return false;
        if ((ready && cudaStreamWaitEvent(mStream, static_cast<cudaEvent_t>(ready), 0) != cudaSuccess)
            || (done && cudaStreamWaitEvent(mStream, static_cast<cudaEvent_t>(done), 0) != cudaSuccess)) return false;
        if(!count) {
            emptyBatch<<<1,1,0,mStream>>>(mStatus);
            return cudaGetLastError()==cudaSuccess && cudaEventRecord(mReady,mStream)==cudaSuccess;
        }
        captureClusterMotion<<<(mN+BLOCK-1)/BLOCK,BLOCK,0,mStream>>>(mRoots,mClusterSlots,mClusters,
            mMotions,mPreviousMotions,mPreviousCenters,mPreviousSlots,mStatus);
        if(cudaMemcpyAsync(mPreviousLabels,mLabels,sizeof(unsigned)*mN,
            cudaMemcpyDeviceToDevice,mStream)!=cudaSuccess)return false;
        startBatch<<<1,1,0,mStream>>>(mStatus);
        if (count) {
            validate<<<(count+BLOCK-1)/BLOCK,BLOCK,0,mStream>>>(edits,count,mN,mM,mStatus);
            editGraph<<<(count+BLOCK-1)/BLOCK,BLOCK,0,mStream>>>(edits,count,mActiveChunks,mActiveBonds,mStatus);
        }
        return rebuild(true);
    }
    PxgDestructionTopologyView view() const override {
        return {mChunks,mBonds,mActiveBonds,mActiveChunks,mLabels,mOrder,mRoots,
                mClusters,mStatus,mMotions,mClusterSlots,mSlotRoots,mSlotGenerations,mN,mN,mM,mReady};
    }
    void release() override { delete this; }
    ~Topology() override {
        if (mStream) cudaStreamSynchronize(mStream);
        if(mOwnAssets){cudaFree(mChunks);cudaFree(mBonds);} cudaFree(mActiveChunks); cudaFree(mActiveBonds);
        cudaFree(mLabels); cudaFree(mIndices); cudaFree(mKeys); cudaFree(mOrder);
        cudaFree(mMotions); cudaFree(mPreviousMotions); cudaFree(mPreviousLabels);
        cudaFree(mClusterSlots);cudaFree(mSlotRoots);cudaFree(mSlotGenerations);
        cudaFree(mFreeFlags);cudaFree(mFreeRanks);cudaFree(mFreeSlots);cudaFree(mRequestRanks);
        cudaFree(mPreviousSlots); cudaFree(mPreviousCenters);
        cudaFree(mBegins); cudaFree(mEnds); cudaFree(mRoots); cudaFree(mRootFlags); cudaFree(mClusters); cudaFree(mMassChanged); cudaFree(mStatus); cudaFree(mTemp);
        if (mReady) cudaEventDestroy(mReady);
        if (mStream) cudaStreamDestroy(mStream);
    }
};
#include "PxgDestructionTransaction.cuh"
} // namespace

PxgDestructionTopology* PxgDestructionTopology::create(const PxgDestructionChunk* chunks,
    std::uint32_t n, const PxgDestructionBond* bonds, std::uint32_t m, const std::uint32_t* initialActiveBonds) {
    if (!chunks || !n || n > unsigned(std::numeric_limits<int>::max())
        || m > unsigned(std::numeric_limits<int>::max()) || (m && !bonds)) return nullptr;
    for (unsigned i=0;i<n;++i) {
        if (!std::isfinite(chunks[i].mass) || chunks[i].mass < 0
            || (!chunks[i].mass && !chunks[i].supported)) return nullptr;
        for (double x : chunks[i].center) if (!std::isfinite(x)) return nullptr;
        for (double x : chunks[i].inertia) if (!std::isfinite(x)) return nullptr;
    }
    for (unsigned i=0;i<m;++i)
        if (bonds[i].chunk0 >= n || bonds[i].chunk1 >= n) return nullptr;
    if(initialActiveBonds)for(unsigned i=0;i<m;++i)if(initialActiveBonds[i]>1)return nullptr;
    auto* out = new (std::nothrow) Topology;
    if (out && out->init(chunks,n,bonds,m,nullptr,initialActiveBonds)) return out;
    delete out;
    return nullptr;
}
PxgDestructionTopologyTransaction* PxgDestructionTopologyTransaction::create(
    const PxgDestructionChunk* chunks, std::uint32_t n, const PxgDestructionBond* bonds, std::uint32_t m, const std::uint32_t* initialActiveBonds) {
    auto* accepted=static_cast<Topology*>(PxgDestructionTopology::create(chunks,n,bonds,m,initialActiveBonds));
    if(!accepted)return nullptr;
    auto* transaction=new(std::nothrow) Transaction(accepted);
    if(transaction && transaction->init(chunks,n,bonds,m))return transaction;
    if(transaction)delete transaction;else accepted->release();
    return nullptr;
}
} // namespace physx
