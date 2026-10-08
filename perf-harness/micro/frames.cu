// principalFrame (double) vs principalFramePair (CuMetal) on the body test's
// analytic tensors: agreement and GPU time (cold launches).
#include "foundation/PxSimpleTypes.h"
using physx::PxU32;
#include "PxgDestructionBody.cuh"
#include <cuda_runtime.h>
#include <cstdio>
#include <vector>
#include <random>
#include <array>
#include <thread>
#include <chrono>
#include <cmath>
#include <algorithm>
using namespace physx;
struct R {double m[3],q[4];unsigned ok;};
__global__ void dbl(const double* in,R* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)out[i].ok=destructionBody::principalFrame(in+6*i,out[i].m,out[i].q);}
__global__ void prs(const double* in,R* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)out[i].ok=destructionBody::principalFramePair(in+6*i,out[i].m,out[i].q);}
using V=std::array<double,3>;using Q=std::array<double,4>;using M=std::array<V,3>;
M matrix(Q q){const auto [x,y,z,w]=q;return {{{1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)},{2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)},{2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)}}};}
int main(int argc,char**argv){
  const unsigned n=argc>1?atoi(argv[1]):4096;std::mt19937 rng(587);std::uniform_real_distribution<double> positive(.1,3);std::normal_distribution<double> nd(0,1);
  std::vector<double> in(6*n);
  for(unsigned i=0;i<n;++i){Q q;double len=0;for(double&x:q){x=nd(rng);len+=x*x;}for(double&x:q)x/=sqrt(len);const M a=matrix(q);
    const V size={positive(rng),positive(rng),positive(rng)};const double scale=pow(10.0,int(i%51)-25);
    V diag={scale*(size[1]*size[1]+size[2]*size[2]),scale*(size[0]*size[0]+size[2]*size[2]),scale*(size[0]*size[0]+size[1]*size[1])};
    if(i%7==0)diag={scale,scale,scale};if(i%13==0)diag={scale,scale,2*scale};
    M t{};for(unsigned j=0;j<3;++j)for(unsigned k=0;k<3;++k)for(unsigned p=0;p<3;++p)t[j][k]+=a[j][p]*diag[p]*a[k][p];
    const double packed[]={t[0][0],t[1][1],t[2][2],t[0][1],t[0][2],t[1][2]};std::copy(packed,packed+6,&in[6*i]);}
  double* d;R *o1,*o2;cudaMalloc(&d,8*in.size());cudaMalloc(&o1,n*sizeof(R));cudaMalloc(&o2,n*sizeof(R));cudaMemcpy(d,in.data(),8*in.size(),cudaMemcpyHostToDevice);
  cudaEvent_t e0,e1;cudaEventCreate(&e0);cudaEventCreate(&e1);
  auto time=[&](auto k,R* o,const char* name){float best=1e9,sum=0;for(int r=0;r<10;++r){std::this_thread::sleep_for(std::chrono::milliseconds(16));cudaEventRecord(e0);k<<<(n+127)/128,128>>>(d,o,n);cudaEventRecord(e1);cudaEventSynchronize(e1);float ms;cudaEventElapsedTime(&ms,e0,e1);best=std::min(best,ms);sum+=ms;}std::printf("%s: best %.1f us mean %.1f us\n",name,best*1e3,sum*100);};
  time(dbl,o1,"double");time(prs,o2,"pair");
  std::vector<R> a(n),b(n);cudaMemcpy(a.data(),o1,n*sizeof(R),cudaMemcpyDeviceToHost);cudaMemcpy(b.data(),o2,n*sizeof(R),cudaMemcpyDeviceToHost);
  {FILE* f=fopen("frames.bin","wb");fwrite(&n,4,1,f);fwrite(in.data(),8,in.size(),f);fwrite(a.data(),sizeof(R),n,f);fwrite(b.data(),sizeof(R),n,f);fclose(f);}
  unsigned okDiff=0,qf=0,mf=0,deg=0;double wm=0,wq=0;
  for(unsigned i=0;i<n;++i){if(a[i].ok!=b[i].ok){++okDiff;continue;}if(!a[i].ok)continue;bool degenerate=(i%7==0)||(i%13==0);
    for(int k=0;k<3;++k){wm=std::max(wm,fabs(a[i].m[k]-b[i].m[k])/fabs(a[i].m[k]));mf+=float(a[i].m[k])!=float(b[i].m[k]);}
    double qd=0;for(int k=0;k<4;++k){qd=std::max(qd,fabs(a[i].q[k]-b[i].q[k]));}
    if(degenerate){deg+=qd>1e-6;continue;}
    wq=std::max(wq,qd);for(int k=0;k<4;++k)qf+=float(a[i].q[k])!=float(b[i].q[k]);}
  std::printf("n %u: ok mismatches %u, moments worst rel %.3g float-mismatch %u, frames (non-degenerate) worst %.3g float-mismatch %u, degenerate frames differing %u\n",n,okDiff,wm,mf,wq,qf,deg);
}
