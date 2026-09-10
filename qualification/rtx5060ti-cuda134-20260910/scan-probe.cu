#include <cuda_runtime.h>
#include <cub/device/device_scan.cuh>
#include <cstdio>
#include <cstdlib>
#define CHECK(x) do {auto e=(x); if(e!=cudaSuccess){std::fprintf(stderr,"%s: %s\n",#x,cudaGetErrorString(e));std::exit(1);}}while(0)
__global__ void consume(const unsigned* ranks,unsigned* copy,unsigned n){unsigned i=threadIdx.x;if(i<n)copy[i]=ranks[i];}
int main(){for(unsigned n=1;n<=16;++n){unsigned *in,*out,*copy;void* tmp;size_t bytes=0;unsigned input[16],result[16];for(unsigned i=0;i<n;++i)input[i]=1;CHECK(cudaMalloc(&in,n*4));CHECK(cudaMalloc(&out,n*4));CHECK(cudaMalloc(&copy,n*4));CHECK(cudaMemcpy(in,input,n*4,cudaMemcpyHostToDevice));CHECK(cub::DeviceScan::ExclusiveSum(nullptr,bytes,in,out,n));CHECK(cudaMalloc(&tmp,bytes));CHECK(cub::DeviceScan::ExclusiveSum(tmp,bytes,in,out,n));consume<<<1,32>>>(out,copy,n);CHECK(cudaMemcpy(result,copy,n*4,cudaMemcpyDeviceToHost));for(unsigned i=0;i<n;++i)if(result[i]!=i){std::fprintf(stderr,"n=%u i=%u got=%u\n",n,i,result[i]);return 2;}std::printf("n=%u PASS\n",n);CHECK(cudaFree(in));CHECK(cudaFree(out));CHECK(cudaFree(copy));CHECK(cudaFree(tmp));}}
