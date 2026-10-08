// pairBits == pair, valueBits == value, doubleBits == double(float) on random and edge inputs.
#include "PxgDestructionFloatPair.cuh"
#include <cuda_runtime.h>
#include <cstdio>
#include <cstring>
#include <random>
#include <vector>
#include <cmath>
using namespace physx::destructionPair;
__global__ void k(const double* d,const float* f,const Pair* p,Pair* a0,Pair* a1,double* b0,double* b1,double* c0,double* c1,unsigned n){
  unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  a0[i]=pair(d[i]);a1[i]=pairBits(d[i]);b0[i]=value(p[i]);b1[i]=valueBits(p[i]);c0[i]=double(f[i]);c1[i]=doubleBits(f[i]);}
int main(){const unsigned n=1<<20;std::mt19937_64 rng(9);std::uniform_real_distribution<double> u(-1,1);
  std::vector<double> d(n);std::vector<float> f(n);std::vector<Pair> p(n);
  for(unsigned i=0;i<n;++i){
    const int kind=i%8;double x=u(rng)*std::pow(2.0,int(u(rng)*60));
    if(kind==1)x=std::ldexp(std::round(u(rng)*(1<<24)),int(u(rng)*40)); // floats exactly
    if(kind==2){float h=float(x);x=double(h)+std::ldexp(double(h),-24)*0.5;} // ties
    if(kind==3)x=0.0; if(kind==4)x=-std::ldexp(1.0,int(u(rng)*50));
    d[i]=x;f[i]=float(u(rng)*std::pow(2.0,int(u(rng)*60)));if(kind==3)f[i]=0;if(kind==5)f[i]=-0.0f;
    // pairs: normalized from a random double, or from sums
    double y=u(rng)*std::pow(2.0,int(u(rng)*40));float hi=float(y);float lo=float(y-double(hi));
    if(kind==6){lo=std::ldexp(float(u(rng)),-40)*hi;}      // lo much smaller than ulp
    if(kind==7){lo=-std::ldexp(1.0f,std::ilogb(hi)-24);}   // exactly half ulp, opposite sign
    p[i]={hi,lo};}
  auto up=[](const auto& v){using T=typename std::decay_t<decltype(v)>::value_type;T* x;cudaMalloc(&x,v.size()*sizeof(T));cudaMemcpy(x,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice);return x;};
  auto *dd=up(d);auto* df=up(f);auto* dp=up(p);Pair *a0,*a1;double *b0,*b1,*c0,*c1;cudaMalloc(&a0,n*8);cudaMalloc(&a1,n*8);cudaMalloc(&b0,n*8);cudaMalloc(&b1,n*8);cudaMalloc(&c0,n*8);cudaMalloc(&c1,n*8);
  k<<<(n+255)/256,256>>>(dd,df,dp,a0,a1,b0,b1,c0,c1,n);auto e=cudaDeviceSynchronize();if(e){printf("err %s\n",cudaGetErrorString(e));return 1;}
  std::vector<Pair> A0(n),A1(n);std::vector<double> B0(n),B1(n),C0(n),C1(n);
  cudaMemcpy(A0.data(),a0,n*8,cudaMemcpyDeviceToHost);cudaMemcpy(A1.data(),a1,n*8,cudaMemcpyDeviceToHost);cudaMemcpy(B0.data(),b0,n*8,cudaMemcpyDeviceToHost);
  cudaMemcpy(B1.data(),b1,n*8,cudaMemcpyDeviceToHost);cudaMemcpy(C0.data(),c0,n*8,cudaMemcpyDeviceToHost);cudaMemcpy(C1.data(),c1,n*8,cudaMemcpyDeviceToHost);
  unsigned bp=0,bv=0,bc=0,hv=0,e0=0,e1=0;int shown=0;
  for(unsigned i=0;i<n;++i){float h=float(d[i]);float l=float(d[i]-double(h));Pair hp{h,l};if(memcmp(&hp,&A0[i],8))++e0;if(memcmp(&hp,&A1[i],8)){++e1;if(shown++<5)printf("d=%.17g kind=%u host {%a,%a} bits {%a,%a} emu {%a,%a}\n",d[i],i%8,h,l,A1[i].hi,A1[i].lo,A0[i].hi,A0[i].lo);}}
  printf("vs host split: emulated pair %u, pairBits %u\n",e0,e1);
  for(unsigned i=0;i<n;++i){if(memcmp(&A0[i],&A1[i],8))++bp;if(memcmp(&B0[i],&B1[i],8))++bv;if(memcmp(&C0[i],&C1[i],8))++bc;
    const double host=double(p[i].hi)+double(p[i].lo);if(memcmp(&host,&B1[i],8))++hv;}
  printf("n=%u mismatches: pairBits %u valueBits %u (vs host %u) doubleBits %u\n",n,bp,bv,hv,bc);}
