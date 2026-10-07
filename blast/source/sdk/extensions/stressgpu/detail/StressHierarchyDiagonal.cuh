// Private construction fragment included inside StressHierarchy's namespace.
// One warp assembles/factors one exact 6x6 diagonal block of L=B B^T.
// Only 21 lower-triangle coefficients are retained; no inverse is assembled.
constexpr unsigned DiagonalEntries=21;
__device__ __forceinline__ unsigned triangle(unsigned row,unsigned col){return row*(row+1)/2+col;}
__device__ __forceinline__ StressReal skewEntry(float4 r,unsigned row,unsigned col){
    if(row==col)return 0;
    if(row==0)return col==1?-StressReal(r.z):StressReal(r.y);
    if(row==1)return col==0?StressReal(r.z):-StressReal(r.x);
    return col==0?-StressReal(r.y):StressReal(r.x);
}
// Packed symmetric (xx yy zz xy xz yz) entry.
__device__ __forceinline__ unsigned symmetricEntry(unsigned row,unsigned col){
    return row==col?row:(row+col==1?3u:row+col==2?4u:5u);
}
// w: the bond's rotational weight W (Input::angularWeight), or null for the
// uniform length scale (W = I). The angular block is s^2 (W + |r|^2 I - r r^T).
__device__ __forceinline__ StressReal diagonalCoefficient(float4 r,float2 d,StressReal scale,unsigned row,unsigned col,const float* w=nullptr){
    const StressReal p[3]={r.x,r.y,r.z};StressReal value=0;
    if(row<3){
        const StressReal squared=p[0]*p[0]+p[1]*p[1]+p[2]*p[2];
        if(w)value=StressReal(w[symmetricEntry(row,col)])+(row==col?squared:0)-p[row]*p[col];
        else value=(row==col?1+squared:0)-p[row]*p[col];
    } else if(col<3)value=skewEntry(r,row-3,col);
    else value=StressReal(row==col);
    return value*scale*scale*(row<3?d.x:d.y)*(col<3?d.x:d.y);
}
__device__ __forceinline__ void buildFineDiagonal(const Input& input,Buffers buffers,Status* status,unsigned logicalBlock){
    const unsigned lane=threadIdx.x&31u,node=logicalBlock*(Threads/32)+threadIdx.x/32;
    if(node>=input.nodes)return;
    const unsigned row=lane<1?0:lane<3?1:lane<6?2:lane<10?3:lane<15?4:5;
    const unsigned col=lane<DiagonalEntries?lane-row*(row+1)/2:0;
    StressReal coefficient=0;unsigned coupled=0;
    if(lane<DiagonalEntries && input.component[node]!=Invalid){
        for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
            const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
            const unsigned bond=ref&0x7fffffffu;if(input.health[bond]<=0)continue;
            const auto offset=(ref>>31)?input.offset1[bond]:input.offset0[bond];
            coefficient+=diagonalCoefficient(offset,input.inertia[node],input.scale[bond],row,col,
                input.angularWeight?input.angularWeight+6*size_t(bond):nullptr);
            coupled=1;
        }
    }
    // All lanes follow the same factorization control flow. A truly uncoupled
    // row has zero operator and zero pseudoinverse, not an identity fallback.
    coupled=__shfl_sync(0xffffffffu,coupled,0);
    if(coupled)for(unsigned k=0;k<6;++k){
        const StressReal diagonal=__shfl_sync(0xffffffffu,coefficient,triangle(k,k));
        if(!(diagonal>0) || !isfinite(diagonal)){
            if(!lane)atomicOr(&status->error,16u);
            coefficient=0;break;
        }
        const StressReal pivot=sqrt(diagonal);
        if(col==k && row>=k)coefficient/=pivot;
        const StressReal left=__shfl_sync(0xffffffffu,coefficient,triangle(row,k<=row?k:row));
        const StressReal right=__shfl_sync(0xffffffffu,coefficient,triangle(col,k<=col?k:col));
        if(lane<DiagonalEntries && col>k)coefficient-=left*right;
    }
    if(lane<DiagonalEntries)buffers.diagonal[size_t(node)*DiagonalEntries+lane]=coefficient;
}
