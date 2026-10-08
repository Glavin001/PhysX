// Latency of dependent float-pair operations on one thread (CuMetal).
#include "PxgDestructionFloatPair.cuh"
#include <cuda_runtime.h>
#include <cstdio>
#include <chrono>
#include <algorithm>
using namespace physx::destructionPair;
template<int Op> __global__ void chain(const float* in,float* out,int n){
  Pair x={in[0],in[1]*1e-9f},y={in[2],in[3]*1e-9f};float f=in[4];
  for(int i=0;i<n;++i){
    if(Op==0)x=add(x,y);
    if(Op==1)x=mul(x,y);
    if(Op==2)x=div(x,y);
    if(Op==3)x=sqrt(x);
    if(Op==4){x.hi=x.hi*y.hi+f;}
    if(Op==5){x.hi=x.hi/y.hi;}
    if(Op==6){x.hi=sqrtf(x.hi)+f;}
    if(Op==7){float s,e;twoSum(x.hi,y.hi,s,e);x.hi=s;x.lo+=e;}
  }
  out[0]=x.hi;out[1]=x.lo;}
int main(){float* in;float* out;cudaMalloc(&in,64);cudaMalloc(&out,64);float h[5]={1.0001f,0.5f,0.99999f,0.25f,1e-6f};cudaMemcpy(in,h,20,cudaMemcpyHostToDevice);
  auto time=[&](auto k,int n){double best=1e9;for(int r=0;r<5;++r){cudaDeviceSynchronize();auto t0=std::chrono::steady_clock::now();for(int j=0;j<10;++j)k<<<1,1>>>(in,out,n);
    cudaDeviceSynchronize();best=std::min(best,std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-t0).count()/10);}return best;};
  const char* names[]={"pair add","pair mul","pair div","pair sqrt","float fma","float div","float sqrt","twoSum"};
  double base=time(chain<4>,0);
  auto rep=[&](auto k,int i){double t=time(k,10000);printf("%-10s %.1f ns/op\n",names[i],(t-base)*1e3/10000);};
  rep(chain<0>,0);rep(chain<1>,1);rep(chain<2>,2);rep(chain<3>,3);rep(chain<4>,4);rep(chain<5>,5);rep(chain<6>,6);rep(chain<7>,7);
}
