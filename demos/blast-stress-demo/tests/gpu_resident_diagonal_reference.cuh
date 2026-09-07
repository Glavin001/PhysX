// Test-only pre-optimization implementation. The production solve divides
// once in the pivot lane; compare every output bit against the original work.
__device__ __forceinline__ Vector referenceDiagonalAllLanes(Buffers b,unsigned node,Vector value){
    const unsigned lane=threadIdx.x&31u;
    const double coefficient=lane<DiagonalEntries?b.diagonal[size_t(node)*DiagonalEntries+lane]:0;
    double rhs=lane==0?value.angular.x:lane==1?value.angular.y:lane==2?value.angular.z:
               lane==3?value.linear.x:lane==4?value.linear.y:lane==5?value.linear.z:0;
    const double first=__shfl_sync(0xffffffffu,coefficient,0);
    if(first==0)rhs=0;
    else {
        for(unsigned k=0;k<6;++k){
            const double pivot=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
            const double solved=__shfl_sync(0xffffffffu,rhs,k)/pivot;
            const unsigned row=lane<6?lane:0;
            const double lower=__shfl_sync(0xffffffffu,coefficient,triangle(row,k<=row?k:row));
            if(lane==k)rhs=solved;
            else if(lane<6 && lane>k)rhs-=lower*solved;
        }
        for(int k=5;k>=0;--k){
            const double pivot=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
            const double solved=__shfl_sync(0xffffffffu,rhs,k)/pivot;
            const unsigned col=lane<unsigned(k)?lane:unsigned(k);
            const double upper=__shfl_sync(0xffffffffu,coefficient,triangle(k,col));
            if(lane==unsigned(k))rhs=solved;
            else if(lane<unsigned(k))rhs-=upper*solved;
        }
    }
    return {{__shfl_sync(0xffffffffu,rhs,0),__shfl_sync(0xffffffffu,rhs,1),__shfl_sync(0xffffffffu,rhs,2)},
            {__shfl_sync(0xffffffffu,rhs,3),__shfl_sync(0xffffffffu,rhs,4),__shfl_sync(0xffffffffu,rhs,5)}};
}
__global__ void applyReferenceDiagonal(Input input,Buffers buffers,const Status* status,const Vector* rhs,Vector* result){
    const unsigned node=(blockIdx.x*blockDim.x+threadIdx.x)/32;
    if(node>=input.nodes)return;
    Vector value{};if(usable(status))value=referenceDiagonalAllLanes(buffers,node,rhs[node]);
    if(!(threadIdx.x&31u))result[node]=value;
}

__global__ void applyThreadDiagonal(Input input,Buffers buffers,const Status* status,const Vector* rhs,Vector* result){
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;
    if(node>=input.nodes)return;
    result[node]=usable(status)?solveFineDiagonalThread(buffers,node,rhs[node]):Vector{};
}
