#include <cuda_runtime.h>
#include <cstdio>
#include <random>
#include <vector>
#include <cmath>
#include "PxgDestructionFloatPair.cuh"
using namespace physx::destructionPair;
__global__ void k(const double* x,double* y,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
 const Pair a=pair(x[2*i]),b=pair(x[2*i+1]);
 y[8*i+0]=value(a);y[8*i+1]=value(add(a,b));y[8*i+2]=value(mul(a,b));y[8*i+3]=value(div(a,b));y[8*i+4]=value(sqrt(abs(a)));
 y[8*i+5]=value(mul(a,b.hi));float s,e;twoSum(a.hi,b.hi,s,e);y[8*i+6]=double(s)+double(e);y[8*i+7]=double(a.hi)+double(b.hi);}
int main(){const unsigned n=4096;std::mt19937 rng(1);std::uniform_real_distribution<double> u(-1,1);std::vector<double> x(2*n),y(8*n);
 for(auto& v:x)v=u(rng)*pow(10.0,int(u(rng)*6));
 double *dx,*dy;cudaMalloc(&dx,8*x.size());cudaMalloc(&dy,8*y.size());cudaMemcpy(dx,x.data(),8*x.size(),cudaMemcpyHostToDevice);
 k<<<(n+127)/128,128>>>(dx,dy,n);cudaMemcpy(y.data(),dy,8*y.size(),cudaMemcpyDeviceToHost);
 double w[8]={};for(unsigned i=0;i<n;++i){double a=x[2*i],b=x[2*i+1];double ref[8]={a,a+b,a*b,a/b,std::sqrt(std::fabs(a)),a*(double)(float)b,(double)(float)a+(double)(float)b,(double)(float)a+(double)(float)b};
  for(int k=0;k<8;++k){double r=std::fabs(y[8*i+k]-ref[k])/std::max(1e-300,std::fabs(ref[k]));if(k==5)r=0;if(r>w[k])w[k]=r;}}
 const char* nm[8]={"conv","add","mul","div","sqrt","mulf","twoSum","plain"};for(int k=0;k<8;++k)std::printf("%s %.3g\n",nm[k],w[k]);}
