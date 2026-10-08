// CuMetal emission bug reproducer: negating a product whose factor is the
// constant -1 (after inlining) emits `--1.0` in the generated Metal, which xcrun
// metal rejects ("expression is not assignable"); the build fails. Seen in the
// explicit step's closed-form stiffness blocks (PhysX perf/explicit-step
// 2ecfa147a; docs/CUMETAL_COMPATIBILITY.md).
//
//   build-tool.sh tests/tools/cumetal_negconst_repro.cu   (fails while the bug is present)
#include <cuda_runtime.h>
#include <cstdio>
__device__ __forceinline__ void block(float k,const float* o,float sign,float* C)
{
    #pragma unroll
    for(int i=0;i<3;++i)C[i]=-sign*k*o[i];
}
__global__ void kern(const float* in,float* out)
{
    float C[6];block(in[0],in+1,1.0f,C);block(in[0],in+1,-1.0f,C+3);
    for(int i=0;i<6;++i)out[6*threadIdx.x+i]=C[i];
}
int main()
{
    float h[4]={2.0f,1.0f,2.0f,3.0f},r[6];float *in,*out;cudaMalloc(&in,sizeof h);cudaMalloc(&out,sizeof r);cudaMemcpy(in,h,sizeof h,cudaMemcpyHostToDevice);
    kern<<<1,1>>>(in,out);cudaDeviceSynchronize();cudaMemcpy(r,out,sizeof r,cudaMemcpyDeviceToHost);
    const float want[6]={-2,-4,-6,2,4,6};int bad=0;for(int i=0;i<6;++i)bad+=r[i]!=want[i];
    std::printf("%s\n",bad?"WRONG":"right");return bad?1:0;
}
