// GPU cost per operation: N tiny kernels as plain launches vs inside a graph's conditional body (CuMetal ICB program).
#include <cuda_runtime.h>
#include <cstdio>
#include <chrono>
#include <algorithm>
#include <vector>
__global__ void tiny(unsigned* x,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)x[i]+=1;}
__global__ void setCond(cudaGraphConditionalHandle h,const unsigned* flag){cudaGraphSetConditional(h,*flag);}
int main(int argc,char**argv){
  const int N=argc>1?atoi(argv[1]):60;const unsigned elems=argc>2?atoi(argv[2]):4096;
  unsigned *x,*flag;cudaMalloc(&x,elems*4);cudaMalloc(&flag,4);unsigned one=1;cudaMemcpy(flag,&one,4,cudaMemcpyHostToDevice);
  cudaStream_t s;cudaStreamCreate(&s);
  auto time=[&](auto f){double best=1e9;for(int r=0;r<7;++r){cudaStreamSynchronize(s);auto t0=std::chrono::steady_clock::now();for(int k=0;k<20;++k)f();
    cudaStreamSynchronize(s);best=std::min(best,std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-t0).count()/20);}return best;};
  const double plain=time([&]{for(int i=0;i<N;++i)tiny<<<(elems+255)/256,256,0,s>>>(x,elems);});
  // graph: set conditional, conditional body with N kernels (captured)
  cudaGraph_t g;cudaGraphCreate(&g,0);cudaGraphConditionalHandle h;cudaGraphConditionalHandleCreate(&h,g,0,cudaGraphCondAssignDefault);
  cudaGraphNode_t setNode;{void* args[]={&h,&flag};cudaKernelNodeParams p{};p.func=(void*)setCond;p.gridDim=dim3(1);p.blockDim=dim3(1);p.kernelParams=args;cudaGraphAddKernelNode(&setNode,g,nullptr,0,&p);}
  cudaGraphNodeParams cp{};cp.type=cudaGraphNodeTypeConditional;cp.conditional.handle=h;cp.conditional.type=cudaGraphCondTypeIf;cp.conditional.size=1;
  cudaGraphNode_t condNode;cudaGraphAddNode(&condNode,g,&setNode,1,&cp);cudaGraph_t body=cp.conditional.phGraph_out[0];
  cudaStream_t cs;cudaStreamCreate(&cs);cudaStreamBeginCaptureToGraph(cs,body,nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal);
  for(int i=0;i<N;++i)tiny<<<(elems+255)/256,256,0,cs>>>(x,elems);
  cudaGraph_t cap;cudaStreamEndCapture(cs,&cap);
  cudaGraphExec_t ge;if(cudaGraphInstantiate(&ge,g,0)){printf("instantiate failed\n");return 1;}
  const double graph=time([&]{cudaGraphLaunch(ge,s);});
  one=0;cudaMemcpy(flag,&one,4,cudaMemcpyHostToDevice);
  const double skipped=time([&]{cudaGraphLaunch(ge,s);});
  printf("N=%d elems=%u: plain %.1f us (%.2f/op) | graph taken %.1f us (%.2f/op) | graph skipped %.1f us\n",N,elems,plain,plain/N,graph,graph/N,skipped);
}
