#include <cuda_runtime.h>
#include <cstdio>
#include <random>
#include <vector>
#include <cmath>
__global__ void k(const double* x,double* y,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[2*i],b=x[2*i+1];
 y[9*i+0]=a+b;y[9*i+1]=a*b;y[9*i+2]=a/b;y[9*i+3]=sqrt(fabs(a));y[9*i+4]=hypot(a,b);y[9*i+5]=copysign(1.0,a);y[9*i+6]=fma(a,b,a);y[9*i+7]=1/sqrt(1+a*a);y[9*i+8]=fmax(a,b);}
int main(){const unsigned n=8192;std::mt19937 rng(3);std::uniform_real_distribution<double> u(-1,1);std::vector<double> x(2*n),y(9*n);
 for(auto& v:x)v=u(rng)*pow(10.0,int(u(rng)*8));
 double *dx,*dy;cudaMalloc(&dx,8*x.size());cudaMalloc(&dy,8*y.size());cudaMemcpy(dx,x.data(),8*x.size(),cudaMemcpyHostToDevice);
 k<<<(n+127)/128,128>>>(dx,dy,n);cudaMemcpy(y.data(),dy,8*y.size(),cudaMemcpyDeviceToHost);
 const char* nm[9]={"add","mul","div","sqrt","hypot","copysign","fma","rsqrt1p","fmax"};double w[9]={};unsigned bad[9]={};
 for(unsigned i=0;i<n;++i){double a=x[2*i],b=x[2*i+1];double r[9]={a+b,a*b,a/b,std::sqrt(std::fabs(a)),std::hypot(a,b),std::copysign(1.0,a),std::fma(a,b,a),1/std::sqrt(1+a*a),std::fmax(a,b)};
  for(int k=0;k<9;++k){double e=std::fabs(y[9*i+k]-r[k])/std::max(1e-300,std::fabs(r[k]));if(e>w[k])w[k]=e;bad[k]+=y[9*i+k]!=r[k];}}
 for(int k=0;k<9;++k)std::printf("%-8s worst rel %.3g, not bitwise %u/%u\n",nm[k],w[k],bad[k],n);}
