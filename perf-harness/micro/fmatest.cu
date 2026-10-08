#include <cuda_runtime.h>
#include <cstdio>
#include <cstring>
__global__ void k(const float* x,float* y){float a=x[0],b=x[1];float p=a*b;y[0]=fmaf(a,b,-p);y[1]=__fmaf_rn(a,b,-p);
 float s=a+b;float v=s-a;y[2]=(a-(s-v))+(b-v);double d=*reinterpret_cast<const double*>(x+2);float hi=float(d);y[3]=hi;y[4]=float(d-double(hi));}
int main(){float h[3]={1.0f+1.0f/4096,1.0f+1.0f/4096,0};double dd=1.0/3.0;float* dx;float* dy;cudaMalloc(&dx,16);cudaMalloc(&dy,32);
 float in[4]={h[0],h[1],0,0};std::memcpy(&in[2],&dd,8);
 cudaMemcpy(dx,in,16,cudaMemcpyHostToDevice);
 k<<<1,1>>>(dx,dy);float out[5];cudaMemcpy(out,dy,20,cudaMemcpyDeviceToHost);
 std::printf("fma err %.9g (expect %.9g) __fmaf_rn %.9g twoSum err %.9g hi %.9g lo %.9g (expect lo %.9g)\n",out[0],1.0/16777216,out[1],out[2],out[3],out[4],(double)(dd-(double)(float)dd));}
