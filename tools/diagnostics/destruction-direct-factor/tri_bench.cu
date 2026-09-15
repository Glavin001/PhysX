// R1 gate (d): batched per-CTA level-scheduled sparse triangular solves
// (forward L, diagonal, backward L^T) for many independent components.
// One CTA per system; rows grouped into dependency levels on the host.
// Usage: tri_bench <factors-dir> <component-id-list-file> [reps]
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <string>
#include <fstream>
#include <algorithm>
#include <numeric>
#define CK(x) do{cudaError_t e=(x); if(e!=cudaSuccess){printf("CUDA %s at %d\n",cudaGetErrorString(e),__LINE__);exit(1);}}while(0)
template<class T> static std::vector<T> rd(const std::string& p){std::ifstream f(p,std::ios::binary); if(!f){printf("missing %s\n",p.c_str());exit(1);} f.seekg(0,std::ios::end); size_t n=f.tellg()/sizeof(T); f.seekg(0); std::vector<T> v(n); f.read((char*)v.data(),n*sizeof(T)); return v;}
struct Sys { int n, nnz, nlevF, nlevB; int offRow, offNnz, offLevF, offLevB, offOrdF, offOrdB; };
// Build levels for a CSR lower-triangular (forward) matrix: level[i] = 1 + max level[j] for j in row i.
static void levels(const std::vector<int>& ptr, const std::vector<int>& col, int n, std::vector<int>& lev, std::vector<int>& order, std::vector<int>& levptr, bool backward){
    lev.assign(n,0);
    if(!backward){ for(int i=0;i<n;i++){int m=0; for(int k=ptr[i];k<ptr[i+1];k++) m=std::max(m,lev[col[k]]+1); lev[i]=m;} }
    else { for(int i=n-1;i>=0;i--){int m=0; for(int k=ptr[i];k<ptr[i+1];k++) m=std::max(m,lev[col[k]]+1); lev[i]=m;} }
    int L=*std::max_element(lev.begin(),lev.end())+1; order.resize(n); std::iota(order.begin(),order.end(),0);
    std::stable_sort(order.begin(),order.end(),[&](int a,int b){return lev[a]<lev[b];});
    levptr.assign(L+1,0); for(int i=0;i<n;i++) levptr[lev[i]+1]++; for(int l=0;l<L;l++) levptr[l+1]+=levptr[l];
}
__global__ void solveBatched(const Sys* sys, const int* rowptrF, const int* colF, const float* valF, const int* rowptrB, const int* colB, const float* valB,
                             const float* udiag, const int* levptrF, const int* ordF, const int* levptrB, const int* ordB, const float* rhs, float* x, float* y){
    const Sys s = sys[blockIdx.x];
    const int* pF=rowptrF+s.offRow; const int* cF=colF+s.offNnz; const float* vF=valF+s.offNnz;
    const int* pB=rowptrB+s.offRow; const int* cB=colB+s.offNnz; const float* vB=valB+s.offNnz;
    const float* d=udiag+s.offRow; const float* b=rhs+s.offRow; float* xx=x+s.offRow; float* yy=y+s.offRow;
    const int* lF=levptrF+s.offLevF; const int* oF=ordF+s.offOrdF; const int* lB=levptrB+s.offLevB; const int* oB=ordB+s.offOrdB;
    // forward: L y = b (unit diagonal)
    for(int l=0;l<s.nlevF;l++){
        for(int t=lF[l]+threadIdx.x;t<lF[l+1];t+=blockDim.x){ int i=oF[t]; float acc=b[i]; for(int k=pF[i];k<pF[i+1];k++) acc-=vF[k]*yy[cF[k]]; yy[i]=acc; }
        __syncthreads();
    }
    // backward: (D L^T) x = y  ->  L^T x = D^{-1} y ; L^T stored as CSR upper (row i depends on cols > i)
    for(int l=0;l<s.nlevB;l++){
        for(int t=lB[l]+threadIdx.x;t<lB[l+1];t+=blockDim.x){ int i=oB[t]; float acc=yy[i]/d[i]; for(int k=pB[i];k<pB[i+1];k++) acc-=vB[k]*xx[cB[k]]; xx[i]=acc; }
        __syncthreads();
    }
}

// v2: warp-per-row (lanes stride the row, shuffle reduce), solution vectors in shared memory.
__global__ void solveBatchedWarp(const Sys* sys, const int* rowptrF, const int* colF, const float* valF, const int* rowptrB, const int* colB, const float* valB,
                             const float* udiag, const int* levptrF, const int* ordF, const int* levptrB, const int* ordB, const float* rhs, float* x, float* y){
    extern __shared__ float sm[];
    const Sys s = sys[blockIdx.x]; float* yy = sm; float* xx = sm + s.n + 1;
    const int* pF=rowptrF+s.offRow; const int* cF=colF+s.offNnz; const float* vF=valF+s.offNnz;
    const int* pB=rowptrB+s.offRow; const int* cB=colB+s.offNnz; const float* vB=valB+s.offNnz;
    const float* d=udiag+s.offRow; const float* b=rhs+s.offRow;
    const int* lF=levptrF+s.offLevF; const int* oF=ordF+s.offOrdF; const int* lB=levptrB+s.offLevB; const int* oB=ordB+s.offOrdB;
    const int warp=threadIdx.x>>5, lane=threadIdx.x&31, nwarp=blockDim.x>>5;
    for(int l=0;l<s.nlevF;l++){
        for(int t=lF[l]+warp;t<lF[l+1];t+=nwarp){ int i=oF[t]; float acc=0.f; for(int k=pF[i]+lane;k<pF[i+1];k+=32) acc+=vF[k]*yy[cF[k]];
            for(int o=16;o>0;o>>=1) acc+=__shfl_xor_sync(0xffffffffu,acc,o); if(lane==0) yy[i]=b[i]-acc; }
        __syncthreads();
    }
    for(int l=0;l<s.nlevB;l++){
        for(int t=lB[l]+warp;t<lB[l+1];t+=nwarp){ int i=oB[t]; float acc=0.f; for(int k=pB[i]+lane;k<pB[i+1];k+=32) acc+=vB[k]*xx[cB[k]];
            for(int o=16;o>0;o>>=1) acc+=__shfl_xor_sync(0xffffffffu,acc,o); if(lane==0) xx[i]=yy[i]/d[i]-acc; }
        __syncthreads();
    }
    for(int i=threadIdx.x;i<s.n;i+=blockDim.x) x[s.offRow+i]=xx[i];
}
int main(int argc,char**argv){
    if(argc<3){printf("usage: %s factors-dir idlist [reps]\n",argv[0]);return 1;}
    std::string dir=argv[1]; std::ifstream ids(argv[2]); int reps=argc>3?atoi(argv[3]):20; std::vector<int> id; for(int v;ids>>v;) id.push_back(v);
    std::vector<Sys> S; std::vector<int> rowptrF,colF,rowptrB,colB,levF,ordF,levB,ordB; std::vector<float> valF,valB,udiag,rhs;
    size_t totalRows=0,totalNnz=0; int maxLev=0;
    for(int c: id){ std::string b=dir+"/c"+std::to_string(c); auto meta=rd<int>(b+".meta.i32"); int n=meta[0];
        auto pF=rd<int>(b+".L.rowptr.i32"), cF=rd<int>(b+".L.cols.i32"), pB=rd<int>(b+".LT.rowptr.i32"), cB=rd<int>(b+".LT.cols.i32");
        auto vF=rd<float>(b+".L.vals.f32"), vB=rd<float>(b+".LT.vals.f32"), ud=rd<float>(b+".udiag.f32"), r=rd<float>(b+".rhs.f32");
        std::vector<int> lv,oF_,lpF,lv2,oB_,lpB; levels(pF,cF,n,lv,oF_,lpF,false); levels(pB,cB,n,lv2,oB_,lpB,true);
        Sys s{n,(int)cF.size(),(int)lpF.size()-1,(int)lpB.size()-1,(int)rowptrF.size()?(int)udiag.size():0,(int)colF.size(),(int)levF.size(),(int)levB.size(),(int)ordF.size(),(int)ordB.size()};
        s.offRow=(int)udiag.size();
        // rowptr arrays are per-system (n+1 entries) but indexed by offRow; store with n+1 entries and pad to keep offRow == udiag offset
        for(int i=0;i<n;i++){rowptrF.push_back(pF[i]); rowptrB.push_back(pB[i]);} // we only need pF[i],pF[i+1]; store pF[n] via separate trick: append sentinel row
        // simpler: store full (n+1) but then offRow mismatches; instead keep a parallel end array
        colF.insert(colF.end(),cF.begin(),cF.end()); valF.insert(valF.end(),vF.begin(),vF.end()); colB.insert(colB.end(),cB.begin(),cB.end()); valB.insert(valB.end(),vB.begin(),vB.end());
        udiag.insert(udiag.end(),ud.begin(),ud.end()); rhs.insert(rhs.end(),r.begin(),r.end());
        levF.insert(levF.end(),lpF.begin(),lpF.end()); ordF.insert(ordF.end(),oF_.begin(),oF_.end()); levB.insert(levB.end(),lpB.begin(),lpB.end()); ordB.insert(ordB.end(),oB_.begin(),oB_.end());
        S.push_back(s); totalRows+=n; totalNnz+=cF.size(); maxLev=std::max(maxLev,std::max(s.nlevF,s.nlevB));
    }
    // fix rowptr: kernel uses pF[i+1]; we stored n entries per system; append per-system end pointers by rebuilding as (n+1)-strided with offRow adjusted
    // Rebuild rowptr arrays with n+1 entries per system and a separate offset.
    std::vector<int> rpF, rpB; std::vector<int> offRp; { size_t pos=0; for(size_t k=0;k<S.size();k++){ int n=S[k].n; offRp.push_back((int)rpF.size()); std::string b=dir+"/c"+std::to_string(id[k]); auto pF=rd<int>(b+".L.rowptr.i32"), pB=rd<int>(b+".LT.rowptr.i32"); rpF.insert(rpF.end(),pF.begin(),pF.end()); rpB.insert(rpB.end(),pB.begin(),pB.end()); pos+=n; } }
    // The kernel indexes rowptr by offRow; to keep one offset, store rowptr with stride (n+1) and set a second offset field: reuse offLevF? No: add explicit array below.
    std::vector<Sys> S2=S; for(size_t k=0;k<S.size();k++){ S2[k].offRow=S[k].offRow; }
    // Use a wrapper: copy rp arrays into device and pass separate offsets via a small array.
    int N=S.size(); printf("systems %d rows %zu nnzL %zu maxLevels %d\n",N,totalRows,totalNnz,maxLev);
    Sys* dS; int *dRpF,*dRpB,*dCF,*dCB,*dLF,*dOF,*dLB,*dOB,*dOffRp; float *dVF,*dVB,*dUd,*dRhs,*dX,*dY;
    CK(cudaMalloc(&dS,N*sizeof(Sys))); CK(cudaMemcpy(dS,S2.data(),N*sizeof(Sys),cudaMemcpyHostToDevice));
    auto up=[&](auto** d,auto& v){CK(cudaMalloc((void**)d,v.size()*sizeof(v[0])));CK(cudaMemcpy(*d,v.data(),v.size()*sizeof(v[0]),cudaMemcpyHostToDevice));};
    up(&dRpF,rpF);up(&dRpB,rpB);up(&dCF,colF);up(&dCB,colB);up(&dLF,levF);up(&dOF,ordF);up(&dLB,levB);up(&dOB,ordB);up(&dOffRp,offRp);up(&dVF,valF);up(&dVB,valB);up(&dUd,udiag);up(&dRhs,rhs);
    CK(cudaMalloc(&dX,totalRows*4));CK(cudaMalloc(&dY,totalRows*4));
    // kernel variant with separate rowptr offsets
    auto launch=[&](){ solveBatched<<<N,256>>>(dS,dRpF,dCF,dVF,dRpB,dCB,dVB,dUd,dLF,dOF,dLB,dOB,dRhs,dX,dY); };
    // patch: rowptr offsets differ from row offsets (n+1 per system). Build S3 with offRow used for rows and encode rowptr offset in offLevF? Keep it simple: give rowptr its own Sys copy.
    // To avoid complexity, we allocate rowptr arrays with stride (n+1) and pass offsets through a modified struct.
    std::vector<Sys> S3=S2; for(int k=0;k<N;k++){ S3[k].offRow=S2[k].offRow; }
    // NOTE: kernel uses pF=rowptrF+offRow which is wrong by k (one extra entry per preceding system). Fix by allocating rowptr with per-system base = offRow + k.
    {   std::vector<int> rpF2(totalRows+N), rpB2(totalRows+N); size_t pos=0; for(int k=0;k<N;k++){ int n=S[k].n; std::copy(rpF.begin()+offRp[k],rpF.begin()+offRp[k]+n+1,rpF2.begin()+pos); std::copy(rpB.begin()+offRp[k],rpB.begin()+offRp[k]+n+1,rpB2.begin()+pos); pos+=n+1; }
        CK(cudaFree(dRpF));CK(cudaFree(dRpB)); up(&dRpF,rpF2); up(&dRpB,rpB2); }
    // shift: system k rowptr base = offRow + k. Emulate by adjusting Sys.offRow for rowptr only via a second struct array.
    std::vector<Sys> S4=S2; for(int k=0;k<N;k++) S4[k].offLevF=S2[k].offLevF; // unchanged
    // Simplest correct approach: separate kernel signature would be cleaner; instead re-index: make udiag/rhs/x/y also stride n+1 (pad one element per system).
    {   std::vector<float> ud2(totalRows+N,1.f), rhs2(totalRows+N,0.f); size_t pos=0; for(int k=0;k<N;k++){ int n=S[k].n; std::copy(udiag.begin()+S2[k].offRow,udiag.begin()+S2[k].offRow+n,ud2.begin()+pos); std::copy(rhs.begin()+S2[k].offRow,rhs.begin()+S2[k].offRow+n,rhs2.begin()+pos); S4[k].offRow=(int)pos; pos+=n+1; }
        CK(cudaFree(dUd));CK(cudaFree(dRhs));CK(cudaFree(dX));CK(cudaFree(dY)); up(&dUd,ud2); up(&dRhs,rhs2); CK(cudaMalloc(&dX,(totalRows+N)*4));CK(cudaMalloc(&dY,(totalRows+N)*4));
        CK(cudaMemcpy(dS,S4.data(),N*sizeof(Sys),cudaMemcpyHostToDevice)); }
    launch(); CK(cudaDeviceSynchronize());
    cudaEvent_t e0,e1; cudaEventCreate(&e0); cudaEventCreate(&e1); cudaEventRecord(e0); for(int r=0;r<reps;r++) launch(); cudaEventRecord(e1); CK(cudaEventSynchronize(e1)); float ms; cudaEventElapsedTime(&ms,e0,e1);
    printf("batched solve (fwd+bwd) for %d systems: %.3f ms per pass (avg of %d)\n",N,ms/reps,reps);
    { int maxn=0; for(auto& q:S) maxn=std::max(maxn,q.n); size_t smem=(2*maxn+2)*sizeof(float);
      auto launch2=[&](int threads){ solveBatchedWarp<<<N,threads,smem>>>(dS,dRpF,dCF,dVF,dRpB,dCB,dVB,dUd,dLF,dOF,dLB,dOB,dRhs,dX,dY); };
      for(int threads: {128,256,512}){ launch2(threads); CK(cudaDeviceSynchronize()); cudaEventRecord(e0); for(int r=0;r<reps;r++) launch2(threads); cudaEventRecord(e1); CK(cudaEventSynchronize(e1)); cudaEventElapsedTime(&ms,e0,e1);
        printf("v2 warp-per-row smem, %d threads: %.3f ms per pass\n",threads,ms/reps); } }
    // verify: residual of L D L^T x = b for first system on host
    { int k=0; int n=S[k].n; std::vector<float> x(n); CK(cudaMemcpy(x.data(),dX+S4[k].offRow,n*4,cudaMemcpyDeviceToHost)); std::string b=dir+"/c"+std::to_string(id[k]);
      auto pF=rd<int>(b+".L.rowptr.i32"), cF=rd<int>(b+".L.cols.i32"); auto vF=rd<float>(b+".L.vals.f32"), ud=rd<float>(b+".udiag.f32"), r=rd<float>(b+".rhs.f32");
      // z = L^T x scaled: t = D L^T x ; then L t should equal b
      std::vector<double> t(n,0.0); for(int i=0;i<n;i++){ t[i]+= (double)ud[i]*x[i]; for(int q=pF[i];q<pF[i+1];q++) t[cF[q]] += (double)ud[cF[q]]*vF[q]*x[i]; }
      double num=0,den=0; for(int i=0;i<n;i++){ double acc=t[i]; for(int q=pF[i];q<pF[i+1];q++) acc+=vF[q]*t[cF[q]]; num+=(acc-r[i])*(acc-r[i]); den+=(double)r[i]*r[i]; }
      printf("system %d relative residual (fp32 solve, fp64 check) %.3e\n",id[k],sqrt(num/den)); }
    return 0;
}
