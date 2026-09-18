// The modes come from native successful-union witnesses and actual live bond
// offsets. Full free rotation, constrained rotation and prescribed supports
// therefore share one GPU-owned projection without guessed rigid modes.
__device__ __forceinline__ void projectNativeNullspace(const PersistentStressArgs& a,
    unsigned id,const unsigned* nodes,unsigned count,StressHierarchy::Vector* values){
    StressHierarchy::projectMotionComponent(a.hierarchy.cycle.levels[0].input,a.hierarchy.modes,id,nodes,count,values);
}
__device__ __forceinline__ void projectNativeNullspacesGrid(const PersistentStressArgs& a,StressHierarchy::Vector* values,const unsigned* selected=nullptr){
    const auto p=a.hierarchy.cycle.levels[0].input.partition;
    for(unsigned i=blockIdx.x;i<*a.liveIslandCount;i+=gridDim.x){const unsigned id=a.islandIds[i];
        if(a.m_islandActive[id] && (!selected || selected[id]))projectNativeNullspace(a,id,p.nodes+p.begin[id],p.end[id]-p.begin[id],values);}
    cooperative_groups::this_grid().sync();
}
