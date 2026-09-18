// Private to StressHierarchyKernels.cuh. Preserve the original CSR ordering
// and hub degrees while deleting self-column visits from seed selection.
// Every original reference is validated here before any filtering occurs.
__device__ __forceinline__ void compactCoarseAdjacency(Input a,Buffers b,Status* status,unsigned node){
    __shared__ unsigned prefixes[Threads/32],written;
    const unsigned lane=threadIdx.x&31u,warp=threadIdx.x/32;
    const unsigned begin=a.begin[node],end=a.begin[node+1];
    if(begin>end || end>2ull*a.bonds){if(!threadIdx.x)atomicOr(&status->error,1u);return;}
    if(!threadIdx.x)written=0;__syncthreads();
    for(unsigned base=begin;base<end;base+=blockDim.x){
        const unsigned slot=base+threadIdx.x,ref=slot<end?a.refs[slot]:Invalid;
        if(slot<end)(void)neighbour(a,node,slot,status);
        const unsigned edge=ref&0x7fffffffu;
        const bool keep=ref!=Invalid && edge<a.bonds && sourceFirst(a,edge)!=sourceSecond(a,edge);
        const unsigned mask=__ballot_sync(0xffffffffu,keep);
        if(!lane)prefixes[warp]=__popc(mask);__syncthreads();
        unsigned offset=0;for(unsigned i=0;i<warp;++i)offset+=prefixes[i];
        offset+=__popc(mask & ((1u<<lane)-1u));
        if(keep)b.nonSelfRefs[begin+written+offset]=ref;
        __syncthreads();
        if(!threadIdx.x)for(unsigned i=0;i<Threads/32;++i)written+=prefixes[i];
        __syncthreads();
    }
    if(!threadIdx.x)b.nonSelfEnd[node]=begin+written;
    __syncthreads();
}
