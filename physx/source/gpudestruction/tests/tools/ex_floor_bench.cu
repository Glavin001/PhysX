// The explicit step's floor on this GPU (CuMetal / Apple): what one substep's
// building blocks cost in one threadgroup, so a kernel change can be judged
// against what is possible. Each kernel runs N iterations in one launch; the
// time per iteration is (launch with N - launch with N/2) / (N/2), so launch
// overhead cancels.
//
//   ex_floor_bench [N=20000]
//
// barrier          __syncthreads alone
// global chase     one dependent device load per thread per iteration (latency)
// global gather    write a value, barrier, read another thread's (the wr pattern)
// shared gather    the same through threadgroup memory
// gather8          each thread sums 8 other threads' 6-float values from device memory
// gather8 shared   the same from threadgroup memory
#include <cuda_runtime.h>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>
static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}

__global__ void kBarrier(float* out,int n)
{
    float a=float(threadIdx.x);
    for(int i=0;i<n;++i){a=a*0.999f+1.0f;__syncthreads();}
    out[blockIdx.x*blockDim.x+threadIdx.x]=a;
}
__global__ void kChase(const unsigned* next,float* out,int n)
{
    unsigned k=threadIdx.x;float a=0.0f;
    for(int i=0;i<n;++i){k=next[k];a+=float(k);}
    out[blockIdx.x*blockDim.x+threadIdx.x]=a;
}
__global__ void kGlobalGather(float* buf,float* out,int n)
{
    float* b=buf+blockIdx.x*blockDim.x;float a=float(threadIdx.x);
    for(int i=0;i<n;++i){b[threadIdx.x]=a;__syncthreads();a+=0.5f*b[(threadIdx.x*37u+11u)%blockDim.x];__syncthreads();}
    out[blockIdx.x*blockDim.x+threadIdx.x]=a;
}
__global__ void kSharedGather(float* out,int n)
{
    __shared__ float b[1024];float a=float(threadIdx.x);
    for(int i=0;i<n;++i){b[threadIdx.x]=a;__syncthreads();a+=0.5f*b[(threadIdx.x*37u+11u)%blockDim.x];__syncthreads();}
    out[blockIdx.x*blockDim.x+threadIdx.x]=a;
}
__global__ void kGather8(float* buf,const unsigned* adj,float* out,int n)
{
    float* b=buf+size_t(blockIdx.x)*blockDim.x*6;float a[6]={0,0,0,0,0,0};
    for(int i=0;i<n;++i){
        for(int q=0;q<6;++q)b[6*threadIdx.x+q]=a[q]*0.5f+1.0f;
        __syncthreads();
        float f[6]={0,0,0,0,0,0};
        for(int j=0;j<8;++j){const float* s=b+6*adj[8*threadIdx.x+j];for(int q=0;q<6;++q)f[q]+=s[q];}
        for(int q=0;q<6;++q)a[q]=f[q]*0.125f;
        __syncthreads();
    }
    out[blockIdx.x*blockDim.x+threadIdx.x]=a[0];
}
__global__ void kGather8Shared(const unsigned* adj,float* out,int n)
{
    __shared__ float b[6*1024];float a[6]={0,0,0,0,0,0};
    for(int i=0;i<n;++i){
        for(int q=0;q<6;++q)b[6*threadIdx.x+q]=a[q]*0.5f+1.0f;
        __syncthreads();
        float f[6]={0,0,0,0,0,0};
        for(int j=0;j<8;++j){const float* s=b+6*adj[8*threadIdx.x+j];for(int q=0;q<6;++q)f[q]+=s[q];}
        for(int q=0;q<6;++q)a[q]=f[q]*0.125f;
        __syncthreads();
    }
    out[blockIdx.x*blockDim.x+threadIdx.x]=a[0];
}
__global__ void kGather8V(float4* buf,const unsigned* adj,float* out,int n)
{
    float4* b=buf+size_t(blockIdx.x)*blockDim.x*2;float a[8]={0,0,0,0,0,0,0,0};
    for(int i=0;i<n;++i){
        b[2*threadIdx.x]=make_float4(a[0]*0.5f+1.0f,a[1]*0.5f+1.0f,a[2]*0.5f+1.0f,a[3]*0.5f+1.0f);
        b[2*threadIdx.x+1]=make_float4(a[4]*0.5f+1.0f,a[5]*0.5f+1.0f,0.0f,0.0f);
        __syncthreads();
        float f[8]={0,0,0,0,0,0,0,0};
        for(int j=0;j<8;++j){const float4 p=b[2*adj[8*threadIdx.x+j]],q=b[2*adj[8*threadIdx.x+j]+1];f[0]+=p.x;f[1]+=p.y;f[2]+=p.z;f[3]+=p.w;f[4]+=q.x;f[5]+=q.y;}
        for(int q=0;q<8;++q)a[q]=f[q]*0.125f;
        __syncthreads();
    }
    out[blockIdx.x*blockDim.x+threadIdx.x]=a[0];
}

int main(int argc,char** argv)
{
    try {
        const int N=argc>1?std::atoi(argv[1]):20000;
        float* out;check(cudaMalloc(&out,8*1024*sizeof(float)));
        float* buf;check(cudaMalloc(&buf,8*1024*8*sizeof(float)));
        unsigned *next,*adj;check(cudaMalloc(&next,1024*sizeof(unsigned)));check(cudaMalloc(&adj,8*1024*sizeof(unsigned)));
        {unsigned h[1024];for(unsigned i=0;i<1024;++i)h[i]=(i*389u+7u)%1024u;check(cudaMemcpy(next,h,sizeof h,cudaMemcpyHostToDevice));
         static unsigned g[8*1024];for(unsigned i=0;i<8*1024;++i)g[i]=(i*977u+13u)%256u;check(cudaMemcpy(adj,g,sizeof g,cudaMemcpyHostToDevice));}
        auto time=[&](const char* name,auto launch) {
            launch(8);check(cudaDeviceSynchronize());   // pipeline build
            double best[2]={1e30,1e30};
            for(int rep=0;rep<5;++rep)for(int h=0;h<2;++h){
                const auto t0=std::chrono::steady_clock::now();launch(h?N:N/2);check(cudaDeviceSynchronize());
                const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();if(ms<best[h])best[h]=ms;}
            std::printf("%-34s %8.3f us per iteration (launch of %d: %.2f ms)\n",name,1e3*(best[1]-best[0])/(N/2),N,best[1]);
        };
        for(int threads:{256,1024})for(int blocks:{1}) {
            char tag[64];std::snprintf(tag,sizeof tag,"[%d threads x %d blocks]",threads,blocks);std::printf("%s\n",tag);
            time("  barrier",[&](int n){kBarrier<<<blocks,threads>>>(out,n);});
            time("  global chase (dependent load)",[&](int n){kChase<<<blocks,threads>>>(next,out,n);});
            time("  global gather (+2 barriers)",[&](int n){kGlobalGather<<<blocks,threads>>>(buf,out,n);});
            time("  shared gather (+2 barriers)",[&](int n){kSharedGather<<<blocks,threads>>>(out,n);});
            time("  gather8 x6 floats, device float4",[&](int n){kGather8V<<<blocks,threads>>>(reinterpret_cast<float4*>(buf),adj,out,n);});
            if(threads<=1024 && blocks*threads<=8*1024) {
                time("  gather8 x6 floats, device",[&](int n){kGather8<<<blocks,threads>>>(buf,adj,out,n);});
                time("  gather8 x6 floats, shared",[&](int n){kGather8Shared<<<blocks,threads>>>(adj,out,n);});
            }
        }
        return 0;
    } catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}
}
