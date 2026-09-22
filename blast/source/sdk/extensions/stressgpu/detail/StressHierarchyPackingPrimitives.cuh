// Private cooperative scan/radix primitives. All partials are producer-owned.
constexpr unsigned SortItems=4,SortTile=Threads*SortItems,RadixBins=16;
using PackingScan=cub::BlockScan<unsigned,Threads>;
using PackingSort=cub::BlockRadixSort<std::uint64_t,Threads,SortItems>;
using PackingLoad=cub::BlockLoad<std::uint64_t,Threads,SortItems,cub::BLOCK_LOAD_WARP_TRANSPOSE>;
using PackingStore=cub::BlockStore<std::uint64_t,Threads,SortItems,cub::BLOCK_STORE_WARP_TRANSPOSE>;
struct PackingShared {
    union {typename PackingScan::TempStorage scan;typename PackingSort::TempStorage sort;
           typename PackingLoad::TempStorage load;typename PackingStore::TempStorage store;} temp;
    unsigned carry,begin[RadixBins],end[RadixBins];
};
template<bool Retire>
__device__ __forceinline__ void localPackingScan(const Input& input,Buffers parent,PackingBuffers b,
                                                PackingShared& shared,unsigned block,bool bonds,TerminalRetirement retired){
    const unsigned i=block*Threads+threadIdx.x,count=bonds?input.bonds:*input.partition.nodeCount;
    unsigned flag=0;if(i<count){const unsigned node=(!bonds && input.partition.nodes)?input.partition.nodes[i]:i;
        flag=bonds?packingBondRetained<Retire>(input,parent,i,retired):packingRootRetained<Retire>(input,parent,node,retired);}
    unsigned prefix,total;PackingScan(shared.temp.scan).ExclusiveSum(flag,prefix,total);
    if(i<count)(bonds?b.bondMap:b.orderedPrefix)[i]=prefix;
    if(!threadIdx.x)b.partial[block]=total;
    __syncthreads();
}
template<bool Maximum=false>
__device__ __forceinline__ void prefixPackingBlocks(PackingBuffers b,PackingShared& shared,unsigned blocks,unsigned kind){
    if(!threadIdx.x)shared.carry=0;__syncthreads();
    for(unsigned base=0;base<blocks;base+=Threads){
        const unsigned i=base+threadIdx.x,value=i<blocks?b.partial[i]:0;unsigned prefix,total;
        if constexpr(Maximum)PackingScan(shared.temp.scan).ExclusiveScan(value,prefix,0u,cub::Max(),total);
        else PackingScan(shared.temp.scan).ExclusiveSum(value,prefix,total);
        if(i<blocks)b.partial[i]=Maximum?max(shared.carry,prefix):shared.carry+prefix;
        __syncthreads();if(!threadIdx.x)shared.carry=Maximum?max(shared.carry,total):shared.carry+total;__syncthreads();
    }
    if(!threadIdx.x && kind<3)b.counts[kind]=shared.carry;
}
__device__ __forceinline__ void localRowPrefix(PackingBuffers b,PackingShared& shared,unsigned block,unsigned nodes){
    const unsigned i=block*Threads+threadIdx.x,value=i<=nodes?b.begin[i]:0;unsigned prefix,total;
    PackingScan(shared.temp.scan).InclusiveScan(value,prefix,cub::Max(),total);
    if(i<=nodes)b.begin[i]=prefix;if(!threadIdx.x)b.partial[block]=total;__syncthreads();
}
__device__ __forceinline__ void localRadix(PackingBuffers b,PackingShared& shared,unsigned block,unsigned bit,unsigned tilesCapacity){
    const unsigned base=block*SortTile;std::uint64_t keys[SortItems];
    PackingLoad(shared.temp.load).Load(b.keys+base,keys);__syncthreads();
    PackingSort(shared.temp.sort).Sort(keys,32+bit,36+bit);__syncthreads();
    PackingStore(shared.temp.store).Store(b.sorted+base,keys);__syncthreads();
    if(threadIdx.x<RadixBins)shared.begin[threadIdx.x]=shared.end[threadIdx.x]=0;
    __syncthreads();
    for(unsigned item=0;item<SortItems;++item){
        // Warp-transposed BlockStore changes the register arrangement. Read
        // the canonical stored order for boundary detection.
        const unsigned i=threadIdx.x*SortItems+item,digit=unsigned(b.sorted[base+i]>>(32+bit))&15u;
        if(!i || (unsigned(b.sorted[base+i-1]>>(32+bit))&15u)!=digit)shared.begin[digit]=i;
        if(i+1==SortTile || (unsigned(b.sorted[base+i+1]>>(32+bit))&15u)!=digit)shared.end[digit]=i+1;
    }
    __syncthreads();
    if(threadIdx.x<RadixBins){
        const unsigned bin=threadIdx.x,index=bin*tilesCapacity+block;
        b.localBegin[index]=shared.begin[bin];b.partial[index]=shared.end[bin]-shared.begin[bin];
    }
    __syncthreads();
}
__device__ __forceinline__ void prefixRadixBins(PackingBuffers b,PackingWork* work,unsigned tiles,unsigned tilesCapacity){
    static_assert(Threads%32==0,"Radix prefixes require complete CUDA warps");
    const unsigned lane=threadIdx.x&31u,warp=(blockIdx.x*Threads+threadIdx.x)/32;
    const unsigned warps=gridDim.x*(Threads/32);
    // Every bin owns an independent tile prefix. With one resident block its
    // eight warps each visit two bins; two or more blocks retain the original
    // one-bin-per-warp assignment. All 32 lanes take the same bin iterations.
    for(unsigned bin=warp;bin<RadixBins;bin+=warps){
        unsigned carry=0;
        for(unsigned base=0;base<tiles;base+=32){
            const unsigned i=base+lane,value=i<tiles?b.partial[bin*tilesCapacity+i]:0;unsigned prefix=value;
            for(unsigned offset=1;offset<32;offset*=2){const unsigned other=__shfl_up_sync(0xffffffffu,prefix,offset);if(lane>=offset)prefix+=other;}
            if(i<tiles)b.partial[bin*tilesCapacity+i]=carry+prefix-value;
            carry+=__shfl_sync(0xffffffffu,prefix,31);
        }
        if(!lane)work->bins[bin]=carry;
    }
}
__device__ __forceinline__ void prefixRadixTotals(PackingWork* work){
    const unsigned lane=threadIdx.x&31u,value=lane<RadixBins?work->bins[lane]:0;unsigned prefix=value;
    for(unsigned offset=1;offset<32;offset*=2){const unsigned other=__shfl_up_sync(0xffffffffu,prefix,offset);if(lane>=offset)prefix+=other;}
    if(lane<RadixBins)work->bins[lane]=prefix-value;
}
__device__ __forceinline__ void scatterRadix(PackingBuffers b,PackingWork* work,unsigned tiles,unsigned tilesCapacity,unsigned bit){
    const unsigned stride=gridDim.x*Threads;
    for(unsigned i=blockIdx.x*Threads+threadIdx.x;i<tiles*SortTile;i+=stride){
        const auto key=b.sorted[i];const unsigned bin=unsigned(key>>(32+bit))&15u,block=i/SortTile,index=bin*tilesCapacity+block;
        const unsigned target=work->bins[bin]+b.partial[index]+i%SortTile-b.localBegin[index];b.keys[target]=key;
    }
}
