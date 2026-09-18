// Native destruction broad-phase producer: exact descending pair sort/unique.
// Reuse the raw and actor reports after actor/aggregate partitioning. All
// bounds come from device-produced counts; unused capacity is never traversed.
#ifndef PXG_NATIVE_PAIR_CANONICALIZATION_CUH
#define PXG_NATIVE_PAIR_CANONICALIZATION_CUH
#include "PxgBroadPhaseDesc.h"
#include "PxgBroadPhasePairReport.h"
#include <cub/block/block_radix_sort.cuh>
#include <cub/block/block_scan.cuh>
#include <cub/block/block_reduce.cuh>

namespace physx { namespace nativePairs {
using Key = unsigned long long;
constexpr PxU32 Threads = 128, Items = 8, Tile = Threads * Items;
__device__ inline PxU32 count(const PxgBroadPhaseDesc* d, PxU32 axis)
{
    const PxU32 raw = axis ? d->sharedLostPairIndex : d->sharedFoundPairIndex;
    const PxU32 agg = axis ? d->sharedLostAggPairIndex : d->sharedFoundAggPairIndex;
    return raw <= d->max_found_lost_pairs && agg <= raw ? raw - agg : 0;
}
__device__ inline PxgBroadPhasePair* raw(PxgBroadPhaseDesc* d, PxU32 axis)
{ return axis ? d->lostPairReport : d->foundPairReport; }
__device__ inline PxgBroadPhasePair* actor(PxgBroadPhaseDesc* d, PxU32 axis)
{ return axis ? d->lostActorPairReport : d->foundActorPairReport; }
__device__ inline Key key(const PxgBroadPhasePair& p)
{ return (Key(p.mVolA) << 32) | p.mVolB; }
__device__ inline void put(PxgBroadPhasePair* p, Key k)
{ p->mVolA = PxU32(k >> 32); p->mVolB = PxU32(k); }
__device__ inline PxU32* offsets(PxgBroadPhaseDesc* d, PxU32 axis)
{ return d->nativePairTileOffsets + axis * ((PxU64(d->max_found_lost_pairs) + Tile - 1) / Tile); }
__device__ inline bool parity(PxU32 n)
{
    bool odd = false;
    for (PxU64 width = Tile; width < n; width *= 2) odd = !odd;
    return odd;
}
__device__ inline PxgBroadPhasePair* sorted(PxgBroadPhaseDesc* d, PxU32 axis, PxU32 n)
{ return parity(n) ? actor(d, axis) : raw(d, axis); }
__device__ inline PxgBroadPhasePair* compacted(PxgBroadPhaseDesc* d, PxU32 axis, PxU32 n)
{ return parity(n) ? raw(d, axis) : actor(d, axis); }
} }

extern "C" __global__ void nativePairSortTiles(physx::PxgBroadPhaseDesc* d)
{
    using namespace physx; using namespace nativePairs;
    using Sort = cub::BlockRadixSort<Key, Threads, Items>;
    __shared__ typename Sort::TempStorage temp;
    const PxU32 axis = blockIdx.y, n = count(d, axis);
    const PxU32 total = axis ? d->sharedLostPairIndex : d->sharedFoundPairIndex;
    const PxU32 agg = axis ? d->sharedLostAggPairIndex : d->sharedFoundAggPairIndex;
    if (total > d->max_found_lost_pairs || agg > total)
    {
        if (!threadIdx.x && !blockIdx.x) atomicOr(&d->nativePairError, 1u);
        return;
    }
    const auto input = actor(d, axis); const auto output = raw(d, axis);
    for (PxU64 base = PxU64(blockIdx.x) * Tile; base < n; base += PxU64(gridDim.x) * Tile)
    {
        Key keys[Items];
        #pragma unroll
        for (PxU32 j = 0; j < Items; ++j)
        {
            const PxU64 i = base + threadIdx.x * Items + j;
            keys[j] = i < n ? key(input[i]) : 0;
            if (i < n && (input[i].mVolA >= input[i].mVolB || input[i].mVolB == 0xffffffffu))
                atomicOr(&d->nativePairError, 2u);
        }
        Sort(temp).SortDescending(keys);
        #pragma unroll
        for (PxU32 j = 0; j < Items; ++j)
        {
            const PxU64 i = base + threadIdx.x * Items + j;
            if (i < n) put(output + i, keys[j]);
        }
        __syncthreads();
    }
}

extern "C" __global__ void nativePairMerge(physx::PxgBroadPhaseDesc* d, physx::PxU32 width)
{
    using namespace physx; using namespace nativePairs;
    const PxU32 axis = blockIdx.y, n = count(d, axis);
    if (n <= width || d->nativePairError) return;
    // The run width uniquely identifies the ping-pong state, independent of
    // capacity and of the other axis's count. Stable ties go to the left run.
    const bool odd = parity(width);
    const auto input = odd ? actor(d, axis) : raw(d, axis);
    const auto output = odd ? raw(d, axis) : actor(d, axis);
    for (PxU64 i = threadIdx.x + PxU64(blockIdx.x) * blockDim.x; i < n; i += PxU64(blockDim.x) * gridDim.x)
    {
        const PxU64 start = (i / (PxU64(width) * 2)) * (PxU64(width) * 2);
        const PxU64 middle = start + width;
        const bool left = i < middle;
        const PxU64 otherStart = left ? middle : start;
        const PxU64 end = left ? (middle + width < n ? middle + width : n) : middle;
        PxU64 lo = otherStart < n ? otherStart : n, hi = end;
        const Key k = key(input[i]);
        while (lo < hi)
        {
            const PxU64 mid = lo + (hi - lo) / 2;
            const Key other = key(input[mid]);
            if (other > k || (!left && other == k)) lo = mid + 1;
            else hi = mid;
        }
        const PxU64 before = otherStart < n ? lo - otherStart : 0;
        const PxU64 own = i - (left ? start : middle);
        put(output + start + own + before, k);
    }
}

extern "C" __global__ void nativePairUniqueCounts(physx::PxgBroadPhaseDesc* d)
{
    using namespace physx; using namespace nativePairs;
    using Reduce = cub::BlockReduce<PxU32, Threads>;
    __shared__ typename Reduce::TempStorage temp;
    const PxU32 axis = blockIdx.y, n = count(d, axis);
    if (d->nativePairError) return;
    const auto input = sorted(d, axis, n); auto sums = offsets(d, axis);
    for (PxU64 tile = blockIdx.x; tile * Tile < n; tile += gridDim.x)
    {
        PxU32 local = 0;
        #pragma unroll
        for (PxU32 j = 0; j < Items; ++j)
        {
            const PxU64 i = tile * Tile + threadIdx.x * Items + j;
            local += i < n && (!i || key(input[i]) != key(input[i - 1]));
        }
        const PxU32 sum = Reduce(temp).Sum(local);
        if (!threadIdx.x) sums[tile] = sum;
        __syncthreads();
    }
}

extern "C" __global__ void nativePairUniquePrefix(physx::PxgBroadPhaseDesc* d)
{
    using namespace physx; using namespace nativePairs;
    using Scan = cub::BlockScan<PxU32, Threads>;
    __shared__ typename Scan::TempStorage temp;
    const PxU32 axis = blockIdx.y, n = count(d, axis);
    const PxU32 tiles = PxU32((PxU64(n) + Tile - 1) / Tile);
    auto sums = offsets(d, axis); PxU32 carry = 0;
    if (!d->nativePairError)
        for (PxU32 base = 0; base < tiles; base += Threads)
        {
            const PxU32 i = base + threadIdx.x, value = i < tiles ? sums[i] : 0;
            PxU32 prefix, total;
            Scan(temp).ExclusiveSum(value, prefix, total);
            if (i < tiles) sums[i] = prefix + carry;
            carry += total;
            __syncthreads();
        }
    if (!threadIdx.x)
    {
        d->nativePairCounts[axis] = carry;
        d->nativePairReports[axis] = compacted(d, axis, n);
    }
}

extern "C" __global__ void nativePairUniqueScatter(physx::PxgBroadPhaseDesc* d)
{
    using namespace physx; using namespace nativePairs;
    using Scan = cub::BlockScan<PxU32, Threads>;
    __shared__ typename Scan::TempStorage temp;
    const PxU32 axis = blockIdx.y, n = count(d, axis);
    if (d->nativePairError) return;
    const auto input = sorted(d, axis, n); auto output = compacted(d, axis, n);
    const auto sums = offsets(d, axis);
    for (PxU64 tile = blockIdx.x; tile * Tile < n; tile += gridDim.x)
    {
        Key keys[Items]; bool keep[Items]; PxU32 local = 0;
        #pragma unroll
        for (PxU32 j = 0; j < Items; ++j)
        {
            const PxU64 i = tile * Tile + threadIdx.x * Items + j;
            keys[j] = i < n ? key(input[i]) : 0;
            keep[j] = i < n && (!i || keys[j] != key(input[i - 1]));
            local += keep[j];
        }
        PxU32 prefix; Scan(temp).ExclusiveSum(local, prefix);
        PxU32 index = sums[tile] + prefix;
        #pragma unroll
        for (PxU32 j = 0; j < Items; ++j)
            if (keep[j]) put(output + index++, keys[j]);
        __syncthreads();
    }
}
#endif
