// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgDestructionTopology.h"
#include <cuda_runtime.h>
#include <cub/device/device_radix_sort.cuh>
#include <cub/device/device_select.cuh>
#include <cub/device/device_scan.cuh>
#include <algorithm>
#include <cmath>
#include <cstring>
#include <limits>
#include <new>
#include <vector>
#if defined(PX_CUMETAL) && PX_CUMETAL
#include "PxgDestructionFloatPair.cuh"
#endif

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
        clusters[i] = {};
    }
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
    const PxgDestructionTopologyStatus* status) {
    __shared__ double sums[10][BLOCK];
    __shared__ unsigned supports[BLOCK];
    for (unsigned cidx = blockIdx.x; cidx < status->clusterCount; cidx += gridDim.x) {
    const unsigned r = roots[cidx];
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

#if defined(PX_CUMETAL) && PX_CUMETAL
// massProperties above for Apple GPUs (PX_CUMETAL), where binary64 is
// emulated: its accumulation and 256-wide shared-memory tree of ten doubles
// per cluster is a chain of emulated operations, ~250 us per rebuild in
// vibe-land's meteor bench (every fracture rebuilds all clusters, twice per
// split tick). Here each cluster is one warp: the same sums, term for term,
// in float pairs (PxgDestructionFloatPair.cuh, ~48 significand bits), read
// from the asset's chunk properties split into pairs once at creation, then
// a shuffle tree and the same final composition. Only the thirteen outputs
// are rounded to double. Chunk offsets are taken from a nearby chunk, as in
// the double kernel, so no pair holds a world-scale moment. Summation order
// differs from the double tree, which is itself not the host's; results are
// deterministic. CUDA keeps massProperties.
struct ChunkPairs { destructionPair::Pair center[3],mass,inertia[6]; unsigned supported; };
__device__ __forceinline__ destructionPair::Pair shuffleDown(destructionPair::Pair a,unsigned offset) {
    return {__shfl_down_sync(0xffffffffu,a.hi,offset),__shfl_down_sync(0xffffffffu,a.lo,offset)};
}
__global__ void massPropertiesPairs(const PxgDestructionChunk* chunks, const ChunkPairs* pairs,
    const unsigned* order, const unsigned* begins, const unsigned* ends, PxgDestructionCluster* clusters,
    const unsigned* roots, const PxgDestructionTopologyStatus* status) {
    using namespace destructionPair;
    const unsigned lane=threadIdx.x&31u,warp=(blockIdx.x*blockDim.x+threadIdx.x)>>5,warps=(gridDim.x*blockDim.x)>>5;
    for (unsigned cidx=warp; cidx<status->clusterCount; cidx+=warps) {
        const unsigned r=roots[cidx];
        const ChunkPairs reference=pairs[r];
        Pair v[10];for(unsigned k=0;k<10;++k)v[k]=pair(0.0f);
        unsigned support=0;
        for (unsigned j=begins[r]+lane; j<ends[r]; j+=32) {
            const unsigned id=order[j];const ChunkPairs c=pairs[id];
            const Pair x=sub(c.center[0],reference.center[0]),y=sub(c.center[1],reference.center[1]),
                z=sub(c.center[2],reference.center[2]),m=c.mass;
            v[0]=add(v[0],m);v[1]=add(v[1],mul(m,x));v[2]=add(v[2],mul(m,y));v[3]=add(v[3],mul(m,z));
            v[4]=add(v[4],add(c.inertia[0],mul(m,add(mul(y,y),mul(z,z)))));
            v[5]=add(v[5],add(c.inertia[1],mul(m,add(mul(x,x),mul(z,z)))));
            v[6]=add(v[6],add(c.inertia[2],mul(m,add(mul(x,x),mul(y,y)))));
            v[7]=add(v[7],sub(c.inertia[3],mul(mul(m,x),y)));
            v[8]=add(v[8],sub(c.inertia[4],mul(mul(m,x),z)));
            v[9]=add(v[9],sub(c.inertia[5],mul(mul(m,y),z)));
            support|=c.supported;
        }
        for (unsigned offset=16; offset; offset>>=1) {
            for (unsigned k=0;k<10;++k) v[k]=add(v[k],shuffleDown(v[k],offset));
            support|=__shfl_down_sync(0xffffffffu,support,offset);
        }
        if (!lane) {
            PxgDestructionCluster out{};
            const Pair m=v[0];
            out.mass=valueBits(m);
            Pair offset[3];
            for (unsigned k=0;k<3;++k) {
                offset[k]=m.hi>0?div(v[k+1],m):pair(0.0f);
                out.center[k]=valueBits(add(reference.center[k],offset[k]));
            }
            const Pair x=offset[0],y=offset[1],z=offset[2];
            out.inertia[0]=valueBits(sub(v[4],mul(m,add(mul(y,y),mul(z,z)))));
            out.inertia[1]=valueBits(sub(v[5],mul(m,add(mul(x,x),mul(z,z)))));
            out.inertia[2]=valueBits(sub(v[6],mul(m,add(mul(x,x),mul(y,y)))));
            out.inertia[3]=valueBits(add(v[7],mul(mul(m,x),y)));
            out.inertia[4]=valueBits(add(v[8],mul(mul(m,x),z)));
            out.inertia[5]=valueBits(add(v[9],mul(mul(m,y),z)));
            out.chunkCount=ends[r]-begins[r];
            out.supported=support;
            clusters[r]=out;
        }
    }
}
#endif
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

#if defined(PX_CUMETAL) && PX_CUMETAL
// transferClusterMotion above in float pairs (PX_CUMETAL): the rotated COM
// displacement and v + w x r, term for term, with the double inputs split
// into pairs and the three velocities rounded back. Its ~40 dependent
// emulated double operations per cluster took ~60-110 us per rebuild on
// Metal. Values outside the pair range (nonzero below 2^-60 or above 2^60)
// keep the double arithmetic, out of line.
__device__ __noinline__ void transferClusterMotionDouble(unsigned r,unsigned parent,const unsigned* slots,
    const PxgDestructionCluster* clusters,const double* previousCenters,
    const PxgDestructionClusterMotion* previousMotion,PxgDestructionClusterMotion* motion) {
    auto out=previousMotion[parent];
    double d[3];
    for(unsigned k=0;k<3;++k)d[k]=clusters[r].center[k]-previousCenters[3*parent+k];
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
__device__ __forceinline__ unsigned pairOutOfRange(double x) {
    const unsigned long long bits=*reinterpret_cast<const unsigned long long*>(&x);
    const unsigned exponent=unsigned(bits>>52)&0x7ffu;
    return unsigned((bits<<1)!=0ull)&(unsigned(exponent<963u)|unsigned(exponent>1083u));
}
__global__ void transferClusterMotionPairs(const unsigned* roots,const unsigned* slots,
    const PxgDestructionCluster* clusters, const unsigned* previousLabels,
    const unsigned* previousSlots, const double* previousCenters,
    const PxgDestructionClusterMotion* previousMotion,
    PxgDestructionClusterMotion* motion, const PxgDestructionTopologyStatus* status) {
    using namespace destructionPair;
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=status->clusterCount || status->slotError)return;
    const unsigned r=roots[i], parent=previousSlots[previousLabels[r]];
    auto out=previousMotion[parent];
    const double* c=clusters[r].center;const double* p=previousCenters+3*parent;
    const double* q=out.orientation;const double* w=out.angularVelocity;
    unsigned bad=0;
    for(unsigned k=0;k<3;++k)bad|=pairOutOfRange(c[k])|pairOutOfRange(p[k])|pairOutOfRange(w[k])|pairOutOfRange(out.linearVelocity[k]);
    for(unsigned k=0;k<4;++k)bad|=pairOutOfRange(q[k]);
    if(bad){transferClusterMotionDouble(r,parent,slots,clusters,previousCenters,previousMotion,motion);return;}
    const Pair d[3]={sub(pairBits(c[0]),pairBits(p[0])),sub(pairBits(c[1]),pairBits(p[1])),sub(pairBits(c[2]),pairBits(p[2]))};
    const Pair qq[4]={pairBits(q[0]),pairBits(q[1]),pairBits(q[2]),pairBits(q[3])};
    // Rotate the COM displacement from asset space into world space.
    const Pair t[3]={scale(sub(mul(qq[1],d[2]),mul(qq[2],d[1])),2.0f),scale(sub(mul(qq[2],d[0]),mul(qq[0],d[2])),2.0f),
        scale(sub(mul(qq[0],d[1]),mul(qq[1],d[0])),2.0f)};
    const Pair world[3]={sub(add(add(d[0],mul(qq[3],t[0])),mul(qq[1],t[2])),mul(qq[2],t[1])),
        sub(add(add(d[1],mul(qq[3],t[1])),mul(qq[2],t[0])),mul(qq[0],t[2])),
        sub(add(add(d[2],mul(qq[3],t[2])),mul(qq[0],t[1])),mul(qq[1],t[0]))};
    const Pair ww[3]={pairBits(w[0]),pairBits(w[1]),pairBits(w[2])};
    // linear += w x world, as (w_i world_j - w_j world_i) added to the old value.
    out.linearVelocity[0]=valueBits(add(pairBits(out.linearVelocity[0]),sub(mul(ww[1],world[2]),mul(ww[2],world[1]))));
    out.linearVelocity[1]=valueBits(add(pairBits(out.linearVelocity[1]),sub(mul(ww[2],world[0]),mul(ww[0],world[2]))));
    out.linearVelocity[2]=valueBits(add(pairBits(out.linearVelocity[2]),sub(mul(ww[0],world[1]),mul(ww[1],world[0]))));
    motion[slots[r]]=out;
}
#endif
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
#if defined(PX_CUMETAL) && PX_CUMETAL
    ChunkPairs* mChunkPairs = nullptr; // immutable asset data, shared like mChunks
    bool mPairMassProperties = false;  // every chunk value is zero or within 2^+-60
#endif
    unsigned *mActiveChunks = nullptr, *mActiveBonds = nullptr, *mLabels = nullptr;
    unsigned *mIndices = nullptr, *mKeys = nullptr, *mOrder = nullptr;
    unsigned *mBegins = nullptr, *mEnds = nullptr, *mRoots = nullptr, *mRootFlags = nullptr;
    PxgDestructionCluster* mClusters = nullptr;
    unsigned *mClusterSlots=nullptr,*mSlotRoots=nullptr;
    std::uint64_t* mSlotGenerations=nullptr;
    unsigned *mFreeFlags=nullptr,*mFreeRanks=nullptr,*mFreeSlots=nullptr,*mRequestRanks=nullptr;
    PxgDestructionClusterMotion *mMotions = nullptr, *mPreviousMotions = nullptr;
    unsigned *mPreviousLabels = nullptr, *mPreviousSlots = nullptr;
    double* mPreviousCenters = nullptr;
    PxgDestructionTopologyStatus* mStatus = nullptr;
    unsigned mN = 0, mM = 0, mLabelBits = 32;
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
            mIndices, mOrder, mN, 0, int(mLabelBits), mStream) != cudaSuccess) return false;
        ranges<<<grid, BLOCK, 0, mStream>>>(mKeys, mLabels, mActiveChunks, mN, mBegins, mEnds, mRootFlags);
        if (cub::DeviceSelect::Flagged(mTemp, mTempBytes, mIndices, mRootFlags,
            mRoots, &mStatus->clusterCount, mN, mStream) != cudaSuccess) return false;
        finishGeneration<<<1,1,0,mStream>>>(mStatus);
#if defined(PX_CUMETAL) && PX_CUMETAL
        if (mPairMassProperties)
            massPropertiesPairs<<<std::min((mN+BLOCK/32-1)/(BLOCK/32),2560u), BLOCK, 0, mStream>>>(mChunks, mChunkPairs,
                mOrder, mBegins, mEnds, mClusters, mRoots, mStatus);
        else
#endif
        massProperties<<<std::min(mN,2560u), BLOCK, 0, mStream>>>(mChunks, mLabels, mActiveChunks,
            mOrder, mBegins, mEnds, mClusters, mRoots, mStatus);
        retainMotionSlots<<<grid,BLOCK,0,mStream>>>(mSlotRoots,mActiveChunks,mLabels,mFreeFlags,mN);
        requestMotionSlots<<<grid,BLOCK,0,mStream>>>(mActiveChunks,mLabels,mClusterSlots,mSlotRoots,mRootFlags,mN);
        if(cub::DeviceScan::ExclusiveSum(mTemp,mTempBytes,mFreeFlags,mFreeRanks,mN,mStream)!=cudaSuccess
            || cub::DeviceScan::ExclusiveSum(mTemp,mTempBytes,mRootFlags,mRequestRanks,mN,mStream)!=cudaSuccess)return false;
        compactFreeMotionSlots<<<grid,BLOCK,0,mStream>>>(mFreeFlags,mFreeRanks,mFreeSlots,mN);
        allocateMotionSlots<<<grid,BLOCK,0,mStream>>>(mRootFlags,mRequestRanks,mFreeSlots,mFreeRanks,mFreeFlags,
            mClusterSlots,mSlotRoots,mSlotGenerations,mStatus,mN);
        if(transfer)
#if defined(PX_CUMETAL) && PX_CUMETAL
            transferClusterMotionPairs<<<grid,BLOCK,0,mStream>>>(mRoots,mClusterSlots,mClusters,mPreviousLabels,
                mPreviousSlots,mPreviousCenters,mPreviousMotions,mMotions,mStatus);
#else
            transferClusterMotion<<<grid,BLOCK,0,mStream>>>(mRoots,mClusterSlots,mClusters,mPreviousLabels,
                mPreviousSlots,mPreviousCenters,mPreviousMotions,mMotions,mStatus);
#endif
        else
            initializeMotion<<<grid,BLOCK,0,mStream>>>(mMotions,mRoots,mClusterSlots,mStatus);
        return cudaGetLastError() == cudaSuccess && (!signal || cudaEventRecord(mReady, mStream) == cudaSuccess);
    }
public:
    bool init(const PxgDestructionChunk* chunks, unsigned n,
        const PxgDestructionBond* bonds, unsigned m, const Topology* shared = nullptr) {
        mN = n; mM = m;
        if(shared){mChunks=shared->mChunks;mBonds=shared->mBonds;mOwnAssets=false;
#if defined(PX_CUMETAL) && PX_CUMETAL
            mChunkPairs=shared->mChunkPairs;mPairMassProperties=shared->mPairMassProperties;
#endif
        }
        if (cudaStreamCreateWithFlags(&mStream, cudaStreamNonBlocking) != cudaSuccess
            || cudaEventCreateWithFlags(&mReady, cudaEventDisableTiming) != cudaSuccess) return false;
        if ((mOwnAssets && (!alloc(mChunks,n) || !alloc(mBonds,m))) || !alloc(mActiveChunks,n)
            || !alloc(mActiveBonds,m) || !alloc(mLabels,n) || !alloc(mIndices,n)
            || !alloc(mKeys,n) || !alloc(mOrder,n) || !alloc(mBegins,n)
            || !alloc(mEnds,n) || !alloc(mRoots,n) || !alloc(mRootFlags,n) || !alloc(mClusters,n) || !alloc(mStatus,1)
            || !alloc(mMotions,n) || !alloc(mPreviousMotions,n) || !alloc(mPreviousLabels,n)
            || !alloc(mPreviousSlots,n) || !alloc(mPreviousCenters,size_t(n)*3)
            || !alloc(mClusterSlots,n) || !alloc(mSlotRoots,n) || !alloc(mSlotGenerations,n)
            || !alloc(mFreeFlags,n) || !alloc(mFreeRanks,n) || !alloc(mFreeSlots,n) || !alloc(mRequestRanks,n)) return false;
        if (mOwnAssets && (cudaMemcpyAsync(mChunks,chunks,sizeof(*chunks)*n,cudaMemcpyHostToDevice,mStream) != cudaSuccess
            || (m && cudaMemcpyAsync(mBonds,bonds,sizeof(*bonds)*m,cudaMemcpyHostToDevice,mStream) != cudaSuccess))) return false;
#if defined(PX_CUMETAL) && PX_CUMETAL
        if (mOwnAssets) {
            // Split each double into its leading float and the rounded
            // remainder (destructionPair::pair(double), exact on the host).
            const auto split=[](double d){const float hi=float(d);return destructionPair::Pair{hi,float(d-double(hi))};};
            // Pairs are floats: an asset value outside [2^-60, 2^60] keeps the
            // double kernel for the whole topology (none in practice).
            const auto inRange=[](double d){return d==0 || (std::fabs(d)>=0x1p-60 && std::fabs(d)<=0x1p60);};
            mPairMassProperties=true;
            std::vector<ChunkPairs> pairs(n);
            for (unsigned i=0;i<n;++i) {
                mPairMassProperties=mPairMassProperties && inRange(chunks[i].mass);
                for (unsigned k=0;k<3;++k) mPairMassProperties=mPairMassProperties && inRange(chunks[i].center[k]);
                for (unsigned k=0;k<6;++k) mPairMassProperties=mPairMassProperties && inRange(chunks[i].inertia[k]);
                for (unsigned k=0;k<3;++k) pairs[i].center[k]=split(chunks[i].center[k]);
                pairs[i].mass=split(chunks[i].mass);
                for (unsigned k=0;k<6;++k) pairs[i].inertia[k]=split(chunks[i].inertia[k]);
                pairs[i].supported=chunks[i].supported;
            }
            if (!alloc(mChunkPairs,n) || cudaMemcpy(mChunkPairs,pairs.data(),sizeof(ChunkPairs)*n,cudaMemcpyHostToDevice) != cudaSuccess) return false;
        }
#endif
        size_t sortBytes = 0, selectBytes = 0, scanBytes=0;
        // A label is a chunk index below n, or INVALID. With 2^bits-1 >= n the
        // low bits order every label and put INVALID (all ones) last, so a
        // stable sort on them alone gives the full 32-bit order: 12 bits
        // (two digit passes instead of four) for vibe-land's 3258-chunk city.
        mLabelBits=1;
        while (mLabelBits<32 && ((1ull<<mLabelBits)-1)<n) ++mLabelBits;
        if (cub::DeviceRadixSort::SortPairs(nullptr,sortBytes,mLabels,mKeys,mIndices,mOrder,n,0,int(mLabelBits),mStream) != cudaSuccess
            || cub::DeviceSelect::Flagged(nullptr,selectBytes,mIndices,mRootFlags,mRoots,
                &mStatus->clusterCount,n,mStream) != cudaSuccess
            || cub::DeviceScan::ExclusiveSum(nullptr,scanBytes,mFreeFlags,mFreeRanks,n,mStream)!=cudaSuccess) return false;
        mTempBytes = std::max({sortBytes,selectBytes,scanBytes});
        if (cudaMalloc(&mTemp,mTempBytes) != cudaSuccess) return false;
        if(cudaMemsetAsync(mClusterSlots,0xff,n*sizeof(unsigned),mStream)!=cudaSuccess
            || cudaMemsetAsync(mSlotRoots,0xff,n*sizeof(unsigned),mStream)!=cudaSuccess
            || cudaMemsetAsync(mSlotGenerations,0,n*sizeof(std::uint64_t),mStream)!=cudaSuccess)return false;
        initialize<<<(std::max(n,m)+BLOCK-1)/BLOCK,BLOCK,0,mStream>>>(mActiveChunks,n,mActiveBonds,m,mStatus);
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
        if(mOwnAssets){cudaFree(mChunks);cudaFree(mBonds);
#if defined(PX_CUMETAL) && PX_CUMETAL
            cudaFree(mChunkPairs);
#endif
        } cudaFree(mActiveChunks); cudaFree(mActiveBonds);
        cudaFree(mLabels); cudaFree(mIndices); cudaFree(mKeys); cudaFree(mOrder);
        cudaFree(mMotions); cudaFree(mPreviousMotions); cudaFree(mPreviousLabels);
        cudaFree(mClusterSlots);cudaFree(mSlotRoots);cudaFree(mSlotGenerations);
        cudaFree(mFreeFlags);cudaFree(mFreeRanks);cudaFree(mFreeSlots);cudaFree(mRequestRanks);
        cudaFree(mPreviousSlots); cudaFree(mPreviousCenters);
        cudaFree(mBegins); cudaFree(mEnds); cudaFree(mRoots); cudaFree(mRootFlags); cudaFree(mClusters); cudaFree(mStatus); cudaFree(mTemp);
        if (mReady) cudaEventDestroy(mReady);
        if (mStream) cudaStreamDestroy(mStream);
    }
};
#include "PxgDestructionTransaction.cuh"
} // namespace

PxgDestructionTopology* PxgDestructionTopology::create(const PxgDestructionChunk* chunks,
    std::uint32_t n, const PxgDestructionBond* bonds, std::uint32_t m) {
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
    auto* out = new (std::nothrow) Topology;
    if (out && out->init(chunks,n,bonds,m)) return out;
    delete out;
    return nullptr;
}
PxgDestructionTopologyTransaction* PxgDestructionTopologyTransaction::create(
    const PxgDestructionChunk* chunks, std::uint32_t n, const PxgDestructionBond* bonds, std::uint32_t m) {
    auto* accepted=static_cast<Topology*>(PxgDestructionTopology::create(chunks,n,bonds,m));
    if(!accepted)return nullptr;
    auto* transaction=new(std::nothrow) Transaction(accepted);
    if(transaction && transaction->init(chunks,n,bonds,m))return transaction;
    if(transaction)delete transaction;else accepted->release();
    return nullptr;
}
} // namespace physx
