#include <cuda_runtime.h>
#include <cooperative_groups.h>
#include <cstdio>
#include <cstdlib>
#define CK(x) do {auto e=(x);if(e!=cudaSuccess){std::fprintf(stderr,"%s: %s\n",#x,cudaGetErrorString(e));std::exit(2);}}while(0)
struct View {cudaGraphConditionalHandle next;int* output;};
__global__ void begin(View v,cudaGraphConditionalHandle work,int* input) {cudaGraphSetConditional(work,*input);cudaGraphSetConditional(v.next,0);}
__global__ void body(View v) {auto grid=cooperative_groups::this_grid();grid.sync();if(!grid.thread_rank()){atomicAdd(v.output,1);cudaGraphSetConditional(v.next,1);}}
__global__ void continuation(int* output) {atomicAdd(output+1,1);}
int main(){
 cudaStream_t stream;CK(cudaStreamCreate(&stream));cudaGraph_t g;CK(cudaGraphCreate(&g,0));
 View v{};int* input;CK(cudaMalloc(&input,sizeof(int)));CK(cudaMalloc(&v.output,2*sizeof(int)));
 cudaGraphConditionalHandle work;CK(cudaGraphConditionalHandleCreate(&v.next,g,0,cudaGraphCondAssignDefault));CK(cudaGraphConditionalHandleCreate(&work,g,0,cudaGraphCondAssignDefault));
 void* args[]={&v,&work,&input};cudaKernelNodeParams kp{};kp.func=(void*)begin;kp.gridDim=dim3(1);kp.blockDim=dim3(1);kp.kernelParams=args;
 cudaGraphNode_t start;CK(cudaGraphAddKernelNode(&start,g,nullptr,0,&kp));
 cudaGraphNodeParams cp{};cp.type=cudaGraphNodeTypeConditional;cp.conditional.handle=work;cp.conditional.type=cudaGraphCondTypeIf;cp.conditional.size=1;
 cudaGraphNode_t branch;CK(cudaGraphAddNode(&branch,g,&start,nullptr,1,&cp));
 void* ba[]={&v};kp.func=(void*)body;kp.kernelParams=ba;kp.gridDim=dim3(72);kp.blockDim=dim3(128);cudaGraphNode_t bn;CK(cudaGraphAddKernelNode(&bn,cp.conditional.phGraph_out[0],nullptr,0,&kp));
 cudaKernelNodeAttrValue attribute{};attribute.cooperative=1;CK(cudaGraphKernelNodeSetAttribute(bn,cudaKernelNodeAttributeCooperative,&attribute));kp.gridDim=dim3(1);kp.blockDim=dim3(1);
 cp={};cp.type=cudaGraphNodeTypeConditional;cp.conditional.handle=v.next;cp.conditional.type=cudaGraphCondTypeIf;cp.conditional.size=1;
 cudaGraphNode_t tail;CK(cudaGraphAddNode(&tail,g,&branch,nullptr,1,&cp));void* ca[]={&v.output};kp.func=(void*)continuation;kp.kernelParams=ca;CK(cudaStreamBeginCaptureToGraph(stream,cp.conditional.phGraph_out[0],nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal));continuation<<<1,1,0,stream>>>(v.output);cudaGraph_t captured;CK(cudaStreamEndCapture(stream,&captured));
 cudaGraphExec_t exec;CK(cudaGraphInstantiate(&exec,g,0));CK(cudaGraphUpload(exec,stream));int errors=0;
 for(int i=0;i<4;++i){int value=i%2,result[2]={};CK(cudaMemcpyAsync(input,&value,sizeof(int),cudaMemcpyHostToDevice,stream));CK(cudaMemsetAsync(v.output,0,2*sizeof(int),stream));CK(cudaGraphLaunch(exec,stream));CK(cudaMemcpyAsync(result,v.output,sizeof(result),cudaMemcpyDeviceToHost,stream));CK(cudaStreamSynchronize(stream));std::printf("input=%d body=%d continuation=%d\n",value,result[0],result[1]);if(result[0]!=value||result[1]!=value)++errors;}
 CK(cudaGraphExecDestroy(exec));CK(cudaGraphDestroy(g));CK(cudaFree(input));CK(cudaFree(v.output));CK(cudaStreamDestroy(stream));return errors?1:0;
}
