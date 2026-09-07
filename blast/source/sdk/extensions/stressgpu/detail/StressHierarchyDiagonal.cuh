// Private construction fragment included inside StressHierarchy's namespace.
// One warp assembles/factors one exact 6x6 diagonal block of L=B B^T.
// Only 21 lower-triangle coefficients are retained; no inverse is assembled.
constexpr unsigned DiagonalEntries=21;
__device__ __forceinline__ unsigned triangle(unsigned row,unsigned col){return row*(row+1)/2+col;}
__device__ __forceinline__ double skewEntry(float4 r,unsigned row,unsigned col){
    if(row==col)return 0;
    if(row==0)return col==1?-double(r.z):double(r.y);
    if(row==1)return col==0?double(r.z):-double(r.x);
    return col==0?-double(r.y):double(r.x);
}
__device__ __forceinline__ double diagonalCoefficient(float4 r,float2 d,double scale,unsigned row,unsigned col){
    const double p[3]={r.x,r.y,r.z};double value=0;
    if(row<3){
        const double squared=p[0]*p[0]+p[1]*p[1]+p[2]*p[2];
        value=(row==col?1+squared:0)-p[row]*p[col];
    } else if(col<3)value=skewEntry(r,row-3,col);
    else value=double(row==col);
    return value*scale*scale*(row<3?d.x:d.y)*(col<3?d.x:d.y);
}
__device__ __forceinline__ void buildFineDiagonal(const Input& input,Buffers buffers,Status* status,unsigned logicalBlock){
    const unsigned lane=threadIdx.x&31u,node=logicalBlock*(Threads/32)+threadIdx.x/32;
    if(node>=input.nodes)return;
    const unsigned row=lane<1?0:lane<3?1:lane<6?2:lane<10?3:lane<15?4:5;
    const unsigned col=lane<DiagonalEntries?lane-row*(row+1)/2:0;
    double coefficient=0;unsigned coupled=0;
    if(lane<DiagonalEntries && input.component[node]!=Invalid){
        for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
            const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
            const unsigned bond=ref&0x7fffffffu;if(input.health[bond]<=0)continue;
            const auto offset=(ref>>31)?input.offset1[bond]:input.offset0[bond];
            coefficient+=diagonalCoefficient(offset,input.inertia[node],input.scale[bond],row,col);
            coupled=1;
        }
    }
    // All lanes follow the same factorization control flow. A truly uncoupled
    // row has zero operator and zero pseudoinverse, not an identity fallback.
    coupled=__shfl_sync(0xffffffffu,coupled,0);
    if(coupled)for(unsigned k=0;k<6;++k){
        const double diagonal=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
        if(!(diagonal>0) || !isfinite(diagonal)){
            if(!lane)atomicOr(&status->error,16u);
            coefficient=0;break;
        }
        const double pivot=sqrt(diagonal);
        if(col==k && row>=k)coefficient/=pivot;
        const double left=__shfl_sync(0xffffffffu,coefficient,triangle(row,k<=row?k:row));
        const double right=__shfl_sync(0xffffffffu,coefficient,triangle(col,k<=col?k:col));
        if(lane<DiagonalEntries && col>k)coefficient-=left*right;
    }
    if(lane<DiagonalEntries)buffers.diagonal[size_t(node)*DiagonalEntries+lane]=coefficient;
}
