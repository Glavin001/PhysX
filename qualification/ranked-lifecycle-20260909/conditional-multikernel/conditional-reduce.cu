#include <cuda_runtime.h>
#include <cstdio>
#include <cub/cub.cuh>
__global__ void gate(cudaGraphConditionalHandle h){cudaGraphSetConditional(h,1);}
__global__ void barrier(){using R=cub::BlockReduce<unsigned,128>;__shared__ R::TempStorage t;unsigned sum=R(t).Sum(threadIdx.x);if(!threadIdx.x && sum!=8128)asm("trap;");__syncthreads();}
int main(int argc,char**) {
 if(argc>1){barrier<<<1,128>>>();return int(cudaDeviceSynchronize());}
 cudaGraph_t graph;cudaGraphCreate(&graph,0);cudaGraphConditionalHandle h;
 cudaGraphConditionalHandleCreate(&h,graph,0,cudaGraphCondAssignDefault);
 void* args[]={&h};cudaKernelNodeParams p{};p.func=(void*)gate;p.gridDim=dim3(1);p.blockDim=dim3(1);p.kernelParams=args;
 cudaGraphNode_t first,branch,last;cudaGraphAddKernelNode(&first,graph,nullptr,0,&p);
 cudaGraphNodeParams c{};c.type=cudaGraphNodeTypeConditional;c.conditional.handle=h;c.conditional.type=cudaGraphCondTypeIf;c.conditional.size=1;
 cudaGraphAddNode(&branch,graph,&first,1,&c);
 p.func=(void*)barrier;p.blockDim=dim3(128);p.kernelParams=nullptr;cudaGraphAddKernelNode(&last,c.conditional.phGraph_out[0],nullptr,0,&p);
 cudaGraphExec_t exe;auto e=cudaGraphInstantiate(&exe,graph,0);if(e){puts(cudaGetErrorString(e));return 1;}
 e=cudaGraphLaunch(exe,0);if(e){puts(cudaGetErrorString(e));return 2;}
 e=cudaDeviceSynchronize();if(e){puts(cudaGetErrorString(e));return 3;}return 0;
}
