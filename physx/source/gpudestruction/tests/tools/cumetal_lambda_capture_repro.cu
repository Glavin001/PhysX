// CuMetal miscompile reproducer: a lambda that captures by reference a pointer
// whose pointee is a local (private) array reads the wrong values (here zeros:
// relative error 1). Capturing the pointer by value, or no lambda, is right.
// __syncthreads, loops and inlining are irrelevant.
//
// Found as the explicit impact step's contact impulse (PhysX
// PxgDestructionImpactExplicit.cuh, 8e9006545): exConeMetric's `value` lambda
// captured [&] the 3x3 W, which pointed at a register array; the impactor's
// momentum change came out 557 against 2204 N s. docs/CUMETAL_COMPATIBILITY.md.
//
//   build-tool.sh tests/tools/cumetal_lambda_capture_repro.cu; cumetal_lambda_capture_repro
//   exit 1 (and WRONG lines) while the miscompile is present.
#include <cuda_runtime.h>
#include <cstdio>
__device__ __forceinline__ float viaLambda(const float* p,float x){auto f=[&](float t){return p[0]*t+p[4]*t*t+p[8];};float s=0.0f;for(int k=0;k<4;++k)s+=f(x+float(k));return s;}
__device__ __forceinline__ float viaLambdaCopy(const float* p,float x){auto f=[p](float t){return p[0]*t+p[4]*t*t+p[8];};float s=0.0f;for(int k=0;k<4;++k)s+=f(x+float(k));return s;}
__device__ __forceinline__ float direct(const float* p,float x){float s=0.0f;for(int k=0;k<4;++k){const float t=x+float(k);s+=p[0]*t+p[4]*t*t+p[8];}return s;}
template<int V,bool Sync> __global__ void k(const float* in,float* out)
{
    const int t=threadIdx.x;float a[9];for(int i=0;i<9;++i)a[i]=in[9*t+i]*2.0f;
    if(Sync)__syncthreads();
    const float x=float(t)*0.25f;
    out[t]=V==0?direct(a,x):V==1?viaLambda(a,x):viaLambdaCopy(a,x);
}
int main()
{
    const int n=32;float h[9*n];for(int i=0;i<9*n;++i)h[i]=float(i%13)*0.5f+1.0f;
    float *in,*out;cudaMalloc(&in,sizeof h);cudaMalloc(&out,n*4);cudaMemcpy(in,h,sizeof h,cudaMemcpyHostToDevice);
    float r[6][n];
    auto go=[&](int i,auto kern){kern<<<1,n>>>(in,out);cudaDeviceSynchronize();cudaMemcpy(r[i],out,n*4,cudaMemcpyDeviceToHost);};
    go(0,k<0,false>);go(1,k<1,false>);go(2,k<2,false>);go(3,k<0,true>);go(4,k<1,true>);go(5,k<2,true>);
    const char* name[6]={"direct","lambda [&]","lambda [p]","direct+sync","lambda [&]+sync","lambda [p]+sync"};
    int bad=0;
    for(int i=0;i<6;++i){double m=0;for(int t=0;t<n;++t){float a[9];for(int q=0;q<9;++q)a[q]=h[9*t+q]*2.0f;const float x=float(t)*0.25f;float s=0;for(int k=0;k<4;++k){float u=x+k;s+=a[0]*u+a[4]*u*u+a[8];}m=fmax(m,fabs(double(r[i][t])-s)/fabs(s));}
        std::printf("%-18s max rel err %.3g%s\n",name[i],m,m>1e-5?"  WRONG":"");bad+=m>1e-5;}
    return bad?1:0;
}
