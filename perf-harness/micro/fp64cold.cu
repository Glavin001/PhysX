#include <cuda_runtime.h>
#include <cstdio>
#include <thread>
#include <chrono>
__global__ void none(const float* x,float* y,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)y[i]=x[i]*1.5f+2.f;}
__global__ void one(const float* x,double* y,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)y[i]=double(x[i])*1.5;}
__global__ void six(const float* x,const double* d,double* y,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n){double a=x[i];y[i]=((a*d[i]+d[i+1])*a-d[i+2])*a+d[i]*a;}}
__global__ void conv(const double* d,float* y,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)y[i]=float(d[i]);}
int main(){const int n=164;float *x,*y;double *d,*yd;cudaMalloc(&x,4*n+64);cudaMalloc(&y,4*n+64);cudaMalloc(&d,8*n+64);cudaMalloc(&yd,8*n+64);
 cudaMemset(x,0,4*n+64);cudaMemset(d,0,8*n+64);
 for(int r=0;r<40;++r){std::this_thread::sleep_for(std::chrono::milliseconds(16));
   none<<<2,128>>>(x,y,n);one<<<2,128>>>(x,yd,n);six<<<2,128>>>(x,d,yd,n);conv<<<2,128>>>(d,y,n);cudaDeviceSynchronize();}
 std::puts("done");}
