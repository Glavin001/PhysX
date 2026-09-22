// Cached per-node 6x6 inverse for the native block preconditioner. This is
// bounded local algebra, never a dense inverse of a component or world.
// Packed symmetric coefficients are stored by coefficient then node so the
// hot matrix-vector products read coalesced columns across independent lanes.
__device__ __noinline__ void buildNativeFineInverse(NativeStressCycleView h,unsigned node){
    using namespace StressHierarchy;
    if(h.inverseValid[node] && h.inverseGeneration[node]==h.topology->generation)return;
    for(unsigned column=0;column<6;++column){
        const Vector basis{{StressReal(column==0),StressReal(column==1),StressReal(column==2)},
                           {StressReal(column==3),StressReal(column==4),StressReal(column==5)}};
        const auto solved=solveFineDiagonalThread(h.cycle.levels[0].diagonal,node,basis);
        const StressReal value[6]={solved.angular.x,solved.angular.y,solved.angular.z,solved.linear.x,solved.linear.y,solved.linear.z};
        // Use one triangle for both halves, preserving an explicitly symmetric
        // preconditioner rather than independently rounded transposed entries.
        for(unsigned row=column;row<6;++row)h.fineInverse[size_t(triangle(row,column))*h.inverseStride+node]=value[row];
    }
    h.inverseGeneration[node]=h.topology->generation;h.inverseValid[node]=1;
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
