#include <cuda_runtime.h>
#include <cstdio>
#include <random>
#include <vector>
#include <cmath>
#include <cstring>
#include "PxgDestructionFloatPair.cuh"
using namespace physx::destructionPair;
__global__ void k(const double* x,float* y,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;const double d=x[i];
 const Pair a=pair(d);const float hi=float(d);y[4*i]=a.hi;y[4*i+1]=a.lo;y[4*i+2]=hi;y[4*i+3]=float(d-double(hi));}
int main(){const unsigned n=1<<16;std::mt19937_64 rng(5);std::vector<double> x(n);std::vector<float> y(4*n);
 for(unsigned i=0;i<n;++i){unsigned long long b=rng();double d;std::memcpy(&d,&b,8);if(i%2){std::uniform_real_distribution<double> u(-1,1);d=u(rng)*std::pow(2.0,int(rng()%200)-100);}x[i]=d;}
 x[0]=1.0;x[1]=-1.0/3;x[2]=0;x[3]=1e-320;x[4]=INFINITY;x[5]=3.4028235677973366e38;x[6]=1.0-1e-17;x[7]=0.99999997;
 double* dx;float* dy;cudaMalloc(&dx,8*n);cudaMalloc(&dy,16*n);cudaMemcpy(dx,x.data(),8*n,cudaMemcpyHostToDevice);k<<<n/128,128>>>(dx,dy,n);cudaMemcpy(y.data(),dy,16*n,cudaMemcpyDeviceToHost);
 unsigned bad=0,badh=0,nan=0;for(unsigned i=0;i<n;++i){if(std::isnan(x[i])){nan++;continue;}if(std::memcmp(&y[4*i],&y[4*i+2],4))badh++;
  if(std::memcmp(&y[4*i+1],&y[4*i+3],4)){if(bad<8)std::printf("x=%.17g hi %.9g lo new %.9g old %.9g\n",x[i],y[4*i],y[4*i+1],y[4*i+3]);bad++;}}
 std::printf("n %u (nan %u): hi mismatches %u, lo mismatches %u\n",n,nan,badh,bad);}
