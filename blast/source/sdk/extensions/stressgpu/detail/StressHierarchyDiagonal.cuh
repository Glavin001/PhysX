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
// Per-bond rotational stiffness: the block in linear-first order, factored
// exactly. With D = [[A, G^T], [G, c I]] (angular first), c = sum s^2,
// G = sum s^2 [r]x, A = sum s^2 (W + [r]x^T [r]x), the angular Schur
// complement is, by the parallel-axis theorem,
//     S = A - G^T G / c = sum s^2 (W + [r - rbar]x^T [r - rbar]x),
// rbar = sum s^2 r / c: a sum of positive semidefinite terms, formed with no
// cancellation. Angular-first FP32 Cholesky instead forms S by subtracting
// O(c |r|^2) terms, and a chunk hanging from one thin bond (S ~ s^2 W, its
// soft axis 1e-7 of |r|^2) lost its pivot. In linear-first order
//     L = [[dl sqrt(c) I, 0], [da sqrt(c) [rbar]x^T, da chol(S)]]
// (d the node's inertia scaling). The layout is flagged by a negative first
// entry, which the triangular solves read as "linear first"; a Cholesky pivot
// is otherwise positive. Thread 0 of the node's warp builds it.
__device__ __forceinline__ void buildFineDiagonalParallelAxis(const Input& input,Buffers buffers,Status* status,unsigned node,unsigned lane){
    StressReal* out=buffers.diagonal+size_t(node)*DiagonalEntries;
    if(lane>=DiagonalEntries)return;
    out[lane]=0;
    if(lane || input.component[node]==Invalid)return;
    StressReal c=0,rx=0,ry=0,rz=0;
    for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
        const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
        const unsigned bond=ref&0x7fffffffu;if(input.health[bond]<=0)continue;
        const auto r=(ref>>31)?input.offset1[bond]:input.offset0[bond];const StressReal s2=StressReal(input.scale[bond])*input.scale[bond];
        c+=s2;rx+=s2*r.x;ry+=s2*r.y;rz+=s2*r.z;
    }
    if(!(c>0))return;   // uncoupled: zero operator, zero response
    rx/=c;ry/=c;rz/=c;
    StressReal m[6]={0,0,0,0,0,0}; // S packed xx yy zz xy xz yz
    for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
        const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
        const unsigned bond=ref&0x7fffffffu;if(input.health[bond]<=0)continue;
        const auto r=(ref>>31)?input.offset1[bond]:input.offset0[bond];const StressReal s2=StressReal(input.scale[bond])*input.scale[bond];
        const StressReal x=StressReal(r.x)-rx,y=StressReal(r.y)-ry,z=StressReal(r.z)-rz;
        const float* w=input.angularWeight+6*size_t(bond);
        // [d]x^T [d]x = |d|^2 I - d d^T
        m[0]+=s2*(StressReal(w[0])+y*y+z*z);m[1]+=s2*(StressReal(w[1])+x*x+z*z);m[2]+=s2*(StressReal(w[2])+x*x+y*y);
        m[3]+=s2*(StressReal(w[3])-x*y);m[4]+=s2*(StressReal(w[4])-x*z);m[5]+=s2*(StressReal(w[5])-y*z);
    }
    const auto d=input.inertia[node];
    const StressReal da=d.x,dl=d.y,root=sqrt(c);
    // chol(S): l00 l10 l11 l20 l21 l22
    const StressReal l00=m[0]>0?sqrt(m[0]):StressReal(0);
    const StressReal l10=l00>0?m[3]/l00:StressReal(0),l20=l00>0?m[4]/l00:StressReal(0);
    const StressReal p11=m[1]-l10*l10,l11=p11>0?sqrt(p11):StressReal(0);
    const StressReal l21=l11>0?(m[5]-l20*l10)/l11:StressReal(0);
    const StressReal p22=m[2]-l20*l20-l21*l21,l22=p22>0?sqrt(p22):StressReal(0);
    if(!(l00>0 && l11>0 && l22>0) || !isfinite(l00+l11+l22+root)){atomicOr(&status->error,16u);return;}
    // Rows 0..2 linear, 3..5 angular. [rbar]x^T row a, column j = [rbar]x[j][a].
    const StressReal k=da*root,diag=dl*root;
    out[triangle(0,0)]=-diag;out[triangle(1,1)]=diag;out[triangle(2,2)]=diag;
    out[triangle(3,0)]=0;          out[triangle(3,1)]=k*rz;  out[triangle(3,2)]=-k*ry;
    out[triangle(4,0)]=-k*rz;      out[triangle(4,1)]=0;     out[triangle(4,2)]=k*rx;
    out[triangle(5,0)]=k*ry;       out[triangle(5,1)]=-k*rx; out[triangle(5,2)]=0;
    out[triangle(3,3)]=da*l00;out[triangle(4,3)]=da*l10;out[triangle(4,4)]=da*l11;
    out[triangle(5,3)]=da*l20;out[triangle(5,4)]=da*l21;out[triangle(5,5)]=da*l22;
}
// Per-bond shear stiffness (Shear; ExtStressGpuSetBondShearStiffness): each
// bond's linear stiffness is s^2 Wl (its row's second six floats), so the
// node's linear block is C = sum s^2 Wl, no longer c I. In linear-first order
// the block is [[C, H], [H^T, A]], H = sum s^2 Wl [r]x, A = sum s^2 (W +
// [r]x^T Wl [r]x). With X = C^-1 H (the parallel-axis theorem's [rbar]x when
// every Wl = I) the angular Schur complement is
//     S = A - H^T C^-1 H = sum s^2 (W + ([r]x - X)^T Wl ([r]x - X)),
// a sum of positive semidefinite terms formed with no cancellation, as there.
// L = [[dl chol(C), 0], [da X^T chol(C), da chol(S)]]; the layout flag is the
// same negative first entry.
__device__ __forceinline__ StressReal diagonalCross(float4 r,unsigned i,unsigned k){
    if(i==k)return 0;
    const unsigned l=3-i-k;const StressReal v=l==0?StressReal(r.x):l==1?StressReal(r.y):StressReal(r.z);
    return ((i+1)%3==k)?-v:v;
}
__device__ __forceinline__ StressReal diagonalPacked(const float* w,unsigned k,unsigned l){
    return StressReal(w[k==l?k:(k+l==1?3u:k+l==2?4u:5u)]);
}
__device__ __forceinline__ void buildFineDiagonalShear(const Input& input,Buffers buffers,Status* status,unsigned node,unsigned lane){
    StressReal* out=buffers.diagonal+size_t(node)*DiagonalEntries;
    if(lane>=DiagonalEntries)return;
    out[lane]=0;
    if(lane || input.component[node]==Invalid)return;
    StressReal C[3][3]={{0,0,0},{0,0,0},{0,0,0}},H[3][3]={{0,0,0},{0,0,0},{0,0,0}};
    for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
        const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
        const unsigned bond=ref&0x7fffffffu;if(input.health[bond]<=0)continue;
        const auto r=(ref>>31)?input.offset1[bond]:input.offset0[bond];const StressReal s2=StressReal(input.scale[bond])*input.scale[bond];
        const float* wl=input.angularWeight+12*size_t(bond)+6;
        for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j){
            C[i][j]+=s2*diagonalPacked(wl,i,j);
            StressReal h=0;for(unsigned k=0;k<3;++k)h+=diagonalPacked(wl,i,k)*diagonalCross(r,k,j);
            H[i][j]+=s2*h;
        }
    }
    if(!(C[0][0]>0 && C[1][1]>0 && C[2][2]>0))return;   // uncoupled: zero operator, zero response
    // chol(C)
    StressReal L[3][3]={{0,0,0},{0,0,0},{0,0,0}};
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<=i;++j){
        StressReal v=C[i][j];for(unsigned k=0;k<j;++k)v-=L[i][k]*L[j][k];
        if(i==j){if(!(v>0)){atomicOr(&status->error,16u);return;}L[i][i]=sqrt(v);}
        else L[i][j]=v/L[j][j];
    }
    // X = C^-1 H, column by column: L y = h, L^T x = y.
    StressReal X[3][3];
    for(unsigned c=0;c<3;++c){
        StressReal y[3];
        for(unsigned i=0;i<3;++i){StressReal v=H[i][c];for(unsigned k=0;k<i;++k)v-=L[i][k]*y[k];y[i]=v/L[i][i];}
        for(int i=2;i>=0;--i){StressReal v=y[i];for(unsigned k=unsigned(i)+1;k<3;++k)v-=L[k][i]*X[k][c];X[i][c]=v/L[i][i];}
    }
    // S = sum s^2 (W + D^T Wl D), D = [r]x - X.
    StressReal S[3][3]={{0,0,0},{0,0,0},{0,0,0}};
    for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
        const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
        const unsigned bond=ref&0x7fffffffu;if(input.health[bond]<=0)continue;
        const auto r=(ref>>31)?input.offset1[bond]:input.offset0[bond];const StressReal s2=StressReal(input.scale[bond])*input.scale[bond];
        const float* w=input.angularWeight+12*size_t(bond);
        StressReal D[3][3],WD[3][3];
        for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j)D[i][j]=diagonalCross(r,i,j)-X[i][j];
        for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j){StressReal v=0;for(unsigned k=0;k<3;++k)v+=diagonalPacked(w+6,i,k)*D[k][j];WD[i][j]=v;}
        for(unsigned i=0;i<3;++i)for(unsigned j=0;j<=i;++j){
            StressReal v=diagonalPacked(w,i,j);for(unsigned k=0;k<3;++k)v+=D[k][i]*WD[k][j];
            S[i][j]+=s2*v;
        }
    }
    StressReal M[3][3]={{0,0,0},{0,0,0},{0,0,0}};
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<=i;++j){
        StressReal v=S[i][j];for(unsigned k=0;k<j;++k)v-=M[i][k]*M[j][k];
        if(i==j){if(!(v>0) || !isfinite(v)){atomicOr(&status->error,16u);return;}M[i][i]=sqrt(v);}
        else M[i][j]=v/M[j][j];
    }
    const auto d=input.inertia[node];
    const StressReal da=d.x,dl=d.y;
    // Rows 0..2 linear, 3..5 angular; L21 = X^T chol(C).
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<=i;++j)out[triangle(i,j)]=dl*L[i][j];
    out[triangle(0,0)]=-out[triangle(0,0)];
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j){StressReal v=0;for(unsigned k=0;k<3;++k)v+=X[k][i]*L[k][j];out[triangle(3+i,j)]=da*v;}
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<=i;++j)out[triangle(3+i,3+j)]=da*M[i][j];
    if(!isfinite(out[triangle(0,0)]+out[triangle(5,5)]))atomicOr(&status->error,16u);
}
template<bool Shear=false>
__device__ __forceinline__ void buildFineDiagonal(const Input& input,Buffers buffers,Status* status,unsigned logicalBlock){
    const unsigned lane=threadIdx.x&31u,node=logicalBlock*(Threads/32)+threadIdx.x/32;
    if(node>=input.nodes)return;
    if constexpr(Shear){if(input.angularWeight){buildFineDiagonalShear(input,buffers,status,node,lane);return;}}
    if(input.angularWeight){buildFineDiagonalParallelAxis(input,buffers,status,node,lane);return;}
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
