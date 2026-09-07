// One resident cooperative construction, driven by actual GPU counts.
#pragma once
#include "StressHierarchyKernels.cuh"
#include <cub/block/block_scan.cuh>
#include <cub/block/block_radix_sort.cuh>
#include <cub/block/block_load.cuh>
#include <cub/block/block_store.cuh>
namespace Nv { namespace Blast { namespace StressHierarchy {
struct PackingBuffers {
    unsigned *nodeMap,*nodeSource,*bondMap,*identity,*component,*bondIdentity,*begin,*refs,*counts,*partial,*localBegin;
    std::uint64_t *keys,*sorted;
    CoarseBond* bonds;
};
struct PackingWork {unsigned active,bins[16];};
#include "StressHierarchyPackingPrimitives.cuh"
__device__ __forceinline__ void startPacking(Input input,const Status* parent,Status* output,PackingWork* work){
    work->active=0;
    if(input.accept && !*input.accept)return;
    if(!parent->initialized || parent->error || !sourceCountsValid(input) || parent->generation!=*input.generation){output->error=32;return;}
    if(output->initialized && parent->generation<output->generation){output->error=4;return;}
    if(!output->initialized || output->generation!=parent->generation || output->error){output->error=0;work->active=1;}
}
__global__ void packLevel(Input input,Buffers parent,const Status* source,Status* output,
                          PackingBuffers b,PackingWork* work,unsigned tilesCapacity){
    __shared__ PackingShared shared;const auto grid=cooperative_groups::this_grid();
    const unsigned lane=blockIdx.x*Threads+threadIdx.x,stride=gridDim.x*Threads;
    if(!lane)startPacking(input,source,output,work);
    grid.sync();if(!work->active)return;input=resolvedInput(input);
    const unsigned nodeBlocks=(input.nodes+Threads-1)/Threads,bondBlocks=(input.bonds+Threads-1)/Threads;
    for(unsigned block=blockIdx.x;block<nodeBlocks;block+=gridDim.x)localPackingScan(input,parent,b,shared,block,false);
    grid.sync();if(!blockIdx.x)prefixPackingBlocks(b,shared,nodeBlocks,0);grid.sync();
    for(unsigned i=lane;i<input.nodes;i+=stride){
        b.nodeMap[i]+=b.partial[i/Threads];
        if(parent.leader[i]==i && parent.coarseActive[i]){const unsigned next=b.nodeMap[i];b.nodeSource[next]=i;b.identity[next]=input.identity?input.identity[i]:i;b.component[next]=input.component[i];}
    }
    grid.sync();
    for(unsigned block=blockIdx.x;block<bondBlocks;block+=gridDim.x)localPackingScan(input,parent,b,shared,block,true);
    grid.sync();if(!blockIdx.x)prefixPackingBlocks(b,shared,bondBlocks,1);grid.sync();
    for(unsigned i=lane;i<input.bonds;i+=stride){
        b.bondMap[i]+=b.partial[i/Threads];if(!retainedColumn(parent.coarse[i]))continue;
        const unsigned next=b.bondMap[i];auto edge=parent.coarse[i];std::uint64_t first=~std::uint64_t(0),second=first;
        if(edge.a!=Invalid){edge.a=b.nodeMap[edge.a];first=(std::uint64_t(edge.a)<<32)|(next*2);}
        if(edge.b!=Invalid){edge.b=b.nodeMap[edge.b];second=(std::uint64_t(edge.b)<<32)|(next*2+1);}
        b.bonds[next]=edge;b.bondIdentity[next]=input.bondIdentity?input.bondIdentity[i]:i;
        b.keys[2*next]=first;b.keys[2*next+1]=second;
    }
    const unsigned nodes=b.counts[0],entries=2*b.counts[1],tiles=(entries+SortTile-1)/SortTile;
    for(unsigned i=lane;i<=nodes;i+=stride)b.begin[i]=0;
    for(unsigned i=entries+lane;i<tiles*SortTile;i+=stride)b.keys[i]=~std::uint64_t(0);
    grid.sync();
    // Stable radix passes sort only owner bits. The initial compact bond order
    // already orders the low half of each key. Sentinel owners remain greater
    // than every valid node, including at exact powers of two.
    const unsigned bits=nodes?32-__clz(nodes):0;
    for(unsigned bit=0;bit<bits && tiles;bit+=4){
        for(unsigned block=blockIdx.x;block<tiles;block+=gridDim.x)localRadix(b,shared,block,bit,tilesCapacity);
        grid.sync();prefixRadixBins(b,work,tiles,tilesCapacity);grid.sync();
        if(!blockIdx.x && threadIdx.x<32)prefixRadixTotals(work);
        grid.sync();scatterRadix(b,work,tiles,tilesCapacity,bit);grid.sync();
    }
    for(unsigned i=lane;i<entries;i+=stride){
        const auto key=b.keys[i];const unsigned node=unsigned(key>>32),ref=unsigned(key);
        b.refs[i]=node==Invalid?Invalid:(ref>>1)|((ref&1u)<<31);
        if(node!=Invalid && (i+1==entries || unsigned(b.keys[i+1]>>32)!=node))b.begin[node+1]=i+1;
    }
    grid.sync();
    // Parallel tile prefixes, then only the compact tile totals in one CTA.
    // Work scales with used rows rather than serializing all rows in a block.
    const unsigned rowBlocks=(nodes+1+Threads-1)/Threads;
    for(unsigned block=blockIdx.x;block<rowBlocks;block+=gridDim.x)localRowPrefix(b,shared,block,nodes);
    grid.sync();if(!blockIdx.x)prefixPackingBlocks<true>(b,shared,rowBlocks,Invalid);grid.sync();
    for(unsigned i=lane;i<=nodes;i+=stride)b.begin[i]=max(b.begin[i],b.partial[i/Threads]);
    grid.sync();
    if(!lane){output->generation=source->generation;output->initialized=1;++output->builds;output->aggregates=nodes;}
}
}}}
