// Cached per-node 6x6 inverse for the native block preconditioner. This is
// bounded local algebra, never a dense inverse of a component or world.
// Packed symmetric coefficients are stored by coefficient then node so the
// hot matrix-vector products read coalesced columns across independent lanes.
// The out-of-line builder takes raw pointers (a narrow ABI, as the rigid
// inverse's: CuMetal proves each pointee's address space at the call).
__device__ __noinline__ void buildNativeFineInverseCoefficients(const StressReal* factors,StressReal* inverse,unsigned stride,unsigned node){
    using namespace StressHierarchy;
    Buffers diagonal{};diagonal.diagonal=const_cast<StressReal*>(factors);
    for(unsigned column=0;column<6;++column){
        const Vector basis{{StressReal(column==0),StressReal(column==1),StressReal(column==2)},
                           {StressReal(column==3),StressReal(column==4),StressReal(column==5)}};
        const auto solved=solveFineDiagonalThread(diagonal,node,basis);
        const StressReal value[6]={solved.angular.x,solved.angular.y,solved.angular.z,solved.linear.x,solved.linear.y,solved.linear.z};
        // Use one triangle for both halves, preserving an explicitly symmetric
        // preconditioner rather than independently rounded transposed entries.
        for(unsigned row=column;row<6;++row)inverse[size_t(triangle(row,column))*stride+node]=value[row];
    }
}
__device__ __forceinline__ void buildNativeFineInverse(const NativeStressCycleView& h,unsigned node){
    const auto generation=h.topology->rebuilds;
    if(h.inverseValid[node] && h.inverseGeneration[node]==generation)return;
    buildNativeFineInverseCoefficients(h.cycle.levels[0].diagonal.diagonal,h.fineInverse,h.inverseStride,node);
    h.inverseGeneration[node]=generation;h.inverseValid[node]=1;
}
__device__ __forceinline__ StressHierarchy::Vector applyNativeFineInverse(NativeStressCycleView h,unsigned node,StressHierarchy::Vector value){
    const StressReal rhs[6]={value.angular.x,value.angular.y,value.angular.z,value.linear.x,value.linear.y,value.linear.z};
    StressReal out[6]{};
#pragma unroll
    for(unsigned row=0;row<6;++row){
#pragma unroll
        for(unsigned column=0;column<6;++column){
            const unsigned entry=StressHierarchy::triangle(row>column?row:column,row>column?column:row);
            out[row]=fma(h.fineInverse[size_t(entry)*h.inverseStride+node],rhs[column],out[row]);
        }
    }
    return {{out[0],out[1],out[2]},{out[3],out[4],out[5]}};
}
