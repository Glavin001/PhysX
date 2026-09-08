// Private to StressHierarchyCycle.cuh. Coarsening retains bond columns, so
// a small node count can still have very long rows. Give those rows a full
// block rather than eight lanes. Every contribution remains in FP64.
__device__ __forceinline__ bool coarseBlockRows(const Input& input){
    return input.levelBonds && input.nodes<=1024;
}
__device__ __forceinline__ Vector coarseBlockSum(Vector value){
    __shared__ Vector partial[Threads/32];
    value=warpSum(value);
    if(!(threadIdx.x&31u))partial[threadIdx.x/32]=value;
    __syncthreads();
    value=threadIdx.x<blockDim.x/32?partial[threadIdx.x]:Vector{};
    value=warpSum(value);
    // All consumers have read the partials before the next row reuses them.
    __syncthreads();return value;
}
