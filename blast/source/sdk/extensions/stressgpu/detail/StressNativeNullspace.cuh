// Exact translational null-space projection for unsupported stress components.
// Terminal lifts identify absence of prescribed boundaries. Translation is an
// exact null mode even when authored offsets contain real self-edge moments;
// rotation is deliberately not assumed null from geometry alone.
__device__ __forceinline__ void projectNativeTranslation(const PersistentStressArgs& a,
    unsigned id,const unsigned* nodes,unsigned count,StressHierarchy::Vector* values){
    if(!(a.hierarchy.cycle.pool.lift[size_t(id)*6]>0))return;
    __shared__ double partial[4][kBlockSize/32];
    double sum[4]{};
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];const double inverse=1./a.m_inertia[node].linear;
        const auto v=values[node].linear;sum[0]+=v.x*inverse;sum[1]+=v.y*inverse;sum[2]+=v.z*inverse;sum[3]+=inverse*inverse;}
    for(unsigned step=16;step;step>>=1)for(unsigned k=0;k<4;++k)sum[k]+=__shfl_down_sync(0xffffffffu,sum[k],step);
    if(!(threadIdx.x&31u))for(unsigned k=0;k<4;++k)partial[k][threadIdx.x/32]=sum[k];
    __syncthreads();
    if(!threadIdx.x){double total[4]{};for(unsigned warp=0;warp<kBlockSize/32;++warp)for(unsigned k=0;k<4;++k)total[k]+=partial[k][warp];
        for(unsigned k=0;k<3;++k)partial[k][0]=total[k]/total[3];}
    __syncthreads();
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];const double inverse=1./a.m_inertia[node].linear;
        auto& v=values[node].linear;v.x-=partial[0][0]*inverse;v.y-=partial[1][0]*inverse;v.z-=partial[2][0]*inverse;}
    __syncthreads();
}
__device__ __forceinline__ void projectNativeTranslationsGrid(const PersistentStressArgs& a,StressHierarchy::Vector* values){
    const auto p=a.hierarchy.cycle.levels[0].input.partition;
    for(unsigned i=blockIdx.x;i<*a.liveIslandCount;i+=gridDim.x){const unsigned id=a.islandIds[i];
        if(a.m_islandActive[id])projectNativeTranslation(a,id,p.nodes+p.begin[id],p.end[id]-p.begin[id],values);}
    cooperative_groups::this_grid().sync();
}
