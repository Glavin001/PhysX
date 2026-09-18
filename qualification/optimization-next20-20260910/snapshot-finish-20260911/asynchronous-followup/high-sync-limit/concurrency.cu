#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#define CHECK(x) do {cudaError_t e=(x);if(e!=cudaSuccess){fprintf(stderr,"%s: %s\n",#x,cudaGetErrorString(e));return 2;}}while(0)
__global__ void rendezvous(unsigned* flags,unsigned* results,unsigned id,unsigned long long timeout) {
 atomicExch(flags+id,1u);
 const unsigned long long start=clock64();
 while(!atomicAdd(flags+(1-id),0u) && clock64()-start<timeout) {}
 results[id]=atomicAdd(flags+(1-id),0u)?1u:0u;
}
__global__ void enable(cudaGraphConditionalHandle h){cudaGraphSetConditional(h,1);}
int main(){
 cudaStream_t streams[2]; unsigned *flags,*results; cudaDeviceProp prop;CHECK(cudaGetDeviceProperties(&prop,0));
 for(auto& s:streams)CHECK(cudaStreamCreateWithFlags(&s,cudaStreamNonBlocking));
 CHECK(cudaMalloc(&flags,2*sizeof(unsigned))); CHECK(cudaMalloc(&results,2*sizeof(unsigned)));
 CHECK(cudaMemset(flags,0,2*sizeof(unsigned)));CHECK(cudaMemset(results,0,2*sizeof(unsigned)));CHECK(cudaDeviceSynchronize());
 cudaGraph_t graph;CHECK(cudaGraphCreate(&graph,0));cudaGraphConditionalHandle h;CHECK(cudaGraphConditionalHandleCreate(&h,graph,0,cudaGraphCondAssignDefault));
 cudaKernelNodeParams k{};k.func=(void*)enable;k.gridDim=dim3(1);k.blockDim=dim3(1);void* args[]={&h};k.kernelParams=args;cudaGraphNode_t first;
 CHECK(cudaGraphAddKernelNode(&first,graph,nullptr,0,&k));cudaGraphNodeParams p{};p.type=cudaGraphNodeTypeConditional;p.conditional.handle=h;p.conditional.type=cudaGraphCondTypeIf;p.conditional.size=1;cudaGraphNode_t node;
 CHECK(cudaGraphAddNode(&node,graph,&first,nullptr,1,&p));
 // Three billion GPU clocks gives a bounded overlap check without a CPU rendezvous.
 const unsigned long long timeout=3000000000ull;
 CHECK(cudaStreamBeginCaptureToGraph(streams[0],p.conditional.phGraph_out[0],nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal));
 rendezvous<<<1,1,0,streams[0]>>>(flags,results,0,timeout);cudaGraph_t captured;CHECK(cudaStreamEndCapture(streams[0],&captured));
 cudaGraphExec_t exec;CHECK(cudaGraphInstantiate(&exec,graph,0));
 CHECK(cudaGraphLaunch(exec,streams[0]));rendezvous<<<1,1,0,streams[1]>>>(flags,results,1,timeout);
 CHECK(cudaDeviceSynchronize());unsigned host[2];CHECK(cudaMemcpy(host,results,sizeof(host),cudaMemcpyDeviceToHost));
 printf("RENDEZVOUS %u %u (both 1 requires simultaneous pending kernels)\n",host[0],host[1]);
 CHECK(cudaGraphExecDestroy(exec));CHECK(cudaGraphDestroy(graph));CHECK(cudaFree(flags));CHECK(cudaFree(results));for(auto s:streams)CHECK(cudaStreamDestroy(s));return host[0]&&host[1]?0:3;
}
