// Private cooperative row scheduling for the few long rows at deep levels.
// A row spans several CTAs to occupy more SMs. Block-local qualification uses
// the identical tiling/reduction tree sequentially, preserving schedule parity.
constexpr unsigned CoarseTileNodes=128,CoarseRowTiles=8;
__device__ __forceinline__ bool tiledCoarseRows(const Input& a){
    return a.levelBonds && a.nodes<=CoarseTileNodes;
}
template<bool Local,bool Correction>
__device__ __forceinline__ void cycleTiledRows(CycleLevel d,TerminalBuffers pool,unsigned level,CycleWork<Local> work,const Vector* childX){
    for(unsigned index=Local?0u:blockIdx.x;index<work.count(d.input)*CoarseRowTiles;index+=Local?1u:gridDim.x){
        const unsigned node=work.node(d.input,index/CoarseRowTiles),tile=index%CoarseRowTiles;
        const bool enabled=work.enabled(d.input,node) && smoothedNode(d,pool,level,node);
        Vector partial{};
        if(enabled){
            const unsigned lane=tile*blockDim.x+threadIdx.x,width=CoarseRowTiles*blockDim.x;
            if constexpr(Correction)partial=cycleCoarseEffect(d,node,childX,lane,width);
            else partial=levelRowContribution(d.input,node,d.x,lane,width);
        }
        partial=coarseBlockSum(partial);
        if(!threadIdx.x)d.rowPartials[node*CoarseRowTiles+tile]=partial;
    }
    work.sync();
    for(unsigned index=work.threadFirst();index<work.count(d.input);index+=work.threadStride()){
        const unsigned node=work.node(d.input,index);
        Vector value{};for(unsigned tile=0;tile<CoarseRowTiles;++tile)value=add(value,d.rowPartials[node*CoarseRowTiles+tile]);
        if(work.enabled(d.input,node) && smoothedNode(d,pool,level,node)){
            if constexpr(Correction)d.residual[node]=sub(d.residual[node],value);
            else d.residual[node]=sub(d.rhs[node],value);
        }else if constexpr(!Correction)d.residual[node]={};
    }
}
